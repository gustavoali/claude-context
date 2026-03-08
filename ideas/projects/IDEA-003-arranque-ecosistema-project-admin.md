# IDEA-003: Arranque Project Admin Backend

**Fecha:** 2026-02-12
**Categoria:** projects
**Estado:** In Progress
**Prioridad:** Alta

---

## Descripcion

Iniciar la implementacion del backend central del ecosistema Project Admin. Es prerequisito de todos los demas proyectos del ecosistema.

## Alcance Estimado

Grande (~172h en 4 fases)

## Al arrancar

1. Setup proyecto Node.js (Fastify 5.x, ESM, Zod 4.x)
2. PostgreSQL 17 en Docker (puerto 5433)
3. Modelo de datos (5 tablas: projects, project_dependencies, health_checks, tags, project_tags)
4. MCP tools con prefijo `pa_`
5. REST API (~20 endpoints)

## Documentacion

- Seed: `C:/claude_context/mcp/project-admin/SEED_DOCUMENT.md`
- Equipos: `TEAM_PLANNING.md`, `TEAM_DEVELOPMENT.md`
- Inventario: `PROJECT_INVENTORY.md`
- Codigo: `C:/mcp/project-admin/`

---

## Historial

| Fecha | Evento |
|-------|--------|
| 2026-02-12 | Planificacion completa. Pendiente arranque. |
| 2026-02-14 | Estado → In Progress. Phase 1 completa + TD fixes (commits activos). |
