# Arquitectura de Monolito Modularizado - LinkedIn Transcript Extractor

**Version:** 2.0
**Fecha:** 2026-01-30
**Arquitecto:** Software Architect (Claude)
**Estado:** IMPLEMENTADO - Epic 7 completado

---

## Estado de Implementacion

| Fase | Historias | Estado | Fecha |
|------|-----------|--------|-------|
| Phase 1: Fundamentos | LTE-028, LTE-029, LTE-030, LTE-031 | COMPLETADO | 2026-01-29 |
| Phase 2: Storage | LTE-035, LTE-036 | COMPLETADO | 2026-01-29 |
| Phase 3: Capture | LTE-037, LTE-038 | COMPLETADO | 2026-01-29 |
| Phase 4: Matching | LTE-039 | COMPLETADO | 2026-01-29 |
| Phase 5: Crawl | LTE-040 | COMPLETADO | 2026-01-30 |
| Phase 6: API | LTE-041, LTE-042, LTE-043 | COMPLETADO | 2026-01-30 |

### Metricas de Implementacion

| Metrica | Valor |
|---------|-------|
| **Modulos creados** | 6/6 (100%) |
| **Archivos JS** | 67 |
| **Archivos de test** | 14 |
| **Interfaces TypeScript** | 6 (4,211 lineas) |
| **Tests pasando** | 1,214 |
| **Lineas de codigo en modules/** | ~19,000 |
| **Server reduccion** | 1,700 -> 124 lineas (93%) |

---

## Executive Summary

Este documento define una arquitectura de **monolito modularizado** para LinkedIn Transcript Extractor (LTE) que:

1. **Organiza el codigo actual** en bounded contexts bien definidos
2. **Prepara la migracion futura** a microservicios sin reescritura masiva
3. **Implementa almacenamiento hibrido**: SQL para dominio, JSON para infraestructura
4. **Define interfaces claras** entre modulos para evitar acoplamiento

### Principios de Diseno

| Principio | Descripcion | Beneficio |
|-----------|-------------|-----------|
| **Single Responsibility** | Cada modulo tiene una responsabilidad unica | Facilita testing y mantenimiento |
| **Dependency Inversion** | Modulos dependen de interfaces, no implementaciones | Permite swap de implementaciones |
| **No Cross-Context Joins** | Datos de un contexto no hacen JOIN con otro | Facilita separacion futura |
| **Event-First Communication** | Preferir eventos sobre llamadas directas | Preparacion para messaging async |

---

## Bounded Contexts

### Diagrama de Alto Nivel

```
                                    EXTERNAL CONSUMERS
                           +--------------------------------+
                           |   ChatGPT     |     Claude     |
                           +-------+-------+--------+-------+
                                   |                |
                                   v                v
+==============================================================================+
|                         LINKEDIN TRANSCRIPT EXTRACTOR                        |
|                              (Modular Monolith)                              |
+==============================================================================+
|                                                                              |
|  +-------------------------+      +---------------------------+              |
|  |       API MODULE        |      |        API MODULE         |              |
|  |      (HTTP Server)      |      |       (MCP Server)        |              |
|  |       Port: 3456        |      |        stdio/SSE          |              |
|  +------------+------------+      +--------------+------------+              |
|               |                                  |                           |
|               +----------------------------------+                           |
|                                |                                             |
|                                v                                             |
|  +===================================================================+      |
|  |                      ORCHESTRATION LAYER                          |      |
|  |   Routes requests to appropriate modules, handles cross-cutting   |      |
|  +===================================================================+      |
|               |                    |                    |                    |
|               v                    v                    v                    |
|  +----------------+   +-------------------+   +------------------+           |
|  |    STORAGE     |   |      CRAWL        |   |    MATCHING      |           |
|  |    MODULE      |   |     MODULE        |   |     MODULE       |           |
|  |                |   |                   |   |                  |           |
|  | - Courses      |   | - Auto-crawler    |   | - Semantic match |           |
|  | - Chapters     |   | - Batch manager   |   | - Order fallback |           |
|  | - Videos       |   | - Folder parser   |   | - Translation    |           |
|  | - Transcripts  |   | - VTT interceptor |   | - Deduplication  |           |
|  +-------+--------+   +--------+----------+   +--------+---------+           |
|          |                     |                       |                     |
|          |                     v                       |                     |
|          |            +----------------+               |                     |
|          |            |    CAPTURE     |               |                     |
|          |            |    MODULE      |               |                     |
|          |            |                |               |                     |
|          |            | - Extension    |               |                     |
|          |            | - Native Host  |               |                     |
|          |            | - VTT Fetch    |               |                     |
|          |            +-------+--------+               |                     |
|          |                    |                        |                     |
|          +--------------------+------------------------+                     |
|                               |                                              |
|                               v                                              |
|  +===================================================================+      |
|  |                     SHARED INFRASTRUCTURE                         |      |
|  |   - Event Bus (in-process for now, future: message queue)         |      |
|  |   - Logging / Telemetry                                           |      |
|  |   - Configuration Management                                      |      |
|  +===================================================================+      |
|                               |                                              |
+===============================|==============================================+
                                v
                   +-------------------------+
                   |    DATA PERSISTENCE     |
                   |                         |
                   |  SQLite: lte.db         |
                   |    - transcripts        |
                   |    - unassigned_vtts    |
                   |    - visited_contexts   |
                   |    - available_captions |
                   |                         |
                   |  JSON Files:            |
                   |    - data/crawls/*.json |
                   |    - data/batches/*.json|
                   +-------------------------+
```

---

## Modulo 1: CAPTURE

### Responsabilidad

Captura de VTTs y contextos desde LinkedIn Learning. Es el **punto de entrada de datos** al sistema.

### Componentes Actuales

| Componente | Ubicacion Actual | Responsabilidad |
|------------|------------------|-----------------|
| Chrome Extension | `extension/background.js` | Interceptar VTT URLs, fetch content |
| Content Script | `extension/content.js` | Extraer contexto de pagina (video, curso) |
| Storage Manager | `extension/storage-manager.js` | Persistencia en chrome.storage |
| Native Host | `native-host/host.js` | Puente extension -> SQLite |
| VTT Interceptor | `crawler/vtt-interceptor.js` | Captura directa via Playwright |

### Datos Propios

| Tabla/Storage | Tipo | Proposito | Retencion |
|---------------|------|-----------|-----------|
| `unassigned_vtts` | SQLite | VTTs capturados sin asignar | Hasta matching |
| `visited_contexts` | SQLite | Paginas visitadas durante crawl | Hasta matching |
| `available_captions` | SQLite | Tracks de caption descubiertos | Permanente |
| `chrome.storage.local` | Browser | Estado transitorio de captura | Session |

### Interfaz Publica (Contratos)

```typescript
// capture/interfaces.ts

/**
 * Evento emitido cuando se captura un VTT
 */
