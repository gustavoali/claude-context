### CB-010: Implementar restore.ps1 para restauracion de backups
**Points:** 5 | **Priority:** High

**As a** ecosystem administrator
**I want** a restore script that can download and restore any backup
**So that** I can recover from data loss quickly and reliably

#### Acceptance Criteria
**AC1:** Given `./restore.ps1 --list`, When I run it, Then it shows all available backup dates on Google Drive with their contents
**AC2:** Given `./restore.ps1 --date 2026-03-15 --source lte.db`, When I run it, Then it downloads only that specific file from the backup to a local restore directory
**AC3:** Given `./restore.ps1 --date latest`, When I run it, Then it identifies the most recent backup date and uses that
**AC4:** Given a downloaded SQLite backup, When I specify `--apply`, Then it copies the file to its original path (with a `.bak` of the current file first)
**AC5:** Given a downloaded PostgreSQL dump, When I specify `--apply`, Then it runs `docker exec ... psql < dump.sql` to restore the database (with confirmation prompt)
**AC6:** Given encrypted secrets in the backup, When restoring, Then the script uses the crypt remote to decrypt them transparently

#### Technical Notes
- Restore dir: `C:/tools/cloud-backup/restore/`
- Always create `.bak` of current file before overwriting
- PostgreSQL restore requires the target container to be running
- Secrets decryption requires the crypt remote to be configured
- Add `--force` flag to skip confirmation prompts
