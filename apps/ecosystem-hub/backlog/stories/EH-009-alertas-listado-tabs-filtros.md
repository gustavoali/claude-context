### EH-009: Modulo Alertas - listado con tabs y filtros
**Points:** 5 | **Priority:** High
**Epic:** EPIC-02: Dashboard + Alertas UI
**Dependencies:** EH-007 (servicios HTTP)

**As a** ecosystem owner
**I want** to see all alerts organized by scope with filtering
**So that** I can manage alerts efficiently across the ecosystem

#### Acceptance Criteria

**AC1: Tabs por scope**
- Given alerts exist with scopes "global" and "jerarquicos"
- When the alerts page loads
- Then it shows tabs: "Todas", "Globales", "Jerarquicos"
- And switching tabs filters the displayed alerts

**AC2: Tabla de alertas**
- Given a scope tab is selected
- When alerts are displayed
- Then a table shows: fecha, tipo (badge color), mensaje, accion, estado
- And the table supports sorting by date (default: newest first)

**AC3: Filtro por tipo**
- Given the table is showing alerts
- When the user selects a type filter (recordatorio, incidente, hallazgo-ce, estado)
- Then only alerts of that type are shown

**AC4: Filtro por estado**
- Given active and resolved alerts exist
- When the user toggles between "Activas" and "Resueltas"
- Then the table shows only alerts of the selected status
- And default view shows active alerts

**AC5: Badge de tipo con color**
- Given alert types have semantic meaning
- When alerts are rendered
- Then type badges use colors: incidente=red, recordatorio=blue, hallazgo-ce=yellow, estado=gray

**AC6: Conteo en tabs**
- Given each scope has N active alerts
- When the tabs render
- Then each tab shows the count of active alerts as a badge (e.g., "Globales (16)")

#### Technical Notes
- PrimeNG components: TabView, Table (p-table), Tag, MultiSelect for filters
- Filters combine: tab scope + type dropdown + status toggle
- No paginacion en MVP (16 alertas activas es manejable)
- Responsive: en mobile, tabla se convierte en cards o scroll horizontal

#### Definition of Done
- [ ] Tabs funcionan con filtrado por scope
- [ ] Tabla con sorting y filtros
- [ ] Badges de tipo con colores correctos
- [ ] Conteo en tabs actualizado
