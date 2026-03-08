# IDEA-007: Integracion Sprint Backlog Manager con Project Admin

**Fecha:** 2026-02-12
**Categoria:** projects
**Estado:** In Progress
**Prioridad:** Media

---

## Descripcion

Integrar Sprint Backlog Manager con el ecosistema Project Admin. Incluye exponer REST API, emitir webhooks, sincronizar proyectos y migrar github-sync desde Sprint Tracker.

## Alcance Estimado

Mediano-Grande (~4-6 sprints)

## Al arrancar

1. REST API layer sobre las funciones MCP existentes
2. Webhook emitter para notificar cambios a Project Admin
3. Migrar github-sync desde Sprint Tracker (decision documentada)
4. Sincronizacion bidireccional de proyectos

## Documentacion

- Integracion: `C:/claude_context/mcp/sprint-backlog-manager/ECOSYSTEM_INTEGRATION.md`
- Decision github-sync: `C:/claude_context/mcp/sprint-backlog-manager/GITHUB_SYNC_MIGRATION_DECISION.md`
- Codigo: `C:/mcp/sprint-backlog-manager/`

## Dependencias

- Requiere Project Admin Backend con API funcional (IDEA-003) para integracion completa
- La migracion de github-sync puede hacerse independientemente

---

## Historial

| Fecha | Evento |
|-------|--------|
| 2026-02-12 | Documento de integracion y decision github-sync creados. Pendiente arranque. |
| 2026-02-14 | Estado → In Progress. Import script + REST API layer activos. |
