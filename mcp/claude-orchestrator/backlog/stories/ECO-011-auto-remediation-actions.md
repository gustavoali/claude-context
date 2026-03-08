# ECO-011: Auto-Remediation Actions

**Points:** 8 | **Priority:** High
**Epic:** EPIC-ECO-03: Ecosystem Support Agent
**Depends on:** ECO-009 (Health Check Engine), ECO-010 (Docker Container Monitoring)

---

## User Story

**As a** system operator
**I want** the orchestrator to automatically attempt to fix known problems when detected
**So that** common issues (crashed container, unresponsive service) are resolved without my manual intervention, reducing downtime

---

## Acceptance Criteria

**AC1: Remediation action registry**
- Given the support agent has a registry of known remediation actions
- When a health check detects an unhealthy service
- Then the engine looks up applicable remediation actions for that service
- And if a matching action exists, it is queued for execution

**AC2: Docker container restart remediation**
- Given a Docker container is detected as stopped/exited
- When the remediation engine processes the action
- Then it executes `docker start <containerName>`
- And waits for the container to be running (up to timeout)
- And runs a follow-up health check to verify recovery
- And records the result (success/failure) in the remediation log

**AC3: Remediation cooldown**
- Given a remediation action was attempted for a service
- When the same service fails again within the cooldown period (default 5 minutes)
- Then the remediation is NOT attempted again
- And the incident is escalated (marked as "remediation_exhausted")
- And the escalation event `support:remediation_exhausted` is emitted

**AC4: Maximum retry limit**
- Given a remediation has been attempted N times for the same service
- When N reaches the configured max retries (default 3)
- Then no further remediation is attempted for that service
- And the service is marked as "needs_manual_intervention"
- And the event `support:needs_intervention` is emitted

**AC5: Remediation disabled by default**
- Given the support agent starts
- When `SUPPORT_AGENT_REMEDIATION_ENABLED` is not set or is "false"
- Then health checks run normally
- But no remediation actions are executed
- And the log indicates "remediation disabled, manual action required"

**AC6: Dry-run mode**
- Given `SUPPORT_AGENT_REMEDIATION_DRY_RUN` is set to "true"
- When a remediation action would be executed
- Then the action is logged with all details (what would run, target, reason)
- But the actual command is NOT executed
- And the log entry is marked as "dry_run"

**AC7: Remediation log**
- Given remediations have been attempted
- When a consumer calls `supportAgent.getRemediationLog()`
- Then it returns a list of all remediation attempts with: timestamp, service, action, result, duration, error (if failed)
- And the log is capped at the last 100 entries

**AC8: Custom remediation commands**
- Given a service has a custom remediation command configured
- When that service becomes unhealthy
- Then the custom command is executed instead of the default action
- And the command is run with a timeout (default 30s)
- And the output is captured in the remediation log

---

## Technical Notes

### Remediation Action Schema

```javascript
{
  serviceName: 'project-admin-pg',
  action: 'docker_restart',       // 'docker_restart' | 'custom_command'
  command: null,                   // for custom_command: 'systemctl restart x'
  timeout: 30000,                 // ms
  cooldown: 300000,               // ms (5 min)
  maxRetries: 3,
  verifyAfter: true,              // run health check after remediation
  verifyDelay: 5000,              // ms to wait before verify check
}
```

### Default Remediation Actions

```javascript
const DEFAULT_REMEDIATIONS = {
  'project-admin-pg': { action: 'docker_restart', containerName: 'project-admin-pg' },
  'sprint-backlog-pg': { action: 'docker_restart', containerName: 'sprint-backlog-pg' },
};
```

### Archivos a crear/modificar

| Archivo | Cambio |
|---------|--------|
| `src/support-agent/remediator.js` | Nuevo: Remediator class, action registry, cooldown tracking, retry counting, log |
| `src/support-agent/health-checker.js` | Hook: al detectar unhealthy, notificar remediator |
| `tests/support-agent/remediator.test.js` | Tests: docker restart, cooldown, max retries, dry-run, custom commands |

### Consideraciones

- Auto-remediacion es CONSERVADORA: solo restart, nunca delete/recreate
- Usar `execFile` con timeout estricto para todos los comandos
- El cooldown se trackea por servicio, no globalmente
- Los retries se resetean cuando el servicio vuelve a healthy por N checks consecutivos (configurable, default 5)
- Dry-run mode es ideal para validar configuracion antes de habilitar remediacion real
- No remediar el propio orchestrator (self-remediation crea loops peligrosos)

### Seguridad

- Solo permitir comandos de una whitelist configurable
- No ejecutar comandos arbitrarios del usuario sin validacion
- Loguear TODOS los comandos ejecutados con timestamp y resultado
- No pasar variables de entorno sensibles a los comandos de remediacion

---

## Definition of Done

- [ ] Remediator class con action registry
- [ ] Docker container restart action implementada
- [ ] Cooldown tracking por servicio
- [ ] Max retry limit con escalacion
- [ ] Remediacion deshabilitada por defecto
- [ ] Dry-run mode funcional
- [ ] Remediation log con cap de 100 entries
- [ ] Custom command support con timeout
- [ ] Integracion con health checker (hook en transicion a unhealthy)
- [ ] Verify-after-remediation con delay configurable
- [ ] Tests unitarios con mocks (>70% coverage)
- [ ] Tests de cooldown, retry exhaustion, dry-run
- [ ] Build: 0 errors, 0 warnings
- [ ] Tests existentes siguen pasando

---

## Historial

| Fecha | Evento |
|-------|--------|
| 2026-03-08 | Historia creada. Auto-remediacion conservadora de servicios del ecosistema. |
