# Project Admin - Plan de Proyecto

**Proyecto:** Project Admin Backend
**Version:** 1.0
**Fecha:** 2026-02-13
**Project Manager:** project-manager agent
**Escala:** Micro (1 developer)
**Metodologia:** Agile simplificado (sprints de 10 dias)

---

## 1. Objetivos de Fase 1

### Objetivo General

Entregar un backend funcional standalone que sirva como registro centralizado de los 26+ proyectos de desarrollo, accesible tanto via MCP tools (para Claude Code) como via REST API (para futuros frontends).

### Objetivos Especificos

| # | Objetivo | Criterio de Exito |
|---|----------|-------------------|
| O1 | Registro centralizado de proyectos | CRUD completo funcional via REST + MCP |
| O2 | Auto-discovery de proyectos en filesystem | Scan de 4 directorios detecta 26 proyectos con stack correcto |
| O3 | Health check de proyectos | Verificacion de git, archivos clave y ultimo commit por proyecto |
| O4 | Metadata extensible | Tags, relaciones y metadata key-value funcionando |
| O5 | MCP Server operativo | 13 tools registrados y funcionales desde Claude Code |
| O6 | REST API documentada | Swagger/OpenAPI spec generada automaticamente |
| O7 | Seed data completo | 26 proyectos registrados con datos verificados |
| O8 | Calidad de codigo | >70% coverage en services, 0 errors/warnings, code review aprobado |

### Fuera de Scope (Fase 1)

- Comunicacion con Sprint Backlog Manager
- Comunicacion con Claude Orchestrator
- WebSocket server
- Dashboard Angular
- Autenticacion/autorizacion
- Migracion github-sync (Fase 1b, planificada por separado)

---

## 2. Capacity Calculation

### Parametros Base

```
Team:           1 developer
Sprint:         10 dias laborales
Horas/dia:      6h efectivas (8h - 2h overhead)
Efficiency:     80% (factor de eficiencia)
Availability:   98% (sin vacaciones/sick previstas)
```

### Calculo

```
Capacity bruta  = 1 dev x 10 dias x 6h x 0.80 x 0.98
                = 47.04h por sprint
                ~ 47h

Commitment (80% de capacity):  37.6h ~ 37h
Buffer (20% de capacity):       9.4h ~ 10h
```

### Conversion a Story Points

```
Estimacion inicial:  ~4.5 horas por punto (promedio)
Capacity en puntos:  47h / 4.5h = ~10.4 puntos por sprint
Commitment:          37h / 4.5h = ~8.2 puntos por sprint ~ 8 puntos
```

**Regla operativa:** No comprometer mas de 8 story points por sprint. El buffer de 10h es para bugs, deuda tecnica y urgencias imprevistas.

---

## 3. Estimacion de Esfuerzo Total - Fase 1

### Consolidado de Horas por Area

Las estimaciones provienen de TEAM_DEVELOPMENT.md, agrupadas por sprint propuesto.

| Area | Horas Estimadas | Puntos (~4.5h/pt) |
|------|----------------:|-------------------:|
| **Infraestructura y Setup** | | |
| DevOps: Docker, .env, .gitignore, scripts, ESLint | 7h | 1.5 |
| DevOps: README, MCP registration | 2.5h | 0.5 |
| **Base de Datos** | | |
| DB: Docker setup + pool.js | 2h | 0.5 |
| DB: Schema DDL + migration runner | 5h | 1 |
| DB: Seed data script | 3h | 0.5 |
| DB: Index tuning | 2h | 0.5 |
| **Backend Core** | | |
| Backend: Setup proyecto + entry points | 5h | 1 |
| Backend: project-repository + project-service | 4h | 1 |
| Backend: tag-repository + tag-service | 2h | 0.5 |
| Backend: relationship-repository + relationship-service | 3h | 0.5 |
| Backend: metadata-repository + metadata-service | 2h | 0.5 |
| Backend: scan-service (filesystem scanner) | 5h | 1 |
| Backend: health-service (git checks) | 4h | 1 |
| Backend: REST API routes completas | 6h | 1.5 |
| Backend: Fastify plugins (swagger, cors, error-handler) | 3h | 0.5 |
| **MCP Server** | | |
| MCP: Server setup (index.js, McpServer) | 2h | 0.5 |
| MCP: CRUD tools (list, get, create, update, delete) | 5h | 1 |
| MCP: Scan tools (scan_directory, scan_all) | 3h | 0.5 |
| MCP: Health, search, relationships, metadata, ecosystem tools | 8h | 2 |
| MCP: Tools index.js | 1h | 0.25 |
| **Testing** | | |
| Test: Infrastructure (jest, helpers, test DB) | 5h | 1 |
| Test: Unit tests services (project, scan, health, tag, rel, meta) | 14h | 3 |
| Test: Integration REST API | 4h | 1 |
| Test: Integration MCP tools | 3h | 0.5 |
| Test: Integration DB queries | 2h | 0.5 |
| **Review y Documentacion** | | |
| Code review: todas las capas | 10h | 2 |
| Architecture advisor: consultas | 4h | 1 |
| **TOTAL** | **~115h** | **~25 pts** |

