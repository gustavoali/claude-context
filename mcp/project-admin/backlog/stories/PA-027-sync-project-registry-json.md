# PA-027: Auto-sync project-registry.json on project changes

**Points:** 3 | **Priority:** Medium | **MoSCoW:** Should Have
**Epic:** - (standalone, quality-of-life) | **DoR Level:** L1 | **Sprint:** Backlog

## User Story

**As a** developer using the PowerShell `proyecto` command
**I want** project-admin to automatically sync `C:/claude_context/project-registry.json` when projects are created, updated, or deleted
**So that** new projects are immediately available in the `proyecto` navigation command without manual JSON editing

## Context

Two registries exist and drift apart:
1. **project-admin DB** (PostgreSQL) - source of truth, managed via MCP tools
2. **project-registry.json** - consumed by PowerShell `proyecto` command for quick navigation by ID or short code

Currently, `pa_create_project` + `pa_set_metadata` do NOT update the JSON file. This causes friction every time a new project is registered (e.g., "Workspace Global" was in the DB but missing from the JSON).

## Acceptance Criteria

**AC1: Sync on project creation**
- Given a new project is created via `pa_create_project` with slug "my-project", name "My Project", path "C:/apps/my-project", category "apps"
- When the creation completes successfully
- Then `project-registry.json` is updated with a new entry under `projects["my-project"]`
- And the entry contains: name, path, category
- And short is empty string if no metadata "short" exists yet
- And context is derived from convention `C:/claude_context/{category}/{slug}` if metadata "context_path" is not set

**AC2: Sync on metadata "short" change**
- Given project "my-project" exists in the registry JSON without a short code
- When `pa_set_metadata` is called with key "short" and value "mp"
- Then `project-registry.json` entry for "my-project" is updated with `"short": "mp"`

**AC3: Sync on metadata "context_path" change**
- Given project "my-project" exists in the registry JSON
- When `pa_set_metadata` is called with key "context_path" and value "C:/claude_context/custom/my-project"
- Then `project-registry.json` entry for "my-project" is updated with `"context": "C:/claude_context/custom/my-project"`

**AC4: Sync on project update**
- Given project "my-project" exists in the registry JSON
- When `pa_update_project` is called changing name to "My Renamed Project" or path to a new location
- Then `project-registry.json` reflects the updated name and/or path

**AC5: Sync on project deletion**
- Given project "my-project" exists in the registry JSON
- When `pa_delete_project` is called with confirm: true
- Then the entry is removed from `project-registry.json`
- And the `_meta.updated` field is set to the current date

**AC6: JSON file integrity**
- Given `project-registry.json` is being updated
- When the sync writes the file
- Then the existing entries are preserved (no data loss)
- And the JSON is formatted with 2-space indentation
- And the `_meta.updated` date is set to the current date (YYYY-MM-DD)
- And the `_meta.version` is incremented (patch level)

**AC7: Missing JSON file**
- Given `project-registry.json` does not exist at the expected path
- When a sync trigger fires
- Then a warning is logged but the MCP operation does NOT fail
- And the project change in the DB succeeds regardless of JSON sync result

**AC8: Concurrent access safety**
- Given another process might read the JSON while it is being written
- When the sync writes the file
- Then it writes to a temp file first and renames (atomic write)

## Technical Notes
- Registry JSON path: `C:/claude_context/project-registry.json`
- New file: `src/services/registry-sync.js` (or similar) - isolated service for JSON sync logic
- Hook into existing service layer (project-service.js, metadata-service.js) as post-operation side effect
- JSON schema for each entry: `{ name, short, path, context, category }`
- Context derivation convention: `C:/claude_context/{category}/{slug}` (fallback when no metadata "context_path")
- Short code comes from project_metadata table, key "short"
- Use fs.writeFile with temp file + rename pattern for atomic writes
- Sync failures must NOT break the primary MCP operation - wrap in try/catch, log warning
- Consider a single `syncProjectToRegistry(slug)` function called from multiple hooks

## Definition of Done
- [ ] Registry sync service implemented
- [ ] Hooks added to pa_create_project, pa_update_project, pa_delete_project
- [ ] Hook added to pa_set_metadata for keys "short" and "context_path"
- [ ] Atomic file write (temp + rename)
- [ ] Error handling: sync failure does not break primary operation
- [ ] Unit tests for sync logic (read, merge, write)
- [ ] Integration test: create project -> verify JSON updated
- [ ] Integration test: delete project -> verify JSON entry removed
- [ ] Build with 0 errors, 0 warnings
