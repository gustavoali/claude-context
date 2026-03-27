# Backlog - Ecosystem Hub
**Version:** 1.2 | **Actualizacion:** 2026-03-27

## Resumen
| Metrica | Valor |
|---------|-------|
| Total Stories | 22 |
| Total Puntos | 67 |
| Epics | 4 |
| Pendientes | 5 |
| Completadas | 20 |

## Vision
Dashboard web unificado para administrar proyectos, ideas y alertas del ecosistema personal. MVP lee archivos MD/JSON directamente (sin DB para ideas/alertas). Extiende Project Admin (backend) y Web Monitor (frontend).

## Epics
| Epic | Historias | Puntos | Status |
|------|-----------|--------|--------|
| EPIC-01: Backend - File Parsers & REST | EH-001 a EH-005 | 15 | Done |
| EPIC-02: Dashboard + Alertas UI | EH-006 a EH-012 | 22 | Done |
| EPIC-03: Ideas UI | EH-013 a EH-017 | 17 | Done |
| EPIC-04: Polish & Integracion | EH-018 a EH-022 | 13 | Pendiente |

## Pendientes (indice)

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
| EH-001 | Parser de ALERTS.md | 3 | 2026-03-20 | Backend DB-backed (alert-parser.js ya existia) |
| EH-002 | Parser de IDEAS_INDEX.md | 5 | 2026-03-20 | Backend DB-backed (idea-parser.js ya existia) |
| EH-003 | REST endpoints alertas | 3 | 2026-03-20 | CRUD + resolve/reopen |
| EH-004 | REST endpoints ideas | 3 | 2026-03-20 | CRUD completo |
| EH-005 | REST endpoint deadlines | 2 | 2026-03-20 | CRUD + days_until_due computado |
| EH-006 | Scaffold Angular app | 3 | 2026-03-20 | App standalone con routing + PrimeNG |
| EH-007 | Servicios HTTP Angular | 3 | 2026-03-23 | Wiring completo a API real + mappers |
| EH-008 | Dashboard resumen ejecutivo | 5 | 2026-03-20 | Summary cards + alertas urgentes + ideas |
| EH-009 | Modulo Alertas - listado | 5 | 2026-03-20 | Tabs por scope + filtros + tabla |
| EH-010 | Alertas - resolver/crear UI | 3 | 2026-03-23 | Resolve/reopen + crear dialog |
| EH-011 | Deadlines CRUD | 3 | 2026-03-23 | Feature completa con semaforo |
| EH-012 | Proyectos - tabla con filtros | 3 | 2026-03-23 | Conectado a PA API |
| EH-013 | Ideas - listado con filtros | 5 | 2026-03-20 | Tabla + filtros + summary cards |
| EH-014 | Ideas - crear/editar inline | 3 | 2026-03-20 | Dialog reactivo + toast |
| EH-015 | Ideas - transicion idea a proyecto | 5 | 2026-03-27 | Dialog pre-llenado, createProject, slug validation |
| EH-016 | Ideas - vinculacion proyectos | 2 | 2026-03-27 | Link/unlink, columna proyecto, filtro |
| EH-017 | Ideas - vista por proyecto | 2 | 2026-03-27 | Seccion en detalle proyecto, navegacion cruzada |

## ID Registry
| Rango | Estado |
|-------|--------|
| EH-001 a EH-022 | Asignados |
| EH-023+ | Disponibles |
Proximo ID: EH-023
