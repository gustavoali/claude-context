# Angular Web Monitor - Project Plan

**Version:** 1.0
**Fecha:** 2026-02-14
**Estado:** APROBADO (GO Condicional)

---

## 1. Executive Summary

| Aspecto | Detalle |
|---------|---------|
| Proyecto | Angular Web Monitor - Dashboard SPA |
| Objetivo | Interfaz web para monitoreo centralizado del ecosistema de desarrollo |
| Fases aprobadas | A (GO), B (Condicional), C (Condicional), D (Rechazada) |
| Fase A scope | 12 stories, 34 puntos, 3 sprints |
| Timeline Fase A | Sprint 1-3 (~6 semanas calendario) |
| Equipo | 1 developer + agentes AI especializados |
| Dependencia critica | Project Admin Backend REST API operativa |
| Condicion bloqueante | API contracts definidos antes de codigo |

---

## 2. Timeline y Milestones

### Fase A: MVP - Dashboard de Proyectos

```
Semana 1-2:  Sprint 1 (Setup + Fundacion)     13 pts
Semana 3-4:  Sprint 2 (Core Features)          11 pts
Semana 5-6:  Sprint 3 (Completar MVP)          12 pts
Semana 7:    Deployment + Metricas baseline
```

### Milestones

| ID | Milestone | Cuando | Criterio de exito |
|----|-----------|--------|-------------------|
| M0 | API contracts definidos | Pre-Sprint 1 | Endpoints documentados, backend verificado |
| M1 | Fundacion completa | Fin Sprint 1 | Proyecto corriendo, CI verde, servicio HTTP funcional, layout shell |
| M2 | Features core | Fin Sprint 2 | Dashboard con cards, tabla, filtros operativos |
| M3 | MVP completo | Fin Sprint 3 | Todas las 12 stories DONE, Docker setup listo |
| M4 | Validacion post-MVP | Semana 7-8 | Dashboard en uso 3+ veces/semana |
| M5 | GO/NO-GO Fase B | Post M4 (4 semanas) | Metricas de uso positivas, time-box cumplido |

### Fases Futuras (sin sprint plan detallado)

| Fase | Scope | Estimacion | Prerequisito |
|------|-------|------------|--------------|
| B - Sprint Tracking | Burndown, velocity, stories, TD register | 2-3 sprints | M5 aprobado + Sprint Backlog Manager integrado |
| C - Sesiones Claude | Lista sesiones, metricas, historial | 1-2 sprints | Fase B validada + Claude Orchestrator WebSocket |
| D - Avanzado | RECHAZADA | N/A | Reevaluar 6 meses post-produccion |

---

## 3. Sprint Plan Detallado - Fase A

### Sprint 1: Setup + Fundacion (13 pts)

**Objetivo:** Proyecto Angular operativo con CI, servicio HTTP, state management y layout shell.

| Story | Pts | Asignado a | Horas est. | Dependencia |
|-------|-----|-----------|------------|-------------|
| WM-001: Setup Angular 17+ | 3 | frontend-angular-developer | 6h | M0 (API contracts) |
| WM-002: CI pipeline | 2 | devops-engineer | 4h | WM-001 |
| WM-010: Layout shell | 3 | frontend-angular-developer | 6h | WM-001 |
| WM-003: ProjectAdminService | 3 | frontend-angular-developer | 6h | WM-001, backend operativo |
| WM-004: State management | 2 | frontend-angular-developer | 4h | WM-003 |

**Paralelismo posible:**
- WM-001 primero (bloqueante para todo lo demas)
- WM-002 + WM-010 en paralelo (post WM-001)
- WM-003 en paralelo con WM-010
- WM-004 despues de WM-003

**Capacity:** 47h disponibles, 26h estimadas. Buffer amplio para setup imprevisto.

**Quality gate Sprint 1:**
- Build 0 errores, 0 warnings, strict mode
- ESLint pasando sin errores
- CI pipeline verde
- `ng serve` funcional en localhost:4200
- ProjectAdminService conecta al backend y retorna datos
- Layout shell renderiza correctamente en desktop

