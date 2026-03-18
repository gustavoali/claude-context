### EH-007: Servicios HTTP Angular (alertas, ideas, proyectos)
**Points:** 3 | **Priority:** Critical
**Epic:** EPIC-02: Dashboard + Alertas UI
**Dependencies:** EH-003, EH-004, EH-005 (backend endpoints), EH-006 (Angular app)

**As a** frontend developer
**I want** Angular services that consume the backend REST endpoints
**So that** components can access data through a clean abstraction layer

#### Acceptance Criteria

**AC1: AlertsService**
- Given the backend exposes `/api/alerts`
- When `AlertsService.getAlerts(filters?)` is called
- Then it returns a `Signal<Alert[]>` with the fetched data
- And supports optional filters: scope, status, type

**AC2: IdeasService**
- Given the backend exposes `/api/ideas`
- When `IdeasService.getIdeas(filters?)` is called
- Then it returns a `Signal<Idea[]>` with the fetched data
- And `IdeasService.getIdea(id)` returns the full idea detail

**AC3: ProjectsService**
- Given the backend exposes `/api/hub/projects`
- When `ProjectsService.getProjects(filters?)` is called
- Then it returns a `Signal<Project[]>` with merged project data
- And `ProjectsService.getStats()` returns project counts

**AC4: Error handling**
- Given the backend is unreachable
- When any service makes a request
- Then it sets an error signal and does not throw unhandled exceptions
- And components can react to the error state

**AC5: Loading state**
- Given a request is in flight
- When data is being fetched
- Then a loading signal is true
- And it becomes false when the request completes (success or error)

#### Technical Notes
- Usar `HttpClient` con `toSignal()` o custom signal wrappers
- Base URL configurable via environment.ts (default: `http://localhost:3001`)
- Interfaces TypeScript para Alert, Idea, Project
- Interceptor para error handling global (toast con PrimeNG)

#### Definition of Done
- [ ] 3 servicios implementados con interfaces tipadas
- [ ] Signals para data, loading, error
- [ ] Error handling con feedback visual
- [ ] Unit tests para cada servicio (mock HTTP)
