# Architecture Analysis: IDEA-043 + IDEA-044

**Version:** 1.0
**Fecha:** 2026-03-05
**Estado:** Analisis de viabilidad

---

## Executive Summary

Este documento analiza la viabilidad tecnica y propone la arquitectura para dos iniciativas complementarias:

- **IDEA-044 (Mejoras al Ecosistema):** Cuatro mejoras incrementales al claude-orchestrator y ecosistema (M1-M4), cada una independiente pero con sinergias claras.
- **IDEA-043 (Agente Autonomo):** Un agente coordinador que se monta sobre el orchestrator para gestionar trabajo multi-proyecto de forma autonoma.

La conclusion principal es que IDEA-044 es prerequisito parcial de IDEA-043, y que el agente autonomo debe implementarse como **una sesion de Claude Code que usa el orchestrator como herramienta** (meta-nivel), no como un proceso standalone ni un MCP server adicional.

---

## 1. Viabilidad Tecnica: Mejoras al Ecosistema (IDEA-044)

### M1: Mid-Session Injection en Orchestrator

**Viabilidad: ALTA (con restricciones del SDK)**

**Que es:** Capacidad de inyectar mensajes a una sesion en ejecucion entre tool calls, sin terminar la sesion. El ai-sdk-provider implementa esto con `streamingInput: 'always'` y un sistema queue+promise.

**Analisis del estado actual:**

El `SessionManager.sendMessage()` actual (lineas 72-142 de `session-manager.js`) itera sobre `query()` del Agent SDK en un loop `for await...of`. Una vez que el generator esta en ejecucion, no hay mecanismo para inyectar mensajes adicionales. El flujo es estrictamente request-response:

```
sendMessage(prompt) -> query({prompt}) -> for await (message of stream) -> idle
```

**Implementacion propuesta:**

1. Agregar una cola de mensajes pendientes (`pendingInjections: []`) al SessionInfo
2. Usar el patron del ai-sdk-provider: un async iterable que se mantiene abierto como `streamingInput` del Agent SDK
3. Cuando llega una inyeccion, resolver una promise que el iterable esta esperando
4. El Agent SDK procesa la inyeccion entre tool calls (no durante generacion de texto)

**Restriccion critica:** El Agent SDK (`@anthropic-ai/claude-agent-sdk ^0.1.0`) actual del orchestrator debe soportar `streamingInput`. Verificar compatibilidad de version. El ai-sdk-provider usa `^0.2.63` -- el orchestrator usa `^0.1.0`. **Se requiere upgrade del SDK.**

**Impacto en API:**
- Nuevo mensaje WebSocket: `inject_message { sessionId, content }`
- Nuevo endpoint HTTP: `POST /api/sessions/:id/inject`
- Nuevo tool MCP: `inject_message`

**Esfuerzo estimado:** 5-8 pts (incluye upgrade SDK + implementacion + tests)

**Riesgos:**
- El upgrade de SDK `0.1.x -> 0.2.x` puede tener breaking changes
- La inyeccion solo funciona entre tool calls; si el agente esta generando texto puro sin tools, la inyeccion queda encolada indefinidamente
- Race conditions si multiples inyecciones llegan simultaneamente

---

### M2: UI Web via AI SDK

**Viabilidad: ALTA**

**Que es:** Interfaz web usando Vercel AI SDK v6 + ai-sdk-provider-claude-code que se conecte al orchestrator para visualizar y controlar sesiones con streaming real-time.

**Analisis arquitectonico:**

Hay dos enfoques posibles:

**Enfoque A: UI Web directa con ai-sdk-provider**
```
Browser -> Next.js API Route -> ai-sdk-provider -> Claude Agent SDK -> CLI claude
```
Problema: Cada usuario de la UI lanza su propio proceso `claude`. No se integra con las sesiones existentes del orchestrator. Es un cliente independiente, no una UI del orchestrator.

**Enfoque B: UI Web como cliente del Orchestrator (RECOMENDADO)**
```
Browser -> Next.js -> WebSocket/REST -> Orchestrator -> SessionManager -> Claude
```
La UI se conecta al orchestrator existente via WebSocket (puerto 8765) y/o REST (puerto 3000). El streaming ya esta implementado via `agent_message` events del WebSocket server.

