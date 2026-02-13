# Project Admin - Project Context

## Descripcion
Backend central del ecosistema de administracion de proyectos. MCP Server + REST API para registro, metadata y estado de todos los proyectos de desarrollo.

## Ubicacion
- **Codigo:** C:/mcp/project-admin/
- **Contexto:** C:/claude_context/mcp/project-admin/
- **Clasificador:** mcp

## Stack Tecnologico
- **Runtime:** Node.js 20+
- **Framework:** Fastify 5.x
- **Base de datos:** PostgreSQL 17 (Docker, puerto 5433)
- **MCP:** @modelcontextprotocol/sdk
- **Validacion:** Zod 4.x
- **Modulos:** ESM (import/export)

## Documentacion del Proyecto
@C:/claude_context/mcp/project-admin/SEED_DOCUMENT.md
@C:/claude_context/mcp/project-admin/TEAM_PLANNING.md
@C:/claude_context/mcp/project-admin/TEAM_DEVELOPMENT.md
@C:/claude_context/mcp/project-admin/PROJECT_INVENTORY.md

## Ecosistema
Pieza central que integra:
- Sprint Backlog Manager (datos de sprints/backlogs)
- Claude Orchestrator (sesiones de agentes)
- Claude Code Monitor Flutter (dashboard mobile)
- Angular Web Monitor (dashboard web)

## Estado
**Fase:** Planificacion completada, pendiente implementacion Phase 1.

---

**Ultima actualizacion:** 2026-02-12
