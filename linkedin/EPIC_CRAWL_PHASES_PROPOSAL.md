# Epic: Multi-Phase Crawl System

**Version:** 1.0
**Fecha:** 2026-02-02
**Product Owner:** Technical Lead
**Estado:** PROPOSAL

---

## Vision

Transformar el sistema de crawl actual (monolitico, todo-o-nada) en un sistema de **3 fases independientes** que permita:

1. **Visibilidad anticipada**: Ver la estructura completa de cursos antes de capturar contenido
2. **Optimizacion de tiempos**: Crawl paralelo de multiples videos simultaneamente
3. **Mantenimiento evolutivo**: Detectar y versionar cambios en transcripts existentes

Este epic representa una evolucion significativa del sistema de captura, pasando de un modelo "crawl and capture everything" a un modelo "discover, complete, maintain" que ofrece mayor control, visibilidad y eficiencia.

---

## Success Criteria

- **Visibilidad**: Usuario puede ver 100% de la estructura de un curso (capitulos, videos) antes de capturar transcripts
- **Completitud medible**: Flag `isComplete` en cada entidad permite ver porcentaje de completitud de la biblioteca
- **Performance**: Crawl paralelo reduce tiempo total en >50% comparado con secuencial
- **Versionado**: 100% de cambios en transcripts son detectados y versionados
- **API completa**: Todas las operaciones disponibles via HTTP API para integracion con ChatGPT

---

## Contexto Tecnico

### Estado Actual

El sistema actual (v0.14.x) tiene:
- **Crawl monolitico**: `auto-crawler.js` navega curso completo, captura VTTs y hace matching
- **Sin visibilidad previa**: No se puede ver estructura sin ejecutar crawl completo
- **Sin paralelismo**: Videos se procesan secuencialmente
- **Sin versionado**: Transcripts se sobreescriben sin historial

### Schema Actual (SQLite)

```
courses_normalized (id, slug, title, ...)
chapters_normalized (id, course_id, title, order, ...)
videos_normalized (id, chapter_id, slug, title, duration, ...)
transcripts_normalized (id, video_id, content, language, ...)
```

### Cambios Propuestos

Agregar a `videos_normalized`:
- `is_complete: BOOLEAN DEFAULT 0` - Si tiene transcript capturado
- `last_crawled_at: TIMESTAMP` - Ultima vez que se intento capturar

Agregar tabla `transcript_versions`:
- `id, transcript_id, content, language, version, captured_at`
- FK a `transcripts_normalized`

---

## Phase 1: Discovery (Estructura)

### Objetivo

Permitir crawlear SOLO la estructura de un curso (capitulos y videos) sin capturar transcripts, habilitando visibilidad completa de la biblioteca.

### Beneficios

- Ver que cursos/videos estan disponibles antes de invertir tiempo en captura
- Planificar que cursos priorizar
- Medir completitud de la biblioteca

---

### LTE-044: Course Structure Discovery

**As a** content curator
**I want** to crawl only the structure of a course (chapters, videos)
**So that** I can see what content is available before capturing transcripts

**Acceptance Criteria:**

**AC1: Discovery Mode**
- Given a course URL
- When I run `npm run crawl:discover -- --url "URL"`
- Then the system extracts all chapters and videos (metadata only)
- And no VTT capture is attempted
- And execution time is <30 seconds for a 50-video course

**AC2: Data Persistence**
- Given discovery data is extracted
- When persisted to database
- Then `courses_normalized` has the course record
- And `chapters_normalized` has all chapter records with correct order
- And `videos_normalized` has all video records with `is_complete = false`
- And `last_crawled_at` is set to current timestamp

**AC3: Idempotent Operation**
- Given a course already exists in database
- When discovery is run again
- Then existing records are updated (not duplicated)
- And new videos/chapters are added
- And removed videos/chapters are NOT deleted (soft reference)

**AC4: Error Handling**
- Given LinkedIn structure changes or network error
- When discovery fails mid-process
- Then partial data is preserved
- And error is logged with context
- And exit code indicates failure

