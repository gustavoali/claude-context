# Project Plan: LinkedIn Transcript Extractor v0.8.2 - Technical Debt & Backlog Resolution

**Version:** 1.0
**Date:** 2026-01-15
**Project Manager:** Claude Code (AI PM)
**Technical Lead:** User (1 developer + AI agents)
**Status:** DRAFT - Awaiting Approval

---

## Executive Summary

### Project Overview

**Current State:**
- Version: 0.8.2
- Architecture: 3-layer (Chrome Extension + Native Host + MCP Server)
- Status: MVP funcional pero con deuda técnica significativa

**Problem Statement:**
El proyecto ha acumulado deuda técnica considerable durante el desarrollo iterativo del MVP:
- 60+ scripts ad-hoc sin consolidar
- Dependencia de librería deprecated (NeDB, último commit 2016)
- 0% test coverage
- Configuración hardcodeada

**Objective:**
Estabilizar el proyecto mediante:
1. Pago de deuda técnica crítica (ROI >5x)
2. Implementación de features pendientes de valor
3. Establecimiento de prácticas de calidad sostenibles

**Timeline:** 8 semanas (4 sprints de 2 semanas)

**Budget:** 160 horas efectivas de desarrollo (1 developer @ 20h/semana)

---

## 📊 Technical Debt Analysis (Priorizado por ROI)

### High Priority Technical Debt (ROI >5x)

| ID | Descripción | Interest Rate | Fix Cost | Sprints Remaining | ROI | Decision |
|----|-------------|---------------|----------|-------------------|-----|----------|
| **TD-003** | Sin tests automatizados | 3h/sprint | 12h | 16 | **12.0x** | Fix Sprint 1 |
| **TD-001** | Scripts sin consolidar (60+) | 2h/sprint | 8h | 16 | **8.0x** | Fix Sprint 1 |
| **TD-004** | Configuración hardcodeada | 1h/sprint | 4h | 16 | **8.0x** | Fix Sprint 2 |

### Medium Priority Technical Debt (ROI 3-5x)

| ID | Descripción | Interest Rate | Fix Cost | Sprints Remaining | ROI | Decision |
|----|-------------|---------------|----------|-------------------|-----|----------|
| **TD-005** | Sin logging estructurado | 1h/sprint | 6h | 16 | **5.3x** | Fix Sprint 2 |

### Low Priority Technical Debt (ROI <3x)

| ID | Descripción | Interest Rate | Fix Cost | Sprints Remaining | ROI | Decision |
|----|-------------|---------------|----------|-------------------|-----|----------|
| **TD-002** | NeDB sin mantenimiento | 1h/sprint | 16h | 16 | **2.5x** | Fix when capacity |

**Interest Rate Calculations:**

**TD-003 (No Tests):**
- Debugging manual bugs: 1.5h/sprint
- Regression testing manual: 1h/sprint
- Fear-driven development overhead: 0.5h/sprint
- **Total: 3h/sprint**

**TD-001 (Scripts Duplicados):**
- Finding correct script: 0.5h/sprint
- Understanding script purpose: 0.5h/sprint
- Maintaining duplicates: 1h/sprint
- **Total: 2h/sprint**

**TD-004 (Config Hardcoded):**
- Changing hardcoded values: 0.5h/sprint
- Rebuilding/redeploying: 0.5h/sprint
- **Total: 1h/sprint**

**TD-005 (No Logging):**
- Debugging without logs: 1h/sprint
- **Total: 1h/sprint**

**TD-002 (NeDB Deprecated):**
- Workarounds for bugs: 0.5h/sprint
- Security concerns: 0.5h/sprint
- **Total: 1h/sprint**

---

## 📋 Product Backlog (Features Pendientes)

### High Priority Features (MoSCoW: Must Have)

| ID | Feature | Value | Effort (SP) | ROI | Dependencies |
|----|---------|-------|-------------|-----|--------------|
| **BL-001** | Sincronizar idioma de captions | High | 5 | Business critical | TD-004 resolved |

**Value Justification:**
- **Problem:** Captions capturados no coinciden con idioma que usuario ve
- **Impact:** Experiencia de usuario degradada, contenido incorrecto
- **Business Value:** Feature blocker para users no-English

### Medium Priority Features (MoSCoW: Should Have)

| ID | Feature | Value | Effort (SP) | Priority | Dependencies |
|----|---------|-------|-------------|----------|--------------|
| **BL-002** | Organizar por curso completo | Medium | 8 | Should Have | BL-001 |
| **BL-003** | Ver historial por curso | Medium | 3 | Should Have | BL-002 |
| **BL-004** | Exportar curso completo | Medium | 5 | Should Have | BL-002 |
| **BL-005** | Detectar idioma automático | Low | 3 | Could Have | None |
| **BL-006** | Selector de idiomas | Medium | 5 | Should Have | BL-001, BL-005 |
| **BL-007** | Indicador de idioma en UI | Low | 2 | Could Have | BL-005 |
| **BL-008** | Auto-limpiar al cambiar video | Low | 3 | Could Have | None |
| **BL-009** | Mostrar URL/título en popup | Low | 2 | Could Have | None |

---

## 🎯 Sprint Planning (4 Sprints x 2 Semanas)

### Sprint Capacity Calculation

**Base Calculation:**
```
Team Days = 1 developer × 10 días × 2h/día efectivas = 20h
Efficiency = 0.80 (solo developer, context switching)
Availability = 0.95

Capacity = 20h × 0.80 × 0.95 = 15.2h per sprint

Story Points Conversion: 1.5h/point (conservative for 1 dev)
Capacity = 15.2h / 1.5h = 10.1 ≈ 10 story points

Commitment (80%): 8 story points
Buffer (20%): 2 story points
```

