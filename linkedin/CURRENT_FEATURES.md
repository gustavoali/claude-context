# LinkedIn Transcript Extractor - Current Features Analysis

**Document Version:** 1.0
**Date:** 2026-02-02
**Status:** ANALYSIS COMPLETE

---

## Executive Summary

This document provides a comprehensive analysis of the current LinkedIn Transcript Extractor (LTE) system features, architecture, and capabilities. It also identifies improvement opportunities beyond the proposed 3-phase crawl architecture.

---

## 1. Current System Architecture

### 1.1 Component Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    CHROME EXTENSION                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ background.js│  │  content.js  │  │   popup.js   │     │
│  │ VTT Intercept│  │ DOM Extract  │  │  UI Display  │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
                           │
                    Native Messaging
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    NATIVE HOST (Node.js)                    │
│                    SQLite Database                          │
└─────────────────────────────────────────────────────────────┘
                           │
              ┌────────────┴────────────┐
              ▼                         ▼
┌─────────────────────────┐  ┌─────────────────────────┐
│     HTTP SERVER         │  │      MCP SERVER         │
│     (Express.js)        │  │    (Claude Desktop)     │
│     Port 3456           │  │                         │
└─────────────────────────┘  └─────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────────────┐
│                    CRAWLER (Playwright)                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │auto-crawler  │  │batch-manager │  │folder-parser │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Technology Stack

| Component | Technology | Version |
|-----------|------------|---------|
| Extension | Chrome Manifest V3 | - |
| Backend | Node.js | 18+ |
| Database | SQLite (better-sqlite3) | - |
| HTTP Server | Express.js | 5.x |
| MCP Server | @modelcontextprotocol/sdk | 1.0+ |
| Crawler | Playwright | 1.40+ |
| Testing | Jest | 29.x |

---

## 2. Chrome Extension Features

### 2.1 VTT Interception (background.js)

**Capabilities:**
- Intercepts VTT caption URLs from LinkedIn Learning videos
- Pattern matching for multiple VTT URL formats
- Language detection (URL patterns + content analysis)
- Deduplication via content hashing
- Tab-based context management

**Current Patterns Detected:**
```javascript
- /captions/urn:li:lyndaCaptionFile:*/es-ES.vtt
- /transcript/urn:li:lyndaTranscript:*
- /captions/*_es*.vtt
```

### 2.2 Context Extraction (content.js)

**Capabilities:**
- URL parsing for courseSlug/videoSlug extraction
- JSON-LD metadata extraction
- DOM scraping with 12 selector categories (140+ fallbacks)
- Chapter and video index detection
- SPA navigation handling via URL polling

**Selector Categories:**
- courseTitle, videoTitle, tocSection, tocVideoItem
- tocActiveItem, chapterTitle, tocItemTitle, tocItemDuration
- progressIndicator, jsonLdScript, instructor, courseDescription

### 2.3 Popup Interface (popup.js)

**Capabilities:**
- Display captured VTTs with timestamps
- Copy to clipboard functionality
- Language badge with color coding (47 languages supported)
- Language preference selection with cross-device sync

### 2.4 Language Preference System (v0.14.0)

**Capabilities:**
- 30 supported languages for preference selection
- Automatic UI language detection
- Cross-device sync via chrome.storage.sync
- Background filtering based on preference

---

## 3. Native Host Features

### 3.1 Database Management (host.js)

**Capabilities:**
- Native Messaging Protocol implementation
- SQLite database operations via better-sqlite3
- Language detection (pattern-based with tinyld)
- Transcript versioning and archiving
- Content deduplication by normalized hash

### 3.2 Database Schema

**Main Tables:**
| Table | Purpose | Records |
|-------|---------|---------|
| transcripts | Assigned transcripts | 205 |
| unassigned_vtts | VTTs pending assignment | Variable |
| visited_contexts | Crawler visited videos | Variable |
| available_captions | Available caption languages | Variable |

**Normalized Tables (Migration 007-009):**
| Table | Purpose | Records |
|-------|---------|---------|
| courses_normalized | Course entities | 13 |
| chapters_normalized | Chapter entities | 36 |
| videos_normalized | Video entities | 206 |
| transcripts_normalized | Normalized transcripts | 205 |

**Views:**
- transcripts_denormalized - JOIN of normalized tables
- course_summary - Statistics per course
- chapter_details - Statistics per chapter

---

## 4. HTTP Server Features (Port 3456)

