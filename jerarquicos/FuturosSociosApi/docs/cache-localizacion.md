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
  LocalizacionCacheOptions.cs        --> Configuracion del cache (constantes + propiedades)
  LocalizacionLogMessages.cs         --> Constantes de mensajes de log

FuturosSociosApiMovil/
  Services/
    LocalizacionCacheWarmupService.cs   --> Carga inicial al arrancar
    LocalizacionCacheRefreshService.cs  --> Refresco diario programado
  Startup.cs                            --> Registro de dependencias (lineas 182-193)
  Controllers/
    LocalidadesController.cs            --> Consume el cache
    ProvinciasController.cs             --> Consume el cache
    SidController.cs                    --> Consume el cache
```

---

## Componentes principales

El sistema tiene 6 componentes:

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
                    Refresco diario
                           |
                           v
                    [Controllers]
                    Consumen datos
```

---

### 1. Cache Options

**Archivo:** `BackendServices/ApiLocalizacion/LocalizacionCacheOptions.cs`

Define las constantes por defecto y las propiedades configurables del sistema:

```csharp
public class LocalizacionCacheOptions
{
    public const int IdPaisArgentina = 1;
    public const int DefaultCacheDurationHours = 24;
    public const int DefaultStaleTtlMinutes = 5;
    public const int DefaultRefreshHour = 2;
    public const int DefaultRefreshMaxRetries = 5;
    public const string DefaultCacheDirectory = "App_Data/cache";

    public string CacheDirectory { get; set; } = DefaultCacheDirectory;
    public int IdPaisDefault { get; set; } = IdPaisArgentina;
    public int CacheDurationHours { get; set; } = DefaultCacheDurationHours;
    public int StaleTtlMinutes { get; set; } = DefaultStaleTtlMinutes;
    public int RefreshHour { get; set; } = DefaultRefreshHour;
    public int RefreshMaxRetries { get; set; } = DefaultRefreshMaxRetries;
}
```

Todas las propiedades se pueden sobreescribir desde `appsettings.json` en la seccion `LocalizacionCache`. Si no se configuran, usan las constantes como valor por defecto.

---

### 2. Cache Service

**Archivo:** `BackendServices/ApiLocalizacion/Services/LocalizacionCacheService.cs`
**Interfaz:** `BackendServices/ApiLocalizacion/Interfaces/ILocalizacionCacheService.cs`

Es el componente central. Mantiene en memoria los datos de **localidades** y **provincias** organizados en indices (diccionarios) para busqueda rapida.

#### Constantes locales (no configurables)

Definidas al inicio de la clase (lineas 22-23):

| Constante | Valor | Proposito |
|-----------|-------|-----------|
| `DefaultPageSize` | 20 | Tamanio de pagina por defecto en `FindLocalidadesPaginado` cuando no se especifica `pageSize` |
| `ProvinciaPerformanceWarningThreshold` | 200 | Si una provincia tiene mas de 200 localidades, se loguea un warning porque el `IN` clause que genera EF Core puede impactar performance |

#### Indices en memoria

Cuando llegan datos frescos, el metodo `BuildLocalidadCacheData()` (linea 450) los organiza en 4 estructuras:

| Indice | Tipo | Permite buscar por |
|--------|------|--------------------|
| `ById` | `Dictionary<int, LocalidadFindAllResponseDto>` | Una localidad por su ID |
| `ByProvincia` | `Dictionary<int, List<LocalidadFindAllResponseDto>>` | Todas las localidades de una provincia |
| `ByCodigoPostal` | `Dictionary<string, List<LocalidadFindAllResponseDto>>` | Localidades por codigo postal (case-insensitive via `StringComparer.OrdinalIgnoreCase`) |
| `All` | `IReadOnlyList<LocalidadFindAllResponseDto>` | Listado completo |

Para provincias, `BuildProvinciaCacheData()` (linea 488) crea 2 estructuras:

| Indice | Tipo | Permite buscar por |
|--------|------|--------------------|
| `ById` | `Dictionary<int, ProvinciaFindResponseDto>` | Una provincia por su ID |
| `All` | `IReadOnlyList<ProvinciaFindResponseDto>` | Listado completo |

#### Metodos de consulta

