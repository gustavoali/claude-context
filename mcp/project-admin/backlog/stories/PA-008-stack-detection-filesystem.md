# PA-008: Stack detection por archivos del filesystem

**Points:** 3 | **Priority:** High | **MoSCoW:** Must Have
**Epic:** EPIC-PA-002 | **DoR Level:** L1 | **Sprint:** 1

## User Story

**As a** user scanning projects
**I want** the system to automatically detect the technology stack of a project by examining its files
**So that** I don't have to manually specify the stack for each of my 26+ projects

## Acceptance Criteria

**AC1: Node.js detection**
- Given a directory contains `package.json`
- When I call fsScanner.detectStack(directory)
- Then "node" is included in the detected stack array

**AC2: Flutter detection**
- Given a directory contains `pubspec.yaml`
- When I call fsScanner.detectStack(directory)
- Then "flutter" and "dart" are included in the detected stack array

**AC3: .NET detection**
- Given a directory contains a file matching `*.csproj` or `*.sln`
- When I call fsScanner.detectStack(directory)
- Then "dotnet" is included in the detected stack array

**AC4: Python detection**
- Given a directory contains `requirements.txt` or `pyproject.toml`
- When I call fsScanner.detectStack(directory)
- Then "python" is included in the detected stack array

**AC5: MCP detection**
- Given a directory has `package.json` with `@modelcontextprotocol/sdk` as a dependency
- When I call fsScanner.detectStack(directory)
- Then "mcp" is included in the detected stack array

**AC6: Multiple stack detection**
- Given a directory contains both `package.json` and `docker-compose.yml`
- When I call fsScanner.detectStack(directory)
- Then both "node" and "docker" are in the detected stack array

**AC7: Additional detections**
- Given various project files
- When I call fsScanner.detectStack(directory)
- Then the following mappings apply:
  - `angular.json` -> "angular"
  - `docker-compose.yml` -> "docker"
  - `Cargo.toml` -> "rust"
  - `go.mod` -> "go"
  - `pom.xml` -> "java"

## Technical Notes
- File: `src/utils/fs-scanner.js`
- Use fs.existsSync or fs.access for file checks (synchronous is acceptable for scanning)
- For package.json dependency checks, read and parse the file
- Return sorted, deduplicated array of strings
- Do not recurse into subdirectories for detection (only root level of project)

## Definition of Done
- [ ] fs-scanner.js with detectStack function
- [ ] All detection rules implemented
- [ ] Unit tests with mocked filesystem (>90% coverage for this utility)
- [ ] Build with 0 errors, 0 warnings