**Story Points:** 8
**Priority:** Critical
**Dependencies:** None

**Technical Notes:**
- Modificar `auto-crawler.js` para soportar modo `--discovery-only`
- Usar `content.js` extraction logic para metadata sin reproducir videos
- Crear `DiscoveryService` en `modules/crawl/services/`

---

### LTE-045: Completion Status Tracking

**As a** library manager
**I want** to see completion status of courses, chapters, and videos
**So that** I can track progress and identify gaps in my library

**Acceptance Criteria:**

**AC1: Video Completion Flag**
- Given a video in `videos_normalized`
- When it has a matching transcript in `transcripts_normalized`
- Then `is_complete = true`
- And when transcript is missing, `is_complete = false`

**AC2: Chapter Completion Percentage**
- Given a chapter with N videos
- When M videos have `is_complete = true`
- Then `completion_percentage = (M/N) * 100`
- And this is calculated dynamically via SQL view

**AC3: Course Completion Summary**
- Given a course with multiple chapters
- When querying course status
- Then response includes:
  - `total_videos`: Total videos in course
  - `completed_videos`: Videos with transcripts
  - `completion_percentage`: Overall percentage
  - `chapters`: Array with per-chapter completion

**AC4: Library-wide Statistics**
- Given multiple courses in database
- When querying library status
- Then response includes:
  - `total_courses`: Number of courses
  - `total_videos`: Sum of all videos
  - `completed_videos`: Sum of completed
  - `overall_completion`: Percentage
  - Per-language breakdown

**Story Points:** 5
**Priority:** Critical
**Dependencies:** LTE-044

**Technical Notes:**
- Crear vistas SQL: `video_completion_status`, `chapter_completion_summary`, `course_completion_summary`
- Agregar migration `010_completion_tracking.js`
- Actualizar `CourseRepository` con metodos de completion

---

### LTE-046: Discovery API Endpoints

**As a** API consumer (ChatGPT/Claude)
**I want** HTTP endpoints to trigger and query discovery
**So that** I can integrate discovery into conversational workflows

**Acceptance Criteria:**

**AC1: Trigger Discovery**
- Given `POST /api/discovery`
- With body `{ "courseUrl": "https://linkedin.com/learning/..." }`
- Then discovery crawl is triggered asynchronously
- And response includes `{ "jobId": "uuid", "status": "started" }`

**AC2: Query Discovery Status**
- Given `GET /api/discovery/:jobId`
- When job is in progress
- Then response includes `{ "status": "running", "progress": { "chapters": 5, "videos": 23 } }`
- When job is complete
- Then response includes `{ "status": "completed", "courseSlug": "...", "summary": {...} }`

**AC3: Get Completion Status**
- Given `GET /api/completion`
- Then response includes library-wide completion statistics
- Given `GET /api/completion/:courseSlug`
- Then response includes course-specific completion with chapter breakdown

**AC4: List Incomplete Courses**
- Given `GET /api/courses?filter=incomplete`
- Then response includes only courses with `completion_percentage < 100`
- And sorted by completion percentage ascending (least complete first)

**Story Points:** 5
**Priority:** High
**Dependencies:** LTE-044, LTE-045

**Technical Notes:**
- Agregar routes en `modules/api/http/routes/discovery.js`
- Usar job queue pattern (in-memory para MVP, Redis para escala)
- Integrar con Event Bus para progress tracking

---

## Phase 2: Parallel Completion

### Objetivo

Completar el contenido de videos (capturar transcripts) con capacidad de procesamiento paralelo para optimizar tiempos.

### Beneficios

- Reduccion significativa de tiempo total de crawl
- Mejor utilizacion de recursos
- Posibilidad de priorizar videos especificos

---

### LTE-047: Parallel Video Processing

**As a** power user
**I want** to crawl multiple videos in parallel
**So that** I can complete my library faster

**Acceptance Criteria:**

