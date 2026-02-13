# IDEA-006: Integracion Claude Orchestrator con Project Admin

**Fecha:** 2026-02-12
**Categoria:** projects
**Estado:** Seed
**Prioridad:** Media

---

## Descripcion

Integrar Claude Orchestrator (orquestacion de sesiones Claude via Agent SDK) con el ecosistema Project Admin. Permite vincular sesiones a proyectos y stories.

## Alcance Estimado

Mediano (~4 sprints)

## Al arrancar

1. REST API layer para exponer datos de sesiones
2. Binding de sesiones a proyectos y stories
3. WebSocket auth contra Project Admin
4. Health checks bidireccionales

## Documentacion

- Integracion: `C:/claude_context/mcp/claude-orchestrator/ECOSYSTEM_INTEGRATION.md`
- Codigo: `C:/mcp/claude-orchestrator/`

## Dependencias

- Requiere Project Admin Backend con API funcional (IDEA-003)

---

## Historial

| Fecha | Evento |
|-------|--------|
| 2026-02-12 | Documento de integracion creado. Pendiente arranque. |
