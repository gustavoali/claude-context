# Estado de Tareas - Claude Orchestrator

**Ultima actualizacion:** 2026-02-10 10:00
**Sesion activa:** Si

---

## Resumen Ejecutivo

**Proyecto:** MCP Server + WebSocket API para orquestar multiples sesiones de Claude Agent SDK.
**Fase actual:** Scaffolding completado. Pendiente: npm install, testing, integracion Flutter.

---

## Que YA Esta Hecho

### Documentacion (claude_context)
- `C:/claude_context/mcp/claude-orchestrator/CLAUDE.md` - Contexto del proyecto
- `C:/claude_context/mcp/claude-orchestrator/ARCHITECTURE.md` - Arquitectura completa
- `C:/claude_context/mcp/claude-orchestrator/TASK_STATE.md` - Este archivo

### Codigo (C:/mcp/claude-orchestrator/)

| Archivo | Estado | Descripcion |
|---------|--------|-------------|
| `package.json` | Completo | Deps: claude-agent-sdk, mcp/sdk, ws, express |
| `.env.example` | Completo | Template de config |
| `.gitignore` | Completo | node_modules, .env, etc |
| `README.md` | Completo | Setup, MCP config, protocolo WebSocket |
| `.claude/CLAUDE.md` | Completo | Puntero a claude_context |
| `src/config.js` | Completo | Config loader (env vars) |
| `src/agents/session-manager.js` | Completo | Core session management con EventEmitter |
| `src/mcp/tools/sessions.js` | Completo | 6 MCP tools para sesiones |
| `src/websocket/server.js` | Completo | WebSocket server con protocolo completo |
| `src/index.js` | Completo | MCP server entry point |
| `src/server.js` | Completo | WebSocket server standalone |
| `src/cli.js` | Completo | CLI (server, mcp, status, help) |

### MCP Tools Implementados

| Tool | Descripcion |
|------|-------------|
| `list_sessions` | Listar sesiones activas |
| `create_session` | Crear nueva sesion |
| `send_instruction` | Enviar prompt y obtener resultado |
| `get_session` | Obtener detalles de sesion |
| `stop_session` | Detener query activo |
| `end_session` | Terminar sesion |

### WebSocket Protocol Implementado

**Cliente → Servidor:**
- list_sessions
- create_session
- send_message
- stop_session
- end_session
- subscribe_session
- unsubscribe_session
- get_session

**Servidor → Cliente (push):**
- sessions_list
- session_created
- session_updated
- agent_message
- agent_complete
- agent_error
- session_ended
- subscribed

---

## Que FALTA Hacer

### Fase 1: Setup (inmediato) ✅ COMPLETADO
1. ✅ **npm install** en `C:/mcp/claude-orchestrator/`
2. ✅ **Crear .env** con ANTHROPIC_API_KEY
3. ✅ **Probar WebSocket server:** `npm run server` - Corriendo en ws://localhost:8765
4. ✅ **Probar MCP server:** `npm start`
5. ✅ **Inicializar git:** commit bd9e369

### Fase 2: Testing
1. Test basico de conexion WebSocket
2. Test de create_session
3. Test de send_instruction con Agent SDK real
4. Unit tests para session-manager

### Fase 3: Integracion Flutter (Fase B) - OTRO EQUIPO

**NOTA:** La implementacion en Flutter es responsabilidad del equipo claude-code-monitor-flutter.

**Responsabilidad de este equipo (orchestrator):**
- Mantener WebSocket API estable
- Documentar protocolo de mensajes
- Proveer ejemplos de uso
- Coordinar testing de integracion

**Responsabilidad del equipo Flutter:**
- Crear OrchestratorService
- Integrar en DashboardViewModel
- Crear UI components

**Documentacion de coordinacion:**
- Ver `C:/claude_context/apps/claude-code-monitor-flutter/TASK_STATE.md` seccion "Coordinacion entre Equipos"

### Fase 4: Integracion sprint-backlog-manager
- Conectar ambos MCP servers
- Asignar stories a sesiones
- Tracking de progreso

---

## Dependencias

### Claude Agent SDK
- Package: `@anthropic-ai/claude-agent-sdk`
- API: `query({ prompt, options })` → AsyncGenerator
- Docs: https://platform.claude.com/docs/en/agent-sdk/overview

### Proyecto Flutter relacionado
- Path: `C:/claude_context/apps/claude-code-monitor-flutter/`
- Estado: 96% completo (444 tests)
- WebSocket client: A implementar en Fase 3

---

## Stack

- **Runtime:** Node.js 18+
- **Agent SDK:** @anthropic-ai/claude-agent-sdk
- **MCP:** @modelcontextprotocol/sdk
- **WebSocket:** ws ^8.18.0
- **HTTP:** express ^4.21.0

---

## Notas para Nueva Sesion

1. Leer ARCHITECTURE.md para entender la estructura
2. Empezar por Fase 1 (npm install, .env, test basico)
3. El Session Manager ya implementa todo el lifecycle
4. El WebSocket server ya tiene protocolo completo
5. Para Flutter, empezar por OrchestratorService

---

## Referencias

- Agent SDK Docs: https://platform.claude.com/docs/en/agent-sdk/overview
- MCP SDK: https://github.com/modelcontextprotocol/sdk
- Flutter project: C:/claude_context/apps/claude-code-monitor-flutter/
