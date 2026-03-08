# ECO-001: Mid-Session Message Injection

**Points:** 5 | **Priority:** Critical
**Epic:** Ecosystem Improvements
**Depends on:** Ninguna (es prerequisito de IDEA-043 Agente Autonomo)

---

## User Story

**As a** orchestrator client (MCP, WebSocket, HTTP)
**I want** to inject messages into active sessions between tool calls
**So that** I can redirect, correct, or provide additional context to running agents without stopping and restarting sessions

---

## Acceptance Criteria

**AC1: Session Manager soporta inject_message**
- Given a session in status 'working'
- When I call `injectMessage(sessionId, message)`
- Then the message is delivered to the agent between tool calls
- And the session emits a 'session:injected' event

**AC2: Injection via MCP tool**
- Given a session in status 'working'
- When I call the MCP tool `inject_message` with sessionId and message
- Then the message is injected and I receive confirmation with delivery status

**AC3: Injection via WebSocket**
- Given a session in status 'working' and a subscribed WebSocket client
- When the client sends `{ type: "inject_message", payload: { sessionId, message } }`
- Then the message is injected and the client receives `{ type: "message_injected", sessionId }`

**AC4: Injection via HTTP**
- Given a session in status 'working'
- When I POST to `/api/sessions/:id/inject` with `{ message }`
- Then the message is injected and I receive 200 with delivery status

**AC5: Injection only when working**
- Given a session NOT in status 'working'
- When I try to inject a message
- Then I receive an error "Session is not actively working"

**AC6: Delivery feedback**
- Given a session in status 'working'
- When I inject a message
- Then I receive a `delivered: true/false` indicator
- And if not delivered (agent finished before injection), I'm notified

---

## Technical Notes

### Mecanismo del SDK (YA DISPONIBLE en 0.1.77)

El Agent SDK `query()` acepta `prompt: string | AsyncIterable<SDKUserMessage>`. Hay dos approaches:

#### Approach A: AsyncIterable prompt (recomendado)

Modificar `sendMessage()` para pasar un `AsyncIterable` en vez de string. El generador yield el mensaje inicial y luego queda esperando mensajes inyectados via una queue interna.

```javascript
// Pseudo-codigo del cambio en session-manager.js
async *sendMessage(sessionId, prompt) {
  // ... setup ...

  // Crear queue de inyeccion
  const injectionQueue = new MessageQueue();
  session.injectionQueue = injectionQueue;

  // Crear AsyncIterable que yield inicial + inyectados
  async function* promptIterable() {
    yield { role: 'user', content: prompt };
    while (true) {
      const injected = await injectionQueue.next();
      if (injected === null) break; // sesion terminada
      yield { role: 'user', content: injected };
    }
  }

  const queryOptions = {
    prompt: promptIterable(),
    options: { /* ... existing options ... */ }
  };

  for await (const message of query(queryOptions)) {
    // ... existing message processing ...
  }

  injectionQueue.close();
  session.injectionQueue = null;
}

// Nuevo metodo
injectMessage(sessionId, message) {
  const session = this.sessions.get(sessionId);
  if (!session || session.status !== 'working') {
    throw new Error('Session is not actively working');
  }
  if (!session.injectionQueue) {
    throw new Error('Session does not support injection');
  }
  return session.injectionQueue.enqueue(message);
}
```

#### Approach B: Query.streamInput() (alternativo)

El objeto `Query` retornado por `query()` expone `streamInput(asyncIterable)`. Se puede retener la referencia al Query y llamar `streamInput()` on-demand.

### Referencia: ai-sdk-provider-claude-code

El proyecto `C:/investigacion/ai-sdk-provider-claude-code/` tiene una implementacion completa de referencia:

- `src/claude-code-language-model.ts` lineas 291-463: `createMessageInjector()` y `toAsyncIterablePrompt()`
- `src/types.ts` lineas 449-480: interfaz `MessageInjector`
- `src/message-injection.test.ts`: suite completa de tests

El provider usa un patron queue+promise con un `resolveNext` que se resuelve cuando hay un mensaje nuevo o la sesion termina.

### Archivos a modificar

| Archivo | Cambio |
|---------|--------|
| `src/agents/session-manager.js` | Agregar `injectionQueue` a SessionInfo, modificar `sendMessage()`, nuevo `injectMessage()` |
| `src/mcp/tools/sessions.js` | Nuevo tool `inject_message` + handler |
| `src/websocket/server.js` | Nuevo message type `inject_message` |
| `src/http/routes/sessions.js` | Nuevo endpoint POST `/api/sessions/:id/inject` |
| `tests/` | Tests para injection queue, delivery feedback, edge cases |

### SessionInfo extension

```javascript
// Agregar a SessionInfo
{
  // ... campos existentes ...
  injectionQueue: null,    // MessageQueue instance cuando working
}
```

### MessageQueue (nuevo utility)

```javascript
// src/utils/message-queue.js
export class MessageQueue {
  constructor() {
    this.queue = [];
    this.resolveNext = null;
    this.closed = false;
  }

  enqueue(message) {
    if (this.closed) return { delivered: false, reason: 'closed' };
    if (this.resolveNext) {
      this.resolveNext(message);
      this.resolveNext = null;
      return { delivered: true };
    }
    this.queue.push(message);
    return { delivered: true, queued: true };
  }

  async next() {
    if (this.closed) return null;
    if (this.queue.length > 0) return this.queue.shift();
    return new Promise(resolve => { this.resolveNext = resolve; });
  }

  close() {
    this.closed = true;
    if (this.resolveNext) this.resolveNext(null);
  }
}
```

### SDK version

El SDK actual (0.1.77) ya tiene el `AsyncIterable<SDKUserMessage>` prompt y `Query.streamInput()`. NO se necesita upgrade para esta feature.

Verificado en: `C:/mcp/claude-orchestrator/node_modules/@anthropic-ai/claude-agent-sdk/entrypoints/agentSdkTypes.d.ts`

```typescript
export declare function query(_params: {
    prompt: string | AsyncIterable<SDKUserMessage>;
    options?: Options;
}): Query;
```

### Importante: Inyeccion entre tool calls

La inyeccion ocurre cuando el SDK consume el siguiente mensaje del AsyncIterable. Esto sucede naturalmente **entre tool calls** (despues de un tool_result, antes del siguiente assistant message). NO interrumpe generacion de texto continuo.

---

## Definition of Done

- [ ] MessageQueue utility implementado con tests
- [ ] session-manager.js usa AsyncIterable prompt
- [ ] injectMessage() funciona con delivery feedback
- [ ] MCP tool inject_message registrado y funcional
- [ ] WebSocket message type inject_message funcional
- [ ] HTTP endpoint POST /api/sessions/:id/inject funcional
- [ ] Tests unitarios para MessageQueue
- [ ] Tests de integracion para injection via cada interfaz
- [ ] Tests de edge cases: injection a sesion no-working, injection cuando queue cerrada
- [ ] Build: 0 errors, 0 warnings
- [ ] Tests existentes siguen pasando (388+)

---

## Historial

| Fecha | Evento |
|-------|--------|
| 2026-03-05 | Historia creada. Prerequisito para IDEA-043 (Agente Autonomo) |
