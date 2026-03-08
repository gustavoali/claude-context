# PA-015: MCP tools de relationships y metadata

**Points:** 2 | **Priority:** Medium | **MoSCoW:** Should Have
**Epic:** EPIC-PA-003 | **DoR Level:** L1 | **Sprint:** 2

## User Story

**As a** Claude Code user
**I want** MCP tools to manage project relationships and metadata
**So that** I can document how projects connect and store flexible data via my IDE

## Acceptance Criteria

**AC1: pa_add_relationship**
- Given two projects exist
- When Claude calls pa_add_relationship({ source: "project-admin", target: "sprint-backlog-manager", type: "integrates_with", description: "REST API integration" })
- Then the relationship is created and confirmed

**AC2: pa_get_relationships**
- Given a project has relationships
- When Claude calls pa_get_relationships({ slug: "project-admin", direction: "both" })
- Then all incoming and outgoing relationships are returned with project names

**AC3: pa_set_metadata**
- Given a project exists
- When Claude calls pa_set_metadata({ slug: "project-admin", key: "docker_container", value: "project-admin-pg" })
- Then the metadata is stored (upserted) and confirmed

## Technical Notes
- File: `src/mcp/tools/relationships.js`
- Tools call relationship-service and metadata-service
- Direction parameter: "outgoing", "incoming", "both" (default "both")

## Definition of Done
- [ ] 3 tools implemented: pa_add_relationship, pa_get_relationships, pa_set_metadata
- [ ] Zod input schemas
- [ ] Integration tests
- [ ] Build with 0 errors, 0 warnings
