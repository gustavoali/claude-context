# Learnings - Workspace Global
**Actualizacion:** 2026-03-09

Patrones y hallazgos de sesiones generales que no pertenecen a un proyecto especifico.

---

### 2026-03-09 - MCP servers: ~/.claude.json is the correct config file
**Context:** Playwright MCP was configured in `~/.claude/settings.json` under `mcpServers` key but never loaded. Server worked perfectly when tested manually via stdio.
**Root cause:** Claude CLI reads MCP server config from `~/.claude.json`, NOT from `~/.claude/settings.json`. The `settings.json` file is for permissions, hooks, and other settings — but MCP servers defined there are ignored.
**Learning:** Use `claude mcp add -s user <name> -- <command> <args>` to register MCP servers. This writes to `~/.claude.json` which is the actual config file. Also remember `-y` flag for npx-based servers.
**Applies to:** All MCP server configuration for Claude CLI

### 2026-03-09 - MCP servers load only at Claude Code session start
**Context:** Added MCP server mid-session, tools not available until restart.
**Learning:** MCP servers are loaded when Claude Code starts. They cannot be added or activated mid-session. Restart the session after adding servers. Use `ToolSearch` to verify availability.
**Applies to:** Any Claude Code session needing MCP tools

### 2026-03-09 - Google ServiceUsage API requires separate OAuth scopes
**Context:** Tried to query YouTube API quota usage programmatically using the same OAuth token used for YouTube Data API v3.
**Learning:** The Google ServiceUsage API (`serviceusage.googleapis.com`) requires its own OAuth scopes, separate from YouTube API scopes. A token with only `youtube.readonly`/`youtube` scopes will get `ACCESS_TOKEN_SCOPE_INSUFFICIENT` when trying to query quota via API. To check quota programmatically, either add `cloud-platform` scope to the OAuth flow or use the Google Cloud Console UI instead.
**Applies to:** Any project needing to programmatically monitor Google API quota usage

