# Analisis: NUnit Assert vs FluentAssertions - ApiJsMobile

**Fecha:** 2026-02-14
**Contexto:** Feature 176505 - Cartilla Controller
**Autor:** Test Engineer (analisis objetivo para decision de equipo)

---

## Estado Actual

### Resumen Cuantitativo

| Proyecto | Total archivos test | Solo NUnit Assert | Solo FluentAssertions | Mixto (ambos) | Ni uno ni otro |
|----------|--------------------:|-------------------:|----------------------:|---------------:|---------------:|
| BackendServices.Test | 66 | 2 | 52 | 7 | 5 (validators*) |
| ApiJsMobile.Api.Test | 8 | 8 | 0 | 0 | 0 |
| **Total** | **74** | **10** | **52** | **7** | **5** |

*Los 5 archivos de validators usan `FluentValidation.TestHelper` (ShouldHaveValidationErrorFor), que es parte de FluentValidation, no de FluentAssertions. Se cuentan aparte.

### Detalle por Categoria

| Estilo | Archivos | % del total | Ejemplo representativo |
|--------|----------|-------------|------------------------|
| Solo FluentAssertions | 52 | 70% | Models DTOs, ServiceConfig, ApiUrlBuilder |
| Solo NUnit Assert | 10 | 14% | AuthController, CartillaController, ApiClientException, Middleware |
| Mixto (Assert.Throws + .Should()) | 7 | 9% | ApiPrestadoresClientConstructorTests, ExceptionTests |
| FluentValidation.TestHelper | 5 | 7% | Validators (EntidadSalud, Profesional, etc.) |

### Dependencias en .csproj

| Proyecto | FluentAssertions | Version | NUnit | Version |
|----------|:----------------:|---------|:-----:|---------|
| BackendServices.Test | Si | 6.12.1 | Si | 4.2.2 |
| ApiJsMobile.Api.Test | **No** | N/A | Si | 4.2.2 |

**Observacion critica:** `ApiJsMobile.Api.Test` no tiene la dependencia de FluentAssertions en su .csproj. Todos sus tests usan NUnit Assert nativo.

---

## Comparacion

### NUnit Assert Nativo

**Pros:**
- Ya incluido con NUnit, sin dependencia adicional
- Mejor integrado con `Assert.Multiple()` para agrupar assertions relacionadas
- `Assert.Throws<T>()` y `Assert.ThrowsAsync<T>()` son la forma estandar de testear excepciones en NUnit, usada incluso en archivos que importan FluentAssertions
- Constraint model (`Is.EqualTo`, `Is.InstanceOf`, `Does.Contain`) es expresivo y bien documentado
- NUnit.Analyzers provee warnings en tiempo de compilacion
- Sin riesgo de breaking changes por dependencia externa (FluentAssertions tuvo cambios de licencia en v7)

**Contras:**
- Sintaxis menos fluida para assertions encadenadas
- Mensajes de error menos descriptivos por defecto
- Assertions sobre colecciones y objetos complejos requieren mas codigo
- No tiene equivalente a `BeEquivalentTo()` para comparacion profunda de objetos

**Ejemplo real del proyecto** (`AuthControllerTest.cs`):
```csharp
Assert.That(result.Result, Is.TypeOf<OkObjectResult>());
var okResult = (OkObjectResult)result.Result!;
var response = (LoginResponseDto)okResult.Value!;

Assert.Multiple(() =>
{
    Assert.That(response.Token, Is.EqualTo(expectedResponse.Token));
    Assert.That(response.TokenType, Is.EqualTo("Bearer"));
    Assert.That(response.ExpiresIn, Is.EqualTo(28800));
});
```

### FluentAssertions

**Pros:**
- Sintaxis natural que se lee como ingles: `dto.Should().NotBeNull()`
- `BeEquivalentTo()` para comparacion profunda de objetos con opciones configurables
- Mensajes de error descriptivos automaticamente (incluyen nombre de variable, valor esperado y actual)
- Assertions encadenadas: `dto.Should().NotBeNull().And.BeAssignableTo<IDto>()`
- Excelente soporte para colecciones, strings, fechas y objetos complejos
- Integra bien con records de C# via `BeEquivalentTo()`

