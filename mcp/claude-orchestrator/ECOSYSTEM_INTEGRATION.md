# Claude Orchestrator - Integracion al Ecosistema Project Admin

**Version:** 1.0
**Fecha:** 2026-02-12
**Estado:** PLANIFICADO

---

## Estado Actual

| Aspecto | Detalle |
|---------|---------|
| **Path** | `C:/mcp/claude-orchestrator` |
| **Contexto** | `C:/claude_context/mcp/claude-orchestrator/` |
| **Stack** | Node.js 18+, @anthropic-ai/claude-agent-sdk, @modelcontextprotocol/sdk, ws |
| **Status** | Scaffolding completo (estructura + codigo, testing pendiente) |
| **Interfaces** | MCP Server (stdio) + WebSocket Server (ws://localhost:8765) |

### Funcionalidad Existente

**MCP Server (6 tools):**
`list_sessions`, `create_session`, `send_instruction`, `get_session`, `stop_session`, `end_session`

**WebSocket Server (puerto 8765):**
Protocolo request/response + push events. Subscription model por sesion.

### Conexiones Actuales

| Cliente | Protocolo | Proposito |
|---------|-----------|-----------|
| Claude Code | MCP (stdio) | Orquestar sesiones desde CLI |
| Flutter App | WebSocket | UI de monitoreo y control real-time |

---

## Rol en el Ecosistema

El Claude Orchestrator es el **motor de ejecucion de agentes** del ecosistema. Cualquier componente que necesite crear, controlar o monitorear sesiones de Claude Agent SDK lo hace a traves del Orchestrator.

### Que Provee al Ecosistema

- **Gestion de sesiones:** CRUD de sesiones Claude Agent SDK con lifecycle completo
- **Streaming real-time:** Push events de mensajes de agente, cambios de estado, errores
- **Estado de sesiones:** Lista de sesiones activas por proyecto, con token usage y status
- **Control remoto:** Cualquier cliente autorizado puede crear sesiones y enviar instrucciones

### Que Consume del Ecosistema

| Fuente | Datos | Uso |
|--------|-------|-----|
| **Project Admin Backend** | Lista de proyectos registrados | Validar que el cwd de una sesion corresponde a un proyecto conocido |
| **Sprint Backlog Manager** (via Project Admin) | Story asignada a sesion | Vincular sesiones con stories del backlog |
| **Claude Agent SDK** (Anthropic) | API de ejecucion de agentes | Motor subyacente para crear y controlar agentes |

---

## Puntos de Integracion

### 1. REST API - Expuesta a Project Admin Backend (NUEVO)

```
Project Admin Backend --> Orchestrator REST API

GET  /api/sessions                    --> Todas las sesiones activas
GET  /api/sessions?project=<cwd>      --> Sesiones de un proyecto especifico
GET  /api/sessions/:id                --> Detalle de sesion
POST /api/sessions                    --> Crear sesion
POST /api/sessions/:id/instruction    --> Enviar instruccion
POST /api/sessions/:id/stop           --> Detener sesion
DELETE /api/sessions/:id              --> Terminar sesion
GET  /api/health                      --> Health check
GET  /api/stats                       --> Estadisticas globales
```

### 2. WebSocket - Para Clientes Real-Time (EXISTENTE + EXTENDER)

Extensiones para ecosistema:
- Agregar campo `projectId`/`projectPrefix` a `SessionInfo`
- Agregar evento `session_progress` con porcentaje estimado
- Broadcast de estadisticas periodicas
- Soporte de autenticacion por token en handshake WebSocket

### 3. Event Bus - Notificaciones al Ecosistema (NUEVO)

| Evento | Payload | Consumidores |
|--------|---------|-------------|
| `session.created` | `{ sessionId, cwd, projectPrefix, name }` | Project Admin |
| `session.completed` | `{ sessionId, tokenUsage, duration }` | Project Admin, Sprint Backlog |
| `session.error` | `{ sessionId, error, cwd }` | Project Admin, Flutter/Angular |

### 4. Vinculacion Sesion-Story (NUEVO)

Al crear sesion, recibir `projectPrefix` y `storyId` para vincular con el backlog.
Al completar sesion, notificar a Project Admin que la story puede avanzar de estado.

---

## Features de Integracion

### Feature 1: REST API Layer (Alta)
Capa HTTP REST sobre el Session Manager existente. Express.js routes que invocan Session Manager.

### Feature 2: Project Binding (Alta)
Vincular sesiones con proyectos del ecosistema mediante `projectPrefix`.

### Feature 3: Story Binding (Media)
Vincular sesiones con stories del Sprint Backlog Manager mediante `storyId`.

### Feature 4: Autenticacion WebSocket (Media)
Token en handshake. Sin auth = solo localhost. Con auth = acceso remoto.

### Feature 5: Health Check y Metricas (Media)
Endpoints `/api/health` y `/api/stats` para monitoreo del ecosistema.

---

## Fase de Activacion

**Fase 2 del ecosistema Project Admin.**

### Cronograma Estimado

| Etapa | Descripcion | Estimacion |
|-------|-------------|------------|
| E1 | Testing interno del Orchestrator | 1 sprint |
| E2 | REST API layer | 1 sprint |
| E3 | Project binding + story binding | 1 sprint |
| E4 | Autenticacion WebSocket + health check | 0.5 sprint |
| E5 | Testing de integracion con Project Admin | 0.5 sprint |

**Total estimado:** 4 sprints.

---

## Equipo de Trabajo

### Node.js Backend Developer (Lead)

- **Agente:** `nodejs-backend-developer`
- **Funciones:**
  - Implementar REST API layer sobre Express
  - Extender Session Manager con campos de ecosistema (`projectPrefix`, `storyId`)
  - Implementar autenticacion WebSocket
  - Crear endpoints de health check y metricas
  - Implementar event webhooks hacia Project Admin
- **Tareas clave:**
  1. Crear `src/api/routes/sessions.js` - REST routes para sesiones
  2. Crear `src/api/routes/health.js` - Health check y stats
  3. Crear `src/api/middleware/auth.js` - Autenticacion por token
  4. Extender `src/agents/session-manager.js` con campos de ecosistema
  5. Implementar webhook client para notificar a Project Admin
- **Entregables:**
  - `src/api/` - Directorio completo de REST API
  - `src/agents/session-manager.js` extendido
  - `src/websocket/auth.js` - Middleware de autenticacion
  - `src/webhooks/project-admin.js` - Cliente de webhooks
- **Dependencias:** API contracts del software-architect.

### MCP Server Developer

- **Agente:** `mcp-server-developer`
- **Funciones:**
  - Extender MCP tools existentes con params de ecosistema
  - Agregar tools nuevos (`get_project_sessions`, `get_session_stats`)
  - Asegurar que MCP tools y REST API comparten la misma logica
- **Tareas clave:**
  1. Extender `create_session` tool con `projectPrefix` y `storyId`
  2. Agregar tool `get_project_sessions`
  3. Agregar tool `get_session_stats`
  4. Documentar cambios en README.md
- **Dependencias:** Cambios en Session Manager (nodejs-backend-developer).

### Test Engineer

- **Agente:** `test-engineer`
- **Funciones:**
  - Unit tests para Session Manager
  - Integration tests para REST API endpoints
  - Integration tests para WebSocket protocol
  - Tests de autenticacion
  - Mock del Agent SDK para tests sin API key
- **Entregables:**
  - `tests/unit/session-manager.test.js`
  - `tests/integration/rest-api.test.js`
  - `tests/integration/websocket.test.js`
  - `tests/integration/auth.test.js`
  - `tests/helpers/mock-agent-sdk.js`
  - Coverage report (target: >70%)
- **Dependencias:** Implementacion del nodejs-backend-developer para integration tests.

### Code Reviewer

- **Agente:** `code-reviewer`
- **Funciones:**
  - Code review riguroso pre-merge
  - Verificar seguridad: API keys nunca expuestas via WebSocket o REST
  - Validar manejo de errores: que pasa si Agent SDK falla mid-stream
  - Verificar concurrencia: multiples sesiones no interfieren entre si
  - Validar que REST API y MCP tools usan la misma logica
- **Entregables:**
  - Code review reports por cada PR
  - Security review checklist verificado
  - Sign-off de calidad para merge
- **Dependencias:** Despues de cada feature completada y testeada.

### Software Architect

- **Agente:** `software-architect`
- **Funciones:**
  - Definir API contracts entre Orchestrator y Project Admin Backend
  - Disenar patron de comunicacion (REST vs WebSocket vs MCP)
  - Definir estrategia de autenticacion del ecosistema
  - Validar que la arquitectura escala (10+ sesiones concurrentes)
  - Definir protocolo de eventos entre servicios
- **Entregables:**
  - `API_CONTRACTS_ORCHESTRATOR.md` - OpenAPI spec
  - `EVENT_PROTOCOL.md` - Definicion de eventos
  - `SCALABILITY_ANALYSIS.md` - Limites y recomendaciones
  - Recomendacion de auth strategy
- **Dependencias:** Se ejecuta primero (upstream de nodejs-backend-developer).

---

## Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigacion |
|--------|-------------|---------|------------|
| Agent SDK rate limits con multiples sesiones | Media | Alto | Limitar MAX_CONCURRENT_SESSIONS, queue |
| Memory leak con sesiones de larga duracion | Media | Alto | Cleanup periodico, limites por sesion |
| WebSocket desconexion pierde estado | Baja | Medio | Sesiones persisten en Session Manager, reconexion |
| API key expuesta en logs o eventos | Baja | Critico | Nunca incluir API key en payloads, sanitizar logs |
| Project Admin caido, no recibe webhooks | Media | Medio | Queue con retry, Project Admin consulta REST al reconectar |

---

## Decisiones Abiertas

1. REST vs MCP para comunicacion con Project Admin
2. Persistencia de sesiones: memoria o PostgreSQL
3. Event delivery: webhooks HTTP, WebSocket push, o message queue
4. Multi-tenant: un Orchestrator por usuario o compartido
5. Model selection por sesion (Opus, Sonnet)

---

**Ecosistema:** Project Admin
**Fase de activacion:** Phase 2
