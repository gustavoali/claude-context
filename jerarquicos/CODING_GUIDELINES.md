# Coding Guidelines - Jerarquicos Salud

**Fecha:** 2025-12-23
**Estado:** OBLIGATORIO
**Aplica a:** Todos los proyectos de Jerarquicos Salud
**Version:** 1.0

---

## Directiva de Comentarios en Codigo

### Regla Principal: No Agregar Comentarios Innecesarios

**NO se deben agregar comentarios en codigo nuevo** excepto en casos especificos.

El codigo debe ser **auto-documentado** mediante:
- Nombres de variables, metodos y clases descriptivos
- Funciones pequenas con responsabilidad unica
- Estructura de codigo clara y logica

### Comentarios Prohibidos

Los siguientes tipos de comentarios NO deben agregarse:

```csharp
// INCORRECTO - Comentario obvio
// Incrementa el contador
contador++;

// INCORRECTO - Comentario que repite el nombre del metodo
// Obtiene el usuario por ID
public User GetUserById(int id) { ... }

// INCORRECTO - Comentario de bloque innecesario
// Este metodo valida el request
// y lanza una excepcion si es invalido
public void ValidateRequest(Request request) { ... }

// INCORRECTO - Comentario TODO sin resolver
// TODO: Refactorizar esto despues
```

### Excepciones: Comentarios Permitidos

#### 1. Comentarios en Tests: Arrange/Act/Assert

En archivos de tests, se PERMITE usar los comentarios `// Arrange`, `// Act`, `// Assert` para estructurar los tests:

```csharp
[Test]
public void GetUserById_WithValidId_ReturnsUser()
{
    // Arrange
    var userId = 1;
    var expectedUser = new User { Id = 1, Name = "Test" };
    _mockRepository.Setup(r => r.GetById(userId)).Returns(expectedUser);

    // Act
    var result = _service.GetUserById(userId);

    // Assert
    result.Should().NotBeNull();
    result.Id.Should().Be(userId);
}
```

#### 2. Comentarios que Explican el "Por Que" (No el "Que")

Se permite comentar decisiones tecnicas no obvias:

```csharp
// Usamos ConfigureAwait(false) en BackendServices
// porque no necesitamos contexto de sincronizacion
await client.GetAsync(url).ConfigureAwait(false);

// Validacion explicita porque la API original no valida este campo
if (request.IdPlan <= 0)
    throw new BusinessException("IdPlan debe ser mayor a 0");
```

#### 3. XML Documentation en Interfaces Publicas

Para APIs publicas y interfaces, usar documentacion XML:

```csharp
/// <summary>
/// Busca profesionales cercanos a una ubicacion.
/// </summary>
/// <param name="request">Parametros de busqueda incluyendo coordenadas y radio.</param>
/// <returns>Lista paginada de profesionales.</returns>
Task<PaginatedResponse> FindNearbyAsync(FindNearbyRequest request);
```

#### 4. Advertencias de Seguridad o Performance

```csharp
// IMPORTANTE: Este metodo no valida permisos - el caller debe verificar
// autorizacion antes de llamar
public async Task DeleteUser(int userId) { ... }

// PERF: Evitar llamar en loops - usar batch en su lugar
public async Task<User> GetUserById(int id) { ... }
```

### Regla para Codigo Existente

- **NO** agregar comentarios a codigo existente que no los tiene
- **NO** modificar comentarios existentes sin razon
- **SI** se refactoriza codigo, evaluar si los comentarios siguen siendo necesarios

### Razon de Esta Directiva

1. **Comentarios desactualizados** son peores que no tener comentarios
2. **Codigo auto-documentado** es mas mantenible
3. **Menos ruido** en el codigo facilita la lectura
4. **Consistencia** entre todos los proyectos

---

## Otras Convenciones de Codigo

### Async/Await

- Usar `ConfigureAwait(false)` en capas no-UI (Services, Repositories, etc.)
- NO usar en Controllers que necesitan HttpContext

### Logging

- NO agregar `_logger.LogError` en catch blocks - el middleware lo hace
- Usar `LogInformation` para trazabilidad de operaciones

### Manejo de Errores

- Usar excepciones tipadas (`BusinessException`, `ApiClientException`, etc.)
- El middleware centralizado maneja el logging de errores

### Naming Conventions

- **Interfaces**: Prefijo `I` (IUserService)
- **DTOs**: Sufijo `Dto`, `RequestDto`, `ResponseDto`
- **Tests**: Sufijo `Tests` (UserServiceTests)
- **Metodos async**: Sufijo `Async`

---

**Ultima actualizacion:** 2025-12-23
**Autor:** Claude Code
**Version:** 1.0