### Sprint 2: Core Features (11 pts)

**Objetivo:** Dashboard operativo con cards, tabla alternativa y filtros.

| Story | Pts | Asignado a | Horas est. | Dependencia |
|-------|-----|-----------|------------|-------------|
| WM-005: Dashboard con cards | 5 | frontend-angular-developer | 10h | WM-004, WM-010 |
| WM-006: Tabla alternativa | 3 | frontend-angular-developer | 6h | WM-005 (comparte datos) |
| WM-007: Filtros | 3 | frontend-angular-developer | 6h | WM-004 |

**Paralelismo posible:**
- WM-005 + WM-007 en paralelo (ambos dependen de WM-004)
- WM-006 despues de WM-005 (comparte layout)
- test-engineer: unit tests de Sprint 1 stories en paralelo con Sprint 2 dev

**Capacity:** 47h disponibles, 22h estimadas + tests. Buffer para iteracion visual.

**Quality gate Sprint 2:**
- Dashboard muestra proyectos reales del backend
- Toggle cards/tabla funcional
- Filtros aplican correctamente en ambas vistas
- Responsive en desktop (1200px+) y tablet (768px+)
- Unit tests para componentes y servicios (>70% coverage de features nuevos)
- Code review aprobado por code-reviewer

### Sprint 3: Completar MVP (12 pts)

**Objetivo:** MVP completo con busqueda, detalle, ecosystem summary y Docker.

| Story | Pts | Asignado a | Horas est. | Dependencia |
|-------|-----|-----------|------------|-------------|
| WM-008: Busqueda | 2 | frontend-angular-developer | 4h | WM-004 |
| WM-009: Detalle proyecto | 5 | frontend-angular-developer | 10h | WM-003, WM-010 |
| WM-012: Ecosystem summary | 3 | frontend-angular-developer | 6h | WM-004 |
| WM-011: Docker setup | 2 | devops-engineer | 4h | WM-001 (build funcional) |

**Paralelismo posible:**
- WM-008 + WM-009 + WM-012 en paralelo (features independientes)
- WM-011 (devops) en paralelo con todo el dev work
- test-engineer: E2E tests para flujo completo

**Capacity:** 47h disponibles, 24h estimadas + tests + E2E. Buffer para polish final.

**Quality gate Sprint 3 (MVP release):**
- Todas las 12 stories con AC verificados
- E2E test: dashboard -> filtrar -> buscar -> abrir detalle -> volver
- Lighthouse Performance score > 80
- Bundle size initial < 500KB
- Docker image funcional, docker-compose levanta stack completo
- Code review final aprobado
- 0 errores, 0 warnings en build y lint

---

## 4. Dependency Map

### Endpoints del Backend por Sprint

| Sprint | Endpoint requerido | Uso | Estado |
|--------|-------------------|-----|--------|
| 1 | GET /api/health | Footer: indicador de conexion | Verificar |
| 1 | GET /api/projects | Lista de proyectos | Verificar |
| 1 | GET /api/projects/:id | Detalle de proyecto | Verificar |
| 2 | GET /api/projects?clasificador=X&estado=Y | Filtros server-side (o client-side) | Verificar |
| 3 | (mismos endpoints) | Sin endpoints nuevos | - |

**Accion requerida (M0):** Verificar que Project Admin Backend expone estos endpoints con el schema esperado. Documentar response types exactos antes de Sprint 1.

### Dependencias Cross-Proyecto

| Proyecto | Fase que lo necesita | Tipo | Estado |
|----------|---------------------|------|--------|
| Project Admin Backend | A (MVP) | REST API operativa | Phase 1 completada - verificar endpoints |
| Sprint Backlog Manager | B | Formato datos sprint/backlog via Project Admin | Pendiente definicion |
| Claude Orchestrator | C | WebSocket protocol ws://localhost:8765 | Existente - no necesario ahora |

---

## 5. Risk Register

