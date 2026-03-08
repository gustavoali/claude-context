# ECO-015: Support Agent Configuration & Lifecycle

**Points:** 3 | **Priority:** Critical
**Epic:** EPIC-ECO-03: Ecosystem Support Agent
**Depends on:** Ninguna

---

## User Story

**As a** system operator
**I want** the support agent to be a well-defined, configurable module with clear startup and shutdown lifecycle
**So that** I can enable/disable it, configure its behavior via environment variables, and trust it integrates cleanly with the existing orchestrator

---

## Acceptance Criteria

**AC1: Support agent module structure**
- Given the orchestrator codebase
- When the support agent module is created
- Then it lives under `src/support-agent/` with its own `index.js` entry point
- And the `SupportAgent` class exposes `start()`, `stop()`, and `getStatus()` methods

**AC2: Enabled via environment variable**
- Given `SUPPORT_AGENT_ENABLED=true` is set
- When the orchestrator starts (via `npm run server`)
- Then the support agent is instantiated and `start()` is called
- And a log message confirms "Support agent started"

**AC3: Disabled by default**
- Given `SUPPORT_AGENT_ENABLED` is not set or is "false"
- When the orchestrator starts
- Then the support agent is NOT instantiated
- And no health checks, maintenance, or remediations run
- And the orchestrator operates exactly as before (zero impact)

**AC4: Configuration via env vars**
- Given the support agent is enabled
- When it reads configuration
- Then the following env vars are supported:
  - `SUPPORT_AGENT_ENABLED` (boolean, default false)
  - `SUPPORT_AGENT_CHECK_INTERVAL` (ms, default 30000)
  - `SUPPORT_AGENT_STARTUP_DELAY` (ms, default 5000)
  - `SUPPORT_AGENT_TARGETS` (JSON string, override default targets)
  - `SUPPORT_AGENT_REMEDIATION_ENABLED` (boolean, default false)
  - `SUPPORT_AGENT_REMEDIATION_DRY_RUN` (boolean, default false)
  - `SUPPORT_AGENT_MAINTENANCE_ENABLED` (boolean, default false)
- And missing env vars use sensible defaults

**AC5: Graceful shutdown**
- Given the support agent is running
- When the orchestrator receives SIGTERM or SIGINT
- Then `stop()` is called on the support agent
- And all timers are cleared
- And all pending health check requests are aborted
- And the agent reports "Support agent stopped" in logs

**AC6: Status reporting**
- Given the support agent is running
- When I call `supportAgent.getStatus()`
- Then it returns: enabled, uptime, componentsActive (healthChecker, maintenance, remediator), lastHealthCheck, targetCount

**AC7: Integration with server.js**
- Given the orchestrator server starts
- When the support agent is enabled
- Then it receives a reference to the SessionManager (for stale cleanup, events)
- And it receives a reference to the WebhookEmitter (for notifications)
- And it does NOT create duplicate instances of existing services

**AC8: .env.example updated**
- Given the new env vars exist
- When a developer looks at `.env.example`
- Then all `SUPPORT_AGENT_*` variables are documented with descriptions and defaults

---

## Technical Notes

### SupportAgent Class

```javascript
class SupportAgent {
  constructor({ sessionManager, webhookEmitter, config }) { }

  async start() { }     // Initialize and start all enabled components
  async stop() { }      // Stop all components, clear timers
  getStatus() { }       // Return current status
  getHealthStatus() { } // Delegate to health checker
  getRemediationLog() { }  // Delegate to remediator
  getMaintenanceLog() { }  // Delegate to maintenance scheduler
  getIncidentLog() { }     // Delegate to incident reporter
}
```

### Archivos a crear/modificar

| Archivo | Cambio |
|---------|--------|
| `src/support-agent/index.js` | Nuevo: SupportAgent class, lifecycle management |
| `src/support-agent/config.js` | Nuevo: Configuration parsing, defaults, validation |
| `src/server.js` | Instanciar SupportAgent si habilitado, conectar con SessionManager y WebhookEmitter |
| `src/config.js` | Agregar SUPPORT_AGENT_* vars al config loader existente |
| `.env.example` | Documentar nuevas variables |
| `tests/support-agent/index.test.js` | Tests de lifecycle, config, enable/disable |
| `tests/support-agent/config.test.js` | Tests de parsing y defaults |

### Consideraciones

- Este es el "shell" del support agent. Las funcionalidades reales (health checks, docker monitoring, remediation, maintenance, incidents) se implementan en stories separadas y se conectan aqui.
- El SupportAgent sigue el mismo patron de EventEmitter que el SessionManager.
- Los componentes internos (healthChecker, remediator, etc.) son opcionales: si una story no esta implementada aun, el SupportAgent funciona sin ese componente.
- La integracion con server.js debe ser minimal: una linea para instanciar, una para start, una para stop.

---

## Definition of Done

- [ ] SupportAgent class con start/stop/getStatus
- [ ] Configuration parsing con defaults sensatos
- [ ] Enabled/disabled via env var, disabled by default
- [ ] Graceful shutdown: todos los timers limpiados
- [ ] Integration con server.js: instanciacion condicional
- [ ] .env.example actualizado con todas las SUPPORT_AGENT_* vars
- [ ] Tests unitarios de lifecycle y config (>70% coverage)
- [ ] Tests de integracion: start/stop ciclo completo
- [ ] Orchestrator funciona identicamente cuando agent esta deshabilitado
- [ ] Build: 0 errors, 0 warnings
- [ ] Tests existentes siguen pasando

---

## Historial

| Fecha | Evento |
|-------|--------|
| 2026-03-08 | Historia creada. Fundacion del modulo Support Agent. |
