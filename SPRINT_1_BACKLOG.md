# Sprint 1 Backlog - ERP Multinacional

**Sprint:** 1 de 10
**Duración:** 2 semanas (10 días laborables)
**Fecha Inicio:** [A definir]
**Fecha Fin:** [A definir]
**Equipo:** 4-6 Developers + 1 QA + 1 DevOps

---

## 🎯 Sprint Goal

> **"Establecer la infraestructura base del ERP con multi-tenancy, API REST, y motor multi-moneda funcional, con pipeline CI/CD operativo."**

**Criterios de Éxito:**
- ✅ Multi-tenancy implementado y probado con 2+ tenants
- ✅ API REST base con autenticación JWT funcional
- ✅ Multi-Currency Engine con integración a API externa
- ✅ Pipeline CI/CD ejecutando build, tests, y deployment a Staging
- ✅ Tests con >90% coverage
- ✅ Demo funcional al Product Owner

---

## 📊 Sprint Capacity

**Team Capacity:**
- **4 Backend Developers:** 4 × 6h/día × 10 días = 240 horas
- **1 QA Engineer:** 1 × 6h/día × 10 días = 60 horas
- **1 DevOps Engineer:** 1 × 4h/día × 10 días = 40 horas (part-time)
- **Total Capacity:** 340 horas

**Overhead Estimado (20%):** 68 horas (meetings, code reviews, unplanned work)
**Net Capacity:** 272 horas

---

## 📋 User Stories Seleccionadas

| ID | User Story | Story Points | Estimado (horas) | Status |
|----|-----------|--------------|------------------|---------|
| US-001 | Multi-Tenancy Context | 8 | 64 | 🔵 TODO |
| US-002 | Base de Datos Multi-Tenant | 13 | 104 | 🔵 TODO |
| US-003 | API REST Base con Swagger | 8 | 64 | 🔵 TODO |
| US-007 | API Consulta Tipos de Cambio | 5 | 40 | 🔵 TODO |
| **US-048** | **Contenedorización con Docker** | **13** | **104** | 🔵 TODO |
| **TOTAL** | **5 User Stories** | **47 pts** | **376 horas** | |

**Nota:** US-049 (CI/CD Pipeline) y US-050 (Staging Setup) se movieron a Sprint 2 para mantener el Sprint 1 en capacidad razonable (47 pts vs 73 pts original).

**Leyenda:**
- 🔵 TODO
- 🟡 IN PROGRESS
- 🟢 DONE
- 🔴 BLOCKED

---

## 🔨 US-001: Multi-Tenancy Context (8 SP, 64 horas)

**Objetivo:** Implementar el patrón Multi-Tenancy para aislar datos por empresa/país.

### Tasks Técnicas

#### T1.1: Diseño de Arquitectura Multi-Tenant (8h)
**Responsable:** Tech Lead
**Descripción:** Definir estrategia de multi-tenancy (Database-per-Tenant vs Schema-per-Tenant vs Row-Level)

**Subtareas:**
- [ ] Documentar decisión de arquitectura (Row-Level con TenantId)
- [ ] Diseñar flujo de detección de tenant (header, JWT, subdomain)
- [ ] Crear diagrama de arquitectura (C4 Model)
- [ ] Definir estructura de TenantContext
- [ ] Validar con equipo en Tech Review

**DoD:**
- Documento de diseño en Wiki
- Diagrama aprobado por Tech Lead
- Consenso del equipo

---

#### T1.2: Implementar Entidad Tenant (4h)
**Responsable:** Backend Dev 1
**Descripción:** Crear entidad Tenant en Domain layer

**Subtareas:**
- [ ] Crear `Domain/Entities/Tenant.cs`
  ```csharp
  public class Tenant : BaseEntity
  {
      public string Name { get; set; }
      public string CountryCode { get; set; }
      public CurrencyCode DefaultCurrency { get; set; }
      public string Subdomain { get; set; }
      public bool IsActive { get; set; }
      public DateTime CreatedAt { get; set; }
  }
  ```
- [ ] Crear migración EF Core
- [ ] Seed data inicial (2 tenants: AR y MX)

**DoD:**
- Entidad creada con validaciones
- Migración aplicada en DB local
- Tests unitarios de entidad

---

#### T1.3: Implementar ITenantContext y TenantContextService (6h)
**Responsable:** Backend Dev 1
**Descripción:** Servicio para acceder al tenant actual en toda la aplicación

**Subtareas:**
- [ ] Crear interfaz `Application/Common/Interfaces/ITenantContext.cs`
  ```csharp
  public interface ITenantContext
  {
      int TenantId { get; }
      string CountryCode { get; }
      CurrencyCode DefaultCurrency { get; }
      string TenantName { get; }
  }
  ```
- [ ] Implementar `Infrastructure/Services/TenantContextService.cs`
- [ ] Usar `IHttpContextAccessor` para leer tenant del JWT
- [ ] Implementar caching con `AsyncLocal<T>` para thread-safety

**DoD:**
- Servicio implementado
- Registrado en DI Container
- Unit tests con mocks

---

#### T1.4: Middleware de Detección de Tenant (8h)
**Responsable:** Backend Dev 2
**Descripción:** Middleware que detecta el tenant en cada request

**Subtareas:**
- [ ] Crear `API/Middleware/TenantDetectionMiddleware.cs`
- [ ] Leer tenant de:
  - Header `X-Tenant-Id` (para APIs externas)
  - JWT Claim `TenantId` (para usuarios autenticados)
  - Subdomain (futuro, opcional)
- [ ] Validar que el tenant exista y esté activo
- [ ] Setear `ITenantContext` para el request
- [ ] Manejar errores (tenant no encontrado → 400 Bad Request)

**DoD:**
- Middleware funcional
- Tests de integración con diferentes headers
- Logging implementado

---

#### T1.5: Filtro Global de Queries (Query Filter) (10h)
**Responsable:** Backend Dev 2
**Descripción:** Aplicar filtro automático por TenantId en todas las queries EF Core

**Subtareas:**
- [ ] Configurar Global Query Filters en `ApplicationDbContext`
  ```csharp
  modelBuilder.Entity<Cliente>()
      .HasQueryFilter(e => e.TenantId == _tenantContext.TenantId);
  ```
- [ ] Aplicar filtro a TODAS las entidades (excepto Tenant)
- [ ] Implementar método `IgnoreQueryFilters()` para casos especiales
- [ ] Crear interceptor de SaveChanges para auto-setear TenantId

**DoD:**
- Filtros aplicados a todas las entidades
- Interceptor funcionando
- Tests validando aislamiento de datos

---

#### T1.6: Tests de Multi-Tenancy (12h)
**Responsable:** Backend Dev 3 + QA
**Descripción:** Suite completa de tests para validar aislamiento

