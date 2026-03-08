# PA-021: REST endpoints de scan y ecosystem stats

**Points:** 2 | **Priority:** High | **MoSCoW:** Must Have
**Epic:** EPIC-PA-004 | **DoR Level:** L1 | **Sprint:** 3

## User Story

**As a** frontend developer and API consumer
**I want** REST endpoints to trigger scans and get ecosystem statistics
**So that** I can refresh project data and display global metrics on the dashboard

## Acceptance Criteria

**AC1: POST /api/v1/scan**
- Given the server is running
- When I POST /api/v1/scan
- Then a full scan of all configured directories is executed
- And results are returned with summary

**AC2: POST /api/v1/scan/directory**
- Given a valid directory path
- When I POST /api/v1/scan/directory with { directory: "C:/mcp/" }
- Then the specified directory is scanned and results returned

**AC3: GET /api/v1/scan/history**
- Given scans have been executed
- When I GET /api/v1/scan/history
- Then recent scan records are returned ordered by started_at desc

**AC4: GET /api/v1/ecosystem/stats**
- Given projects are registered
- When I GET /api/v1/ecosystem/stats
- Then ecosystem statistics are returned (by status, category, stack, health)

**AC5: GET /api/v1/ecosystem/health**
- Given projects have health data
- When I GET /api/v1/ecosystem/health
- Then a health summary of all projects is returned grouped by status

## Technical Notes
- File: `src/api/routes/scan.js`, `src/api/routes/ecosystem.js`
- Routes call scan-service and project-service for aggregations
- Scan endpoints may take several seconds; return 202 or block synchronously (Fase 1: synchronous is acceptable)

## Definition of Done
- [ ] 5 REST endpoints implemented
- [ ] Integration tests
- [ ] Swagger documentation
- [ ] Build with 0 errors, 0 warnings
