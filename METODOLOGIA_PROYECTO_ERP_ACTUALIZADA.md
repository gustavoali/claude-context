# Metodología de Implementación - Sistema ERP Multinacional
## Stock / Comercial / Contable | Multi-Moneda | Multi-País

**Versión:** 2.0 (Actualizada con scope multinacional)
**Fecha:** 2025-10-10
**Proyecto:** Sistema de Gestión Integral (ERP) - Alcance América
**Basado en:**
- Aprendizajes de YouTube RAG .NET (99.3% test coverage)
- Especificación de Negocio v0.1 (base Argentina)
- Especificación de Negocio v0.2 (multipaís - toda América)

**Stack Tecnológico:** .NET 8 + Clean Architecture + Multi-Tenant + Multi-Currency

---

## ⚠️ CAMBIO CRÍTICO DE ALCANCE

### De v0.1 a v0.2:
```
v0.1 (Base):
- Alcance: Argentina únicamente
- Moneda: ARS (Peso argentino)
- Fiscal: AFIP solamente
- Complejidad: ALTA

v0.2 (Multinacional): ← ESTA VERSIÓN
- Alcance: Toda América (LATAM + Norteamérica + Caribe)
- Monedas: Múltiples monedas con conversión automática
- Fiscal: 8+ regulaciones diferentes (AFIP, SAT, SII, DIAN, SUNAT, DGI, etc.)
- Complejidad: MUY ALTA
- Duración estimada: 20-24 semanas (vs 14 semanas original)
```

**Implicaciones:**
- 📈 +70% de complejidad adicional
- 🌎 Localización fiscal para 8+ países
- 💱 Motor de multi-moneda y consolidación
- 🏢 Multi-sucursal, multi-depósito, multi-país
- 📊 Consolidación contable multinacional (IFRS)
- 🌐 Multi-idioma (ES, PT, EN)

---

## 📋 Resumen Ejecutivo del Proyecto

### Alcance Multinacional
Sistema ERP integral con alcance **América completa**:

**Módulos Core:**
- **Stock/Inventario:** Multi-país, multi-depósito, lotes/series, trazabilidad completa
- **Compras:** OC internacionales y locales, control de costos en moneda origen/destino
- **Ventas:** Multi-canal (mayorista, minorista, POS, e-commerce, marketplace)
- **Logística:** Envíos nacionales e internacionales, costos por país
- **Tesorería:** Multi-moneda, caja/bancos por país
- **Contabilidad:** Asientos automáticos, plan de cuentas por país, consolidación multinacional
- **Impuestos:** Localización fiscal adaptable por país
- **Integraciones:** e-commerce, fiscales, bancarias por país

**Países en Scope (Roadmap Regional):**
- **Fase 1 MVP:** Argentina, México, Chile, Perú
- **Fase 2:** Colombia, Uruguay, Centroamérica
- **Fase 3:** Caribe, EE.UU., Canadá
- **Fase 4:** Consolidación multinacional IFRS

**Multi-Moneda:**
- Moneda local por país
- Moneda matriz: USD (consolidación)
- Tipos de cambio diarios automáticos
- Ajustes por diferencias de cambio
- Reexpresión contable mensual

**Multi-Idioma:**
- Español (primario)
- Português (Brasil)
- English (EE.UU./Canadá)

### Complejidad Elevada
- **MUY ALTA:** 7 roles, multi-sucursal, multi-país, multi-moneda
- **Requisitos estrictos:** 99.5% disponibilidad, <2s response time
- **Regulatorio:** Cumplimiento fiscal en 8+ jurisdicciones
- **Consolidación:** IFRS + normas locales por país

### Riesgos Identificados (Ampliados)
- Complejidad contable y fiscal **multiplicada por país**
- Múltiples integraciones externas **por jurisdicción**
- Tipos de cambio y diferencias de cambio
- Consolidación multinacional (cierre <24h)
- Transferencias inter-país (asientos intercompany)
- Compliance fiscal multi-jurisdicción
- Migración de datos legacy multi-país
- Sincronización de datos entre países
- Reportes consolidados en tiempo real

---

## 🌎 Localización Fiscal por País

### Países Soportados y Regulaciones

| País | Entidad Fiscal | Documentos | Impuestos | Complejidad |
|------|---------------|------------|-----------|-------------|
| **Argentina** | AFIP | Factura A/B/C/E, CAE | IVA, IIBB, Percepciones, Retenciones | Alta |
| **México** | SAT | CFDI 4.0 | IVA, ISR | Alta |
| **Chile** | SII | Factura Electrónica | IVA, RUT | Media |
| **Perú** | SUNAT | Factura Electrónica | IGV, Detracciones, Percepciones | Alta |
| **Colombia** | DIAN | Documento Soporte, FE | IVA, Retenciones | Media |
| **Uruguay** | DGI | e-Factura | IVA, Retenciones | Media |
| **EE.UU./Canadá** | IRS/CRA | Invoice | Sales Tax/Provincial Tax | Media |
| **Caribe/Centroamérica** | Varios | Genérica | IVA/ITBIS local | Baja-Media |

### Estrategia de Localización

**Activación modular por país:**
```csharp
// Configuración por país en appsettings
"Localization": {
  "EnabledCountries": ["AR", "MX", "CL", "PE"],
  "DefaultCountry": "AR",
  "TaxEngines": {
    "AR": "AFIPTaxEngine",
    "MX": "SATTaxEngine",
    "CL": "SIITaxEngine",
    "PE": "SUNATTaxEngine"
  }
}
```

**Plantillas de asientos por país:**
- Cada país tiene su propio plan de cuentas
- Mapeo automático a plan de cuentas consolidado (USD)
- Asientos intercompany para transferencias entre países

---

## 🎯 Principios Fundamentales Aplicados (Ampliados)

### 1. NO DUPLICACIÓN (CRÍTICO para ERP Multinacional)
```
🚫 NO crear múltiples versiones por país (ERPArgentina, ERPMexico, etc.)
🚫 NO crear múltiples versiones por moneda
🚫 NO crear múltiples versiones por idioma
✅ UN sistema configurable con localización por país
✅ UN motor de facturación con adaptadores por jurisdicción
✅ UN motor de asientos contables con plantillas por país
✅ UN motor de impuestos con reglas parametrizables
```

**Rationale:** Con 8+ países, la duplicación de código sería CATASTRÓFICA.
Un bug en una versión requeriría fixes en 8+ lugares. INACEPTABLE.

