# PA-022: Seed data de los 26 proyectos existentes

**Points:** 2 | **Priority:** High | **MoSCoW:** Must Have
**Epic:** EPIC-PA-004 | **DoR Level:** L1 | **Sprint:** 3

## User Story

**As a** user of Project Admin
**I want** all 26 existing projects pre-loaded in the database
**So that** the system is immediately useful from day one with a complete registry

## Acceptance Criteria

**AC1: Seed script execution**
- Given the database has the schema migrated
- When I run `npm run seed`
- Then all 26 projects from PROJECT_INVENTORY.md are inserted
- And running seed again does not create duplicates (idempotent)

**AC2: Projects with known data**
- Given the seed runs
- When I query projects
- Then projects with known stack data are populated correctly:
  - sprint-backlog-manager: category=mcp, stack=["node", "postgresql", "mcp"]
  - claude-orchestrator: category=mcp, stack=["node", "mcp", "websocket", "express"]
  - sprint-tracker: category=mcp, status=deprecated
  - youtube-rag-net: category=agent, stack=["dotnet"]

**AC3: Auto-detected projects**
- Given the seed runs
- When paths exist on the filesystem
- Then stack detection runs for projects with "(por determinar)" stacks
- And detected stacks are stored

**AC4: Category mapping**
- Given the seed runs
- When projects are inserted
- Then categories are assigned based on path:
  - C:/agents/* -> agent
  - C:/apps/* -> web
  - C:/mcp/* -> mcp
  - C:/mobile/* -> mobile

**AC5: Relationships seeded**
- Given the seed runs
- When relationships are queried
- Then known relationships are created:
  - sprint-backlog-manager replaces sprint-tracker
  - project-admin integrates_with sprint-backlog-manager
  - project-admin integrates_with claude-orchestrator

**AC6: Tags seeded**
- Given the seed runs
- When tags are queried
- Then projects have tags derived from their stack (e.g., "node", "flutter", "mcp")

## Technical Notes
- Script: `src/db/seed.js` (runnable via `npm run seed`)
- Uses project-service and scan-service for auto-detection
- Idempotent: uses ON CONFLICT DO UPDATE or service-level upsert
- Sources PROJECT_INVENTORY.md data as hardcoded seed array
- For projects with unknown stack: attempt fsScanner.detectStack if path exists

## Definition of Done
- [ ] seed.js script implemented
- [ ] All 26 projects inserted with correct data
- [ ] Stack auto-detection for unknown projects
- [ ] Relationships and tags seeded
- [ ] Idempotent execution verified
- [ ] Data quality validated (no nulls in required fields)
- [ ] Build with 0 errors, 0 warnings
