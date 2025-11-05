# Metodología de Implementación - Sistema ERP
## Stock / Comercial / Contable

**Versión:** 1.0
**Fecha:** 2025-10-10
**Proyecto:** Sistema de Gestión Integral (ERP)
**Basado en:** Aprendizajes de YouTube RAG .NET + Especificación de Negocio v0.1
**Stack Tecnológico:** .NET 8 + Clean Architecture

---

## 📋 Resumen Ejecutivo del Proyecto

### Alcance
Sistema ERP integral que cubre:
- **Stock/Inventario:** Multi-depósito, lotes/series, trazabilidad
- **Compras:** OC, recepción, cuentas a pagar
- **Ventas:** Cotización, pedidos, facturación, cuentas a cobrar
- **Logística:** Picking, packing, transferencias
- **Tesorería:** Caja/bancos, cobranzas, pagos
- **Contabilidad:** Asientos automáticos, plan de cuentas, cierres
- **Impuestos:** AFIP, IVA, IIBB, percepciones/retenciones (Argentina)
- **Integraciones:** e-commerce (Shopify, Mercado Libre, TiendaNube)

### Complejidad
- **Alta:** 7 roles diferentes, multi-sucursal, multi-moneda opcional
- **Requisitos estrictos:** 99.5% disponibilidad, <2s response time
- **Regulatorio:** Cumplimiento fiscal Argentina (AFIP e-Factura, CAE)

### Riesgos Identificados
- Complejidad contable y fiscal
- Múltiples integraciones externas
- Requisitos de auditoría estrictos
- Migración de datos legacy

---

## 🎯 Principios Fundamentales Aplicados

### 1. NO DUPLICACIÓN (Crítico para ERP)
```
🚫 NO crear múltiples versiones por tipo de negocio (mayorista/minorista/e-commerce)
✅ UN sistema configurable con feature toggles por canal
✅ UN motor de facturación con tipos configurables (A/B/C/E)
✅ UN motor de asientos contables con plantillas configurables
```

**Rationale:** En ERPs es común que surjan "versiones especiales" por sucursal o canal.
Esto lleva a divergencia de código y bugs imposibles de trackear.

### 2. Clean Architecture Estricta
```
Domain Layer:
- Entidades: Producto, Cliente, Proveedor, Pedido, Factura, Asiento
- Reglas de negocio: validaciones contables, cálculos fiscales
- Interfaces: IStockService, IFacturacionService, IContabilidadService

Application Layer:
- DTOs para cada operación
- Servicios de aplicación con orquestación
- Validadores con FluentValidation
- Mapeos con AutoMapper

Infrastructure Layer:
- DbContext con 30+ entidades
- Repositorios con Unit of Work
- Servicios externos (AFIP, e-commerce)
- Background jobs (Hangfire)

API Layer:
- Controllers por módulo (Stock, Ventas, Compras, etc.)
- Autenticación JWT con roles
- Swagger completo
- Health checks
```

### 3. Testing No Negociable para ERP
```
✅ Unit tests: Validaciones contables, cálculos fiscales (>90% coverage)
✅ Integration tests: Flujos E2E (Pedido→Factura→Asiento→Stock) (>80%)
✅ Regression tests: Cálculos de impuestos, asientos contables (100%)
✅ Performance tests: Procesamiento de batch de 1000+ facturas
```

**Rationale:** Errores en cálculos contables o fiscales son CRÍTICOS. No negociable.

### 4. Auditoría Total desde Día 1
```
✅ Cada entidad con CreatedAt, CreatedBy, UpdatedAt, UpdatedBy
✅ Tabla AuditLog con registro de TODOS los cambios
✅ Soft deletes (IsDeleted flag) - NUNCA hard delete
✅ Versionado de documentos fiscales (inmutables después de firmados)
```

### 5. DevOps Automatizado Crítico
```
✅ CI/CD con GitHub Actions
✅ Automated testing en cada commit
✅ Deployment automatizado a staging/production
✅ Database migrations automatizadas con rollback
✅ Backup automático diario
```

---

## 🏗️ Arquitectura Técnica Propuesta

### Stack Tecnológico

**Backend:**
- **.NET 8** - Framework principal
- **ASP.NET Core Web API** - REST API
- **Entity Framework Core 8** - ORM
- **MySQL 8** - Base de datos principal
- **Redis** - Caching y sessions
- **Hangfire** - Background jobs
- **FluentValidation** - Validaciones
- **AutoMapper** - Mappings
- **Serilog** - Logging estructurado

**Integraciones:**
- **AFIP SDK** - Factura electrónica Argentina
- **Shopify/ML/TiendaNube APIs** - e-commerce
- **SignalR** - Real-time notifications

**DevOps:**
- **Docker Compose** - Local development
- **GitHub Actions** - CI/CD
- **Azure/AWS** - Cloud hosting (TBD)

### Estructura del Proyecto

