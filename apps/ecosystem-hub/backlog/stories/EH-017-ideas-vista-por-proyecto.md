### EH-017: Ideas - vista por proyecto (ideas relacionadas)
**Points:** 2 | **Priority:** Low
**Epic:** EPIC-03: Ideas UI
**Dependencies:** EH-016 (vinculacion ideas-proyectos)

**As a** ecosystem owner
**I want** to see all ideas related to a specific project from the Projects view
**So that** I can understand the full context of a project's ideation history

#### Acceptance Criteria

**AC1: Ideas en detalle de proyecto**
- Given a project has linked ideas
- When the user views the project detail (from EH-012)
- Then a section shows "Ideas Relacionadas" with the list of linked ideas

**AC2: Sin ideas**
- Given a project has no linked ideas
- When the project detail is shown
- Then the "Ideas Relacionadas" section shows "Sin ideas vinculadas"

**AC3: Navegacion cruzada**
- Given an idea is shown in the project detail
- When the user clicks on the idea
- Then they navigate to the Ideas page with that idea expanded

#### Technical Notes
- Reutiliza datos de IdeasService filtrados por project_id
- Componente reutilizable: `IdeaListComponent` con input de filtro
- Navegacion via router con query params

#### Definition of Done
- [ ] Seccion de ideas en detalle de proyecto
- [ ] Empty state correcto
- [ ] Navegacion cruzada funciona
