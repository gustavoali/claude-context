# Angular Web Monitor - Architecture Document

**Version:** 1.0
**Fecha:** 2026-02-14
**Autor:** software-architect (agente)
**Estado:** APROBADO para implementacion

---

## 1. Arquitectura de Componentes

### 1.1 Component Tree

```
AppComponent (shell: sidebar + toolbar + router-outlet)
├── SidebarComponent (navegacion principal)
├── ToolbarComponent (breadcrumb, search global)
│
├── [route: /dashboard]
│   └── DashboardComponent (pagina principal)
│       ├── EcosystemSummaryComponent (metricas agregadas)
│       ├── ProjectCardListComponent (grid de cards)
│       │   └── ProjectCardComponent (*) (card individual)
│       └── ProjectTableComponent (vista tabla alternativa)
│
├── [route: /projects/:id]
│   └── ProjectDetailComponent (detalle completo)
│       ├── ProjectHeaderComponent (nombre, estado, stack badges)
│       ├── ProjectMetadataComponent (paths, links, equipo)
│       └── ProjectDependenciesComponent (deps del ecosistema)
│
├── [route: /sprints] (Fase B - stub)
│   └── SprintDashboardComponent
│       ├── SprintBoardComponent (lista por columnas, sin drag-drop)
│       ├── BurndownChartComponent (ngx-charts)
│       ├── VelocityChartComponent (ngx-charts)
│       └── StoryDetailComponent
│
└── [route: /sessions] (Fase C - stub)
    └── SessionListComponent
        ├── SessionCardComponent (*)
        └── SessionMetricsComponent
```

### 1.2 Responsabilidades por Componente

| Componente | Responsabilidad | Tipo |
|------------|----------------|------|
| AppComponent | Shell layout, routing, inicializacion global | Smart |
| SidebarComponent | Navegacion, menu items, active route highlight | Presentational |
| ToolbarComponent | Breadcrumb, search input, view toggle (cards/table) | Presentational + emits |
| DashboardComponent | Orquesta datos: carga proyectos, maneja filtros, vista activa | Smart (page) |
| EcosystemSummaryComponent | Muestra totales (proyectos, activos, por stack) | Presentational |
| ProjectCardListComponent | Renderiza grid de cards, recibe lista filtrada | Presentational |
| ProjectCardComponent | Card individual: nombre, stack, estado, ultimo cambio | Presentational |
| ProjectTableComponent | Tabla PrimeNG con sorting, paginacion | Presentational + emits |
| ProjectDetailComponent | Carga y muestra detalle de un proyecto | Smart (page) |
| ProjectHeaderComponent | Header del detalle: titulo, badges, acciones | Presentational |
| ProjectMetadataComponent | Metadata: paths, clasificador, config | Presentational |
| ProjectDependenciesComponent | Lista de dependencias del ecosistema | Presentational |

**Convencion Smart vs Presentational:**
- **Smart (page) components:** Inyectan servicios, llaman API, manejan estado local. Son los route components.
- **Presentational components:** Reciben datos via `@Input()`, emiten eventos via `@Output()`. Sin inyeccion de servicios de datos.

---

## 2. Data Flow

### 2.1 Patron General (Fase A)

```
                HTTP GET
ProjectAdminService ──────────► Backend API (localhost:3000)
        │                              │
        │  Observable<T>               │ JSON response
        ▼                              ▼
  Smart Component ◄──────────── ProjectAdminService
  (DashboardComponent)           (transforma, cachea)
        │
        │  @Input() bindings
        ▼
  Presentational Components
  (ProjectCard, ProjectTable)
        │
        │  @Output() events
        ▼
  Smart Component (maneja evento, actualiza estado)
```

### 2.2 State Flow para Fase A

No hay store global. Cada smart component (page) es dueno de su estado:

```
DashboardComponent:
  state = {
    projects: Signal<Project[]>          // datos del backend
    filteredProjects: Signal<Project[]>  // proyectos filtrados (computed)
    filters: Signal<ProjectFilters>      // filtros activos
    viewMode: Signal<'cards' | 'table'> // modo de vista
    loading: Signal<boolean>            // estado de carga
    error: Signal<string | null>        // error de API
  }

ProjectDetailComponent:
  state = {
    project: Signal<ProjectDetail | null>
    loading: Signal<boolean>
    error: Signal<string | null>
  }
```

### 2.3 Flujo de Filtrado

```
Usuario cambia filtro
  → ToolbarComponent emite @Output filterChange
    → DashboardComponent actualiza filters signal
      → computed signal filteredProjects se recalcula automaticamente
        → ProjectCardListComponent / ProjectTableComponent re-renderizan
```

### 2.4 Flujo de Navegacion

