# Flujo del Cache de Localizacion

## Arquitectura General

```
┌─────────────────────────────────────────────────────────────┐
│                    ASP.NET Core App                          │
│                                                             │
│  ┌─────────────────┐  ┌──────────────────────────────────┐  │
│  │  WarmupService   │  │   RefreshService (BackgroundSvc) │  │
│  │  (IHostedService)│  │   Dispara a las 2 AM diario      │  │
│  │  Solo al arranque│  │   5 reintentos con backoff        │  │
│  └────────┬─────────┘  └──────────────┬───────────────────┘  │
│           │                           │                      │
│           ▼                           ▼                      │
│  ┌────────────────────────────────────────────────────────┐  │
│  │            LocalizacionCacheService (Singleton)         │  │
│  │                                                        │  │
│  │  ┌──────────────┐  ┌─────────────┐  ┌──────────────┐  │  │
│  │  │ IMemoryCache  │  │ _lastKnown* │  │ JSON en disco│  │  │
│  │  │ (TTL 24h)     │  │ (static)    │  │ (App_Data/)  │  │  │
│  │  └──────────────┘  └─────────────┘  └──────────────┘  │  │
│  │                                                        │  │
│  │  Indices pre-computados:                               │  │
│  │  - ById (Dictionary)                                   │  │
│  │  - All (IReadOnlyList)                                 │  │
│  │  - ByProvincia (Dictionary<int, List>)                 │  │
│  │  - ByCodigoPostal (Dictionary<string, List>)           │  │
│  └──────────────────────────┬─────────────────────────────┘  │
│                             │                                │
│  ┌──────────────────────────┴─────────────────────────────┐  │
│  │                    Controllers                          │  │
│  │  AplicacionController    GestionInternaSeguraController │  │
│  │  LocalidadesController   SidController                  │  │
│  │  ExpedienteDAO                                          │  │
│  └─────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                             │
                             ▼
                   ┌───────────────────┐
                   │ API Localizacion   │
                   │ (REST externa)     │
                   └───────────────────┘
```

## Flujo de Arranque

```
App inicia
  │
  ├─ 1. ConfigureServices() - registra DI (Singleton)
  │
  ├─ 2. WarmupService.StartAsync() [ANTES de que Kestrel abra el puerto]
  │     │
  │     ├─ Llama GetAllLocalidades() + GetAllProvincias()
  │     │   │
  │     │   ├─ EXITO: cache caliente + persiste JSON a disco
  │     │   │         Kestrel abre puerto con datos listos
  │     │   │
  │     │   └─ FALLA (API caida, timeout, etc.)
  │     │       │
  │     │       └─ TryLoadFromFiles()
  │     │           │
  │     │           ├─ JSON existe: carga desde disco, construye indices
  │     │           │               Kestrel abre puerto con datos del backup
  │     │           │
  │     │           └─ JSON no existe: log error
  │     │                              Kestrel abre puerto sin datos
  │     │                              Se carga en primer request (sincrono)
  │     │
  ├─ 3. RefreshService.ExecuteAsync() [en paralelo, espera hasta las 2 AM]
  │
  └─ 4. Kestrel abre puerto
```

## Flujo de Request (operacion normal)

```
Request HTTP llega
  │
  ├─ Controller llama cache service (ej: GetAllLocalidades())
  │
  └─ GetLocalidadesCacheData()
      │
      ├─ CACHE HIT (IMemoryCache tiene datos y no expiro)
      │   └─ Retorna datos inmediatamente [O(1)]
      │
      ├─ CACHE MISS + hay _lastKnown* (datos stale)
      │   ├─ Re-setea stale en cache con TTL 5 min
      │   ├─ Dispara refresh async en background (fire-and-forget)
      │   └─ Retorna datos stale inmediatamente [O(1)]
      │       │
      │       └─ [Background] RefreshLocalidadesInternal()
      │           ├─ Adquiere SemaphoreSlim
      │           ├─ Llama API
      │           ├─ Construye indices
      │           ├─ Setea en IMemoryCache (TTL 24h)
      │           ├─ Actualiza _lastKnown*
      │           ├─ Persiste JSON a disco
      │           └─ Libera semaforo
      │           Los requests posteriores usan datos frescos
      │
      └─ CACHE MISS + NO hay _lastKnown* (primer arranque sin warm-up ni JSON)
          ├─ Adquiere SemaphoreSlim (bloquea este request)
          ├─ Double-check: otro thread ya cargo?
          ├─ Llama API sincronamente
          ├─ Construye indices, setea cache, persiste JSON
          └─ Retorna datos [1-5 seg de latencia]
```