**AC1: Configurable Concurrency**
- Given configuration `CRAWL_CONCURRENCY=N`
- When running completion crawl
- Then up to N videos are processed simultaneously
- And default value is 3 (conservative for LinkedIn rate limits)

**AC2: Browser Tab Management**
- Given N concurrent videos
- When crawling
- Then N browser tabs are opened (one per video)
- And tabs are reused for subsequent videos
- And all tabs share same session/cookies

**AC3: Independent Processing**
- Given video A fails during capture
- When video B and C are also processing
- Then B and C continue independently
- And A is marked as failed with retry capability

**AC4: Resource Cleanup**
- Given parallel crawl completes or is interrupted
- When cleanup runs
- Then all browser tabs are closed
- And memory is released
- And partial progress is persisted

**Story Points:** 13
**Priority:** High
**Dependencies:** LTE-046

**Technical Notes:**
- Refactorizar `auto-crawler.js` para usar worker pool pattern
- Considerar Playwright BrowserContext per-tab para isolation
- Implementar semaphore para controlar concurrency
- Usar p-limit o similar para throttling

---

### LTE-048: Rate Limiting & Throttling

**As a** responsible user
**I want** automatic rate limiting to avoid LinkedIn detection/blocking
**So that** I can crawl sustainably without getting my account banned

**Acceptance Criteria:**

**AC1: Request Rate Limiting**
- Given `CRAWL_REQUESTS_PER_MINUTE=30` (default)
- When requests exceed rate
- Then additional requests are queued
- And processed when rate allows
- And warning is logged

**AC2: Adaptive Throttling**
- Given LinkedIn returns 429 (Too Many Requests)
- When detected
- Then concurrency is automatically reduced by 50%
- And delay between videos is increased to 10 seconds
- And normal rate resumes after 5 minutes without 429

**AC3: Cooldown Periods**
- Given configuration `CRAWL_COOLDOWN_BETWEEN_COURSES=60` (seconds)
- When completing one course and starting another
- Then system waits cooldown period
- And this is logged for transparency

**AC4: Circuit Breaker**
- Given 5 consecutive failures
- When circuit breaker triggers
- Then crawl is paused for 2 minutes
- And notification is logged
- And crawl can be manually resumed

**Story Points:** 8
**Priority:** High
**Dependencies:** LTE-047

**Technical Notes:**
- Implementar circuit breaker pattern en `CrawlService`
- Usar exponential backoff para retries
- Configuracion via environment variables
- Metricas de rate limiting en logs

---

### LTE-049: Progress Tracking for Parallel Crawl

**As a** user monitoring a long crawl
**I want** real-time progress tracking
**So that** I can estimate completion time and identify stuck jobs

**Acceptance Criteria:**

**AC1: Progress Events**
- Given parallel crawl in progress
- When video completes/fails
- Then Event Bus emits `video:completed` or `video:failed`
- And progress is updated in real-time

**AC2: ETA Calculation**
- Given N videos remaining and average time T per video
- When querying progress
- Then ETA is calculated as `(N / concurrency) * T`
- And displayed in human-readable format ("~15 minutes remaining")

**AC3: Progress API**
- Given `GET /api/crawl/:jobId/progress`
- Then response includes:
  - `total_videos`: Total to process
  - `completed`: Successfully captured
  - `failed`: Failed attempts
  - `in_progress`: Currently processing
  - `eta_seconds`: Estimated time remaining
  - `current_rate`: Videos per minute

**AC4: Stuck Detection**
- Given a video takes >5x average processing time
- When detected
- Then warning is logged
- And video is marked as "potentially stuck"
- And optionally: automatic timeout and retry

**Story Points:** 5
**Priority:** Medium
**Dependencies:** LTE-047, LTE-048

**Technical Notes:**
- Usar Event Bus para progress events
- Calcular rolling average para ETA
- WebSocket opcional para real-time updates (future)

---

## Phase 3: Versioning & Updates

### Objetivo

