# Code Review Rules - Jerarquicos

**Version:** 1.7
**Ultima actualizacion:** 2026-03-12
**Origen:** Observaciones de code review de Guillermo Loinaz + convenciones del equipo

---

## Reglas

### R001: Usar namespaces en lugar de nombres fully qualified
**Severidad:** Media
**Aplica a:** Todos los archivos .cs

No usar nombres de tipo fully qualified (ej: `System.Threading.Tasks.Task<T>`).
En su lugar, agregar el `using` correspondiente y usar el nombre corto.

**Incorrecto:**
```csharp
public async System.Threading.Tasks.Task<HttpResponseMessage> MiMetodo()
```

**Correcto:**
```csharp
using System.Threading.Tasks;
// ...
public async Task<HttpResponseMessage> MiMetodo()
```

---

### R002: Reutilizar recursos existentes en archivos .resx
**Severidad:** Alta
**Aplica a:** Excepciones.resx, Mensajes.resx, y todos los archivos de recursos

Antes de crear un nuevo recurso en un archivo .resx, verificar si ya existe uno con el mismo proposito o significado similar.
Crear recursos duplicados con diferentes nombres genera confusion y dificulta el mantenimiento.

**Verificacion obligatoria:** Antes de sugerir crear un recurso nuevo, leer el .resx completo, listar los recursos existentes y confirmar explicitamente que ninguno cubre el mismo caso de uso. Si no se realiza esta verificacion, el hallazgo del review es invalido.

**Incorrecto:** Crear "SinDocumentos" cuando ya existe "ErrorAlDescargarArchivo"
**Correcto:** Reutilizar "ErrorAlDescargarArchivo"

---

### R003: Nombres de carpetas, namespaces y clases en singular para integraciones de API
**Severidad:** Alta
**Aplica a:** BackendServices/, integraciones externas

La convencion del proyecto es usar nombres **en singular** para carpetas de integracion, namespaces y clases.
Seguir el patron existente (ej: `ApiRecetaElectronica`, no `ApiRecetasElectronicas`).

**Incorrecto:** `ApiReportes`, `ApiReportesClient`, `IApiReportesClient`
**Correcto:** `ApiReporte`, `ApiReporteClient`, `IApiReporteClient`

---

### R004: Ubicar configuraciones en la seccion correcta de Web.config
**Severidad:** Media
**Aplica a:** Web.config (appSettings)

El Web.config tiene secciones organizadas con comentarios HTML (`<!-- SECCION -->`).
Al agregar nuevas keys, ubicarlas en la seccion tematica correspondiente:
- URLs de APIs van en `<!--URLS APIS-->`
- Configuracion de servidor de reportes va en `<!--CONFIGURACION SERVIDOR API REPORTES-->`
- Etc.

No mezclar keys de diferentes categorias en una misma seccion.

---

### R005: Simplificar nombres de clase, no expandirlos
**Severidad:** Media
**Aplica a:** Todos los archivos .cs

Si un `using` ya resuelve el namespace, no reemplazarlo por el nombre fully qualified.
Si se necesita el fully qualified por ambiguedad, documentar por que con un comentario.

**Incorrecto:** Cambiar `ConfigurationManager` a `System.Configuration.ConfigurationManager`
**Correcto:** Mantener `ConfigurationManager` con `using System.Configuration;`

---

### R006: Naming de keys de URLs de APIs en Web.config sigue patron UrlApi...
**Severidad:** Media
**Aplica a:** Web.config (appSettings), clases de configuracion de servicios

Las keys de URLs de APIs en Web.config siguen el patron `UrlApi[NombreServicio]`, sin "Base" ni prefijos extra.
Respetar la convencion existente en la seccion `<!--URLS APIS-->`.

**Incorrecto:** `UrlBaseApiReporte`
**Correcto:** `UrlApiReporte`

