# Sistema de Cache de Localizacion - FuturosSociosApi

## Que es y para que sirve

La API consume datos de localidades y provincias desde un servicio externo (ApiLocalizacion). En lugar de consultar ese servicio en cada request, mantenemos una **copia local en memoria** que se refresca periodicamente. Esto nos da:

- **Respuestas rapidas:** las consultas de localidades y provincias se resuelven en memoria, sin esperar al servicio externo.
- **Disponibilidad:** si el servicio externo esta caido, la API sigue funcionando con los datos cacheados.
- **Menor carga:** se reduce drasticamente la cantidad de llamadas HTTP al servicio de localizacion.

---

## Estructura de archivos

Todos los archivos del sistema de cache estan organizados en dos proyectos:

```
BackendServices/ApiLocalizacion/
  Interfaces/
    ILocalizacionCacheService.cs     --> Contrato del cache service
    IApiLocalizacionClient.cs        --> Contrato del client HTTP
  Services/
    LocalizacionCacheService.cs      --> Logica principal del cache
    ApiLocalizacionClient.cs         --> Comunicacion HTTP con API externa
  Models/
    LocalidadFindAllResponseDto.cs   --> Modelo de localidad
    ProvinciaFindResponseDto.cs      --> Modelo de provincia
    LocalidadFilterDto.cs            --> Filtros de busqueda
    GenericListResult.cs             --> Wrapper de resultado paginado
  LocalizacionCacheOptions.cs        --> Configuracion del cache

FuturosSociosApiMovil/
  Services/
    LocalizacionCacheWarmupService.cs   --> Carga inicial al arrancar
    LocalizacionCacheRefreshService.cs  --> Refresco diario programado
  Startup.cs                            --> Registro de dependencias (lineas 181-190)
  Controllers/
    LocalidadesController.cs            --> Consume el cache
    ProvinciasController.cs             --> Consume el cache
    SidController.cs                    --> Consume el cache
```

---

## Componentes principales

El sistema tiene 4 piezas que trabajan juntas:

```
                        Startup
                           |
                    [Cache Warmup]
                    Carga inicial
                           |
                           v
[ApiLocalizacion] <--- [Cache Service] ---> [Archivo JSON backup]
  (servicio externo)     (memoria)            (App_Data/cache/)
                           ^
                           |
                    [Cache Refresh]
                    Refresco diario 2 AM
                           |
                           v
                    [Controllers]
                    Consumen datos
```

---

### 1. Cache Service

**Archivo:** `BackendServices/ApiLocalizacion/Services/LocalizacionCacheService.cs`
**Interfaz:** `BackendServices/ApiLocalizacion/Interfaces/ILocalizacionCacheService.cs`

Es el componente central. Mantiene en memoria los datos de **localidades** y **provincias** organizados en indices (diccionarios) para busqueda rapida.

#### Indices en memoria

Cuando llegan datos frescos, el metodo `BuildLocalidadCacheData()` (linea 446) los organiza en 4 estructuras:

| Indice | Tipo | Permite buscar por |
|--------|------|--------------------|
| `ById` | `Dictionary<int, LocalidadFindAllResponseDto>` | Una localidad por su ID |
| `ByProvincia` | `Dictionary<int, List<LocalidadFindAllResponseDto>>` | Todas las localidades de una provincia |
| `ByCodigoPostal` | `Dictionary<string, List<LocalidadFindAllResponseDto>>` | Localidades por codigo postal |
| `All` | `IReadOnlyList<LocalidadFindAllResponseDto>` | Listado completo |

Para provincias, `BuildProvinciaCacheData()` (linea 484) crea indices `ById` y `All`.

#### Metodos de consulta

| Metodo | Linea | Que hace |
|--------|-------|----------|
| `GetLocalidad(int id)` | 53 | Busca una localidad por ID en el diccionario `ById` |
| `GetProvincia(int id)` | 60 | Busca una provincia por ID en el diccionario `ById` |
| `GetAllLocalidades()` | 67 | Devuelve la lista completa de localidades |
| `GetAllProvincias()` | 72 | Devuelve la lista completa de provincias |
| `GetLocalidadIdsForProvincia(int idProvincia)` | 77 | Devuelve los IDs de localidades de una provincia (usa indice `ByProvincia`) |
| `FindLocalidadesPorCodigoPostal(string codigoPostal)` | 90 | Busca localidades por codigo postal (usa indice `ByCodigoPostal`) |
| `FindLocalidadesPaginado(...)` | 104 | Busqueda paginada con filtros opcionales (nombre, codigo postal, provincia) |

