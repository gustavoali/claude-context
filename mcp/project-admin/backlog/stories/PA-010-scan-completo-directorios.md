# PA-010: Scan completo de todos los directorios conocidos

**Points:** 3 | **Priority:** High | **MoSCoW:** Must Have
**Epic:** EPIC-PA-002 | **DoR Level:** L1 | **Sprint:** 2

## User Story

**As a** user of Project Admin
**I want** to run a full scan of all configured directories at once
**So that** I get a complete picture of all projects in my development environment

## Acceptance Criteria

**AC1: Scan all directories**
- Given SCAN_DIRECTORIES is configured as "C:/agents/,C:/apps/,C:/mcp/,C:/mobile/"
- When I call scanService.scanAll()
- Then each directory is scanned sequentially
- And results are aggregated into a single summary

**AC2: Aggregated summary**
- Given a full scan discovers projects across 4 directories
- When the scan completes
- Then the summary includes: total projects_found, projects_new, projects_updated, and errors per directory
- And a scan_history record of type "full" is created

**AC3: Error isolation**
- Given one directory (e.g., C:/agents/) is not accessible
- When a full scan runs
- Then the error is captured in the summary
- And the remaining directories continue to be scanned
- And partial results are still saved to the database

**AC4: Performance**
- Given 26 projects across 4 directories
- When a full scan runs
- Then it completes in under 10 seconds

## Technical Notes
- Reuses scanService.scanDirectory() for each configured directory
- Reads SCAN_DIRECTORIES from config.js
- Each directory scan is independent; errors don't abort the full scan
- scan_type: "full" in scan_history

## Definition of Done
- [ ] scanService.scanAll() implemented
- [ ] Error isolation per directory
- [ ] Aggregated summary with scan_history record
- [ ] Unit tests
- [ ] Build with 0 errors, 0 warnings
