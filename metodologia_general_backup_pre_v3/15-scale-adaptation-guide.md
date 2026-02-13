# Scale Adaptation Guide - Metodología por Tamaño de Proyecto

**Versión:** 2.1
**Fecha:** 2025-10-16
**Estado:** GUÍA RECOMENDADA

---

## 🎯 Objetivo

**La metodología debe adaptarse al tamaño del proyecto, no al revés.**

Esta guía te ayuda a seleccionar el nivel apropiado de proceso, documentación y rigor según:
- Tamaño del equipo (1 persona vs 10+)
- Complejidad del proyecto (MVP vs Enterprise)
- Riesgo de negocio (Low vs Critical)

---

## 📊 Matriz de Escala de Proyectos

| Escala | Team Size | Complexity | Budget | Duration | Risk | Examples |
|--------|-----------|------------|--------|----------|------|----------|
| **Micro** | 1 developer | Simple MVP | <$10K | 1-3 months | Low | Personal project, prototype |
| **Small** | 2-3 developers | Standard app | $10K-50K | 3-6 months | Low-Medium | Startup MVP, internal tool |
| **Medium** | 4-8 developers | Multi-module | $50K-200K | 6-12 months | Medium | SaaS product, B2B platform |
| **Large** | 9-20 developers | Complex system | $200K-1M | 12-24 months | High | Enterprise software, multi-tenant |
| **Enterprise** | 20+ developers | Mission-critical | $1M+ | 24+ months | Critical | Banking, healthcare, government |

---

## 🔍 Escala 1: Micro Projects (1 developer)

### Características
- **Team:** 1 developer (tú)
- **Sprint:** 1 semana (5 días de trabajo)
- **Velocity:** 15-25 story points/sprint
- **Examples:** YouTube RAG Project, personal SaaS, portfolio projects

### Proceso Adaptado

**6 Fases → 3 Fases Simplificadas**

```
❌ NO USAR: Proceso completo de 6 fases para cada US
✅ USAR: Proceso simplificado para US ≤3pts (mayoría de las US)

Fase 1: Quick Diagnosis (30min-1h)
  - Mental model, no documento formal
  - Solo para features >5 pts: escribir DIAGNOSTIC_REPORT

Fase 2: Implementation (2-4h)
  - Código + Tests + Manual testing

Fase 3: Done (30min-1h)
  - Self-review + merge

TOTAL: 3-6 horas por US pequeña
```

**Definition of Ready:**
- ✅ **Level 1 (Minimum)** para US ≤3 pts (80% de tus US)
- ✅ **Level 2 (Standard)** para US 3-8 pts
- ❌ **Level 3 (Comprehensive)** solo para features críticas

**Two-Track Agile:**
- ⚠️ **Opcional** - Puedes hacer discovery on-the-fly
- ✅ Usar solo si trabajas en épicas grandes (>30 pts)
- Ejemplo: Durante Sprint N (implementando feature), preparar Sprint N+1 en momentos de espera (builds, deploys)

**Technical Debt:**
- ✅ **TD Register básico** (Google Sheet o Markdown simple)
- ✅ **ROI calculation** para TD items >8h fix cost
- ❌ **Strategic Debt** - No necesario en micro projects (horizons son cortos)

**Documentación:**
- ✅ README actualizado
- ✅ API docs (Swagger auto-generado)
- ✅ Commit messages claros
- ❌ DIAGNOSTIC_REPORT, PROJECT_PLAN para US pequeñas
- ❌ Architecture Decision Records (ADR) - Solo para decisiones grandes

### Quick Reference Micro Project

```bash
# Workflow diario típico
1. Pick US from backlog (ya tiene AC básicos)
2. Quick diagnosis (30 min): ¿Qué archivos tocar?
3. Implement + tests (2-4h)
4. Self-review (15 min)
5. Merge a develop
6. Mark as Done

Duración total: 3-5 horas por US
Velocidad: 3-5 US pequeñas por día
Sprint 5 días: 15-25 story points
```

---

## 🏢 Escala 2: Small Teams (2-3 developers)

### Características
- **Team:** 2-3 developers
- **Sprint:** 2 semanas (10 días de trabajo)
- **Velocity:** 60-80 story points/sprint
- **Examples:** Startup MVP, small SaaS, internal corporate tool

### Proceso Adaptado

**6 Fases → 4 Fases**