### Sprints Necesarios

```
Total estimado:     ~115h de trabajo
Commitment/sprint:  ~37h
Sprints minimos:    115h / 37h = 3.1 sprints

Con buffer aplicado: 3 sprints firmes + margen de medio sprint
```

**Decision:** Planificar 3 sprints completos para Fase 1. Si se completa antes, el tiempo restante se usa para Fase 1b (github-sync) o polish adicional.

---

## 4. Timeline de Fase 1

### Vista General

```
Sprint 1 (Dias 1-10):  Fundaciones - Setup + Schema + Core Services
Sprint 2 (Dias 11-20): Interfaces - MCP Tools + REST API + Scanner
Sprint 3 (Dias 21-30): Completitud - Seed Data + Testing + Polish

Fase 1b (Sprint 4, opcional): Migracion github-sync a SBM
```

---

### Sprint 1: Fundaciones

**Goal:** Proyecto configurado, base de datos migrada, servicios core implementados y testeables.

**Capacity:** 47h | **Commitment:** 37h | **Buffer:** 10h

| Dia | Actividad | Rol | Horas | Acumulado |
|-----|-----------|-----|------:|----------:|
| 1 | Docker PostgreSQL setup + verificacion | DevOps + DB Expert | 2h | 2h |
| 1 | Setup proyecto: package.json, estructura carpetas, config.js | DevOps + Backend | 3h | 5h |
| 1 | .env.example, .gitignore, ESLint, Prettier | DevOps | 1.5h | 6.5h |
| 2 | Entry points: index.js (MCP), server.js (Fastify) | Backend | 3h | 9.5h |
| 2 | pool.js (connection pool) | DB Expert | 1h | 10.5h |
| 2 | 001_initial_schema.sql (DDL completo) | DB Expert | 3h | 13.5h |
| 3 | migrate.js (migration runner) | DB Expert | 2h | 15.5h |
| 3 | Ejecutar migration, verificar schema | DB Expert | 0.5h | 16h |
| 3 | Test infrastructure: jest config, test-db.js, fixtures | Test Engineer | 3h | 19h |
| 4 | project-repository.js | Backend | 2h | 21h |
| 4 | project-service.js (CRUD) | Backend | 2h | 23h |
| 5 | tag-repository.js + tag-service.js | Backend | 2h | 25h |
| 5 | relationship-repository.js + relationship-service.js | Backend | 3h | 28h |
| 6 | metadata-repository.js + metadata-service.js | Backend | 2h | 30h |
| 6 | Test fixtures (mock projects, mock data) | Test Engineer | 2h | 32h |
| 7-8 | Unit tests: project-service + tag-service | Test Engineer | 4h | 36h |
| 9 | Code review: schema + repositories + services | Code Reviewer | 2h | 38h |
| 10 | Fixes de review + buffer | Backend | -- | -- |

**Entregables Sprint 1:**
- [x] Proyecto inicializado con estructura completa
- [x] PostgreSQL corriendo en Docker (puerto 5433)
- [x] Schema migrado (5 tablas: projects, project_tags, project_relationships, project_metadata, scan_history)
- [x] Capa de repositories completa (5 archivos)
- [x] Capa de services core completa (4 archivos: project, tag, relationship, metadata)
- [x] Infraestructura de testing funcional
- [x] Tests unitarios de project-service y tag-service

**Riesgos del Sprint:**
- Docker Desktop no arrancando en Windows (mitigacion: verificar al inicio del dia 1)
- Schema mas complejo de lo esperado (mitigacion: simplificar JSONB constraints)

---

### Sprint 2: Interfaces

**Goal:** MCP tools y REST API funcionales, filesystem scanner operativo, health checks implementados.

**Capacity:** 47h | **Commitment:** 37h | **Buffer:** 10h

**Pre-requisito:** Sprint 1 completo (services core + schema migrado).

