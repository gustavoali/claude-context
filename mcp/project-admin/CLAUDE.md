# Project Admin - Project Context
**Version:** 0.2.0 | **Tests:** 160 unit tests | **Proyectos registrados:** 23
**Git:** Inicializado | **MCP:** Registrado globalmente | **Fase 1b:** GitHub Sync

## Ubicacion
- **Codigo:** C:/mcp/project-admin/
- **Contexto:** C:/claude_context/mcp/project-admin/
- **Clasificador:** mcp

## Stack
- Node.js 20+ | Fastify 5.x | PostgreSQL 17 (Docker WSL, puerto 5434)
- @modelcontextprotocol/sdk | Zod 3.x | pg 8.x | ESM | Jest 29.x

## Componentes
| Componente | Ubicacion | Estado |
|------------|-----------|--------|
| REST API (Fastify) | src/server.js | Funcional |
| MCP Server (stdio) | src/index.js | Funcional |
| Repositories (6) | src/repositories/ | Funcional (incluye ecosystem-repository) |
| Services (8) | src/services/ | Funcional (incluye github-sync-service) |
| MCP Tools (15) | src/mcp/tools/ | Funcional (incluye github-sync) |
| REST Routes (6 groups) | src/api/routes/ | Funcional (incluye github-sync) |
| Utils | src/utils/ | Funcional (incluye gh-cli) |
| Migrations | src/db/migrations/ | 001 aplicada |
| Seed | src/db/seed.js | 23 proyectos |
| Unit Tests (160) | tests/ | Pasando |

## Comandos
```bash
npm run start:api    # Fastify en :3000
npm run start:mcp    # MCP server stdio
npm run migrate      # Ejecutar migraciones
npm run seed         # Poblar datos iniciales
npm test             # Jest ESM (node --experimental-vm-modules)
```

## Endpoints REST
- `GET /health` - Health check (refleja estado real de DB)
- `GET/POST /api/v1/projects` - CRUD proyectos
- `GET/PUT/DELETE /api/v1/projects/:slug` - Proyecto individual
- `GET /api/v1/tags` - Listar tags
- `POST/DELETE /api/v1/projects/:slug/tags` - Tags por proyecto
- `GET /api/v1/projects/:slug/relationships` - Relaciones
- `POST/DELETE /api/v1/relationships` - CRUD relaciones
- `GET /api/v1/relationships/graph` - Grafo completo
- `POST /api/v1/scan` - Scan completo
- `POST /api/v1/scan/directory` - Scan directorio
- `GET /api/v1/ecosystem/stats` - Estadisticas
- `GET /api/v1/ecosystem/health` - Health ecosistema
- `POST /api/v1/github-sync/:slug` - Sync GitHub metadata individual
- `POST /api/v1/github-sync` - Sync GitHub metadata batch
- `GET /api/v1/projects/:slug/github` - GitHub metadata de un proyecto
- `GET /docs` - Swagger UI

## MCP Tools (prefijo pa_)
pa_list_projects, pa_get_project, pa_create_project, pa_update_project, pa_delete_project, pa_scan_directory, pa_scan_all, pa_project_health, pa_search_projects, pa_get_ecosystem_stats, pa_add_relationship, pa_get_relationships, pa_set_metadata, pa_github_sync, pa_github_sync_all

## Agentes Recomendados
| Tarea | Agente |
|-------|--------|
| Backend Node.js | nodejs-backend-developer |
| Tests | test-engineer |
| Code review | code-reviewer |
| DB queries/schema | database-expert |
| MCP tools | mcp-server-developer |

## Reglas del Proyecto
1. Shared Service Layer: MCP tools y REST routes usan los mismos services
2. Puerto PostgreSQL: 5434 (no 5432/5433, ambos ocupados)
3. Docker via WSL (no Docker Desktop)
4. Layered architecture estricta: routes/tools -> services -> repositories -> db

## Docs
@C:/claude_context/mcp/project-admin/TASK_STATE.md
@C:/claude_context/mcp/project-admin/ARCHITECTURE.md
@C:/claude_context/mcp/project-admin/PRODUCT_BACKLOG.md

---
**Ultima actualizacion:** 2026-02-15
