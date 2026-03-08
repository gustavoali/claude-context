# PA-006: Relationship repository y service

**Points:** 3 | **Priority:** High | **MoSCoW:** Should Have
**Epic:** EPIC-PA-001 | **DoR Level:** L1 | **Sprint:** 2

## User Story

**As a** user of Project Admin
**I want** to define and query relationships between projects
**So that** I can understand dependencies and connections in my ecosystem

## Acceptance Criteria

**AC1: Create relationship**
- Given projects "project-admin" and "sprint-backlog-manager" exist
- When I call relationshipService.create({ source: "project-admin", target: "sprint-backlog-manager", relationship: "integrates_with" })
- Then the relationship is stored in the database
- And the created relationship is returned with id and created_at

**AC2: Invalid relationship type**
- Given valid source and target projects
- When I try to create a relationship with type "unknown_type"
- Then an INVALID_RELATIONSHIP_TYPE error is thrown
- And valid types are: depends_on, integrates_with, replaces, extends

**AC3: Get relationships for project**
- Given project "flutter-monitor" has relationships
- When I call relationshipService.getForProject("flutter-monitor", "both")
- Then all incoming and outgoing relationships are returned
- And each relationship includes source and target project slugs and names

**AC4: Get dependency graph**
- Given multiple projects with relationships
- When I call relationshipService.getGraph()
- Then a complete graph of all relationships is returned
- And the graph includes nodes (projects) and edges (relationships)

**AC5: Delete relationship**
- Given a relationship exists with id 5
- When I call relationshipService.delete(5)
- Then the relationship is removed from the database

## Technical Notes
- Files: `src/repositories/relationship-repository.js`, `src/services/relationship-service.js`
- Relationship types validated via CHECK constraint and service-level validation
- Graph query joins projects table for source and target names
- Direction filter: "outgoing" (source_id), "incoming" (target_id), "both"

## Definition of Done
- [ ] relationship-repository.js with all queries
- [ ] relationship-service.js with validation
- [ ] Unit tests for service
- [ ] Build with 0 errors, 0 warnings
