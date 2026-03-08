# PA-018: REST endpoints de projects CRUD

**Points:** 3 | **Priority:** Critical | **MoSCoW:** Must Have
**Epic:** EPIC-PA-004 | **DoR Level:** L1 | **Sprint:** 2

## User Story

**As a** frontend developer building the Angular Dashboard
**I want** REST endpoints for full CRUD operations on projects
**So that** I can display and manage the project registry from the web UI

## Acceptance Criteria

**AC1: GET /api/v1/projects**
- Given projects exist in the database
- When I GET /api/v1/projects?status=active&category=mcp&search=sprint&page=1&limit=20
- Then filtered, paginated results are returned with: `{ success: true, data: [...], meta: { page, limit, total, timestamp } }`

**AC2: GET /api/v1/projects/:slug**
- Given a project "project-admin" exists
- When I GET /api/v1/projects/project-admin
- Then the complete project is returned with tags and metadata count
- When the slug does not exist, then 404 with standard error format

**AC3: POST /api/v1/projects**
- Given valid project data in the request body
- When I POST /api/v1/projects
- Then the project is created and returned with 201 status
- When slug is duplicate, then 409 Conflict

**AC4: PUT /api/v1/projects/:slug**
- Given a project exists
- When I PUT /api/v1/projects/my-project with partial update fields
- Then only provided fields are updated and the updated project is returned

**AC5: DELETE /api/v1/projects/:slug**
- Given a project exists
- When I DELETE /api/v1/projects/my-project?confirm=true
- Then the project is deleted and 200 is returned
- When confirm is missing or false, then 400 with CONFIRMATION_REQUIRED

**AC6: Input validation**
- Given invalid data (missing required fields, invalid slug format)
- When any endpoint receives the request
- Then 400 is returned with validation errors

## Technical Notes
- File: `src/api/routes/projects.js`
- Routes call project-service (shared with MCP tools)
- Fastify schema validation for request body and query params
- Response format wrapper at route level

## Definition of Done
- [ ] 5 REST endpoints implemented
- [ ] Fastify schema validation
- [ ] Standard response format
- [ ] Integration tests for each endpoint
- [ ] Swagger documentation generated
- [ ] Build with 0 errors, 0 warnings
