# Product Backlog - LinkedIn Transcript Extractor

**Version:** 5.1
**Ultima actualizacion:** 2026-02-10
**Product Owner:** Technical Lead

---

## Resumen

| Metrica | Valor |
|---------|-------|
| Historias completadas | 58 |
| Historias pendientes | 5 |
| Story points completados | ~298+ |
| Story points pendientes | 24 |
| Test coverage | ~85% |
| Tests pasando | 2,366 |

---

## Product Vision

Chrome Extension + MCP Server para capturar y consultar transcripts de LinkedIn Learning, optimizado para LLMs (ChatGPT, Claude).

**Success Criteria:**
- Confiabilidad: >95% tasa de deteccion de captions
- Usabilidad: Export con <=2 clicks
- Calidad: Transcripts sin artefactos en >98% casos
- Mantenibilidad: Test coverage >70% (ALCANZADO)

---

## Epic 8: Crawl por Fases (NEW - APPROVED)

**Epic Goal:** Implementar arquitectura de crawl en 3 fases para captura estructurada, procesamiento paralelo y versionado de contenido.

**Business Value:** Visibilidad de progreso, eficiencia en captura, detección de cambios.

**Total Story Points:** 68 pts

**Decision Record:**
- Etapa 1 (Discovery): GO - ROI 10.6x
- Etapa 2 (Parallel): CONDITIONAL - Requiere spike de rate limiting
- Etapa 3 (Versioning): DEFERRED - ROI 0.41x, backlog futuro

---

### Etapa 1: Discovery/Search (CRITICAL - Sprint N)

| ID | Titulo | Puntos | Prioridad | Estado |
|----|--------|--------|-----------|--------|
| LTE-044 | Course Structure Discovery | 8 | Critical | ✅ Done |
| LTE-045 | Completion Status Tracking | 5 | Critical | ✅ Done |
| LTE-046 | Discovery API Endpoints | 5 | Critical | ✅ Done |

**Total Etapa 1:** 18 pts ✅ COMPLETADO (2026-02-03)

---

#### LTE-044: Course Structure Discovery

**As a** content curator
**I want** to crawl course structure (chapters, videos) without downloading content
**So that** I can see what's available before committing to full capture

**Acceptance Criteria:**
- AC1: Given a course URL, When discovery crawl runs, Then all chapters are extracted with titles and order
- AC2: Given a course URL, When discovery crawl runs, Then all videos are extracted with titles, duration, and chapter association
- AC3: Given a discovery crawl, When completed, Then entities are stored with isComplete=false
- AC4: Given an existing course, When re-discovered, Then only new entities are added (no duplicates)

**Technical Notes:**
- New DiscoveryService in modules/crawl/services/
- Uses StructureExtractor for DOM parsing
- Migration 010 for schema changes
- No video playback needed (faster crawl)

**Story Points:** 8
**Priority:** Critical
**Dependencies:** None

---

#### LTE-045: Completion Status Tracking

**As a** system administrator
**I want** isComplete flags on courses, chapters, and videos
**So that** I can track capture progress and resume incomplete crawls

**Acceptance Criteria:**
- AC1: Given a course entity, When created, Then isComplete defaults to false
- AC2: Given a video, When transcript is captured, Then video.isComplete becomes true
- AC3: Given a chapter, When all videos are complete, Then chapter.isComplete becomes true automatically
- AC4: Given a course, When all chapters are complete, Then course.isComplete becomes true automatically
- AC5: Given an API query, When filtering by isComplete, Then correct entities are returned

**Technical Notes:**
- Add isComplete column to courses_normalized, chapters_normalized, videos_normalized
- Triggers for automatic propagation
- Index on isComplete for query performance

**Story Points:** 5
**Priority:** Critical
**Dependencies:** LTE-044

---

#### LTE-046: Discovery API Endpoints

**As a** API consumer
**I want** endpoints to query course structure and completion status
**So that** I can build dashboards and automation

**Acceptance Criteria:**
- AC1: GET /api/courses/:slug/structure returns full hierarchy (chapters > videos)
- AC2: GET /api/courses?incomplete=true returns only incomplete courses
- AC3: GET /api/courses/:slug/progress returns completion statistics
- AC4: POST /api/crawl/discover accepts course URL and starts discovery crawl

**Technical Notes:**
- New routes in modules/api/http/routes/
- Response includes completionPercentage calculated field
- OpenAPI spec updated

