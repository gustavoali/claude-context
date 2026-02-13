# Claude Orchestrator - Arquitectura

**Version:** 1.0
**Fecha:** 2026-02-05

---

## Vision General

El Orchestrator actua como puente entre:
1. **Claude Code** (via MCP) - para orquestar sesiones desde la linea de comandos
2. **Flutter App** (via WebSocket) - para UI de monitoreo y control
3. **Claude Agent SDK** - para crear y controlar agentes programaticamente

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLIENTS                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────┐         ┌─────────────────────────────────┐    │
│  │ Claude Code │         │ Flutter App                     │    │
│  │ (MCP Client)│         │ (claude-code-monitor-flutter)   │    │
│  └──────┬──────┘         └──────────────┬──────────────────┘    │
│         │ MCP/stdio                     │ WebSocket              │
└─────────┼───────────────────────────────┼───────────────────────┘
          │                               │
┌─────────▼───────────────────────────────▼───────────────────────┐
│                    CLAUDE ORCHESTRATOR                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────┐       ┌─────────────────────────────┐      │
│  │   MCP Server    │       │   WebSocket Server          │      │
│  │   (stdio)       │       │   (ws://localhost:8765)     │      │
│  │                 │       │                             │      │
│  │   Tools:        │       │   Messages:                 │      │
│  │   - list_*      │       │   - list_sessions           │      │
│  │   - create_*    │       │   - create_session          │      │
│  │   - send_*      │       │   - send_message            │      │
│  │   - stop_*      │       │   - subscribe_session       │      │
│  │   - end_*       │       │   + push events             │      │
│  └────────┬────────┘       └──────────────┬──────────────┘      │
│           │                               │                      │
│           └───────────────┬───────────────┘                      │
│                           │                                      │
│              ┌────────────▼────────────┐                         │
│              │    Session Manager      │                         │
│              │    (EventEmitter)       │                         │
│              │                         │                         │
│              │    - sessions: Map      │                         │
│              │    - createSession()    │                         │
│              │    - sendMessage()      │                         │
│              │    - stopSession()      │                         │
│              │    - endSession()       │                         │
│              │    + events             │                         │
│              └────────────┬────────────┘                         │
│                           │                                      │
└───────────────────────────┼──────────────────────────────────────┘
                            │
┌───────────────────────────▼──────────────────────────────────────┐
│                    CLAUDE AGENT SDK                               │
│                 @anthropic-ai/claude-agent-sdk                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   query({                                                        │
│     prompt: "...",                                               │
│     options: {                                                   │
│       allowedTools: [...],                                       │
│       cwd: "/path/to/project",                                   │
│       resume: sessionId                                          │
│     }                                                            │
│   })                                                             │
│                                                                  │
│   → Yields: system, assistant, tool_use, tool_result messages    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                            │
          ┌─────────────────┼─────────────────┐
          │                 │                 │
     ┌────▼────┐       ┌────▼────┐       ┌────▼────┐
     │Agent    │       │Agent    │       │Agent    │
     │Session 1│       │Session 2│       │Session 3│
     │         │       │         │       │         │
     │Project: │       │Project: │       │Project: │
     │sprint-  │       │flutter  │       │api-     │
     │backlog  │       │monitor  │       │mobile   │
     └─────────┘       └─────────┘       └─────────┘
```

---

## Componentes

### 1. Session Manager (src/agents/session-manager.js)

Nucleo del orchestrator. Mantiene el estado de todas las sesiones.

```javascript
class SessionManager extends EventEmitter {
  sessions: Map<string, SessionInfo>

  // Lifecycle
  createSession({ cwd, name, allowedTools }) → SessionInfo
  endSession(sessionId)
  removeSession(sessionId)

  // Communication
  async *sendMessage(sessionId, prompt) → AsyncGenerator<Message>
  stopSession(sessionId)

  // Queries
  getSession(sessionId) → SessionInfo
  getAllSessions() → SessionInfo[]
  getActiveSessions() → SessionInfo[]

  // Maintenance
  cleanupStaleSessions(maxAgeMinutes)
  exportState() → Object

  // Events emitted
  'session:created', 'session:updated', 'session:message',
  'session:ended', 'session:error', 'session:stopped'
}
```

**SessionInfo:**
```typescript
interface SessionInfo {
  id: string;                    // UUID generado
  agentSessionId: string | null; // ID del Agent SDK (para resume)
  cwd: string;                   // Working directory
  name: string;                  // Friendly name
  status: 'idle' | 'working' | 'waiting_input' | 'ended' | 'error';
  statusDetail: string | null;   // e.g., "Using Bash..."
  createdAt: Date;
  updatedAt: Date;
  tokenUsage: { input: number; output: number };
  allowedTools: string[];
  controller: AbortController | null; // Para cancelar
}
```

### 2. MCP Server (src/index.js)

Expone session management via MCP protocol (stdio).

**Tools registrados:**

| Tool | Input | Output |
|------|-------|--------|
| `list_sessions` | `{ includeEnded?: boolean }` | `{ sessions: [...] }` |
| `create_session` | `{ cwd, name?, allowedTools? }` | `{ sessionId, name, cwd, status }` |
| `send_instruction` | `{ sessionId, prompt }` | `{ success, result, tokenUsage }` |
| `get_session` | `{ sessionId }` | `{ id, status, ... }` |
| `stop_session` | `{ sessionId }` | `{ success }` |
| `end_session` | `{ sessionId }` | `{ success }` |

### 3. WebSocket Server (src/websocket/server.js)

Comunicacion real-time con Flutter app.

**Protocolo:**

Cliente → Servidor:
```json
{ "type": "list_sessions" }
{ "type": "create_session", "payload": { "cwd": "..." } }
{ "type": "send_message", "payload": { "sessionId": "...", "prompt": "..." } }
{ "type": "stop_session", "payload": { "sessionId": "..." } }
{ "type": "end_session", "payload": { "sessionId": "..." } }
{ "type": "subscribe_session", "payload": { "sessionId": "..." } }
{ "type": "unsubscribe_session", "payload": { "sessionId": "..." } }
{ "type": "get_session", "payload": { "sessionId": "..." } }
```

Servidor → Cliente:
```json
{ "type": "sessions_list", "payload": [...] }
{ "type": "session_created", "payload": {...} }
{ "type": "session_updated", "payload": {...} }
{ "type": "agent_message", "sessionId": "...", "payload": {...} }
{ "type": "agent_complete", "sessionId": "..." }
{ "type": "agent_error", "sessionId": "...", "error": "..." }
{ "type": "session_ended", "sessionId": "..." }
{ "type": "subscribed", "sessionId": "..." }
{ "type": "error", "error": "..." }
```

**Subscription model:**
- Cliente puede suscribirse a sesiones especificas
- Solo recibe eventos de sesiones suscritas (excepto session_created que es broadcast)
- Auto-subscribe al crear sesion

---

## Flujos de Datos

### Flujo 1: Crear Sesion desde Flutter

```
Flutter                  WebSocket Server          Session Manager
   │                           │                         │
   │ create_session            │                         │
   │ {cwd: "/path"}            │                         │
   ├──────────────────────────>│                         │
   │                           │ createSession()         │
   │                           ├────────────────────────>│
   │                           │                         │ new SessionInfo
   │                           │ session_created event   │
   │                           │<────────────────────────┤
   │ session_created           │                         │
   │<──────────────────────────┤                         │
   │                           │                         │
```

### Flujo 2: Enviar Instruccion

```
Flutter                  WebSocket Server          Session Manager         Agent SDK
   │                           │                         │                      │
   │ send_message              │                         │                      │
   │ {sessionId, prompt}       │                         │                      │
   ├──────────────────────────>│                         │                      │
   │                           │ sendMessage()           │                      │
   │                           ├────────────────────────>│                      │
   │                           │                         │ query()              │
   │                           │                         ├─────────────────────>│
   │                           │                         │                      │
   │                           │                         │ message (stream)     │
   │                           │ session_message event   │<─────────────────────┤
   │ agent_message             │<────────────────────────┤                      │
   │<──────────────────────────┤                         │                      │
   │                           │                         │ message (stream)     │
   │ agent_message             │<────────────────────────│<─────────────────────┤
   │<──────────────────────────┤                         │                      │
   │                           │                         │ done                 │
   │ agent_complete            │<────────────────────────│<─────────────────────┤
   │<──────────────────────────┤                         │                      │
```

### Flujo 3: MCP Tool desde Claude Code

```
Claude Code              MCP Server              Session Manager         Agent SDK
   │                        │                         │                      │
   │ CallToolRequest        │                         │                      │
   │ send_instruction       │                         │                      │
   ├───────────────────────>│                         │                      │
   │                        │ handleSessionTool()     │                      │
   │                        ├────────────────────────>│                      │
   │                        │                         │ sendMessage()        │
   │                        │                         ├─────────────────────>│
   │                        │                         │ ... streaming ...    │
   │                        │                         │<─────────────────────┤
   │                        │<────────────────────────┤                      │
   │ ToolResult (JSON)      │                         │                      │
   │<───────────────────────┤                         │                      │
```

---

## Integracion con Flutter App

### Estado Actual del Flutter App

La app `claude-code-monitor-flutter` actualmente:
- Lee `~/.claude/dashboard-state.json` cada 3 segundos (polling)
- Muestra sesiones de Claude Code existentes
- Tiene integracion Telegram bidireccional
- Soporta Android via Telegram bridge

### Evolucion con Orchestrator (Fase B)

```
┌─────────────────────────────────────────────────────────────────┐
│                    Flutter App (Evolucionada)                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                   OrchestratorService                    │    │
│  │  (Reemplaza/complementa StateFileService)               │    │
│  │                                                          │    │
│  │  - WebSocket connection to ws://localhost:8765           │    │
│  │  - createSession(cwd, name)                              │    │
│  │  - sendInstruction(sessionId, prompt)                    │    │
│  │  - stopSession(sessionId)                                │    │
│  │  - Stream<OrchestratorEvent> events                      │    │
│  └─────────────────────────────────────────────────────────┘    │
│                              │                                   │
│  ┌───────────────────────────▼───────────────────────────────┐  │
│  │                   DashboardViewModel                       │  │
│  │  (Extendido)                                               │  │
│  │                                                            │  │
│  │  - Mantiene sessions de:                                   │  │
│  │    1. JSON file (Claude Code existentes)                   │  │
│  │    2. Orchestrator (sesiones creadas desde app)            │  │
│  │                                                            │  │
│  │  - Actions nuevas:                                         │  │
│  │    createSession() → UI para seleccionar proyecto          │  │
│  │    sendInstruction() → UI para escribir prompt             │  │
│  └────────────────────────────────────────────────────────────┘  │
│                              │                                   │
│  ┌───────────────────────────▼───────────────────────────────┐  │
│  │                      UI Components                         │  │
│  │                                                            │  │
│  │  - CreateSessionDialog (nuevo)                             │  │
│  │    - Selector de proyecto (recientes, browse)              │  │
│  │    - Nombre opcional                                       │  │
│  │    - Tools a permitir                                      │  │
│  │                                                            │  │
│  │  - SessionCard (extendido)                                 │  │
│  │    - Boton "Send Instruction" para sesiones orchestrator   │  │
│  │    - Streaming output en expansion                         │  │
│  │                                                            │  │
│  │  - InstructionInputSheet (nuevo)                           │  │
│  │    - Text field para prompt                                │  │
│  │    - Send button                                           │  │
│  │    - Cancel button (si working)                            │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Modelo de Datos Extendido

```dart
// Nuevo: Sesion desde Orchestrator
class OrchestratorSession {
  final String id;
  final String? agentSessionId;
  final String cwd;
  final String name;
  final OrchestratorSessionStatus status;
  final String? statusDetail;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TokenUsage tokenUsage;

  // Distincion de origen
  bool get isFromOrchestrator => true;
}

// Mensaje de agente (para streaming)
class AgentMessage {
  final String type;      // assistant, tool_use, tool_result
  final String? subtype;
  final String? content;
  final String? tool;
  final dynamic result;
}
```

---

## Seguridad

### Consideraciones

1. **API Key**: Nunca exponer via WebSocket. Solo en backend.
2. **Local only**: WebSocket server solo escucha en localhost por defecto.
3. **Permissions**: Agent SDK usa `bypassPermissions` - confiar en el orchestrator.
4. **Session isolation**: Cada sesion tiene su propio working directory.

### Para produccion

Si se necesita exponer fuera de localhost:
1. Agregar autenticacion al WebSocket (token en header)
2. Usar HTTPS/WSS
3. Limitar allowedTools por defecto
4. Logging de todas las operaciones

---

## Proximos Pasos (Roadmap)

### Fase A (Actual) - Scaffolding
- [x] Estructura de proyecto
- [x] Session Manager
- [x] MCP Server
- [x] WebSocket Server
- [x] Documentacion

### Fase B - Integracion Flutter
- [ ] OrchestratorService en Flutter
- [ ] UI para crear sesiones
- [ ] UI para enviar instrucciones
- [ ] Streaming de respuestas

### Fase C - Integracion sprint-backlog-manager
- [ ] Conectar con backlog MCP
- [ ] Asignar historias a sesiones
- [ ] Tracking de progreso

### Fase D - Produccion
- [ ] Tests completos
- [ ] Autenticacion WebSocket
- [ ] Logging y metricas
- [ ] CI/CD

---

**Revision:** 2026-02-05
**Estado:** Scaffolding completo
