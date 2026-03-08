-- ============================================================================
-- Project Admin - Initial Schema
-- Migration: 001_initial_schema.sql
-- Date: 2026-02-13
-- Database: PostgreSQL 17
-- Description: Creates all tables, indexes, and constraints for Phase 1
-- ============================================================================

-- Migration tracking table (must exist before any migration runs)
CREATE TABLE IF NOT EXISTS schema_migrations (
    id              SERIAL PRIMARY KEY,
    version         VARCHAR(10) NOT NULL UNIQUE,       -- "001", "002", etc.
    name            VARCHAR(200) NOT NULL,
    applied_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    checksum        VARCHAR(64)                        -- SHA-256 of the SQL file for drift detection
);

-- ============================================================================
-- PROJECTS - Core registry of all projects
-- ============================================================================

CREATE TABLE IF NOT EXISTS projects (
    id              SERIAL PRIMARY KEY,
    slug            VARCHAR(100) NOT NULL UNIQUE,       -- "project-admin", "sprint-backlog-manager"
    name            VARCHAR(200) NOT NULL,              -- "Project Admin"
    description     TEXT,
    path            VARCHAR(500),                       -- "C:/mcp/project-admin"
    repo_url        VARCHAR(500),                       -- "https://github.com/user/repo"
    stack           JSONB NOT NULL DEFAULT '[]'::jsonb,  -- ["node", "postgresql", "mcp"]
    status          VARCHAR(20) NOT NULL DEFAULT 'active'
                    CHECK (status IN ('active', 'archived', 'deprecated', 'planned')),
    category        VARCHAR(50)
                    CHECK (category IN ('mcp', 'mobile', 'web', 'agent', 'tool', 'other')),
    health          JSONB NOT NULL DEFAULT '{}'::jsonb,  -- { hasGit: true, hasPackageJson: true, ... }
    config          JSONB NOT NULL DEFAULT '{}'::jsonb,  -- { sbmProjectId: 3, dockerContainers: [...] }
    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_scanned_at TIMESTAMPTZ
);

-- Trigger to auto-update updated_at on row modification
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_projects_updated_at ON projects;
CREATE TRIGGER trg_projects_updated_at
    BEFORE UPDATE ON projects
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- PROJECT_TAGS - Tags for cross-project categorization
-- ============================================================================

CREATE TABLE IF NOT EXISTS project_tags (
    id              SERIAL PRIMARY KEY,
    project_id      INTEGER NOT NULL
                    REFERENCES projects(id) ON DELETE CASCADE,
    tag             VARCHAR(50) NOT NULL,               -- "backend", "frontend", "flutter", "mcp"
    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (project_id, tag)
);

-- ============================================================================
-- PROJECT_RELATIONSHIPS - Directed edges between projects
-- ============================================================================

CREATE TABLE IF NOT EXISTS project_relationships (
    id              SERIAL PRIMARY KEY,
    source_id       INTEGER NOT NULL
                    REFERENCES projects(id) ON DELETE CASCADE,
    target_id       INTEGER NOT NULL
                    REFERENCES projects(id) ON DELETE CASCADE,
    relationship    VARCHAR(30) NOT NULL
                    CHECK (relationship IN ('depends_on', 'integrates_with', 'replaces', 'extends')),
    description     TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (source_id, target_id, relationship),
    CHECK (source_id <> target_id)                      -- No self-relationships
);

-- ============================================================================
-- PROJECT_METADATA - Extensible key-value pairs per project
-- ============================================================================

CREATE TABLE IF NOT EXISTS project_metadata (
    id              SERIAL PRIMARY KEY,
    project_id      INTEGER NOT NULL
                    REFERENCES projects(id) ON DELETE CASCADE,
    key             VARCHAR(100) NOT NULL,              -- "sbm_project_id", "orchestrator_port"
    value           JSONB NOT NULL DEFAULT 'null'::jsonb, -- Flexible value
    source          VARCHAR(50) NOT NULL DEFAULT 'manual'
                    CHECK (source IN ('manual', 'auto_scan', 'sbm_sync', 'git_sync')),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (project_id, key)
);

