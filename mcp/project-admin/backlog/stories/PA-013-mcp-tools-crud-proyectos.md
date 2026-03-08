# PA-013: MCP tools de CRUD de proyectos

**Points:** 3 | **Priority:** Critical | **MoSCoW:** Must Have
**Epic:** EPIC-PA-003 | **DoR Level:** L1 | **Sprint:** 2

## User Story

**As a** Claude Code user
**I want** MCP tools to list, get, create, update, and delete projects
**So that** I can manage my project registry without leaving the IDE

## Acceptance Criteria

**AC1: pa_list_projects**
- Given projects exist in the database
- When Claude calls pa_list_projects with optional filters { status, category, tag, search }
- Then a formatted list of matching projects is returned
- And each project shows: slug, name, status, category, stack

**AC2: pa_get_project**
- Given a project "sprint-backlog-manager" exists
- When Claude calls pa_get_project({ slug: "sprint-backlog-manager" })
- Then the complete project detail is returned including tags, metadata count, and health summary

**AC3: pa_create_project**
- Given valid project data
- When Claude calls pa_create_project({ slug, name, path, category, stack?, description? })
- Then the project is created and the result is returned

**AC4: pa_update_project**
- Given a project exists
- When Claude calls pa_update_project({ slug, name?, status?, description?, ... })
- Then only the provided fields are updated

**AC5: pa_delete_project**
- Given a project exists
- When Claude calls pa_delete_project({ slug, confirm: true })
- Then the project is deleted with all associated data

**AC6: Error responses**
- Given an invalid operation (not found, duplicate, etc.)
- When any tool encounters an error
- Then isError: true is returned with a descriptive message

## Technical Notes
- File: `src/mcp/tools/projects.js`
- All tools use the `pa_` prefix
- Input schemas defined with Zod, each field has a description
- Response format: `{ content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] }`
- Error format: `{ content: [{ type: 'text', text: errorMessage }], isError: true }`
- Tools call project-service, never access DB directly

## Definition of Done
- [ ] 5 tools implemented: pa_list_projects, pa_get_project, pa_create_project, pa_update_project, pa_delete_project
- [ ] Zod input schemas with descriptions
- [ ] Error handling with isError flag
- [ ] Integration tests for each tool
- [ ] Build with 0 errors, 0 warnings
