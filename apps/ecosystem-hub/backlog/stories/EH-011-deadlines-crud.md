### EH-011: Deadlines - CRUD con urgencia automatica
**Points:** 3 | **Priority:** Medium
**Epic:** EPIC-02: Dashboard + Alertas UI
**Dependencies:** EH-009 (modulo alertas como contexto de UI)

**As a** ecosystem owner
**I want** to create and manage deadlines with automatic urgency calculation
**So that** I can track time-sensitive tasks across projects

#### Acceptance Criteria

**AC1: Crear deadline**
- Given the user is on the Alertas & Deadlines page
- When the user clicks "Nuevo Deadline" and fills: descripcion, fecha limite, prioridad (alta/media/baja), proyecto asociado (opcional)
- Then the deadline is created and appears in the deadlines list

**AC2: Urgencia automatica**
- Given a deadline has a due_date
- When the deadlines list renders
- Then each deadline shows days remaining with color: red (<=3 dias), yellow (<=7 dias), green (>7 dias)
- And overdue deadlines show negative days in red with "Vencido" badge

**AC3: Listar deadlines**
- Given deadlines exist
- When the deadlines section loads
- Then a table shows: descripcion, fecha limite, dias restantes, prioridad, proyecto, estado
- And default sort is by due_date ascending (most urgent first)

**AC4: Completar deadline**
- Given a pending deadline exists
- When the user clicks "Completar"
- Then the deadline status changes to "completed"
- And it moves to a "Completados" section or disappears from active list

**AC5: Backend storage**
- Given the MVP does not have a deadlines file to parse
- When deadlines are created
- Then they are stored in-memory on the backend (POST `/api/deadlines`)
- And they persist until the backend restarts

#### Technical Notes
- Backend: CRUD endpoints `/api/deadlines`
- In-memory storage for MVP (no file parsing needed, deadlines don't exist in MD today)
- Urgencia es computed en el frontend basado en due_date vs today
- PrimeNG: Table, Calendar (date picker), Dropdown, Badge

#### Definition of Done
- [ ] CRUD completo funcionando
- [ ] Calculo de urgencia correcto (colores y dias)
- [ ] Sort por fecha predeterminado
- [ ] Overdue handling correcto
