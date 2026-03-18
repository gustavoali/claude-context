### EH-004: REST endpoints ideas
**Points:** 3 | **Priority:** Critical
**Epic:** EPIC-01: Backend - File Parsers & REST
**Dependencies:** EH-002 (parser de IDEAS_INDEX.md)

**As a** frontend developer
**I want** REST endpoints to query ideas
**So that** the Angular app can display, filter and browse the ideas repository

#### Acceptance Criteria

**AC1: GET /api/ideas**
- Given IDEAS_INDEX.md is accessible
- When a GET request is made to `/api/ideas`
- Then it returns HTTP 200 with an array of idea summaries
- And each summary has: `id`, `title`, `category`, `date`, `status`

**AC2: GET /api/ideas/:id**
- Given an idea with ID "IDEA-001" exists
- When GET `/api/ideas/IDEA-001` is called
- Then it returns the full idea including the markdown body from the individual file

**AC3: Filtro por categoria**
- Given ideas span categories: projects, features, improvements, general
- When GET `/api/ideas?category=projects` is called
- Then only ideas of that category are returned

**AC4: Filtro por estado**
- Given ideas have various statuses
- When GET `/api/ideas?status=Seed` is called
- Then only ideas with that status are returned

**AC5: Idea no encontrada**
- Given an idea ID that does not exist
- When GET `/api/ideas/IDEA-999` is called
- Then it returns HTTP 404 with a descriptive error message

#### Technical Notes
- Prefix: `/api/ideas`
- El body del detalle se devuelve como campo `body: string` (markdown raw)
- Soportar multiples filtros simultaneos (AND)
- Paginacion no requerida para MVP (47 ideas)

#### Definition of Done
- [ ] Endpoints list y detail implementados
- [ ] Filtros por categoria y estado
- [ ] Tests de integracion
- [ ] 404 para ideas inexistentes