| ID | Riesgo | Prob | Impacto | Score | Mitigacion | Contingencia | Owner |
|----|--------|------|---------|-------|------------|--------------|-------|
| R1 | Backend no expone endpoints necesarios o schema difiere | Media | Alto | 6 | Verificar endpoints en M0 antes de codear | Mock service para desarrollo independiente | PM |
| R2 | Scope creep: agregar features no aprobados | Alta | Medio | 6 | Respetar MoSCoW estrictamente. Todo cambio por backlog | Rechazar en code review | PM/PO |
| R3 | PrimeNG no cubre componente necesario | Baja | Medio | 3 | Evaluar PrimeNG Showcase antes de Sprint 1 | Custom component puntual | Architect |
| R4 | Sprint 1 se extiende por setup imprevisto (Node versions, Angular CLI issues) | Media | Medio | 4 | Buffer amplio en Sprint 1 (47h cap, 26h est.) | Diferir WM-004 a Sprint 2 si es necesario | Dev |
| R5 | Time-box excedido (>3 sprints para Fase A) | Baja | Alto | 4 | Velocity tracking desde Sprint 1. Alerta si Sprint 2 no completa | Reducir scope Sprint 3 (diferir WM-012) | PM |
| R6 | Mantenimiento 2 frontends (Angular + Flutter) genera overhead | Media | Medio | 4 | Scope diferenciado, sin duplicacion de features | Pausar Flutter Monitor features superpuestos | BS |

**Escala:** Prob (1-3), Impacto (1-3), Score = Prob x Impacto. Score >= 6 = atencion inmediata.

---

## 6. Capacity Planning

### Parametros Base

| Parametro | Valor |
|-----------|-------|
| Developer | 1 |
| Sprint duration | 10 dias laborales |
| Horas efectivas/dia | 6h |
| Efficiency factor | 0.80 |
| Availability | 0.98 |
| Capacity bruta | 47h/sprint |
| Commitment (80%) | 37.6h |
| Buffer (20%) | 9.4h |

### Capacity por Sprint

| Sprint | Story pts | Horas estimadas (dev) | Tests + review | Total est. | Buffer real |
|--------|-----------|----------------------|----------------|------------|-------------|
| 1 | 13 | 26h | 8h | 34h | 13h (28%) |
| 2 | 11 | 22h | 10h | 32h | 15h (32%) |
| 3 | 12 | 24h | 12h | 36h | 11h (23%) |

**Nota:** Buffer saludable en todos los sprints. Sprint 1 tiene mas buffer por incertidumbre de setup. Sprint 3 incluye mas testing (E2E) y review final.

### Conversion estimada

| Metrica | Valor |
|---------|-------|
| Horas/punto (estimado) | ~2h |
| Puntos/sprint (capacity) | ~18 pts |
| Commitment (80%) | ~15 pts |
| Sprint mas cargado | Sprint 1 (13 pts) - dentro de commitment |

---

## 7. Quality Gates entre Sprints

### Gate 1: Sprint 1 -> Sprint 2

| Criterio | Obligatorio |
|----------|-------------|
| Proyecto Angular ejecuta sin errores (`ng serve`) | Si |
| CI pipeline verde (lint + test + build) | Si |
| ProjectAdminService conecta al backend real | Si |
| Layout shell renderiza con navegacion funcional | Si |
| Build: 0 errores, 0 warnings | Si |
| ESLint: 0 errores | Si |
| Unit tests para servicios creados | Si |

### Gate 2: Sprint 2 -> Sprint 3

| Criterio | Obligatorio |
|----------|-------------|
| Dashboard muestra proyectos del backend | Si |
| Toggle cards/tabla funcional | Si |
| Filtros operativos (al menos clasificador + estado) | Si |
| Responsive desktop verificado | Si |
| Code review aprobado por code-reviewer | Si |
| Coverage > 70% en features nuevos | Si |

### Gate 3: MVP Release

| Criterio | Obligatorio |
|----------|-------------|
| 12/12 stories completadas con AC verificados | Si |
| E2E test flujo completo pasando | Si |
| Lighthouse Performance > 80 | Si |
| Bundle size < 500KB | Si |
| Docker image funcional | Si |
| docker-compose levanta stack completo | Si |
| Code review final aprobado | Si |
| 0 errores, 0 warnings en build + lint | Si |
| Documentacion de setup en README | Si |