**Por que Enfoque B:**
- Reutiliza toda la infraestructura existente (auth, rate limiting, session management)
- La UI ve las MISMAS sesiones que el Flutter monitor y el MCP client
- No duplica procesos claude
- El ai-sdk-provider se puede usar en el BACKEND para features adicionales (structured output, thinking traces) pero no como el canal principal de comunicacion

**Stack recomendado:**
- Next.js 15 (App Router)
- Vercel AI SDK v6 para el componente de chat (useChat hook)
- WebSocket nativo para la conexion al orchestrator
- Tailwind CSS + shadcn/ui para UI rapida
- Adapter pattern: traducir mensajes WS del orchestrator al formato que espera `useChat`

**Esfuerzo estimado:** 8-13 pts (MVP con lista de sesiones + chat streaming + creacion de sesiones)

**Riesgos:**
- El formato de mensajes del orchestrator WS no es compatible 1:1 con el formato que espera `useChat` del AI SDK. Se necesita un adapter layer.
- El orchestrator actual no tiene CORS configurado para el HTTP server (solo localhost).

---

### M3: Testing de MCP Servers In-Process

**Viabilidad: ALTA**

**Que es:** Usar `createCustomMcpServer()` del ai-sdk-provider para levantar MCP servers (sprint-backlog-manager, project-admin) en integration tests sin procesos externos.

**Analisis:**

Actualmente, el orchestrator testea la integracion con sprint-backlog-manager via `BacklogClient` que spawna un proceso hijo MCP. En tests, esto requiere:
1. PostgreSQL corriendo
2. El MCP server real disponible
3. Proceso hijo spawneado

Con `createCustomMcpServer()`, se puede crear un MCP server in-process con herramientas mock definidas en Zod:

```typescript
import { createCustomMcpServer } from 'ai-sdk-provider-claude-code';

const mockBacklog = createCustomMcpServer({
  tools: {
    list_stories: {
      description: 'List stories',
      parameters: z.object({ project_id: z.number() }),
      execute: async (args) => ({ stories: [mockStory] })
    }
  }
});
```

**Aplicabilidad:**
- Integration tests del orchestrator contra MCP servers mockeados
- Tests de la UI web contra un orchestrator con MCPs simulados
- Tests E2E del agente autonomo sin dependencias externas

**Restriccion:** `createCustomMcpServer()` crea un servidor tipo `sdk` (in-process). El `BacklogClient` actual usa `StdioClientTransport`. Se necesita un adapter o una segunda implementacion del client que acepte transporte in-process.

**Esfuerzo estimado:** 3-5 pts

**Riesgos:**
- Divergencia entre mocks y servidores reales si los schemas cambian
- El ai-sdk-provider es dependencia de terceros (MIT pero no bajo nuestro control)

---

### M4: Subagent Tracking en Monitor

**Viabilidad: MEDIA-ALTA**

**Que es:** Visualizar la jerarquia de subagentes en claude-monitor (Flutter) usando `parentToolCallId` que expone el ai-sdk-provider.

**Analisis del flujo de datos actual:**

```
Orchestrator -> WS agent_message -> Flutter Monitor
```

El `serializeAgentMessage()` del WebSocket server (linea 471 de `websocket/server.js`) solo extrae `{ type, subtype, content, tool, result, usage }`. No hay `parentToolCallId` ni metadata de jerarquia.

**Que se necesita:**

1. **En el orchestrator:** El Agent SDK emite tool_use events con IDs. Cuando una tool es `Task` (subagente), el ID de esa tool call es el `parentToolCallId` de los mensajes del subagente. Hay que:
   - Capturar `tool_use.id` en cada mensaje
   - Mantener un Map de tool call IDs activos por sesion
   - Enriquecer `serializeAgentMessage()` con `toolCallId` y `parentToolCallId`

2. **En el WebSocket protocol:** Agregar campos al payload de `agent_message`:
   ```json
   { "toolCallId": "tc_123", "parentToolCallId": "tc_098", ... }
   ```

