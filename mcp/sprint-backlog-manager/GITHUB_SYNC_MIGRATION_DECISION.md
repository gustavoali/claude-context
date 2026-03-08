# Decision: Migracion de GitHub Sync a Sprint Backlog Manager

**Fecha:** 2026-02-12
**Autor:** Claude (coordinacion)
**Estado:** PENDIENTE DE EJECUCION
**Origen:** `C:/mcp/sprint-tracker/src/github-sync.js` (325 lineas)
**Destino:** `C:/mcp/sprint-backlog-manager/`

---

## 1. Contexto

Sprint Backlog Manager (SBM) es la evolucion de Sprint Tracker: reemplaza la persistencia JSON por PostgreSQL, expone funcionalidad via MCP tools, y agrega soporte multi-proyecto, epics, metricas de velocity/burndown, y technical debt CRUD completo.

Sin embargo, SBM **no tiene GitHub sync**, que es la unica funcionalidad diferenciadora que Sprint Tracker todavia provee. Ademas, Sprint Tracker tiene dos features menores sin equivalente en SBM: terminal kanban board y markdown export.

**Decision tomada:** Migrar github-sync a SBM. Una vez completada la migracion (y opcionalmente las features secundarias), Sprint Tracker pasa a estado de deprecacion.

---

## 2. Analisis del Modulo github-sync.js

### 2.1 Funciones Exportadas

| Funcion | Lineas | Descripcion | Patron |
|---------|--------|-------------|--------|
| `checkGhCli()` | 13-20 | Verifica que `gh` CLI esta instalado | `execSync` con try/catch |
| `getRepoInfo()` | 23-34 | Extrae owner/repo del remote origin de git | Regex sobre output de `git remote` |
| `createIssue(task, repoInfo, labels)` | 37-118 | Crea GitHub Issue desde una task | `spawnSync` con body markdown |
| `closeIssue(issueNumber, repoInfo)` | 121-129 | Cierra un issue por numero | `execSync` |
| `reopenIssue(issueNumber, repoInfo)` | 132-140 | Reabre un issue por numero | `execSync` |
| `getIssueStatus(issueNumber, repoInfo)` | 143-154 | Obtiene state y title de un issue | `gh issue view --json` |
| `addToProject(issueUrl, projectNumber, owner)` | 157-167 | Agrega issue a un GitHub Project | `gh project item-add` |
| `listProjectItems(projectNumber, owner)` | 170-180 | Lista items de un GitHub Project | `gh project item-list --format json` |
| `syncToGitHub(data, config, options)` | 183-266 | Orquestacion: push masivo de tasks a issues | Itera tasks, crea/actualiza/cierra |
| `pullFromGitHub(data, config)` | 269-311 | Pull: actualiza status local desde issues | Itera tasks con githubIssue |

### 2.2 Dependencias Externas

- **`gh` CLI** (GitHub CLI): Dependencia obligatoria. Todas las operaciones de GitHub se ejecutan via `gh` (no API REST directa).
- **`child_process`**: `execSync` y `spawnSync` para ejecutar comandos `gh`.
- **`git`**: Se usa `git remote get-url origin` para detectar owner/repo.

### 2.3 Patrones Relevantes

- **Ejecucion sincronica:** Todo usa `execSync`/`spawnSync`. En la migracion a SBM, esto debe convertirse a **async** usando `child_process.exec` con promesas o `execa`.
- **Deteccion de repo:** Se asume un unico repositorio Git local. En SBM (multi-proyecto), el repo info deberia ser **configurable por proyecto**, no detectado automaticamente.
- **Labels automaticos:** Crea labels por priority y type (`priority:critical`, `type:feature`). Usa `gh label create` con fire-and-forget.
- **Body markdown:** Genera body del issue con metadata de la task (type, priority, points, sprint, AC, notes).
- **Bidireccional parcial:** Push crea/cierra/reabre issues. Pull solo marca tasks como done si el issue se cerro. Pull **no reabre** tasks automaticamente (solo advierte).

