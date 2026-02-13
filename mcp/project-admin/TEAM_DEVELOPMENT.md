# Project Admin - Equipo de Desarrollo

**Proyecto:** Project Admin
**Version:** 1.0
**Fecha:** 2026-02-12

---

## Proposito del Equipo

El equipo de desarrollo es responsable de implementar, testear y entregar el codigo de Project Admin siguiendo la arquitectura y el backlog definidos por el equipo de planificacion. Opera bajo el principio de delegacion especializada: cada agente ejecuta tareas dentro de su dominio de expertise.

---

## Composicion del Equipo

### 1. Backend Developer (Lead)

| Campo | Detalle |
|-------|---------|
| **Rol** | Backend Developer (Lead) |
| **Tipo de agente** | `nodejs-backend-developer` |
| **Fase activa** | Fase 1, Fase 1b, Fase 2 |

**Funciones y responsabilidades:**

- Implementar la estructura base del proyecto (package.json, config, entry points)
- Desarrollar la capa de servicios (project-service, tag-service, relationship-service, metadata-service, scan-service, health-service)
- Desarrollar la capa de repositorios (acceso a datos PostgreSQL via pg driver)
- Implementar la REST API completa con Fastify (routes, schemas, error handling)
- Implementar el filesystem scanner para auto-discovery de proyectos
- Implementar health checks (git status, file detection, etc.)
- Desarrollar la capa de integracion con Sprint Backlog Manager y Claude Orchestrator (Fase 2)
- Implementar caching in-memory para datos de filesystem
- Manejar error handling consistente a traves de toda la aplicacion
- Implementar graceful shutdown y lifecycle management

**Tareas clave:**

| Tarea | Fase | Prioridad | Estimacion |
|-------|------|-----------|------------|
| Setup proyecto (package.json, estructura, config.js) | Fase 1 | Critical | 2h |
| Entry points (index.js para MCP, server.js para REST) | Fase 1 | Critical | 3h |
| project-repository.js + project-service.js (CRUD) | Fase 1 | Critical | 4h |
| tag-repository.js + tag-service.js | Fase 1 | High | 2h |
| relationship-repository.js + relationship-service.js | Fase 1 | High | 3h |
| metadata-repository.js + metadata-service.js | Fase 1 | High | 2h |
| scan-service.js (filesystem auto-discovery) | Fase 1 | High | 5h |
| health-service.js (git checks, file detection) | Fase 1 | High | 4h |
| REST API routes (projects, tags, relationships, scan, ecosystem) | Fase 1 | Critical | 6h |
| Fastify plugins (swagger, cors, error-handler) | Fase 1 | High | 3h |
| Seed data script (registrar 26 proyectos) | Fase 1 | High | 3h |
| github-sync-service.js adaptado a SBM | Fase 1b | High | 5h |
| Integration layer con SBM (HTTP client) | Fase 2 | Critical | 5h |
| Integration layer con CO (HTTP/WS client) | Fase 2 | Critical | 4h |
| Aggregated endpoints (project overview, ecosystem) | Fase 2 | High | 4h |
| Cache layer para datos cross-service | Fase 2 | Medium | 3h |

**Dependencias:**

- Depende de: Database Expert (schema listo y migrado antes de escribir repositories)
- Depende de: MCP Server Developer (contratos de tools definidos, para no duplicar logica)
- Depende de: Architecture Advisor (decisiones de estructura, patrones)
- Consume: Stories del Product Owner con AC claros

**Quality gates que aplica:**

- Cada servicio tiene JSDoc en funciones publicas
- Error handling con mensajes descriptivos (nunca `throw new Error("error")`)
- Async/await en toda la capa de datos
- Validacion de inputs en la capa de servicio (no solo en routes)
- Logging estructurado en operaciones criticas

---

### 2. Database Expert

| Campo | Detalle |
|-------|---------|
| **Rol** | Database Expert |
| **Tipo de agente** | `database-expert` |
| **Fase activa** | Fase 1 (intenso), Fase 1b (consulta), Fase 2 (consulta) |

**Funciones y responsabilidades:**

- Implementar el schema DDL completo en migrations SQL
- Configurar el Docker container de PostgreSQL (puerto 5433)
- Implementar el migration runner (migrate.js)
- Crear los indexes optimizados para los patrones de query
- Implementar el connection pool (pool.js) con configuracion apropiada
- Desarrollar el seed data script para los 26 proyectos iniciales
- Optimizar queries que el Backend Developer escribe en repositories
- Crear la migration para agregar campos de github-sync a SBM (Fase 1b)
- Analizar y proponer queries de agregacion para Fase 2

