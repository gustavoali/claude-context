### EH-008: Dashboard - resumen ejecutivo
**Points:** 5 | **Priority:** Critical
**Epic:** EPIC-02: Dashboard + Alertas UI
**Dependencies:** EH-007 (servicios HTTP)

**As a** ecosystem owner
**I want** a dashboard showing the executive summary of my ecosystem
**So that** I can see at a glance what needs attention

#### Acceptance Criteria

**AC1: Contadores de proyectos**
- Given there are 37 projects in the registry
- When the dashboard loads
- Then it shows cards with counts: total projects, by category (apps, mcp, mobile, etc.)

**AC2: Alertas urgentes destacadas**
- Given there are active alerts of type "incidente" or with age <=3 days
- When the dashboard loads
- Then urgent alerts appear in a highlighted section at the top
- And each shows: type badge, message (truncated), action, date

**AC3: Deadlines proximos**
- Given there are deadlines configured (future story)
- When the dashboard loads
- Then a section shows upcoming deadlines with days remaining
- And color coding: red (<=3 days), yellow (<=7 days), green (>7 days)
- And if no deadlines exist yet, the section shows "No deadlines configured"

**AC4: Ideas sin proyecto**
- Given there are ideas with status "Approved" or "In Progress" without an associated project
- When the dashboard loads
- Then a section shows these ideas as actionable items

**AC5: Refresh manual**
- Given the dashboard is displayed
- When the user clicks a refresh button
- Then all data reloads from the backend
- And loading indicators show during the fetch

**AC6: Empty state**
- Given the backend returns empty arrays for any section
- When the dashboard renders
- Then each section shows an appropriate empty state message (not blank space)

#### Technical Notes
- PrimeNG components: Card, Tag, Badge, DataView o custom layout
- No polling automatico en MVP; refresh manual con boton
- Las alertas urgentes son un subconjunto filtrado de AlertsService
- Los contadores de proyectos vienen de ProjectsService.getStats()

#### Definition of Done
- [ ] Dashboard muestra las 4 secciones con datos reales
- [ ] Alertas urgentes correctamente filtradas y destacadas
- [ ] Empty states para cada seccion
- [ ] Refresh manual funciona
- [ ] Responsive layout