#### Como resuelve un pedido de datos (ejemplo con localidades)

El metodo interno `GetLocalidadesCacheData()` (linea 253) es el que decide de donde salen los datos:

```
1. Busca en IMemoryCache (linea 255)
   -> Si hay datos vigentes: los devuelve inmediatamente

2. Si no hay en cache pero hay datos "stale" guardados (linea 261):
   -> Devuelve los datos stale al instante
   -> En paralelo, dispara un refresh en background (linea 264)

3. Si no hay nada en memoria (primer arranque sin warmup):
   -> Adquiere un lock (linea 269) para evitar que multiples requests llamen a la API
   -> Verifica de nuevo el cache (double-check, linea 273)
   -> Llama a la API de forma sincrona (linea 280)
   -> Guarda en cache + backup y devuelve
```

Para provincias existe un metodo equivalente: `GetProvinciasCacheData()` (linea 309).

#### Refresco del cache

El metodo `RefreshCacheAsync()` (linea 149) coordina la actualizacion:
- Llama a `RefreshLocalidadesInternalAsync()` (linea 157) que:
  1. Toma un lock (`SemaphoreSlim`, linea 159) para que no haya refrescos simultaneos
  2. Llama al API client (linea 162)
  3. Construye los indices con `BuildLocalidadCacheData()` (linea 166)
  4. Guarda en `IMemoryCache` con TTL de 24 horas (linea 167)
  5. Actualiza la referencia stale `_lastKnownLocalidades` (linea 168)
  6. Persiste a archivo JSON de backup (linea 169)
- Repite lo mismo para provincias con `RefreshProvinciasInternalAsync()` (linea 182)

#### Persistencia en disco

El metodo `PersistToFile()` (linea 416) graba los datos en archivos JSON como backup:
- Escribe primero a un archivo temporal (`.tmp`, linea 429)
- Luego reemplaza el archivo definitivo (lineas 434-436)
- Si el proceso se interrumpe entre ambas operaciones, el cache se reconstruye desde la API en el proximo arranque

El metodo `TryLoadFromFiles()` (linea 365) lee esos archivos cuando la API no esta disponible:
- Busca `localidades_cache.json` y `provincias_cache.json` en el directorio configurado
- Deserializa, construye los indices y los carga en memoria

---

### 2. Warmup Service

**Archivo:** `FuturosSociosApiMovil/Services/LocalizacionCacheWarmupService.cs`

Implementa `IHostedService`, lo que significa que .NET lo ejecuta automaticamente al arrancar la aplicacion.

El metodo `StartAsync()` (linea 21) hace lo siguiente:

```
1. Llama a RefreshCacheAsync() (linea 27)
   -> Intenta traer datos frescos de la API externa

2. Si falla (catch en linea 32):
   -> Intenta TryLoadFromFiles() (linea 35)
   -> Carga desde los JSON de backup

3. Si ambos fallan (linea 41):
   -> Loguea error
   -> El cache se cargara on-demand en el primer request
     (via GetLocalidadesCacheData, paso 3 descrito arriba)
```

---

### 3. Refresh Service

**Archivo:** `FuturosSociosApiMovil/Services/LocalizacionCacheRefreshService.cs`

Hereda de `BackgroundService`, lo que lo convierte en un proceso que corre permanentemente en segundo plano.

El metodo `ExecuteAsync()` (linea 23) funciona en loop:

```
1. Calcula cuanto falta para las 2:00 AM (linea 29, metodo CalculateDelayUntilNext2AM en linea 83)
2. Duerme hasta esa hora (linea 34)
3. Al despertar, intenta refrescar el cache (linea 50)
4. Si falla, reintenta hasta 5 veces (constante MaxRetries, linea 12):
   - Intento 1 falla -> espera 1 minuto
   - Intento 2 falla -> espera 2 minutos
   - Intento 3 falla -> espera 4 minutos
   - Intento 4 falla -> espera 8 minutos
   - Intento 5 falla -> espera 16 minutos
   (backoff exponencial: 2^(intento-1) minutos, linea 59)
5. Si todos fallan, loguea error y vuelve al paso 1 (reintenta manana)
```

