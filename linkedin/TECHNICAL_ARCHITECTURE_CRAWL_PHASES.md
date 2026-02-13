# Technical Architecture: 3-Etapa Crawl System

**Version:** 1.0
**Date:** 2026-02-02
**Author:** Software Architect
**Project:** LinkedIn Transcript Extractor (LTE)
**Status:** PROPOSAL

---

## Executive Summary

This document evaluates and designs a 3-phase (etapa) crawl architecture for the LinkedIn Transcript Extractor project. The proposed system separates concerns between structure discovery, parallel content completion, and versioning, enabling more efficient crawling and better change tracking.

### Proposed Etapas

| Etapa | Name | Description |
|-------|------|-------------|
| **1** | Discovery | Crawl course STRUCTURE only (chapters, videos) without transcript content |
| **2** | Parallel Completion | Complete incomplete videos IN PARALLEL using multiple Playwright pages |
| **3** | Versioning | Detect transcript changes, store version history |

### Key Benefits

- **Faster initial indexing**: Discovery phase indexes course structure without waiting for VTT capture
- **Parallelization**: Multiple videos processed simultaneously, reducing total crawl time by 60-80%
- **Incremental updates**: Only fetch new/changed content instead of full re-crawls
- **Change tracking**: Version history enables diff analysis and content freshness validation

---

## Section 1: Analysis of Current Architecture

### 1.1 Current System Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         CURRENT ARCHITECTURE                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────────┐        │
│  │ batch-service│────>│ crawl-service│────>│  auto-crawler.js │        │
│  │   (queue)    │     │  (spawn)     │     │  (Playwright)    │        │
│  └──────────────┘     └──────────────┘     └────────┬─────────┘        │
│                                                      │                   │
│                                                      ▼                   │
│                                            ┌──────────────────┐         │
│                                            │ vtt-interceptor  │         │
│                                            │ (page.route())   │         │
│                                            └────────┬─────────┘         │
│                                                      │                   │
│                                                      ▼                   │
│                                            ┌──────────────────┐         │
│                                            │ match-transcripts│         │
│                                            │  (post-crawl)    │         │
│                                            └────────┬─────────┘         │
│                                                      │                   │
│                                                      ▼                   │
│                                            ┌──────────────────┐         │
│                                            │   SQLite DB      │         │
│                                            │ (transcripts,    │         │
│                                            │  courses, etc.)  │         │
│                                            └──────────────────┘         │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Current Capabilities

| Capability | Implementation | File(s) |
|------------|----------------|---------|
| **Single Course Crawl** | Sequential video processing with Playwright | `auto-crawler.js` |
| **Batch Crawl** | Queue-based with rate limiting (30-120s delays) | `batch-service.js` |
| **VTT Interception** | `page.route()` network interception | `vtt-interceptor.js` |
| **Language Detection** | tinyld + regex fallback | `vtt-interceptor.js` |
| **Deferred Matching** | VTT-to-context semantic matching | `match-transcripts.js` |
| **State Persistence** | JSON files in `data/crawls/` | `crawl-state-store.js` |
| **Folder Parsing** | Extract courses from collections | `folder-parser.js` |
| **Normalized Schema** | courses/chapters/videos tables | Migration 007 |

### 1.3 Current Data Flow (Single Course)

```
1. CrawlService.startCrawl(url)
   └─> Spawns auto-crawler.js as detached process

2. auto-crawler.js
   └─> Launches Playwright with Chrome + Extension
   └─> Navigates to course URL
   └─> Extracts chapter/video structure from TOC
   └─> For EACH video (SEQUENTIAL):
       └─> Click video in TOC
       └─> Wait for video player
       └─> vtt-interceptor captures VTT via page.route()
       └─> Store VTT in unassigned_vtts table
       └─> Wait 2-5 seconds (fixed delay)
       └─> Move to next video

3. Post-crawl matching
   └─> match-transcripts.js matches VTTs to contexts
   └─> Stores in transcripts table

4. State update
   └─> crawl-state-store marks crawl as completed
```

### 1.4 Current Database Schema (Normalized)

```sql
-- From migration 007
CREATE TABLE courses_normalized (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    slug TEXT NOT NULL UNIQUE,
    title TEXT,
    instructor TEXT,
    total_duration_seconds INTEGER DEFAULT 0,
    video_count INTEGER DEFAULT 0,
    chapter_count INTEGER DEFAULT 0,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE chapters_normalized (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    course_id INTEGER NOT NULL,
    slug TEXT NOT NULL,
    title TEXT,
    index_order INTEGER NOT NULL,
    video_count INTEGER DEFAULT 0,
    FOREIGN KEY (course_id) REFERENCES courses_normalized(id),
    UNIQUE(course_id, slug)
);

CREATE TABLE videos_normalized (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    chapter_id INTEGER NOT NULL,
    slug TEXT NOT NULL,
    title TEXT,
    index_order INTEGER NOT NULL,
    duration_seconds INTEGER DEFAULT 0,
    FOREIGN KEY (chapter_id) REFERENCES chapters_normalized(id),
    UNIQUE(chapter_id, slug)
);
```

### 1.5 Identified Gaps for 3-Etapa System

| Gap | Current State | Required for Etapas |
|-----|---------------|---------------------|
| **Completion Flag** | No `isComplete` on entities | Etapa 1 needs to mark incomplete videos |
| **Parallel Processing** | Strictly sequential | Etapa 2 needs multiple concurrent Playwright pages |
| **Discovery Mode** | Always captures VTTs | Etapa 1 needs structure-only mode |
| **Version Tracking** | No history, overwrites | Etapa 3 needs version table and content hashing |
| **Content Hashing** | No hash stored | Etapa 3 needs hash comparison for change detection |
| **Scheduled Triggers** | Manual only | Etapa 3 needs cron-like scheduling |
| **Partial Course State** | Course-level only | Need video-level completion tracking |

### 1.6 Current Performance Metrics

| Metric | Value | Source |
|--------|-------|--------|
| **Videos per course (avg)** | 15-25 | Observed data |
| **Time per video (sequential)** | 8-12 seconds | auto-crawler.js delays |
| **Full course crawl time** | 3-6 minutes | (videos * 10s + overhead) |
| **Batch delay between courses** | 30-120 seconds | batch-service.js RATE_LIMITS |
| **VTT capture success rate** | ~95% | Empirical |

---

## Section 2: Technical Design

### 2.1 Etapa 1: Discovery (Structure-Only Crawl)

#### 2.1.1 Objective

Crawl course structure (chapters, videos with metadata) WITHOUT capturing transcript content. Mark all discovered entities with `isComplete: false` for later completion.

#### 2.1.2 Schema Changes

