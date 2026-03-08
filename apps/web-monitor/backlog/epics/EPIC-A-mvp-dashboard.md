# EPIC-A: MVP - Dashboard de Proyectos

**Fecha:** 2026-02-14
**Status:** PENDIENTE
**Time-box:** 3 sprints (maximo, condicion del Business Stakeholder)

## Objetivo

Entregar un dashboard web funcional que muestre todos los proyectos del ecosistema con cards, tabla, filtros, busqueda y detalle. Primera fase del Angular Web Monitor.

## Scope

| ID | Titulo | Puntos | Prioridad |
|----|--------|--------|-----------|
| WM-001 | Setup proyecto Angular 17+ | 3 | Critical |
| WM-002 | CI pipeline basica | 2 | Critical |
| WM-003 | ProjectAdminService (HTTP client) | 3 | Critical |
| WM-004 | State management simple | 2 | High |
| WM-005 | Dashboard con project cards | 5 | Critical |
| WM-006 | Tabla alternativa con sorting/paginacion | 3 | High |
| WM-007 | Filtros por clasificador, estado, stack | 3 | High |
| WM-008 | Busqueda por nombre | 2 | High |
| WM-009 | Detalle de proyecto | 5 | High |
| WM-010 | Layout shell con navegacion | 3 | Critical |
| WM-011 | Docker setup | 2 | Medium |
| WM-012 | Ecosystem summary widget | 3 | Medium |
| **Total** | | **36** | |

## Criterios de Exito del Epic

1. Dashboard accesible en http://localhost:4200
2. Muestra proyectos reales del backend (no mocks en produccion)
3. Filtros y busqueda funcionales
4. Detalle de proyecto completo
5. Build 0 errores, 0 warnings
6. Test coverage > 70% unit, > 60% integration
7. Lighthouse performance > 80

## Dependencias

- Project Admin Backend REST API operativa (Phase 1 completada)
- API contracts definidos (condicion bloqueante del Business Stakeholder)

## Post-Epic Review

Medir despues de 3 meses en produccion:
- Se usa 3+ veces por semana? (condicion para GO de Fase B)
- FCP < 2s?
- Feedback del usuario?
