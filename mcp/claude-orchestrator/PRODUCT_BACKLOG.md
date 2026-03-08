# Backlog - Claude Orchestrator

**Version:** 1.3 | **Actualizacion:** 2026-03-08

## Resumen

| Metrica | Valor |
|---------|-------|
| Pendientes | 7 |
| Completadas | 12 |
| Story points pendientes | 34 |
| Story points completados | 36 |
| Epics | 3 (2 completados, 1 ready) |

## Vision

Evolucionar el orchestrator de gestor pasivo de sesiones a plataforma capaz de soportar un agente autonomo que coordine trabajo multi-proyecto con supervision remota via Telegram.

## Epics

| Epic | Historias | Puntos | Status |
|------|-----------|--------|--------|
| EPIC-ECO-01: Session Injection | ECO-001 | 5 | Completado |
| EPIC-ECO-02: Autonomous Agent Foundation | ECO-002 a ECO-008 | 31 | Completado |
| EPIC-ECO-03: Ecosystem Support Agent | ECO-009 a ECO-015 | 34 | Ready |

## Pendientes (indice)

| ID | Titulo | Pts | Priority | Deps | Ola |
|----|--------|-----|----------|------|-----|
| ECO-015 | Support Agent Configuration & Lifecycle | 3 | Critical | - | 1 |
| ECO-009 | Ecosystem Health Check Engine | 5 | Critical | - | 1 |
| ECO-010 | Docker Container Monitoring | 5 | High | ECO-009 | 2 |
| ECO-012 | Ecosystem Status Dashboard Endpoint | 3 | High | ECO-009 | 2 |
| ECO-011 | Auto-Remediation Actions | 8 | High | ECO-009, ECO-010 | 3 |
| ECO-013 | Scheduled Maintenance Tasks | 5 | Medium | ECO-009, ECO-015 | 4 |
| ECO-014 | Incident Detection & Notification Payloads | 5 | Medium | ECO-009, ECO-006 | 4 |

Detalle de cada story en: `backlog/stories/ECO-XXX-*.md`

### Orden de implementacion

```
Ola 1 (paralelo):   ECO-015 (config, 3pts) + ECO-009 (engine, 5pts)
Ola 2 (paralelo):   ECO-010 (docker, 5pts) + ECO-012 (endpoint, 3pts)
Ola 3 (secuencial):  ECO-011 (remediation, 8pts)
Ola 4 (paralelo):   ECO-013 (maintenance, 5pts) + ECO-014 (notifications, 5pts)
```

## Completadas (indice)

| ID | Titulo | Puntos | Fecha | Detalle |
|----|--------|--------|-------|---------|
| FIX-001 | Duplicate WebSocket events (session:updated 3x/2x) | - | 2026-03-02 | Commit e559503 |
| FIX-002 | Health URL mismatch (/health vs /api/health) | - | 2026-03-02 | Commits e559503, d643ec5 |
| FIX-003 | backlog-client.js env leak (process.env unfiltered) | - | 2026-03-02 | Commit e559503 |
| FIX-004 | PG container resilience (crashes on WSL2 restart) | - | 2026-03-02 | Commit 57ab6d7 |
| ECO-001 | Mid-Session Message Injection | 5 | 2026-03-05 | Commit 7c06525 |
| ECO-002 | Session Health Monitoring | 3 | 2026-03-07 | Commit 90937f4 |
| ECO-003 | Session Activity Log | 3 | 2026-03-07 | Commit 90937f4 |
| ECO-004 | Bulk Session Operations | 2 | 2026-03-07 | Commit 90937f4 |
| ECO-005 | Session Priority Queue | 5 | 2026-03-07 | Commit 90937f4 |
| ECO-006 | Session Events Webhook | 5 | 2026-03-07 | Commit 90937f4 |
| ECO-007 | Inject + Auto-Recovery Pattern | 8 | 2026-03-07 | Commit 90937f4 |
| ECO-008 | Discover External Claude Code Sessions | 5 | 2026-03-07 | Commit 90937f4 |

## ID Registry

| Rango | Estado |
|-------|--------|
| ECO-001 a ECO-008 | Completados |
| ECO-009 a ECO-015 | Pendientes (EPIC-ECO-03) |
Proximo ID: ECO-016