3. **En Flutter Monitor:** Construir un tree view de la jerarquia. Cada nodo es un tool call, los subagentes son hijos.

**Restriccion:** El Agent SDK en modo CLI (`cli-session-manager.js`) parsea `stream-json` y los eventos de tool_use ya incluyen IDs de bloque, pero no hay un campo explicito `parentToolCallId`. Este campo lo construye el ai-sdk-provider como logica propia (no viene del SDK). Habria que replicar esa logica en el orchestrator.

**Esfuerzo estimado:** 5-8 pts (orchestrator) + 5-8 pts (Flutter)

**Riesgos:**
- La logica de tracking de parentToolCallId es no trivial (Map, no stack, por Tasks paralelas)
- El CLI mode no expone metadata de subagentes de la misma forma que el SDK mode
- Requiere cambios en el protocolo WS (backward compatibility)

---

## 2. Viabilidad Tecnica: Agente Autonomo (IDEA-043)

### Analisis de Opciones Arquitectonicas

**Opcion A: Proceso Standalone (Node.js)**
```
┌─────────────────────┐
│  Autonomous Agent    │ (nuevo proceso Node.js)
│  ┌───────────────┐  │
│  │ Decision Loop  │  │
│  │ (reglas, FSM)  │  │
│  └───────┬───────┘  │
│          │           │
│  ┌───────▼───────┐  │
│  │ Orchestrator   │  │
│  │ Client (WS)   │──┼──> Orchestrator :8765
│  └───────────────┘  │
│  ┌───────────────┐  │
│  │ Backlog Client │──┼──> Sprint Backlog Manager
│  └───────────────┘  │
│  ┌───────────────┐  │
│  │ Telegram Bot   │──┼──> Telegram API
│  └───────────────┘  │
└─────────────────────┘
```

**Pros:** Control total, sin limites de contexto, logica determinista.
**Contras:** Hay que escribir TODA la logica de coordinacion, deteccion de bloqueos, y toma de decisiones en codigo imperativo. Es un project manager en codigo. Enorme esfuerzo y fragilidad.

**Opcion B: MCP Server**
```
MCP Client (Claude) -> MCP Server "autonomous-agent" -> Orchestrator
```

**Pros:** Se expone como herramienta para Claude.
**Contras:** Un MCP server es pasivo (responde a llamadas). Un agente autonomo necesita ser ACTIVO (iniciar acciones). Modelo incorrecto.

**Opcion C: Sesion de Claude Code que usa Orchestrator como Tool (RECOMENDADO)**
```
┌─────────────────────────────────────────────────────┐
│                  Meta-Session                        │
│  Claude Code (con system prompt de coordinador)      │
│                                                      │
│  Tools disponibles:                                  │
│  ├── mcp__claude-orchestrator__create_session        │
│  ├── mcp__claude-orchestrator__send_instruction      │
│  ├── mcp__claude-orchestrator__list_sessions         │
│  ├── mcp__sprint-backlog-manager__list_stories       │
│  ├── mcp__sprint-backlog-manager__update_story       │
│  ├── mcp__project-admin__pa_project_health           │
│  ├── mcp__telegram-bot__send_message                 │
│  ├── mcp__telegram-bot__ask_user                     │
│  └── Read, Write, Bash, Glob, Grep                   │
│                                                      │
│  Behavior (via system prompt):                       │
│  1. Leer backlog del sprint actual                   │
│  2. Evaluar historias pendientes                     │
│  3. Crear sesiones en orchestrator para cada historia│
│  4. Monitorear progreso de sesiones                  │
│  5. Detectar bloqueos (timeout, error, stuck)        │
│  6. Escalar via Telegram cuando necesita decisiones  │
│  7. Reportar progreso periodicamente                 │
└─────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
   Orchestrator         Backlog Manager      Telegram Bot
   (gestiona N          (lee/actualiza       (bidireccional
    sesiones             historias)           con usuario)
    worker)
```

**Por que Opcion C:**

1. **Claude ES el coordinador.** No hay que programar logica de decision -- Claude ya sabe coordinar, priorizar, y detectar bloqueos. Es exactamente lo que hace hoy un humano usando el orchestrator.

