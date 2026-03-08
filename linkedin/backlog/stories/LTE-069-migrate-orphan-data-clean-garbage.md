# LTE-069: Migrate Orphan Data and Clean Garbage Courses

**As a** developer
**I want** orphan transcripts migrated from the legacy table and garbage courses removed
**So that** all useful data lives in normalized tables and the database is clean

## Acceptance Criteria

**AC1: Garbage courses removed**
- Given the database contains 6 garbage courses (answer, chatbot, me, test-course-slug, undefined, settings)
- When the cleanup migration runs
- Then these 6 courses and all their associated chapters, videos, and transcripts are deleted from normalized tables
- And a log entry confirms each deletion with row counts
- Note: This cleanup is already being executed at the time of story creation; include as reference and validation

**AC2: Orphan transcripts identified**
- Given the legacy `transcripts` table contains rows
- When an analysis query compares legacy rows against `transcripts_normalized`
- Then a report shows how many transcripts exist only in legacy (orphans), only in normalized, and in both

**AC3: Orphan transcripts migrated**
- Given orphan transcripts are identified in the legacy table
- When the migration script runs
- Then orphans with valid course/video references are inserted into `transcripts_normalized` via matching to `videos_normalized`
- And orphans without valid references are logged to a report file for manual review

**AC4: Data integrity validated**
- Given migration and cleanup are complete
- When a validation query runs
- Then `transcripts_normalized` count >= previous count (no data loss)
- And 0 garbage courses exist in `courses_normalized`
- And a before/after summary is printed

## Technical Notes

- Files: `scripts/migrations/` (new migration script), `modules/storage/` (queries)
- Garbage courses may have cascading data in chapters/videos/transcripts normalized tables - use DELETE CASCADE or explicit multi-table cleanup
- The 6 garbage slugs should be defined as a constant array for reuse
- Consider running as a reversible migration (backup before delete)
- SQLite does not support DELETE CASCADE by default - verify `PRAGMA foreign_keys = ON`

## Dependencies

- None (can start immediately)

## Definition of Done

- [ ] Garbage courses removed from all normalized tables
- [ ] Orphan transcripts migrated or documented
- [ ] Validation query confirms data integrity
- [ ] Migration script is idempotent (safe to re-run)
- [ ] `npm test` passes

## Story Points: 3
## Priority: Critical
## Sprint: Next
## Epic: Legacy Data Migration
