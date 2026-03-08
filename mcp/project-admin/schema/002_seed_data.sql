-- ============================================================================
-- Project Admin - Seed Data
-- Migration: 002_seed_data.sql
-- Date: 2026-02-13
-- Description: Registers the 28 known projects from the development machine.
--              Stack and health fields are intentionally minimal; the auto-scan
--              service will enrich them on first run.
-- ============================================================================

-- Use ON CONFLICT to make this idempotent (safe to re-run).

-- ============================================================================
-- 1. agents/ - AI Agents and RAG projects
-- ============================================================================

INSERT INTO projects (slug, name, description, path, category, status, stack)
VALUES
    ('atlas-ops',
     'AtlasOps',
     'Multi-service agent: TypeScript (Fastify) + Python (FastAPI) + .NET 8 + PostgreSQL + Redis',
     'C:/agents/atlasOps',
     'agent', 'active',
     '["typescript", "python", "dotnet", "postgresql", "redis", "fastify", "fastapi"]'::jsonb),

    ('linkedin-rag-agent',
     'LinkedIn RAG Agent',
     'Python-based RAG agent for LinkedIn data (app + ingest + notebooks)',
     'C:/agents/linkedin_rag_agent',
     'agent', 'active',
     '["python"]'::jsonb),

    ('tensor-lake-ai',
     'TensorLake AI',
     'AI project (details pending scan)',
     'C:/agents/tensor_lake_ai',
     'agent', 'active',
     '[]'::jsonb),

    ('youtube-jupyter',
     'YouTube Jupyter',
     'Jupyter notebooks for YouTube video analysis experiments',
     'C:/agents/youtube_jupyter',
     'agent', 'active',
     '["python", "jupyter"]'::jsonb),

    ('youtube-rag-mvp',
     'YouTube RAG MVP',
     'Python FastAPI RAG system for YouTube content (most complete version)',
     'C:/agents/youtube_rag_mvp',
     'agent', 'archived',
     '["python", "fastapi", "docker"]'::jsonb),

    ('youtube-rag-net',
     'YouTube RAG .NET',
     '.NET port of YouTube RAG system (abandoned)',
     'C:/agents/youtube_rag_net',
     'agent', 'archived',
     '["dotnet"]'::jsonb),

    ('youtube-rag-old',
     'YouTube RAG Old',
     'Original Python version of YouTube RAG (superseded by MVP)',
     'C:/agents/youtube_rag_old',
     'agent', 'archived',
     '["python"]'::jsonb)

ON CONFLICT (slug) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    path = EXCLUDED.path,
    category = EXCLUDED.category,
    status = EXCLUDED.status,
    stack = EXCLUDED.stack;

-- ============================================================================
-- 2. apps/ - Desktop and cross-platform applications
-- ============================================================================

INSERT INTO projects (slug, name, description, path, category, status, stack)
VALUES
    ('mew-michis',
     'Mew Michis',
     'Flutter app with SQLite and Clean Architecture (multiple worktrees)',
     'C:/apps/mew-michis',
     'web', 'active',
     '["flutter", "dart", "sqlite"]'::jsonb),

    ('claude-code-monitor-flutter',
     'Claude Code Monitor (Flutter)',
     'Flutter desktop/mobile app for monitoring Claude Code sessions',
     'C:/apps/claude-code-monitor/claude-code-monitor-flutter',
     'mobile', 'planned',
     '["flutter", "dart"]'::jsonb),

    ('claude-code-monitor-swift',
     'Claude Code Monitor (Swift)',
     'macOS native app for monitoring Claude Code sessions',
     'C:/apps/claude-code-monitor/claude-code-monitor-swift',
     'web', 'planned',
     '["swift"]'::jsonb),

    ('sudoku',
     'Sudoku',
     'Sudoku game with Python backend and HTML/JS/CSS frontend',
     'C:/apps/sudoku',
     'web', 'active',
     '["python", "html", "javascript"]'::jsonb)

ON CONFLICT (slug) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    path = EXCLUDED.path,
    category = EXCLUDED.category,
    status = EXCLUDED.status,
    stack = EXCLUDED.stack;

-- ============================================================================
-- 3. mcp/ - MCP Servers and tools
-- ============================================================================