Detectar y gestionar cambios en transcripts existentes, manteniendo historial de versiones.

### Beneficios

- Detectar cuando LinkedIn actualiza contenido de un video
- Mantener historial para comparacion/auditoria
- Sincronizacion periodica automatizada

---

### LTE-050: Transcript Version History

**As a** content analyst
**I want** to keep version history of transcripts
**So that** I can track changes over time and compare versions

**Acceptance Criteria:**

**AC1: Version Table**
- Given new table `transcript_versions`
- Then schema includes:
  - `id`: Primary key
  - `transcript_id`: FK to transcripts_normalized
  - `content`: Full VTT content
  - `content_hash`: SHA-256 of content (for quick comparison)
  - `language`: Language code
  - `version`: Auto-increment per transcript
  - `captured_at`: Timestamp
  - `change_summary`: JSON with diff metadata

**AC2: Automatic Versioning on Update**
- Given transcript already exists
- When new content is captured with different hash
- Then previous content is moved to `transcript_versions`
- And new content replaces current in `transcripts_normalized`
- And `version` is incremented

**AC3: Query Version History**
- Given `GET /api/transcripts/:videoSlug/versions`
- Then response includes list of all versions
- With `version`, `captured_at`, `change_summary`

**AC4: Get Specific Version**
- Given `GET /api/transcripts/:videoSlug/versions/:version`
- Then response includes full content of that version

**Story Points:** 8
**Priority:** Medium
**Dependencies:** LTE-047

**Technical Notes:**
- Crear migration `011_transcript_versions.js`
- Usar SHA-256 para content hashing
- Considerar compresion para versiones antiguas

---

### LTE-051: Change Detection Algorithm

**As a** system administrator
**I want** accurate detection of meaningful changes
**So that** I don't create versions for trivial differences (whitespace, formatting)

**Acceptance Criteria:**

**AC1: Content Normalization**
- Given two VTT contents
- When comparing
- Then whitespace is normalized
- And timestamp format differences are ignored
- And only text content is compared

**AC2: Similarity Threshold**
- Given configuration `VERSION_SIMILARITY_THRESHOLD=0.95`
- When similarity is >= threshold
- Then NO new version is created (considered identical)
- When similarity is < threshold
- Then new version IS created

**AC3: Change Summary Generation**
- Given meaningful change detected
- When creating version
- Then `change_summary` includes:
  - `similarity_score`: Numeric similarity
  - `added_segments`: Count of new segments
  - `removed_segments`: Count of removed segments
  - `modified_segments`: Count of changed segments
  - `change_type`: "minor" | "major" | "restructure"

**AC4: Diff Visualization (API)**
- Given `GET /api/transcripts/:videoSlug/diff?v1=1&v2=2`
- Then response includes structured diff
- With segments marked as added/removed/unchanged

**Story Points:** 8
**Priority:** Medium
**Dependencies:** LTE-050

**Technical Notes:**
- Usar Levenshtein distance o similar para similarity
- Parsear VTT en segmentos para diff granular
- Considerar diff-match-patch library

---

### LTE-052: Scheduled Update Checks

**As a** library maintainer
**I want** automatic periodic checks for updates
**So that** my library stays current without manual intervention

**Acceptance Criteria:**

**AC1: Scheduler Configuration**
- Given configuration `UPDATE_CHECK_SCHEDULE="0 3 * * 0"` (Sundays 3am)
- When schedule triggers
- Then update check runs for all completed courses
- And only checks, does not auto-update

**AC2: Selective Checking**
- Given 100 courses in library
- When scheduled check runs
- Then courses are checked in priority order:
  1. Recently updated (last 30 days on LinkedIn)
  2. Frequently accessed (high query count)
  3. Oldest `last_crawled_at`

**AC3: Update Report**
- Given scheduled check completes
- When results are available
- Then report includes:
  - Courses checked
  - Updates detected (count)
  - Courses needing attention
  - Errors encountered

