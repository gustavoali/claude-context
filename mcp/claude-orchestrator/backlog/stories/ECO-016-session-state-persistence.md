# ECO-016: Session State Persistence

**Points:** 5 | **Priority:** Critical
**Epic:** (Standalone - prerequisito de EPIC-ECO-03)
**Depends on:** ninguna
**Blocks:** ECO-011 (Auto-Remediation necesita reinicio sin perder sesiones)

---

## User Story

**As a** system operator
**I want** the orchestrator to persist session state to disk and restore it on startup
**So that** restarting the orchestrator process does not lose the mapping between orchestrator sessions and their underlying Claude CLI/SDK sessions, enabling seamless resume after restarts

---

## Acceptance Criteria

**AC1: Auto-save on state change**
- Given persistence is enabled (`PERSISTENCE_ENABLED=true`)
- When a session changes state (created, updated, ended, priority changed, message sent)
- Then the full session map is serialized to the configured file path
- And the write is async (does not block the event loop)
- And only one write is in-flight at a time (coalesce rapid changes)

**AC2: Periodic auto-save**
- Given persistence is enabled
- When the configured interval elapses (default 30s, configurable via `PERSISTENCE_INTERVAL_MS`)
- Then a save is triggered if there are unsaved changes (dirty flag)
- And if there are no unsaved changes, the write is skipped
- And the interval timer is cleaned up on graceful shutdown

**AC3: Restore sessions on startup**
- Given a persistence file exists at the configured path
- When the SessionManager initializes
- Then it reads the file and restores all sessions that were in `idle`, `working`, or `waiting_input` status
- And sessions that were `ended` or `error` are NOT restored (they are discarded)
- And restored sessions have status set to `idle` (not `working`, since no process is running)
- And the `createdAt` timestamp is preserved from the original session
- And `updatedAt` is set to the current time

**AC4: Resume validation for restored sessions**
- Given sessions have been restored from persistence
- When a consumer calls `sendMessage(sessionId, prompt)` on a restored session
- Then the session resumes using the stored `conversationId` (CLI mode) or `agentSessionId` (SDK mode)
- And if the underlying session no longer exists (expired, purged), the error is caught
- And the session status is set to `error` with statusDetail indicating "resume failed: session expired"
- And the failure is recorded in the activity log

**AC5: Expired session cleanup**
- Given sessions are being restored from the persistence file
- When a session's `updatedAt` is older than `PERSISTENCE_MAX_AGE_HOURS` (default 24h)
- Then that session is NOT restored
- And a log entry indicates "session [id] expired, skipping restore"
- And the expired session is removed from the persisted file on next save

**AC6: Persistence file path configuration**
- Given `PERSISTENCE_PATH` is set to a custom path
- When the orchestrator initializes persistence
- Then it uses the custom path for reading and writing state
- And if the directory does not exist, it is created recursively
- And if the path is not writable, an error is logged and persistence is disabled gracefully (orchestrator continues without persistence)
- And the default path is `~/.claude-orchestrator/sessions.json`

**AC7: Disabled by default**
- Given `PERSISTENCE_ENABLED` is not set or is "false"
- When the orchestrator starts
- Then no persistence file is read or written
- And the orchestrator behaves exactly as before (sessions in memory only)
- And no persistence-related errors or warnings are logged

**AC8: Graceful shutdown save**
- Given persistence is enabled and there are active sessions
- When the orchestrator receives SIGTERM or SIGINT
- Then a final save is performed synchronously before the process exits
- And the save includes all current session state
- And if the save fails, the error is logged but the process still exits

**AC9: Corrupted file recovery**
- Given the persistence file exists but contains invalid JSON
- When the orchestrator attempts to restore sessions
- Then the corrupted file is renamed to `sessions.json.corrupt.{timestamp}`
- And the orchestrator starts with an empty session map
- And a warning is logged: "persistence file corrupted, starting fresh"
- And a new valid file is created on the next save

**AC10: Concurrent access safety**
- Given multiple writes could be triggered in rapid succession (e.g., bulk operations)
- When writes are coalesced
- Then a dirty flag is set on each state change
- And the actual write happens at most once per `PERSISTENCE_DEBOUNCE_MS` (default 1000ms)
- And if a write is in progress when another is requested, the next write is deferred (not dropped)

---

## Technical Notes

### Persistence File Schema