**Subtareas:**
- [ ] Unit tests de TenantContextService
- [ ] Unit tests de Middleware
- [ ] Integration tests:
  - Crear 2 tenants (AR, MX)
  - Crear datos para cada tenant
  - Validar que Tenant A no vea datos de Tenant B
  - Validar que queries sin TenantId en header fallen
- [ ] Tests de concurrencia (múltiples tenants simultáneos)

**DoD:**
- >95% coverage en multi-tenancy
- Tests pasando en CI
- Documentación de tests

---

#### T1.7: Documentación y Code Review (4h)
**Responsable:** Tech Lead

**Subtareas:**
- [ ] Documentar uso de multi-tenancy en README
- [ ] Ejemplos de cómo agregar nuevas entidades
- [ ] Code Review de US-001
- [ ] Refactoring según feedback

**DoD:**
- Documentación publicada
- PR aprobado y mergeado

---

#### T1.8: Demo de Multi-Tenancy (2h)
**Responsable:** Scrum Master + Tech Lead

**Subtareas:**
- [ ] Preparar demo con Postman
- [ ] Demostrar aislamiento de datos
- [ ] Presentar al Product Owner

---

### Resumen US-001
**Total Estimado:** 64 horas
**Developers Asignados:** 3 Backend Devs + Tech Lead + QA
**Timeline:** Días 1-4 del Sprint

---

## 🗄️ US-002: Base de Datos Multi-Tenant (13 SP, 104 horas)

**Objetivo:** Diseñar y crear el esquema de base de datos completo con soporte multi-tenant.

### Tasks Técnicas

#### T2.1: Diseño del Modelo de Datos (12h)
**Responsable:** Tech Lead + DBA (si disponible)
**Descripción:** Diseñar ERD completo del sistema

**Subtareas:**
- [ ] Crear ERD con todas las entidades:
  - Core: Tenant, User, Role, Permission
  - Inventory: Producto, Stock, Deposito, Movimiento
  - Purchases: Proveedor, OrdenCompra, Recepcion, FacturaProveedor
  - Sales: Cliente, Pedido, Factura, Cobranza
  - Accounting: Cuenta, Asiento, AsientoDetalle
  - Currency: ExchangeRate, CurrencyConversion
- [ ] Definir relaciones (1:N, N:M)
- [ ] Definir índices para performance
- [ ] Definir constraints y validaciones

**DoD:**
- ERD documentado (draw.io, Lucidchart, o DbDiagram.io)
- Revisado y aprobado por equipo
- Documento de especificación de DB

---

#### T2.2: Crear Entidades de Domain Layer (20h)
**Responsable:** Backend Dev 1 + Backend Dev 2
**Descripción:** Implementar todas las entidades en `Domain/Entities/`

**Subtareas:**
- [ ] Crear `BaseEntity.cs` con Id, CreatedAt, ModifiedAt, IsDeleted
- [ ] Crear entidades Core (Tenant, User, Role)
- [ ] Crear entidades Inventory (Producto, Stock, Deposito)
- [ ] Crear entidades Purchases (Proveedor, OrdenCompra)
- [ ] Crear entidades Sales (Cliente, Pedido, Factura)
- [ ] Crear entidades Accounting (Cuenta, Asiento)
- [ ] Crear entidades Currency (ExchangeRate)
- [ ] Agregar atributos de validación (Required, MaxLength, etc.)
- [ ] Agregar navigation properties

**DoD:**
- ~30-40 entidades creadas
- Validaciones implementadas
- XML comments en propiedades

---

#### T2.3: Configurar EF Core DbContext (12h)
**Responsable:** Backend Dev 2
**Descripción:** Configurar ApplicationDbContext con Fluent API

**Subtareas:**
- [ ] Crear `Infrastructure/Persistence/ApplicationDbContext.cs`
- [ ] Configurar DbSets para todas las entidades
- [ ] Implementar IApplicationDbContext interface
- [ ] Configurar conexión a MySQL
- [ ] Implementar interceptores:
  - AuditableEntityInterceptor (auto-setear CreatedAt/ModifiedAt)
  - TenantInterceptor (auto-setear TenantId)
  - SoftDeleteInterceptor (IsDeleted en lugar de DELETE)

**DoD:**
- DbContext configurado correctamente
- Interceptores funcionando
- Connection string en appsettings.json

---

#### T2.4: Configuración de Entidades con Fluent API (16h)
**Responsable:** Backend Dev 1 + Backend Dev 2
**Descripción:** Configurar relaciones, índices, y constraints con Fluent API

**Subtareas:**
- [ ] Crear `EntityTypeConfiguration` para cada entidad
- [ ] Configurar relaciones (HasOne/HasMany/WithMany)
- [ ] Configurar índices únicos (ej: Email, CUIT por Tenant)
- [ ] Configurar índices compuestos (ej: TenantId + Codigo)
- [ ] Configurar cascadas (DeleteBehavior)
- [ ] Configurar conversiones (ej: Enum → String)
- [ ] Configurar precision de decimales (18,6 para Money)

**Ejemplo:**
```csharp
public class ClienteConfiguration : IEntityTypeConfiguration<Cliente>
{
    public void Configure(EntityTypeBuilder<Cliente> builder)
    {
        builder.ToTable("Clientes");

        builder.HasKey(c => c.Id);

        builder.Property(c => c.RazonSocial)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(c => c.TaxId)
            .IsRequired()
            .HasMaxLength(20);

        builder.HasIndex(c => new { c.TenantId, c.TaxId })
            .IsUnique();

        builder.HasQueryFilter(c => !c.IsDeleted);

        builder.HasOne(c => c.Tenant)
            .WithMany()
            .HasForeignKey(c => c.TenantId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
```

**DoD:**
- Configuraciones creadas para todas las entidades
- Índices optimizados
- Tests de configuración

---

#### T2.5: Crear Migraciones Iniciales (8h)
**Responsable:** Backend Dev 2
**Descripción:** Generar migraciones de EF Core

**Subtareas:**
- [ ] Ejecutar `dotnet ef migrations add InitialCreate`
- [ ] Revisar SQL generado manualmente
- [ ] Ajustar tipos de datos si es necesario
- [ ] Agregar migraciones adicionales para índices específicos
- [ ] Aplicar migraciones en DB local
- [ ] Validar schema generado

**DoD:**
- Migraciones generadas correctamente
- DB local creada y validada
- Scripts SQL revisados

---

#### T2.6: Seed Data (12h)
**Responsable:** Backend Dev 3
**Descripción:** Crear datos iniciales para desarrollo y testing