---

## 🗓️ Sprint 1 (Weeks 1-2): Foundation - Critical TD

**Theme:** Establecer calidad base y eliminar overhead

**Sprint Goal:** Implementar testing framework y consolidar scripts para reducir interest rate de 6h/sprint a 2h/sprint.

**Commitment: 8 story points (12h)**

### User Stories

#### US-TD-003: Implement Testing Framework
**Story Points:** 5 (8h)
**Priority:** Critical (ROI 12.0x)
**Type:** Technical Debt

**As a** developer
**I want** automated tests for core functionality
**So that** I can refactor confidently and catch regressions early

**Acceptance Criteria:**

**AC1: Test Framework Setup**
- Given the project needs testing
- When Jest testing framework is configured
- Then test command `npm test` runs successfully
- And coverage report is generated

**AC2: Unit Tests for Core Modules**
- Given VTT parser exists
- When unit tests are written
- Then parser logic has >80% coverage
- And edge cases are tested (empty VTT, malformed, timestamps)

**AC3: Integration Tests for Storage**
- Given NeDB storage layer exists
- When integration tests are written
- Then CRUD operations are tested
- And data persistence is verified

**AC4: Extension Tests**
- Given Chrome extension components exist
- When tests are written using chrome-extension-test library
- Then background.js message handling is tested
- And content.js detection logic is tested

**Technical Requirements:**
- Framework: Jest
- Coverage target: >70% overall, >80% critical paths
- Test files: `__tests__/` directory structure
- CI/CD: GitHub Actions workflow

**Output:**
- `package.json` updated with test scripts
- `jest.config.js` created
- 15+ tests covering core functionality
- Coverage report showing >70%

**Estimated Effort:** 8h (framework setup 2h, writing tests 6h)

---

#### US-TD-001: Consolidate Ad-hoc Scripts
**Story Points:** 3 (5h)
**Priority:** High (ROI 8.0x)
**Type:** Technical Debt

**As a** developer
**I want** scripts organized by purpose
**So that** I can find and maintain them easily

**Acceptance Criteria:**

**AC1: Scripts Categorized**
- Given 60+ scripts exist in flat directory
- When scripts are analyzed
- Then they are categorized into:
  - `migration/` - One-time data migrations
  - `admin/` - Admin operations (view, check, verify)
  - `translation/` - Translation-related scripts
  - `analysis/` - Analysis and reporting
  - `maintenance/` - Cleanup and fixes

**AC2: Duplicate Scripts Eliminated**
- Given multiple scripts with similar purpose exist
- When consolidation is done
- Then duplicate scripts are merged into single parameterized script
- And original count reduced by >30%

**AC3: Scripts Documentation**
- Given scripts are now organized
- When documentation is created
- Then `scripts/README.md` exists with:
  - Purpose of each category
  - Index of scripts with descriptions
  - Common usage examples

**AC4: Scripts Runnable**
- Given scripts are reorganized
- When `npm run script:list` is executed
- Then all available scripts are listed
- And each script has help text

**Technical Requirements:**
- Directory structure: `scripts/{category}/script-name.js`
- Naming convention: kebab-case, descriptive
- Each script: JSDoc header with purpose, params, examples

**Output:**
- Scripts organized in 5 subdirectories
- 60+ scripts → ~40 scripts (30% reduction)
- `scripts/README.md` with full index
- `package.json` scripts section updated

**Estimated Effort:** 5h (analysis 2h, reorganization 2h, docs 1h)

---

**Sprint 1 Buffer: 2 story points**
- Bug fixes
- Unexpected issues
- Code review iterations

**Sprint 1 Total: 10 story points (15.2h)**

---

## 🗓️ Sprint 2 (Weeks 3-4): Configuration & Observability

**Theme:** Hacer el sistema configurable y observable

**Sprint Goal:** Externalizar configuración y agregar logging estructurado para eliminar 2h/sprint de interest rate adicional.

**Commitment: 8 story points (12h)**

### User Stories

#### US-TD-004: Externalize Configuration
**Story Points:** 3 (4h)
**Priority:** High (ROI 8.0x)
**Type:** Technical Debt

**As a** developer
**I want** configuration externalized
**So that** I can change behavior without rebuilding

**Acceptance Criteria:**

**AC1: Configuration File Created**
- Given hardcoded config exists in code
- When config is externalized
- Then `config/default.json` exists with:
  - Supported languages array
  - Storage paths
  - Polling intervals
  - Feature flags

**AC2: Configuration Loaded at Runtime**
- Given config file exists
- When extension starts
- Then config is loaded from `chrome.storage.sync`
- And defaults are applied if not set

**AC3: Configuration UI**
- Given user wants to change settings
- When options page is created
- Then user can configure:
  - Preferred language
  - Storage location
  - Auto-cleanup behavior

**AC4: No Hardcoded Values**
- Given code is refactored
- When grep for hardcoded strings is run
- Then <5 hardcoded values remain (only constants)
- And all user-changeable config is externalized

**Technical Requirements:**
- Config format: JSON
- Config location: `chrome.storage.sync` (synced across devices)
- Options page: `options.html` + `options.js`
- Migration: Old installs get default config

**Output:**
- `config/default.json` created
- `options.html` + `options.js` created
- All hardcoded config removed
- Migration script for existing users

**Estimated Effort:** 4h

---

#### US-TD-005: Implement Structured Logging
**Story Points:** 2 (3h)
**Priority:** Medium (ROI 5.3x)
**Type:** Technical Debt

**As a** developer
**I want** structured logging
**So that** I can debug issues faster

**Acceptance Criteria:**