2. **Ya funciona.** Hoy, un usuario abre Claude Code, usa los MCP tools del orchestrator para crear sesiones y enviar instrucciones. El agente autonomo es lo mismo, pero sin humano en el loop (salvo escalaciones).

3. **El orchestrator ya es la herramienta correcta.** Los tools MCP existentes (`create_session`, `send_instruction`, `list_sessions`, etc.) son exactamente la API que necesita el agente.

4. **Mid-session injection (M1) habilita supervision.** El agente coordinador puede inyectar correcciones a sesiones worker sin terminarlas.

5. **Telegram como canal de escalacion.** Un MCP server de Telegram (nuevo o existente del monitor Flutter) permite al agente preguntar al usuario y reportar progreso.

**Que falta para Opcion C:**

| Componente | Estado | Necesita |
|------------|--------|----------|
| Orchestrator MCP tools | EXISTE | M1 (injection) para supervision activa |
| Sprint Backlog Manager MCP | EXISTE | Nada adicional |
| Project Admin MCP | EXISTE | Nada adicional |
| Telegram MCP Server | PARCIAL | Existe integracion en Flutter monitor; necesita MCP server standalone |
| System prompt de coordinador | NO EXISTE | Disenar prompt con reglas de autonomia, escalacion, y limites |
| Launcher / Supervisor | NO EXISTE | Script que lance la meta-sesion y la mantenga viva |

---

### Arquitectura Detallada del Agente Autonomo

```
                    ┌──────────────────┐
                    │    USUARIO        │
                    │   (Telegram)      │
                    └────────┬─────────┘
                             │ escalaciones / decisiones
                             ▼
┌────────────────────────────────────────────────────────────┐
│                    SUPERVISOR PROCESS                       │
│  (Node.js script minimo: spawn claude, restart on crash)   │
│                                                            │
│  Responsabilidades:                                        │
│  - Lanzar meta-sesion con system prompt                    │
│  - Watchdog: reiniciar si se cae                           │
│  - Pasar env vars y configuracion                          │
│  - Log de actividad                                        │
└───────────────────────────┬────────────────────────────────┘
                            │ spawn
                            ▼
┌────────────────────────────────────────────────────────────┐
│                    META-SESSION                             │
│  (Claude Code con MCP servers configurados)                │
│                                                            │
│  MCP Servers:                                              │
│  ├── claude-orchestrator (manage worker sessions)          │
│  ├── sprint-backlog-manager (read/update stories)          │
│  ├── project-admin (project health, registry)              │
│  └── telegram-mcp (send/receive messages)                  │
│                                                            │
│  System Prompt:                                            │
│  "Sos un agente coordinador autonomo.                      │
│   Tu trabajo es ejecutar el sprint actual.                 │
│   Leiste el backlog, creas sesiones worker para            │
│   cada historia, monitoream progreso, y escalas            │
│   al usuario via Telegram cuando necesitas                 │
│   decisiones que no podes tomar solo.                      │
│   [... reglas de autonomia, limites, etc.]"                │
│                                                            │
│  Loop conceptual:                                          │
│  1. list_stories(status='ready') -> historias pendientes   │
│  2. Para cada historia:                                    │
│     a. create_session(cwd=proyecto, name=historia)         │
│     b. assign_story(sessionId, storyExternalId)            │
│     c. send_instruction(sessionId, prompt_detallado)       │
│  3. Periodicamente:                                        │
│     a. list_sessions() -> verificar estados                │
│     b. Si session stuck >30min -> intervenir o escalar     │
│     c. Si session error -> diagnosticar, reintentar o      │
│        escalar                                             │
│     d. Si session idle (completada) -> verificar output,   │
│        update_story(status='done'), reportar               │
│  4. Cada N historias completadas -> telegram.send(resumen) │
│  5. Si necesita decision (ambiguedad, conflicto,           │
│     prioridad) -> telegram.ask(pregunta) -> esperar resp   │
└────────────────────────────────────────────────────────────┘
         │              │              │              │
         ▼              ▼              ▼              ▼
   Orchestrator    Backlog Mgr    Project Admin   Telegram
   :8765/:3000     MCP stdio      MCP stdio       MCP stdio
         │
         ▼
   ┌───────────┐  ┌───────────┐  ┌───────────┐
   │ Session 1  │  │ Session 2  │  │ Session 3  │
   │ (worker)   │  │ (worker)   │  │ (worker)   │
   │ LTE-045    │  │ LTE-046    │  │ LTE-047    │
   │ proyecto-A │  │ proyecto-A │  │ proyecto-B │
   └───────────┘  └───────────┘  └───────────┘
```