**Subtareas:**
- [ ] Crear `Infrastructure/Persistence/ApplicationDbContextSeed.cs`
- [ ] Seed de Tenants:
  - Tenant 1: "ERP Argentina" (AR, ARS)
  - Tenant 2: "ERP México" (MX, MXN)
- [ ] Seed de Usuarios y Roles:
  - Admin, Almacenero, Comprador, Vendedor, Tesorero, Contador, Auditor
- [ ] Seed de Plan de Cuentas básico (AR y MX)
- [ ] Seed de Productos de ejemplo (10-20 productos)
- [ ] Seed de Clientes y Proveedores de ejemplo
- [ ] Ejecutar seed automáticamente en startup (solo en Development)

**DoD:**
- Seed data completo
- Ejecuta automáticamente en Development
- Datos de prueba útiles para desarrollo

---

#### T2.7: Repository Pattern (Opcional pero Recomendado) (12h)
**Responsable:** Backend Dev 1
**Descripción:** Implementar patrón Repository para abstracción de acceso a datos

**Subtareas:**
- [ ] Crear `Application/Common/Interfaces/IRepository<T>.cs`
  ```csharp
  public interface IRepository<T> where T : BaseEntity
  {
      Task<T> GetByIdAsync(int id, CancellationToken ct);
      Task<List<T>> GetAllAsync(CancellationToken ct);
      Task<T> AddAsync(T entity, CancellationToken ct);
      Task UpdateAsync(T entity, CancellationToken ct);
      Task DeleteAsync(int id, CancellationToken ct);
      IQueryable<T> Query();
  }
  ```
- [ ] Implementar `Infrastructure/Repositories/Repository<T>.cs`
- [ ] Crear repositorios específicos si se necesita lógica custom
- [ ] Registrar en DI Container

**DoD:**
- Repository pattern implementado
- Usado en al menos 1 feature
- Tests unitarios

---

#### T2.8: Performance Testing de DB (8h)
**Responsable:** Backend Dev 3 + QA
**Descripción:** Validar performance con múltiples tenants

**Subtareas:**
- [ ] Crear script para poblar DB con datos masivos:
  - 10 Tenants
  - 1000 Clientes por tenant
  - 500 Productos por tenant
  - 5000 Facturas por tenant
- [ ] Ejecutar queries y medir tiempos
- [ ] Validar índices están siendo usados (EXPLAIN)
- [ ] Optimizar índices si es necesario
- [ ] Documentar resultados

**DoD:**
- DB poblada con datos masivos
- Queries optimizadas (<100ms)
- Índices validados

---

#### T2.9: Backup y Recovery Strategy (4h)
**Responsable:** DevOps Engineer
**Descripción:** Definir estrategia de backups

**Subtareas:**
- [ ] Configurar backups automáticos de MySQL
- [ ] Definir retention policy (30 días)
- [ ] Probar restore de backup
- [ ] Documentar procedimiento

**DoD:**
- Backups automáticos configurados
- Restore probado exitosamente
- Documentación publicada

---

### Resumen US-002
**Total Estimado:** 104 horas
**Developers Asignados:** 3 Backend Devs + DevOps
**Timeline:** Días 1-8 del Sprint (paralelo con US-001)

---

## 🌐 US-003: API REST Base con Swagger (8 SP, 64 horas)

**Objetivo:** Configurar la infraestructura base de la API REST con mejores prácticas.

### Tasks Técnicas

#### T3.1: Configuración Inicial del Proyecto API (6h)
**Responsable:** Tech Lead
**Descripción:** Setup del proyecto ASP.NET Core Web API

**Subtareas:**
- [ ] Crear solution structure:
  ```
  src/
  ├── Domain/           (Class Library)
  ├── Application/      (Class Library)
  ├── Infrastructure/   (Class Library)
  └── API/              (ASP.NET Core Web API)
  tests/
  ├── Domain.Tests/
  ├── Application.Tests/
  └── Infrastructure.Tests/
  ```
- [ ] Configurar referencias entre proyectos
- [ ] Configurar appsettings.json (Development, Staging, Production)
- [ ] Configurar launchSettings.json
- [ ] Configurar .editorconfig y StyleCop

**DoD:**
- Solución creada y compilando
- Clean Architecture respetada
- Configuraciones básicas hechas

---

#### T3.2: Configurar Swagger/OpenAPI (4h)
**Responsable:** Backend Dev 1
**Descripción:** Documentación automática de API

**Subtareas:**
- [ ] Instalar `Swashbuckle.AspNetCore`
- [ ] Configurar Swagger en `Program.cs`
- [ ] Configurar versionado de API (v1)
- [ ] Agregar XML comments para documentación
- [ ] Configurar JWT Bearer en Swagger
- [ ] Personalizar UI de Swagger (logo, título, descripción)

**DoD:**
- Swagger accesible en `/swagger`
- Documentación generada automáticamente
- JWT testeable desde Swagger UI

---

#### T3.3: Configurar CORS (2h)
**Responsable:** Backend Dev 1
**Descripción:** Permitir requests desde frontend

**Subtareas:**
- [ ] Configurar CORS policy
- [ ] Permitir orígenes específicos (configurables)
- [ ] Permitir headers necesarios (Authorization, X-Tenant-Id)
- [ ] Configurar para Development y Production

**DoD:**
- CORS configurado correctamente
- Testeable desde frontend local

---

#### T3.4: Middleware de Error Handling Global (8h)
**Responsable:** Backend Dev 2
**Descripción:** Manejo centralizado de errores

**Subtareas:**
- [ ] Crear `API/Middleware/ExceptionHandlingMiddleware.cs`
- [ ] Capturar excepciones no manejadas
- [ ] Convertir excepciones a responses HTTP estándar:
  - `NotFoundException` → 404
  - `ValidationException` → 400
  - `UnauthorizedException` → 401
  - `ForbiddenException` → 403
  - `BusinessException` → 422
  - `Exception` → 500
- [ ] Formato de error estándar:
  ```json
  {
    "type": "ValidationError",
    "title": "One or more validation errors occurred",
    "status": 400,
    "errors": {
      "Email": ["Email is required"]
    },
    "traceId": "0HMV7K..."
  }
  ```
- [ ] Logear errores con Serilog
- [ ] NO exponer stack traces en Production

**DoD:**
- Middleware funcionando
- Errores estandarizados
- Tests de diferentes tipos de error

---

#### T3.5: Response Wrappers y Result Pattern (6h)
**Responsable:** Backend Dev 2
**Descripción:** Estandarizar responses de la API

**Subtareas:**
- [ ] Crear `Application/Common/Models/Result.cs`
  ```csharp
  public class Result<T>
  {
      public bool Success { get; set; }
      public T Data { get; set; }
      public string Message { get; set; }
      public List<string> Errors { get; set; }
  }
  ```