**Contras:**
- Dependencia externa adicional (actualmente v6.12.1)
- FluentAssertions v7+ cambio a licencia comercial para empresas (riesgo futuro)
- No reemplaza `Assert.Throws` de NUnit -- el proyecto ya demuestra que se mezclan ambos
- Curva de aprendizaje adicional (aunque minima)
- Overhead de la libreria (negligible en tests)

**Ejemplo real del proyecto** (`SolicitudAddRequestDtoTests.cs`):
```csharp
// Comparacion profunda de objetos con opciones
deserialized.Should().BeEquivalentTo(original, options => options
    .WithStrictOrdering());

// Igualdad por valor vs referencia (claro y conciso)
original.Should().Be(modificado);
original.Should().NotBeSameAs(modificado);
```

---

## Comparacion Directa

| Criterio | NUnit Assert | FluentAssertions | Ventaja |
|----------|:------------:|:----------------:|:-------:|
| **Legibilidad** | Buena con constraint model | Superior (sintaxis natural) | FA |
| **Mensajes de error** | Genericos | Descriptivos automaticos | FA |
| **Curva de aprendizaje** | Minima (viene con NUnit) | Baja (bien documentada) | NUnit |
| **Mantenimiento** | 0 deps extra | 1 dep extra + riesgo licencia v7 | NUnit |
| **Performance** | Marginal | Marginal | Empate |
| **Ecosystem/Soporte** | Parte de NUnit, estable | Proyecto externo, popular pero riesgo v7 | NUnit |
| **Cadena de assertions** | No soporta | `Should().X().And.Y()` | FA |
| **Colecciones complejas** | Verbose | `BeEquivalentTo()`, `Contain()` | FA |
| **Exceptions** | `Assert.Throws` (estandar) | `act.Should().Throw<T>()` | Empate* |
| **Assert.Multiple** | Nativo | No tiene equivalente directo | NUnit |
| **Records/DTOs** | Manual (propiedad por propiedad) | `BeEquivalentTo()` potente | FA |
| **Integr. con NUnit Analyzers** | Completa | Parcial | NUnit |

*En la practica, el proyecto usa `Assert.Throws` de NUnit incluso en archivos con FluentAssertions, lo que demuestra que FA no reemplaza este patron.

---

## Ejemplos Lado a Lado

### Ejemplo 1: Verificar resultado de controller (del proyecto real)

**NUnit Assert** (como esta en `CartillaControllerTests.cs`):
```csharp
// Assert
Assert.That(result, Is.InstanceOf<OkObjectResult>());
var okResult = result as OkObjectResult;
Assert.That(okResult!.Value, Is.EqualTo(expectedResponse));
_mockCartillaService.Verify(s => s.GetEmergenciasAsync(...), Times.Once);
```

**FluentAssertions** (equivalente):
```csharp
// Assert
result.Should().BeOfType<OkObjectResult>();
var okResult = result as OkObjectResult;
okResult!.Value.Should().Be(expectedResponse);
_mockCartillaService.Verify(s => s.GetEmergenciasAsync(...), Times.Once);
```

**Diferencia:** Minima. La legibilidad es comparable en este caso.

### Ejemplo 2: Verificar excepcion con propiedades (del proyecto real)

**NUnit Assert** (como esta en `ApiPrestadoresClientExceptionTests.cs`):
```csharp
var ex = Assert.ThrowsAsync<ApiClientException>(async () =>
    await _client.ProfesionalFindNearbyAsync(request));

Assert.Multiple(() =>
{
    Assert.That(ex, Is.Not.Null);
    Assert.That(ex!.StatusCode, Is.EqualTo((int)HttpStatusCode.ServiceUnavailable));
    Assert.That(ex.Message, Does.Contain("Error de red"));
    Assert.That(ex.Endpoint, Does.Contain("/profesionales/nearby"));
});
```

**FluentAssertions** (equivalente):
```csharp
var act = async () => await _client.ProfesionalFindNearbyAsync(request);

var ex = (await act.Should().ThrowAsync<ApiClientException>()).Which;
ex.StatusCode.Should().Be((int)HttpStatusCode.ServiceUnavailable);
ex.Message.Should().Contain("Error de red");
ex.Endpoint.Should().Contain("/profesionales/nearby");
```

