# Project Admin - Equipo de Planificacion

**Proyecto:** Project Admin
**Version:** 1.0
**Fecha:** 2026-02-12

---

## Proposito del Equipo

El equipo de planificacion es responsable de disenar, validar y priorizar el trabajo antes de que entre en desarrollo. Se activa principalmente en las fases de discovery y planificacion, produciendo los artefactos que guian la ejecucion. Opera bajo el principio de "preparar Sprint N+1 durante Sprint N".

---

## Composicion del Equipo

### 1. Lead Architect

| Campo | Detalle |
|-------|---------|
| **Rol** | Lead Architect |
| **Tipo de agente** | `software-architect` |
| **Fase activa** | Todas las fases (intensidad variable) |

**Funciones y responsabilidades:**

- Definir y mantener la arquitectura del ecosistema Project Admin + servicios integrados
- Tomar decisiones de arquitectura documentadas (ADRs) para cada componente nuevo
- Disenar los puntos de integracion entre Project Admin, Sprint Backlog Manager y Claude Orchestrator
- Validar que el modelo de datos soporta los casos de uso presentes y futuros
- Evaluar trade-offs tecnologicos (Fastify vs Express, REST vs gRPC para inter-servicio, etc.)
- Definir contratos de API (REST endpoints, MCP tools, WebSocket protocol)
- Revisar que cada historia tenga un diseno tecnico viable antes de entrar en desarrollo
- Guiar decisiones de caching, connection pooling y performance

**Entregables:**

| Entregable | Fase | Descripcion |
|------------|------|-------------|
| `ARCHITECTURE.md` | Fase 1 | Documento de arquitectura del proyecto con diagramas |
| ADR-001: Fastify vs Express | Fase 1 | Justificacion de la eleccion de framework HTTP |
| ADR-002: Estrategia de integracion inter-servicio | Fase 2 | REST directo vs message queue vs DB compartida |
| ADR-003: Estrategia de caching | Fase 2 | Cache de filesystem scans y datos cross-service |
| Contratos de API (OpenAPI spec borrador) | Fase 1 | Definicion de endpoints, schemas, respuestas |
| Contratos MCP tools (spec borrador) | Fase 1 | Definicion de tools, inputs, outputs |
| Diagramas de integracion Fase 2 | Pre-Fase 2 | Como se comunican los 3 servicios |
| Review tecnico por historia | Todas | Validacion de viabilidad tecnica |

**Criterios de activacion:**

- Fase 1: Alta dedicacion. Diseno inicial de toda la arquitectura.
- Fase 1b: Consulta. Validar que la migracion de github-sync no rompe nada.
- Fase 2: Alta dedicacion. Disenar la capa de integracion.
- Fase 2+: Media dedicacion. Guiar arquitectura del Angular Dashboard.

---

### 2. Product Owner

| Campo | Detalle |
|-------|---------|
| **Rol** | Product Owner |
| **Tipo de agente** | `product-owner` |
| **Fase activa** | Pre-Fase 1, Pre-Fase 2, Pre-Fase 2+ |

**Funciones y responsabilidades:**

- Crear y mantener el Product Backlog de Project Admin
- Escribir user stories con acceptance criteria en formato Given-When-Then
- Priorizar stories usando RICE score y MoSCoW
- Gestionar el ID Registry (prefijo PA para stories, e.g., PA-001, PA-002)
- Descomponer epics en stories manejables (max 8 puntos por story)
- Validar que cada story tiene Definition of Ready Level 1 o 2 antes de entrar en sprint
- Coordinar con el Business Stakeholder para validar prioridades de negocio
- Mantener el backlog groomed: re-priorizar, archivar stories obsoletas, split stories grandes

**Entregables:**

| Entregable | Fase | Descripcion |
|------------|------|-------------|
| `PRODUCT_BACKLOG.md` | Pre-Fase 1 | Indice del backlog (1 linea por story) |
| `backlog/stories/PA-001-*.md` ... | Pre-Fase 1 | Stories individuales con AC completos |
| `backlog/epics/EPIC-PA-001-*.md` ... | Pre-Fase 1 | Epics con descripcion y stories asociadas |
| Sprint Backlog por sprint | Cada sprint | Seleccion de stories para el sprint |
| Backlog refinement | Semanal | Re-priorizacion y grooming |

**Historias epicas esperadas:**

