# Sprint Backlog Manager - Integracion al Ecosistema Project Admin

**Version:** 1.0
**Fecha:** 2026-02-12
**Estado:** PLANIFICADO

---

## Estado Actual

| Aspecto | Detalle |
|---------|---------|
| **Path** | `C:/mcp/sprint-backlog-manager` |
| **Contexto** | `C:/claude_context/mcp/sprint-backlog-manager/` |
| **Stack** | Node.js 20+, PostgreSQL 16, @modelcontextprotocol/sdk, Commander.js, pg |
| **Status** | Funcional (25 tools + 4 resources operativos) |
| **Interfaz primaria** | MCP Server (stdio) con 25 tools |
| **Interfaz secundaria** | CLI con Commander.js (pendiente) |

### Funcionalidad Existente

**MCP Tools (25 operativos):**
- Proyectos: `list_projects`, `get_project`, `create_project`
- Stories: `list_stories`, `get_story`, `create_story`, `update_story`, `delete_story`, `move_story`
- Sprints: `list_sprints`, `get_sprint`, `create_sprint`, `get_sprint_board`, `get_burndown`
- Epics: `list_epics`, `get_epic`, `create_epic`, `update_epic`
- Technical Debt: `list_debt`, `create_debt`, `update_debt`
- Metricas: `get_velocity`, `get_capacity`, `archive_completed`

**MCP Resources (4 operativos):**
- `project:///{id}/summary`, `project:///{id}/board`, `project:///{id}/backlog`, `project:///{id}/metrics`

**Infraestructura:** PostgreSQL 16 en Docker (WSL2), puerto 5432, 7 tablas + indices.

### Conexiones Actuales

| Cliente | Protocolo | Proposito |
|---------|-----------|-----------|
| Claude Code | MCP (stdio) | CRUD de backlog, sprints, stories, metricas |

---

## Rol en el Ecosistema

El Sprint Backlog Manager es la **fuente de verdad para datos de sprint y backlog** del ecosistema.

### Que Provee al Ecosistema

- **Datos de sprint:** Sprint activo, board kanban, burndown chart data
- **Datos de backlog:** Stories con AC, prioridad, puntos, estado
- **Metricas:** Velocity historica, capacity planning, trend analysis
- **Technical debt:** Items con ROI calculado, severity
- **Datos de proyecto:** Configuracion, prefixes, resumen ejecutivo

### Que Consume del Ecosistema

| Fuente | Datos | Uso |
|--------|-------|-----|
| **Project Admin Backend** | Registro centralizado de proyectos | Sincronizar lista de proyectos |
| **Claude Orchestrator** (via Project Admin) | Eventos de sesion completada | Actualizar estado de stories vinculadas |
| **GitHub API** (directo, pendiente) | Issues, PRs, projects | Sincronizacion bidireccional stories <-> Issues |

---

## Puntos de Integracion

### 1. REST API - Para Project Admin Backend (NUEVO)

```
Project Admin Backend --> Sprint Backlog Manager REST API

GET  /api/projects                         --> Todos los proyectos
GET  /api/projects/:prefix                 --> Proyecto por prefix
GET  /api/projects/:prefix/sprint/active   --> Sprint activo con board
GET  /api/projects/:prefix/sprint/active/board    --> Kanban board
GET  /api/projects/:prefix/sprint/active/burndown --> Burndown data
GET  /api/projects/:prefix/backlog         --> Backlog index
GET  /api/projects/:prefix/stories         --> Stories con filtros
GET  /api/projects/:prefix/metrics         --> Velocity, capacity
GET  /api/projects/:prefix/debt            --> Technical debt items
GET  /api/health                           --> Health check
```

### 2. Event Notifications - Hacia Project Admin (NUEVO)

| Evento | Payload | Trigger |
|--------|---------|---------|
| `story.status_changed` | `{ storyId, projectPrefix, oldStatus, newStatus, points }` | `move_story` o `update_story` |
| `sprint.completed` | `{ sprintId, projectPrefix, metrics }` | Sprint cerrado o ultimo story done |
| `sprint.started` | `{ sprintId, projectPrefix, capacity, committedPoints }` | Sprint pasa a active |
| `debt.critical_detected` | `{ debtId, projectPrefix, title, roi }` | TD con ROI > 10x |
| `story.created` | `{ storyId, projectPrefix, title, points }` | Nuevo story creado |

Implementacion: HTTP webhooks a Project Admin con retry logic.

