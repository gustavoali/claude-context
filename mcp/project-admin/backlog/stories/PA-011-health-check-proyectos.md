# PA-011: Health check de proyectos via git y filesystem

**Points:** 5 | **Priority:** High | **MoSCoW:** Must Have
**Epic:** EPIC-PA-002 | **DoR Level:** L2 | **Sprint:** 2

## User Story

**As a** user of Project Admin
**I want** to check the health status of any registered project
**So that** I can quickly identify issues like missing git repos, stale projects, or broken builds

## Acceptance Criteria

**AC1: Git health check**
- Given a project has path "C:/mcp/project-admin" with a .git directory
- When I call healthService.check("project-admin")
- Then the health report includes: hasGit: true, gitBranch (current branch), lastCommitDate, lastCommitMessage, lastCommitHash

**AC2: No git directory**
- Given a project path exists but has no .git directory
- When I call healthService.check("some-project")
- Then the health report includes hasGit: false
- And git-related fields are null

**AC3: Package detection**
- Given a project has package.json and node_modules/
- When I call healthService.check("my-node-project")
- Then the health report includes hasPackageJson: true, nodeModulesExists: true

**AC4: Flutter detection**
- Given a project has pubspec.yaml
- When I call healthService.check("my-flutter-app")
- Then the health report includes hasPubspec: true

**AC5: Remote URL extraction**
- Given a project has a git remote named "origin"
- When I call healthService.check("my-project")
- Then the health report includes repoUrl with the remote URL

**AC6: Health status calculation**
- Given a project health check completes
- When all checks pass (hasGit, project files exist, recent commit within 90 days)
- Then lastScanResult is "healthy"
- When git is missing or last commit is older than 90 days
- Then lastScanResult is "warning"
- When the project path does not exist
- Then lastScanResult is "error"

**AC7: Health data persistence**
- Given a health check completes
- When the results are computed
- Then the project.health JSONB field is updated in the database
- And project.last_scanned_at is refreshed
- And if a repo_url was extracted and the project has no repo_url, it is updated

**AC8: Cached health**
- Given a project was health-checked less than 5 minutes ago
- When I call healthService.check("my-project") without refresh flag
- Then the cached health data is returned without running git commands
- When I call healthService.check("my-project", { refresh: true })
- Then a fresh health check is executed

## Technical Notes
- Files: `src/services/health-service.js`, `src/utils/git-utils.js`
- git-utils.js: wraps child_process.execFile for git commands
- Git commands: `git rev-parse --abbrev-ref HEAD`, `git log -1 --format="%H|%s|%ai"`, `git remote get-url origin`
- Cache: in-memory Map with TTL of 5 minutes
- All git operations are read-only
- Handle Windows paths correctly in child_process.execFile

## Definition of Done
- [ ] health-service.js with check function
- [ ] git-utils.js with git command wrappers
- [ ] In-memory cache with TTL
- [ ] Health status calculation logic
- [ ] Unit tests with mocked git commands
- [ ] Integration test: full health check on real project
- [ ] Build with 0 errors, 0 warnings