**AC4: Notification (Optional)**
- Given updates are detected
- When `NOTIFY_ON_UPDATES=true`
- Then notification is sent (log file, webhook, etc.)

**Story Points:** 5
**Priority:** Low
**Dependencies:** LTE-050, LTE-051

**Technical Notes:**
- Usar node-cron para scheduling
- Implementar en `modules/crawl/services/update-scheduler.js`
- Considerar que LinkedIn puede detectar patrones periodicos

---

### LTE-053: Manual Update Trigger

**As a** user
**I want** to manually trigger update check for specific courses
**So that** I can refresh content on-demand when needed

**Acceptance Criteria:**

**AC1: API Trigger**
- Given `POST /api/courses/:courseSlug/check-updates`
- Then update check is triggered for that course
- And response includes job ID for tracking

**AC2: Force Recrawl Option**
- Given `POST /api/courses/:courseSlug/check-updates?force=true`
- Then ALL videos are recrawled regardless of change detection
- And new versions are created if content differs

**AC3: Batch Update Check**
- Given `POST /api/courses/check-updates`
- With body `{ "courseSlugs": ["course-1", "course-2"] }`
- Then update check is triggered for all specified courses
- And response includes job ID

**AC4: CLI Support**
- Given `npm run crawl:check-updates -- --course "course-slug"`
- Then update check runs for specified course
- And `--all` flag checks all courses
- And `--stale 30` flag checks courses not crawled in 30 days

**Story Points:** 3
**Priority:** Low
**Dependencies:** LTE-050, LTE-051

**Technical Notes:**
- Reutilizar logica de LTE-052
- Integrar con progress tracking de LTE-049

---

## Dependency Map

```
Phase 1: Discovery
-----------------
LTE-044 (Course Structure Discovery)
    |
    v
LTE-045 (Completion Status Tracking)
    |
    v
LTE-046 (Discovery API Endpoints)

Phase 2: Parallel Completion
----------------------------
LTE-046 -----> LTE-047 (Parallel Video Processing)
                   |
                   v
               LTE-048 (Rate Limiting & Throttling)
                   |
                   v
               LTE-049 (Progress Tracking)

Phase 3: Versioning & Updates
-----------------------------
LTE-047 -----> LTE-050 (Transcript Version History)
                   |
                   v
               LTE-051 (Change Detection Algorithm)
                   |
                   +-------+-------+
                   |               |
                   v               v
               LTE-052         LTE-053
               (Scheduled)     (Manual)
```

### Dependency Summary

| Story | Depends On |
|-------|------------|
| LTE-044 | None |
| LTE-045 | LTE-044 |
| LTE-046 | LTE-044, LTE-045 |
| LTE-047 | LTE-046 |
| LTE-048 | LTE-047 |
| LTE-049 | LTE-047, LTE-048 |
| LTE-050 | LTE-047 |
| LTE-051 | LTE-050 |
| LTE-052 | LTE-050, LTE-051 |
| LTE-053 | LTE-050, LTE-051 |

---

## ID Registry Update

| ID | Descripcion | Status |
|----|-------------|--------|
| LTE-044 | Course Structure Discovery | Proposed |
| LTE-045 | Completion Status Tracking | Proposed |
| LTE-046 | Discovery API Endpoints | Proposed |
| LTE-047 | Parallel Video Processing | Proposed |
| LTE-048 | Rate Limiting & Throttling | Proposed |
| LTE-049 | Progress Tracking for Parallel Crawl | Proposed |
| LTE-050 | Transcript Version History | Proposed |
| LTE-051 | Change Detection Algorithm | Proposed |
| LTE-052 | Scheduled Update Checks | Proposed |
| LTE-053 | Manual Update Trigger | Proposed |

**Proximo ID disponible:** LTE-054

---

## Estimacion Total

| Phase | Stories | Story Points | Sprints Estimados* |
|-------|---------|--------------|-------------------|
| Phase 1: Discovery | 3 | 18 | 0.8 |
| Phase 2: Parallel | 3 | 26 | 1.2 |
| Phase 3: Versioning | 4 | 24 | 1.0 |
| **TOTAL** | **10** | **68** | **~3 sprints** |

