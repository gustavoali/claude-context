# Project Admin - Seed Document

**Proyecto:** Project Admin
**Version:** 1.0
**Fecha:** 2026-02-12
**Ubicacion codigo:** C:/mcp/project-admin/
**Ubicacion contexto:** C:/claude_context/mcp/project-admin/

---

## 1. Vision y Objetivos

### Vision

Project Admin es el backend central del ecosistema de desarrollo. Actua como hub de administracion que registra, cataloga y conecta los 26+ proyectos de desarrollo dispersos en multiples ubicaciones del sistema de archivos (C:/agents/, C:/apps/, C:/mcp/, C:/mobile/), proporcionando un punto unico de consulta y gestion tanto para Claude Code (via MCP) como para frontends humanos (via REST API).

### Objetivos Estrategicos

1. **Registro centralizado de proyectos:** Catalogo unico con metadata enriquecida de cada proyecto (stack, estado, ubicacion, relaciones, health).
2. **Integracion sin absorcion:** Conectar servicios existentes (Sprint Backlog Manager, Claude Orchestrator) como fuentes de datos, sin duplicar ni reemplazar su funcionalidad.
3. **Acceso dual:** Exponer la misma funcionalidad via MCP tools (para Claude Code) y REST API (para Angular Dashboard y Flutter Monitor).
4. **Visibilidad transversal:** Permitir consultas cross-project: "que proyectos usan PostgreSQL?", "cuales tienen sprints activos?", "que deuda tecnica acumulada tiene el ecosistema?".
5. **Base para dashboard:** Servir como backend del Angular Web Dashboard que visualizara el estado completo del ecosistema.

### Problemas que Resuelve

| Problema actual | Solucion |
|-----------------|----------|
| 26 proyectos sin catalogo central | Registro unificado con metadata |
| No hay forma rapida de saber el estado de un proyecto | Health check + status agregado |
| Sprint Backlog Manager y Claude Orchestrator no se hablan | Project Admin como intermediario |
| Claude Code no tiene vision global del ecosistema | MCP tools para consultar/gestionar |
| No hay dashboard web para visualizar todo | REST API lista para Angular |
| github-sync vive en sprint-tracker (deprecated) | Migracion a Sprint Backlog Manager |

---

## 2. Arquitectura del Ecosistema

### Diagrama General

```
                         ┌─────────────────────────────┐
                         │   Angular Web Dashboard      │  (Fase 2+)
                         │   - Visualizacion proyectos  │
                         │   - Metricas ecosistema      │
                         │   - Gestion centralizada     │
                         └─────────────┬───────────────┘
                                       │ REST API (HTTP)
                                       │
┌──────────────────┐     ┌─────────────┴───────────────┐     ┌──────────────────────┐
│  Claude Code     │     │    PROJECT ADMIN BACKEND     │     │  Flutter Monitor     │
│  (IDE/Terminal)  │     │    (Node.js + PostgreSQL)    │     │  (Mobile App)        │
│                  │◄───►│                              │◄───►│                      │
│  - MCP Client    │ MCP │  - Project Registry          │ WS  │  - Via Claude        │
│  - Usa tools     │     │  - Metadata + State          │     │    Orchestrator      │
│    directamente  │     │  - Unified REST API          │     │  - Monitoreo real-   │
│                  │     │  - MCP Server                │     │    time sesiones     │
└──────────────────┘     │  - Integration Hub           │     └──────────────────────┘
                         └──┬──────────┬────────────┬───┘
                            │          │            │
               ┌────────────┘          │            └────────────────┐
               │                       │                             │
               ▼                       ▼                             ▼
    ┌──────────────────┐    ┌──────────────────────┐     ┌──────────────────┐
    │ Sprint Backlog   │    │  Claude Orchestrator  │     │  Git Repos       │
    │ Manager          │    │                       │     │  (filesystem)    │
    │                  │    │  - WebSocket server   │     │                  │
    │ - PostgreSQL     │    │  - Agent sessions     │     │  C:/agents/      │
    │ - Sprints        │    │  - MCP + WS APIs      │     │  C:/apps/        │
    │ - Stories        │    │  - SDK + CLI modes    │     │  C:/mcp/         │
    │ - Epics          │    │                       │     │  C:/mobile/      │
    │ - Tech Debt      │    │  Puerto: WS :8080     │     │                  │
    │ - Metricas       │    └──────────────────────┘     └──────────────────┘
    │                  │
    │ Puerto: MCP stdio│
    │ DB: PostgreSQL   │
    └──────────────────┘
```

