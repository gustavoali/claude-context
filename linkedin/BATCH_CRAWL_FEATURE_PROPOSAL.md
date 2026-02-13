# Feature Proposal: Batch Crawl from LinkedIn Learning Folders

**Document Version:** 1.0
**Date:** 2026-01-28
**Author:** Product Owner (Claude)
**Status:** PROPOSAL - Pending Technical Validation

---

## Executive Summary

This proposal outlines a batch crawl feature that enables automatic discovery and crawling of all courses from a LinkedIn Learning folder (saved courses, collections, or learning paths). The feature addresses the user need to capture transcripts from multiple courses without manual intervention.

---

## Research Findings

### LinkedIn Learning Folder Types

Based on research, LinkedIn Learning supports several ways to organize courses:

| Folder Type | Description | URL Pattern (Estimated) | Access Method |
|-------------|-------------|------------------------|---------------|
| **Saved Courses** | User's bookmarked courses | `/learning/me/saved` or `/learning/saved` | User profile menu > Saved |
| **Collections** | User-created groupings | `/learning/collections/{id}` | My Learning > Collections |
| **Learning Paths** | Curated course sequences | `/learning/paths/{slug}` | Browse > Learning Paths |
| **My Learning** | All in-progress courses | `/learning/me/` | My Learning tab |

**Technical Limitation:** LinkedIn Learning does not expose a public API for accessing saved courses or collections. The existing crawler uses browser automation (Playwright) which CAN access these pages when authenticated.

### Current System Capabilities

The existing crawler (`auto-crawler.js`) already supports:
- Session persistence (login saved across crawls)
- Course navigation and video extraction
- VTT capture via interception
- Progress tracking via status files
- API-triggered crawls (`POST /api/crawl`)

**Gap:** Currently only supports single-course crawls via direct URL.

---

## User Stories

### US-1: Discover Courses from Folder URL

**ID:** LTE-024
**Story Points:** 8
**Priority:** HIGH
**Status:** PROPOSAL

**As a** user with multiple saved courses
**I want** to provide a folder URL and have the system discover all courses in it
**So that** I don't have to manually copy each course URL

#### Acceptance Criteria

**AC1: Saved Courses Page Discovery**
- Given a URL like `https://www.linkedin.com/learning/me/saved`
- When the batch crawler navigates to this page
- Then it extracts all course links from the page
- And returns a list with course slugs and titles

**AC2: Collection Page Discovery**
- Given a URL like `https://www.linkedin.com/learning/collections/{id}`
- When the batch crawler navigates to this page
- Then it extracts all course links from the collection
- And handles pagination if the collection has many courses

**AC3: Learning Path Discovery**
- Given a URL like `https://www.linkedin.com/learning/paths/{slug}`
- When the batch crawler navigates to this page
- Then it extracts all course links in the path order
- And preserves the sequence for ordered learning

**AC4: Invalid Folder URL Handling**
- Given an invalid or inaccessible folder URL
- When the batch crawler attempts to access it
- Then it returns a clear error message
- And suggests valid folder URL formats

#### Technical Notes
- Must handle LinkedIn's SPA navigation (dynamic loading)
- Need multiple CSS selectors for course card extraction (LinkedIn changes DOM frequently)
- Consider scroll-based lazy loading of course lists
- Session authentication required (same as single crawl)

---

### US-2: Queue-Based Batch Processing

**ID:** LTE-025
**Story Points:** 5
**Priority:** HIGH
**Status:** PROPOSAL

**As a** user initiating a batch crawl
**I want** courses to be processed sequentially in a queue
**So that** the system doesn't overload LinkedIn's servers or trigger rate limiting

#### Acceptance Criteria

**AC1: Queue Creation**
- Given a folder with N courses discovered
- When batch crawl starts
- Then a queue is created with all N courses
- And each course is marked as "pending"

**AC2: Sequential Processing**
- Given a queue of courses
- When processing begins
- Then only one course is crawled at a time
- And the next course starts only after the previous completes

**AC3: Configurable Delay**
- Given a batch crawl in progress
- When a course completes
- Then the system waits for a configurable delay (default: 60 seconds)
- And then starts the next course

