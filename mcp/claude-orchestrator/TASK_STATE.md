# Estado de Tareas - Claude Orchestrator

**Ultima actualizacion:** 2026-03-07 18:00
**Version:** 0.8.0 (pendiente bump)

---

## Resumen Ejecutivo

Backlog completo implementado. 8 historias (ECO-001 a ECO-008) + 4 fixes completados.
577 tests (23 suites). Code review pasado con fixes aplicados (C-01 a C-03, M-01 a M-03, m-02).

## Completado Esta Sesion

| ID | Titulo | Pts |
|----|--------|-----|
| ECO-002 | Session Health Monitoring | 3 |
| ECO-003 | Session Activity Log | 3 |
| ECO-004 | Bulk Session Operations | 2 |
| ECO-005 | Session Priority Queue | 5 |
| ECO-006 | Session Events Webhook | 5 |
| ECO-007 | Inject + Auto-Recovery Pattern | 8 |
| ECO-008 | Discover External Claude Code Sessions | 5 |

## Code Review Fixes Aplicados

C-01/C-02: CliSessionManager missing methods (detectStaleSessions, getActivityLog, activityLog)
C-03: globalThis -> service-registry.js
M-01: updateSessionMeta allowlist
M-02: replaceAll en recovery prompt
M-03: recoveryLog cleanup on session:ended
m-02: _recordActivity en CLI sendMessage

## Proximos Pasos

1. Bump version a 0.8.0 y commit
2. Test E2E desde browser (pendiente desde ECO-001)
3. Definir siguiente epic (autonomous agent, Flutter integration, etc.)
4. Considerar refactor: extraer clase base para SessionManager y CliSessionManager (M-04)
5. Considerar: webhook HMAC signature (m-01), backoff cap/jitter (m-04)

## Notas para Retomar

- `npm test` - 577 tests (23 suites)
- `npm run server` - WS :8765 + HTTP :3000
- `bash C:/mcp/ecosystem-start.sh` - levanta todo
- Nuevos endpoints: GET /health, GET /:id/activity, GET /:id/recovery-log, POST /discover
- Nuevos MCP tools: bulk_stop_sessions, bulk_end_sessions, update_priority, discover_sessions
- Nuevos WS handlers: bulk_stop, bulk_end, update_priority
- Config vars nuevas: WEBHOOK_*, RECOVERY_*, SESSION_STALE_THRESHOLD_MINUTES, SESSION_MAX_ACTIVITY_LOG