### Flujos de Comunicacion

```
[Claude Code] ──MCP stdio──► [Project Admin] ──HTTP interno──► [Sprint Backlog Manager API*]
                                    │
                                    ├──HTTP interno──► [Claude Orchestrator REST*]
                                    │
                                    └──filesystem──► [Git repos en disco]

[Angular Dashboard] ──REST HTTP──► [Project Admin :3000]

[Flutter Monitor] ──WebSocket──► [Claude Orchestrator :8080]
                   ──REST HTTP──► [Project Admin :3000] (Fase 2+, opcional)

* Sprint Backlog Manager y Claude Orchestrator expondran REST endpoints
  adicionales para comunicacion inter-servicio (Fase 2).
  En Fase 1, Project Admin es standalone.
```

---

## 3. Fases de Implementacion

### Fase 1: Project Admin Backend Standalone

**Duracion estimada:** 2-3 sprints
**Objetivo:** Backend funcional con registro de proyectos, MCP tools y REST API.

**Scope:**
- Setup del proyecto (Node.js, PostgreSQL en Docker, estructura de carpetas)
- Modelo de datos: projects, project_metadata, project_relationships, tags
- CRUD completo de proyectos via REST API
- MCP server con tools para Claude Code
- Auto-discovery de proyectos en filesystem (scan de directorios conocidos)
- Health check basico (existe el directorio, tiene package.json/pubspec.yaml, tiene git)
- Seed data: registrar los 26 proyectos existentes
- Tests unitarios e integracion

**Entregables:**
- REST API funcional en puerto :3000
- MCP server registrado en Claude Code config
- Base de datos PostgreSQL con schema inicial
- Documentacion de API (Swagger/OpenAPI)

**NO incluye en Fase 1:**
- Comunicacion con Sprint Backlog Manager
- Comunicacion con Claude Orchestrator
- WebSocket server
- Dashboard Angular

### Fase 1b: Migracion github-sync

**Duracion estimada:** 1 sprint (en paralelo o inmediatamente despues de Fase 1)
**Objetivo:** Migrar el modulo github-sync de Sprint Tracker a Sprint Backlog Manager.

**Scope:**
- Analizar github-sync.js actual (C:/mcp/sprint-tracker/src/github-sync.js)
- Adaptar a la arquitectura de Sprint Backlog Manager (PostgreSQL, services, MCP tools)
- Crear MCP tools: `sync_to_github`, `pull_from_github`, `get_sync_status`
- Crear servicio github-sync-service.js en Sprint Backlog Manager
- Tests de integracion con GitHub API (via gh CLI)
- Documentar deprecation de Sprint Tracker

**Entregables:**
- github-sync-service.js en Sprint Backlog Manager
- MCP tools de sync en Sprint Backlog Manager
- Sprint Tracker marcado como deprecated en su README
- Migracion documentada

### Fase 2: Integracion con Servicios Existentes

**Duracion estimada:** 2-3 sprints
**Objetivo:** Conectar Project Admin con Sprint Backlog Manager y Claude Orchestrator.

**Scope:**
- Integracion con Sprint Backlog Manager:
  - Consultar sprints activos por proyecto
  - Consultar stories y su estado
  - Metricas de velocidad por proyecto
  - Tech debt agregado por proyecto
- Integracion con Claude Orchestrator:
  - Consultar sesiones activas por proyecto (via directorio de trabajo)
  - Estado de agentes trabajando en cada proyecto
  - Metricas de uso de tokens por proyecto
- API agregada: endpoint `/projects/:id/overview` con datos de todos los servicios
- WebSocket server en Project Admin para push updates al dashboard
- Cached views para reducir carga en servicios downstream

**Entregables:**
- Integration layer con Sprint Backlog Manager
- Integration layer con Claude Orchestrator
- API endpoints agregados
- WebSocket server para real-time updates

### Fase 2+: Angular Web Dashboard

**Duracion estimada:** 3-4 sprints
**Objetivo:** Dashboard web para visualizar y gestionar el ecosistema completo.

**Scope:**
- Angular 18+ con componentes standalone
- Vista de portfolio: todos los proyectos con filtros y busqueda
- Vista de proyecto individual: detalle, sprints, stories, tech debt, sesiones
- Vista de ecosistema: metricas globales, health general, dependencias
- Graficos y visualizaciones (metricas, burndown, velocity)
- Real-time updates via WebSocket
- Responsive design (uso secundario desde mobile)

