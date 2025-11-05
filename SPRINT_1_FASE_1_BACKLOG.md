# Sprint 1 Backlog - Release v0.2.0 (Fase 1)
**Sprint Duration:** 2 semanas
**Sprint Goal:** Implementar el motor multi-moneda base del sistema
**Epic Focus:** Epic 1 - Multi-Currency Engine
**Team Velocity:** 40-50 puntos estimados
**Start Date:** 2025-10-13
**End Date:** 2025-10-27
**Branch:** `release/v0.2.0`

---

## 🎯 Sprint Goal

Implementar la **infraestructura base del motor multi-moneda**, incluyendo:
- Catálogo de monedas con ISO 4217
- Obtención automática de tipos de cambio desde múltiples fuentes
- Servicio de conversión entre monedas con trazabilidad
- Configuración multi-moneda por tenant

Este sprint establece los **cimientos del sistema multi-moneda**, permitiendo que todos los módulos posteriores (Stock, Compras, Ventas, Contabilidad) operen con múltiples monedas.

---

## 📋 User Stories Seleccionadas

### US-004: Gestión de Monedas
**Story Points:** 8
**Priority:** Must Have (P0)
**Assignee:** TBD

**Como** Administrador del sistema
**Quiero** gestionar el catálogo de monedas
**Para** soportar operaciones multi-moneda en diferentes países

#### Acceptance Criteria
- [ ] AC1: CRUD de Monedas con código ISO 4217 (ARS, USD, MXN, CLP, PEN, etc.)
- [ ] AC2: Moneda Base del Sistema (USD como moneda de consolidación)
- [ ] AC3: Monedas por País (cada país tiene moneda local por defecto)
- [ ] AC4: Validaciones (código ISO único, no eliminar con transacciones)

#### Technical Implementation
- Entidad `Moneda.cs` en Domain Layer
- Enum `CodigoMoneda` con ISO 4217
- Seed inicial: USD, ARS, MXN, CLP, PEN, COP, UYU
- API endpoints: GET/POST/PUT/DELETE /api/currencies

#### Definition of Done
- [ ] Entidad Moneda implementada con Fluent API configuration
- [ ] CRUD API endpoints funcionales
- [ ] Seed data con monedas principales (7+ monedas)
- [ ] Validación ISO 4217 implementada
- [ ] Tests unitarios >90% coverage
- [ ] Tests de integración para CRUD
- [ ] Documentación Swagger completa
- [ ] No permite eliminación con datos transaccionales

**Dependencies:** Ninguna (es la base)

---

### US-005: Tipos de Cambio Automáticos
**Story Points:** 13
**Priority:** Must Have (P0)
**Assignee:** TBD

**Como** Sistema
**Quiero** obtener tipos de cambio automáticamente
**Para** mantener conversiones actualizadas sin intervención manual

#### Acceptance Criteria
- [ ] AC1: Múltiples Fuentes - Banco Central (primario), OpenExchangeRates (fallback), XE.com (fallback)
- [ ] AC2: Actualización Automática Diaria a las 8 AM hora local de cada país
- [ ] AC3: Storage con historial completo (fecha, monedas, tipo compra/venta, fuente)
- [ ] AC4: Fallback y Resilience con exponential backoff, timeout 30s

#### Technical Implementation
- Background job con Hangfire (cron: `0 8 * * *` por zona horaria)
- Interface `IExchangeRateProvider`
- Providers: `BancoCentralProvider`, `OpenExchangeRatesProvider`, `XEProvider`
- Polly para resilience (3 retries, circuit breaker)
- Cache en Redis con TTL 24 horas
- Tabla `TipoCambio` con historial completo

#### Definition of Done
- [ ] IExchangeRateProvider interface implementada
- [ ] 3 providers funcionando (al menos con mocks en desarrollo)
- [ ] Background job configurado con Hangfire
- [ ] Tabla TipoCambio con historial y seed data inicial
- [ ] Polly resilience implementado (retries, circuit breaker)
- [ ] Tests con mocks de APIs externas
- [ ] Tests de fallback entre providers
- [ ] Alertas configuradas para fallos
- [ ] Cache Redis implementado