*Asumiendo 1 developer, 25 story points/sprint de capacity

---

## Priorizacion MoSCoW

### Must Have (MVP)

Minimo viable para entregar valor:

| ID | Historia | Story Points |
|----|----------|--------------|
| LTE-044 | Course Structure Discovery | 8 |
| LTE-045 | Completion Status Tracking | 5 |
| LTE-046 | Discovery API Endpoints | 5 |
| **Total Must Have** | | **18 pts** |

### Should Have

Valor significativo, prioridad alta post-MVP:

| ID | Historia | Story Points |
|----|----------|--------------|
| LTE-047 | Parallel Video Processing | 13 |
| LTE-048 | Rate Limiting & Throttling | 8 |
| **Total Should Have** | | **21 pts** |

### Could Have

Valor agregado, si hay capacity:

| ID | Historia | Story Points |
|----|----------|--------------|
| LTE-049 | Progress Tracking | 5 |
| LTE-050 | Transcript Version History | 8 |
| LTE-051 | Change Detection Algorithm | 8 |
| **Total Could Have** | | **21 pts** |

### Won't Have (This Release)

Diferido para version futura:

| ID | Historia | Story Points |
|----|----------|--------------|
| LTE-052 | Scheduled Update Checks | 5 |
| LTE-053 | Manual Update Trigger | 3 |
| **Total Won't Have** | | **8 pts** |

---

## Riesgos y Mitigaciones

### R1: LinkedIn Rate Limiting / Detection

**Probabilidad:** Alta
**Impacto:** Alto (bloqueo de cuenta)

**Mitigacion:**
- LTE-048 implementa rate limiting proactivo
- Crawl con delays configurables
- Circuito breaker ante errores
- Usar sesion real de usuario (no bots)

### R2: Complejidad de Paralelismo

**Probabilidad:** Media
**Impacto:** Medio (bugs, race conditions)

**Mitigacion:**
- Tests exhaustivos para concurrency
- Empezar con concurrency=2, escalar gradualmente
- Logging detallado para debugging

### R3: Schema Migration con Data Existente

**Probabilidad:** Baja
**Impacto:** Alto (perdida de datos)

**Mitigacion:**
- Backup automatico antes de migration
- Migrations reversibles
- Testing en copia de DB real

### R4: Cambios en LinkedIn DOM

**Probabilidad:** Media (cada 3-6 meses)
**Impacto:** Alto (rompe discovery)

**Mitigacion:**
- Ya resuelto en LTE-007 (CSS Selectors Resistentes)
- Multiples fallback selectors
- Health check de selectors

---

## Metricas de Exito

### Phase 1 Metrics

| Metrica | Target |
|---------|--------|
| Discovery time (50 videos) | <30 segundos |
| Completion % accuracy | 100% |
| API response time | <200ms |

### Phase 2 Metrics

| Metrica | Target |
|---------|--------|
| Crawl time reduction | >50% vs secuencial |
| Concurrent videos | 3-5 estable |
| Rate limit incidents | <1 por sesion |

### Phase 3 Metrics

| Metrica | Target |
|---------|--------|
| Change detection accuracy | >95% |
| Version storage overhead | <20% adicional |
| Scheduled check reliability | 100% uptime |

---

## Proximos Pasos

1. **Revision de Propuesta**: Usuario revisa y aprueba historias
2. **Ajuste de Prioridades**: Confirmar MoSCoW con stakeholder
3. **Importar a Backlog**: Mover historias aprobadas a PRODUCT_BACKLOG.md
4. **Sprint Planning**: Seleccionar historias para proximo sprint
5. **Ejecucion**: Comenzar con Phase 1 (Discovery)

---

**Documento creado:** 2026-02-02
**Product Owner:** Technical Lead
**Estado:** PROPOSAL - Pendiente aprobacion