**Entregables:**
- Angular Web Dashboard desplegado
- Conectado a Project Admin REST API
- Conectado a Project Admin WebSocket

---

## 4. Stack Tecnologico

### Project Admin Backend (Fase 1)

| Componente | Tecnologia | Version | Justificacion |
|------------|-----------|---------|---------------|
| Runtime | Node.js | 20+ LTS | Consistente con ecosistema existente (SBM, CO) |
| Framework HTTP | Fastify | 5.x | Mas rapido que Express, mejor schema validation, plugin system |
| Base de datos | PostgreSQL | 17 | Consistente con SBM, JSONB para metadata flexible |
| DB Driver | pg | 8.x | Driver nativo, probado en SBM |
| MCP SDK | @modelcontextprotocol/sdk | 1.x | Estandar MCP, usado en SBM y CO |
| Validation | zod | 4.x | Schema validation, consistente con SBM |
| Environment | dotenv | 16.x | Consistente con ecosistema |
| Testing | Jest | 29.x | Consistente con ecosistema |
| API Docs | @fastify/swagger | latest | Auto-generacion de OpenAPI spec |
| Container | Docker | latest | PostgreSQL en Docker (obligatorio) |
| Module System | ESM | - | import/export, consistente con Claude Orchestrator |

### Alternativas Consideradas

| Decision | Elegido | Alternativa | Razon |
|----------|---------|-------------|-------|
| HTTP Framework | Fastify | Express | Fastify tiene mejor performance, schema validation nativa, mejor TypeScript support futuro |
| HTTP Framework | Fastify | Hono | Hono es mas nuevo, menos plugins maduros para MCP ecosystem |
| Database | PostgreSQL | SQLite | PostgreSQL ya esta en uso (SBM), JSONB necesario para metadata |
| ORM | Raw pg + migrations | Prisma/Drizzle | Consistencia con SBM (raw pg), menor overhead, control total |
| Module System | ESM | CommonJS | ESM es el estandar, CO ya lo usa. SBM usa CJS pero Project Admin es nuevo |

---

## 5. Modelo de Datos

### Diagrama de Entidades

```
┌──────────────────────────────────┐
│            projects              │
├──────────────────────────────────┤
│ id              SERIAL PK        │
│ slug            VARCHAR(100) UQ   │  -- "project-admin", "sprint-backlog-manager"
│ name            VARCHAR(200)      │  -- "Project Admin"
│ description     TEXT              │
│ path            VARCHAR(500)      │  -- "C:/mcp/project-admin"
│ repo_url        VARCHAR(500)      │  -- "https://github.com/user/repo"
│ stack           JSONB             │  -- ["node", "postgresql", "mcp"]
│ status          VARCHAR(20)       │  -- active, archived, deprecated, planned
│ category        VARCHAR(50)       │  -- mcp, mobile, web, agent, tool
│ health          JSONB             │  -- { git: true, build: true, lastCommit: "..." }
│ config          JSONB             │  -- Configuracion flexible
│ created_at      TIMESTAMPTZ       │
│ updated_at      TIMESTAMPTZ       │
│ last_scanned_at TIMESTAMPTZ       │  -- Ultimo scan del filesystem
└─────────┬────────────────────────┘
          │
          │ 1:N
          ▼
┌──────────────────────────────────┐
│        project_tags              │
├──────────────────────────────────┤
│ id              SERIAL PK        │
│ project_id      INTEGER FK       │
│ tag             VARCHAR(50)       │  -- "backend", "frontend", "flutter", "mcp"
│ created_at      TIMESTAMPTZ       │
│ UNIQUE(project_id, tag)          │
└──────────────────────────────────┘

┌──────────────────────────────────┐
│     project_relationships        │
├──────────────────────────────────┤
│ id              SERIAL PK        │
│ source_id       INTEGER FK       │  -- proyecto origen
│ target_id       INTEGER FK       │  -- proyecto destino
│ relationship    VARCHAR(30)       │  -- "depends_on", "integrates_with", "replaces", "extends"
│ description     TEXT              │
│ created_at      TIMESTAMPTZ       │
│ UNIQUE(source_id, target_id, relationship) │
└──────────────────────────────────┘

┌──────────────────────────────────┐
│     project_metadata             │
├──────────────────────────────────┤
│ id              SERIAL PK        │
│ project_id      INTEGER FK       │
│ key             VARCHAR(100)      │  -- "sbm_project_id", "orchestrator_port", "docker_container"
│ value           JSONB             │  -- Valor flexible
│ source          VARCHAR(50)       │  -- "manual", "auto_scan", "sbm_sync", "git_sync"
│ created_at      TIMESTAMPTZ       │
│ updated_at      TIMESTAMPTZ       │
│ UNIQUE(project_id, key)          │
└──────────────────────────────────┘

┌──────────────────────────────────┐
│     scan_history                 │
├──────────────────────────────────┤
│ id              SERIAL PK        │
│ scan_type       VARCHAR(30)       │  -- "full", "incremental", "single_project"
│ directories     JSONB             │  -- ["C:/mcp/", "C:/apps/"]
│ projects_found  INTEGER           │
│ projects_new    INTEGER           │
│ projects_updated INTEGER          │
│ errors          JSONB             │
│ started_at      TIMESTAMPTZ       │
│ completed_at    TIMESTAMPTZ       │
└──────────────────────────────────┘
```

