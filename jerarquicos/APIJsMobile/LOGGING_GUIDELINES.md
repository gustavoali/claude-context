# Logging Guidelines - ApiJsMobile

**Fecha:** 2024-12-18
**Origen:** Code Reviews (Natalia Belén Mignola)
**Estado:** ACTIVO

---

## Resumen Ejecutivo

Este documento establece los criterios de logging para el proyecto ApiJsMobile, basados en las observaciones de code review y las decisiones tomadas durante el desarrollo.

---

## Regla 1: No Duplicar Logs en Catch Blocks

### Problema Identificado

El `HandlerExceptionMiddleware` ya loguea TODAS las excepciones que captura. Agregar `_logger.LogError()` en los catch blocks antes de lanzar excepciones genera **logs duplicados**.

### Incorrecto

```csharp
catch (HttpRequestException ex)
{
    _logger.LogError(ex, httpErrorMessage, ex.StatusCode);  // DUPLICADO

    var statusCode = (int)(ex.StatusCode ?? HttpStatusCode.InternalServerError);
    throw new ApiClientException(
        string.Format(httpErrorMessage, ex.Message),
        statusCode,
        ex.Message,
        url);
}
```

### Correcto

```csharp
catch (HttpRequestException ex)
{
    var statusCode = (int)(ex.StatusCode ?? HttpStatusCode.InternalServerError);
    throw new ApiClientException(
        string.Format(httpErrorMessage, ex.Message),
        statusCode,
        ex.Message,
        url);
}
// El middleware logueara la excepcion automaticamente
```

### Justificacion

- El `HandlerExceptionMiddleware` captura todas las excepciones no manejadas
- Loguea con contexto completo (environment, client, user, correlation)
- Evita entradas duplicadas en Graylog/logs

---

## Regla 2: Registrar Excepciones Personalizadas en el Middleware

### Problema Identificado

Si una excepcion personalizada (como `ApiClientException`) no tiene un case en el middleware, siempre devuelve HTTP 500 aunque la excepcion tenga un StatusCode diferente.

### Solucion

Agregar un case especifico en `HandlerExceptionMiddleware.HandlerError()`:

```csharp
case ApiClientException apiClient:
    logger.LogError(exception,
        "ApiClientException {EnviromentName}: {Client} {User} {Correlation} - StatusCode: {StatusCode}, Endpoint: {Endpoint}",
        contextInfo[0], contextInfo[1], contextInfo[2], contextInfo[3],
        apiClient.StatusCode, apiClient.Endpoint ?? "Unknown");
    return (HttpStatusCode)apiClient.StatusCode;
```

### Excepciones Registradas en el Middleware

| Excepcion | Nivel Log | HTTP Status |
|-----------|-----------|-------------|
| `BusinessException` | Information | Variable (de la excepcion) |
| `NotFoundException` | Information | Variable (de la excepcion) |
| `ValidatorException` | Warning | Variable (de la excepcion) |
| `AuthenticationException` | Warning | 401 Unauthorized |
| `ApiClientException` | Error | Variable (de la excepcion) |
| `InvalidOperationException` | Error | 400 Bad Request |
| Default (otras) | Error | 500 Internal Server Error |

---

## Regla 3: Capturar Response Body Antes de Lanzar Excepcion

### Problema Identificado

`EnsureSuccessStatusCode()` lanza una excepcion generica y descarta el body de la respuesta, perdiendo el mensaje de error real de la API externa.

### Incorrecto

```csharp
var response = await httpClient.GetAsync(url, cancellationToken);
response.EnsureSuccessStatusCode();  // Pierde el body del error

var result = await response.Content.ReadFromJsonAsync<TResponse>();
```

### Correcto

```csharp
var response = await httpClient.GetAsync(url, cancellationToken);

if (!response.IsSuccessStatusCode)
{
    // Capturar el body ANTES de lanzar
    var errorContent = await response.Content.ReadAsStringAsync(cancellationToken);
    var statusCode = (int)response.StatusCode;

    throw new ApiClientException(
        string.Format(httpErrorMessage, errorContent),
        statusCode,
        errorContent,  // Contiene el mensaje real de la API
        url);
}

var result = await response.Content.ReadFromJsonAsync<TResponse>();
```

### Beneficios

- El error real de la API externa se preserva en `ResponseContent`
- Facilita debugging cuando hay problemas de integracion
- El mensaje de error es significativo, no generico

---

## Regla 4: Logs de Trazabilidad (LogInformation)

### Contexto

Se utilizan callbacks `logStart()` y `logResult()` para registrar el inicio y fin de operaciones contra APIs externas.

```csharp
return await ExecuteGetAsync<TRequest, TResponse>(
    request,
    endpoint,
    () => _logger.LogInformation("Buscando profesionales cercanos..."),  // logStart
    result => _logger.LogInformation("Encontrados {Count} profesionales", result?.Count),  // logResult
    ...);
```

### Estado Actual

**Pendiente de decision** - Evaluar si:
- Mantener en `LogInformation` (util para trazabilidad/monitoreo)
- Cambiar a `LogDebug` (solo visible en desarrollo)
- Eliminar (si genera ruido excesivo en produccion)

### Recomendacion

Mantener en `LogInformation` para ambientes Dev/Test/Staging, evaluar cambio a `LogDebug` para Production si los logs son excesivos.

---

## Niveles de Log - Guia de Uso

| Nivel | Uso | Ejemplo |
|-------|-----|---------|
| `Debug` | Detalles internos, solo desarrollo | Variables internas, flujo detallado |
| `Information` | Operaciones normales, trazabilidad | Inicio/fin de operaciones, requests |
| `Warning` | Situaciones anormales pero manejadas | Auth fallida, validacion fallida |
| `Error` | Errores que afectan operacion | Excepciones, fallas de API |
| `Critical` | Fallas graves del sistema | DB down, servicios criticos caidos |

---

## Archivos Afectados

| Archivo | Cambios |
|---------|---------|
| `HandlerExceptionMiddleware.cs` | Agregado case para `ApiClientException` |
| `ApiPrestadoresClient.cs` | Eliminados `LogError` duplicados en catch blocks |
| `ApiPrestadoresClient.cs` | Reemplazado `EnsureSuccessStatusCode()` por validacion manual |

---

## Referencias

- **Code Review:** PR de integracion ApiPrestadores
- **Reviewer:** Natalia Belen Mignola
- **Fecha Review:** Diciembre 2024

---

## Historial de Cambios

| Fecha | Cambio | Autor |
|-------|--------|-------|
| 2024-12-18 | Documento inicial | Claude |