**AC1: Logger Module Created**
- Given logging is scattered with console.log
- When logger module is created
- Then `logger.js` exports:
  - `logger.info(message, context)`
  - `logger.warn(message, context)`
  - `logger.error(message, context)`
  - `logger.debug(message, context)`

**AC2: Structured Log Format**
- Given logger is used
- When logs are written
- Then format is JSON with:
  - `timestamp` (ISO 8601)
  - `level` (INFO/WARN/ERROR/DEBUG)
  - `component` (background/content/popup)
  - `message` (string)
  - `context` (object with additional data)

**AC3: Log Levels Configurable**
- Given user wants to control verbosity
- When log level is set in config
- Then only logs >= level are written
- And production defaults to WARN

**AC4: All console.log Replaced**
- Given code uses console.log/warn/error
- When refactoring is done
- Then 100% of logs use structured logger
- And no raw console.log remain

**Technical Requirements:**
- Logger: Custom module (lightweight)
- Storage: `chrome.storage.local` (last 1000 logs)
- Viewer: Add "View Logs" button in popup
- Log rotation: Keep last 7 days

**Output:**
- `logger.js` module
- All console.log replaced
- Log viewer in popup
- Configurable log levels

**Estimated Effort:** 3h (logger 1h, refactor 1.5h, viewer 0.5h)

---

#### US-BL-009: Show Video URL/Title in Popup
**Story Points:** 1 (2h)
**Priority:** Low (Quick Win)
**Type:** Feature

**As a** user
**I want** to see which video captions belong to
**So that** I can identify content in my history

**Acceptance Criteria:**

**AC1: Extract Video Metadata**
- Given user is on LinkedIn Learning video
- When content script runs
- Then video URL is extracted
- And video title is extracted from page

**AC2: Display in Popup**
- Given captions exist for video
- When popup opens
- Then video title is shown
- And video URL is shown as clickable link

**AC3: Handle Missing Metadata**
- Given some videos lack metadata
- When popup opens
- Then gracefully show "Unknown Video"
- And still show captions

**Technical Requirements:**
- Extract from: `document.title` or JSON-LD schema
- Store: Associate with caption entry
- UI: Display above transcript in popup

**Output:**
- Metadata extraction in content.js
- UI update in popup.html/popup.js
- Graceful fallback for missing data

**Estimated Effort:** 2h

---

#### US-BL-008: Auto-clear Captions on Video Change
**Story Points:** 2 (3h)
**Priority:** Low (Quick Win)
**Type:** Feature

**As a** user
**I want** old captions cleared when I change videos
**So that** I don't see stale content

**Acceptance Criteria:**

**AC1: Detect Video Change**
- Given user navigates to different video
- When URL changes (SPA navigation)
- Then content script detects change
- And triggers cleanup

**AC2: Clear Old Captions**
- Given video changed
- When cleanup triggers
- Then old captions are removed from memory
- And badge is reset to 0

**AC3: Preserve History**
- Given captions should be saved
- When cleanup happens
- Then old captions are moved to history
- And accessible via "View Courses" button

**AC4: Manual Clear Option**
- Given user wants to manually clear
- When "Clear" button is clicked in popup
- Then current captions are cleared
- And confirmation is shown

**Technical Requirements:**
- Detection: URL polling (existing mechanism)
- Storage: Move to `history` object before clearing
- UI: "Clear" button in popup

**Output:**
- Auto-clear on URL change
- Manual clear button
- Captions preserved in history

**Estimated Effort:** 3h

---

**Sprint 2 Buffer: 2 story points**

**Sprint 2 Total: 10 story points (15.2h)**

**Cumulative Interest Rate Reduction:**
- Start: 8h/sprint
- After Sprint 1: 2h/sprint (-6h)
- After Sprint 2: 0h/sprint (-2h)

---

## 🗓️ Sprint 3 (Weeks 5-6): Critical Feature - Language Sync

**Theme:** Implementar feature crítica de sincronización de idioma

**Sprint Goal:** Permitir a usuarios capturar captions en su idioma preferido, resolviendo el blocker #1 de UX.

**Commitment: 8 story points (12h)**

### User Stories

#### US-BL-001: Sync Caption Language with User Preference
**Story Points:** 5 (8h)
**Priority:** Critical (Business Blocker)
**Type:** Feature

**As a** user watching LinkedIn videos in Spanish
**I want** captions captured in Spanish
**So that** the content I save matches what I'm watching

**Acceptance Criteria:**

**AC1: Detect Available Language Tracks**
- Given video has multiple caption tracks
- When video loads
- Then all available languages are detected
- And stored in metadata (e.g., `["en", "es", "pt", "fr"]`)

**AC2: Respect User Language Preference**
- Given user configured preferred language in options
- When caption request is intercepted
- Then extension filters for preferred language track
- And captures only that language

**AC3: Fallback to Primary Language**
- Given preferred language is not available
- When caption detection runs
- Then fallback to primary language (English)
- And log warning about fallback

**AC4: Language Indicator in UI**
- Given caption is captured
- When popup opens
- Then language code is shown (e.g., "ES 🇪🇸")
- And user can verify correct language captured

**AC5: Multiple Language Detection**
- Given video has 5+ language tracks
- When user wants to see available languages
- Then popup shows list of detected languages
- And user can switch preferred language

**Technical Requirements:**
- Detection: Parse VTT URLs for language codes (`/es/`, `/en/`, etc.)
- Storage: Add `language` field to caption object
- UI: Language dropdown in options page
- Filtering: Match URL pattern against preferred language

**Dependencies:**
- US-TD-004 (Configuration) must be complete

**Output:**
- Language detection in background.js
- Language filter logic
- Options page with language selector
- UI indicator in popup

