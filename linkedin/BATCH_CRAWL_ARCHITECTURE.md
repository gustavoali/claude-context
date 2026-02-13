# Batch Crawl System Architecture

**Version:** 1.0.0
**Date:** 2026-01-28
**Author:** Software Architect (Claude)
**Status:** PROPOSED

---

## Executive Summary

This document describes the architecture for a batch crawl system that enables crawling multiple LinkedIn Learning courses from a folder/collection URL. The system extends the existing single-course crawler with queue management, progress tracking, and completion validation.

### Goals

1. Extract course list from LinkedIn Learning folder/collection URLs
2. Queue and execute crawls sequentially (respecting rate limits)
3. Track progress across multiple courses
4. Verify completion with transcript counts
5. Provide API endpoints for external triggering (ChatGPT)
6. Persist state for resume capability

### Non-Goals

- Parallel crawling (rate limiting concerns)
- User authentication management
- Course content analysis

---

## Current System Analysis

### Existing Components

```
                    +-------------------+
                    |   HTTP Server     |
                    |  (http-server.js) |
                    +--------+----------+
                             |
              +--------------+--------------+
              |                             |
    +---------v---------+         +---------v---------+
    |   Crawl Manager   |         |   Database Lib    |
    | (crawl-manager.js)|         |   (database.js)   |
    +---------+---------+         +-------------------+
              |
              | spawn (detached)
              |
    +---------v---------+
    |   Auto-Crawler    |
    | (auto-crawler.js) |
    +---------+---------+
              |
              | Playwright
              |
    +---------v---------+
    | VTT Interceptor   |
    |(vtt-interceptor.js|
    +-------------------+
```

### Current Capabilities

| Capability | Status | Notes |
|------------|--------|-------|
| Single course crawl | Working | via CLI or API |
| Crawl status tracking | Working | JSON files in data/crawls/ |
| Duplicate prevention | Working | 409 Conflict for active crawls |
| VTT language filtering | Working | Spanish-preferred with fallback |
| Post-crawl matching | Working | Semantic + order-based |
| Progress tracking | Working | totalVideos, processed, skipped, errors |

### Current Data Model

**Crawl Status File (`data/crawls/{crawlId}.json`):**
```json
{
  "crawlId": "uuid-v4",
  "courseSlug": "course-name",
  "url": "https://linkedin.com/learning/course-name",
  "status": "starting|in_progress|completed|failed",
  "progress": {
    "totalVideos": 20,
    "processed": 15,
    "skipped": 3,
    "errors": 2
  },
  "startedAt": "2026-01-28T10:00:00Z",
  "completedAt": "2026-01-28T10:30:00Z",
  "error": null
}
```

---

## Proposed Architecture

### System Overview

```
+------------------+     +-------------------+     +-------------------+
|   ChatGPT/User   |---->|   HTTP Server     |---->|  Batch Manager    |
|   (API Client)   |     |  (http-server.js) |     |(batch-manager.js) |
+------------------+     +-------------------+     +---------+---------+
                                                            |
                         +----------------------------------+
                         |                                  |
              +----------v----------+            +----------v----------+
              |   Folder Extractor  |            |    Queue Manager    |
              |  (folder-parser.js) |            | (batch-manager.js)  |
              +----------+----------+            +----------+----------+
                         |                                  |
                         | course list                      | dequeue next
                         |                                  |
              +----------v----------+            +----------v----------+
              |   LinkedIn Page     |            |   Crawl Manager     |
              |   (Playwright)      |            | (crawl-manager.js)  |
              +---------------------+            +----------+----------+
                                                           |
                                                           | spawn
                                                           |
                                                +----------v----------+
                                                |   Auto-Crawler      |
                                                | (auto-crawler.js)   |
                                                +---------------------+
```

### New Components

#### 1. Batch Manager (`server/lib/batch-manager.js`)

**Responsibilities:**
- Create and manage batch jobs
- Maintain course queue with FIFO ordering
- Track overall batch progress
- Coordinate with crawl-manager for individual crawls
- Handle resume logic after interruptions
- Trigger completion validation

**State Machine:**

