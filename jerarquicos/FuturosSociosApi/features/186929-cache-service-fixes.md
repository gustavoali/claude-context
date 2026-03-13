# 186929 - Cache Service Fixes (Rama 2)
**Fecha:** 2026-03-10
**Branch:** feature/186929_eliminar_localidad_provincia_ef_core

## Contexto
Code review exhaustivo del LocalizacionCacheService identifico 8 hallazgos (2 BLOCKER, 4 MAJOR, 2 MINOR).
Se implementaron todos los fixes en una sola sesion.

## Fixes Implementados

### FIX 1: Stale-while-revalidate
- Campos estaticos `_lastKnownLocalidades` / `_lastKnownProvincias` como fallback
- Si la API falla o devuelve vacio, se mantienen datos anteriores
- Logging con ILogger cuando se usa fallback

### FIX 2: Cache stampede protection
- `SemaphoreSlim(1, 1)` para localidades y provincias
- Patron double-check: TryGetValue antes del lock, TryGetValue despues del lock, luego carga

### FIX 3: Singleton con IServiceScopeFactory
- Constructor recibe `IServiceScopeFactory` en vez de `IApiLocalizacionClient`
- Metodos privados crean scope, resuelven client, usan, disponen
- Startup.cs: `AddSingleton` en vez de `AddScoped`

### FIX 4: Indices pre-computados + IReadOnlyList
- Clases internas `LocalidadCacheData` y `ProvinciaCacheData`
- Indices: `ById`, `All`, `ByProvincia`, `ByCodigoPostal`
- Interfaz cambiada a `IReadOnlyList<T>` para GetAllLocalidades/GetAllProvincias
- Callers actualizados (AutoMapper inferencia de source type)

### FIX 5: Eliminar parametro idPais de FindLocalidadesPaginado
- Removido de interfaz e implementacion
- GestionInternaSeguraController actualizado

### FIX 6: TTL 1h -> 24h
- `CacheDuration = TimeSpan.FromHours(24)`

### FIX 7: Warm-up via IHostedService
- `LocalizacionCacheWarmupService` en FuturosSociosApiMovil/Services/
- Precarga localidades y provincias en startup
- Registrado con `AddHostedService`

### FIX 8: ToList() redundante en controller
- `data?.Registers?.ToList()` -> `data?.Registers` en GestionInternaSeguraController

## Archivos Modificados
- BackendServices/ApiLocalizacion/Interfaces/ILocalizacionCacheService.cs
- BackendServices/ApiLocalizacion/Services/LocalizacionCacheService.cs
- FuturosSociosApiMovil/Startup.cs
- FuturosSociosApiMovil/Controllers/GestionInternaSeguraController.cs
- FuturosSociosApiMovil/Controllers/AplicacionController.cs
- FuturosSociosApiMovil/Controllers/LocalidadesController.cs

## Archivos Creados
- FuturosSociosApiMovil/Services/LocalizacionCacheWarmupService.cs

## Decision de Diseño: Interfaz ILocalizacionCacheService
Se mantuvo la interfaz con 7 metodos especializados (no se unifico como IApiLocalizacionClient).
Razon: el cache service opera en memoria (sin costo de red por metodo), cada metodo tiene semantica
y tipo de retorno diferente, y los consumidores tienen necesidades distintas.

## Hallazgo: naming "solicitudesSettings"
Variable legacy en todos los API clients. Originalmente existia `SolicitudesSettings`, se renombro
la clase a `FuturosSociosApiMovilSettings` pero la variable quedo con nombre viejo.
Tech debt de naming, no funcional.

---

## Code Review - Resultado Final (2026-03-12/13)
**Branch:** feature/186929_eliminar_localidad_provincia_ef_core

### Criticos/Bloqueantes
| ID | Descripcion | Estado |
|----|-------------|--------|
| C-01 | `.GetAwaiter().GetResult()` + `.Wait()` — riesgo deadlock | RESUELTO (WaitAsync + RefreshCacheAsync) |
| C-02 | Lifetime mismatch Singleton/Scoped | RETIRADO (IServiceScopeFactory es correcto) |
| C-03 | `localidadIds.Contains()` genera IN clause enorme | PENDIENTE — deuda tecnica (requiere columna IdProvincia desnormalizada en Domicilio) |
| C-04 | DbContext leak en ExpedienteDAO | PENDIENTE — TD preexistente, fuera de scope de esta rama |

### Observaciones
| ID | Descripcion | Estado |
|----|-------------|--------|
| O-01 | `IdPaisArgentina = 1` hardcodeado | RESUELTO — movido a `LocalizacionCacheOptions.IdPaisDefault` |
| O-02 | Typo `Expedente_v71` en clase de migracion | RESUELTO — corregido a `Expediente_v71` en .cs y .Designer.cs |
| O-03 | `File.Delete` + `File.Move` no atomico | RESUELTO (parcial) — agregado `File.Exists` guard + comentario sobre limitacion .NET 3.1 |
| O-06 | `JsonConvert.DeserializeObject` puede retornar null | RESUELTO — null-check post-deserializacion en `ExecuteGetAsync`, `Success = false` si null |

### Notas de diseno
- `IApiLocalizacionClient` es Singleton. Valido mientras la implementacion solo use `IHttpClientFactory`, `IOptions<T>` e `ILogger<T>`. Si en el futuro necesita datos del request (token por usuario, tenant ID), volver a Scoped + `IServiceScopeFactory`.
- C-03 (solucion definitiva): agregar columna `IdProvincia` desnormalizada en tabla `Domicilio`. Evaluar cuando se reemplacen otras tablas del modelo EF.