**Story Points:** 5
**Priority:** Critical
**Dependencies:** LTE-044, LTE-045

---

### Etapa 2: Parallel Completion (DONE)

| ID | Titulo | Puntos | Prioridad | Estado |
|----|--------|--------|-----------|--------|
| LTE-047 | Parallel Video Processing | 13 | High | ✅ Done |
| LTE-048 | Rate Limiting & Throttling | 8 | High | ✅ Done |
| LTE-049 | Progress Tracking Dashboard | 5 | Medium | ✅ Done |
| LTE-054 | Integrar Workers con Auto-Crawler | 5 | High | ✅ Done |
| LTE-055 | API Endpoints para Parallel Crawl | 3 | High | ✅ Done |
| LTE-056 | Testing E2E Parallel Crawl | 3 | High | ✅ Done |

**Total Etapa 2:** 37 pts ✅ COMPLETADO (2026-02-05)

**STATUS:** Etapa 2 completa. Workers module (98 tests), auto-crawler integrado, API endpoints, E2E script, WebSocket progress dashboard (87 tests).

---

#### LTE-047: Parallel Video Processing

**As a** power user
**I want** to process multiple videos concurrently
**So that** large course capture completes 3-5x faster

**Acceptance Criteria:**
- AC1: Given a course with 100 videos, When parallel completion runs with 5 workers, Then all videos are processed
- AC2: Given a WorkerPool, When a worker fails, Then work is redistributed to healthy workers
- AC3: Given concurrent processing, When database writes occur, Then no race conditions happen
- AC4: Given parallel crawl, When monitoring, Then per-worker statistics are available

**Technical Notes:**
- WorkerPool pattern with configurable worker count (default: 3)
- Each worker is separate Playwright BrowserContext
- Shared queue with atomic dequeue operations
- Event Bus for coordination

**Story Points:** 13
**Priority:** High
**Dependencies:** LTE-044, LTE-045, Rate Limiting Spike

---

#### LTE-048: Rate Limiting & Throttling

**As a** system administrator
**I want** automatic rate limiting and backoff
**So that** LinkedIn doesn't block or suspend the account

**Acceptance Criteria:**
- AC1: Given 429 response from LinkedIn, When detected, Then exponential backoff activates
- AC2: Given circuit breaker open, When threshold exceeded, Then all requests pause for cooldown
- AC3: Given rate limit config, When changed, Then workers respect new limits immediately
- AC4: Given rate limit events, When logged, Then include request details for debugging

**Technical Notes:**
- Circuit breaker pattern (half-open state for recovery)
- Configurable: minDelay, maxDelay, backoffMultiplier
- Metrics: requestsPerMinute, rateLimitEvents, circuitBreakerTrips

**Story Points:** 8
**Priority:** High
**Dependencies:** LTE-047

---

#### LTE-049: Progress Tracking Dashboard

**As a** user
**I want** real-time progress tracking during parallel crawls
**So that** I know estimated completion time and can identify stuck workers

**Acceptance Criteria:**
- AC1: Given active parallel crawl, When queried, Then per-worker status is returned
- AC2: Given progress data, When displayed, Then ETA is calculated based on current rate
- AC3: Given a stuck worker, When detected, Then alert is generated
- AC4: Given WebSocket endpoint, When connected, Then real-time updates are pushed

**Technical Notes:**
- WebSocket endpoint /ws/crawl/:batchId/progress
- Metrics: videosCompleted, videosRemaining, currentRate, eta
- Heartbeat from workers every 5 seconds

**Story Points:** 5
**Priority:** Medium
**Dependencies:** LTE-047

---

#### LTE-054: Integrar Workers con Auto-Crawler

**As a** developer
**I want** to use ParallelCompletionManager in auto-crawler.js
**So that** the existing crawl workflow benefits from parallel processing

**Acceptance Criteria:**
- AC1: Given auto-crawler config with `parallel: true`, When crawl starts, Then ParallelCompletionManager is used
- AC2: Given rate limiting detected, When threshold exceeded, Then fallback to sequential processing
- AC3: Given parallel crawl options, When worker count specified, Then respect configuration
- AC4: Given existing batch-manager integration, When parallel enabled, Then batch state tracks worker progress

**Technical Notes:**
- Modify auto-crawler.js to import and use modules/crawl/workers/
- Add `parallelOptions` to crawl config: { enabled: true, workerCount: 3, fallbackOnRateLimit: true }
- Maintain backward compatibility with sequential mode
- Use RateLimitMonitor to detect when to fallback