---

## 3. Dependencias Tecnicas entre Mejoras

```
M3 (MCP in-process testing) ──────────────────────> independiente
                                                     (se puede hacer primero)

M1 (mid-session injection) ──────────────────────> prerequisito para:
  │                                                 - IDEA-043 (supervision activa)
  │                                                 - M2 parcial (inject desde UI)
  │
  └── Requiere: upgrade @anthropic-ai/claude-agent-sdk 0.1.x -> 0.2.x+

M4 (subagent tracking) ───────────────────────────> independiente del resto
  │                                                  (mejora observabilidad)
  └── Beneficia: IDEA-043 (visualizar jerarquia del agente autonomo)

M2 (UI web) ──────────────────────────────────────> beneficia de M1 (inject)
  │                                                  y M4 (subagent view)
  └── Independiente para MVP basico

IDEA-043 (agente autonomo) ───────────────────────> requiere:
  ├── M1 (mid-session injection) -- para supervision activa
  ├── Telegram MCP Server -- nuevo componente
  └── System prompt de coordinador -- diseno
```

**Diagrama de dependencias:**

```
                M3 (testing)
                (independiente)

M1 (injection) ─────────┐
     │                   │
     ▼                   ▼
  M2 (UI web)     IDEA-043 (agente autonomo)
                         │
                   Telegram MCP ──┘
                   (nuevo)

M4 (subagent tracking)
(independiente, mejora IDEA-043 y M2)
```

---

## 4. Riesgos y Mitigaciones

### R1: Upgrade del Agent SDK (Critico para M1 y IDEA-043)

**Riesgo:** El orchestrator usa `@anthropic-ai/claude-agent-sdk ^0.1.0`. El ai-sdk-provider usa `^0.2.63`. El upgrade puede tener breaking changes en la API de `query()`.

**Mitigacion:**
- Hacer el upgrade como tarea aislada antes de M1
- Verificar que `query()` sigue funcionando con la interfaz actual
- Los 388 tests existentes del orchestrator son la red de seguridad
- Si hay breaking changes, el CliSessionManager (que usa el CLI, no el SDK) no se ve afectado

**Severidad:** Alta | **Probabilidad:** Media

### R2: Limites de Contexto del Agente Autonomo (Critico para IDEA-043)

**Riesgo:** La meta-sesion de Claude Code tiene limite de contexto. Si monitorea muchas sesiones con outputs largos, puede agotar contexto y perder estado.

**Mitigacion:**
- El agente NO lee outputs completos de sesiones worker. Solo lee status y resumen.
- Usar `get_session()` (compacto) en lugar de suscribirse al stream completo.
- El supervisor reinicia la meta-sesion si se agota el contexto, con un TASK_STATE.md que preserva estado.
- Limitar concurrencia a 3-5 sesiones worker simultaneas.
- El system prompt debe instruir al agente a ser conciso en su razonamiento.

**Severidad:** Alta | **Probabilidad:** Alta

### R3: Autonomia sin Control (Medio para IDEA-043)

**Riesgo:** El agente toma decisiones incorrectas (merge a rama equivocada, elimina archivos, gasta tokens excesivos).

**Mitigacion:**
- Guardrails en el system prompt: lista explicita de lo que NO puede hacer sin autorizacion
- Limite de tokens por sesion worker configurable
- Escalacion obligatoria para: merges, cambios a main/develop, gastos >$X
- Kill switch via Telegram: comando `/stop` que detiene todo
- Las sesiones worker usan `permissionMode: 'bypassPermissions'` pero con `allowedTools` restrictivo