```
                     +-------------+
                     |   CREATED   |
                     +------+------+
                            |
                            | extractCourses()
                            v
                     +------+------+
                     |  EXTRACTING |
                     +------+------+
                            |
                            | courses extracted
                            v
                     +------+------+
                     |   QUEUED    |<------------+
                     +------+------+             |
                            |                    |
                            | startNext()        | course completed
                            v                    |
                     +------+------+             |
                     |  CRAWLING   +-------------+
                     +------+------+
                            |
                            | all courses done
                            v
                     +------+------+
                     |  VALIDATING |
                     +------+------+
                            |
                            | validation complete
                            v
                     +------+------+
                     |  COMPLETED  |
                     +-------------+
                            |
             (or)           | error at any stage
                            v
                     +------+------+
                     |   FAILED    |
                     +-------------+
```

#### 2. Folder Parser (`crawler/folder-parser.js`)

**Responsibilities:**
- Parse LinkedIn Learning folder/collection URLs
- Extract course slugs from folder page DOM
- Handle pagination if folders have many courses
- Return structured course list

**URL Patterns to Support:**

```
# LinkedIn Learning Collections/Folders
https://www.linkedin.com/learning/collections/COLLECTION_ID
https://www.linkedin.com/learning/me/saved-courses
https://www.linkedin.com/learning/me/my-learning
https://www.linkedin.com/learning/topics/TOPIC_SLUG
https://www.linkedin.com/learning/paths/PATH_SLUG

# Direct course list (for manual input)
POST with { "courses": ["course-1", "course-2"] }
```

---

## Data Model

### Batch Job Record

**Location:** `data/batches/{batchId}.json`

```typescript
interface BatchJob {
  // Identity
  batchId: string;              // UUID v4
  createdAt: string;            // ISO timestamp

  // Source
  sourceType: 'folder' | 'collection' | 'topic' | 'path' | 'manual';
  sourceUrl: string | null;     // Original folder URL
  sourceName: string | null;    // Extracted folder/collection name

  // Status
  status: 'created' | 'extracting' | 'queued' | 'crawling' | 'validating' | 'completed' | 'failed' | 'paused';

  // Queue
  courses: CourseInBatch[];

  // Progress
  progress: {
    totalCourses: number;
    extracted: number;        // Courses extracted from folder
    queued: number;           // Courses waiting to crawl
    crawling: number;         // Currently crawling (0 or 1)
    completed: number;        // Successfully crawled
    failed: number;           // Failed to crawl
    skipped: number;          // Already in database
  };

  // Timing
  startedAt: string | null;
  completedAt: string | null;
  estimatedTimeRemaining: number | null;  // seconds

  // Validation
  validation: {
    totalExpectedVideos: number;
    totalActualVideos: number;
    coursesWithMissingVideos: string[];
    isValid: boolean;
  } | null;

  // Error handling
  error: string | null;
  retryCount: number;
  maxRetries: number;

  // Settings
  settings: {
    skipExisting: boolean;     // Skip courses already in DB
    continueOnError: boolean;  // Continue with next course on error
    delayBetweenCourses: number;  // Seconds between crawls (rate limiting)
    filterMode: string;        // VTT filter mode
  };
}

interface CourseInBatch {
  courseSlug: string;
  courseTitle: string | null;
  status: 'pending' | 'crawling' | 'completed' | 'failed' | 'skipped';
  crawlId: string | null;      // Reference to individual crawl

  // Progress (copied from crawl when available)
  progress: {
    totalVideos: number;
    processed: number;
    skipped: number;
    errors: number;
  } | null;

  // Timing
  startedAt: string | null;
  completedAt: string | null;

  // Error
  error: string | null;

  // Validation
  validation: {
    expectedVideos: number;    // From TOC extraction
    actualVideos: number;      // From database after crawl
    missingVideos: string[];   // Video slugs not captured
    isComplete: boolean;
  } | null;

  // Order
  queueIndex: number;
}
```

### Database Schema Extension

Add new table for batch tracking (optional, can use JSON files):

```sql
-- Optional: Add to database.js initializeTables()
CREATE TABLE IF NOT EXISTS batch_jobs (
  id TEXT PRIMARY KEY,
  source_type TEXT NOT NULL,
  source_url TEXT,
  source_name TEXT,
  status TEXT NOT NULL DEFAULT 'created',
  total_courses INTEGER DEFAULT 0,
  completed_courses INTEGER DEFAULT 0,
  failed_courses INTEGER DEFAULT 0,
  settings TEXT,  -- JSON
  created_at TEXT,
  started_at TEXT,
  completed_at TEXT,
  error TEXT
);

CREATE TABLE IF NOT EXISTS batch_courses (
  id TEXT PRIMARY KEY,
  batch_id TEXT NOT NULL,
  course_slug TEXT NOT NULL,
  course_title TEXT,
  status TEXT NOT NULL DEFAULT 'pending',
  crawl_id TEXT,
  queue_index INTEGER,
  expected_videos INTEGER,
  actual_videos INTEGER,
  started_at TEXT,
  completed_at TEXT,
  error TEXT,
  FOREIGN KEY (batch_id) REFERENCES batch_jobs(id)
);

CREATE INDEX IF NOT EXISTS idx_batch_courses_batch ON batch_courses(batch_id);
CREATE INDEX IF NOT EXISTS idx_batch_courses_status ON batch_courses(status);
```