```
ERP-Backend/
├── src/
│   ├── ERP.Domain/
│   │   ├── Entities/
│   │   │   ├── Stock/
│   │   │   │   ├── Producto.cs
│   │   │   │   ├── Stock.cs
│   │   │   │   ├── Movimiento.cs
│   │   │   │   ├── Lote.cs
│   │   │   │   └── Ubicacion.cs
│   │   │   ├── Compras/
│   │   │   │   ├── Proveedor.cs
│   │   │   │   ├── OrdenCompra.cs
│   │   │   │   ├── Recepcion.cs
│   │   │   │   └── FacturaProveedor.cs
│   │   │   ├── Ventas/
│   │   │   │   ├── Cliente.cs
│   │   │   │   ├── ListaPrecio.cs
│   │   │   │   ├── Pedido.cs
│   │   │   │   ├── Factura.cs
│   │   │   │   └── Cobranza.cs
│   │   │   ├── Contabilidad/
│   │   │   │   ├── CuentaContable.cs
│   │   │   │   ├── Asiento.cs
│   │   │   │   ├── AsientoDetalle.cs
│   │   │   │   └── CentroCosto.cs
│   │   │   ├── Logistica/
│   │   │   │   ├── Deposito.cs
│   │   │   │   ├── Transferencia.cs
│   │   │   │   ├── Picking.cs
│   │   │   │   └── Packing.cs
│   │   │   ├── Tesoreria/
│   │   │   │   ├── Caja.cs
│   │   │   │   ├── Banco.cs
│   │   │   │   ├── Recibo.cs
│   │   │   │   └── OrdenPago.cs
│   │   │   └── Shared/
│   │   │       ├── BaseEntity.cs (Id, CreatedAt, UpdatedAt, IsDeleted)
│   │   │       └── AuditLog.cs
│   │   ├── Enums/
│   │   │   ├── EstadoPedido.cs
│   │   │   ├── TipoFactura.cs (A, B, C, E)
│   │   │   ├── TipoMovimiento.cs
│   │   │   └── CondicionIVA.cs
│   │   └── Interfaces/
│   │       ├── IStockService.cs
│   │       ├── IFacturacionService.cs
│   │       ├── IContabilidadService.cs
│   │       └── IAFIPService.cs
│   │
│   ├── ERP.Application/
│   │   ├── Configuration/
│   │   │   ├── AFIPOptions.cs
│   │   │   ├── ImpuestosOptions.cs
│   │   │   └── IntegracionesOptions.cs
│   │   ├── DTOs/
│   │   │   ├── Stock/
│   │   │   ├── Ventas/
│   │   │   ├── Compras/
│   │   │   ├── Contabilidad/
│   │   │   └── Shared/
│   │   ├── Interfaces/
│   │   │   └── Services/ (por módulo)
│   │   ├── Services/
│   │   │   ├── Stock/
│   │   │   │   ├── StockService.cs
│   │   │   │   ├── MovimientoService.cs
│   │   │   │   └── InventarioService.cs
│   │   │   ├── Ventas/
│   │   │   │   ├── PedidoService.cs
│   │   │   │   ├── FacturacionService.cs
│   │   │   │   └── CobranzaService.cs
│   │   │   ├── Compras/
│   │   │   │   ├── OrdenCompraService.cs
│   │   │   │   ├── RecepcionService.cs
│   │   │   │   └── ProveedorService.cs
│   │   │   ├── Contabilidad/
│   │   │   │   ├── AsientoService.cs
│   │   │   │   ├── AsientoAutomaticoService.cs (CRÍTICO)
│   │   │   │   └── CierreContableService.cs
│   │   │   └── Shared/
│   │   │       └── AuditService.cs
│   │   └── Validators/
│   │       ├── PedidoValidator.cs
│   │       ├── FacturaValidator.cs
│   │       └── AsientoValidator.cs
│   │
│   ├── ERP.Infrastructure/
│   │   ├── Data/
│   │   │   ├── ERPDbContext.cs
│   │   │   ├── Configurations/ (EntityTypeConfiguration por entidad)
│   │   │   └── Migrations/
│   │   ├── Repositories/
│   │   │   ├── Base/
│   │   │   │   └── Repository.cs
│   │   │   ├── StockRepository.cs
│   │   │   ├── VentasRepository.cs
│   │   │   └── ContabilidadRepository.cs
│   │   ├── Jobs/
│   │   │   ├── ReposicionStockJob.cs
│   │   │   ├── CierreContableJob.cs
│   │   │   └── SincronizacionEcommerceJob.cs
│   │   └── Services/
│   │       ├── AFIP/
│   │       │   ├── AFIPFacturaElectronicaService.cs
│   │       │   ├── AFIPPadronService.cs
│   │       │   └── AFIPWSAAService.cs (autenticación)
│   │       └── Integraciones/
│   │           ├── ShopifyService.cs
│   │           ├── MercadoLibreService.cs
│   │           └── TiendaNubeService.cs
│   │
│   └── ERP.Api/
│       ├── Controllers/
│       │   ├── Stock/
│       │   │   ├── ProductosController.cs
│       │   │   ├── StockController.cs
│       │   │   └── MovimientosController.cs
│       │   ├── Ventas/
│       │   │   ├── ClientesController.cs
│       │   │   ├── PedidosController.cs
│       │   │   ├── FacturasController.cs
│       │   │   └── CobranzasController.cs
│       │   ├── Compras/
│       │   │   ├── ProveedoresController.cs
│       │   │   ├── OrdenesCompraController.cs
│       │   │   └── RecepcionesController.cs
│       │   ├── Contabilidad/
│       │   │   ├── PlanCuentasController.cs
│       │   │   ├── AsientosController.cs
│       │   │   └── CierresController.cs
│       │   └── Reportes/
│       │       ├── ReportesStockController.cs
│       │       ├── ReportesVentasController.cs
│       │       └── ReportesContablesController.cs
│       ├── HealthChecks/
│       │   ├── DatabaseHealthCheck.cs
│       │   ├── AFIPHealthCheck.cs
│       │   └── EcommerceHealthCheck.cs
│       ├── Middleware/
│       │   ├── AuditMiddleware.cs
│       │   ├── ErrorHandlingMiddleware.cs
│       │   └── PerformanceMiddleware.cs
│       └── Program.cs
│
├── tests/
│   ├── ERP.Tests.Unit/
│   │   ├── Domain/
│   │   ├── Services/
│   │   └── Validators/
│   ├── ERP.Tests.Integration/
│   │   ├── Stock/
│   │   ├── Ventas/
│   │   ├── Compras/
│   │   ├── Contabilidad/ (CRÍTICO - 100% coverage)
│   │   └── E2E/
│   │       ├── FlujoPedidoCompletoTests.cs
│   │       ├── FlujoCompraCompletoTests.cs
│   │       └── FlujoContableTests.cs
│   └── ERP.Tests.Performance/
│       ├── BulkFacturacionTests.cs
│       └── CierreContablePerformanceTests.cs
│
├── scripts/
│   ├── dev-setup.ps1
│   ├── dev-setup.sh
│   ├── seed-database.ps1 (datos de prueba completos)
│   └── migrate-database.ps1
│
├── docs/
│   ├── architecture/
│   │   ├── ADR-001-clean-architecture.md
│   │   ├── ADR-002-database-design.md
│   │   ├── ADR-003-audit-strategy.md
│   │   └── DER-sistema-completo.png
│   ├── business/
│   │   ├── Especificacion-Negocio.pdf (original)
│   │   ├── procesos-bpmn/ (diagramas)
│   │   └── asientos-contables-plantillas.md
│   └── devops/
│       ├── DEVELOPER_SETUP_GUIDE.md
│       └── DEPLOYMENT_GUIDE.md
│
├── .github/workflows/
│   ├── ci.yml
│   ├── cd-staging.yml
│   ├── cd-production.yml
│   └── security.yml
│
├── docker-compose.yml
├── docker-compose.dev.yml
├── .env.template
├── .gitignore
├── .editorconfig
└── README.md
```

---

## 📅 Plan de Implementación por Fases