**Severidad:** Alta | **Probabilidad:** Baja (con guardrails)

### R4: Telegram MCP Server (Medio para IDEA-043)

**Riesgo:** No existe un MCP server standalone de Telegram. El monitor Flutter tiene integracion Telegram pero es bidireccional via polling, no via MCP.

**Mitigacion:**
- Crear un MCP server minimo de Telegram con 3 tools: `send_message`, `ask_user` (blocking con timeout), `get_updates`
- Reutilizar el bot token y chat ID del monitor Flutter
- Alternativa: usar el monitor Flutter como proxy (mandar WS al monitor, que este reenvie a Telegram)

**Severidad:** Media | **Probabilidad:** Baja (es trabajo conocido)

### R5: Backward Compatibility del Protocolo WS (Bajo para M4)

**Riesgo:** Agregar campos al protocolo WS puede romper clientes existentes (Flutter monitor).

**Mitigacion:**
- Campos nuevos son ADITIVOS (no se remueven campos existentes)
- Flutter monitor ignora campos desconocidos (Dart JSON parsing es tolerante)
- Versionar el protocolo con un campo `protocolVersion` en el handshake

**Severidad:** Baja | **Probabilidad:** Baja

---

## 5. Recomendacion de Secuencia de Implementacion

### Fase 1: Foundations (Sprint 1-2)

| # | Mejora | Puntos | Justificacion |
|---|--------|--------|---------------|
| 1 | Upgrade Agent SDK 0.1 -> 0.2+ | 3 | Prerequisito de M1; desbloquea todo |
| 2 | M3: MCP in-process testing | 3-5 | Independiente, mejora DX inmediatamente |

### Fase 2: Core Capabilities (Sprint 3-4)

| # | Mejora | Puntos | Justificacion |
|---|--------|--------|---------------|
| 3 | M1: Mid-session injection | 5-8 | Habilita supervision activa |
| 4 | Telegram MCP Server | 3-5 | Prerequisito de IDEA-043 |

### Fase 3: Agente Autonomo MVP (Sprint 5-6)

| # | Mejora | Puntos | Justificacion |
|---|--------|--------|---------------|
| 5 | IDEA-043: System prompt + supervisor | 8-13 | El agente autonomo propiamente dicho |
| 6 | IDEA-043: Testing E2E con mocks (M3) | 3-5 | Validar comportamiento |

### Fase 4: UI y Observabilidad (Sprint 7-8)

| # | Mejora | Puntos | Justificacion |
|---|--------|--------|---------------|
| 7 | M2: UI Web MVP | 8-13 | Dashboard visual del ecosistema |
| 8 | M4: Subagent tracking | 5-8 | Observabilidad de jerarquia |

**Total estimado:** 38-60 pts (8 sprints, ~2 meses)

**Camino critico:** SDK Upgrade -> M1 -> Telegram MCP -> IDEA-043

---

## 6. Stack Tecnologico Recomendado

### M1: Mid-Session Injection

| Componente | Tecnologia | Justificacion |
|------------|------------|---------------|
| Runtime | Node.js 18+ | Existente |
| Agent SDK | @anthropic-ai/claude-agent-sdk ^0.2.63 | Upgrade necesario |
| Pattern | Queue + Promise (del ai-sdk-provider) | Probado, production-ready |

### M2: UI Web

| Componente | Tecnologia | Justificacion |
|------------|------------|---------------|
| Framework | Next.js 15 (App Router) | Soporte nativo AI SDK, SSR |
| AI SDK | Vercel AI SDK v6 | useChat hook para streaming UI |
| UI | Tailwind CSS + shadcn/ui | Rapido de prototipar |
| WS Client | ws nativo del browser | Conexion al orchestrator |
| State | Zustand o React Context | Liviano, sin overhead |
| Build | Turbopack | Incluido en Next.js 15 |

### M3: MCP In-Process Testing

| Componente | Tecnologia | Justificacion |
|------------|------------|---------------|
| Helper | createCustomMcpServer() de ai-sdk-provider | Ya existe |
| Schema | Zod | Para definir tools mock |
| Test runner | Jest (existente) o Vitest | Compatible con ambos |