| Epic | Fase | Stories estimadas |
|------|------|-------------------|
| EPIC-PA-001: Project Registry CRUD | Fase 1 | 6-8 stories |
| EPIC-PA-002: Filesystem Scanner | Fase 1 | 3-4 stories |
| EPIC-PA-003: MCP Server | Fase 1 | 4-5 stories |
| EPIC-PA-004: REST API | Fase 1 | 5-6 stories |
| EPIC-PA-005: github-sync Migration | Fase 1b | 3-4 stories |
| EPIC-PA-006: SBM Integration | Fase 2 | 4-5 stories |
| EPIC-PA-007: CO Integration | Fase 2 | 3-4 stories |
| EPIC-PA-008: Angular Dashboard | Fase 2+ | 10-15 stories |

**Criterios de activacion:**

- Pre-Fase 1: Alta dedicacion. Crear backlog completo de Fase 1.
- Entre sprints: Media. Grooming, re-priorizacion.
- Pre-Fase 2: Alta. Crear backlog de integraciones.

---

### 3. Project Manager

| Campo | Detalle |
|-------|---------|
| **Rol** | Project Manager |
| **Tipo de agente** | `project-manager` |
| **Fase activa** | Pre-Fase 1, transiciones entre fases |

**Funciones y responsabilidades:**

- Crear el Project Plan con timeline, dependencias y milestones
- Estimar capacity por sprint (1 dev, ~47h capacity, ~37h commitment)
- Mapear dependencias entre fases y entre epics
- Identificar ruta critica y cuellos de botella
- Planificar la migracion de github-sync (Fase 1b) en paralelo o secuencial
- Coordinar la transicion de fases (cuando Fase 1 esta completa, que se necesita para Fase 2)
- Detectar riesgos de timeline y proponer mitigaciones
- Reportar estado del proyecto al usuario (progreso, blockers, ETA)

**Entregables:**

| Entregable | Fase | Descripcion |
|------------|------|-------------|
| `PROJECT_PLAN.md` | Pre-Fase 1 | Plan completo con timeline, dependencias, milestones |
| Dependency map | Pre-Fase 1 | Diagrama de dependencias entre epics y fases |
| Sprint plan por sprint | Cada sprint | Capacity calculation, story selection, goals |
| Risk register | Pre-Fase 1 | Riesgos con probabilidad, impacto, mitigacion |
| Status report | Semanal | Progreso, burndown, blockers |
| Transition checklist Fase 1 -> 2 | Final Fase 1 | Que debe estar completo antes de iniciar Fase 2 |

**Dependencias clave a mapear:**

```
Fase 1:
  Setup proyecto → Schema DB → Repositories → Services → MCP tools + REST API
  Schema DB → Seed data (en paralelo con services)
  Services → Tests (en paralelo parcial)

Fase 1b (puede solaparse con Fase 1 final):
  Analisis github-sync → Adaptacion a SBM → MCP tools sync → Tests
  Dependencia: SBM schema debe soportar github_project_number

Fase 2:
  SBM REST API (nueva) → Integration layer PA → Aggregated endpoints
  CO REST API (existente parcial) → Integration layer PA
  Ambas integraciones pueden ser paralelas entre si

Fase 2+:
  PA REST API completa → Angular scaffold → Vistas → Real-time
```

**Criterios de activacion:**

- Pre-Fase 1: Alta dedicacion. Plan completo.
- Durante ejecucion: Baja. Monitoreo y ajustes.
- Transiciones de fase: Media. Checklists y re-planning.

---

### 4. Database Architect

| Campo | Detalle |
|-------|---------|
| **Rol** | Database Architect |
| **Tipo de agente** | `database-expert` |
| **Fase activa** | Fase 1 (diseno), Fase 2 (integracion) |

**Funciones y responsabilidades:**

- Disenar el schema completo de PostgreSQL para Project Admin
- Definir indexes optimos para los patrones de query esperados
- Disenar la estructura JSONB para campos flexibles (stack, health, config, metadata)
- Planificar la estrategia de migraciones (versionadas, reversibles)
- Analizar el schema existente de Sprint Backlog Manager para la integracion Fase 2
- Definir queries para los aggregated views cross-service
- Optimizar queries para los endpoints de mayor uso (list projects, search, ecosystem stats)
- Validar que el modelo de datos no tiene redundancias innecesarias con SBM
- Disenar la seed data migration para los 26 proyectos iniciales

