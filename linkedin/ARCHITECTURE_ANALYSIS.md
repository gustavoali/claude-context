# Arquitectura - LinkedIn Transcript Extractor

**Version:** 0.16.0
**Fecha:** 2026-02-13
**Estado:** Arquitectura modular completa

---

## Stack

- **Extension:** JavaScript (Chrome Manifest V3)
- **Backend:** Node.js + SQLite (better-sqlite3)
- **Servidor:** Express.js (HTTP) + MCP SDK
- **Crawler:** Playwright
- **Testing:** Jest (~85% coverage, 2,366 tests)

---

## Arquitectura Modular (6 Bounded Contexts)

```
modules/
  shared/      Event Bus, Logger, Config, Errors, Schemas, Validator
  capture/     Repositorios: UnassignedVtt, VisitedContext, AvailableCaptions
  storage/     TranscriptRepository, CourseRepository, StorageService
  matching/    HintMatcher, SemanticMatcher, OrderMatcher, MatchingService
  crawl/       Discovery, Completion, Workers, BatchService, GapAnalysis, Collections
  api/
    http/      Express routes, middleware, error handler
    mcp/       MCP tools (11 herramientas)
    ws/        WebSocket ProgressTracker
```

---

## Base de Datos (SQLite)

**Archivo:** `data/lte.db`

### Tablas Principales

| Tabla | Descripcion |
|-------|-------------|
| courses_normalized | Cursos con metadata y completion status |
| chapters_normalized | Capitulos con FK a courses |
| videos_normalized | Videos con FK a chapters, is_complete flag |
| transcripts_normalized | Transcripts con FK a videos |
| transcripts | Tabla flat original (legacy, preservada) |
| unassigned_vtts | VTTs capturados pendientes de matching |
| visited_contexts | Contextos de video visitados por crawler |

### Vistas

- `transcripts_denormalized` - JOIN completo para queries
- `course_summary` - Estadisticas por curso
- `chapter_details` - Estadisticas por capitulo
- `incomplete_videos` - Videos sin transcript

---

## Flujo de Datos

```
1. DISCOVERY: Crawler navega curso -> StructureExtractor extrae estructura
   -> Persiste en courses/chapters/videos_normalized (is_complete=false)

2. CAPTURE: Crawler reproduce videos -> Extension intercepta VTTs
   -> Almacena en unassigned_vtts + visited_contexts

3. MATCHING: MatchingService asigna VTTs a videos
   -> Hint > Semantic > Order (multi-criteria scoring)
   -> Resultado en transcripts_normalized

4. COMPLETION: CompletionTracker marca videos como complete
   -> Propagacion automatica a chapters y courses
```

---

## API Endpoints

### HTTP (puerto 3456)

| Endpoint | Descripcion |
|----------|-------------|
| GET /api/status | Estado del servidor |
| GET /api/courses | Lista cursos |
| GET /api/search?q= | Buscar en transcripts |
| POST /api/ask | Preguntar sobre contenido |
| POST /api/crawl/discover | Iniciar discovery |
| POST /api/crawl/parallel | Crawl paralelo |
| POST /api/collections/capture | Capturar coleccion |
| GET /api/discovery/courses/:slug/progress | Progreso de curso |

### MCP Tools (11)

`list_courses`, `get_course_structure`, `get_video_transcript`, `search_transcripts`, `ask_about_content`, `get_topics_overview`, `compare_videos`, `get_full_course_content`, `find_prerequisites`, `check_for_updates`, `list_learnings`

---

## Componentes Clave

| Componente | Archivo | Responsabilidad |
|------------|---------|-----------------|
| Auto-Crawler | `crawler/auto-crawler.js` | Automatizacion Playwright, Discovery+Capture |
| Folder Parser | `crawler/folder-parser.js` | Parsear colecciones LinkedIn |
| DiscoveryService | `modules/crawl/services/discovery-service.js` | Descubrir estructura de cursos |
| CompletionTracker | `modules/crawl/state/completion-tracker.js` | Tracking de completitud |
| ParallelCompletionManager | `modules/crawl/workers/parallel-completion-manager.js` | Procesamiento paralelo |
| RateLimitMonitor | `modules/crawl/workers/rate-limit-monitor.js` | Deteccion de rate limits |
| CollectionCaptureOrchestrator | `modules/crawl/services/collection-capture-orchestrator.js` | Orquestacion de captura por coleccion |
| GapAnalysisService | `modules/crawl/services/gap-analysis-service.js` | Identificar videos faltantes |
| HTTP Server | `server/http-server.js` | Express (72 lineas, delegado a modules/) |
| MCP Server | `server/index.js` | MCP SDK (52 lineas, delegado a modules/) |

---

**Historial:** `archive/2026-02-13/ARCHITECTURE_ANALYSIS_v010.md` (analisis original v0.10.0)
