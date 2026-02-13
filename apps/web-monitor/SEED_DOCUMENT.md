# Angular Web Monitor - Documento Semilla

**Version:** 1.0
**Fecha:** 2026-02-12
**Estado:** PLANIFICADO

---

## Vision y Objetivos

Angular Web Monitor es el **dashboard web** del ecosistema Project Admin. Provee una interfaz completa en navegador para monitorear y gestionar todos los proyectos de desarrollo, sprints, sesiones de agentes Claude y metricas del ecosistema.

Complementa al Claude Code Monitor Flutter (mobile/desktop) ofreciendo una experiencia mas rica y detallada para sesiones de trabajo prolongadas.

### Objetivos

- Centralizar la visibilidad de todos los proyectos en una interfaz web
- Mostrar estado de sprints, velocity, burndown y backlogs en tiempo real
- Monitorear sesiones activas de Claude Orchestrator
- Proveer filtros, busqueda y categorias para navegar el ecosistema
- Servir como interfaz de gestion (no solo monitoreo) en fases avanzadas

---

## Arquitectura

```
+-------------------------------------------+
|         Angular Web Monitor               |
|         (SPA - Browser)                   |
|                                           |
|  +------------+  +-------------------+    |
|  | NgRx Store |  | Angular Services  |    |
|  | (state)    |  | (HTTP + WebSocket)|    |
|  +------+-----+  +--------+----------+    |
|         |                  |               |
+---------+------------------+---------------+
          |                  |
          |    HTTP/REST     |    WebSocket
          |                  |
+---------+------------------+---------------+
|         Project Admin Backend              |
|         (Node.js + PostgreSQL)             |
|         REST API + MCP Server              |
+---------+------------------+---------------+
          |                  |
    +-----+------+    +-----+--------+
    |            |    |              |
    v            v    v              v
+--------+ +--------+ +-------------+
| Sprint | | Claude | | Git repos   |
| Backlog| | Orches-| | (filesystem)|
| Manager| | trator | |             |
+--------+ +--------+ +-------------+
```

### Flujo de Datos

1. Angular consume REST API de Project Admin Backend
2. Project Admin agrega datos de Sprint Backlog Manager, Claude Orchestrator y filesystem
3. Para datos real-time (sesiones Claude), Angular conecta via WebSocket al Orchestrator (opcionalmente proxied por Project Admin)

---

## Stack Tecnologico

| Componente | Tecnologia | Justificacion |
|------------|-----------|---------------|
| Framework | Angular 17+ | Ecosistema maduro, TypeScript nativo, experiencia del usuario |
| Lenguaje | TypeScript 5.x | Type safety, consistente con backend |
| UI Library | Angular Material o PrimeNG | Componentes enterprise-ready, tablas, cards, dashboards |
| State Management | NgRx | Manejo predecible de estado complejo, effects para async |
| HTTP | HttpClient + interceptors | Nativo de Angular, error handling centralizado |
| WebSocket | rxjs/webSocket | Integracion nativa con RxJS para streaming real-time |
| Graficos | ngx-charts o Chart.js | Burndown, velocity, pie charts de estado |
| Testing | Jasmine + Karma (unit), Cypress o Playwright (E2E) | Standard de Angular |
| Build | Angular CLI + esbuild | Rapido, tree-shaking optimizado |

---

## Features por Fase

### Fase A: MVP - Dashboard de Proyectos

- Dashboard principal con cards de cada proyecto (nombre, stack, estado, ultimo cambio)
- Tabla alternativa con sorting y paginacion
- Filtros por clasificador (agents, apps, mcp, mobile), estado, stack
- Busqueda por nombre
- Detalle de proyecto (metadata completa, paths, links, equipo)
- Responsive layout (desktop-first, adaptable a tablet)

### Fase B: Sprint Tracking

- Sprint board kanban por proyecto (columnas: Backlog, Ready, In Progress, Review, Done)
- Burndown chart del sprint activo
- Velocity chart historica
- Lista de stories con filtros (status, priority, epic)
- Detalle de story (AC, technical notes, branch, owner)
- Technical debt register con ROI

### Fase C: Monitor de Sesiones Claude

- Lista de sesiones activas (real-time via WebSocket)
- Detalle de sesion: proyecto, story vinculada, token usage, duracion
- Streaming de mensajes de agente (output live)
- Crear/detener sesiones desde la web (opcional)
- Historial de sesiones completadas con metricas

### Fase D: Avanzado

- Dashboard configurable con widgets drag-and-drop
- Reportes exportables (PDF, CSV)
- Notificaciones en browser (Web Notifications API)
- Dark mode toggle
- Comparativa entre proyectos (metricas lado a lado)
- Timeline de actividad cross-proyecto

---

## Estructura de Componentes