### 4.1 API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/status` | GET | Health check and statistics |
| `/api/courses` | GET | List all courses |
| `/api/courses/:slug` | GET | Course structure with chapters |
| `/api/courses/:slug/videos` | GET | All videos in a course |
| `/api/courses/:slug/:videoSlug` | GET | Single video transcript |
| `/api/search` | GET | Search transcripts |
| `/api/ask` | POST | AI-powered Q&A |
| `/openapi.json` | GET | OpenAPI specification |

### 4.2 Batch Crawl API (v0.13.0)

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/batch-crawl/start` | POST | Start batch crawl |
| `/api/batch-crawl/:batchId/status` | GET | Batch status |
| `/api/batch-crawl/:batchId/pause` | POST | Pause batch |
| `/api/batch-crawl/:batchId/resume` | POST | Resume batch |
| `/api/batch-crawl/:batchId/cancel` | POST | Cancel batch |

### 4.3 Export Features

- ZIP export with manifest
- Course-level export
- Batch export of multiple courses

---

## 5. MCP Server Features (11 Tools)

### 5.1 Discovery Tools

| Tool | Purpose |
|------|---------|
| `list_courses` | List all captured courses |
| `get_course_structure` | Get course chapters and videos |
| `list_learnings` | List saved learning items |

### 5.2 Content Access Tools

| Tool | Purpose |
|------|---------|
| `get_video_transcript` | Get transcript for specific video |
| `get_full_course_content` | Get all transcripts for a course |
| `search_transcripts` | Full-text search across transcripts |

### 5.3 Analysis Tools

| Tool | Purpose |
|------|---------|
| `ask_about_content` | AI-powered Q&A about content |
| `get_topics_overview` | Extract topics from transcripts |
| `compare_videos` | Compare content between videos |
| `find_prerequisites` | Find prerequisite relationships |
| `check_for_updates` | Check for content updates |

---

## 6. Crawler Features

### 6.1 Auto-Crawler (auto-crawler.js)

**Capabilities:**
- Automated course navigation via Playwright
- Persistent session management (LinkedIn login)
- Video playback triggering for VTT capture
- VTT interception via page.route()
- Progress tracking and resumption

**Configuration:**
```javascript
DEFAULT_CONFIG = {
  navigationTimeout: 30000,
  videoPlaybackDelay: 5000,
  maxRetries: 3,
  concurrentVideos: 1  // Sequential only
}
```

### 6.2 Batch Manager (v0.13.0)

**Capabilities:**
- Process multiple courses from LinkedIn collection
- State persistence in JSON files
- Pause/resume functionality
- Progress tracking per course
- Error recovery and retry logic

### 6.3 Folder Parser (v0.13.0)

**Capabilities:**
- Parse LinkedIn collection pages
- Extract course URLs from folder view
- Support for learning paths and collections

---

## 7. Modular Architecture (v0.14.x)

### 7.1 Module Structure

```
modules/
├── shared/           # Common utilities
│   ├── logger.js
│   ├── config.js
│   ├── event-bus.js
│   ├── errors.js
│   ├── validator.js
│   └── schemas/
├── capture/          # VTT capture logic
│   ├── repositories/
│   └── services/
├── matching/         # VTT-to-context matching
│   ├── algorithms/
│   └── services/
├── storage/          # Data persistence
│   ├── repositories/
│   └── services/
├── crawl/            # Crawler orchestration
│   ├── state/
│   ├── services/
│   └── orchestration/
└── api/              # HTTP and MCP servers
    ├── http/
    └── mcp/
