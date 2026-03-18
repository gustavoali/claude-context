### EH-016: Ideas - vinculacion con proyectos existentes
**Points:** 2 | **Priority:** Medium
**Epic:** EPIC-03: Ideas UI
**Dependencies:** EH-013 (listado de ideas)

**As a** ecosystem owner
**I want** to link existing ideas to existing projects
**So that** I can track which ideas originated or relate to which projects

#### Acceptance Criteria

**AC1: Vincular idea a proyecto**
- Given an idea without project association is displayed
- When the user clicks "Vincular Proyecto"
- Then a dropdown/search shows all available projects
- And on selection, the idea gets a `project_id` linking to that project

**AC2: Desvincular**
- Given an idea is linked to a project
- When the user clicks "Desvincular"
- Then the association is removed
- And the idea appears as "sin proyecto" again

**AC3: Indicador visual**
- Given an idea is linked to a project
- When the ideas list renders
- Then the idea row shows the project name/short as a chip or link

**AC4: Filtro por proyecto**
- Given ideas are linked to projects
- When the user selects "Filtrar por proyecto" and picks a project
- Then only ideas linked to that project are shown

#### Technical Notes
- Backend: PATCH `/api/ideas/:id` with `project_id` field
- In-memory for MVP; EH-019 persists to files
- Project dropdown: reuse ProjectsService data

#### Definition of Done
- [ ] Vincular/desvincular funciona
- [ ] Indicador visual de proyecto asociado
- [ ] Filtro por proyecto implementado