**Story Points:** 5
**Priority:** High
**Dependencies:** LTE-047, LTE-048

---

#### LTE-055: API Endpoints para Parallel Crawl

**As a** API consumer
**I want** endpoints to start and monitor parallel crawls
**So that** I can integrate parallel crawling into automation workflows

**Acceptance Criteria:**
- AC1: POST /api/crawl/parallel accepts course URL and parallel options, returns crawl ID
- AC2: GET /api/crawl/parallel/:id/status returns worker states, progress, and rate limit status
- AC3: POST /api/crawl/parallel/:id/stop gracefully stops all workers
- AC4: API responses include workerStats: { active, completed, failed, rateLimited }

**Technical Notes:**
- New routes in modules/api/http/routes/parallel-crawl.js
- Integrate with existing batch-manager for state persistence
- Return real-time metrics from ParallelCompletionManager

**Story Points:** 3
**Priority:** High
**Dependencies:** LTE-054

---

#### LTE-056: Testing E2E Parallel Crawl

**As a** QA engineer
**I want** validated parallel crawl with real LinkedIn Learning course
**So that** I can confirm rate limit detection and fallback work correctly

**Acceptance Criteria:**
- AC1: Given a real course with 10+ videos, When parallel crawl runs, Then all videos are captured
- AC2: Given rate limit detection, When LinkedIn returns 429, Then exponential backoff activates
- AC3: Given fallback condition, When rate limited at low parallelism, Then sequential mode resumes
- AC4: Test results documented with metrics: duration, rate limit events, success rate

**Technical Notes:**
- Use test course with known structure
- Document safe parallelism level for LinkedIn
- Create test script in scripts/test-parallel-crawl.js

**Story Points:** 3
**Priority:** High
**Dependencies:** LTE-054, LTE-055

---

### Etapa 3: Versioning (DEFERRED - Backlog)

| ID | Titulo | Puntos | Prioridad | Estado |
|----|--------|--------|-----------|--------|
| LTE-050 | Transcript Version History | 8 | Low | Backlog |
| LTE-051 | Change Detection Algorithm | 8 | Low | Backlog |
| LTE-052 | Scheduled Update Checks | 5 | Low | Backlog |
| LTE-053 | Manual Update Trigger | 3 | Low | Backlog |

**Total Etapa 3:** 24 pts

**STATUS:** Deferred to backlog. Revisit when:
- User feedback indicates demand
- Storage strategy defined
- Higher priority items completed

---

#### LTE-050: Transcript Version History

**As a** researcher
**I want** historical versions of transcripts stored
**So that** I can track how content evolved over time

**Acceptance Criteria:**
- AC1: Given a transcript update, When content differs, Then previous version is archived
- AC2: Given version history, When queried, Then all versions are returned with timestamps
- AC3: Given storage limits, When exceeded, Then oldest versions are pruned (configurable retention)

**Story Points:** 8
**Priority:** Low
**Dependencies:** LTE-044, LTE-045

---

#### LTE-051: Change Detection Algorithm

**As a** system
**I want** efficient change detection for transcripts
**So that** only actual changes trigger version creation

**Acceptance Criteria:**
- AC1: Given two transcript versions, When compared, Then content hash determines if different
- AC2: Given minor formatting changes, When detected, Then not treated as new version
- AC3: Given change detection, When run, Then diff summary is generated

**Story Points:** 8
**Priority:** Low
**Dependencies:** LTE-050

---

#### LTE-052: Scheduled Update Checks

**As a** administrator
**I want** automatic periodic checks for content updates
**So that** my transcript library stays current without manual intervention

**Acceptance Criteria:**
- AC1: Given cron expression, When scheduled, Then update checks run automatically
- AC2: Given update check, When changes found, Then new versions are captured
- AC3: Given schedule config, When modified, Then next run time updates

**Story Points:** 5
**Priority:** Low
**Dependencies:** LTE-050, LTE-051

---

#### LTE-053: Manual Update Trigger

**As a** user
**I want** to manually trigger update check for a course
**So that** I can refresh content on demand

**Acceptance Criteria:**
- AC1: Given API endpoint, When called with course slug, Then update check runs immediately
- AC2: Given UI button, When clicked, Then update check starts with progress feedback

**Story Points:** 3
**Priority:** Low
**Dependencies:** LTE-050, LTE-051