| Dia | Actividad | Rol | Horas | Acumulado |
|-----|-----------|-----|------:|----------:|
| 11 | scan-service.js (filesystem auto-discovery) | Backend | 5h | 5h |
| 12 | health-service.js (git checks, file detection) | Backend | 4h | 9h |
| 12 | git-utils.js + fs-scanner.js (utilities) | Backend | 1h | 10h |
| 13 | MCP server setup (index.js, McpServer instance) | MCP Dev | 2h | 12h |
| 13 | MCP tools: pa_list_projects + pa_get_project | MCP Dev | 2h | 14h |
| 14 | MCP tools: pa_create/update/delete_project | MCP Dev | 3h | 17h |
| 14 | MCP tools: pa_scan_directory + pa_scan_all | MCP Dev | 3h | 20h |
| 15 | MCP tools: pa_project_health + pa_search_projects | MCP Dev | 4h | 24h |
| 15 | MCP tools: pa_add/get_relationships + pa_set_metadata + pa_ecosystem_stats | MCP Dev | 4h | 28h |
| 16 | MCP tools index.js (registro centralizado) | MCP Dev | 1h | 29h |
| 16 | Fastify plugins (swagger, cors, error-handler, request-logger) | Backend | 3h | 32h |
| 17 | REST API routes: projects (GET, POST, PUT, DELETE) | Backend | 3h | 35h |
| 18 | REST API routes: tags, relationships, scan, ecosystem | Backend | 3h | 38h |
| 19 | Unit tests: scan-service + health-service | Test Engineer | 5h | 43h |
| 20 | Code review: MCP tools + REST routes + scanner | Code Reviewer | 4h | 47h |

**Entregables Sprint 2:**
- [x] scan-service.js: escanea C:/agents/, C:/apps/, C:/mcp/, C:/mobile/
- [x] health-service.js: verifica git, package.json, pubspec.yaml, ultimo commit
- [x] 13 MCP tools funcionales con prefijo pa_
- [x] REST API completa con todos los endpoints de Fase 1
- [x] Swagger/OpenAPI spec generada
- [x] Tests unitarios de scan-service y health-service
- [x] Code review aprobado de toda la capa de interfaces

**Riesgos del Sprint:**
- Performance de git commands en Windows (mitigacion: cache con TTL)
- Fastify learning curve (mitigacion: documentacion oficial es excelente)
- Sprint overcommitted si hay carryover de Sprint 1 (mitigacion: priorizar MCP tools sobre REST si hay que recortar)

---

### Sprint 3: Completitud

**Goal:** Seed data cargado y verificado, testing completo, documentacion lista, sistema listo para produccion.

**Capacity:** 47h | **Commitment:** 37h | **Buffer:** 10h

**Pre-requisito:** Sprint 2 completo (MCP + REST + Scanner funcionales).

| Dia | Actividad | Rol | Horas | Acumulado |
|-----|-----------|-----|------:|----------:|
| 21 | Seed data script: 26 proyectos | DB Expert | 3h | 3h |
| 21 | Ejecutar seed + primer scan completo | Backend | 2h | 5h |
| 22 | Data quality audit post-seed | Data Quality | 2h | 7h |
| 22 | Fixes de datos: stacks incorrectos, paths invalidos | Backend | 2h | 9h |
| 23 | Unit tests: relationship-service + metadata-service | Test Engineer | 3h | 12h |
| 23 | Integration tests: REST API endpoints | Test Engineer | 4h | 16h |
| 24 | Integration tests: MCP tools | Test Engineer | 3h | 19h |
| 24 | Integration tests: database queries | Test Engineer | 2h | 21h |
| 25 | Coverage report + gap analysis | Test Engineer | 1h | 22h |
| 25 | Tests adicionales para alcanzar >70% coverage | Test Engineer | 3h | 25h |
| 26 | README.md completo con Quick Start | DevOps | 2h | 27h |
| 26 | MCP server registration en Claude Code config | DevOps | 0.5h | 27.5h |
| 26 | npm scripts finales (start, dev, test, migrate, seed) | DevOps | 1h | 28.5h |
| 27 | Index tuning basado en queries reales | DB Expert | 2h | 30.5h |
| 28 | Code review final: todo el sistema | Code Reviewer | 3h | 33.5h |
| 29 | Fixes finales de review | Backend | 2h | 35.5h |
| 29 | Architecture validation: capas, patrones, acoplamiento | Architect | 1h | 36.5h |
| 30 | Demo funcional + smoke test E2E | Todos | 2h | 38.5h |

**Entregables Sprint 3:**
- [x] 26 proyectos registrados via seed data
- [x] Scan completo ejecutado y datos verificados
- [x] Data quality report sin anomalias criticas
- [x] Test coverage >70% en services, >60% overall
- [x] Integration tests para REST API y MCP tools
- [x] README con Quick Start funcional en <5 minutos
- [x] MCP server registrado en Claude Code
- [x] Code review final aprobado
- [x] Demo funcional al usuario

