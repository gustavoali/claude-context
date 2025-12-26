# API Client Implementation Guidelines - ApiJsMobile

**Fecha:** 2025-12-22
**Estado:** OBLIGATORIO
**Aplica a:** Todos los API Clients en BackendServices/
**Version:** 2.0

---

## Regla Principal: Coincidencia Exacta con APIs Originales

**Los DTOs de BackendServices DEBEN coincidir EXACTAMENTE con los DTOs de las APIs que consumen.**

Esta regla es fundamental porque:
1. Los **nombres de propiedades** deben coincidir para la deserializacion JSON
2. Los **tipos de propiedades** deben coincidir (int, int?, double, double?, etc.)
3. Los **tipos genericos** deben coincidir (List<TipoOriginal>, no List<TipoSimplificado>)
4. Evita errores silenciosos donde propiedades quedan en `null` por nombre/tipo incorrecto
5. Facilita el mantenimiento cuando la API original cambia

---

## Proceso de Implementacion de un Nuevo API Client

### Paso 1: Identificar la API Original

Antes de crear DTOs, localizar el proyecto de la API original:

| API | Repositorio/Ubicacion |
|-----|----------------------|
| ApiPrestadores | `C:\jerarquicos\apiprestadores\src\ApiPrestadores.Dto\` |
| ApiLocalizacion | `C:\jerarquicos\apilocalizacion\src\ApiLocalizacion.Dto\` |
| ApiCoberturaSocios | `C:\jerarquicos\apicobertura\src\ApiCobertura.Dto\` |

### Paso 2: Copiar Estructura de DTOs

Para cada DTO que necesites consumir:

1. **Leer el DTO original** en la API fuente
2. **Verificar nombres de propiedades** - deben ser IDENTICOS
3. **Verificar tipos de datos** - deben ser IDENTICOS (int vs int?, double vs double?)
4. **Verificar nullable** - respetar si es `?` o no
5. **Verificar herencia** - puede que no sea apropiado usar clases base si APIs tienen inconsistencias

### Paso 3: Crear DTO en BackendServices

```csharp
// Ejemplo: Si la API original tiene:
// public List<EntidadSaludServicioSaludResponseDto>? ServiciosSalud { get; set; }

// Tu DTO en BackendServices DEBE tener:
public List<ServicioSaludDto>? ServiciosSalud { get; init; }
// Nombre de propiedad: IDENTICO (ServiciosSalud)
// Tipo: Compatible (List<>)
// Nullable: Respetado (?)
```

---

## Errores Comunes a Evitar

### Error 1: Nombre de Propiedad Diferente

```csharp
// API Original:
public int? IdTipo { get; set; }

// INCORRECTO - nombre diferente:
public int? IdTipoEntidadSalud { get; init; }

// CORRECTO - nombre identico:
public int? IdTipo { get; init; }
```

**Consecuencia:** Al serializar para enviar a la API, el campo tendra nombre incorrecto y la API no lo reconocera.

**Caso Real (corregido 2025-12-22):**
- `EntidadSaludFindNearbyRequestDto`: Tenia `IdTipoEntidadSalud`, debia ser `IdTipo`

### Error 2: Propiedad Faltante

```csharp
// API Original tiene:
public bool? Atencion24Hs { get; set; }

// INCORRECTO - falta la propiedad:
// (nada)

// CORRECTO - incluir la propiedad:
public bool? Atencion24Hs { get; init; }
```

**Caso Real (corregido 2025-12-22):**
- `EntidadSaludFindNearbyRequestDto`: Faltaba `Atencion24Hs`

### Error 3: Tipo Nullable vs No-Nullable

```csharp
// API Original:
public double? Latitud { get; set; }
public int? Id { get; set; }

// INCORRECTO - tipos no-nullable:
public double Latitud { get; init; }  // Deberia ser double?
public int Id { get; init; }          // Deberia ser int?

// CORRECTO - respetar nullable:
public double? Latitud { get; init; }
public int? Id { get; init; }
```

**Casos Reales (corregidos 2025-12-22):**
- `ProfesionalFindNearbyRequestDto`: `Latitud` y `Longitud` debian ser `double?`
- `TelefonoPrestadorDto`: `Id` debia ser `int?`

### Error 4: Herencia Incorrecta

```csharp
// API Original tiene inconsistencias entre DTOs similares:
// EntidadSaludFindNearbyRequestDto: double Latitud, double Longitud (no-nullable)
// ProfesionalFindNearbyRequestDto:  double? Latitud, double? Longitud (nullable)

