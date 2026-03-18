### EH-012: Proyectos - tabla con filtros y health
**Points:** 3 | **Priority:** High
**Epic:** EPIC-02: Dashboard + Alertas UI
**Dependencies:** EH-007 (servicios HTTP)

**As a** ecosystem owner
**I want** to see all projects in a filterable table with health indicators
**So that** I can quickly assess the state of my ecosystem

#### Acceptance Criteria

**AC1: Tabla de proyectos**
- Given 37 projects exist in the registry
- When the Projects page loads
- Then a table shows: name, short code, category, path, health status (if available from PA)

**AC2: Filtro por categoria**
- Given projects span categories: apps, mcp, mobile, personal, etc.
- When the user selects a category filter
- Then only projects of that category are shown
- And the count updates

**AC3: Busqueda por texto**
- Given the table is displayed
- When the user types in a search box
- Then the table filters by name or short code matching the search text

**AC4: Health badge**
- Given Project Admin has health data for some projects
- When a project has health info
- Then a badge shows: healthy (green), warning (yellow), unhealthy (red), unknown (gray)
- And projects without PA data show "unknown"

**AC5: Click para ver detalle**
- Given a project row is displayed
- When the user clicks on a project
- Then a side panel or dialog shows: full path, context path, related ideas count, related alerts count

#### Technical Notes
- PrimeNG: Table con global filter, Column filters, Tag, Badge, Dialog/Sidebar
- Datos vienen de ProjectsService (EH-007) que merge registry + PA
- Para "related ideas", filtrar ideas que tienen project_id matching (si se implementa vinculacion)
- Para MVP, el detalle puede ser simple: path + context + category

#### Definition of Done
- [ ] Tabla muestra todos los proyectos
- [ ] Filtros por categoria y busqueda funcionan
- [ ] Health badges correctos
- [ ] Detalle al click
