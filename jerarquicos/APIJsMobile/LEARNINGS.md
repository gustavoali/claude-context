# ApiJsMobile - Learnings y Decisiones

## 2024-12-26: Migracion a FluentValidation

### Contexto
Se identifico duplicacion de recursos de validacion entre FluentValidation y DataAnnotations. El proyecto tenia `DisableDataAnnotationsValidation = true` lo que significa que DataAnnotations nunca se ejecutaban.

### Decision
Usar **exclusivamente FluentValidation** para todas las validaciones.

### Cambios Realizados

1. **Eliminados recursos duplicados DA_***
   - `DA_GreaterThan`, `DA_Between`, `DA_MaxLength` removidos
   - Solo se usan recursos `Validation.*`

2. **Validators movidos a ubicaciones correctas**
   - DTOs de BackendServices -> `BackendServices\ApiPrestadores\Validators\`
   - DTOs de ApiJsMobile.Dto -> `ApiJsMobile.Api\Validators\`

3. **Tests actualizados**
   - Cambiado de `Validator.TryValidateObject()` a FluentValidation validators
   - Tests en `BackendServices.Test` y `ApiJsMobile.Api.Test`

### Patrones de Codigo

```csharp
// Validator pattern
public class MiDtoValidator : AbstractValidator<MiDto>
{
    public MiDtoValidator()
    {
        RuleFor(x => x.Campo)
            .NotEmpty()
            .WithMessage(Validation.Required);
    }
}

// Test pattern
var validator = new MiDtoValidator();
var result = validator.Validate(dto);
result.IsValid.Should().BeFalse();
result.Errors.Should().Contain(e => e.PropertyName == "Campo");
```

### Registro en Program.cs

```csharp
builder.Services.AddValidatorsFromAssemblyContaining<Program>();
builder.Services.AddValidatorsFromAssemblyContaining<ApiPrestadoresClient>();
```

---

## Codigos de Error

- Nomenclatura: `A23-XXX`
- Rangos:
  - `A23-001` a `A23-010`: Errores generales
  - `A23-011` en adelante: Errores de validacion FluentValidation
- Excel de referencia: `C:\images\CodigosError.xlsx`