```
Fase 1: Diagnosis (1-2h por epic)
  - Documento DIAGNOSTIC_REPORT solo para epics
  - Para US individuales: quick diagnosis (30min)

Fase 2: Planning (1h)
  - PROJECT_PLAN básico (timeline, resources)
  - Sprint planning con todos

Fase 3: Product Backlog (2h)
  - PRODUCT_BACKLOG con US y AC
  - Priorización MoSCoW

Fase 4: Ejecución Simplificada
  - Implementación con code review (por otro developer)
  - Testing (unit + integration básica)
  - Deploy

SKIP Fase 4 formal (Business Stakeholder decision) →
  Decision implícita durante Sprint Planning
```

**Definition of Ready:**
- ✅ **Level 1 (Minimum)** para US ≤3 pts
- ✅ **Level 2 (Standard)** para mayoría de US (default)
- ✅ **Level 3 (Comprehensive)** para features críticas (auth, payments)

**Two-Track Agile:**
- ✅ **Recomendado** - Un developer en delivery, otro en discovery (alternando)
- Ejemplo Sprint N:
  - Dev 1: 80% delivery (implementar Epic N), 20% discovery (preparar Epic N+1)
  - Dev 2: 80% delivery, 20% code review + support

**Technical Debt:**
- ✅ **TD Register completo** con ROI calculations
- ✅ **Weekly review** de TD (15 min en sprint planning)
- ⚠️ **Strategic Debt** - Usar si project tiene horizons >6 months

**Documentación:**
- ✅ README + Getting Started guide
- ✅ API docs (Swagger)
- ✅ Architecture diagram básico
- ⚠️ ADR para decisiones arquitecturales importantes

---

## 🏢 Escala 3: Medium Teams (4-8 developers)

### Características
- **Team:** 4-8 developers + Tech Lead + Product Owner
- **Sprint:** 2 semanas
- **Velocity:** 150-250 story points/sprint
- **Examples:** ERP systems, B2B platforms, multi-tenant SaaS

### Proceso Adaptado

**6 Fases → 5 Fases** (Skip Fase 4 si stakeholder = Product Owner)

```
Fase 1: Diagnosis (2-8h por epic)
  - DIAGNOSTIC_REPORT formal para todos los epics
  - Quick diagnosis (30min-1h) para US individuales

Fase 2: Planning (2-4h por epic)
  - PROJECT_PLAN con timeline, risks, resources
  - Sprint planning con todo el equipo

Fase 3: Product Backlog (2-4h por epic)
  - PRODUCT_BACKLOG detallado
  - User stories con 3-5 AC mínimo

Fase 4: Business Decision (puede ser implícita si PO = stakeholder)
  - Approval durante sprint planning
  - O documento BUSINESS_STAKEHOLDER_DECISION para features grandes

Fase 5: Ejecución Completa
  - Implementación con agentes especializados
  - Code review obligatorio (otro developer)
  - Testing completo (unit + integration + E2E selected paths)

Fase 6: Validación
  - Sprint review con demo
  - Retrospectiva
  - Documentation actualizada
```

**Definition of Ready:**
- ✅ **Level 1 (Minimum)** para US ≤3 pts (refactors, tech debt)
- ✅ **Level 2 (Standard)** para mayoría de US (default - 70%)
- ✅ **Level 3 (Comprehensive)** para features críticas (20-30%)

**Two-Track Agile:**
- ✅ **OBLIGATORIO** - Máximo throughput
- Structure:
  - Track 1 (Discovery Team): Tech Lead + 1 developer (20% time)
  - Track 2 (Delivery Team): Resto del equipo (80-100% time)

**Technical Debt:**
- ✅ **TD Register completo** con dashboard
- ✅ **ROI calculations** obligatorias
- ✅ **Strategic Debt** tracking quarterly
- ✅ **15-20% sprint capacity** para pagar TD con ROI >10x

**Documentación:**
- ✅ README + Architecture docs + Runbooks
- ✅ API docs (Swagger + examples)
- ✅ ADR para todas las decisiones arquitecturales
- ✅ Onboarding guide para nuevos developers

---

## 🏢 Escala 4: Large Teams (9-20 developers)

### Características
- **Team:** Multiple teams (2-3 squads), architects, QA, DevOps
- **Sprint:** 2 semanas
- **Velocity:** 400-600 story points/sprint
- **Examples:** Enterprise ERPs, banking systems, large e-commerce

### Proceso Adaptado

**6 Fases Completas + Governance**