- [ ] Crear métodos helper (Result.Ok(), Result.Fail())
- [ ] Aplicar en controllers
- [ ] Configurar filtro para auto-wrapping (opcional)

**DoD:**
- Result pattern implementado
- Usado en al menos 2 endpoints
- Documentado en Wiki

---

#### T3.6: Configurar Logging con Serilog (6h)
**Responsable:** Backend Dev 3
**Descripción:** Structured logging

**Subtareas:**
- [ ] Instalar `Serilog.AspNetCore`
- [ ] Configurar sinks:
  - Console (Development)
  - File (Staging/Production)
  - Seq (opcional, para desarrollo)
- [ ] Configurar niveles de log por ambiente
- [ ] Configurar formato JSON estructurado
- [ ] Logear HTTP requests/responses
- [ ] Enriquecer logs con TenantId, UserId, TraceId

**DoD:**
- Serilog configurado
- Logs estructurados generándose
- Probado en diferentes ambientes

---

#### T3.7: Health Checks (4h)
**Responsable:** Backend Dev 3
**Descripción:** Endpoints para monitoreo

**Subtareas:**
- [ ] Configurar `/health` endpoint
- [ ] Health check de Database (MySQL)
- [ ] Health check de Redis (si se usa)
- [ ] Health check de API externa de Currency (ping)
- [ ] Configurar UI de Health Checks (opcional)

**DoD:**
- `/health` retorna 200 si todo OK
- Checks configurados
- Testeable desde Postman

---

#### T3.8: Rate Limiting (4h)
**Responsable:** Backend Dev 3
**Descripción:** Protección contra abuso

**Subtareas:**
- [ ] Instalar `AspNetCoreRateLimit`
- [ ] Configurar límites por IP:
  - 1000 requests/hour general
  - 100 requests/minute por endpoint
- [ ] Configurar límites por tenant (opcional)
- [ ] Retornar 429 Too Many Requests cuando se excede

**DoD:**
- Rate limiting funcionando
- Configuración documentada
- Tests validando límites

---

#### T3.9: API Versioning (4h)
**Responsable:** Backend Dev 1
**Descripción:** Soporte de múltiples versiones de API

**Subtareas:**
- [ ] Instalar `Microsoft.AspNetCore.Mvc.Versioning`
- [ ] Configurar versionado por URL (`/api/v1/...`)
- [ ] Configurar versionado en Swagger
- [ ] Crear estructura para v1 y v2 futuras

**DoD:**
- Versionado configurado
- `/api/v1/` funcional
- Documentado en Swagger

---

#### T3.10: Primer Controller de Ejemplo (10h)
**Responsable:** Backend Dev 1 + Backend Dev 2
**Descripción:** Implementar HealthController y TenantsController

**Subtareas:**
- [ ] Crear `API/Controllers/v1/HealthController.cs`
  - GET `/api/v1/health` → Status de la API
- [ ] Crear `API/Controllers/v1/TenantsController.cs`
  - GET `/api/v1/tenants` → Lista de tenants (solo Admin)
  - GET `/api/v1/tenants/{id}` → Detalle de tenant
  - POST `/api/v1/tenants` → Crear tenant (solo Admin)
  - PUT `/api/v1/tenants/{id}` → Actualizar tenant
- [ ] Implementar validators con FluentValidation
- [ ] Agregar XML comments para Swagger
- [ ] Tests de integración

**DoD:**
- 2 controllers implementados
- Endpoints documentados en Swagger
- Tests pasando

---

#### T3.11: Configurar FluentValidation (6h)
**Responsable:** Backend Dev 2
**Descripción:** Validaciones de input centralizadas

**Subtareas:**
- [ ] Instalar `FluentValidation.AspNetCore`
- [ ] Configurar pipeline de validación
- [ ] Crear validators para DTOs principales
- [ ] Integrar con middleware de error handling
- [ ] Configurar auto-retorno de 400 si validación falla

**DoD:**
- FluentValidation configurado
- Validators creados para DTOs principales
- Tests de validación

---

#### T3.12: Code Review y Documentación (4h)
**Responsable:** Tech Lead

**Subtareas:**
- [ ] Code Review de US-003
- [ ] Documentar convenciones de la API en Wiki
- [ ] Crear Postman Collection de ejemplo
- [ ] Publicar Swagger URL

**DoD:**
- PR aprobado y mergeado
- Documentación publicada
- Postman Collection disponible

---

### Resumen US-003
**Total Estimado:** 64 horas
**Developers Asignados:** 3 Backend Devs + Tech Lead
**Timeline:** Días 3-7 del Sprint

---

## 💱 US-007: API Consulta Tipos de Cambio (5 SP, 40 horas)

**Objetivo:** Integrar API externa para obtener tipos de cambio automáticamente.

### Tasks Técnicas

#### T7.1: Investigación de APIs de Tipos de Cambio (4h)
**Responsable:** Backend Dev 3
**Descripción:** Evaluar opciones de APIs externas

**Subtareas:**
- [ ] Investigar opciones:
  - ExchangeRate-API.com (gratuita, 1500 req/mes)
  - Fixer.io (freemium)
  - CurrencyLayer (freemium)
  - Open Exchange Rates (freemium)
  - Banco Central de cada país (oficial pero limitado)
- [ ] Comparar características (latencia, cobertura, límites)
- [ ] Seleccionar 1 principal + 1 fallback
- [ ] Obtener API keys de prueba

**DoD:**
- Documento de comparación
- API seleccionada (recomendado: ExchangeRate-API + fallback manual)
- API keys obtenidas

---

#### T7.2: Crear Entidades de Domain (3h)
**Responsable:** Backend Dev 3
**Descripción:** Modelar tipos de cambio en el dominio

**Subtareas:**
- [ ] Crear `Domain/Entities/ExchangeRate.cs`
  ```csharp
  public class ExchangeRate : BaseEntity
  {
      public CurrencyCode FromCurrency { get; set; }
      public CurrencyCode ToCurrency { get; set; }
      public decimal Rate { get; set; }
      public DateTime Date { get; set; }
      public string Source { get; set; } // "ExchangeRateAPI", "Manual"
      public int TenantId { get; set; }
  }
  ```
- [ ] Agregar a DbContext
- [ ] Crear migración

**DoD:**
- Entidad creada
- Migración aplicada

---

#### T7.3: Implementar HttpClient para API Externa (8h)
**Responsable:** Backend Dev 3
**Descripción:** Cliente HTTP para consultar tipos de cambio

**Subtareas:**
- [ ] Crear `Infrastructure/Services/ExchangeRateApiClient.cs`
- [ ] Configurar HttpClient con IHttpClientFactory
- [ ] Implementar método `GetExchangeRateAsync(from, to, date)`
- [ ] Mapear response de API a modelo interno
- [ ] Manejo de errores (timeout, 429, 500, etc.)
- [ ] Configurar retry policy con Polly (3 reintentos)

