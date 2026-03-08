# Arquitectura - Atlas Agent
**Version:** 0.1.0 | **Fecha:** 2026-03-05

## Diagrama de Componentes

```
                         ┌──────────────────┐
                         │     USUARIO       │
                         │    (Telegram)     │
                         └────────┬─────────┘
                                  │ Bot API
                                  ▼
┌─────────────────────────────────────────────────────────────┐
│                   SUPERVISOR (Node.js ~100 LOC)             │
│  - child_process.spawn de meta-sesion                       │
│  - Watchdog: detecta exit, reinicia con backoff             │
│  - Graceful shutdown: SIGTERM -> forward -> wait 30s        │
│  - PID file para single-instance                            │
└──────────────────────────────┬──────────────────────────────┘
                               │ spawn claude-code
                               ▼
┌─────────────────────────────────────────────────────────────┐
│              META-SESSION (Claude Code + Agent SDK)          │
│                                                             │
│  System prompt: prompts/coordinator.md                      │
│  Loop: backlog -> sesiones -> monitoreo -> reporte          │
│                                                             │
│  MCP Servers (stdio):                                       │
│  ├── claude-orchestrator  → gestionar sesiones worker       │
│  ├── sprint-backlog-mgr   → leer/actualizar historias       │
│  ├── project-admin        → registry, health de proyectos   │
│  └── telegram-mcp         → comunicacion con usuario        │
│                                                             │
│  Estado: state/atlas-state.json (persistido cada 30s)       │
└───┬──────────┬──────────┬──────────┬────────────────────────┘
    │          │          │          │
    ▼          ▼          ▼          ▼
┌────────┐ ┌────────┐ ┌────────┐ ┌────────────┐
│Orchestr│ │Backlog │ │Project │ │ Telegram   │
│ :8765  │ │Manager │ │ Admin  │ │ MCP Server │
│ :3000  │ │(stdio) │ │(stdio) │ │  (stdio)   │
└───┬────┘ └────────┘ └────────┘ └────────────┘
    │
    ▼
 Worker Sessions (1 a la vez en MVP)
```

## Componentes

| Componente | Ubicacion | Responsabilidad |
|------------|-----------|-----------------|
| Supervisor | `src/supervisor.js` | Spawn meta-sesion, watchdog con backoff, graceful shutdown, PID lock |
| Config | `src/config.js` | Centralizacion de env vars con defaults |
| System Prompt | `prompts/coordinator.md` | Comportamiento del agente: loop, autonomia, limites, escalacion |
| Telegram MCP | `src/telegram-mcp/server.js` | Server stdio con tools: send_message, ask_user, get_updates |
| Estado | `state/atlas-state.json` | JSON persistido: sesiones activas, progreso, historias asignadas |

## Flujo de Datos

### Flujo Principal (Happy Path)

```
1. Supervisor spawn -> Meta-session arranca
2. Meta-session lee backlog (sprint-backlog-mgr MCP)
   <- Lista de historias pendientes con prioridad y dependencias
3. Meta-session consulta proyecto (project-admin MCP)
   <- CWD, health, metadata del proyecto target
4. Meta-session crea sesion worker (claude-orchestrator MCP)
   -> create_session({ cwd, name }) + send_instruction({ contexto completo })
5. Meta-session monitorea (loop cada ~30s via get_session)
   <- Estado: running/completed/failed + output compacto
6. Al completar: actualiza backlog (sprint-backlog-mgr MCP)
   -> Marca historia como Done, registra resultado
7. Reporta progreso (telegram-mcp)
   -> send_message al usuario cada 30 min o al completar historia
8. Repite desde paso 2 con siguiente historia
```

### Flujo de Error / Escalacion

```
1. Meta-session detecta sesion estancada (sin output >5 min)
2. Intenta intervencion via inject_message (requiere ECO-001)
3. Si no responde: termina sesion, reintenta (max 3, backoff 30s/1m/2m)
4. Si 3 reintentos fallan: escala via Telegram (ask_user con opciones)
5. Usuario responde via boton -> meta-session actua segun respuesta
```