### **FASE 0: Setup y Foundation (Semana 1-2)**

#### Objetivos
- Setup completo del proyecto
- CI/CD funcional
- Estructura de Clean Architecture
- Base de datos y migraciones
- Autenticación y autorización

#### Tareas (Sprint 0)

**Día 1-2: Setup Inicial**
- [ ] Crear repositorio Git
- [ ] Configurar estructura de proyectos (.NET solution)
- [ ] Setup de Docker Compose (MySQL, Redis)
- [ ] Configurar CI/CD básico (GitHub Actions)
- [ ] Crear scripts de setup automatizado
- [ ] Documentación base (README, CONTRIBUTING)

**Día 3-5: Domain Layer**
- [ ] Diseñar DER completo (30+ entidades)
- [ ] Implementar entidades de dominio base
- [ ] Implementar BaseEntity con auditoría
- [ ] Crear enumeraciones (EstadoPedido, TipoFactura, etc.)
- [ ] Definir interfaces de servicios de dominio

**Día 6-8: Infrastructure Layer**
- [ ] Configurar ERPDbContext
- [ ] Crear EntityTypeConfiguration para cada entidad
- [ ] Implementar repositorios base
- [ ] Configurar Unit of Work pattern
- [ ] Primera migración de base de datos
- [ ] Seed de datos maestros básicos

**Día 9-10: API Base**
- [ ] Configurar Program.cs con DI
- [ ] Implementar autenticación JWT
- [ ] Implementar autorización RBAC (7 roles)
- [ ] Configurar Swagger/OpenAPI
- [ ] Implementar health checks
- [ ] Middleware de auditoría y error handling

**Entregables Fase 0:**
- ✅ Proyecto compilando sin errores
- ✅ CI/CD ejecutando tests básicos
- ✅ Base de datos con schema completo
- ✅ Autenticación funcionando
- ✅ Setup automatizado (<5 min)
- ✅ Documentación actualizada

---

### **FASE 1: MVP - Stock + Compras (Semana 3-5)**

#### Epic 1: Gestión de Inventario

**US-001: Alta de Catálogo de Productos**
- Story Points: 8
- AC: Crear productos con SKU, descripción, UoM, GTIN, categoría, atributos, foto
- Implementación:
  - ProductoController con CRUD
  - ProductoService con validaciones
  - Tests: unitarios + integration

**US-002: Gestión de Stock por Depósito**
- Story Points: 13
- AC: Multi-depósito, ubicaciones (depósito→zona→ubicación), stock real/reservado
- Implementación:
  - StockService con lógica de movimientos
  - StockRepository con queries optimizadas
  - Tests: scenarios de movimientos complejos

**US-003: Movimientos de Inventario**
- Story Points: 8
- AC: Ingresos, egresos, transferencias, ajustes con motivos y autorización
- Implementación:
  - MovimientoService con validaciones de negocio
  - Auditoría completa de movimientos
  - Tests: E2E de flujo completo

**US-004: Trazabilidad de Stock**
- Story Points: 5
- AC: Historial completo por SKU, lote, documento origen, usuario
- Implementación:
  - TrazabilidadService con queries complejas
  - Reportes de trazabilidad
  - Tests: queries de performance

#### Epic 2: Compras

**US-005: Maestro de Proveedores**
- Story Points: 5
- AC: CUIT, condición IVA, lead time, condiciones de pago
- Implementación:
  - ProveedorController + Service
  - Validaciones fiscales (CUIT, condición IVA)
  - Tests: validaciones

**US-006: Órdenes de Compra**
- Story Points: 13
- AC: Carga manual, sugeridas por MRP simple (punto de pedido), aprobación workflow
- Implementación:
  - OrdenCompraService con workflow
  - MRP simple (cálculo punto de pedido)
  - Tests: workflow de aprobaciones

**US-007: Recepción de Mercadería**
- Story Points: 13
- AC: Contra OC, tolerancias, control de calidad, discrepancias
- Implementación:
  - RecepcionService con validación contra OC
  - Ingreso automático a stock
  - Generación automática de asiento contable (CRÍTICO)
  - Tests: flujo completo con asientos

**US-008: Facturas de Proveedor**
- Story Points: 8
- AC: Validación contra OC/recepción, retenciones/percepciones, cuentas a pagar
- Implementación:
  - FacturaProveedorService
  - Cálculo de retenciones/percepciones
  - Asiento contable automático
  - Tests: cálculos fiscales (100% coverage)

**Entregables Fase 1:**
- ✅ Módulo Stock completo y probado
- ✅ Módulo Compras completo y probado
- ✅ Asientos contables de compras funcionando
- ✅ Tests >80% coverage
- ✅ Performance: <2s response time
- ✅ Documentación API (Swagger)

---

### **FASE 2: MVP - Ventas + Logística (Semana 6-8)**

#### Epic 3: Ventas

**US-009: Maestro de Clientes**
- Story Points: 5
- AC: Condición fiscal, lista de precios, límite de crédito, canal
- Implementación:
  - ClienteController + Service
  - Validación de crédito
  - Tests: validaciones

**US-010: Listas de Precios y Promociones**
- Story Points: 8
- AC: Por canal/cliente, vigencias, descuentos, combos, 2×1
- Implementación:
  - ListaPrecioService con reglas de promociones
  - Motor de cálculo de precios
  - Tests: escenarios de promociones

**US-011: Gestión de Pedidos**
- Story Points: 13
- AC: Verificación de crédito, verificación de stock, reserva automática
- Implementación:
  - PedidoService con workflow
  - Reserva automática de stock
  - Tests: validaciones de crédito y stock

**US-012: Facturación Electrónica AFIP**
- Story Points: 21 (CRÍTICO)
- AC: Tipos A/B/C/E, CAE, timbrado, validaciones AFIP
- Implementación:
  - FacturacionService
  - Integración con AFIP SDK
  - Generación de PDF de factura
  - Asiento contable automático (CRÍTICO)
  - Descuento de stock
  - Tests: todos los tipos de factura + rollback en caso de error AFIP

**US-013: Notas de Crédito y Devoluciones**
- Story Points: 13
- AC: Reintegro a stock, control de estado, asiento contable reverso
- Implementación:
  - NotaCreditoService
  - Reintegro inteligente a stock
  - Asiento contable reverso
  - Tests: flujo completo

**US-014: Cobranzas**
- Story Points: 8
- AC: Efectivo, transferencia, tarjetas, conciliación
- Implementación:
  - CobranzaService
  - Integración con medios de pago
  - Asiento contable de cobranza
  - Tests: diferentes medios de pago