**Entregables:**

| Entregable | Fase | Descripcion |
|------------|------|-------------|
| Schema DDL completo | Pre-Fase 1 | SQL de creacion de tablas, indexes, constraints |
| Estrategia de migraciones | Pre-Fase 1 | Como se versionan y ejecutan las migraciones |
| Analisis de indexes | Fase 1 | Indexes recomendados basados en patrones de query |
| Seed data SQL/script | Fase 1 | Script para poblar los 26 proyectos |
| Analisis schema SBM | Pre-Fase 2 | Como se relacionan los schemas de PA y SBM |
| Queries de agregacion | Fase 2 | SQL para vistas cross-service |
| Performance baseline | Fase 1 | Benchmarks de queries con 26 y con 200 proyectos |

**Coordinacion con SBM schema:**

El schema de SBM ya tiene una tabla `projects` con campos `id`, `name`, `prefix`, `description`, `config`. Project Admin NO duplica esta tabla. En cambio:

- PA tiene su propia tabla `projects` con datos complementarios (path, stack, health, category)
- El link se hace via `project_metadata` con key `sbm_project_id`
- En Fase 2, PA consulta SBM via REST API usando ese ID

**Criterios de activacion:**

- Pre-Fase 1: Alta dedicacion. Disenar schema desde cero.
- Fase 1: Media. Optimizaciones, seed data.
- Pre-Fase 2: Alta. Analisis de integracion con SBM schema.

---

### 5. Business Stakeholder

| Campo | Detalle |
|-------|---------|
| **Rol** | Business Stakeholder |
| **Tipo de agente** | `business-stakeholder` |
| **Fase activa** | Pre-Fase 1, Pre-Fase 2, Pre-Fase 2+ |

**Funciones y responsabilidades:**

- Validar que las funcionalidades propuestas generan valor real para el workflow de desarrollo
- Aprobar o rechazar el scope de cada fase (GO/NO-GO decisions)
- Priorizar desde la perspectiva de impacto en productividad diaria
- Identificar funcionalidades "nice to have" vs "must have" para Fase 1
- Validar que la integracion con servicios existentes no degrada su funcionamiento
- Evaluar si el Angular Dashboard (Fase 2+) justifica su inversion vs alternativas mas simples

**Entregables:**

| Entregable | Fase | Descripcion |
|------------|------|-------------|
| `BUSINESS_STAKEHOLDER_DECISION.md` | Pre-Fase 1 | Decision GO/NO-GO con scope aprobado |
| Validacion de prioridades | Pre-cada fase | Confirmacion de que el scope tiene sentido |
| Feedback post-fase | Final de cada fase | Evaluacion de valor entregado vs esperado |

**Preguntas clave a responder:**

- Fase 1: "Un registro central de proyectos con MCP tools, aporta suficiente valor al workflow diario con Claude Code?"
- Fase 1b: "La migracion de github-sync justifica 1 sprint completo, o se puede postergar?"
- Fase 2: "La integracion cross-service agrega suficiente valor, o con Project Admin standalone ya alcanza?"
- Fase 2+: "Un Angular Dashboard es necesario, o con MCP tools + Flutter Monitor alcanza?"

**Criterios de activacion:**

- Pre-cada fase: Puntual. Sesion de validacion y decision.
- Post-cada fase: Puntual. Review de valor entregado.

---

### 6. Data Correlation Analyst

| Campo | Detalle |
|-------|---------|
| **Rol** | Data Correlation Analyst |
| **Tipo de agente** | `matching-specialist` |
| **Fase activa** | Fase 1 (seed data), Fase 2 (integracion) |

**Funciones y responsabilidades:**

- Disenar el algoritmo de auto-discovery que escanea directorios y detecta proyectos
- Definir las reglas de deteccion de stack por archivos presentes (package.json -> node, pubspec.yaml -> flutter, etc.)
- Disenar el mapping entre proyectos en Project Admin y entidades en Sprint Backlog Manager
- Resolver como matchear sesiones de Claude Orchestrator (por `cwd`) con proyectos registrados (por `path`)
- Definir heuristicas para detectar relaciones entre proyectos (worktrees, monorepos, shared dependencies)
- Disenar el mecanismo de reconciliacion cuando un scan encuentra proyectos nuevos vs existentes