### Detalle de Campos Clave

**projects.stack (JSONB):**
```json
["node", "postgresql", "mcp", "express"]
```

**projects.health (JSONB):**
```json
{
  "hasGit": true,
  "hasPackageJson": true,
  "hasPubspec": false,
  "lastCommitDate": "2026-02-10T14:30:00Z",
  "lastCommitMessage": "feat: add new endpoint",
  "gitBranch": "develop",
  "nodeModulesExists": true,
  "lastScanResult": "healthy"
}
```

**projects.config (JSONB):**
```json
{
  "sbmProjectId": 3,
  "orchestratorPort": 8080,
  "dockerContainers": ["project-admin-pg"],
  "autoScan": true,
  "scanFrequency": "daily"
}
```

### Relaciones Entre Proyectos

| Relacion | Significado | Ejemplo |
|----------|-------------|---------|
| `depends_on` | Necesita al otro para funcionar | Flutter Monitor depends_on Claude Orchestrator |
| `integrates_with` | Se comunica bidireccionalmente | Project Admin integrates_with Sprint Backlog Manager |
| `replaces` | Reemplaza funcionalidad | Sprint Backlog Manager replaces Sprint Tracker |
| `extends` | Agrega funcionalidad sobre otro | Angular Dashboard extends Project Admin |

---

## 6. MCP Tools (para Claude Code)

### Tools de Fase 1

| Tool | Descripcion | Input | Output |
|------|-------------|-------|--------|
| `pa_list_projects` | Listar todos los proyectos registrados | `{ status?, category?, tag?, search? }` | Array de proyectos |
| `pa_get_project` | Obtener detalle de un proyecto | `{ slug }` o `{ id }` | Proyecto completo con metadata |
| `pa_create_project` | Registrar un proyecto nuevo | `{ slug, name, path, stack, category, ... }` | Proyecto creado |
| `pa_update_project` | Actualizar datos de un proyecto | `{ slug, ...fields }` | Proyecto actualizado |
| `pa_delete_project` | Eliminar un proyecto del registro | `{ slug, confirm: true }` | Confirmacion |
| `pa_scan_directory` | Escanear directorio y descubrir proyectos | `{ directory, recursive? }` | Proyectos encontrados |
| `pa_scan_all` | Escanear todos los directorios conocidos | `{}` | Resumen del scan |
| `pa_project_health` | Verificar health de un proyecto | `{ slug }` | Health report |
| `pa_search_projects` | Busqueda avanzada cross-project | `{ query, filters }` | Proyectos que matchean |
| `pa_add_relationship` | Agregar relacion entre proyectos | `{ source, target, type, desc? }` | Relacion creada |
| `pa_get_relationships` | Ver relaciones de un proyecto | `{ slug, direction? }` | Relaciones |
| `pa_set_metadata` | Agregar/actualizar metadata | `{ slug, key, value }` | Metadata actualizada |
| `pa_get_ecosystem_stats` | Estadisticas globales del ecosistema | `{}` | Stats agregadas |

### Tools de Fase 2 (Integracion)

| Tool | Descripcion | Input | Output |
|------|-------------|-------|--------|
| `pa_project_overview` | Vista 360 del proyecto (PA + SBM + CO) | `{ slug }` | Overview completo |
| `pa_active_sprints` | Sprints activos cross-project | `{ category? }` | Sprints de todos los proyectos |
| `pa_ecosystem_health` | Health completo del ecosistema | `{}` | Health de todos + servicios |
| `pa_active_sessions` | Sesiones de Claude activas por proyecto | `{ slug? }` | Sesiones agrupadas |