```sql
-- ALTER existing tables to add completion tracking
ALTER TABLE videos_normalized ADD COLUMN is_complete INTEGER DEFAULT 0;
ALTER TABLE videos_normalized ADD COLUMN discovered_at TEXT;
ALTER TABLE videos_normalized ADD COLUMN completed_at TEXT;

ALTER TABLE chapters_normalized ADD COLUMN is_complete INTEGER DEFAULT 0;
ALTER TABLE chapters_normalized ADD COLUMN discovered_at TEXT;

ALTER TABLE courses_normalized ADD COLUMN is_complete INTEGER DEFAULT 0;
ALTER TABLE courses_normalized ADD COLUMN discovered_at TEXT;
ALTER TABLE courses_normalized ADD COLUMN completed_at TEXT;
ALTER TABLE courses_normalized ADD COLUMN incomplete_video_count INTEGER DEFAULT 0;

-- Index for finding incomplete videos efficiently
CREATE INDEX idx_videos_incomplete ON videos_normalized(is_complete) WHERE is_complete = 0;
CREATE INDEX idx_courses_incomplete ON courses_normalized(is_complete) WHERE is_complete = 0;

-- View for incomplete videos queue
CREATE VIEW incomplete_videos AS
SELECT
    v.id as video_id,
    v.slug as video_slug,
    v.title as video_title,
    c.slug as chapter_slug,
    co.slug as course_slug,
    co.id as course_id,
    v.discovered_at,
    v.index_order
FROM videos_normalized v
JOIN chapters_normalized c ON v.chapter_id = c.id
JOIN courses_normalized co ON c.course_id = co.id
WHERE v.is_complete = 0
ORDER BY v.discovered_at ASC, co.id, c.index_order, v.index_order;
```

**Migration file:** `scripts/migrations/010_discovery_completion_tracking.js`

#### 2.1.3 New Components

```
modules/crawl/
├── services/
│   └── discovery-service.js      # NEW: Discovery-only crawl orchestration
├── extractors/
│   └── structure-extractor.js    # NEW: Extract TOC without VTT capture
└── state/
    └── completion-tracker.js     # NEW: Track video completion state
```

**discovery-service.js** (Key Interface):

```javascript
/**
 * DiscoveryService - Crawls course structure without VTT capture
 *
 * @module modules/crawl/services/discovery-service
 */
class DiscoveryService {
    /**
     * Discover course structure
     * @param {string} courseUrl - LinkedIn Learning course URL
     * @param {Object} options
     * @param {boolean} options.updateExisting - Update if course exists
     * @returns {Promise<DiscoveryResult>}
     */
    async discoverCourse(courseUrl, options = {}) {}

    /**
     * Discover multiple courses from folder
     * @param {string} folderUrl - Collection/folder URL
     * @returns {Promise<DiscoveryResult[]>}
     */
    async discoverFolder(folderUrl) {}

    /**
     * Get discovery status
     * @param {string} discoveryId
     * @returns {DiscoveryStatus}
     */
    getStatus(discoveryId) {}
}

// DiscoveryResult interface
{
    courseSlug: string,
    chaptersDiscovered: number,
    videosDiscovered: number,
    duration: number,
    status: 'completed' | 'failed' | 'partial'
}
```

**structure-extractor.js** (Key Interface):

```javascript
/**
 * Extracts course structure from LinkedIn Learning page
 * WITHOUT triggering video playback or VTT capture
 */
class StructureExtractor {
    /**
     * Extract full course structure from TOC
     * @param {Page} page - Playwright page
     * @returns {Promise<CourseStructure>}
     */
    async extractStructure(page) {}

    /**
     * Extract single chapter details
     * @param {ElementHandle} chapterElement
     * @returns {Promise<ChapterInfo>}
     */
    async extractChapter(chapterElement) {}

    /**
     * Extract video metadata (title, duration) without clicking
     * @param {ElementHandle} videoElement
     * @returns {Promise<VideoInfo>}
     */
    async extractVideoMetadata(videoElement) {}
}

// CourseStructure interface
{
    slug: string,
    title: string,
    instructor: string,
    totalDuration: number,
    chapters: [{
        slug: string,
        title: string,
        order: number,
        videos: [{
            slug: string,
            title: string,
            order: number,
            durationSeconds: number
        }]
    }]
}
```

#### 2.1.4 Data Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         ETAPA 1: DISCOVERY FLOW                          │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  1. API Request                                                          │
│     POST /api/discovery                                                  │
│     { "url": "https://linkedin.com/learning/course-slug" }              │
│                                                                          │
│  2. DiscoveryService.discoverCourse(url)                                │
│     └─> Validates URL                                                    │
│     └─> Checks if course exists (update vs create)                      │
│     └─> Spawns discovery process                                        │
│                                                                          │
│  3. Playwright Navigation (NO video playback)                           │
│     └─> Navigate to course URL                                          │
│     └─> Wait for TOC to load                                            │
│     └─> Extract structure via StructureExtractor                        │
│          - Course title, instructor                                      │
│          - For each chapter: title, order                               │
│          - For each video: title, duration, order                       │
│                                                                          │
│  4. Database Persistence                                                 │
│     └─> INSERT/UPDATE courses_normalized                                │
│         SET is_complete = 0, discovered_at = NOW()                      │
│     └─> INSERT/UPDATE chapters_normalized                               │
│         SET is_complete = 0, discovered_at = NOW()                      │
│     └─> INSERT/UPDATE videos_normalized                                 │
│         SET is_complete = 0, discovered_at = NOW()                      │
│                                                                          │
│  5. Event Emission                                                       │
│     EventBus.emit('DISCOVERY_COMPLETED', {                              │
│         courseSlug, videosDiscovered, chaptersDiscovered                │
│     })                                                                   │
│                                                                          │
│  TIME: ~10-15 seconds per course (vs 3-6 minutes full crawl)            │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

#### 2.1.5 API Endpoints

```javascript
// New endpoints for discovery
POST /api/discovery
  Body: { url: string, options?: { updateExisting: boolean } }
  Response: { discoveryId, courseSlug, status }

POST /api/discovery/batch
  Body: { folderUrl: string }
  Response: { batchId, coursesQueued }

GET /api/discovery/:discoveryId/status
  Response: { status, progress, result }

GET /api/courses/incomplete
  Response: { courses: [{ slug, incompleteVideos, totalVideos }] }
```

#### 2.1.6 Effort Estimate

| Task | Hours | Notes |
|------|-------|-------|
| Migration 010 (schema changes) | 3 | Add columns, indexes, view |
| StructureExtractor class | 8 | TOC parsing without video click |
| DiscoveryService class | 6 | Orchestration logic |
| CompletionTracker class | 4 | State tracking |
| API endpoints (4 endpoints) | 4 | Routes + validation |
| Unit tests | 8 | 50+ tests |
| Integration tests | 6 | E2E discovery flow |
| Documentation | 3 | API docs, architecture |
| **TOTAL ETAPA 1** | **42 hours** | ~5 days |

---

### 2.2 Etapa 2: Parallel Completion

#### 2.2.1 Objective

Complete incomplete videos IN PARALLEL using multiple Playwright pages/tabs, significantly reducing total crawl time.

#### 2.2.2 Schema Changes

