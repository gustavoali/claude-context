# LTE-072: Drop Legacy Transcripts Table

**As a** developer
**I want** the legacy `transcripts` table removed from the database
**So that** there is a single source of truth and no maintenance burden for deprecated schema

## Acceptance Criteria

**AC1: Prerequisites validated**
- Given LTE-069 (orphan migration) and LTE-070 (search migration) are complete
- When a pre-drop validation script runs
- Then it confirms: 0 orphan transcripts remaining in legacy table, SearchRepository has no legacy references, FTS5 index does not depend on legacy table

**AC2: Table dropped**
- Given validation passes
- When the drop migration script runs
- Then the `transcripts` table is removed from the SQLite database
- And the old FTS5 index (if still present) is dropped

**AC3: DDL cleaned**
- Given `storage-service.js` contains `_initializeTables()` or equivalent
- When the code is updated
- Then no CREATE TABLE statement for `transcripts` exists
- And no INSERT/SELECT/UPDATE/DELETE referencing `transcripts` exists anywhere in the codebase

**AC4: Scripts updated**
- Given `scripts/` directory contains utility scripts
- When scripts referencing the legacy `transcripts` table are identified
- Then they are updated to use normalized tables, or deprecated with a clear comment, or removed if no longer needed

**AC5: Full test suite passes**
- Given the table is dropped and code is updated
- When `npm test` runs
- Then all tests pass (no references to dropped table)
- And no runtime errors when starting HTTP or MCP server

## Technical Notes

- Files: `modules/storage/services/storage-service.js` (DDL), `scripts/` (utility scripts), migration script in `scripts/migrations/`
- Run `grep -r "transcripts" --include="*.js"` to find all references - distinguish `transcripts_normalized` and `transcripts_denormalized` (keep) from `transcripts` (remove)
- The drop is irreversible - migration script should create a backup of the table data before dropping (e.g., export to JSON or SQL dump)
- Consider a migration version number to prevent re-running

## Dependencies

- **Blocked by:** LTE-069 (Migrate Orphan Data), LTE-070 (Migrate SearchRepository)

## Definition of Done

- [ ] Pre-drop validation passes
- [ ] Legacy `transcripts` table dropped
- [ ] DDL in storage-service.js cleaned
- [ ] All scripts updated or deprecated
- [ ] `npm test` passes
- [ ] No code reference to bare `transcripts` table (only `transcripts_normalized`, `transcripts_denormalized`)
- [ ] Backup of legacy data created before drop

## Story Points: 2
## Priority: High
## Sprint: After LTE-069 + LTE-070
## Epic: Legacy Data Migration