---

## Backlog Activo (Otras Historias)

| ID | Titulo | Puntos | Prioridad | Estado |
|----|--------|--------|-----------|--------|
| LTE-061 | Integrar Discovery en flujo de Crawl | 8 | Critical | ✅ Done |
| LTE-012 | Debug panel en popup | 3 | Low | Done |
| LTE-015 | Scripts testing manual | 3 | Low | Done |

---

### LTE-061: Integrar Discovery en flujo de Crawl

**As a** content curator
**I want** auto-crawler.js to use Discovery phase before capturing and CompletionTracker after capturing
**So that** I know the real completion state of courses and don't waste time re-capturing completed videos

**Business Context:**
Los modulos de Discovery (StructureExtractor, CompletionTracker, DiscoveryService) fueron creados en LTE-044/045/046 pero NUNCA integrados en auto-crawler.js. Esto significa que:
- No sabemos con certeza si un curso esta completo
- Recrawleamos videos que ya tenemos
- No hay visibilidad del progreso real

**Acceptance Criteria:**

**AC1: Discovery Phase antes de Capture Phase**
- Given a course URL
- When auto-crawler.js starts
- Then DiscoveryService.discoverFromPage() is called FIRST
- And course structure (chapters, videos) is persisted with isComplete=false
- And crawler has visibility of total videos before capturing

**AC2: Videos completos son skipeados**
- Given a video marked as isComplete=true in videos_normalized
- When crawler iterates through videos
- Then that video is skipped (no playback triggered)
- And skip is logged with reason "already complete"

**AC3: Videos capturados son marcados como complete**
- Given a video was successfully captured (VTT saved to transcripts_normalized)
- When capture completes
- Then CompletionTracker.markVideoComplete(courseSlug, videoSlug) is called
- And video.isComplete becomes true
- And chapter/course propagation triggers if applicable

**AC4: Resumen de crawl muestra estado real**
- Given crawl completes (success or partial)
- When summary is logged
- Then include metrics: { totalVideos, alreadyComplete, newlyCaptured, stillIncomplete, captureRate }
- And message shows: "Course X: 50 videos total, 30 already complete, 15 newly captured, 5 remaining"

**Technical Notes:**
- Modify `crawler/auto-crawler.js` to import and use `DiscoveryService` and `CompletionTracker`
- Call discovery BEFORE iterating videos in `crawlCourse()`
- Add `skipComplete: true` option (default true) to crawl config
- Use `videos_normalized.is_complete` to filter videos
- Update batch-manager to track completion stats
- Maintain backward compatibility with `--no-discovery` flag

**Definition of Done:**
- [x] auto-crawler.js calls DiscoveryService before capture
- [x] Videos with isComplete=true are skipped
- [x] Successfully captured videos are marked complete
- [x] Crawl summary shows completion breakdown
- [x] Unit tests for discovery integration
- [x] Integration test with real course (validates skip logic)

**Story Points:** 8
**Priority:** Critical
**Sprint:** N+3
**Dependencies:** LTE-044 (DiscoveryService), LTE-045 (CompletionTracker)
**Completed:** 2026-02-10

**Implementation Summary:**
- Modified `crawler/auto-crawler.js` with Discovery phase integration
- Added `runDiscoveryPhase()` function that calls DiscoveryService before capture
- Added `isVideoComplete()` check to skip already-captured videos
- Added `markVideoAsComplete()` call after successful VTT capture
- Added `generateCrawlSummary()` with completion breakdown metrics
- Exported `CompletionTracker` from `modules/crawl/index.js`
- 29 new tests in `__tests__/auto-crawler-discovery.test.js`
- All 4 ACs validated with unit tests

### LTE-012: Debug Panel en Popup

**As a** developer
**I want** un panel de debug en el popup de la extension
**So that** pueda ver estado interno sin abrir DevTools

**Acceptance Criteria:**
- AC1: Toggle para mostrar/ocultar panel de debug - DONE
- AC2: Mostrar estado de VTTs capturados, contextos, idioma - DONE
- AC3: Botones para limpiar cache, forzar sync - DONE

**Completed:** 2026-02-06
**Implementation:**
- Added gear icon toggle button in popup header
- Debug panel shows: Active Tabs, Saved Videos, Unassigned VTTs, Visited Contexts, Crawl Mode, Preferred Language
- Three action buttons: Refresh State, Force Sync, Clear Cache
- Added GET_INTERNAL_STATE message handler in background.js

