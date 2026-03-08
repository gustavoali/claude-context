# Gaia Protocol - Project Context
**Version:** 0.9.0 | **Tests:** 265 pasando | **Coverage:** ~80% engines
**Ubicacion:** C:/games/gaia-protocol
**Contexto:** C:/claude_context/games/gaia-protocol

## Descripcion
Juego 4X de estrategia por turnos con foco ecologico-sistemico. Conquista blanda via influencia, ciencia y gobernanza climatica. Mapa hexagonal, limites planetarios, Consejo Global multilateral.

## Stack
- **Frontend/Cliente:** Unity (C#) - Android (futuro PC/WebGL)
- **Nucleo Simulacion:** C# puro netstandard2.1 (engines deterministas)
- **Backend:** .NET 8 Clean Architecture (FUTURO, post-MVP)
- **Persistencia MVP:** JSON (System.Text.Json)
- **Data-driven:** Biomas, techs, policies en JSON

## Componentes
| Componente | Ubicacion | Estado |
|------------|-----------|--------|
| Simulation Core | src/GaiaProtocol.Core/ | Completo (S1-S6) |
| Core Tests | src/GaiaProtocol.Core.Tests/ | 265 tests |
| Save/Load | Core/Persistence/ | Completo |
| Balance Harness | Core/Simulation/BalanceHarness.cs | Completo |
| Unity Scripts | unity/Assets/Scripts/ | Completo (22 scripts) |
| Unity Plugins | unity/Assets/Plugins/GaiaProtocol/ | Core DLL importada |
| Data JSON | Tests/TestData/ + unity/Assets/Resources/Data/ | 6 biomas, 12 techs, 8 distritos, 8 politicas, 1 epica |
| Backend API | src/GaiaProtocol.Api/ | FUTURO |

## Unity Scripts (22 archivos)
| Carpeta | Scripts |
|---------|---------|
| Bootstrap/ | GameBootstrap |
| Game/ | GameManager, DataManager |
| Map/ | HexGridRenderer, HexMeshGenerator, HexSelector, CameraController, BiomeColors, OwnerBorderRenderer, InfluenceOverlay, HexPool |
| UI/HUD/ | GameHUD, CouncilButton, InfluenceToggleButton |
| UI/Panels/ | HexInfoPanel, DistrictBuildPanel, CouncilPanel, ProposalListItem, TreatyListItem, CouncilPrefabFactory |
| UI/Feedback/ | ActionFeedback, TooltipSystem, TooltipTrigger |
| Performance/ | PerformanceMonitor |

## Comandos
```bash
dotnet build src/GaiaProtocol.sln --no-incremental
dotnet test src/GaiaProtocol.sln
```

## Agentes Recomendados
| Tarea | Agente |
|-------|--------|
| Engines C# (Core) | `dotnet-backend-developer` |
| Tests de engines | `test-engineer` |
| Arquitectura | `software-architect` |
| User stories / backlog | `product-owner` |
| Code review | `code-reviewer` |
| Business decisions | `business-stakeholder` |

## Reglas del Proyecto
1. Engines puros (sin IO, deterministas): decimal para acumulaciones, PRNG con seed, OrderBy en iteracion
2. Data-driven: biomas/techs/policies en JSON, IDs string estables
3. Offline-first MVP, preparado para migrar a backend
4. Cada engine con unit tests (>80% coverage engines, >70% overall)

## Backlog
- 33 historias | 124 pts | 9 epics
- 31 completadas (119 pts) - Core C# + Unity Scripts
- 2 pendientes (5 pts) - GP-032 (Editor setup), GP-033 (MCP server)

## Docs
@C:/claude_context/games/gaia-protocol/TASK_STATE.md
@C:/claude_context/games/gaia-protocol/SEED_DOCUMENT.md
@C:/claude_context/games/gaia-protocol/ARCHITECTURE_ANALYSIS.md
@C:/claude_context/games/gaia-protocol/PRODUCT_BACKLOG.md
@C:/claude_context/games/gaia-protocol/BUSINESS_STAKEHOLDER_DECISION.md
@C:/claude_context/games/gaia-protocol/TEAM_ANALYSIS.md
@C:/claude_context/games/gaia-protocol/TEAM_DEVELOPMENT.md