### 2. Clean Architecture Estricta + Multi-Tenant Pattern
```
Domain Layer:
- Entidades: Producto, Cliente, Proveedor, Pedido, Factura, Asiento
- Nuevas: Pais, Moneda, TipoCambio, Sucursal, Region, LocalizacionFiscal
- Reglas de negocio: validaciones contables, cálculos fiscales POR PAÍS
- Interfaces: IStockService, IFacturacionService, IContabilidadService
- Nuevas: ITaxEngine, ICurrencyService, ILocalizationService

Application Layer:
- DTOs con soporte multi-idioma
- Servicios con tenant context (país actual)
- Validadores con reglas por país
- Mapeos con conversión de moneda

Infrastructure Layer:
- DbContext con 40+ entidades (10 nuevas para multi-país)
- Repositorios con filtros por país/sucursal
- Tax engines por jurisdicción (factory pattern)
- Currency conversion service
- Background jobs con awareness de zona horaria

API Layer:
- Controllers con tenant detection
- Multi-idioma en responses (Accept-Language header)
- Swagger con documentación por país
- Health checks por país
```

### 3. Testing No Negociable para ERP Multinacional
```
✅ Unit tests: >90% coverage
✅ Integration tests POR PAÍS: Cada tax engine testeado independientemente
✅ Currency conversion tests: Todos los pares de monedas
✅ Regression tests: Cálculos fiscales inmutables POR PAÍS
✅ Performance tests: Consolidación de 1000+ facturas multi-moneda
✅ E2E tests: Flujo completo por país (AR, MX, CL, PE mínimo)
```

**Rationale:** Errores en conversión de moneda o cálculos fiscales por país = MILLONES de pérdidas.

### 4. Auditoría Total + Trazabilidad Multi-País
```
✅ Cada entidad con: CreatedAt, CreatedBy, UpdatedAt, UpdatedBy, CountryCode
✅ AuditLog con país de origen
✅ Soft deletes con trazabilidad
✅ Versionado de documentos fiscales (inmutables)
✅ Trazabilidad de conversión de monedas (tipo de cambio usado)
✅ Log de transferencias inter-país (intercompany tracking)
```

### 5. DevOps Automatizado + Environment Consistency
```
✅ CI/CD con GitHub Actions
✅ Testing automatizado POR PAÍS
✅ Deployment por región (AR, MX, LATAM, US)
✅ Database migrations con rollback
✅ Backup automático por región
✅ Monitoring por país
```

---

## 🏗️ Arquitectura Técnica Multinacional

### Stack Tecnológico (Actualizado)

**Backend:**
- **.NET 8** - Framework principal
- **ASP.NET Core Web API** - REST API
- **Entity Framework Core 8** - ORM
- **MySQL 8** - Base de datos principal (con particiones por país)
- **Redis** - Caching, sessions, tipos de cambio
- **Hangfire** - Background jobs con awareness de timezone
- **FluentValidation** - Validaciones con reglas por país
- **AutoMapper** - Mappings con conversión de moneda
- **Serilog** - Logging estructurado con país/moneda
- **Polly** - Resilience para APIs externas de tipos de cambio

**Nuevos Componentes:**
- **Currency Exchange Service** - Tipos de cambio automáticos
- **Tax Engine Factory** - Factory para tax engines por país
- **Localization Service** - Multi-idioma y formatos por país
- **Consolidation Engine** - Consolidación contable multinacional
- **Intercompany Service** - Asientos entre países

**Integraciones Fiscales (8+ países):**
- **AFIP SDK** (Argentina) - Factura electrónica
- **SAT SDK** (México) - CFDI 4.0
- **SII SDK** (Chile) - Factura electrónica
- **SUNAT SDK** (Perú) - Factura electrónica
- **DIAN SDK** (Colombia) - Documento soporte
- **DGI SDK** (Uruguay) - e-Factura
- **Avalara** (EE.UU./Canadá) - Sales tax (opcional)

**Integraciones de Tipos de Cambio:**
- **Banco Central de cada país** (primario)
- **OpenExchangeRates** (fallback)
- **XE.com API** (fallback)

**DevOps:**
- **Docker Compose** - Local development
- **GitHub Actions** - CI/CD con matrix por país
- **Azure/AWS** - Multi-region deployment

---

## 🗂️ Estructura del Proyecto (Ampliada)

### Nuevas Entidades de Dominio

```
ERP.Domain/
├── Entities/
│   ├── Localization/ (NUEVO)
│   │   ├── Pais.cs
│   │   ├── Region.cs
│   │   ├── Moneda.cs
│   │   ├── TipoCambio.cs
│   │   ├── LocalizacionFiscal.cs
│   │   └── PlantillaAsiento.cs
│   ├── Stock/
│   │   ├── Sucursal.cs (ACTUALIZADO - con Pais)
│   │   ├── Deposito.cs (ACTUALIZADO - con Sucursal/Pais)
│   │   └── ... existentes
│   ├── Ventas/
│   │   ├── Factura.cs (ACTUALIZADO - con Moneda, TipoCambio)
│   │   └── ... existentes
│   ├── Compras/
│   │   ├── OrdenCompra.cs (ACTUALIZADO - con Moneda)
│   │   └── ... existentes
│   ├── Contabilidad/
│   │   ├── AsientoIntercompany.cs (NUEVO)
│   │   ├── ConsolidacionContable.cs (NUEVO)
│   │   └── ... existentes
│   └── ... otros
│
├── Enums/
│   ├── CodigoPais.cs (NUEVO - ISO 3166)
│   ├── CodigoMoneda.cs (NUEVO - ISO 4217)
│   └── ... existentes
│
└── Interfaces/
    ├── ITaxEngine.cs (NUEVO - interfaz para tax engines)
    ├── ICurrencyService.cs (NUEVO)
    ├── ILocalizationService.cs (NUEVO)
    ├── IConsolidationEngine.cs (NUEVO)
    └── ... existentes
```

### Nuevos Servicios de Aplicación

```
ERP.Application/
├── Services/
│   ├── Currency/ (NUEVO)
│   │   ├── CurrencyConversionService.cs
│   │   ├── ExchangeRateService.cs
│   │   └── RevaluationService.cs (reexpresión contable)
│   ├── Taxation/ (NUEVO)
│   │   ├── TaxEngineFactory.cs
│   │   ├── ARTaxEngine.cs (Argentina - AFIP)
│   │   ├── MXTaxEngine.cs (México - SAT)
│   │   ├── CLTaxEngine.cs (Chile - SII)
│   │   ├── PETaxEngine.cs (Perú - SUNAT)
│   │   ├── COTaxEngine.cs (Colombia - DIAN)
│   │   ├── UYTaxEngine.cs (Uruguay - DGI)
│   │   └── USTaxEngine.cs (USA - generic)
│   ├── Consolidation/ (NUEVO)
│   │   ├── ConsolidationService.cs
│   │   ├── IntercompanyService.cs
│   │   └── IFRSReportingService.cs
│   ├── Localization/ (NUEVO)
│   │   ├── LocalizationService.cs
│   │   ├── CultureService.cs
│   │   └── DateTimeService.cs (timezone por país)
│   └── ... existentes
```

---

## 📅 Plan de Implementación Multinacional (20-24 semanas)

### **FASE 0: Setup + Foundation + Multi-País Base (Semana 1-3)**