interface VttCapturedEvent {
  type: 'VTT_CAPTURED';
  payload: {
    contentHash: string;
    content: string;
    textPreview: string;
    capturedAt: number;
    courseSlug?: string;
    hintVideoSlug?: string;
    url?: string;
    languageCode?: string;
  };
}

/**
 * Evento emitido cuando se visita una pagina de video
 */
interface ContextVisitedEvent {
  type: 'CONTEXT_VISITED';
  payload: {
    courseSlug: string;
    videoSlug: string;
    videoTitle?: string;
    courseTitle?: string;
    chapterSlug?: string;
    chapterTitle?: string;
    chapterIndex?: number;
    url: string;
    visitedAt: string;
    order: number;
  };
}

/**
 * Servicio de captura - API publica
 */
interface CaptureService {
  // Guardar VTT capturado
  saveUnassignedVtt(vtt: VttCapturedEvent['payload']): Promise<{ id: string; inserted: boolean }>;

  // Guardar contexto visitado
  saveVisitedContext(ctx: ContextVisitedEvent['payload']): Promise<{ id: string; inserted: boolean }>;

  // Obtener VTTs sin asignar
  getUnmatchedVtts(): Promise<UnassignedVtt[]>;

  // Obtener contextos sin asignar
  getUnmatchedContexts(): Promise<VisitedContext[]>;

  // Limpiar datos de captura (para nuevo crawl)
  clearCaptureData(): Promise<{ vttsCleared: number; contextsCleared: number }>;

  // Verificar si VTT ya existe
  vttExists(contentHash: string): Promise<boolean>;
}
```

### Estructura de Carpetas Propuesta

```
modules/
  capture/
    index.js              # Exporta interfaz publica
    interfaces.d.ts       # Definiciones TypeScript
    services/
      capture-service.js  # Implementacion CaptureService
      vtt-fetcher.js      # Fetch de contenido VTT
      context-extractor.js # Extraccion de metadata
    repositories/
      unassigned-vtt-repo.js
      visited-context-repo.js
      available-captions-repo.js
    events/
      vtt-captured.js
      context-visited.js
    __tests__/
      capture-service.test.js
      vtt-fetcher.test.js
```

---

## Modulo 2: MATCHING

### Responsabilidad

Algoritmo de matching entre VTTs capturados y contextos visitados. **Orquesta datos de CAPTURE y escribe a STORAGE**.

### Componentes Actuales

| Componente | Ubicacion Actual | Responsabilidad |
|------------|------------------|-----------------|
| Match Script | `scripts/match-transcripts.js` | Algoritmo de matching |
| Language Detector | `scripts/lib/language-detector.js` | Deteccion de idioma |
| Translator | `scripts/lib/translator.js` | Traduccion de VTTs |
| Config | `scripts/lib/config.js` | Configuracion de matching |

### Datos Propios

**MATCHING no tiene storage propio.** Lee de CAPTURE, escribe a STORAGE.

### Interfaz Publica

```typescript
// matching/interfaces.ts

/**
 * Resultado de un match individual
 */
interface MatchResult {
  vttContentHash: string;
  videoSlug: string;
  courseSlug: string;
  matchMethod: 'hint' | 'semantic' | 'order' | 'translation';
  score?: number;
  languageDetected?: string;
  translated?: boolean;
}

/**
 * Resultado de una operacion de matching completa
 */
interface MatchingRunResult {
  totalVtts: number;
  totalContexts: number;
  matched: number;
  unmatched: number;
  byMethod: {
    hint: number;
    semantic: number;
    order: number;
    translation: number;
  };
  errors: Array<{ vttHash: string; error: string }>;
  duration: number; // ms
}

/**
 * Servicio de matching - API publica
 */
interface MatchingService {
  // Ejecutar matching completo
  runMatching(options?: MatchingOptions): Promise<MatchingRunResult>;

  // Preview sin guardar
  previewMatching(): Promise<MatchResult[]>;

  // Match individual (para retry)
  matchSingleVtt(contentHash: string): Promise<MatchResult | null>;

  // Configuracion
  getConfig(): MatchingConfig;
  updateConfig(partial: Partial<MatchingConfig>): void;
}

interface MatchingOptions {
  dryRun?: boolean;
  verbose?: boolean;
  skipTranslation?: boolean;
  skipCleanup?: boolean;
}