**Estimated Effort:** 8h
- Analysis of VTT URL patterns: 2h
- Detection logic: 2h
- Filtering logic: 2h
- UI updates: 1h
- Testing with multiple languages: 1h

---

#### US-BL-005: Auto-detect Caption Language
**Story Points:** 2 (3h)
**Priority:** Medium (Enhances BL-001)
**Type:** Feature

**As a** user
**I want** language auto-detected from captured captions
**So that** I don't have to manually configure

**Acceptance Criteria:**

**AC1: Parse Language from VTT URL**
- Given VTT URL contains language code
- When caption is captured
- Then language is parsed from URL path
- And stored in caption metadata

**AC2: Fallback to Content Analysis**
- Given URL does not contain language code
- When VTT content is downloaded
- Then analyze first 10 segments for language
- And detect using language detection library

**AC3: Confidence Score**
- Given language is auto-detected
- When stored
- Then confidence score is included (0.0-1.0)
- And low confidence (<0.7) shows warning

**AC4: Override Option**
- Given auto-detection may be wrong
- When user manually selects language
- Then manual selection overrides auto-detection
- And confidence is set to 1.0

**Technical Requirements:**
- URL parsing: Regex for `/lang-code/` patterns
- Content detection: Use `franc-min` library (lightweight)
- Storage: Add `languageConfidence` field

**Output:**
- Language parsing from URL
- Optional: Language detection from content
- Confidence score calculation
- Manual override in UI

**Estimated Effort:** 3h

---

#### US-BL-007: Show Language Indicator in Popup
**Story Points:** 1 (2h)
**Priority:** Low (Visual Enhancement)
**Type:** Feature

**As a** user
**I want** clear visual indicator of caption language
**So that** I can verify at a glance

**Acceptance Criteria:**

**AC1: Flag Emoji for Language**
- Given caption has language code
- When popup displays caption
- Then flag emoji is shown (🇪🇸 for Spanish, 🇺🇸 for English)
- And language code is shown (ES, EN)

**AC2: Color Coding**
- Given language matches user preference
- When displayed
- Then indicator is green
- And if mismatch, indicator is orange with warning

**AC3: Tooltip with Details**
- Given user hovers over language indicator
- When tooltip appears
- Then shows:
  - Full language name
  - Confidence score
  - Source (URL/Auto/Manual)

**Technical Requirements:**
- Emoji mapping: ISO 639-1 → Flag emoji
- CSS: Color coding for match/mismatch
- Tooltip: Simple hover effect

**Output:**
- Language indicator UI component
- Emoji + code display
- Color coding
- Tooltip

**Estimated Effort:** 2h

---

**Sprint 3 Buffer: 2 story points**

**Sprint 3 Total: 10 story points (15.2h)**

---

## 🗓️ Sprint 4 (Weeks 7-8): Course Organization

**Theme:** Organización avanzada por curso completo

**Sprint Goal:** Permitir a usuarios organizar y exportar captions por curso completo.

**Commitment: 8 story points (12h)**

### User Stories

#### US-BL-002: Organize Captions by Course
**Story Points:** 5 (8h)
**Priority:** Medium (High Value)
**Type:** Feature

**As a** user taking LinkedIn Learning courses
**I want** captions organized by course
**So that** I can see all videos of a course together

**Acceptance Criteria:**

**AC1: Extract Course Metadata**
- Given user is on LinkedIn Learning course page
- When content script runs
- Then course metadata is extracted:
  - `courseSlug` (from URL)
  - `courseTitle` (from page)
  - `instructor` (from JSON-LD)
  - `videoCount` (from page)

**AC2: Hierarchical Storage**
- Given course and video metadata exist
- When caption is stored
- Then structure is:
  ```
  courses/
    {courseSlug}/
      metadata: { title, instructor, ... }
      videos/
        {videoSlug}/
          caption: { ... }
  ```

**AC3: Course List UI**
- Given user has captions from multiple courses
- When "View Courses" button is clicked
- Then popup shows:
  - List of courses
  - Video count per course
  - Progress (X/Y videos captured)

**AC4: Navigation**
- Given user clicks on a course
- When course detail view opens
- Then shows:
  - All videos in course
  - Captions per video
  - Ability to navigate between videos

**Technical Requirements:**
- Metadata extraction: Use existing JSON-LD parser
- Storage: Nested object structure in NeDB
- UI: Multi-level navigation (courses → videos → captions)

**Dependencies:**
- None (uses existing metadata extraction)

**Output:**
- Course metadata extraction
- Hierarchical storage model
- Course list UI
- Navigation between courses/videos

**Estimated Effort:** 8h
- Metadata extraction: 2h
- Storage refactoring: 3h
- UI implementation: 3h

---

#### US-BL-003: View Course History
**Story Points:** 2 (3h)
**Priority:** Medium
**Type:** Feature

**As a** user
**I want** to see history of videos I've captured in a course
**So that** I can review my learning progress

**Acceptance Criteria:**

**AC1: Course Progress Tracking**
- Given user captures captions from course videos
- When course is viewed
- Then shows:
  - Total videos in course
  - Videos with captions captured
  - Completion percentage

**AC2: Timestamp of Captures**
- Given captions were captured at different times
- When history is shown
- Then each video shows:
  - Date/time of capture
  - Most recent first

**AC3: Re-capture Indicator**
- Given video was captured multiple times
- When history shows
- Then indicates "Updated X times"
- And shows most recent version

**Technical Requirements:**
- Storage: Add `capturedAt` timestamp
- Storage: Track `updateCount`
- UI: Sort by date descending

**Output:**
- Timestamps on all captures
- Progress tracking
- History view sorted by date

**Estimated Effort:** 3h