INSERT INTO projects (slug, name, description, path, category, status, stack)
VALUES
    ('linkedin-transcript-extractor',
     'LinkedIn Transcript Extractor (LTE)',
     'Chrome Extension MV3 + Node.js MCP server for LinkedIn transcript extraction (v0.12.0)',
     'C:/mcp/linkedin',
     'mcp', 'active',
     '["node", "sqlite", "chrome-extension", "playwright", "mcp"]'::jsonb),

    ('claude-orchestrator',
     'Claude Orchestrator',
     'Agent orchestration via MCP + WebSocket + Agent SDK',
     'C:/mcp/claude-orchestrator',
     'mcp', 'active',
     '["node", "mcp", "websocket", "express"]'::jsonb),

    ('sprint-backlog-manager',
     'Sprint Backlog Manager',
     'MCP server for sprint/backlog management with PostgreSQL backend',
     'C:/mcp/sprint-backlog-manager',
     'mcp', 'active',
     '["node", "postgresql", "mcp"]'::jsonb),

    ('sprint-tracker',
     'Sprint Tracker (legacy)',
     'CLI-based sprint tracker with JSON storage. Replaced by Sprint Backlog Manager.',
     'C:/mcp/sprint-tracker',
     'mcp', 'deprecated',
     '["node", "cli"]'::jsonb),

    ('youtube-mcp',
     'YouTube MCP',
     'MCP server for YouTube operations (PRD only, no code yet)',
     'C:/mcp/youtube',
     'mcp', 'planned',
     '[]'::jsonb),

    ('project-admin',
     'Project Admin',
     'Central backend for the project administration ecosystem. MCP Server + REST API.',
     'C:/mcp/project-admin',
     'mcp', 'active',
     '["node", "postgresql", "mcp", "fastify"]'::jsonb)

ON CONFLICT (slug) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    path = EXCLUDED.path,
    category = EXCLUDED.category,
    status = EXCLUDED.status,
    stack = EXCLUDED.stack;

-- ============================================================================
-- 4. mobile/ - Flutter mobile applications
-- ============================================================================

INSERT INTO projects (slug, name, description, path, category, status, stack)
VALUES
    ('agenda',
     'Agenda',
     'Flutter app with flutter_bloc + Hive + Clean Architecture (timer feature)',
     'C:/mobile/agenda',
     'mobile', 'active',
     '["flutter", "dart", "hive"]'::jsonb),

    ('chemical',
     'Chemical',
     'Flutter mobile app (details pending scan)',
     'C:/mobile/chemical',
     'mobile', 'active',
     '["flutter", "dart"]'::jsonb),

    ('recetario',
     'Recetario',
     'Flutter recipe app with Riverpod + Drift/SQLite (MVP Local completed)',
     'C:/mobile/recetario',
     'mobile', 'active',
     '["flutter", "dart", "riverpod", "sqlite"]'::jsonb),

    ('spoti-admin',
     'Spoti-Admin',
     'Flutter app for Spotify administration with Riverpod + Dio + OAuth',
     'C:/mobile/spoti-admin',
     'mobile', 'active',
     '["flutter", "dart", "riverpod", "spotify-api"]'::jsonb),

    ('tracking-app',
     'Tracking App',
     'Flutter location tracking app with Provider + SQLite + flutter_map (v1.0.3)',
     'C:/mobile/tracking_app',
     'mobile', 'active',
     '["flutter", "dart", "provider", "sqlite"]'::jsonb)

ON CONFLICT (slug) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    path = EXCLUDED.path,
    category = EXCLUDED.category,
    status = EXCLUDED.status,
    stack = EXCLUDED.stack;

-- ============================================================================
-- 5. Documentation-only / Other projects
-- ============================================================================

INSERT INTO projects (slug, name, description, path, category, status, stack)
VALUES
    ('plane-integracion',
     'Plane Integracion (GitHub MCP)',
     'GitHub webhook integration documentation (no code repository found)',
     NULL,
     'mcp', 'archived',
     '[]'::jsonb),

    ('anyoneai-sprint-2',
     'AnyoneAI Sprint 2',
     'Personal training project (documentation only)',
     NULL,
     'other', 'archived',
     '[]'::jsonb),

    ('youtube-rag-docs',
     'YouTube RAG (Docs)',
     'Architecture and backlog documentation for YouTube RAG variants',
     NULL,
     'agent', 'archived',
     '[]'::jsonb),

    ('angular-web-monitor',
     'Angular Web Monitor',
     'Web dashboard for the project administration ecosystem (planned)',
     NULL,
     'web', 'planned',
     '["angular", "typescript"]'::jsonb)

ON CONFLICT (slug) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    path = EXCLUDED.path,
    category = EXCLUDED.category,
    status = EXCLUDED.status,
    stack = EXCLUDED.stack;

-- ============================================================================
-- 6. Tags - Categorize projects by technology and purpose
-- ============================================================================

-- Helper: insert tag only if it does not exist yet for that project.
-- Uses a CTE to resolve slug -> id.

