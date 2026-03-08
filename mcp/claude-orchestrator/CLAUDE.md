# Claude Orchestrator - Contexto del Proyecto

**Version:** 0.8.0 (pendiente bump)

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
│   │   ├── cli-session-manager.js  # CLI mode session management
│   │   ├── session-manager.js      # SDK mode session management
│   │   └── session-manager-factory.js # Factory CLI vs SDK
│   ├── mcp/
│   │   └── tools/
│   │       └── sessions.js    # MCP tool handlers
│   ├── websocket/
│   │   └── server.js          # WebSocket server
│   ├── http/
│   │   ├── server.js          # HTTP REST API
│   │   ├── routes/            # health.js, sessions.js
│   │   └── middleware/        # rate-limiter.js, error-handler.js
│   ├── integrations/
│   │   └── backlog-client.js  # Sprint backlog MCP client
│   └── utils/                 # logger.js, metrics.js, rate-limiter.js, serialize.js, message-queue.js, clean-env.js, webhook-emitter.js, auto-recovery.js, session-discovery.js, service-registry.js
├── tests/
├── package.json
├── .env.example
└── README.md
```

## Interfaces

### 1. MCP Server (para Claude Code)

Ejecutar: `npm start` o `node src/index.js`

Tools: list_sessions, create_session, send_instruction, get_session, stop_session, end_session, inject_message, bulk_stop_sessions, bulk_end_sessions, update_priority, discover_sessions

### 2. WebSocket Server (para Flutter/Angular app)

Ejecutar: `npm run server` o `node src/server.js`
Puerto default: 8765

### 3. HTTP REST API

Puerto default: 3000
Endpoints: GET /api/health, GET /api/sessions, GET /api/sessions/by-project, GET /api/sessions/:id, GET /api/sessions/health, GET /api/sessions/:id/activity, GET /api/sessions/:id/recovery-log, POST /api/sessions/discover

## Configuracion

Variables de entorno (ver .env.example):
- `ORCHESTRATOR_MODE` - sdk/cli/auto (default: auto, resuelve a CLI si no hay API key)
- `ANTHROPIC_API_KEY` - Solo para modo SDK
- `WS_PORT` / `HTTP_PORT` - Puertos (8765 / 3000)
- `WS_AUTH_TOKEN` / `HTTP_AUTH_TOKEN` - Auth opcional
- `BACKLOG_MCP_PATH` - Integracion sprint-backlog-manager
- `MAX_CONCURRENT_SESSIONS` - Maximo de sesiones (default: 10)
- `WEBHOOK_URL` / `WEBHOOK_EVENTS` / `WEBHOOK_*` - Webhook configuration
- `RECOVERY_*` - Auto-recovery configuration
- `SESSION_STALE_THRESHOLD_MINUTES` - Stale session detection threshold
- `SESSION_MAX_ACTIVITY_LOG` - Max activity log entries per session

## IMPORTANTE: Iniciar sin CLAUDECODE

Si se inicia desde dentro de Claude Code, el env var CLAUDECODE se hereda.
El server limpia esto para child processes, pero el propio process.env lo mantiene.
Usar ecosystem-start.sh o iniciar desde terminal limpia.

## Comandos

- `npm run server` - WS :8765 + HTTP :3000
- `npm start` - MCP server (stdio)
- `npm test` - 577 tests (23 suites)

## Estado del Proyecto

**Fase:** Backlog completado. Autonomous Agent Foundation implementada.
**Tests:** 577 pass, 23 suites

## Documentacion Relacionada

@C:/claude_context/mcp/claude-orchestrator/ARCHITECTURE.md
@C:/claude_context/mcp/claude-orchestrator/TASK_STATE.md