**Tareas clave:**

| Tarea | Fase | Prioridad | Estimacion |
|-------|------|-----------|------------|
| Docker setup PostgreSQL (puerto 5433, volume, restart policy) | Fase 1 | Critical | 1h |
| pool.js (connection pool configuration) | Fase 1 | Critical | 1h |
| 001_initial_schema.sql (tablas, constraints, indexes) | Fase 1 | Critical | 3h |
| migrate.js (migration runner) | Fase 1 | Critical | 2h |
| Seed data script (26 proyectos) | Fase 1 | High | 3h |
| Index tuning post-implementacion | Fase 1 | Medium | 2h |
| Migration SBM: agregar github sync fields | Fase 1b | High | 2h |
| Queries de agregacion cross-project | Fase 2 | High | 3h |
| Performance testing con 200 proyectos | Fase 2 | Medium | 2h |

**Dependencias:**

- Depende de: Architecture Advisor (schema design aprobado)
- Bloqueante para: Backend Developer (necesita schema migrado para escribir repositories)
- Bloqueante para: MCP Server Developer (necesita queries para implementar tools)

**Quality gates que aplica:**

- Toda migration es idempotente (IF NOT EXISTS, ON CONFLICT DO NOTHING)
- Indexes justificados por patrones de query documentados
- Connection pool con limites configurados (no unlimited connections)
- Constraints a nivel de DB (CHECK, UNIQUE, FK) ademas de validacion en codigo
- Seed data es reversible (tiene DELETE o TRUNCATE correspondiente)

---

### 3. MCP Server Developer

| Campo | Detalle |
|-------|---------|
| **Rol** | MCP Server Developer |
| **Tipo de agente** | `mcp-server-developer` |
| **Fase activa** | Fase 1, Fase 1b, Fase 2 |

**Funciones y responsabilidades:**

- Implementar el MCP server entry point (index.js) usando @modelcontextprotocol/sdk
- Desarrollar todos los MCP tools definidos en SEED_DOCUMENT.md (prefijo `pa_`)
- Definir input schemas con Zod para cada tool
- Implementar respuestas consistentes (JSON formateado en content blocks)
- Mantener consistencia con el patron de tools de Sprint Backlog Manager (referencia: SBM tools)
- Implementar los tools de github-sync en Sprint Backlog Manager (Fase 1b)
- Desarrollar los tools de integracion cross-service (Fase 2)
- Documentar cada tool con descripcion clara y ejemplos de uso

**Tareas clave:**

| Tarea | Fase | Prioridad | Estimacion |
|-------|------|-----------|------------|
| MCP server setup (index.js, McpServer instance) | Fase 1 | Critical | 2h |
| pa_list_projects + pa_get_project | Fase 1 | Critical | 2h |
| pa_create_project + pa_update_project + pa_delete_project | Fase 1 | Critical | 3h |
| pa_scan_directory + pa_scan_all | Fase 1 | High | 3h |
| pa_project_health | Fase 1 | High | 2h |
| pa_search_projects | Fase 1 | High | 2h |
| pa_add_relationship + pa_get_relationships | Fase 1 | Medium | 2h |
| pa_set_metadata + pa_get_ecosystem_stats | Fase 1 | Medium | 2h |
| Tools index.js (registro centralizado de todos los tools) | Fase 1 | High | 1h |
| SBM tools: sync_to_github, pull_from_github | Fase 1b | High | 4h |
| pa_project_overview (cross-service) | Fase 2 | High | 3h |
| pa_active_sprints + pa_active_sessions | Fase 2 | High | 3h |
| pa_ecosystem_health (cross-service) | Fase 2 | Medium | 2h |

**Dependencias:**

- Depende de: Backend Developer (servicios implementados que los tools invocaran)
- Depende de: Database Expert (schema listo, para que los servicios funcionen)
- Coordinacion con: Backend Developer (compartir la capa de servicios, no duplicar logica)

**Quality gates que aplica:**

- Toda tool tiene `description` clara y util para Claude Code
- Input schemas con Zod y descriptions en cada campo
- Respuestas en formato `{ content: [{ type: 'text', text: JSON.stringify(...) }] }`
- Error handling que retorna `isError: true` con mensaje descriptivo
- Prefijo `pa_` en todas las tools para evitar colisiones con otros MCP servers
- Cada tool invoca un servicio, nunca accede directamente a la DB

---

### 4. Test Engineer

| Campo | Detalle |
|-------|---------|
| **Rol** | Test Engineer |
| **Tipo de agente** | `test-engineer` |
| **Fase activa** | Fase 1 (continuo), Fase 1b, Fase 2 |

