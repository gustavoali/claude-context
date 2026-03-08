# Angular Web Monitor - Project Context

**Version:** 0.2.0 | **Build:** 0 errores, 0 warnings | **Bundle:** 748 KB initial (prod)
**Ubicacion:** C:/apps/web-monitor/

## Stack Tecnologico
- **Framework:** Angular 20 (CLI 20.3.16)
- **Lenguaje:** TypeScript 5.9 strict
- **UI Library:** PrimeNG 20 (Lara theme)
- **State Management:** Angular Signals (ProjectStore con signal/computed)
- **Styling:** SCSS con variables/mixins propios, CSS Grid nativo
- **Testing:** Jasmine + Karma (unit), pendiente E2E
- **Build:** Angular CLI + esbuild
- **Node:** 22.18.0

## Componentes Implementados (Fase A - MVP)

| Componente | Ubicacion | Estado |
|------------|-----------|--------|
| App Shell (sidebar + toolbar) | layout/ | Done |
| Dashboard (cards + table + summary) | features/dashboard/ | Done |
| Project Detail | features/projects/project-detail/ | Done |
| ProjectAdminService (HTTP) | core/services/ | Done |
| ProjectStore (signals) | core/services/ | Done |
| Error Interceptor | core/interceptors/ | Done |
| StatusBadge, RelativeTimePipe | shared/ | Done |
| LoadingState, ErrorState | shared/ | Done |
| Docker + Nginx + CSP headers | root | Done |
| CI pipeline (coverage + prod build) | .github/workflows/ | Done |
| Health check polling (sidebar) | layout/sidebar/ | Done |

## Comandos
```bash
npm start           # ng serve (dev en localhost:4200)
npm run build       # ng build (produccion)
npm run lint        # ng lint (ESLint)
npm test            # ng test (Jasmine/Karma)
docker compose up   # Frontend + backend placeholder
```

## Arquitectura
- **Standalone components** (no NgModules), OnPush en todos
- **Smart/Presentational pattern**: pages inyectan store, presentational reciben inputs
- **Lazy loading**: loadComponent/loadChildren en todas las rutas
- **Functional interceptors**: errorInterceptor transforma a AppError
- **Store**: Subject + switchMap + takeUntilDestroyed (sin subscription leaks)
- **Scoped loading/error**: listLoading/listError + detailLoading/detailError (sin state bleed)
- **Dynamic filters**: opciones derivadas de datos cargados via computed signals
- **Accessibility**: WCAG 2.1 AA basico (keyboard nav, ARIA labels, focus rings)

## Rutas
| Ruta | Componente | Carga |
|------|-----------|-------|
| /dashboard | DashboardComponent | Lazy |
| /projects/:id | ProjectDetailComponent | Lazy |
| /sprints | Placeholder | Lazy |
| /sessions | Placeholder | Lazy |

## API (consume Project Admin Backend)
- `GET /api/projects` - Lista proyectos
- `GET /api/projects/:id` - Detalle proyecto
- `GET /api/health` - Health check
- Base URL: environment.projectAdminUrl (default: http://localhost:3000)

## Agentes Recomendados
| Tarea | Agente |
|-------|--------|
| Componentes Angular | `frontend-angular-developer` |
| Tests | `test-engineer` |
| Code review | `code-reviewer` |
| Arquitectura | `software-architect` |
| Docker/CI | `devops-engineer` |

## Estado del Proyecto
- **Fase A (MVP):** COMPLETADA - 12 stories, 42 pts
- **EPIC-QA:** COMPLETADO - 8 stories, 18 pts (mejoras del code review)
- **Total completado:** 20 stories, 60 pts
- **Fase B (Sprint Tracking):** FUTURO (next phase)
- **Fase C (Sesiones Claude):** FUTURO

## Ecosistema
Consume datos de Project Admin Backend (REST API). Fases futuras integran Claude Orchestrator (WebSocket) y Sprint Backlog Manager.

## Documentacion
@C:/claude_context/apps/web-monitor/PRODUCT_BACKLOG.md
@C:/claude_context/apps/web-monitor/SEED_DOCUMENT.md
@C:/claude_context/apps/web-monitor/TEAM_PLANNING.md
@C:/claude_context/apps/web-monitor/TEAM_DEVELOPMENT.md

---

**Ultima actualizacion:** 2026-02-15
