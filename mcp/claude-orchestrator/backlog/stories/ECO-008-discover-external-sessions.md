# ECO-008: Discover External Claude Code Sessions

**Points:** 5 | **Priority:** Medium
**Epic:** EPIC-ECO-02: Autonomous Agent Foundation
**Depends on:** Ninguna

---

## User Story

**As a** orchestrator client (MCP, HTTP)
**I want** to discover Claude Code sessions that were opened manually (outside the orchestrator)
**So that** I can monitor, inspect, and potentially interact with all active Claude Code sessions in the system, not only those created via the orchestrator

---

## Acceptance Criteria

**AC1: Discover external sessions via MCP tool**
- Given there are Claude Code sessions running that were NOT created by the orchestrator
- When I call the MCP tool `discover_sessions`
- Then I receive a list of discovered sessions with their metadata (id, project directory, status, creation time)
- And each discovered session is clearly marked with `source: "external"`

**AC2: Discovered sessions are registered in the orchestrator**
- Given `discover_sessions` found N external sessions
- When the discovery completes
- Then each discovered session is registered in the orchestrator's session registry
- And they appear in `list_sessions` results alongside orchestrator-created sessions
- And they have `source: "external"` to distinguish them from `source: "orchestrator"` sessions

**AC3: Filter by project directory**
- Given there are external sessions in multiple project directories
- When I call `discover_sessions` with an optional `projectDir` parameter
- Then only sessions matching that project directory are returned
- And sessions in other directories are excluded

**AC4: Avoid duplicate registration**
- Given an external session that was already discovered and registered
- When I call `discover_sessions` again
- Then the session is NOT duplicated in the registry
- And its metadata is updated if it changed (e.g., status)

**AC5: Retrieve messages from discovered session**
- Given a discovered external session registered in the orchestrator
- When I call `get_session` with its session ID
- Then I receive the session info including recent messages obtained via Agent SDK `getSessionMessages()`

**AC6: Discovery via HTTP endpoint**
- Given there are external Claude Code sessions running
- When I POST to `/api/sessions/discover` with optional `{ projectDir }` body
- Then I receive 200 with `{ discovered: N, sessions: [...] }`
- And new sessions are registered in the orchestrator

**AC7: Discovered sessions have limited operations**
- Given a discovered external session (source: "external")
- When I try to `stop_session` or `end_session` on it
- Then the operation succeeds (Agent SDK supports it)
- But `send_instruction` is NOT available (the session has its own conversation context)
- And the response indicates which operations are available for external sessions

**AC8: Session no longer exists**
- Given a previously discovered session that has since terminated
- When I call `discover_sessions`
- Then the terminated session is updated to status "completed" or "terminated" in the registry
- And it is NOT removed from the registry (preserves history)

---

## Technical Notes

### Agent SDK Functions

```typescript
import { listSessions, getSessionMessages } from '@anthropic-ai/claude-agent-sdk';

// Discover sessions - returns light metadata
const sessions = await listSessions({ projectDir?: string });
// Returns: Array<{ sessionId, projectDir, status, createdAt, ... }>

// Get messages from a specific session
const messages = await getSessionMessages(sessionId);
// Returns: Array<{ role, content, timestamp, ... }>
```

### Archivos a modificar

| Archivo | Cambio |
|---------|--------|
| `src/agents/session-manager.js` | Agregar campo `source` a SessionInfo ("orchestrator" o "external"). Nuevo metodo `discoverSessions(projectDir?)`. Logica de merge/dedup con sesiones existentes. |
| `src/mcp/tools/sessions.js` | Nuevo tool `discover_sessions` con parametro opcional `projectDir` |
| `src/http/routes/sessions.js` | Nuevo endpoint POST `/api/sessions/discover` |
| `tests/` | Tests para discovery, dedup, source field, limited operations |

### SessionInfo extension

```javascript
// Agregar a SessionInfo
{
  // ... campos existentes ...
  source: 'orchestrator',  // default para sesiones creadas via create_session
  // 'external' para sesiones descubiertas
}
```

### Consideraciones

- `listSessions()` del Agent SDK descubre sesiones a nivel de sistema. Puede incluir sesiones del propio orchestrator, por lo que el merge debe ser inteligente: si el sessionId ya existe en el registry con source "orchestrator", no sobreescribir.
- Las sesiones externas no tienen `injectionQueue` (ECO-001) porque no fueron creadas con el AsyncIterable prompt pattern. `send_instruction` no aplica.
- El scan periodico automatico se deja como mejora futura (ECO-009+). Esta historia cubre solo el scan on-demand.
- `getSessionMessages()` puede retornar muchos mensajes. Limitar a los ultimos N (configurable, default 50) para evitar problemas de memoria.

### Impacto en tools existentes

- `list_sessions` debe incluir el campo `source` en su respuesta para todas las sesiones.
- `get_session` debe funcionar transparentemente con sesiones externas (usando `getSessionMessages` del SDK en lugar del activity log interno).

---

## Definition of Done

- [ ] Campo `source` agregado a SessionInfo ("orchestrator" | "external")
- [ ] `discoverSessions(projectDir?)` implementado en session-manager.js
- [ ] Logica de merge/dedup: no duplicar sesiones ya conocidas
- [ ] MCP tool `discover_sessions` registrado y funcional
- [ ] HTTP endpoint POST `/api/sessions/discover` funcional
- [ ] `list_sessions` incluye campo `source` en respuesta
- [ ] `get_session` funciona con sesiones externas (via getSessionMessages)
- [ ] Operaciones limitadas para sesiones externas documentadas y enforced
- [ ] Tests unitarios para discovery y merge logic
- [ ] Tests de integracion para MCP tool y HTTP endpoint
- [ ] Tests de edge cases: sesion ya registrada, sesion terminada, sin sesiones externas
- [ ] Build: 0 errors, 0 warnings
- [ ] Tests existentes siguen pasando

---

## Historial

| Fecha | Evento |
|-------|--------|
| 2026-03-06 | Historia creada. Mejora para visibilidad de sesiones externas al orchestrator. |