---

### LTE-015: Scripts Testing Manual

**As a** QA engineer
**I want** scripts para testing manual de la extension
**So that** pueda validar funcionalidad sin automatizacion

**Acceptance Criteria:**
- Script para verificar captura de VTT
- Script para validar matching
- Documentacion de escenarios de test

---

## Completadas (ultimas 10)

| ID | Titulo | Completada |
|----|--------|------------|
| LTE-061 | Integrar Discovery en flujo de Crawl | 2026-02-10 |
| LTE-058 | Gap Analysis Service | 2026-02-06 |
| LTE-057 | Collection Discovery Service | 2026-02-06 |
| LTE-015 | Scripts Testing Manual | 2026-02-06 |
| LTE-012 | Debug Panel en Popup | 2026-02-06 |
| LTE-049 | Progress Tracking Dashboard | 2026-02-05 |
| LTE-056 | Testing E2E Parallel Crawl | 2026-02-05 |
| LTE-055 | API Endpoints para Parallel Crawl | 2026-02-05 |
| LTE-054 | Integrar Workers con Auto-Crawler | 2026-02-04 |
| LTE-048 | Rate Limiting & Throttling | 2026-02-03 |

**Archivo completo:** [backlog/archive/2026-Q1-completed.md](backlog/archive/2026-Q1-completed.md)

---

## Epics

| Epic | Historias | Story Points | Status |
|------|-----------|--------------|--------|
| Quality Foundations | 5 | ~25 | DONE |
| Validation & Reliability | 4 | 15 | DONE |
| Developer Experience | 4 | 10 | DONE |
| Advanced Features | 4 | 21 | DONE |
| External Integrations | 1 | 8 | DONE |
| Batch Crawl | 4 | 18 | DONE |
| Modular Architecture | 16 | 100 | DONE |
| Crawl por Fases | 10 | 68 | Etapa 1+2 DONE, Etapa 3 Deferred |
| **Collection-Driven Capture** | 4 | 24 | **IN PROGRESS** (2/4 done) |

---

## Technical Debt

| ID | Descripcion | Severity | Status |
|----|-------------|----------|--------|
| TD-001 | Tests unitarios incompletos | High | RESOLVED (79.29%) |
| TD-002 | Duplicacion parsing VTT | High | RESOLVED |
| TD-003 | Scripts desorganizados | Medium | RESOLVED |
| TD-004 | Estado global complejo | High | RESOLVED |
| TD-006 | DOM selectors fragiles | Medium | RESOLVED |

---

## ID Registry

| Rango | Estado |
|-------|--------|
| LTE-001 a LTE-043 | Completados |
| LTE-044 a LTE-046 | Epic 8 Etapa 1: Discovery (DONE) |
| LTE-047 a LTE-048 | Epic 8 Etapa 2: Workers Module (DONE) |
| LTE-049 | Epic 8 Etapa 2: Progress Dashboard (DONE) |
| LTE-050 a LTE-053 | Epic 8 Etapa 3: Versioning (Deferred) |
| LTE-054 | Epic 8 Etapa 2: Auto-Crawler Integration (DONE) |
| LTE-055 a LTE-056 | Epic 8 Etapa 2: API + E2E (DONE) |
| LTE-057 a LTE-060 | Epic 9: Collection-Driven Capture (DONE) |
| LTE-061 | Integrar Discovery en flujo de Crawl (DONE) |
| LTE-062+ | Disponibles |

**Proximo ID disponible:** LTE-062

---

## Epic 9: Collection-Driven Capture (NEW - PROPOSAL)

**Epic Goal:** Implementar flujo integrado end-to-end que dado una URL de coleccion/carpeta, automaticamente descubra, compare con DB, y capture todos los transcripts faltantes.

**Business Value:** Eliminacion de scripts ad-hoc, automatizacion completa, visibilidad de progreso en tiempo real.

**Total Story Points:** 24 pts (estimado)

**Status:** PROPOSAL - Pendiente aprobacion

---

### Historias Epic 9

| ID | Titulo | Puntos | Prioridad | Estado |
|----|--------|--------|-----------|--------|
| LTE-057 | Collection Discovery Service | 8 | High | ✅ Done |
| LTE-058 | Gap Analysis Service | 5 | High | ✅ Done |
| LTE-059 | Collection Capture Orchestrator | 8 | High | ✅ Done |
| LTE-060 | Collection API Endpoints | 3 | High | ✅ Done |

