# Inventario de Proyectos - Maquina de Desarrollo

**Fecha:** 2026-02-12
**Version:** 1.0
**Autor:** Claude (generado como seed inicial para Project Admin)
**Total de proyectos:** 26 (existentes) + 2 nuevos del ecosistema Project Admin

---

## Resumen Ejecutivo

Este documento contiene el inventario completo de los 26 proyectos de desarrollo encontrados en la maquina, excluyendo la carpeta `jerarquicos`. Sirve como seed de datos inicial para el sistema Project Admin.

### Estadisticas Generales

| Estado | Cantidad | Proyectos |
|--------|----------|-----------|
| Activo / En progreso | ~10 | AtlasOps, Mew Michis, LTE, Sprint Backlog Manager, Agenda, Recetario, Spoti-Admin, Tracking App, Claude Orchestrator, Project Admin |
| Legacy / Archivable | ~4 | YouTube RAG MVP, YouTube RAG .NET, YouTube RAG Old, Sprint Tracker |
| Scaffolding / Inicial | ~3 | Claude Code Monitor Flutter, Claude Code Monitor Swift, YouTube MCP |
| Solo documentacion / Sin codigo | ~3 | Plane Integracion, AnyoneAI Sprint 2, YouTube RAG (projects) |
| Incierto / Sin info clara | ~3 | LinkedIn RAG Agent, TensorLake AI, Chemical |
| Experimental | ~1 | YouTube Jupyter |
| Otros (vacios/starter) | ~2 | MyApplication, Anaconda Projects |

### Infraestructura

- **Disco unico:** C:
- **WSL:** Ubuntu y docker-desktop instalados, sin repositorios encontrados dentro de WSL
- **Docker Desktop:** Disponible para contenedores de desarrollo

---

## Inventario Detallado por Clasificador

### 1. agents/ - Agentes e Inteligencia Artificial

| # | Proyecto | Path | Clasificador | Stack | Estado | claude_context |
|---|----------|------|-------------|-------|--------|----------------|
| 1 | AtlasOps | `C:/agents/atlasOps` | agents | TypeScript (Fastify) + Python (FastAPI) + .NET 8 (ASP.NET Core) + PostgreSQL + Redis | En progreso (Epica 6 + PR Analyzer) | Si |
| 2 | LinkedIn RAG Agent | `C:/agents/linkedin_rag_agent` | agents | Python (app + ingest + notebooks) | Incierto | Parcial (solo README) |
| 3 | TensorLake AI | `C:/agents/tensor_lake_ai` | agents | Desconocido (subcarpeta tensorlake) | Incierto | Parcial (solo README) |
| 4 | YouTube Jupyter | `C:/agents/youtube_jupyter` | agents | Jupyter notebooks + videos descargados | Experimental | No |
| 5 | YouTube RAG MVP | `C:/agents/youtube_rag_mvp` | agents | Python (FastAPI + Alembic + Docker Compose) | Legacy | No directamente |
| 6 | YouTube RAG .NET | `C:/agents/youtube_rag_net` | agents | .NET (YoutubeRag.sln) | Legacy / Archivable | No directamente |
| 7 | YouTube RAG Old | `C:/agents/youtube_rag_old` | agents | Python (version anterior del RAG) | Legacy / Archivable | No |

### 2. apps/ - Aplicaciones Desktop y Multiplataforma

| # | Proyecto | Path | Clasificador | Stack | Estado | claude_context |
|---|----------|------|-------------|-------|--------|----------------|
| 8 | Mew Michis | `C:/apps/mew-michis` (+3 worktrees) | apps | Flutter (Dart, SQLite, Clean Architecture) | En progreso | Si |
| 9 | Claude Code Monitor (Flutter) | `C:/apps/claude-code-monitor/claude-code-monitor-flutter` | apps | Flutter | Scaffolding | Parcial |
| 10 | Claude Code Monitor (Swift) | `C:/apps/claude-code-monitor/claude-code-monitor-swift` | apps | Swift (macOS, Package.swift) | Scaffolding | No |
| 11 | Sudoku | `C:/apps/sudoku` | apps | Python (backend) + HTML/JS/CSS (frontend) | Incierto | No |

### 3. mcp/ - MCP Servers y Chrome Extensions

| # | Proyecto | Path | Clasificador | Stack | Estado | claude_context |
|---|----------|------|-------------|-------|--------|----------------|
| 12 | LinkedIn Transcript Extractor (LTE) | `C:/mcp/linkedin` (+4 worktrees) | mcp | Node.js + SQLite + Chrome Extension MV3 + Playwright | Activo (v0.12.0) | Si |
| 13 | Claude Orchestrator | `C:/mcp/claude-orchestrator` | mcp | Node.js + Agent SDK + WebSocket + MCP SDK | Scaffolding | Si |
| 14 | Sprint Backlog Manager | `C:/mcp/sprint-backlog-manager` | mcp | Node.js + PostgreSQL + MCP SDK | En progreso | Si |
| 15 | Sprint Tracker (legacy) | `C:/mcp/sprint-tracker` | mcp | Node.js CLI + JSON | Reemplazado por #14 | No |
| 16 | YouTube MCP | `C:/mcp/youtube` | mcp | (vacio en disco) | Solo documentacion PRD | Si (solo CLAUDE.md) |

### 4. mobile/ - Aplicaciones Moviles Flutter