Patron de referencia:
```xml
<add key="UrlApiGS" value="..." />
<add key="UrlApiRecetaElectronica" value="..." />
<add key="UrlApiReporte" value="..." />
```

---

### R007: No exponer ex.Message en respuestas al cliente
**Severidad:** Alta
**Aplica a:** Todos los servicios que devuelven DTOs de respuesta al cliente

Los mensajes de error devueltos al cliente **nunca** deben contener `ex.Message` ni informacion derivada de excepciones internas. Las excepciones pueden filtrar detalles de infraestructura (connection strings, URLs internas, nombres de tablas, stack traces parciales).

Loguear el detalle completo en el logger y devolver un mensaje generico o un ID de correlacion para trazabilidad.

**Incorrecto:**
```csharp
catch (Exception ex)
{
    _logger.LogError(ex, "Error en operacion");
    return ResponseDto.Error("Error", "ERR-001", ex.Message);  // EXPONE detalles internos
}
```

**Correcto:**
```csharp
catch (Exception ex)
{
    _logger.LogError(ex, "Error en operacion. CorrelationId: {CorrelationId}", correlationId);
    return ResponseDto.Error("Error", "ERR-001", null);  // Sin detalles internos
}
```

---

### R008: Constantes de negocio en configuracion, no hardcodeadas
**Severidad:** Media
**Aplica a:** Todos los archivos .cs

Los valores de negocio (IDs por defecto, limites, umbrales) deben estar en `appsettings.json` o en una clase de configuracion inyectable, no como `const` o magic numbers hardcodeados en el codigo. Esto permite cambiarlos sin recompilar y evita duplicacion cuando se usan en multiples lugares.

**Incorrecto:**
```csharp
private const int DefaultPlanId = 24;  // Magic number duplicado en 2 clases
```

**Correcto:**
```csharp
// appsettings.json
"CartillaSettings": { "DefaultPlanId": 24 }

// Clase
private readonly int _defaultPlanId = options.Value.DefaultPlanId;
```

---

### R009: Abstracciones base deben ser efectivamente reutilizadas
**Severidad:** Media
**Aplica a:** Validators, servicios base, clases abstractas

Si se crea una clase base, validator base o interface con el proposito de reutilizacion, los consumidores **deben** efectivamente usarla. De lo contrario, es codigo muerto que agrega complejidad sin beneficio. No crear abstracciones "por si acaso".

**Incorrecto:**
```csharp
// Se crea GeoLocationValidator<T> con interface IGeoLocation
// Pero los DTOs no implementan IGeoLocation
// Y los validators concretos repiten las reglas manualmente
```

**Correcto:**
```csharp
// Opcion A: Los DTOs implementan IGeoLocation y los validators heredan de GeoLocationValidator
// Opcion B: No crear GeoLocationValidator y poner las reglas directamente en cada validator
```

---

### R010: Metodos async deben usar async/await, no Task.FromResult
**Severidad:** Media
**Aplica a:** Todos los archivos .cs con metodos que retornan Task<T>

Los metodos que hacen I/O (llamadas a API, reportes, base de datos) DEBEN usar `async Task<T>` con `await`, no devolver `Task.FromResult()` simulando asincronia.

**Incorrecto:**
```csharp
public Task<HttpResponseMessage> DescargarReporte(int id)
{
    var respuesta = servicio.GenerarReporte(id);
    var response = new HttpResponseMessage(HttpStatusCode.OK);
    return Task.FromResult(response);
}
```

**Correcto:**
```csharp
public async Task<HttpResponseMessage> DescargarReporte(int id)
{
    var respuesta = await servicio.GenerarReporteAsync(id).ConfigureAwait(false);
    var response = new HttpResponseMessage(HttpStatusCode.OK);
    return response;
}
```

---

### R011: No devolver null desde endpoints de Web API
**Severidad:** Alta
**Aplica a:** Controllers con endpoints que retornan HttpResponseMessage o Task<HttpResponseMessage>