```sql
-- Track parallel completion state
CREATE TABLE completion_jobs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    job_id TEXT NOT NULL UNIQUE,
    course_id INTEGER,
    status TEXT DEFAULT 'pending',  -- pending, running, completed, failed
    concurrency INTEGER DEFAULT 3,
    videos_total INTEGER DEFAULT 0,
    videos_completed INTEGER DEFAULT 0,
    videos_failed INTEGER DEFAULT 0,
    started_at TEXT,
    completed_at TEXT,
    error TEXT,
    FOREIGN KEY (course_id) REFERENCES courses_normalized(id)
);

CREATE TABLE completion_tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    job_id TEXT NOT NULL,
    video_id INTEGER NOT NULL,
    worker_id INTEGER,  -- Which parallel worker is handling this
    status TEXT DEFAULT 'pending',  -- pending, running, completed, failed
    attempts INTEGER DEFAULT 0,
    started_at TEXT,
    completed_at TEXT,
    error TEXT,
    FOREIGN KEY (job_id) REFERENCES completion_jobs(job_id),
    FOREIGN KEY (video_id) REFERENCES videos_normalized(id)
);

CREATE INDEX idx_completion_tasks_status ON completion_tasks(job_id, status);
CREATE INDEX idx_completion_tasks_worker ON completion_tasks(worker_id, status);
```

**Migration file:** `scripts/migrations/011_parallel_completion.js`

#### 2.2.3 New Components

```
modules/crawl/
├── services/
│   └── completion-service.js     # NEW: Parallel completion orchestration
├── workers/
│   ├── completion-worker.js      # NEW: Single Playwright page worker
│   └── worker-pool.js            # NEW: Worker pool management
└── state/
    └── completion-job-store.js   # NEW: Job state persistence
```

**completion-service.js** (Key Interface):

```javascript
/**
 * CompletionService - Orchestrates parallel video completion
 *
 * @module modules/crawl/services/completion-service
 */
class CompletionService {
    /**
     * Complete all incomplete videos for a course
     * @param {string} courseSlug
     * @param {Object} options
     * @param {number} options.concurrency - Number of parallel workers (1-5)
     * @param {string} options.language - Preferred language for VTTs
     * @returns {Promise<CompletionResult>}
     */
    async completeCourse(courseSlug, options = { concurrency: 3 }) {}

    /**
     * Complete specific videos
     * @param {number[]} videoIds
     * @param {Object} options
     * @returns {Promise<CompletionResult>}
     */
    async completeVideos(videoIds, options = {}) {}

    /**
     * Get job status
     * @param {string} jobId
     * @returns {CompletionJobStatus}
     */
    getJobStatus(jobId) {}

    /**
     * Cancel running job
     * @param {string} jobId
     */
    async cancelJob(jobId) {}
}
```

**worker-pool.js** (Key Interface):

```javascript
/**
 * WorkerPool - Manages pool of Playwright page workers
 */
class WorkerPool {
    /**
     * Create worker pool
     * @param {Browser} browser - Playwright browser instance
     * @param {number} poolSize - Number of workers (pages)
     */
    constructor(browser, poolSize) {}

    /**
     * Initialize all workers
     * @returns {Promise<void>}
     */
    async initialize() {}

    /**
     * Get available worker
     * @returns {Promise<Worker>}
     */
    async acquireWorker() {}

    /**
     * Release worker back to pool
     * @param {Worker} worker
     */
    releaseWorker(worker) {}

    /**
     * Execute task on worker
     * @param {Function} task
     * @returns {Promise<any>}
     */
    async execute(task) {}

    /**
     * Shutdown all workers
     */
    async shutdown() {}
}
```

**completion-worker.js** (Key Interface):

```javascript
/**
 * CompletionWorker - Single Playwright page for video completion
 */
class CompletionWorker {
    /**
     * Complete a single video
     * @param {VideoTask} task - Video to complete
     * @returns {Promise<VideoResult>}
     */
    async completeVideo(task) {}

    /**
     * Navigate to course page (one-time per course)
     * @param {string} courseSlug
     */
    async navigateToCourse(courseSlug) {}
}

// VideoTask interface
{
    videoId: number,
    videoSlug: string,
    courseSlug: string,
    chapterSlug: string,
    indexInChapter: number
}

// VideoResult interface
{
    videoId: number,
    success: boolean,
    vttCaptured: boolean,
    language: string,
    error?: string
}
```

#### 2.2.4 Data Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    ETAPA 2: PARALLEL COMPLETION FLOW                     │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  1. API Request                                                          │
│     POST /api/completion/course/:slug                                   │
│     { "concurrency": 3, "language": "es" }                              │
│                                                                          │
│  2. CompletionService.completeCourse(slug, options)                     │
│     └─> Query incomplete_videos view for course                         │
│     └─> Create completion_job record                                    │
│     └─> Create completion_tasks for each video                          │
│     └─> Initialize WorkerPool(browser, concurrency)                     │
│                                                                          │
│  3. Worker Pool Initialization                                          │
│     ┌─────────────────────────────────────────────────────┐            │
│     │  Browser (Single Chromium instance)                  │            │
│     │                                                       │            │
│     │  ┌─────────┐  ┌─────────┐  ┌─────────┐             │            │
│     │  │ Worker 1│  │ Worker 2│  │ Worker 3│             │            │
│     │  │ (Page 1)│  │ (Page 2)│  │ (Page 3)│             │            │
│     │  └────┬────┘  └────┬────┘  └────┬────┘             │            │
│     │       │            │            │                    │            │
│     │       ▼            ▼            ▼                    │            │
│     │  VTT Intercept VTT Intercept VTT Intercept          │            │
│     └─────────────────────────────────────────────────────┘            │
│                                                                          │
│  4. Parallel Task Execution                                             │
│     ┌────────────────────────────────────────────────────────────┐     │
│     │  Task Queue: [v1, v2, v3, v4, v5, v6, v7, v8, ...]         │     │
│     │                 ↓      ↓      ↓                             │     │
│     │              Worker1 Worker2 Worker3                        │     │
│     │                 │      │      │                             │     │
│     │                 ▼      ▼      ▼                             │     │
│     │              [Done] [Done] [Done] → Continue with v4,v5,v6  │     │
│     └────────────────────────────────────────────────────────────┘     │
│                                                                          │
│  5. Per-Video Process (on each worker)                                  │
│     └─> Click video in TOC                                              │
│     └─> Wait for video player (max 5s)                                  │
│     └─> VTT interceptor captures transcript                             │
│     └─> Store VTT in unassigned_vtts                                    │
│     └─> Mark video is_complete = 1                                      │
│     └─> Update completion_tasks status                                  │
│                                                                          │
│  6. Job Completion                                                      │
│     └─> All tasks done                                                  │
│     └─> Run post-crawl matching                                         │
│     └─> Update course is_complete = 1 (if all videos done)             │
│     └─> Emit 'COMPLETION_JOB_FINISHED' event                           │
│                                                                          │
│  TIME COMPARISON (20 video course):                                     │
│    Sequential: 20 * 10s = 200s (3.3 min)                               │
│    Parallel (3 workers): ~70s (1.2 min) - 65% faster                   │
│    Parallel (5 workers): ~50s (0.8 min) - 75% faster                   │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

