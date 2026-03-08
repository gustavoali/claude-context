# Backlog - Unity MCP Server
**Version:** 3.0 | **Actualizacion:** 2026-02-25

## Resumen
| Metrica | Valor |
|---------|-------|
| Total historias | 31 |
| Total puntos | 95 |
| Completadas | 30 (92 pts) |
| Pendientes | 1 (3 pts) |
| Epics | 6 (5 Done, 1 In Progress) |
| Tools | 21 |
| Tests | 75 EditMode |
| E2E | 7/7 passing |

## Vision
A reusable UPM package implementing an MCP server inside Unity Editor. AI assistants communicate via a bridge process (stdio to named pipe) to automate scene setup, UI building, prefab management, and component wiring.

## Epics
| Epic | Historias | Puntos | Status |
|------|-----------|--------|--------|
| EPIC-001: Foundation & Transport (M0) | UMS-001 a UMS-005 | 18 | Done |
| EPIC-002: Core Scene Tools (M1) | UMS-006 a UMS-010 | 13 | Done |
| EPIC-003: UI Building Tools (M2) | UMS-011 a UMS-014 | 16 | Done |
| EPIC-004: Prefab & Asset Tools (M3) | UMS-015 a UMS-017 | 6 | Done |
| EPIC-005: Advanced Tools & Polish (M4) | UMS-018 a UMS-025 | 23 | Done |
| EPIC-006: Component Wiring & Scene Automation | UMS-026 a UMS-031 | 19 | In Progress (5/6 Done) |

## Pendientes (con detalle)

### UMS-031: Tests para nuevas herramientas
**Points:** 3 | **Priority:** High
**As a** developer **I want** EditMode tests for all new tools **so that** regressions are caught.
#### Acceptance Criteria
**AC1:** UMS-026: 8+ tests (Camera, Button, Image, TMP, custom MB, GameObject compat, asset ref, error).
**AC2:** UMS-027: 4+ tests (create, save, build settings, set_active).
**AC3:** UMS-028: 4+ tests (by type, name, folder, max_results).
**AC4:** UMS-029: 6+ tests (vertical, horizontal, grid, CSF, LE, update existing).
**AC5:** All pass in Unity Test Runner EditMode.
#### Technical Notes
- Follow patterns of existing 75 tests. Depends on UMS-026 to UMS-029.

## Desarrollo recomendado
**Ola 1 (paralelo):** UMS-026 + UMS-027 + UMS-028 (independientes, 11 pts)
**Ola 2 (paralelo):** UMS-029 + UMS-030 (independientes, 5 pts)
**Ola 3:** UMS-031 (tests, depende de Ola 1+2, 3 pts)

## Completadas (indice)
| ID | Titulo | Puntos | Fecha |
|----|--------|--------|-------|
| UMS-001 | Project setup - UPM package + Bridge | 3 | 2026-02-22 |
| UMS-002 | Bridge process - stdio to named pipe relay | 5 | 2026-02-22 |
| UMS-003 | Named pipe transport inside Unity Editor | 5 | 2026-02-22 |
| UMS-004 | Tool registry with attribute-based discovery | 3 | 2026-02-22 |
| UMS-005 | MCP server lifecycle and message routing | 3 | 2026-02-22 |
| UMS-006 | create_gameobject tool | 3 | 2026-02-22 |
| UMS-007 | add_component tool | 5 | 2026-02-22 |
| UMS-008 | set_transform tool | 2 | 2026-02-22 |
| UMS-009 | find_gameobject tool | 2 | 2026-02-22 |
| UMS-010 | delete_gameobject tool | 1 | 2026-02-22 |
| UMS-011 | create_canvas tool | 3 | 2026-02-22 |
| UMS-012 | create_ui_element tool | 5 | 2026-02-22 |
| UMS-013 | set_rect_transform tool | 3 | 2026-02-22 |
| UMS-014 | set_serialized_field tool | 5 | 2026-02-22 |
| UMS-015 | create_prefab tool | 3 | 2026-02-22 |
| UMS-016 | instantiate_prefab tool | 2 | 2026-02-22 |
| UMS-017 | save_scene tool | 1 | 2026-02-22 |
| UMS-018 | get_hierarchy tool | 2 | 2026-02-22 |
| UMS-019 | get_component_info tool | 3 | 2026-02-22 |
| UMS-020 | create_material tool | 3 | 2026-02-22 |
| UMS-021 | set_layer_tag tool | 1 | 2026-02-22 |
| UMS-022 | batch_operations tool | 3 | 2026-02-22 |
| UMS-023 | UndoHelper + SerializedPropertyHelper utilities | 3 | 2026-02-22 |
| UMS-024 | Integration tests (75 EditMode tests) | 5 | 2026-02-22 |
| UMS-025 | README, docs, installation guide | 2 | 2026-02-22 |
| UMS-026 | Component-typed field resolution | 5 | 2026-02-25 |
| UMS-027 | Scene management tools | 3 | 2026-02-25 |
| UMS-028 | Asset discovery tool | 3 | 2026-02-25 |
| UMS-029 | Layout component helpers | 2 | 2026-02-25 |
| UMS-030 | Auto-reconnect del server | 3 | 2026-02-25 |

## ID Registry
| Rango | Estado |
|-------|--------|
| UMS-001 a UMS-025 | Asignados (25 Done) |
| UMS-026 a UMS-031 | Asignados (EPIC-006 - Pending) |
Proximo ID: UMS-032