**Total Epic 9:** 24 pts ✅ COMPLETADO (2026-02-06)

---

#### LTE-057: Collection Discovery Service

**As a** content curator
**I want** a service that scans a LinkedIn Learning collection and discovers all courses with their structure
**So that** I can see everything available in a collection before capturing

**Acceptance Criteria:**

**AC1: Collection Parsing Integration**
- Given a valid collection URL (e.g., /learning/collections/123)
- When CollectionDiscoveryService.discoverCollection(url) is called
- Then folder-parser.js extracts all course slugs from the collection
- And each course slug is stored with collection metadata

**AC2: Bulk Course Structure Discovery**
- Given a list of course slugs from a collection
- When discovery phase runs
- Then DiscoveryService.discoverFromPage() is called for each course
- And course structure (chapters, videos) is persisted to courses_normalized, chapters_normalized, videos_normalized

**AC3: Discovery Progress Events**
- Given discovery is in progress
- When a course structure is discovered
- Then COLLECTION_DISCOVERY_PROGRESS event is emitted with {coursesDiscovered, totalCourses, currentCourse}

**AC4: Idempotent Discovery**
- Given a course already exists in DB
- When re-discovered from a collection
- Then existing data is updated (upsert), not duplicated
- And new videos/chapters are added if course was updated on LinkedIn

**Technical Notes:**
- Create `modules/crawl/services/collection-discovery-service.js`
- Integrate `crawler/folder-parser.js` with `DiscoveryService`
- Use Playwright browser context shared across course discoveries for efficiency
- Store collection metadata: { collectionId, collectionName, sourceUrl, discoveredAt, courseCount }

**Story Points:** 8
**Priority:** High
**Dependencies:** LTE-044 (DiscoveryService), folder-parser.js

---

#### LTE-058: Gap Analysis Service

**As a** system
**I want** to compare discovered course structures against existing transcripts
**So that** I can identify exactly which videos need capturing

**Acceptance Criteria:**

**AC1: Identify Missing Transcripts**
- Given a discovered course with N videos
- When GapAnalysisService.analyzeGaps(courseSlug) is called
- Then return list of videos where is_complete = 0 (no transcript)
- And include video metadata: { slug, title, chapterSlug, durationSeconds }

**AC2: Collection-Wide Gap Analysis**
- Given a collection with multiple courses
- When GapAnalysisService.analyzeCollectionGaps(collectionId) is called
- Then return aggregated gaps: { totalVideos, videosWithTranscripts, videosWithoutTranscripts, gapPercentage, videosByPriority }

**AC3: Priority Ordering**
- Given multiple videos need capturing
- When gap analysis runs
- Then videos are ordered by: courseOrder (from collection), chapterOrder, videoOrder
- And this order is used for capture queue

**AC4: Gap Summary Statistics**
- Given gap analysis is complete
- When results are returned
- Then include summary: { coursesComplete, coursesIncomplete, totalGapVideos, estimatedCaptureTime }
- And estimatedCaptureTime uses average of 30 seconds per video

**Technical Notes:**
- Create `modules/crawl/services/gap-analysis-service.js`
- Uses CompletionTracker for is_complete status queries
- Uses incomplete_videos view for efficient gap lookup
- Return structured data suitable for capture queue

**Story Points:** 5
**Priority:** High
**Dependencies:** LTE-045 (CompletionTracker), LTE-057 (CollectionDiscoveryService)

---

#### LTE-059: Collection Capture Orchestrator

**As a** power user
**I want** a single command/API call that captures all missing transcripts from a collection
**So that** I don't need to run multiple scripts manually

**Acceptance Criteria:**

**AC1: End-to-End Orchestration**
- Given a collection URL
- When CollectionCaptureOrchestrator.captureCollection(url, options) is called
- Then Phase 1: Discover collection courses (LTE-057)
- And Phase 2: Analyze gaps (LTE-058)
- And Phase 3: Capture missing videos using ParallelCompletionManager

**AC2: Parallel Capture Integration**
- Given gap analysis identifies N videos to capture
- When capture phase starts
- Then ParallelCompletionManager processes videos with configured concurrency (default: 2)
- And RateLimitMonitor manages backoff if LinkedIn throttles