#### 2.2.5 Concurrency Considerations

| Factor | Consideration | Mitigation |
|--------|---------------|------------|
| **LinkedIn Rate Limiting** | Too many parallel requests may trigger throttling | Limit to 3-5 workers max; add random delays |
| **Memory Usage** | Multiple pages consume RAM | Monitor memory; limit pool size |
| **VTT Interception Conflicts** | Multiple pages capturing simultaneously | Each worker has own interceptor context |
| **Navigation Race Conditions** | Workers clicking same TOC | Task assignment ensures unique videos |
| **Browser Stability** | Long-running sessions may leak | Periodic browser restart after N videos |

#### 2.2.6 API Endpoints

```javascript
// New endpoints for completion
POST /api/completion/course/:slug
  Body: { concurrency?: number, language?: string }
  Response: { jobId, videosQueued, estimatedTime }

POST /api/completion/videos
  Body: { videoIds: number[], concurrency?: number }
  Response: { jobId, videosQueued }

GET /api/completion/job/:jobId
  Response: { status, progress, videosCompleted, videosFailed, eta }

DELETE /api/completion/job/:jobId
  Response: { cancelled: boolean }

GET /api/completion/queue
  Response: { runningJobs, pendingTasks }
```

#### 2.2.7 Effort Estimate

| Task | Hours | Notes |
|------|-------|-------|
| Migration 011 (schema changes) | 2 | Job and task tables |
| WorkerPool class | 12 | Pool lifecycle, task distribution |
| CompletionWorker class | 10 | Single worker logic |
| CompletionService class | 10 | Orchestration, state management |
| CompletionJobStore class | 4 | Job persistence |
| VTT Interceptor adaptation | 6 | Multi-page context support |
| API endpoints (5 endpoints) | 5 | Routes + validation |
| Unit tests | 12 | Worker pool, service tests |
| Integration tests | 10 | E2E parallel completion |
| Performance testing | 6 | Concurrency optimization |
| Documentation | 3 | API docs, architecture |
| **TOTAL ETAPA 2** | **80 hours** | ~10 days |

---

### 2.3 Etapa 3: Versioning

#### 2.3.1 Objective

Detect changes in existing transcripts, store version history, and enable scheduled or manual re-crawls to keep content fresh.

#### 2.3.2 Schema Changes

```sql
-- Version history table
CREATE TABLE transcript_versions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    video_id INTEGER NOT NULL,
    version_number INTEGER NOT NULL,
    content TEXT NOT NULL,
    content_hash TEXT NOT NULL,  -- SHA-256 of normalized content
    language TEXT,
    word_count INTEGER,
    segment_count INTEGER,
    captured_at TEXT NOT NULL,
    previous_version_id INTEGER,
    change_type TEXT,  -- 'initial', 'update', 'correction'
    change_summary TEXT,  -- e.g., "15% content change"
    FOREIGN KEY (video_id) REFERENCES videos_normalized(id),
    FOREIGN KEY (previous_version_id) REFERENCES transcript_versions(id),
    UNIQUE(video_id, version_number)
);

-- Current transcript pointer (latest version)
CREATE TABLE current_transcripts (
    video_id INTEGER PRIMARY KEY,
    current_version_id INTEGER NOT NULL,
    FOREIGN KEY (video_id) REFERENCES videos_normalized(id),
    FOREIGN KEY (current_version_id) REFERENCES transcript_versions(id)
);

-- Add hash to existing transcripts table for quick comparison
ALTER TABLE transcripts ADD COLUMN content_hash TEXT;

-- Scheduled update jobs
CREATE TABLE update_schedules (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    course_id INTEGER,
    schedule_type TEXT NOT NULL,  -- 'manual', 'daily', 'weekly', 'monthly'
    cron_expression TEXT,  -- e.g., '0 2 * * 0' for weekly Sunday 2am
    last_run_at TEXT,
    next_run_at TEXT,
    enabled INTEGER DEFAULT 1,
    FOREIGN KEY (course_id) REFERENCES courses_normalized(id)
);

-- Update run history
CREATE TABLE update_runs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    schedule_id INTEGER,
    course_id INTEGER,
    run_type TEXT NOT NULL,  -- 'scheduled', 'manual'
    started_at TEXT NOT NULL,
    completed_at TEXT,
    status TEXT DEFAULT 'running',  -- running, completed, failed
    videos_checked INTEGER DEFAULT 0,
    videos_changed INTEGER DEFAULT 0,
    error TEXT,
    FOREIGN KEY (schedule_id) REFERENCES update_schedules(id),
    FOREIGN KEY (course_id) REFERENCES courses_normalized(id)
);

-- Indexes
CREATE INDEX idx_transcript_versions_video ON transcript_versions(video_id);
CREATE INDEX idx_transcript_versions_hash ON transcript_versions(content_hash);
CREATE INDEX idx_update_schedules_next ON update_schedules(next_run_at) WHERE enabled = 1;
```

**Migration file:** `scripts/migrations/012_versioning.js`

#### 2.3.3 New Components

```
modules/crawl/
├── services/
│   └── versioning-service.js     # NEW: Version management
├── schedulers/
│   ├── update-scheduler.js       # NEW: Cron-like scheduling
│   └── schedule-runner.js        # NEW: Execute scheduled updates
├── comparators/
│   └── content-comparator.js     # NEW: Diff detection
└── state/
    └── version-store.js          # NEW: Version persistence
```

**versioning-service.js** (Key Interface):

```javascript
/**
 * VersioningService - Manages transcript version history
 *
 * @module modules/crawl/services/versioning-service
 */
class VersioningService {
    /**
     * Check for updates on a course
     * @param {string} courseSlug
     * @returns {Promise<UpdateCheckResult>}
     */
    async checkForUpdates(courseSlug) {}

    /**
     * Create new version if content changed
     * @param {number} videoId
     * @param {string} newContent
     * @param {string} language
     * @returns {Promise<VersionResult>}
     */
    async saveVersion(videoId, newContent, language) {}

    /**
     * Get version history for video
     * @param {number} videoId
     * @returns {Promise<Version[]>}
     */
    async getVersionHistory(videoId) {}

    /**
     * Get diff between versions
     * @param {number} versionId1
     * @param {number} versionId2
     * @returns {Promise<VersionDiff>}
     */
    async getDiff(versionId1, versionId2) {}

    /**
     * Rollback to previous version
     * @param {number} videoId
     * @param {number} versionId
     */
    async rollbackToVersion(videoId, versionId) {}
}
```

**update-scheduler.js** (Key Interface):

```javascript
/**
 * UpdateScheduler - Manages scheduled update checks
 */
class UpdateScheduler {
    /**
     * Create update schedule
     * @param {string} courseSlug
     * @param {Object} schedule
     * @param {string} schedule.type - 'daily', 'weekly', 'monthly'
     * @param {string} schedule.cronExpression - Custom cron (optional)
     */
    async createSchedule(courseSlug, schedule) {}

    /**
     * Get pending schedules
     * @returns {Promise<Schedule[]>}
     */
    async getPendingSchedules() {}

    /**
     * Execute scheduled update
     * @param {Schedule} schedule
     */
    async executeSchedule(schedule) {}

    /**
     * Start scheduler daemon
     */
    start() {}

    /**
     * Stop scheduler daemon
     */
    stop() {}
}
```