// INCORRECTO - usar clase base comun con double (no-nullable):
public abstract record FindNearbyRequestDtoBase
{
    public double Latitud { get; init; }  // No sirve para ProfesionalFind...
    public double Longitud { get; init; }
}

// CORRECTO - NO usar herencia si hay inconsistencias:
public record ProfesionalFindNearbyRequestDto  // Sin herencia
{
    public double? Latitud { get; init; }   // Nullable como API original
    public double? Longitud { get; init; }
}
```

**Caso Real (corregido 2025-12-22):**
- `ProfesionalFindNearbyRequestDto` ya no hereda de `FindNearbyRequestDtoBase`

### Error 5: DTO Generico vs Especifico

```csharp
// API Original tiene DTOs separados:
// - ProfesionalAddFavoriteRequestDto { IdPersona, IdProfesional }
// - EntidadSaludAddFavoriteRequestDto { IdPersona, IdEntidadSalud }

// INCORRECTO - DTO generico con propiedades diferentes:
public record FavoritoRequestDto { IdPersona, IdPrestador }

// CORRECTO - DTOs especificos que coinciden:
public record ProfesionalFavoritoRequestDto { IdPersona, IdProfesional }
public record EntidadSaludFavoritoRequestDto { IdPersona, IdEntidadSalud }
```

---

## Checklist de Verificacion

Antes de mergear cambios a un API Client, verificar:

- [ ] **Nombres de propiedades** coinciden EXACTAMENTE con API original
- [ ] **Tipos de datos** son IDENTICOS (int vs int?, double vs double?, etc.)
- [ ] **Nullable** respetado segun API original
- [ ] **Propiedades no faltan** - comparar lista completa con API original
- [ ] **Herencia apropiada** - si APIs tienen inconsistencias, NO usar clase base
- [ ] **DTOs de Request** usan los mismos campos que la API espera
- [ ] **DTOs de Response** pueden deserializar la respuesta JSON correctamente
- [ ] **Tests** verifican la estructura de los DTOs
- [ ] **Build** exitoso con 0 errores

---

## Inconsistencias Conocidas en APIs Originales

Algunas APIs originales tienen inconsistencias internas. Documentarlas aqui:

### ApiPrestadores

| Propiedad | EntidadSaludFindNearby | ProfesionalFindNearby |
|-----------|------------------------|----------------------|
| IdTipo | `int? IdTipo` | N/A (no tiene) |
| Latitud | `double Latitud` | `double? Latitud` |
| Longitud | `double Longitud` | `double? Longitud` |
| IdEspecialidad | N/A | `int? IdEspecialidadMedica` |
| Atencion24Hs | `bool? Atencion24Hs` | N/A |

**Implicacion:** NO usar clase base `FindNearbyRequestDtoBase` para ambos.

---

## Cuando la API Original Cambia

Si la API original modifica sus DTOs:

1. **Detectar el cambio** - revisar commits en el repositorio de la API
2. **Actualizar DTOs** en BackendServices para reflejar cambios
3. **Actualizar tests** que usan los DTOs modificados
4. **Verificar servicios** que usan los DTOs
5. **Ejecutar build y tests** completos
6. **Documentar** cambios en esta guia si revelan nuevas inconsistencias

---

## Estructura de Carpetas Recomendada

```
BackendServices/
├── ApiPrestadores/
│   ├── Interfaces/
│   │   └── IApiPrestadoresClient.cs
│   ├── Services/
│   │   └── ApiPrestadoresClient.cs
│   ├── Models/
│   │   ├── Common/           # DTOs compartidos (con cuidado sobre herencia)
│   │   ├── Profesional/      # DTOs de profesionales
│   │   └── EntidadSalud/     # DTOs de entidades de salud
│   └── Config/
│       └── ApiPrestadoresConfig.cs
```

---

## Correcciones Realizadas (2025-12-22)

| Archivo | Problema | Solucion |
|---------|----------|----------|
| `EntidadSaludFindNearbyRequestDto.cs` | `IdTipoEntidadSalud` en lugar de `IdTipo`, faltaba `Atencion24Hs` | Renombrar a `IdTipo`, agregar `Atencion24Hs` |
| `ProfesionalFindNearbyRequestDto.cs` | `Latitud`/`Longitud` no-nullable, heredaba de base incorrecta | Remover herencia, hacer propiedades nullable |
| `TelefonoPrestadorDto.cs` | `Id` no-nullable (`int`) | Cambiar a `int?` |
| Tests relacionados | Referencias a propiedades incorrectas | Actualizar para reflejar cambios |

---

## Testing

### Test de Estructura de DTOs

Crear tests que verifiquen que los DTOs tienen las propiedades correctas:

```csharp
[Test]
public void EntidadSaludFindNearbyRequestDto_ShouldHaveCorrectProperties()
{
    var dto = new EntidadSaludFindNearbyRequestDto
    {
        IdPlan = 1,
        Latitud = -34.6,
        Longitud = -58.4,
        Radio = 10,
        IdTipo = 5,        // NO IdTipoEntidadSalud
        Atencion24Hs = true // Propiedad que debe existir
    };

    dto.IdTipo.Should().Be(5);
    dto.Atencion24Hs.Should().BeTrue();
}

