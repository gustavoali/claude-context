# Sistema ERP Multinacional - Product Backlog
**Versión del Documento:** 1.0
**Fecha de Creación:** 2025-10-11
**Product Owner:** Equipo de Producto ERP
**Duración del Proyecto:** 20-24 semanas
**Alcance:** América completa (8+ países)

---

## 📋 Tabla de Contenidos

1. [Resumen Ejecutivo](#-resumen-ejecutivo)
2. [Framework de Priorización](#-framework-de-priorización)
3. [Epics del Proyecto](#-epics-del-proyecto)
4. [User Stories Detalladas](#-user-stories-detalladas)
5. [Scoring RICE](#-scoring-rice-top-20-stories)
6. [Plan de Releases](#-plan-de-releases)
7. [Mapa de Dependencias](#-mapa-de-dependencias)
8. [Definition of Done](#-definition-of-done)
9. [Métricas y KPIs](#-métricas-y-kpis)

---

## 🎯 Resumen Ejecutivo

### Visión del Producto

Desarrollar un **Sistema ERP integral multinacional** que permita gestionar operaciones de Stock, Compras, Ventas, Tesorería y Contabilidad para empresas con presencia en múltiples países de América, con soporte completo para:

- **Multi-moneda:** Conversión automática y consolidación en USD
- **Multi-país:** 8+ jurisdicciones fiscales (AFIP, SAT, SII, SUNAT, DIAN, DGI, etc.)
- **Multi-tenant:** Soporte para múltiples empresas, sucursales y depósitos
- **Multi-idioma:** Español, Português, English

### Evolución del Alcance

```
v0.1 (Alcance Inicial):
- País: Argentina únicamente
- Moneda: ARS (Peso argentino)
- Regulación fiscal: AFIP
- Duración estimada: 14 semanas
- Complejidad: ALTA

v0.2 (Alcance Multinacional): ← VERSIÓN ACTUAL
- Países: 8+ en América (AR, MX, CL, PE, CO, UY, US/CA, Caribe/Centroamérica)
- Monedas: Múltiples con consolidación USD
- Regulaciones fiscales: 8+ tax engines
- Duración estimada: 20-24 semanas
- Complejidad: MUY ALTA (+70% vs v0.1)
```

### Objetivos de Negocio

1. **Expansión Regional:** Permitir operaciones simultáneas en múltiples países desde un único sistema
2. **Consolidación Financiera:** Reportes consolidados en USD siguiendo IFRS
3. **Cumplimiento Fiscal:** 100% de compliance con regulaciones locales de cada país
4. **Eficiencia Operativa:** Eliminar duplicación de sistemas por país
5. **Escalabilidad:** Soportar crecimiento a nuevos países sin reescribir código

### Stakeholders y Roles del Sistema

El sistema soporta **7 roles principales**:

| Rol | Responsabilidad | Módulos Principales |
|-----|----------------|-------------------|
| **Admin** | Administración completa del sistema | Todos los módulos |
| **Almacenero** | Gestión de inventario y movimientos | Stock, Transferencias |
| **Comprador** | Órdenes de compra y recepción | Compras, Proveedores |
| **Vendedor** | Ventas y facturación | Ventas, Clientes, Facturación |
| **Tesorero** | Gestión de cobros y pagos | Tesorería, Bancos, Cobranzas |
| **Contador** | Contabilidad y cierres contables | Contabilidad, Reportes Fiscales |
| **Auditor** | Consulta y auditoría (solo lectura) | Todos (solo consulta) |

### Timeline del Proyecto

**Duración Total:** 20-24 semanas (5-6 meses)

**Fases:**
- **Fase 0:** Setup + Foundation Multinacional (Sem 1-3)
- **Fase 1:** MVP - Multi-Moneda + Stock + Compras (Sem 4-7)
- **Fase 2:** Ventas Multi-País + Tax Engines (Sem 8-12)
- **Fase 3:** Contabilidad Multinacional + Consolidación (Sem 13-16)
- **Fase 4:** Localización Adicional + Reportes (Sem 17-20)
- **Fase 5:** Quality, Performance & Production (Sem 21-24)

### Métricas de Éxito

| Métrica | Target | Prioridad |
|---------|--------|-----------|
| **Cobertura de Tests** | >90% global, 100% fiscal/contable | CRÍTICA |
| **Performance** | Response time <2s (P95) | ALTA |
| **Conversión de Moneda** | <100ms, precisión 6 decimales | CRÍTICA |
| **Consolidación Multi-País** | <1h para 4 países | ALTA |
| **Disponibilidad** | 99.5% uptime | ALTA |
| **Compliance Fiscal** | 100% por país | CRÍTICA |

### Riesgos Identificados

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|------------|
| Errores en conversión de moneda | Media | Crítico | Tests 100%, auditoría de conversiones |
| Cálculos fiscales incorrectos por país | Alta | Crítico | Tests 100% por tax engine, validación con contadores locales |
| Complejidad de consolidación | Alta | Alto | Implementación incremental, validación continua |
| Integración con APIs fiscales (AFIP, SAT, etc.) | Media | Alto | Polly resilience, fallbacks, mocks para testing |
| Performance con múltiples países | Media | Medio | Particionamiento DB, caching Redis, índices optimizados |
| Migración de datos legacy multi-país | Alta | Alto | Plan de migración por país, validaciones exhaustivas |

---

## 📊 Framework de Priorización

### RICE Scoring Formula

Utilizamos **RICE Scoring** para priorizar todas las User Stories:

```
RICE Score = (Reach × Impact × Confidence) / Effort

Componentes:
- Reach: 1-10 (usuarios/transacciones afectadas por trimestre)
- Impact: 0.25=Mínimo, 0.5=Bajo, 1=Medio, 2=Alto, 3=Masivo
- Confidence: 50%=Bajo, 80%=Medio, 100%=Alto
- Effort: Story Points (1-21 escala Fibonacci)
```

### MoSCoW Classification

Todas las historias están clasificadas según MoSCoW:

- **Must Have:** Funcionalidades core del MVP - Sin estas, el sistema no funciona
- **Should Have:** Importantes pero no bloquean MVP - Se pueden implementar en fases posteriores cercanas
- **Could Have:** Mejoras valiosas pero diferibles - Se implementan si hay tiempo/presupuesto
- **Won't Have:** Fuera de scope actual - Se consideran para versiones futuras

### Criterios de Priorización Específicos ERP Multinacional

1. **Principio NO DUPLICACIÓN:** Historias que evitan duplicación por país tienen prioridad alta
2. **Multi-Moneda primero:** El motor de monedas debe estar funcional antes que módulos transaccionales
3. **Tax Engines por país:** Se priorizan según roadmap regional (AR, MX, CL, PE primero)
4. **Consolidación temprana:** Se implementa en paralelo con módulos contables
5. **Testing no negociable:** Historias de testing tienen prioridad igual a features

---

## 🎯 Epics del Proyecto

### Resumen de Epics

| Epic ID | Nombre | Story Points | Priority | Status | Release |
|---------|--------|--------------|----------|--------|---------|
| **Epic 0** | Multi-Tenant Core Infrastructure | 85 | Must Have | Planned | 0 |
| **Epic 1** | Multi-Currency Engine | 89 | Must Have | Planned | 1 |
| **Epic 2** | Gestión de Inventario Multinacional | 97 | Must Have | Planned | 1 |
| **Epic 3** | Compras Multinacionales | 76 | Must Have | Planned | 1 |
| **Epic 4** | Tax Engines por País | 147 | Must Have | Planned | 2 |
| **Epic 5** | Ventas Multi-País | 102 | Must Have | Planned | 2 |
| **Epic 6** | Contabilidad Multinacional | 118 | Must Have | Planned | 3 |
| **Epic 7** | Consolidación & IFRS | 84 | Must Have | Planned | 3 |
| **Epic 8** | User Management & RBAC | 42 | Must Have | Planned | 0-1 |
| **Epic 9** | DevOps & Testing Infrastructure | 63 | Must Have | Planned | 0-5 |
| **Epic 10** | Localization Adicional | 89 | Should Have | Planned | 4 |

**Total Story Points:** ~992 puntos

---

## Epic 0: Multi-Tenant Core Infrastructure

**Prioridad:** MUST HAVE
**Story Points:** 85
**RICE Score:** N/A (Foundation)
**Sprint:** Fase 0 (Semana 1-3)
**Release:** Release 0 (Setup)

### Business Value

Establece la **base arquitectónica multinacional** del sistema. Sin esta infraestructura, no se puede implementar soporte multi-país, multi-moneda, ni multi-tenant. Es la fundación sobre la que se construye todo el ERP.

### Descripción

Implementar la infraestructura core que permita:
- Gestión de múltiples países, regiones, sucursales
- Multi-tenancy (aislamiento por empresa/país)
- Autenticación y autorización multi-tenant
- Base de datos con schema multinacional
- CI/CD con matrix testing por país

### Acceptance Criteria (Epic Level)

- [ ] Arquitectura Clean Architecture implementada con 4 capas
- [ ] Base de datos con 40+ entidades core
- [ ] Autenticación JWT multi-tenant funcionando
- [ ] RBAC con 7 roles completo
- [ ] CI/CD con matrix por país (AR, MX, CL, PE)
- [ ] Setup automatizado <10 minutos

### Dependencies

- Ninguna (es la base)

### Risks

- Complejidad arquitectónica inicial alta
- Decisiones tempranas difíciles de cambiar después

---

## Epic 1: Multi-Currency Engine

**Prioridad:** MUST HAVE
**Story Points:** 89
**RICE Score:** 225.0
**Sprint:** Fase 1 (Semana 4-7)
**Release:** Release 1 (MVP)

### Business Value

El **motor multi-moneda es CRÍTICO** para el ERP multinacional. Permite:
- Operar con múltiples monedas simultáneamente
- Conversión automática entre cualquier par de monedas
- Consolidación contable en USD
- Cálculo de diferencias de cambio
- Reexpresión contable mensual

**Impacto económico:** Un error en conversión de moneda puede costar millones. Este epic tiene tests al 100%.

### Descripción

Desarrollar un motor completo de gestión multi-moneda que incluya:
- Gestión de monedas (CRUD con ISO 4217)
- Obtención automática de tipos de cambio (múltiples fuentes)
- Servicio de conversión con trazabilidad
- Cálculo de diferencias de cambio
- Reexpresión contable mensual
- Cache de tipos de cambio en Redis

### Acceptance Criteria (Epic Level)

- [ ] Soporte para 8+ monedas activas (ARS, MXN, CLP, PEN, COP, UYU, USD, etc.)
- [ ] Tipos de cambio automáticos diarios desde Bancos Centrales
- [ ] Conversión entre cualquier par de monedas con 6 decimales de precisión
- [ ] Diferencias de cambio calculadas automáticamente
- [ ] Asientos contables de diferencias de cambio generados automáticamente
- [ ] Reexpresión mensual a USD funcionando
- [ ] 100% test coverage en conversiones

### User Stories Incluidas

- US-001: Gestión de Monedas (8 pts)
- US-002: Tipos de Cambio Automáticos (13 pts)
- US-003: Servicio de Conversión de Moneda (13 pts)
- US-004: Diferencias de Cambio (13 pts)
- US-005: Reexpresión Contable Mensual (13 pts)
- US-006: Cache de Tipos de Cambio (8 pts)
- US-007: API de Consulta de Tipos de Cambio (5 pts)
- US-008: Auditoría de Conversiones (8 pts)
- US-009: Configuración Multi-Moneda (8 pts)

### Dependencies

- Epic 0: Multi-Tenant Core Infrastructure (completo)

### Risks

- APIs de Bancos Centrales pueden tener límites de rate
- Precisión de conversiones crítica (6 decimales requeridos)
- Sincronización de tipos de cambio entre países

---

## Epic 2: Gestión de Inventario Multinacional

**Prioridad:** MUST HAVE
**Story Points:** 97
**RICE Score:** 194.0
**Sprint:** Fase 1 (Semana 4-7)
**Release:** Release 1 (MVP)

### Business Value

Permite gestionar el inventario de productos en **múltiples países, sucursales y depósitos** desde un único sistema. Incluye:
- Estructura jerárquica: País → Región → Sucursal → Depósito
- Stock por ubicación con trazabilidad
- Transferencias inter-país con costos
- Lotes, series y vencimientos
- Inventario cíclico
- Valuación de stock multi-moneda

### Descripción

Implementar un sistema completo de gestión de inventario que soporte:
- Catálogo de productos con precios por país/moneda
- Stock por depósito con múltiples ubicaciones
- Movimientos de stock con auditoría completa
- Transferencias entre depósitos (mismo país e inter-país)
- Control de lotes, series y vencimientos
- Inventario cíclico y ajustes
- Reportes de stock consolidados

### Acceptance Criteria (Epic Level)

- [ ] Jerarquía País → Región → Sucursal → Depósito funcionando
- [ ] Productos con precios en múltiples monedas
- [ ] Stock en tiempo real por depósito
- [ ] Transferencias inter-país con costos y asientos intercompany
- [ ] Trazabilidad completa de lotes y series
- [ ] Valuación PPP (Precio Promedio Ponderado) por depósito
- [ ] Reportes consolidados de stock multi-país
- [ ] Alertas de stock mínimo, vencimientos

### User Stories Incluidas

- US-010: Estructura Regional Multi-País (13 pts)
- US-011: Catálogo de Productos Multi-Precio (13 pts)
- US-012: Stock por Depósito (13 pts)
- US-013: Movimientos de Stock (8 pts)
- US-014: Transferencias Inter-Sucursal (13 pts)
- US-015: Transferencias Inter-País con Costo (13 pts)
- US-016: Lotes y Series (8 pts)
- US-017: Control de Vencimientos (5 pts)
- US-018: Inventario Cíclico (8 pts)
- US-019: Valuación de Stock Multi-Moneda (8 pts)

### Dependencies

- Epic 0: Multi-Tenant Core Infrastructure
- Epic 1: Multi-Currency Engine (para precios y valuación)

### Risks

- Complejidad de transferencias inter-país con múltiples monedas
- Performance con grandes volúmenes de movimientos
- Sincronización de stock en tiempo real

---

## 📚 User Stories Detalladas

### Convenciones de Formato

Todas las User Stories siguen este formato estándar:

```markdown
#### US-XXX: [Título de la Historia]

**Como** [Rol del usuario]
**Quiero** [Funcionalidad deseada]
**Para** [Beneficio de negocio]

**Priority:** Must Have / Should Have / Could Have
**Story Points:** X
**Sprint:** Fase X (Semana X-X)
**Epic:** Epic X
**RICE Score:** X.X

**Acceptance Criteria:**
- [ ] AC1: [Criterio específico y medible con formato Given/When/Then]
- [ ] AC2: [Criterio específico y medible]
- [ ] AC3: [Criterio específico y medible]

**Technical Notes:**
- Approach de implementación
- Tecnologías/patrones a usar
- Consideraciones de performance
- Dependencies técnicas

**Definition of Done:**
- [ ] Código implementado siguiendo Clean Architecture
- [ ] Tests unitarios (>90% coverage)
- [ ] Tests de integración por país (si aplica)
- [ ] API documentada en Swagger
- [ ] Code review aprobado
- [ ] No duplicación verificada
- [ ] Deployed a staging
```

---

## Epic 0: Multi-Tenant Core Infrastructure - User Stories

### US-001: Gestión de Países y Regiones

**Como** Administrador del sistema
**Quiero** gestionar la estructura de países y regiones
**Para** poder configurar el sistema para operar en múltiples jurisdicciones

**Priority:** Must Have
**Story Points:** 8
**Sprint:** Fase 0 (Semana 1-3)
**Epic:** Epic 0
**RICE Score:** N/A (Foundation)

#### Acceptance Criteria

**AC1: CRUD de Países**
- Given un administrador autenticado
- When accede al módulo de configuración de países
- Then puede crear, leer, actualizar países
- And cada país tiene código ISO 3166 (AR, MX, CL, etc.)
- And moneda por defecto
- And zona horaria
- And formato de fecha/número

**AC2: CRUD de Regiones**
- Given un país creado
- When el administrador crea regiones
- Then cada región está asociada a un país
- And tiene nombre y código
- And puede tener configuración regional específica

**AC3: Activación/Desactivación por País**
- Given países configurados
- When se activa/desactiva un país
- Then el sistema habilita/deshabilita funcionalidades de ese país
- And los tax engines se activan/desactivan automáticamente
- And se muestra en la UI solo países activos

**AC4: Configuración Fiscal por País**
- Given un país activo
- When se configura
- Then permite especificar entidad fiscal (AFIP, SAT, SII, etc.)
- And tipos de documentos fiscales
- And impuestos aplicables
- And plantilla de plan de cuentas

#### Technical Notes

- Implementar en Domain Layer: `Pais.cs`, `Region.cs`
- Enum `CodigoPais` con ISO 3166
- Seed inicial con AR, MX, CL, PE configurados
- Validación: No permitir eliminar países con datos transaccionales
- Cache de configuración de países en Redis

#### Definition of Done

- [ ] Entidades Pais y Region implementadas
- [ ] CRUD API endpoints funcionales
- [ ] Seed data para AR, MX, CL, PE
- [ ] Validaciones completas
- [ ] Tests unitarios >90%
- [ ] Tests de integración por país
- [ ] Documentación Swagger completa
- [ ] Cache implementado

---

### US-002: Multi-Tenancy Context

**Como** Desarrollador del sistema
**Quiero** un contexto multi-tenant completo
**Para** que todas las operaciones estén aisladas por empresa/país

**Priority:** Must Have
**Story Points:** 13
**Sprint:** Fase 0 (Semana 1-3)
**Epic:** Epic 0
**RICE Score:** N/A (Foundation)

#### Acceptance Criteria

**AC1: Tenant Detection Middleware**
- Given una request HTTP entrante
- When el middleware procesa la request
- Then extrae el tenant ID del JWT token
- And lo almacena en el contexto de la request
- And valida que el tenant existe y está activo

**AC2: Tenant Isolation en DbContext**
- Given operaciones de base de datos
- When se ejecutan queries
- Then se filtran automáticamente por tenant ID
- And no es posible acceder a datos de otros tenants
- And las inserts incluyen tenant ID automáticamente

**AC3: Tenant Scope en Services**
- Given servicios de aplicación
- When se ejecutan operaciones
- Then tienen acceso al tenant actual
- And al país actual
- And a la moneda del país
- And a la configuración específica del tenant

**AC4: Tenant Switching (Admin Only)**
- Given un usuario admin de multi-tenant
- When hace tenant switching
- Then puede cambiar entre tenants autorizados
- And el contexto se actualiza correctamente
- And se registra en audit log

#### Technical Notes

- Middleware: `TenantDetectionMiddleware`
- Service: `ITenantContext`, `TenantContextService`
- DbContext: Filtros globales por tenant
- JWT Claims: Incluir TenantId, CountryCode, CurrencyCode
- Usar AsyncLocal para thread-safety

#### Definition of Done

- [ ] Middleware implementado
- [ ] DbContext con filtros globales
- [ ] TenantContext service funcional
- [ ] JWT con claims multi-tenant
- [ ] Tests de aislamiento de tenants (crítico)
- [ ] Performance: overhead <5ms
- [ ] Documentación de multi-tenancy
- [ ] Security audit passed

---

### US-003: Autenticación JWT Multi-Tenant

**Como** Usuario del sistema
**Quiero** autenticarme con JWT
**Para** acceder al sistema de forma segura con contexto de país/empresa

**Priority:** Must Have
**Story Points:** 8
**Sprint:** Fase 0 (Semana 1-3)
**Epic:** Epic 0
**RICE Score:** N/A (Foundation)

#### Acceptance Criteria

**AC1: Login con Credenciales**
- Given un usuario registrado
- When realiza login con email/password
- Then recibe JWT token
- And el token incluye: UserId, TenantId, CountryCode, CurrencyCode, Roles
- And el token expira en tiempo configurable (default: 8 horas)

**AC2: Token Validation**
- Given un request con JWT
- When se valida el token
- Then verifica firma
- And expiration
- And issuer/audience
- And claims requeridos
- And rechaza tokens malformados o expirados

**AC3: Refresh Token**
- Given un token próximo a expirar
- When se solicita refresh
- Then genera nuevo token con mismos claims
- And invalida token anterior
- And registra en audit log

**AC4: Multi-Country Access**
- Given un usuario con acceso a múltiples países
- When realiza login
- Then puede seleccionar país activo
- And el token incluye el país seleccionado
- And puede cambiar de país con nuevo token

#### Technical Notes

- Usar `Microsoft.AspNetCore.Authentication.JwtBearer`
- Secret Key en variables de entorno (>256 bits)
- Claims custom: TenantId, CountryCode, CurrencyCode
- Refresh token en Redis con TTL
- Password hashing con BCrypt (cost factor: 12)

#### Definition of Done

- [ ] Login endpoint implementado
- [ ] JWT generation funcional
- [ ] Token validation middleware
- [ ] Refresh token implementado
- [ ] Tests de autenticación completos
- [ ] Tests de seguridad (tokens inválidos, expirados)
- [ ] Password hashing seguro
- [ ] Rate limiting en login (5 intentos/min)

---

## Epic 1: Multi-Currency Engine - User Stories

### US-004: Gestión de Monedas

**Como** Administrador del sistema
**Quiero** gestionar el catálogo de monedas
**Para** soportar operaciones multi-moneda en diferentes países

**Priority:** Must Have
**Story Points:** 8
**Sprint:** Fase 1 (Semana 4-7)
**Epic:** Epic 1
**RICE Score:** 160.0

#### Acceptance Criteria

**AC1: CRUD de Monedas**
- Given un administrador autenticado
- When gestiona monedas
- Then puede crear monedas con código ISO 4217 (ARS, USD, MXN, etc.)
- And nombre y símbolo
- And cantidad de decimales (default: 2, configurable hasta 6)
- And estado activo/inactivo

**AC2: Moneda Base del Sistema**
- Given la configuración del sistema
- When se define moneda base
- Then se establece USD como moneda de consolidación
- And todas las conversiones finales son a USD
- And no se puede cambiar moneda base con datos transaccionales

**AC3: Monedas por País**
- Given países configurados
- When se asignan monedas
- Then cada país tiene una moneda local por defecto
- And puede tener múltiples monedas activas
- And la moneda local se usa por defecto en transacciones

**AC4: Validaciones**
- Given operaciones con monedas
- When se realizan validaciones
- Then código ISO debe ser único
- And no se puede eliminar monedas con transacciones
- And monedas inactivas no se pueden usar en nuevas transacciones

#### Technical Notes

- Entidad: `Moneda.cs` en Domain Layer
- Enum: `CodigoMoneda` con ISO 4217
- Seed inicial: USD, ARS, MXN, CLP, PEN, COP, UYU
- Índice único en código ISO
- Soft delete para monedas

#### Definition of Done

- [ ] Entidad Moneda implementada
- [ ] CRUD API endpoints
- [ ] Seed data con monedas principales
- [ ] Validación ISO 4217
- [ ] Tests unitarios >90%
- [ ] Tests de validaciones
- [ ] Documentación Swagger
- [ ] No permite eliminación con datos

---

### US-005: Tipos de Cambio Automáticos

**Como** Sistema
**Quiero** obtener tipos de cambio automáticamente
**Para** mantener conversiones actualizadas sin intervención manual

**Priority:** Must Have
**Story Points:** 13
**Sprint:** Fase 1 (Semana 4-7)
**Epic:** Epic 1
**RICE Score:** 195.0

#### Acceptance Criteria

**AC1: Múltiples Fuentes de Tipos de Cambio**
- Given configuración de providers
- When se obtienen tipos de cambio
- Then intenta Banco Central de cada país (primario)
- And fallback a OpenExchangeRates API
- And fallback a XE.com API
- And registra qué fuente se usó

**AC2: Actualización Automática Diaria**
- Given un background job configurado
- When se ejecuta a las 8 AM hora local de cada país
- Then obtiene tipos de cambio para todas las monedas activas
- And actualiza tabla TipoCambio
- And registra fecha y hora de actualización
- And envía alerta si falla

**AC3: Storage de Tipos de Cambio**
- Given tipos de cambio obtenidos
- When se almacenan
- Then se guardan con: fecha, moneda origen, moneda destino, tipo compra, tipo venta
- And fuente del tipo de cambio
- And timestamp de actualización
- And mantiene historial completo

**AC4: Fallback y Resilience**
- Given falla de API primaria
- When se intenta obtener tipos
- Then usa siguiente provider en orden de prioridad
- And si fallan todos, usa último tipo de cambio disponible + alerta
- And implementa exponential backoff entre reintentos
- And timeout de 30 segundos por provider

#### Technical Notes

- Background job con Hangfire (cron: `0 8 * * *` por zona horaria)
- Implementar `IExchangeRateProvider` interface
- Providers: `BancoCentralProvider`, `OpenExchangeRatesProvider`, `XEProvider`
- Usar Polly para resilience (3 retries, circuit breaker)
- Cache en Redis con TTL 24 horas

#### Definition of Done

- [ ] Interface IExchangeRateProvider implementada
- [ ] 3 providers funcionando (Banco Central, OpenExchange, XE)
- [ ] Background job configurado
- [ ] Tabla TipoCambio con historial
- [ ] Polly resilience implementado
- [ ] Tests con mocks de APIs
- [ ] Tests de fallback
- [ ] Alertas configuradas

---

### US-006: Servicio de Conversión de Moneda

**Como** Sistema
**Quiero** convertir montos entre cualquier par de monedas
**Para** calcular correctamente valores en transacciones multi-moneda

**Priority:** Must Have
**Story Points:** 13
**Sprint:** Fase 1 (Semana 4-7)
**Epic:** Epic 1
**RICE Score:** 195.0

#### Acceptance Criteria

**AC1: Conversión entre Monedas**
- Given un monto, moneda origen, moneda destino, fecha
- When se solicita conversión
- Then busca tipo de cambio para esa fecha
- And si no existe, usa tipo de cambio más reciente
- And calcula: monto * tipo_cambio
- And retorna con 6 decimales de precisión

**AC2: Conversión Directa e Indirecta**
- Given un par de monedas sin tipo de cambio directo
- When se realiza conversión
- Then usa USD como moneda puente
- And convierte origen → USD → destino
- And mantiene precisión de 6 decimales

**AC3: Trazabilidad de Conversiones**
- Given una conversión realizada
- When se completa
- Then registra en tabla ConversionLog:
  - Fecha/hora
  - Monto origen y moneda
  - Monto destino y moneda
  - Tipo de cambio usado
  - Fuente del tipo de cambio
  - Usuario/sistema que solicitó
- And permite auditoría completa

**AC4: Performance y Cache**
- Given conversiones frecuentes
- When se realizan
- Then convierte en <100ms (P95)
- And cachea tipos de cambio del día en Redis
- And minimiza hits a base de datos

#### Technical Notes

- Service: `CurrencyConversionService : ICurrencyService`
- Método principal: `ConvertAsync(decimal amount, CurrencyCode from, CurrencyCode to, DateTime date)`
- Cache en Redis con key pattern: `exchange_rate:{from}:{to}:{date}`
- Logging estructurado de todas las conversiones
- Índices en tabla TipoCambio: (MonedaOrigenId, MonedaDestinoId, Fecha)

#### Definition of Done

- [ ] CurrencyConversionService implementado
- [ ] Conversión directa funcional
- [ ] Conversión indirecta (USD puente)
- [ ] Trazabilidad en ConversionLog
- [ ] Cache Redis implementado
- [ ] Performance <100ms validado
- [ ] Tests con todos los pares de monedas
- [ ] Tests de precisión (6 decimales)

---

**CONTINÚA EN PARTE 2...**

---

## 📝 Notas sobre este Documento

Este es la **Parte 1** del Product Backlog completo del Sistema ERP Multinacional.

**Contenido de Parte 1:**
- ✅ Resumen Ejecutivo
- ✅ Framework de Priorización
- ✅ Epics 0, 1, 2 (descripción completa)
- ✅ User Stories US-001 a US-006 (detalladas)

**Próximas Partes a Crear:**
- **Parte 2:** User Stories US-007 a US-025 (Multi-Currency, Stock, Compras)
- **Parte 3:** User Stories US-026 a US-045 (Tax Engines, Ventas, Contabilidad)
- **Parte 4:** RICE Scoring, Release Plan, Dependencies, Métricas

**Total Estimado:**
- ~50 User Stories detalladas
- 10 Epics completos
- ~992 Story Points
- 20-24 semanas de duración

---

**Versión:** 1.0 (Parte 1 de 4)
**Última Actualización:** 2025-10-11
**Estado:** READY FOR REVIEW
**Próximo Paso:** Crear Parte 2 del Backlog