**content-comparator.js** (Key Interface):

```javascript
/**
 * ContentComparator - Detects changes in VTT content
 */
class ContentComparator {
    /**
     * Calculate content hash
     * @param {string} content - VTT content
     * @returns {string} - SHA-256 hash
     */
    calculateHash(content) {}

    /**
     * Compare two contents
     * @param {string} oldContent
     * @param {string} newContent
     * @returns {ComparisonResult}
     */
    compare(oldContent, newContent) {}

    /**
     * Generate human-readable diff summary
     * @param {string} oldContent
     * @param {string} newContent
     * @returns {string}
     */
    generateDiffSummary(oldContent, newContent) {}
}

// ComparisonResult interface
{
    identical: boolean,
    oldHash: string,
    newHash: string,
    changePercentage: number,  // 0-100
    segmentsAdded: number,
    segmentsRemoved: number,
    segmentsModified: number
}
```

#### 2.3.4 Data Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        ETAPA 3: VERSIONING FLOW                          │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  A. MANUAL UPDATE CHECK                                                  │
│  ────────────────────────                                                │
│                                                                          │
│  1. API Request                                                          │
│     POST /api/versioning/check/:courseSlug                              │
│                                                                          │
│  2. VersioningService.checkForUpdates(courseSlug)                       │
│     └─> Get all videos with is_complete = 1                             │
│     └─> For each video:                                                 │
│         └─> Re-crawl single video (reuse completion worker)             │
│         └─> Calculate hash of new content                               │
│         └─> Compare with current_transcripts.content_hash               │
│         └─> If different:                                                │
│             └─> Create new transcript_versions record                   │
│             └─> Update current_transcripts pointer                      │
│             └─> Emit 'TRANSCRIPT_VERSION_CREATED' event                 │
│                                                                          │
│  3. Response                                                             │
│     { videosChecked: 20, videosChanged: 2, newVersions: [...] }        │
│                                                                          │
│                                                                          │
│  B. SCHEDULED UPDATE                                                     │
│  ────────────────────                                                    │
│                                                                          │
│  1. UpdateScheduler.start() (runs on server startup)                    │
│     └─> Poll update_schedules every 60 seconds                          │
│     └─> Find schedules where next_run_at <= NOW()                       │
│                                                                          │
│  2. For each pending schedule:                                          │
│     └─> Create update_runs record (status: 'running')                   │
│     └─> Execute checkForUpdates(courseSlug)                             │
│     └─> Update update_runs (status: 'completed', stats)                 │
│     └─> Calculate next_run_at based on cron                             │
│                                                                          │
│  3. Schedule Examples:                                                   │
│     - Daily at 2am:   '0 2 * * *'                                       │
│     - Weekly Sunday:  '0 2 * * 0'                                       │
│     - Monthly 1st:    '0 2 1 * *'                                       │
│                                                                          │
│                                                                          │
│  C. VERSION HISTORY QUERY                                                │
│  ───────────────────────                                                 │
│                                                                          │
│  GET /api/versioning/video/:videoId/history                             │
│  Response: {                                                             │
│    versions: [                                                           │
│      { version: 3, capturedAt: '2026-02-01', changeType: 'update' },   │
│      { version: 2, capturedAt: '2026-01-15', changeType: 'update' },   │
│      { version: 1, capturedAt: '2026-01-01', changeType: 'initial' }   │
│    ],                                                                    │
│    currentVersion: 3                                                     │
│  }                                                                       │
│                                                                          │
│                                                                          │
│  D. DIFF VIEW                                                            │
│  ───────────                                                             │
│                                                                          │
│  GET /api/versioning/diff?v1=2&v2=3                                     │
│  Response: {                                                             │
│    changePercentage: 12.5,                                              │
│    segmentsAdded: 3,                                                     │
│    segmentsRemoved: 1,                                                   │
│    segmentsModified: 5,                                                  │
│    diffHtml: "<del>old text</del><ins>new text</ins>..."               │
│  }                                                                       │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

#### 2.3.5 Change Detection Algorithm

```javascript
/**
 * Change detection algorithm for VTT content
 *
 * 1. Normalize content (remove timestamps, normalize whitespace)
 * 2. Calculate SHA-256 hash
 * 3. If hash differs, calculate detailed diff
 */

function normalizeVttContent(vttContent) {
    return vttContent
        .replace(/\d{2}:\d{2}:\d{2}\.\d{3}/g, '')  // Remove timestamps
        .replace(/-->/g, '')                        // Remove arrow
        .replace(/\s+/g, ' ')                       // Normalize whitespace
        .trim()
        .toLowerCase();
}

function calculateChangePercentage(oldContent, newContent) {
    const oldWords = normalizeVttContent(oldContent).split(' ');
    const newWords = normalizeVttContent(newContent).split(' ');

    const oldSet = new Set(oldWords);
    const newSet = new Set(newWords);

    const added = [...newSet].filter(w => !oldSet.has(w)).length;
    const removed = [...oldSet].filter(w => !newSet.has(w)).length;

    const totalChanges = added + removed;
    const totalWords = Math.max(oldWords.length, newWords.length);

    return (totalChanges / totalWords) * 100;
}
```

#### 2.3.6 API Endpoints

```javascript
// New endpoints for versioning
POST /api/versioning/check/:courseSlug
  Response: { runId, videosChecked, videosChanged, newVersions }

GET /api/versioning/video/:videoId/history
  Query: { limit?: number }
  Response: { versions: Version[], currentVersion: number }

GET /api/versioning/diff
  Query: { v1: number, v2: number }
  Response: { changePercentage, segmentsAdded, segmentsRemoved, diffHtml }

POST /api/versioning/rollback
  Body: { videoId: number, versionId: number }
  Response: { success: boolean, newCurrentVersion: number }

// Schedule management
POST /api/versioning/schedule
  Body: { courseSlug: string, type: 'daily'|'weekly'|'monthly', cronExpression?: string }
  Response: { scheduleId, nextRunAt }

GET /api/versioning/schedules
  Response: { schedules: Schedule[] }

DELETE /api/versioning/schedule/:scheduleId
  Response: { deleted: boolean }

GET /api/versioning/runs
  Query: { courseSlug?: string, limit?: number }
  Response: { runs: UpdateRun[] }
```

#### 2.3.7 Effort Estimate

| Task | Hours | Notes |
|------|-------|-------|
| Migration 012 (schema changes) | 4 | Version tables, indexes |
| ContentComparator class | 6 | Hash, diff, normalization |
| VersionStore class | 4 | Version CRUD |
| VersioningService class | 10 | Core versioning logic |
| UpdateScheduler class | 8 | Cron-like scheduler |
| ScheduleRunner class | 6 | Execute scheduled jobs |
| API endpoints (8 endpoints) | 8 | Routes + validation |
| Unit tests | 10 | All versioning components |
| Integration tests | 8 | E2E versioning flow |
| Scheduler integration | 4 | Server startup, graceful shutdown |
| Documentation | 4 | API docs, architecture |
| **TOTAL ETAPA 3** | **72 hours** | ~9 days |

