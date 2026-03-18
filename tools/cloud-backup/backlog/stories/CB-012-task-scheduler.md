### CB-012: Configurar Windows Task Scheduler para backup diario
**Points:** 3 | **Priority:** Medium

**As a** ecosystem administrator
**I want** daily backups to run automatically at 03:00 AM
**So that** I have consistent backups without manual intervention

#### Acceptance Criteria
**AC1:** Given a Task Scheduler task named "CloudBackup-Daily", When it triggers at 03:00 AM, Then it runs `backup.ps1 --tier 1` with full logging
**AC2:** Given the PC is turned off at 03:00 AM, When it turns on later, Then the task runs at the next opportunity (missed task execution setting)
**AC3:** Given the task completes with errors, When the log shows failures, Then an alert is written to `C:/claude_context/ALERTS.md`
**AC4:** Given a weekly schedule on Sundays, When the weekly task triggers, Then it runs `backup.ps1 --tier 2` in addition to the daily tier 1

#### Technical Notes
- Use `Register-ScheduledTask` PowerShell cmdlet for setup
- Task runs under current user context (needs access to Docker, rclone, files)
- Two tasks: daily (Tier 1) + weekly (Tier 2 on Sundays)
- Consider creating a `setup-scheduler.ps1` helper script
