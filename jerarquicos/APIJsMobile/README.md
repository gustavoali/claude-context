# APIMovil .NET 8 - Contexto del Proyecto

**Ubicación:** `C:\jerarquicos\APIMovil_net8\`
**Framework:** .NET 8.0
**Arquitectura:** Clean Architecture
**Estado:** En desarrollo activo

---

## 📁 Estructura de Documentación

Este directorio contiene toda la documentación y contexto del proyecto APIMovil migrado a .NET 8.

### Archivos Disponibles:

- **PROJECT_ANALYSIS.md** - Análisis exhaustivo del proyecto completo
- **ARQUITECTURA_APIPRESTADORES_CLIENT.md** - Diseño del cliente HTTP para API Prestadores
- **CARTILLA_IMPLEMENTATION.md** - Implementación completa de CartillaController (4 endpoints + 20 tests)
- **README.md** - Este archivo (overview del contexto)

---

## 🎯 Propósito del Proyecto

APIMovil_net8 es la **migración moderna** del API móvil legacy de .NET Framework 4.x a .NET 8.0, implementando:

- Clean Architecture
- Mejores prácticas modernas de .NET
- Testing comprehensivo
- API versioning
- Logging estructurado
- Validación robusta

---

## 🏗️ Arquitectura Quick Reference

```
ApiJsMobile.Api          → Controllers, Middlewares, Filters
ApiJsMobile.Application  → Application Services, Use Cases
ApiJsMobile.Domain       → Domain Services, Business Logic, Entities
ApiJsMobile.Infraestructure → Repositories, Data Access (Dapper)
ApiJsMobile.Dto          → Data Transfer Objects
JS.Framework.API         → Framework compartido
JS.Framework.Resources   → Recursos compartidos
```

---

## 🚀 Comandos Rápidos

### Build y Ejecución
```bash
cd C:\jerarquicos\APIMovil_net8\src
dotnet restore
dotnet build
dotnet run --project ApiJsMobile.Api
```

### Testing
```bash
dotnet test
```

### Acceso
- **API:** http://localhost:5209
- **Swagger:** http://localhost:5209/docs

---

## 📊 Estado Actual del Proyecto

### ✅ Completado:
- Estructura Clean Architecture
- Patrones: Repository, UoW, DI
- API Versioning (v1.0, v2.0)
- Swagger/OpenAPI documentation
- Logging con Serilog
- FluentValidation
- Testing framework (NUnit + Moq)
- Sample endpoints como template
- **BackendServices project** con ApiPrestadoresClient (6 métodos, 32 DTOs)
- **CartillaController** (4 endpoints funcionales)
- **CartillaService** con lógica de negocio completa
- **20 tests unitarios** (100% passing) para CartillaService

### 🔄 En Progreso:
- Migración de endpoints del proyecto legacy (21 totales, 4 completados)
- Implementación de servicios faltantes (ApiLocalizacion, Servicio de Socios)
- Migración de WCF services a .NET 8 (ServiciosJs.Generico, ServiciosJs.MiCartilla)

### 📋 Pendiente:
- **CartillaController:** 17 endpoints restantes (ver CARTILLA_IMPLEMENTATION.md)
- Tests de integración para CartillaController
- Autenticación/Autorización en endpoints
- CI/CD pipeline
- Docker containerization
- Seguridad completa (JWT, CORS)
- Monitoring y observabilidad
- Caching con Redis
- Database migrations formales

---

## 🔗 Referencias Cruzadas

### Proyecto Legacy:
- **Ubicación:** `C:\jerarquicos\Repositorio-ApiMovil\`
- **Framework:** .NET Framework 4.x
- **Arquitectura:** N-Tier tradicional

### Proyecto Nuevo (.NET 8):
- **Ubicación:** `C:\jerarquicos\APIMovil_net8\`
- **Framework:** .NET 8.0
- **Arquitectura:** Clean Architecture

---

## 📝 Notas de Desarrollo

### Patrones a Seguir:
1. Siempre usar Clean Architecture
2. Aplicar SOLID principles
3. DTOs para todas las comunicaciones
4. FluentValidation para reglas de negocio
5. Testing obligatorio (AAA pattern)
6. Logging estructurado con contexto

### Convenciones:
- Controllers: Minimal API style preferido
- Services: Inyección por constructor
- Repositories: Interface + Implementation
- DTOs: Separados por feature
- Tests: Un archivo por clase a testear

---

## 🎓 Para Nuevos Desarrolladores

1. **Leer primero:** `PROJECT_ANALYSIS.md` para entender la estructura completa
2. **Explorar:** Proyecto `Sample` como referencia de implementación
3. **Revisar:** Patrones en `JS.Framework.API` (base framework)
4. **Consultar:** appsettings.json para configuraciones disponibles

---

## 📞 Contacto y Soporte

Para preguntas sobre el proyecto o la arquitectura, consultar con el Technical Lead o revisar la documentación en:
- `C:\jerarquicos\APIMovil_net8\docs\` (si existe)
- Este directorio de contexto

---

**Última actualización:** 2025-11-14
**Versión documentación:** 1.1
**Mantenido por:** Claude Code Assistant

---

## 📚 Implementaciones Recientes

### 2025-11-14: CartillaController + Tests
- ✅ Implementados 4 endpoints de búsqueda de prestadores
- ✅ 20 tests unitarios (100% passing)
- ✅ Integración con BackendServices.ApiPrestadores
- ✅ Lógica de agrupación y ordenamiento de resultados
- 📝 Ver detalles en: `CARTILLA_IMPLEMENTATION.md`

### 2025-11-13: BackendServices.ApiPrestadores
- ✅ Cliente HTTP con Polly (retry + circuit breaker)
- ✅ 6 métodos de API (EntidadSalud x3, Profesional x3)
- ✅ 32 DTOs con records inmutables
- ✅ Logging con DelegatingHandler
- 📝 Ver detalles en: `ARQUITECTURA_APIPRESTADORES_CLIENT.md`