**Ejemplo:**
```csharp
public class ExchangeRateApiClient : IExchangeRateApiClient
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<ExchangeRateApiClient> _logger;

    public async Task<decimal> GetExchangeRateAsync(
        CurrencyCode from,
        CurrencyCode to,
        DateTime date)
    {
        var url = $"https://api.exchangerate-api.com/v4/latest/{from}";

        var response = await _httpClient.GetAsync(url);
        response.EnsureSuccessStatusCode();

        var data = await response.Content.ReadFromJsonAsync<ExchangeRateApiResponse>();

        if (!data.Rates.ContainsKey(to.ToString()))
            throw new CurrencyNotFoundException($"Rate not found for {to}");

        return data.Rates[to.ToString()];
    }
}
```

**DoD:**
- Cliente implementado
- Retry policy configurado
- Tests con mock de HttpClient

---

#### T7.4: Implementar Servicio de Currency (10h)
**Responsable:** Backend Dev 3
**Descripción:** Lógica de negocio para tipos de cambio

**Subtareas:**
- [ ] Crear `Application/Services/CurrencyService.cs`
- [ ] Implementar `ICurrencyService` interface
- [ ] Métodos principales:
  - `GetExchangeRateAsync(from, to, date)` → Consulta API o DB cache
  - `ConvertAsync(amount, from, to, date)` → Convierte montos
  - `UpdateExchangeRatesAsync()` → Actualiza rates diarios (background job)
- [ ] Implementar caching:
  - Cache en memoria (1 hora)
  - Cache en DB (histórico)
- [ ] Fallback a rate manual si API falla

**DoD:**
- Servicio completo implementado
- Caching funcionando
- Tests unitarios con mocks

---

#### T7.5: Background Job para Actualización Diaria (6h)
**Responsable:** Backend Dev 3
**Descripción:** Job que actualiza rates automáticamente cada día

**Subtareas:**
- [ ] Instalar Hangfire (o usar BackgroundService nativo)
- [ ] Configurar Hangfire con MySQL
- [ ] Crear job `UpdateExchangeRatesJob.cs`
- [ ] Programar ejecución diaria a las 6 AM UTC
- [ ] Actualizar rates de monedas principales (USD, ARS, MXN, CLP, PEN, COP, UYU)
- [ ] Guardar histórico en DB

**DoD:**
- Hangfire configurado
- Job ejecutándose correctamente
- Dashboard de Hangfire accesible (/hangfire)

---

#### T7.6: Implementar Controller de Currency (4h)
**Responsable:** Backend Dev 3
**Descripción:** Endpoints REST para consultar types de cambio

**Subtareas:**
- [ ] Crear `API/Controllers/v1/CurrencyController.cs`
- [ ] Endpoints:
  - GET `/api/v1/currency/rates?from=USD&to=ARS&date=2025-01-10` → Obtener rate
  - GET `/api/v1/currency/convert?amount=100&from=USD&to=ARS` → Convertir monto
  - GET `/api/v1/currency/rates/latest` → Últimos rates actualizados
  - POST `/api/v1/currency/rates` → Crear rate manual (solo Admin)
- [ ] Documentar en Swagger
- [ ] Agregar validaciones

**DoD:**
- Controller implementado
- Endpoints funcionando
- Documentados en Swagger

---

#### T7.7: Tests de Integración (3h)
**Responsable:** QA Engineer
**Descripción:** Tests end-to-end del flujo de currency

**Subtareas:**
- [ ] Test: Consultar rate de API externa
- [ ] Test: Convertir monto USD → ARS
- [ ] Test: Cache está funcionando (no consulta API 2 veces)
- [ ] Test: Fallback a rate manual si API falla
- [ ] Test: Background job actualiza rates

**DoD:**
- 5+ tests de integración pasando
- Coverage >90%

---

#### T7.8: Documentación y Demo (2h)
**Responsable:** Backend Dev 3

**Subtareas:**
- [ ] Documentar uso del servicio de Currency
- [ ] Crear ejemplos en README
- [ ] Preparar demo para Product Owner

**DoD:**
- Documentación publicada
- Demo preparada

---

### Resumen US-007
**Total Estimado:** 40 horas
**Developers Asignados:** 1 Backend Dev + QA
**Timeline:** Días 5-8 del Sprint

---

## 🧪 Testing y Quality Assurance (Transversal)

### Testing Strategy

**Responsable:** QA Engineer + All Developers

#### Unit Tests (Continuo)
- [ ] Todos los servicios y handlers con tests unitarios
- [ ] Coverage >95% en Application layer
- [ ] Coverage >90% en Infrastructure layer
- [ ] Usar xUnit + FluentAssertions + Moq

#### Integration Tests (Días 7-9)
- [ ] Tests de API completos (WebApplicationFactory)
- [ ] Tests de DB con TestContainers (MySQL)
- [ ] Tests de multi-tenancy isolation
- [ ] Tests de Currency Service con API externa mockeada

#### Code Quality (Continuo)
- [ ] SonarQube/SonarCloud configurado en pipeline
- [ ] Resolver code smells críticos
- [ ] Mantener Security Rating A
- [ ] Mantener Maintainability Rating A

---

## 🐳 US-048: Contenedorización con Docker (13 SP, 104 horas)

**Objetivo:** Contenedorizar la aplicación con Docker para garantizar consistencia entre entornos de desarrollo, testing, staging y producción (Dev/Prod Parity - Factor X del 12-Factor App).

### Tasks Técnicas

#### T48.1: Crear Dockerfile Multi-Stage Optimizado (16h)
**Responsable:** DevOps Engineer + Backend Dev 1
**Descripción:** Implementar Dockerfile production-ready con optimización de capas y seguridad

**Subtareas:**
- [ ] Crear `Dockerfile` en raíz del proyecto
- [ ] Stage 1: Build con mcr.microsoft.com/dotnet/sdk:8.0-alpine
  - Configurar WORKDIR /src
  - Copiar .sln y .csproj primero (para cache de restore)
  - Ejecutar dotnet restore
  - Copiar resto del código
  - Ejecutar dotnet build -c Release
- [ ] Stage 2: Publish
  - Ejecutar dotnet publish -c Release -o /app/publish
  - Optimizar artifacts (--no-restore)
- [ ] Stage 3: Runtime con mcr.microsoft.com/dotnet/aspnet:8.0-alpine
  - Crear non-root user (appuser:appgroup con UID 1000)
  - Copiar artifacts de stage publish
  - Configurar EXPOSE 8080
  - Configurar HEALTHCHECK integrado
  - Configurar ENTRYPOINT ["dotnet", "ERP.API.dll"]
