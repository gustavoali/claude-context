# PA-004: Project repository y service (CRUD core)

**Points:** 5 | **Priority:** Critical | **MoSCoW:** Must Have
**Epic:** EPIC-PA-001 | **DoR Level:** L2 | **Sprint:** 1

## User Story

**As a** user of Project Admin (via MCP or REST)
**I want** to create, read, update, and delete project records
**So that** I can maintain a complete registry of all my development projects

## Acceptance Criteria

**AC1: Create project**
- Given valid project data (slug, name, path, category)
- When I call projectService.create(data)
- Then a new project is inserted into the database
- And the created project is returned with id, created_at, and updated_at
- And slug is validated as kebab-case (lowercase, alphanumeric, hyphens)

**AC2: Create project - duplicate slug**
- Given a project with slug "my-project" already exists
- When I try to create another project with slug "my-project"
- Then a DUPLICATE_SLUG error is thrown with a descriptive message
- And no data is modified

**AC3: Get project by slug**
- Given a project with slug "project-admin" exists
- When I call projectService.getBySlug("project-admin")
- Then the complete project record is returned including all JSONB fields

**AC4: Get project - not found**
- Given no project with slug "nonexistent" exists
- When I call projectService.getBySlug("nonexistent")
- Then a PROJECT_NOT_FOUND error is thrown

**AC5: List projects with filters**
- Given multiple projects exist with different status and category
- When I call projectService.list({ status: "active", category: "mcp", search: "sprint", page: 1, limit: 20 })
- Then only projects matching ALL provided filters are returned
- And results are paginated with total count
- And search matches against slug, name, and description (case-insensitive)

**AC6: Update project**
- Given a project with slug "my-project" exists
- When I call projectService.update("my-project", { name: "New Name", status: "archived" })
- Then only the specified fields are updated
- And updated_at is refreshed
- And the updated project is returned

**AC7: Delete project with confirmation**
- Given a project with slug "old-project" exists
- When I call projectService.delete("old-project", { confirm: true })
- Then the project and all associated tags, metadata, and relationships are deleted
- And a confirmation message is returned

**AC8: Delete project without confirmation**
- Given a project exists
- When I call projectService.delete("some-project", { confirm: false })
- Then the deletion is rejected with a CONFIRMATION_REQUIRED error

## Technical Notes
- Files: `src/repositories/project-repository.js`, `src/services/project-service.js`
- Repository: raw SQL with parameterized queries via pool.query()
- Service: business logic, validation, error handling; calls repository
- Slug validation: /^[a-z0-9]+(-[a-z0-9]+)*$/ (max 100 chars)
- Pagination: LIMIT/OFFSET with total count via COUNT(*) OVER()
- JSONB fields (stack, health, config) stored as-is, validated at service level
- Error classes: ProjectNotFoundError, DuplicateSlugError, ConfirmationRequiredError

## Definition of Done
- [ ] project-repository.js with all CRUD queries
- [ ] project-service.js with validation and business logic
- [ ] Error classes defined and used consistently
- [ ] Unit tests for service (>70% coverage)
- [ ] Integration tests for repository queries
- [ ] Build with 0 errors, 0 warnings