---

#### US-BL-004: Export Course Captions
**Story Points:** 3 (5h)
**Priority:** Medium
**Type:** Feature

**As a** user
**I want** to export all captions of a course at once
**So that** I can share or analyze the complete content

**Acceptance Criteria:**

**AC1: Export Single Course**
- Given user is viewing a course
- When "Export Course" button is clicked
- Then all captions are exported to single file

**AC2: Export Format Options**
- Given export is triggered
- When format selector is shown
- Then user can choose:
  - JSON (structured data)
  - Markdown (readable format)
  - Plain Text (timestamps + text)

**AC3: Export Contains Metadata**
- Given export file is generated
- When opened
- Then includes:
  - Course title, instructor
  - All video titles and URLs
  - All captions with timestamps
  - Export date

**AC4: Filename Convention**
- Given export is saved
- When filename is generated
- Then format is: `linkedin-course-{courseSlug}-{date}.{format}`
- And sanitized for filesystem

**Technical Requirements:**
- Export formats: JSON, Markdown, TXT
- Filename sanitization: Remove special chars
- Download: Use `chrome.downloads.download()`

**Output:**
- Export button in course view
- Format selector
- 3 export formats implemented
- Proper filename generation

**Estimated Effort:** 5h
- Export logic: 2h
- Format renderers: 2h
- UI integration: 1h

---

**Sprint 4 Buffer: 2 story points**

**Sprint 4 Total: 10 story points (15.2h)**

---

## 📊 Resource Allocation

### Roles & Responsibilities

| Role | Responsibilities | Skills Required | Allocation % | Agente Recomendado |
|------|------------------|-----------------|--------------|-------------------|
| **Technical Lead** | - Arquitectura de decisiones<br>- Code review<br>- Sprint planning<br>- Technical direction | - Chrome Extension API<br>- JavaScript ES6+<br>- Testing (Jest)<br>- Architecture | 20% (3h/sprint) | Human (tú) |
| **Backend Developer** | - Implementar refactors<br>- Consolidar scripts<br>- Testing implementation<br>- NeDB migrations | - Node.js<br>- NeDB/Database<br>- Async/await patterns<br>- Refactoring | 40% (6h/sprint) | `dotnet-backend-developer`<br>(adaptable a Node.js) |
| **Frontend Developer** | - Chrome extension UI<br>- Popup refactoring<br>- Options page<br>- CSS/HTML | - HTML/CSS/JavaScript<br>- Chrome Extension UI<br>- UX design | 25% (3.75h/sprint) | `frontend-developer` |
| **Test Engineer** | - Write tests<br>- Test automation<br>- Coverage analysis<br>- E2E testing | - Jest/Testing frameworks<br>- Test design<br>- Coverage tools | 15% (2.25h/sprint) | `test-engineer` |

**Total Allocation: 100% (15h/sprint)**

### Sprint-by-Sprint Allocation

#### Sprint 1: Foundation

| Role | Tasks | Hours |
|------|-------|-------|
| Test Engineer | US-TD-003: Setup Jest + write tests | 8h |
| Backend Developer | US-TD-001: Consolidate scripts | 5h |
| Technical Lead | Planning + Code review | 2h |
| **Total** | | **15h** |

#### Sprint 2: Configuration

| Role | Tasks | Hours |
|------|-------|-------|
| Backend Developer | US-TD-004: Externalize config | 4h |
| Backend Developer | US-TD-005: Structured logging | 3h |
| Frontend Developer | US-BL-009: Show video URL/title | 2h |
| Frontend Developer | US-BL-008: Auto-clear captions | 3h |
| Technical Lead | Planning + Review | 3h |
| **Total** | | **15h** |

#### Sprint 3: Language Sync

| Role | Tasks | Hours |
|------|-------|-------|
| Backend Developer | US-BL-001: Language sync logic | 4h |
| Frontend Developer | US-BL-001: UI components | 2h |
| Backend Developer | US-BL-005: Auto-detect language | 3h |
| Frontend Developer | US-BL-007: Language indicator | 2h |
| Test Engineer | Testing language features | 2h |
| Technical Lead | Planning + Review | 2h |
| **Total** | | **15h** |

#### Sprint 4: Course Organization

| Role | Tasks | Hours |
|------|-------|-------|
| Backend Developer | US-BL-002: Course storage model | 4h |
| Frontend Developer | US-BL-002: Course UI | 3h |
| Backend Developer | US-BL-003: Course history | 2h |
| Backend Developer | US-BL-004: Export functionality | 3h |
| Test Engineer | Testing course features | 2h |
| Technical Lead | Planning + Review | 2h |
| **Total** | | **16h** |

---

## 📅 Timeline & Milestones

### Project Timeline (8 Weeks)

```
Week 1-2  | Sprint 1: Foundation
          | Milestone M1: Testing + Scripts Consolidated
          |
Week 3-4  | Sprint 2: Configuration
          | Milestone M2: System Configurable + Observable
          |
Week 5-6  | Sprint 3: Language Sync
          | Milestone M3: Critical UX Feature Complete
          |
Week 7-8  | Sprint 4: Course Organization
          | Milestone M4: Advanced Organization Features
```

### Milestones with Success Criteria

#### M1: Foundation (End of Sprint 1)
**Date:** Week 2 (Day 10)

**Success Criteria:**
- [ ] Test coverage >70% overall
- [ ] 15+ tests passing
- [ ] Scripts reduced from 60+ to ~40
- [ ] Scripts organized in 5 categories
- [ ] `scripts/README.md` complete
- [ ] Interest rate reduced by 5h/sprint

**Deliverables:**
- Working test suite
- Organized script structure
- Documentation