#### Objetivos
- Setup completo del proyecto
- CI/CD funcional con testing por país
- Estructura de Clean Architecture + Multi-Tenant
- Base de datos con soporte multi-país/multi-moneda
- Autenticación y autorización multi-tenant

#### Tareas (Sprint 0 - EXTENDIDO)

**Día 1-3: Setup Inicial Multinacional**
- [ ] Crear repositorio Git con estructura multinacional
- [ ] Configurar proyectos .NET con localización
- [ ] Setup Docker Compose (MySQL, Redis)
- [ ] Configurar CI/CD con matrix por país
- [ ] Crear scripts de setup automatizado
- [ ] Documentación base (README multiidioma)

**Día 4-7: Domain Layer Multinacional**
- [ ] Diseñar DER completo (40+ entidades, +10 nuevas)
- [ ] Implementar entidades de localización (Pais, Moneda, TipoCambio)
- [ ] Implementar BaseEntity con CountryCode
- [ ] Crear enumeraciones multi-país (CodigoPais, CodigoMoneda)
- [ ] Definir interfaces multi-tenant

**Día 8-12: Infrastructure Layer Multinacional**
- [ ] Configurar ERPDbContext con tenant context
- [ ] Crear EntityTypeConfiguration para nuevas entidades
- [ ] Implementar repositorios con filtros por país
- [ ] Configurar Unit of Work con tenant awareness
- [ ] Primera migración con schema multinacional
- [ ] Seed de datos maestros (países, monedas, tipos de cambio)

**Día 13-15: API Base Multinacional**
- [ ] Configurar Program.cs con DI multi-tenant
- [ ] Implementar tenant detection middleware
- [ ] Implementar autenticación JWT multi-tenant
- [ ] Implementar autorización RBAC con scope por país
- [ ] Configurar Swagger con documentación multi-país
- [ ] Implementar health checks por país
- [ ] Middleware de localización (idioma, cultura)

**Entregables Fase 0:**
- ✅ Proyecto compilando con arquitectura multinacional
- ✅ CI/CD ejecutando tests para AR, MX, CL, PE
- ✅ Base de datos con schema multi-país/multi-moneda
- ✅ Autenticación multi-tenant funcionando
- ✅ Setup automatizado (<10 min)
- ✅ Documentación actualizada con scope multinacional

---

### **FASE 1: MVP - Multi-Moneda + Stock + Compras (Semana 4-7)**

#### Epic 0: Multi-Moneda (NUEVO - CRÍTICO)

**US-000: Gestión de Monedas**
- Story Points: 8
- AC: CRUD de monedas, moneda base, monedas activas por país
- Implementación:
  - MonedaController con CRUD
  - MonedaService con validaciones
  - Tests: validaciones ISO 4217

**US-001: Tipos de Cambio Automáticos**
- Story Points: 13
- AC: Obtención automática de tipos de cambio, múltiples fuentes, fallback
- Implementación:
  - ExchangeRateService con múltiples providers
  - Background job para actualización diaria
  - Cache en Redis (1 día)
  - Tests: todos los pares de monedas activas

**US-002: Conversión de Moneda**
- Story Points: 8
- AC: Conversión entre cualquier par de monedas, trazabilidad del tipo de cambio usado
- Implementación:
  - CurrencyConversionService
  - Registro de conversiones en transacciones
  - Tests: precisión de conversiones (6 decimales)

**US-003: Ajustes por Diferencias de Cambio**
- Story Points: 13
- AC: Cálculo automático de diferencias de cambio, asientos automáticos
- Implementación:
  - RevaluationService
  - Generación de asientos de ajuste
  - Tests: cálculos correctos de diferencias

#### Epic 1: Gestión de Inventario Multinacional (ACTUALIZADO)

**US-004: Estructura Regional (País → Región → Sucursal → Depósito)**
- Story Points: 13
- AC: Jerarquía completa, navegación, filtros
- Implementación:
  - PaisService, RegionService, SucursalService, DepositoService
  - Queries optimizadas con jerarquía
  - Tests: integridad referencial

**US-005: Alta de Catálogo Multi-País**
- Story Points: 8
- AC: Productos con precio por país/moneda, atributos localizados
- Implementación:
  - ProductoService con precios multi-moneda
  - ProductoPrecio entity (por país/moneda)
  - Tests: conversión de precios

**US-006: Stock por Depósito (Multi-País)**
- Story Points: 13
- AC: Stock por depósito/país, consolidación, transferencias inter-país
- Implementación:
  - StockService con agregación por país
  - Tests: transferencias inter-país

**US-007: Transferencias Inter-Sucursal con Costo**
- Story Points: 13
- AC: Transferencias entre sucursales/países, costos de traslado, asiento intercompany
- Implementación:
  - TransferenciaIntercompanyService
  - Generación automática de asientos intercompany
  - Tests: asientos complejos inter-país

#### Epic 2: Compras Multinacionales (ACTUALIZADO)

**US-008: OC con Multi-Moneda**
- Story Points: 13
- AC: OC en moneda local o extranjera, conversión automática
- Implementación:
  - OrdenCompraService con multi-moneda
  - Conversión a moneda contable
  - Tests: conversiones correctas

**US-009: Recepción con Control de Moneda**
- Story Points: 13
- AC: Validación contra OC en moneda original, diferencias de cambio
- Implementación:
  - RecepcionService con validación de moneda
  - Cálculo de diferencias de cambio
  - Tests: diferencias de cambio

**US-010: Facturas de Proveedor Multi-Moneda**
- Story Points: 13
- AC: Facturas en moneda original, conversión, retenciones por país
- Implementación:
  - FacturaProveedorService multi-moneda
  - Tax engine por país del proveedor
  - Tests: cálculos fiscales por país

**Entregables Fase 1:**
- ✅ Motor multi-moneda funcionando perfectamente
- ✅ Stock multi-país completo
- ✅ Compras multi-moneda completas
- ✅ Tipos de cambio automáticos
- ✅ Tests >85% coverage
- ✅ Performance: conversiones <100ms

---

### **FASE 2: Ventas Multi-País + Tax Engines (Semana 8-12)**

#### Epic 3: Tax Engines por País (NUEVO - CRÍTICO)

**US-011: Tax Engine Factory**
- Story Points: 8
- AC: Factory pattern para tax engines, activación por país
- Implementación:
  - ITaxEngine interface
  - TaxEngineFactory con registro de engines
  - Tests: factory pattern

**US-012: Argentina Tax Engine (AFIP)**
- Story Points: 21
- AC: Facturas A/B/C/E, CAE, IVA, IIBB, percepciones, retenciones
- Implementación:
  - ARTaxEngine con integración AFIP
  - AFIP SDK completo
  - Tests: TODOS los tipos de factura (100% coverage)

**US-013: México Tax Engine (SAT)**
- Story Points: 21
- AC: CFDI 4.0, timbrado, IVA, ISR
- Implementación:
  - MXTaxEngine con integración SAT
  - CFDI generation
  - Tests: validación SAT