[Test]
public void ProfesionalFindNearbyRequestDto_LatitudLongitud_ShouldBeNullable()
{
    var dto = new ProfesionalFindNearbyRequestDto
    {
        IdPlan = 1,
        Radio = 10
    };

    // Latitud y Longitud son nullable segun API original
    dto.Latitud.Should().BeNull();
    dto.Longitud.Should().BeNull();
}

[Test]
public void TelefonoPrestadorDto_Id_ShouldBeNullable()
{
    var dto = new TelefonoPrestadorDto();

    // Id es nullable segun API original
    dto.Id.Should().BeNull();
}
```

---

## Directiva de Propiedades de DTOs (Actualizada 2025-12-23)

### Criterio de Inclusion de Propiedades

**REGLA:** Los DTOs de BackendServices deben incluir SOLO las propiedades que:
1. **Existen en la API backend original** (ApiPrestadores, etc.) - para asegurar compatibilidad de serialization
2. **Fueron usadas en el legacy API Mobile client** (Repositorio-ApiMovil) - para mantener paridad funcional

### Razon de Esta Regla

El proyecto ApiJsMobile es una **reimplementacion** del legacy API Mobile (Repositorio-ApiMovil). El objetivo es:
- Replicar la funcionalidad existente, no agregar funcionalidad nueva
- Mantener compatibilidad con los consumidores existentes (apps mobile)
- Evitar incluir propiedades que nunca se usaron y que agregan complejidad innecesaria

### Proceso de Verificacion

Al crear o revisar DTOs:

1. **Verificar propiedad en API backend** - debe existir con mismo nombre/tipo
2. **Verificar propiedad en legacy client** - debe haber sido usada

Ubicaciones de referencia:
- API Backend (ApiPrestadores): `C:\jerarquicos\apiprestadores\src\ApiPrestadores.Dto\`
- Legacy Client (Repositorio-ApiMovil): `C:\jerarquicos\Repositorio-ApiMovil\ApiMobileRest.ApiClients\`

### Propiedades Eliminadas (2025-12-23)

Las siguientes propiedades fueron removidas porque NO existian en el legacy client:

**ProfesionalFindByFiltersRequestDto:**
- `IdBarriosSeleccionados` - no usada en legacy

**ProfesionalFindByFiltersResponseDto:**
- `Matriculas` - no usada en legacy
- `Convenios` - no usada en legacy

**EntidadSaludFindByFiltersRequestDto:**
- `IdServicios` - no usada en legacy
- `IdBarriosSeleccionados` - no usada en legacy

**EntidadSaludFindByFiltersResponseDto:**
- `Convenios` - no usada en legacy
- `ServiciosSalud` - no usada en legacy

**DomicilioProfesionalDto:**
- `Barrio` - no usada en legacy

### DTOs Eliminados (2025-12-23)

Los siguientes DTOs fueron eliminados porque NO existian en el legacy client:

- `BarrioDto.cs`
- `MatriculaDto.cs`
- `ConvenioProfesionalDto.cs`
- `ConvenioEntidadSaludDto.cs`
- `ServicioSaludDto.cs`

### Inconsistencia Conocida: Propiedades de Expand/Paginacion

**IMPORTANTE:** ApiPrestadores tiene una inconsistencia interna que DEBE respetarse:

| DTO | Propiedad Expand | Propiedad Paginacion |
|-----|------------------|---------------------|
| `FindByFiltersRequestDto` | `Flags` (int) | `WithPagination` (bool?) |
| `FindFavoritesRequestDto` | `Expand` (int?) | `PaginationActive` (bool) |

Esta inconsistencia existe tanto en ApiPrestadores como en el Legacy client.
Los DTOs de BackendServices DEBEN usar los mismos nombres para cada tipo de DTO.

---

**Ultima actualizacion:** 2025-12-23
**Autor:** Claude Code
**Version:** 2.2