| Metodo | Linea | Que hace |
|--------|-------|----------|
| `GetLocalidad(int id)` | 57 | Busca una localidad por ID en el diccionario `ById` |
| `GetProvincia(int id)` | 64 | Busca una provincia por ID en el diccionario `ById` |
| `GetAllLocalidades()` | 71 | Devuelve la lista completa de localidades |
| `GetAllProvincias()` | 76 | Devuelve la lista completa de provincias |
| `GetLocalidadIdsForProvincia(int idProvincia)` | 81 | Devuelve los IDs de localidades de una provincia (usa indice `ByProvincia`). Si supera `ProvinciaPerformanceWarningThreshold`, loguea warning. |
| `FindLocalidadesPorCodigoPostal(string codigoPostal)` | 94 | Busca localidades por codigo postal (normaliza a uppercase, usa indice `ByCodigoPostal`) |
| `FindLocalidadesPaginado(...)` | 108 | Busqueda paginada con filtros opcionales (nombre, codigo postal, provincia). Usa indice `ByProvincia` como optimizacion cuando el unico filtro es provincia. |

#### Como resuelve un pedido de datos

Los metodos publicos de consulta (`GetAllLocalidades()`, `GetLocalidad()`, `FindLocalidadesPaginado()`, etc.) son **sincronos** (no son `async`). Esto es intencional: en el 99% de los casos los datos estan en memoria y no hay nada asincrono que esperar, por lo que no tiene sentido forzar `await` en cada controller que los consume.

El metodo interno `GetLocalidadesCacheData()` (linea 257) es el que decide de donde salen los datos:

```
1. Busca en IMemoryCache (linea 259)
   -> Si hay datos vigentes: los devuelve inmediatamente

2. Si no hay en cache pero hay datos "stale" guardados (linea 265):
   -> Devuelve los datos stale al instante
   -> Los re-inserta en cache con TTL corto (StaleTtlMinutes, linea 267)
   -> En paralelo, dispara TriggerBackgroundRefreshLocalidades() (linea 268)

3. Si no hay nada en memoria (primer arranque sin warmup):
   -> Adquiere un lock (SemaphoreSlim, linea 273) para evitar requests simultaneos a la API
   -> Verifica de nuevo el cache (double-check, linea 277)
   -> Llama a la API via Task.Run().GetAwaiter().GetResult() (linea 284)
      Nota: es una llamada sincrona bloqueante (sync-over-async) porque el metodo
      no es async. Este caso solo ocurre si el warmup fallo y es el primer request.
   -> Guarda en cache + backup y devuelve
   -> Si la API tambien falla, devuelve datos vacios (linea 303)
```

Para provincias existe un metodo equivalente `GetProvinciasCacheData()` (linea 313) con la misma logica de 3 niveles.

#### Refresco del cache

El metodo `RefreshCacheAsync()` (linea 153) coordina la actualizacion:
- Llama a `RefreshLocalidadesInternalAsync()` (linea 161) que:
  1. Toma un lock (`SemaphoreSlim`, linea 163) para que no haya refrescos simultaneos
  2. Llama al API client con filtro `IdPais = _idPaisDefault` (linea 166)
  3. Valida que la respuesta tenga datos (linea 168)
  4. Construye los indices con `BuildLocalidadCacheData()` (linea 170)
  5. Guarda en `IMemoryCache` con TTL configurable (`_cacheDuration`, linea 171)
  6. Actualiza la referencia stale `_lastKnownLocalidades` (linea 172)
  7. Persiste a archivo JSON de backup (linea 173)
- Repite lo mismo para provincias con `RefreshProvinciasInternalAsync()` (linea 186)

#### Background refresh (stale-while-revalidate)

Los metodos `TriggerBackgroundRefreshLocalidades()` (linea 211) y `TriggerBackgroundRefreshProvincias()` (linea 234) usan `Interlocked.CompareExchange` como flag atomico para garantizar que solo un refresh corra a la vez por tipo de dato. Si ya hay un refresh en curso, el trigger es no-op. El refresh se ejecuta en `Task.Run()` para no bloquear el request actual.

#### Persistencia en disco

El metodo `PersistToFile()` (linea 420) graba los datos en archivos JSON como backup:
- Crea el directorio si no existe (linea 427)
- Escribe primero a un archivo temporal (`.tmp`, linea 433)
- Luego elimina el archivo destino y mueve el temporal (lineas 438-440)
- En .NET 3.1 no se puede usar `File.Move(src, dst, overwrite:true)`, por eso se usa delete-then-move. Si el proceso se interrumpe entre ambas operaciones, el cache se reconstruye desde la API en el proximo arranque.