```

### 7.2 Key Services

| Service | Responsibility |
|---------|----------------|
| CaptureService | VTT capture and storage |
| MatchingService | VTT-to-context matching |
| StorageService | Database operations facade |
| CrawlService | Single course crawling |
| BatchService | Multi-course batch processing |

---

## 8. Quality Metrics

### 8.1 Test Coverage

| Metric | Value |
|--------|-------|
| Total Tests | 1,791 |
| Test Suites | 39 |
| Coverage | 79.29% |
| Status | All passing |

### 8.2 Technical Debt Status

| ID | Description | Status |
|----|-------------|--------|
| TD-001 | Tests unitarios | RESOLVED (79%) |
| TD-002 | Duplicación parsing | RESOLVED |
| TD-003 | Scripts desorganizados | RESOLVED |
| TD-004 | Estado global complejo | RESOLVED |
| TD-006 | DOM selectors frágiles | RESOLVED |

---

## 9. Improvement Opportunities

### 9.1 Proposed by User (3-Phase Crawl)

See EPIC_CRAWL_PHASES_PROPOSAL.md for details:
- **Phase 1:** Discovery/Search (structure-first crawl)
- **Phase 2:** Parallel Completion (concurrent video processing)
- **Phase 3:** Versioning (change detection and history)

### 9.2 Additional Improvements Identified

#### 9.2.1 Full-Text Search Enhancement

**Current State:** Basic LIKE queries
**Improvement:** SQLite FTS5 implementation

**Benefits:**
- 10-100x faster search
- Relevance ranking
- Snippet highlighting
- Boolean operators

**Effort:** 8 story points

---

#### 9.2.2 Transcript Quality Scoring

**Current State:** No quality metrics
**Improvement:** Quality scoring system

**Metrics to Track:**
- Completeness (% of video duration covered)
- Language confidence score
- Speaker identification accuracy
- Timing precision

**Benefits:**
- Identify low-quality transcripts
- Prioritize re-capture
- Quality reports

**Effort:** 5 story points

---

#### 9.2.3 Multi-Language Transcript Management

**Current State:** Single language per video
**Improvement:** Store all available languages

**Benefits:**
- Access any language transcript
- Translation comparison
- Learning in multiple languages

**Effort:** 8 story points

---

#### 9.2.4 Offline Access / PWA

**Current State:** Requires server running
**Improvement:** Progressive Web App for offline access

**Benefits:**
- Access transcripts without server
- Mobile-friendly interface
- Sync when online

**Effort:** 13 story points

---

#### 9.2.5 Learning Path Optimization

**Current State:** Individual course capture
**Improvement:** Learning path as first-class entity

**Benefits:**
- Capture entire learning paths
- Track progress across paths
- Prerequisite detection

**Effort:** 8 story points

---

#### 9.2.6 Analytics Dashboard

**Current State:** Basic statistics in status API
**Improvement:** Visual dashboard

**Features:**
- Courses by language chart
- Capture timeline
- Storage usage
- Most searched topics

**Effort:** 5 story points

---

#### 9.2.7 Export Formats

**Current State:** ZIP with text files
**Improvement:** Multiple export formats

**Formats:**
- Markdown with timestamps
- EPUB for e-readers
- Anki flashcards
- Obsidian-compatible notes

**Effort:** 8 story points

---

#### 9.2.8 Smart Recommendations

**Current State:** Manual course selection
**Improvement:** AI-powered recommendations

**Features:**
- Based on captured content
- Gap analysis (topics not covered)
- Similar courses detection

**Effort:** 13 story points

---

## 10. Improvement Priority Matrix

| Improvement | Value | Effort | Priority |
|-------------|-------|--------|----------|
| Phase 1: Discovery | High | 18 pts | CRITICAL |
| FTS5 Search | High | 8 pts | HIGH |
| Multi-Language | Medium | 8 pts | MEDIUM |
| Quality Scoring | Medium | 5 pts | MEDIUM |
| Export Formats | Medium | 8 pts | MEDIUM |
| Phase 2: Parallel | Medium | 26 pts | CONDITIONAL |
| Analytics Dashboard | Low | 5 pts | LOW |
| Offline/PWA | Low | 13 pts | LOW |
| Phase 3: Versioning | Low | 24 pts | DEFERRED |
| Smart Recommendations | Low | 13 pts | FUTURE |

---

## 11. Recommended Roadmap

### Quarter 1 (Immediate)

1. **Phase 1: Discovery Crawl** (18 pts)
   - Structure-first crawl
   - isComplete tracking
   - Foundation for future phases

2. **FTS5 Search Enhancement** (8 pts)
   - Better search experience
   - Performance improvement

### Quarter 2 (After Rate Limit Research)

3. **Phase 2: Parallel Completion** (26 pts)
   - Conditional on rate limit research
   - 3-5x speed improvement

4. **Multi-Language Support** (8 pts)
   - Store all available languages
   - Language switching

### Quarter 3 (Future)

5. **Quality Scoring** (5 pts)
6. **Export Formats** (8 pts)
7. **Analytics Dashboard** (5 pts)

### Backlog (No Timeline)

- Phase 3: Versioning
- Offline/PWA
- Smart Recommendations

---

## 12. Conclusion

The LinkedIn Transcript Extractor has evolved into a comprehensive system with:

**Strengths:**
- Robust VTT capture with 140+ CSS fallbacks
- Modular architecture with 6 bounded contexts
- High test coverage (79%)
- Batch processing capability
- Multi-language support (47 languages)

**Growth Opportunities:**
- Structure-first crawl (Phase 1) - CRITICAL
- Parallel processing (Phase 2) - CONDITIONAL
- Enhanced search with FTS5 - HIGH
- Multi-language storage - MEDIUM

The proposed 3-phase crawl architecture addresses the most significant current limitations and provides a foundation for future enhancements.

---

**Document Status:** Complete
**Next Steps:** Review with stakeholders, prioritize backlog, begin Phase 1 implementation
