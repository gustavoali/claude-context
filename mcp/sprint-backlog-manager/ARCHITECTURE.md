# Sprint Backlog Manager - Architecture

**Version:** 1.0
**Fecha:** 2026-02-05
**Estado:** DRAFT

---

## Vision General

```
                    Claude Code
                        |
                   (stdio MCP)
                        |
              +---------+---------+
              |  MCP Server Layer |
              |  (tools + resources)|
              +---------+---------+
                        |
              +---------+---------+
              |  Service Layer    |
              |  (business logic) |
              +---------+---------+
                        |
              +---------+---------+
              |  Repository Layer |
              |  (data access)    |
              +---------+---------+
                        |
              +---------+---------+
              |   PostgreSQL 16   |
              |  sprint_backlog   |
              +-------------------+

              CLI (secundario, usa Service Layer)
```

---

## Capas

### 1. MCP Server Layer (`src/mcp/`)

Expone herramientas (tools) y recursos (resources) via protocolo MCP stdio.

**Tools (operaciones):**

| Tool | Params | Descripcion |
|------|--------|-------------|
| `list_projects` | - | Listar todos los proyectos |
| `get_project` | project_id | Detalle de un proyecto |
| `create_project` | name, prefix, description | Crear proyecto nuevo |
| `list_stories` | project_id, ?status, ?sprint_id, ?epic_id, ?priority | Listar stories con filtros |
| `get_story` | story_id | Detalle completo de una story |
| `create_story` | project_id, title, ?epic_id, ?type, ?priority, ?points, ?sprint_id, ?acceptance_criteria[], ?description | Crear story |
| `update_story` | story_id, fields... | Actualizar campos de story |
| `delete_story` | story_id | Eliminar story |
| `move_story` | story_id, new_status | Mover story en el board |
| `list_sprints` | project_id, ?status | Listar sprints |
| `get_sprint` | sprint_id | Detalle del sprint |
| `create_sprint` | project_id, number, start_date, end_date, ?capacity_hours | Crear sprint |
| `get_sprint_board` | sprint_id | Vista kanban del sprint |
| `list_epics` | project_id, ?status | Listar epics |
| `get_epic` | epic_id | Detalle del epic con stories |
| `create_epic` | project_id, name, ?description | Crear epic |
| `update_epic` | epic_id, fields... | Actualizar epic |
| `list_debt` | project_id, ?status, ?min_roi | Listar technical debt |
| `create_debt` | project_id, title, severity, interest_rate, fix_cost, ?description | Crear TD item |
| `update_debt` | debt_id, fields... | Actualizar TD item |
| `get_velocity` | project_id, ?last_n_sprints | Metricas de velocity |
| `get_capacity` | sprint_id | Capacity planning del sprint |
| `archive_completed` | project_id, ?before_date | Archivar stories completadas |
| `create_github_issue` | story_id, ?repo | Create GitHub issue from story |
| `link_github_issue` | story_id, issue_number, ?repo | Link existing issue to story |
| `sync_to_github` | project_id, ?sprint_id, ?status, ?repo | Bulk sync stories to GitHub |
| `pull_from_github` | project_id, ?repo | Pull issue state from GitHub |

**Resources (lecturas de contexto):**

| URI | Descripcion |
|-----|-------------|
| `project:///{id}/summary` | Resumen del proyecto |
| `project:///{id}/board` | Board del sprint actual |
| `project:///{id}/backlog` | Indice del backlog |
| `project:///{id}/metrics` | Metricas consolidadas |

### 2. Service Layer (`src/services/`)

Logica de negocio pura, independiente de MCP y de persistencia.

| Service | Responsabilidad |
|---------|----------------|
| `ProjectService` | CRUD proyectos, configuracion |
| `StoryService` | CRUD stories, transiciones de estado, validacion AC |
| `SprintService` | CRUD sprints, asignacion, board view, burndown |
| `EpicService` | CRUD epics, metricas de completitud |
| `DebtService` | CRUD debt, calculo ROI automatico, decision rules |
| `MetricsService` | Velocity, capacity, burndown, leading indicators |
| `ArchiveService` | Archivar stories completadas, cleanup |
| `IdRegistryService` | Generacion secuencial de IDs por proyecto (PREFIX-NNN) |
| `GitHubService` | GitHub issue creation, linking, sync via gh CLI |