---

## Section 3: Dependencies Between Etapas

### 3.1 Dependency Graph

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         DEPENDENCY GRAPH                                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│                      ┌───────────────┐                                  │
│                      │   ETAPA 1     │                                  │
│                      │  Discovery    │                                  │
│                      │   (42 hrs)    │                                  │
│                      └───────┬───────┘                                  │
│                              │                                           │
│              ┌───────────────┼───────────────┐                          │
│              │               │               │                          │
│              ▼               │               ▼                          │
│     ┌────────────────┐       │      ┌────────────────┐                  │
│     │    ETAPA 2     │       │      │    ETAPA 3     │                  │
│     │   Parallel     │◄──────┘      │   Versioning   │                  │
│     │  Completion    │              │    (72 hrs)    │                  │
│     │   (80 hrs)     │              └────────┬───────┘                  │
│     └────────────────┘                       │                          │
│              │                               │                          │
│              │                               │                          │
│              └───────────────┬───────────────┘                          │
│                              │                                          │
│                              ▼                                          │
│                    ┌───────────────────┐                                │
│                    │ Integration Phase │                                │
│                    │    (optional)     │                                │
│                    │     (16 hrs)      │                                │
│                    └───────────────────┘                                │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Dependency Matrix

| From Etapa | To Etapa | Dependency Type | Description |
|------------|----------|-----------------|-------------|
| 1 | 2 | **REQUIRED** | Etapa 2 needs `is_complete` flag and `incomplete_videos` view from Etapa 1 |
| 1 | 3 | **REQUIRED** | Etapa 3 needs structured video records with IDs from Etapa 1 |
| 2 | 3 | **OPTIONAL** | Etapa 3 can use parallel workers from Etapa 2 for faster update checks |

### 3.3 Shared Components

| Component | Used By | Notes |
|-----------|---------|-------|
| VTT Interceptor | Etapa 2, 3 | Needs multi-context adaptation for parallel pages |
| Matching Service | Etapa 2, 3 | Used after VTT capture |
| Event Bus | All | Events for coordination |
| Logger | All | Structured logging |
| State Stores | All | JSON file persistence |

### 3.4 Implementation Order Constraints

1. **Migration 010 MUST run before Etapa 1 code** - Schema changes needed first
2. **Etapa 1 MUST complete before Etapa 2 starts** - Need `is_complete` flag
3. **Etapa 2 can run in parallel with Etapa 3** - After Etapa 1, no dependency
4. **Integration phase after all etapas** - Combined testing

---

## Section 4: Technical Risks

### 4.1 Risk Register

| ID | Risk | Probability | Impact | Mitigation | Owner |
|----|------|-------------|--------|------------|-------|
| R1 | **LinkedIn rate limiting with parallel requests** | HIGH | HIGH | Limit to 3 workers max; add exponential backoff; monitor 429 responses | Etapa 2 |
| R2 | **Browser memory leaks with long-running workers** | MEDIUM | MEDIUM | Restart browser after 50 videos; memory monitoring | Etapa 2 |
| R3 | **VTT interceptor conflicts with multiple pages** | MEDIUM | HIGH | Isolated interceptor context per page; mutex for DB writes | Etapa 2 |
| R4 | **TOC structure changes break discovery** | MEDIUM | MEDIUM | Multiple selector fallbacks (already implemented in LTE-007) | Etapa 1 |
| R5 | **False positive version changes (timestamp only)** | LOW | MEDIUM | Content normalization removes timestamps before hash | Etapa 3 |
| R6 | **Scheduler not starting on server restart** | LOW | LOW | Scheduler health check; startup verification tests | Etapa 3 |
| R7 | **Database locks during parallel writes** | MEDIUM | MEDIUM | WAL mode already enabled; batch writes with transactions | Etapa 2 |
| R8 | **Course structure changes between discovery and completion** | LOW | MEDIUM | Re-verify structure on completion start; handle missing videos gracefully | Etapa 1,2 |

### 4.2 Risk Score Calculation

```
Risk Score = Probability (1-5) × Impact (1-5)

HIGH risk (>15): R1 (Rate limiting) - Score: 4×4 = 16
MEDIUM risk (8-15): R3, R7, R4, R2 - Scores: 12, 9, 9, 6
LOW risk (<8): R5, R6, R8 - Scores: 4, 3, 4
```

### 4.3 Mitigation Details

#### R1: LinkedIn Rate Limiting (Score: 16)

**Detection:**
- Monitor HTTP 429 responses
- Track request timing per IP

**Mitigation Strategy:**
```javascript
const RATE_LIMIT_CONFIG = {
    maxConcurrentWorkers: 3,
    minDelayBetweenRequests: 2000,  // 2 seconds
    backoffMultiplier: 2,
    maxBackoffDelay: 60000,  // 60 seconds
    cooldownAfter429: 300000  // 5 minutes
};

async function handleRateLimit(response) {
    if (response.status === 429) {
        const retryAfter = response.headers['retry-after'] || RATE_LIMIT_CONFIG.cooldownAfter429;
        logger.warn('Rate limited, pausing', { retryAfter });
        await sleep(retryAfter);
        return true;  // Should retry
    }
    return false;
}
```

#### R3: VTT Interceptor Conflicts (Score: 12)

**Mitigation Strategy:**
```javascript
// Each worker gets isolated context
class CompletionWorker {
    constructor(workerId, browser) {
        this.workerId = workerId;
        this.context = null;  // Isolated browser context
        this.page = null;
        this.vttInterceptor = null;  // Own interceptor instance
    }

    async initialize() {
        // Create isolated browser context (not shared)
        this.context = await browser.newContext();
        this.page = await this.context.newPage();

        // Each page has own interceptor with worker-specific prefix
        this.vttInterceptor = new VttInterceptor({
            contextPrefix: `worker_${this.workerId}`
        });
        await this.vttInterceptor.setup(this.page);
    }
}
```

---

## Section 5: Recommendations

### 5.1 Implementation Approach

1. **Start with Etapa 1** - Lowest risk, foundation for others
2. **Implement Etapa 2 next** - Highest value (performance improvement)
3. **Implement Etapa 3 last** - Nice-to-have, can be deferred

### 5.2 Suggested Milestones

| Milestone | Duration | Deliverables |
|-----------|----------|--------------|
| **M1: Discovery Foundation** | 1 week | Migration 010, StructureExtractor, basic discovery API |
| **M2: Discovery Complete** | 1 week | DiscoveryService, batch discovery, full API |
| **M3: Parallel Workers** | 1.5 weeks | WorkerPool, CompletionWorker, VTT adaptation |
| **M4: Parallel Complete** | 1 week | CompletionService, job management, full API |
| **M5: Versioning Core** | 1 week | Migration 012, ContentComparator, VersionStore |
| **M6: Versioning Complete** | 1.5 weeks | VersioningService, scheduler, full API |
| **M7: Integration** | 1 week | Combined testing, documentation, optimization |

