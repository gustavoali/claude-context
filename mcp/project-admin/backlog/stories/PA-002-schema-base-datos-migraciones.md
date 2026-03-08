# PA-002: Schema de base de datos y migraciones

**Points:** 5 | **Priority:** Critical | **MoSCoW:** Must Have
**Epic:** EPIC-PA-001 | **DoR Level:** L2 | **Sprint:** 1

## User Story

**As a** backend developer
**I want** a complete database schema with a migration runner
**So that** all tables, indexes, and constraints are created reliably and reproducibly

## Acceptance Criteria

**AC1: Migration runner**
- Given the database is running and empty
- When I run `npm run migrate`
- Then all migration files in `src/db/migrations/` execute in order
- And a `schema_migrations` tracking table records which migrations have been applied
- And running migrate again does not re-apply already applied migrations

**AC2: Projects table**
- Given migrations have been applied
- When I query the `projects` table
- Then it has columns: id (SERIAL PK), slug (VARCHAR(100) UNIQUE), name (VARCHAR(200)), description (TEXT), path (VARCHAR(500)), repo_url (VARCHAR(500)), stack (JSONB), status (VARCHAR(20)), category (VARCHAR(50)), health (JSONB), config (JSONB), created_at (TIMESTAMPTZ), updated_at (TIMESTAMPTZ), last_scanned_at (TIMESTAMPTZ)
- And status has a CHECK constraint for values: active, archived, deprecated, planned
- And category has a CHECK constraint for values: mcp, mobile, web, agent, tool, other

**AC3: Supporting tables**
- Given migrations have been applied
- When I query the database
- Then `project_tags` table exists with: id, project_id (FK), tag (VARCHAR(50)), created_at, UNIQUE(project_id, tag)
- And `project_relationships` table exists with: id, source_id (FK), target_id (FK), relationship (VARCHAR(30)), description (TEXT), created_at, UNIQUE(source_id, target_id, relationship)
- And `project_metadata` table exists with: id, project_id (FK), key (VARCHAR(100)), value (JSONB), source (VARCHAR(50)), created_at, updated_at, UNIQUE(project_id, key)
- And `scan_history` table exists with: id, scan_type, directories (JSONB), projects_found, projects_new, projects_updated, errors (JSONB), started_at, completed_at

**AC4: Indexes**
- Given migrations have been applied
- When I inspect the database indexes
- Then projects has indexes on: slug (unique), status, category, path
- And project_tags has an index on tag
- And project_metadata has an index on (project_id, key)

**AC5: Idempotent migrations**
- Given migrations have already been applied
- When I run `npm run migrate` again
- Then no errors occur
- And no duplicate tables or indexes are created

**AC6: Foreign key cascading**
- Given a project exists with tags, relationships, and metadata
- When I delete the project
- Then all associated tags, relationships (both source and target), and metadata are cascade deleted

## Technical Notes
- Migration files: `src/db/migrations/001_initial_schema.sql`
- Migration runner: `src/db/migrate.js` - reads .sql files, tracks in schema_migrations table
- Use IF NOT EXISTS and ON CONFLICT DO NOTHING for idempotency
- All timestamps default to NOW()
- updated_at should have a trigger or be managed at application level
- relationship CHECK constraint: depends_on, integrates_with, replaces, extends
- source CHECK constraint for metadata: manual, auto_scan, sbm_sync, git_sync

## Definition of Done
- [ ] 001_initial_schema.sql creates all 5 tables with constraints
- [ ] migrate.js runs migrations in order and tracks them
- [ ] All indexes created and justified
- [ ] FK cascading works correctly
- [ ] Unit tests for migrate.js
- [ ] Integration test: fresh DB -> migrate -> verify schema
- [ ] Build with 0 errors, 0 warnings