### Prefijo `pa_`

Todos los tools de Project Admin usan el prefijo `pa_` para evitar colisiones con tools de otros MCP servers (Sprint Backlog Manager usa nombres sin prefijo como `list_projects`, `create_story`).

### Ejemplo de Uso desde Claude Code

```
Usuario: "Que proyectos tengo que usen Flutter?"
Claude usa: pa_search_projects({ query: "flutter", filters: { stack: "flutter" } })

Usuario: "Registra mi nuevo proyecto en C:/apps/nuevo-app"
Claude usa: pa_scan_directory({ directory: "C:/apps/nuevo-app" })
          + pa_create_project({ slug: "nuevo-app", path: "C:/apps/nuevo-app", ... })

Usuario: "Como esta el ecosistema?"
Claude usa: pa_get_ecosystem_stats({})
```

---

## 7. REST API Endpoints

### Base URL: `http://localhost:3000/api/v1`

### Projects

| Method | Endpoint | Descripcion | Query Params |
|--------|----------|-------------|--------------|
| GET | `/projects` | Listar proyectos | `?status=active&category=mcp&tag=backend&search=sprint&page=1&limit=20` |
| GET | `/projects/:slug` | Detalle de proyecto | - |
| POST | `/projects` | Crear proyecto | - |
| PUT | `/projects/:slug` | Actualizar proyecto | - |
| DELETE | `/projects/:slug` | Eliminar proyecto | `?confirm=true` |
| GET | `/projects/:slug/health` | Health check | `?refresh=true` |
| GET | `/projects/:slug/relationships` | Relaciones | `?direction=outgoing|incoming|both` |
| GET | `/projects/:slug/metadata` | Metadata del proyecto | - |
| PUT | `/projects/:slug/metadata/:key` | Actualizar metadata | - |

### Tags

| Method | Endpoint | Descripcion |
|--------|----------|-------------|
| GET | `/tags` | Listar todos los tags usados |
| GET | `/tags/:tag/projects` | Proyectos con ese tag |
| POST | `/projects/:slug/tags` | Agregar tag a proyecto |
| DELETE | `/projects/:slug/tags/:tag` | Remover tag de proyecto |

### Relationships

| Method | Endpoint | Descripcion |
|--------|----------|-------------|
| POST | `/relationships` | Crear relacion |
| DELETE | `/relationships/:id` | Eliminar relacion |
| GET | `/relationships/graph` | Grafo de dependencias completo |

### Scan

| Method | Endpoint | Descripcion |
|--------|----------|-------------|
| POST | `/scan` | Ejecutar scan completo |
| POST | `/scan/directory` | Escanear directorio especifico |
| GET | `/scan/history` | Historial de scans |

### Ecosystem

| Method | Endpoint | Descripcion |
|--------|----------|-------------|
| GET | `/ecosystem/stats` | Estadisticas globales |
| GET | `/ecosystem/health` | Health de todo el ecosistema |

### Fase 2 Endpoints

| Method | Endpoint | Descripcion |
|--------|----------|-------------|
| GET | `/projects/:slug/overview` | Vista 360 (PA + SBM + CO) |
| GET | `/ecosystem/sprints` | Sprints activos cross-project |
| GET | `/ecosystem/sessions` | Sesiones Claude activas |
| GET | `/ecosystem/debt` | Tech debt agregado |

### Formato de Respuesta Estandar

```json
{
  "success": true,
  "data": { ... },
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 26,
    "timestamp": "2026-02-12T10:00:00Z"
  }
}
```

```json
{
  "success": false,
  "error": {
    "code": "PROJECT_NOT_FOUND",
    "message": "Project with slug 'xyz' not found"
  }
}
```

---

## 8. Puntos de Integracion

### 8.1 Sprint Backlog Manager (Fase 2)

**Metodo de comunicacion:** HTTP REST interno (SBM necesitara exponer REST endpoints ademas de MCP).

**Alternativa para Fase 1:** Conexion directa a la base de datos PostgreSQL de SBM (read-only). Esto es mas simple pero acopla los schemas.

**Decision recomendada:** REST interno. Requiere agregar REST endpoints a SBM pero mantiene bajo acoplamiento.

**Datos a consultar:**
- Sprints activos por proyecto (via `project_id` en SBM)
- Stories y su estado agrupadas por proyecto
- Metricas de velocidad y capacity
- Technical debt summary por proyecto

