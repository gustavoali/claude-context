# API Prestadores - Project Context
**Version:** Current | **Framework:** .NET 8.0 | **DB:** SQL Server (Dapper)
**Ubicacion:** C:/jerarquicos/APIPrestadores/src

## Stack
- ASP.NET Core 8.0 Web API
- Dapper + Dapper.Contrib (ORM)
- SQL Server (JS2000_V1, Windows Auth)
- FluentValidation 11.9.2
- AutoMapper 13.0.1
- CSharpFunctionalExtensions 3.6.0 (Result pattern)
- Serilog + Graylog sink
- Swagger/OpenAPI (Asp.Versioning + Swashbuckle)
- NUnit 4.2.2 + Moq 4.20.72 + Coverlet

## Arquitectura
Clean Architecture (4 capas):
- **Api** → Controllers, Validators, Filters, Program.cs
- **Application** → Services, Mappers (AutoMapper), Helpers
- **Domain** → Entities, DomainServices, Filters, Result classes, Repo interfaces
- **Infraestructure** → Repos (Dapper), UnitOfWork, TransactionalProxy, DI config
- **Dto** → Request/Response DTOs con SwaggerSchema
- **Common** → Excepciones.resx (mensajes localizados)
- **JS.Framework.API** → Middleware excepciones, Swagger config, headers
- **JS.Framework.Resources** → Custom exceptions (Database, NotFound, Validator)

## Dominios
| Dominio | Controller | Service | Operaciones |
|---------|------------|---------|-------------|
| Profesionales | ProfesionalController | ProfesionalService | CRUD, busqueda filtros/convenio/cercania, favoritos |
| Entidades Salud | EntidadSaludController | EntidadSaludService | Busqueda, favoritos, validacion PMO |
| Especialidades | EspecialidadMedicaController | EspecialidadMedicaService | Consulta por localidad/id |

## Patrones Clave
- **Flags bitmask** para expansion condicional (Domicilios=1, Matriculas=2, Especialidades=4, Convenios=8)
- **TransactionalProxy** dinamico sobre domain services
- **API versioning** v1 (GET) / v2 (POST filtros complejos)
- **Result pattern** (CSharpFunctionalExtensions)
- **Pagination** OFFSET/FETCH con helper

## Comandos
```bash
dotnet build --no-incremental                    # Build completo
dotnet test --configuration Release              # Tests
dotnet run --project ApiPrestadores.Api           # Ejecutar
```

## Endpoints (base: /api/v{version})
- `GET/POST /profesional/findbyfilters` - Busqueda con filtros
- `GET /profesional/findbyidconvenio` - Por convenio
- `GET /profesional/findnearby` - Geolocalizacion
- `POST /profesional` - Alta profesional (nuevo)
- `GET/POST /entidadessalud/findbyfilters` - Busqueda entidades
- `GET /especialidad/findall` - Todas las especialidades
- Favoritos: add/remove/find para ambos dominios

## Agentes Recomendados
| Tarea | Agente |
|-------|--------|
| Implementar endpoints/services | `dotnet-backend-developer` |
| Tests unitarios/integracion | `test-engineer` |
| Code review pre-PR | `code-reviewer` |
| Optimizar queries SQL | `database-expert` |
| Arquitectura | `software-architect` |

## Reglas del Proyecto
- Entidades usan Dapper.Contrib attributes (`[Table]`, `[Column]`, `[Write(false)]`)
- Soft deletes con columnas `*_baj`
- Headers custom: X-Request-Id, X-User-Name, X-Correlation-Id, X-Client-Name
- Validators en capa Api (no DataAnnotations)
- Connection string por ambiente via appsettings transform

## Docs
@C:/claude_context/jerarquicos/APIPrestadores/LEARNINGS.md
@C:/claude_context/jerarquicos/APIPrestadores/TASK_STATE.md
