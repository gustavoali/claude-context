### CB-011: Implementar restore selectivo por tipo y tier
**Points:** 3 | **Priority:** Medium

**As a** ecosystem administrator
**I want** to restore only specific types of data (sqlite, postgres, secrets)
**So that** I can do targeted recovery without downloading everything

#### Acceptance Criteria
**AC1:** Given `./restore.ps1 --date latest --type sqlite`, When I run it, Then it downloads only SQLite backups from that date
**AC2:** Given `./restore.ps1 --date latest --type postgres`, When I run it, Then it downloads only PostgreSQL dumps
**AC3:** Given `./restore.ps1 --date latest --type secrets`, When I run it, Then it downloads and decrypts only the secrets
**AC4:** Given `./restore.ps1 --date latest --tier 1`, When I run it, Then it downloads only Tier 1 items regardless of type

#### Technical Notes
- Builds on CB-010 base restore functionality
- Filter logic reads from backup-manifest.json to know which sources belong to which tier/type
