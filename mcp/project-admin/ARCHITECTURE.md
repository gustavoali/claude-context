# Project Admin - Architecture Document

**Version:** 1.0 | **Date:** 2026-02-13 | **Status:** ACTIVE - Phase 1

---

## Component Diagram

```
                    ┌─────────────────────────────────────────────┐
                    │           PROJECT ADMIN BACKEND              │
  MCP stdio         │  ┌──────────┐       ┌──────────────────┐   │  REST :3000
 ◄─────────────────►│  │ index.js │       │    server.js     │   │◄──────────────►
  (Claude Code)     │  │ MCP Entry│       │  Fastify Entry   │   │  (Dashboard)
                    │  └────┬─────┘       └───────┬──────────┘   │
                    │       │   ┌─────────────┐   │              │
                    │       └──►│  MCP Tools  │   │              │
                    │           └──────┬──────┘   │              │
                    │       ┌──────────┼──────────┘              │
                    │       │    ┌─────┴──────┐                  │
                    │       └───►│  Services  │◄─── REST routes  │
                    │            └─────┬──────┘                  │
                    │           ┌──────┴───────┐                 │
                    │           │ Repositories │                 │
                    │           └──────┬───────┘                 │
                    │           ┌──────┴───────┐   ┌──────────┐  │
                    │           │   pg Pool    │   │  Cache   │  │
                    │           └──────┬───────┘   │ (memory) │  │
                    └──────────────────┼───────────┴──────────┘  │
                              ┌────────┴────────┐                │
                              │  PostgreSQL 17  │                │
                              │  :5433 (Docker) │                │
                              └─────────────────┘
```

---

## Components

| Component | File | Responsibility |
|-----------|------|----------------|
| MCP Entry | `src/index.js` | MCP server via stdio, registers tools |
| REST Entry | `src/server.js` | Fastify HTTP on :3000, registers routes + plugins |
| Config | `src/config.js` | Centralized env vars, validated at startup |
| DB Pool | `src/db/pool.js` | PostgreSQL connection pool (pg, max 10) |
| Migration Runner | `src/db/migrate.js` | Sequential SQL migration executor |
| Project Service | `src/services/project-service.js` | CRUD, slug generation, validation |
| Tag Service | `src/services/tag-service.js` | Tag management, tag-based search |
| Relationship Service | `src/services/relationship-service.js` | Inter-project relationships, graph queries |
| Metadata Service | `src/services/metadata-service.js` | Key-value metadata per project |
| Scan Service | `src/services/scan-service.js` | Filesystem auto-discovery, stack detection |
| Health Service | `src/services/health-service.js` | Git status, file detection, health assessment |
| Repositories | `src/repositories/*.js` | SQL queries per table (project, tag, relationship, metadata, scan) |
| MCP Tools | `src/mcp/tools/*.js` | Tool definitions with Zod schemas, delegate to services |
| REST Routes | `src/api/routes/*.js` | Fastify route handlers, delegate to services |
| Error Handler | `src/api/middleware/error-handler.js` | Centralized error formatting for REST |
| Utils | `src/utils/*.js` | git-utils (git CLI), fs-scanner (stack detection), slug, cache, errors |

---

## Data Flow

### REST Request Flow

```
HTTP Request -> Fastify route (validate via schema) -> Service (business logic)
  -> Repository (parameterized SQL) -> pg Pool -> PostgreSQL
  <- JSON response { success, data, meta }
```

### MCP Request Flow

```
MCP Tool Call (stdio) -> Tool handler (validate via Zod) -> Service (shared)
  -> Repository -> pg Pool -> PostgreSQL
  <- MCP response { content: [{ type: 'text', text: JSON.stringify(...) }] }
```

### Filesystem Scan Flow

```
pa_scan_all / POST /scan -> scan-service.scanAllDirectories()
  -> For each configured directory: fs-scanner.detectProjects()
  -> For each candidate: health-service.checkHealth() [cached]
  -> project-service.upsert() -> scan-repository.recordScan()
  <- Scan summary { found, new, updated, errors }
```

---

## Architectural Patterns

### 1. Layered Architecture (strict)

```
Routes/Tools  ->  Services  ->  Repositories  ->  Database
```

- Routes/tools NEVER import repositories or pool
- Services NEVER import route/tool modules
- Repositories contain only SQL + row mapping (no business logic)
- All calls are top-down, never lateral or bottom-up

### 2. Shared Service Layer

The service layer is the single source of business logic for both REST and MCP:

```javascript
// Both interfaces consume the same service
// src/api/routes/projects.js
import { projectService } from '../../services/project-service.js';
fastify.get('/projects', async (req) => {
  const data = await projectService.listProjects(req.query);
  return { success: true, data };
});

// src/mcp/tools/projects.js
import { projectService } from '../../services/project-service.js';
server.tool('pa_list_projects', schema, async (args) => {
  const data = await projectService.listProjects(args);
  return { content: [{ type: 'text', text: JSON.stringify(data) }] };
});
```

### 3. Repository Pattern (raw SQL, parameterized)

Consistent with Sprint Backlog Manager. All SQL lives in repositories. Queries always use `$1, $2` placeholders.

### 4. Module Singleton Pattern