**Funciones y responsabilidades:**

- Disenar la estrategia de testing (unit, integration, E2E)
- Implementar test helpers (test database setup/teardown, fixtures, mocks)
- Escribir tests unitarios para la capa de servicios
- Escribir tests de integracion para REST API endpoints (Fastify inject)
- Escribir tests de integracion para MCP tools
- Validar acceptance criteria de cada story con tests automatizados
- Implementar tests para el filesystem scanner (con mocked filesystem)
- Verificar que la seed data se carga correctamente
- Medir y reportar test coverage (target: >70% en services, >60% overall)

**Tareas clave:**

| Tarea | Fase | Prioridad | Estimacion |
|-------|------|-----------|------------|
| Test infrastructure (jest config, test helpers, test DB) | Fase 1 | Critical | 3h |
| Test fixtures (mock projects, mock filesystem) | Fase 1 | Critical | 2h |
| Unit tests: project-service | Fase 1 | High | 3h |
| Unit tests: scan-service (mocked fs) | Fase 1 | High | 3h |
| Unit tests: health-service (mocked git) | Fase 1 | High | 2h |
| Unit tests: tag, relationship, metadata services | Fase 1 | Medium | 3h |
| Integration tests: REST API endpoints | Fase 1 | High | 4h |
| Integration tests: MCP tools | Fase 1 | High | 3h |
| Integration tests: database queries | Fase 1 | Medium | 2h |
| Tests: github-sync migrated service | Fase 1b | High | 3h |
| Tests: integration layer SBM + CO | Fase 2 | High | 4h |
| Coverage report y gap analysis | Cada fase | Medium | 1h |

**Dependencias:**

- Depende de: Database Expert (test DB setup, schema)
- Depende de: Backend Developer (servicios a testear)
- Depende de: MCP Server Developer (tools a testear)
- Bloqueante para: Code Reviewer (tests deben pasar antes de review)

**Quality gates que aplica:**

- Build completo antes de testing (`npm test`, nunca `--no-build`)
- Coverage >70% en capa de servicios
- Coverage >60% overall
- Tests de integracion usan test database separada (no production)
- Cada AC tiene al menos 1 test automatizado
- Tests son deterministas (no dependen de estado externo, orden, o timing)
- Test names descriptivos: `should [expected behavior] when [condition]`

---

### 5. Code Reviewer

| Campo | Detalle |
|-------|---------|
| **Rol** | Code Reviewer |
| **Tipo de agente** | `code-reviewer` |
| **Fase activa** | Todas las fases (antes de cada merge) |

**Funciones y responsabilidades:**

- Ejecutar code review riguroso (harsh reviewer) antes de cada merge
- Verificar que el codigo sigue las convenciones definidas (ESM, naming, async/await)
- Validar error handling: no errores silenciosos, mensajes descriptivos
- Buscar vulnerabilidades de seguridad (SQL injection, path traversal en scanner)
- Verificar que no hay duplicacion de logica entre REST API y MCP tools
- Validar que los tests cubren los cambios
- Verificar que el codigo es mantenible y legible
- Proponer mejoras concretas (no solo senalar problemas)
- Rechazar PRs que no cumplen quality gates

**Tareas clave:**

| Tarea | Fase | Prioridad | Estimacion |
|-------|------|-----------|------------|
| Review: schema DDL y migraciones | Fase 1 | Critical | 1h |
| Review: capa de repositorios | Fase 1 | High | 2h |
| Review: capa de servicios | Fase 1 | High | 2h |
| Review: REST API routes | Fase 1 | High | 2h |
| Review: MCP tools | Fase 1 | High | 2h |
| Review: filesystem scanner | Fase 1 | High | 1h |
| Review: github-sync migration | Fase 1b | High | 1h |
| Review: integration layer | Fase 2 | High | 2h |
| Review final pre-release por fase | Cada fase | Critical | 3h |

**Dependencias:**

- Depende de: Test Engineer (tests deben pasar antes del review)
- Depende de: Backend Developer + MCP Developer (codigo listo para review)
- Bloqueante para: Merge a develop/main

**Quality gates que aplica (checklist de review):**