interface MatchingConfig {
  semanticThreshold: number;     // default: 0.3
  preferredLanguages: string[];  // default: ['es']
  enableTranslationFallback: boolean;
}
```

### Estructura de Carpetas Propuesta

```
modules/
  matching/
    index.js              # Exporta interfaz publica
    interfaces.d.ts
    services/
      matching-service.js
      semantic-matcher.js
      order-matcher.js
      hint-matcher.js
    algorithms/
      keyword-extractor.js
      similarity-calculator.js
    language/
      detector.js
      translator.js
    config.js
    __tests__/
      matching-service.test.js
      semantic-matcher.test.js
```

---

## Modulo 3: STORAGE

### Responsabilidad

Persistencia del **modelo de dominio**: cursos, capitulos, videos y transcripts. Es la **fuente de verdad** para contenido ya procesado.

### Componentes Actuales

| Componente | Ubicacion Actual | Responsabilidad |
|------------|------------------|-----------------|
| Database Library | `scripts/lib/database.js` | Acceso a SQLite |

### Datos Propios

| Tabla | Tipo | Proposito |
|-------|------|-----------|
| `transcripts` | SQLite | Transcripts finales asignados |

**Nota:** Cursos y capitulos se derivan de transcripts (no hay tabla separada).

### Interfaz Publica

```typescript
// storage/interfaces.ts

/**
 * Entidad de dominio: Transcript
 */
interface Transcript {
  id: string;               // courseSlug/videoSlug
  courseSlug: string;
  courseTitle?: string;
  chapterSlug?: string;
  chapterTitle?: string;
  chapterIndex?: number;
  videoSlug: string;
  videoTitle?: string;
  videoIndex?: number;
  transcript: string;       // VTT content
  language: string;
  durationSeconds?: number;
  capturedAt?: string;
  updatedAt?: string;
}

/**
 * Entidad de dominio: Course (derivada)
 */
interface Course {
  slug: string;
  title: string;
  chapterCount: number;
  videoCount: number;
  lastUpdated?: string;
}

/**
 * Entidad de dominio: CourseStructure (con capitulos y videos)
 */
interface CourseStructure {
  slug: string;
  title: string;
  chapterCount: number;
  videoCount: number;
  chapters: Chapter[];
}

interface Chapter {
  slug?: string;
  title: string;
  index: number;
  videoCount: number;
  videos: VideoSummary[];
}

interface VideoSummary {
  slug: string;
  title?: string;
  index: number;
  language?: string;
  hasTranscript: boolean;
  durationSeconds?: number;
}

/**
 * Servicio de storage - API publica
 */
interface StorageService {
  // === COURSES ===
  listCourses(): Promise<Course[]>;
  getCourseStructure(courseSlug: string): Promise<CourseStructure | null>;
  deleteCourse(courseSlug: string): Promise<number>;

  // === TRANSCRIPTS ===
  getTranscript(courseSlug: string, videoSlug: string): Promise<Transcript | null>;
  getTranscriptsByCourse(courseSlug: string): Promise<Transcript[]>;
  saveTranscript(transcript: Omit<Transcript, 'id'>): Promise<{ id: string; isNew: boolean }>;
  deleteTranscript(id: string): Promise<boolean>;

  // === SEARCH ===
  searchTranscripts(query: string, options?: SearchOptions): Promise<SearchResult[]>;

  // === STATS ===
  getStats(): Promise<StorageStats>;
}

interface SearchOptions {
  limit?: number;
  courseSlug?: string;
}

interface StorageStats {
  totalCourses: number;
  totalVideos: number;
  totalLanguages: number;
  byLanguage: Array<{ language: string; count: number }>;
  byCourse: Array<{ slug: string; title: string; videoCount: number }>;
}
```

### Estructura de Carpetas Propuesta

```
modules/
  storage/
    index.js              # Exporta interfaz publica
    interfaces.d.ts
    services/
      storage-service.js
    repositories/
      transcript-repo.js
      course-repo.js      # Queries derivadas
    __tests__/
      storage-service.test.js
      transcript-repo.test.js
```

---

## Modulo 4: CRAWL

### Responsabilidad

Orquestacion de operaciones de captura: navegacion automatizada, batch processing, gestion de estado de crawls.

### Componentes Actuales

| Componente | Ubicacion Actual | Responsabilidad |
|------------|------------------|-----------------|
| Auto Crawler | `crawler/auto-crawler.js` | Navegacion Playwright |
| Batch Manager | `server/lib/batch-manager.js` | Cola de multiples cursos |
| Crawl Manager | `server/lib/crawl-manager.js` | Estado de crawls individuales |
| Folder Parser | `crawler/folder-parser.js` | Extraer cursos de carpetas |
| VTT Interceptor | `crawler/vtt-interceptor.js` | Captura directa |

### Datos Propios

| Archivo | Tipo | Proposito | Retencion |
|---------|------|-----------|-----------|
| `data/crawls/*.json` | JSON | Estado de crawls individuales | 30 dias |
| `data/batches/*.json` | JSON | Estado de batch operations | 30 dias |
| `crawler-config.json` | JSON | Configuracion del crawler | Permanente |

**Por que JSON y no SQLite?**
- Estado transitorio de operaciones en curso
- Facil inspeccion manual durante debugging
- No requiere queries complejas
- Facilita debugging de crawls fallidos

### Interfaz Publica

```typescript
// crawl/interfaces.ts

/**
 * Estado de un crawl individual
 */
interface CrawlState {
  id: string;
  courseSlug: string;
  courseUrl: string;
  status: 'pending' | 'in_progress' | 'completed' | 'failed' | 'cancelled';
  progress: {
    totalVideos: number;
    processed: number;
    captured: number;
    skipped: number;
    errors: number;
  };
  startedAt?: string;
  completedAt?: string;
  error?: string;
  pid?: number;
}