**Riesgos del Sprint:**
- Coverage gap dificil de cerrar (mitigacion: priorizar tests de happy path primero)
- Seed data con inconsistencias (mitigacion: data quality audit en dia 22)
- Carryover de sprints anteriores consume buffer (mitigacion: recortar polish, no testing)

---

## 5. Dependency Map

### Diagrama de Dependencias - Fase 1

```
                                SPRINT 1
                                --------

  DevOps Setup ─────────────► Schema DDL ─────────────► Repositories
  (Docker, pkg,               (migration,                (project, tag,
   .env, eslint)               pool.js)                   relationship,
       │                           │                       metadata)
       │                           │                          │
       │                           │                          ▼
       │                           │                      Services Core
       │                           │                      (project, tag,
       │                           │                       relationship,
       │                           │                       metadata)
       │                           │                          │
       ▼                           ▼                          │
  Test Infra ◄─────────── Test DB Setup                      │
  (jest config,                                              │
   helpers)                                                  │
                                                             │
                                SPRINT 2                     │
                                --------                     │
                                                             │
                           ┌─────────────────────────────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │   scan-service.js      │
              │   health-service.js    │
              │   git-utils.js         │
              │   fs-scanner.js        │
              └─────────┬──────────────┘
                        │
            ┌───────────┴───────────┐
            │                       │
            ▼                       ▼
    MCP Tools (13)          REST API Routes
    (pa_list, pa_get,       (projects, tags,
     pa_create, pa_scan,     relationships,
     pa_health, ...)         scan, ecosystem)
            │                       │
            │                       │
            ▼                       ▼
    Fastify Plugins ◄───── Swagger/OpenAPI
    (cors, error-handler)
            │                       │
            └───────────┬───────────┘
                        │
                        │
                                SPRINT 3
                                --------
                        │
                        ▼
              ┌────────────────────────┐
              │     Seed Data          │
              │   (26 proyectos)       │
              └─────────┬──────────────┘
                        │
                        ▼
              ┌────────────────────────┐
              │  Data Quality Audit    │
              └─────────┬──────────────┘
                        │
            ┌───────────┴───────────┐
            │                       │
            ▼                       ▼
    Integration Tests       Unit Tests
    (REST + MCP)            (restantes)
            │                       │
            └───────────┬───────────┘
                        │
                        ▼
              ┌────────────────────────┐
              │   Code Review Final    │
              │   + Architecture       │
              │     Validation         │
              └─────────┬──────────────┘
                        │
                        ▼
              ┌────────────────────────┐
              │      DEMO              │
              │   Fase 1 Complete      │
              └────────────────────────┘
```

### Dependencias Criticas (Bloqueantes)

| Dependencia | Bloqueado por | Bloquea a | Sprint |
|-------------|---------------|-----------|--------|
| Docker PostgreSQL | Nada | Todo lo demas | S1 D1 |
| Schema DDL migrado | Docker + pool.js | Repositories, Services | S1 D2-3 |
| Repositories | Schema | Services | S1 D4 |
| Services core | Repositories | MCP tools, REST routes | S1 D4-6 |
| scan-service + health-service | Services core | MCP scan/health tools | S2 D11-12 |
| MCP tools | Services + scan/health | Integration tests MCP | S2 D13-16 |
| REST routes | Services + Fastify plugins | Integration tests REST | S2 D17-18 |
| Seed data | Scan service + REST/MCP funcional | Data quality audit | S3 D21 |
| Tests completos | Todo el codigo | Code review final | S3 D23-25 |
| Code review final | Tests pasando | Demo / release | S3 D28 |

### Dependencias No Bloqueantes (Paralelo Posible)

| Actividad A | Actividad B | Condicion |
|-------------|-------------|-----------|
| MCP tools | REST routes | Ambos dependen de services, no entre si |
| Unit tests services | Integration tests | Pueden solaparse parcialmente |
| Seed data script | Tests restantes | Seed en dia 21, tests desde dia 23 |
| README / docs | Testing | Independientes |

---

## 6. Ruta Critica

La ruta critica es la secuencia mas larga de tareas dependientes que determina la duracion minima del proyecto.

### Ruta Critica Identificada

```
Docker Setup → Schema DDL → pool.js → migrate.js → project-repository
→ project-service → scan-service → MCP tools CRUD → MCP tools scan/health
→ Seed data → Data quality audit → Integration tests → Code review final
→ Fixes → Demo
```

