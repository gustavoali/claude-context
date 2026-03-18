### EH-006: Scaffold Angular app con routing y PrimeNG
**Points:** 3 | **Priority:** Critical
**Epic:** EPIC-02: Dashboard + Alertas UI
**Dependencies:** Ninguna (puede arrancar en paralelo con EPIC-01)

**As a** developer
**I want** the Angular app scaffolded with routing, layout and PrimeNG configured
**So that** feature modules can be developed independently

#### Acceptance Criteria

**AC1: App corre en dev**
- Given the project has been scaffolded
- When `ng serve` is executed
- Then the app starts on localhost:4201 (diferente de web-monitor 4200)
- And the browser shows the shell layout

**AC2: Routing configurado**
- Given the app has routes defined
- When navigating to `/dashboard`, `/projects`, `/ideas`, `/alerts`
- Then each route loads a placeholder component
- And a sidebar/topbar navigation allows switching between them

**AC3: PrimeNG integrado**
- Given PrimeNG 20 is installed
- When a component uses PrimeNG elements (table, button, tag)
- Then they render correctly with the configured theme

**AC4: Layout responsive**
- Given the app shell uses PrimeNG layout components
- When the viewport is desktop (>=1024px)
- Then sidebar is visible and content area fills remaining space
- And when viewport is tablet/mobile, sidebar collapses

**AC5: Signals-based state**
- Given Angular 20 with Signals
- When creating the app structure
- Then services use `signal()` and `computed()` for reactive state
- And no RxJS Subjects for local component state

#### Technical Notes
- Decisiones: app standalone (no extension de web-monitor) para independencia de deploy
- Puerto 4201 para coexistir con web-monitor en 4200
- Theme: PrimeNG Lara Dark o Aura (consistente con web-monitor si existe)
- Standalone components (Angular 20 default)
- Lazy loading per route module

#### Definition of Done
- [ ] `ng serve` funciona sin errores
- [ ] 4 rutas con placeholders
- [ ] PrimeNG renderiza correctamente
- [ ] Layout responsive verificado
