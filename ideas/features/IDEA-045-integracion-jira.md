# IDEA-045: Integracion con JIRA

**Fecha:** 2026-03-06
**Categoria:** features
**Estado:** Seed
**Prioridad:** Sin definir

---

## Descripcion

Estudiar la API de JIRA y evaluar crear un MCP server o herramienta que permita gestionar issues, sprints y backlogs de JIRA desde Claude Code. Sincronizar con el flujo de trabajo actual (backlog, historias, sprint planning).

## Motivacion

Integrar la gestion de proyectos profesional (JIRA) con el ecosistema de Claude Code permitiria manejar todo desde un solo lugar: crear issues, planificar sprints, actualizar estados, y mantener sincronizado el backlog entre la metodologia local y JIRA.

## Alcance Estimado

Mediano

## Investigar

- JIRA REST API v3 (endpoints, rate limits, paginacion)
- Autenticacion: OAuth 2.0 vs API tokens (Atlassian Cloud)
- Mapeo entre formato de historias de la metodologia (PRODUCT_BACKLOG.md) y JIRA issues
- Operaciones clave: CRUD issues, gestionar sprints, transiciones de estado, busqueda JQL
- Evaluar si conviene MCP server dedicado o integracion en project-admin
- Alternativa: Atlassian Forge apps

## Proyectos Relacionados

- Project Admin MCP (`C:/mcp/project-admin`)
- Sprint Backlog Manager (`C:/mcp/sprint-backlog-manager`)
- Claude Orchestrator (`C:/mcp/claude-orchestrator`)

## Notas

- JIRA Cloud tiene API REST v3 bien documentada
- Existe SDK oficial de Atlassian para Node.js (`jira.js`)
- Considerar tambien Confluence para documentacion

---

## Historial

| Fecha | Evento |
|-------|--------|
| 2026-03-06 | Idea capturada |
