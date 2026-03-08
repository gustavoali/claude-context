# ECO-012: Ecosystem Status Dashboard Endpoint

**Points:** 3 | **Priority:** High
**Epic:** EPIC-ECO-03: Ecosystem Support Agent
**Depends on:** ECO-009 (Health Check Engine)

---

## User Story

**As a** dashboard client (web-monitor, flutter-monitor, external tool)
**I want** an HTTP endpoint that provides a consolidated view of the entire ecosystem health
**So that** I can display ecosystem status in a dashboard without polling each service individually

---

## Acceptance Criteria

**AC1: GET /api/ecosystem/health endpoint**
- Given the support agent is running with health checks active
- When I send GET to `/api/ecosystem/health`
- Then I receive 200 with a JSON response containing the status of all monitored services
- And the response includes: overall status ("healthy", "degraded", "unhealthy"), services array, last check time

**AC2: Overall status calculation**
- Given some services are healthy and some are unhealthy
- When the overall status is calculated
- Then "healthy" means all services are healthy
- And "degraded" means at least one non-critical service is unhealthy
- And "unhealthy" means at least one critical service is unhealthy

**AC3: Service detail in response**
- Given a service is being monitored
- When the ecosystem health endpoint is called
- Then each service in the response includes: name, type, status, lastCheck, lastTransition, consecutiveFailures, metadata (uptime, ports, etc.)

**AC4: GET /api/ecosystem/health/:serviceName endpoint**
- Given a specific service is being monitored
- When I send GET to `/api/ecosystem/health/project-admin-pg`
- Then I receive the detailed status of only that service
- And if the service name does not exist, I receive 404

**AC5: Support agent disabled response**
- Given the support agent is disabled (`SUPPORT_AGENT_ENABLED=false`)
- When I send GET to `/api/ecosystem/health`
- Then I receive 200 with `{ status: "disabled", message: "Support agent is not enabled" }`

**AC6: MCP tool for ecosystem health**
- Given the support agent is running
- When I call the MCP tool `ecosystem_health`
- Then I receive the same data as the HTTP endpoint
- And I can optionally filter by service name

**AC7: WebSocket event for ecosystem status changes**
- Given a client is connected via WebSocket
- When the overall ecosystem status changes (e.g., healthy -> degraded)
- Then a `ecosystem_status_changed` event is broadcast to all connected clients
- And the event includes the new overall status and the service that triggered the change

---

## Technical Notes

### Response Schema

```javascript
{
  success: true,
  data: {
    status: 'degraded',           // 'healthy' | 'degraded' | 'unhealthy'
    services: [
      {
        name: 'project-admin',
        type: 'http',
        status: 'healthy',
        lastCheck: '2026-03-08T10:00:00Z',
        lastTransition: '2026-03-08T08:00:00Z',
        consecutiveFailures: 0,
        metadata: { endpoint: 'http://localhost:3001/api/health' }
      },
      {
        name: 'project-admin-pg',
        type: 'docker',
        status: 'unhealthy',
        lastCheck: '2026-03-08T10:00:00Z',
        lastTransition: '2026-03-08T09:55:00Z',
        consecutiveFailures: 5,
        metadata: { containerName: 'project-admin-pg', lastError: 'Connection refused' }
      }
    ],
    lastUpdated: '2026-03-08T10:00:00Z',
    checkInterval: 30000
  },
  timestamp: '2026-03-08T10:00:05Z'
}
```

### Archivos a crear/modificar

| Archivo | Cambio |
|---------|--------|
| `src/http/routes/ecosystem.js` | Nuevo: GET /api/ecosystem/health, GET /api/ecosystem/health/:serviceName |
| `src/http/server.js` | Registrar nuevas rutas de ecosystem |
| `src/mcp/tools/sessions.js` | Agregar tool `ecosystem_health` |
| `src/websocket/server.js` | Emitir `ecosystem_status_changed` en cambio de estado global |
| `tests/http/ecosystem.test.js` | Tests de endpoints |
| `tests/mcp/ecosystem-health.test.js` | Tests del MCP tool |

### Consideraciones

- El endpoint NO ejecuta health checks on-demand: devuelve el estado cacheado del ultimo check
- Si el support agent no esta habilitado, el endpoint responde correctamente (no 500)
- Mantener consistencia con el formato de respuesta estandar del HTTP API (`{ success, data, timestamp }`)
- El MCP tool sigue el patron de los tools existentes en sessions.js

---

## Definition of Done

- [ ] GET /api/ecosystem/health implementado con overall status
- [ ] GET /api/ecosystem/health/:serviceName implementado
- [ ] Overall status logic: healthy/degraded/unhealthy
- [ ] MCP tool `ecosystem_health` registrado y funcional
- [ ] WebSocket broadcast en cambio de estado global
- [ ] Respuesta correcta cuando support agent esta deshabilitado
- [ ] Tests unitarios de endpoints y logica de calculo (>70% coverage)
- [ ] Build: 0 errors, 0 warnings
- [ ] Tests existentes siguen pasando

---

## Historial

| Fecha | Evento |
|-------|--------|
| 2026-03-08 | Historia creada. Endpoint consolidado para dashboards. |