### 2.4 Campos en DB ya Existentes

La tabla `stories` en SBM **ya tiene** las columnas necesarias:

```sql
github_issue    INTEGER,        -- Numero del issue
github_url      VARCHAR(500),   -- URL completa del issue
```

Ademas, `ALLOWED_UPDATE_FIELDS` en story-repository.js ya incluye `github_issue` y `github_url`. Esto significa que el schema no necesita migracion adicional para la funcionalidad basica.

---

## 3. Funcionalidades a Migrar

### 3.1 Push: Crear Issues desde Stories (PRIORIDAD ALTA)

**Que hace:** Toma stories del backlog/sprint y crea GitHub Issues correspondientes.

**Adaptaciones necesarias:**
- Reemplazar `task` por `story` (mapeo de campos: `external_id`, `title`, `type`, `priority`, `points`, `sprint_id`, `owner`, `branch`, `acceptance_criteria`, `technical_notes`).
- Sprint info: en Sprint Tracker es un string (`task.sprint`). En SBM es una FK a la tabla `sprints`. Hacer JOIN para incluir sprint number/dates en el body.
- Linked technical debt: `task.linkedTD` no existe directamente en stories. Consultar `technical_debt` donde `linked_story_id = story.id`.
- repo info: hacer configurable via `projects.config` (JSONB) en lugar de detectar con `git remote`. Ejemplo: `config.github = { owner, repo, projectNumber }`.
- Usar async/await en lugar de sync.
- Actualizar `github_issue` y `github_url` en DB despues de crear el issue.

**Filtros soportados:**
- Por sprint (sprint activo por default).
- Por status (solo stories en cierto estado).
- Solo stories sin github_issue (skip las ya sincronizadas).

### 3.2 Pull: Actualizar Status desde GitHub (PRIORIDAD ALTA)

**Que hace:** Para cada story con `github_issue`, consulta el estado del issue y actualiza la story si cambio.

**Adaptaciones necesarias:**
- Consultar stories con `github_issue IS NOT NULL` para el proyecto.
- Si issue CLOSED y story no esta en `done` -> mover story a `done` (usar `storyService.move()`).
- Si issue OPEN y story en `done` -> **advertir**, no mover automaticamente (mantener comportamiento actual).
- Registrar `completed_at` al marcar como done (ya lo hace story-repository).

### 3.3 Link: Vincular Story a Issue Existente (PRIORIDAD MEDIA)

**Que hace:** Asocia manualmente una story con un issue existente por numero.

**Adaptaciones necesarias:**
- Recibir `story_id` (o `external_id`) + `issue_number`.
- Construir URL a partir de la config del proyecto (`config.github.owner`/`config.github.repo`).
- Actualizar `github_issue` y `github_url` en la story.
- Opcionalmente: verificar que el issue existe (via `gh issue view`) antes de guardar.

### 3.4 Status Sync: Close/Reopen Issues (PRIORIDAD ALTA)

**Que hace:** Cuando una story cambia a `done`, cierra el issue correspondiente. Si sale de `done`, reabre el issue.

**Adaptaciones necesarias:**
- Puede integrarse directamente en `storyService.update()` o `storyService.move()` como side-effect post-update.
- Alternativa: hook independiente que se invoca explicitamente (mas seguro, evita side-effects inesperados).
- Decision recomendada: **operacion explicita via MCP tool**, no automatica. El usuario debe invocar `github_push` para sincronizar cambios.

### 3.5 GitHub Projects Integration (PRIORIDAD BAJA)

**Que hace:** Agrega issues a un GitHub Project board y lista items del project.

**Adaptaciones necesarias:**
- `projectNumber` configurable por proyecto en `projects.config`.
- `addToProject` y `listProjectItems` como operaciones auxiliares.
- Puede exponerse como herramienta separada o como opcion del push.

---

## 4. Funcionalidades Opcionales (No GitHub, del Sprint Tracker)

### 4.1 Terminal Kanban Board (PRIORIDAD BAJA)

