# ECO-014: Incident Detection & Notification Payloads

**Points:** 5 | **Priority:** Medium
**Epic:** EPIC-ECO-03: Ecosystem Support Agent
**Depends on:** ECO-009 (Health Check Engine), ECO-006 (Session Events Webhook)

---

## User Story

**As a** system operator
**I want** the support agent to detect incidents and prepare notification payloads for Telegram and webhooks
**So that** I am notified immediately on my phone when something goes wrong in the ecosystem, even when I am away from my desk

---

## Acceptance Criteria

**AC1: Incident detection from health transitions**
- Given a service transitions from "healthy" to "unhealthy"
- When the `support:health_changed` event fires
- Then an incident record is created with: id, timestamp, service, severity, message, status ("open")
- And the incident is stored in the incident log

**AC2: Severity classification**
- Given a health change event occurs
- When the incident is created
- Then the severity is determined by the service's criticality configuration:
  - "critical" for PostgreSQL databases and core services
  - "warning" for non-essential services (web-monitor, etc.)
  - "info" for recovery events (unhealthy -> healthy)

**AC3: Webhook notification via existing webhook emitter**
- Given an incident is detected
- When the incident has severity "critical" or "warning"
- Then a webhook is emitted using the existing `webhook-emitter.js` (ECO-006)
- And the webhook event type is `ecosystem:incident`
- And the payload includes: incident details, affected service, suggested action

**AC4: Telegram-compatible payload format**
- Given an incident triggers a webhook
- When the payload is prepared
- Then it includes a `telegram` field with a pre-formatted message string
- And the message uses Telegram MarkdownV2 format
- And the message includes: severity icon, service name, status, timestamp, suggested action
- And the message is concise (<500 characters)

**AC5: Incident resolution detection**
- Given a service was in an open incident
- When the service recovers to "healthy"
- Then the incident is updated to status "resolved" with resolution timestamp
- And a recovery webhook is emitted with event type `ecosystem:recovery`
- And the Telegram payload includes a recovery message

**AC6: Incident deduplication**
- Given a service has an open incident
- When the same service fails again (consecutive unhealthy checks)
- Then a new incident is NOT created
- But the existing incident's `lastSeen` timestamp is updated
- And the consecutive failure count is included in the incident

**AC7: Incident log query**
- Given incidents have been detected
- When a consumer calls `supportAgent.getIncidentLog({ status, severity, since })`
- Then it returns filtered incidents matching the criteria
- And the log is capped at the last 200 entries

**AC8: Notification throttling**
- Given multiple services go unhealthy simultaneously (e.g., Docker daemon restart)
- When multiple incidents are created within a short window (configurable, default 30s)
- Then notifications are batched into a single webhook call
- And the Telegram payload summarizes all affected services in one message

---

## Technical Notes

### Incident Schema

```javascript
{
  id: 'INC-001',
  timestamp: '2026-03-08T10:00:00Z',
  service: 'project-admin-pg',
  severity: 'critical',          // 'critical' | 'warning' | 'info'
  message: 'Container stopped unexpectedly',
  status: 'open',                // 'open' | 'resolved'
  resolvedAt: null,
  lastSeen: '2026-03-08T10:00:00Z',
  consecutiveFailures: 5,
  suggestedAction: 'Run: docker start project-admin-pg',
}
```

### Telegram Payload Format

```javascript
{
  telegram: {
    text: "*CRITICAL* | project\\-admin\\-pg\n" +
          "Container stopped unexpectedly\n" +
          "Failures: 5 consecutive\n" +
          "Action: `docker start project\\-admin\\-pg`\n" +
          "_2026\\-03\\-08 10:00:00_",
    parse_mode: 'MarkdownV2'
  }
}
```

### Webhook Event Types

| Event | Trigger |
|-------|---------|
| `ecosystem:incident` | New incident or severity escalation |
| `ecosystem:recovery` | Service recovered from incident |
| `ecosystem:batch` | Multiple incidents batched |

### Service Criticality Configuration

```javascript
const SERVICE_CRITICALITY = {
  'project-admin-pg': 'critical',
  'sprint-backlog-pg': 'critical',
  'project-admin': 'critical',
  'orchestrator-http': 'critical',
  'web-monitor': 'warning',
};
```

### Archivos a crear/modificar

| Archivo | Cambio |
|---------|--------|
| `src/support-agent/incident-reporter.js` | Nuevo: IncidentReporter class, detection, dedup, notification, log |
| `src/support-agent/index.js` | Conectar IncidentReporter con health checker events |
| `src/utils/webhook-emitter.js` | Agregar event types `ecosystem:*` al schema permitido |
| `tests/support-agent/incident-reporter.test.js` | Tests de deteccion, dedup, throttling, telegram format |

### Consideraciones

- Reusar `webhook-emitter.js` existente (ECO-006): NO crear nuevo mecanismo de notificacion
- El flutter-monitor ya procesa webhooks para Telegram bridge: el payload solo necesita el campo `telegram`
- Incident IDs son secuenciales in-memory (INC-001, INC-002...), no persistidos (se resetean al restart)
- La throttling window agrupa incidentes en un solo batch para evitar spam de notificaciones
- Escapar caracteres especiales para Telegram MarkdownV2 (. - _ * etc.)

---

## Definition of Done

- [ ] IncidentReporter class con deteccion desde health events
- [ ] Severity classification por criticidad de servicio
- [ ] Webhook emission via webhook-emitter existente
- [ ] Telegram-compatible payload con MarkdownV2
- [ ] Incident resolution detection y recovery notifications
- [ ] Deduplicacion: no crear incidentes duplicados para mismo servicio
- [ ] Incident log con filtros y cap de 200 entries
- [ ] Notification throttling para incidentes simultaneos
- [ ] Tests unitarios (>70% coverage)
- [ ] Tests de Telegram payload format
- [ ] Build: 0 errors, 0 warnings
- [ ] Tests existentes siguen pasando

---

## Historial

| Fecha | Evento |
|-------|--------|
| 2026-03-08 | Historia creada. Deteccion de incidentes y payloads para Telegram/webhook. |
