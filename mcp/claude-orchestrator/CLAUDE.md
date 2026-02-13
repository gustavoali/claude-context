# Claude Orchestrator - Contexto del Proyecto

## Descripcion

MCP Server y API WebSocket para orquestar multiples sesiones de Claude Agent SDK.
Permite a Claude Code (o la app Flutter) crear, controlar y monitorear multiples agentes trabajando en paralelo en diferentes proyectos.

## Stack Tecnologico

- **Runtime:** Node.js 18+
- **Agent SDK:** @anthropic-ai/claude-agent-sdk
- **MCP:** @modelcontextprotocol/sdk
- **WebSocket:** ws
- **HTTP (opcional):** express

## Estructura del Proyecto

```
C:/mcp/claude-orchestrator/
├── src/
│   ├── index.js              # MCP Server entry point (stdio)
│   ├── server.js             # WebSocket server standalone
│   ├── cli.js                # CLI entry point
│   ├── config.js             # Configuration loader
│   ├── agents/
│   │   └── session-manager.js # Core session management
│   ├── mcp/
│   │   └── tools/
│   │       └── sessions.js    # MCP tool handlers
│   └── websocket/
│       └── server.js          # WebSocket server
├── tests/
├── package.json
├── .env.example
└── README.md
```

## Interfaces

### 1. MCP Server (para Claude Code)

Ejecutar: `npm start` o `node src/index.js`

Tools disponibles:
- `list_sessions` - Listar sesiones activas
- `create_session` - Crear nueva sesion
- `send_instruction` - Enviar prompt a sesion
- `get_session` - Obtener detalles de sesion
- `stop_session` - Detener query activo
- `end_session` - Terminar sesion

### 2. WebSocket Server (para Flutter app)

Ejecutar: `npm run server` o `node src/server.js`

Puerto default: 8765 (configurable via WS_PORT)

Protocolo:
- Cliente envia: `{ type: "...", payload: {...} }`
- Servidor responde: `{ type: "...", payload: {...} }`
- Servidor pushea eventos de sesion automaticamente

## Dependencias de claude_context

Este proyecto se relaciona con:
- `C:/claude_context/apps/claude-code-monitor-flutter/` - Flutter app que consume la API WebSocket
- `C:/claude_context/mcp/sprint-backlog-manager/` - Posible integracion futura para asignar tareas del backlog a sesiones

## Configuracion

Variables de entorno (ver .env.example):
- `ANTHROPIC_API_KEY` - Requerido
- `WS_PORT` - Puerto WebSocket (default: 8765)
- `MAX_CONCURRENT_SESSIONS` - Maximo de sesiones (default: 10)

## Estado del Proyecto

**Fase:** Scaffolding completo
**Pendiente:**
- npm install
- Testear conexion con Agent SDK
- Implementar tests
- Integrar con Flutter app (Fase B)

## Documentacion Relacionada

@C:/claude_context/mcp/claude-orchestrator/ARCHITECTURE.md
@C:/claude_context/mcp/claude-orchestrator/TASK_STATE.md