**Duracion de ruta critica:** ~28 dias laborales (encaja en 3 sprints de 10 dias)

### Implicaciones

1. **No hay margen en la ruta critica para Sprint 1.** El schema y los repositories deben completarse en los primeros 5 dias para no retrasar Sprint 2.

2. **Sprint 2 tiene el mayor riesgo** porque concentra scan-service (5h, la tarea individual mas grande) + todos los MCP tools + REST routes.

3. **Sprint 3 tiene mas flexibilidad** porque seed data y testing pueden ajustar su intensidad.

### Mitigaciones de Ruta Critica

| Riesgo | Mitigacion |
|--------|------------|
| Schema DDL toma mas de 3h | Simplificar indexes, agregar en Sprint 3 |
| scan-service mas complejo de lo esperado | Implementar version minima (solo deteccion basica), iterar en Sprint 3 |
| MCP tools no se completan en Sprint 2 | Priorizar CRUD tools (5 core), postergar ecosystem/metadata tools |
| Integration tests revelan bugs | Buffer de Sprint 3 (10h) para fixes |

---

## 7. Risk Register

| ID | Riesgo | Probabilidad | Impacto | Score | Mitigacion | Contingencia | Owner |
|----|--------|:------------:|:-------:|:-----:|------------|--------------|-------|
| R01 | Docker Desktop no arranca en Windows | Media | Alto | 6 | Verificar Docker al inicio de Sprint 1 Dia 1. Tener WSL como backup. | Instalar PostgreSQL nativo temporalmente (violar regla Docker solo si bloquea >4h). | DevOps |
| R02 | Conflicto puerto 5433 con otro servicio | Baja | Bajo | 2 | Verificar puertos antes de iniciar. Usar puerto alternativo (5434) si es necesario. | Cambiar DB_PORT en .env. | DevOps |
| R03 | Fastify learning curve genera retrasos | Baja | Medio | 3 | La API surface es similar a Express. Documentacion oficial excelente. Sprint 1 tiene buffer. | Pivotear a Express si el retraso supera 1 dia completo. | Backend Dev |
| R04 | Performance de git commands en Windows es mala | Media | Bajo | 3 | Implementar cache in-memory con TTL de 5 min para resultados de git. No ejecutar git en cada request. | Reducir scope de health-service a solo deteccion de archivos (sin git commands en hot path). | Backend Dev |
| R05 | Auto-scan detecta proyectos incorrectamente (falsos positivos/negativos) | Media | Bajo | 3 | Flag `autoScan: false` por proyecto. Confirmacion manual disponible. Heuristicas conservadoras. | Correccion manual via pa_update_project. Scan es complementario, no la unica forma de registrar. | Matching Specialist |
| R06 | Schema DDL mas complejo de lo esperado | Baja | Medio | 3 | Schema ya esta disenado en SEED_DOCUMENT.md. Implementacion es directa. | Simplificar: postergar constraints complejos y JSONB GIN indexes a Sprint 3. | DB Expert |
| R07 | Sprint 2 overcommitted (MCP + REST + Scanner) | Media | Alto | 6 | Priorizar MCP tools sobre REST si hay que recortar. REST puede completarse en Sprint 3. | Mover REST routes a Sprint 3, entregar MCP-only en Sprint 2. | PM |
| R08 | Test coverage no alcanza 70% en services | Media | Medio | 4 | Planificar tests desde Sprint 1. Infrastructure de testing lista temprano. | Aceptar 60% en Sprint 3 si el codigo tiene code review aprobado. Completar coverage post-Fase 1. | Test Engineer |
| R09 | Carryover entre sprints acumula deuda | Media | Alto | 6 | Revisar scope al inicio de cada sprint. No comprometer mas de 37h. Buffer de 10h por sprint. | Re-planificar: agregar Sprint 3.5 de 5 dias si Sprint 3 no es suficiente. | PM |
| R10 | Seed data de 26 proyectos tiene inconsistencias | Media | Bajo | 3 | Data quality audit planificado en Sprint 3 dia 22. Inventario ya documentado en PROJECT_INVENTORY.md. | Correcciones manuales. No bloquea la demo, se puede iterar post-release. | Data Quality |
| R11 | Zod 4.x tiene breaking changes vs versiones anteriores | Baja | Medio | 3 | Verificar documentacion de Zod 4 antes de implementar schemas. | Usar Zod 3.x si hay problemas de compatibilidad con MCP SDK. | MCP Dev |

### Matriz de Probabilidad x Impacto

