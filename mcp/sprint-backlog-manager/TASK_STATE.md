# Estado de Tareas - Sprint Backlog Manager

**Ultima actualizacion:** 2026-02-10 11:00
**Sesion activa:** Si

---

## Resumen Ejecutivo

**Proyecto:** MCP Server unificado - sprint tracking + backlog management con PostgreSQL.
**Fase actual:** Fases 1-6 completadas. Server MCP funcional con 25 tools + 4 resources + import script.
**Pendiente:** Fase 7 (CLI) y Fase 8 (Tests) - baja prioridad.

---

## Completado

### Fase 1: Setup
- npm install (361 packages, SDK 1.26.0)
- Docker PostgreSQL 17 (`sprint-backlog-pg`, `postgres:postgres@localhost:5432/sprint_backlog`)
- Migracion 001 aplicada (7 tablas + indices)
- Git init + commit inicial

### Fase 2: Repository Layer (6 archivos)
- `src/repositories/project-repository.js` - CRUD, findByPrefix
- `src/repositories/story-repository.js` - CRUD con filtros, archive, countByStatus, completed_at logic
- `src/repositories/sprint-repository.js` - CRUD, findActive, getBoard (kanban)
- `src/repositories/epic-repository.js` - CRUD, getWithStories
- `src/repositories/debt-repository.js` - CRUD, findHighRoi, excluye roi de writes
- `src/repositories/id-registry-repository.js` - getNextId atomico (UPSERT)

### Fase 3: Service Layer (8 archivos)
- `src/services/id-registry-service.js` - Genera PREFIX-NNN
- `src/services/project-service.js` - Validacion prefix unico, uppercase
- `src/services/story-service.js` - Auto external_id, validacion transiciones status
- `src/services/sprint-service.js` - 1 sprint activo por proyecto, board, burndown
- `src/services/epic-service.js` - Stats de completitud
- `src/services/debt-service.js` - Decision rules (ROI > 10 = fix now)
- `src/services/metrics-service.js` - Velocity, capacity, trend
- `src/services/archive-service.js` - Archive done stories

### Fase 4: MCP Tools + index.js (7 archivos)
- `src/index.js` - Reescrito con McpServer (high-level API)
- `src/mcp/tools/projects.js` - 3 tools
- `src/mcp/tools/stories.js` - 6 tools
- `src/mcp/tools/sprints.js` - 5 tools (incluye board y burndown)
- `src/mcp/tools/epics.js` - 4 tools
- `src/mcp/tools/debt.js` - 4 tools
- `src/mcp/tools/metrics.js` - 3 tools
- Total: 25 tools registrados, smoke test OK (create_project + create_story TST-001)

### Fase 5: MCP Resources (completado 2026-02-10)
- `src/mcp/resources/project-resources.js` - 4 resources registrados
- `project:///{id}/summary` - Resumen del proyecto con stats
- `project:///{id}/board` - Kanban del sprint activo
- `project:///{id}/backlog` - Indice del backlog agrupado por sprint
- `project:///{id}/metrics` - Velocity, capacity, burndown, debt summary

### Fase 6: Import desde sprint-tracker (completado 2026-02-10)
- `src/db/import-from-json.js` - Script de importacion (reescrito con mejor validacion)
- npm script: `npm run import -- <path> [--project-name "Name"] [--prefix PREFIX] [--force]`
- Mapea: project, sprint, tasks→stories, technicalDebt→technical_debt
- Linked story resolution para tech debt (linkedTask → linked_story_id)
- Type/status/priority mapping con validacion
- Actualiza id_registry automaticamente
- Soporta transacciones (rollback on error)
- Test exitoso: 7 stories + 7 debt items importados (LinkedIn data)
- Proteccion contra duplicados via prefix check
- Flag --force para eliminar proyecto existente y reimportar

### Configuracion
- Claude Desktop: `sprint-backlog` server configurado en `claude_desktop_config.json`
- Git: 6 commits en master (ultimo: feat(import): add --force flag)

---

## Pendiente

| Fase | Descripcion | Prioridad |
|------|-------------|-----------|
| 7 | CLI con commander.js | Baja |
| 8 | Tests Jest | Baja |

---

## Decisiones Tomadas

1. PostgreSQL via Docker en WSL2 (NO Docker Desktop) - container `postgres` (migrado 2026-02-10)
2. McpServer high-level API (no Server low-level) - SDK 1.26.0
3. zod/v4 para input schemas de tools
4. Directiva general: DBs siempre en Docker (agregada a 03-obligatory-directives.md v3.1)

---

## Infraestructura

- **Docker:** WSL2 Ubuntu (NO Docker Desktop, ver directiva 24-docker-wsl-directive.md)
- **Container:** `postgres` en WSL (postgres:16)
- **DB:** sprint_backlog en localhost:5432
- **Credenciales:** postgres:postgres
- **Node deps:** @modelcontextprotocol/sdk@1.26.0, pg@8.x, commander@12.x, dotenv@16.x

### Comandos Docker (desde Windows)
```bash
# Verificar estado
wsl -d Ubuntu docker ps --filter "name=postgres"

# Reiniciar container
wsl -d Ubuntu docker restart postgres

# Ver logs
wsl -d Ubuntu docker logs postgres
```
