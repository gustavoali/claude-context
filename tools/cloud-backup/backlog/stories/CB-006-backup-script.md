### CB-006: Implementar script principal backup.ps1 con orquestacion
**Points:** 5 | **Priority:** Critical

**As a** ecosystem administrator
**I want** a single PowerShell script that orchestrates the full backup pipeline
**So that** I can run one command to back up everything

#### Acceptance Criteria
**AC1:** Given no arguments, When I run `./backup.ps1`, Then it executes all tiers in order: SQLite, PostgreSQL, Secrets, Upload, Cleanup
**AC2:** Given `--tier 1`, When I run `./backup.ps1 --tier 1`, Then it backs up only Tier 1 items
**AC3:** Given `--dry-run`, When I run `./backup.ps1 --dry-run`, Then it logs what it would do without executing any backup or upload operations
**AC4:** Given the backup completes (success or partial), When all steps finish, Then a log file is written to `logs/YYYY-MM-DD.log` with timestamps, sources processed, sizes, and any errors
**AC5:** Given any step fails for a specific source, When the error is caught, Then the script continues with remaining sources and reports failures in the summary
**AC6:** Given the staging directory has files from a previous run, When a new backup starts, Then staging is cleaned before starting

#### Technical Notes
- PowerShell script, compatible with Windows nativo
- Read manifest from `config/backup-manifest.json`
- Modular functions: `Backup-SQLite`, `Backup-PostgreSQL`, `Backup-Secrets`, `Upload-ToCloud`, `Cleanup-Staging`
- Exit code 0 = full success, 1 = partial (some sources failed), 2 = critical failure
- Log format: `[YYYY-MM-DD HH:mm:ss] [LEVEL] message`