### Flujo de Crash Recovery

```
1. Meta-session crashea (exit code != 0)
2. Supervisor detecta exit event
3. Supervisor espera backoff (5s, 15s, 45s, max 2min si crashes consecutivos)
4. Supervisor relanza meta-session
5. Meta-session lee state/atlas-state.json al arrancar
6. Reconcilia: sesiones huerfanas en orchestrator vs estado persistido
7. Retoma loop desde ultimo estado conocido
```

## Decisiones Arquitectonicas

### ADR-001: Meta-sesion de Claude Code (no proceso standalone)

| Campo | Detalle |
|-------|---------|
| **Estado** | Aceptada |
| **Fecha** | 2026-03-05 |
| **Contexto** | Se evaluaron tres opciones para implementar el agente autonomo: (A) proceso standalone con logica imperativa en Node.js, (B) MCP server que recibe instrucciones, (C) sesion de Claude Code que usa orchestrator como herramienta via MCP tools. |
| **Decision** | Opcion C: el agente es una sesion de Claude Code con system prompt especializado. |
| **Razon** | Claude ya posee capacidad de coordinacion, priorizacion y deteccion de bloqueos. Programar esta logica en codigo imperativo seria reimplementar lo que el modelo ya hace. Los MCP tools existentes (orchestrator, backlog manager, project admin) proveen la API necesaria. |
| **Consecuencias (+)** | No hay que programar logica de coordinacion. Se reutiliza infraestructura existente. El comportamiento se ajusta iterando el system prompt, no el codigo. |
| **Consecuencias (-)** | Depende del limite de contexto de Claude. Si la sesion se agota, pierde estado en memoria. El supervisor debe compensar con restarts y el estado persistido a disco. |

### ADR-002: Supervisor minimo (~100 LOC)

| Campo | Detalle |
|-------|---------|
| **Estado** | Aceptada |
| **Fecha** | 2026-03-05 |
| **Contexto** | Definir la division de responsabilidad entre el supervisor (codigo) y la meta-sesion (Claude). Se evaluo poner logica de scheduling, retry y monitoreo en el supervisor. |
| **Decision** | Supervisor solo hace spawn, watchdog con backoff, y graceful shutdown. Toda la inteligencia reside en la meta-sesion. |
| **Razon** | Minima superficie de codigo. Cada linea de logica en el supervisor es una linea que hay que mantener y testear, mientras que la meta-sesion se ajusta con cambios al prompt. |
| **Consecuencias (+)** | Codigo simple y facil de auditar. Menos bugs posibles en el supervisor. |
| **Consecuencias (-)** | Si Claude pierde contexto post-restart, el supervisor no puede compensar con logica propia. Se mitiga con estado persistido a disco. |

### ADR-003: MVP con una sesion worker a la vez

| Campo | Detalle |
|-------|---------|
| **Estado** | Aceptada |
| **Fecha** | 2026-03-05 |
| **Contexto** | Decidir si el MVP soporta multiples sesiones concurrentes o una sola. Multi-sesion permitiria paralelizar historias independientes. |
| **Decision** | MVP opera una sesion worker a la vez. |
| **Razon** | Validar el concepto basico (loop de supervision, escalacion, recovery) antes de agregar complejidad de concurrencia. Multi-sesion se puede agregar despues sin cambios estructurales. |
| **Consecuencias (+)** | Simplicidad en monitoreo, estado y debugging. Sin race conditions. |
| **Consecuencias (-)** | No paraleliza trabajo. Throughput limitado al tiempo de una sesion a la vez. |

## Stack Tecnologico

| Tecnologia | Version | Proposito |
|------------|---------|-----------|
| Node.js | 18+ | Runtime del supervisor y Telegram MCP |
| @anthropic-ai/claude-agent-sdk | latest | Spawn de meta-sesion via Agent SDK |
| @modelcontextprotocol/sdk | latest | Telegram MCP server (stdio) |
| node-telegram-bot-api | latest | Comunicacion con Telegram Bot API |
| child_process (builtin) | - | Spawn de proceso Claude Code |

