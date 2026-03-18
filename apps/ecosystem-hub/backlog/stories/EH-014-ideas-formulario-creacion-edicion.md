### EH-014: Ideas - formulario creacion/edicion inline
**Points:** 3 | **Priority:** High
**Epic:** EPIC-03: Ideas UI
**Dependencies:** EH-013 (listado de ideas)

**As a** ecosystem owner
**I want** to create new ideas and edit existing ones from the UI
**So that** I can capture ideas without switching to markdown files

#### Acceptance Criteria

**AC1: Crear idea**
- Given the user is on the Ideas page
- When the user clicks "Nueva Idea"
- Then a dialog shows a form with: titulo, categoria (dropdown), descripcion (textarea/markdown editor), prioridad (dropdown)
- And on submit, the idea is created with auto-generated ID (next IDEA-NNN), status "Seed", and today's date

**AC2: Editar idea**
- Given an idea exists in the list
- When the user clicks "Editar" on that row
- Then a dialog pre-fills the form with the idea's current data
- And on submit, the idea is updated

**AC3: Validacion**
- Given the create/edit dialog is open
- When the user submits without titulo
- Then validation error is shown
- And the form is not submitted

**AC4: ID auto-generado**
- Given there are 47 ideas (last ID: IDEA-047)
- When a new idea is created
- Then it receives ID IDEA-048
- And the ID is displayed in the confirmation

**AC5: Backend write**
- Given the MVP stores changes in-memory
- When an idea is created or edited via the UI
- Then POST `/api/ideas` or PUT `/api/ideas/:id` is called
- And the ideas list refreshes to show the change

#### Technical Notes
- Backend: POST `/api/ideas`, PUT `/api/ideas/:id` (in-memory for MVP)
- Next ID: backend tracks max ID from parsed index and increments
- Description field: textarea is sufficient for MVP, no need for full markdown editor
- PrimeNG: Dialog, InputText, InputTextarea, Dropdown

#### Definition of Done
- [ ] Crear idea con formulario validado
- [ ] Editar idea con datos pre-cargados
- [ ] ID auto-generado correctamente
- [ ] Lista se refresca post-operacion
