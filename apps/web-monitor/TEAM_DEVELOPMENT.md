# Angular Web Monitor - Equipo de Desarrollo

**Version:** 1.0
**Fecha:** 2026-02-12
**Estado:** PLANIFICADO

---

## Composicion del Equipo

| # | Rol | Agente | Dedicacion |
|---|-----|--------|-----------|
| 1 | Frontend Developer (Lead) | `frontend-angular-developer` | Todas las fases |
| 2 | Test Engineer | `test-engineer` | Todas las fases |
| 3 | Code Reviewer | `code-reviewer` | Pre-merge en cada fase |
| 4 | DevOps Engineer | `devops-engineer` | Setup inicial + deployments |
| 5 | Architecture Advisor | `software-architect` | On-demand |

---

## Detalle por Rol

### 1. Frontend Developer (Lead)

- **Agente:** `frontend-angular-developer`
- **Funciones:**
  - Implementar componentes, servicios, routing, state management
  - Integrar con REST API de Project Admin Backend
  - Integrar con WebSocket de Claude Orchestrator
  - Implementar NgRx store (actions, reducers, effects, selectors)
  - Crear servicios HTTP con interceptors
  - Implementar responsive layouts
  - Optimizar performance (lazy loading, OnPush, virtual scrolling)
- **Tareas clave por fase:**

  **Fase A (MVP):**
  1. Setup proyecto Angular 17+ con Angular CLI
  2. Configurar Angular Material/PrimeNG
  3. Implementar `ProjectAdminService` (HTTP client)
  4. Implementar NgRx store para projects (actions, reducer, effects, selectors)
  5. Crear `DashboardComponent` con project cards
  6. Crear `ProjectTableComponent` con sorting y paginacion
  7. Crear `ProjectDetailComponent`
  8. Implementar filtros (clasificador, estado, stack)
  9. Implementar busqueda
  10. Configurar routing con lazy loading
  11. Crear `EnvironmentConfigComponent` para settings

  **Fase B (Sprints):**
  1. Implementar NgRx store para sprints
  2. Crear `SprintBoardComponent` (kanban drag-drop)
  3. Crear `BurndownChartComponent` (ngx-charts)
  4. Crear `VelocityChartComponent`
  5. Crear `StoryDetailComponent`
  6. Crear `TechnicalDebtListComponent`

  **Fase C (Sessions):**
  1. Implementar `WebSocketService` (rxjs/webSocket)
  2. Implementar NgRx store para sessions
  3. Crear `SessionListComponent` (real-time updates)
  4. Crear `SessionDetailComponent`
  5. Crear `SessionStreamComponent` (live output)

- **Entregables:**
  - Codigo fuente completo en `C:/apps/web-monitor/src/`
  - Componentes, servicios, store, routing funcionales
- **Dependencias:** Requiere API contracts del architect. Requiere backend operativo para testing de integracion.

### 2. Test Engineer

- **Agente:** `test-engineer`
- **Funciones:**
  - Disenar test strategy (unit, integration, E2E)
  - Unit tests para servicios (mock HTTP, mock WebSocket)
  - Unit tests para NgRx (reducers, selectors, effects)
  - Component tests (shallow rendering, interaction testing)
  - E2E tests para flujos criticos (Cypress o Playwright)
  - Configurar CI para ejecutar tests automaticamente
- **Tareas clave:**

  **Fase A:**
  1. Setup test infrastructure (Jasmine/Karma config, test utilities)
  2. Unit tests para `ProjectAdminService` (HttpClientTestingModule)
  3. Unit tests para NgRx projects store (reducer, selectors, effects)
  4. Component tests para `DashboardComponent`, `ProjectCardComponent`
  5. E2E test: navegar dashboard -> filtrar -> abrir detalle

  **Fase B:**
  6. Unit tests para NgRx sprints store
  7. Component tests para `SprintBoardComponent`, charts
  8. E2E test: abrir proyecto -> ver sprint board -> ver burndown

  **Fase C:**
  9. Unit tests para `WebSocketService` (mock WebSocket)
  10. Component tests para session components
  11. E2E test: ver sesiones activas -> suscribirse -> ver streaming

- **Entregables:**
  - `src/app/**/*.spec.ts` - Unit tests por componente/servicio
  - `e2e/` - E2E test suites
  - Coverage report (target: >70% statements, >60% branches)
  - Test plan documentado
- **Dependencias:** Requiere implementacion del frontend-developer para cada feature. Unit tests de NgRx pueden escribirse en paralelo.

### 3. Code Reviewer

- **Agente:** `code-reviewer`
- **Funciones:**
  - Code review riguroso pre-merge de cada feature
  - Verificar Angular best practices (OnPush, trackBy, unsubscribe, async pipe)
  - Validar TypeScript strict mode compliance
  - Revisar accesibilidad (ARIA labels, keyboard navigation)
  - Verificar performance (no subscriptions leaks, lazy loading correcto)
  - Validar que NgRx patterns son correctos (no side effects en reducers)
  - Verificar seguridad (no XSS, sanitizacion de inputs)
  - Revisar consistencia de estilos (SCSS organization, naming conventions)
