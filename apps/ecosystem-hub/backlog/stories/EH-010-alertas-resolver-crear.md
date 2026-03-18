### EH-010: Modulo Alertas - resolver/crear desde UI
**Points:** 3 | **Priority:** High
**Epic:** EPIC-02: Dashboard + Alertas UI
**Dependencies:** EH-009 (listado de alertas)

**As a** ecosystem owner
**I want** to resolve existing alerts and create new ones from the UI
**So that** I don't need to edit ALERTS.md manually

#### Acceptance Criteria

**AC1: Resolver alerta**
- Given an active alert is displayed in the table
- When the user clicks "Resolver" on that row
- Then a dialog asks for resolution notes (text area)
- And on confirm, the alert moves to status "resolved" with the provided notes and current date

**AC2: Crear alerta**
- Given the user is on the alerts page
- When the user clicks "Nueva Alerta"
- Then a form dialog appears with fields: tipo (dropdown), mensaje (textarea), accion (textarea), scope (dropdown: global/jerarquicos)
- And on submit, the alert is created with status "active" and today's date

**AC3: Validacion de formulario**
- Given the create alert dialog is open
- When the user submits without filling required fields (tipo, mensaje)
- Then validation errors are shown inline
- And the form is not submitted

**AC4: Feedback visual**
- Given an alert is resolved or created
- When the operation completes
- Then a toast notification confirms the action
- And the alerts list refreshes automatically

#### Technical Notes
- Backend: POST `/api/alerts` (create), PATCH `/api/alerts/:id/resolve` (resolve)
- En MVP, las operaciones de escritura se guardan en memoria del backend (volatile)
- EH-018 agregara persistencia a ALERTS.md
- PrimeNG: Dialog, InputTextarea, Dropdown, Toast

#### Definition of Done
- [ ] Resolver alerta funciona con dialog
- [ ] Crear alerta con formulario validado
- [ ] Toast de confirmacion
- [ ] Lista se refresca post-operacion