#### Epic 4: Logística

**US-015: Picking y Packing**
- Story Points: 13
- AC: Por prioridad/ola, control de bultos, etiquetas
- Implementación:
  - PickingService con algoritmo de optimización
  - PackingService con validaciones
  - Tests: scenarios complejos

**US-016: Transferencias entre Depósitos**
- Story Points: 8
- AC: Solicitud, aprobación, tránsito, recepción
- Implementación:
  - TransferenciaService con workflow
  - Control de stock en tránsito
  - Tests: workflow completo

**Entregables Fase 2:**
- ✅ Módulo Ventas completo (incluyendo AFIP)
- ✅ Módulo Logística completo
- ✅ Asientos contables de ventas funcionando
- ✅ Facturación AFIP probada exhaustivamente
- ✅ Tests >80% coverage
- ✅ E2E test: Pedido→Factura→Cobranza→Asientos

---

### **FASE 3: Contabilidad + Tesorería (Semana 9-10)**

#### Epic 5: Contabilidad

**US-017: Plan de Cuentas**
- Story Points: 8
- AC: Parametrizable nivel 4-6, jerarquía, tipos de cuenta
- Implementación:
  - PlanCuentasService
  - Validaciones de estructura
  - Tests: validaciones

**US-018: Motor de Asientos Automáticos (CRÍTICO)**
- Story Points: 21
- AC: Por evento (recepción, factura, cobro, pago, ajuste), configurable por plantillas
- Implementación:
  - AsientoAutomaticoService (CORE DEL SISTEMA)
  - Plantillas de asientos por tipo de operación
  - Engine de generación de asientos
  - Validación contable (debe = haber)
  - Tests: TODOS los tipos de asientos (100% coverage)

**US-019: Centros de Costo y Dimensiones**
- Story Points: 8
- AC: Canal, sucursal, proyecto
- Implementación:
  - CentroCostoService
  - Asientos con dimensiones
  - Tests: reportes por dimensión

**US-020: Cierre Contable**
- Story Points: 13
- AC: Cierre mensual, validaciones, bloqueo de modificaciones
- Implementación:
  - CierreContableService
  - Validaciones pre-cierre
  - Generación de asientos de cierre
  - Tests: flujo completo de cierre

#### Epic 6: Tesorería

**US-021: Caja y Bancos**
- Story Points: 8
- AC: Recibos, pagos, arqueos, conciliación bancaria
- Implementación:
  - CajaService
  - BancoService con conciliación
  - Tests: conciliación automática

**Entregables Fase 3:**
- ✅ Módulo Contabilidad completo
- ✅ Motor de asientos automáticos funcionando perfectamente
- ✅ Módulo Tesorería completo
- ✅ Tests >90% coverage (contabilidad 100%)
- ✅ E2E test: Flujo contable completo
- ✅ Performance: cierre contable <30 min

---

### **FASE 4: Integraciones + Reportes (Semana 11-12)**

#### Epic 7: Integraciones

**US-022: Integración Shopify**
- Story Points: 13
- AC: Sincronización bidireccional de pedidos, clientes, stock, precios
- Implementación:
  - ShopifyService con webhooks
  - Sincronización en background (Hangfire)
  - Tests: simulación de webhooks

**US-023: Integración Mercado Libre**
- Story Points: 13
- AC: Similar a Shopify
- Implementación: Similar

**US-024: Integración TiendaNube**
- Story Points: 13
- AC: Similar a Shopify
- Implementación: Similar

#### Epic 8: Reportes y KPIs

**US-025: Reportes Operativos**
- Story Points: 8
- AC: Stock por SKU/depósito, valuación, rotación ABC, quiebres
- Implementación:
  - ReportesStockService
  - Queries optimizadas
  - Export a Excel/PDF
  - Tests: performance

**US-026: Reportes Comerciales**
- Story Points: 8
- AC: Ventas por canal/cliente/SKU, margen bruto
- Implementación: Similar

**US-027: Reportes Financieros**
- Story Points: 13
- AC: Cuentas por cobrar/pagar, aging, flujo de caja, PyG, balance
- Implementación:
  - ReportesContablesService
  - Generación de estados contables
  - Tests: validación de balances

**Entregables Fase 4:**
- ✅ Integraciones e-commerce funcionando
- ✅ Reportes completos
- ✅ Dashboards por rol
- ✅ Tests >80% coverage
- ✅ Performance: reportes <5s

---

### **FASE 5: Quality & Production Ready (Semana 13-14)**

#### Objetivos
- Testing exhaustivo
- Performance optimization
- Security hardening
- Documentation
- Production deployment

#### Tareas

**Testing:**
- [ ] Test coverage >85% general, >95% contabilidad
- [ ] E2E tests de todos los flujos críticos
- [ ] Performance tests (load testing con 1000+ usuarios concurrentes)
- [ ] Security testing (OWASP)
- [ ] UAT con usuarios clave

**Performance:**
- [ ] Optimización de queries
- [ ] Implementación de caching (Redis)
- [ ] CDN para assets
- [ ] Database indexing
- [ ] Connection pooling optimization

**Security:**
- [ ] Penetration testing
- [ ] Dependency vulnerability scanning
- [ ] Security headers
- [ ] Rate limiting
- [ ] SQL injection prevention validation

**Documentation:**
- [ ] API documentation completa (Swagger)
- [ ] User manuals por rol
- [ ] Admin guide
- [ ] Deployment guide
- [ ] Troubleshooting guide

**Production:**
- [ ] Blue-green deployment setup
- [ ] Monitoring (Application Insights / New Relic)
- [ ] Logging estructurado (Serilog)
- [ ] Backup strategy
- [ ] Disaster recovery plan

**Entregables Fase 5:**
- ✅ Sistema production-ready
- ✅ Documentación completa
- ✅ Tests >85% coverage
- ✅ Performance targets met
- ✅ Security audit passed
- ✅ Deployment automatizado

---

## 🔧 Configuration Strategy (Crítico para ERP)

### Variables de Entorno (.env)

