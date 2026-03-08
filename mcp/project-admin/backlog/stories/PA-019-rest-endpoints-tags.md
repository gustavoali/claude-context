# PA-019: REST endpoints de tags

**Points:** 2 | **Priority:** High | **MoSCoW:** Should Have
**Epic:** EPIC-PA-004 | **DoR Level:** L1 | **Sprint:** 2

## User Story

**As a** frontend developer
**I want** REST endpoints to manage and query project tags
**So that** the dashboard can display tag-based filtering and tag management

## Acceptance Criteria

**AC1: GET /api/v1/tags**
- Given projects have various tags
- When I GET /api/v1/tags
- Then a list of all unique tags is returned with project count per tag

**AC2: GET /api/v1/tags/:tag/projects**
- Given 3 projects have tag "flutter"
- When I GET /api/v1/tags/flutter/projects
- Then all 3 projects are returned

**AC3: POST /api/v1/projects/:slug/tags**
- Given a project exists
- When I POST /api/v1/projects/my-project/tags with body { tag: "backend" }
- Then the tag is added (idempotent)

**AC4: DELETE /api/v1/projects/:slug/tags/:tag**
- Given a project has tag "legacy"
- When I DELETE /api/v1/projects/my-project/tags/legacy
- Then the tag is removed

## Technical Notes
- File: `src/api/routes/tags.js`
- Routes call tag-service
- Tags are validated as lowercase, alphanumeric with hyphens, max 50 chars

## Definition of Done
- [ ] 4 REST endpoints implemented
- [ ] Integration tests
- [ ] Swagger documentation
- [ ] Build with 0 errors, 0 warnings