**US-014: Chile Tax Engine (SII)**
- Story Points: 13
- AC: Factura electrónica, IVA, RUT
- Implementación:
  - CLTaxEngine con integración SII
  - Tests: validación SII

**US-015: Perú Tax Engine (SUNAT)**
- Story Points: 13
- AC: Factura electrónica, IGV, detracciones, percepciones
- Implementación:
  - PETaxEngine con integración SUNAT
  - Tests: cálculos SUNAT

#### Epic 4: Ventas Multi-País (ACTUALIZADO)

**US-016: Facturación Multi-País**
- Story Points: 21
- AC: Facturación según regulación del país de la sucursal
- Implementación:
  - FacturacionService con tax engine selection
  - Conversión de moneda en factura
  - PDF localizado por país
  - Tests: facturación en AR, MX, CL, PE

**US-017: Listas de Precios Multi-Moneda**
- Story Points: 13
- AC: Precios por país/moneda, conversión automática, promociones localizadas
- Implementación:
  - ListaPrecioService multi-moneda
  - Conversión dinámica de precios
  - Tests: conversiones correctas

**US-018: Cobranzas Multi-Moneda**
- Story Points: 13
- AC: Cobros en moneda local, conversión, diferencias de cambio
- Implementación:
  - CobranzaService multi-moneda
  - Asientos de diferencia de cambio
  - Tests: diferencias de cambio

**Entregables Fase 2:**
- ✅ Tax engines para AR, MX, CL, PE funcionando
- ✅ Facturación multi-país completa
- ✅ Ventas multi-moneda completas
- ✅ Tests >90% coverage (tax engines 100%)
- ✅ E2E test por país (AR, MX, CL, PE)
- ✅ Performance: facturación <3s (incluyendo timbrado)

---

### **FASE 3: Contabilidad Multinacional + Consolidación (Semana 13-16)**

#### Epic 5: Contabilidad Multi-País (ACTUALIZADO)

**US-019: Plan de Cuentas Multi-País**
- Story Points: 13
- AC: Plan de cuentas por país, mapeo a plan consolidado
- Implementación:
  - PlanCuentasService con mapeo multinacional
  - Tabla de mapeo país → cuentas consolidadas
  - Tests: mapeos correctos

**US-020: Motor de Asientos Multi-Moneda**
- Story Points: 21
- AC: Asientos en moneda local, conversión a USD, plantillas por país
- Implementación:
  - AsientoAutomaticoService multi-moneda
  - Conversión automática a USD
  - Plantillas por país
  - Tests: TODOS los asientos por país (100% coverage)

**US-021: Asientos Intercompany**
- Story Points: 13
- AC: Asientos automáticos para transferencias entre países
- Implementación:
  - IntercompanyService
  - Generación de asientos cruzados
  - Eliminaciones en consolidación
  - Tests: asientos intercompany correctos

**US-022: Reexpresión Contable Mensual**
- Story Points: 13
- AC: Reexpresión mensual a USD de todos los balances
- Implementación:
  - RevaluationService
  - Background job mensual
  - Generación de asientos de ajuste
  - Tests: reexpresión correcta

#### Epic 6: Consolidación Multinacional (NUEVO)

**US-023: Consolidación de Balances**
- Story Points: 21
- AC: Consolidación de balances de todos los países en USD
- Implementación:
  - ConsolidationService
  - Conversión de balances a USD
  - Eliminaciones intercompany
  - Tests: balances consolidados correctos

**US-024: Reporting IFRS**
- Story Points: 13
- AC: Estados contables consolidados según IFRS
- Implementación:
  - IFRSReportingService
  - Generación de P&L, Balance consolidados
  - Export a Excel/PDF
  - Tests: reportes IFRS

**US-025: Cierre Contable Multi-País**
- Story Points: 13
- AC: Cierre contable por país, consolidación global <24h
- Implementación:
  - CierreContableService multi-país
  - Parallelización por país
  - Consolidación final
  - Tests: cierre completo <24h

**Entregables Fase 3:**
- ✅ Contabilidad multi-país completa
- ✅ Asientos intercompany funcionando
- ✅ Consolidación multinacional operativa
- ✅ Reporting IFRS completo
- ✅ Cierre contable <24h para 4 países
- ✅ Tests >95% coverage (contabilidad 100%)

---

### **FASE 4: Localización Adicional + Reportes (Semana 17-20)**

#### Epic 7: Localización Colombia, Uruguay, Centroamérica

**US-026: Colombia Tax Engine (DIAN)**
- Story Points: 13
- AC: Documento soporte, IVA, retenciones
- Implementación: Similar a otros tax engines

**US-027: Uruguay Tax Engine (DGI)**
- Story Points: 13
- AC: e-Factura, IVA, retenciones
- Implementación: Similar

**US-028: Tax Engine Genérico (Centroamérica/Caribe)**
- Story Points: 8
- AC: Motor configurable para países con regulación simple
- Implementación: Tax engine parametrizable

#### Epic 8: Reportes Multinacionales

**US-029: Reportes Operativos Multi-País**
- Story Points: 13
- AC: Reportes de stock, ventas, compras por país y consolidados
- Implementación:
  - ReportesService con filtros por país
  - Conversión automática a USD
  - Tests: reportes correctos

**US-030: Dashboards Regionales**
- Story Points: 13
- AC: Dashboards ejecutivos con KPIs por país y consolidados
- Implementación:
  - Dashboards con visualizaciones
  - KPIs por país
  - Comparativas

**Entregables Fase 4:**
- ✅ Tax engines para CO, UY, genérico
- ✅ Reportes multinacionales completos
- ✅ Dashboards regionales
- ✅ 7 países operativos

---

### **FASE 5: Quality, Performance & Production (Semana 21-24)**

#### Objetivos (AMPLIADOS)
- Testing exhaustivo por país
- Performance optimization global
- Security hardening multi-país
- Multi-idioma (ES, PT, EN)
- Documentation completa
- Production deployment multi-región

#### Tareas Específicas Multinacionales

**Testing Multi-País:**
- [ ] E2E tests para cada país (AR, MX, CL, PE, CO, UY)
- [ ] Currency conversion tests (todos los pares)
- [ ] Consolidation tests (>1000 transacciones multi-país)
- [ ] Performance tests multi-región
- [ ] Security testing multi-tenant

**Multi-Idioma:**
- [ ] Localización ES (completo)
- [ ] Localización PT-BR (brasileño)
- [ ] Localización EN-US (inglés)
- [ ] Tests de localización

**Performance Multinacional:**
- [ ] Optimización de queries con país/moneda
- [ ] Caching de tipos de cambio (Redis)
- [ ] Particionamiento de base de datos por región
- [ ] CDN multi-región para assets
- [ ] Índices compuestos (país + moneda + fecha)