```
Fase 0: Epic Planning (antes de desarrollo)
  - Epic debe tener business case documentado
  - ROI esperado calculado
  - Approval de stakeholders

Fases 1-4: Discovery Track (1 sprint ahead)
  - TODOS los documentos formales obligatorios
  - Architectural review board para cambios grandes
  - Security review para features con PII/auth

Fase 5: Ejecución
  - Equipos especializados (Frontend, Backend, QA, DevOps)
  - Code review obligatorio + aprobación de Tech Lead
  - CI/CD pipelines con quality gates

Fase 6: Validación
  - QA formal (test plans, regression)
  - UAT (User Acceptance Testing) con stakeholders
  - Sign-off formal antes de production
```

**Definition of Ready:**
- ⚠️ **Level 1 (Minimum)** raro (solo small bug fixes)
- ✅ **Level 2 (Standard)** para US standard (60%)
- ✅ **Level 3 (Comprehensive)** para features medium-high risk (40%)

**Two-Track Agile:**
- ✅ **OBLIGATORIO** - Pipeline completo
- Structure:
  - Discovery Squad: Prepara Sprint N+1 (full time)
  - Delivery Squads: Ejecutan Sprint N (full time)
  - Rotation: Discovery squad cambia cada 2-3 sprints

**Technical Debt:**
- ✅ **TD Register** con métricas en dashboards (Grafana/similar)
- ✅ **ROI calculations** + costo de negocio incluido
- ✅ **Strategic Debt** revisión mensual
- ✅ **15-25% sprint capacity** dedicado a TD
- ✅ **TD budget** asignado por quarter

**Documentación:**
- ✅ Documentation completa obligatoria
- ✅ ADR para TODAS las decisiones
- ✅ Architecture diagrams (C4 model)
- ✅ API contracts formales (OpenAPI 3.0+)
- ✅ Runbooks, disaster recovery plans
- ✅ Security audit reports

---

## 🚀 Escala 5: Enterprise (20+ developers)

Similar a Large Teams pero con:
- ✅ Compliance obligatorio (SOC2, ISO27001, GDPR, etc.)
- ✅ Security first (penetration testing, threat modeling)
- ✅ Formal change management (CAB - Change Advisory Board)
- ✅ Observability completa (logs, metrics, traces, APM)
- ✅ DR/BC plans tested quarterly

---

## 🎯 Matriz de Decision: ¿Qué Usar de la Metodología?

| Feature | Micro (1 dev) | Small (2-3) | Medium (4-8) | Large (9-20) | Enterprise (20+) |
|---------|---------------|-------------|--------------|--------------|------------------|
| **Proceso 6 Fases** | 3 fases simplificadas | 4 fases | 5 fases | 6 fases completas | 6 fases + governance |
| **DoR Level** | Mostly L1 | L1 + L2 | L2 default | L2 + L3 | L3 default |
| **Two-Track Agile** | Opcional | Recomendado | Obligatorio | Obligatorio | Obligatorio |
| **TD Management** | Básico | Completo | Completo + Strategic | Dashboard + Budget | Enterprise-grade |
| **Documentation** | Minimal | Basic | Standard | Comprehensive | Complete + Compliance |
| **Code Review** | Self-review | Peer review | Mandatory peer | Mandatory + TL | Formal review board |
| **Testing** | Unit + Manual | Unit + Integration | Unit + Int + E2E | Full pyramid | Full + Security + Performance |
| **CI/CD** | Basic | Automated tests | Quality gates | Full gates + approvals | Formal deployment |
| **Observability** | Logs | Logs + basic metrics | Logs + Metrics | Full stack (LMT) | Enterprise APM |

---

## 📋 Ejemplo Práctico: Mismo Feature en Diferentes Escalas

**Feature:** "Implement user authentication with JWT"

### Micro Project (1 developer)
```
Time investment:
- Quick diagnosis: 30 min
- Implementation: 4h (JWT service + middleware + tests)
- Self-review: 15 min
- Manual testing: 30 min
TOTAL: 5.25 hours

Process:
- DoR Level 1 (AC básicos, no documento formal)
- Código + unit tests + manual testing
- Self-review y merge
- Deploy

Documentation:
- README updated (how to authenticate)
- Swagger auto-generated
- Commit message: "feat(auth): implement JWT authentication"
```

### Medium Team (6 developers)
```
Time investment:
- Diagnosis: 4h (security implications, architecture)
- Planning: 2h (timeline, resources)
- Backlog: 2h (US con AC detallados)
- Implementation: 12h (2 developers)
- Testing: 6h (unit + integration + E2E auth flows)
- Code review: 2h
- Security review: 2h
TOTAL: 30 hours

Process:
- DoR Level 3 (Comprehensive) - auth es crítico
- DIAGNOSTIC_REPORT formal
- Security considerations documented
- Code review + security review obligatorio
- Integration testing completo

Documentation:
- ADR: "Why JWT vs Session-based auth"
- API docs with auth examples
- Security documentation
- Runbook: "How to rotate JWT secrets"
```