---

### 4. API Client

**Archivo:** `BackendServices/ApiLocalizacion/Services/ApiLocalizacionClient.cs`
**Interfaz:** `BackendServices/ApiLocalizacion/Interfaces/IApiLocalizacionClient.cs`

Se encarga de la comunicacion HTTP con el servicio externo de localizacion.

**Metodos:**

| Metodo | Linea | Que hace |
|--------|-------|----------|
| `FindLocalidades(LocalidadFilterDto filtro)` | 29 | Trae localidades con filtros opcionales. Arma la query string dinamicamente (lineas 33-47) segun los filtros que vengan. |
| `FindProvincias(int idPais)` | 53 | Trae todas las provincias de un pais. |

Ambos usan el metodo privado `ExecuteGetAsync()` (linea 62) que:
1. Crea un `HttpClient` con nombre configurado (linea 65)
2. Arma la URL completa: base + endpoint + query string (linea 68)
3. Hace el GET HTTP (linea 69)
4. Deserializa la respuesta JSON (linea 74)
5. Envuelve el resultado en `ApiResponse<T>` con flag de exito/error

---

## Registro de dependencias

**Archivo:** `FuturosSociosApiMovil/Startup.cs`, lineas 181-190

```csharp
services.AddMemoryCache();                                          // linea 181 - Cache en memoria de .NET
services.AddSingleton<IApiLocalizacionClient, ApiLocalizacionClient>(); // linea 183 - Client HTTP
services.Configure<LocalizacionCacheOptions>(options =>             // linea 184 - Configuracion
{
    options.CacheDirectory = Path.Combine(
        Directory.GetCurrentDirectory(), "App_Data", "cache");      // linea 186 - Carpeta de backup
});
services.AddSingleton<ILocalizacionCacheService, LocalizacionCacheService>(); // linea 188 - Cache service
services.AddHostedService<LocalizacionCacheWarmupService>();         // linea 189 - Warmup al arrancar
services.AddHostedService<LocalizacionCacheRefreshService>();        // linea 190 - Refresh diario
```

El cache service y el API client se registran como **Singleton** (una sola instancia para toda la aplicacion) porque los datos en memoria son compartidos por todos los requests.

---

## Ciclo de vida de los datos

### Al iniciar la aplicacion

```
App arranca
  -> WarmupService.StartAsync() se ejecuta
  -> Llama a CacheService.RefreshCacheAsync()
     -> ApiClient.FindLocalidades() hace HTTP GET al servicio externo
     -> ApiClient.FindProvincias() hace HTTP GET al servicio externo
  -> CacheService construye los indices (BuildLocalidadCacheData / BuildProvinciaCacheData)
  -> Datos quedan en IMemoryCache con TTL 24h
  -> Datos se persisten en App_Data/cache/*.json
  -> Cache listo para servir requests
```

### Durante la operacion normal

```
Request del cliente
  -> Controller pide datos al Cache Service (ej: GetAllLocalidades)
  -> CacheService.GetLocalidadesCacheData() busca en IMemoryCache
  -> HIT: devuelve desde memoria (instantaneo)
```

### Cuando el cache expira (cada 24 horas)

```
Cache expira (IMemoryCache descarta el entry despues de 24h)
  -> GetLocalidadesCacheData() detecta cache miss
  -> Encuentra datos en _lastKnownLocalidades (stale)
  -> Devuelve los datos stale al instante con TTL de 5 min
  -> En paralelo, TriggerBackgroundRefreshLocalidades() inicia refresco
  -> Proximo request ya recibe datos actualizados
```

Esto se llama **stale-while-revalidate**: el usuario nunca espera, siempre recibe una respuesta rapida aunque los datos tengan hasta 24 horas de antiguedad.

### Refresco programado (2 AM)

```
2:00 AM
  -> RefreshService despierta
  -> Llama a CacheService.RefreshCacheAsync()
  -> Actualiza memoria + indices + archivos de backup
  -> Si falla, reintenta con backoff exponencial (hasta 5 veces)
  -> Si agota reintentos, vuelve a intentar manana
```

---

## Que pasa si el servicio externo esta caido?

El sistema tiene **3 niveles de fallback**:

| Nivel | Situacion | Que pasa | Donde esta en el codigo |
|-------|-----------|----------|-------------------------|
| 1 | Cache en memoria vigente | Datos frescos, sin demora | `GetLocalidadesCacheData()` linea 255 |
| 2 | Cache expirado pero datos previos disponibles | Datos "stale" (< 24h), sin demora + refresco async | `GetLocalidadesCacheData()` linea 261 |
| 3 | Memoria vacia, API caida al arrancar | Carga desde archivos JSON de backup | `TryLoadFromFiles()` linea 365 |

Solo si los 3 niveles fallan (primera ejecucion + servicio caido + sin archivos de backup) el endpoint devolveria datos vacios.

---

## Donde se usa

Los controllers que consumen datos de localizacion inyectan `ILocalizacionCacheService` y lo usan en lugar de llamar al servicio externo:

### LocalidadesController

**Archivo:** `FuturosSociosApiMovil/Controllers/LocalidadesController.cs`

```csharp
// Lineas 31-34 del metodo Get()
var localidades = _localizacionCache.GetAllLocalidades();
var provincias = _localizacionCache.GetAllProvincias();
respuesta.Modelo = Mapper.MapLocalidadesConProvincia(localidades, provincias);
```

Obtiene todas las localidades y provincias del cache, las cruza para agregar el nombre de provincia a cada localidad, y devuelve el resultado.

### SidController

**Archivo:** `FuturosSociosApiMovil/Controllers/SidController.cs`

Usa `FindLocalidadesPorCodigoPostal()` para resolver la localidad de una persona a partir de su codigo postal, y `GetProvincia()` para obtener el nombre de la provincia.

### ProvinciasController

**Archivo:** `FuturosSociosApiMovil/Controllers/ProvinciasController.cs`

Usa `GetAllProvincias()` para devolver el listado de provincias.

---

## Configuracion

**Archivo:** `BackendServices/ApiLocalizacion/LocalizacionCacheOptions.cs`

```csharp
public class LocalizacionCacheOptions
{
    public string CacheDirectory { get; set; }     // Carpeta para archivos de backup
    public int IdPaisDefault { get; set; } = 1;    // Pais por defecto (1 = Argentina)
}
```

### Valores actuales

| Parametro | Valor | Donde se define |
|-----------|-------|-----------------|
| Duracion del cache | 24 horas | `LocalizacionCacheService.cs` linea 22 |
| Datos stale | 5 minutos | `LocalizacionCacheService.cs` linea 23 |
| Refresco programado | 2:00 AM diario | `LocalizacionCacheRefreshService.cs` linea 86 |
| Reintentos | 5 intentos | `LocalizacionCacheRefreshService.cs` linea 12 |
| Pais por defecto | Argentina (ID: 1) | `LocalizacionCacheOptions.cs` linea 6 |
| Backup en disco | `App_Data/cache/` | `Startup.cs` linea 186 |
| Archivos de backup | `localidades_cache.json`, `provincias_cache.json` | `LocalizacionCacheService.cs` lineas 20-21 |

---

## Resumen visual

```
ARRANQUE:   WarmupService.StartAsync()
              -> CacheService.RefreshCacheAsync()
                -> ApiClient.FindLocalidades() --(HTTP)--> API externa
                -> ApiClient.FindProvincias()  --(HTTP)--> API externa
              -> BuildLocalidadCacheData() / BuildProvinciaCacheData()
              -> IMemoryCache.Set() (24h TTL)
              -> PersistToFile() -> App_Data/cache/*.json

OPERACION:  Controller.Get()
              -> CacheService.GetAllLocalidades()
                -> IMemoryCache.TryGetValue() -> HIT -> return datos

STALE:      IMemoryCache expira (24h)
              -> GetLocalidadesCacheData() -> MISS
              -> _lastKnownLocalidades != null -> return stale (5 min TTL)
              -> TriggerBackgroundRefreshLocalidades() -> refresco async

REFRESH:    RefreshService.ExecuteAsync()
              -> Espera hasta 2:00 AM
              -> CacheService.RefreshCacheAsync()
              -> Si falla: retry x5 con backoff exponencial
              -> Si todo falla: reintenta manana

FALLBACK:   API caida al arrancar
              -> WarmupService catch -> TryLoadFromFiles()
              -> Lee App_Data/cache/*.json
              -> Construye indices y carga en memoria
```