## Technical Debt Activo

Ninguno (proyecto en fase seed).

## Tabla de Autonomia (referencia del system prompt)

| Accion | Nivel |
|--------|-------|
| Crear sesion worker | Autonomo |
| Enviar instruccion a sesion | Autonomo |
| Reintentar error conocido | Autonomo |
| Actualizar estado de historia en backlog | Autonomo |
| Reportar progreso via Telegram | Autonomo |
| Merge a develop/main | Requiere aprobacion |
| Push a main | Requiere aprobacion |
| Cambio de scope de historia | Requiere aprobacion |
| Error desconocido no recuperable | Escalar |
| Eliminar archivos | Nunca |
| Cambiar config de otros proyectos | Nunca |

## Riesgos

| ID | Riesgo | Prob. | Severidad | Mitigacion |
|----|--------|-------|-----------|------------|
| R1 | Agotamiento de contexto de la meta-sesion | Alta | Alta | Leer solo status compactos (get_session), no outputs completos. Supervisor reinicia si se agota. Estado persistido permite retomar. |
| R2 | Agente toma decisiones destructivas | Baja | Alta | Tabla de autonomia en system prompt. Kill switch via /stop en Telegram. Limites de tokens por sesion worker. |
| R3 | ECO-001 pendiente (bloqueante) | - | Alta | MVP funciona sin injection (ATL-001 a ATL-003). ATL-004+ espera ECO-001. No hay workaround viable. |
| R4 | Telegram MCP no existe como componente | Baja | Media | Se crea como parte del proyecto (ATL-002). Stack conocido, scope acotado (3 tools). |
| R5 | Crash loop del supervisor | Baja | Media | Backoff exponencial (5s -> 15s -> 45s -> 2min max). Alerta via Telegram si disponible. |

## Prerequisitos Externos

| Prerequisito | Proyecto | Estado | Bloqueante para |
|-------------|----------|--------|-----------------|
| ECO-001: Mid-session injection | claude-orchestrator | Pendiente | ATL-004, ATL-006 |
| Orchestrator corriendo | claude-orchestrator | Operativo | Todo (runtime) |
| Sprint Backlog Manager MCP | sprint-backlog-manager | Operativo | ATL-005, ATL-007 |
| Project Admin MCP | project-admin | Operativo | ATL-007 |

## Folder Structure

```
atlas-agent/
  package.json
  README.md
  .claude/
    CLAUDE.md                  # Puntero a claude_context
    settings.local.json        # Permisos amplios
  src/
    supervisor.js              # Entry point: spawn + watchdog + restart
    config.js                  # Env vars centralizadas con defaults
    telegram-mcp/
      server.js                # MCP server entry (stdio)
      tools/
        send-message.js        # Enviar mensaje a chat
        ask-user.js            # Pregunta blocking con inline keyboard
        get-updates.js         # Leer mensajes nuevos
  prompts/
    coordinator.md             # System prompt v1.0
  state/                       # Runtime state (gitignored)
    .gitkeep
  tests/
    supervisor.test.js
    telegram-mcp.test.js
```

## Testing Strategy

| Nivel | Scope | Herramientas |
|-------|-------|-------------|
| Unit | Supervisor (spawn, restart, backoff logic), Telegram MCP tools (mock Bot API) | Jest + mocks |
| Integration | Supervisor + Claude Code CLI (spawn real), Telegram MCP + bot real (sandbox chat) | Jest + real processes |
| E2E | Full loop: supervisor -> meta-sesion -> orchestrator -> worker -> backlog update -> Telegram report | Manual + scripts |

**Coverage target:** >70% unit, >60% integration.

## Performance Targets

| Metrica | Target |
|---------|--------|
| Supervisor startup | < 2s |
| Telegram message send | < 1s |
| Session monitoring interval | 30s (configurable) |
| Crash recovery (backoff base) | < 10s (5s delay + 5s startup) |
| State persistence interval | 30s |