**Entregables:**

| Entregable | Fase | Descripcion |
|------------|------|-------------|
| Reglas de deteccion de stack | Pre-Fase 1 | Tabla archivo -> tecnologia |
| Algoritmo de auto-discovery | Pre-Fase 1 | Pseudocodigo del scanner |
| Mapping PA <-> SBM | Pre-Fase 2 | Como se correlacionan proyectos entre sistemas |
| Mapping sesiones CO <-> proyectos PA | Pre-Fase 2 | Logica de matching por path |
| Heuristicas de relaciones automaticas | Fase 1 | Deteccion de worktrees, dependencias |

**Reglas de deteccion de stack (borrador):**

| Archivo / Patron | Tecnologia detectada |
|-------------------|---------------------|
| `package.json` | node |
| `package.json` + `node_modules/` | node (instalado) |
| `pubspec.yaml` | flutter/dart |
| `*.csproj` o `*.sln` | dotnet |
| `requirements.txt` o `pyproject.toml` | python |
| `Cargo.toml` | rust |
| `go.mod` | go |
| `pom.xml` | java |
| `docker-compose.yml` | docker |
| `.env` o `.env.example` | env-config |
| `src/mcp/` o dependencia `@modelcontextprotocol/sdk` | mcp |
| `angular.json` | angular |
| `next.config.*` | nextjs |

**Criterios de activacion:**

- Pre-Fase 1: Media dedicacion. Disenar deteccion y discovery.
- Pre-Fase 2: Media. Disenar mapping cross-service.

---

### 7. Data Quality Analyst

| Campo | Detalle |
|-------|---------|
| **Rol** | Data Quality Analyst |
| **Tipo de agente** | `data-quality-analyst` |
| **Fase activa** | Fase 1 (post-seed), Fase 2 (post-integracion) |

**Funciones y responsabilidades:**

- Validar la calidad de los datos del seed data despues del primer scan
- Detectar anomalias: proyectos sin path valido, paths duplicados, slugs inconsistentes
- Verificar completitud: todos los proyectos tienen categoria, stack detectado, health evaluado
- Validar consistencia cross-service en Fase 2: proyectos en PA que no existen en SBM y viceversa
- Definir reglas de validacion automatica para datos que ingresan al sistema
- Proponer data cleanup cuando se detecten inconsistencias

**Entregables:**

| Entregable | Fase | Descripcion |
|------------|------|-------------|
| Data quality report post-seed | Fase 1 | Reporte de calidad del seed data |
| Reglas de validacion | Fase 1 | Constraints y checks automaticos |
| Cross-service consistency report | Fase 2 | Discrepancias entre PA, SBM, CO |
| Data cleanup recommendations | Cada fase | Acciones correctivas propuestas |

**Criterios de activacion:**

- Post-seed Fase 1: Puntual. Auditoria de datos.
- Post-integracion Fase 2: Puntual. Auditoria cross-service.

---

## Resumen de Activacion por Fase

```
Pre-Fase 1:  Architect + PO + PM + DB Architect + Business + Matching
Fase 1:      Architect (consulta) + DB Architect + Data Quality (post-seed)
Fase 1b:     Architect (consulta)
Pre-Fase 2:  Architect + PO + PM + DB Architect + Business + Matching
Fase 2:      Architect (consulta) + Data Quality (post-integracion)
Pre-Fase 2+: Architect + PO + Business
Fase 2+:     Architect (consulta)
```

---

## Coordinacion entre Planificacion y Desarrollo

El equipo de planificacion produce artefactos que el equipo de desarrollo consume:

```
Planificacion                          Desarrollo
─────────────                          ──────────
ARCHITECTURE.md         ──────►        Guia de implementacion
PRODUCT_BACKLOG.md      ──────►        Stories a implementar
PROJECT_PLAN.md         ──────►        Timeline y dependencias
Schema DDL              ──────►        Migration files
API contracts           ──────►        Route handlers + MCP tools
Reglas de discovery     ──────►        scan-service.js
Mapping cross-service   ──────►        Integration layer
```

El usuario (Technical Lead) es el puente entre ambos equipos y toma las decisiones finales.

---

**Documento creado:** 2026-02-12
**Relacionado con:** SEED_DOCUMENT.md, TEAM_DEVELOPMENT.md
