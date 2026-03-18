### EH-015: Ideas - transicion idea a proyecto
**Points:** 5 | **Priority:** Medium
**Epic:** EPIC-03: Ideas UI
**Dependencies:** EH-014 (formulario de ideas), EH-005 (endpoint proyectos)

**As a** ecosystem owner
**I want** to convert an idea into a project with one click
**So that** the transition from ideation to execution is seamless

#### Acceptance Criteria

**AC1: Boton de transicion**
- Given an idea with status "Approved" or "Evaluating" is displayed
- When the user clicks "Crear Proyecto"
- Then a dialog shows a pre-filled form with: project name (from idea title), short code (suggested), category (from idea category), path (suggested based on category)

**AC2: Creacion del proyecto**
- Given the user confirms the project creation dialog
- When the form is submitted
- Then a new project is registered in Project Admin via POST `/api/projects`
- And the idea status changes to "In Progress"
- And the idea gets a `project_id` linking to the new project

**AC3: Validacion de short code**
- Given existing projects have short codes
- When the user enters a short code for the new project
- Then the UI validates it doesn't conflict with existing codes
- And shows an error if it does

**AC4: Ideas sin status elegible**
- Given an idea has status "Seed" or "In Progress" or "Implemented"
- When the idea is displayed
- Then the "Crear Proyecto" button is disabled or hidden
- And a tooltip explains why (e.g., "La idea debe estar en estado Approved o Evaluating")

**AC5: Confirmacion**
- Given the project was created successfully
- When the operation completes
- Then a toast shows "Proyecto creado: [name] ([short])"
- And the ideas list refreshes showing the updated status

#### Technical Notes
- Flujo: UI -> POST `/api/hub/idea-to-project` (backend orchestrates PA creation + idea update)
- Category mapping: idea category "projects" -> project category based on content
- Short code suggestion: first 2 chars of each word in title
- No crea archivos en filesystem ni entry en project-registry.json (eso es PA-027)

#### Definition of Done
- [ ] Flujo completo idea -> proyecto funciona
- [ ] Validacion de short code
- [ ] Idea status actualizado post-creacion
- [ ] Feedback visual completo