- [ ] Validar que imagen final sea <150MB
- [ ] Crear `.dockerignore` con exclusiones apropiadas

**Ejemplo esperado:**
```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build
WORKDIR /src
COPY *.sln .
COPY src/**/*.csproj ./src/
RUN dotnet restore
COPY src/ ./src/
WORKDIR /src/API
RUN dotnet build -c Release -o /app/build --no-restore

FROM build AS publish
RUN dotnet publish -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS runtime
RUN addgroup -g 1000 appuser && adduser -D -u 1000 -G appuser appuser
WORKDIR /app
COPY --from=publish /app/publish .
RUN chown -R appuser:appuser /app
USER appuser
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s CMD wget --spider http://localhost:8080/health || exit 1
ENTRYPOINT ["dotnet", "ERP.API.dll"]
```

**DoD:**
- Dockerfile multi-stage creado
- Build exitoso con `docker build -t erp-api:dev .`
- Imagen <150MB
- Non-root user configurado
- Health check funcionando

---

#### T48.2: Crear docker-compose.yml Base (12h)
**Responsable:** DevOps Engineer
**Descripción:** Configurar stack completo con todos los servicios necesarios

**Subtareas:**
- [ ] Crear `docker-compose.yml` en raíz
- [ ] Servicio API:
  - Build desde Dockerfile local
  - Port mapping 5000:8080
  - Environment variables configurables
  - Depends_on con health checks de MySQL y Redis
  - Networks y volumes apropiados
- [ ] Servicio MySQL:
  - Image: mysql:8.0.35 (versión EXACTA, no :latest)
  - Environment: MYSQL_ROOT_PASSWORD, MYSQL_DATABASE
  - Port 3306 expuesto (solo para desarrollo)
  - Volume persistente para datos
  - Health check con mysqladmin ping
- [ ] Servicio Redis:
  - Image: redis:7.2-alpine (versión EXACTA)
  - Command: redis-server --appendonly yes
  - Port 6379 expuesto
  - Volume para persistencia
- [ ] Servicio Seq (logging):
  - Image: datalust/seq:2024.1 (versión EXACTA)
  - Port 5341:80 para UI
  - Volume para logs
  - Environment: ACCEPT_EULA=Y
- [ ] Configurar networks (app-network)
- [ ] Configurar volumes con nombres explícitos

**DoD:**
- docker-compose.yml funcional
- `docker-compose up -d` levanta todos los servicios
- Health checks pasando
- API accesible en http://localhost:5000
- MySQL accesible desde host
- Seq UI accesible en http://localhost:5341

---

#### T48.3: Crear Docker Compose Overrides por Ambiente (10h)
**Responsable:** DevOps Engineer
**Descripción:** Configurar overrides específicos para cada ambiente

**Subtareas:**
- [ ] Crear `docker-compose.override.yml` (Development):
  - Port exposures para debugging
  - Volumes para hot-reload (opcional)
  - Logging nivel Debug
  - Resource limits relajados
  - Comiteado al repo
- [ ] Crear `docker-compose.staging.yml`:
  - Resource limits (cpu: 1.0, memory: 2G para API)
  - Logging nivel Information
  - Restart policy: unless-stopped
  - Secrets desde archivos
  - Configuración específica de staging
- [ ] Crear `docker-compose.prod.yml`:
  - Resource limits estrictos (cpu: 2.0, memory: 4G)
  - Logging nivel Warning
  - Restart policy: always
  - Secrets desde orchestrator
  - Health checks más agresivos
  - NO exponer puertos internos
- [ ] Documentar uso de overrides:
  - Development: `docker-compose up` (auto-load override)
  - Staging: `docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d`
  - Production: `docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d`

**DoD:**
- 3 archivos de override creados
- Testeados en diferentes ambientes
- Documentados en README
- Commiteados al repo

---

#### T48.4: Crear Scripts de Utilidad (8h)
**Responsable:** DevOps Engineer + Backend Dev 2
**Descripción:** Scripts bash para simplificar operaciones comunes

**Subtareas:**
- [ ] Crear directorio `/scripts` en raíz
- [ ] `docker-build.sh`:
  - Build de imagen Docker
  - Tagging con versión y latest
  - Validación de build exitoso
- [ ] `docker-up.sh`:
  - Levanta stack en development
  - Espera health checks
  - Muestra logs de inicio
- [ ] `docker-up-staging.sh`:
  - Levanta con override de staging
  - Pull de imágenes antes de up
  - Validación de servicios
- [ ] `docker-logs.sh`:
  - Follow logs de todos los servicios o uno específico
  - Uso: `./scripts/docker-logs.sh [service-name]`
- [ ] `docker-migrate.sh`:
  - Ejecuta migrations EF Core dentro del container
  - Comando: `docker exec -it erp-api dotnet ef database update`
- [ ] `docker-clean.sh`:
  - Down de todos los containers
  - Limpieza de volumes (con confirmación)
  - Limpieza de imágenes dangling
- [ ] Configurar permisos de ejecución: `chmod +x scripts/*.sh`
- [ ] Validar compatibilidad con Git Bash (Windows)

**DoD:**
- 6 scripts creados y funcionando
- Permisos de ejecución configurados
- Probados en Linux y Windows (Git Bash)
- Documentados en README

---

#### T48.5: Validar Consistencia de Versiones (4h)
**Responsable:** DevOps Engineer + Tech Lead
**Descripción:** Garantizar que todas las versiones sean exactas y consistentes

**Subtareas:**
- [ ] Validar versiones en Dockerfile:
  - SDK: 8.0-alpine (revisar que sea versión estable)
  - Runtime: 8.0-alpine
- [ ] Validar versiones en docker-compose.yml:
  - MySQL: 8.0.35 (NO :8.0, NO :latest)
  - Redis: 7.2-alpine (NO :latest)
  - Seq: 2024.1 (NO :latest)
- [ ] Validar versiones en CI/CD workflows (US-049):
  - GitHub Actions debe usar las MISMAS versiones
  - Dockerfile en CI debe ser idéntico al local
- [ ] Documentar versiones en ESTRATEGIA_ENTORNOS_CONSISTENTES.md
- [ ] Crear checklist de verificación de versiones
- [ ] Configurar Dependabot para alertas de actualizaciones

**DoD:**
- Todas las versiones son exactas (no :latest)
- Documentado en estrategia de entornos
- Checklist creado
- Revisado por Tech Lead

---

#### T48.6: Documentar Setup de Docker (12h)
**Responsable:** Backend Dev 2 + Tech Lead
**Descripción:** Documentación completa para nuevos developers