```
src/
├── app/
│   ├── core/
│   │   ├── services/           # API services (singleton)
│   │   │   ├── project-admin.service.ts
│   │   │   ├── websocket.service.ts
│   │   │   └── auth.service.ts
│   │   ├── interceptors/       # HTTP interceptors
│   │   │   ├── error.interceptor.ts
│   │   │   ├── auth.interceptor.ts
│   │   │   └── cache.interceptor.ts
│   │   ├── guards/             # Route guards
│   │   └── models/             # Interfaces y types compartidos
│   │
│   ├── shared/
│   │   ├── components/         # Componentes reutilizables
│   │   │   ├── status-badge/
│   │   │   ├── search-bar/
│   │   │   └── loading-spinner/
│   │   ├── pipes/
│   │   └── directives/
│   │
│   ├── features/
│   │   ├── dashboard/          # Lazy-loaded
│   │   │   ├── dashboard.module.ts
│   │   │   ├── dashboard.component.ts
│   │   │   └── components/
│   │   │       ├── project-card/
│   │   │       ├── project-table/
│   │   │       └── ecosystem-summary/
│   │   │
│   │   ├── projects/           # Lazy-loaded
│   │   │   ├── projects.module.ts
│   │   │   ├── project-list/
│   │   │   └── project-detail/
│   │   │
│   │   ├── sprints/            # Lazy-loaded (Fase B)
│   │   │   ├── sprints.module.ts
│   │   │   ├── sprint-board/
│   │   │   ├── burndown-chart/
│   │   │   ├── velocity-chart/
│   │   │   └── story-detail/
│   │   │
│   │   └── sessions/           # Lazy-loaded (Fase C)
│   │       ├── sessions.module.ts
│   │       ├── session-list/
│   │       ├── session-detail/
│   │       └── session-stream/
│   │
│   ├── store/                  # NgRx
│   │   ├── projects/
│   │   │   ├── projects.actions.ts
│   │   │   ├── projects.reducer.ts
│   │   │   ├── projects.effects.ts
│   │   │   └── projects.selectors.ts
│   │   ├── sprints/
│   │   └── sessions/
│   │
│   ├── app.component.ts
│   ├── app.routes.ts
│   └── app.config.ts
│
├── assets/
├── environments/
│   ├── environment.ts
│   └── environment.prod.ts
└── styles/
    ├── _variables.scss
    └── _mixins.scss
```

---

## Estrategia de API

### HTTP Client

```typescript
// core/services/project-admin.service.ts
@Injectable({ providedIn: 'root' })
export class ProjectAdminService {
  private baseUrl = environment.projectAdminUrl; // default: http://localhost:3000

  getProjects(filters?: ProjectFilters): Observable<Project[]>;
  getProject(id: string): Observable<ProjectDetail>;
  getActiveSprint(projectPrefix: string): Observable<Sprint>;
  getSprintBoard(projectPrefix: string): Observable<SprintBoard>;
  getBurndown(projectPrefix: string): Observable<BurndownData>;
  getVelocity(projectPrefix: string): Observable<VelocityData>;
  getActiveSessions(): Observable<Session[]>;
}
```

### Interceptors

- **ErrorInterceptor:** Manejo centralizado de errores HTTP (401, 403, 404, 500)
- **AuthInterceptor:** Agregar token a requests (cuando se implemente auth)
- **CacheInterceptor:** Cache de responses con TTL configurable (5 min default para metricas)

### WebSocket

```typescript
// core/services/websocket.service.ts
@Injectable({ providedIn: 'root' })
export class WebSocketService {
  private wsUrl = environment.orchestratorWsUrl; // default: ws://localhost:8765

  connect(): Observable<WebSocketMessage>;
  subscribeTo(sessionId: string): void;
  unsubscribeFrom(sessionId: string): void;
}
```

---

## Ubicacion del Proyecto

| Aspecto | Path |
|---------|------|
| Codigo fuente | `C:/apps/web-monitor/` |
| Contexto Claude | `C:/claude_context/apps/web-monitor/` |
| Clasificador | apps |

---

## Dependencias del Ecosistema

| Dependencia | Tipo | Requerida para |
|-------------|------|---------------|
| Project Admin Backend (REST API) | Obligatoria | Fase A en adelante |
| Sprint Backlog Manager (via Project Admin) | Obligatoria | Fase B |
| Claude Orchestrator (WebSocket) | Obligatoria | Fase C |

**El backend debe existir antes de comenzar desarrollo del frontend.**

---

## Requerimientos No Funcionales

| Metrica | Target |
|---------|--------|
| First Contentful Paint | < 2s |
| Bundle size (initial) | < 500KB |
| Time to Interactive | < 3s |
| Lighthouse Performance score | > 80 |
| Responsive breakpoints | Desktop (1200+), Tablet (768-1199), Mobile (< 768) |

---

## Configuracion por Entorno

### Development
```
PROJECT_ADMIN_URL=http://localhost:3000
ORCHESTRATOR_WS_URL=ws://localhost:8765
CACHE_TTL_MS=30000
```

### Production
```
PROJECT_ADMIN_URL=https://admin.local
ORCHESTRATOR_WS_URL=wss://orchestrator.local
CACHE_TTL_MS=300000
```

---

## Decisiones Abiertas

1. **UI Library:** Angular Material vs PrimeNG vs Taiga UI
2. **Standalone components:** Usar la nueva API de Angular 17+ (standalone) o NgModules clasicos
3. **SSR:** Necesario? Para un dashboard interno probablemente no
4. **Auth:** Implementar desde Fase A o dejar para cuando haya acceso remoto
5. **Monorepo:** Considerar Nx workspace si se agregan mas frontends

---

**Ecosistema:** Project Admin
**Fase de activacion:** Phase 2+ (requiere backend operativo)