## Flujo de Refresh Programado (2 AM)

```
RefreshService loop
  │
  ├─ Calcula delay hasta proximas 2:00 AM
  ├─ Task.Delay(delay)
  │
  └─ 2:00 AM: inicia refresh
      │
      ├─ Intento 1: RefreshCache()
      │   ├─ EXITO: cache renovado 24h + JSON actualizado
      │   │         Siguiente refresh: manana 2 AM
      │   │
      │   └─ FALLA: log warning
      │       ├─ Espera 1 min (backoff)
      │       │
      │       ├─ Intento 2: espera 2 min si falla
      │       ├─ Intento 3: espera 4 min si falla
      │       ├─ Intento 4: espera 8 min si falla
      │       └─ Intento 5: ultimo intento
      │           │
      │           ├─ EXITO: cache renovado
      │           └─ FALLA: log error
      │                     Datos stale siguen sirviendo
      │                     Se reintenta manana 2 AM
      │
      └─ Loop: calcula delay hasta proximas 2 AM
```

## Capas de Resiliencia

```
Capa 1: IMemoryCache (TTL 24h)
  │ Datos frescos, acceso O(1)
  │ Si expira:
  ▼
Capa 2: _lastKnown* (static, en memoria)
  │ Datos stale, acceso O(1), dispara refresh async
  │ Si no hay (primer arranque):
  ▼
Capa 3: JSON en disco (App_Data/cache/)
  │ Backup persistente, se lee en warm-up
  │ Si no existe:
  ▼
Capa 4: Carga sincrona desde API
  │ Unico caso bloqueante (primer deploy)
  │ Si API caida:
  ▼
Sin datos (solo posible en primer deploy + API caida + sin JSON)
```

## Persistencia JSON

```
Cuando se persiste:
  - RefreshLocalidadesInternal() exitoso
  - RefreshProvinciasInternal() exitoso
  - Carga sincrona exitosa (primer arranque)

Archivos:
  App_Data/cache/localidades_cache.json   (~50K registros, ~2-4 MB)
  App_Data/cache/provincias_cache.json    (~24 registros, ~2 KB)

Atomic write:
  1. Serializa a JSON (Newtonsoft.Json)
  2. Escribe a archivo temporal en mismo directorio
  3. Borra archivo destino si existe
  4. Rename temporal -> destino
  Si falla: log warning, no interrumpe el flujo

Cuando se lee:
  - WarmupService.StartAsync() cuando la API falla (fallback)
```

## Proteccion contra Concurrencia

```
SemaphoreSlim (1, 1) por coleccion:
  - _localidadesLock: protege RefreshLocalidadesInternal + carga sincrona
  - _provinciasLock: protege RefreshProvinciasInternal + carga sincrona

Interlocked flags para refresh async:
  - _isRefreshingLocalidades: evita multiples Task.Run simultaneos
  - _isRefreshingProvincias: idem

IMemoryCache con StaleTtl (5 min):
  - Cuando se sirven datos stale, se re-setean con TTL corto
  - Evita que multiples requests disparen refresh async redundantes
  - El refresh async reemplaza con TTL 24h al completar
```

## Escenarios de Falla

| Escenario | Impacto en usuario | Recuperacion |
|-----------|-------------------|-------------|
| API caida al arranque, JSON existe | Ninguno - datos del backup | Refresh a las 2 AM |
| API caida al arranque, sin JSON | Primer request bloqueante si API se recupera, sin datos si no | Refresh a las 2 AM o manual |
| API caida a las 2 AM | Ninguno - datos stale siguen sirviendo | 5 reintentos, sino manana |
| API caida + cache expira durante el dia | Ninguno - sirve stale, refresca async | Refresh async o 2 AM |
| Disco lleno (no puede persistir JSON) | Ninguno (warning en log) | Solo pierde backup para proximo restart |
| App crash + restart + API caida | Ninguno si JSON existe | Lee de JSON en warm-up |