**Subtareas:**
- [ ] Actualizar README.md con sección "🐳 Getting Started with Docker"
- [ ] Documentar prerrequisitos:
  - Docker Desktop 4.x+ instalado
  - Docker Compose v2
  - Git
  - 8GB RAM libre (mínimo)
- [ ] Documentar comandos básicos:
  - Levantar stack: `docker-compose up -d`
  - Ver logs: `docker-compose logs -f`
  - Detener: `docker-compose down`
  - Ejecutar migrations: `./scripts/docker-migrate.sh`
  - Acceder a shell del container: `docker exec -it erp-api bash`
- [ ] Documentar troubleshooting:
  - Puerto 5000 ya en uso
  - MySQL connection refused (health check no pasó)
  - Permisos en volumes (Windows WSL2)
  - Lentitud en Windows (habilitar WSL2 backend)
- [ ] Crear guía de debugging:
  - Cómo attachar debugger a container
  - Cómo ejecutar tests dentro del container
  - Cómo acceder a MySQL desde host (MySQL Workbench)
- [ ] Agregar capturas de pantalla o GIFs
- [ ] Crear FAQ section

**DoD:**
- README.md actualizado
- Guía de troubleshooting completa
- Al menos 2 capturas de pantalla
- Revisado por 2 developers del equipo

---

#### T48.7: Testing y Validación del Setup Completo (16h)
**Responsable:** QA Engineer + DevOps + Backend Dev 3
**Descripción:** Validación exhaustiva del setup de Docker en múltiples ambientes

**Subtareas:**
- [ ] Testing en Linux (Ubuntu):
  - `docker-compose build` exitoso
  - `docker-compose up -d` levanta todos los servicios
  - Health checks pasan en <2 minutos
  - API responde en http://localhost:5000/health
  - Swagger accesible en http://localhost:5000/swagger
  - Conectar a MySQL desde host (puerto 3306)
  - Ejecutar migrations exitosamente
- [ ] Testing en Windows (WSL2):
  - Mismos tests que Linux
  - Validar que WSL2 backend está habilitado
  - Validar performance (no usar Docker Desktop legacy backend)
- [ ] Testing en macOS (si hay máquinas disponibles):
  - Mismos tests que Linux
- [ ] Testing de scripts de utilidad:
  - Cada script debe ejecutarse sin errores
  - Validar output esperado
- [ ] Testing de overrides:
  - Levantar con override de staging
  - Validar configuraciones específicas
  - Validar resource limits aplicados
- [ ] Load testing básico:
  - 100 requests concurrentes a /health
  - Validar que containers no crashean
- [ ] Documentar resultados de tests

**DoD:**
- Tests pasando en Linux, Windows y macOS
- Scripts funcionando en los 3 OS
- Health checks <2 minutos
- API responde correctamente
- Documento de resultados de testing

---

#### T48.8: Integration con CI/CD (Preparación) (8h)
**Responsable:** DevOps Engineer
**Descripción:** Preparar integración con GitHub Actions (US-049)

**Subtareas:**
- [ ] Crear archivo `.dockerignore` optimizado:
  - Excluir bin/, obj/, .vs/, .git/
  - Excluir tests/ (no necesarios en imagen)
  - Excluir documentación (*.md excepto README)
- [ ] Validar que Dockerfile sea buildeable en CI:
  - Mismo Dockerfile funciona en CI y local
  - No depende de archivos locales no commiteados
- [ ] Documentar qué necesitará US-049 (CI/CD):
  - Docker Hub credentials (o GitHub Container Registry)
  - Build cache configuration
  - Multi-platform builds (opcional)
- [ ] Crear placeholder de workflow (comentado):
  - `.github/workflows/docker-build.yml.example`
  - Será usado por US-049

**DoD:**
- .dockerignore creado
- Dockerfile validado para CI
- Documentación de requisitos para US-049
- Placeholder de workflow creado

---

#### T48.9: Code Review y Refactoring (10h)
**Responsable:** Tech Lead + 2 Senior Devs
**Descripción:** Revisión exhaustiva de toda la implementación de Docker

**Subtareas:**
- [ ] Code review de Dockerfile:
  - Optimización de capas
  - Seguridad (non-root user, vulnerabilities)
  - Best practices (oficial de Docker)
- [ ] Code review de docker-compose files:
  - Configuraciones correctas
  - Resource limits apropiados
  - Health checks bien configurados
- [ ] Code review de scripts:
  - Manejo de errores
  - Mensajes informativos
  - Compatibilidad multiplataforma
- [ ] Code review de documentación:
  - Claridad y completitud
  - Ejemplos correctos
  - Links funcionando
- [ ] Refactoring según feedback
- [ ] Validar compliance con ESTRATEGIA_ENTORNOS_CONSISTENTES.md

**DoD:**
- Pull Request creado y revisado
- Al menos 2 aprobaciones
- Refactoring completado
- Todos los comentarios resueltos

---

#### T48.10: Demo y Knowledge Transfer (8h)
**Responsable:** DevOps Engineer + Scrum Master
**Descripción:** Presentación al equipo y transferencia de conocimiento

**Subtareas:**
- [ ] Preparar demo en vivo:
  - Máquina limpia (sin containers previos)
  - Clonar repo
  - Ejecutar setup completo
  - Mostrar stack funcionando
- [ ] Demo de comandos comunes:
  - Levantar, ver logs, detener
  - Ejecutar migrations
  - Debugging
- [ ] Sesión de Q&A con el equipo
- [ ] Grabar demo en video (para futuros miembros del equipo)
- [ ] Publicar video en Wiki
- [ ] Actualizar onboarding docs

**DoD:**
- Demo realizada exitosamente
- Video grabado y publicado
- Feedback del equipo capturado
- Onboarding docs actualizados

---

### Resumen US-048
**Total Estimado:** 104 horas
**Developers Asignados:** DevOps Engineer (lead) + 2-3 Backend Devs + QA
**Timeline:** Días 1-8 del Sprint (paralelo con otras US)

**Nota Importante:**
- US-049 (CI/CD Pipeline) y US-050 (Staging Setup) se movieron a Sprint 2
- Docker es fundamental para desarrollo local, por eso se incluye en Sprint 1
- CI/CD y Staging dependen de que Docker esté funcionando correctamente

---

## 📅 Sprint Schedule (Gantt Chart)

```
Day 1-2:  [US-001: T1.1-T1.3] [US-002: T2.1-T2.2]
Day 3-4:  [US-001: T1.4-T1.5] [US-002: T2.3-T2.4] [US-003: T3.1-T3.2]
Day 5-6:  [US-001: T1.6-T1.7] [US-002: T2.5-T2.6] [US-003: T3.3-T3.6] [US-007: T7.1-T7.3]
Day 7-8:  [US-002: T2.7-T2.8] [US-003: T3.7-T3.11] [US-007: T7.4-T7.6]
Day 9:    [Integration Testing] [Bug Fixes] [US-007: T7.7-T7.8]
Day 10:   [Code Review] [Documentation] [Sprint Demo]
```

