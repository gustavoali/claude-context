# PA-009: Scan de directorio individual con auto-discovery

**Points:** 5 | **Priority:** High | **MoSCoW:** Must Have
**Epic:** EPIC-PA-002 | **DoR Level:** L2 | **Sprint:** 2

## User Story

**As a** user of Project Admin
**I want** to scan a specific directory and automatically discover projects within it
**So that** new projects are registered without manual data entry

## Acceptance Criteria

**AC1: Discover projects in directory**
- Given directory `C:/mcp/` contains subdirectories that are projects
- When I call scanService.scanDirectory("C:/mcp/")
- Then each subdirectory with a recognizable project structure is identified
- And a list of discovered projects is returned with slug, path, detected stack

**AC2: Slug generation**
- Given a discovered project at path `C:/mcp/sprint-backlog-manager`
- When the scanner generates a slug
- Then the slug is derived from the directory name: "sprint-backlog-manager"
- And underscores are converted to hyphens
- And the slug is lowercase

**AC3: New project registration**
- Given a project at `C:/apps/new-app` is discovered and not yet registered
- When the scan completes
- Then the project is automatically created in the database with detected stack and category
- And status is set to "active"

**AC4: Existing project update**
- Given a project with slug "my-project" already exists in the database
- When a scan discovers the same project
- Then the existing record is updated with refreshed stack detection
- And last_scanned_at is updated
- And no duplicate is created

**AC5: Category auto-detection**
- Given projects are discovered in known directories
- When the scanner determines category
- Then: C:/mcp/ -> "mcp", C:/mobile/ -> "mobile", C:/apps/ -> "web", C:/agents/ -> "agent"

**AC6: Scan history recording**
- Given a scan is executed
- When it completes
- Then a record is inserted in scan_history with: scan_type, directories, projects_found, projects_new, projects_updated, errors, started_at, completed_at

**AC7: Path validation**
- Given a user provides a non-existent directory path
- When I call scanService.scanDirectory("/nonexistent/path")
- Then an INVALID_DIRECTORY error is thrown with the path in the message

**AC8: Path traversal prevention**
- Given a user provides a path with ".." components
- When I call scanService.scanDirectory("C:/mcp/../../etc")
- Then the path is rejected with a SECURITY_VIOLATION error

## Technical Notes
- Files: `src/services/scan-service.js`, `src/repositories/scan-repository.js`
- Uses fs-scanner.js for stack detection
- Uses slug.js utility for slug generation from directory names
- Scan is async: reads filesystem, then does DB upserts
- Category mapping: configurable via scan directories in config
- Skip hidden directories (starting with .) and node_modules

## Definition of Done
- [ ] scan-service.js with scanDirectory function
- [ ] scan-repository.js for scan_history persistence
- [ ] slug.js utility for slug generation
- [ ] Unit tests with mocked filesystem
- [ ] Integration tests for DB upsert logic
- [ ] Build with 0 errors, 0 warnings