**Que hace:** Sprint Tracker (`cmdBoard`, lineas 152-210) muestra un board en terminal con columnas ASCII, colores ANSI, iconos de prioridad, y un resumen de progreso.

**Estado en SBM:** SBM tiene `get_sprint_board` como MCP tool, pero no tiene output formateado para terminal. El CLI (`src/cli.js`) esta en fase pendiente (Fase 7).

**Recomendacion:** Implementar como parte de la Fase 7 (CLI). No es bloqueante para deprecar Sprint Tracker ya que SBM expone la misma data via MCP tools.

### 4.2 Markdown Export (PRIORIDAD BAJA)

**Que hace:** Sprint Tracker (`cmdGenerate`, lineas 418-481) genera un archivo `SPRINT_BOARD.md` con tabla kanban markdown, detalles de tasks, y resumen de progreso.

**Estado en SBM:** No existe. El resource `project:///{id}/board` provee data similar pero como JSON, no como markdown formateado.

**Recomendacion:** Implementar como un MCP tool adicional (`export_sprint_markdown`) o como comando CLI. Reutilizar la data del sprint board y formatear a markdown. Baja prioridad - los LLM consumidores de MCP no necesitan markdown export.

---

## 5. Plan de Migracion

### Fase 1: Configuracion de GitHub por Proyecto

**Objetivo:** Permitir que cada proyecto tenga su configuracion de GitHub.

**Cambios:**
1. Agregar esquema esperado en `projects.config` (JSONB):
   ```json
   {
     "github": {
       "owner": "string (GitHub username/org)",
       "repo": "string (repository name)",
       "projectNumber": "number (optional, GitHub Project number)",
       "defaultLabels": ["array of default labels"]
     }
   }
   ```
2. No requiere migracion de DB (config ya es JSONB libre).
3. Agregar MCP tool `configure_project_github` o reutilizar `update_project` para setear estos campos.

### Fase 2: GitHub Service Layer

**Objetivo:** Encapsular toda la logica de interaccion con GitHub.

**Archivos nuevos:**
- `src/services/github-service.js` - Logica de negocio de sync.
- `src/utils/github-cli.js` - Wrapper async del `gh` CLI.

**Responsabilidades de `github-cli.js`:**
- `checkGhCli()` -> async, con cache del resultado.
- `createIssue(owner, repo, title, body, labels)` -> async.
- `closeIssue(owner, repo, number)` -> async.
- `reopenIssue(owner, repo, number)` -> async.
- `getIssueStatus(owner, repo, number)` -> async, retorna `{ state, title }`.
- `addToProject(url, projectNumber, owner)` -> async.
- `listProjectItems(projectNumber, owner)` -> async.

Patron recomendado: usar `child_process.execFile` con `util.promisify` para evitar shell injection y mantener async.

**Responsabilidades de `github-service.js`:**
- `pushStories(projectId, options)` - Orquesta push de stories a issues.
- `pullStatuses(projectId)` - Orquesta pull de status de issues.
- `linkStoryToIssue(storyId, issueNumber)` - Vincula story con issue.
- `syncStatus(storyId)` - Sync bidireccional para una story individual.

### Fase 3: MCP Tools

**Objetivo:** Exponer funcionalidad de GitHub sync como herramientas MCP.

**Archivo nuevo:** `src/mcp/tools/github.js`

**Registrar en:** `src/index.js` (agregar `registerGitHubTools(server)`)

### Fase 4: Testing

**Objetivo:** Tests unitarios para github-service y github-cli.

- Mock de `child_process.execFile` para simular respuestas de `gh`.
- Tests de integracion con `gh` real (opcional, requiere token).

### Fase 5: CLI (opcional, baja prioridad)

**Objetivo:** Comandos CLI equivalentes a los MCP tools.

- `sprint-backlog github push [--project <id>] [--sprint-only] [--dry-run]`
- `sprint-backlog github pull [--project <id>]`
- `sprint-backlog github link <story-id> <issue-number>`

---

## 6. Nuevos MCP Tools Sugeridos

