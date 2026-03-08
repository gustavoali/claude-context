# Backlog - Gaia Protocol
**Version:** 2.2 | **Actualizacion:** 2026-02-25

## Resumen
| Metrica | Valor |
|---------|-------|
| Total historias | 33 |
| Total puntos | 124 |
| Completadas | 31 (119 pts) |
| Pendientes | 2 (5 pts) |
| Epics | 9 (7 Done, 2 Pending) |
| Tests | 265 pasando |

## Vision
Gaia Protocol es un 4X por turnos con foco ecologico donde civilizaciones compiten por influencia, ciencia y estabilidad climatica. El MVP entrega una partida offline jugable en Android con mapa hexagonal, simulacion economica/climatica, sistema de influencia, Consejo Global basico y una epica completa (Restauracion Planetaria). Sin backend; offline-first.

## Epics
| Epic | Historias | Puntos | Status |
|------|-----------|--------|--------|
| EPIC-001: Foundation (M0) | GP-001 a GP-006 | 21 | Done |
| EPIC-002: Hex Map (M1) | GP-007 a GP-010 | 16 | Done |
| EPIC-003: Core Simulation (M2) | GP-011 a GP-015 | 21 | Done |
| EPIC-004: Player Actions (M3) | GP-016 a GP-020 | 21 | Done |
| EPIC-005: Influence System (M4) | GP-021 a GP-024 | 16 | Done |
| EPIC-006: Council & Epics (M5) | GP-025 a GP-027 | 13 | Done |
| EPIC-007: Polish & Balance (M6) | GP-028 a GP-031 | 11 | Done |
| EPIC-008: Unity Setup | GP-032 | 3 | Pending |
| EPIC-009: Unity Editor MCP Server (External) | GP-033 | 2 | Pending |

## Pendientes (con detalle)

### GP-032: Configurar proyecto Unity + importar Core
**Points:** 3 | **Priority:** Critical
**As a** developer **I want** proyecto Unity configurado con referencia al Core **so that** puedo implementar UI y rendering.
#### Acceptance Criteria
**AC1:** Given proyecto Unity, When abro en Editor, Then compila sin errores y referencia GaiaProtocol.Core.dll.
**AC2:** Given Assets/Plugins/, When inspecciono, Then contiene Core DLL compatible con Unity.
**AC3:** Given escena base, When ejecuto Play, Then no hay errores de runtime.
#### Technical Notes
- DLL ya importada en Assets/Plugins/GaiaProtocol/. Falta: crear escena con GameObjects, wiring de SerializeField references en Inspector, prefabs de UI.
- Todos los scripts estan escritos. Solo falta ensamblaje en Editor.

### GP-033: Integrate Unity MCP Server for automated scene setup
**Points:** 2 | **Priority:** High
**As a** developer **I want** the Unity MCP Server integrated as a tool in my Claude Code environment **so that** I can automate scene setup, prefab creation, and component wiring without manual Editor work.
#### Acceptance Criteria
**AC1:** Given unity-mcp-server is installed, When Claude needs to create GameObjects/UI, Then it can call MCP tools instead of giving manual instructions.
**AC2:** Given MCP server running in Unity Editor, When Claude calls create_gameobject or add_component, Then the operations execute in the Editor.
#### Technical Notes
- Dependency on external project: C:/tools/unity-mcp-server (UMS backlog)
- MCP server runs as Unity Editor extension, communicates via stdio
- Would accelerate GP-032 scene setup significantly

## Completadas (indice)
| ID | Titulo | Puntos | Sprint | Fecha |
|----|--------|--------|--------|-------|
| GP-001 | Setup solution y proyecto Core | 3 | S1 | 2026-02-21 |
| GP-002 | Modelo de dominio base | 5 | S1 | 2026-02-21 |
| GP-003 | Interfaces IEngine, TurnPipeline y TurnResult | 3 | S1 | 2026-02-21 |
| GP-004 | Data definitions y JsonDataProvider | 3 | S1 | 2026-02-21 |
| GP-005 | Archivos JSON de datos iniciales | 5 | S1 | 2026-02-21 |
| GP-006 | CI pipeline y .gitignore | 2 | S1 | 2026-02-21 |
| GP-007 | MapGenerator - generar mapa con biomas | 5 | S2 | 2026-02-21 |
| GP-008 | HexGrid rendering en Unity | 5 | Unity | 2026-02-24 |
| GP-009 | Seleccion de hex y panel de info | 3 | Unity | 2026-02-24 |
| GP-010 | GameManager y flujo de partida nueva | 3 | Unity | 2026-02-24 |
| GP-011 | EconomyEngine | 5 | S2 | 2026-02-21 |
| GP-012 | ClimateEngine | 5 | S2 | 2026-02-21 |
| GP-013 | EcologyEngine y SocialEngine | 5 | S2 | 2026-02-21 |
| GP-014 | Tests unitarios de engines (Economy + Climate) | 3 | S2 | 2026-02-21 |
| GP-015 | TurnSummary y notificaciones (Core logic) | 3 | S2 | 2026-02-21 |
| GP-016 | ActionValidator y sistema de acciones | 3 | S1 | 2026-02-21 |
| GP-017 | Construccion de distritos UI | 5 | Unity | 2026-02-24 |
| GP-018 | Sistema de investigacion tecnologica (Core) | 5 | S3 | 2026-02-21 |
| GP-019 | Sistema de politicas (Core) | 3 | S3 | 2026-02-21 |
| GP-020 | SimpleAI - IA basica | 5 | S3 | 2026-02-21 |
| GP-021 | InfluenceEngine - difusion y calculo | 5 | S4 | 2026-02-21 |
| GP-022 | UI de overlays de influencia | 3 | Unity | 2026-02-25 |
| GP-023 | Tests de InfluenceEngine | 3 | S4 | 2026-02-21 |
| GP-024 | Balance de factores de influencia | 5 | S4 | 2026-02-21 |
| GP-025 | DiplomacyEngine y Consejo Global | 5 | S5 | 2026-02-21 |
| GP-026 | EpicEngine y epica Restauracion Planetaria | 5 | S5 | 2026-02-21 |
| GP-027 | UI del Consejo Global | 3 | Unity | 2026-02-25 |
| GP-028 | Save/Load de partida (Core logic) | 5 | S6 | 2026-02-21 |
| GP-029 | Balance IA vs IA harness | 3 | S6 | 2026-02-21 |
| GP-030 | Optimizacion de performance Android | 2 | Unity | 2026-02-25 |
| GP-031 | UI/UX pulido final | 1 | Unity | 2026-02-25 |

## ID Registry
| Rango | Estado |
|-------|--------|
| GP-001 a GP-031 | Asignados (31 Done) |
| GP-032 | Asignado (Unity Editor Setup - Pending) |
| GP-033 | Asignado (EPIC-009 External Dependency - Pending) |
Proximo ID: GP-034
