### FS-001: Integrar ApiLocalizacion en ObtenerOpcionesGenerales
**Points:** 3 | **Priority:** High

**As a** consumer of the FuturosSociosApiMovil API
**I want** the ObtenerOpcionesGenerales endpoint to obtain Localidades and Provincias from ApiLocalizacion instead of the local database
**So that** geographic data comes from the centralized localization service, maintaining consistency across all Jerarquicos APIs

#### Acceptance Criteria
**AC1:** Given the endpoint GET /api/Aplicacion/OpcionesGenerales is called, When the API processes the request, Then Localidades are fetched from ApiLocalizacion GET /api/v1/Localidad/ with IdPais filter for Argentina instead of LocalidadDAO.ObtenerLocalidades()

**AC2:** Given the endpoint GET /api/Aplicacion/OpcionesGenerales is called, When the API processes the request, Then Provincias are fetched from ApiLocalizacion GET /api/v1/Provincia/ with IdPais filter for Argentina instead of ProvinciaDAO.ObtenerProvincias()

**AC3:** Given ApiLocalizacion is unavailable or returns an error, When the endpoint is called, Then the response returns Exito=false with appropriate error notification (same pattern as existing DAO error handling)

**AC4:** Given the integration is complete, When reviewing the code, Then the ApiLocalizacion client follows the exact same pattern as existing BackendServices clients (static Config class, IHttpClientFactory, ApiResponse<T> wrapper, IOptions<FuturosSociosApiMovilSettings>)

**AC5:** Given the integration is complete, When reviewing appsettings, Then all environment files (Debug, Develop, Staging, Production, Test) have the ApiLocalizacion URL configured

#### Technical Notes
- New files in BackendServices/ApiLocalizacion/: Config, Interface, Service, Models
- Add RutaApiLocalizacion (Uri) to FuturosSociosApiMovilSettings
- Register named HttpClient and DI in Startup.cs
- Modify AplicacionController.ObtenerOpcionesGenerales() to inject and use IApiLocalizacionClient
- ApiLocalizacion endpoints: GET /api/v1/Localidad/?IdPais={id}&PageSize=10000 and GET /api/v1/Provincia/?IdPais={id}&PageSize=10000
- Response wrapper from ApiLocalizacion: GenericListResult<T> with Registers and TotalRegisters
- Map ApiLocalizacion DTOs to existing LocalidadPlanoViewModel and ProvinciaViewModel via AutoMapper
- The endpoint is currently synchronous - will need to become async to support HTTP calls
- PageSize must be large enough to get ALL records (localidades can be thousands)

#### DoD
- [ ] ApiLocalizacion client implemented in BackendServices following existing patterns
- [ ] AplicacionController.ObtenerOpcionesGenerales uses ApiLocalizacion for Localidades and Provincias
- [ ] All appsettings files configured with ApiLocalizacion URL per environment
- [ ] Build 0 errors, 0 warnings
- [ ] Code review aprobado
