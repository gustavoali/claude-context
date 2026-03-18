### CB-008: Implementar upload a Google Drive con rclone sync
**Points:** 3 | **Priority:** High

**As a** ecosystem administrator
**I want** staging files uploaded to Google Drive in the correct folder structure
**So that** backups are organized by date and type in the cloud

#### Acceptance Criteria
**AC1:** Given staging has files in `sqlite/`, `postgres/`, `secrets/`, When the upload runs, Then files are synced to `gdrive:ecosystem-backups/daily/YYYY-MM-DD/sqlite/`, `.../postgres/`, and secrets via crypt remote
**AC2:** Given a Tier 2 backup, When uploaded, Then files go to `gdrive:ecosystem-backups/weekly/YYYY-MM-DD/`
**AC3:** Given the upload completes, When `rclone check` runs against source and remote, Then 0 differences are reported (integrity verified)
**AC4:** Given a network interruption during upload, When rclone retries, Then it resumes from where it left off (rclone default retry behavior)
**AC5:** Given upload is successful, When logged, Then the log includes total bytes uploaded and elapsed time

#### Technical Notes
- Use `rclone copy` (not `rclone sync`) to avoid accidental deletion on remote
- Secrets use `gdrive-crypt` remote (CB-007)
- Non-secrets use `gdrive` remote directly
- `rclone check` post-upload for integrity verification