**Production Multi-Región:**
- [ ] Deployment en AR (Argentina)
- [ ] Deployment en MX (México)
- [ ] Deployment en LATAM (consolidado)
- [ ] Deployment en US (EE.UU./consolidación)
- [ ] Disaster recovery multi-región

**Entregables Fase 5:**
- ✅ Sistema production-ready multinacional
- ✅ Tests >90% coverage global
- ✅ Performance: consolidación de 4 países <1h
- ✅ Security audit multi-país passed
- ✅ Multi-idioma funcionando (ES, PT, EN)
- ✅ Deployed en 4 regiones

---

## 🔧 Configuration Strategy Multi-País

### Variables de Entorno (.env) - AMPLIADO

```bash
# ========================================
# ENVIRONMENT
# ========================================
ENVIRONMENT=development|testing|production

# ========================================
# MULTI-PAÍS CONFIGURATION
# ========================================
DEFAULT_COUNTRY=AR  # AR, MX, CL, PE, CO, UY, US
ENABLED_COUNTRIES=AR,MX,CL,PE  # Lista de países activos
PRIMARY_REGION=LATAM  # LATAM, NORTHAMERICA, CARIBBEAN

# ========================================
# MULTI-MONEDA CONFIGURATION
# ========================================
BASE_CURRENCY=USD  # Moneda matriz para consolidación
DEFAULT_CURRENCY_BY_COUNTRY=AR:ARS,MX:MXN,CL:CLP,PE:PEN,CO:COP,UY:UYU,US:USD
EXCHANGE_RATE_PROVIDER=BancoCentral  # BancoCentral, OpenExchangeRates, XE
EXCHANGE_RATE_FALLBACK_PROVIDERS=OpenExchangeRates,XE
EXCHANGE_RATE_UPDATE_SCHEDULE=0 8 * * *  # Cron: 8 AM diario
CURRENCY_PRECISION=6  # Decimales para conversiones

# ========================================
# LOCALIZACIÓN E IDIOMA
# ========================================
DEFAULT_LANGUAGE=es-ES
SUPPORTED_LANGUAGES=es-ES,pt-BR,en-US
DEFAULT_TIMEZONE_BY_COUNTRY=AR:America/Argentina/Buenos_Aires,MX:America/Mexico_City,...
DATE_FORMAT_BY_COUNTRY=AR:dd/MM/yyyy,US:MM/dd/yyyy
NUMBER_FORMAT_BY_COUNTRY=AR:es-AR,US:en-US

# ========================================
# DATABASE
# ========================================
DATABASE_HOST=localhost
DATABASE_PORT=3306
DATABASE_NAME=erp_multinacional
DATABASE_USER=erp_user
DATABASE_PASSWORD=***
DATABASE_PARTITIONING_STRATEGY=COUNTRY  # Particiones por país

# ========================================
# REDIS
# ========================================
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_CACHE_EXCHANGE_RATES=true
REDIS_EXCHANGE_RATE_TTL=86400  # 24 horas

# ========================================
# AUTHENTICATION
# ========================================
JWT_SECRET=***
JWT_EXPIRATION_MINUTES=480
JWT_INCLUDE_COUNTRY_CLAIM=true
JWT_INCLUDE_CURRENCY_CLAIM=true
ENABLE_MFA=false

# ========================================
# TAX ENGINES (por país)
# ========================================
# Argentina (AFIP)
AFIP_ENVIRONMENT=testing|production
AFIP_CUIT=***
AFIP_CERTIFICATE_PATH=/certificates/afip.pfx
AFIP_CERTIFICATE_PASSWORD=***
AFIP_PUNTO_VENTA=1
ENABLE_AFIP=true

# México (SAT)
SAT_ENVIRONMENT=testing|production
SAT_RFC=***
SAT_CERTIFICATE_PATH=/certificates/sat.cer
SAT_PRIVATE_KEY_PATH=/certificates/sat.key
SAT_PAC_PROVIDER=Finkok  # Finkok, SW, etc.
ENABLE_SAT=true

# Chile (SII)
SII_ENVIRONMENT=testing|production
SII_RUT=***
SII_CERTIFICATE_PATH=/certificates/sii.pfx
ENABLE_SII=true

# Perú (SUNAT)
SUNAT_ENVIRONMENT=testing|production
SUNAT_RUC=***
SUNAT_CERTIFICATE_PATH=/certificates/sunat.pfx
ENABLE_SUNAT=true

# Colombia (DIAN)
DIAN_ENVIRONMENT=testing|production
DIAN_NIT=***
ENABLE_DIAN=true

# Uruguay (DGI)
DGI_ENVIRONMENT=testing|production
DGI_RUT=***
ENABLE_DGI=true

# EE.UU. (Generic + Avalara opcional)
ENABLE_US_TAX=true
AVALARA_ENABLED=false
AVALARA_ACCOUNT_ID=***
AVALARA_LICENSE_KEY=***

# ========================================
# E-COMMERCE INTEGRATIONS (Multi-País)
# ========================================
ENABLE_SHOPIFY=false
SHOPIFY_SHOP_DOMAIN=***
SHOPIFY_SUPPORTED_COUNTRIES=AR,MX,CL,PE

ENABLE_MERCADOLIBRE=false
ML_SUPPORTED_COUNTRIES=AR,MX,CL,PE,CO,UY,BR

ENABLE_AMAZON=false
AMAZON_SUPPORTED_REGIONS=LATAM,US

# ========================================
# FEATURE TOGGLES (Multinacional)
# ========================================
ENABLE_MULTI_CURRENCY=true  # CRÍTICO
ENABLE_MULTI_COUNTRY=true   # CRÍTICO
ENABLE_INTERCOMPANY=true
ENABLE_CONSOLIDATION=true
ENABLE_IFRS_REPORTING=true
ENABLE_EXCHANGE_RATE_AUTO_UPDATE=true
ENABLE_MONTHLY_REVALUATION=true
ENABLE_MULTI_LANGUAGE=true
ENABLE_LOTES_SERIES=true
ENABLE_INVENTARIO_CICLICO=true

# ========================================
# BUSINESS RULES (Multinacional)
# ========================================
PERMITIR_FACTURAR_SIN_STOCK=false
PERMITIR_EXCEDER_CREDITO=false
METODO_VALUACION_STOCK=PPP  # PPP, PEPS, UEPS
DIAS_ALERTA_VENCIMIENTO=30
PERMITIR_TRANSFERENCIAS_INTERPAIS=true
REQUIERE_AUTORIZACION_TRANSFERENCIA_INTERPAIS=true
CONSOLIDACION_FREQUENCY=MONTHLY  # DAILY, WEEKLY, MONTHLY

# ========================================
# PERFORMANCE (Multinacional)
# ========================================
ENABLE_REDIS_CACHE=true
CACHE_DURACION_MINUTOS=15
DATABASE_POOL_SIZE=200  # Aumentado para multi-país
HANGFIRE_WORKERS=10  # Aumentado para jobs por país
ENABLE_QUERY_PARTITIONING=true  # Particiones por país
ENABLE_READ_REPLICAS=false  # Para producción

# ========================================
# LOGGING (Multinacional)
# ========================================
LOG_LEVEL=Information
SERILOG_WRITE_TO_FILE=true
SERILOG_FILE_PATH=/logs/erp_{country}_{date}.log
SERILOG_INCLUDE_COUNTRY=true
SERILOG_INCLUDE_CURRENCY=true
SERILOG_WRITE_TO_SEQ=false

# ========================================
# PATHS
# ========================================
TEMP_PATH=/tmp/erp
UPLOADS_PATH=/uploads
FACTURAS_PDF_PATH=/facturas/{country}  # Por país
BACKUP_PATH=/backups/{country}
```

