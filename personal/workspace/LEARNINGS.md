# Learnings - Workspace Global
**Actualizacion:** 2026-03-09

Patrones y hallazgos de sesiones generales que no pertenecen a un proyecto especifico.

---

### 2026-03-09 - MCP servers: ~/.claude.json is the correct config file
**Context:** Playwright MCP was configured in `~/.claude/settings.json` under `mcpServers` key but never loaded. Server worked perfectly when tested manually via stdio.
**Root cause:** Claude CLI reads MCP server config from `~/.claude.json`, NOT from `~/.claude/settings.json`. The `settings.json` file is for permissions, hooks, and other settings — but MCP servers defined there are ignored.
**Learning:** Use `claude mcp add -s user <name> -- <command> <args>` to register MCP servers. This writes to `~/.claude.json` which is the actual config file. Additionally, on Windows, `npx` as command does NOT work for MCP servers — Claude Code fails to spawn npx-based servers silently. Use `node` with direct path to the JS entry point instead (e.g., `node C:\Users\gdali\AppData\Roaming\npm\node_modules\@playwright\mcp\cli.js`). Install packages globally with `npm install -g` for stable paths.
**Applies to:** All MCP server configuration for Claude CLI on Windows

### 2026-03-09 - MCP servers load only at Claude Code session start
**Context:** Added MCP server mid-session, tools not available until restart.
**Learning:** MCP servers are loaded when Claude Code starts. They cannot be added or activated mid-session. Restart the session after adding servers. Use `ToolSearch` to verify availability.
**Applies to:** Any Claude Code session needing MCP tools

### 2026-03-09 - MCP stdio servers: ALL logs must go to stderr, never stdout
**Context:** YouTube MCP server wasn't loading in Claude Code. structlog was printing logs to stdout, corrupting the JSON-RPC stdio protocol.
**Learning:** MCP servers using stdio transport MUST ensure zero non-JSON-RPC output on stdout. For Python structlog, configure with `PrintLoggerFactory(file=sys.stderr)` and ensure the logging config is imported before any module emits its first log. Also, FastMCP's correct method is `run_stdio_async()`, not `run_async()` — always check the actual API.
**Applies to:** Any Python MCP server using stdio transport with structlog

### 2026-03-09 - Google ServiceUsage API requires separate OAuth scopes
**Context:** Tried to query YouTube API quota usage programmatically using the same OAuth token used for YouTube Data API v3.
**Learning:** The Google ServiceUsage API (`serviceusage.googleapis.com`) requires its own OAuth scopes, separate from YouTube API scopes. A token with only `youtube.readonly`/`youtube` scopes will get `ACCESS_TOKEN_SCOPE_INSUFFICIENT` when trying to query quota via API. To check quota programmatically, either add `cloud-platform` scope to the OAuth flow or use the Google Cloud Console UI instead.
**Applies to:** Any project needing to programmatically monitor Google API quota usage

### 2026-03-09 - youtube-transcript-api IP bans: Whisper auto-fallback implemented
**Context:** `youtube-transcript-api` returned IP ban error for mandarin video. yt-dlp metadata still worked.
**Learning:** YouTube blocks `youtube-transcript-api` by IP (residential included). Now implemented: (1) **Whisper auto-fallback** in `tools.py` — when transcript-api fails, Whisper downloads audio via yt-dlp and transcribes locally (~1:17 for 15 min video on CPU base model). (2) **Cookie support** via `YOUTUBE_COOKIE_FILE` env var pointing to Netscape-format cookies.txt. (3) `force_whisper=True` bypasses transcript-api entirely. Performance: base model on CPU processes ~12x realtime.
**Applies to:** YouTube MCP server transcript extraction