### 5.3 Testing Strategy

| Phase | Test Type | Coverage Target |
|-------|-----------|-----------------|
| **Per Component** | Unit tests | 80%+ |
| **Per Etapa** | Integration tests | All API endpoints |
| **Cross-Etapa** | E2E tests | Full workflow: discover → complete → version |
| **Performance** | Load tests | 50 courses, 3 parallel workers |

### 5.4 Rollout Strategy

1. **Feature flag all new functionality**
   ```javascript
   if (config.features.parallelCompletion) {
       // Use new parallel completion
   } else {
       // Use existing sequential crawl
   }
   ```

2. **Gradual rollout**
   - Week 1: Discovery only (no changes to existing workflow)
   - Week 2: Parallel completion opt-in
   - Week 3: Parallel completion default
   - Week 4: Versioning opt-in

3. **Monitoring**
   - VTT capture success rate
   - Worker pool health
   - Memory usage trends
   - Rate limit incidents

---

## Section 6: Total Estimation

### 6.1 Effort Summary

| Etapa | Description | Hours | Days (8h) | Sprints (40h) |
|-------|-------------|-------|-----------|---------------|
| **1** | Discovery | 42 | 5.3 | 1.1 |
| **2** | Parallel Completion | 80 | 10.0 | 2.0 |
| **3** | Versioning | 72 | 9.0 | 1.8 |
| **-** | Integration | 16 | 2.0 | 0.4 |
| **TOTAL** | | **210** | **26.3** | **5.3** |

### 6.2 Resource Requirements

| Resource | Requirement | Notes |
|----------|-------------|-------|
| **Developer** | 1 senior | Full-time for 5-6 weeks |
| **Memory** | +2GB RAM | For parallel browser pages |
| **Disk** | +500MB | Version history storage |
| **CI/CD** | Extended tests | Add parallel completion E2E |

### 6.3 Delivery Timeline

```
Week 1-2:  Etapa 1 - Discovery
Week 3-4:  Etapa 2 - Parallel Completion
Week 5-6:  Etapa 3 - Versioning
Week 7:    Integration & Polish

Total: 7 weeks (~1.5 months)
```

### 6.4 ROI Analysis

| Metric | Current | After Etapas | Improvement |
|--------|---------|--------------|-------------|
| **Full course crawl time** | 3-6 min | ~1 min | 70-80% faster |
| **Initial indexing time** | 3-6 min | 10-15 sec | 95% faster |
| **Batch crawl (20 courses)** | 90+ min | ~30 min | 66% faster |
| **Content freshness** | Unknown | Tracked | 100% visibility |
| **Re-crawl efficiency** | 100% (full) | ~10% (changed only) | 90% bandwidth saving |

---

## Appendix A: Migration Scripts

### A.1 Migration 010: Discovery Completion Tracking

```javascript
// scripts/migrations/010_discovery_completion_tracking.js
'use strict';

const path = require('path');
const Database = require('better-sqlite3');

const DB_PATH = path.join(__dirname, '../../data/lte.db');

function migrate() {
    const db = new Database(DB_PATH);
    db.pragma('journal_mode = WAL');

    console.log('Migration 010: Adding discovery completion tracking...');

    // Add columns to videos_normalized
    const videoColumns = [
        'ALTER TABLE videos_normalized ADD COLUMN is_complete INTEGER DEFAULT 0',
        'ALTER TABLE videos_normalized ADD COLUMN discovered_at TEXT',
        'ALTER TABLE videos_normalized ADD COLUMN completed_at TEXT'
    ];

    // Add columns to chapters_normalized
    const chapterColumns = [
        'ALTER TABLE chapters_normalized ADD COLUMN is_complete INTEGER DEFAULT 0',
        'ALTER TABLE chapters_normalized ADD COLUMN discovered_at TEXT'
    ];

    // Add columns to courses_normalized
    const courseColumns = [
        'ALTER TABLE courses_normalized ADD COLUMN is_complete INTEGER DEFAULT 0',
        'ALTER TABLE courses_normalized ADD COLUMN discovered_at TEXT',
        'ALTER TABLE courses_normalized ADD COLUMN completed_at TEXT',
        'ALTER TABLE courses_normalized ADD COLUMN incomplete_video_count INTEGER DEFAULT 0'
    ];

    const allColumns = [...videoColumns, ...chapterColumns, ...courseColumns];

    for (const sql of allColumns) {
        try {
            db.exec(sql);
            console.log(`  ✓ ${sql.substring(0, 60)}...`);
        } catch (err) {
            if (err.message.includes('duplicate column')) {
                console.log(`  - Column already exists, skipping`);
            } else {
                throw err;
            }
        }
    }

    // Create indexes
    const indexes = [
        'CREATE INDEX IF NOT EXISTS idx_videos_incomplete ON videos_normalized(is_complete) WHERE is_complete = 0',
        'CREATE INDEX IF NOT EXISTS idx_courses_incomplete ON courses_normalized(is_complete) WHERE is_complete = 0'
    ];

    for (const sql of indexes) {
        db.exec(sql);
        console.log(`  ✓ Index created`);
    }

    // Create incomplete_videos view
    db.exec(`
        CREATE VIEW IF NOT EXISTS incomplete_videos AS
        SELECT
            v.id as video_id,
            v.slug as video_slug,
            v.title as video_title,
            c.slug as chapter_slug,
            co.slug as course_slug,
            co.id as course_id,
            v.discovered_at,
            v.index_order
        FROM videos_normalized v
        JOIN chapters_normalized c ON v.chapter_id = c.id
        JOIN courses_normalized co ON c.course_id = co.id
        WHERE v.is_complete = 0
        ORDER BY v.discovered_at ASC, co.id, c.index_order, v.index_order
    `);
    console.log('  ✓ Created incomplete_videos view');

    // Mark existing videos as complete (they have transcripts)
    const updateResult = db.prepare(`
        UPDATE videos_normalized
        SET is_complete = 1, completed_at = CURRENT_TIMESTAMP
        WHERE id IN (
            SELECT DISTINCT video_id FROM transcripts_normalized
        )
    `).run();
    console.log(`  ✓ Marked ${updateResult.changes} existing videos as complete`);

    db.close();
    console.log('Migration 010 complete!');
}

module.exports = { migrate };

if (require.main === module) {
    migrate();
}
```

### A.2 Migration 011: Parallel Completion

