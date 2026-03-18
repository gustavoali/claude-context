### CB-009: Implementar politica de retencion y limpieza remota
**Points:** 3 | **Priority:** Medium

**As a** ecosystem administrator
**I want** old backups automatically cleaned from Google Drive
**So that** storage does not grow indefinitely

#### Acceptance Criteria
**AC1:** Given daily backups older than 7 days exist on Google Drive, When the retention cleanup runs, Then those folders are deleted and only the last 7 days remain
**AC2:** Given weekly backups older than 4 weeks exist, When the retention cleanup runs, Then those folders are deleted
**AC3:** Given archive tier backups, When the retention cleanup runs, Then archive is never deleted (indefinite retention)
**AC4:** Given `--dry-run`, When retention runs, Then it logs what would be deleted without actually deleting
**AC5:** Given the cleanup runs, When it completes, Then the log shows folders deleted and storage freed

#### Technical Notes
- Use `rclone lsd` to list date-stamped folders and compare with current date
- `rclone purge` for folder deletion
- Run retention cleanup after every successful upload
- Consider adding `--keep-last N` as a parameter override
