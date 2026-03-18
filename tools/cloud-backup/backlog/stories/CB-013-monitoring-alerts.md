### CB-013: Implementar monitoring con logs y alertas
**Points:** 3 | **Priority:** Medium

**As a** ecosystem administrator
**I want** comprehensive logging and alerting for backup operations
**So that** I know immediately when backups fail or degrade

#### Acceptance Criteria
**AC1:** Given every backup run, When it completes, Then a log file at `logs/YYYY-MM-DD.log` contains: start time, each source status (OK/WARN/ERROR), bytes processed, upload status, end time, overall result
**AC2:** Given a backup fails critically (exit code 2), When the script exits, Then it appends an alert to `C:/claude_context/ALERTS.md` with type `incidente`
**AC3:** Given a backup has warnings (exit code 1), When the script exits, Then it appends an alert to `C:/claude_context/ALERTS.md` with type `estado`
**AC4:** Given 3+ consecutive daily backups have not run (no log files for 3+ days), When a new session starts, Then the health check hook detects the gap
**AC5:** Given `./backup.ps1 --status`, When I run it, Then it shows the last backup date, result, and any active alerts

#### Technical Notes
- Log rotation: keep last 30 log files, delete older
- Alert format must match ALERTS.md table structure
- Consider a `Get-BackupHealth` function for quick status checks