### Large Team (15 developers)
```
Time investment:
- Epic planning: 8h (business case, ROI calculation)
- Diagnosis: 8h (architecture board review)
- Security threat modeling: 4h
- Planning: 4h
- Backlog: 4h
- Implementation: 20h (2 developers full time)
- QA testing: 12h (dedicated QA)
- Security testing: 8h (penetration test)
- Code review: 4h
- UAT: 4h (with stakeholders)
- Documentation: 4h
TOTAL: 80 hours

Process:
- DoR Level 3 mandatory
- Architecture Decision Record (ADR) reviewed by board
- Security audit pre-implementation
- Penetration testing post-implementation
- UAT with business stakeholders
- Formal sign-off required

Documentation:
- Complete ADR
- Security audit report
- API documentation comprehensive
- User documentation
- Admin documentation
- Disaster recovery procedures
- Compliance documentation (GDPR, SOC2)
```

---

## ✅ Checklist: ¿Estoy Usando la Escala Correcta?

### Red Flags: Over-Engineering (demasiado proceso)

❌ Equipo de 1 developer con proceso de 6 fases completas para cada US
❌ Escribir ADRs para decisiones triviales
❌ Meetings de 4 horas para planear una US de 2 puntos
❌ DoR Level 3 para todas las historias en proyecto simple
❌ Documentation exhaustiva para MVP que puede pivotar

**Síntomas:**
- Velocity baja (<50% del esperado)
- Frustración del equipo
- "Más tiempo en meetings que programando"
- Documentation desactualizada (porque es mucha)

**Solución:** Bajar un nivel de escala

### Red Flags: Under-Engineering (muy poco proceso)

❌ Team de 10+ developers sin code review
❌ Features críticas sin testing
❌ No hay documentation en proyecto de $500K
❌ Cambios arquitecturales sin consenso del equipo
❌ No tracking de technical debt en proyecto de 2 años

**Síntomas:**
- Bugs en producción frecuentes (>5/week)
- Onboarding de nuevos devs toma >1 mes
- "Nadie sabe cómo funciona X"
- Re-trabajo frecuente (>20%)
- Technical debt creciendo sin control

**Solución:** Subir un nivel de escala

---

## 🎯 Recomendación por Proyecto

### Proyecto YouTube RAG .NET (actual)
**Escala recomendada:** Micro (1 developer)

**Usar:**
- ✅ Proceso simplificado (3 fases)
- ✅ DoR Level 1 para mayoría de US
- ⚠️ Two-Track opcional (solo para épicas grandes)
- ✅ TD Register básico con ROI
- ✅ Documentation mínima pero clara

**No usar:**
- ❌ 6 fases completas para cada US
- ❌ BUSINESS_STAKEHOLDER_DECISION documents
- ❌ Formal architecture board
- ❌ Strategic Debt (horizons son cortos en MVP)

### Proyecto ERP Multinacional
**Escala recomendada:** Large (evolucionar de Medium a Large)

**Usar:**
- ✅ Proceso de 6 fases (con Phase 4 formal por regulaciones)
- ✅ DoR Level 2 default, Level 3 para tax engines
- ✅ Two-Track Agile obligatorio
- ✅ TD Register completo + Strategic Debt
- ✅ Documentation comprensiva
- ✅ ADR para decisiones de tax engines

**Justificación:**
- High regulatory risk (impuestos = legal implications)
- Multi-country = complejidad alta
- Tax engine errors cost $$$
- Long-term project (24+ months)

---

## 📚 Templates por Escala

### Micro Projects
```
DIAGNOSTIC_REPORT.md: Solo para epics >30 pts
PROJECT_PLAN.md: No requerido (sprint planning verbal)
PRODUCT_BACKLOG.md: Simple list de US con AC
```

### Small Teams
```
DIAGNOSTIC_REPORT.md: Para epics
PROJECT_PLAN.md: Básico (timeline + resources)
PRODUCT_BACKLOG.md: Completo
```

### Medium-Large Teams
```
DIAGNOSTIC_REPORT.md: Todos los epics
PROJECT_PLAN.md: Detallado con risks
PRODUCT_BACKLOG.md: Completo con priorización
BUSINESS_STAKEHOLDER_DECISION.md: Features >20 pts
ADR: Decisiones arquitecturales
```

---

**Estado:** GUÍA RECOMENDADA
**Aplicar:** Según tamaño del proyecto
**Revisar:** Cada 6 meses o cuando team size cambia significativamente
**Versión:** 2.1
