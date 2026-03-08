# ApiPrestadores Client - Estado Actual de Implementacion
## Componente BackendServices.ApiPrestadores en ApiJsMobile

**Version:** 2.0 (actualizado con estado real)
**Fecha original:** 2025-11-13
**Ultima revision:** 2026-02-13
**Estado:** Implementacion ~80% completa

---

## 1. Resumen de Estado

El cliente ApiPrestadores fue implementado en `BackendServices/ApiPrestadores/` siguiendo un patron propio (no exactamente el del documento de diseno original). La implementacion es funcional pero tiene merge conflicts pendientes y carece de resilience patterns (Polly).

### Diferencias clave vs documento original

| Aspecto | Doc Original | Implementacion Real |
|---------|-------------|-------------------|
| Ubicacion DTOs | `ApiJsMobile.Dto/ApiPrestadores/` | `BackendServices/ApiPrestadores/Models/` |
| Ubicacion interfaz | `ApiJsMobile.Application/Interfaces/` | `BackendServices/ApiPrestadores/Interfaces/` |
| Ubicacion client | `ApiJsMobile.Infrastructure/HttpClients/` | `BackendServices/ApiPrestadores/` |
| Config class | `ApiPrestadoresClientOptions` | `ApiPrestadoresClientServiceConfig` |
| Config section | `ApiPrestadores` | `ApiPrestadoresSettings` |
| Polly policies | Si (retry + circuit breaker) | No implementado |
| Custom handlers | LoggingHandler, RetryHandler, AuthHandler | Solo header propagation |
| Extension methods DI | `ApiPrestadoresServiceExtensions` | Inline en Program.cs |
| Metodos | 4 (sin favorites) | 10 (con favorites + agregar/quitar) |
| Base class | No (client standalone) | Si (`BaseApiClient` abstracto) |

---

## 2. Estructura Implementada

```
BackendServices/
├── Common/                          # Infraestructura compartida
│   ├── BaseApiClient.cs             # Abstract base con ExecuteGet/PostAsync
│   ├── HandlerExceptionResponseDto.cs
│   ├── IPaging.cs
│   ├── PaginatedResponseBase.cs     # Generic PaginatedResponseBase<T>
│   ├── Helpers/
│   │   ├── ApiClientExceptionHandler.cs
│   │   ├── ApiErrorBuilder.cs
│   │   └── ApiUrlBuilder.cs         # Query string builder sofisticado
│   └── Interfaces/
│       ├── ApiConfiguration.cs      # Record para config
│       └── IBaseApiClient.cs
│
├── ApiPrestadores/
│   ├── ApiPrestadoresClient.cs      # Implementacion (TIENE MERGE CONFLICT)
│   ├── ApiPrestadoresClientServiceConfig.cs  # Config POCO
│   ├── Constants/
│   │   └── ValidationMessages.cs
│   ├── Enums/
│   │   ├── ProfesionalFlags.cs      # [Flags] None/Domicilios/Matriculas/etc
│   │   ├── EntidadSaludFlags.cs     # [Flags] None/Localidad/Telefonos/etc
│   │   └── TipoEntidadSalud.cs
│   ├── Interfaces/
│   │   └── IApiPrestadoresClient.cs # 10 metodos
│   ├── Models/                      # 18+ DTOs como records
│   │   ├── Common/ (EspecialidadMedicaDto, LocalidadDto, PaisDto, etc.)
│   │   ├── EntidadSalud/ (FindByFilters/FindNearby/FindFavorites Request+Response+Paginated)
│   │   └── Profesional/ (FindByFilters/FindNearby/FindFavorites Request+Response+Paginated)
│   └── Validators/                  # FluentValidation
│       ├── EntidadSaludFindByFiltersRequestDtoValidator.cs
│       ├── EntidadSaludFindFavoritesRequestDtoValidator.cs
│       ├── EntidadSaludFindNearbyRequestDtoValidator.cs
│       ├── FindNearbyRequestDtoBaseValidator.cs
│       ├── ProfesionalFindByFiltersRequestDtoValidator.cs
│       ├── ProfesionalFindFavoritesRequestDtoValidator.cs
│       └── ProfesionalFindNearbyRequestDtoValidator.cs
│
└── ApiGestionSolicitudes/           # Segundo client (patron Resource Services)
    ├── ApiGestionSolicitudesClient.cs
    ├── Services/ (6 resources)
    ├── Models/ (40+ DTOs)
    └── Validators/
```

---

## 3. Interfaz del Cliente (10 metodos)