**Risk Level:** 🟢 Low (straightforward refactoring)

---

#### M2: Configuration & Observability (End of Sprint 2)
**Date:** Week 4 (Day 20)

**Success Criteria:**
- [ ] Config externalized (0 hardcoded values in code)
- [ ] Options page functional
- [ ] Structured logging implemented
- [ ] Log viewer in popup working
- [ ] Auto-clear on video change working
- [ ] Video URL/title shown in popup
- [ ] Interest rate reduced to 0h/sprint

**Deliverables:**
- `config/default.json`
- `options.html` + `options.js`
- `logger.js` module
- Enhanced popup UI

**Risk Level:** 🟢 Low (standard config patterns)

---

#### M3: Critical UX Feature (End of Sprint 3)
**Date:** Week 6 (Day 30)

**Success Criteria:**
- [ ] Language sync working for top 5 languages (en, es, pt, fr, de)
- [ ] Auto-detection with >90% accuracy
- [ ] Language indicator visible in popup
- [ ] User can configure preferred language
- [ ] Fallback to English works correctly
- [ ] Manual override functional

**Deliverables:**
- Language sync feature
- Auto-detection
- Enhanced popup with language indicators
- Options page with language selector

**Risk Level:** 🟡 Medium (LinkedIn API changes could break detection)

**Mitigation:**
- Extensive testing with multiple videos
- Fallback mechanisms
- User manual override

---

#### M4: Advanced Organization (End of Sprint 4)
**Date:** Week 8 (Day 40)

**Success Criteria:**
- [ ] Courses organized hierarchically
- [ ] Course list UI functional
- [ ] Navigation between courses/videos working
- [ ] Export in 3 formats (JSON, MD, TXT)
- [ ] Course progress tracking accurate
- [ ] History view sorted correctly

**Deliverables:**
- Course organization feature
- Enhanced popup with course navigation
- Export functionality
- Course history view

**Risk Level:** 🟢 Low (mostly UI work)

---

## 🚨 Risk Register

### High Impact Risks

| Risk ID | Risk Description | Probability | Impact | Risk Score | Mitigation Strategy | Owner |
|---------|------------------|-------------|--------|------------|---------------------|-------|
| **R-001** | LinkedIn changes VTT URL structure | Medium (40%) | High | 🔴 12 | - Monitor LinkedIn updates<br>- Implement flexible URL parsing<br>- Fallback to older patterns<br>- Community monitoring | Tech Lead |
| **R-002** | Chrome Extension API changes (Manifest V3) | Low (20%) | High | 🟡 6 | - Follow Chrome beta releases<br>- Test on Chrome Canary<br>- Deprecation warnings monitoring | Tech Lead |
| **R-003** | NeDB migration fails (if attempted) | Medium (30%) | High | 🟡 9 | - NOT attempting in this plan (deferred)<br>- If needed: Full backup strategy<br>- Gradual migration approach | Backend Dev |

### Medium Impact Risks

| Risk ID | Risk Description | Probability | Impact | Risk Score | Mitigation Strategy | Owner |
|---------|------------------|-------------|--------|------------|---------------------|-------|
| **R-004** | Test coverage target not met (Sprint 1) | Medium (30%) | Medium | 🟡 6 | - Prioritize critical paths<br>- Accept >60% if time limited<br>- Defer edge cases to Sprint 2 | Test Engineer |
| **R-005** | Language detection accuracy <90% | Medium (40%) | Medium | 🟡 8 | - Use multiple detection methods<br>- Allow manual override<br>- Log false positives for improvement | Backend Dev |
| **R-006** | Script consolidation breaks existing workflows | Low (20%) | Medium | 🟢 4 | - Extensive testing before deletion<br>- Keep backups of original scripts<br>- Gradual rollout | Backend Dev |

### Low Impact Risks

| Risk ID | Risk Description | Probability | Impact | Risk Score | Mitigation Strategy | Owner |
|---------|------------------|-------------|--------|------------|---------------------|-------|
| **R-007** | UI redesign takes longer than estimated | Medium (30%) | Low | 🟢 3 | - Use existing UI patterns<br>- Minimal redesign approach<br>- Defer polish to later | Frontend Dev |
| **R-008** | Export file size too large for some courses | Low (20%) | Low | 🟢 2 | - Implement chunking for large exports<br>- Add size warning in UI | Backend Dev |

**Risk Scoring:** Probability (1-5) × Impact (1-5) = Score (1-25)
- 🔴 High (10-25): Immediate attention required
- 🟡 Medium (5-9): Monitor closely
- 🟢 Low (1-4): Track but no immediate action

---

## 📋 Dependencies Map

### Sprint 1 → Sprint 2
- **US-TD-003 → US-TD-004**: Tests make config refactoring safer

### Sprint 2 → Sprint 3
- **US-TD-004 → US-BL-001**: Configuration framework required for language preferences

### Sprint 3 → Sprint 4
- **US-BL-001 → US-BL-002**: Language sync should work before course organization (better UX)

### Within Sprint 3
- **US-BL-001 → US-BL-005**: Language sync provides foundation for auto-detection
- **US-BL-005 → US-BL-007**: Auto-detection needed before showing indicator

### Within Sprint 4
- **US-BL-002 → US-BL-003**: Course organization needed before viewing history
- **US-BL-002 → US-BL-004**: Course organization needed before exporting

**Critical Path:**
```
TD-003 (Tests) → TD-004 (Config) → BL-001 (Language Sync) → BL-002 (Course Org) → BL-004 (Export)
```

**Estimated Critical Path Duration:** 26 story points ≈ 39h ≈ 2.6 sprints

**Buffer for 4 Sprints:** 1.4 sprints (healthy buffer)

---