Devolver `null` desde un endpoint causa `NullReferenceException` en el pipeline de Web API. Siempre devolver un `HttpResponseMessage` con el status code apropiado.

**Incorrecto:**
```csharp
if (!this.RequestContext.Principal.Identity.IsAuthenticated)
{
    return null;
}
```

**Correcto:**
```csharp
if (!this.RequestContext.Principal.Identity.IsAuthenticated)
{
    return new HttpResponseMessage(HttpStatusCode.Unauthorized);
}
```

**Nota:** Este patron pre-existe en +80 lugares del proyecto. Aplicar progresivamente al tocar cada archivo.

---

### R012: En clases static, recibir dependencias como parametro, no usar service locator
**Severidad:** Media
**Aplica a:** Clases utilitarias estaticas que consumen servicios

El patron `ObjectFactory.GetInstance<T>()` dentro de metodos estaticos es un anti-patron (service locator) que dificulta testing y oculta dependencias. Las clases utilitarias estaticas deben recibir sus dependencias como parametros.

**Incorrecto:**
```csharp
public static async Task<ReporteResponseDto> GenerarReporte(int id)
{
    var client = ObjectFactory.GetInstance<IApiReporteClient>();
    return await client.GenerarReporteAsync(nombre, parametros);
}
```

**Correcto:**
```csharp
public static async Task<ReporteResponseDto> GenerarReporte(int id, IApiReporteClient apiReportesClient)
{
    return await apiReportesClient.GenerarReporteAsync(nombre, parametros);
}
```

**Alternativa:** Convertir la clase a no-estatica con DI por constructor.

---

### R013: Todo catch en API clients debe setear Success y ErrorMessage
**Severidad:** Alta
**Aplica a:** Todas las clases *Client.cs en BackendServices/

Todo bloque `catch` en un API client debe setear explicitamente `response.Success = false` y `response.ErrorMessage` con un mensaje descriptivo. No confiar en el valor default de `bool` para indicar fallo.

**Incorrecto:**
```csharp
catch (Exception e)
{
    logger.LogError(e, "Error: {Message}", e.Message);
    // response.Success queda en false por default, ErrorMessage queda null
}
```

**Correcto:**
```csharp
catch (Exception e)
{
    logger.LogError(e, "Error: {Message}", e.Message);
    response.Success = false;
    response.ErrorMessage = $"Error al ejecutar operacion: {e.Message}";
}
```

---

### R014: No usar .Result ni .Wait() en controllers
**Severidad:** Alta
**Aplica a:** Todos los controllers que llaman a API clients o servicios async

Los metodos de controller que invocan operaciones async deben ser `async Task<T>` y usar `await`. Usar `.Result` o `.Wait()` causa deadlocks con el `SynchronizationContext` de ASP.NET. Extension de R010.

**Incorrecto:**
```csharp
[HttpGet]
public RespuestaModel<List<T>> ObtenerDatos()
{
    var respuesta = _apiClient.GetDatosAsync(request).Result; // DEADLOCK RISK
    // ...
}
```

**Correcto:**
```csharp
[HttpGet]
public async Task<RespuestaModel<List<T>>> ObtenerDatos()
{
    var respuesta = await _apiClient.GetDatosAsync(request);
    // ...
}
```

---

### R015: Usar AutoMapper para todos los mapeos DTO/Model a ViewModel
**Severidad:** Alta
**Aplica a:** Todos los controllers y servicios que transforman datos entre capas

Todo mapeo entre DTOs, Models y ViewModels **debe** realizarse mediante AutoMapper con su correspondiente `CreateMap` en `AutoMapperProfile.cs`. No se permite mapeo manual con `new ViewModel { Prop = dto.Prop, ... }` ni con `.Select(x => new ViewModel { ... })`.

Esto asegura:
- Centralizar las reglas de transformacion en un unico lugar
- Facilitar el mantenimiento cuando cambian las propiedades
- Consistencia en todo el proyecto
- Detectar mapeos faltantes en tiempo de startup (no en runtime)