```
Impacto →     Bajo(1)   Medio(2)   Alto(3)
Prob ↓
Alta(3)
Media(2)     R04,R05    R08,R11    R01,R07,R09
             R10
Baja(1)      R02        R03,R06
```

**Top 3 riesgos a monitorear:** R01 (Docker), R07 (Sprint 2 overcommitted), R09 (Carryover).

---

## 8. Milestones

| # | Milestone | Sprint | Dia | Criterios de Aceptacion |
|---|-----------|--------|-----|-------------------------|
| M1 | **Proyecto Bootstrapped** | S1 | D3 | Docker PostgreSQL corriendo. Schema migrado. pool.js conecta. Entry points ejecutan sin error. Test infrastructure funciona. |
| M2 | **Core Services Operativos** | S1 | D8 | CRUD de projects funciona end-to-end (service -> repository -> DB). Tags, relationships y metadata services implementados. Al menos 4 unit tests pasando. |
| M3 | **Scanner Funcional** | S2 | D12 | scan-service detecta proyectos en los 4 directorios. health-service verifica git + archivos. Ambos retornan datos correctos para al menos 5 proyectos de prueba. |
| M4 | **MCP Server Operativo** | S2 | D16 | 13 MCP tools registrados. Tools CRUD funcionan desde Claude Code. Tools de scan y health devuelven datos reales. |
| M5 | **REST API Completa** | S2 | D18 | Todos los endpoints de Fase 1 responden. Swagger UI accesible en /docs. Formato de respuesta estandar verificado. |
| M6 | **Datos Poblados** | S3 | D22 | 26 proyectos registrados via seed. Auto-scan ejecutado. Data quality audit sin anomalias criticas. Stacks detectados correctamente en >80% de proyectos. |
| M7 | **Testing Completo** | S3 | D26 | Coverage >70% en services, >60% overall. Integration tests REST + MCP pasando. 0 tests failing. |
| M8 | **Fase 1 Release** | S3 | D30 | Code review final aprobado. README funcional. Demo exitosa. Todos los criterios de DoD de Fase 1 cumplidos. |

### Milestone Gates (GO/NO-GO)

| Gate | Milestone | Decision |
|------|-----------|----------|
| Gate 1 | M2 (Core Services) | Si no se alcanza al final de S1: re-planificar S2, reducir scope de MCP tools. |
| Gate 2 | M5 (REST API) | Si no se alcanza al final de S2: decidir si Sprint 3 prioriza REST o testing. |
| Gate 3 | M8 (Release) | Si no se alcanza al final de S3: evaluar Sprint 3.5 de estabilizacion (5 dias). |

---

## 9. Sprint Goals

### Sprint 1: Fundaciones

**Goal Statement:** "Al finalizar Sprint 1, el proyecto esta inicializado con infraestructura completa (Docker, DB, testing), el schema esta migrado, y los servicios core (CRUD de proyectos, tags, relaciones, metadata) estan implementados con tests unitarios iniciales."

**Key Results:**
- Docker PostgreSQL corriendo en puerto 5433
- 5 tablas migradas en la base de datos
- 5 repositories implementados
- 4 services core implementados
- Infraestructura de testing funcional
- Al menos 6 unit tests pasando
- Code review de Sprint 1 aprobado

**Velocidad esperada:** ~8 story points

---

### Sprint 2: Interfaces

**Goal Statement:** "Al finalizar Sprint 2, el sistema tiene sus dos interfaces principales funcionales (MCP tools y REST API), el filesystem scanner detecta proyectos, y el health checker verifica su estado."

**Key Results:**
- 13 MCP tools registrados y funcionales
- REST API con todos los endpoints de Fase 1
- Swagger/OpenAPI spec generada
- scan-service detecta proyectos en 4 directorios
- health-service ejecuta checks de git + archivos
- Tests unitarios de scan-service y health-service
- Code review de Sprint 2 aprobado

**Velocidad esperada:** ~9 story points (sprint mas intenso)

---

### Sprint 3: Completitud

**Goal Statement:** "Al finalizar Sprint 3, el sistema esta poblado con los 26 proyectos, la calidad de datos esta verificada, la cobertura de tests supera los targets, la documentacion esta completa, y el sistema esta listo para uso productivo."

**Key Results:**
- 26 proyectos registrados con datos correctos
- Data quality audit aprobado
- Coverage >70% en services, >60% overall
- Integration tests REST + MCP pasando
- README con Quick Start funcional
- MCP server registrado en Claude Code
- Code review final aprobado
- Demo funcional al usuario exitosa

**Velocidad esperada:** ~8 story points

---

## 10. Epics y Stories (Resumen para Product Backlog)