| Tool | Params | Descripcion |
|------|--------|-------------|
| `github_push` | `project_id`, `?sprint_only` (bool, default true), `?status` (filter), `?dry_run` (bool) | Crear GitHub Issues para stories sin issue. Sincronizar estado (close/reopen) para stories con issue. Retorna resumen: created, updated, errors. |
| `github_pull` | `project_id` | Actualizar status de stories desde GitHub Issues. Retorna stories actualizadas y advertencias. |
| `github_link` | `story_id`, `issue_number` | Vincular una story a un issue existente. Actualiza github_issue y github_url. |
| `github_sync_status` | `project_id` | Vista de estado de sincronizacion: stories con issue, stories sin issue, issues desactualizados. Solo lectura, no modifica nada. |
| `github_check` | - | Verificar que `gh` CLI esta instalado y autenticado. Retorna version y usuario autenticado. |

### Descripcion detallada de cada tool

**`github_push`:**
- Valida que el proyecto tiene config de GitHub (`config.github.owner` y `config.github.repo`).
- Filtra stories por sprint activo (por default) o todas.
- Para stories **sin** `github_issue`: crea issue, guarda numero/url, agrega a project (si configurado), cierra si status es `done`.
- Para stories **con** `github_issue`: sincroniza estado (done->close, not done->reopen si estaba cerrado).
- `dry_run`: retorna lo que haria sin ejecutar.
- Retorna: `{ created: [...], updated: [...], skipped: [...], errors: [...] }`.

**`github_pull`:**
- Consulta todas las stories con `github_issue IS NOT NULL` para el proyecto.
- Para cada una, obtiene estado del issue.
- Si issue CLOSED y story no done -> mueve a done.
- Si issue OPEN y story done -> advierte (no mueve).
- Retorna: `{ updated: [...], warnings: [...], errors: [...] }`.

**`github_link`:**
- Acepta `story_id` (interno) o `external_id` (e.g., "LTE-005").
- Verifica que el issue existe via `gh issue view`.
- Actualiza `github_issue` y `github_url` en la story.
- Retorna la story actualizada.

**`github_sync_status`:**
- No modifica datos, solo reporta.
- Stories con issue sincronizado (status coincide).
- Stories con issue desincronizado (status difiere).
- Stories sin issue (candidatas a push).
- Retorna resumen categorizado.

**`github_check`:**
- Ejecuta `gh --version` y `gh auth status`.
- Retorna: `{ installed: bool, version: string, authenticated: bool, user: string }`.

---

## 7. Dependencias

### Obligatorias

| Dependencia | Tipo | Notas |
|-------------|------|-------|
| `gh` CLI | Binario externo | Debe estar instalado y autenticado (`gh auth login`). No es un npm package. |
| `git` | Binario externo | Solo si se usa deteccion automatica de repo (no recomendado para SBM). |

### Opcionales (mejoras)

| Dependencia | Tipo | Notas |
|-------------|------|-------|
| `execa` | npm | Wrapper moderno para child_process. Mejor manejo de errores y async. Alternativa: `util.promisify(execFile)` nativo. |

### Autenticacion de GitHub

El CLI `gh` maneja la autenticacion de forma independiente. SBM **no** necesita almacenar tokens ni credenciales. Requisitos:

1. `gh auth login` ejecutado previamente por el usuario.
2. Permisos necesarios: `repo` (para crear/cerrar issues) y `project` (para GitHub Projects).
3. Verificar con `github_check` tool antes de intentar operaciones.

---

## 8. Riesgos y Mitigaciones