| # | Proyecto | Path | Clasificador | Stack | Estado | claude_context |
|---|----------|------|-------------|-------|--------|----------------|
| 17 | Agenda | `C:/mobile/agenda` | mobile | Flutter (flutter_bloc + Hive + Clean Arch) | Funcional (timer implementado) | Si |
| 18 | Chemical | `C:/mobile/chemical` | mobile | Flutter (Dart) | Incierto | Parcial |
| 19 | Recetario | `C:/mobile/recetario` | mobile | Flutter (Riverpod + Drift/SQLite) | MVP Local completado | Si |
| 20 | Spoti-Admin | `C:/mobile/spoti-admin` | mobile | Flutter (Riverpod + Dio + Spotify OAuth) | En progreso | Si |
| 21 | Tracking App | `C:/mobile/tracking_app` | mobile | Flutter (Provider + SQLite + flutter_map) | v1.0.3 publicada | Si |

### 5. Solo Documentacion (sin codigo en disco)

| # | Proyecto | Clasificador | claude_context Path | Notas |
|---|----------|-------------|---------------------|-------|
| 22 | Plane Integracion (GitHub MCP) | mcp | `C:/claude_context/plane_integracion/` | Docs de integracion GitHub webhook, no se encontro repo |
| 23 | AnyoneAI Sprint 2 | personal | `C:/claude_context/anyoneai/sprint_2/` | Solo TASK_STATE.md |
| 24 | YouTube RAG (projects) | agents | `C:/claude_context/projects/youtuberag/` | Docs de arquitectura/backlog, vinculado a los youtube_rag_* |

### 6. Otros

| # | Proyecto | Path | Clasificador | Notas |
|---|----------|------|-------------|-------|
| 25 | MyApplication | `C:/Users/gdali/AndroidStudioProjects/MyApplication` | otros | Proyecto starter Android Studio (vacio) |
| 26 | Anaconda Projects | `C:/Users/gdali/anaconda_projects/` | otros | GUID + db, no parece activo |

---

## Ecosistema Project Admin

Los siguientes proyectos forman parte del ecosistema de monitoreo y administracion de proyectos:

| # | Proyecto | Rol en el Ecosistema | Estado |
|---|----------|---------------------|--------|
| 27 | Project Admin Backend | Backend API del sistema de administracion de proyectos | Nuevo (por crear) |
| 28 | Angular Web Monitor | Frontend web para visualizacion y gestion | Nuevo (por crear) |
| 9 | Claude Code Monitor (Flutter) | App desktop/mobile para monitoreo | Scaffolding |
| 13 | Claude Orchestrator | Orquestacion de agentes Claude via MCP | Scaffolding |
| 14 | Sprint Backlog Manager | Gestion de backlogs y sprints via MCP | En progreso |

**Nota:** Los proyectos #27 y #28 son nuevos componentes del ecosistema que se crearan como parte de la iniciativa Project Admin. No estan contados en el inventario original de 26 proyectos.

---

## Observaciones y Recomendaciones

### 1. YouTube RAG: Tres versiones del mismo concepto

Existen tres iteraciones del proyecto YouTube RAG:
- **YouTube RAG MVP** (#5): Python con FastAPI, la version mas completa
- **YouTube RAG .NET** (#6): Porteo a .NET, aparentemente abandonado
- **YouTube RAG Old** (#7): Version original, superada por MVP

**Recomendacion:** Archivar #6 y #7. Evaluar si #5 tiene valor como referencia o tambien puede archivarse.

### 2. Sprint Tracker es predecesor de Sprint Backlog Manager

Sprint Tracker (#15) fue reemplazado por Sprint Backlog Manager (#14) con una arquitectura mas robusta (PostgreSQL en lugar de JSON).

**Recomendacion:** Deprecar formalmente #15 una vez que la migracion de github-sync este completa en #14.

### 3. Proyectos en agents/ sin contexto centralizado

Varios proyectos en `C:/agents/` carecen de configuracion centralizada en `claude_context`:
- LinkedIn RAG Agent (#2): Solo tiene README
- TensorLake AI (#3): Solo tiene README
- YouTube Jupyter (#4): Sin contexto
- YouTube RAG MVP (#5): Sin contexto directo
- YouTube RAG Old (#7): Sin contexto

**Recomendacion:** Para los proyectos activos, crear estructura en `claude_context/agents/`. Para los legacy/archivables, no es necesario.

### 4. Worktrees de LTE pendientes de limpieza

El proyecto LTE (#12) tiene 4 worktrees activos:
- `linkedin-LTE-001`
- `linkedin-LTE-002`
- `linkedin-LTE-020`
- `linkedin-LTE-021`

**Recomendacion:** Verificar si las branches asociadas ya fueron mergeadas y limpiar los worktrees que ya no sean necesarios.

### 5. WSL sin repositorios

WSL tiene Ubuntu y docker-desktop instalados pero no se encontraron repositorios dentro del filesystem de WSL. Todo el desarrollo esta en el disco C: nativo de Windows.

### 6. Disco unico

La maquina cuenta con un solo disco (C:). No hay particiones adicionales ni discos externos configurados para desarrollo.

---

## Mapeo de Clasificadores para claude_context

| Clasificador | Carpeta en disco | Carpeta en claude_context | Proyectos |
|-------------|-----------------|--------------------------|-----------|
| agents | `C:/agents/` | `C:/claude_context/agents/` | #1-#7 |
| apps | `C:/apps/` | `C:/claude_context/apps/` | #8-#11 |
| mcp | `C:/mcp/` | `C:/claude_context/mcp/` | #12-#16, #22 |
| mobile | `C:/mobile/` | `C:/claude_context/mobile/` | #17-#21 |
| personal | -- | `C:/claude_context/anyoneai/` | #23 |
| projects | -- | `C:/claude_context/projects/` | #24 |
| otros | Varias ubicaciones | -- | #25-#26 |

---

## Historial de Cambios

| Fecha | Version | Descripcion |
|-------|---------|-------------|
| 2026-02-12 | 1.0 | Inventario inicial - seed de datos para Project Admin |