```
Usuario hace click en proyecto (card o fila de tabla)
  → ProjectCardComponent / ProjectTableComponent emite @Output projectSelected
    → DashboardComponent navega a /projects/:id via Router
      → ProjectDetailComponent carga datos via ProjectAdminService
```

---

## 3. State Management Strategy

### 3.1 Fase A: Angular Signals

**Decision:** Usar Angular Signals para estado local en cada page component. Sin store global.

**Justificacion:**
- Fase A tiene 2 page components con estado simple (lista y detalle)
- No hay estado compartido entre rutas que justifique un store global
- Signals son reactivos, tipados y nativos de Angular 17+
- Menor boilerplate que NgRx (0 acciones, 0 reducers, 0 effects)

**Implementacion:**

```typescript
// dashboard.component.ts
export class DashboardComponent implements OnInit {
  private projectService = inject(ProjectAdminService);

  // State
  projects = signal<Project[]>([]);
  filters = signal<ProjectFilters>({});
  viewMode = signal<'cards' | 'table'>('cards');
  loading = signal(false);
  error = signal<string | null>(null);

  // Derived state
  filteredProjects = computed(() => {
    return this.applyFilters(this.projects(), this.filters());
  });

  summary = computed(() => {
    return this.calculateSummary(this.projects());
  });
}
```

### 3.2 Migracion a NgRx (Fase B - si se necesita)

**Trigger para migrar:** Si en Fase B se cumplen 2+ de estas condiciones:
- Estado compartido entre 3+ rutas (ej: proyecto seleccionado afecta sprint y stories)
- Necesidad de cache sofisticado con invalidacion (ej: sprint data + velocity + burndown)
- Mas de 5 efectos asincronos interrelacionados
- WebSocket events que modifican estado en multiples componentes

**Ruta de migracion:**
1. Extraer signals a un `ProjectStore` service (injectable, singleton)
2. El `ProjectStore` encapsula signals + metodos de mutacion
3. Si NgRx se justifica: reemplazar `ProjectStore` interno por NgRx actions/reducer/selectors
4. Los componentes NO cambian (siguen usando el store service como fachada)

**Patron de fachada (recomendado como paso intermedio):**

```typescript
// Fase A: servicio con signals
@Injectable({ providedIn: 'root' })
export class ProjectStore {
  private _projects = signal<Project[]>([]);
  readonly projects = this._projects.asReadonly();

  loadProjects(): void { /* HTTP call, update signal */ }
  setFilters(filters: ProjectFilters): void { /* ... */ }
}

// Fase B (si se migra a NgRx): misma interfaz, NgRx por debajo
@Injectable({ providedIn: 'root' })
export class ProjectStore {
  private store = inject(Store);
  readonly projects = toSignal(this.store.select(selectProjects));

  loadProjects(): void { this.store.dispatch(loadProjects()); }
}
```

Los componentes nunca saben si usan signals puros o NgRx por debajo.

---

## 4. API Integration

### 4.1 Servicios

```typescript
// core/services/project-admin.service.ts
@Injectable({ providedIn: 'root' })
export class ProjectAdminService {
  private http = inject(HttpClient);
  private baseUrl = environment.projectAdminUrl; // http://localhost:3000

  // Fase A
  getProjects(): Observable<Project[]> {
    return this.http.get<Project[]>(`${this.baseUrl}/api/projects`);
  }

  getProject(id: string): Observable<ProjectDetail> {
    return this.http.get<ProjectDetail>(`${this.baseUrl}/api/projects/${id}`);
  }

  getHealth(): Observable<HealthStatus> {
    return this.http.get<HealthStatus>(`${this.baseUrl}/api/health`);
  }

  // Fase B (placeholder)
  // getActiveSprint(projectPrefix: string): Observable<Sprint>
  // getSprintBoard(projectPrefix: string): Observable<SprintBoard>
  // getBurndown(projectPrefix: string): Observable<BurndownData>
  // getVelocity(projectPrefix: string): Observable<VelocityData>
}
```

### 4.2 Models/Interfaces

