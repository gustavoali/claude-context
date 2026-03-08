# Learnings - Claude Orchestrator

### 2026-03-07 - ESM Jest: `jest` is not a global, must import from `@jest/globals`
**Context:** Writing tests for auto-recovery.js in an ESM project using Jest with `--experimental-vm-modules`
**Learning:** In ESM mode, `jest.fn()`, `jest.mock()`, etc. are NOT available as globals. You must explicitly `import { jest, describe, it, expect, beforeEach } from '@jest/globals';` at the top of every test file. Without this import, tests will fail with `ReferenceError: jest is not defined`. This is different from CommonJS mode where Jest injects globals automatically.
**Applies to:** Any Node.js ESM project using Jest (`"type": "module"` in package.json)

### 2026-03-07 - Express: `express.json()` middleware must be added before POST routes
**Context:** Adding `POST /api/sessions/discover` endpoint to an Express server that previously only had GET endpoints
**Learning:** If an Express server starts with only GET endpoints, `express.json()` middleware may not be configured. When adding POST endpoints later, `req.body` will be `undefined` without it. This also affects existing POST endpoints (like `/:id/inject`) that may have been silently broken. Always verify body-parsing middleware is present when adding POST routes.
**Applies to:** Express.js servers that evolve incrementally from GET-only to mixed HTTP methods

### 2026-03-07 - Express: Named routes (`POST /discover`) must precede parameterized routes (`GET /:id`)
**Context:** Adding `POST /discover` to a router that already had `GET /:id`, `GET /:id/activity`, etc.
**Learning:** Express evaluates routes in registration order. A `POST /discover` registered after `GET /:id` would match the `:id` parameter with value "discover" on GET requests (not POST, but confusing for debugging). More critically, if both are the same HTTP method, the parameterized route would shadow the named one. Always register specific named routes before parameterized catch-all routes like `/:id`.
**Applies to:** Express routers with mixed named and parameterized routes

### 2026-03-08 - WSL2 Docker: Port forwarding may silently fail; use `docker exec` as workaround
**Context:** Debugging PostgreSQL connectivity - container running, port mapping correct (`0.0.0.0:5434->5432`), `pg_isready` OK inside container, but `ECONNREFUSED` from Windows on `127.0.0.1:5434`
**Learning:** WSL2 Docker port forwarding can silently stop working even when containers are running with correct port mappings. Diagnosis chain: (1) check container status via `wsl docker inspect`, (2) check port mapping via `wsl docker port`, (3) verify DB health inside container via `docker exec pg_isready`, (4) check Windows port via `netstat`. If ports aren't forwarded, use `docker exec` to interact with the DB directly as a workaround. Fix: restart WSL (`wsl --shutdown`) or check Hyper-V firewall rules.
**Applies to:** Any project using Docker databases via WSL2 on Windows