---

## 8. Checkpoints de Validacion

Alineados con Business Stakeholder Decision:

| Checkpoint | Cuando | Evaluador | Que se evalua | Accion si falla |
|------------|--------|-----------|---------------|-----------------|
| Pre-inicio | Antes de Sprint 1 | PM + Dev | API contracts definidos, backend verificado | NO iniciar hasta resolver |
| Mid-Fase A | Fin Sprint 2 | PM | Velocity, burndown, riesgos | Ajustar scope Sprint 3 si necesario |
| Post-Fase A | Fin Sprint 3 | Business Stakeholder | MVP completo, time-box cumplido | Retrospectiva obligatoria |
| Validacion uso | 4 semanas post-MVP | Business Stakeholder | Dashboard usado 3+ veces/semana | Si no: pausar Fases B/C |
| GO/NO-GO Fase B | Post validacion uso | Business Stakeholder | Metricas positivas, Sprint Backlog Manager listo | GO: planificar Fase B. NO-GO: pausar |

---

## 9. Equipo y Roles

| Rol | Agente | Responsabilidad principal |
|-----|--------|--------------------------|
| Frontend Developer (Lead) | frontend-angular-developer | Implementacion de todos los componentes |
| Test Engineer | test-engineer | Unit tests, component tests, E2E |
| Code Reviewer | code-reviewer | Review riguroso pre-merge |
| DevOps Engineer | devops-engineer | CI pipeline (Sprint 1), Docker (Sprint 3) |
| Architecture Advisor | software-architect | On-demand para decisiones tecnicas |

### Reglas de coordinacion

- Cada story se delega al agente con contexto completo (paths, specs, restricciones, AC)
- Code review obligatorio antes de considerar story DONE
- test-engineer puede trabajar en paralelo con frontend-developer
- devops-engineer trabaja en Sprint 1 (CI) y Sprint 3 (Docker), disponible on-demand

---

## 10. Communication Plan

| Evento | Frecuencia | Contenido |
|--------|-----------|-----------|
| Sprint planning | Inicio de sprint | Scope, capacity, stories seleccionadas |
| Daily status | Diario (en TASK_STATE.md) | Stories en progreso, blockers, completadas |
| Sprint review | Fin de sprint | Demo de features, velocity, burndown |
| Sprint retrospective | Fin de sprint | Que funciono, que mejorar, action items |
| Checkpoint Business | Fin Fase A + 4 semanas | Metricas de uso, GO/NO-GO |

---

## 11. Decisiones Registradas

| Decision | Fecha | Fuente | Impacto en plan |
|----------|-------|--------|-----------------|
| PrimeNG como UI library | 2026-02-14 | Business Stakeholder | Reduce estimaciones de componentes UI |
| Standalone components (NO NgModules) | 2026-02-14 | Business Stakeholder | Angular 17+ moderno, menos boilerplate |
| State management simple (NO NgRx Fase A) | 2026-02-14 | Business Stakeholder | Signals/BehaviorSubject, menos complejidad Sprint 1 |
| Auth no necesario Fase A | 2026-02-14 | Business Stakeholder | Elimina interceptor de auth de Sprint 1 |
| Time-box 3 sprints por fase | 2026-02-14 | Business Stakeholder | Constraint firme, ajustar scope si necesario |
| Fase D rechazada | 2026-02-14 | Business Stakeholder | No planificar features avanzados |
| Kanban simplificado Fase B | 2026-02-14 | Business Stakeholder | Lista con estados, sin drag-drop |

---

## 12. Definition of Done (proyecto)

Una story esta DONE cuando:

1. Codigo implementado y funcional
2. Unit tests escritos (>70% coverage del feature)
3. Component tests para componentes UI
4. Build: 0 errores, 0 warnings
5. ESLint: 0 errores
6. Code review aprobado por code-reviewer
7. AC validados manualmente con evidencia
8. Documentacion actualizada si aplica

---

**Ultima actualizacion:** 2026-02-14
**Creado por:** Project Manager (agente)
**Proxima revision:** Fin Sprint 1