```typescript
// core/models/project.model.ts
export interface Project {
  id: string;
  name: string;
  classifier: string;      // 'agents' | 'apps' | 'mcp' | 'mobile' | etc.
  status: ProjectStatus;
  stack: string[];          // ['Angular', 'TypeScript', 'PrimeNG']
  path: string;
  contextPath: string;
  lastModified: string;     // ISO date
  description?: string;
}

export interface ProjectDetail extends Project {
  dependencies: ProjectDependency[];
  team: TeamMember[];
  endpoints?: ApiEndpoint[];
  commands?: ProjectCommand[];
  metadata: Record<string, unknown>;
}

export type ProjectStatus = 'active' | 'planned' | 'paused' | 'completed' | 'archived';

export interface ProjectFilters {
  classifier?: string;
  status?: ProjectStatus;
  stack?: string;
  search?: string;
}

export interface ProjectDependency {
  name: string;
  type: 'required' | 'optional';
  status: 'available' | 'unavailable' | 'partial';
}

export interface TeamMember {
  role: string;
  agent: string;
}

export interface EcosystemSummary {
  totalProjects: number;
  activeProjects: number;
  byClassifier: Record<string, number>;
  byStatus: Record<ProjectStatus, number>;
  byStack: Record<string, number>;
}

// core/models/health.model.ts
export interface HealthStatus {
  status: 'ok' | 'degraded' | 'down';
  uptime: number;
  version: string;
  dependencies: Record<string, 'ok' | 'down'>;
}
```

### 4.3 Interceptors

```typescript
// core/interceptors/error.interceptor.ts
// Manejo centralizado de errores HTTP
// - 0 (network error): mostrar "Backend no disponible"
// - 404: mostrar "Recurso no encontrado"
// - 500: mostrar "Error del servidor"
// - Loggear todos los errores a console en development

// core/interceptors/base-url.interceptor.ts
// Agregar baseUrl a requests relativas (opcional, puede manejarse en el servicio)

// core/interceptors/loading.interceptor.ts (DIFERIDO)
// Para Fase B+: loading indicator global automatico
```

**Para Fase A solo se implementa `error.interceptor.ts`.** Los demas se agregan cuando se necesiten.

### 4.4 Error Handling Strategy

```
HTTP Error
  → ErrorInterceptor captura
    → Transforma a AppError (tipo + mensaje user-friendly)
      → Re-throw como Observable error
        → Smart component captura en subscribe/toSignal
          → Actualiza signal de error
            → Template muestra mensaje con PrimeNG Message/Toast
```

```typescript
// core/models/error.model.ts
export interface AppError {
  type: 'network' | 'not-found' | 'server' | 'unknown';
  message: string;        // user-friendly
  originalError?: unknown; // para debugging
}
```

---

## 5. Routing Strategy

### 5.1 Route Configuration

```typescript
// app.routes.ts
export const routes: Routes = [
  {
    path: '',
    redirectTo: 'dashboard',
    pathMatch: 'full'
  },
  {
    path: 'dashboard',
    loadComponent: () => import('./features/dashboard/dashboard.component')
      .then(m => m.DashboardComponent),
    title: 'Dashboard'
  },
  {
    path: 'projects/:id',
    loadComponent: () => import('./features/projects/project-detail/project-detail.component')
      .then(m => m.ProjectDetailComponent),
    title: 'Project Detail'
  },
  // Fase B
  {
    path: 'sprints',
    loadChildren: () => import('./features/sprints/sprint.routes')
      .then(m => m.SPRINT_ROUTES),
    title: 'Sprints'
  },
  // Fase C
  {
    path: 'sessions',
    loadChildren: () => import('./features/sessions/session.routes')
      .then(m => m.SESSION_ROUTES),
    title: 'Sessions'
  },
  {
    path: '**',
    redirectTo: 'dashboard'
  }
];
```

### 5.2 Lazy Loading Strategy