---

## API Design

### New Endpoints

#### POST /api/batch-crawl

Start a batch crawl from a folder URL or course list.

**Request:**
```json
{
  "url": "https://www.linkedin.com/learning/collections/123456",
  // OR
  "courses": ["course-slug-1", "course-slug-2"],

  // Optional settings
  "settings": {
    "skipExisting": true,
    "continueOnError": true,
    "delayBetweenCourses": 30,
    "filterMode": "strict"
  }
}
```

**Response (202 Accepted):**
```json
{
  "batchId": "uuid-v4",
  "status": "extracting",
  "message": "Batch crawl started. Extracting courses from folder...",
  "statusUrl": "/api/batch-crawl/uuid-v4/status"
}
```

**Response (400 Bad Request):**
```json
{
  "error": "Either 'url' or 'courses' must be provided",
  "expected": {
    "url": "https://www.linkedin.com/learning/collections/ID",
    "or": { "courses": ["slug-1", "slug-2"] }
  }
}
```

**Response (409 Conflict):**
```json
{
  "error": "A batch crawl is already in progress",
  "conflict": true,
  "batchId": "existing-batch-id",
  "status": "crawling",
  "progress": { ... }
}
```

#### GET /api/batch-crawl/:batchId/status

Get detailed batch status.

**Response (200 OK):**
```json
{
  "batchId": "uuid-v4",
  "status": "crawling",
  "sourceType": "collection",
  "sourceName": "My Learning Path",

  "progress": {
    "totalCourses": 10,
    "extracted": 10,
    "queued": 5,
    "crawling": 1,
    "completed": 3,
    "failed": 1,
    "skipped": 0
  },

  "currentCourse": {
    "courseSlug": "learning-python",
    "courseTitle": "Learning Python",
    "crawlId": "crawl-uuid",
    "progress": {
      "totalVideos": 50,
      "processed": 25,
      "skipped": 0,
      "errors": 0
    }
  },

  "timing": {
    "startedAt": "2026-01-28T10:00:00Z",
    "estimatedTimeRemaining": 3600,
    "avgCourseTime": 1800
  },

  "courses": [
    {
      "courseSlug": "course-1",
      "status": "completed",
      "progress": { ... }
    },
    {
      "courseSlug": "course-2",
      "status": "crawling",
      "progress": { ... }
    },
    {
      "courseSlug": "course-3",
      "status": "pending"
    }
  ]
}
```

#### POST /api/batch-crawl/:batchId/pause

Pause a running batch (after current course completes).

**Response (200 OK):**
```json
{
  "batchId": "uuid-v4",
  "status": "paused",
  "pausedAt": "2026-01-28T11:00:00Z",
  "resumeUrl": "/api/batch-crawl/uuid-v4/resume"
}
```

#### POST /api/batch-crawl/:batchId/resume

Resume a paused batch.

**Response (200 OK):**
```json
{
  "batchId": "uuid-v4",
  "status": "crawling",
  "resumedAt": "2026-01-28T11:30:00Z",
  "nextCourse": "course-slug-4"
}
```

#### GET /api/batches

List recent batch jobs.

**Response (200 OK):**
```json
{
  "totalBatches": 5,
  "batches": [
    {
      "batchId": "uuid-v4",
      "sourceName": "AI Learning Path",
      "status": "completed",
      "progress": { "totalCourses": 10, "completed": 10 },
      "startedAt": "2026-01-27T10:00:00Z",
      "completedAt": "2026-01-27T15:00:00Z"
    }
  ]
}
```

---

## Component Design

### Batch Manager (`server/lib/batch-manager.js`)

