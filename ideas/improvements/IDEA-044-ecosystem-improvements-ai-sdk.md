# IDEA-044: Mejoras al Ecosistema desde AI SDK Provider

**Fecha:** 2026-03-05
**Categoria:** improvements
**Estado:** Evaluating
**Prioridad:** Media

---

## Descripcion

Conjunto de mejoras derivadas de la investigacion del proyecto ai-sdk-provider-claude-code que pueden incorporarse al ecosistema existente (orchestrator, monitor, MCP servers).

## Mejoras Identificadas

### M1: Mid-session injection en Orchestrator
Incorporar el patron de inyeccion de mensajes entre tool calls para redirigir sesiones programaticamente sin terminarlas.

### M2: UI Web via AI SDK
Crear interfaz web alternativa usando Vercel AI SDK + este provider, con streaming real-time de tool execution.

### M3: Testing de MCP servers in-process
Usar `createCustomMcpServer()` para integration tests de project-admin y sprint-backlog-manager sin levantar procesos completos.

### M4: Subagent tracking en Monitor
Incorporar `parentToolCallId` para visualizar jerarquia de subagentes en claude-monitor.

## Alcance Estimado

Mediano (cada mejora individual es chica, el conjunto es mediano)

## Proyectos Relacionados

- Claude Orchestrator
- Claude Monitor (Flutter + Angular)
- Project Admin
- Sprint Backlog Manager
- AI SDK Provider Claude Code (fuente)

## Notas

- M1 y M4 son las de mayor impacto inmediato
- M2 podria ser un proyecto separado
- M3 mejora developer experience pero no es visible al usuario

---

## Historial

| Fecha | Evento |
|-------|--------|
| 2026-03-05 | Ideas identificadas durante investigacion ai-sdk-provider |