Services and repositories exported as plain object singletons. Pool is a shared module-level instance. Avoids DI complexity; testable via module mocking (jest.mock).

---

## Initialization Sequence

```
1. config.js loads and validates env vars
2. pool.js creates PostgreSQL pool
3. repositories import pool (module-level)
4. services import repositories (module-level)
5a. index.js -> registers MCP tools -> starts stdio server
5b. server.js -> registers Fastify routes/plugins -> starts HTTP :3000
```

MCP and REST are independent entry points, run as separate processes via npm scripts (`start:mcp`, `start:api`).

---

## Error Handling Strategy

### Error Hierarchy (`src/utils/errors.js`)

| Class | Code | HTTP Status | Usage |
|-------|------|-------------|-------|
| `AppError` | varies | varies | Base class |
| `NotFoundError` | `*_NOT_FOUND` | 404 | Entity not found by slug/id |
| `ValidationError` | `VALIDATION_ERROR` | 400 | Invalid input data |
| `ConflictError` | `CONFLICT` | 409 | Duplicate slug, constraint violation |

### Error Flow

- **Services** throw typed errors (NotFoundError, ValidationError, ConflictError)
- **Repositories** propagate DB errors upward (no silent catches)
- **REST layer** catches via `fastify.setErrorHandler()` -> `{ success: false, error: { code, message } }`
- **MCP layer** catches in tool handler -> `{ content: [{ type: 'text', text: message }], isError: true }`
- **Unexpected errors** logged with full stack trace, return generic 500 message

---

## Caching Strategy

In-memory Map with TTL (`src/utils/cache.js`). No external dependency (no Redis).

| Data | TTL | Reason |
|------|-----|--------|
| Filesystem scan results | 5 min | Git operations slow on Windows (~200ms each) |
| Project health data | 5 min | Same filesystem/git cost |
| Ecosystem stats | 2 min | Computed from multiple queries |

**Invalidation rules:**
- Create/update/delete project -> invalidate `project:*`
- Scan operations -> invalidate `scan:*` and `health:*`
- Health check with `?refresh=true` -> bypass cache for that project
- Ecosystem stats invalidated on any project change

---

## Architectural Decisions

| ID | Decision | Rationale |
|----|----------|-----------|
| ADR-001 | Fastify 5.x over Express | Performance, native schema validation, auto-OpenAPI. See ADR-001. |
| ADR-002 | Raw pg driver, no ORM | Consistency with SBM, full SQL control |
| ADR-003 | Separate MCP and REST entry points | Independent lifecycle, simpler debugging |
| ADR-004 | In-memory cache, no Redis | Single-user, <200 projects |
| ADR-005 | ESM module system | Modern standard, consistent with Claude Orchestrator |
| ADR-006 | Prefixed MCP tools (pa_*) | Avoid collisions with SBM tools |

---

## Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| Runtime | Node.js | 20+ LTS |
| HTTP Framework | Fastify | 5.x |
| Database | PostgreSQL | 17 |
| DB Driver | pg | 8.x |
| MCP SDK | @modelcontextprotocol/sdk | 1.x |
| Validation | Zod | 4.x |
| Testing | Jest | 29.x |
| API Docs | @fastify/swagger + @fastify/swagger-ui | latest |
| Module System | ESM (import/export) | - |

---

## Database Schema Overview

```
projects (core registry, JSONB: stack, health, config)
  |-- project_tags (1:N, tag-based filtering)
  |-- project_metadata (1:N, key-value extensible)
  |-- project_relationships (N:N self-referencing, typed edges)
scan_history (audit log of filesystem scans)
```

Key indexes: `projects.slug` (UNIQUE), `projects.status`, `projects.category`, GIN on `projects.stack`, composite UNIQUE on tags/relationships/metadata. Full DDL in `src/db/migrations/001_initial_schema.sql`.

---

## Security Considerations

- **Network:** 127.0.0.1 only. No external access in Phase 1.
- **SQL Injection:** Parameterized queries ($1, $2). Never string concatenation.
- **Path Traversal:** scan-service validates paths against configured SCAN_DIRECTORIES. Rejects `..` segments.
- **Filesystem:** Read-only. Git operations read-only (log, status, branch).
- **Credentials:** In .env (gitignored), never in code.
- **Phase 2+:** API key middleware if exposed beyond localhost.

---

## Performance Targets

| Metric | Target |
|--------|--------|
| REST API p95 (simple) | < 200ms |
| REST API p95 (aggregated) | < 500ms |
| MCP tool response | < 300ms |
| Full scan (26 projects) | < 10s |
| Health check (single) | < 2s |
| Concurrent connections | 50+ |

---

## Phase 2 Integration Preview

```
Project Admin
  |-- HTTP Client --> SBM REST API (sprints, stories, velocity, debt)
  |                   Mapping: PA metadata.sbm_project_id -> SBM projects.id
  |-- HTTP Client --> CO REST API (sessions, agents, tokens)
  |                   Mapping: CO session.cwd -> PA projects.path (prefix match)
  |-- WebSocket Server --> Angular Dashboard (push updates)
```

Integration layer in `src/integrations/` (sbm-client.js, co-client.js) with circuit breaker and 2-min response caching.

---

**Created:** 2026-02-13 | **Related:** SEED_DOCUMENT.md, ADR-001-fastify-vs-express.md