---

## ✅ Sprint Definition of Done

El Sprint 1 está DONE cuando:

### Funcionalidad:
- [ ] Multi-tenancy implementado y probado con 2+ tenants
- [ ] API REST funcional con al menos 5 endpoints
- [ ] JWT authentication configurado (sin login aún, solo validación)
- [ ] Swagger documentando toda la API
- [ ] Currency Service consultando rates de API externa
- [ ] Background job actualizando rates diarios

### Base de Datos:
- [ ] Schema completo creado en MySQL
- [ ] Migraciones aplicadas
- [ ] Seed data ejecutado
- [ ] Índices optimizados y validados

### Testing:
- [ ] Unit tests >95% coverage en Application layer
- [ ] Integration tests >80% coverage
- [ ] Todos los tests pasando en CI
- [ ] SonarCloud sin issues críticos

### CI/CD:
- [ ] Pipeline CI/CD funcional en GitHub Actions
- [ ] Build y tests ejecutándose automáticamente
- [ ] Deployment a Staging exitoso
- [ ] Docker Compose funcional

### Documentación:
- [ ] README actualizado con setup instructions
- [ ] Swagger documentando endpoints
- [ ] Wiki con decisiones de arquitectura
- [ ] Postman Collection publicada

### Demo:
- [ ] Demo preparada y ensayada
- [ ] Product Owner acepta las funcionalidades
- [ ] Feedback capturado para próximo sprint

---

## 🎤 Sprint Ceremonies

### Daily Standup (15 min, cada día a las 9:30 AM)
**Formato:**
- ¿Qué hice ayer?
- ¿Qué haré hoy?
- ¿Tengo algún blocker?

**Checklist:**
- [ ] Actualizar estado de tasks en Jira/GitHub Projects
- [ ] Identificar blockers temprano
- [ ] Pair programming si alguien está atascado

---

### Sprint Review (2 horas, Día 10)
**Agenda:**
1. Demo de funcionalidades (45 min)
   - Multi-tenancy en acción
   - API REST con Swagger
   - Currency Service convirtiendo montos
2. Métricas del Sprint (15 min)
   - Velocity: 34 Story Points completados
   - Test Coverage: 92%
   - Bugs encontrados: X
3. Feedback del Product Owner (30 min)
4. Próximo Sprint Preview (30 min)

---

### Sprint Retrospective (1.5 horas, Día 10)
**Formato: Start, Stop, Continue**

**Preguntas guía:**
- ¿Qué funcionó bien?
- ¿Qué no funcionó?
- ¿Qué deberíamos mejorar?

**Acciones:**
- [ ] Identificar 2-3 mejoras concretas para Sprint 2
- [ ] Asignar responsables
- [ ] Trackear en próxima retro

---

## 📊 Sprint Metrics

### Planned vs Actual
- **Planned Story Points:** 34 pts
- **Planned Hours:** 272 hours
- **Actual Completed:** [TBD al final del sprint]
- **Velocity:** [TBD]

### Quality Metrics
- **Unit Test Coverage:** Target >95%
- **Integration Test Coverage:** Target >80%
- **Code Quality (SonarCloud):** Target A
- **Bugs Found:** Target <5
- **Bugs Fixed:** Target 100%

### Team Health
- **Team Morale:** [Survey al final]
- **Blockers Resolved:** [Count]
- **Pair Programming Sessions:** [Count]

---

## 🚧 Risks and Mitigation

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| MySQL multi-tenancy performance issues | HIGH | MEDIUM | Performance testing en T2.8, índices optimizados |
| API externa de Currency tiene downtime | MEDIUM | LOW | Implementar fallback a rates manuales |
| Team member enfermo | MEDIUM | MEDIUM | Pair programming, documentación continua |
| Complejidad de EF Core Query Filters | MEDIUM | MEDIUM | Tech Lead revisa implementación, tests exhaustivos |
| Overhead de meetings reduce tiempo productivo | LOW | MEDIUM | Limitar meetings a lo esencial, async communication |

---

## 📞 Sprint Contacts

- **Scrum Master:** [Nombre]
- **Product Owner:** [Nombre]
- **Tech Lead:** [Nombre]
- **Backend Devs:** [Dev 1], [Dev 2], [Dev 3]
- **QA Engineer:** [Nombre]
- **DevOps Engineer:** [Nombre]

**Communication Channels:**
- **Daily Standup:** Google Meet / Zoom
- **Chat:** Slack #erp-dev
- **Code Reviews:** GitHub Pull Requests
- **Documentation:** Confluence / GitHub Wiki

---

## 📚 Resources

### Documentation
- [Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [EF Core Multi-Tenancy](https://docs.microsoft.com/en-us/ef/core/miscellaneous/multitenancy)
- [ASP.NET Core Best Practices](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/best-practices)

### Tools
- **IDE:** Visual Studio 2022 / JetBrains Rider
- **DB Client:** MySQL Workbench / DBeaver
- **API Testing:** Postman / Insomnia
- **Git Client:** GitKraken / SourceTree / CLI

### APIs
- **ExchangeRate-API:** https://www.exchangerate-api.com/docs
- **Swagger Editor:** https://editor.swagger.io/

---

## ✨ Sprint 1 Success Criteria

**We will consider Sprint 1 successful if:**

1. ✅ Multi-tenancy is working flawlessly with data isolation verified
2. ✅ API is stable, documented, and deployable to Staging
3. ✅ Currency Service is converting amounts accurately
4. ✅ CI/CD pipeline is green and deploying automatically
5. ✅ Test coverage is >90%
6. ✅ Product Owner is satisfied with the demo
7. ✅ Team feels confident about the architecture decisions

---

## 🎯 Next Sprint Preview (Sprint 2)

**Tentative Scope for Sprint 2:**
- US-004: Autenticación JWT completa (Login, Refresh Token)
- US-041: User Management (CRUD de usuarios)
- US-042: Autorización RBAC con 7 roles
- US-010: Estructura Regional Multi-País (continuación)

**Preparation:**
- [ ] Refinar US-004, US-041, US-042 antes del Sprint Planning
- [ ] Investigar mejores prácticas de JWT en .NET 8
- [ ] Preparar diseño de RBAC

---

**FIN DEL SPRINT 1 BACKLOG**

**Ready to start development! 🚀**

---

**Última Actualización:** 2025-10-11
**Versión:** 1.0
**Estado:** Ready for Sprint Planning