**Dependencies:** US-004 (Gestión de Monedas)

---

### US-006: Servicio de Conversión de Moneda
**Story Points:** 13
**Priority:** Must Have (P0)
**Assignee:** TBD

**Como** Sistema
**Quiero** convertir montos entre cualquier par de monedas
**Para** calcular correctamente valores en transacciones multi-moneda

#### Acceptance Criteria
- [ ] AC1: Conversión directa entre monedas con 6 decimales de precisión
- [ ] AC2: Conversión Indirecta usando USD como moneda puente
- [ ] AC3: Trazabilidad completa en tabla ConversionLog
- [ ] AC4: Performance <100ms (P95) con cache Redis

#### Technical Implementation
- Service: `CurrencyConversionService : ICurrencyService`
- Método: `ConvertAsync(decimal amount, CurrencyCode from, CurrencyCode to, DateTime date)`
- Cache en Redis: `exchange_rate:{from}:{to}:{date}`
- Logging estructurado de todas las conversiones
- Tabla `ConversionLog` para auditoría

#### Definition of Done
- [ ] CurrencyConversionService implementado en Application Layer
- [ ] Conversión directa funcional
- [ ] Conversión indirecta (USD como puente) funcional
- [ ] Trazabilidad en ConversionLog implementada
- [ ] Cache Redis implementado y funcional
- [ ] Performance <100ms validado con tests
- [ ] Tests con todos los pares de monedas (matriz completa)
- [ ] Tests de precisión (6 decimales verificados)
- [ ] Tests de conversión indirecta
- [ ] API endpoints expuestos

**Dependencies:** US-004 (Monedas), US-005 (Tipos de Cambio)

---

### US-009: Configuración Multi-Moneda por Tenant
**Story Points:** 8
**Priority:** Must Have (P1)
**Assignee:** TBD

**Como** Administrador de tenant
**Quiero** configurar monedas activas para mi empresa
**Para** controlar qué monedas se pueden usar en transacciones

#### Acceptance Criteria
- [ ] AC1: Configuración por Tenant (activar/desactivar monedas del catálogo global)
- [ ] AC2: Moneda Base y Alternativas (1 moneda base + hasta 5 alternativas)
- [ ] AC3: Validación en Transacciones (solo monedas activas permitidas)
- [ ] AC4: Cambio de Configuración con validaciones (no desactivar con saldo > 0)

#### Technical Implementation
- Tabla: `TenantCurrencyConfig` (many-to-many: Tenant ↔ Moneda)
- Validación en Application Layer
- Evento: `CurrencyConfigChangedEvent`
- Cache de configuración por tenant en Redis

#### Definition of Done
- [ ] TenantCurrencyConfig entidad implementada
- [ ] CRUD de configuración funcional (API endpoints)
- [ ] Validaciones en transacciones implementadas
- [ ] Tests de validación completos
- [ ] Cambio de configuración con validaciones de saldo
- [ ] Audit log de cambios de configuración
- [ ] Cache por tenant implementado
- [ ] Documentación de configuración para admins

**Dependencies:** US-004 (Monedas)

---

## 📊 Sprint Metrics

### Story Points Distribution
- **Total Story Points:** 42 puntos
- **Velocity Target:** 40-50 puntos

| User Story | Story Points | % del Sprint |
|------------|--------------|--------------|
| US-004     | 8            | 19%          |
| US-005     | 13           | 31%          |
| US-006     | 13           | 31%          |
| US-009     | 8            | 19%          |

### Priority Breakdown
- **Must Have (P0):** 3 historias (34 pts) - 81%
- **Must Have (P1):** 1 historia (8 pts) - 19%

---

## 🔗 Dependencies

```
US-004 (Monedas)
    ↓
US-005 (Tipos de Cambio) → US-006 (Conversión)
    ↓                           ↓
US-009 (Config por Tenant)
```

**Orden de Implementación Recomendado:**
1. **Semana 1:**
   - Días 1-2: US-004 (Gestión de Monedas) - 8 pts
   - Días 3-5: US-005 (Tipos de Cambio Automáticos) - 13 pts

2. **Semana 2:**
   - Días 6-8: US-006 (Servicio de Conversión) - 13 pts
   - Días 9-10: US-009 (Configuración por Tenant) - 8 pts