```bash
# ========================================
# ENVIRONMENT
# ========================================
ENVIRONMENT=development|testing|production

# ========================================
# DATABASE
# ========================================
DATABASE_HOST=localhost
DATABASE_PORT=3306
DATABASE_NAME=erp_db
DATABASE_USER=erp_user
DATABASE_PASSWORD=***

# ========================================
# REDIS
# ========================================
REDIS_HOST=localhost
REDIS_PORT=6379

# ========================================
# AUTHENTICATION
# ========================================
JWT_SECRET=***
JWT_EXPIRATION_MINUTES=480
JWT_REFRESH_EXPIRATION_DAYS=7
ENABLE_MFA=false

# ========================================
# AFIP (Argentina)
# ========================================
AFIP_ENVIRONMENT=testing|production
AFIP_CUIT=***
AFIP_CERTIFICATE_PATH=/certificates/afip.pfx
AFIP_CERTIFICATE_PASSWORD=***
AFIP_PUNTO_VENTA=1
ENABLE_AFIP_INTEGRATION=true

# ========================================
# FISCAL (Argentina)
# ========================================
IVA_GENERAL=21.0
IVA_REDUCIDO=10.5
CALCULAR_PERCEPCIONES_IIBB=true
CALCULAR_RETENCIONES=true

# ========================================
# E-COMMERCE INTEGRATIONS
# ========================================
ENABLE_SHOPIFY=false
SHOPIFY_SHOP_DOMAIN=***
SHOPIFY_API_KEY=***
SHOPIFY_API_SECRET=***

ENABLE_MERCADOLIBRE=false
ML_CLIENT_ID=***
ML_CLIENT_SECRET=***

ENABLE_TIENDANUBE=false
TIENDANUBE_APP_ID=***
TIENDANUBE_APP_SECRET=***

# ========================================
# FEATURE TOGGLES
# ========================================
ENABLE_MULTI_MONEDA=false
ENABLE_LOTES_SERIES=true
ENABLE_INVENTARIO_CICLICO=true
ENABLE_PICKING_AVANZADO=true
ENABLE_ASIENTOS_AUTOMATICOS=true
ENABLE_REPORTES_AVANZADOS=true

# ========================================
# BUSINESS RULES
# ========================================
PERMITIR_FACTURAR_SIN_STOCK=false
PERMITIR_EXCEDER_CREDITO=false
METODO_VALUACION_STOCK=PPP  # PPP, PEPS, UEPS
DIAS_ALERTA_VENCIMIENTO=30

# ========================================
# PERFORMANCE
# ========================================
ENABLE_REDIS_CACHE=true
CACHE_DURACION_MINUTOS=15
DATABASE_POOL_SIZE=100
HANGFIRE_WORKERS=5

# ========================================
# LOGGING
# ========================================
LOG_LEVEL=Information
SERILOG_WRITE_TO_FILE=true
SERILOG_FILE_PATH=/logs/erp.log
SERILOG_WRITE_TO_SEQ=false

# ========================================
# PATHS
# ========================================
TEMP_PATH=/tmp/erp
UPLOADS_PATH=/uploads
FACTURAS_PDF_PATH=/facturas
BACKUP_PATH=/backups
```

### appsettings.json (por environment)

**appsettings.Development.json:**
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Debug",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "Swagger": {
    "Enabled": true
  },
  "AFIP": {
    "UseMockService": true
  }
}
```

**appsettings.Production.json:**
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "erp.tuempresa.com",
  "Swagger": {
    "Enabled": false
  },
  "AFIP": {
    "UseMockService": false
  }
}
```

---

## 🧪 Testing Strategy (Crítico para ERP)

### Niveles de Testing

**1. Unit Tests (Target: >85% coverage general, >95% contabilidad)**

Prioridades:
- ✅ **Cálculos contables** (100% coverage) - CRÍTICO
- ✅ **Cálculos fiscales** (100% coverage) - CRÍTICO
- ✅ **Validaciones de negocio** (>90% coverage)
- ✅ **Servicios de aplicación** (>85% coverage)

Ejemplo:
```csharp
[TestFixture]
public class AsientoAutomaticoServiceTests
{
    [Test]
    public void GenerarAsientoVenta_ConIVA21_DebeGenerarAsientoCorrecto()
    {
        // Arrange
        var factura = new Factura
        {
            TipoFactura = TipoFactura.A,
            Subtotal = 100m,
            IVA = 21m,
            Total = 121m
        };

        // Act
        var asiento = _asientoService.GenerarAsientoVenta(factura);

        // Assert
        Assert.That(asiento.Detalle.Count, Is.EqualTo(3));
        Assert.That(asiento.Debe, Is.EqualTo(asiento.Haber)); // CRÍTICO
        Assert.That(asiento.Debe, Is.EqualTo(121m));

        // Validar cuentas
        var debeClientes = asiento.Detalle.First(d => d.CuentaContable.Codigo == "1.1.01.001");
        Assert.That(debeClientes.Debe, Is.EqualTo(121m));

        var haberVentas = asiento.Detalle.First(d => d.CuentaContable.Codigo == "4.1.01.001");
        Assert.That(haberVentas.Haber, Is.EqualTo(100m));

        var haberIVA = asiento.Detalle.First(d => d.CuentaContable.Codigo == "2.1.04.001");
        Assert.That(haberIVA.Haber, Is.EqualTo(21m));
    }
}
```

**2. Integration Tests (Target: >80% coverage)**

Prioridades:
- ✅ **Flujos E2E críticos** (100% coverage)
- ✅ **API endpoints** (100% coverage)
- ✅ **Integraciones externas** (>80% coverage)

Ejemplo:
```csharp
[TestFixture]
public class FlujoVentaCompletoIntegrationTests
{
    [Test]
    public async Task FlujoCompleto_PedidoHastaCobranza_DebeGenerarTodosLosAsientos()
    {
        // 1. Crear pedido
        var pedido = await CrearPedidoAsync();
        Assert.That(pedido.Estado, Is.EqualTo(EstadoPedido.Pendiente));

        // 2. Verificar stock y aprobar
        await AprobarPedidoAsync(pedido.Id);
        Assert.That(pedido.Estado, Is.EqualTo(EstadoPedido.Aprobado));

        var stockReservado = await _stockService.GetStockReservadoAsync(producto.Id);
        Assert.That(stockReservado, Is.EqualTo(10));

        // 3. Facturar (genera asiento automático)
        var factura = await FacturarPedidoAsync(pedido.Id);
        Assert.That(factura.CAE, Is.Not.Null); // AFIP

        var asientoVenta = await _asientoService.GetAsientoByDocumentoAsync("FACTURA", factura.Id);
        Assert.That(asientoVenta, Is.Not.Null);
        Assert.That(asientoVenta.Debe, Is.EqualTo(asientoVenta.Haber));

        // 4. Descontar stock
        var stockActual = await _stockService.GetStockDisponibleAsync(producto.Id);
        Assert.That(stockActual, Is.EqualTo(stockInicial - 10));

        // 5. Cobrar (genera asiento de cobranza)
        var cobranza = await CobrarFacturaAsync(factura.Id);

        var asientoCobranza = await _asientoService.GetAsientoByDocumentoAsync("COBRANZA", cobranza.Id);
        Assert.That(asientoCobranza, Is.Not.Null);
        Assert.That(asientoCobranza.Debe, Is.EqualTo(asientoCobranza.Haber));

        // 6. Verificar saldo cliente = 0
        var saldo = await _clienteService.GetSaldoAsync(cliente.Id);
        Assert.That(saldo, Is.EqualTo(0));
    }
}
```

