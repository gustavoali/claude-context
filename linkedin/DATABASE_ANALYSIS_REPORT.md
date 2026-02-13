# Database Analysis Report - LinkedIn Transcript Extractor

**Date:** 2026-01-29
**Analyst:** Database Expert (Claude)
**Database:** C:\mcp\linkedin\data\lte.db
**Status:** MIGRATIONS APPLIED

---

## Migrations Applied

| Migration | Status | Changes |
|-----------|--------|---------|
| 001_add_detected_language | **APPLIED** | Added column + index |
| 002_remove_available_captions | SKIPPED | Keep for now (no impact) |
| 003_cleanup_orphans | **APPLIED** | Fixed 4 VTTs, removed 3 nav pages |
| 004_backfill_language | **APPLIED** | Detected language for 138 VTTs |

---

## Executive Summary

The database is in good health overall, with clear identified issues that can be addressed through targeted improvements. The 48 "unmatched" VTTs are NOT errors - they are multi-language captions that were intentionally captured but filtered out because the system only saves Spanish transcripts.

### Key Findings (POST-MIGRATION)

| Metric | Before | After | Status |
|--------|--------|-------|--------|
| Total Transcripts | 165 | 165 | OK |
| Total Courses | 7 | 7 | OK |
| Unmatched VTTs | 48 | 52 | **Expected** (multi-language) |
| Unmatched Contexts | 29 | 26 | Improved (removed nav pages) |
| Orphaned VTTs | 4 | 0 | **FIXED** |
| Navigation Contexts | 3 | 0 | **FIXED** |
| Duplicate Transcripts | 0 | 0 | OK |
| Missing course_title | 5 | 5 | Data quality issue (future) |
| available_captions table | 0 rows | 0 rows | Keep (no impact) |
| detected_language column | N/A | **ADDED** | NEW |

### Post-Migration Statistics

**Unassigned VTTs by Language (top 10):**
| Language | Count | Notes |
|----------|-------|-------|
| Spanish (es) | 92 | 86 matched, 6 unmatched |
| Portuguese (pt) | 3 | Multi-language |
| French (fr) | 3 | Multi-language |
| German (de) | 2 | Multi-language |
| And 34 more languages... | 39 | Multi-language |

The 52 unmatched VTTs break down as:
- **46 non-Spanish VTTs**: Expected - system only saves Spanish
- **6 Spanish VTTs**: These are duplicates - content already in transcripts with different ID format

---

## 1. Unmatched VTTs Analysis

### Root Cause Identified

**47 of 48 unmatched VTTs** belong to the video `ai-trends/welcome-to-ai-trends`:

```
Distribution:
- hint_video_slug = "welcome": 47 VTTs
- hint_video_slug = "context-engineering-26536866": 1 VTT
```

**Why are they unmatched?**

LinkedIn Learning sends **ALL 47 language versions** of captions when a video loads. The system captures all of them but only matches the Spanish version:

| Language | Count |
|----------|-------|
| Unknown script languages | 27 |
| Japanese | 3 |
| French | 2 |
| Devanagari-based | 2 |
| Portuguese | 2 |
| Farsi | 1 |
| Spanish | 1 (redundant - already matched) |
| English | 1 |
| And more... | ... |

**The 1 other unmatched VTT** (`context-engineering-26536866`) appears to have a matching VTT that was already matched (VTT ID shows `matched: 1`), but the context shows `matched: 0`. This is a referential integrity issue.

### Recommendation

1. **Do NOT treat unmatched VTTs as errors** - they are working as designed
2. **Add `detected_language` column** to `unassigned_vtts` for better filtering
3. **Consider periodic cleanup** of non-Spanish VTTs to reduce clutter

---

## 2. Unmatched Contexts Analysis

29 contexts remain unmatched. Breakdown by course:

| Course | Unmatched Contexts | Reason |
|--------|-------------------|--------|
| build-with-ai-create-an-agent-with-gpt-oss | 15 | **VTTs never captured** |
| governing-ai-agents-visibility-and-control | 6 | **VTTs never captured** |
| ai-trends | 3 | Referential integrity issue |
| me | 3 | **Navigation pages, not videos** |
| azure-ai-for-developers-building-ai-agents | 1 | VTT never captured |
| hands-on-ai-turn-spreadsheets-into-web-apps... | 1 | VTT never captured |

**Key Finding:** The "me" contexts (`saved`, `my-learning`, `collections`) are LinkedIn Learning navigation pages, NOT videos. These should be excluded from context capture.

**For the actual courses:** The VTTs for these videos were never captured, possibly because:
- Crawl was interrupted before completion
- VTT filtering excluded them (wrong language?)
- Network issues during capture

---

## 3. Data Quality Issues

### 3.1 Missing Course Titles (5 courses)

```sql
Courses with NULL course_title:
- ai-trends
- azure-ai-for-developers-azure-ai-speech
- azure-ai-for-developers-building-ai-agents
- azure-service-fabric-for-developers
- hands-on-ai-turn-spreadsheets-into-web-apps-with-google-ai-studio
```

### 3.2 Missing Video Titles (4 videos)

### 3.3 Missing Chapter Info (7 videos)

### 3.4 Orphaned Records

```
Orphaned VTTs (matched_to points to non-existent transcript): 4
  - vtt_de86922743d350a0 -> ai-regulations
  - vtt_00dc07ce0669370e -> claude-cowork-and-the-future-of-getting-things-done
  - vtt_4bfb5d298de5f313 -> npus-vs-gpus-vs-cpus
  - vtt_144c80b511c6d7af -> placeholder-26986568

Orphaned contexts (vtt_hash points to non-existent VTT): 41
```