```javascript
/**
 * Batch Manager - Orchestrates multi-course crawling
 *
 * Key responsibilities:
 * 1. Create batch jobs from folder URLs or course lists
 * 2. Extract courses from folder pages (via folder-parser)
 * 3. Queue management (FIFO)
 * 4. Coordinate with crawl-manager for individual crawls
 * 5. Monitor crawl completion and trigger next
 * 6. Handle errors and retries
 * 7. Persist state for resume capability
 */

// ============ Exports ============

export function startBatch(options);         // Create and start batch
export function getBatchStatus(batchId);     // Get batch status
export function pauseBatch(batchId);         // Pause after current course
export function resumeBatch(batchId);        // Resume paused batch
export function cancelBatch(batchId);        // Cancel batch entirely
export function listBatches(limit);          // List recent batches
export function validateBatch(batchId);      // Run completion validation

// ============ Internal Functions ============

function createBatchJob(options);            // Initialize batch record
function extractCoursesFromFolder(url);      // Use folder-parser
function queueCourses(batchId, courses);     // Add courses to queue
function processQueue(batchId);              // Main queue processing loop
function startNextCourse(batchId);           // Dequeue and start crawl
function onCrawlComplete(batchId, courseSlug, crawlStatus);  // Handle completion
function onCrawlFailed(batchId, courseSlug, error);          // Handle failure
function validateCourseCompletion(courseSlug);  // Check transcript counts
function updateBatchProgress(batchId);       // Recalculate progress
function saveBatchState(batchId, state);     // Persist to JSON
function loadBatchState(batchId);            // Load from JSON
function findActiveBatch();                  // Check for running batch
function cleanupOldBatches(maxAgeHours);     // Remove old batch files

// ============ Queue Processing ============

/**
 * Process queue continuously until all courses done
 * This runs as an async loop, started by startBatch()
 */
async function processQueue(batchId) {
  const batch = loadBatchState(batchId);

  while (batch.status === 'crawling') {
    // Find next pending course
    const nextCourse = batch.courses.find(c => c.status === 'pending');

    if (!nextCourse) {
      // All courses processed, run validation
      await validateBatch(batchId);
      updateBatchStatus(batchId, 'completed');
      break;
    }

    // Check for pause request
    if (batch.status === 'paused') {
      break;
    }

    // Start crawl for next course
    const crawlResult = startCrawl(nextCourse.courseSlug);

    if (crawlResult.success) {
      updateCourseStatus(batchId, nextCourse.courseSlug, 'crawling', {
        crawlId: crawlResult.crawlId
      });

      // Wait for crawl to complete (poll status)
      await waitForCrawlCompletion(crawlResult.crawlId);

      // Get final crawl status
      const crawlStatus = getCrawlStatus(crawlResult.crawlId);

      if (crawlStatus.status === 'completed') {
        await onCrawlComplete(batchId, nextCourse.courseSlug, crawlStatus);
      } else {
        await onCrawlFailed(batchId, nextCourse.courseSlug, crawlStatus.error);
      }
    } else if (crawlResult.conflict) {
      // Course already being crawled, wait and retry
      await sleep(60000);
    } else {
      // Failed to start crawl
      await onCrawlFailed(batchId, nextCourse.courseSlug, crawlResult.error);
    }

    // Rate limiting delay between courses
    await sleep(batch.settings.delayBetweenCourses * 1000);
  }
}
```

### Folder Parser (`crawler/folder-parser.js`)

