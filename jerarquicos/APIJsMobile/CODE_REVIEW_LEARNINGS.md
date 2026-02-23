# Lecciones Aprendidas de Code Reviews - ApiJsMobile

**Fecha de creacion:** 2024-12-29
**Ultima actualizacion:** 2024-12-29
**Proposito:** Documentar errores comunes detectados en code reviews para evitar repetirlos.

---

## Indice

1. [FluentValidation](#1-fluentvalidation)
2. [Logging y Exception Handling](#2-logging-y-exception-handling)
3. [Patrones Generales](#3-patrones-generales)
4. [Dependency Injection](#4-dependency-injection)

---

## 1. FluentValidation

### 1.1 No usar .When(HasValue) redundante en tipos nullable

**Fecha:** 2024-12-29
**Reviewer:** Natalia Belen Mignola
**Archivo:** `EntidadSaludFindByFiltersRequestDtoValidator.cs`

#### Incorrecto

```csharp
// Page es int? (nullable)
RuleFor(x => x.Page)
    .GreaterThan(0)
    .When(x => x.Page.HasValue)    // ← REDUNDANTE
    .WithMessage(Validation.GreaterThan);
```

#### Correcto

```csharp
RuleFor(x => x.Page)
    .GreaterThan(0)
    .WithMessage(Validation.GreaterThan);
```

#### Explicacion

FluentValidation **automaticamente ignora valores null** en tipos nullable (`int?`, `string?`, etc.) para validadores como:
- `GreaterThan()`
- `LessThan()`
- `InclusiveBetween()`
- `ExclusiveBetween()`
- `MaximumLength()`
- `MinimumLength()`

El `.When(x => x.Property.HasValue)` es redundante porque el validador ya no se ejecuta si el valor es null.

#### Cuando SI usar .When()

Usar `.When()` solo cuando la condicion depende de **otro campo**:

```csharp
// Correcto: validar Page solo si WithPagination es true
RuleFor(x => x.Page)
    .GreaterThan(0)
    .When(x => x.WithPagination == true)  // ← Depende de OTRO campo
    .WithMessage(Validation.GreaterThan);
```

---

### 1.2 Unificar RuleFor duplicados para el mismo campo

**Fecha:** 2024-12-29
**Reviewer:** Natalia Belen Mignola
**Archivo:** `FindNearbyRequestDtoBaseValidator.cs`

#### Incorrecto

```csharp
// Dos RuleFor separados para el mismo campo
RuleFor(x => x.Latitud)
    .NotNull()
    .WithMessage(Validation.Required);

RuleFor(x => x.Latitud)              // ← DUPLICADO
    .InclusiveBetween(-90, 90)
    .WithMessage(Validation.Between);
```

#### Correcto

```csharp
// Un solo RuleFor con validadores encadenados
RuleFor(x => x.Latitud)
    .NotNull()
    .WithMessage(Validation.Required)
    .InclusiveBetween(-90, 90)
    .WithMessage(Validation.Between);
```

#### Explicacion

En FluentValidation, se pueden encadenar multiples validadores en un solo `RuleFor()`. Cada `.WithMessage()` aplica al validador inmediatamente anterior.

**Ventajas:**
- Codigo mas conciso y legible
- Menor duplicacion
- Mas facil de mantener
- Claridad de que todas las validaciones son para el mismo campo

---

### 1.3 Usar mensajes de validacion centralizados

**Referencia:** Project CLAUDE.md

#### Incorrecto

```csharp
RuleFor(x => x.IdPlan)
    .GreaterThan(0)
    .WithMessage("El campo es requerido");  // ← String hardcodeado
```

#### Correcto

```csharp
RuleFor(x => x.IdPlan)
    .GreaterThan(0)
    .WithMessage(Validation.Required);  // ← Recurso centralizado
```

#### Recursos disponibles

| Recurso | Uso |
|---------|-----|
| `Validation.Required` | Campos requeridos |
| `Validation.GreaterThan` | Mayor que X |
| `Validation.Between` | Entre X e Y |
| `Validation.LengthMax` | Longitud maxima |
| `Validation.ExpandInvalid` | Expand invalido |

---

## 2. Logging y Exception Handling

### 2.1 Usar spread operator en lugar de indexacion directa

**Fecha:** 2024-12-29
**Reviewer:** Natalia Belen Mignola
**Archivo:** `HandlerExceptionMiddleware.cs`

#### Incorrecto

```csharp
case ApiClientException apiClient:
    logger.LogError(exception,
        "ApiClientException {Env}: {Client} {User} {Correlation} - Status: {Status}",
        contextInfo[0],           // ← Indexacion directa
        contextInfo[1],           // ← Poco legible
        contextInfo[2],           // ← Fragil si cambia el orden
        contextInfo[3],
        apiClient.StatusCode);
```

#### Correcto

```csharp
case ApiClientException apiClient:
    logger.LogError(exception,
        "ApiClientException {Env}: {Client} {User} {Correlation} - Status: {Status}",
        [.. contextInfo, apiClient.StatusCode]);  // ← Spread operator
```

#### Explicacion

El spread operator `[.. array, valor1, valor2]` (C# 12):
- Mantiene consistencia con otros casos que pasan `contextInfo` completo
- Es mas legible y expresivo
- Se adapta automaticamente si `contextInfo` cambia de estructura
- Evita errores de indice incorrecto

#### Patron consistente en HandlerExceptionMiddleware

```csharp
// Casos sin propiedades adicionales: pasar array completo
case BusinessException business:
    logger.LogInformation(exception, "BusinessException {Env}: {Client} {User} {Correlation}",
        contextInfo);

// Casos con propiedades adicionales: usar spread operator
case ApiClientException apiClient:
    logger.LogError(exception, "ApiClientException {Env}: {Client} {User} {Correlation} - Status: {Status}",
        [.. contextInfo, apiClient.StatusCode]);
```

---

## 3. Patrones Generales

### 3.1 Mantener consistencia con codigo existente

Antes de implementar algo nuevo, revisar como se hace en casos similares dentro del mismo archivo o proyecto.

**Checklist:**
- [ ] Buscar patrones existentes en el mismo archivo
- [ ] Revisar archivos similares en el proyecto
- [ ] Verificar si hay convenciones documentadas
- [ ] Mantener el mismo estilo que el codigo circundante

### 3.2 Evitar codigo redundante

Preguntarse siempre: "¿Este codigo agrega valor o es redundante?"

**Senales de codigo redundante:**
- Condiciones que siempre son true/false
- Validaciones que el framework ya hace automaticamente
- Null checks despues de operaciones que nunca retornan null
- `.When()` en FluentValidation para tipos nullable

### 3.3 Preferir expresividad sobre verbosidad

**Incorrecto (verboso):**
```csharp
contextInfo[0], contextInfo[1], contextInfo[2], contextInfo[3], extraValue
```

**Correcto (expresivo):**
```csharp
[.. contextInfo, extraValue]
```

---

## 4. Dependency Injection

### 4.1 No instanciar clients/services con `new` dentro de metodos

**Fecha:** 2026-02-23
**Reviewer:** Natalia Belen Mignola
**Archivo:** `ComprasComerciosController.cs` (Repositorio-ApiMovil)

#### Incorrecto

```csharp
public async Task<HttpResponseMessage> DescargarResumenTarjeta(int id)
{
    // Instanciar el client en cada llamada al metodo
    var apiReportesClient = new ApiReporteClient();
    var respuesta = await apiReportesClient.GenerarReporteAsync(nombre, parametros);
}
```

#### Correcto

```csharp
// Field a nivel de clase
private readonly IApiReporteClient apiReportesClient;

// Inyeccion por constructor
public MiController(IApiReporteClient _apiReportesClient)
{
    apiReportesClient = _apiReportesClient;
}

// Uso directo del field inyectado
public async Task<HttpResponseMessage> DescargarResumenTarjeta(int id)
{
    var respuesta = await apiReportesClient.GenerarReporteAsync(nombre, parametros);
}
```

#### Explicacion

Los clients y services deben registrarse en el container de DI y recibirse por constructor, no instanciarse con `new` en cada metodo. Razones:

- **Reutilizacion:** Una sola instancia (Singleton) en vez de crear una nueva por cada request
- **Testabilidad:** Se puede mockear la interfaz en tests
- **Consistencia:** Todos los demas clients del proyecto siguen este patron
- **Rendimiento:** Evita overhead de crear y configurar instancias repetidamente

**Aplica a:** Cualquier proyecto con DI container (StructureMap en ApiMovil, Microsoft DI en ApiJsMobile).

**Patron para clases estaticas (sin constructor):** Resolver via `ObjectFactory.GetInstance<IInterface>()` o recibir como parametro.

---

## Checklist de Code Review

Antes de crear un PR, verificar:

### FluentValidation
- [ ] No hay `.When(x => x.Prop.HasValue)` redundante en tipos nullable
- [ ] Mensajes de error usan recursos de `Validation.*`
- [ ] Validators estan en la carpeta correcta segun el DTO

### Logging
- [ ] Se usa spread operator `[.. array, extras]` en lugar de indexacion
- [ ] Los logs mantienen consistencia con otros casos similares
- [ ] Se incluye informacion de contexto (correlation, user, client)

### Dependency Injection
- [ ] No se instancian clients/services con `new` dentro de metodos
- [ ] Nuevos clients registrados en el container de DI
- [ ] Inyeccion por constructor, no por `ObjectFactory.GetInstance` en controllers

### General
- [ ] El codigo sigue los patrones existentes del proyecto
- [ ] No hay codigo redundante o innecesario
- [ ] Los cambios son minimos y focalizados

---

## Historial de Correcciones

| Fecha | Archivo | Correccion | Reviewer |
|-------|---------|------------|----------|
| 2024-12-29 | `HandlerExceptionMiddleware.cs` | Indexacion → Spread operator | Natalia Mignola |
| 2024-12-29 | `EntidadSaludFindByFiltersRequestDtoValidator.cs` | Remover `.When(HasValue)` redundante | Natalia Mignola |
| 2024-12-29 | `EntidadSaludFindFavoritesRequestDtoValidator.cs` | Remover `.When(HasValue)` redundante | Natalia Mignola |
| 2024-12-29 | `PaginationValidator.cs` | Remover `.When(HasValue)` redundante | (detectado en busqueda) |
| 2024-12-29 | `ProfesionalFindFavoritesRequestDtoValidator.cs` | Remover `.When(HasValue)` redundante | (detectado en busqueda) |
| 2024-12-29 | `ProfesionalFindByFiltersRequestDtoValidator.cs` | Remover `.When(HasValue)` redundante | (detectado en busqueda) |
| 2024-12-29 | `FindNearbyRequestDtoBaseValidator.cs` | Remover `.When(HasValue)` en Latitud, Longitud, Page, PageSize | (detectado en busqueda) |
| 2024-12-29 | `FindNearbyRequestDtoBaseValidator.cs` | Unificar RuleFor duplicados para Latitud y Longitud | Natalia Mignola |
| 2026-02-23 | `ComprasComerciosController.cs` (ApiMovil) | No instanciar clients con `new` en metodos, usar DI | Natalia Mignola |

---

**Nota:** Este documento debe actualizarse cada vez que se detecte un nuevo patron de error en code reviews.