DROP TRIGGER IF EXISTS trg_project_metadata_updated_at ON project_metadata;
CREATE TRIGGER trg_project_metadata_updated_at
    BEFORE UPDATE ON project_metadata
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- SCAN_HISTORY - Record of filesystem scans
-- ============================================================================

CREATE TABLE IF NOT EXISTS scan_history (
    id              SERIAL PRIMARY KEY,
    scan_type       VARCHAR(30) NOT NULL
                    CHECK (scan_type IN ('full', 'incremental', 'single_project')),
    directories     JSONB NOT NULL DEFAULT '[]'::jsonb, -- ["C:/mcp/", "C:/apps/"]
    projects_found  INTEGER NOT NULL DEFAULT 0,
    projects_new    INTEGER NOT NULL DEFAULT 0,
    projects_updated INTEGER NOT NULL DEFAULT 0,
    errors          JSONB NOT NULL DEFAULT '[]'::jsonb,
    started_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at    TIMESTAMPTZ
);

-- ============================================================================
-- INDEXES
-- ============================================================================

-- projects.slug: Primary lookup pattern. Every MCP tool and REST endpoint
-- resolves projects by slug. Already covered by UNIQUE constraint, but
-- explicit index ensures B-tree is used for prefix/pattern matching too.
-- (UNIQUE creates an implicit unique index, so this is a no-op safety net)

-- projects.status + category: List/filter endpoints use these as WHERE clauses.
-- Combined index supports: WHERE status = 'active', WHERE category = 'mcp',
-- and WHERE status = 'active' AND category = 'mcp'.
CREATE INDEX IF NOT EXISTS idx_projects_status_category
    ON projects (status, category);

-- projects.path: Used by scan-service to match filesystem paths to existing
-- projects, and by Claude Orchestrator integration to map session cwd to project.
CREATE INDEX IF NOT EXISTS idx_projects_path
    ON projects (path);

-- projects.stack (GIN on JSONB array): Supports queries like
-- "SELECT * FROM projects WHERE stack @> '["node"]'::jsonb"
-- (find all projects that use node in their stack).
CREATE INDEX IF NOT EXISTS idx_projects_stack_gin
    ON projects USING GIN (stack jsonb_path_ops);

-- Full-text search on name + description: Supports pa_search_projects tool
-- and GET /projects?search=sprint queries. Uses English config for stemming.
-- tsvector is computed at query time; for 200 projects this is fast enough
-- without a materialized column.
CREATE INDEX IF NOT EXISTS idx_projects_fulltext
    ON projects USING GIN (
        to_tsvector('english', COALESCE(name, '') || ' ' || COALESCE(description, ''))
    );

-- project_tags.tag: Supports "find all projects with tag X" queries.
-- Also used by GET /tags/:tag/projects endpoint.
CREATE INDEX IF NOT EXISTS idx_project_tags_tag
    ON project_tags (tag);

-- project_tags.project_id: FK lookup when loading tags for a project.
-- Already partially covered by the UNIQUE(project_id, tag) composite index,
-- but this single-column index is more efficient for "all tags of project X".
CREATE INDEX IF NOT EXISTS idx_project_tags_project_id
    ON project_tags (project_id);

-- project_relationships: Lookup by source (outgoing) and target (incoming).
-- The UNIQUE constraint covers (source_id, target_id, relationship) which
-- helps with source_id lookups. Add target_id index for incoming queries.
CREATE INDEX IF NOT EXISTS idx_project_relationships_target
    ON project_relationships (target_id);

-- project_metadata.project_id: Load all metadata for a project.
-- Covered by UNIQUE(project_id, key) but single-column is more efficient
-- for "all metadata of project X" without key filter.
CREATE INDEX IF NOT EXISTS idx_project_metadata_project_id
    ON project_metadata (project_id);

-- scan_history.started_at: Query recent scans, ordered by date.
CREATE INDEX IF NOT EXISTS idx_scan_history_started_at
    ON scan_history (started_at DESC);

-- ============================================================================
-- Record this migration
-- ============================================================================

INSERT INTO schema_migrations (version, name)
VALUES ('001', '001_initial_schema')
ON CONFLICT (version) DO NOTHING;