```javascript
/**
 * Folder Parser - Extracts course list from LinkedIn Learning folders
 *
 * Uses Playwright to navigate to folder page and extract course links
 * Reuses browser session from auto-crawler for authentication
 */

// ============ Exports ============

export async function extractCoursesFromFolder(folderUrl, options);
export function parseLinkedInFolderUrl(url);
export function identifyFolderType(url);

// ============ URL Type Detection ============

const FOLDER_URL_PATTERNS = {
  collection: /linkedin\.com\/learning\/collections\/([^/?#]+)/,
  savedCourses: /linkedin\.com\/learning\/me\/saved-courses/,
  myLearning: /linkedin\.com\/learning\/me\/my-learning/,
  topic: /linkedin\.com\/learning\/topics\/([^/?#]+)/,
  path: /linkedin\.com\/learning\/paths\/([^/?#]+)/,
  search: /linkedin\.com\/learning\/search\?/
};

/**
 * Identify folder type from URL
 */
function identifyFolderType(url) {
  for (const [type, pattern] of Object.entries(FOLDER_URL_PATTERNS)) {
    if (pattern.test(url)) {
      return type;
    }
  }
  return 'unknown';
}

// ============ Course Extraction ============

/**
 * Extract courses from a folder page
 * @param {string} folderUrl - LinkedIn Learning folder URL
 * @param {object} options - Extraction options
 * @returns {Promise<{courses: Array, folderName: string, totalFound: number}>}
 */
async function extractCoursesFromFolder(folderUrl, options = {}) {
  const {
    maxCourses = 100,           // Limit extraction
    includeProgress = false,    // Include user's progress %
    timeout = 30000
  } = options;

  const folderType = identifyFolderType(folderUrl);

  // Launch browser with existing session
  const context = await launchBrowser(loadConfig());
  const page = await context.newPage();

  try {
    await page.goto(folderUrl, { timeout });
    await page.waitForTimeout(3000);  // Wait for dynamic content

    // Extract folder name
    const folderName = await extractFolderName(page, folderType);

    // Scroll to load all courses (pagination)
    await scrollToLoadAll(page, maxCourses);

    // Extract course links
    const courses = await page.evaluate((max) => {
      const courseLinks = document.querySelectorAll(
        'a[href*="/learning/"][href*="course"], ' +
        '.learning-card a, ' +
        '[data-test="learning-card"] a, ' +
        '.course-card a'
      );

      const seen = new Set();
      const results = [];

      for (const link of courseLinks) {
        if (results.length >= max) break;

        const match = link.href.match(/\/learning\/([^/?#]+)/);
        if (match && !seen.has(match[1])) {
          // Skip non-course paths
          if (['collections', 'topics', 'paths', 'me', 'search'].includes(match[1])) {
            continue;
          }

          seen.add(match[1]);

          // Try to extract title
          const titleEl = link.querySelector('h3, h4, .course-title, [data-test="card-title"]');
          const title = titleEl?.textContent?.trim() || null;

          results.push({
            courseSlug: match[1],
            courseTitle: title,
            url: link.href.split('?')[0]
          });
        }
      }

      return results;
    }, maxCourses);

    return {
      courses,
      folderName,
      folderType,
      totalFound: courses.length
    };

  } finally {
    await context.close();
  }
}

/**
 * Scroll page to load all lazy-loaded content
 */
async function scrollToLoadAll(page, maxItems) {
  let previousCount = 0;
  let sameCountIterations = 0;

  while (sameCountIterations < 3) {  // Stop if count unchanged 3x
    const currentCount = await page.evaluate(() => {
      return document.querySelectorAll('a[href*="/learning/"]').length;
    });

    if (currentCount >= maxItems) break;

    if (currentCount === previousCount) {
      sameCountIterations++;
    } else {
      sameCountIterations = 0;
    }

    previousCount = currentCount;

    // Scroll down
    await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
    await page.waitForTimeout(1000);
  }
}
```

---

## Sequence Diagrams

### Start Batch Crawl

```
User            HTTP Server       Batch Manager       Folder Parser       Crawl Manager
 |                   |                  |                   |                   |
 |-- POST /batch --->|                  |                   |                   |
 |                   |-- startBatch() ->|                   |                   |
 |                   |                  |-- createJob() --->|                   |
 |                   |                  |                   |                   |
 |                   |                  |-- extractCourses()|                   |
 |                   |                  |<-- courses[] -----|                   |
 |                   |                  |                   |                   |
 |                   |<-- 202 Accepted--|                   |                   |
 |<-- batchId -------|                  |                   |                   |
 |                   |                  |                   |                   |
 |                   |                  |== processQueue() loop ==============>|
 |                   |                  |                   |                   |
 |                   |                  |-- startCrawl() -->|-- spawn -------->|
 |                   |                  |<-- crawlId -------|                   |
 |                   |                  |                   |                   |
 |                   |                  |-- waitForComplete |                   |
 |                   |                  |     (poll)        |                   |
 |                   |                  |<-- completed -----|                   |
 |                   |                  |                   |                   |
 |                   |                  |-- startCrawl() -->|  (next course)   |
 |                   |                  |   ...             |                   |
 |                   |                  |                   |                   |
 |                   |                  |-- validateBatch() |                   |
 |                   |                  |<-- validation ----|                   |
 |                   |                  |                   |                   |
```

### Poll Batch Status

```
User            HTTP Server       Batch Manager
 |                   |                  |
 |-- GET status ---->|                  |
 |                   |-- getStatus() -->|
 |                   |<-- batchState ---|
 |<-- 200 OK --------|                  |
 |   (with progress) |                  |
```

### Resume After Interruption