```csharp
public interface IApiPrestadoresClient
{
    // Profesionales
    Task<ProfesionalFindNearbyPaginatedResponseDto> ProfesionalFindNearbyAsync(ProfesionalFindNearbyRequestDto, CancellationToken);
    Task<ProfesionalFindByFiltersPaginatedResponseDto> FindByFiltersAsync(ProfesionalFindByFiltersRequestDto, CancellationToken);
    Task<ProfesionalFindFavoritesPaginatedResponseDto> ProfesionalFindFavoritesAsync(ProfesionalFindFavoritesRequestDto, CancellationToken);
    Task ProfesionalAgregarFavoritoAsync(...);
    Task ProfesionalQuitarFavoritoAsync(...);

    // Entidades de Salud
    Task<EntidadSaludFindNearbyPaginatedResponseDto> EntidadSaludFindNearbyAsync(EntidadSaludFindNearbyRequestDto, CancellationToken);
    Task<EntidadSaludFindByFiltersPaginatedResponseDto> EntidadSaludFindByFiltersAsync(EntidadSaludFindByFiltersRequestDto, CancellationToken);
    Task<EntidadSaludFindFavoritesPaginatedResponseDto> EntidadSaludFindFavoritesAsync(EntidadSaludFindFavoritesRequestDto, CancellationToken);
    Task EntidadSaludAgregarFavoritoAsync(...);
    Task EntidadSaludQuitarFavoritoAsync(...);
}
```

---

## 4. Configuracion (appsettings)

```json
"ApiPrestadoresSettings": {
    "RutaApiPrestadores": "http://srvappdevelop.jerarquicossalud.com.ar:8290/api/prestadores/",
    "NamedClient": "ApiPrestadores",
    "Username": "AppMobileJS",
    "Proxy": false,
    "ProfesionalFindNearby": "v1/profesional/findnearby",
    "ProfesionalFindByFilters": "v2/profesional/findbyfilters",
    "ProfesionalFindFavorites": "v1/profesional/findfavorites",
    "EntidadSaludFindNearby": "v1/entidadessalud/findnearby",
    "EntidadSaludFindByFilters": "v2/entidadessalud/findbyfilters",
    "EntidadSaludFindFavorites": "v1/entidadessalud/findfavorites"
}
```

Registrado en Program.cs con IHttpClientFactory + IOptions + header propagation.

---

## 5. Registro DI

```csharp
// Program.cs - HttpClient
builder.Services.AddHttpClient(prestadoresConfig.NamedClient, httpClient => {
    httpClient.BaseAddress = new Uri(prestadoresConfig.RutaApiPrestadores);
    httpClient.DefaultRequestHeaders.Add("Accept", "application/json");
    httpClient.DefaultRequestHeaders.Add("X-User-Name", prestadoresConfig.UserName);
}).ConfigurePrimaryHttpMessageHandler(() => new HttpClientHandler() { UseProxy = prestadoresConfig.Proxy })
  .AddHeaderPropagation();

// DependencyInjectionManagement.cs - Service
services.AddScoped<IApiPrestadoresClient, ApiPrestadoresClient>();
```

---

## 6. Testing (18 archivos)

- `ApiPrestadoresClientConstructorTests.cs`
- `ApiPrestadoresClientProfesionalTests.cs`
- `ApiPrestadoresClientEntidadSaludTests.cs`
- `ApiPrestadoresClientExceptionTests.cs`
- `ApiPrestadoresClientQueryStringTests.cs`
- 8 validator tests
- DTO model tests
- Common tests (ApiClientException, ApiUrlBuilder, TestBase)

Patron: NUnit + Moq + FluentAssertions

---

## 7. Endpoints de API Prestadores

| Metodo | Version | Endpoint | HTTP |
|--------|---------|----------|------|
| ProfesionalFindNearby | v1 | `v1/profesional/findnearby` | GET |
| ProfesionalFindByFilters | v2 | `v2/profesional/findbyfilters` | POST |
| ProfesionalFindFavorites | v1 | `v1/profesional/findfavorites` | GET |
| EntidadSaludFindNearby | v1 | `v1/entidadessalud/findnearby` | GET |
| EntidadSaludFindByFilters | v2 | `v2/entidadessalud/findbyfilters` | POST |
| EntidadSaludFindFavorites | v1 | `v1/entidadessalud/findfavorites` | GET |

**Nota:** FindFavorites puede no estar disponible en la API destino (verificar).

---

## 8. Flags

```csharp
[Flags] ProfesionalFlags: None=0, Domicilios=1, Matriculas=2, Especialidades=4, Convenios=8, All=15
[Flags] EntidadSaludFlags: None=0, Localidad=1, Telefonos=2, Convenios=4, Servicios=8, All=15
```