El metodo `TryLoadFromFiles()` (linea 369) lee esos archivos cuando la API no esta disponible:
- Busca `localidades_cache.json` y `provincias_cache.json` en el directorio configurado
- Valida que ambos archivos existan y tengan contenido (lineas 382-398)
- Deserializa, construye los indices y los carga en memoria con TTL completo
- Actualiza las referencias stale (`_lastKnownLocalidades`, `_lastKnownProvincias`)

---

### 3. Warmup Service

**Archivo:** `FuturosSociosApiMovil/Services/LocalizacionCacheWarmupService.cs`

Implementa `IHostedService`, lo que significa que .NET lo ejecuta automaticamente al arrancar la aplicacion.

El metodo `StartAsync()` (linea 22) hace lo siguiente:

```
1. Llama a RefreshCacheAsync() (linea 28)
   -> Intenta traer datos frescos de la API externa

2. Si falla (catch en linea 32):
   -> Intenta TryLoadFromFiles() (linea 36)
   -> Carga desde los JSON de backup

3. Si ambos fallan (linea 40):
   -> Loguea error
   -> El cache se cargara on-demand en el primer request
     (via GetLocalidadesCacheData, paso 3 descrito arriba)
```

---

### 4. Refresh Service

**Archivo:** `FuturosSociosApiMovil/Services/LocalizacionCacheRefreshService.cs`

Hereda de `BackgroundService`, lo que lo convierte en un proceso que corre permanentemente en segundo plano.

Lee la configuracion desde `LocalizacionCacheOptions` en el constructor (lineas 27-28):
- `_refreshHour`: hora del dia para ejecutar el refresco (clamped entre 0 y 23)
- `_maxRetries`: cantidad maxima de reintentos

El metodo `ExecuteAsync()` (linea 31) funciona en loop:

```
1. Calcula cuanto falta para la hora configurada (linea 37, metodo CalculateDelayUntilNextRefresh en linea 91)
2. Duerme hasta esa hora (linea 42)
3. Al despertar, intenta refrescar el cache (linea 58)
4. Si falla, reintenta hasta _maxRetries veces (linea 53):
   - Intento 1 falla -> espera 1 minuto
   - Intento 2 falla -> espera 2 minutos
   - Intento 3 falla -> espera 4 minutos
   - Intento 4 falla -> espera 8 minutos
   - Intento 5 falla -> espera 16 minutos
   (backoff exponencial: 2^(intento-1) minutos, linea 67)
5. Si todos fallan, loguea error y vuelve al paso 1 (reintenta manana)
```

---

### 5. API Client

**Archivo:** `BackendServices/ApiLocalizacion/Services/ApiLocalizacionClient.cs`
**Interfaz:** `BackendServices/ApiLocalizacion/Interfaces/IApiLocalizacionClient.cs`

Se encarga de la comunicacion HTTP con el servicio externo de localizacion.

**Metodos:**

| Metodo | Linea | Que hace |
|--------|-------|----------|
| `FindLocalidades(LocalidadFilterDto filtro)` | 29 | Trae localidades con filtros opcionales. Arma la query string dinamicamente (lineas 33-46) segun los filtros que vengan. Siempre incluye `PageNumber`, `PageSize` y `OrderBy=Nombre,ASC`. |
| `FindProvincias(int idPais)` | 53 | Trae todas las provincias de un pais, ordenadas por nombre. |

Ambos usan el metodo privado `ExecuteGetAsync()` (linea 62) que:
1. Crea un `HttpClient` via `IHttpClientFactory` con named client (linea 65)
2. Arma la URL completa: `RutaApiLocalizacion` + endpoint + query string (linea 68)
3. Hace el GET HTTP (linea 69)
4. Deserializa la respuesta JSON con `Newtonsoft.Json` (linea 74)
5. Envuelve el resultado en `ApiResponse<T>` con flag de exito/error

`FindProvincias` usa adicionalmente `ToListResponse()` (linea 101) para extraer la lista de `Registers` del wrapper `GenericListResult` y devolver directamente `ApiResponse<List<ProvinciaFindResponseDto>>`.

---

### 6. Log Messages

