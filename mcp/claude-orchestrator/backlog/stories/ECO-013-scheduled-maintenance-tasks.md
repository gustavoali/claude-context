# ECO-013: Scheduled Maintenance Tasks

**Points:** 5 | **Priority:** Medium
**Epic:** EPIC-ECO-03: Ecosystem Support Agent
**Depends on:** ECO-009 (Health Check Engine), ECO-015 (Configuration & Lifecycle)

---

## User Story

**As a** system operator
**I want** the orchestrator to execute periodic maintenance tasks automatically
**So that** routine cleanup (stale sessions, old logs, temp files) happens without manual intervention, keeping the ecosystem lean

---

## Acceptance Criteria

**AC1: Maintenance task registry**
- Given the support agent has a list of maintenance tasks
- When the support agent starts
- Then each task is scheduled at its configured interval
- And tasks include: stale session cleanup, activity log trimming, remediation log trimming

**AC2: Stale session cleanup**
- Given there are sessions that have been idle longer than `SESSION_STALE_THRESHOLD_MINUTES`
- When the stale cleanup task runs
- Then sessions exceeding the threshold are ended via the existing `endSession()` method
- And a summary is logged: N sessions cleaned up, their IDs and ages

**AC3: Activity log trimming**
- Given session activity logs have accumulated beyond `SESSION_MAX_ACTIVITY_LOG` entries
- When the activity log trim task runs
- Then each session's activity log is trimmed to the configured maximum
- And the oldest entries are removed first

**AC4: Maintenance task execution log**
- Given a maintenance task has run
- When the task completes
- Then the result is recorded: task name, timestamp, duration, items processed, errors
- And the log is available via `supportAgent.getMaintenanceLog()`

**AC5: Configurable schedule per task**
- Given different tasks have different optimal intervals
- When configuring maintenance tasks
- Then each task has its own interval (e.g., stale cleanup every 10min, log trim every 1h)
- And tasks can be individually enabled/disabled

**AC6: Task locking (no overlap)**
- Given a maintenance task is currently running
- When the same task's interval fires again
- Then the new execution is skipped
- And a warning is logged indicating overlap detected

**AC7: On-demand execution via MCP tool**
- Given the support agent is running
- When I call the MCP tool `run_maintenance` with an optional `taskName` parameter
- Then the specified task (or all tasks) runs immediately
- And the result is returned in the tool response

**AC8: Maintenance disabled by default**
- Given the support agent starts
- When `SUPPORT_AGENT_MAINTENANCE_ENABLED` is not set or is "false"
- Then no maintenance tasks are scheduled
- But on-demand execution via MCP tool still works

---

## Technical Notes

### Maintenance Task Schema

```javascript
{
  name: 'stale_session_cleanup',
  handler: async () => { /* ... */ },
  interval: 600000,       // ms (10 min)
  enabled: true,
  lastRun: null,
  running: false,          // lock flag
}
```

### Default Tasks

```javascript
const DEFAULT_TASKS = [
  { name: 'stale_session_cleanup', interval: 600000 },    // 10 min
  { name: 'activity_log_trim', interval: 3600000 },       // 1 hour
  { name: 'remediation_log_trim', interval: 3600000 },    // 1 hour
];
```

### Archivos a crear/modificar

| Archivo | Cambio |
|---------|--------|
| `src/support-agent/maintenance.js` | Nuevo: MaintenanceScheduler class, task registry, locking, log |
| `src/support-agent/index.js` | Instanciar MaintenanceScheduler, conectar con session manager |
| `src/mcp/tools/sessions.js` | Agregar tool `run_maintenance` |
| `tests/support-agent/maintenance.test.js` | Tests de scheduling, locking, on-demand |

### Consideraciones

- Reusar `cleanupStaleSessions()` existente del session manager para stale cleanup
- Reusar `SESSION_MAX_ACTIVITY_LOG` existente para log trimming
- Las tareas de mantenimiento no deben bloquear el event loop: usar async/await
- El log de mantenimiento se limita a las ultimas 50 ejecuciones
- Considerar agregar future tasks: disk usage check, temp file cleanup (post-MVP)

---

## Definition of Done

- [ ] MaintenanceScheduler class con task registry
- [ ] Stale session cleanup task implementada (reusa existente)
- [ ] Activity log trimming task implementada
- [ ] Remediation log trimming task implementada
- [ ] Task locking para prevenir overlap
- [ ] Configurable intervals y enable/disable por task
- [ ] MCP tool `run_maintenance` registrado y funcional
- [ ] Maintenance log con cap de 50 entries
- [ ] Disabled by default, habilitado via env var
- [ ] Tests unitarios (>70% coverage)
- [ ] Build: 0 errors, 0 warnings
- [ ] Tests existentes siguen pasando

---

## Historial

| Fecha | Evento |
|-------|--------|
| 2026-03-08 | Historia creada. Tareas de mantenimiento periodicas. |