**AC4: Resume After Interruption**
- Given a batch crawl that was interrupted (crash, restart)
- When the system restarts
- Then it can resume from the last incomplete course
- And already-completed courses are skipped

#### Technical Notes
- Leverage existing `data/crawls/` directory for queue state
- Create `batch-{id}.json` to track overall batch state
- Individual course crawls use existing `{crawl-id}.json` format
- Consider SQLite table for more robust queue management

---

### US-3: Completion Verification

**ID:** LTE-026
**Story Points:** 5
**Priority:** MEDIUM
**Status:** PROPOSAL

**As a** user who has completed a batch crawl
**I want** to verify that all courses were fully captured
**So that** I can identify and retry any failures

#### Acceptance Criteria

**AC1: Video Count Verification**
- Given a completed batch crawl
- When verification runs
- Then for each course, compare expected videos (from TOC) vs captured transcripts
- And flag courses with missing transcripts

**AC2: Verification Report**
- Given verification has completed
- When the report is generated
- Then it shows: course slug, expected videos, captured videos, missing videos, status
- And provides a summary with success rate percentage

**AC3: Retry Failed Courses**
- Given a verification report with failed courses
- When user requests retry
- Then only the failed/incomplete courses are re-queued
- And already-complete courses are skipped

**AC4: Individual Video Retry**
- Given a course with specific missing videos
- When detailed retry is requested
- Then only those specific videos are re-crawled
- And existing transcripts are preserved

#### Technical Notes
- Use existing `getCourseStructure()` to get expected video count
- Compare with `getTranscriptsByCourse()` for captured count
- Identify gaps by video slug comparison
- Retry mechanism uses existing single-course crawler

---

### US-4: Progress Reporting

**ID:** LTE-027
**Story Points:** 3
**Priority:** MEDIUM
**Status:** PROPOSAL

**As a** user with a batch crawl in progress
**I want** to see overall and per-course progress
**So that** I can estimate completion time and monitor for issues

#### Acceptance Criteria

**AC1: Overall Batch Progress**
- Given a batch crawl in progress
- When querying batch status
- Then return: total courses, completed, in progress, pending, failed
- And estimated time remaining based on average course duration

**AC2: Per-Course Progress**
- Given a specific course within a batch
- When querying course status
- Then return: total videos, processed, skipped, errors
- And current video being processed

**AC3: API Endpoints**
- Given the HTTP server is running
- When calling `GET /api/batch/{id}/status`
- Then return complete batch status
- And when calling `GET /api/batches` return list of recent batches

**AC4: Real-time Updates (Optional Enhancement)**
- Given a batch crawl in progress
- When watching for updates
- Then receive status updates via polling (every 10 seconds)
- Or consider WebSocket for real-time updates (future enhancement)

#### Technical Notes
- Extend existing `/api/crawl` endpoints to support batch operations
- Batch ID links to individual crawl IDs
- Consider adding ETA calculation based on historical crawl durations

---

## Technical Approach

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      HTTP Server                            │
│  POST /api/batch/crawl { folderUrl }                        │
│  GET /api/batch/{id}/status                                 │
│  GET /api/batches                                           │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                   Batch Manager                             │
│  - Validate folder URL                                      │
│  - Spawn folder discovery process                           │
│  - Create batch queue                                       │
│  - Schedule course crawls                                   │
└────────────────────────┬────────────────────────────────────┘
                         │
         ┌───────────────┼───────────────┐
         ▼               ▼               ▼
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│ Folder      │  │ Queue       │  │ Verification │
│ Discovery   │  │ Processor   │  │ Engine       │
│ (Playwright)│  │ (Sequential)│  │ (Compare DB) │
└─────────────┘  └─────────────┘  └──────────────┘
         │               │
         ▼               ▼
