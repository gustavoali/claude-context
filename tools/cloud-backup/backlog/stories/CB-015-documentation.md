### CB-015: Documentar procedimientos de operacion y restore
**Points:** 2 | **Priority:** Medium

**As a** ecosystem administrator
**I want** clear documentation for operating and restoring backups
**So that** I can recover data even months later without re-learning the system

#### Acceptance Criteria
**AC1:** Given a README.md in the project root, When I read it, Then it explains: what the tool does, how to install prerequisites, how to run backups, how to restore, and how to troubleshoot common errors
**AC2:** Given the restore documentation, When I follow the steps for a SQLite restore, Then the instructions are complete and accurate (no missing steps)
**AC3:** Given the restore documentation, When I follow the steps for a PostgreSQL restore, Then the instructions include container setup, dump import, and verification
**AC4:** Given the secrets documentation, When I follow the recovery procedure, Then it explains how to access the crypt password and decrypt files manually

#### Technical Notes
- Include a troubleshooting section with common errors and fixes
- Document rclone crypt password recovery
- Include example commands for every operation