### 3. GitHub Sync Module (PENDIENTE)

Migracion del modulo `github-sync` del Sprint Tracker original. Ver `GITHUB_SYNC_MIGRATION_DECISION.md` para detalle completo.

Funcionalidad a migrar:
- Push stories a GitHub Issues
- Pull cambios de GitHub Issues
- Link tasks con issues (campos `github_issue` y `github_url` ya existen en schema)
- Integracion con GitHub Projects

### 4. Vinculacion Story-Sesion (NUEVO)

Orchestrator informa que una sesion esta trabajando en una story. Al completar, Project Admin notifica al Sprint Backlog Manager para actualizar estado.

---

## Features de Integracion

### Feature 1: REST API Layer (Alta)
Express.js routes que invocan el Service Layer existente. Logica compartida entre MCP tools y REST API.

```
REST Route --> Service Layer --> Repository Layer --> PostgreSQL
MCP Tool   --> Service Layer --> Repository Layer --> PostgreSQL
```

### Feature 2: Webhook Emitter (Media)
Hook en Service Layer que emite evento post-operacion. EventEmitter interno + webhook client con retry y dead-letter.

### Feature 3: GitHub Sync Migration (Media)
Migrar github-sync del Sprint Tracker. Nuevos MCP tools: `sync_to_github`, `sync_from_github`, `link_story_to_issue`, `get_github_sync_status`.

### Feature 4: Project Sync con Project Admin (Alta)
Sincronizar lista de proyectos. Recomendacion: Sprint Backlog Manager como fuente de verdad de proyectos existentes, Project Admin agrega metadata de ecosistema.

### Feature 5: Tests - Deuda Tecnica (Alta)
Completar Fase 8 (tests) pendiente. Prerequisito para integracion estable.

---

## Fase de Activacion

**Desarrollo independiente continua. Integracion activa en Fase 2 del ecosistema.**

### Cronograma Estimado

| Etapa | Descripcion | Estimacion |
|-------|-------------|------------|
| E0 | Tests Jest para Services y MCP tools (deuda tecnica) | 1-2 sprints |
| E1 | REST API layer (Express + routes + auth) | 1 sprint |
| E2 | Webhook emitter | 0.5 sprint |
| E3 | Project sync con Project Admin | 0.5 sprint |
| E4 | GitHub sync migration | 1-2 sprints |
| E5 | Testing de integracion E2E | 0.5 sprint |

**Total estimado:** 4-6 sprints. E0 puede ejecutarse inmediatamente.

---

## Equipo de Trabajo

### Node.js Backend Developer (Lead)

- **Agente:** `nodejs-backend-developer`
- **Funciones:**
  - Implementar REST API layer reutilizando Service Layer existente
  - Implementar webhook emitter para notificaciones a Project Admin
  - Migrar modulo github-sync del Sprint Tracker original
  - Crear endpoints de health check
  - Implementar sincronizacion de proyectos con Project Admin
- **Tareas clave:**
  1. Crear `src/api/server.js` - Express app con middleware
  2. Crear routes REST para projects, stories, sprints, metrics, debt
  3. Crear `src/events/emitter.js` - EventEmitter post-operacion
  4. Crear `src/webhooks/project-admin-client.js` - Webhook client con retry
  5. Migrar github-sync: `src/services/github-sync-service.js`
  6. Crear MCP tools para github-sync: `src/mcp/tools/github.js`
- **Entregables:**
  - `src/api/` - REST API completa
  - `src/events/` - Sistema de eventos
  - `src/webhooks/` - Webhook clients
  - `src/services/github-sync-service.js`
  - `src/mcp/tools/github.js`
- **Dependencias:** API contracts del software-architect. Para github-sync, revisar `C:/mcp/sprint-tracker/src/github-sync.js`.

### Database Expert

- **Agente:** `database-expert`
- **Funciones:**
  - Optimizar queries para endpoints REST (metricas, board)
  - Crear migraciones SQL para campos de integracion
  - Disenar indices para queries de alta frecuencia
  - Configurar connection pooling para REST + MCP concurrente
  - Evaluar materialized views para metricas
- **Tareas clave:**
  1. Analizar queries existentes y agregar indices faltantes
  2. Crear migracion `002_ecosystem_fields.sql`
  3. Crear tabla `event_log` para audit trail
  4. Optimizar `get_sprint_board` y `get_burndown`
  5. Configurar pg pool para concurrencia
  6. Migracion para campos github-sync en projects