```
Server Restart      Batch Manager       Crawl Manager
      |                   |                   |
      |-- init() -------->|                   |
      |                   |-- loadBatches() ->|
      |                   |   (from JSON)     |
      |                   |                   |
      |                   |-- findActive() -->|
      |                   |<-- batch w/       |
      |                   |    crawling=true  |
      |                   |                   |
      |                   |-- Check crawl --->|
      |                   |   status          |
      |                   |                   |
      |                   |<-- completed/     |
      |                   |    failed         |
      |                   |                   |
      |                   |-- processQueue() >|
      |                   |   (continue)      |
```

---

## Error Handling

### Error Categories

| Category | Example | Handling |
|----------|---------|----------|
| **Folder Extraction** | Invalid URL, auth expired | Fail batch, report error |
| **Crawl Start** | Duplicate crawl, resource limit | Retry with delay, or skip |
| **Crawl Execution** | Network error, timeout | Retry course, or mark failed |
| **Validation** | Missing transcripts | Report in validation, mark partial |

### Retry Strategy

```javascript
const RETRY_CONFIG = {
  maxRetriesPerCourse: 2,
  retryDelayMs: 60000,       // 1 minute
  backoffMultiplier: 2,      // Exponential backoff
  maxRetryDelayMs: 300000    // 5 minutes max
};
```

### Error Recovery Flow

```
Course Crawl Failed
        |
        v
  +-----+-----+
  | Retry     |
  | available?|
  +-----+-----+
    |       |
   Yes      No
    |       |
    v       v
  Retry   +----------+
  crawl   | Continue |
          | on error?|
          +----+-----+
            |       |
           Yes      No
            |       |
            v       v
         Mark as  Fail
         failed,  entire
         continue batch
```

---

## Persistence Strategy

### File-Based Storage

**Rationale:** Keep batch state in JSON files (like current crawl-manager) for simplicity. SQLite integration optional for querying.

**Files:**
```
data/
  batches/
    {batchId}.json          # Full batch state
    {batchId}.progress.json # Progress snapshot (frequent updates)
  crawls/
    {crawlId}.json          # Individual crawl state (existing)
```

### State Persistence Points

| Event | What to Persist |
|-------|-----------------|
| Batch created | Full batch state |
| Courses extracted | Course list with queue order |
| Course started | Course status = crawling, crawlId |
| Progress update | Progress snapshot (every 30s during crawl) |
| Course completed | Course status, progress, validation |
| Course failed | Course status, error message |
| Batch completed | Final status, validation results |

### Resume Logic

```javascript
/**
 * On server startup, check for interrupted batches
 */
async function initBatchManager() {
  const batches = listBatchFiles();

  for (const batchFile of batches) {
    const batch = loadBatchState(batchFile);

    if (batch.status === 'crawling') {
      // Find course that was crawling
      const crawlingCourse = batch.courses.find(c => c.status === 'crawling');

      if (crawlingCourse) {
        // Check if crawl is still running or completed
        const crawlStatus = getCrawlStatus(crawlingCourse.crawlId);

        if (!crawlStatus || crawlStatus.status === 'failed') {
          // Crawl was interrupted, retry or mark failed
          await handleInterruptedCrawl(batch.batchId, crawlingCourse);
        } else if (crawlStatus.status === 'completed') {
          // Crawl completed while we were down
          await onCrawlComplete(batch.batchId, crawlingCourse.courseSlug, crawlStatus);
        }
        // If still 'in_progress', wait for it
      }

      // Resume queue processing
      processQueue(batch.batchId);
    }
  }
}
```

---

## Completion Validation

### What to Validate

1. **Transcript Count:** Compare expected videos (from TOC) vs actual transcripts
2. **Missing Videos:** List specific video slugs without transcripts
3. **Empty Transcripts:** Detect transcripts with no content

### Validation Process

```javascript
/**
 * Validate batch completion
 * Called after all courses processed
 */
async function validateBatch(batchId) {
  const batch = loadBatchState(batchId);
  const validation = {
    totalExpectedVideos: 0,
    totalActualVideos: 0,
    coursesWithMissingVideos: [],
    isValid: true
  };

  for (const course of batch.courses) {
    if (course.status !== 'completed') continue;

    // Get expected videos from crawl progress
    const expectedVideos = course.progress?.totalVideos || 0;

    // Get actual transcripts from database
    const actualTranscripts = getTranscriptsByCourse(course.courseSlug);
    const actualVideos = actualTranscripts.length;

    validation.totalExpectedVideos += expectedVideos;
    validation.totalActualVideos += actualVideos;

    // Check for missing
    const missing = expectedVideos - actualVideos;
    if (missing > 0) {
      validation.coursesWithMissingVideos.push({
        courseSlug: course.courseSlug,
        expected: expectedVideos,
        actual: actualVideos,
        missing
      });
      validation.isValid = false;
    }

    // Store per-course validation
    course.validation = {
      expectedVideos,
      actualVideos,
      isComplete: missing === 0
    };
  }

  batch.validation = validation;
  saveBatchState(batch);

  return validation;
}
```