**Diferencia:** El patron de NUnit con `Assert.Throws` + `Assert.Multiple` es mas explicito y ya esta adoptado en todo el proyecto. El patron de FA con `.Which` es mas compacto pero menos familiar para el equipo actual.

### Ejemplo 3: Comparacion profunda de objetos (del proyecto real)

**FluentAssertions** (como esta en `SolicitudAddRequestDtoTests.cs`):
```csharp
deserialized.Should().BeEquivalentTo(original, options => options
    .WithStrictOrdering());
```

**NUnit Assert** (equivalente):
```csharp
// No hay equivalente directo. Se requeriria:
Assert.Multiple(() =>
{
    Assert.That(deserialized!.OficinaCarga, Is.EqualTo(original.OficinaCarga));
    Assert.That(deserialized.IdSolicitudOrigenDesdoblar, Is.EqualTo(original.IdSolicitudOrigenDesdoblar));
    Assert.That(deserialized.TieneProgramaEspecialActivo, Is.EqualTo(original.TieneProgramaEspecialActivo));
    // ... una linea por cada propiedad
});
```

**Diferencia:** Aqui FluentAssertions tiene una ventaja clara. `BeEquivalentTo` reemplaza N lineas de assertions manuales y detecta automaticamente nuevas propiedades agregadas al DTO.

### Ejemplo 4: Patron mixto real (como se usa en el proyecto)

**Archivo real** (`ApiPrestadoresClientConstructorTests.cs`):
```csharp
// Assert.Throws de NUnit + .Should() de FluentAssertions en el mismo test
var exception = Assert.Throws<ArgumentNullException>(() =>
    new ApiPrestadoresClient(null!, loggerMock.Object, optionsMock.Object))!;

exception.ParamName.Should().Be("httpClientFactory");
```

**Observacion:** Este patron mixto es comun en el proyecto. Se usa `Assert.Throws` (NUnit) para capturar la excepcion y `.Should().Be()` (FA) para verificar sus propiedades. Esto demuestra que ambas herramientas no son mutuamente excluyentes sino complementarias.

---

## Analisis de Riesgo: FluentAssertions v7

FluentAssertions v7 (lanzada en 2024) cambio a una licencia comercial para empresas con mas de 3 desarrolladores. Datos relevantes:

| Aspecto | Detalle |
|---------|---------|
| Version actual en el proyecto | 6.12.1 (licencia Apache 2.0, libre) |
| Version 7.x | Licencia comercial para empresas >3 devs |
| Costo estimado | Desde $129.95/year (community sponsor) |
| Impacto si se queda en v6 | Recibe solo fixes criticos, no features nuevas |
| Alternativas a FA v7 | Shouldly (libre), NUnit nativo, TUnit |

---

## Recomendacion

### Estandarizar en: **NUnit Assert nativo** (constraint model)

**Justificacion:**

1. **Reduccion de dependencias:** Eliminar FluentAssertions de `BackendServices.Test.csproj` elimina una dependencia externa y el riesgo asociado a la licencia v7.

2. **Consistencia:** `ApiJsMobile.Api.Test` ya usa 100% NUnit Assert. Estandarizar en NUnit unifica ambos proyectos de test.

3. **El patron dominante en tests criticos ya es NUnit:** Los tests de controllers, middleware y exception handling (los mas importantes para la logica de negocio) ya usan NUnit Assert.

4. **Assert.Throws no tiene reemplazo:** Incluso los archivos que importan FluentAssertions usan `Assert.Throws` de NUnit para excepciones, demostrando que FA no es suficiente por si sola.

5. **Assert.Multiple es superior:** NUnit's `Assert.Multiple` es el patron preferido del proyecto para agrupar assertions. FA no tiene un equivalente directo tan limpio.

6. **BeEquivalentTo es el unico feature diferencial fuerte:** Solo se usa en tests de DTOs (serialization/equality). Estos tests se pueden reescribir con `Assert.That` + comparacion por propiedad, o usar JSON serialization para comparacion.

### Caso alternativo para FluentAssertions