```json
{
  "version": 1,
  "savedAt": "2026-03-08T12:00:00.000Z",
  "mode": "cli",
  "sessions": {
    "uuid-1": {
      "id": "uuid-1",
      "agentSessionId": null,
      "conversationId": "abc123",
      "cwd": "/path/to/project",
      "name": "session-name",
      "status": "idle",
      "statusDetail": null,
      "createdAt": "2026-03-08T10:00:00.000Z",
      "updatedAt": "2026-03-08T11:30:00.000Z",
      "tokenUsage": { "input": 1500, "output": 800 },
      "allowedTools": ["Bash", "Read", "Write"],
      "priority": "normal",
      "meta": {}
    }
  }
}
```

### Que se persiste vs que NO

| Se persiste | NO se persiste |
|-------------|----------------|
| id, agentSessionId, conversationId | AbortController (controller) |
| cwd, name, status, statusDetail | In-flight promises |
| createdAt, updatedAt | WebSocket subscriptions |
| tokenUsage, allowedTools, priority | Event listeners |
| meta | activityLog (demasiado grande, transient) |

### Archivos a crear/modificar

| Archivo | Cambio |
|---------|--------|
| `src/persistence/state-persister.js` | Nuevo: StatePersister class, save/load/debounce/cleanup |
| `src/agents/base-session-manager.js` | Hook: emitir evento en cada cambio de estado para que persister reaccione |
| `src/agents/session-manager.js` | Integrar persister en constructor, restore en init |
| `src/agents/cli-session-manager.js` | Integrar persister en constructor, restore en init |
| `src/config.js` | Agregar PERSISTENCE_* variables |
| `src/server.js` | Graceful shutdown hook para final save |
| `tests/persistence/state-persister.test.js` | Tests: save, load, debounce, corrupted file, expired cleanup, disabled mode |

### Configuracion (env vars)

| Variable | Default | Descripcion |
|----------|---------|-------------|
| `PERSISTENCE_ENABLED` | `false` | Habilitar persistencia |
| `PERSISTENCE_PATH` | `~/.claude-orchestrator/sessions.json` | Archivo de estado |
| `PERSISTENCE_INTERVAL_MS` | `30000` | Intervalo de auto-save periodico |
| `PERSISTENCE_DEBOUNCE_MS` | `1000` | Debounce entre writes |
| `PERSISTENCE_MAX_AGE_HOURS` | `24` | Edad maxima de sesiones restauradas |

### Consideraciones

- El `activityLog` NO se persiste: es grande, transient, y se regenera con el uso. Persistir solo los datos necesarios para resume.
- Los `Date` objects se serializan como ISO strings y se rehidratan al cargar.
- El campo `version` en el schema permite migraciones futuras si cambia la estructura.
- El debounce previene escrituras excesivas durante bulk operations (ECO-004).
- La validacion de resume (AC4) ocurre lazy: al primer `sendMessage`, no al restore. Esto evita hacer N llamadas de validacion al startup.
- No persistir sesiones `ended` o `error`: son historicas y no tienen valor para resume.
- El `mode` en el archivo sirve como sanity check: si cambio de CLI a SDK, las sesiones anteriores no son resumibles.

### Seguridad

- El archivo de persistencia puede contener paths de proyectos. No incluir tokens ni API keys.
- Permisos del archivo: 0600 (solo el usuario owner puede leer/escribir).
- No loguear contenido completo de sesiones, solo IDs y conteos.

---

## Definition of Done

- [ ] StatePersister class implementada con save/load/debounce
- [ ] Auto-save on state change (event-driven)
- [ ] Auto-save periodico con dirty flag
- [ ] Restore de sesiones al startup con filtro de status
- [ ] Resume funcional post-restore (CLI conversationId y SDK agentSessionId)
- [ ] Expired session cleanup (max age configurable)
- [ ] Path configurable con creacion de directorio
- [ ] Deshabilitado por defecto
- [ ] Graceful shutdown save
- [ ] Recuperacion de archivo corrupto
- [ ] Debounce de escrituras concurrentes
- [ ] Config vars agregadas a config.js y .env.example
- [ ] Tests unitarios (>70% coverage)
- [ ] Tests de integracion: save -> kill -> restore -> resume
- [ ] Build: 0 errors, 0 warnings
- [ ] Tests existentes siguen pasando (577+)

---

## Historial

| Fecha | Evento |
|-------|--------|
| 2026-03-08 | Historia creada. Prerequisito de EPIC-ECO-03 para reinicio sin perdida de sesiones. |