### M4: Subagent Tracking

| Componente | Tecnologia | Justificacion |
|------------|------------|---------------|
| Orchestrator | Logica en session-manager.js | Extension del codigo existente |
| Flutter | TreeView widget | Para visualizacion jerarquica |
| Protocol | JSON sobre WS (campos aditivos) | Compatible con existente |

### IDEA-043: Agente Autonomo

| Componente | Tecnologia | Justificacion |
|------------|------------|---------------|
| Meta-sesion | Claude Code (CLI mode) | Reutiliza infraestructura existente |
| Supervisor | Node.js script (~100 lineas) | spawn + watchdog + restart |
| MCP Servers | Orchestrator + Backlog + Project Admin + Telegram | Todos existentes o planeados |
| System prompt | Markdown file con reglas | Versionable, iterable |
| Estado persistente | TASK_STATE.md en claude_context | Alineado con metodologia |
| Telegram MCP | Node.js + node-telegram-bot-api + MCP SDK | Nuevo componente, stack conocido |

### Telegram MCP Server (Nuevo)

| Componente | Tecnologia | Justificacion |
|------------|------------|---------------|
| Runtime | Node.js 18+ | Consistente con ecosistema |
| Telegram SDK | node-telegram-bot-api | Libreria madura, 12K+ stars |
| MCP SDK | @modelcontextprotocol/sdk | Consistente con otros servers |
| Transport | stdio | Estandar MCP |
| Tools | send_message, ask_user, get_updates | Minimo viable |

---

## 7. Decisiones Arquitectonicas Clave

### ADR-001: El agente autonomo es una meta-sesion, no un proceso standalone

**Contexto:** Hay tres opciones para implementar el agente autonomo.
**Decision:** Opcion C -- sesion de Claude Code que usa el orchestrator como herramienta.
**Razon:** Claude ya sabe coordinar. Programar logica de coordinacion imperativa es reinventar la rueda con peor resultado. Los MCP tools existentes son exactamente la API que necesita.
**Consecuencia:** Depende del limite de contexto de Claude. El supervisor debe manejar reinicios.

### ADR-002: La UI web se conecta al orchestrator, no directamente al Agent SDK

**Contexto:** El ai-sdk-provider permite crear UIs que hablan directamente con Claude.
**Decision:** La UI es un cliente del orchestrator existente, no un bypass.
**Razon:** Centralizar la gestion de sesiones. Evitar sesiones fantasma fuera del orchestrator.
**Consecuencia:** Se necesita un adapter entre el formato WS del orchestrator y el formato que espera useChat.

### ADR-003: Upgrade del Agent SDK es prerequisito bloqueante

**Contexto:** M1 requiere features de SDK 0.2.x que no existen en 0.1.x.
**Decision:** Hacer el upgrade como primera tarea, antes de cualquier otra mejora.
**Razon:** Los 388 tests existentes dan confianza. Sin upgrade, M1 y IDEA-043 no son posibles.
**Consecuencia:** Riesgo de breaking changes. Mitigado por tests.

---

## 8. Open Questions

| # | Pregunta | Impacto | Para resolver |
|---|----------|---------|---------------|
| Q1 | El Agent SDK 0.2.x expone `streamingInput` para la funcion `query()`? | Bloqueante para M1 | Revisar changelog/docs del SDK |
| Q2 | El CLI mode (`claude --print --stream-json`) soporta injection? | Determina si M1 funciona en CLI mode | Experimentar con `--resume` + stdin |
| Q3 | Cual es el limite practico de contexto para la meta-sesion del agente? | Dimensiona cuantas sesiones puede monitorear | Testear con 5-10 sesiones |
| Q4 | El bot de Telegram del monitor Flutter puede reutilizarse o necesita uno nuevo? | Esfuerzo del Telegram MCP | Revisar implementacion actual |
| Q5 | Se quiere la UI web como SPA standalone o integrada al monitor Flutter (web)? | Arquitectura de M2 | Decision del usuario |

---

**Version:** 1.0 | **Ultima actualizacion:** 2026-03-05