/**
 * Estado de un batch
 */
interface BatchState {
  id: string;
  sourceType: 'folder' | 'collection' | 'manual';
  sourceUrl?: string;
  sourceName?: string;
  status: 'created' | 'extracting' | 'queued' | 'crawling' | 'paused' | 'completed' | 'failed';
  courses: BatchCourse[];
  progress: {
    total: number;
    pending: number;
    crawling: number;
    completed: number;
    failed: number;
    skipped: number;
  };
  createdAt: string;
  startedAt?: string;
  completedAt?: string;
}

interface BatchCourse {
  courseSlug: string;
  courseUrl: string;
  courseName?: string;
  status: 'pending' | 'crawling' | 'completed' | 'failed' | 'skipped';
  crawlId?: string;
  result?: {
    videosFound: number;
    videosCaptured: number;
    errors: number;
  };
}

/**
 * Evento emitido cuando un crawl progresa
 */
interface CrawlProgressEvent {
  type: 'CRAWL_PROGRESS';
  payload: {
    crawlId: string;
    processed: number;
    total: number;
    currentVideo?: string;
  };
}

/**
 * Evento emitido cuando un crawl completa
 */
interface CrawlCompletedEvent {
  type: 'CRAWL_COMPLETED';
  payload: {
    crawlId: string;
    courseSlug: string;
    success: boolean;
    stats: {
      total: number;
      captured: number;
      skipped: number;
      errors: number;
    };
  };
}

/**
 * Servicio de crawl - API publica
 */
interface CrawlService {
  // === SINGLE CRAWL ===
  startCrawl(courseUrl: string, options?: CrawlOptions): Promise<CrawlState>;
  getCrawlStatus(crawlId: string): Promise<CrawlState | null>;
  cancelCrawl(crawlId: string): Promise<boolean>;
  listCrawls(options?: ListCrawlsOptions): Promise<CrawlState[]>;

  // === BATCH CRAWL ===
  startBatch(sourceUrl: string, options?: BatchOptions): Promise<BatchState>;
  getBatchStatus(batchId: string): Promise<BatchState | null>;
  pauseBatch(batchId: string): Promise<boolean>;
  resumeBatch(batchId: string): Promise<boolean>;
  listBatches(): Promise<BatchState[]>;

  // === UTILITIES ===
  extractCoursesFromFolder(folderUrl: string): Promise<Array<{ slug: string; url: string; name?: string }>>;
}

interface CrawlOptions {
  skipExisting?: boolean;
  filterMode?: 'strict' | 'withFallback' | 'captureAll';
  timeout?: number;
}

interface BatchOptions {
  skipExisting?: boolean;
  continueOnError?: boolean;
  delayBetweenCourses?: number;
}
```

### Estructura de Carpetas Propuesta

```
modules/
  crawl/
    index.js              # Exporta interfaz publica
    interfaces.d.ts
    services/
      crawl-service.js
      batch-service.js
    orchestration/
      auto-crawler.js
      vtt-interceptor.js
      folder-parser.js
    state/
      crawl-state-store.js    # JSON file operations
      batch-state-store.js
    __tests__/
      crawl-service.test.js
      batch-service.test.js
```

---

## Modulo 5: API

### Responsabilidad

Exponer funcionalidad a consumidores externos (ChatGPT via HTTP, Claude via MCP). **No contiene logica de negocio**, solo mapea requests a servicios.

### Componentes Actuales

| Componente | Ubicacion Actual | Responsabilidad |
|------------|------------------|-----------------|
| HTTP Server | `server/http-server.js` | REST API para ChatGPT |
| MCP Server | `server/index.js` | MCP protocol para Claude |

### Datos Propios

**API no tiene storage propio.** Solo expone otros modulos.

### Interfaz Publica

```typescript
// api/interfaces.ts

/**
 * HTTP API Routes
 */
interface HttpApiRoutes {
  // Status
  'GET /api/status': () => StatusResponse;

  // Courses
  'GET /api/courses': () => CoursesListResponse;
  'GET /api/courses/:slug': (slug: string) => CourseResponse;
  'GET /api/courses/:slug/transcripts': (slug: string) => CourseTranscriptsResponse;

  // Videos
  'GET /api/video/:course/:video': (course: string, video: string) => VideoResponse;

  // Search
  'GET /api/search': (query: string, options?: SearchOptions) => SearchResponse;
  'POST /api/ask': (body: AskRequest) => AskResponse;

  // Crawl
  'POST /api/crawl': (body: CrawlRequest) => CrawlResponse;
  'GET /api/crawl/:id/status': (id: string) => CrawlStatusResponse;
  'GET /api/crawls': () => CrawlsListResponse;

  // Batch
  'POST /api/batch-crawl': (body: BatchCrawlRequest) => BatchResponse;
  'GET /api/batch-crawl/:id/status': (id: string) => BatchStatusResponse;
  'POST /api/batch-crawl/:id/pause': (id: string) => BatchResponse;
  'POST /api/batch-crawl/:id/resume': (id: string) => BatchResponse;
  'GET /api/batches': () => BatchesListResponse;

  // OpenAPI
  'GET /openapi.json': () => OpenApiSpec;
}

/**
 * MCP Tools
 */