### appsettings.json (Multinacional)

**appsettings.json:**
```json
{
  "Localization": {
    "EnabledCountries": ["AR", "MX", "CL", "PE"],
    "DefaultCountry": "AR",
    "BaseCurrency": "USD",
    "TaxEngines": {
      "AR": "ARTaxEngine",
      "MX": "MXTaxEngine",
      "CL": "CLTaxEngine",
      "PE": "PETaxEngine",
      "CO": "COTaxEngine",
      "UY": "UYTaxEngine",
      "US": "USTaxEngine"
    },
    "SupportedLanguages": ["es-ES", "pt-BR", "en-US"],
    "DefaultLanguage": "es-ES"
  },
  "Currency": {
    "ExchangeRateProviders": [
      {
        "Name": "BancoCentral",
        "Priority": 1,
        "Countries": ["AR", "MX", "CL", "PE"]
      },
      {
        "Name": "OpenExchangeRates",
        "Priority": 2,
        "ApiKey": "***"
      }
    ],
    "UpdateSchedule": "0 8 * * *",
    "CacheDuration": "24:00:00",
    "Precision": 6
  },
  "Consolidation": {
    "Enabled": true,
    "ConsolidationCurrency": "USD",
    "Frequency": "Monthly",
    "IFRSCompliant": true,
    "IntercompanyEliminationRules": {
      "EliminateSales": true,
      "EliminatePurchases": true,
      "EliminateTransfers": true
    }
  }
}
```

---

## 🧪 Testing Strategy Multi-País

### 1. Unit Tests Por País

```csharp
[TestFixture]
public class ARTaxEngineTests
{
    [Test]
    public void CalcularFacturaA_Argentina_DebeCalcularCorrectamente()
    {
        // Arrange
        var taxEngine = _factory.GetTaxEngine(CountryCode.AR);
        var factura = new FacturaDto
        {
            Pais = CountryCode.AR,
            Moneda = CurrencyCode.ARS,
            Subtotal = 1000m,
            CondicionIVA = CondicionIVA.ResponsableInscripto
        };

        // Act
        var resultado = taxEngine.CalcularImpuestos(factura);

        // Assert
        Assert.That(resultado.IVA, Is.EqualTo(210m)); // 21%
        Assert.That(resultado.Total, Is.EqualTo(1210m));
    }
}

[TestFixture]
public class MXTaxEngineTests
{
    [Test]
    public void CalcularCFDI_Mexico_DebeCalcularCorrectamente()
    {
        // Arrange
        var taxEngine = _factory.GetTaxEngine(CountryCode.MX);
        var factura = new FacturaDto
        {
            Pais = CountryCode.MX,
            Moneda = CurrencyCode.MXN,
            Subtotal = 1000m
        };

        // Act
        var resultado = taxEngine.CalcularImpuestos(factura);

        // Assert
        Assert.That(resultado.IVA, Is.EqualTo(160m)); // 16%
        Assert.That(resultado.Total, Is.EqualTo(1160m));
    }
}
```

### 2. Currency Conversion Tests

```csharp
[TestFixture]
public class CurrencyConversionTests
{
    [TestCase(100, CurrencyCode.ARS, CurrencyCode.USD, 0.25)]  // AR: 400 ARS = 1 USD
    [TestCase(100, CurrencyCode.MXN, CurrencyCode.USD, 5.0)]   // MX: 20 MXN = 1 USD
    [TestCase(100, CurrencyCode.CLP, CurrencyCode.USD, 0.125)] // CL: 800 CLP = 1 USD
    [TestCase(100, CurrencyCode.PEN, CurrencyCode.USD, 28.57)] // PE: 3.5 PEN = 1 USD
    public async Task ConvertirMoneda_ConTipoCambioReal_DebeCalcularCorrectamente(
        decimal monto,
        CurrencyCode desde,
        CurrencyCode hacia,
        decimal resultadoEsperado)
    {
        // Arrange & Act
        var resultado = await _currencyService.ConvertAsync(monto, desde, hacia, DateTime.Today);

        // Assert
        Assert.That(resultado, Is.EqualTo(resultadoEsperado).Within(0.01m));
    }

    [Test]
    public async Task ConvertirMoneda_DebeGuardarTrazabilidad()
    {
        // Act
        var resultado = await _currencyService.ConvertAsync(100, CurrencyCode.ARS, CurrencyCode.USD, DateTime.Today);

        // Assert
        var log = await _conversionLogRepository.GetLastAsync();
        Assert.That(log.MonedaOrigen, Is.EqualTo(CurrencyCode.ARS));
        Assert.That(log.MonedaDestino, Is.EqualTo(CurrencyCode.USD));
        Assert.That(log.TipoCambioUtilizado, Is.Not.Zero);
        Assert.That(log.Fecha, Is.EqualTo(DateTime.Today));
    }
}
```

### 3. Consolidation Tests

```csharp
[TestFixture]
public class ConsolidationTests
{
    [Test]
    public async Task ConsolidarBalances_MultiPais_DebeConsolidarCorrectamente()
    {
        // Arrange
        // Crear ventas en 4 países
        await CrearVentaAsync(CountryCode.AR, 1000m, CurrencyCode.ARS); // 1000 ARS
        await CrearVentaAsync(CountryCode.MX, 2000m, CurrencyCode.MXN); // 2000 MXN
        await CrearVentaAsync(CountryCode.CL, 800000m, CurrencyCode.CLP); // 800k CLP
        await CrearVentaAsync(CountryCode.PE, 350m, CurrencyCode.PEN); // 350 PEN

        // Tipos de cambio a USD:
        // 1 USD = 400 ARS, 20 MXN, 800 CLP, 3.5 PEN

        // Act
        var balanceConsolidado = await _consolidationService.ConsolidarBalancesAsync(
            DateTime.Today,
            CurrencyCode.USD
        );

        // Assert
        var ventasTotales = balanceConsolidado.Ingresos["Ventas"];
        var esperado = (1000 / 400) + (2000 / 20) + (800000 / 800) + (350 / 3.5);
        // = 2.5 + 100 + 1000 + 100 = 1202.5 USD

        Assert.That(ventasTotales, Is.EqualTo(1202.5m).Within(0.1m));
    }

    [Test]
    public async Task ConsolidarBalances_ConEliminacionIntercompany_DebeEliminar()
    {
        // Arrange
        // Transferencia de AR a MX: 1000 USD
        await CrearTransferenciaInterPaisAsync(
            CountryCode.AR,
            CountryCode.MX,
            1000m,
            CurrencyCode.USD
        );

        // Act
        var balanceConsolidado = await _consolidationService.ConsolidarBalancesAsync(
            DateTime.Today,
            CurrencyCode.USD,
            eliminarIntercompany: true
        );

        // Assert - La transferencia interna debe estar eliminada
        var cuentasPorCobrarIntercompany = balanceConsolidado.Activos["CuentasPorCobrar_Intercompany"];
        var cuentasPorPagarIntercompany = balanceConsolidado.Pasivos["CuentasPorPagar_Intercompany"];

        Assert.That(cuentasPorCobrarIntercompany, Is.EqualTo(0));
        Assert.That(cuentasPorPagarIntercompany, Is.EqualTo(0));
    }
}
```

