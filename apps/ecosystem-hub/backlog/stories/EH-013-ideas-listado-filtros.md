### EH-013: Modulo Ideas - listado con filtros
**Points:** 5 | **Priority:** High
**Epic:** EPIC-03: Ideas UI
**Dependencies:** EH-007 (servicios HTTP con IdeasService)

**As a** ecosystem owner
**I want** to browse all ideas with filters by category, status and priority
**So that** I can manage my 47 ideas efficiently

#### Acceptance Criteria

**AC1: Tabla de ideas**
- Given 47 ideas exist in IDEAS_INDEX.md
- When the Ideas page loads
- Then a table shows: ID, titulo, categoria (badge), fecha, estado (badge)

**AC2: Filtro por categoria**
- Given ideas span: projects, features, improvements, general
- When the user selects a category
- Then only ideas of that category are shown

**AC3: Filtro por estado**
- Given ideas have states: Seed, Evaluating, Approved, In Progress, Implemented, Paused, Discarded
- When the user selects a status filter
- Then only ideas of that status are shown
- And default view excludes Discarded and Implemented (show active ideas)

**AC4: Estado badges con color**
- Given each status has semantic meaning
- When ideas are rendered
- Then status badges use colors: Seed=gray, Evaluating=blue, Approved=green, In Progress=orange, Implemented=teal, Paused=yellow, Discarded=red

**AC5: Detalle expandible**
- Given an idea is displayed in the table
- When the user clicks on it
- Then the row expands or a panel shows the full markdown body of the idea
- And the markdown is rendered as HTML

**AC6: Contadores por estado**
- Given the ideas list is loaded
- When the header renders
- Then it shows counts: "47 ideas | 20 Seed | 10 In Progress | ..."

#### Technical Notes
- PrimeNG: Table with row expansion, MultiSelect filters, Tag, Badge
- Markdown rendering: use `marked` or `ngx-markdown` for idea body
- Default filter: exclude Implemented and Discarded
- Responsive: card layout on mobile

#### Definition of Done
- [ ] Tabla con 47 ideas cargando
- [ ] Filtros por categoria y estado
- [ ] Badges con colores correctos
- [ ] Detalle expandible con markdown renderizado
- [ ] Contadores en header
