### EH-021: Test suite E2E criticos
**Points:** 3 | **Priority:** High
**Epic:** EPIC-04: Polish & Integracion
**Dependencies:** EH-008 (dashboard), EH-009 (alertas), EH-013 (ideas)

**As a** developer
**I want** E2E tests covering the critical user flows
**So that** regressions are caught before deployment

#### Acceptance Criteria

**AC1: Dashboard loads con datos**
- Given the backend is running with real data
- When the E2E test navigates to /dashboard
- Then project counters, alerts section, and ideas section are visible with data

**AC2: Alertas - filtro por scope**
- Given the alerts page is loaded
- When the test clicks the "Globales" tab
- Then only global alerts are displayed

**AC3: Alertas - resolver**
- Given an active alert exists
- When the test clicks "Resolver", fills notes, confirms
- Then the alert moves to resolved state

**AC4: Ideas - filtro por categoria**
- Given the ideas page is loaded
- When the test selects category "projects"
- Then only project ideas are displayed

**AC5: Proyectos - busqueda**
- Given the projects page is loaded
- When the test types "web-monitor" in the search box
- Then only web-monitor appears in the table

#### Technical Notes
- Herramienta: Playwright (consistente con ecosistema)
- Tests corren contra backend real con datos de archivos reales
- No mocks: E2E debe validar flujo completo
- CI: run after `docker compose up`

#### Definition of Done
- [ ] 5 E2E tests pasando
- [ ] Tests corren contra stack real
- [ ] Tiempo total <60 segundos
- [ ] Documentado como correrlos
