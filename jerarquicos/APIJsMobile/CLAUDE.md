# ApiJsMobile - Configuracion de Proyecto

**Tipo:** API REST .NET 8
**Organizacion:** Jerarquicos Salud
**Estado:** En desarrollo activo

---

## Descripcion del Proyecto

API Mobile para Jerarquicos Salud que reemplaza la API legacy (Repositorio-ApiMovil). Implementa endpoints para:
- Cartilla medica (profesionales, instituciones, emergencias)
- Autenticacion JWT
- Integracion con APIs backend (ApiPrestadores, ApiLocalizacion, ApiCoberturaSocios)

## Estructura del Proyecto

```
ApiJsMobile/src/
├── ApiJsMobile.Api/           # Web API, Controllers, Validators
├── ApiJsMobile.Application/   # Services, Interfaces, Settings
├── ApiJsMobile.Dto/           # DTOs de request/response
├── BackendServices/           # Clients para APIs externas
│   ├── ApiPrestadores/
│   ├── ApiLocalizacion/
│   ├── ApiCoberturaSocios/
│   └── Common/                # ApiClientException, helpers
├── JS.Framework.API/          # Middleware, Headers, Swagger
├── JS.Framework.Resources/    # Excepciones base (BusinessException, etc.)
└── Tests/                     # Unit tests
```

## URLs de Ambientes

| Ambiente | URL Base |
|----------|----------|
| Development | srvappdevelop.jerarquicossalud.com.ar:8290 |
| Test | srvtest.jerarquicossalud.com.ar:8290 |
| Staging | srvappstaging.jerarquicossalud.com.ar:8290 |
| Production | balanceadorbackendprod01.jerarquicossalud.com.ar:8290 |

## Convenciones de Codigo

### Async/Await
- Usar `ConfigureAwait(false)` en todas las llamadas async en BackendServices
- No usar en Controllers (necesitan HttpContext)

### Logging
- NO agregar `_logger.LogError` en catch blocks - el middleware lo hace
- Usar `LogInformation` para trazabilidad de operaciones
- Ver `LOGGING_GUIDELINES.md` para reglas completas

### Manejo de Errores
- Usar `ApiClientException` para errores de APIs externas
- Capturar response body ANTES de lanzar excepcion
- El `HandlerExceptionMiddleware` maneja el logging centralizado

### DTOs
- Request DTOs en `ApiJsMobile.Dto/[Feature]/`
- Response DTOs del backend en `BackendServices/[Api]/Models/`
- Validacion con FluentValidation en `Api/Validators/`

### API Clients - Directiva de Implementacion
**REGLA OBLIGATORIA:** Los DTOs de BackendServices DEBEN coincidir EXACTAMENTE con los DTOs de las APIs originales.

Ver directivas detalladas en:
@C:/claude_context/jerarquicos/APIJsMobile/API_CLIENT_IMPLEMENTATION_GUIDELINES.md

## Documentacion Relacionada

### Guidelines y Pendientes
@C:/claude_context/jerarquicos/APIJsMobile/LOGGING_GUIDELINES.md
@C:/claude_context/jerarquicos/APIJsMobile/PENDING_APIPRESTADORES_ENDPOINTS.md

### Arquitectura e Implementacion
@C:/claude_context/jerarquicos/APIJsMobile/ARQUITECTURA_APIPRESTADORES_CLIENT.md
@C:/claude_context/jerarquicos/APIJsMobile/CARTILLA_IMPLEMENTATION.md

### Analisis del Proyecto
@C:/claude_context/jerarquicos/APIJsMobile/PROJECT_ANALYSIS.md
@C:/claude_context/jerarquicos/APIJsMobile/README.md

## Comandos Frecuentes

```bash
# Build completo
dotnet build --no-incremental

# Ejecutar tests
dotnet test

# Ejecutar API
dotnet run --project ApiJsMobile.Api
```

## Notas Importantes

- El proyecto usa versionado de API (`api/v{version}/`)
- JWT provisorio implementado (sin MiJS por ahora)
- Endpoints legacy deben mantener compatibilidad de rutas
