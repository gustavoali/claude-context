# ADR-001: Fastify vs Express for HTTP Framework

**Date:** 2026-02-13
**Status:** Accepted
**Decision Maker:** Lead Architect
**Project:** Project Admin

---

## Context

Project Admin needs an HTTP framework to serve a REST API on port 3000. The API will be consumed by an Angular Web Dashboard (Phase 2+), a Flutter mobile app (optional), and potentially other internal services. The project also runs an MCP server via stdio, but the HTTP framework only applies to the REST API entry point (`server.js`).

The ecosystem already has precedent:
- **Sprint Backlog Manager (SBM):** Does not have a REST API (MCP-only via stdio). No HTTP framework to reference.
- **Claude Orchestrator (CO):** Uses Express with WebSocket support.
- **AtlasOps:** Uses Fastify (TypeScript) for its Node.js services.

The development team has primary experience with Express. The choice must balance performance, ecosystem maturity, developer experience, and long-term maintainability.

---

## Decision

**Use Fastify 5.x** as the HTTP framework for Project Admin's REST API.

---

## Alternatives Considered

### 1. Express 4.x / 5.x

**Pros:**
- De facto standard for Node.js HTTP servers
- Massive ecosystem of middleware (10,000+ npm packages)
- Team has direct experience (Claude Orchestrator uses it)
- Extremely mature, stable, well-documented
- Express 5 brings async error handling improvements

**Cons:**
- No built-in schema validation (requires express-validator, joi, or zod middleware)
- No built-in serialization optimization
- Middleware-based architecture can lead to "middleware soup" in complex APIs
- No native OpenAPI/Swagger generation from route schemas
- Performance: ~30-40% slower than Fastify in benchmarks for JSON serialization workloads
- No built-in lifecycle hooks (onRequest, onSend, onClose)

### 2. Fastify 5.x (chosen)

**Pros:**
- Native JSON schema validation on routes (request and response)
- Built-in serialization with fast-json-stringify (~2x faster JSON responses)
- Plugin system with encapsulation (decorators, hooks scoped to plugin)
- First-class @fastify/swagger integration: auto-generates OpenAPI spec from route schemas
- Lifecycle hooks (onRequest, preHandler, onSend, onClose) are cleaner than middleware chains
- ~30-40% better throughput than Express in JSON-heavy workloads
- Built-in logging via pino (structured, fast)
- TypeScript-first design (beneficial for future TS migration)
- Active development, backed by OpenJS Foundation
- Already in use in the ecosystem (AtlasOps)

**Cons:**
- Smaller middleware ecosystem than Express (though growing rapidly)
- Plugin encapsulation model has a learning curve
- Some Express middleware requires @fastify/express compatibility layer
- Team has less direct experience compared to Express

### 3. Hono

**Pros:**
- Ultra-lightweight, excellent performance
- Works across runtimes (Node, Deno, Bun, Cloudflare Workers)
- Modern API design

**Cons:**
- Relatively new (less battle-tested for production backends)
- Smaller plugin ecosystem
- No built-in Swagger generation as mature as @fastify/swagger
- Less community support and fewer tutorials
- Multi-runtime portability is not needed (Project Admin is Node.js only)

---

## Detailed Technical Justification

### 1. Native Schema Validation Eliminates Boilerplate

Fastify validates request params, query, body, and headers from JSON Schema or Zod schemas declared in the route definition. This eliminates the need for separate validation middleware.

```javascript
// Fastify: validation is part of the route definition
fastify.get('/projects', {
  schema: {
    querystring: {
      type: 'object',
      properties: {
        status: { type: 'string', enum: ['active', 'archived', 'deprecated', 'planned'] },
        category: { type: 'string' },
        page: { type: 'integer', minimum: 1, default: 1 },
        limit: { type: 'integer', minimum: 1, maximum: 100, default: 20 },
      },
    },
    response: {
      200: projectListResponseSchema,
    },
  },
  handler: async (request, reply) => {
    // request.query is already validated and typed
    const data = await projectService.listProjects(request.query);
    return { success: true, data };
  },
});
```

