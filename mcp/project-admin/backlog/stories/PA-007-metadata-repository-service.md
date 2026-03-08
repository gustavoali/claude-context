# PA-007: Metadata repository y service

**Points:** 1 | **Priority:** High | **MoSCoW:** Should Have
**Epic:** EPIC-PA-001 | **DoR Level:** L1 | **Sprint:** 2

## User Story

**As a** user of Project Admin
**I want** to attach arbitrary key-value metadata to projects
**So that** I can store flexible, extensible data like SBM project IDs or Docker container names

## Acceptance Criteria

**AC1: Set metadata**
- Given a project "project-admin" exists
- When I call metadataService.set("project-admin", "docker_container", "project-admin-pg", "manual")
- Then the metadata is stored with key, JSONB value, and source
- And setting the same key again updates the value (upsert)

**AC2: Get metadata for project**
- Given a project has multiple metadata entries
- When I call metadataService.getForProject("project-admin")
- Then all key-value pairs are returned with source and timestamps

**AC3: Get specific metadata key**
- Given a project has metadata key "sbm_project_id" with value 3
- When I call metadataService.get("project-admin", "sbm_project_id")
- Then the value 3 is returned

**AC4: Delete metadata key**
- Given a project has metadata key "obsolete_key"
- When I call metadataService.delete("project-admin", "obsolete_key")
- Then the metadata entry is removed

## Technical Notes
- Files: `src/repositories/metadata-repository.js`, `src/services/metadata-service.js`
- Use INSERT ... ON CONFLICT (project_id, key) DO UPDATE for upsert
- Value is JSONB: can be string, number, object, array

## Definition of Done
- [ ] metadata-repository.js with all queries
- [ ] metadata-service.js with validation
- [ ] Unit tests for service
- [ ] Build with 0 errors, 0 warnings