interface McpTools {
  list_courses: () => CoursesList;
  get_course_structure: (args: { course_slug: string }) => CourseStructure;
  get_video_transcript: (args: { course_slug: string; video_slug: string }) => Transcript;
  search_transcripts: (args: { query: string; limit?: number }) => SearchResults;
  ask_about_content: (args: { question: string }) => Answer;
  get_topics_overview: (args: { course_slug: string }) => TopicsOverview;
  compare_videos: (args: { video1: string; video2: string }) => Comparison;
  get_full_course_content: (args: { course_slug: string }) => FullCourseContent;
  find_prerequisites: (args: { topic: string }) => Prerequisites;
  check_for_updates: () => UpdatesInfo;
  list_learnings: (args?: { tags?: string[] }) => Learnings;
}
```

### Estructura de Carpetas Propuesta

```
modules/
  api/
    http/
      index.js            # Express app
      routes/
        status.js
        courses.js
        videos.js
        search.js
        crawl.js
        batch.js
      middleware/
        error-handler.js
        cors.js
        logging.js
      openapi.json
    mcp/
      index.js            # MCP server
      tools/
        courses.js
        transcripts.js
        search.js
        analytics.js
    __tests__/
      http-routes.test.js
      mcp-tools.test.js
```

---

## Shared Infrastructure

### Event Bus

Comunicacion entre modulos mediante eventos (patron Observer).

```typescript
// shared/event-bus.ts

type EventType =
  | 'VTT_CAPTURED'
  | 'CONTEXT_VISITED'
  | 'CRAWL_STARTED'
  | 'CRAWL_PROGRESS'
  | 'CRAWL_COMPLETED'
  | 'MATCHING_STARTED'
  | 'MATCHING_COMPLETED'
  | 'TRANSCRIPT_SAVED';

interface Event<T = unknown> {
  type: EventType;
  payload: T;
  timestamp: string;
  source: string;
}

interface EventBus {
  emit<T>(event: Event<T>): void;
  on<T>(eventType: EventType, handler: (event: Event<T>) => void): () => void;
  off(eventType: EventType, handler: Function): void;
}

// Implementacion actual: EventEmitter en memoria
// Futura: RabbitMQ, Redis Pub/Sub, o similar
```

### Configuracion

```typescript
// shared/config.ts

interface AppConfig {
  // Database
  database: {
    path: string;
    enableWAL: boolean;
  };

  // Capture
  capture: {
    preferredLanguages: string[];
    enableLanguageDetection: boolean;
  };

  // Matching
  matching: {
    semanticThreshold: number;
    enableTranslation: boolean;
  };

  // Crawl
  crawl: {
    defaultTimeout: number;
    retryAttempts: number;
    delayBetweenVideos: number;
    delayBetweenCourses: number;
  };

  // API
  api: {
    httpPort: number;
    corsOrigins: string[];
  };
}
```

### Logging

```typescript
// shared/logging.ts

type LogLevel = 'debug' | 'info' | 'warn' | 'error';

interface Logger {
  debug(message: string, context?: object): void;
  info(message: string, context?: object): void;
  warn(message: string, context?: object): void;
  error(message: string, error?: Error, context?: object): void;

  child(module: string): Logger;
}

// Implementacion: Winston o Pino
// Futura: Envio a servicio de logs centralizado
```

### Estructura

```
modules/
  shared/
    index.js
    event-bus.js
    config.js
    logging.js
    errors.js           # Custom error classes
    utils/
      hash.js
      date.js
      validation.js
```

---

## Estrategia de Almacenamiento

### Por Modulo

| Modulo | Storage | Tipo | Justificacion |
|--------|---------|------|---------------|
| **CAPTURE** | SQLite: unassigned_vtts, visited_contexts | SQL | Queries de matching, indices |
| **CAPTURE** | SQLite: available_captions | SQL | Relacion con videos |
| **STORAGE** | SQLite: transcripts | SQL | Dominio principal, busqueda |
| **CRAWL** | JSON files | NoSQL | Estado transitorio, debugging |
| **MATCHING** | Ninguno | - | Orquesta otros modulos |
| **API** | Ninguno | - | Solo expone |

### Migracion de Datos

La arquitectura actual ya usa SQLite para dominio. Los archivos JSON para crawls/batches son apropiados y no requieren cambio.

### Futuro: Separacion de Bases de Datos

Cuando se migre a microservicios, cada bounded context tendra su propia base:

```
Monolito actual:
  lte.db (SQLite)
    - transcripts (STORAGE)
    - unassigned_vtts (CAPTURE)
    - visited_contexts (CAPTURE)
    - available_captions (CAPTURE)

Microservicios futuro:
  capture-service-db (PostgreSQL o SQLite)
    - unassigned_vtts
    - visited_contexts
    - available_captions

  storage-service-db (PostgreSQL)
    - transcripts

  crawl-service-state (Redis o JSON)
    - crawl states
    - batch states
```

---

## Flujos de Datos

### Flujo 1: Captura de Transcript (Crawl)

```
                                    [CRAWLER]
                                        |
                                        v
+---------------------------------------------------------------------+
| 1. Crawler navega a video                                           |
+---------------------------------------------------------------------+
                                        |
                                        v
+---------------------------------------------------------------------+
| 2. VTT Interceptor captura contenido VTT                            |
|    -> Emite: VTT_CAPTURED                                           |
+---------------------------------------------------------------------+
                                        |
                                        v
+---------------------------------------------------------------------+
| 3. CAPTURE Module recibe evento                                     |
|    -> Guarda en unassigned_vtts                                     |
+---------------------------------------------------------------------+
                                        |
                                        v
+---------------------------------------------------------------------+
| 4. Content Script extrae contexto de pagina                         |
|    -> Emite: CONTEXT_VISITED                                        |
+---------------------------------------------------------------------+
                                        |
                                        v
+---------------------------------------------------------------------+
| 5. CAPTURE Module recibe evento                                     |
|    -> Guarda en visited_contexts                                    |
+---------------------------------------------------------------------+
                                        |
                                        v
