# PA-005: Tag repository y service

**Points:** 3 | **Priority:** High | **MoSCoW:** Must Have
**Epic:** EPIC-PA-001 | **DoR Level:** L1 | **Sprint:** 1

## User Story

**As a** user of Project Admin
**I want** to add, remove, and query tags on projects
**So that** I can categorize and filter projects by multiple dimensions

## Acceptance Criteria

**AC1: Add tag to project**
- Given a project with slug "my-project" exists
- When I call tagService.addTag("my-project", "backend")
- Then the tag is associated with the project
- And adding the same tag again does not create a duplicate (idempotent)

**AC2: Remove tag from project**
- Given a project has tag "legacy"
- When I call tagService.removeTag("my-project", "legacy")
- Then the tag is removed from the project

**AC3: List all tags**
- Given multiple projects have various tags
- When I call tagService.listAll()
- Then a list of unique tags is returned with project count per tag

**AC4: Get projects by tag**
- Given 3 projects have tag "flutter"
- When I call tagService.getProjectsByTag("flutter")
- Then all 3 projects are returned

**AC5: Get tags for a project**
- Given a project has tags ["backend", "mcp", "node"]
- When I call tagService.getTagsForProject("my-project")
- Then all 3 tags are returned as an array of strings

## Technical Notes
- Files: `src/repositories/tag-repository.js`, `src/services/tag-service.js`
- Tags are lowercase, max 50 chars, validated at service level
- Use ON CONFLICT DO NOTHING for idempotent add
- Tag list query: SELECT tag, COUNT(*) FROM project_tags GROUP BY tag ORDER BY count DESC

## Definition of Done
- [ ] tag-repository.js with all queries
- [ ] tag-service.js with validation
- [ ] Unit tests for service
- [ ] Build with 0 errors, 0 warnings