With Express, this would require a separate validation middleware (express-validator, celebrate, or custom zod middleware), adding complexity and boilerplate to every route.

### 2. Automatic OpenAPI Generation

@fastify/swagger reads route schemas and generates a complete OpenAPI 3.x spec automatically. This is a Phase 1 deliverable (API documentation). With Express, we would need swagger-jsdoc with JSDoc annotations or manually written spec files.

```javascript
// One plugin registration, all routes are documented
await fastify.register(swagger, {
  openapi: {
    info: { title: 'Project Admin API', version: '1.0.0' },
  },
});
await fastify.register(swaggerUi, { routePrefix: '/docs' });
```

### 3. Performance for JSON-Heavy Workloads

Project Admin's REST API is almost entirely JSON serialization: listing projects, returning metadata, ecosystem stats. Fastify's fast-json-stringify pre-compiles serializers from response schemas, providing measurably faster JSON output.

While the absolute difference is small at our scale (26-200 projects), the architecture gets this optimization for free with no additional code.

### 4. Structured Logging Built-In

Fastify uses pino for logging, which outputs structured JSON logs. This aligns with the observability requirements (structured logging with levels). Express requires adding morgan or winston manually.

### 5. Plugin Encapsulation

Fastify's plugin system provides proper encapsulation. Each plugin can add decorators, hooks, and routes that are scoped. This is cleaner than Express's flat middleware chain for organizing a multi-domain API (projects, tags, relationships, scan, ecosystem).

### 6. Lifecycle Hooks

Fastify provides granular lifecycle hooks (onRequest, preParsing, preValidation, preHandler, preSerialization, onSend, onResponse, onTimeout, onError, onClose). This is more structured than Express's `app.use()` middleware, making it easier to add cross-cutting concerns (request logging, timing, cache headers) at the right point in the lifecycle.

---

## Migration Risk Assessment

The risk of choosing Fastify over Express is **low**:

- **API surface similarity:** Route definition syntax is nearly identical (`fastify.get()` vs `app.get()`)
- **Request/reply objects:** Similar to Express req/res, with some naming differences
- **Async handlers:** Fastify natively supports async handlers and auto-sends the return value (no `res.send()` needed for return values)
- **Express compatibility:** @fastify/express plugin exists as a bridge if any Express middleware is needed
- **Team ramp-up:** Estimated 2-4 hours of documentation reading for a developer familiar with Express

---

## Consequences

### Positive

- Route schema validation and OpenAPI docs come with minimal extra work
- Better performance baseline for JSON APIs
- Structured logging out of the box
- Consistent with AtlasOps (another ecosystem project using Fastify)
- Plugin system scales better as API grows (Phase 2+ with more endpoints)
- Future TypeScript migration will be smoother (Fastify has first-class TS support)

### Negative

- Team needs to learn Fastify plugin model and decorator pattern
- Some Express middleware patterns need adaptation (e.g., app.use() -> fastify.register())
- Claude Orchestrator uses Express, creating a minor inconsistency in the ecosystem
- Fewer Stack Overflow answers and community examples compared to Express

### Neutral

- Testing approach is similar: Fastify provides `fastify.inject()` for integration tests (equivalent to supertest for Express)
- Deployment and operational model is identical
- No impact on MCP server (index.js), which does not use HTTP

---

## References

- [Fastify Documentation](https://fastify.dev/docs/latest/)
- [Fastify vs Express Benchmarks](https://fastify.dev/benchmarks/)
- [@fastify/swagger](https://github.com/fastify/fastify-swagger)
- [Fastify Plugin Guide](https://fastify.dev/docs/latest/Reference/Plugins/)

---

**Decision recorded:** 2026-02-13
**Applies to:** Project Admin REST API (src/server.js and src/api/*)
**Does not apply to:** MCP server (src/index.js), which uses @modelcontextprotocol/sdk directly
