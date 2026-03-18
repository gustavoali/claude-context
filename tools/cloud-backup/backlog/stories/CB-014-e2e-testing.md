### CB-014: Testing E2E del ciclo backup-restore
**Points:** 5 | **Priority:** High

**As a** ecosystem administrator
**I want** verified end-to-end testing of the backup and restore cycle
**So that** I can trust the backups will work when I need them

#### Acceptance Criteria
**AC1:** Given a full Tier 1 backup completes, When I verify staging files, Then every expected source from the manifest has a corresponding file with size >0
**AC2:** Given files are uploaded to Google Drive, When I run `rclone check`, Then 0 differences between local staging and remote
**AC3:** Given a SQLite backup on Google Drive, When I restore it to a test location, Then the restored DB passes `PRAGMA integrity_check` and has the expected tables
**AC4:** Given a PostgreSQL dump on Google Drive, When I restore it to a test database, Then the restored DB has the expected tables and row counts
**AC5:** Given encrypted secrets on Google Drive, When I restore and decrypt them, Then the files match the originals byte-for-byte
**AC6:** Given the retention policy runs, When I verify Google Drive, Then only the expected number of backup folders remain

#### Technical Notes
- Test with real data (not mocks) per project conventions
- Create a test PG database for restore testing (not prod)
- Document test results in `archive/tests/YYYY-MM-DD-e2e.md`
- Run before marking the project as production-ready
