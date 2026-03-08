# PA-020: REST endpoints de relationships y graph

**Points:** 3 | **Priority:** High | **MoSCoW:** Should Have
**Epic:** EPIC-PA-004 | **DoR Level:** L1 | **Sprint:** 3

## User Story

**As a** frontend developer
**I want** REST endpoints to manage relationships and get the full dependency graph
**So that** the dashboard can visualize how projects connect to each other

## Acceptance Criteria

**AC1: POST /api/v1/relationships**
- Given two projects exist
- When I POST /api/v1/relationships with { source: "project-admin", target: "sprint-backlog-manager", relationship: "integrates_with" }
- Then the relationship is created and returned with 201

**AC2: DELETE /api/v1/relationships/:id**
- Given a relationship exists
- When I DELETE /api/v1/relationships/5
- Then the relationship is removed

**AC3: GET /api/v1/projects/:slug/relationships**
- Given a project has relationships
- When I GET /api/v1/projects/project-admin/relationships?direction=both
- Then all relationships are returned with source and target project details

**AC4: GET /api/v1/relationships/graph**
- Given multiple projects with relationships
- When I GET /api/v1/relationships/graph
- Then a graph structure is returned with nodes (projects) and edges (relationships)
- And the format is suitable for graph visualization libraries

## Technical Notes
- File: `src/api/routes/relationships.js`
- Graph format: `{ nodes: [{ id, slug, name, category }], edges: [{ source, target, type, description }] }`
- Routes call relationship-service

## Definition of Done
- [ ] 4 REST endpoints implemented
- [ ] Integration tests
- [ ] Swagger documentation
- [ ] Build with 0 errors, 0 warnings