**AC3: Real-Time Progress Tracking**
- Given capture is in progress
- When progress changes
- Then emit COLLECTION_CAPTURE_PROGRESS event with { phase, phaseName, coursesProcessed, videosProcessed, totalVideos, eta }
- And WebSocket clients can subscribe for live updates

**AC4: Resume Capability**
- Given capture was interrupted (error, pause, restart)
- When CollectionCaptureOrchestrator.resumeCapture(collectionId) is called
- Then gap analysis re-runs to find remaining videos
- And capture continues from where it left off

**AC5: Error Handling and Reporting**
- Given some videos fail to capture
- When capture phase completes
- Then report includes: { successful, failed, skipped, errors: [{videoSlug, error}] }
- And failed videos remain in gap (is_complete = 0) for retry

**Technical Notes:**
- Create `modules/crawl/services/collection-capture-orchestrator.js`
- Orchestrates: CollectionDiscoveryService -> GapAnalysisService -> ParallelCompletionManager
- State persistence for resume: store collection capture state in data/collections/{id}.json
- CLI support: `node auto-crawler.js --collection <url> [--parallel] [--workers=N]`

**Story Points:** 8
**Priority:** High
**Dependencies:** LTE-057, LTE-058, LTE-047 (ParallelCompletionManager)

---

#### LTE-060: Collection API Endpoints

**As a** API consumer
**I want** HTTP endpoints to trigger and monitor collection captures
**So that** I can integrate collection capture into automation workflows

**Acceptance Criteria:**

**AC1: Start Collection Capture**
- Given POST /api/collections/capture with body { url: "collection-url", options: { parallel: true, workers: 2 } }
- When request is valid
- Then return 202 Accepted with { captureId, status: "discovering", phases: [...], statusUrl }

**AC2: Get Capture Status**
- Given GET /api/collections/capture/:id/status
- When captureId exists
- Then return { captureId, status, currentPhase, progress: { discovery: {...}, gaps: {...}, capture: {...} }, eta, startedAt }

**AC3: Get Collection Summary**
- Given GET /api/collections/:id/summary
- When collectionId exists
- Then return { collectionId, name, courseCount, totalVideos, capturedVideos, gapPercentage, courses: [...] }

**AC4: List Recent Collections**
- Given GET /api/collections
- When called
- Then return { collections: [{ id, name, sourceUrl, discoveredAt, captureStatus }], total }

**Technical Notes:**
- Create routes in `modules/api/http/routes/collections.js`
- Integrate with CollectionCaptureOrchestrator
- Add WebSocket endpoint /ws/collections/:id/progress for real-time updates
- Update OpenAPI spec

**Story Points:** 3
**Priority:** High
**Dependencies:** LTE-059

---

## Roadmap

```
Sprint N (Completado)   Sprint N+1 (Completado)  Sprint N+2 (Completado)  Future
|---------------------|---------------------|-------------------------|---------->
[    Etapa 1:        ][    Etapa 2:        ][     Etapa 2:           ][ Etapa 3  ]
[    Discovery       ][    Workers         ][     Integration +      ][ Version  ]
[    18 pts DONE     ][    21 pts DONE     ][     Dashboard 16 DONE  ][ Backlog  ]
[    COMPLETADO      ][    COMPLETADO      ][     COMPLETADO         ][          ]

Workers: RateLimitMonitor, WorkerContext, ParallelCompletionManager (98 tests)
Auto-Crawler: Integrado con modo paralelo via --parallel y --workers=N
API: POST/GET/POST endpoints para parallel crawl (24 tests)
E2E Script: scripts/test-parallel-crawl.js con Playwright
WebSocket: ProgressTracker con ETA, stuck worker detection, heartbeat (87 tests)
Total Etapa 2: 37/37 pts COMPLETADOS
```

---

## Quick Reference

```bash
npm test                          # 2,190 tests
npm run lint                      # ESLint
npm run db:backup                 # Backup SQLite
cd server && npm run start:http   # HTTP server (puerto 3456)
```

---

## Documentacion Relacionada

- `EPIC_CRAWL_PHASES_PROPOSAL.md` - Detalle completo de historias
- `TECHNICAL_ARCHITECTURE_CRAWL_PHASES.md` - Arquitectura técnica
- `BUSINESS_ANALYSIS_CRAWL_PHASES.md` - Análisis de negocio
- `CURRENT_FEATURES.md` - Funcionalidades actuales

---

**Gestion:** Ver `metodologia_general/20-backlog-management-directive.md`