**Mapping:** `projects.config.sbmProjectId` en Project Admin apunta a `projects.id` en SBM.

### 8.2 Claude Orchestrator (Fase 2)

**Metodo de comunicacion:** HTTP REST (CO ya tiene Express server) o WebSocket client.

**Datos a consultar:**
- Sesiones activas y su `cwd` (para mapear a proyecto)
- Token usage por sesion/proyecto
- Estado de agentes

**Mapping:** Se matchea `session.cwd` con `projects.path` en Project Admin.

### 8.3 Git Repos - Filesystem (Fase 1)

**Metodo de comunicacion:** Lectura directa del filesystem + ejecucion de `git` CLI.

**Datos a extraer por proyecto:**
- Existencia de `.git/`
- Branch actual (`git rev-parse --abbrev-ref HEAD`)
- Ultimo commit (`git log -1 --format="%H|%s|%ai"`)
- Estado del working tree (`git status --porcelain`)
- Remote URL (`git remote get-url origin`)
- Existencia de `package.json`, `pubspec.yaml`, `.csproj`, etc.
- Stack detection por archivos presentes

**Directorios a escanear:**
```
C:/agents/       - Agentes y proyectos AI
C:/apps/         - Aplicaciones web y desktop
C:/mcp/          - MCP servers y herramientas
C:/mobile/       - Aplicaciones mobile
```

### 8.4 github-sync (Fase 1b - migra a SBM)

**Estado actual:** Vive en C:/mcp/sprint-tracker/src/github-sync.js
**Destino:** C:/mcp/sprint-backlog-manager/src/services/github-sync-service.js

**Funcionalidad a migrar:**
- `syncToGitHub()` - Crear/actualizar GitHub Issues desde stories
- `pullFromGitHub()` - Sincronizar estado de Issues a stories
- `createIssue()` - Crear issue individual
- `closeIssue()` / `reopenIssue()` - Gestionar estado
- `addToProject()` - Agregar a GitHub Project

**Adaptaciones necesarias:**
- Cambiar de JSON file storage a PostgreSQL queries
- Integrar con story-service.js existente
- Agregar MCP tools (`sync_to_github`, `pull_from_github`)
- Agregar campo `github_project_number` a projects config en SBM

---

## 9. Estructura del Proyecto

```
C:/mcp/project-admin/
├── .env.example
├── .env
├── .gitignore
├── package.json
├── README.md
├── src/
│   ├── index.js                  # Entry point MCP server
│   ├── server.js                 # Entry point REST API (Fastify)
│   ├── config.js                 # Configuracion centralizada
│   ├── db/
│   │   ├── pool.js               # PostgreSQL connection pool
│   │   ├── migrate.js            # Migration runner
│   │   └── migrations/
│   │       ├── 001_initial_schema.sql
│   │       └── ...
│   ├── services/
│   │   ├── project-service.js
│   │   ├── tag-service.js
│   │   ├── relationship-service.js
│   │   ├── metadata-service.js
│   │   ├── scan-service.js       # Filesystem scanner
│   │   └── health-service.js     # Project health checker
│   ├── repositories/
│   │   ├── project-repository.js
│   │   ├── tag-repository.js
│   │   ├── relationship-repository.js
│   │   ├── metadata-repository.js
│   │   └── scan-repository.js
│   ├── mcp/
│   │   ├── tools/
│   │   │   ├── projects.js
│   │   │   ├── scan.js
│   │   │   ├── relationships.js
│   │   │   ├── ecosystem.js
│   │   │   └── index.js          # Registra todos los tools
│   │   └── resources/
│   │       └── ...
│   ├── api/
│   │   ├── routes/
│   │   │   ├── projects.js
│   │   │   ├── tags.js
│   │   │   ├── relationships.js
│   │   │   ├── scan.js
│   │   │   ├── ecosystem.js
│   │   │   └── index.js          # Registra todas las rutas
│   │   ├── middleware/
│   │   │   ├── error-handler.js
│   │   │   ├── request-logger.js
│   │   │   └── validation.js
│   │   └── plugins/
│   │       ├── swagger.js
│   │       └── cors.js
│   └── utils/
│       ├── git-utils.js          # Helpers para git CLI
│       ├── fs-scanner.js         # Deteccion de stack por archivos
│       └── slug.js               # Generacion de slugs
├── tests/
│   ├── unit/
│   │   ├── services/
│   │   └── utils/
│   ├── integration/
│   │   ├── api/
│   │   └── mcp/
│   └── helpers/
│       ├── test-db.js
│       └── fixtures.js
└── docs/
    └── api/                      # OpenAPI spec generada
```