## 💰 Budget & Cost Estimation

### Total Project Budget

**Development Hours:**
- Sprint 1: 15h
- Sprint 2: 15h
- Sprint 3: 15h
- Sprint 4: 15h
- **Total Development:** 60h

**Overhead (Planning, Meetings, Reviews):**
- Sprint Planning: 4 × 1h = 4h
- Sprint Reviews: 4 × 1h = 4h
- Retrospectives: 4 × 0.5h = 2h
- **Total Overhead:** 10h

**Total Project Hours:** 70h

**Contingency Buffer (20%):** 14h

**Grand Total:** 84h over 8 weeks

**Weekly Average:** 10.5h/week (feasible for solo developer with day job)

---

### Cost Breakdown by Category

| Category | Hours | % of Total |
|----------|-------|------------|
| Technical Debt Resolution | 24h | 34% |
| Feature Development | 34h | 49% |
| Testing | 8h | 11% |
| Documentation | 4h | 6% |
| **Total** | **70h** | **100%** |

---

## ✅ Definition of Done (Project-Level)

### Per Sprint DoD

**For each User Story:**
- [ ] Code implemented according to AC
- [ ] Unit tests written (if applicable)
- [ ] Manual testing completed
- [ ] Code reviewed (self-review or agent-review)
- [ ] Documentation updated (README, inline comments)
- [ ] No P0 bugs introduced

**For each Sprint:**
- [ ] All committed stories completed or carried over with justification
- [ ] Sprint goal achieved
- [ ] Test coverage maintained or improved
- [ ] Build successful (0 errors, 0 warnings)
- [ ] Sprint review completed
- [ ] Retrospective documented

---

### Project-Level DoD (End of Sprint 4)

**Technical Debt:**
- [ ] Interest rate reduced from 8h/sprint to 0h/sprint
- [ ] Test coverage >70% overall
- [ ] Scripts consolidated from 60+ to ~40
- [ ] Configuration 100% externalized
- [ ] Logging structured and queryable

**Features:**
- [ ] Language sync working for top 5 languages
- [ ] Course organization functional
- [ ] Export working in 3 formats
- [ ] All high-priority backlog items completed

**Quality:**
- [ ] No P0 or P1 bugs open
- [ ] Documentation up-to-date
- [ ] All tests passing
- [ ] Code review completed

**Deployment:**
- [ ] Chrome Web Store listing updated (if public)
- [ ] Release notes published
- [ ] User migration tested (existing installs)

---

## 📊 Success Metrics & KPIs

### Technical Metrics

| Metric | Baseline | Target | Measurement |
|--------|----------|--------|-------------|
| **Test Coverage** | 0% | >70% | Jest coverage report |
| **Interest Rate** | 8h/sprint | 0h/sprint | Manual tracking |
| **Script Count** | 60+ | ~40 | File count in `/scripts` |
| **Hardcoded Config** | ~20 instances | 0 | Grep for hardcoded strings |
| **P0 Bugs** | Unknown | 0 open | Issue tracker |

### Feature Metrics

| Metric | Baseline | Target | Measurement |
|--------|----------|--------|-------------|
| **Language Sync Accuracy** | N/A | >90% | Manual testing with 20+ videos |
| **Course Organization Adoption** | N/A | >80% of users | Analytics (if implemented) |
| **Export Success Rate** | N/A | 100% | Manual testing |

### Velocity Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Story Points per Sprint** | 8-10 | Sprint burndown |
| **Velocity Stability** | ±15% variation | Rolling 3-sprint average |
| **Sprint Goal Success** | 100% | Goals achieved per sprint |

---

## 🔄 Sprint Ceremonies

### Sprint Planning (Week 1, Day 1 of each sprint)
**Duration:** 1h
**Attendees:** Technical Lead (you) + AI Product Owner role

**Agenda:**
1. Review previous sprint (5 min)
2. Confirm sprint goal (5 min)
3. Review user stories and AC (20 min)
4. Estimate effort and confirm capacity (15 min)
5. Identify dependencies and risks (10 min)
6. Commit to sprint backlog (5 min)

**Output:** Sprint backlog committed

---

### Daily Progress Check (Optional, 15 min/day)
**Format:** Solo review or AI assistant check-in

**Questions:**
1. What was completed yesterday?
2. What is planned for today?
3. Any blockers?

---

### Sprint Review (Week 2, Day 10 of each sprint)
**Duration:** 1h
**Format:** Demo to yourself or stakeholders (if any)

**Agenda:**
1. Demo completed features (30 min)
2. Review sprint metrics (10 min)
3. Gather feedback (10 min)
4. Accept/reject stories (10 min)

**Output:** Accepted stories, feedback for next sprint

---

### Sprint Retrospective (Week 2, Day 10 of each sprint)
**Duration:** 30 min
**Format:** Solo reflection or AI-facilitated

**Questions:**
1. What went well?
2. What didn't go well?
3. What to improve next sprint?

**Output:** Action items for next sprint

---

## 📚 Documentation Plan

### Documentation to Create/Update

| Document | Sprint | Owner | Status |
|----------|--------|-------|--------|
| `README.md` | 1-4 | Tech Lead | Update ongoing |
| `scripts/README.md` | 1 | Backend Dev | New |
| `TESTING.md` | 1 | Test Engineer | New |
| `CONFIGURATION.md` | 2 | Backend Dev | New |
| `LANGUAGE_SYNC.md` | 3 | Backend Dev | New |
| `COURSE_ORGANIZATION.md` | 4 | Backend Dev | New |
| `CHANGELOG.md` | 1-4 | Tech Lead | Update per sprint |
| `ARCHITECTURE.md` | 4 | Tech Lead | Update at end |