### 3. Repository Layer (`src/repositories/`)

Acceso a datos via pg driver. Cada repo encapsula queries SQL.

| Repository | Tabla principal |
|------------|----------------|
| `ProjectRepository` | projects |
| `StoryRepository` | stories |
| `SprintRepository` | sprints |
| `EpicRepository` | epics |
| `DebtRepository` | technical_debt |
| `MetricsRepository` | (queries agregadas sobre stories/sprints) |

### 4. Database (`src/db/`)

PostgreSQL con migraciones SQL manuales versionadas.

---

## Schema de Base de Datos

### Tabla: projects
```sql
CREATE TABLE projects (
    id              SERIAL PRIMARY KEY,
    name            VARCHAR(200) NOT NULL,
    prefix          VARCHAR(10) NOT NULL UNIQUE,
    description     TEXT,
    config          JSONB DEFAULT '{}',
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);
```

### Tabla: sprints
```sql
CREATE TABLE sprints (
    id              SERIAL PRIMARY KEY,
    project_id      INTEGER NOT NULL REFERENCES projects(id),
    number          INTEGER NOT NULL,
    start_date      DATE NOT NULL,
    end_date        DATE NOT NULL,
    capacity_hours  DECIMAL(6,1),
    committed_hours DECIMAL(6,1),
    buffer_hours    DECIMAL(6,1),
    status          VARCHAR(20) DEFAULT 'planned',
    goal            TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(project_id, number)
);
-- status: planned, active, completed
```

### Tabla: epics
```sql
CREATE TABLE epics (
    id              SERIAL PRIMARY KEY,
    project_id      INTEGER NOT NULL REFERENCES projects(id),
    name            VARCHAR(300) NOT NULL,
    description     TEXT,
    status          VARCHAR(20) DEFAULT 'active',
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);
-- status: active, completed, cancelled
```

### Tabla: stories
```sql
CREATE TABLE stories (
    id              SERIAL PRIMARY KEY,
    project_id      INTEGER NOT NULL REFERENCES projects(id),
    epic_id         INTEGER REFERENCES epics(id),
    sprint_id       INTEGER REFERENCES sprints(id),
    external_id     VARCHAR(20) NOT NULL,
    title           VARCHAR(500) NOT NULL,
    description     TEXT,
    user_story      TEXT,
    type            VARCHAR(20) DEFAULT 'feature',
    status          VARCHAR(20) DEFAULT 'backlog',
    priority        VARCHAR(20) DEFAULT 'medium',
    points          INTEGER DEFAULT 0,
    owner           VARCHAR(100),
    branch          VARCHAR(200),
    acceptance_criteria JSONB DEFAULT '[]',
    technical_notes TEXT,
    github_issue    INTEGER,
    github_url      VARCHAR(500),
    archived        BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW(),
    completed_at    TIMESTAMPTZ,
    UNIQUE(project_id, external_id)
);
-- type: feature, bug, refactor, docs, test, chore, spike
-- status: backlog, ready, in_progress, review, done, blocked
-- priority: critical, high, medium, low
```

### Tabla: technical_debt
```sql
CREATE TABLE technical_debt (
    id              SERIAL PRIMARY KEY,
    project_id      INTEGER NOT NULL REFERENCES projects(id),
    external_id     VARCHAR(20) NOT NULL,
    title           VARCHAR(500) NOT NULL,
    description     TEXT,
    location        VARCHAR(500),
    severity        VARCHAR(20) DEFAULT 'medium',
    interest_rate   DECIMAL(6,1),
    fix_cost        DECIMAL(6,1),
    roi             DECIMAL(8,2) GENERATED ALWAYS AS (
                        CASE WHEN fix_cost > 0 THEN (interest_rate * 20) / fix_cost ELSE 0 END
                    ) STORED,
    status          VARCHAR(20) DEFAULT 'open',
    linked_story_id INTEGER REFERENCES stories(id),
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW(),
    resolved_at     TIMESTAMPTZ,
    UNIQUE(project_id, external_id)
);
-- severity: critical, high, medium, low
-- status: open, planned, in_progress, closed
```

