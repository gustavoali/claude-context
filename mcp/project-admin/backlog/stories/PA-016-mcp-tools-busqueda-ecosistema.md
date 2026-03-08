# PA-016: MCP tools de busqueda y estadisticas del ecosistema

**Points:** 3 | **Priority:** High | **MoSCoW:** Should Have
**Epic:** EPIC-PA-003 | **DoR Level:** L1 | **Sprint:** 2

## User Story

**As a** Claude Code user
**I want** MCP tools to search projects and get ecosystem-wide statistics
**So that** I can answer questions like "what projects use Flutter?" or "how is my ecosystem?"

## Acceptance Criteria

**AC1: pa_search_projects**
- Given projects with various stacks and categories
- When Claude calls pa_search_projects({ query: "flutter", filters: { category: "mobile" } })
- Then projects matching the query AND filters are returned
- And search matches against slug, name, description, and stack

**AC2: pa_get_ecosystem_stats**
- Given 26 projects are registered
- When Claude calls pa_get_ecosystem_stats({})
- Then statistics are returned including:
  - Total projects by status (active, archived, deprecated, planned)
  - Total projects by category (mcp, mobile, web, agent, tool)
  - Most common technologies (top 10 stack items)
  - Total relationships count
  - Last scan timestamp
  - Health summary (healthy, warning, error counts)

## Technical Notes
- File: `src/mcp/tools/ecosystem.js`
- pa_search_projects: search is case-insensitive, ILIKE on multiple fields
- Stack search: uses JSONB containment operator @> or array overlap
- Ecosystem stats: aggregate queries on projects table, group by status/category
- Stack stats: unnest JSONB array, group by, order by count desc, limit 10

## Definition of Done
- [ ] 2 tools implemented: pa_search_projects, pa_get_ecosystem_stats
- [ ] Zod input schemas
- [ ] Integration tests
- [ ] Build with 0 errors, 0 warnings