+---------------------------------------------------------------------+
| 6. Crawl completa, invoca MATCHING                                  |
|    -> Emite: MATCHING_STARTED                                       |
+---------------------------------------------------------------------+
                                        |
                                        v
+---------------------------------------------------------------------+
| 7. MATCHING Module:                                                 |
|    a. Lee unassigned_vtts de CAPTURE                                |
|    b. Lee visited_contexts de CAPTURE                               |
|    c. Ejecuta algoritmo de matching                                 |
|    d. Para cada match exitoso:                                      |
|       -> Llama STORAGE.saveTranscript()                             |
|       -> Marca VTT y Context como matched                           |
+---------------------------------------------------------------------+
                                        |
                                        v
+---------------------------------------------------------------------+
| 8. MATCHING completa                                                |
|    -> Emite: MATCHING_COMPLETED                                     |
+---------------------------------------------------------------------+
```

### Flujo 2: Consulta de Transcript (API)

```
[ChatGPT/Claude]
      |
      v
+---------------------------------------------------------------------+
| 1. Request: GET /api/video/:course/:video                           |
+---------------------------------------------------------------------+
      |
      v
+---------------------------------------------------------------------+
| 2. API Module recibe request                                        |
|    -> Valida parametros                                             |
+---------------------------------------------------------------------+
      |
      v
+---------------------------------------------------------------------+
| 3. API llama STORAGE.getTranscript(course, video)                   |
+---------------------------------------------------------------------+
      |
      v
+---------------------------------------------------------------------+
| 4. STORAGE Module:                                                  |
|    -> Query SQLite: SELECT * FROM transcripts WHERE ...             |
|    -> Retorna transcript o null                                     |
+---------------------------------------------------------------------+
      |
      v
+---------------------------------------------------------------------+
| 5. API Module:                                                      |
|    -> Formatea respuesta                                            |
|    -> Retorna JSON                                                  |
+---------------------------------------------------------------------+
```

### Flujo 3: Batch Crawl

```
[User via ChatGPT]
      |
      v
+---------------------------------------------------------------------+
| 1. Request: POST /api/batch-crawl { url: "collection/123" }         |
+---------------------------------------------------------------------+
      |
      v
+---------------------------------------------------------------------+
| 2. API valida y llama CRAWL.startBatch(url)                         |
+---------------------------------------------------------------------+
      |
      v
+---------------------------------------------------------------------+
| 3. CRAWL Module:                                                    |
|    a. Extrae cursos de la coleccion (folder-parser)                 |
|    b. Crea batch state file (JSON)                                  |
|    c. Inicia procesamiento en background                            |
|    d. Retorna batchId inmediatamente                                |
+---------------------------------------------------------------------+
      |
      v (async, en background)
+---------------------------------------------------------------------+
| 4. Para cada curso en batch:                                        |
|    a. Espera delay (rate limiting)                                  |
|    b. Inicia crawl individual (reutiliza auto-crawler)              |
|    c. Actualiza batch state con progreso                            |
|    d. Al completar: invoca MATCHING                                 |
|    -> Emite: CRAWL_COMPLETED                                        |
+---------------------------------------------------------------------+
      |
      v
+---------------------------------------------------------------------+
| 5. Batch completa                                                   |
|    -> Actualiza batch state: completed                              |
+---------------------------------------------------------------------+
```

---

## Estructura de Carpetas Completa

```
linkedin/
├── modules/                          # MODULOS DEL MONOLITO
│   ├── capture/
│   │   ├── index.js
│   │   ├── interfaces.d.ts
│   │   ├── services/
│   │   │   ├── capture-service.js
│   │   │   └── vtt-fetcher.js
│   │   ├── repositories/
│   │   │   ├── unassigned-vtt-repo.js
│   │   │   ├── visited-context-repo.js
│   │   │   └── available-captions-repo.js
│   │   └── __tests__/
│   │
│   ├── matching/
│   │   ├── index.js
│   │   ├── interfaces.d.ts
│   │   ├── services/
│   │   │   └── matching-service.js
│   │   ├── algorithms/
│   │   │   ├── keyword-extractor.js
│   │   │   ├── similarity-calculator.js
│   │   │   └── hint-matcher.js
│   │   ├── language/
│   │   │   ├── detector.js
│   │   │   └── translator.js
│   │   └── __tests__/
│   │
│   ├── storage/
│   │   ├── index.js
│   │   ├── interfaces.d.ts
│   │   ├── services/
│   │   │   └── storage-service.js
│   │   ├── repositories/
│   │   │   ├── transcript-repo.js
│   │   │   └── course-repo.js
│   │   └── __tests__/
│   │
│   ├── crawl/
│   │   ├── index.js
│   │   ├── interfaces.d.ts
│   │   ├── services/
│   │   │   ├── crawl-service.js
│   │   │   └── batch-service.js
│   │   ├── orchestration/
│   │   │   ├── auto-crawler.js
│   │   │   ├── vtt-interceptor.js
│   │   │   └── folder-parser.js
│   │   ├── state/
│   │   │   ├── crawl-state-store.js
│   │   │   └── batch-state-store.js
│   │   └── __tests__/
│   │
│   ├── api/
│   │   ├── http/
│   │   │   ├── index.js
│   │   │   ├── routes/
│   │   │   ├── middleware/
│   │   │   └── openapi.json
│   │   ├── mcp/
│   │   │   ├── index.js
│   │   │   └── tools/
│   │   └── __tests__/
│   │
│   └── shared/
│       ├── index.js
│       ├── event-bus.js
│       ├── config.js
│       ├── logging.js
│       ├── errors.js
│       └── utils/
│
├── extension/                        # CHROME EXTENSION (parte de CAPTURE)
│   ├── manifest.json
│   ├── background.js                 # Refactorizar para usar modules/capture
│   ├── content.js
│   ├── popup.js
│   ├── popup.html
│   ├── storage-manager.js
│   └── vtt-parser.js
│
├── native-host/                      # NATIVE MESSAGING (parte de CAPTURE)
│   ├── host.js                       # Refactorizar para usar modules/capture
│   └── com.lte.transcripts.json
│
├── data/                             # DATOS PERSISTENTES
│   ├── lte.db                        # SQLite database
│   ├── crawls/                       # JSON crawl states
│   └── batches/                      # JSON batch states
│
├── scripts/                          # SCRIPTS DE UTILIDAD (reorganizar)
│   ├── admin/                        # Operaciones administrativas
│   ├── analysis/                     # Scripts de analisis
│   ├── migrations/                   # Migraciones de DB
│   └── lib/                          # Librerias compartidas (legacy, migrar a modules/shared)
│       ├── database.js               # -> modules/capture/repositories + modules/storage/repositories
│       ├── config.js                 # -> modules/shared/config.js
│       ├── language-detector.js      # -> modules/matching/language/
│       └── translator.js             # -> modules/matching/language/
│
├── __tests__/                        # TESTS DE INTEGRACION
│   ├── integration/
│   └── e2e/
│
├── server/                           # SERVERS (refactorizar)
│   ├── package.json
│   ├── http-server.js                # -> modules/api/http/
│   ├── index.js                      # -> modules/api/mcp/
│   └── lib/                          # -> migrar a modules/
│       ├── crawl-manager.js          # -> modules/crawl/services/
│       └── batch-manager.js          # -> modules/crawl/services/
│
└── crawler/                          # CRAWLER (refactorizar)
    ├── auto-crawler.js               # -> modules/crawl/orchestration/
    ├── vtt-interceptor.js            # -> modules/crawl/orchestration/
    └── folder-parser.js              # -> modules/crawl/orchestration/