### Tabla: id_registry
```sql
CREATE TABLE id_registry (
    id              SERIAL PRIMARY KEY,
    project_id      INTEGER NOT NULL REFERENCES projects(id),
    entity_type     VARCHAR(20) NOT NULL,
    last_number     INTEGER DEFAULT 0,
    UNIQUE(project_id, entity_type)
);
-- entity_type: story, debt
```

### Indices
```sql
CREATE INDEX idx_stories_project_status ON stories(project_id, status) WHERE NOT archived;
CREATE INDEX idx_stories_sprint ON stories(sprint_id) WHERE sprint_id IS NOT NULL;
CREATE INDEX idx_stories_epic ON stories(epic_id) WHERE epic_id IS NOT NULL;
CREATE INDEX idx_stories_external ON stories(external_id);
CREATE INDEX idx_debt_project_status ON technical_debt(project_id, status);
CREATE INDEX idx_sprints_project ON sprints(project_id);
CREATE INDEX idx_epics_project ON epics(project_id);
```

---

## Estructura de Carpetas del Proyecto

```
C:/mcp/sprint-backlog-manager/
|-- package.json
|-- .env.example
|-- .gitignore
|-- README.md
|-- src/
|   |-- index.js              # Entry point MCP server (stdio)
|   |-- cli.js                # Entry point CLI (secundario)
|   |-- config.js             # Config loader (env vars, defaults)
|   |-- db/
|   |   |-- pool.js           # PostgreSQL connection pool
|   |   |-- migrate.js        # Migration runner
|   |   |-- migrations/
|   |       |-- 001_initial_schema.sql
|   |       |-- 002_seed_data.sql (opcional)
|   |-- mcp/
|   |   |-- server.js          # MCP server setup + tool registration
|   |   |-- tools/
|   |   |   |-- projects.js    # Project tools
|   |   |   |-- stories.js     # Story tools
|   |   |   |-- sprints.js     # Sprint tools
|   |   |   |-- epics.js       # Epic tools
|   |   |   |-- debt.js        # Technical debt tools
|   |   |   |-- metrics.js     # Metrics tools
|   |   |   |-- github.js      # GitHub sync tools
|   |   |-- resources/
|   |       |-- project-resources.js  # Resource handlers
|   |-- services/
|   |   |-- project-service.js
|   |   |-- story-service.js
|   |   |-- sprint-service.js
|   |   |-- epic-service.js
|   |   |-- debt-service.js
|   |   |-- metrics-service.js
|   |   |-- archive-service.js
|   |   |-- id-registry-service.js
|   |   |-- github-service.js
|   |-- repositories/
|   |   |-- project-repository.js
|   |   |-- story-repository.js
|   |   |-- sprint-repository.js
|   |   |-- epic-repository.js
|   |   |-- debt-repository.js
|   |-- utils/
|       |-- validators.js      # Input validation
|       |-- formatters.js      # Board formatting, markdown generation
|-- tests/
|   |-- services/
|   |-- repositories/
|   |-- mcp/
|-- .claude/
    |-- CLAUDE.md              # Puntero a claude_context
```

---

## Migracion desde sprint-tracker

### Datos a migrar
- `sprint-data.json` → tablas stories, sprints, technical_debt
- `.sprint-tracker.json` → tabla projects (config JSONB)

### Herramienta de migracion
Script `src/db/import-from-json.js` que:
1. Lee sprint-data.json de un path dado
2. Crea proyecto en DB con config del JSON
3. Importa tasks como stories
4. Importa technicalDebt como technical_debt
5. Crea sprint correspondiente

### CLI preservado
El CLI se mantiene como interfaz secundaria que usa el mismo Service Layer.
Comando `sprint-backlog` en lugar de `sprint` para evitar conflictos.

---

## Configuracion MCP en Claude Desktop

```json
{
  "mcpServers": {
    "sprint-backlog": {
      "command": "node",
      "args": ["C:/mcp/sprint-backlog-manager/src/index.js"],
      "env": {
        "DATABASE_URL": "postgresql://localhost:5432/sprint_backlog"
      }
    }
  }
}
```

---

## Dependencias

```json
{
  "@modelcontextprotocol/sdk": "^1.x",
  "pg": "^8.x",
  "commander": "^12.x",
  "dotenv": "^16.x"
}
```

Dev dependencies:
```json
{
  "jest": "^29.x"
}
```

---

**Version:** 1.0 | **Ultima actualizacion:** 2026-02-05
