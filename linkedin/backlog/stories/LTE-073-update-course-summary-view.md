# LTE-073: Update course_summary View with Completion

**As a** developer
**I want** the `course_summary` view to include completion data
**So that** queries using this view get accurate, up-to-date course statistics

## Acceptance Criteria

**AC1: View updated with completion fields**
- Given the `course_summary` view exists in the database
- When the migration runs
- Then the view includes `is_complete`, `completion_percentage`, and `discovered_at` fields
- Or the view is replaced by `course_completion_stats` if that view already has these fields

**AC2: Existing queries unaffected**
- Given code that queries `course_summary`
- When the view is updated
- Then all previously available columns remain available
- And no query breaks due to missing columns

**AC3: Data accuracy**
- Given courses with known completion status
- When querying the updated view
- Then `completion_percentage` matches actual transcript/video ratio
- And `is_complete` is true only when all videos have transcripts

## Technical Notes

- Check if `course_completion_stats` view already exists and has the needed fields - if so, consider aliasing or replacing `course_summary` with it
- Files: `modules/storage/services/storage-service.js` (view DDL), migration script
- SQLite views are cheap to recreate: `DROP VIEW IF EXISTS` + `CREATE VIEW`
- Minimal change - mostly DDL update

## Dependencies

- None (independent, but logically follows the epic)

## Definition of Done

- [ ] View updated or replaced
- [ ] Existing queries verified working
- [ ] Completion data accurate
- [ ] `npm test` passes

## Story Points: 1
## Priority: Low
## Sprint: Backlog
## Epic: Legacy Data Migration