```

---

## Plan de Migracion a Microservicios

### Fase 1: Monolito Modularizado (ACTUAL)

**Estado:** En proceso de implementacion

**Tareas:**
1. [ ] Crear estructura de carpetas `modules/`
2. [ ] Definir interfaces TypeScript para cada modulo
3. [ ] Refactorizar codigo existente en modulos
4. [ ] Implementar Event Bus in-process
5. [ ] Migrar tests a nueva estructura

**Resultado:** Monolito bien organizado con boundaries claros

### Fase 2: APIs Internas (3-6 meses)

**Objetivo:** Preparar para separacion

**Tareas:**
1. [ ] Convertir comunicacion directa a llamadas via interfaces
2. [ ] Implementar circuit breakers en llamadas entre modulos
3. [ ] Agregar timeouts y retries
4. [ ] Implementar health checks por modulo
5. [ ] Instrumentar con metricas

**Resultado:** Modulos comunicandose como si fueran servicios externos

### Fase 3: Event-Driven Architecture (6-12 meses)

**Objetivo:** Desacoplar completamente

**Tareas:**
1. [ ] Reemplazar Event Bus in-process por Redis Pub/Sub o RabbitMQ
2. [ ] Implementar sagas para operaciones cross-module
3. [ ] Agregar idempotencia a handlers de eventos
4. [ ] Implementar dead letter queues

**Resultado:** Comunicacion completamente asincrona

### Fase 4: Separacion de Servicios (12+ meses)

**Objetivo:** Microservicios independientes

**Tareas:**
1. [ ] Separar STORAGE como primer servicio (menor dependencias)
2. [ ] Separar CRAWL como segundo servicio
3. [ ] Separar CAPTURE (incluye extension, mas complejo)
4. [ ] Separar MATCHING
5. [ ] API permanece como Gateway

**Diagrama de servicios finales:**

```
                        [API Gateway]
                             |
         +-------------------+-------------------+
         |                   |                   |
         v                   v                   v
  [Storage Service]   [Crawl Service]    [Capture Service]
         ^                   |                   |
         |                   v                   v
         +<-----------[Matching Service]<--------+
                             |
                             v
                      [Message Broker]
                      (RabbitMQ/Redis)