| # | Riesgo | Probabilidad | Impacto | Mitigacion |
|---|--------|-------------|---------|------------|
| 1 | `gh` CLI no instalado en el host | Media | Alto (feature inutilizable) | Tool `github_check` con mensaje claro. Documentar en README. Graceful degradation: el resto de SBM funciona sin `gh`. |
| 2 | Rate limiting de GitHub API | Baja (via gh CLI tiene cache) | Medio | Implementar backoff y retry en `github-cli.js`. Para pushes masivos, agregar delay entre calls. |
| 3 | Config de GitHub incorrecta por proyecto | Media | Medio | Validar config al inicio de cada operacion. Retornar error descriptivo si falta `owner` o `repo`. |
| 4 | Conflicto de estado bidireccional | Media | Medio | Pull no reabre stories automaticamente (advertencia). Push es la fuente de verdad para estado. Documentar flujo. |
| 5 | `execSync` -> async migration introduce bugs | Baja | Alto | Tests unitarios con mocks de `child_process`. Respetar exactamente los argumentos de `gh` del modulo original. |
| 6 | Sprint Tracker deprecado antes de migracion completa | Baja | Medio | No deprecar hasta que `github_push`, `github_pull`, y `github_link` esten funcionales y testeados. |
| 7 | GitHub Projects API cambia | Baja | Bajo | GitHub Projects es la feature de menor prioridad. Si cambia, afecta solo `addToProject`/`listProjectItems`. |
| 8 | Multiples proyectos apuntan al mismo repo | Media | Medio | Permitirlo (es valido). Labels y prefijos del external_id distinguen stories. Documentar como best practice. |

---

## 9. Criterios de Exito (Deprecacion de Sprint Tracker)

Sprint Tracker puede pasar a estado **DEPRECATED** cuando se cumplan TODOS estos criterios:

### Obligatorios

- [ ] `github_push` funcional: crea issues, sincroniza estado, agrega a projects.
- [ ] `github_pull` funcional: actualiza status de stories desde issues cerrados/abiertos.
- [ ] `github_link` funcional: vincula stories a issues existentes.
- [ ] `github_sync_status` funcional: vista de estado de sincronizacion.
- [ ] `github_check` funcional: verifica instalacion y autenticacion de gh CLI.
- [ ] Campos `github_issue` y `github_url` correctamente persistidos en PostgreSQL.
- [ ] Config de GitHub almacenada en `projects.config` JSONB.
- [ ] Tests unitarios para github-service y github-cli (>70% coverage).
- [ ] Documentacion de setup y uso en README.

### Opcionales (no bloquean deprecacion)

- [ ] Terminal kanban board en CLI (Fase 7 de SBM).
- [ ] Markdown export como MCP tool o CLI command.
- [ ] Tests de integracion con GitHub real.
- [ ] GitHub Projects integration (addToProject, listProjectItems).

### Proceso de Deprecacion

1. Completar criterios obligatorios.
2. Verificar que datos importados desde Sprint Tracker (via `import-from-json.js`) preservan `github_issue` y `github_url`.
3. Agregar `DEPRECATED` notice en Sprint Tracker README.
4. Mantener Sprint Tracker en `C:/mcp/sprint-tracker/` como referencia durante 3 meses.
5. Despues de 3 meses sin uso, archivar o eliminar.

---

## 10. Estado

**PENDIENTE DE EJECUCION**

**Nota (2026-02-15):** Project Admin (Fase 1b) ahora sincroniza **repo metadata** de GitHub (stars, forks, topics, language, etc.) via `pa_github_sync` / `pa_github_sync_all`. Esto es read-only metadata, NO la sincronizacion bidireccional de stories <-> GitHub Issues descrita en este documento. La migracion de stories/issues desde Sprint Tracker a SBM sigue pendiente.

Este documento describe la decision y el plan. La implementacion se ejecutara cuando el equipo lo priorice. Las fases 1-3 del plan de migracion son las de mayor impacto y deberian ejecutarse como una sola unidad de trabajo (estimacion: 3-5 horas para un agente `nodejs-backend-developer`).

### Proximos pasos al ejecutar

1. Crear historia(s) en el backlog de SBM.
2. Delegar a `nodejs-backend-developer` con este documento como contexto.
3. Delegar tests a `test-engineer`.
4. Review con `code-reviewer` (modo riguroso).
5. Actualizar TASK_STATE.md y ARCHITECTURE.md.

---

**Ultima actualizacion:** 2026-02-12