INSERT INTO project_tags (project_id, tag)
SELECT p.id, t.tag
FROM projects p
CROSS JOIN (VALUES
    -- AtlasOps
    ('atlas-ops', 'backend'), ('atlas-ops', 'multi-service'), ('atlas-ops', 'ai'),
    -- LTE
    ('linkedin-transcript-extractor', 'backend'), ('linkedin-transcript-extractor', 'chrome-extension'), ('linkedin-transcript-extractor', 'mcp'),
    -- Sprint Backlog Manager
    ('sprint-backlog-manager', 'backend'), ('sprint-backlog-manager', 'mcp'),
    -- Claude Orchestrator
    ('claude-orchestrator', 'backend'), ('claude-orchestrator', 'mcp'), ('claude-orchestrator', 'realtime'),
    -- Project Admin
    ('project-admin', 'backend'), ('project-admin', 'mcp'), ('project-admin', 'rest-api'),
    -- Flutter apps
    ('mew-michis', 'frontend'), ('mew-michis', 'flutter'),
    ('claude-code-monitor-flutter', 'frontend'), ('claude-code-monitor-flutter', 'flutter'), ('claude-code-monitor-flutter', 'monitoring'),
    ('agenda', 'frontend'), ('agenda', 'flutter'),
    ('recetario', 'frontend'), ('recetario', 'flutter'),
    ('spoti-admin', 'frontend'), ('spoti-admin', 'flutter'),
    ('tracking-app', 'frontend'), ('tracking-app', 'flutter'),
    ('chemical', 'frontend'), ('chemical', 'flutter'),
    -- Angular
    ('angular-web-monitor', 'frontend'), ('angular-web-monitor', 'angular'), ('angular-web-monitor', 'monitoring'),
    -- Legacy/archived
    ('sprint-tracker', 'legacy'), ('sprint-tracker', 'cli'),
    ('youtube-rag-mvp', 'ai'), ('youtube-rag-mvp', 'legacy'),
    ('youtube-rag-net', 'ai'), ('youtube-rag-net', 'legacy'),
    ('youtube-rag-old', 'ai'), ('youtube-rag-old', 'legacy')
) AS t(project_slug, tag)
WHERE p.slug = t.project_slug
ON CONFLICT (project_id, tag) DO NOTHING;

-- ============================================================================
-- 7. Relationships - Known connections between projects
-- ============================================================================

INSERT INTO project_relationships (source_id, target_id, relationship, description)
SELECT s.id, t.id, r.rel, r.descr
FROM (VALUES
    -- Sprint Backlog Manager replaces Sprint Tracker
    ('sprint-backlog-manager', 'sprint-tracker', 'replaces',
     'SBM replaced Sprint Tracker with PostgreSQL-backed architecture'),

    -- Project Admin integrates with Sprint Backlog Manager
    ('project-admin', 'sprint-backlog-manager', 'integrates_with',
     'PA queries SBM for sprint/story data per project (Phase 2)'),

    -- Project Admin integrates with Claude Orchestrator
    ('project-admin', 'claude-orchestrator', 'integrates_with',
     'PA queries CO for active agent sessions per project (Phase 2)'),

    -- Angular Web Monitor extends Project Admin
    ('angular-web-monitor', 'project-admin', 'extends',
     'Web dashboard frontend consuming PA REST API'),

    -- Claude Code Monitor Flutter depends on Claude Orchestrator
    ('claude-code-monitor-flutter', 'claude-orchestrator', 'depends_on',
     'Flutter monitor connects to CO via WebSocket for real-time data'),

    -- YouTube RAG .NET replaces YouTube RAG Old
    ('youtube-rag-mvp', 'youtube-rag-old', 'replaces',
     'MVP superseded the original Python version')
) AS r(source_slug, target_slug, rel, descr)
JOIN projects s ON s.slug = r.source_slug
JOIN projects t ON t.slug = r.target_slug
ON CONFLICT (source_id, target_id, relationship) DO NOTHING;

-- ============================================================================
-- 8. Metadata - Known integration IDs and configuration
-- ============================================================================

INSERT INTO project_metadata (project_id, key, value, source)
SELECT p.id, m.key, m.val::jsonb, m.src
FROM (VALUES
    ('project-admin',           'docker_container',  '"project-admin-pg"',  'manual'),
    ('project-admin',           'api_port',          '3000',                'manual'),
    ('project-admin',           'db_port',           '5433',                'manual'),
    ('sprint-backlog-manager',  'db_port',           '5432',                'manual'),
    ('claude-orchestrator',     'ws_port',           '8080',                'manual'),
    ('linkedin-transcript-extractor', 'version',     '"0.12.0"',           'manual')
) AS m(project_slug, key, val, src)
JOIN projects p ON p.slug = m.project_slug
ON CONFLICT (project_id, key) DO UPDATE SET
    value = EXCLUDED.value,
    source = EXCLUDED.source;

-- ============================================================================
-- Record this migration
-- ============================================================================

INSERT INTO schema_migrations (version, name)
VALUES ('002', '002_seed_data')
ON CONFLICT (version) DO NOTHING;