**3. Regression Tests (Contabilidad y Fiscales)**

```csharp
[TestFixture]
[Category("Regression")]
public class CalculosContablesRegressionTests
{
    // Dataset con casos reales de producción
    private static IEnumerable<TestCaseData> CasosRealesFacturacion()
    {
        yield return new TestCaseData(100m, TipoFactura.A, CondicionIVA.ResponsableInscripto)
            .Returns(new { Subtotal = 100m, IVA = 21m, Total = 121m });

        yield return new TestCaseData(100m, TipoFactura.B, CondicionIVA.ConsumidorFinal)
            .Returns(new { Subtotal = 82.64m, IVA = 17.36m, Total = 100m });

        // ... más casos
    }

    [Test, TestCaseSource(nameof(CasosRealesFacturacion))]
    public object CalcularFactura_ConDiferentesEscenarios_DebeCalcularCorrectamente(
        decimal monto, TipoFactura tipo, CondicionIVA condicion)
    {
        // Test de cálculos que NO DEBEN cambiar nunca
        var resultado = _facturacionService.CalcularFactura(monto, tipo, condicion);
        return new {
            Subtotal = resultado.Subtotal,
            IVA = resultado.IVA,
            Total = resultado.Total
        };
    }
}
```

**4. Performance Tests**

```csharp
[TestFixture]
[Category("Performance")]
public class PerformanceTests
{
    [Test]
    public async Task CierreContable_Con10000Asientos_DebeCompletarEn30Segundos()
    {
        // Arrange
        await GenerarAsientosDeTestAsync(10000);

        // Act
        var stopwatch = Stopwatch.StartNew();
        await _cierreService.EjecutarCierreMensualAsync(2025, 10);
        stopwatch.Stop();

        // Assert
        Assert.That(stopwatch.Elapsed.TotalSeconds, Is.LessThan(30));
    }

    [Test]
    public async Task BulkFacturacion_1000Facturas_DebeCompletarEn60Segundos()
    {
        // Test de procesamiento masivo
        var pedidos = await GenerarPedidosAsync(1000);

        var stopwatch = Stopwatch.StartNew();
        await _facturacionService.FacturarLoteAsync(pedidos.Select(p => p.Id).ToList());
        stopwatch.Stop();

        Assert.That(stopwatch.Elapsed.TotalSeconds, Is.LessThan(60));
    }
}
```

---

## 🔐 Security & Audit (Crítico para ERP)

### Auditoría Total

**1. BaseEntity con Auditoría**

```csharp
public abstract class BaseEntity
{
    public string Id { get; set; } = Guid.NewGuid().ToString();

    // Auditoría
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public string CreatedBy { get; set; } = string.Empty;
    public DateTime? UpdatedAt { get; set; }
    public string? UpdatedBy { get; set; }

    // Soft delete
    public bool IsDeleted { get; set; } = false;
    public DateTime? DeletedAt { get; set; }
    public string? DeletedBy { get; set; }
}
```

**2. AuditLog Entity**

```csharp
public class AuditLog
{
    public string Id { get; set; }
    public string EntityName { get; set; } // "Factura", "Pedido", etc.
    public string EntityId { get; set; }
    public string Action { get; set; } // "CREATE", "UPDATE", "DELETE"
    public string UserId { get; set; }
    public string UserName { get; set; }
    public DateTime Timestamp { get; set; }
    public string Changes { get; set; } // JSON con before/after
    public string IpAddress { get; set; }
    public string UserAgent { get; set; }
}
```

**3. Middleware de Auditoría**

```csharp
public class AuditMiddleware
{
    public async Task InvokeAsync(HttpContext context)
    {
        // Capturar request
        var originalBody = context.Response.Body;
        using var responseBody = new MemoryStream();
        context.Response.Body = responseBody;

        await _next(context);

        // Log de auditoría
        if (context.Request.Method != "GET")
        {
            await _auditService.LogAsync(new AuditLog
            {
                Action = context.Request.Method,
                Path = context.Request.Path,
                UserId = context.User.FindFirst(ClaimTypes.NameIdentifier)?.Value,
                Timestamp = DateTime.UtcNow,
                IpAddress = context.Connection.RemoteIpAddress?.ToString()
            });
        }

        // Restore response
        responseBody.Seek(0, SeekOrigin.Begin);
        await responseBody.CopyToAsync(originalBody);
    }
}
```

### RBAC (Role-Based Access Control)

**Roles definidos en especificación:**
1. Administrador (full access)
2. Operador de Depósito (stock, movimientos)
3. Comprador (OC, recepción, facturas proveedor)
4. Vendedor (cotizaciones, pedidos, facturación)
5. Tesorero (cobranzas, pagos, conciliación)
6. Contador (plan cuentas, asientos, cierres)
7. Auditor (read-only + exports)

**Implementación:**

```csharp
[Authorize(Roles = "Administrador,Contador")]
[HttpGet("asientos")]
public async Task<IActionResult> GetAsientos()
{
    // Solo Admin y Contador pueden ver asientos
}

[Authorize(Roles = "Administrador,Vendedor")]
[HttpPost("facturas")]
public async Task<IActionResult> CrearFactura([FromBody] FacturaDto dto)
{
    // Solo Admin y Vendedor pueden facturar
}

[Authorize(Roles = "Auditor")]
[HttpGet("reportes/audit-log")]
public async Task<IActionResult> GetAuditLog()
{
    // Auditor puede ver logs
}
```

### Inmutabilidad de Documentos Fiscales

