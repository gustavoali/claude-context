# Documento de Diseño Arquitectónico
## ApiPrestadores.Client - Componente para APIMovil_net8

**Versión:** 1.0
**Fecha:** 2025-11-13
**Autor:** Arquitectura de Software
**Estado:** Diseño Aprobado para Implementación

---

## Tabla de Contenidos

1. [Executive Summary](#1-executive-summary)
2. [Análisis de APIProgramasSocios BackendServices](#2-análisis-de-apiprogramassocios-backendservices)
3. [Análisis de ApiPrestadoresClient Legacy](#3-análisis-de-apiprestadoresclient-legacy)
4. [Revisión de API Prestadores](#4-revisión-de-api-prestadores)
5. [Diseño Arquitectónico del Nuevo Cliente](#5-diseño-arquitectónico-del-nuevo-cliente)
6. [Recomendaciones](#6-recomendaciones)

---

## 1. Executive Summary

### 1.1 Objetivos del Proyecto

Migrar la funcionalidad del cliente `ApiPrestadoresClient` desde la arquitectura legacy (.NET Framework) hacia el nuevo proyecto **APIMovil_net8** (.NET 8 con Clean Architecture), modernizando:

- Uso de `IHttpClientFactory` en lugar de singleton custom
- Async/await en todos los métodos
- Manejo de errores robusto con logging estructurado
- Retry policies y circuit breaker patterns (Polly)
- Configuración flexible mediante appsettings.json
- DTOs modernos con validación (FluentValidation)
- Integración con inyección de dependencias nativa de .NET

### 1.2 Scope

**En Scope:**
- 6 métodos principales del cliente de prestadores
- Versionado de API (v1 y v2)
- Manejo de paginación
- DTOs para profesionales y entidades de salud
- Enums para flags configurables

**Fuera de Scope:**
- Funcionalidad de favoritos (a evaluar en siguiente fase)
- Migración de datos
- Cambios en la API Prestadores

### 1.3 Entregables Esperados

1. Componente `ApiPrestadores.Client` en capa Infrastructure
2. Interfaces en capa Application
3. DTOs en capa Dto
4. Tests unitarios y de integración
5. Documentación de configuración
6. Documentación de uso

---

## 2. Análisis de APIProgramasSocios BackendServices

### 2.1 Estructura del Proyecto

APIProgramasSocios implementa un patrón moderno de cliente HTTP que sirve como referencia arquitectónica.

**Estructura de Carpetas:**
```
APIProgramasSocios/
└── src/
    └── BackendServices/
        ├── BackendServices.csproj
        └── ApiSocios/
            ├── Interfaces/
            │   └── IApiSociosClient.cs
            ├── Models/
            │   ├── SocioFindAllRequestDto.cs
            │   └── SocioFindAsyncResponseDto.cs
            ├── ApiSociosClient.cs
            └── ApiSociosClientServiceConfig.cs
```

### 2.2 Patrones Identificados

#### 2.2.1 Cliente HTTP

**Archivo:** `ApiSociosClient.cs`

**Patrones observados:**

1. **IHttpClientFactory Pattern:**
   - Uso de `IHttpClientFactory` para crear clientes HTTP
   - Named client pattern: `"ApiSocios"`
   - Evita agotamiento de sockets

2. **Dependency Injection:**
   ```csharp
   public ApiSociosClient(IHttpClientFactory httpClientFactory,
                          ILogger<ApiSociosClient> logger,
                          IOptions<ApiSociosClientServiceConfig> socioClientServiceConfig)
   ```

3. **Configuración mediante IOptions:**
   - Uso de `IOptions<T>` para configuración
   - Permite hot-reload de configuración
   - Fuertemente tipado

4. **Logging Estructurado:**
   ```csharp
   this.logger.LogError(ex, $"FindAllSocio - GetAsync - {ex.Message}");
   ```

5. **Async/Await:**
   - Todos los métodos públicos son asíncronos
   - Uso correcto de `await` sin bloqueos

#### 2.2.2 Configuración

**Archivo:** `ApiSociosClientServiceConfig.cs`

```csharp
public class ApiSociosClientServiceConfig
{
    public string NamedClient { get; set; }
    public string Authorization { get; set; }
    public string Username { get; set; }
    public bool Proxy { get; set; }
    public string RutaApiSocios { get; set; }
    public string FindAllSocios { get; set; }
}
```

**Observaciones:**
- Configuración simple y directa
- Rutas de endpoints configurables
- Headers personalizables

#### 2.2.3 Manejo de Errores

**Patrón observado:**
```csharp
try
{
    // Llamada HTTP
    if (response != null && response.IsSuccessStatusCode && response.Content != null)
    {
        var jsonString = await response.Content.ReadAsStringAsync();
        return JsonConvert.DeserializeObject<T>(jsonString);
    }
    return null;
}
catch (Exception ex)
{
    this.logger.LogError(ex, $"Method - GetAsync - {ex.Message}");
    return null;
}
```

**Mejoras a aplicar:**
- Agregar retry policies
- Agregar circuit breaker
- Manejo específico de excepciones HTTP

#### 2.2.4 Dependencias

**Archivo:** `BackendServices.csproj`

```xml
<ItemGroup>
    <PackageReference Include="Microsoft.Extensions.Http" Version="6.0.0" />
    <PackageReference Include="Microsoft.Extensions.Logging.Abstractions" Version="6.0.1" />
    <PackageReference Include="Newtonsoft.Json" Version="13.0.3" />
    <PackageReference Include="Swashbuckle.AspNetCore.Annotations" Version="6.5.0" />
</ItemGroup>
```

### 2.3 Mejores Prácticas Observadas

1. **Separación de responsabilidades:** Interfaz, implementación, configuración en archivos separados
2. **Inmutabilidad de configuración:** Uso de `IOptions<T>`
3. **Logging consistente:** Logger inyectado, no estático
4. **Named clients:** Facilita configuración específica por cliente
5. **Manejo de null:** Validaciones explícitas antes de deserializar

### 2.4 Áreas de Mejora Identificadas

1. **Retry policies:** No implementado (recomendado Polly)
2. **Circuit breaker:** No implementado
3. **Timeout configuración:** No explícito
4. **Telemetría:** No observada
5. **Validación de DTOs:** No implementada

---

## 3. Análisis de ApiPrestadoresClient Legacy

### 3.1 Estructura Actual

**Ubicación:** `C:\jerarquicos\Repositorio-ApiMovil\BackendServices\ApiPrestadores\`

**Estructura de Archivos:**
```
ApiPrestadores/
├── Interfaces/
│   └── IApiPrestadoresClient.cs
├── Services/
│   └── ApiPrestadoresClient.cs
├── Models/
│   ├── ProfesionalFindByFiltersRequestDto.cs
│   ├── ProfesionalFindByFiltersResponseDto.cs
│   ├── ProfesionalFindByFiltersPaginatedResponseDto.cs
│   ├── ProfesionalFindNearbyRequestDto.cs
│   ├── ProfesionalFindNearbyResponseDto.cs
│   ├── ProfesionalFindNearbyPaginatedResponseDto.cs
│   ├── ProfesionalFindFavoritesRequestDto.cs
│   ├── ProfesionalFindFavoritesResponseDto.cs
│   ├── ProfesionalFindFavoritesPaginatedResponseDto.cs
│   ├── EntidadSaludFindByFiltersRequestDto.cs
│   ├── EntidadSaludFindByFiltersResponseDto.cs
│   ├── EntidadSaludFindByFiltersPaginatedResponseDto.cs
│   ├── EntidadSaludFindNearbyRequestDto.cs
│   ├── EntidadSaludFindNearbyResponseDto.cs
│   ├── EntidadSaludFindNearbyPaginatedResponseDto.cs
│   ├── EntidadSaludFindFavoritesRequestDto.cs
│   ├── EntidadSaludFindFavoritesResponseDto.cs
│   ├── EntidadSaludFindFavoritesPaginatedResponseDto.cs
│   ├── DomicilioProfesionalDto.cs
│   ├── EspecialidadMedicaDto.cs
│   ├── LocalidadDto.cs
│   ├── ProvinciaDto.cs
│   ├── PaisDto.cs
│   └── TelefonoPrestadorDto.cs
├── Enum/
│   ├── ProfesionalFlags.cs
│   └── EntidadSaludFlags.cs
└── ApiPrestadoresServiceConfig.cs
```

### 3.2 Métodos Expuestos

**Interfaz:** `IApiPrestadoresClient.cs`

```csharp
public interface IApiPrestadoresClient
{
    // Profesionales
    Task<ProfesionalFindNearbyPaginatedResponseDto> FindNearby(ProfesionalFindNearbyRequestDto filter);
    Task<ProfesionalFindByFiltersPaginatedResponseDto> FindByFilters(ProfesionalFindByFiltersRequestDto filter);
    Task<ProfesionalFindFavoritesPaginatedResponseDto> ProfesionalFindFavorites(ProfesionalFindFavoritesRequestDto filter);

    // Entidades de Salud
    Task<EntidadSaludFindNearbyPaginatedResponseDto> EntidadSaludFindNearby(EntidadSaludFindNearbyRequestDto filter);
    Task<EntidadSaludFindByFiltersPaginatedResponseDto> EntidadSaludFindByFilters(EntidadSaludFindByFiltersRequestDto filter);
    Task<EntidadSaludFindFavoritesPaginatedResponseDto> EntidadSaludFindFavorites(EntidadSaludFindFavoritesRequestDto filter);
}
```

### 3.3 Endpoints Consumidos

#### 3.3.1 Profesionales

| Método | Versión API | Endpoint | HTTP Verb | Descripción |
|--------|-------------|----------|-----------|-------------|
| FindNearby | v1 | `v1/profesional/findnearby` | GET | Busca profesionales cercanos a coordenadas |
| FindByFilters | v2 | `v2/profesional/findbyfilters` | POST | Busca profesionales por múltiples filtros |
| ProfesionalFindFavorites | v1 | `v1/profesional/findfavorites` | GET | Obtiene profesionales favoritos |

#### 3.3.2 Entidades de Salud

| Método | Versión API | Endpoint | HTTP Verb | Descripción |
|--------|-------------|----------|-----------|-------------|
| EntidadSaludFindNearby | v1 | `v1/entidadessalud/findnearby` | GET | Busca entidades cercanas a coordenadas |
| EntidadSaludFindByFilters | v2 | `v2/entidadessalud/findbyfilters` | POST | Busca entidades por múltiples filtros |
| EntidadSaludFindFavorites | v1 | `v1/entidadessalud/findfavorites` | GET | Obtiene entidades favoritas |

### 3.4 DTOs Clave

#### 3.4.1 ProfesionalFindByFiltersRequestDto

```csharp
public class ProfesionalFindByFiltersRequestDto
{
    public int? IdEspecialidadMedica { get; set; }
    public string ApellidoNombre { get; set; } = string.Empty;
    public string Cuit { get; set; } = string.Empty;
    public int IdPais { get; set; }  // Obligatorio
    public int? IdProvincia { get; set; }
    public int? IdLocalidad { get; set; }
    public List<int> IdLocalidadesCercanas { get; set; } = new List<int>();
    public int? IdPlan { get; set; }
    public DateTime? FechaConsultaPlan { get; set; }
    public int Flags { get; set; } = 0;  // ProfesionalFlags

    // Paginación
    public bool? WithPagination { get; set; } = true;
    public int? Page { get; set; }
    public int? PageSize { get; set; }
    public string[] OrderBy { get; set; } = null;
}
```

#### 3.4.2 ProfesionalFlags Enum

```csharp
[Flags]
public enum ProfesionalFlags
{
    None = 0,
    Domicilios = 1,
    Matriculas = 2,
    Especialidades = 4,
    Convenios = 8,
    All = Domicilios | Matriculas | Especialidades | Convenios
}
```

#### 3.4.3 Response Paginado

```csharp
public class ProfesionalFindByFiltersPaginatedResponseDto
{
    public List<ProfesionalFindByFiltersResponseDto> Data { get; set; }
    public int TotalRecords { get; set; }
    public int TotalPages { get; set; }
    public int CurrentPage { get; set; }
    public int PageSize { get; set; }
}
```

### 3.5 Lógica de Negocio en el Cliente

**Observaciones importantes:**

1. **Manejo de errores silencioso:**
   ```csharp
   catch (Exception)
   {
       return new ProfesionalFindNearbyPaginatedResponseDto();
   }
   ```
   - Retorna objetos vacíos en lugar de propagar excepciones
   - No hay logging de errores
   - Dificulta debugging

2. **Dependencia de BaseApiClient:**
   - Usa `BaseApiClient` con `ApiConnectorSingleton`
   - Genera query strings automáticamente
   - Maneja headers de contexto (CorrelationId)

3. **ConfigureAwait(false):**
   - Correctamente implementado en métodos async
   - Evita deadlocks

4. **Serialización:**
   - Usa `Newtonsoft.Json` (JsonConvert)
   - Serialización redundante en línea 70 (no utilizada)

### 3.6 Dependencias del Legacy

```csharp
using BackendServices.ApiPrestadores.Dto;
using BackendServices.ApiPrestadores.Interfaces;
using BackendServices.Common;
using Newtonsoft.Json;
using System;
using System.Configuration;
using System.Net;
using System.Threading.Tasks;
```

**Dependencias a reemplazar:**
- `BackendServices.Common` → Implementación propia con IHttpClientFactory
- `System.Configuration.ConfigurationManager` → `IOptions<T>`
- `ApiConnectorSingleton` → IHttpClientFactory

### 3.7 Configuración Legacy

**Archivo:** `ApiPrestadoresServiceConfig.cs`

```csharp
public static class ApiPrestadoresServiceConfig
{
    public const string BASEURLCONFIGKEY = "UrlApiPrestadores";
    public const string NAMEDCLIENT = "ApiPrestadores";
    public const string USERNAME = "ApiPrestadores Default";
    public const string AUTHORIZATION = "ApiPrestadores Default - Token";
    public const string VERSION1 = "v1/";
    public const string VERSION2 = "v2/";

    // Endpoints
    public const string UrlProfesionalesCercademi = VERSION1 + "profesional/findnearby";
    public const string UrlProfesionalesFindbyFiltersPost = VERSION2 + "profesional/findbyfilters";
    public const string UrlEntidadesSaludCercademi = VERSION1 + "entidadessalud/findnearby";
    public const string UrlEntidadesSaludFindbyFiltersPost = VERSION2 + "entidadessalud/findbyfilters";
    public const string UrlProfesionalFindFavorites = VERSION1 + "profesional/findfavorites";
    public const string UrlEntidadSaludFindFavorites = VERSION1 + "entidadessalud/findfavorites";
}
```

**Observaciones:**
- Configuración mediante constantes (rígido)
- Debe migrar a appsettings.json

---

## 4. Revisión de API Prestadores

### 4.1 Controllers Disponibles

**Ubicación:** `C:\jerarquicos\APIPrestadores\src\ApiPrestadores.Api\Controllers\`

1. `ProfesionalController.cs`
2. `EntidadSaludController.cs`

### 4.2 Endpoints Verificados

#### 4.2.1 ProfesionalController

| Endpoint | Versión | Método HTTP | Descripción | Estado |
|----------|---------|-------------|-------------|--------|
| `/api/v1/profesional/findbyidconvenio` | v1 | GET | Busca por convenio | ✅ Disponible |
| `/api/v1/profesional/findbyfilters` | v1 | GET | Busca por filtros (query) | ✅ Disponible |
| `/api/v2/profesional/findbyfilters` | v2 | POST | Busca por filtros (body) | ✅ Disponible |
| `/api/v1/profesional/cercademi` | v1 | GET | Busca cercanos | ✅ Disponible |

**Nota importante:** El endpoint `findfavorites` NO está implementado en el controller actual de APIPrestadores.

#### 4.2.2 EntidadSaludController

| Endpoint | Versión | Método HTTP | Descripción | Estado |
|----------|---------|-------------|-------------|--------|
| `/api/v1/entidadessalud/findbyidconvenio` | v1 | GET | Busca por convenio | ✅ Disponible |
| `/api/v1/entidadessalud/findbyfilters` | v1 | GET | Busca por filtros (query) | ✅ Disponible |
| `/api/v2/entidadessalud/findbyfilters` | v2 | POST | Busca por filtros (body) | ✅ Disponible |
| `/api/v1/entidadessalud/cercademi` | v1 | GET | Busca cercanos | ✅ Disponible |

**Nota importante:** El endpoint `findfavorites` NO está implementado en el controller actual de APIPrestadores.

### 4.3 Contratos de API

#### 4.3.1 Profesional FindByFilters v2 (POST)

**Request:**
```json
{
  "idEspecialidadMedica": 0,
  "apellidoNombre": "string",
  "cuit": "string",
  "idPais": 0,
  "idProvincia": 0,
  "idLocalidad": 0,
  "idLocalidadesCercanas": [0],
  "idBarriosSeleccionados": [0],
  "idPlan": 0,
  "fechaConsultaPlan": "2025-10-21T15:27:48.286Z",
  "flags": 0,
  "withPagination": true,
  "page": 0,
  "pageSize": 0,
  "orderBy": ["string"]
}
```

**Response:**
```csharp
ProfesionalFindByFiltersPaginatedResponseDto
{
    Data: List<ProfesionalFindByFiltersResponseDto>,
    TotalRecords: int,
    TotalPages: int,
    CurrentPage: int,
    PageSize: int
}
```

#### 4.3.2 Profesional FindNearby v1 (GET)

**Query Parameters:**
- `nombre`: string (opcional)
- `idEspecialidadMedica`: int (opcional)
- `longitud`: double (obligatorio)
- `latitud`: double (obligatorio)
- `radio`: int (obligatorio, en km)
- `page`: int
- `pageSize`: int

### 4.4 Flags en API

#### Profesional Flags

```csharp
None = 0
Domicilios = 1
Matriculas = 2
Especialidades = 4
Convenios = 8
All = 15  // Domicilios | Matriculas | Especialidades | Convenios
```

#### EntidadSalud Flags

```csharp
None = 0
Localidad = 1
Telefonos = 2
Convenios = 4
Servicios = 8
All = 15  // Localidad | Telefonos | Convenios | Servicios
```

### 4.5 Versionado de API

La API usa `Asp.Versioning`:

```csharp
[ApiVersion("1.0")]
[ApiVersion("2.0")]
[Route("api/v{version:apiVersion}/profesional/")]
```

**Diferencias entre v1 y v2:**
- **v1:** Parámetros por query string (GET)
- **v2:** Parámetros en body (POST) - Mayor flexibilidad para filtros complejos

### 4.6 Discrepancias con Legacy

| Aspecto | Legacy | API Actual | Impacto |
|---------|--------|------------|---------|
| FindFavorites | ✅ Implementado | ❌ No disponible | Alto - Requiere aclaración |
| IdBarriosSeleccionados | ❌ No existe | ✅ Disponible | Bajo - Nuevo parámetro |
| Route "cercademi" | findnearby | cercademi | Bajo - Solo cambio de nombre |

---

## 5. Diseño Arquitectónico del Nuevo Cliente

### 5.1 Arquitectura General

El nuevo cliente seguirá **Clean Architecture** de APIMovil_net8:

```
┌──────────────────────────────────────────────────────────┐
│                    API Layer (Controllers)                │
│                  ApiJsMobile.Api                          │
└───────────────────────┬──────────────────────────────────┘
                        │
┌───────────────────────▼──────────────────────────────────┐
│               Application Layer                           │
│              ApiJsMobile.Application                      │
│  ┌─────────────────────────────────────────────┐         │
│  │  Interfaces/IApiPrestadoresClient.cs        │         │
│  │  - Define contrato del cliente              │         │
│  └─────────────────────────────────────────────┘         │
└───────────────────────┬──────────────────────────────────┘
                        │
┌───────────────────────▼──────────────────────────────────┐
│                  DTO Layer                                │
│                ApiJsMobile.Dto                            │
│  ┌──────────────────────────────────────────────┐        │
│  │  ApiPrestadores/                             │        │
│  │  ├── Request/                                │        │
│  │  │   ├── ProfesionalFindByFiltersRequest.cs │        │
│  │  │   └── ...                                 │        │
│  │  ├── Response/                               │        │
│  │  │   ├── ProfesionalFindByFiltersResponse.cs│        │
│  │  │   └── ...                                 │        │
│  │  └── Enums/                                  │        │
│  │      ├── ProfesionalFlags.cs                 │        │
│  │      └── EntidadSaludFlags.cs                │        │
│  └──────────────────────────────────────────────┘        │
└───────────────────────┬──────────────────────────────────┘
                        │
┌───────────────────────▼──────────────────────────────────┐
│              Infrastructure Layer                         │
│           ApiJsMobile.Infrastructure                      │
│  ┌──────────────────────────────────────────────┐        │
│  │  HttpClients/                                │        │
│  │  └── ApiPrestadores/                         │        │
│  │      ├── ApiPrestadoresClient.cs             │        │
│  │      ├── ApiPrestadoresClientOptions.cs      │        │
│  │      ├── Handlers/                           │        │
│  │      │   ├── ApiPrestadoresLoggingHandler.cs │        │
│  │      │   └── ApiPrestadoresRetryHandler.cs   │        │
│  │      └── Extensions/                         │        │
│  │          └── HttpClientServiceExtensions.cs  │        │
│  └──────────────────────────────────────────────┘        │
└──────────────────────────────────────────────────────────┘
```

### 5.2 Estructura de Carpetas Propuesta

```
APIMovil_net8/
├── src/
│   ├── ApiJsMobile.Application/
│   │   └── Interfaces/
│   │       └── IApiPrestadoresClient.cs
│   │
│   ├── ApiJsMobile.Dto/
│   │   └── ApiPrestadores/
│   │       ├── Request/
│   │       │   ├── ProfesionalFindByFiltersRequest.cs
│   │       │   ├── ProfesionalFindNearbyRequest.cs
│   │       │   ├── EntidadSaludFindByFiltersRequest.cs
│   │       │   ├── EntidadSaludFindNearbyRequest.cs
│   │       │   └── Common/
│   │       │       └── PaginationRequest.cs
│   │       ├── Response/
│   │       │   ├── ProfesionalFindByFiltersResponse.cs
│   │       │   ├── ProfesionalFindNearbyResponse.cs
│   │       │   ├── EntidadSaludFindByFiltersResponse.cs
│   │       │   ├── EntidadSaludFindNearbyResponse.cs
│   │       │   ├── Common/
│   │       │   │   └── PaginatedResponse.cs
│   │       │   └── Nested/
│   │       │       ├── DomicilioProfesional.cs
│   │       │       ├── EspecialidadMedica.cs
│   │       │       ├── Localidad.cs
│   │       │       ├── Provincia.cs
│   │       │       ├── Pais.cs
│   │       │       └── TelefonoPrestador.cs
│   │       └── Enums/
│   │           ├── ProfesionalFlags.cs
│   │           └── EntidadSaludFlags.cs
│   │
│   └── ApiJsMobile.Infrastructure/
│       ├── HttpClients/
│       │   └── ApiPrestadores/
│       │       ├── ApiPrestadoresClient.cs
│       │       ├── ApiPrestadoresClientOptions.cs
│       │       ├── Handlers/
│       │       │   ├── ApiPrestadoresLoggingHandler.cs
│       │       │   ├── ApiPrestadoresRetryHandler.cs
│       │       │   └── ApiPrestadoresAuthHandler.cs
│       │       └── Extensions/
│       │           └── ApiPrestadoresServiceExtensions.cs
│       └── DependencyInjectionManagement.cs (actualizar)
│
├── tests/
│   ├── ApiJsMobile.Infrastructure.Test/
│   │   └── HttpClients/
│   │       └── ApiPrestadores/
│   │           ├── ApiPrestadoresClientTests.cs
│   │           └── Mocks/
│   │               └── MockApiPrestadoresHttpMessageHandler.cs
│   │
│   └── ApiJsMobile.Integration.Test/
│       └── ApiPrestadores/
│           └── ApiPrestadoresClientIntegrationTests.cs
│
└── docs/
    └── ApiPrestadoresClient/
        ├── Configuration.md
        └── Usage.md
```

### 5.3 Componentes Principales

#### 5.3.1 Interfaz del Cliente

**Archivo:** `ApiJsMobile.Application/Interfaces/IApiPrestadoresClient.cs`

```csharp
namespace ApiJsMobile.Application.Interfaces;

using ApiJsMobile.Dto.ApiPrestadores.Request;
using ApiJsMobile.Dto.ApiPrestadores.Response;

/// <summary>
/// Cliente para consumir la API de Prestadores.
/// Permite buscar profesionales de salud y entidades de salud según diversos criterios.
/// </summary>
public interface IApiPrestadoresClient
{
    #region Profesionales

    /// <summary>
    /// Busca profesionales de salud cercanos a una ubicación geográfica.
    /// </summary>
    /// <param name="request">Filtros de búsqueda incluyendo coordenadas y radio.</param>
    /// <param name="cancellationToken">Token de cancelación.</param>
    /// <returns>Lista paginada de profesionales cercanos.</returns>
    Task<ProfesionalFindNearbyResponse> FindNearbyAsync(
        ProfesionalFindNearbyRequest request,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Busca profesionales de salud según múltiples filtros.
    /// Utiliza API v2 con método POST para soportar filtros complejos.
    /// </summary>
    /// <param name="request">Filtros de búsqueda (especialidad, nombre, ubicación, etc.).</param>
    /// <param name="cancellationToken">Token de cancelación.</param>
    /// <returns>Lista paginada de profesionales que cumplen los criterios.</returns>
    Task<ProfesionalFindByFiltersResponse> FindByFiltersAsync(
        ProfesionalFindByFiltersRequest request,
        CancellationToken cancellationToken = default);

    #endregion

    #region Entidades de Salud

    /// <summary>
    /// Busca entidades de salud cercanas a una ubicación geográfica.
    /// </summary>
    /// <param name="request">Filtros de búsqueda incluyendo coordenadas y radio.</param>
    /// <param name="cancellationToken">Token de cancelación.</param>
    /// <returns>Lista paginada de entidades de salud cercanas.</returns>
    Task<EntidadSaludFindNearbyResponse> FindNearbyAsync(
        EntidadSaludFindNearbyRequest request,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Busca entidades de salud según múltiples filtros.
    /// Utiliza API v2 con método POST para soportar filtros complejos.
    /// </summary>
    /// <param name="request">Filtros de búsqueda (tipo, servicios, ubicación, etc.).</param>
    /// <param name="cancellationToken">Token de cancelación.</param>
    /// <returns>Lista paginada de entidades de salud que cumplen los criterios.</returns>
    Task<EntidadSaludFindByFiltersResponse> FindByFiltersAsync(
        EntidadSaludFindByFiltersRequest request,
        CancellationToken cancellationToken = default);

    #endregion
}
```

#### 5.3.2 Implementación del Cliente

**Archivo:** `ApiJsMobile.Infrastructure/HttpClients/ApiPrestadores/ApiPrestadoresClient.cs`

```csharp
namespace ApiJsMobile.Infrastructure.HttpClients.ApiPrestadores;

using System.Net.Http.Json;
using System.Text;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using ApiJsMobile.Application.Interfaces;
using ApiJsMobile.Dto.ApiPrestadores.Request;
using ApiJsMobile.Dto.ApiPrestadores.Response;

public class ApiPrestadoresClient : IApiPrestadoresClient
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<ApiPrestadoresClient> _logger;
    private readonly ApiPrestadoresClientOptions _options;

    private const string V1_PROFESIONAL_NEARBY = "v1/profesional/cercademi";
    private const string V2_PROFESIONAL_FILTERS = "v2/profesional/findbyfilters";
    private const string V1_ENTIDADSALUD_NEARBY = "v1/entidadessalud/cercademi";
    private const string V2_ENTIDADSALUD_FILTERS = "v2/entidadessalud/findbyfilters";

    public ApiPrestadoresClient(
        HttpClient httpClient,
        ILogger<ApiPrestadoresClient> logger,
        IOptions<ApiPrestadoresClientOptions> options)
    {
        _httpClient = httpClient ?? throw new ArgumentNullException(nameof(httpClient));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        _options = options?.Value ?? throw new ArgumentNullException(nameof(options));
    }

    #region Profesionales

    public async Task<ProfesionalFindNearbyResponse> FindNearbyAsync(
        ProfesionalFindNearbyRequest request,
        CancellationToken cancellationToken = default)
    {
        if (request == null)
            throw new ArgumentNullException(nameof(request));

        try
        {
            _logger.LogInformation(
                "Buscando profesionales cercanos. Lat: {Latitud}, Long: {Longitud}, Radio: {Radio}",
                request.Latitud, request.Longitud, request.Radio);

            var queryString = BuildQueryString(request);
            var url = $"{V1_PROFESIONAL_NEARBY}{queryString}";

            var response = await _httpClient.GetAsync(url, cancellationToken)
                .ConfigureAwait(false);

            response.EnsureSuccessStatusCode();

            var result = await response.Content
                .ReadFromJsonAsync<ProfesionalFindNearbyResponse>(cancellationToken: cancellationToken)
                .ConfigureAwait(false);

            _logger.LogInformation(
                "Profesionales encontrados: {Count}",
                result?.Data?.Count ?? 0);

            return result ?? new ProfesionalFindNearbyResponse();
        }
        catch (HttpRequestException ex)
        {
            _logger.LogError(ex,
                "Error HTTP al buscar profesionales cercanos. StatusCode: {StatusCode}",
                ex.StatusCode);
            throw;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex,
                "Error inesperado al buscar profesionales cercanos");
            throw;
        }
    }

    public async Task<ProfesionalFindByFiltersResponse> FindByFiltersAsync(
        ProfesionalFindByFiltersRequest request,
        CancellationToken cancellationToken = default)
    {
        if (request == null)
            throw new ArgumentNullException(nameof(request));

        try
        {
            _logger.LogInformation(
                "Buscando profesionales por filtros. IdPais: {IdPais}",
                request.IdPais);

            var response = await _httpClient.PostAsJsonAsync(
                V2_PROFESIONAL_FILTERS,
                request,
                cancellationToken)
                .ConfigureAwait(false);

            response.EnsureSuccessStatusCode();

            var result = await response.Content
                .ReadFromJsonAsync<ProfesionalFindByFiltersResponse>(cancellationToken: cancellationToken)
                .ConfigureAwait(false);

            _logger.LogInformation(
                "Profesionales encontrados: {Count}",
                result?.Data?.Count ?? 0);

            return result ?? new ProfesionalFindByFiltersResponse();
        }
        catch (HttpRequestException ex)
        {
            _logger.LogError(ex,
                "Error HTTP al buscar profesionales por filtros. StatusCode: {StatusCode}",
                ex.StatusCode);
            throw;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex,
                "Error inesperado al buscar profesionales por filtros");
            throw;
        }
    }

    #endregion

    #region Entidades de Salud

    public async Task<EntidadSaludFindNearbyResponse> FindNearbyAsync(
        EntidadSaludFindNearbyRequest request,
        CancellationToken cancellationToken = default)
    {
        if (request == null)
            throw new ArgumentNullException(nameof(request));

        try
        {
            _logger.LogInformation(
                "Buscando entidades de salud cercanas. Lat: {Latitud}, Long: {Longitud}, Radio: {Radio}",
                request.Latitud, request.Longitud, request.Radio);

            var queryString = BuildQueryString(request);
            var url = $"{V1_ENTIDADSALUD_NEARBY}{queryString}";

            var response = await _httpClient.GetAsync(url, cancellationToken)
                .ConfigureAwait(false);

            response.EnsureSuccessStatusCode();

            var result = await response.Content
                .ReadFromJsonAsync<EntidadSaludFindNearbyResponse>(cancellationToken: cancellationToken)
                .ConfigureAwait(false);

            _logger.LogInformation(
                "Entidades de salud encontradas: {Count}",
                result?.Data?.Count ?? 0);

            return result ?? new EntidadSaludFindNearbyResponse();
        }
        catch (HttpRequestException ex)
        {
            _logger.LogError(ex,
                "Error HTTP al buscar entidades de salud cercanas. StatusCode: {StatusCode}",
                ex.StatusCode);
            throw;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex,
                "Error inesperado al buscar entidades de salud cercanas");
            throw;
        }
    }

    public async Task<EntidadSaludFindByFiltersResponse> FindByFiltersAsync(
        EntidadSaludFindByFiltersRequest request,
        CancellationToken cancellationToken = default)
    {
        if (request == null)
            throw new ArgumentNullException(nameof(request));

        try
        {
            _logger.LogInformation(
                "Buscando entidades de salud por filtros. IdPais: {IdPais}",
                request.IdPais);

            var response = await _httpClient.PostAsJsonAsync(
                V2_ENTIDADSALUD_FILTERS,
                request,
                cancellationToken)
                .ConfigureAwait(false);

            response.EnsureSuccessStatusCode();

            var result = await response.Content
                .ReadFromJsonAsync<EntidadSaludFindByFiltersResponse>(cancellationToken: cancellationToken)
                .ConfigureAwait(false);

            _logger.LogInformation(
                "Entidades de salud encontradas: {Count}",
                result?.Data?.Count ?? 0);

            return result ?? new EntidadSaludFindByFiltersResponse();
        }
        catch (HttpRequestException ex)
        {
            _logger.LogError(ex,
                "Error HTTP al buscar entidades de salud por filtros. StatusCode: {StatusCode}",
                ex.StatusCode);
            throw;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex,
                "Error inesperado al buscar entidades de salud por filtros");
            throw;
        }
    }

    #endregion

    #region Helper Methods

    private static string BuildQueryString<T>(T request) where T : class
    {
        var properties = typeof(T).GetProperties()
            .Where(p => p.GetValue(request) != null);

        var queryParams = new List<string>();

        foreach (var prop in properties)
        {
            var value = prop.GetValue(request);
            var name = char.ToLowerInvariant(prop.Name[0]) + prop.Name.Substring(1);

            if (value is IEnumerable<int> intList)
            {
                queryParams.AddRange(intList.Select(v => $"{name}={v}"));
            }
            else if (value is IEnumerable<string> strList)
            {
                queryParams.AddRange(strList.Select(v => $"{name}={Uri.EscapeDataString(v)}"));
            }
            else if (value is DateTime dateTime)
            {
                queryParams.Add($"{name}={dateTime:yyyy-MM-dd}");
            }
            else if (value is double doubleValue)
            {
                queryParams.Add($"{name}={doubleValue.ToString(System.Globalization.CultureInfo.InvariantCulture)}");
            }
            else
            {
                queryParams.Add($"{name}={Uri.EscapeDataString(value.ToString())}");
            }
        }

        return queryParams.Count > 0 ? "?" + string.Join("&", queryParams) : string.Empty;
    }

    #endregion
}
```

#### 5.3.3 Configuración

**Archivo:** `ApiJsMobile.Infrastructure/HttpClients/ApiPrestadores/ApiPrestadoresClientOptions.cs`

```csharp
namespace ApiJsMobile.Infrastructure.HttpClients.ApiPrestadores;

/// <summary>
/// Configuración para el cliente de API Prestadores.
/// </summary>
public class ApiPrestadoresClientOptions
{
    public const string SectionName = "ApiPrestadores";

    /// <summary>
    /// URL base de la API de Prestadores.
    /// Ejemplo: https://api.prestadores.com/api/
    /// </summary>
    public string BaseUrl { get; set; } = string.Empty;

    /// <summary>
    /// Timeout en segundos para las solicitudes HTTP.
    /// Por defecto: 30 segundos.
    /// </summary>
    public int TimeoutSeconds { get; set; } = 30;

    /// <summary>
    /// Username para autenticación/logging.
    /// </summary>
    public string Username { get; set; } = "APIMovil";

    /// <summary>
    /// Token de autorización si es requerido.
    /// </summary>
    public string? Authorization { get; set; }

    /// <summary>
    /// Nombre del cliente HTTP.
    /// </summary>
    public string ClientName { get; set; } = "ApiPrestadores";

    /// <summary>
    /// Habilitar retry policies (Polly).
    /// </summary>
    public bool EnableRetryPolicy { get; set; } = true;

    /// <summary>
    /// Número máximo de reintentos.
    /// </summary>
    public int MaxRetryAttempts { get; set; } = 3;

    /// <summary>
    /// Habilitar circuit breaker.
    /// </summary>
    public bool EnableCircuitBreaker { get; set; } = true;

    /// <summary>
    /// Número de fallas consecutivas antes de abrir el circuit breaker.
    /// </summary>
    public int CircuitBreakerThreshold { get; set; } = 5;

    /// <summary>
    /// Duración del circuit breaker abierto en segundos.
    /// </summary>
    public int CircuitBreakerDurationSeconds { get; set; } = 30;
}
```

**Archivo de configuración:** `appsettings.json`

```json
{
  "ApiPrestadores": {
    "BaseUrl": "https://api-prestadores.dev.jerarquicos.com.ar/api/",
    "TimeoutSeconds": 30,
    "Username": "APIMovil",
    "Authorization": "Bearer {token}",
    "ClientName": "ApiPrestadores",
    "EnableRetryPolicy": true,
    "MaxRetryAttempts": 3,
    "EnableCircuitBreaker": true,
    "CircuitBreakerThreshold": 5,
    "CircuitBreakerDurationSeconds": 30
  }
}
```

**Por ambiente:**

```json
// appsettings.Development.json
{
  "ApiPrestadores": {
    "BaseUrl": "https://api-prestadores.dev.jerarquicos.com.ar/api/",
    "TimeoutSeconds": 60
  }
}

// appsettings.Testing.json
{
  "ApiPrestadores": {
    "BaseUrl": "https://api-prestadores.test.jerarquicos.com.ar/api/",
    "EnableRetryPolicy": false
  }
}

// appsettings.Production.json
{
  "ApiPrestadores": {
    "BaseUrl": "https://api-prestadores.jerarquicos.com.ar/api/",
    "TimeoutSeconds": 30,
    "MaxRetryAttempts": 5,
    "CircuitBreakerThreshold": 10
  }
}
```

#### 5.3.4 Dependency Injection

**Archivo:** `ApiJsMobile.Infrastructure/HttpClients/ApiPrestadores/Extensions/ApiPrestadoresServiceExtensions.cs`

```csharp
namespace ApiJsMobile.Infrastructure.HttpClients.ApiPrestadores.Extensions;

using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;
using Polly;
using Polly.Extensions.Http;
using ApiJsMobile.Application.Interfaces;
using ApiJsMobile.Infrastructure.HttpClients.ApiPrestadores.Handlers;

public static class ApiPrestadoresServiceExtensions
{
    public static IServiceCollection AddApiPrestadoresClient(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        // Configuración
        services.Configure<ApiPrestadoresClientOptions>(
            configuration.GetSection(ApiPrestadoresClientOptions.SectionName));

        // Obtener opciones para configurar HttpClient
        var options = configuration
            .GetSection(ApiPrestadoresClientOptions.SectionName)
            .Get<ApiPrestadoresClientOptions>();

        if (options == null)
            throw new InvalidOperationException(
                $"La sección '{ApiPrestadoresClientOptions.SectionName}' no está configurada en appsettings.");

        // Registrar HttpClient con políticas
        var httpClientBuilder = services.AddHttpClient<IApiPrestadoresClient, ApiPrestadoresClient>(client =>
        {
            client.BaseAddress = new Uri(options.BaseUrl);
            client.Timeout = TimeSpan.FromSeconds(options.TimeoutSeconds);
            client.DefaultRequestHeaders.Add("Accept", "application/json");

            if (!string.IsNullOrEmpty(options.Username))
                client.DefaultRequestHeaders.Add("X-Username", options.Username);

            if (!string.IsNullOrEmpty(options.Authorization))
                client.DefaultRequestHeaders.Add("Authorization", options.Authorization);
        });

        // Logging Handler
        httpClientBuilder.AddHttpMessageHandler<ApiPrestadoresLoggingHandler>();

        // Retry Policy (Polly)
        if (options.EnableRetryPolicy)
        {
            httpClientBuilder.AddPolicyHandler(GetRetryPolicy(options));
        }

        // Circuit Breaker Policy (Polly)
        if (options.EnableCircuitBreaker)
        {
            httpClientBuilder.AddPolicyHandler(GetCircuitBreakerPolicy(options));
        }

        // Registrar handlers
        services.AddTransient<ApiPrestadoresLoggingHandler>();

        return services;
    }

    private static IAsyncPolicy<HttpResponseMessage> GetRetryPolicy(
        ApiPrestadoresClientOptions options)
    {
        return HttpPolicyExtensions
            .HandleTransientHttpError()
            .OrResult(msg => msg.StatusCode == System.Net.HttpStatusCode.NotFound)
            .WaitAndRetryAsync(
                retryCount: options.MaxRetryAttempts,
                sleepDurationProvider: retryAttempt =>
                    TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)),
                onRetry: (outcome, timespan, retryAttempt, context) =>
                {
                    // Log retry (se puede mejorar inyectando ILogger)
                    Console.WriteLine(
                        $"Delaying for {timespan.TotalSeconds}s, then making retry {retryAttempt}.");
                });
    }

    private static IAsyncPolicy<HttpResponseMessage> GetCircuitBreakerPolicy(
        ApiPrestadoresClientOptions options)
    {
        return HttpPolicyExtensions
            .HandleTransientHttpError()
            .CircuitBreakerAsync(
                handledEventsAllowedBeforeBreaking: options.CircuitBreakerThreshold,
                durationOfBreak: TimeSpan.FromSeconds(options.CircuitBreakerDurationSeconds),
                onBreak: (outcome, duration) =>
                {
                    Console.WriteLine(
                        $"Circuit breaker opened for {duration.TotalSeconds}s due to {outcome.Exception?.Message ?? outcome.Result?.StatusCode.ToString()}");
                },
                onReset: () =>
                {
                    Console.WriteLine("Circuit breaker reset.");
                });
    }
}
```

**Actualizar:** `ApiJsMobile.Infrastructure/DependencyInjectionManagement.cs`

```csharp
// Agregar al método InitializeInjections:
public static void InitializeInjections(this IServiceCollection services, IConfiguration configuration)
{
    // ... código existente ...

    // HTTP Clients
    InitializeHttpClients(services, configuration);
}

private static void InitializeHttpClients(this IServiceCollection services, IConfiguration configuration)
{
    services.AddApiPrestadoresClient(configuration);
}
```

#### 5.3.5 Handlers

**Archivo:** `ApiJsMobile.Infrastructure/HttpClients/ApiPrestadores/Handlers/ApiPrestadoresLoggingHandler.cs`

```csharp
namespace ApiJsMobile.Infrastructure.HttpClients.ApiPrestadores.Handlers;

using System.Diagnostics;
using Microsoft.Extensions.Logging;

public class ApiPrestadoresLoggingHandler : DelegatingHandler
{
    private readonly ILogger<ApiPrestadoresLoggingHandler> _logger;

    public ApiPrestadoresLoggingHandler(ILogger<ApiPrestadoresLoggingHandler> logger)
    {
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    protected override async Task<HttpResponseMessage> SendAsync(
        HttpRequestMessage request,
        CancellationToken cancellationToken)
    {
        var stopwatch = Stopwatch.StartNew();

        _logger.LogInformation(
            "API Prestadores Request: {Method} {Uri}",
            request.Method,
            request.RequestUri);

        try
        {
            var response = await base.SendAsync(request, cancellationToken);

            stopwatch.Stop();

            if (response.IsSuccessStatusCode)
            {
                _logger.LogInformation(
                    "API Prestadores Response: {StatusCode} in {ElapsedMs}ms",
                    (int)response.StatusCode,
                    stopwatch.ElapsedMilliseconds);
            }
            else
            {
                _logger.LogWarning(
                    "API Prestadores Response: {StatusCode} {ReasonPhrase} in {ElapsedMs}ms",
                    (int)response.StatusCode,
                    response.ReasonPhrase,
                    stopwatch.ElapsedMilliseconds);
            }

            return response;
        }
        catch (Exception ex)
        {
            stopwatch.Stop();

            _logger.LogError(ex,
                "API Prestadores Request failed after {ElapsedMs}ms: {Method} {Uri}",
                stopwatch.ElapsedMilliseconds,
                request.Method,
                request.RequestUri);

            throw;
        }
    }
}
```

#### 5.3.6 DTOs Modernos

**Archivo:** `ApiJsMobile.Dto/ApiPrestadores/Request/ProfesionalFindByFiltersRequest.cs`

```csharp
namespace ApiJsMobile.Dto.ApiPrestadores.Request;

using System.ComponentModel.DataAnnotations;
using ApiJsMobile.Dto.ApiPrestadores.Enums;

public record ProfesionalFindByFiltersRequest
{
    public int? IdEspecialidadMedica { get; init; }

    [MaxLength(200)]
    public string? ApellidoNombre { get; init; }

    [MaxLength(11)]
    public string? Cuit { get; init; }

    [Required(ErrorMessage = "IdPais es obligatorio")]
    [Range(1, int.MaxValue)]
    public int IdPais { get; init; }

    public int? IdProvincia { get; init; }

    public int? IdLocalidad { get; init; }

    public List<int>? IdLocalidadesCercanas { get; init; }

    public List<int>? IdBarriosSeleccionados { get; init; }

    public int? IdPlan { get; init; }

    public DateTime? FechaConsultaPlan { get; init; }

    public ProfesionalFlags Flags { get; init; } = ProfesionalFlags.None;

    // Paginación
    public bool WithPagination { get; init; } = true;

    [Range(1, int.MaxValue)]
    public int? Page { get; init; }

    [Range(1, 1000)]
    public int? PageSize { get; init; }

    public string[]? OrderBy { get; init; }
}
```

**Archivo:** `ApiJsMobile.Dto/ApiPrestadores/Response/Common/PaginatedResponse.cs`

```csharp
namespace ApiJsMobile.Dto.ApiPrestadores.Response.Common;

public record PaginatedResponse<T> where T : class
{
    public List<T> Data { get; init; } = new();
    public int TotalRecords { get; init; }
    public int TotalPages { get; init; }
    public int CurrentPage { get; init; }
    public int PageSize { get; init; }
}
```

**Archivo:** `ApiJsMobile.Dto/ApiPrestadores/Response/ProfesionalFindByFiltersResponse.cs`

```csharp
namespace ApiJsMobile.Dto.ApiPrestadores.Response;

using ApiJsMobile.Dto.ApiPrestadores.Response.Common;
using ApiJsMobile.Dto.ApiPrestadores.Response.Nested;

public record ProfesionalFindByFiltersResponse : PaginatedResponse<ProfesionalData>;

public record ProfesionalData
{
    public int Id { get; init; }
    public string ApellidoNombre { get; init; } = string.Empty;
    public string Cuit { get; init; } = string.Empty;
    public string CodigoSisa { get; init; } = string.Empty;
    public int? IdMotivoBaja { get; init; }
    public string Observaciones { get; init; } = string.Empty;
    public DateTime? FechaBaja { get; init; }
    public bool? NoFacturar { get; init; }
    public bool? AccesoPorDerivacion { get; init; }
    public List<DomicilioProfesional> Domicilios { get; init; } = new();
    public List<EspecialidadMedica> EspecialidadesMedicas { get; init; } = new();
}
```

**Archivo:** `ApiJsMobile.Dto/ApiPrestadores/Enums/ProfesionalFlags.cs`

```csharp
namespace ApiJsMobile.Dto.ApiPrestadores.Enums;

[Flags]
public enum ProfesionalFlags
{
    None = 0,
    Domicilios = 1,
    Matriculas = 2,
    Especialidades = 4,
    Convenios = 8,
    All = Domicilios | Matriculas | Especialidades | Convenios
}
```

### 5.4 Testing

#### 5.4.1 Tests Unitarios

**Archivo:** `ApiJsMobile.Infrastructure.Test/HttpClients/ApiPrestadores/ApiPrestadoresClientTests.cs`

```csharp
namespace ApiJsMobile.Infrastructure.Test.HttpClients.ApiPrestadores;

using System.Net;
using System.Net.Http.Json;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Moq;
using Moq.Protected;
using Xunit;
using ApiJsMobile.Infrastructure.HttpClients.ApiPrestadores;
using ApiJsMobile.Dto.ApiPrestadores.Request;
using ApiJsMobile.Dto.ApiPrestadores.Response;

public class ApiPrestadoresClientTests
{
    private readonly Mock<ILogger<ApiPrestadoresClient>> _loggerMock;
    private readonly Mock<IOptions<ApiPrestadoresClientOptions>> _optionsMock;
    private readonly ApiPrestadoresClientOptions _options;

    public ApiPrestadoresClientTests()
    {
        _loggerMock = new Mock<ILogger<ApiPrestadoresClient>>();
        _options = new ApiPrestadoresClientOptions
        {
            BaseUrl = "https://api-test.com/api/",
            TimeoutSeconds = 30
        };
        _optionsMock = new Mock<IOptions<ApiPrestadoresClientOptions>>();
        _optionsMock.Setup(x => x.Value).Returns(_options);
    }

    [Fact]
    public async Task FindByFiltersAsync_ValidRequest_ReturnsResponse()
    {
        // Arrange
        var expectedResponse = new ProfesionalFindByFiltersResponse
        {
            Data = new List<ProfesionalData>
            {
                new ProfesionalData { Id = 1, ApellidoNombre = "Dr. Test" }
            },
            TotalRecords = 1,
            CurrentPage = 1
        };

        var handlerMock = new Mock<HttpMessageHandler>();
        handlerMock
            .Protected()
            .Setup<Task<HttpResponseMessage>>(
                "SendAsync",
                ItExpr.IsAny<HttpRequestMessage>(),
                ItExpr.IsAny<CancellationToken>())
            .ReturnsAsync(new HttpResponseMessage
            {
                StatusCode = HttpStatusCode.OK,
                Content = JsonContent.Create(expectedResponse)
            });

        var httpClient = new HttpClient(handlerMock.Object)
        {
            BaseAddress = new Uri(_options.BaseUrl)
        };

        var client = new ApiPrestadoresClient(httpClient, _loggerMock.Object, _optionsMock.Object);

        var request = new ProfesionalFindByFiltersRequest
        {
            IdPais = 1,
            ApellidoNombre = "Test"
        };

        // Act
        var result = await client.FindByFiltersAsync(request);

        // Assert
        Assert.NotNull(result);
        Assert.Single(result.Data);
        Assert.Equal("Dr. Test", result.Data[0].ApellidoNombre);
    }

    [Fact]
    public async Task FindByFiltersAsync_NullRequest_ThrowsArgumentNullException()
    {
        // Arrange
        var httpClient = new HttpClient { BaseAddress = new Uri(_options.BaseUrl) };
        var client = new ApiPrestadoresClient(httpClient, _loggerMock.Object, _optionsMock.Object);

        // Act & Assert
        await Assert.ThrowsAsync<ArgumentNullException>(() =>
            client.FindByFiltersAsync(null!));
    }

    [Fact]
    public async Task FindByFiltersAsync_HttpError_ThrowsHttpRequestException()
    {
        // Arrange
        var handlerMock = new Mock<HttpMessageHandler>();
        handlerMock
            .Protected()
            .Setup<Task<HttpResponseMessage>>(
                "SendAsync",
                ItExpr.IsAny<HttpRequestMessage>(),
                ItExpr.IsAny<CancellationToken>())
            .ReturnsAsync(new HttpResponseMessage
            {
                StatusCode = HttpStatusCode.InternalServerError
            });

        var httpClient = new HttpClient(handlerMock.Object)
        {
            BaseAddress = new Uri(_options.BaseUrl)
        };

        var client = new ApiPrestadoresClient(httpClient, _loggerMock.Object, _optionsMock.Object);

        var request = new ProfesionalFindByFiltersRequest { IdPais = 1 };

        // Act & Assert
        await Assert.ThrowsAsync<HttpRequestException>(() =>
            client.FindByFiltersAsync(request));
    }
}
```

#### 5.4.2 Tests de Integración

**Archivo:** `ApiJsMobile.Integration.Test/ApiPrestadores/ApiPrestadoresClientIntegrationTests.cs`

```csharp
namespace ApiJsMobile.Integration.Test.ApiPrestadores;

using System.Net.Http.Json;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Xunit;
using ApiJsMobile.Application.Interfaces;
using ApiJsMobile.Dto.ApiPrestadores.Request;
using ApiJsMobile.Infrastructure.HttpClients.ApiPrestadores.Extensions;

[Collection("Integration")]
public class ApiPrestadoresClientIntegrationTests : IClassFixture<IntegrationTestFixture>
{
    private readonly IApiPrestadoresClient _client;

    public ApiPrestadoresClientIntegrationTests(IntegrationTestFixture fixture)
    {
        var services = new ServiceCollection();

        var configuration = new ConfigurationBuilder()
            .AddJsonFile("appsettings.Testing.json")
            .Build();

        services.AddApiPrestadoresClient(configuration);
        services.AddLogging();

        var provider = services.BuildServiceProvider();
        _client = provider.GetRequiredService<IApiPrestadoresClient>();
    }

    [Fact]
    public async Task FindByFiltersAsync_RealAPI_ReturnsValidResponse()
    {
        // Arrange
        var request = new ProfesionalFindByFiltersRequest
        {
            IdPais = 1,
            Page = 1,
            PageSize = 10
        };

        // Act
        var response = await _client.FindByFiltersAsync(request);

        // Assert
        Assert.NotNull(response);
        Assert.NotNull(response.Data);
        // Los datos pueden estar vacíos, pero la respuesta debe ser válida
    }
}
```

### 5.5 Plan de Implementación por Fases

#### Fase 1: Setup Inicial (2-3 horas)

**Tareas:**
1. Crear estructura de carpetas
2. Configurar packages NuGet necesarios:
   - `Microsoft.Extensions.Http.Polly`
   - `System.Net.Http.Json`
3. Crear archivos de configuración base
4. Agregar sección ApiPrestadores a appsettings

**Entregables:**
- Estructura de proyecto creada
- NuGet packages instalados

#### Fase 2: DTOs y Enums (4-5 horas)

**Tareas:**
1. Migrar todos los DTOs a records
2. Implementar validaciones con Data Annotations
3. Crear DTOs genéricos (PaginatedResponse, etc.)
4. Documentar cada DTO con XML comments

**Entregables:**
- 30+ DTOs migrados
- Enums creados
- Validaciones implementadas

#### Fase 3: Cliente HTTP Base (6-8 horas)

**Tareas:**
1. Implementar `ApiPrestadoresClient`
2. Implementar métodos principales (4 métodos core)
3. Agregar logging estructurado
4. Implementar helper methods (BuildQueryString)

**Entregables:**
- Cliente funcional con 4 endpoints
- Logging implementado

#### Fase 4: Configuración y DI (3-4 horas)

**Tareas:**
1. Implementar `ApiPrestadoresClientOptions`
2. Crear extension methods para DI
3. Configurar HttpClient con IHttpClientFactory
4. Agregar configuración por ambiente

**Entregables:**
- Configuración completa
- DI integrado

#### Fase 5: Resiliencia (Polly) (4-5 horas)

**Tareas:**
1. Implementar retry policies
2. Implementar circuit breaker
3. Configurar timeouts
4. Agregar logging de políticas

**Entregables:**
- Retry policies funcionales
- Circuit breaker configurado

#### Fase 6: Handlers (2-3 horas)

**Tareas:**
1. Implementar `ApiPrestadoresLoggingHandler`
2. Implementar `ApiPrestadoresAuthHandler` (si necesario)
3. Integrar handlers en pipeline

**Entregables:**
- Handlers implementados
- Telemetría mejorada

#### Fase 7: Testing Unitario (6-8 horas)

**Tareas:**
1. Escribir tests unitarios (>80% coverage)
2. Mock HttpMessageHandler
3. Validar manejo de errores
4. Validar validaciones de DTOs

**Entregables:**
- Suite de tests unitarios
- Coverage >80%

#### Fase 8: Testing de Integración (4-5 horas)

**Tareas:**
1. Setup de tests de integración
2. Tests contra API real (ambiente Testing)
3. Validar todos los endpoints
4. Smoke tests

**Entregables:**
- Tests de integración funcionales
- Validación E2E

#### Fase 9: Documentación (3-4 horas)

**Tareas:**
1. Documentar configuración
2. Crear guía de uso
3. Ejemplos de código
4. README del componente

**Entregables:**
- `Configuration.md`
- `Usage.md`
- Code samples

#### Fase 10: Code Review y Ajustes (2-3 horas)

**Tareas:**
1. Code review
2. Ajustes según feedback
3. Validación final

**Entregables:**
- Código aprobado
- Listo para merge

**Tiempo Total Estimado:** 36-46 horas (~1 semana de trabajo)

---

## 6. Recomendaciones

### 6.1 Mejoras sobre el Legacy

#### 6.1.1 Manejo de Errores

**Legacy:**
```csharp
catch (Exception)
{
    return new ProfesionalFindNearbyPaginatedResponseDto();
}
```

**Nuevo:**
```csharp
catch (HttpRequestException ex)
{
    _logger.LogError(ex, "Error HTTP al buscar profesionales. StatusCode: {StatusCode}", ex.StatusCode);
    throw; // Propagar excepción para que el caller decida
}
catch (Exception ex)
{
    _logger.LogError(ex, "Error inesperado");
    throw;
}
```

**Beneficios:**
- Logging de errores para diagnóstico
- El caller puede manejar errores apropiadamente
- No oculta problemas

#### 6.1.2 CancellationToken

**Nuevo:**
```csharp
Task<T> FindByFiltersAsync(Request request, CancellationToken cancellationToken = default);
```

**Beneficios:**
- Permite cancelar requests largos
- Mejor manejo de recursos
- Soporte para timeouts granulares

#### 6.1.3 Uso de Records

**Beneficios:**
- Inmutabilidad por defecto
- Sintaxis concisa
- Comparación por valor
- `with` expressions para clonado

#### 6.1.4 Validación con Data Annotations

**Nuevo:**
```csharp
[Required(ErrorMessage = "IdPais es obligatorio")]
[Range(1, int.MaxValue)]
public int IdPais { get; init; }
```

**Beneficios:**
- Validación automática en API
- Mensajes de error claros
- Documentación inline

### 6.2 Consideraciones de Seguridad

#### 6.2.1 Secretos

**No hacer:**
```json
{
  "ApiPrestadores": {
    "Authorization": "Bearer abc123xyz" // ❌ No hardcodear tokens
  }
}
```

**Hacer:**
```csharp
// User Secrets en Development
dotnet user-secrets set "ApiPrestadores:Authorization" "Bearer {token}"

// Azure Key Vault en Production
builder.Configuration.AddAzureKeyVault(...);
```

#### 6.2.2 HTTPS

- Siempre usar HTTPS en producción
- Validar certificados SSL
- No deshabilitar validación de certificados

#### 6.2.3 Sensitive Data Logging

```csharp
// No loggear datos sensibles
_logger.LogInformation("Buscando por CUIT: {Cuit}", request.Cuit); // ❌

// Loggear solo metadatos
_logger.LogInformation("Buscando profesionales por filtros"); // ✅
```

### 6.3 Performance Optimizations

#### 6.3.1 Connection Pooling

`IHttpClientFactory` automáticamente maneja connection pooling. No crear HttpClient manualmente.

#### 6.3.2 JSON Serialization

Usar `System.Text.Json` en lugar de `Newtonsoft.Json` para mejor performance:

```csharp
await response.Content.ReadFromJsonAsync<T>(cancellationToken);
```

#### 6.3.3 Compresión

Habilitar compresión en HttpClient:

```csharp
services.AddHttpClient<IApiPrestadoresClient, ApiPrestadoresClient>()
    .ConfigurePrimaryHttpMessageHandler(() => new SocketsHttpHandler
    {
        AutomaticDecompression = DecompressionMethods.GZip | DecompressionMethods.Deflate
    });
```

### 6.4 Telemetría y Observabilidad

#### 6.4.1 Métricas Recomendadas

- Latencia de requests (P50, P95, P99)
- Tasa de errores
- Tasa de reintentos
- Estado del circuit breaker
- Tamaño de respuestas

#### 6.4.2 Logging Estructurado

Usar logging estructurado para facilitar búsquedas:

```csharp
_logger.LogInformation(
    "API Request completed: {Method} {Endpoint} {StatusCode} {ElapsedMs}ms",
    "POST",
    "v2/profesional/findbyfilters",
    200,
    elapsed);
```

#### 6.4.3 Correlación de Requests

Agregar `CorrelationId` handler:

```csharp
public class CorrelationIdHandler : DelegatingHandler
{
    protected override async Task<HttpResponseMessage> SendAsync(
        HttpRequestMessage request,
        CancellationToken cancellationToken)
    {
        var correlationId = Activity.Current?.Id ?? Guid.NewGuid().ToString();
        request.Headers.Add("X-Correlation-Id", correlationId);

        return await base.SendAsync(request, cancellationToken);
    }
}
```

### 6.5 Testing Best Practices

#### 6.5.1 Arrange-Act-Assert

Seguir patrón AAA en todos los tests.

#### 6.5.2 Test Naming

```csharp
[Fact]
public async Task MethodName_Scenario_ExpectedBehavior()
{
    // ...
}
```

#### 6.5.3 Mock vs Real

- Unit tests: Mock HttpClient
- Integration tests: API real (ambiente Testing)

### 6.6 Próximos Pasos Post-Implementación

1. **Monitoreo:**
   - Configurar Application Insights
   - Crear dashboards de métricas
   - Configurar alertas

2. **Documentación Swagger:**
   - Si se expone mediante controller, agregar Swagger annotations

3. **Versionado:**
   - Preparar para cambios futuros de API
   - Estrategia de deprecación

4. **Favoritos:**
   - Evaluar si se implementan métodos de favoritos
   - Verificar disponibilidad en API Prestadores

---

## Apéndices

### A. Diagrama de Componentes

```
┌─────────────────────────────────────────────────────────────┐
│                      APIMovil_net8                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌────────────────────┐                                    │
│  │  CartillaController │                                    │
│  └──────────┬──────────┘                                    │
│             │                                                │
│  ┌──────────▼──────────┐                                   │
│  │  IApiPrestadoresClient │  (Application Interface)       │
│  └──────────┬──────────┘                                    │
│             │                                                │
│  ┌──────────▼──────────────────────┐                       │
│  │  ApiPrestadoresClient            │                       │
│  │  ┌────────────────────────────┐ │                       │
│  │  │ HttpClient (IHttpClientFactory) │                    │
│  │  └────────────────────────────┘ │                       │
│  │  ┌────────────────────────────┐ │                       │
│  │  │ LoggingHandler              │ │                       │
│  │  └────────────────────────────┘ │                       │
│  │  ┌────────────────────────────┐ │                       │
│  │  │ Polly Retry Policy          │ │                       │
│  │  └────────────────────────────┘ │                       │
│  │  ┌────────────────────────────┐ │                       │
│  │  │ Polly Circuit Breaker       │ │                       │
│  │  └────────────────────────────┘ │                       │
│  └──────────┬──────────────────────┘                        │
│             │                                                │
└─────────────┼────────────────────────────────────────────────┘
              │ HTTPS
              │
┌─────────────▼────────────────────────────────────────────────┐
│                    API Prestadores                           │
│  ┌──────────────────────────────────────────────┐           │
│  │  ProfesionalController                       │           │
│  │  - GET  v1/profesional/cercademi              │           │
│  │  - POST v2/profesional/findbyfilters         │           │
│  └──────────────────────────────────────────────┘           │
│  ┌──────────────────────────────────────────────┐           │
│  │  EntidadSaludController                      │           │
│  │  - GET  v1/entidadessalud/cercademi          │           │
│  │  - POST v2/entidadessalud/findbyfilters      │           │
│  └──────────────────────────────────────────────┘           │
└──────────────────────────────────────────────────────────────┘
```

### B. Flujo de Request

```
1. Controller                → IApiPrestadoresClient.FindByFiltersAsync(request)
                                      ↓
2. ApiPrestadoresClient      → Validar request (ArgumentNullException si null)
                                      ↓
3. HttpClient                → POST v2/profesional/findbyfilters
                                      ↓
4. LoggingHandler            → Log: "Request: POST ..."
                                      ↓
5. Retry Policy (Polly)      → Retry si falla (hasta 3 veces)
                                      ↓
6. Circuit Breaker (Polly)   → Abrir si fallas consecutivas > threshold
                                      ↓
7. API Prestadores           → Procesar request
                                      ↓
8. Response                  ← JSON response
                                      ↓
9. Deserialización           ← ReadFromJsonAsync<ProfesionalFindByFiltersResponse>
                                      ↓
10. LoggingHandler           → Log: "Response: 200 OK in 250ms"
                                      ↓
11. Return                   ← Return response a controller
```

### C. Checklist de Implementación

- [ ] Fase 1: Setup Inicial
- [ ] Fase 2: DTOs y Enums
- [ ] Fase 3: Cliente HTTP Base
- [ ] Fase 4: Configuración y DI
- [ ] Fase 5: Resiliencia (Polly)
- [ ] Fase 6: Handlers
- [ ] Fase 7: Testing Unitario
- [ ] Fase 8: Testing de Integración
- [ ] Fase 9: Documentación
- [ ] Fase 10: Code Review y Ajustes

### D. Glosario

| Término | Descripción |
|---------|-------------|
| **Circuit Breaker** | Patrón que previene llamadas a un servicio que está fallando repetidamente |
| **IHttpClientFactory** | Factory pattern de .NET para crear instancias de HttpClient con mejor manejo de recursos |
| **Polly** | Librería de resiliencia para .NET (retry, circuit breaker, timeout, etc.) |
| **Record** | Tipo de referencia inmutable introducido en C# 9 |
| **Named Client** | HttpClient configurado con un nombre específico para reutilización |
| **Retry Policy** | Política de reintentos automáticos ante fallas transitorias |
| **ConfigureAwait(false)** | Evita capturar el contexto de sincronización, mejora performance |

---

**Fin del Documento**

**Próximos Pasos:**
1. Revisar y aprobar diseño con equipo
2. Crear branch de desarrollo
3. Iniciar implementación por fases
4. Tracking de progreso en proyecto management tool
