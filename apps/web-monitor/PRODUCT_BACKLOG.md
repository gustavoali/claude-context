# Backlog - Angular Web Monitor

**Version:** 3.0
**Actualizacion:** 2026-02-15

---

## Resumen

| Metrica | Valor |
|---------|-------|
| Total Stories | 20 |
| Total Points | 60 |
| Completadas | 20 (60 pts) - Fase A + QA |
| Pendientes | 0 (0 pts) |

## Vision

Dashboard web Angular para monitoreo centralizado del ecosistema de desarrollo. Consume REST API de Project Admin Backend. Fase A (MVP) completada con vista de proyectos (cards, tabla, filtros, busqueda, detalle). Fases B y C agregan sprint tracking y sesiones Claude. Fase D rechazada.

---

## Epics

| Epic | Historias | Puntos | Status |
|------|-----------|--------|--------|
| EPIC-A: MVP - Dashboard de Proyectos | WM-001 a WM-012 | 42 | COMPLETADO |
| EPIC-QA: Quality Improvements (Code Review) | WM-013 a WM-020 | 18 | COMPLETADO |
| EPIC-B: Sprint Tracking | Por definir | TBD | FUTURO (next phase) |
| EPIC-C: Sesiones Claude | Por definir | TBD | FUTURO (post Fase B) |

---


## Completadas (indice)

| ID | Titulo | Puntos | Fecha |
|----|--------|--------|-------|
| WM-001 | Setup proyecto Angular 17+ con standalone components | 3 | 2026-02-15 |
| WM-002 | Configurar CI pipeline basica | 2 | 2026-02-15 |
| WM-003 | Implementar ProjectAdminService (HTTP client) | 3 | 2026-02-15 |
| WM-004 | Implementar state management simple para proyectos | 2 | 2026-02-15 |
| WM-005 | Dashboard principal con project cards | 5 | 2026-02-15 |
| WM-006 | Tabla alternativa con sorting y paginacion | 3 | 2026-02-15 |
| WM-007 | Filtros por clasificador, estado y stack | 3 | 2026-02-15 |
| WM-008 | Busqueda de proyectos por nombre | 2 | 2026-02-15 |
| WM-009 | Detalle de proyecto | 5 | 2026-02-15 |
| WM-010 | Layout shell con navegacion y responsive | 3 | 2026-02-15 |
| WM-011 | Docker setup para desarrollo local | 2 | 2026-02-15 |
| WM-012 | Ecosystem summary widget en dashboard | 3 | 2026-02-15 |
| WM-013 | Separar ProjectStore en stores por vista | 3 | 2026-02-15 |
| WM-014 | CSP header en Nginx | 1 | 2026-02-15 |
| WM-015 | CI pipeline con coverage y prod build | 2 | 2026-02-15 |
| WM-016 | Filtros dinamicos desde datos | 2 | 2026-02-15 |
| WM-017 | Extraer TagSeverity compartido | 1 | 2026-02-15 |
| WM-018 | Componentes LoadingState y ErrorState | 2 | 2026-02-15 |
| WM-019 | Accesibilidad cards y KPIs | 2 | 2026-02-15 |
| WM-020 | Health check real en sidebar | 2 | 2026-02-15 |

---

## ID Registry

| Rango | Estado |
|-------|--------|
| WM-001 a WM-012 | Completados (Fase A) |
| WM-013 a WM-020 | Asignados (EPIC-QA) |
| WM-021 a WM-050 | Reservado para Fase B (Sprint Tracking) |
| WM-051 a WM-080 | Reservado para Fase C (Sesiones Claude) |
| WM-081+ | Disponible |

**Proximo ID disponible:** WM-021

---

## Orden de Implementacion (EPIC-QA COMPLETADO)

EPIC-QA completado exitosamente con todas las mejoras de calidad. Fase A (MVP) + QA = 20 stories, 60 puntos.

Proxima fase: EPIC-B (Sprint Tracking) - por planificar.

---

## Decisiones Registradas

| Decision | Fecha | Fuente |
|----------|-------|--------|
| PrimeNG como UI library | 2026-02-14 | Business Stakeholder |
| Standalone components, NO NgModules | 2026-02-14 | Business Stakeholder |
| State management simple (NO NgRx) en Fase A | 2026-02-14 | Business Stakeholder |
| SSR no necesario | 2026-02-14 | Business Stakeholder |
| Auth no necesario en Fase A | 2026-02-14 | Business Stakeholder |
| Fase D rechazada | 2026-02-14 | Business Stakeholder |
| Kanban simplificado sin drag-drop en Fase B | 2026-02-14 | Business Stakeholder |

---

**Ultima actualizacion:** 2026-02-15
**Creado por:** Product Owner (agente)