```

---

## Trade-offs y Decisiones de Diseno

### Decision 1: SQLite vs PostgreSQL para Dominio

**Elegido:** SQLite (mantener actual)

**Justificacion:**
- Proyecto personal, single user
- No requiere conexiones concurrentes
- Simplicidad operacional (archivo unico)
- Suficiente para volumen actual (~1000 transcripts)

**Cuando migrar a PostgreSQL:**
- Multiples usuarios concurrentes
- Volumen >100k transcripts
- Requerimiento de full-text search avanzado

### Decision 2: JSON vs SQLite para Estado de Crawls

**Elegido:** JSON files

**Justificacion:**
- Estado transitorio (no dominio)
- Facil inspeccion durante debugging
- No requiere queries complejas
- Separacion logica de datos de captura vs dominio

**Alternativa considerada:** Tabla `crawl_states` en SQLite
- Rechazada: Mezclaria estado operacional con datos de dominio

### Decision 3: Event Bus In-Process vs Message Queue

**Elegido:** In-process (EventEmitter)

**Justificacion:**
- Simplicidad para fase actual
- Sin overhead de infraestructura
- Suficiente para monolito

**Cuando migrar a Message Queue:**
- Fase 3 del plan de microservicios
- Cuando se necesite persistencia de eventos
- Cuando haya multiples instancias del servidor

### Decision 4: TypeScript vs JavaScript

**Elegido:** JavaScript con JSDoc + interfaces.d.ts

**Justificacion:**
- Mantener consistencia con codigo existente
- Menor overhead de build
- Interfaces en .d.ts para documentacion de contratos

**Cuando migrar a TypeScript completo:**
- Equipo mas grande (>2 developers)
- Complejidad de tipos aumenta
- Refactorizacion mayor

### Decision 5: Extension Chrome como Modulo vs Separado

**Elegido:** Extension como parte del modulo CAPTURE

**Justificacion:**
- Extension es un "cliente" del sistema de captura
- Comparte interfaces con Native Host
- Facilita testing de flujo completo

**Nota:** En microservicios, extension se comunicaria via HTTP con CAPTURE service

---

## Metricas de Exito

### Corto Plazo (1-2 meses)

| Metrica | Target | Medicion |
|---------|--------|----------|
| **Modulos creados** | 5/5 | Estructura en `modules/` |
| **Interfaces definidas** | 100% | Archivos .d.ts |
| **Tests migrados** | >80% | Tests corriendo en nueva estructura |
| **Imports circulares** | 0 | ESLint rule |

### Mediano Plazo (3-6 meses)

| Metrica | Target | Medicion |
|---------|--------|----------|
| **Acoplamiento entre modulos** | <10 imports directos | Analisis estatico |
| **Cobertura de tests por modulo** | >70% | Jest coverage |
| **Latencia de operaciones cross-module** | <5ms overhead | Instrumentacion |

### Largo Plazo (6-12 meses)

| Metrica | Target | Medicion |
|---------|--------|----------|
| **Tiempo para extraer un servicio** | <1 semana | Medicion real al separar STORAGE |
| **Eventos procesados/segundo** | >100 | Event Bus metrics |
| **Disponibilidad por modulo** | >99% | Health checks |

---

## Apendices

### A. Mapeo de Archivos Actuales a Modulos

| Archivo Actual | Modulo Destino | Componente |
|----------------|----------------|------------|
| `scripts/lib/database.js` | `capture`, `storage` | Dividir en repos |
| `scripts/match-transcripts.js` | `matching` | `matching-service.js` |
| `scripts/lib/config.js` | `shared` | `config.js` |
| `scripts/lib/language-detector.js` | `matching` | `language/detector.js` |
| `scripts/lib/translator.js` | `matching` | `language/translator.js` |
| `server/http-server.js` | `api` | `http/index.js` |
| `server/index.js` | `api` | `mcp/index.js` |
| `server/lib/crawl-manager.js` | `crawl` | `services/crawl-service.js` |
| `server/lib/batch-manager.js` | `crawl` | `services/batch-service.js` |
| `crawler/auto-crawler.js` | `crawl` | `orchestration/auto-crawler.js` |
| `crawler/vtt-interceptor.js` | `crawl` | `orchestration/vtt-interceptor.js` |
| `crawler/folder-parser.js` | `crawl` | `orchestration/folder-parser.js` |
| `native-host/host.js` | `capture` | `services/native-host.js` |
| `extension/background.js` | `capture` | Cliente (mantener separado) |
| `extension/storage-manager.js` | `capture` | Cliente (mantener separado) |

### B. Diagrama de Dependencias entre Modulos

```
                    +--------+
                    |  API   |
                    +---+----+
                        |
        +---------------+---------------+
        |               |               |
        v               v               v
   +---------+    +---------+    +---------+
   | STORAGE |    | MATCHING |    |  CRAWL  |
   +---------+    +----+-----+    +----+----+
        ^              |               |
        |              v               v
        |         +---------+    +---------+
        +---------| CAPTURE |<---| CAPTURE |
                  +---------+    +---------+
                       |
                       v
                  +---------+
                  | SHARED  |
                  +---------+
```

**Reglas de dependencia:**
- API depende de todos (es la capa de entrada)
- MATCHING depende de CAPTURE (lee) y STORAGE (escribe)
- CRAWL depende de CAPTURE (escribe) y MATCHING (invoca)
- STORAGE no depende de nadie (solo de SHARED)
- CAPTURE no depende de nadie (solo de SHARED)
- SHARED no depende de nadie

### C. Referencias

- [Monolith to Microservices - Sam Newman](https://www.oreilly.com/library/view/monolith-to-microservices/9781492047834/)
- [Domain-Driven Design - Eric Evans](https://www.domainlanguage.com/ddd/)
- [Building Microservices - Sam Newman](https://www.oreilly.com/library/view/building-microservices-2nd/9781492034018/)
- [Event-Driven Architecture - Martin Fowler](https://martinfowler.com/articles/201701-event-driven.html)

---

**Documento creado:** 2026-01-29
**Implementacion completada:** 2026-01-30
**Version:** 2.0
**Estado:** IMPLEMENTADO - Ver modules/README.md para documentacion detallada

---

## Post-Implementacion: Resultados

### Reduccion de Complejidad en Servers

**Antes (server/http-server.js):** ~900 lineas
**Despues:** 72 lineas (92% reduccion)

**Antes (server/index.js):** ~800 lineas
**Despues:** 52 lineas (93.5% reduccion)

### Tests por Modulo

| Modulo | Tests | Cobertura |
|--------|-------|-----------|
| shared | 189 | 98.85% (event-bus) |
| storage | 58 | >80% |
| capture | 87 | >75% |
| matching | 143 | >80% |
| crawl | 130 | >75% |
| api | 45 | >70% |

### Proximos Pasos (Post-Epic 7)

1. **Monitoreo:** Agregar metricas de performance por modulo
2. **Observability:** Integrar OpenTelemetry
3. **Documentation:** Swagger/OpenAPI auto-generado desde tipos
4. **Future:** Preparar para microservicios cuando sea necesario