### Documentation Standards

**All documentation must:**
- Be written in Markdown
- Include table of contents for >500 words
- Use code examples where applicable
- Be updated in same PR as code changes
- Include "Last Updated" date

---

## 🎯 Post-Project Recommendations

### Deferred to Future Releases

**Low ROI Technical Debt:**
- **TD-002: NeDB Migration** (ROI 2.5x)
  - **Recommendation:** Migrate to SQLite or IndexedDB in v0.9.0
  - **Reason:** NeDB still functional, migration is 16h effort
  - **Timeline:** Q2 2026

**Could Have Features:**
- BL-006: Multi-track language selector (complex UI)
- Advanced analytics dashboard
- Collaboration features (share captions with team)

---

### Continuous Improvement

**Establish Practices:**
1. **Weekly TD Review** (15 min)
   - Review new TD items
   - Update ROI calculations
   - Plan TD payment

2. **Monthly Dependency Audit** (30 min)
   - Check for outdated packages
   - Security vulnerabilities scan
   - Update dependencies

3. **Quarterly Architecture Review** (2h)
   - Assess if current architecture scales
   - Plan major refactors
   - Update ARCHITECTURE.md

---

## 📞 Stakeholder Communication Plan

### Weekly Status Updates

**Format:** Brief written summary

**Content:**
- Sprint progress (% complete)
- Completed stories
- Blockers (if any)
- Next week's plan

**Audience:** Self (for tracking) or manager (if applicable)

---

### Milestone Reviews

**Format:** Demo + written report

**Timing:** End of each milestone (Sprints 1, 2, 3, 4)

**Content:**
- Milestone success criteria status
- Key achievements
- Metrics dashboard
- Next milestone preview

---

## ✅ Pre-Flight Checklist (Before Starting Sprint 1)

- [ ] This project plan reviewed and approved
- [ ] Development environment set up
- [ ] Git repository clean (no uncommitted changes)
- [ ] Backup of current version created
- [ ] Test framework research completed (Jest chosen)
- [ ] Calendar blocked for sprint work (20h over 2 weeks)
- [ ] AI agents identified and access confirmed
- [ ] Scripts analyzed and categorized (prep for Sprint 1)
- [ ] Risk mitigation strategies reviewed

---

## 📋 Appendix A: Story Point Reference

### Story Point Estimation Guide

**1 Point (1-2h):**
- Small UI change
- Simple config update
- Documentation update

**2 Points (2-3h):**
- New UI component
- Simple feature
- Bug fix with tests

**3 Points (4-5h):**
- Medium feature
- Refactoring module
- Integration with existing system

**5 Points (6-8h):**
- Complex feature
- Significant refactoring
- New subsystem

**8 Points (12-14h):**
- Large feature
- Architecture change
- Complex integration

**13 Points (20+h):**
- Epic-level work
- Should be split into smaller stories

---

## 📋 Appendix B: Technical Stack

### Current Stack

**Chrome Extension:**
- Manifest V3
- Vanilla JavaScript (ES6+)
- HTML5 + CSS3
- Chrome APIs: storage, webRequest, tabs, nativeMessaging

**Backend (Native Host + MCP):**
- Node.js 18+
- NeDB (embedded database)
- Custom VTT parser

**Testing (Planned):**
- Jest
- Chrome Extension Test Utilities

**Build/Dev Tools:**
- npm
- ESLint (recommended)
- Prettier (recommended)

---

## 📋 Appendix C: Glossary

| Term | Definition |
|------|------------|
| **VTT** | WebVTT (Web Video Text Tracks) - Caption file format |
| **MCP Server** | Model Context Protocol server for Claude Desktop |
| **Native Host** | Native messaging host for Chrome Extension |
| **SPA** | Single Page Application (LinkedIn uses SPA navigation) |
| **ROI** | Return on Investment (for technical debt) |
| **Interest Rate** | Hours wasted per sprint due to technical debt |
| **Story Points** | Relative measure of effort (Fibonacci scale) |
| **DoD** | Definition of Done |
| **AC** | Acceptance Criteria |

---

## 🎯 Final Recommendations

### Immediate Next Steps (This Week)

1. **Review and approve this plan** (30 min)
2. **Set up testing framework** (Jest) (1h)
3. **Create Sprint 1 branch** from develop (5 min)
4. **Schedule Sprint 1 Planning** session (15 min)
5. **Analyze scripts for categorization** (prep for US-TD-001) (2h)

### Keys to Success

1. **Stick to the plan** - Resist scope creep during sprints
2. **Embrace the buffer** - Use it for quality, not more features
3. **Delegate to agents** - Don't try to code everything yourself
4. **Test continuously** - Don't defer testing to end of sprint
5. **Celebrate milestones** - Acknowledge progress at each milestone

### Expected Outcomes (End of Week 8)

- **Technical Health:**
  - 0h/sprint wasted on technical debt (from 8h)
  - >70% test coverage (from 0%)
  - Maintainable, organized codebase

- **Feature Completeness:**
  - Critical language sync feature complete
  - Advanced course organization working
  - Professional-grade export functionality

- **Process Maturity:**
  - Established testing practices
  - Documented architecture
  - Sustainable development velocity

---

**Project Plan Status:** READY FOR APPROVAL

**Prepared by:** Claude Code AI Project Manager
**Date:** 2026-01-15
**Version:** 1.0

**Approval Required From:**
- [ ] Technical Lead (User)
- [ ] Product Owner (User as PO)

**Once approved, create:**
- `SPRINT_1_BACKLOG.md` with detailed tasks
- GitHub Project board or similar tracking tool
- Calendar invites for sprint ceremonies

---

**END OF PROJECT PLAN**