┌─────────────────────────────────────────────────────────────┐
│              Existing auto-crawler.js                       │
│  (Reused for individual course crawls)                      │
└─────────────────────────────────────────────────────────────┘
```

### New Components Required

| Component | File | Description |
|-----------|------|-------------|
| **Batch Manager** | `server/lib/batch-manager.js` | Orchestrates batch operations |
| **Folder Discovery** | `crawler/folder-discovery.js` | Extracts course list from folder pages |
| **Queue Processor** | `crawler/queue-processor.js` | Sequential course processing |
| **Verification Engine** | `scripts/verify-batch.js` | Compares expected vs actual |

### Data Model

**Batch Status File (`data/batches/{batch-id}.json`):**
```json
{
  "batchId": "uuid",
  "folderUrl": "https://linkedin.com/learning/me/saved",
  "folderType": "saved",
  "status": "in_progress",
  "courses": [
    {
      "courseSlug": "learning-python",
      "courseTitle": "Learning Python",
      "crawlId": "uuid",
      "status": "completed",
      "videosExpected": 45,
      "videosCaptured": 45
    },
    {
      "courseSlug": "advanced-sql",
      "courseTitle": "Advanced SQL",
      "crawlId": null,
      "status": "pending",
      "videosExpected": null,
      "videosCaptured": null
    }
  ],
  "progress": {
    "totalCourses": 10,
    "completed": 5,
    "inProgress": 1,
    "pending": 4,
    "failed": 0
  },
  "config": {
    "delayBetweenCourses": 60000,
    "skipExisting": true,
    "retryFailedVideos": true
  },
  "startedAt": "2026-01-28T10:00:00Z",
  "completedAt": null,
  "estimatedCompletion": "2026-01-28T12:30:00Z"
}
```

---

## Risks and Mitigations

### Risk 1: LinkedIn DOM Changes

**Description:** LinkedIn frequently changes their page structure, breaking course extraction.

**Probability:** HIGH (historically common)
**Impact:** HIGH (feature becomes non-functional)

**Mitigation:**
- Multiple fallback CSS selectors for course cards
- Structured error reporting when extraction fails
- Easy-to-update selector configuration
- Monitoring/alerting when extraction rates drop

### Risk 2: Rate Limiting / Account Blocking

**Description:** LinkedIn may detect automated access and block the account.

**Probability:** MEDIUM
**Impact:** CRITICAL (loss of LinkedIn account)

**Mitigation:**
- Conservative default delays (60s between courses)
- Randomized delays to appear more human-like
- Respect robot.txt (informational, not binding for personal use)
- Configurable batch size limits (e.g., max 20 courses per batch)
- User warning about automation risks

### Risk 3: Session Expiration During Long Batches

**Description:** LinkedIn session may expire during multi-hour batch crawls.

**Probability:** MEDIUM
**Impact:** MEDIUM (batch interruption, need to restart)

**Mitigation:**
- Session refresh mechanism (navigate to neutral page periodically)
- Save progress frequently so resume works
- Alert user if session appears invalid
- Consider shorter daily batch limits

### Risk 4: Resource Consumption

**Description:** Long-running batch process consumes system resources.

**Probability:** LOW
**Impact:** LOW (system slowdown)

**Mitigation:**
- Process runs detached (doesn't block other operations)
- Playwright browser closed between courses (optional config)
- Configurable concurrency (default: 1, for safety)

---

## Complexity Estimation

| User Story | Complexity | Estimate | Dependencies |
|------------|------------|----------|--------------|
| LTE-024: Folder Discovery | **LARGE** | 13 SP | New component, DOM parsing |
| LTE-025: Queue Processing | **MEDIUM** | 8 SP | LTE-024, state management |
| LTE-026: Verification | **MEDIUM** | 5 SP | LTE-025, database queries |
| LTE-027: Progress Reporting | **SMALL** | 3 SP | LTE-025, API extension |
| **TOTAL** | | **29 SP** | ~2 sprints |

---

## Recommended Implementation Order

### Phase 1: Foundation (Sprint N)
1. **LTE-024: Folder Discovery** (13 SP)
   - Start with "Saved Courses" page as it's most commonly used
   - Implement course link extraction
   - Create fallback selector strategy

### Phase 2: Automation (Sprint N+1)
2. **LTE-025: Queue Processing** (8 SP)
   - Depends on folder discovery working
   - Focus on sequential, reliable processing
   - Implement resume capability

3. **LTE-027: Progress Reporting** (3 SP)
   - Add API endpoints for batch status
   - Can be done in parallel with queue testing

### Phase 3: Reliability (Sprint N+2)
4. **LTE-026: Verification** (5 SP)
   - Run after queue processing is stable
   - Enables retry of failed items

---

## API Design

### POST /api/batch/crawl

**Request:**
```json
{
  "folderUrl": "https://www.linkedin.com/learning/me/saved",
  "options": {
    "delayBetweenCourses": 60000,
    "skipExisting": true,
    "maxCourses": 50
  }
}
```

**Response (202 Accepted):**
```json
{
  "batchId": "abc-123",
  "status": "discovering",
  "message": "Batch crawl started. Discovering courses from folder...",
  "statusUrl": "/api/batch/abc-123/status"
}
```

### GET /api/batch/{id}/status

**Response:**
```json
{
  "batchId": "abc-123",
  "status": "in_progress",
  "progress": {
    "totalCourses": 10,
    "completed": 5,
    "inProgress": 1,
    "pending": 4,
    "failed": 0,
    "percentComplete": 55
  },
  "currentCourse": {
    "slug": "learning-python",
    "title": "Learning Python",
    "videoProgress": "15/45"
  },
  "estimatedCompletion": "2026-01-28T12:30:00Z",
  "courses": [
    { "slug": "course-1", "status": "completed", "videos": "30/30" },
    { "slug": "course-2", "status": "in_progress", "videos": "15/45" },
    { "slug": "course-3", "status": "pending", "videos": null }
  ]
}
```

### POST /api/batch/{id}/verify

**Response:**
```json
{
  "batchId": "abc-123",
  "verification": {
    "totalCourses": 10,
    "complete": 8,
    "incomplete": 2,
    "successRate": "80%"
  },
  "issues": [
    {
      "courseSlug": "course-7",
      "expected": 30,
      "captured": 28,
      "missing": ["video-15", "video-22"]
    }
  ]
}
```

### POST /api/batch/{id}/retry

**Request:**
```json
{
  "mode": "failed_only"
}
```

**Response:**
```json
{
  "batchId": "abc-123-retry",
  "retrying": 2,
  "courses": ["course-7", "course-9"],
  "statusUrl": "/api/batch/abc-123-retry/status"
}
```

---

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Folder Discovery Rate** | >95% | Courses discovered / courses in folder |
| **Batch Completion Rate** | >90% | Batches completing without failure |
| **Transcript Capture Rate** | >95% | Transcripts captured / videos in batch |
| **Average Course Crawl Time** | <10 min | Time per course in batch |
| **Session Stability** | >99% | Batches not interrupted by session expiry |

---

## Open Questions

1. **Session Refresh:** How often should we refresh the session to prevent expiry?
2. **Concurrency:** Should we ever allow parallel course crawling (faster but riskier)?
3. **Notification:** Should we notify user when batch completes (email, webhook)?
4. **Scheduling:** Should we allow scheduled batch crawls (e.g., nightly)?
5. **Folder Sync:** Should we auto-detect new courses added to a folder?

---

## References

- [LinkedIn Learning Help: Save courses](https://www.linkedin.com/help/learning/answer/a703796/)
- [LinkedIn Learning API Documentation](https://learn.microsoft.com/en-us/linkedin/learning/)
- Existing crawler: `C:\mcp\linkedin\crawler\auto-crawler.js`
- Crawl manager: `C:\mcp\linkedin\server\lib\crawl-manager.js`

---

## Approval

| Role | Name | Date | Status |
|------|------|------|--------|
| Product Owner | - | - | PENDING |
| Technical Lead | - | - | PENDING |
| Business Stakeholder | - | - | PENDING |

---

**Next Steps:**
1. Technical validation of folder URL patterns
2. Prototype folder discovery with manual testing
3. Review and approve user stories
4. Add to product backlog (LTE-024 through LTE-027)