```csharp
public class Factura : BaseEntity
{
    // ... campos

    public string? CAE { get; set; }
    public DateTime? CAEVencimiento { get; set; }
    public bool EstaFirmada => !string.IsNullOrEmpty(CAE);

    // Una vez firmada, NO SE PUEDE MODIFICAR
    public void Update(FacturaDto dto)
    {
        if (EstaFirmada)
            throw new InvalidOperationException("No se puede modificar una factura firmada con CAE");

        // ... actualizar
    }
}
```

---

## 📊 Definition of Done (ERP Específico)

### Para Cada User Story:

**Código:**
- [ ] Implementado según Clean Architecture
- [ ] SOLID principles aplicados
- [ ] NO código duplicado (crítico en ERP)
- [ ] Configuración por variables de entorno
- [ ] Auditoría implementada (CreatedBy, UpdatedAt, etc.)
- [ ] Code review aprobado
- [ ] 0 compiler warnings

**Testing:**
- [ ] Unit tests (>85% coverage, >95% si es contabilidad/fiscal)
- [ ] Integration tests para critical paths
- [ ] Regression tests si afecta cálculos contables/fiscales
- [ ] Performance test si afecta operaciones batch
- [ ] Tests pasando en CI/CD

**Contabilidad (si aplica):**
- [ ] Asiento contable automático implementado
- [ ] Asiento validado: Debe = Haber
- [ ] Plantilla de asiento documentada
- [ ] Tests de asiento (100% coverage)
- [ ] Revisión por contador (si disponible)

**Fiscal (si aplica):**
- [ ] Cálculos fiscales validados
- [ ] Integración AFIP probada (si aplica)
- [ ] Tipos de factura correctos (A/B/C/E)
- [ ] Percepciones/retenciones calculadas
- [ ] Tests de regresión fiscal

**Documentación:**
- [ ] XML comments completos
- [ ] API documentada en Swagger
- [ ] README actualizado si aplica
- [ ] ADR creado para decisiones importantes
- [ ] Reglas de negocio documentadas

**Performance:**
- [ ] Response time < 2s (P95)
- [ ] Queries optimizadas (EXPLAIN analizado)
- [ ] No N+1 queries
- [ ] Caching implementado donde corresponda

**Security:**
- [ ] Autorización RBAC correcta
- [ ] Input validation completa
- [ ] No SQL injection possible
- [ ] Secrets no expuestos

**Auditoría:**
- [ ] Todos los cambios logueados
- [ ] AuditLog poblado
- [ ] Trazabilidad completa
- [ ] Soft delete (no hard delete)

---

## ⚠️ Anti-Patterns Críticos a Evitar

### 🚫 NO HACER - Específico de ERP

**1. Código Duplicado por Canal/Sucursal**
```csharp
❌ FacturacionServiceMayorista.cs
❌ FacturacionServiceMinorista.cs
❌ FacturacionServiceEcommerce.cs

✅ FacturacionService.cs con configuración por canal
```

**2. Hard Delete de Documentos**
```csharp
❌ _context.Facturas.Remove(factura); // NUNCA!

✅ factura.IsDeleted = true;
   factura.DeletedAt = DateTime.UtcNow;
   factura.DeletedBy = userId;
```

**3. Asientos Contables Sin Validación**
```csharp
❌ var asiento = new Asiento { ... };
   _context.Asientos.Add(asiento); // Sin validar Debe = Haber

✅ var asiento = _asientoService.GenerarAsiento(evento);
   if (asiento.Debe != asiento.Haber)
       throw new InvalidOperationException("Asiento desbalanceado");
```

**4. Cálculos Fiscales Hardcodeados**
```csharp
❌ var iva = subtotal * 0.21; // Hardcoded

✅ var alicuota = await _impuestosService.GetAlicuotaIVAAsync(producto.CategoriaFiscal);
   var iva = subtotal * (alicuota / 100);
```

**5. Modificar Stock Directamente**
```csharp
❌ stock.Cantidad -= pedido.Cantidad; // Sin registro

✅ await _movimientoService.RegistrarEgresoAsync(new MovimientoDto
   {
       ProductoId = pedido.ProductoId,
       Cantidad = pedido.Cantidad,
       Motivo = "Venta",
       DocumentoOrigen = $"PEDIDO-{pedido.Numero}"
   });
```

**6. No Validar Límite de Crédito**
```csharp
❌ await FacturarAsync(pedido); // Sin validar

✅ var cliente = await _clienteService.GetByIdAsync(pedido.ClienteId);
   var saldo = await _clienteService.GetSaldoActualAsync(cliente.Id);
   if (saldo + pedido.Total > cliente.LimiteCredito)
       throw new BusinessException("Cliente excede límite de crédito");
```

**7. Asientos Sin Trazabilidad**
```csharp
❌ var asiento = new Asiento { Descripcion = "Venta" }; // No se sabe de qué

✅ var asiento = new Asiento
   {
       Descripcion = $"Venta Factura {factura.Numero}",
       DocumentoOrigen = "FACTURA",
       DocumentoOrigenId = factura.Id
   };
```

---

## 🚀 Scripts de Automatización

### dev-setup.ps1 (Windows)

```powershell
# ERP Backend - Setup Script
# Version: 1.0

Write-Host "🚀 ERP Backend - Setup Automatizado" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# 1. Verificar prerequisitos
Write-Host "`n📋 Verificando prerequisitos..." -ForegroundColor Cyan

# .NET 8
$dotnetVersion = dotnet --version
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ .NET 8 SDK no encontrado" -ForegroundColor Red
    Write-Host "   Descarga: https://dotnet.microsoft.com/download/dotnet/8.0" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ .NET SDK: $dotnetVersion" -ForegroundColor Green

# Docker
docker --version | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker no encontrado" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Docker instalado" -ForegroundColor Green

# Git
git --version | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Git no encontrado" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Git instalado" -ForegroundColor Green

# 2. Crear .env desde template
Write-Host "`n🔧 Configurando variables de entorno..." -ForegroundColor Cyan
if (-not (Test-Path ".env")) {
    Copy-Item ".env.template" ".env"
    Write-Host "✅ Archivo .env creado desde template" -ForegroundColor Green
    Write-Host "⚠️  Edita .env con tus valores antes de continuar" -ForegroundColor Yellow
    notepad .env
    $continue = Read-Host "Presiona Enter cuando hayas editado .env"
} else {
    Write-Host "✅ Archivo .env ya existe" -ForegroundColor Green
}

# 3. Iniciar servicios Docker
Write-Host "`n🐳 Iniciando servicios Docker..." -ForegroundColor Cyan
docker-compose up -d
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al iniciar Docker services" -ForegroundColor Red
    exit 1
}
Write-Host "✅ MySQL y Redis iniciados" -ForegroundColor Green

