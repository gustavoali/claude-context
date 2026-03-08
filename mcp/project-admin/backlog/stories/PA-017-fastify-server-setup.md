# PA-017: Fastify server setup con plugins base

**Points:** 3 | **Priority:** Critical | **MoSCoW:** Must Have
**Epic:** EPIC-PA-004 | **DoR Level:** L1 | **Sprint:** 1

## User Story

**As a** frontend developer or API consumer
**I want** a REST API server running on Fastify with Swagger documentation
**So that** I can interact with Project Admin via standard HTTP requests

## Acceptance Criteria

**AC1: Server starts**
- Given the database is running and migrated
- When I run `npm run start:api` (or `node src/server.js`)
- Then a Fastify server starts on configured API_PORT (default 3000)
- And it binds to API_HOST (default 127.0.0.1)

**AC2: Swagger documentation**
- Given the server is running
- When I navigate to `http://localhost:3000/docs`
- Then Swagger UI is displayed with all registered endpoints

**AC3: CORS enabled**
- Given the server is running
- When a request arrives with an Origin header
- Then CORS headers are included in the response

**AC4: Standard error format**
- Given any endpoint throws an error
- When the error is returned to the client
- Then it follows the format: `{ success: false, error: { code: "ERROR_CODE", message: "description" } }`

**AC5: Request logging**
- Given requests are being made
- When a request completes
- Then method, path, status code, and response time are logged

**AC6: Health endpoint**
- Given the server is running
- When I GET `/health`
- Then a response includes: server status, database connection status, uptime, and version

**AC7: Graceful shutdown**
- Given the server is running
- When SIGTERM is received
- Then the server stops accepting new connections
- And existing connections are drained
- And the database pool is closed

## Technical Notes
- File: `src/server.js`
- Plugins: `@fastify/swagger`, `@fastify/swagger-ui`, `@fastify/cors`
- Middleware: `src/api/middleware/error-handler.js`, `src/api/middleware/request-logger.js`
- All routes registered under `/api/v1` prefix via `src/api/routes/index.js`
- Standard response wrapper: `{ success: true, data: {...}, meta: {...} }`

## Definition of Done
- [ ] server.js starts Fastify with all plugins
- [ ] Swagger UI accessible at /docs
- [ ] Error handler middleware
- [ ] Request logger middleware
- [ ] /health endpoint
- [ ] Graceful shutdown
- [ ] Build with 0 errors, 0 warnings
