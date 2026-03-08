# Sprint Backlog Manager - Project Context

## Descripcion
MCP Server unificado que combina sprint tracking + backlog management con persistencia en PostgreSQL.
Evolucion de `C:/mcp/sprint-tracker/` (CLI con JSON) hacia un servidor MCP completo.

## Documentacion
@C:/claude_context/mcp/sprint-backlog-manager/ARCHITECTURE.md
@C:/claude_context/mcp/sprint-backlog-manager/LEARNINGS.md

## Stack
- **Runtime:** Node.js 20+
- **MCP SDK:** @modelcontextprotocol/sdk
- **Database:** PostgreSQL 16
- **ORM:** pg (driver directo) + migraciones SQL manuales
- **CLI:** Commander.js (interfaz secundaria)
- **Testing:** Jest

## Ubicacion del Proyecto
- **Codigo:** C:/mcp/sprint-backlog-manager/
- **Contexto:** C:/claude_context/mcp/sprint-backlog-manager/
- **Origen:** C:/mcp/sprint-tracker/ (CLI original, JSON persistence)

## Convenciones
- Codigo y comentarios en ingles
- Documentacion en espanol
- Nombres de tablas en snake_case
- MCP tools en snake_case (list_stories, create_story)
- Prefijos de ID por proyecto (LTE-001, API-001, etc.)

## Conexion PostgreSQL
- Default: postgresql://postgres:postgres@localhost:5435/sprint_backlog
- Docker container: sprint-backlog-pg (WSL2, port 5435)
- Configurable via DATABASE_URL env var

## Capacidades MCP (tools expuestos a Claude)
- Proyectos: list_projects, get_project, create_project
- Stories: list_stories, get_story, create_story, update_story, delete_story
- Sprints: list_sprints, get_sprint, create_sprint, get_sprint_board
- Epics: list_epics, get_epic, create_epic, update_epic
- Technical Debt: list_debt, create_debt, update_debt
- Metricas: get_velocity, get_capacity, get_burndown
- Archivado: archive_completed_stories
- GitHub Sync: create_github_issue, link_github_issue, sync_to_github, pull_from_github