---

## 🎯 Sprint Success Criteria

El Sprint 1 será considerado **exitoso** si:

✅ **Funcionalidad Completa:**
- [ ] Todas las 4 User Stories completadas según Definition of Done
- [ ] Catálogo de monedas funcional con al menos 7 monedas
- [ ] Tipos de cambio actualizándose automáticamente (al menos con mocks)
- [ ] Conversiones funcionando entre todas las monedas
- [ ] Configuración por tenant operativa

✅ **Calidad:**
- [ ] Cobertura de tests >90% en todo el código nuevo
- [ ] 0 bugs críticos o bloqueantes
- [ ] Code review aprobado para todas las historias
- [ ] Performance validado (<100ms conversiones)

✅ **Integración:**
- [ ] CI/CD pipeline pasando (build + tests + migrations)
- [ ] Migraciones aplicadas exitosamente
- [ ] Documentación Swagger actualizada
- [ ] Seed data funcional para desarrollo y testing

✅ **Technical Debt:**
- [ ] No technical debt introducido
- [ ] Clean Architecture mantenida
- [ ] Código refactorizado donde necesario

---

## 🚀 Sprint Backlog por Día

### Week 1: Foundation (US-004, US-005)

#### Day 1-2: US-004 - Gestión de Monedas
- [ ] Crear entidad `Moneda` en Domain Layer
- [ ] Crear enum `CodigoMoneda` con ISO 4217
- [ ] Implementar FluentAPI configuration
- [ ] Crear repositorio y service en Application Layer
- [ ] Implementar API endpoints (CRUD)
- [ ] Crear seed data (USD, ARS, MXN, CLP, PEN, COP, UYU)
- [ ] Tests unitarios de entidad y validaciones
- [ ] Tests de integración de API
- [ ] Documentación Swagger

#### Day 3-5: US-005 - Tipos de Cambio Automáticos
- [ ] Crear tabla `TipoCambio` con migrations
- [ ] Implementar interface `IExchangeRateProvider`
- [ ] Implementar `BancoCentralProvider` (mock inicial)
- [ ] Implementar `OpenExchangeRatesProvider` (mock inicial)
- [ ] Implementar `XEProvider` (mock inicial)
- [ ] Configurar Hangfire background job
- [ ] Implementar Polly resilience policies
- [ ] Configurar Redis cache para tipos de cambio
- [ ] Tests de providers con mocks
- [ ] Tests de fallback entre providers
- [ ] Tests de background job
- [ ] Seed inicial de tipos de cambio históricos

### Week 2: Core Services (US-006, US-009)

#### Day 6-8: US-006 - Servicio de Conversión
- [ ] Crear tabla `ConversionLog` con migrations
- [ ] Implementar `CurrencyConversionService`
- [ ] Implementar conversión directa entre monedas
- [ ] Implementar conversión indirecta (USD como puente)
- [ ] Implementar trazabilidad en ConversionLog
- [ ] Configurar cache Redis para conversiones
- [ ] Implementar API endpoints de conversión
- [ ] Tests de conversión directa (todos los pares)
- [ ] Tests de conversión indirecta
- [ ] Tests de precisión (6 decimales)
- [ ] Tests de performance (<100ms)
- [ ] Tests de trazabilidad

#### Day 9-10: US-009 - Configuración Multi-Moneda por Tenant
- [ ] Crear tabla `TenantCurrencyConfig` con migrations
- [ ] Implementar validaciones de monedas activas por tenant
- [ ] Implementar CRUD de configuración
- [ ] Implementar evento `CurrencyConfigChangedEvent`
- [ ] Configurar cache de configuración por tenant
- [ ] Implementar audit log de cambios
- [ ] Tests de configuración
- [ ] Tests de validaciones en transacciones
- [ ] Tests de cambio de configuración
- [ ] Documentación para administradores

---

## 🔍 Sprint Review & Retrospective

### Sprint Review (Day 10 - última hora)
**Objetivo:** Demostrar las funcionalidades implementadas