- **Tareas clave:**
  1. Review de setup inicial (project structure, module organization)
  2. Review de servicios HTTP (error handling, typing, interceptors)
  3. Review de NgRx store (action naming, reducer purity, effect patterns)
  4. Review de cada componente (template, styles, logic separation)
  5. Review de E2E tests (realistic scenarios, no flaky tests)
  6. Review final pre-merge de cada fase
- **Entregables:**
  - Code review reports con findings y recomendaciones por PR
  - Checklist de Angular best practices verificado
  - Sign-off de calidad para merge
- **Dependencias:** Se ejecuta despues de cada feature completada y testeada.

### 4. DevOps Engineer

- **Agente:** `devops-engineer`
- **Funciones:**
  - Setup de build pipeline (Angular CLI + esbuild)
  - Configurar Docker para servir la SPA (Nginx)
  - Crear CI/CD workflow (GitHub Actions)
  - Configurar Nginx para SPA routing (fallback a index.html)
  - Optimizar build (source maps, compression, caching headers)
  - Configurar entornos (development, production)
- **Tareas clave:**
  1. Crear `Dockerfile` multi-stage (build Angular + serve con Nginx)
  2. Crear `nginx.conf` (SPA routing, gzip, cache headers, proxy a backend)
  3. Crear `docker-compose.yml` (Angular + Project Admin Backend + PostgreSQL)
  4. Crear `.github/workflows/ci.yml` (lint, test, build, deploy)
  5. Configurar environment files para cada entorno
  6. Documentar proceso de deployment en README
- **Entregables:**
  - `Dockerfile`
  - `nginx.conf`
  - `docker-compose.yml`
  - `.github/workflows/ci.yml`
  - Documentacion de deployment
- **Dependencias:** Requiere build funcional del frontend-developer. Setup inicial puede hacerse en paralelo con Fase A.

### 5. Architecture Advisor

- **Agente:** `software-architect`
- **Funciones:**
  - Resolver decisiones tecnicas complejas durante desarrollo
  - Revisar que la implementacion sigue la arquitectura planificada
  - Evaluar impacto de cambios en la arquitectura
  - Asesorar sobre patterns avanzados (facades, adapters para APIs, error boundaries)
  - Validar integracion con WebSocket (reconnection, state recovery)
- **Tareas clave:**
  1. Review de implementacion vs arquitectura planificada (post-Fase A)
  2. Asesorar sobre WebSocket integration pattern (Fase C)
  3. Evaluar si agregar facade layer entre components y NgRx store
  4. Validar strategy de error handling cross-feature
  5. Post-mortem de arquitectura al final de cada fase
- **Entregables:**
  - Architecture compliance reports
  - Recommendations para ajustes
  - ADR updates basados en decisiones de desarrollo
- **Dependencias:** On-demand, activado cuando hay decisiones tecnicas.

---

## Quality Gates

| Gate | Criterio | Responsable |
|------|----------|-------------|
| Build | 0 errores, 0 warnings (strict mode) | CI pipeline |
| Lint | 0 errores ESLint/Angular rules | CI pipeline |
| Unit Tests | >70% coverage, 0 failures | test-engineer |
| E2E Tests | Todos los flujos criticos pasando | test-engineer |
| Code Review | Aprobado por code-reviewer | code-reviewer |
| Performance | Lighthouse > 80, FCP < 2s | devops-engineer |
| Accesibilidad | WCAG 2.1 AA basico (keyboard nav, ARIA) | code-reviewer |

---

## Orden de Ejecucion (Fase A)

```
1. DevOps: Setup proyecto + CI pipeline
2. Frontend Dev: Setup Angular + routing + services
3. Frontend Dev: NgRx store + ProjectAdminService
4. Test Engineer: Unit tests para store y services
5. Frontend Dev: Dashboard + Project cards
6. Test Engineer: Component tests
7. Frontend Dev: Filtros + busqueda + detalle
8. Test Engineer: E2E tests
9. Code Reviewer: Review completo de Fase A
10. DevOps: Docker + Nginx + deployment
```

Pasos 1-2 en paralelo. Pasos 3-4 parcialmente en paralelo. Pasos 5-8 iterativos.

---

## Oportunidades de Paralelismo

| Paralelo | Tarea A | Tarea B |
|----------|---------|---------|
| 1 | DevOps: CI setup | Frontend Dev: Project setup |
| 2 | Frontend Dev: Components | Test Engineer: NgRx unit tests |
| 3 | Frontend Dev: Fase B features | Test Engineer: Fase A E2E tests |
| 4 | Code Reviewer: Fase A review | Frontend Dev: Comienza Fase B |

---

## Template de Delegacion a Agentes

```
Objetivo: [Que lograr]
Path: C:/apps/web-monitor
Feature: [Nombre del feature/componente]
Contexto: Angular 17+, NgRx, Angular Material
Specs: [Componentes, servicios, interfaces exactas]
API endpoints que consume: [GET /api/projects, etc.]
Restricciones: [OnPush, strict mode, no any, async pipe]
AC: [Criterios de exito]
```

---

**Ecosistema:** Project Admin
**Proyecto:** Angular Web Monitor
