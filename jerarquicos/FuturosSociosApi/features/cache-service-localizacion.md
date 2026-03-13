# Patron: Cache Service en Memoria para Datos de Catalogo

**Fecha:** 2026-03-12
**Origen:** Implementacion `LocalizacionCacheService` — rama `feature/186929_eliminar_localidad_provincia_ef_core`
**Aplica a:** Datos de catalogo de alto volumen, lectura frecuente, actualizacion infrecuente (localidades, provincias, planes, etc.)

---

## Cuando usar este patron

- Los datos son de solo lectura para la gran mayoria de las operaciones
- El volumen es manejable en memoria (miles de registros, no millones)
- La fuente es una API externa (no la DB local)
- La latencia de la fuente es inaceptable en cada request
- La disponibilidad de la fuente no puede impactar la disponibilidad de la app

---

## Arquitectura del patron

```
ApiLocalizacion (fuente)
    |
    v
ApiLocalizacionClient (HTTP client, IApiLocalizacionClient)
    |
    v
LocalizacionCacheService (ILocalizacionCacheService, Singleton)
    |-- IMemoryCache (datos vivos, TTL 24h)
    |-- _lastKnownXxx (datos stale para fallback)
    |-- Indices secundarios (ByProvincia, ByCodigoPostal)
    |-- Persistencia a disco (localidades_cache.json, provincias_cache.json)
    |
    ^-- LocalizacionCacheWarmupService (IHostedService, precarga al inicio)
    ^-- LocalizacionCacheRefreshService (BackgroundService, refresh cada 12h)
```

---

## Estrategia de disponibilidad (3 capas)

### Capa 1: Cache caliente (IMemoryCache, TTL 24h)
Servicio normal. Si el TTL no expiro, los datos se sirven en microsegundos desde memoria.

### Capa 2: Stale-while-revalidate
Si el TTL expiro pero `_lastKnownXxx != null`, se sirven datos stale inmediatamente y se lanza un refresh en background (`Task.Run`). El request no espera.

```csharp
if (_lastKnownLocalidades != null)
{
    _cache.Set(CacheKeyLocalidades, _lastKnownLocalidades, StaleTtl); // renueva por 5 min
    TriggerBackgroundRefreshLocalidades();
    return _lastKnownLocalidades; // respuesta inmediata
}
```

### Capa 3: Carga sincronica (solo primer arranque sin warmup)
Si no hay nada en memoria ni en `_lastKnown`, se carga sincrónicamente desde la API con double-check locking via `SemaphoreSlim`.

**Advertencia:** Esta capa bloquea un thread del pool durante la llamada HTTP. En produccion el warmup garantiza que nunca se llega aqui.

### Fallback a disco
Si la API esta caida al arrancar, `LocalizacionCacheWarmupService` intenta cargar desde archivos JSON persistidos en disco. Si existen, la app arranca con datos del cache anterior.

---

## Indices secundarios

`BuildLocalidadCacheData` construye 3 indices para acceso O(1):

| Indice | Clave | Uso |
|--------|-------|-----|
| `ById` | `int` (Id localidad) | Lookup por ID |
| `ByProvincia` | `int` (IdProvincia) | Filtro por provincia en queries EF |
| `ByCodigoPostal` | `string` (CP, case-insensitive) | Lookup por CP en SID/Renaper |

---

## Persistencia a disco

Al hacer refresh exitoso, los datos se escriben a `.json` en `LocalizacionCacheDirectory` (configurable en `appsettings`):

```csharp
// Escritura atomica: escribe a .tmp, luego rename
var tempPath = targetPath + ".tmp";
File.WriteAllText(tempPath, json);
File.Move(tempPath, targetPath, overwrite: true); // .NET 6+
```

Esto evita que un crash durante la escritura deje el archivo corrupto.

---

## Configuracion

**appsettings.json:**
```json
{
  "RutaApiLocalizacion": "https://api-localizacion.jerarquicos.com/api/Localizacion/",
  "LocalizacionCacheDirectory": "C:\\cache\\localizacion"
}
```

**Startup.cs:**
```csharp
services.AddMemoryCache();
services.Configure<LocalizacionCacheOptions>(o =>
    o.CacheDirectory = Configuration["LocalizacionCacheDirectory"]);
services.AddSingleton<ILocalizacionCacheService, LocalizacionCacheService>();
services.AddSingleton<IApiLocalizacionClient, ApiLocalizacionClient>();
services.AddHostedService<LocalizacionCacheWarmupService>();
services.AddHostedService<LocalizacionCacheRefreshService>();
```

**Nota importante:** `IApiLocalizacionClient` debe registrarse como `Singleton` (no `Scoped`) si va a ser consumido por `LocalizacionCacheService` (que es Singleton). Internamente, `LocalizacionCacheService` usa `IServiceScopeFactory` para resolver `IApiLocalizacionClient` en un scope manual — esto es correcto si el client es Scoped, pero si es Singleton se puede inyectar directamente.

---

## Reglas de uso en controllers y DAOs

### Correcto — obtener datos del cache
```csharp
var localidades = _localizacionCache.GetAllLocalidades();
var provincias = _localizacionCache.GetAllProvincias();
```

### Correcto — filtro por provincia en EF (via IDs del cache)
```csharp
var localidadIds = _localizacionCache.GetLocalidadIdsForProvincia(idProvincia.Value);
query = query.Where(e => e.Titular.Domicilio.Any(d =>
    d.IdLocalidad.HasValue && localidadIds.Contains(d.IdLocalidad.Value)));
```

**Advertencia:** Si la provincia tiene muchas localidades (500+), el `IN (...)` generado por EF puede ser costoso. Monitorear con provincias grandes.

### Correcto — resolver descripcion post-query
```csharp
var loc = _localizacionCache.GetLocalidad(domicilio.IdLocalidad.Value);
domicilio.Localidad = loc?.Nombre ?? string.Empty;
if (loc != null)
{
    var prov = _localizacionCache.GetProvincia(loc.IdProvincia);
    domicilio.Provincia = prov?.Nombre ?? string.Empty;
}
```

---

## Advertencias conocidas

1. **No usar para datos que cambian frecuentemente.** El cache se actualiza cada 12h. Si los datos de la fuente cambian con alta frecuencia, usar otro patron.
2. **El warmup bloquea el startup.** Si la API esta caida y no hay cache en disco, el startup espera o falla. Evaluar hacer el warmup no-bloqueante con `Task.Run`.
3. **`IdPaisArgentina = 1` hardcodeado.** Mover a configuracion si se requiere soporte multi-pais.

---

## Archivos clave

| Archivo | Responsabilidad |
|---------|----------------|
| `BackendServices/ApiLocalizacion/Interfaces/ILocalizacionCacheService.cs` | Contrato del cache |
| `BackendServices/ApiLocalizacion/Services/LocalizacionCacheService.cs` | Implementacion (515 lineas) |
| `BackendServices/ApiLocalizacion/Services/ApiLocalizacionClient.cs` | HTTP client para la API |
| `FuturosSociosApiMovil/Services/LocalizacionCacheWarmupService.cs` | Precarga al inicio |
| `FuturosSociosApiMovil/Services/LocalizacionCacheRefreshService.cs` | Refresh periodico cada 12h |
| `FuturosSociosApiMovil/Extensions/LocalidadMappingExtensions.cs` | Mapeo LocalidadDto -> ViewModel con ProvinciaDescripcion |