**Archivo:** `BackendServices/ApiLocalizacion/LocalizacionLogMessages.cs`

Clase estatica interna con constantes de string para todos los mensajes de log del sistema de cache. Existe porque el proyecto `BackendServices` no puede referenciar `FuturosSociosApiMovil.Recursos.StringValues`, asi que duplica los mensajes relevantes. Los servicios del host (`WarmupService`, `RefreshService`) usan `StringValues` directamente.

---

## Registro de dependencias

**Archivo:** `FuturosSociosApiMovil/Startup.cs`, lineas 182-193

```csharp
services.AddMemoryCache();                                              // linea 182 - Cache en memoria de .NET
services.AddSingleton<IApiLocalizacionClient, ApiLocalizacionClient>(); // linea 184 - Client HTTP
services.Configure<LocalizacionCacheOptions>(options =>                 // linea 185 - Configuracion
{
    Configuration.GetSection("LocalizacionCache").Bind(options);        // linea 187 - Lee de appsettings.json
    options.CacheDirectory = Path.Combine(
        Directory.GetCurrentDirectory(), options.CacheDirectory);       // linea 189 - Resuelve path absoluto
});
services.AddSingleton<ILocalizacionCacheService, LocalizacionCacheService>(); // linea 191 - Cache service
services.AddHostedService<LocalizacionCacheWarmupService>();             // linea 192 - Warmup al arrancar
services.AddHostedService<LocalizacionCacheRefreshService>();            // linea 193 - Refresh diario
```

El cache service y el API client se registran como **Singleton** (una sola instancia para toda la aplicacion) porque los datos en memoria son compartidos por todos los requests.