Resumen de epics esperados con stories estimadas. El detalle completo estara en PRODUCT_BACKLOG.md.

### EPIC-PA-001: Project Registry CRUD (Sprint 1)

| Story | Puntos | Sprint |
|-------|--------|--------|
| PA-001: Setup proyecto e infraestructura base | 3 | S1 |
| PA-002: Schema DDL y migration runner | 2 | S1 |
| PA-003: Project repository y service (CRUD) | 2 | S1 |
| PA-004: Tag repository y service | 1 | S1 |
| PA-005: Relationship repository y service | 1 | S1 |
| PA-006: Metadata repository y service | 1 | S1 |
| **Subtotal** | **10** | |

### EPIC-PA-002: Filesystem Scanner (Sprint 2)

| Story | Puntos | Sprint |
|-------|--------|--------|
| PA-007: scan-service con auto-discovery | 2 | S2 |
| PA-008: health-service con git checks | 2 | S2 |
| PA-009: Stack detection por archivos presentes | 1 | S2 |
| **Subtotal** | **5** | |

### EPIC-PA-003: MCP Server (Sprint 2)

| Story | Puntos | Sprint |
|-------|--------|--------|
| PA-010: MCP server setup + CRUD tools | 2 | S2 |
| PA-011: MCP scan y health tools | 2 | S2 |
| PA-012: MCP search, relationships, metadata, ecosystem tools | 2 | S2 |
| **Subtotal** | **6** | |

### EPIC-PA-004: REST API (Sprint 2-3)

| Story | Puntos | Sprint |
|-------|--------|--------|
| PA-013: Fastify plugins y middleware | 1 | S2 |
| PA-014: REST routes projects + tags | 2 | S2 |
| PA-015: REST routes relationships + scan + ecosystem | 1 | S2-S3 |
| **Subtotal** | **4** | |

### Cross-cutting (Sprint 3)

| Story | Puntos | Sprint |
|-------|--------|--------|
| PA-016: Seed data 26 proyectos | 1 | S3 |
| PA-017: Integration tests REST API | 2 | S3 |
| PA-018: Integration tests MCP tools | 1 | S3 |
| PA-019: README y documentacion | 1 | S3 |
| PA-020: Code review final y polish | 2 | S3 |
| **Subtotal** | **7** | |

**Total Fase 1: ~32 story points en 3 sprints (~10.7 pts/sprint promedio)**

**Nota:** Las estimaciones en puntos son conservadoras. Si la velocidad real es mayor, se pueden incorporar stories de polish o adelantar Fase 1b.

---

## 11. Plan de Fase 1b: Migracion github-sync

### Timing

Fase 1b puede ejecutarse de dos formas:

**Opcion A (Recomendada):** Iniciar en la segunda mitad de Sprint 3, si hay buffer disponible.
**Opcion B:** Sprint 4 dedicado (10 dias adicionales).

### Estimacion

| Tarea | Horas | Rol |
|-------|------:|-----|
| Analisis github-sync.js actual | 2h | Backend Dev |
| Adaptar a PostgreSQL + SBM services | 5h | Backend Dev |
| Migration SBM: github sync fields | 2h | DB Expert |
| MCP tools: sync_to_github, pull_from_github | 4h | MCP Dev |
| Tests de integracion | 3h | Test Engineer |
| Code review | 1h | Code Reviewer |
| Documentar deprecation Sprint Tracker | 1h | DevOps |
| **Total** | **18h** | |

**Decision:** Si Sprint 3 tiene >10h de buffer libre, iniciar Fase 1b en Sprint 3. Si no, planificar Sprint 4 de 5 dias (medio sprint).

---

## 12. Transition Checklist: Fase 1 a Fase 2

Antes de iniciar Fase 2 (Integracion con SBM y CO), verificar que todos estos items estan completos.

### Pre-requisitos Tecnicos

- [ ] PostgreSQL corriendo estable en Docker (sin crashes en 1 semana)
- [ ] Schema migrado sin errores pendientes
- [ ] REST API respondiendo en todos los endpoints documentados
- [ ] MCP server registrado y funcional en Claude Code
- [ ] 26 proyectos registrados con datos correctos (verificado por data quality audit)
- [ ] Scan completo ejecuta en <10 segundos
- [ ] Health check individual ejecuta en <2 segundos
- [ ] Tests pasando: 0 failures
- [ ] Coverage: >70% services, >60% overall

### Pre-requisitos de Documentacion

- [ ] README.md con Quick Start funcional
- [ ] Swagger/OpenAPI spec accesible en /docs
- [ ] SEED_DOCUMENT.md actualizado si hubo cambios de scope
- [ ] PROJECT_INVENTORY.md actualizado con datos reales post-scan

