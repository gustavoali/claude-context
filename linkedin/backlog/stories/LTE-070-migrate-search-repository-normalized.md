# LTE-070: Migrate SearchRepository to Normalized Tables

**As a** developer
**I want** SearchRepository to query normalized tables instead of the legacy `transcripts` table
**So that** the legacy table can be dropped without breaking search functionality

## Acceptance Criteria

**AC1: All queries migrated**
- Given SearchRepository has 6 methods querying the legacy `transcripts` table
- When migration is complete
- Then all 6 methods query `transcripts_denormalized` view or `transcripts_normalized` table instead
- And no reference to the `transcripts` table remains in `search-repo.js`

**AC2: FTS5 index rebuilt**
- Given the FTS5 index currently depends on the legacy `transcripts` table
- When the FTS5 migration script runs
- Then a new FTS5 index is created over `transcripts_normalized` (or contentless pointing to it)
- And the old FTS5 index referencing `transcripts` is dropped

**AC3: Search results equivalent**
- Given a set of known search queries with known results from the current implementation
- When the same queries run against the migrated implementation
- Then results match (same transcripts returned, same relevance order)
- And snippet() function returns valid highlighted excerpts

**AC4: Performance acceptable**
- Given the migrated FTS5 index
- When a search query runs on the full dataset
- Then response time is within 2x of the legacy implementation
- And if contentless FTS5 is used, snippet() degradation is documented and acceptable

**AC5: Error handling preserved**
- Given an empty database or no matching results
- When search is performed
- Then appropriate empty results returned (no crashes, no undefined)

## Technical Notes

- Primary file: `modules/storage/repositories/search-repo.js` (6 queries to migrate)
- New migration script: `scripts/migrations/` for FTS5 rebuild
- FTS5 contentless (`content=''`) avoids data duplication but limits snippet() - evaluate trade-off
- Alternative: FTS5 with `content=transcripts_normalized` and triggers for sync
- The `transcripts_denormalized` view already JOINs all normalized tables - prefer it for queries needing course/chapter/video metadata
- For pure transcript text search, `transcripts_normalized` with FTS5 is sufficient
- Risk: FTS5 contentless may degrade snippet() performance - test explicitly

## Dependencies

- None (can start in parallel with LTE-069)

## Definition of Done

- [ ] All 6 SearchRepository methods migrated
- [ ] FTS5 index rebuilt without legacy table dependency
- [ ] Search results validated against known dataset
- [ ] Performance benchmarked and documented
- [ ] `npm test` passes
- [ ] No reference to `transcripts` table in search-repo.js

## Story Points: 8
## Priority: Critical
## Sprint: Next
## Epic: Legacy Data Migration