La configuracion se lee primero de la seccion `LocalizacionCache` de `appsettings.json` via `Bind()`. Luego resuelve `CacheDirectory` a path absoluto combinandolo con el directorio actual. El default `"App_Data/cache"` viene de `LocalizacionCacheOptions.DefaultCacheDirectory`.

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
  -> Datos quedan en IMemoryCache con TTL configurable (default 24h)
  -> Datos se persisten en App_Data/cache/*.json
  -> Referencias stale (_lastKnownLocalidades, _lastKnownProvincias) actualizadas
  -> Cache listo para servir requests
```

### Durante la operacion normal

```
Request del cliente
  -> Controller pide datos al Cache Service (ej: GetAllLocalidades)
  -> CacheService.GetLocalidadesCacheData() busca en IMemoryCache
  -> HIT: devuelve desde memoria (instantaneo)
```

### Cuando el cache expira

```
Cache expira (IMemoryCache descarta el entry despues de CacheDurationHours)
  -> GetLocalidadesCacheData() detecta cache miss
  -> Encuentra datos en _lastKnownLocalidades (stale)
  -> Devuelve los datos stale al instante con TTL de StaleTtlMinutes
  -> En paralelo, TriggerBackgroundRefreshLocalidades() inicia refresco
  -> Proximo request ya recibe datos actualizados
```

Esto se llama **stale-while-revalidate**: el usuario nunca espera, siempre recibe una respuesta rapida aunque los datos tengan hasta 24 horas de antiguedad.

### Refresco programado

```
Hora configurada (default 2:00 AM)
  -> RefreshService despierta
  -> Llama a CacheService.RefreshCacheAsync()
  -> Actualiza memoria + indices + archivos de backup
  -> Si falla: retry con backoff exponencial (hasta RefreshMaxRetries veces)
  -> Si agota reintentos: reintenta manana
```

---

## Que pasa si el servicio externo esta caido?

El sistema tiene **3 niveles de fallback**:

| Nivel | Situacion | Que pasa | Donde esta en el codigo |
|-------|-----------|----------|-------------------------|
| 1 | Cache en memoria vigente | Datos frescos, sin demora | `GetLocalidadesCacheData()` linea 259 |
| 2 | Cache expirado pero datos previos disponibles | Datos "stale", sin demora + refresco async en background | `GetLocalidadesCacheData()` linea 265 |
| 3 | Memoria vacia, API caida al arrancar | Carga desde archivos JSON de backup | `TryLoadFromFiles()` linea 369 |

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

Obtiene todas las localidades y provincias del cache, las cruza mediante el extension method `MapLocalidadesConProvincia` para agregar el nombre de provincia a cada localidad, y devuelve el resultado.

### SidController

**Archivo:** `FuturosSociosApiMovil/Controllers/SidController.cs`

Usa `FindLocalidadesPorCodigoPostal()` para resolver la localidad de una persona a partir de su codigo postal, y `GetProvincia()` para obtener el nombre de la provincia.

### ProvinciasController

**Archivo:** `FuturosSociosApiMovil/Controllers/ProvinciasController.cs`

Usa `GetAllProvincias()` para devolver el listado de provincias.

---

## Configuracion

### Seccion en appsettings.json

```json
"LocalizacionCache": {
    "CacheDurationHours": 24,
    "StaleTtlMinutes": 5,
    "RefreshHour": 2,
    "RefreshMaxRetries": 5
}
```

### Tabla de valores

| Parametro | Valor default | Configurable via appsettings | Donde se define/consume |
|-----------|---------------|------------------------------|-------------------------|
| `CacheDurationHours` | 24 horas | Si (`LocalizacionCache:CacheDurationHours`) | `LocalizacionCacheOptions.cs` linea 6, consumido en constructor de `LocalizacionCacheService` linea 53 |
| `StaleTtlMinutes` | 5 minutos | Si (`LocalizacionCache:StaleTtlMinutes`) | `LocalizacionCacheOptions.cs` linea 7, consumido en constructor linea 54 |
| `RefreshHour` | 2 (2:00 AM) | Si (`LocalizacionCache:RefreshHour`) | `LocalizacionCacheOptions.cs` linea 8, consumido en constructor de `LocalizacionCacheRefreshService` linea 27 |
| `RefreshMaxRetries` | 5 intentos | Si (`LocalizacionCache:RefreshMaxRetries`) | `LocalizacionCacheOptions.cs` linea 9, consumido en constructor de `LocalizacionCacheRefreshService` linea 28 |
| `IdPaisDefault` | 1 (Argentina) | Si (`LocalizacionCache:IdPaisDefault`) | `LocalizacionCacheOptions.cs` linea 12, consumido en constructor de `LocalizacionCacheService` linea 52 |
| `CacheDirectory` | `App_Data/cache` | Si (`LocalizacionCache:CacheDirectory`) | `LocalizacionCacheOptions.cs` linea 11, resuelto a path absoluto en `Startup.cs` linea 189 |
| Archivos de backup | `localidades_cache.json`, `provincias_cache.json` | No (constantes) | `LocalizacionCacheService.cs` lineas 20-21 |
| `DefaultPageSize` | 20 | No (constante local) | `LocalizacionCacheService.cs` linea 22 |
| `ProvinciaPerformanceWarningThreshold` | 200 | No (constante local) | `LocalizacionCacheService.cs` linea 23 |

---

## Resumen visual

```
ARRANQUE:   WarmupService.StartAsync()
              -> CacheService.RefreshCacheAsync()
                -> ApiClient.FindLocalidades() --(HTTP)--> API externa
                -> ApiClient.FindProvincias()  --(HTTP)--> API externa
              -> BuildLocalidadCacheData() / BuildProvinciaCacheData()
              -> IMemoryCache.Set() (CacheDurationHours TTL)
              -> _lastKnownLocalidades / _lastKnownProvincias actualizados
              -> PersistToFile() -> App_Data/cache/*.json

OPERACION:  Controller.Get()
              -> CacheService.GetAllLocalidades()
                -> IMemoryCache.TryGetValue() -> HIT -> return datos

STALE:      IMemoryCache expira (CacheDurationHours)
              -> GetLocalidadesCacheData() -> MISS
              -> _lastKnownLocalidades != null -> return stale (StaleTtlMinutes TTL)
              -> TriggerBackgroundRefreshLocalidades() -> refresco async
              -> Interlocked.CompareExchange evita refrescos duplicados

REFRESH:    RefreshService.ExecuteAsync()
              -> Espera hasta RefreshHour
              -> CacheService.RefreshCacheAsync()
              -> Si falla: retry x RefreshMaxRetries con backoff exponencial
              -> Si todo falla: reintenta manana

FALLBACK:   API caida al arrancar
              -> WarmupService catch -> TryLoadFromFiles()
              -> Lee App_Data/cache/*.json
              -> Construye indices y carga en memoria
              -> Actualiza _lastKnown* para stale-while-revalidate
```