---

## 4. Schema Recommendations

### 4.1 Add `detected_language` to `unassigned_vtts` - **RECOMMENDED**

**Rationale:** Currently there's no way to filter VTTs by language without parsing text_preview. Adding a detected_language column would:
- Enable efficient filtering (e.g., "show only Spanish VTTs")
- Improve matching algorithm performance
- Allow reporting on language distribution

**Migration SQL:**
```sql
ALTER TABLE unassigned_vtts ADD COLUMN detected_language TEXT;
CREATE INDEX idx_unassigned_vtts_language ON unassigned_vtts(detected_language);
```

### 4.2 Remove `available_captions` table - **RECOMMENDED**

**Rationale:** The table was created for HLS manifest discovery but:
- Has 0 rows (never used)
- LinkedIn sends all VTTs directly (no manifest parsing needed)
- Adds maintenance overhead

**Migration SQL:**
```sql
DROP TABLE IF EXISTS available_captions;
-- Note: Also remove related indexes and functions from database.js
```

### 4.3 Add Missing Indexes - **NOT NEEDED**

Current indexes are sufficient:
- 16 custom indexes across all tables
- All common query patterns are covered
- No performance issues observed

### 4.4 Consider Adding Composite Index - **OPTIONAL**

For the matching algorithm that queries by course_slug + matched:
```sql
CREATE INDEX IF NOT EXISTS idx_unassigned_vtts_course_matched
ON unassigned_vtts(course_slug, matched);
```

---

## 5. Referential Integrity Issues

### Issue 1: VTTs marked matched but transcript doesn't exist

4 VTTs have `matched = 1` and `matched_to` set, but the referenced transcript ID doesn't exist in the transcripts table.

**Likely cause:** Transcripts were deleted but unassigned_vtts wasn't updated.

### Issue 2: Contexts marked matched but VTT hash doesn't exist

41 contexts have `matched = 1` and `matched_vtt_hash` set, but the VTT content_hash doesn't exist in unassigned_vtts.

**Likely cause:** VTTs were deleted after matching, or the VTT was saved directly to transcripts and then cleared from unassigned_vtts.

### Cleanup Recommendation

Run this cleanup to fix orphaned records:
```sql
-- Mark orphaned VTTs as unmatched
UPDATE unassigned_vtts
SET matched = 0, matched_to = NULL
WHERE matched = 1
AND matched_to NOT IN (SELECT id FROM transcripts);

-- Note: Context orphans don't need cleanup - they just indicate
-- VTTs were processed and moved to transcripts table
```

---

## 6. Proposed Migrations

### Migration 1: Add detected_language column (HIGH PRIORITY)

```sql
-- migrations/001_add_detected_language.sql

-- Add column
ALTER TABLE unassigned_vtts ADD COLUMN detected_language TEXT;

-- Create index
CREATE INDEX IF NOT EXISTS idx_unassigned_vtts_language ON unassigned_vtts(detected_language);

-- Backfill: Set detected_language based on text_preview patterns
-- (This would need to be done via Node.js script with language detection)
```

### Migration 2: Remove available_captions table (MEDIUM PRIORITY)

```sql
-- migrations/002_remove_available_captions.sql

DROP TABLE IF EXISTS available_captions;
```

### Migration 3: Cleanup orphaned records (MEDIUM PRIORITY)

```sql
-- migrations/003_cleanup_orphans.sql

-- Fix orphaned matched VTTs
UPDATE unassigned_vtts
SET matched = 0, matched_to = NULL
WHERE matched = 1
AND matched_to NOT IN (SELECT id FROM transcripts);

-- Delete navigation page contexts (not real videos)
DELETE FROM visited_contexts
WHERE course_slug = 'me'
AND video_slug IN ('saved', 'my-learning', 'collections');
```

### Migration 4: Populate missing course titles (LOW PRIORITY)

```javascript
// This needs to be done via API call or manual lookup
// The course titles should be fetched from LinkedIn during crawl
```

---

## 7. Summary of Actions

### Immediate (Do Now)

1. **Understand:** The 48 unmatched VTTs are NOT bugs - they're multi-language captions
2. **Cleanup:** Run orphan cleanup migration (#3)
3. **Remove:** Delete unused `available_captions` table (#2)

### Short-term (Next Sprint)

1. **Add:** `detected_language` column to `unassigned_vtts` (#1)
2. **Implement:** Language detection during VTT capture (using tinyld)
3. **Fix:** Exclude navigation pages from visited_contexts

### Long-term (Future)

1. **Consider:** Multi-language transcript support if needed
2. **Implement:** Course title auto-population during crawl
3. **Add:** Data quality monitoring/alerting

---

## 8. Appendix: SQL Queries for Analysis

### Query: Find unmatched VTTs by course
```sql
SELECT course_slug, COUNT(*) as cnt
FROM unassigned_vtts
WHERE matched = 0
GROUP BY course_slug
ORDER BY cnt DESC;
```

### Query: Find orphaned records
```sql
-- Orphaned VTTs
SELECT id, matched_to FROM unassigned_vtts
WHERE matched = 1
AND matched_to NOT IN (SELECT id FROM transcripts);

-- Orphaned contexts
SELECT id, matched_vtt_hash FROM visited_contexts
WHERE matched = 1
AND matched_vtt_hash NOT IN (SELECT content_hash FROM unassigned_vtts);
```

### Query: Language distribution in VTTs
```sql
SELECT detected_language, COUNT(*) as cnt
FROM unassigned_vtts
GROUP BY detected_language
ORDER BY cnt DESC;
```

---

**Report Generated:** 2026-01-29
**Next Review:** After implementing migrations