### Pre-requisitos de Planificacion (para Fase 2)

- [ ] Sprint Backlog Manager: verificar si ya tiene REST API o hay que desarrollarla
- [ ] Claude Orchestrator: verificar endpoints disponibles para consulta
- [ ] Product Owner: backlog de Fase 2 creado (EPIC-PA-006, EPIC-PA-007)
- [ ] Lead Architect: contratos de integracion definidos (ADR-002)
- [ ] Database Architect: analisis de schema SBM completado
- [ ] Matching Specialist: mapping PA <-> SBM y sesiones CO <-> PA definido
- [ ] Business Stakeholder: decision GO/NO-GO para Fase 2

### Criterios GO/NO-GO

| Criterio | GO | NO-GO |
|----------|-----|-------|
| DoD Fase 1 completo | >90% items cumplidos | <80% items cumplidos |
| Bugs criticos | 0 | >0 |
| Performance | Dentro de targets | >50% fuera de targets |
| Valor entregado | MCP tools utiles en workflow diario | No se usan los tools |
| Dependencias Fase 2 | SBM y CO accesibles | SBM o CO no tienen APIs disponibles |

---

## 13. Metricas de Seguimiento

### KPIs del Proyecto

| Metrica | Target | Frecuencia de Medicion |
|---------|--------|------------------------|
| Velocidad (pts/sprint) | 8-10 | Fin de sprint |
| Commitment accuracy | >85% | Fin de sprint |
| Bugs encontrados post-review | <3 por sprint | Fin de sprint |
| Test coverage services | >70% | Sprint 3 |
| Test coverage overall | >60% | Sprint 3 |
| Milestones on-time | >75% (6/8) | Continuo |
| Buffer usado | <80% del buffer (8h de 10h) | Fin de sprint |

### Dashboard de Estado (para status reports)

```
Sprint: [N] | Dia: [X/10] | Buffer restante: [Xh]

Milestones:   [=====>      ] M1 OK | M2 OK | M3 pending | ...
Stories:      [========>   ] 5/8 done
Tests:        [=======>    ] 12/18 passing
Coverage:     [====>       ] 45% -> target 70%
Risks:        R07 (elevated) | R09 (monitoring)
Blockers:     [ninguno / descripcion]
```

---

## 14. Supuestos y Restricciones

### Supuestos

1. Docker Desktop esta instalado y funcional en la maquina de desarrollo
2. Node.js 20+ LTS esta instalado
3. Los 4 directorios de scan (C:/agents/, C:/apps/, C:/mcp/, C:/mobile/) existen y son accesibles
4. Los 26 proyectos listados en PROJECT_INVENTORY.md existen en sus paths declarados
5. No hay otros proyectos usando el puerto 3000 (REST API) ni 5433 (PostgreSQL)
6. El developer tiene acceso a internet para npm install y Docker pull
7. No hay vacaciones ni ausencias planificadas durante los 3 sprints

### Restricciones

1. **1 solo developer:** No hay paralelismo real entre personas, solo entre tareas delegadas a agentes
2. **Localhost only:** Sin requisitos de deployment remoto en Fase 1
3. **Read-only filesystem:** Project Admin no modifica archivos de otros proyectos
4. **PostgreSQL en Docker:** Obligatorio por directiva de metodologia
5. **ESM modules:** import/export, no CommonJS
6. **Sin autenticacion:** Fase 1 es localhost, sin auth

---

## Resumen Ejecutivo

```
Proyecto:     Project Admin Backend (Fase 1)
Duracion:     3 sprints (30 dias laborales, ~6 semanas calendario)
Esfuerzo:     ~115 horas de trabajo efectivo
Capacidad:    ~47h/sprint, ~37h commitment
Story Points: ~32 puntos en 3 sprints (~10.7/sprint)
Equipo:       1 developer + agentes especializados

Sprint 1:     Fundaciones (setup, schema, services core)
Sprint 2:     Interfaces (MCP tools, REST API, scanner)
Sprint 3:     Completitud (seed data, testing, docs, release)

Top Risks:    Docker startup (R01), Sprint 2 overcommitted (R07),
              Carryover acumulado (R09)

Fase 1b:      github-sync migration (~18h, al final de S3 o Sprint 4)
```

---

**Documento creado:** 2026-02-13
**Autor:** project-manager agent
**Relacionado con:** SEED_DOCUMENT.md, TEAM_PLANNING.md, TEAM_DEVELOPMENT.md
**Proximo paso:** Crear PRODUCT_BACKLOG.md con stories detalladas (product-owner agent)
