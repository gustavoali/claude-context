# Warm-up del Cache de Localizacion

## Que es

`LocalizacionCacheWarmupService` es un `IHostedService` que precarga el cache de localidades y provincias durante el arranque de la aplicacion, antes de que Kestrel comience a aceptar requests HTTP.

## Por que se necesita

Sin warm-up, el primer request que toque localidades o provincias paga el costo completo de:
1. Llamada HTTP a la API de localizacion
2. Descarga de ~50.000 localidades (JSON)
3. Deserializacion
4. Construccion de indices (ById, ByProvincia, ByCodigoPostal)
5. Cache en memoria

Esto puede tomar 1-5 segundos dependiendo de la red y la carga de la API. Si ese primer request es de un usuario real (no un health check), la experiencia es mala.

## Como funciona

### Ciclo de vida en ASP.NET Core 3.1

```
1. ConfigureServices()           -- registro de DI
2. IHostedService.StartAsync()   -- WARM-UP ACA (antes de aceptar requests)
3. Configure()                   -- middleware pipeline
4. Kestrel empieza a escuchar    -- primer request ya tiene cache caliente
```

`IHostedService.StartAsync()` se ejecuta **antes** de que Kestrel abra el puerto. Esto garantiza que ningun request llegue con cache frio.

### Que hace el warm-up

```csharp
var localidades = _cacheService.GetAllLocalidades();  // fuerza carga de ~50K localidades
var provincias = _cacheService.GetAllProvincias();     // fuerza carga de ~24 provincias
```

Al llamar `GetAllLocalidades()`, el `LocalizacionCacheService` detecta que el cache esta vacio, adquiere el `SemaphoreSlim`, llama a la API, construye los indices (`LocalidadCacheData`) y los almacena en `IMemoryCache`. Lo mismo para provincias.

### Que pasa si la API no esta disponible al arranque

```csharp
catch (Exception ex)
{
    _logger.LogError(ex, "Error durante el warm-up del cache de localizacion. " +
        "La aplicacion continuara y el cache se cargara en el primer request.");
}
```

La app **no falla**. Arranca en modo degradado y el cache se intentara cargar en el primer request que lo necesite. Esto es intencional: una API de localizacion caida no deberia impedir que arranque toda la aplicacion.

### Logging

| Evento | Nivel | Mensaje |
|--------|-------|---------|
| Inicio de warm-up | Information | "Iniciando warm-up del cache de localizacion..." |
| Warm-up exitoso | Information | "Warm-up completado. Localidades: N, Provincias: N" |
| Warm-up fallido | Error | "Error durante el warm-up... La aplicacion continuara..." |

## Registro en DI

En `Startup.cs`:
```csharp
services.AddHostedService<LocalizacionCacheWarmupService>();
```

El warm-up se inyecta `ILocalizacionCacheService` (Singleton) y `ILogger`.

## Interaccion con el resto del cache

```
                Startup
                  |
    LocalizacionCacheWarmupService.StartAsync()
                  |
    ILocalizacionCacheService.GetAllLocalidades()
                  |
    LocalizacionCacheService.GetLocalidadCacheData()
                  |
         SemaphoreSlim.Wait()  (proteccion stampede)
                  |
    IServiceScopeFactory -> scope -> IApiLocalizacionClient.FindLocalidades()
                  |
    API HTTP -> JSON -> Dictionary + indices -> IMemoryCache.Set()
                  |
         SemaphoreSlim.Release()
                  |
    [Cache caliente - TTL 24h]
                  |
    Kestrel abre puerto -> requests usan cache directo
```

## Relacion con otros fixes

| Fix | Relacion con warm-up |
|-----|---------------------|
| Stale-while-revalidate | Si el warm-up carga datos, quedan como `_lastKnown*`. Si 24h despues la API falla al recargar, se usa el fallback. |
| SemaphoreSlim | El warm-up es el primer consumidor del semaforo. Garantiza que una sola carga ocurra. |
| Singleton | El warm-up puede inyectar el cache service porque es Singleton. Si fuera Scoped, no se podria. |
| IReadOnlyList | El warm-up ya fuerza la construccion de las listas pre-computadas. |