- **Entregables:**
  - Migraciones SQL
  - Documento de performance con indices recomendados
  - Pool config optimizada
- **Dependencias:** Definicion de features por software-architect.

### MCP Server Developer

- **Agente:** `mcp-server-developer`
- **Funciones:**
  - Crear MCP tools para github-sync
  - Actualizar tools existentes si cambian schemas
  - Asegurar que MCP tools y REST API usan el mismo Service Layer
- **Tareas clave:**
  1. Crear `sync_to_github` tool
  2. Crear `sync_from_github` tool
  3. Crear `link_story_to_issue` tool
  4. Crear `get_github_sync_status` tool
  5. Actualizar `create_project` tool con campos GitHub
- **Dependencias:** `github-sync-service.js` (nodejs-backend-developer).

### Test Engineer

- **Agente:** `test-engineer`
- **Funciones:**
  - Completar tests pendientes de Fase 8 (deuda tecnica)
  - Unit tests para Services (8 services)
  - Integration tests para MCP tools (25 tools)
  - Integration tests para REST API
  - Tests para github-sync service y webhook emitter
- **Entregables:**
  - `tests/setup.js` - Test infrastructure
  - `tests/unit/services/` - Unit tests para services
  - `tests/integration/mcp/` - Tests para MCP tools
  - `tests/integration/api/` - Tests para REST API
  - `tests/integration/github-sync.test.js`
  - `tests/integration/webhooks.test.js`
  - Coverage report (target: >70% unit, >60% integration)
- **Dependencias:** Puede comenzar inmediatamente con E0 (tests de services existentes).

### Code Reviewer

- **Agente:** `code-reviewer`
- **Funciones:**
  - Code review riguroso pre-merge
  - Verificar que REST API no duplica logica del Service Layer
  - Verificar seguridad: SQL injection, auth bypass, credenciales
  - Validar que github-sync maneja rate limits de GitHub API
  - Revisar manejo de transacciones PostgreSQL
  - Verificar que webhooks son idempotentes
- **Entregables:**
  - Code review reports por cada PR
  - Checklist de seguridad verificado
  - Sign-off de calidad para merge
- **Dependencias:** Despues de cada feature completada y testeada.

### Software Architect

- **Agente:** `software-architect`
- **Funciones:**
  - Definir API contracts entre Sprint Backlog Manager y Project Admin Backend
  - Disenar patron de REST API layer sobre Service Layer existente
  - Definir estrategia de sincronizacion de proyectos (fuente de verdad)
  - Disenar arquitectura del github-sync module
  - Definir event schema para webhooks
  - Evaluar necesidad de caching layer (Redis)
- **Entregables:**
  - `API_CONTRACTS_SPRINT_BACKLOG.md` - OpenAPI spec
  - `EVENT_SCHEMA.md` - Schema de eventos webhook
  - `GITHUB_SYNC_DESIGN.md` - Arquitectura del modulo
  - `DATA_FLOW_ECOSYSTEM.md` - Flujo de datos en el ecosistema
  - Recomendacion de caching strategy
- **Dependencias:** Se ejecuta primero (upstream de nodejs-backend-developer).

---

## Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigacion |
|--------|-------------|---------|------------|
| REST API introduce inconsistencias con MCP tools | Media | Alto | Ambos usan el mismo Service Layer |
| GitHub API rate limits en sync intensivo | Alta | Medio | Backoff exponencial, caching |
| PostgreSQL performance con accesos concurrentes | Media | Medio | Connection pooling, indices, materialized views |
| Conflictos de sync bidireccional con GitHub | Alta | Medio | Timestamp-based conflict resolution |
| Webhook delivery failures | Media | Alto | Event queue persistente, retry con backoff |
| Migracion github-sync introduce bugs | Media | Medio | Tests exhaustivos, migracion incremental |

---

## Decisiones Abiertas

1. github-sync: modulo interno o servicio separado?
2. Fuente de verdad de proyectos: Sprint Backlog Manager o Project Admin Backend?
3. Caching: Redis para metricas frecuentes, o PostgreSQL es suficiente?
4. Event delivery: webhooks HTTP o message queue (Redis Pub/Sub)?
5. CLI (Fase 7): implementar antes o despues de integracion?

---

**Ecosistema:** Project Admin
**Fase de activacion:** Desarrollo independiente continuo; integracion en Phase 2
