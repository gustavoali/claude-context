# PA-014: MCP tools de scan y health

**Points:** 3 | **Priority:** High | **MoSCoW:** Must Have
**Epic:** EPIC-PA-003 | **DoR Level:** L1 | **Sprint:** 2

## User Story

**As a** Claude Code user
**I want** MCP tools to scan directories and check project health
**So that** I can discover new projects and monitor their status from my IDE

## Acceptance Criteria

**AC1: pa_scan_directory**
- Given a valid directory path
- When Claude calls pa_scan_directory({ directory: "C:/mcp/", recursive: false })
- Then the directory is scanned and results include projects found, new, and updated

**AC2: pa_scan_all**
- Given configured scan directories
- When Claude calls pa_scan_all({})
- Then all directories are scanned and an aggregated summary is returned

**AC3: pa_project_health**
- Given a registered project
- When Claude calls pa_project_health({ slug: "project-admin" })
- Then a health report is returned with git status, file detection, and health status
- And the health report includes a human-readable summary

## Technical Notes
- File: `src/mcp/tools/scan.js`
- Tools call scan-service and health-service respectively
- pa_scan_directory accepts optional `recursive` flag (default false)
- pa_project_health returns the health JSONB structure with lastScanResult status

## Definition of Done
- [ ] 3 tools implemented: pa_scan_directory, pa_scan_all, pa_project_health
- [ ] Zod input schemas
- [ ] Integration tests
- [ ] Build with 0 errors, 0 warnings