Si el equipo decide que `BeEquivalentTo` es indispensable para tests de DTOs (52 archivos lo usan), la alternativa es:
- Mantener FluentAssertions 6.12.1 (libre, Apache 2.0)
- Fijar la version con `<PackageReference ... Version="[6.12.1]" />` para evitar upgrade accidental a v7
- Estandarizar el uso: FA solo para assertions sobre objetos, NUnit Assert para todo lo demas
- Agregar FluentAssertions al .csproj de ApiJsMobile.Api.Test para consistencia

---

## Plan de Migracion (si se estandariza NUnit Assert)

### Prioridad y Fases

| Fase | Archivos | Esfuerzo | Prioridad |
|------|----------|----------|-----------|
| 0. No tocar | 5 validators (usan FluentValidation.TestHelper) | 0 | N/A |
| 1. Mixtos | 7 archivos (ApiPrestadores Client tests) | ~2h | Alta |
| 2. DTOs simples | ~40 archivos (Should().NotBeNull(), Be(), NotBe()) | ~4h | Media |
| 3. DTOs complejos | ~12 archivos (BeEquivalentTo, WithStrictOrdering) | ~3h | Baja |
| **Total** | **~59 archivos** | **~9h** | - |

### Patrones de Reemplazo

```csharp
// FA -> NUnit Assert
dto.Should().NotBeNull();              ->  Assert.That(dto, Is.Not.Null);
dto.Should().Be(other);               ->  Assert.That(dto, Is.EqualTo(other));
dto.Should().NotBe(other);            ->  Assert.That(dto, Is.Not.EqualTo(other));
dto.Should().NotBeSameAs(other);      ->  Assert.That(dto, Is.Not.SameAs(other));
client.Should().BeAssignableTo<T>();   ->  Assert.That(client, Is.AssignableTo<T>());
result.Should().BeOfType<T>();         ->  Assert.That(result, Is.TypeOf<T>());
text.Should().Contain("x");           ->  Assert.That(text, Does.Contain("x"));
value.Should().BeTrue();              ->  Assert.That(value, Is.True);
value.Should().BeFalse();             ->  Assert.That(value, Is.False);
list.Should().HaveCount(n);           ->  Assert.That(list, Has.Count.EqualTo(n));
exception.ParamName.Should().Be("x"); ->  Assert.That(exception.ParamName, Is.EqualTo("x"));

// BeEquivalentTo -> Assert.Multiple (propiedad por propiedad)
dto.Should().BeEquivalentTo(expected); ->  Assert.Multiple(() => {
                                            Assert.That(dto.Prop1, Is.EqualTo(expected.Prop1));
                                            Assert.That(dto.Prop2, Is.EqualTo(expected.Prop2));
                                          });

// Alternativa para BeEquivalentTo con serialization:
// Comparar JSON serializado de ambos objetos
var json1 = JsonSerializer.Serialize(dto);
var json2 = JsonSerializer.Serialize(expected);
Assert.That(json1, Is.EqualTo(json2));
```

### Paso Final

Despues de migrar todos los archivos, remover del `BackendServices.Test.csproj`:
```xml
<!-- ELIMINAR -->
<PackageReference Include="FluentAssertions" Version="6.12.1" />
```

### Reglas para Tests Nuevos

1. Usar NUnit Assert con constraint model (`Assert.That` + `Is.*`, `Does.*`, `Has.*`)
2. Usar `Assert.Multiple` para agrupar assertions relacionadas
3. Usar `Assert.Throws<T>` / `Assert.ThrowsAsync<T>` para excepciones
4. NO agregar `using FluentAssertions` en archivos nuevos
5. Los validators siguen usando `FluentValidation.TestHelper` (esto NO cambia)

---

## Decision Pendiente

El equipo debe decidir entre:

| Opcion | Esfuerzo | Riesgo | Consistencia |
|--------|----------|--------|:------------:|
| A. Estandarizar NUnit Assert | ~9h migracion | Bajo | Alta |
| B. Estandarizar FluentAssertions | ~3h (agregar a Api.Test + migrar 10 archivos) | Medio (licencia v7) | Alta |
| C. Mantener mixto (status quo) | 0h | Bajo a corto plazo | Baja |

**Recomendacion del analisis: Opcion A** (NUnit Assert), con la migracion planificada en fases para no impactar el sprint actual.