**Demo Checklist:**
- [ ] Demo 1: Gestión de monedas (CRUD, validaciones)
- [ ] Demo 2: Tipos de cambio automáticos (background job, múltiples fuentes)
- [ ] Demo 3: Conversiones multi-moneda (directas e indirectas, performance)
- [ ] Demo 4: Configuración por tenant (activar/desactivar monedas)
- [ ] Mostrar cobertura de tests (>90%)
- [ ] Mostrar CI/CD pipeline (green)

### Sprint Retrospective (Day 10 - cierre)
**Preguntas clave:**
1. ¿Qué salió bien en este sprint?
2. ¿Qué podemos mejorar para el Sprint 2?
3. ¿Hubo blockers o impedimentos?
4. ¿La velocidad estimada (42 pts) fue realista?
5. ¿Necesitamos ajustar la Definition of Done?

---

## 📝 Notes & Risks

### Technical Risks
- **Riesgo:** APIs de Bancos Centrales pueden tener rate limits o estar caídas
  - **Mitigación:** Implementar mocks robustos para desarrollo, fallbacks múltiples

- **Riesgo:** Precisión de conversiones crítica (errores pueden costar millones)
  - **Mitigación:** Tests exhaustivos con 6 decimales, auditoría de cada conversión

- **Riesgo:** Performance de conversiones con alto volumen
  - **Mitigación:** Cache agresivo en Redis, índices optimizados en DB

### Assumptions
- Redis está disponible para caching
- Hangfire configurado para background jobs
- MySQL 8.0 como base de datos
- Polly library para resilience

### Out of Scope para Sprint 1
- ❌ US-007: API de Consulta de Tipos de Cambio (5 pts) → Sprint 2
- ❌ US-008: Auditoría de Conversiones (8 pts) → Sprint 2
- ❌ Diferencias de Cambio → Sprint 2
- ❌ Reexpresión Contable Mensual → Sprint 3+
- ❌ Integración real con APIs de Bancos Centrales → Sprint 2+

---

## 🔄 Next Steps (Post Sprint 1)

### Sprint 2 Planning Preview
**Candidatos para Sprint 2 de Fase 1:**
- US-007: API de Consulta de Tipos de Cambio (5 pts)
- US-008: Auditoría de Conversiones (8 pts)
- Comenzar Epic 2: Gestión de Inventario Multinacional
  - US-010: Estructura Regional Multi-País (13 pts)
  - US-011: Catálogo de Productos Multi-Precio (13 pts)

**Estimado Sprint 2:** ~40-45 puntos

---

## 📋 Context: Fase 1 (Release v0.2.0)

### Phase 1 Overview
**Duración Total:** 4 semanas (Semana 4-7 del proyecto)
**Release:** v0.2.0 - MVP Multi-Moneda + Stock + Compras
**Total Story Points:** 262 puntos

**Epics Incluidos:**
- **Epic 1:** Multi-Currency Engine (89 pts) ← Sprint 1
- **Epic 2:** Gestión de Inventario Multinacional (97 pts)
- **Epic 3:** Compras Multinacionales (76 pts)

### Sprint Distribution (Estimado)
- **Sprint 1 (Semana 4-5):** Epic 1 - Multi-Currency Engine (42 pts)
- **Sprint 2 (Semana 5-6):** Epic 1 completado + Epic 2 inicio (~50 pts)
- **Sprint 3 (Semana 6-7):** Epic 2 + Epic 3 inicio (~85 pts)
- **Sprint 4 (Semana 7):** Epic 3 completado + testing (~85 pts)

---

## 📚 Related Documents

- **Product Backlog Principal:** `C:/claude_context/PRODUCT_BACKLOG_ERP.md`
- **Product Backlog Parte 2:** `C:/claude_context/PRODUCT_BACKLOG_ERP_PARTE_2.md`
- **Release v0.1.0:** Completada (Epic 0 - Multi-Tenant Core Infrastructure)
- **Branch de Trabajo:** `release/v0.2.0`

---

**Document Version:** 1.0
**Created:** 2025-10-13
**Last Updated:** 2025-10-13
**Status:** ACTIVE SPRINT
**Release:** v0.2.0 (Phase 1 - MVP)
**Epic:** Epic 1 - Multi-Currency Engine
