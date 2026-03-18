# Backlog - Ecosystem Hub
**Version:** 1.0 | **Actualizacion:** 2026-03-17

## Resumen
| Metrica | Valor |
|---------|-------|
| Total Stories | 22 |
| Total Puntos | 67 |
| Epics | 4 |
| Pendientes | 22 |
| Completadas | 0 |

## Vision
Dashboard web unificado para administrar proyectos, ideas y alertas del ecosistema personal. MVP lee archivos MD/JSON directamente (sin DB para ideas/alertas). Extiende Project Admin (backend) y Web Monitor (frontend).

## Epics
| Epic | Historias | Puntos | Status |
|------|-----------|--------|--------|
| EPIC-01: Backend - File Parsers & REST | EH-001 a EH-005 | 15 | Pendiente |
| EPIC-02: Dashboard + Alertas UI | EH-006 a EH-012 | 22 | Pendiente |
| EPIC-03: Ideas UI | EH-013 a EH-017 | 17 | Pendiente |
| EPIC-04: Polish & Integracion | EH-018 a EH-022 | 13 | Pendiente |

## Pendientes (indice)

### EPIC-01: Backend - File Parsers & REST (~3 dias)
| ID | Titulo | Pts | Prioridad | Deps |
|----|--------|-----|-----------|------|
| EH-001 | Parser de ALERTS.md | 3 | Critical | - |
| EH-002 | Parser de IDEAS_INDEX.md e ideas individuales | 5 | Critical | - |
| EH-003 | REST endpoints alertas | 3 | Critical | EH-001 |
| EH-004 | REST endpoints ideas | 3 | Critical | EH-002 |
| EH-005 | REST endpoint proyectos agregado | 2 | High | - |

### EPIC-02: Dashboard + Alertas UI (~4 dias)
| ID | Titulo | Pts | Prioridad | Deps |
|----|--------|-----|-----------|------|
| EH-006 | Scaffold Angular app con routing y PrimeNG | 3 | Critical | - |
| EH-007 | Servicios HTTP Angular (alertas, ideas, proyectos) | 3 | Critical | EH-003, EH-004, EH-005 |
| EH-008 | Dashboard - resumen ejecutivo | 5 | Critical | EH-007 |
| EH-009 | Modulo Alertas - listado con tabs y filtros | 5 | High | EH-007 |
| EH-010 | Modulo Alertas - resolver/crear desde UI | 3 | High | EH-009 |
| EH-011 | Deadlines - CRUD con urgencia automatica | 3 | Medium | EH-009 |
| EH-012 | Proyectos - tabla con filtros y health | 3 | High | EH-007 |*nota: hereda vista de web-monitor*

### EPIC-03: Ideas UI (~3 dias)
| ID | Titulo | Pts | Prioridad | Deps |
|----|--------|-----|-----------|------|
| EH-013 | Modulo Ideas - listado con filtros | 5 | High | EH-007 |
| EH-014 | Ideas - formulario creacion/edicion inline | 3 | High | EH-013 |
| EH-015 | Ideas - transicion idea a proyecto | 5 | Medium | EH-014 |
| EH-016 | Ideas - vinculacion con proyectos existentes | 2 | Medium | EH-013 |
| EH-017 | Ideas - vista por proyecto (ideas relacionadas) | 2 | Low | EH-016 |

### EPIC-04: Polish & Integracion (~2 dias)
| ID | Titulo | Pts | Prioridad | Deps |
|----|--------|-----|-----------|------|
| EH-018 | Sync escritura alertas a ALERTS.md | 3 | High | EH-010 |
| EH-019 | Sync escritura ideas a archivos MD | 3 | Medium | EH-014 |
| EH-020 | Docker Compose unificado | 2 | Medium | EH-006 |
| EH-021 | Test suite E2E criticos | 3 | High | EH-008, EH-009, EH-013 |
| EH-022 | Documentacion de setup y uso | 2 | Medium | EH-020 |

## Completadas (indice)
| ID | Titulo | Puntos | Fecha | Detalle |
|----|--------|--------|-------|---------|
| - | - | - | - | - |

## ID Registry
| Rango | Estado |
|-------|--------|
| EH-001 a EH-022 | Asignados |
| EH-023+ | Disponibles |
Proximo ID: EH-023