**Incorrecto:**
```csharp
var viewModels = dtos.Select(d => new MiViewModel
{
    Id = d.Id,
    Descripcion = d.Nombre,
    OtroCampo = d.Valor
}).ToList();
```

**Correcto:**
```csharp
// En AutoMapperProfile.cs
CreateMap<MiDto, MiViewModel>()
    .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Nombre));

// En el Controller/Service
var viewModels = Mapper.Map<List<MiDto>, List<MiViewModel>>(dtos);
```

**Excepcion:** Mapeos que requieren datos de contexto externo (ej: lookup en otro dataset) pueden completarse post-mapeo con `.ForEach()`, pero las propiedades base deben mapearse con AutoMapper.

---

### R016: Null-guard en apiResponse.Data despues de Success check
**Severidad:** Alta
**Aplica a:** Todos los controllers que consumen API clients de BackendServices/

Despues de verificar `apiResponse.Success`, siempre aplicar null-coalescing al acceder a `apiResponse.Data`. El hecho de que `Success == true` no garantiza que `Data` no sea null (la API puede devolver 200 con body vacio o JSON no deserializable).

**Incorrecto:**
```csharp
if (!apiResponse.Success)
{
    // manejar error...
}
respuesta.Modelo = Mapper.Map<List<MiDto>, List<MiViewModel>>(apiResponse.Data);
```

**Correcto:**
```csharp
if (!apiResponse.Success)
{
    // manejar error...
}
respuesta.Modelo = Mapper.Map<List<MiDto>, List<MiViewModel>>(
    apiResponse.Data ?? new List<MiDto>());
```

---

### R017: Paralelizar llamadas HTTP independientes con Task.WhenAll
**Severidad:** Media
**Aplica a:** Controllers y servicios que realizan multiples llamadas a API clients

Cuando dos o mas llamadas a API clients son independientes (no dependen del resultado del otro), usar `Task.WhenAll` para ejecutarlas en paralelo en vez de awaitar secuencialmente.

**Incorrecto:**
```csharp
var localidades = await _apiClient.FindLocalidades(idPais);
var provincias = await _apiClient.FindProvincias(idPais);
```

**Correcto:**
```csharp
var localidadesTask = _apiClient.FindLocalidades(idPais);
var provinciasTask = _apiClient.FindProvincias(idPais);
await Task.WhenAll(localidadesTask, provinciasTask);
var localidades = localidadesTask.Result;
var provincias = provinciasTask.Result;
```

---

### R018: Cache services en memoria deben documentar estrategia warmup + fallback
**Severidad:** Media
**Aplica a:** Servicios Singleton que mantienen datos de catalogo en IMemoryCache

Todo cache service en memoria para datos de catalogo debe implementar y documentar las tres capas de disponibilidad:
1. **Cache caliente** (IMemoryCache con TTL)
2. **Stale-while-revalidate** (servir datos stale + trigger background refresh)
3. **Fallback a disco o fuente** (para primer arranque o recuperacion tras fallo)

Ademas debe tener un `IHostedService` de warmup que precargue el cache al iniciar la app, y un `BackgroundService` de refresh periodico.

**Referencia de implementacion:** `BackendServices/ApiLocalizacion/Services/LocalizacionCacheService.cs`
**Documentacion del patron:** `C:/claude_context/jerarquicos/FuturosSociosApi/features/cache-service-localizacion.md`

---

## Como agregar nuevas reglas

Al finalizar un code review donde se detecte un patron nuevo:

1. Asignar el siguiente ID disponible: R00N
2. Definir: Severidad (Alta/Media/Baja), Aplica a (scope)
3. Incluir ejemplo Incorrecto/Correcto
4. Agregar separador `---` entre reglas
5. Actualizar la fecha de ultima actualizacion del archivo
