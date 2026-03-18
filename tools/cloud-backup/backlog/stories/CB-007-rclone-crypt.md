### CB-007: Configurar rclone crypt para encriptacion de secretos
**Points:** 3 | **Priority:** High

**As a** ecosystem administrator
**I want** all secret files encrypted before uploading to Google Drive
**So that** sensitive data (tokens, passwords, API keys) is not stored in plaintext in the cloud

#### Acceptance Criteria
**AC1:** Given rclone is configured with a `gdrive` remote, When I create a `gdrive-crypt` remote pointing to `gdrive:ecosystem-backups/daily/YYYY-MM-DD/secrets/`, Then `rclone crypt` encrypts file names and contents
**AC2:** Given files in `staging/secrets/`, When uploaded via the crypt remote, Then the files on Google Drive are not readable without the decryption password
**AC3:** Given the crypt password, When I run `rclone ls gdrive-crypt:`, Then I can see the decrypted file names and sizes
**AC4:** Given the crypt remote is configured, When the backup script uploads secrets, Then it uses `gdrive-crypt` instead of `gdrive` for the secrets directory only

#### Technical Notes
- rclone crypt is a wrapper remote, not a separate tool
- Password stored in rclone.conf (which itself should be protected)
- Only `staging/secrets/` uses crypt; SQLite and PG dumps do not need encryption
- Document the crypt password recovery procedure
