# ECO-009: Ecosystem Health Check Engine

**Points:** 5 | **Priority:** Critical
**Epic:** EPIC-ECO-03: Ecosystem Support Agent
**Depends on:** Ninguna

---

## User Story

**As a** system operator
**I want** the orchestrator to periodically check the health of all ecosystem services
**So that** I am immediately aware when a service goes down or becomes unhealthy, without manually checking each one

---

## Acceptance Criteria

**AC1: Health check registry with configurable targets**
- Given the orchestrator has a health check configuration with target services
- When the support agent starts
- Then it loads the list of health check targets from configuration (env vars or config file)
- And each target has: name, type (http/tcp/docker), endpoint/host+port, interval, timeout, expected status

**AC2: HTTP health checks**
- Given a target service is configured with type "http" (e.g., `http://localhost:3001/api/health`)
- When the health check interval fires
- Then the engine sends an HTTP GET request to the endpoint
- And if the response status is 2xx within the timeout, the service is marked "healthy"
- And if the request fails or times out, the service is marked "unhealthy"

**AC3: TCP port checks**
- Given a target service is configured with type "tcp" (e.g., `localhost:5434`)
- When the health check interval fires
- Then the engine attempts a TCP connection to host:port
- And if the connection succeeds within the timeout, the service is marked "healthy"
- And if the connection fails or times out, the service is marked "unhealthy"

**AC4: State transitions with timestamps**
- Given a service transitions from "healthy" to "unhealthy" (or vice versa)
- When the transition is detected
- Then the engine records the transition with timestamp, previous state, new state
- And emits a `support:health_changed` event on the session manager's EventEmitter
- And the service's consecutive failure/success count is tracked

**AC5: Configurable intervals per target**
- Given different services have different check intervals configured
- When the engine is running
- Then each service is checked at its own interval independently
- And the default interval is 30 seconds if not specified

**AC6: Health check results available programmatically**
- Given health checks have been running
- When a consumer calls `supportAgent.getHealthStatus()`
- Then it returns the current status of all targets with last check time, state, consecutive count, and last transition time

**AC7: Graceful startup and shutdown**
- Given the support agent is enabled
- When the orchestrator starts, the health check engine begins after a configurable initial delay (default 5s)
- And when the orchestrator shuts down, all health check timers are cleared cleanly
- And no orphan timers or pending requests remain

**AC8: Unhealthy threshold before alerting**
- Given a service fails a health check
- When the consecutive failure count reaches the configured threshold (default 3)
- Then the service state transitions to "unhealthy"
- And a single `support:health_changed` event is emitted (not on every failed check)
- But if the first check fails and threshold is 1, it transitions immediately

---

## Technical Notes

### Health Check Target Schema

```javascript
{
  name: 'project-admin',
  type: 'http',              // 'http' | 'tcp' | 'docker'
  endpoint: 'http://localhost:3001/api/health',  // for http
  host: 'localhost',         // for tcp
  port: 5434,                // for tcp
  interval: 30000,           // ms, default 30s
  timeout: 5000,             // ms, default 5s
  unhealthyThreshold: 3,     // consecutive failures before unhealthy
  healthyThreshold: 1,       // consecutive successes to recover
}
```

### Default Ecosystem Targets

```javascript
const DEFAULT_TARGETS = [
  { name: 'orchestrator-http', type: 'http', endpoint: 'http://localhost:3000/api/health', interval: 30000 },
  { name: 'project-admin', type: 'http', endpoint: 'http://localhost:3001/api/health', interval: 30000 },
  { name: 'project-admin-pg', type: 'tcp', host: 'localhost', port: 5434, interval: 60000 },
  { name: 'sprint-backlog-pg', type: 'tcp', host: 'localhost', port: 5435, interval: 60000 },
  { name: 'web-monitor', type: 'http', endpoint: 'http://localhost:4200', interval: 60000 },
];
```

### Archivos a crear/modificar

| Archivo | Cambio |
|---------|--------|
| `src/support-agent/health-checker.js` | Nuevo: HealthChecker class con registro de targets, polling, state machine |
| `src/support-agent/config.js` | Nuevo: parseo de SUPPORT_AGENT_* env vars, defaults |
| `tests/support-agent/health-checker.test.js` | Tests unitarios: HTTP checks, TCP checks, state transitions, thresholds |

### Consideraciones

- Usar `node:http` para health checks HTTP (no instalar axios/got)
- Usar `node:net` para TCP checks
- No usar `setInterval` directo: usar un loop con `setTimeout` para evitar overlap si un check tarda mas que el intervalo
- Los targets se definen via env var `SUPPORT_AGENT_TARGETS` (JSON) o hardcoded defaults
- Esta historia NO incluye Docker checks (eso es ECO-010) ni remediacion (ECO-011)

---

## Definition of Done

- [ ] HealthChecker class implementada con HTTP y TCP checks
- [ ] State machine: healthy/unhealthy con thresholds configurables
- [ ] Eventos `support:health_changed` emitidos en transiciones
- [ ] `getHealthStatus()` retorna estado actual de todos los targets
- [ ] Startup con delay configurable, shutdown limpio
- [ ] Tests unitarios con mocks de HTTP/TCP (>70% coverage)
- [ ] Tests de state transitions y thresholds
- [ ] Build: 0 errors, 0 warnings
- [ ] Tests existentes siguen pasando

---

## Historial

| Fecha | Evento |
|-------|--------|
| 2026-03-08 | Historia creada. Nucleo del ecosistema de monitoreo. |