| Route | Loading | Justificacion |
|-------|---------|---------------|
| /dashboard | `loadComponent` | Single component, se carga rapido |
| /projects/:id | `loadComponent` | Single component con sub-components |
| /sprints/* | `loadChildren` (Fase B) | Multiple sub-routes, chunk separado |
| /sessions/* | `loadChildren` (Fase C) | Multiple sub-routes, chunk separado |

### 5.3 Guards

Para Fase A no se necesitan guards de autenticacion. Se implementara un guard funcional simple:

```typescript
// core/guards/backend-available.guard.ts (opcional)
// Verifica que el backend responde antes de navegar
// Si falla, redirige a una pagina de "Backend no disponible"
// Implementar solo si la experiencia lo justifica
```

---

## 6. Folder Structure

```
src/
├── app/
│   ├── core/                          # Singleton services, interceptors, models
│   │   ├── services/
│   │   │   └── project-admin.service.ts
│   │   ├── interceptors/
│   │   │   └── error.interceptor.ts
│   │   ├── models/
│   │   │   ├── project.model.ts
│   │   │   ├── health.model.ts
│   │   │   └── error.model.ts
│   │   └── guards/
│   │       └── (vacio en Fase A)
│   │
│   ├── shared/                        # Componentes reutilizables cross-feature
│   │   ├── components/
│   │   │   ├── status-badge/
│   │   │   │   └── status-badge.component.ts
│   │   │   ├── stack-chips/
│   │   │   │   └── stack-chips.component.ts
│   │   │   ├── loading-error/
│   │   │   │   └── loading-error.component.ts
│   │   │   └── empty-state/
│   │   │       └── empty-state.component.ts
│   │   └── pipes/
│   │       ├── relative-time.pipe.ts
│   │       └── classifier-label.pipe.ts
│   │
│   ├── layout/                        # Shell components
│   │   ├── sidebar/
│   │   │   └── sidebar.component.ts
│   │   └── toolbar/
│   │       └── toolbar.component.ts
│   │
│   ├── features/                      # Feature components (lazy-loaded)
│   │   ├── dashboard/
│   │   │   ├── dashboard.component.ts
│   │   │   ├── dashboard.component.html
│   │   │   ├── dashboard.component.scss
│   │   │   └── components/
│   │   │       ├── ecosystem-summary/
│   │   │       │   └── ecosystem-summary.component.ts
│   │   │       ├── project-card-list/
│   │   │       │   └── project-card-list.component.ts
│   │   │       ├── project-card/
│   │   │       │   ├── project-card.component.ts
│   │   │       │   └── project-card.component.scss
│   │   │       └── project-table/
│   │   │           └── project-table.component.ts
│   │   │
│   │   ├── projects/
│   │   │   └── project-detail/
│   │   │       ├── project-detail.component.ts
│   │   │       ├── project-detail.component.html
│   │   │       ├── project-detail.component.scss
│   │   │       └── components/
│   │   │           ├── project-header/
│   │   │           │   └── project-header.component.ts
│   │   │           ├── project-metadata/
│   │   │           │   └── project-metadata.component.ts
│   │   │           └── project-dependencies/
│   │   │               └── project-dependencies.component.ts
│   │   │
│   │   ├── sprints/                   # Fase B - solo stubs
│   │   │   └── sprint.routes.ts
│   │   │
│   │   └── sessions/                  # Fase C - solo stubs
│   │       └── session.routes.ts
│   │
│   ├── app.component.ts
│   ├── app.component.html
│   ├── app.component.scss
│   ├── app.routes.ts
│   └── app.config.ts
│
├── environments/
│   ├── environment.ts                 # development defaults
│   └── environment.prod.ts
│
├── assets/
│   └── icons/                         # SVG icons si se necesitan
│
└── styles/
    ├── _variables.scss                # PrimeNG theme overrides, colores custom
    ├── _layout.scss                   # Grid, spacing utilities
    └── styles.scss                    # Global styles, PrimeNG imports
```

### 6.1 Convenciones de Archivos

| Convencion | Ejemplo |
|------------|---------|
| Componente standalone (1 archivo si es simple) | `project-card.component.ts` (template inline) |
| Componente standalone (multiples archivos si es complejo) | `dashboard.component.ts` + `.html` + `.scss` |
| Servicio singleton | `project-admin.service.ts` en `core/services/` |
| Model/interface | `project.model.ts` en `core/models/` |
| Pipe standalone | `relative-time.pipe.ts` en `shared/pipes/` |
| Interceptor functional | `error.interceptor.ts` en `core/interceptors/` |
| Feature sub-components | `features/[feature]/components/[component-name]/` |

### 6.2 Regla de Ubicacion

- Si un componente se usa en **1 solo feature**: va dentro de `features/[feature]/components/`
- Si un componente se usa en **2+ features**: va en `shared/components/`
- Si un servicio maneja **datos de API**: va en `core/services/`
- Si un servicio es **utility puro**: va en `shared/` (o se convierte en pipe/directive)

---

## 7. Component Design (Fase A)

### 7.1 AppComponent

```
Tipo: Smart (shell)
Template: sidebar fijo izquierdo + area principal con toolbar + router-outlet
Layout: CSS Grid - 2 columnas (sidebar 250px | main 1fr)
PrimeNG: nada (layout puro)
Responsabilidades:
  - Renderizar shell layout
  - router-outlet para page components
```

### 7.2 SidebarComponent

```
Tipo: Presentational
Inputs: menuItems: MenuItem[], activeRoute: string
Outputs: (ninguno, usa routerLink directo)
PrimeNG: p-menu (vertical navigation) o p-panelMenu
Responsabilidades:
  - Menu de navegacion: Dashboard, Projects (futuro: Sprints, Sessions)
  - Resaltar ruta activa
  - Logo/titulo del ecosistema
  - Collapsible en tablet (Fase A: fijo)
```

### 7.3 ToolbarComponent

```
Tipo: Presentational + emits
Inputs: breadcrumb: string[], viewMode: 'cards' | 'table', filterOptions: FilterOption[]
Outputs: searchChange: EventEmitter<string>, viewModeChange: EventEmitter<'cards'|'table'>,
         filterChange: EventEmitter<ProjectFilters>
PrimeNG: p-breadcrumb, p-inputGroup (search), p-selectButton (view toggle),
         p-dropdown (filtros)
Responsabilidades:
  - Breadcrumb de navegacion
  - Input de busqueda con debounce (300ms)
  - Toggle cards/tabla
  - Dropdowns de filtros (clasificador, estado, stack)
```

### 7.4 DashboardComponent (Page)

```
Tipo: Smart (page)
Route: /dashboard
PrimeNG: (ninguno directo, orquesta children)
State:
  - projects: Signal<Project[]>
  - filters: Signal<ProjectFilters>
  - viewMode: Signal<'cards' | 'table'>
  - loading: Signal<boolean>
  - error: Signal<string | null>
Computed:
  - filteredProjects: computed(() => applyFilters(projects(), filters()))
  - summary: computed(() => calculateSummary(projects()))
Responsabilidades:
  - OnInit: llamar ProjectAdminService.getProjects()
  - Manejar eventos de ToolbarComponent (filtros, search, view toggle)
  - Pasar datos filtrados a children
  - Navegar a /projects/:id cuando se selecciona un proyecto
```

### 7.5 EcosystemSummaryComponent

```
Tipo: Presentational
Inputs: summary: EcosystemSummary
Outputs: (ninguno)
PrimeNG: p-card (container), badges para numeros
Responsabilidades:
  - Mostrar total de proyectos, activos, por clasificador
  - Cards o badges con numeros agregados
  - Layout horizontal (row de mini-cards)
```

### 7.6 ProjectCardListComponent

```
Tipo: Presentational
Inputs: projects: Project[]
Outputs: projectSelected: EventEmitter<string> (project id)
PrimeNG: (ninguno, CSS Grid para layout)
Responsabilidades:
  - Renderizar grid responsivo de ProjectCardComponent
  - Grid: 3 columnas desktop, 2 tablet, 1 mobile
  - trackBy: project.id
  - Mostrar EmptyStateComponent si projects.length === 0
```

### 7.7 ProjectCardComponent

```
Tipo: Presentational
Inputs: project: Project
Outputs: selected: EventEmitter<string>
PrimeNG: p-card
Responsabilidades:
  - Mostrar: nombre, descripcion (truncada), clasificador badge, status badge
  - Stack chips (shared StackChipsComponent)
  - Ultimo cambio (shared RelativeTimePipe)
  - Click en card emite selected
```

### 7.8 ProjectTableComponent

```
Tipo: Presentational
Inputs: projects: Project[]
Outputs: projectSelected: EventEmitter<string>
PrimeNG: p-table (sorting, pagination, responsive)
Columnas: Nombre | Clasificador | Estado | Stack | Ultimo Cambio
Responsabilidades:
  - Tabla con sorting por columna (client-side, datos ya cargados)
  - Paginacion (10/25/50 rows)
  - Click en fila emite projectSelected
  - Responsive: scroll horizontal en mobile
PrimeNG config:
  - [sortMode]="single"
  - [paginator]="true"
  - [rows]="10"
  - [rowsPerPageOptions]="[10, 25, 50]"
  - [showCurrentPageReport]="true"
```

### 7.9 ProjectDetailComponent (Page)

```
Tipo: Smart (page)
Route: /projects/:id
PrimeNG: p-breadcrumb (back navigation)
State:
  - project: Signal<ProjectDetail | null>
  - loading: Signal<boolean>
  - error: Signal<string | null>
Responsabilidades:
  - OnInit: leer :id de ActivatedRoute, llamar getProject(id)
  - Pasar datos a children
  - Boton "Back to Dashboard" o breadcrumb
```

### 7.10 ProjectHeaderComponent

```
Tipo: Presentational
Inputs: project: ProjectDetail
Outputs: (ninguno)
PrimeNG: p-tag (status, classifier), p-chip (stack items)
Responsabilidades:
  - Titulo grande con nombre del proyecto
  - Tags: estado, clasificador
  - Stack chips
  - Descripcion
```

### 7.11 ProjectMetadataComponent

```
Tipo: Presentational
Inputs: project: ProjectDetail
Outputs: (ninguno)
PrimeNG: p-fieldset o p-panel (agrupador)
Responsabilidades:
  - Mostrar: path, contextPath, comandos, endpoints
  - Layout: key-value pairs en 2 columnas
  - Links clickeables donde aplique
```

### 7.12 ProjectDependenciesComponent

```
Tipo: Presentational
Inputs: dependencies: ProjectDependency[]
Outputs: (ninguno)
PrimeNG: p-table (simple, sin paginacion)
Responsabilidades:
  - Tabla: Dependencia | Tipo | Estado (con StatusBadge)
  - Indicador visual: verde (available), rojo (unavailable), amarillo (partial)
```

### 7.13 Shared Components

**StatusBadgeComponent:**
```
Inputs: status: string, type: 'project' | 'dependency' | 'sprint'
PrimeNG: p-tag con severity mapeada (success/warning/danger/info)
```

**StackChipsComponent:**
```
Inputs: stack: string[]
PrimeNG: p-chip por cada item del stack
```

**LoadingErrorComponent:**
```
Inputs: loading: boolean, error: string | null
PrimeNG: p-progressSpinner (loading), p-message (error)
Template: muestra spinner si loading, mensaje de error si error, nada si ambos false
```

**EmptyStateComponent:**
```
Inputs: message: string, icon?: string
PrimeNG: (HTML/CSS custom)
Template: icono + mensaje centrado cuando no hay datos
```

---

## 8. PrimeNG Integration

### 8.1 Componentes a Usar por Feature

| Feature | PrimeNG Components |
|---------|-------------------|
| Layout/Shell | MenuModule (sidebar) |
| Toolbar | BreadcrumbModule, InputTextModule, SelectButtonModule, DropdownModule |
| Dashboard cards | CardModule |
| Dashboard table | TableModule |
| Project detail | FieldsetModule o PanelModule, TagModule, ChipModule |
| Status indicators | TagModule, BadgeModule |
| Loading/Error | ProgressSpinnerModule, MessageModule, ToastModule |
| General | ButtonModule, RippleModule, TooltipModule |

### 8.2 Theme

Usar un tema built-in de PrimeNG que sea limpio para dashboards:

- **Recomendado:** `lara-light-blue` (moderno, limpio, buen contraste)
- **Alternativa:** `soho-light` (mas enterprise)
- **Dark mode:** `lara-dark-blue` (si se desea en futuro, trivial de cambiar)

### 8.3 Setup en app.config.ts

```typescript
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { providePrimeNG } from 'primeng/config';
import Lara from '@primeng/themes/lara';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    provideHttpClient(withInterceptors([errorInterceptor])),
    provideAnimationsAsync(),
    providePrimeNG({
      theme: {
        preset: Lara
      }
    })
  ]
};
```

### 8.4 Import Strategy

Cada standalone component importa solo los PrimeNG modules que necesita:

```typescript
@Component({
  standalone: true,
  imports: [CardModule, TagModule, ChipModule],
  // ...
})
export class ProjectCardComponent { }
```

Esto permite tree-shaking efectivo: solo el codigo de PrimeNG que se usa entra en el bundle.

---

## 9. Performance Strategy

### 9.1 Change Detection

- **Todos los componentes usan `OnPush`** via `changeDetection: ChangeDetectionStrategy.OnPush`
- Signals son compatibles con OnPush de forma nativa (notifican cambios automaticamente)
- Los presentational components solo re-renderizan cuando sus `@Input()` cambian

### 9.2 Lazy Loading

- Cada feature route usa `loadComponent` o `loadChildren`
- Fase B y C son chunks separados que no se cargan hasta que el usuario navega a esos routes
- PrimeNG modules se importan por componente (no globalmente)

### 9.3 trackBy

Todas las listas con `@for` o `*ngFor` usan `trackBy`:

```html
@for (project of filteredProjects(); track project.id) {
  <app-project-card [project]="project" />
}
```

### 9.4 Debounce

- Search input: debounce de 300ms antes de filtrar
- Implementar con `rxjs/debounceTime` o signal effect con `setTimeout`

### 9.5 Bundle Size

| Target | Estrategia |
|--------|-----------|
| Initial bundle < 300KB | Lazy loading de features, tree-shaking de PrimeNG |
| Feature chunk < 100KB | Solo importar PrimeNG modules necesarios por componente |
| Total < 500KB | Monitorear con `ng build --stats-json` + webpack-bundle-analyzer |

### 9.6 Caching

Para Fase A, cache simple en el servicio:

```typescript
// Cachear lista de proyectos por 30s (evitar re-fetch en back navigation)
private projectsCache = { data: null as Project[] | null, timestamp: 0 };
private CACHE_TTL = 30_000; // 30 seconds

getProjects(): Observable<Project[]> {
  if (this.projectsCache.data && Date.now() - this.projectsCache.timestamp < this.CACHE_TTL) {
    return of(this.projectsCache.data);
  }
  return this.http.get<Project[]>(`${this.baseUrl}/api/projects`).pipe(
    tap(data => { this.projectsCache = { data, timestamp: Date.now() }; })
  );
}
```

---

## 10. Testing Strategy

### 10.1 Que Testear

| Capa | Que | Como | Prioridad |
|------|-----|------|-----------|
| Services | HTTP calls, transformaciones, cache | `HttpClientTestingModule`, mock responses | ALTA |
| Interceptors | Error handling, transformacion de errores | `HttpClientTestingModule` | ALTA |
| Smart components | Inicializacion, llamadas a service, navegacion | `TestBed`, mock services | MEDIA |
| Presentational components | Renderizado con inputs, emision de outputs | Shallow render, no mock services | MEDIA |
| Pipes | Transformaciones | Unit test puro (no TestBed) | BAJA |
| Computed signals | Logica de filtrado/agregacion | Unit test puro | ALTA |

### 10.2 Tools

| Tool | Uso |
|------|-----|
| Jasmine + Karma | Unit tests (default Angular CLI) |
| HttpClientTestingModule | Mock HTTP en tests de servicios |
| ComponentFixture | Render + interact con componentes |
| Playwright (Fase A final) | E2E: flujo completo dashboard -> detalle |

### 10.3 Coverage Targets

| Metrica | Target Fase A |
|---------|--------------|
| Statements | > 70% |
| Branches | > 60% |
| Services | > 90% |
| Pipes | 100% |
| Presentational components | > 60% |
| Smart components | > 50% |

### 10.4 Test Files

Cada archivo `.ts` que tenga logica tiene un `.spec.ts` adyacente:

```
project-admin.service.ts
project-admin.service.spec.ts

dashboard.component.ts
dashboard.component.spec.ts

relative-time.pipe.ts
relative-time.pipe.spec.ts
```

### 10.5 E2E (Fase A final)

Un E2E test basico con Playwright:

1. Navegar a /dashboard
2. Verificar que se cargan project cards
3. Usar filtro de clasificador
4. Verificar que cards se filtran
5. Click en un card
6. Verificar que se navega a /projects/:id con datos correctos
7. Click en "Back"
8. Verificar retorno a dashboard

---

## 11. Architecture Decision Records (ADRs)

### ADR-001: Standalone Components (sin NgModules)

**Status:** ACEPTADO
**Contexto:** Angular 17+ ofrece standalone components como alternativa a NgModules. El proyecto es nuevo sin legacy code.
**Decision:** Usar standalone components exclusivamente. No crear NgModules.
**Consecuencias:**
- (+) Menos boilerplate, cada componente declara sus imports explicitamente
- (+) Tree-shaking mas efectivo
- (+) Alineado con la direccion futura de Angular
- (-) Algunos tutoriales/ejemplos aun usan NgModules (menor impacto)

### ADR-002: Signals para State Management en Fase A

**Status:** ACEPTADO
**Contexto:** La decision de negocio difiere NgRx a Fase B. Fase A tiene estado simple (lista de proyectos, filtros, detalle).
**Decision:** Usar Angular Signals para estado local en page components. No hay store global. Si en Fase B se necesita estado compartido complejo, migrar a NgRx usando patron de fachada (ver seccion 3.2).
**Consecuencias:**
- (+) Zero boilerplate: no actions, no reducers, no effects
- (+) Reactivo y tipado nativamente
- (+) Migration path clara a NgRx via facade pattern
- (-) Sin replay de acciones, sin devtools de NgRx (aceptable para Fase A)

### ADR-003: PrimeNG como UI Library

**Status:** ACEPTADO
**Contexto:** Evaluacion de Angular Material vs PrimeNG vs Taiga UI. Decision de negocio: PrimeNG.
**Decision:** Usar PrimeNG para todos los componentes de UI.
**Justificacion tecnica:**
- p-table tiene sorting, paginacion, filtros built-in (reduce codigo custom)
- p-card, p-tag, p-chip cubren el dashboard sin componentes custom
- Theme system permite cambiar look completo sin tocar componentes
- Bundle size manejable con imports selectivos por componente
**Consecuencias:**
- (+) Desarrollo mas rapido para tablas y formularios
- (+) Consistencia visual automatica
- (-) Dependencia de una libreria third-party (mitigado: PrimeNG es activamente mantenido)

### ADR-004: No SSR

**Status:** ACEPTADO
**Contexto:** Dashboard interno accedido desde localhost. No requiere SEO ni server-side rendering.
**Decision:** No implementar SSR (Angular Universal / SSR). SPA pura servida por Nginx.
**Consecuencias:**
- (+) Setup mas simple
- (+) No necesita Node.js server para servir la app
- (-) First paint depende de JS download (mitigado: bundle pequeno, localhost)

### ADR-005: No Auth en Fase A

**Status:** ACEPTADO
**Contexto:** El dashboard corre en localhost para un solo developer.
**Decision:** No implementar autenticacion en Fase A. Cuando haya acceso remoto, agregar auth via interceptor + guard.
**Preparacion:** El `error.interceptor` ya maneja 401/403 para facilitar la adicion futura.

### ADR-006: Functional Interceptors (no class-based)

**Status:** ACEPTADO
**Contexto:** Angular 15+ recomienda functional interceptors con `withInterceptors()`.
**Decision:** Usar functional interceptors en lugar de class-based.
**Consecuencias:**
- (+) Menos boilerplate, alineado con Angular moderno
- (+) Mas facil de testear (funciones puras)
- (-) Patron menos familiar para developers acostumbrados a class-based (bajo impacto)

### ADR-007: Feature-scoped Sub-components

**Status:** ACEPTADO
**Contexto:** Componentes como ProjectCardComponent o EcosystemSummaryComponent son especificos del dashboard feature.
**Decision:** Los sub-components de un feature viven dentro de `features/[feature]/components/`. Solo se mueven a `shared/` cuando se usan en 2+ features.
**Consecuencias:**
- (+) Colocation: componentes cerca de donde se usan
- (+) Evita shared/ inflado con componentes que solo usa un feature
- (-) Requiere mover archivos si un componente se vuelve compartido (bajo costo)

### ADR-008: CSS Grid para Layout, PrimeNG para Components

**Status:** ACEPTADO
**Contexto:** PrimeNG tiene su propio grid system (PrimeFlex) pero CSS Grid nativo es suficiente y no agrega dependencias.
**Decision:** Usar CSS Grid nativo para layout del shell y grids de cards. Usar PrimeNG solo para componentes de UI (tablas, cards, inputs, etc.). No instalar PrimeFlex.
**Consecuencias:**
- (+) Una dependencia menos
- (+) CSS Grid es mas potente y flexible
- (-) No hay utility classes de PrimeFlex (mitigado: escribir SCSS propio, es minimo)

---

## Apendice A: Environment Configuration

```typescript
// environments/environment.ts
export const environment = {
  production: false,
  projectAdminUrl: 'http://localhost:3000',
  orchestratorWsUrl: 'ws://localhost:8765', // Fase C
  cacheTtlMs: 30_000
};

// environments/environment.prod.ts
export const environment = {
  production: true,
  projectAdminUrl: 'https://admin.local',
  orchestratorWsUrl: 'wss://orchestrator.local',
  cacheTtlMs: 300_000
};
```

---

## Apendice B: Fase B y C - Notas de Arquitectura

### Fase B (Sprint Tracking)

- Nuevos modelos: `Sprint`, `Story`, `SprintBoard`, `BurndownData`, `VelocityData`
- Nuevo servicio o extension de `ProjectAdminService` con metodos de sprint
- ngx-charts para burndown y velocity (lazy loaded con el feature)
- Sprint board: lista simple con columnas por estado (NO kanban drag-drop)
- Evaluar si signals siguen siendo suficientes o migrar a NgRx

### Fase C (Sessions)

- `WebSocketService` usando `rxjs/webSocket`
- Modelo: `Session`, `SessionMetrics`
- Reconexion automatica con backoff exponencial
- Solo lista de sesiones + metricas basicas (NO streaming live de mensajes)
- Estado de sesiones en signals (o NgRx si ya se migro en Fase B)

---

## Apendice C: Diagrama de Dependencias (Fase A)

```
app.config.ts
  ├── provideRouter(routes)
  ├── provideHttpClient(withInterceptors([errorInterceptor]))
  └── provideAnimationsAsync() + providePrimeNG()

AppComponent
  ├── SidebarComponent (PrimeNG Menu)
  ├── ToolbarComponent (PrimeNG Breadcrumb, InputText, SelectButton, Dropdown)
  └── <router-outlet>
        ├── DashboardComponent
        │     ├── ProjectAdminService (injected)
        │     ├── EcosystemSummaryComponent
        │     ├── ProjectCardListComponent
        │     │     └── ProjectCardComponent (PrimeNG Card, Tag, Chip)
        │     └── ProjectTableComponent (PrimeNG Table)
        │
        └── ProjectDetailComponent
              ├── ProjectAdminService (injected)
              ├── ProjectHeaderComponent (PrimeNG Tag, Chip)
              ├── ProjectMetadataComponent (PrimeNG Panel)
              └── ProjectDependenciesComponent (PrimeNG Table)
```

---

**Version:** 1.0 | **Ultima actualizacion:** 2026-02-14
**Proximo paso:** Product Owner crea backlog de Fase A basado en esta arquitectura.