# Esperar a que MySQL esté listo
Write-Host "`n⏳ Esperando a que MySQL esté listo (30 segundos)..." -ForegroundColor Cyan
Start-Sleep -Seconds 30

# 4. Restaurar paquetes
Write-Host "`n📦 Restaurando paquetes NuGet..." -ForegroundColor Cyan
dotnet restore
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al restaurar paquetes" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Paquetes restaurados" -ForegroundColor Green

# 5. Build
Write-Host "`n🔨 Compilando solución..." -ForegroundColor Cyan
dotnet build --configuration Debug
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al compilar" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Compilación exitosa" -ForegroundColor Green

# 6. Migraciones
Write-Host "`n🗄️  Ejecutando migraciones de base de datos..." -ForegroundColor Cyan
dotnet ef database update --project src/ERP.Infrastructure --startup-project src/ERP.Api
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al ejecutar migraciones" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Base de datos actualizada" -ForegroundColor Green

# 7. Seed (opcional)
Write-Host "`n🌱 ¿Quieres cargar datos de prueba? (y/n)" -ForegroundColor Cyan
$seed = Read-Host
if ($seed -eq "y") {
    .\scripts\seed-database.ps1
}

# 8. Resumen
Write-Host "`n✅ ¡Setup completado!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host "`nPróximos pasos:" -ForegroundColor Cyan
Write-Host "1. Ejecuta: dotnet run --project src/ERP.Api" -ForegroundColor White
Write-Host "2. Abre: http://localhost:5000/swagger" -ForegroundColor White
Write-Host "3. Health check: http://localhost:5000/health" -ForegroundColor White
Write-Host "`n¡Feliz codificación! 🚀" -ForegroundColor Green
```

### seed-database.ps1

```powershell
# ERP Backend - Database Seeding
Write-Host "🌱 Cargando datos de prueba..." -ForegroundColor Green

# Ejecutar seeder desde el proyecto
dotnet run --project src/ERP.Api -- --seed

Write-Host "`n✅ Datos cargados:" -ForegroundColor Green
Write-Host "   - 4 usuarios (admin@erp.com, vendedor@erp.com, contador@erp.com, auditor@erp.com)" -ForegroundColor White
Write-Host "   - 50 productos" -ForegroundColor White
Write-Host "   - 20 clientes" -ForegroundColor White
Write-Host "   - 10 proveedores" -ForegroundColor White
Write-Host "   - 5 pedidos de ejemplo" -ForegroundColor White
Write-Host "   - Plan de cuentas básico (100+ cuentas)" -ForegroundColor White
Write-Host "`n🔐 Credenciales:" -ForegroundColor Cyan
Write-Host "   Admin: admin@erp.com / Admin123!" -ForegroundColor Yellow
Write-Host "   Vendedor: vendedor@erp.com / Vendedor123!" -ForegroundColor Yellow
```

---

## 📈 Métricas de Éxito

### Phase 0 (Semana 1-2)
- [ ] Setup completo funcional
- [ ] CI/CD ejecutando
- [ ] Base de datos con schema
- [ ] Autenticación funcionando
- [ ] 0 errores de compilación

### Phase 1 (Semana 3-5)
- [ ] Stock module completo
- [ ] Compras module completo
- [ ] Asientos de compras funcionando
- [ ] Tests >80% coverage
- [ ] Performance <2s

### Phase 2 (Semana 6-8)
- [ ] Ventas module completo
- [ ] AFIP facturación funcionando
- [ ] Logística completa
- [ ] Asientos de ventas funcionando
- [ ] E2E test de venta completa

### Phase 3 (Semana 9-10)
- [ ] Contabilidad completa
- [ ] Motor de asientos automáticos perfecto
- [ ] Tesorería completa
- [ ] Cierre contable <30 min
- [ ] Tests contabilidad >95%

### Phase 4 (Semana 11-12)
- [ ] Integraciones e-commerce funcionando
- [ ] Reportes completos
- [ ] Dashboards por rol
- [ ] Performance targets met

### Phase 5 (Semana 13-14)
- [ ] Production ready
- [ ] Security audit passed
- [ ] Documentation completa
- [ ] UAT aprobado
- [ ] Deployed to production

---

## 🎓 Lecciones Aprendidas Aplicadas

### Del Proyecto Python/FastAPI:
✅ **NO DUPLICACIÓN es sagrado** - aplicado a canales/sucursales
✅ **Configuración única con feature toggles** - aplicado a ERP
✅ **Un main.py configurable** - aplicado a un Program.cs configurable

### Del Proyecto .NET YouTube RAG:
✅ **Clean Architecture desde día 1** - estructura completa desde inicio
✅ **DevOps automatizado temprano** - scripts de setup desde semana 1
✅ **Testing exhaustivo** - >85% coverage, >95% en contabilidad
✅ **99.3% test coverage es posible** - objetivo similar para ERP
✅ **Documentación exhaustiva** - 237k palabras de documentación como referencia
✅ **5-minute onboarding** - scripts automatizados

### Específico de ERP:
✅ **Auditoría total desde día 1** - no negociable
✅ **Inmutabilidad de documentos fiscales** - crítico
✅ **Testing de contabilidad al 100%** - cero tolerancia a errores
✅ **Asientos automáticos testeados exhaustivamente** - core del sistema

---

## 📞 Siguiente Paso

**AHORA:**
1. ✅ Revisar y aprobar esta metodología
2. ✅ Ajustar si es necesario
3. ✅ Crear repositorio Git
4. ✅ Ejecutar Fase 0 - Día 1

**ENTONCES:**
- Usar agentes especializados de Claude Code:
  - `software-architect` → Diseño de arquitectura
  - `dotnet-backend-developer` → Implementación
  - `database-expert` → Diseño de base de datos
  - `test-engineer` → Testing automatizado
  - `code-reviewer` → Code review
  - `devops-engineer` → CI/CD, Docker, scripts

---

**FIN DE METODOLOGÍA**

**Estado:** READY TO START
**Próximo paso:** Aprobación y kick-off de Fase 0
**Autor:** Claude Code
**Basado en:** 237k+ palabras de documentación + Especificación ERP v0.1
**Complejidad estimada:** ALTA
**Duración estimada:** 14 semanas (3.5 meses)
**Resultado esperado:** ERP production-ready con 85%+ test coverage

---

**"En ERP, un error contable puede costar millones. Testing no es opcional."**