---

## Rate Limiting Strategy

### LinkedIn Learning Considerations

- **No official API:** All access via web scraping
- **Authentication required:** Session cookies
- **Rate limits:** Undocumented, but aggressive crawling can trigger blocks

### Recommended Delays

| Action | Delay | Rationale |
|--------|-------|-----------|
| Between videos (within course) | 2-8 seconds | Current auto-crawler config |
| Between courses | 30-60 seconds | Prevent session blocking |
| After error | 60-300 seconds | Exponential backoff |
| Max crawl duration | 2 hours/course | Prevent stuck crawls |

### Implementation

```javascript
// In batch-manager.js
const RATE_LIMITS = {
  minDelayBetweenCourses: 30000,    // 30 seconds minimum
  defaultDelayBetweenCourses: 60000, // 1 minute default
  maxDelayBetweenCourses: 300000,   // 5 minutes maximum
  errorBackoffMultiplier: 2,
  maxConcurrentBatches: 1,          // Only one batch at a time
  maxCrawlDuration: 7200000         // 2 hours
};

// Adaptive delay based on errors
function calculateDelay(batch) {
  const recentErrors = batch.courses
    .filter(c => c.status === 'failed')
    .filter(c => Date.now() - new Date(c.completedAt).getTime() < 3600000)
    .length;

  const baseDelay = batch.settings.delayBetweenCourses || RATE_LIMITS.defaultDelayBetweenCourses;
  const errorMultiplier = Math.pow(RATE_LIMITS.errorBackoffMultiplier, Math.min(recentErrors, 5));

  return Math.min(baseDelay * errorMultiplier, RATE_LIMITS.maxDelayBetweenCourses);
}
```

---

## Implementation Plan

### Phase 1: Core Infrastructure (8 hours)

**Tasks:**
1. Create `server/lib/batch-manager.js` with basic CRUD
2. Create `data/batches/` directory management
3. Implement batch state persistence (JSON files)
4. Add API endpoints to `http-server.js`
5. Basic error handling

**Deliverables:**
- `POST /api/batch-crawl` (manual course list)
- `GET /api/batch-crawl/:id/status`
- `GET /api/batches`

### Phase 2: Folder Extraction (6 hours)

**Tasks:**
1. Create `crawler/folder-parser.js`
2. Implement URL type detection
3. Implement course extraction via Playwright
4. Handle pagination/lazy loading
5. Integration with batch-manager

**Deliverables:**
- Folder URL parsing for collections, topics, paths
- Course extraction with titles

### Phase 3: Queue Processing (6 hours)

**Tasks:**
1. Implement queue processing loop
2. Integration with existing crawl-manager
3. Progress tracking and state updates
4. Rate limiting between courses
5. Handle crawl completion callbacks

**Deliverables:**
- Automatic sequential crawling
- Progress tracking via status endpoint

### Phase 4: Error Handling & Resume (4 hours)

**Tasks:**
1. Implement retry logic per course
2. Error categorization and handling
3. Resume logic on server restart
4. Pause/Resume endpoints
5. Cleanup of old batch files

**Deliverables:**
- Robust error recovery
- Resume capability after interruption

### Phase 5: Validation & Reporting (4 hours)

**Tasks:**
1. Implement completion validation
2. Missing video detection
3. Batch completion report
4. OpenAPI spec update

**Deliverables:**
- Validation results in status response
- Complete API documentation

### Phase 6: Testing & Documentation (4 hours)

**Tasks:**
1. Unit tests for batch-manager
2. Unit tests for folder-parser
3. Integration test for full batch flow
4. Update README and API docs

**Deliverables:**
- Test suite with >70% coverage
- Updated documentation

---

## Total Estimated Effort