```
Correctitud:
- [ ] El codigo hace lo que dice el AC de la story
- [ ] Edge cases manejados (null, empty, invalid input)
- [ ] Error handling con mensajes utiles
- [ ] No hay errores silenciosos (catch vacio)

Seguridad:
- [ ] No SQL injection (queries parametrizadas)
- [ ] No path traversal en scan-service (validar paths)
- [ ] No secrets en codigo (todo en .env)
- [ ] Input validation en entry points (routes y MCP tools)

Mantenibilidad:
- [ ] Funciones de <50 lineas
- [ ] Single responsibility en cada modulo
- [ ] Naming claro y consistente
- [ ] JSDoc en funciones publicas
- [ ] No duplicacion de logica

Performance:
- [ ] Queries no hacen N+1
- [ ] Bulk operations donde corresponde
- [ ] No lectura innecesaria de filesystem en cada request

Consistencia:
- [ ] Sigue patrones de SBM (estructura, naming, error format)
- [ ] ESM imports consistentes
- [ ] Formato de respuesta estandar en REST y MCP
```

---

### 6. DevOps Engineer

| Campo | Detalle |
|-------|---------|
| **Rol** | DevOps Engineer |
| **Tipo de agente** | `devops-engineer` |
| **Fase activa** | Fase 1 (setup), Fase 2+ (CI/CD) |

**Funciones y responsabilidades:**

- Configurar el Docker container de PostgreSQL (coordinado con Database Expert)
- Crear el .env.example con todas las variables necesarias
- Configurar .gitignore apropiado
- Disenar el proceso de startup (como levantar el proyecto desde cero)
- Crear scripts de utilidad en package.json (start, dev, test, migrate, seed)
- Configurar ESLint y Prettier
- Documentar el README con instrucciones de setup completas
- Preparar el registro del MCP server en la configuracion de Claude Code
- En Fase 2+: configurar CI/CD si se necesita (GitHub Actions)

**Tareas clave:**

| Tarea | Fase | Prioridad | Estimacion |
|-------|------|-----------|------------|
| Docker PostgreSQL setup y documentacion | Fase 1 | Critical | 1h |
| .env.example + .gitignore | Fase 1 | Critical | 0.5h |
| package.json scripts (start, dev, test, migrate, seed) | Fase 1 | High | 1h |
| ESLint + Prettier config | Fase 1 | Medium | 1h |
| README.md con instrucciones de setup | Fase 1 | High | 2h |
| MCP server registration en Claude Code config | Fase 1 | Critical | 0.5h |
| npm scripts para MCP + REST server en paralelo | Fase 1 | Medium | 1h |
| GitHub Actions workflow (CI) | Fase 2+ | Medium | 3h |

**Dependencias:**

- Coordinacion con: Database Expert (Docker setup compartido)
- Bloqueante para: Todos (el setup del proyecto debe estar listo primero)

**Quality gates que aplica:**

- Docker container arranca sin errores
- `npm install && npm run migrate && npm start` funciona desde cero
- .env.example tiene TODAS las variables documentadas
- README tiene seccion de "Quick Start" que funciona en <5 minutos
- MCP server se registra y responde a tools desde Claude Code

---

### 7. Architecture Advisor

| Campo | Detalle |
|-------|---------|
| **Rol** | Architecture Advisor (durante desarrollo) |
| **Tipo de agente** | `software-architect` |
| **Fase activa** | Todas (consulta on-demand) |

**Funciones y responsabilidades:**

- Resolver dudas arquitectonicas durante la implementacion
- Validar que las decisiones de implementacion son consistentes con la arquitectura
- Intervenir cuando un desarrollador encuentra un patron no previsto
- Proponer refactorings cuando se detecta desviacion de la arquitectura
- Mediar cuando hay conflicto entre simplicidad y extensibilidad
- Guiar la estructura de la capa de integracion en Fase 2

**Tareas clave:**

| Tarea | Fase | Trigger | Estimacion |
|-------|------|---------|------------|
| Validar estructura de carpetas del proyecto | Fase 1 | Al inicio | 1h |
| Resolver: Fastify vs Express decision final | Fase 1 | Al inicio | 1h |
| Guiar: como compartir servicios entre REST y MCP | Fase 1 | Durante impl. | 1h |
| Resolver: patron de caching para scan results | Fase 1 | Cuando se implemente | 1h |
| Disenar: integration layer architecture | Pre-Fase 2 | Al planificar | 2h |
| Resolver: como manejar failures de servicios downstream | Fase 2 | Durante impl. | 1h |
| Validar: no se creo acoplamiento indebido entre servicios | Fase 2 | Post-impl. | 1h |

**Dependencias:**

- Consultado por: Backend Developer, MCP Server Developer, Database Expert
- Produce decisiones que afectan a todo el equipo
- No tiene dependencias bloqueantes propias

**Quality gates que aplica:**

- Separacion de capas respetada (routes -> services -> repositories -> DB)
- No hay logica de negocio en controllers/routes
- No hay acceso directo a DB desde tools/routes
- Principio de extension sin eliminacion respetado
- Single entry point por tipo de interfaz (1 MCP server, 1 REST server)

