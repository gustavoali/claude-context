# FuturosSociosApi - Project Context
**Version:** N/A (legacy) | **Framework:** .NET Core 2.2 | **Tests:** ~3 archivos basicos
**Ubicacion:** C:/jerarquicos/FuturosSociosApi
**Branch principal:** develop | **Branch actual:** staging

## Stack
- ASP.NET Core 2.2 (API principal - FuturosSociosApiMovil)
- .NET Framework 4.7 (ReportingApi, ViewModels, Comun)
- .NET Standard 2.0 (BackendServices)
- Entity Framework Core 2.2 (con lazy loading proxies)
- SQL Server (DB: FuturosSocios)
- JWT Bearer + ASP.NET Identity + Keycloak
- Serilog -> Graylog
- AutoMapper 8.0
- Crystal Reports 13 (ReportingApi)
- Magick.NET (procesamiento imagenes)

## Proyectos en la Solucion
| Proyecto | Framework | Rol |
|----------|-----------|-----|
| FuturosSociosApiMovil | .NET Core 2.2 | API principal (16 controllers, 26 DAOs) |
| BackendServices | .NET Standard 2.0 | Clientes HTTP para APIs externas |
| ReportingApi | .NET Framework 4.7 | Crystal Reports (MVC5 legacy) |
| FuturosSociosViewModels | .NET Framework 4.7 | ViewModels compartidos (~120) |
| Comun | .NET Framework 4.7 | Enums y utilidades |
| ClienteRenaper | .NET Core 2.1 | Integracion RENAPER |
| FuturosSociosApiMovilTest | .NET Core 3.1 | Tests (NUnit + Moq) |

## Arquitectura
N-Tier con patron DAO: Controllers -> DAOs -> DbContext (EF Core).
Sin capa de servicios intermedia. Sin FluentValidation. Sin Polly.
Diverge del estandar jerarquicos moderno (Clean Architecture + DDD).

## Comandos
```bash
dotnet build --no-incremental          # Build completo
dotnet test                             # Tests
dotnet run --project FuturosSociosApiMovil  # Ejecutar API
```

## APIs Externas Integradas
| API | Cliente | Uso |
|-----|---------|-----|
| ApiConfiguracionPlanesSalud | IApiConfiguracionPlanesSaludClient | Config de planes |
| ApiCalculadoraPlanesSocios | IApiCalculadoraPlanesSociosClient | Cotizaciones |
| ApiPlanesSocios | IApiPlanesSociosClient | Planes de socios |
| AuthProvider (Keycloak) | IAuthProviderClient | OAuth |
| CalculadoraPlanesSociosFrontend | ICalculadoraPlanesSociosFrontendClient | One-time tokens |
| RENAPER | ClienteRenaper | Validacion identidad |
| ReportingApi | HTTP directo | Crystal Reports |

## Features Activas

Cada feature/branch tiene su propio contexto en `features/[id]-[nombre]/`.
Al iniciar sesion en una feature, cargar su TASK_STATE.md para retomar.

| Feature | Branch | Estado | Contexto |
|---------|--------|--------|----------|
| 185688 ApiLocalizacion | `feature/185688_reemplazo_llamada_dao_x_ApiLocalization` | En progreso | `features/185688-apilocalizacion/` |

## Reglas del Proyecto
1. Aplican todas las reglas de jerarquicos (CODE_REVIEW_RULES, CODING_GUIDELINES, SHARED_RULES)
2. Contexto por branch segun @C:/claude_context/jerarquicos/BRANCH_CONTEXT_POLICY.md
3. Proyecto legacy - cambios deben seguir patrones existentes (DAO, ViewModels)
4. Nuevas integraciones de BackendServices siguen patron de APIJsMobile (IHttpClientFactory + config)
5. Build debe ser 0 errores, 0 warnings

## Agentes Recomendados
| Tarea | Agente |
|-------|--------|
| Implementar codigo | dotnet-backend-developer (con contexto .NET Core 2.2 legacy) |
| Tests | test-engineer |
| Code review | code-reviewer |
| DB changes | database-expert |

## Docs
@C:/claude_context/jerarquicos/FuturosSociosApi/TASK_STATE.md
@C:/claude_context/jerarquicos/FuturosSociosApi/PRODUCT_BACKLOG.md

## Convenciones Grupales Jerarquicos
@C:/claude_context/jerarquicos/DEVELOPMENT_BEST_PRACTICES.md
@C:/claude_context/jerarquicos/API_STANDARDS.md
@C:/claude_context/jerarquicos/COMMIT_CONVENTION.md
@C:/claude_context/jerarquicos/API_ERROR_CODES.md
@C:/claude_context/jerarquicos/CODING_GUIDELINES.md
@C:/claude_context/jerarquicos/SHARED_RULES.md
