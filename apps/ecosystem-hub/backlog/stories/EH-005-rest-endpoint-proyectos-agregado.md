### EH-005: REST endpoint proyectos agregado
**Points:** 2 | **Priority:** High
**Epic:** EPIC-01: Backend - File Parsers & REST
**Dependencies:** Ninguna (Project Admin ya tiene /api/projects)

**As a** frontend developer
**I want** a unified projects endpoint that merges registry + PA metadata
**So that** the dashboard can show complete project info in a single call

#### Acceptance Criteria

**AC1: GET /api/hub/projects**
- Given project-registry.json has 37 projects and PA DB has metadata for some
- When GET `/api/hub/projects` is called
- Then it returns all projects with merged data: registry fields (name, short, path, category) + PA fields (health, status, metadata) where available

**AC2: Proyectos sin metadata PA**
- Given a project exists in registry but not in PA DB
- When the endpoint returns projects
- Then that project appears with registry data and null/empty PA fields

**AC3: Filtro por categoria**
- Given projects span categories: apps, mcp, mobile, personal, etc.
- When GET `/api/hub/projects?category=apps` is called
- Then only projects of that category are returned

**AC4: Conteo por estado**
- Given projects have various statuses
- When GET `/api/hub/projects/stats` is called
- Then it returns counts: `{ total, byCategory: {...}, byStatus: {...} }`

#### Technical Notes
- Leer project-registry.json directamente + merge con PA DB query
- Prefix `/api/hub/projects` para no colisionar con PA existente `/api/projects`
- Cache del registry con TTL de 60s
- PA query via el repositorio existente en el codebase de Project Admin

#### Definition of Done
- [ ] Endpoint merge implementado
- [ ] Stats endpoint con conteos
- [ ] Tests con datos reales