---

## Flujo de Trabajo del Equipo

### Orden de Ejecucion por Story

```
1. DevOps Engineer     → Setup inicial (solo Fase 1, sprint 1)
2. Database Expert     → Migraciones necesarias para la story
3. Backend Developer   → Repositories + Services
4. MCP Server Dev      → Tools que consumen los services (en paralelo parcial con 3)
5. Backend Developer   → REST API routes (en paralelo con 4)
6. Test Engineer       → Tests unitarios + integracion
7. Code Reviewer       → Review riguroso
8. [Merge]             → Si aprobado, merge a develop
```

### Paralelismo Posible

```
Sprint tipico (2 stories en paralelo):

Story A (WT principal):
  DB Expert → Backend Dev → MCP Dev ──────────────► Test ► Review
                                                      │
Story B (WT secundario, si independiente):            │
  DB Expert → Backend Dev → REST routes ──► Test ► Review
                                              │
                                              └──► Merge coordinado
```

### Comunicacion entre Roles

```
Backend Developer ◄──────► MCP Server Developer
    │ Comparten la capa de servicios.
    │ Ambos invocan services, ninguno accede directo a DB.
    │
    ├──► Database Expert
    │    Le pide optimizacion de queries o nuevas migraciones.
    │
    ├──► Architecture Advisor
    │    Consulta cuando encuentra patron no previsto.
    │
    └──► Test Engineer
         Recibe tests que validan su implementacion.

Code Reviewer ◄──── Todos
    Revisa todo el codigo antes del merge.
    Puede pedir cambios a cualquier rol.

DevOps Engineer ──► Todos
    Provee la infraestructura que todos usan.
    Mantiene scripts y configuracion.
```

---

## Matriz de Dependencias

| Rol | Depende de | Es bloqueante para |
|-----|-----------|---------------------|
| DevOps Engineer | (ninguno en runtime) | Todos (setup inicial) |
| Database Expert | Architecture Advisor (schema approval) | Backend Dev, MCP Dev (schema) |
| Backend Developer | DB Expert (schema), Architect (decisiones) | MCP Dev (servicios), Test Eng (codigo) |
| MCP Server Developer | Backend Dev (servicios) | Test Eng (tools) |
| Test Engineer | Backend Dev + MCP Dev (codigo) | Code Reviewer (tests pasan) |
| Code Reviewer | Test Engineer (tests) | Merge |
| Architecture Advisor | (ninguno) | (consulta, no bloqueante directo) |

---

## Quality Gates Globales (aplican a todo el equipo)

### Antes de considerar una story "Done":

1. **Build:** 0 errores, 0 warnings (`npm run build` o equivalente)
2. **Tests:** Todos pasan (`npm test`)
3. **Coverage:** >70% en servicios nuevos/modificados
4. **Review:** Code review aprobado por `code-reviewer` (modo riguroso)
5. **AC:** Todos los acceptance criteria validados con evidencia
6. **Docs:** JSDoc en funciones publicas, README actualizado si cambio setup
7. **No regressions:** Tests existentes siguen pasando

### Antes de considerar una fase "Done":

1. Todas las stories de la fase estan Done
2. Seed data cargado y verificado (Fase 1)
3. Tests E2E del flujo completo (scan -> register -> query -> health)
4. Documentacion actualizada (README, API docs)
5. Demo funcional al usuario

---

## Template de Delegacion para Agentes

Cuando Claude (coordinador) delega trabajo a un agente de este equipo, usa este formato:

```markdown
## Delegacion a [Rol]

**Objetivo:** [Que lograr, en una oracion]
**Path:** C:/mcp/project-admin/
**Story:** [PA-XXX: titulo]

### Contexto
[Que necesita saber del sistema, como encaja este trabajo]

### Tareas
1. [Tarea especifica con nombres de archivos]
2. [Tarea especifica con nombres de clases/funciones]
3. [...]

### Specs
- Archivo: [ruta exacta]
- Funcion/clase: [nombre exacto]
- Schema: [contenido del schema si aplica]
- Interfaz: [firma de funciones que debe implementar]

### Restricciones
- NO modificar [archivos/modulos que no debe tocar]
- NO [antipatrones a evitar]
- Usar [patrones especificos]

### Criterios de Exito
- [ ] [Condicion verificable 1]
- [ ] [Condicion verificable 2]
- [ ] Build con 0 errores, 0 warnings
- [ ] Tests existentes siguen pasando
```

---

**Documento creado:** 2026-02-12
**Relacionado con:** SEED_DOCUMENT.md, TEAM_PLANNING.md