```javascript
// scripts/migrations/011_parallel_completion.js
'use strict';

const path = require('path');
const Database = require('better-sqlite3');

const DB_PATH = path.join(__dirname, '../../data/lte.db');

function migrate() {
    const db = new Database(DB_PATH);
    db.pragma('journal_mode = WAL');

    console.log('Migration 011: Adding parallel completion tables...');

    // Create completion_jobs table
    db.exec(`
        CREATE TABLE IF NOT EXISTS completion_jobs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            job_id TEXT NOT NULL UNIQUE,
            course_id INTEGER,
            status TEXT DEFAULT 'pending',
            concurrency INTEGER DEFAULT 3,
            videos_total INTEGER DEFAULT 0,
            videos_completed INTEGER DEFAULT 0,
            videos_failed INTEGER DEFAULT 0,
            started_at TEXT,
            completed_at TEXT,
            error TEXT,
            FOREIGN KEY (course_id) REFERENCES courses_normalized(id)
        )
    `);
    console.log('  ✓ Created completion_jobs table');

    // Create completion_tasks table
    db.exec(`
        CREATE TABLE IF NOT EXISTS completion_tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            job_id TEXT NOT NULL,
            video_id INTEGER NOT NULL,
            worker_id INTEGER,
            status TEXT DEFAULT 'pending',
            attempts INTEGER DEFAULT 0,
            started_at TEXT,
            completed_at TEXT,
            error TEXT,
            FOREIGN KEY (job_id) REFERENCES completion_jobs(job_id),
            FOREIGN KEY (video_id) REFERENCES videos_normalized(id)
        )
    `);
    console.log('  ✓ Created completion_tasks table');

    // Create indexes
    db.exec(`
        CREATE INDEX IF NOT EXISTS idx_completion_tasks_status
        ON completion_tasks(job_id, status);

        CREATE INDEX IF NOT EXISTS idx_completion_tasks_worker
        ON completion_tasks(worker_id, status);

        CREATE INDEX IF NOT EXISTS idx_completion_jobs_status
        ON completion_jobs(status);
    `);
    console.log('  ✓ Created indexes');

    db.close();
    console.log('Migration 011 complete!');
}

module.exports = { migrate };

if (require.main === module) {
    migrate();
}
```

### A.3 Migration 012: Versioning

```javascript
// scripts/migrations/012_versioning.js
'use strict';

const path = require('path');
const Database = require('better-sqlite3');

const DB_PATH = path.join(__dirname, '../../data/lte.db');

function migrate() {
    const db = new Database(DB_PATH);
    db.pragma('journal_mode = WAL');

    console.log('Migration 012: Adding versioning tables...');

    // Create transcript_versions table
    db.exec(`
        CREATE TABLE IF NOT EXISTS transcript_versions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            video_id INTEGER NOT NULL,
            version_number INTEGER NOT NULL,
            content TEXT NOT NULL,
            content_hash TEXT NOT NULL,
            language TEXT,
            word_count INTEGER,
            segment_count INTEGER,
            captured_at TEXT NOT NULL,
            previous_version_id INTEGER,
            change_type TEXT,
            change_summary TEXT,
            FOREIGN KEY (video_id) REFERENCES videos_normalized(id),
            FOREIGN KEY (previous_version_id) REFERENCES transcript_versions(id),
            UNIQUE(video_id, version_number)
        )
    `);
    console.log('  ✓ Created transcript_versions table');

    // Create current_transcripts table
    db.exec(`
        CREATE TABLE IF NOT EXISTS current_transcripts (
            video_id INTEGER PRIMARY KEY,
            current_version_id INTEGER NOT NULL,
            FOREIGN KEY (video_id) REFERENCES videos_normalized(id),
            FOREIGN KEY (current_version_id) REFERENCES transcript_versions(id)
        )
    `);
    console.log('  ✓ Created current_transcripts table');

    // Add content_hash to existing transcripts
    try {
        db.exec('ALTER TABLE transcripts ADD COLUMN content_hash TEXT');
        console.log('  ✓ Added content_hash to transcripts table');
    } catch (err) {
        if (err.message.includes('duplicate column')) {
            console.log('  - content_hash column already exists');
        } else {
            throw err;
        }
    }

    // Create update_schedules table
    db.exec(`
        CREATE TABLE IF NOT EXISTS update_schedules (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            course_id INTEGER,
            schedule_type TEXT NOT NULL,
            cron_expression TEXT,
            last_run_at TEXT,
            next_run_at TEXT,
            enabled INTEGER DEFAULT 1,
            FOREIGN KEY (course_id) REFERENCES courses_normalized(id)
        )
    `);
    console.log('  ✓ Created update_schedules table');

    // Create update_runs table
    db.exec(`
        CREATE TABLE IF NOT EXISTS update_runs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            schedule_id INTEGER,
            course_id INTEGER,
            run_type TEXT NOT NULL,
            started_at TEXT NOT NULL,
            completed_at TEXT,
            status TEXT DEFAULT 'running',
            videos_checked INTEGER DEFAULT 0,
            videos_changed INTEGER DEFAULT 0,
            error TEXT,
            FOREIGN KEY (schedule_id) REFERENCES update_schedules(id),
            FOREIGN KEY (course_id) REFERENCES courses_normalized(id)
        )
    `);
    console.log('  ✓ Created update_runs table');

    // Create indexes
    db.exec(`
        CREATE INDEX IF NOT EXISTS idx_transcript_versions_video
        ON transcript_versions(video_id);

        CREATE INDEX IF NOT EXISTS idx_transcript_versions_hash
        ON transcript_versions(content_hash);

        CREATE INDEX IF NOT EXISTS idx_update_schedules_next
        ON update_schedules(next_run_at) WHERE enabled = 1;
    `);
    console.log('  ✓ Created indexes');

    db.close();
    console.log('Migration 012 complete!');
}

module.exports = { migrate };

if (require.main === module) {
    migrate();
}
```

---

## Appendix B: API Reference

### B.1 Etapa 1: Discovery API

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/discovery` | Discover single course structure |
| POST | `/api/discovery/batch` | Discover courses from folder |
| GET | `/api/discovery/:id/status` | Get discovery job status |
| GET | `/api/courses/incomplete` | List courses with incomplete videos |

### B.2 Etapa 2: Completion API

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/completion/course/:slug` | Complete course videos in parallel |
| POST | `/api/completion/videos` | Complete specific videos |
| GET | `/api/completion/job/:jobId` | Get completion job status |
| DELETE | `/api/completion/job/:jobId` | Cancel completion job |
| GET | `/api/completion/queue` | List running jobs and pending tasks |

### B.3 Etapa 3: Versioning API

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/versioning/check/:slug` | Check course for updates |
| GET | `/api/versioning/video/:id/history` | Get version history |
| GET | `/api/versioning/diff` | Get diff between versions |
| POST | `/api/versioning/rollback` | Rollback to previous version |
| POST | `/api/versioning/schedule` | Create update schedule |
| GET | `/api/versioning/schedules` | List all schedules |
| DELETE | `/api/versioning/schedule/:id` | Delete schedule |
| GET | `/api/versioning/runs` | List update run history |

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-02-02 | Software Architect | Initial proposal |

---

**Status:** PROPOSAL - Pending Technical Lead approval

**Next Steps:**
1. Review with Technical Lead
2. Validate estimates with development team
3. Create backlog stories for approved etapas
4. Begin implementation with Etapa 1