### 4. E2E Tests Por País

```csharp
[TestFixture]
public class E2EArgentinaTests
{
    [Test]
    public async Task FlujoCompleto_Argentina_VentaConAFIP()
    {
        // Setup país Argentina
        SetCurrentCountry(CountryCode.AR);
        SetCurrentCurrency(CurrencyCode.ARS);

        // 1. Crear pedido
        var pedido = await CrearPedidoAsync(cliente: "CUIT-12345678", monto: 1000m);

        // 2. Facturar con AFIP
        var factura = await FacturarAsync(pedido.Id, TipoFactura.A);

        // Validaciones Argentina
        Assert.That(factura.CAE, Is.Not.Null); // CAE de AFIP
        Assert.That(factura.CAEVencimiento, Is.Not.Null);
        Assert.That(factura.Pais, Is.EqualTo(CountryCode.AR));
        Assert.That(factura.Moneda, Is.EqualTo(CurrencyCode.ARS));
        Assert.That(factura.IVA, Is.EqualTo(210m)); // 21%

        // 3. Verificar asiento contable
        var asiento = await GetAsientoByDocumentoAsync("FACTURA", factura.Id);
        Assert.That(asiento.Pais, Is.EqualTo(CountryCode.AR));
        Assert.That(asiento.Moneda, Is.EqualTo(CurrencyCode.ARS));
        Assert.That(asiento.MontoUSD, Is.GreaterThan(0)); // Conversión a USD
    }
}

[TestFixture]
public class E2EMexicoTests
{
    [Test]
    public async Task FlujoCompleto_Mexico_VentaConSAT()
    {
        // Setup país México
        SetCurrentCountry(CountryCode.MX);
        SetCurrentCurrency(CurrencyCode.MXN);

        // 1. Crear pedido
        var pedido = await CrearPedidoAsync(cliente: "RFC-XAXX010101000", monto: 1000m);

        // 2. Facturar con SAT (CFDI 4.0)
        var factura = await FacturarAsync(pedido.Id);

        // Validaciones México
        Assert.That(factura.UUID, Is.Not.Null); // UUID del SAT
        Assert.That(factura.Pais, Is.EqualTo(CountryCode.MX));
        Assert.That(factura.Moneda, Is.EqualTo(CurrencyCode.MXN));
        Assert.That(factura.IVA, Is.EqualTo(160m)); // 16%
        Assert.That(factura.XML, Is.Not.Null); // CFDI XML
    }
}
```

---

## 📊 Definition of Done - Multinacional

### Para Cada User Story Multinacional:

**Código:**
- [ ] Implementado según Clean Architecture
- [ ] Multi-tenant context aplicado
- [ ] SOLID principles aplicados
- [ ] NO código duplicado POR PAÍS
- [ ] Configuración por variables de entorno
- [ ] Soporte multi-moneda (si aplica)
- [ ] Soporte multi-idioma en responses
- [ ] Auditoría implementada (con CountryCode)
- [ ] Code review aprobado
- [ ] 0 compiler warnings

**Testing Multinacional:**
- [ ] Unit tests (>90% coverage)
- [ ] Integration tests POR PAÍS (AR, MX, CL, PE mínimo)
- [ ] Currency conversion tests (si aplica)
- [ ] Regression tests fiscales POR PAÍS
- [ ] Performance tests multi-país
- [ ] Tests pasando en CI/CD con matrix por país

**Multi-Moneda (si aplica):**
- [ ] Conversión de moneda implementada
- [ ] Tipo de cambio trazable
- [ ] Diferencias de cambio calculadas
- [ ] Tests de conversión (6 decimales precisión)

**Fiscal (si aplica):**
- [ ] Tax engine correcto por país
- [ ] Validación con entidad fiscal (AFIP/SAT/SII/SUNAT)
- [ ] Tipos de documento correctos por país
- [ ] Tests de regresión fiscal POR PAÍS (100% coverage)

**Consolidación (si aplica):**
- [ ] Conversión a USD correcta
- [ ] Mapeo a plan de cuentas consolidado
- [ ] Eliminaciones intercompany (si aplica)
- [ ] Tests de consolidación

**Multi-Idioma (si aplica):**
- [ ] Responses localizados (ES, PT, EN)
- [ ] Formatos de fecha/número por país
- [ ] Mensajes de error localizados
- [ ] Tests de localización

**Documentación:**
- [ ] XML comments completos
- [ ] API documentada por país en Swagger
- [ ] README actualizado
- [ ] ADR para decisiones multinacionales
- [ ] Guía de localización por país

**Performance Multinacional:**
- [ ] Response time <2s (P95) POR PAÍS
- [ ] Conversión de moneda <100ms
- [ ] Consolidación <1h para 4 países
- [ ] Queries con índices por país/moneda

**Security:**
- [ ] Autorización multi-tenant correcta
- [ ] Tenant isolation verificado
- [ ] Input validation por país
- [ ] Secrets por país no expuestos

---

## 📈 Métricas de Éxito Multinacional

### Phase 0 (Semana 1-3)
- [ ] Setup multi-país funcional
- [ ] CI/CD con matrix por país (AR, MX, CL, PE)
- [ ] Base de datos con schema multinacional
- [ ] Autenticación multi-tenant
- [ ] 0 errores de compilación

### Phase 1 (Semana 4-7)
- [ ] Motor multi-moneda funcionando
- [ ] Tipos de cambio automáticos
- [ ] Stock multi-país completo
- [ ] Compras multi-moneda completas
- [ ] Tests >85% coverage
- [ ] Conversión de moneda <100ms

### Phase 2 (Semana 8-12)
- [ ] Tax engines para AR, MX, CL, PE
- [ ] Facturación multi-país completa
- [ ] Timbrado fiscal funcionando (AR, MX)
- [ ] Tests >90% coverage por país
- [ ] E2E test por país pasando

