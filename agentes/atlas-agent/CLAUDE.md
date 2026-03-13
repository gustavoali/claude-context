# Atlas Agent - Project Context
**Version:** 0.1.0 | **Tests:** 0 | **Estado:** Sprout (listo para desarrollo)
**Ubicacion:** C:/agentes/atlas-agent

## Concepto

Meta-sesion de Claude Code que opera sobre el orchestrator, coordinando sesiones worker autonomamente. Se comunica con el usuario via Telegram para escalaciones y reportes.

## Arquitectura (ADR-001)

El agente es una **sesion de Claude Code** (no un proceso standalone) que usa MCP tools existentes del ecosistema. Claude ya sabe coordinar - no hace falta programar logica de coordinacion en codigo imperativo.

```
Supervisor (Node.js ~100 lineas) -> spawn Claude Code (meta-session)
  Meta-session usa:
  - claude-orchestrator MCP (gestionar sesiones worker)
  - sprint-backlog-manager MCP (leer/actualizar historias)
  - project-admin MCP (registry, health de proyectos)
  - telegram-mcp (comunicacion con usuario)
```

## Stack

- **Runtime:** Node.js 18+
- **Meta-sesion:** Claude Code CLI via @anthropic-ai/claude-agent-sdk
- **Supervisor:** Node.js script (spawn + watchdog + restart)
- **Telegram:** node-telegram-bot-api o grammy
- **MCP:** @modelcontextprotocol/sdk (para telegram-mcp server)
- **Estado:** JSON file persistido a disco

## Prerequisitos

- Claude Orchestrator corriendo (WS :8765 + HTTP :3000)
- Sprint Backlog Manager MCP disponible
- Project Admin MCP disponible
- **ECO-001 (Mid-session injection)** implementado en orchestrator

## Componentes

| Componente | Ubicacion | Estado |
|------------|-----------|--------|
| Supervisor | src/supervisor.js | Scaffold |
| Config | src/config.js | Scaffold |
| System Prompt | prompts/coordinator.md | Scaffold |
| Telegram MCP Server | src/telegram-mcp/ | Scaffold |
| Estado persistente | state/ | Scaffold |

## Comandos

```bash
npm run start          # Lanzar supervisor + meta-session
npm run start:dev      # Modo desarrollo con logs verbose
npm test               # Tests
```

## Agentes Recomendados

| Tarea | Agente |
|-------|--------|
| Supervisor process | nodejs-backend-developer |
| Telegram MCP server | mcp-server-developer |
| System prompt | software-architect |
| Tests | test-engineer |
| Code review | code-reviewer |

## Reglas del Proyecto

1. El agente NUNCA toma decisiones destructivas sin consultar al usuario (merges, deletes, push a main)
2. Mid-session injection (ECO-001) es prerequisito bloqueante
3. MVP opera una sesion a la vez, no multi-proyecto
4. Limite de tokens configurable por sesion worker
5. Kill switch via Telegram: `/stop` detiene todo inmediatamente

## Docs

@C:/claude_context/agentes/atlas-agent/PRODUCT_BACKLOG.md
@C:/claude_context/agentes/atlas-agent/TASK_STATE.md
@C:/claude_context/agentes/atlas-agent/ARCHITECTURE_ANALYSIS.md