| Phase | Hours |
|-------|-------|
| Phase 1: Core Infrastructure | 8 |
| Phase 2: Folder Extraction | 6 |
| Phase 3: Queue Processing | 6 |
| Phase 4: Error Handling & Resume | 4 |
| Phase 5: Validation & Reporting | 4 |
| Phase 6: Testing & Documentation | 4 |
| **Total** | **32 hours** |

---

## Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| LinkedIn blocks scraping | Medium | High | Rate limiting, delays, session rotation |
| Folder page structure changes | Medium | Medium | Multiple selector fallbacks |
| Long-running batches fail | Medium | Medium | Checkpoint/resume, progress persistence |
| Browser memory issues | Low | Medium | Process isolation, cleanup between courses |
| Crawl stuck indefinitely | Low | High | Timeout limits, health checks |

---

## OpenAPI Additions

```yaml
# Add to openapi.json paths
/api/batch-crawl:
  post:
    operationId: startBatchCrawl
    summary: Start a batch crawl from a folder URL or course list
    description: |
      Initiates a batch crawl process that will sequentially crawl all courses
      from a LinkedIn Learning folder, collection, or provided course list.
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            properties:
              url:
                type: string
                description: LinkedIn Learning folder/collection URL
                example: "https://www.linkedin.com/learning/collections/123456"
              courses:
                type: array
                items:
                  type: string
                description: Alternative - list of course slugs
                example: ["learning-python", "learning-javascript"]
              settings:
                type: object
                properties:
                  skipExisting:
                    type: boolean
                    default: true
                  continueOnError:
                    type: boolean
                    default: true
                  delayBetweenCourses:
                    type: integer
                    default: 60
    responses:
      '202':
        description: Batch crawl started
      '400':
        description: Invalid request
      '409':
        description: Batch already in progress

/api/batch-crawl/{batchId}/status:
  get:
    operationId: getBatchCrawlStatus
    summary: Get batch crawl progress
    parameters:
      - name: batchId
        in: path
        required: true
        schema:
          type: string
    responses:
      '200':
        description: Batch status

/api/batch-crawl/{batchId}/pause:
  post:
    operationId: pauseBatchCrawl
    summary: Pause batch after current course

/api/batch-crawl/{batchId}/resume:
  post:
    operationId: resumeBatchCrawl
    summary: Resume paused batch

/api/batches:
  get:
    operationId: listBatches
    summary: List recent batch operations
```

---

## Appendix: Example Session

### ChatGPT Interaction

```
User: Can you crawl all courses from my "AI Learning" collection?

ChatGPT: I'll start a batch crawl for your AI Learning collection. Let me check the URL format you need to provide.

[Calls GET /api/status to verify server is running]

ChatGPT: Please provide the LinkedIn Learning URL for your collection. It should look like:
- https://www.linkedin.com/learning/collections/YOUR_COLLECTION_ID

User: Here it is: https://www.linkedin.com/learning/collections/6892737486543872000

ChatGPT: [Calls POST /api/batch-crawl with { url: "..." }]

Great! I've started the batch crawl. Here's the status:
- Batch ID: abc123
- Status: Extracting courses from collection...

I'll check the progress in a moment.

[Waits 30 seconds, calls GET /api/batch-crawl/abc123/status]

The batch is now crawling:
- Total courses found: 12
- Currently crawling: "Learning Python" (video 15/50)
- Completed: 2 courses
- Remaining: 9 courses

Estimated time: ~3 hours

Would you like me to check again later, or should I notify you when it's complete?

User: Check again in 30 minutes

[30 minutes later]

ChatGPT: [Calls GET /api/batch-crawl/abc123/status]

Update on your batch crawl:
- Status: Crawling
- Completed: 7/12 courses
- Currently: "Machine Learning Foundations" (video 32/45)
- Failed: 1 course (will retry)

Validation so far:
- Expected transcripts: 312
- Captured: 298 (96%)

Shall I continue monitoring?
```

---

## Conclusion

This architecture extends the existing single-course crawl system with batch capabilities while maintaining:

1. **Backward Compatibility:** Existing `/api/crawl` endpoints unchanged
2. **Robustness:** State persistence, error recovery, resume capability
3. **Rate Limit Compliance:** Sequential processing with configurable delays
4. **Visibility:** Detailed progress tracking via API
5. **Validation:** Post-crawl verification of transcript completeness

The modular design allows for incremental implementation, with each phase delivering usable functionality.

---

**Document Status:** PROPOSED
**Review Required:** Technical Lead, Product Owner
**Next Steps:** Create user stories in PRODUCT_BACKLOG.md