### Phase 3 (Semana 13-16)
- [ ] Contabilidad multi-país completa
- [ ] Asientos intercompany funcionando
- [ ] Consolidación multinacional operativa
- [ ] Reexpresión contable mensual
- [ ] Cierre contable <24h
- [ ] Tests >95% coverage (contabilidad 100%)

### Phase 4 (Semana 17-20)
- [ ] 7 países soportados (AR, MX, CL, PE, CO, UY, genérico)
- [ ] Reportes multinacionales completos
- [ ] Dashboards regionales
- [ ] Performance targets por país met

### Phase 5 (Semana 21-24)
- [ ] Production ready multinacional
- [ ] Multi-idioma (ES, PT, EN) funcionando
- [ ] Security audit multi-país passed
- [ ] Tests >90% coverage global
- [ ] Deployed en 4 regiones
- [ ] Consolidación de 4 países <1h

---

## 🌍 Roadmap Regional de Implementación

### Fase 1 (MVP): Argentina, México, Chile, Perú
**Duración:** Semanas 4-12
**Países:** AR, MX, CL, PE
**Prioridad:** CRÍTICA
**Justificación:** Principales mercados LATAM, regulaciones complejas

**Entregables:**
- ✅ Tax engines: AFIP, SAT, SII, SUNAT
- ✅ Facturación electrónica funcionando
- ✅ Multi-moneda: ARS, MXN, CLP, PEN, USD
- ✅ Consolidación de 4 países
- ✅ IFRS reporting básico

### Fase 2: Colombia, Uruguay, Centroamérica
**Duración:** Semanas 17-20
**Países:** CO, UY, GT, CR, PA, SV, HN, NI
**Prioridad:** ALTA
**Justificación:** Expansión regional, regulaciones intermedias

**Entregables:**
- ✅ Tax engines: DIAN, DGI, genérico Centroamérica
- ✅ Soporte para 12 países
- ✅ Consolidación ampliada

### Fase 3: Caribe, EE.UU., Canadá
**Duración:** Semanas 21-24 (paralelo a Quality)
**Países:** DO, PR, US, CA
**Prioridad:** MEDIA
**Justificación:** Mercados adicionales, regulaciones más simples

**Entregables:**
- ✅ Tax engine genérico Caribe
- ✅ US/Canada Sales Tax (Avalara opcional)
- ✅ 16 países soportados

### Fase 4: Consolidación Multinacional & IFRS
**Duración:** Semanas 13-24 (continuo)
**Alcance:** Todos los países
**Prioridad:** CRÍTICA

**Entregables:**
- ✅ Consolidación completa en USD
- ✅ Eliminaciones intercompany automáticas
- ✅ Reportes IFRS completos
- ✅ Cierre consolidado <24h

---

## 🎓 Lecciones Clave para ERP Multinacional

### Del Proyecto Python/FastAPI:
✅ **NO DUPLICACIÓN es CRÍTICO** - Con 8+ países, duplicación = desastre
✅ **Configuración única** - Activación por país con feature toggles
✅ **Un solo codebase** - Localización por configuración, NO por código

### Del Proyecto .NET YouTube RAG:
✅ **Clean Architecture desde día 1** - Esencial para complejidad multinacional
✅ **DevOps automatizado temprano** - CI/CD con matrix por país
✅ **Testing exhaustivo** - >90% coverage, 100% en cálculos fiscales
✅ **99.3% test coverage es posible** - Objetivo para ERP multinacional
✅ **5-minute onboarding** - Scripts automatizados

### Específico de ERP Multinacional:
✅ **Multi-Moneda desde día 1** - NO es opcional, es core
✅ **Tax engines independientes** - Factory pattern, NO if/else por país
✅ **Consolidación como proceso** - NO como reporte
✅ **Auditoría con país/moneda** - Trazabilidad completa
✅ **Testing por país** - CADA país tiene su suite de tests
✅ **Localización NO es traducción** - Es adaptación completa (fiscal, contable, cultural)

---

## 📞 Próximos Pasos

**AHORA:**
1. ✅ Revisar alcance multinacional
2. ✅ Aprobar roadmap regional
3. ✅ Validar estimaciones (20-24 semanas)
4. ✅ Confirmar priorización de países (AR, MX, CL, PE primero)

**ENTONCES:**
1. ✅ Crear repositorio Git con estructura multinacional
2. ✅ Ejecutar Fase 0 - Setup Multinacional (3 semanas)
3. ✅ Usar agentes especializados:
   - `software-architect` → Diseño multi-tenant
   - `dotnet-backend-developer` → Implementación
   - `database-expert` → Schema multinacional
   - `test-engineer` → Testing por país
   - `code-reviewer` → Code review
   - `devops-engineer` → CI/CD multi-país

---

**FIN DE METODOLOGÍA MULTINACIONAL**

**Estado:** READY FOR REVIEW & APPROVAL
**Próximo paso:** Aprobación de alcance multinacional y kick-off
**Autor:** Claude Code
**Basado en:**
- 237k+ palabras documentación proyectos exitosos
- Especificación ERP v0.1 (Argentina)
- Especificación ERP v0.2 (Multipaís - América)

**Complejidad:** MUY ALTA
**Duración estimada:** 20-24 semanas (5-6 meses)
**Países MVP:** Argentina, México, Chile, Perú
**Monedas:** ARS, MXN, CLP, PEN, USD (+ otras)
**Resultado esperado:** ERP multinacional production-ready, 90%+ test coverage, consolidación IFRS

---

**"En un ERP multinacional, un error en conversión de moneda o cálculo fiscal puede costar millones en múltiples países. Testing al 100% no es opcional, es supervivencia."**

---

## 🔍 Comparativa v0.1 vs v0.2

| Aspecto | v0.1 (Argentina) | v0.2 (Multinacional) | Δ Complejidad |
|---------|------------------|---------------------|---------------|
| **Países** | 1 (AR) | 8+ (toda América) | +800% |
| **Monedas** | 1 (ARS) | 8+ (multi-currency) | +800% |
| **Tax Engines** | 1 (AFIP) | 8+ (AFIP, SAT, SII, etc.) | +800% |
| **Entidades de Dominio** | 30 | 40 | +33% |
| **Servicios de Aplicación** | 25 | 35 | +40% |
| **User Stories** | 27 | 45 | +67% |
| **Story Points** | 350 | 600 | +71% |
| **Duración** | 14 semanas | 20-24 semanas | +71% |
| **Test Coverage Target** | 85% | 90% | +6% |
| **CI/CD Complexity** | Simple | Matrix por país | +300% |
| **Deployment Regions** | 1 | 4+ | +400% |

**Conclusión:** La versión multinacional agrega **70-80% de complejidad** adicional, pero permite **expansión regional completa** con un **único codebase**.