---

## 10. Requerimientos No Funcionales

### Performance

| Metrica | Target | Notas |
|---------|--------|-------|
| Respuesta REST API (p95) | < 200ms | Queries simples a PostgreSQL |
| Respuesta REST API con agregacion (p95) | < 500ms | Queries cross-service (Fase 2) |
| MCP tool response | < 300ms | Similar a REST pero via stdio |
| Scan completo del filesystem | < 10s | 26 proyectos, 4 directorios |
| Health check individual | < 2s | Incluye git commands |
| Concurrent REST connections | 50+ | Suficiente para dashboard + mobile |

### Escalabilidad

- **Proyectos soportados:** Hasta 200 proyectos (actual: 26, proyeccion: ~50 en 1 ano)
- **Base de datos:** PostgreSQL single instance es suficiente para este volumen
- **Caching:** In-memory cache para datos del filesystem (scan results, health) con TTL de 5 minutos
- **Connection pooling:** pg pool con 10 conexiones max (suficiente para 1 dev + dashboard)

### Seguridad

- **Network:** Solo localhost en Fase 1 (127.0.0.1). Sin autenticacion.
- **Database:** Credenciales en .env, nunca en codigo
- **Filesystem:** Read-only access al filesystem de proyectos (no modifica archivos)
- **Git:** Solo operaciones read-only (log, status, branch)
- **Fase 2+:** Agregar API key basica si se expone fuera de localhost

### Disponibilidad

- **Desarrollo local:** No hay SLA formal. Restart manual aceptable.
- **Docker restart policy:** `unless-stopped` para el container de PostgreSQL
- **Graceful shutdown:** Cerrar pool de DB y server HTTP correctamente

### Observabilidad

- **Logging:** Structured logging con niveles (info, warn, error)
- **Metricas:** Conteo de requests, latencia, errores (en log, no stack externo)
- **Health endpoint:** `GET /health` con estado de DB y servicios integrados

---

## 11. Configuracion Docker (PostgreSQL)

```bash
docker run -d \
  --name project-admin-pg \
  -p 5433:5432 \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=project_admin \
  -e POSTGRES_HOST_AUTH_METHOD=scram-sha-256 \
  -e POSTGRES_INITDB_ARGS="--auth-host=scram-sha-256" \
  -v project-admin-pgdata:/var/lib/postgresql/data \
  --restart unless-stopped \
  postgres:17
```

**Nota:** Puerto 5433 externo para evitar conflicto con el PostgreSQL de Sprint Backlog Manager (que usa 5432).

### Variables de Entorno (.env)

```bash
# Database
DATABASE_URL=postgresql://postgres:postgres@localhost:5433/project_admin
DB_HOST=localhost
DB_PORT=5433
DB_NAME=project_admin
DB_USER=postgres
DB_PASSWORD=postgres

# REST API
API_PORT=3000
API_HOST=127.0.0.1

# MCP
MCP_SERVER_NAME=project-admin
MCP_SERVER_VERSION=0.1.0

# Scan directories
SCAN_DIRECTORIES=C:/agents/,C:/apps/,C:/mcp/,C:/mobile/

# Environment
NODE_ENV=development
LOG_LEVEL=info
```

---

## 12. Seed Data: Proyectos Conocidos

Inventario inicial de los proyectos a registrar en Fase 1:

| # | Slug | Path | Category | Stack |
|---|------|------|----------|-------|
| 1 | sprint-backlog-manager | C:/mcp/sprint-backlog-manager | mcp | node, postgresql, mcp |
| 2 | claude-orchestrator | C:/mcp/claude-orchestrator | mcp | node, mcp, websocket, express |
| 3 | sprint-tracker | C:/mcp/sprint-tracker | mcp | node, cli (deprecated) |
| 4 | youtube-mcp | C:/mcp/youtube | mcp | (por determinar) |
| 5 | linkedin-mcp | C:/mcp/linkedin | mcp | (por determinar) |
| 6 | claude-code-monitor-flutter | C:/apps/claude-code-monitor/... | mobile | flutter, dart |
| 7 | mew-michis | C:/apps/mew-michis | web | (por determinar) |
| 8 | sudoku | C:/apps/sudoku | web | (por determinar) |
| 9 | atlas-ops | C:/agents/atlasOps | agent | (por determinar) |
| 10 | linkedin-rag-agent | C:/agents/linkedin_rag_agent | agent | (por determinar) |
| 11 | tensor-lake-ai | C:/agents/tensor_lake_ai | agent | (por determinar) |
| 12 | youtube-rag-mvp | C:/agents/youtube_rag_mvp | agent | (por determinar) |
| 13 | youtube-rag-net | C:/agents/youtube_rag_net | agent | dotnet |
| 14 | youtube-jupyter | C:/agents/youtube_jupyter | agent | python, jupyter |
| 15 | agenda | C:/mobile/agenda | mobile | (por determinar) |
| 16 | chemical | C:/mobile/chemical | mobile | (por determinar) |
| 17 | recetario | C:/mobile/recetario | mobile | (por determinar) |
| 18 | spoti-admin | C:/mobile/spoti-admin | mobile | (por determinar) |
| 19 | tracking-app | C:/mobile/tracking_app | mobile | (por determinar) |
| 20-26 | linkedin-worktrees, etc. | C:/mcp/linkedin-* | mcp | worktrees |

**Nota:** Los "(por determinar)" se resolveran automaticamente via auto-scan del filesystem, que detectara stack por presencia de archivos (package.json, pubspec.yaml, .csproj, requirements.txt, etc.).

---

## 13. Convenciones de Codigo

- **Idioma del codigo:** Ingles (variables, funciones, comentarios)
- **Idioma de la documentacion:** Espanol (Argentina)
- **Module system:** ESM (import/export)
- **Naming:** camelCase para variables/funciones, PascalCase para clases, kebab-case para archivos
- **Async:** async/await (no callbacks, no .then chains)
- **Error handling:** Try/catch con errores tipados, nunca swallow errors silenciosamente
- **Linting:** ESLint (configurar en Fase 1)
- **Formato de commit:** Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`)

---

## 14. Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigacion |
|--------|-------------|---------|------------|
| Conflicto de puertos PostgreSQL (5432 ocupado por SBM) | Alta | Medio | Usar puerto 5433 para Project Admin |
| Schema drift entre Project Admin y SBM | Media | Alto | Fase 2: REST API en vez de acceso directo a DB |
| Auto-scan detecta proyectos incorrectamente | Media | Bajo | Confirmacion manual, flag `autoScan: false` |
| Fastify learning curve (equipo conoce Express) | Baja | Bajo | API surface es similar, documentacion excelente |
| github-sync migracion rompe workflow actual | Media | Medio | Migrar como modulo adicional, mantener Sprint Tracker funcional hasta verificar |
| Performance de git commands en Windows | Media | Bajo | Cache results, no ejecutar en cada request |

---

## 15. Preguntas Abiertas

1. **Puerto REST API:** Se propone 3000. Verificar que no este en uso por otro proyecto.
2. **Autenticacion Angular Dashboard:** En Fase 2+, el dashboard necesita auth? O es solo local?
3. **Sprint Backlog Manager REST:** Existe plan de exponer REST API en SBM o hay que desarrollarlo?
4. **Worktrees de LinkedIn:** Los worktrees (linkedin-LTE-001, etc.) se registran como proyectos separados o como ramas del proyecto principal?
5. **Frecuencia de auto-scan:** On-demand (Fase 1) o scheduled (cron-like)?
6. **Angular vs React:** Se confirma Angular para el dashboard? Flutter Web tambien es opcion.

---

## 16. Definition of Done - Fase 1

- [ ] PostgreSQL corriendo en Docker (puerto 5433)
- [ ] Schema inicial migrado
- [ ] CRUD completo de proyectos (REST API + MCP tools)
- [ ] Auto-scan de directorios funcional
- [ ] Health check de proyectos funcional
- [ ] Tags y relaciones entre proyectos
- [ ] Metadata extensible por proyecto
- [ ] Todos los 26 proyectos registrados como seed data
- [ ] Tests unitarios >70% coverage en services
- [ ] Tests de integracion para API endpoints
- [ ] Tests de integracion para MCP tools
- [ ] Swagger/OpenAPI spec generada
- [ ] README con instrucciones de setup
- [ ] Build con 0 errores, 0 warnings
- [ ] Code review aprobado

---

**Documento creado:** 2026-02-12
**Proximo paso:** Disenar equipos de planificacion y desarrollo (TEAM_PLANNING.md, TEAM_DEVELOPMENT.md)
