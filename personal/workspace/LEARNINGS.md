# Learnings - Workspace Global
**Actualizacion:** 2026-03-13

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

### 2026-03-09 - Claude Code JSONL session transcripts as token consumption proxy
**Context:** Needed to understand where Claude Code token budget was being spent across projects. No direct API for token usage per project.
**Learning:** Claude Code stores full conversation transcripts as JSONL files in `~/.claude/projects/*/`. File sizes are proportional to token consumption. Aggregate by project directory to identify top consumers: `find ~/.claude/projects -name "*.jsonl" -newer <date>` then sum sizes per project folder. Not exact tokens, but effective for relative comparison and identifying outliers.
**Applies to:** Any Claude Code usage monitoring or cost analysis

### 2026-03-09 - Claude Agent SDK continuous loop has significant idle token cost
**Context:** Atlas agent uses Agent SDK `query()` with `maxTurns: Infinity` running a polling loop (`sleep 30` between iterations). Generated 112 sessions and 39MB of JSONL in one week.
**Learning:** A Claude Agent SDK meta-session running a continuous loop (poll Telegram, check orchestrator, sleep 30) consumes ~50-200 tokens per iteration even when idle. At 30s intervals, that's ~2880 iterations/day = ~288K-576K tokens/day in idle overhead. The `sleep 30` bash command itself is free, but each loop iteration requires the model to process context and decide next action. Consider pausing the agent when not actively needed, or increasing the sleep interval significantly for idle periods.
**Applies to:** Any always-on agent built with Claude Agent SDK or similar continuous-loop patterns

### 2026-03-10 - Extracting media from saved HTML when sites block headless browsers
**Context:** NYT blocked Playwright headless access (bot detection). Needed to download podcast audio and video from the article.
**Learning:** When a site blocks headless browser access, media URLs (audio/video) embedded in saved HTML are often still directly downloadable from CDNs. Use `grep -oE 'https://[^"'"'"' ]*\.(mp3|mp4|m3u8)[^"'"'"' ]*'` on saved HTML to extract media URLs, then download with `curl -L`. CDN URLs (e.g., `nyt.simplecastaudio.com`, `vp.nyt.com`) typically don't require authentication or bot checks. This bypasses the article paywall/bot protection while still obtaining the media content.
**Applies to:** Any web scraping or media download task where the main site blocks automated access

### 2026-03-10 - Playwright MCP browser_run_code for web-to-PDF conversion
**Context:** Needed to generate a PDF from a Mashable article loaded in Playwright headless browser.
**Learning:** Use `mcp__playwright-headless__browser_run_code` with `page.pdf()` to generate PDFs from loaded web pages. The code pattern is: `async (page) => { await page.pdf({ path: 'output.pdf', format: 'A4', printBackground: true, margin: { top: '1cm', bottom: '1cm', left: '1cm', right: '1cm' } }); return 'PDF saved'; }`. This works well for archiving articles. Note: the PDF will include ads, cookie banners, and other page elements - consider removing them first with `page.evaluate` if needed.
**Applies to:** Any task requiring web page archival as PDF via Claude Code with Playwright MCP

### 2026-03-11 - Claude Code /usage, /cost, /stats are interactive-only commands
**Context:** Wanted to programmatically check quota consumption from within a running session. Tried `claude usage` via Bash tool.
**Learning:** Claude Code's built-in commands (`/usage`, `/cost`, `/stats`) are interactive-only and cannot be invoked programmatically. Running `claude usage` from Bash inside a session fails with "Claude Code cannot be launched inside another Claude Code session." There is no environment variable, status file, or internal API that exposes current quota percentage within a session. The three commands serve different purposes: `/usage` shows plan rate limits (TPM/RPM), `/cost` shows session token consumption in USD, `/stats` shows daily usage patterns and streaks. For programmatic access, the options are: (1) OpenTelemetry export (`CLAUDE_CODE_ENABLE_TELEMETRY=1`) to an external backend like Prometheus, (2) `/statusline` for live context window % in the terminal footer, or (3) JSONL file size analysis as a rough proxy.
**Applies to:** Any attempt to build automated quota/usage monitoring within Claude Code sessions

### 2026-03-11 - Claude Code OpenTelemetry for programmatic usage tracking
**Context:** Researching how to build a custom `/cuota` skill for real-time quota visibility.
**Learning:** Claude Code can export detailed metrics via OpenTelemetry by setting `CLAUDE_CODE_ENABLE_TELEMETRY=1` plus configuring an exporter (`OTEL_METRICS_EXPORTER=otlp|prometheus|console`). Available metrics include `claude_code.token.usage` (by type: input/output/cacheRead/cacheCreation), `claude_code.cost.usage` (USD), `claude_code.session.count`, `claude_code.lines_of_code.count`, `claude_code.active_time.total`. Events include per-prompt and per-tool-use logging. For quick debugging, use `OTEL_METRICS_EXPORTER=console` with `OTEL_METRIC_EXPORT_INTERVAL=1000` to see metrics in terminal. This is the most precise approach for tracking usage across sessions but requires an external metrics backend for aggregation.
**Applies to:** Building usage dashboards, cost monitoring, or quota alerting for Claude Code

### 2026-03-13 - Launching Claude Code in a new Windows Terminal tab via PowerShell
**Context:** Needed a reusable script to create a new project directory, configure permissions, and open Claude Code in a new terminal tab for running `/sembrar`.
**Learning:** Use `wt.exe new-tab` with `--startingDirectory` and a Base64-encoded PowerShell script (`-EncodedCommand`) to open a new Windows Terminal tab that automatically runs Claude Code in a specific project directory. Pattern: (1) Create dir + `.claude/settings.local.json` with broad permissions, (2) build inner script as here-string, (3) encode with `[Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($script))`, (4) `Start-Process "wt.exe" -ArgumentList "new-tab --title '...' --startingDirectory '...' -- powershell.exe -NoExit -EncodedCommand $encoded"`. Tool lives at `C:\claude_context\tools\sembrar.ps1`. Usage: `powershell -File C:\claude_context\tools\sembrar.ps1 -ProjectSlug "investigacion/llm-landscape" [-SourceDoc "C:\path\to\doc.md"]`.
**Applies to:** Any workflow requiring automated project bootstrap + Claude Code launch in a new terminal session on Windows

### 2026-03-13 - Launching Claude Code from within a Claude Code session: CLAUDECODE env var must be unset

**Context:** Created `sembrar-remoto.ps1` to open a new Windows Terminal tab and launch Claude Code automatically. When invoked from inside a running Claude Code session, the new process inherited the `CLAUDECODE` environment variable and failed with "Claude Code cannot be launched inside another Claude Code session."

**Learning:** Claude Code sets a `CLAUDECODE` environment variable to detect nested sessions and refuse to start. When spawning a new Claude Code process from a script (e.g., via `wt.exe new-tab` + PowerShell), the child process inherits this env var from the parent. Fix: add `Remove-Item Env:CLAUDECODE -ErrorAction SilentlyContinue` before calling `claude` in the inner script. This must happen in the child process's environment, not the parent's. The tool `sembrar-remoto.ps1` at `C:\claude_context\tools\sembrar-remoto.ps1` implements this pattern for project bootstrapping.

**Applies to:** Any PowerShell/batch script that needs to launch a fresh Claude Code session from within an existing one on Windows.

### 2026-03-13 - Persistent Windows Terminal tab title via inline C# TitleLocker
**Context:** The `sembrar-remoto.ps1` tool needed to lock the new terminal tab title to the project name, but `$host.UI.RawUI.WindowTitle` gets overridden by Claude Code's ANSI title updates. The `proyecto`/`pj` PowerShell function already solved this.
**Learning:** Use an inline C# class compiled via `Add-Type` in the PowerShell profile to run a `System.Threading.Timer` that restores the title every 100ms. This survives Claude Code and any other program that writes ANSI title escape sequences. Pattern: `[TitleLocker]::Lock('title')` to lock, `[TitleLocker]::Unlock()` to release, `[TitleLocker]::ChangeTitle('new')` to update while still locked. Override the `$function:global:prompt` as a secondary safety mechanism. The class is defined once in the profile (`Microsoft.PowerShell_profile.ps1`) and available in all new terminal tabs. Any inner script spawned via `wt.exe new-tab` can call `[TitleLocker]::Lock(...)` directly.
**Applies to:** Any PowerShell script that opens a new Windows Terminal tab and needs the tab title to remain fixed regardless of what Claude Code or other processes write to it.

### 2026-03-13 - Reconstructing interrupted session context via git diff
**Context:** Session #9 started after an abrupt interruption. TASK_STATE was stale (last updated 2026-03-09), but the git working tree had uncommitted changes from the interrupted session.
**Learning:** When TASK_STATE is stale after an interruption, `git status` + `git diff HEAD` reliably reconstructs what work was done. Technique: (1) `git status` to identify modified/deleted/untracked files, (2) `git diff HEAD --stat` for a quantitative overview, (3) `git diff HEAD -- <file>` to understand the nature of individual changes. The set of uncommitted changes is a complete record of everything that happened since the last commit, regardless of what the conversation contained. This is a reliable recovery complement to TASK_STATE ÔÇö it shows *what changed* even when the session log is unavailable.
**Applies to:** Any Claude Code session recovery after abrupt interruption where TASK_STATE is stale but code/file changes exist in the working tree.

### 2026-03-13 - Three-layer in-memory cache pattern for catalog data (.NET)
**Context:** Implementing a cache service for localization catalog data in FuturosSociosApi. Codified as code review rule R018.
**Learning:** In-memory cache services for catalog data (singleton, IMemoryCache) should implement three availability layers: (1) **Hot cache** ÔÇö IMemoryCache with TTL as primary path, (2) **Stale-while-revalidate** ÔÇö serve stale data + trigger background refresh when TTL expires, (3) **Fallback to disk or source** ÔÇö for cold start or recovery after failure. Additionally requires: `IHostedService` warmup to preload cache at app startup, and `BackgroundService` for periodic refresh. Without warmup, first request after startup hits the source directly, causing latency spike.
**Applies to:** Any .NET singleton service that caches catalog/reference data in IMemoryCache ÔÇö localization tables, config catalogs, lookup tables, etc.

### 2026-03-13 - TCP connect is more efficient than Docker subprocess for DB health checks
**Context:** Claude Orchestrator health checker used `child_process.execFile` to run `docker ps --filter name=...` for PostgreSQL container liveness checks, adding 50-130ms overhead per check every 60 seconds.
**Learning:** For health checks on TCP-based services (PostgreSQL, Redis, etc.), a direct TCP connect via `net.createConnection` (Node.js) is ~1-5ms with zero subprocess overhead. Use `type: 'tcp'` with `host`/`port` instead of `type: 'docker'` when the goal is just "is the service accepting connections?" - which is what most health checks need. Reserve Docker subprocess checks for scenarios requiring container-specific metadata (status, resource usage).
**Applies to:** Any Node.js service that health-checks databases or TCP services periodically

### 2026-03-13 - `setTimeout(fn, NaN)` fires immediately in Node.js (treated as 0ms delay)
**Context:** Session GC implementation used `config.sessions.endedGcMinutes * 60 * 1000` to calculate the delay. E2E test mock config omitted `endedGcMinutes`, making the value `undefined`. `undefined * 60 * 1000 = NaN`, and `setTimeout(fn, NaN)` fires immediately, causing GC to evict sessions before HTTP responses arrived.
**Learning:** `setTimeout(fn, NaN)` does NOT throw or use a default - it fires immediately (equivalent to 0ms). Always guard TTL/delay calculations with `Number.isFinite(delay) ? delay : DEFAULT_MS`. This is particularly dangerous when config values come from external sources (env vars, mock objects, incomplete config structs) that might be `undefined`.
**Applies to:** Any Node.js code computing setTimeout delays from config or user-provided values

### 2026-03-13 - Use `timer.unref()` for background GC timers to avoid keeping process alive
**Context:** Implementing auto-eviction of `ended`/`error` sessions from an in-memory Map using `setTimeout` as a TTL mechanism.
**Learning:** When using `setTimeout` for background cleanup tasks (GC, cache expiry, TTL eviction), call `.unref()` on the returned timer handle. This prevents Node.js from keeping the process alive just because there are pending GC timers. Without `.unref()`, a process with only GC timers pending will not exit naturally. Pattern: `const t = setTimeout(fn, delay); if (t.unref) t.unref();` (the `if` guard handles environments where `unref` may not exist, e.g. browser polyfills).
**Applies to:** Any Node.js service implementing in-memory GC, cache TTL, or session expiry via setTimeout

### 2026-03-13 - EventEmitter payload mismatch masked by test mock emitting wrong shape
**Context:** Debugging `session:error` GC listener in Claude Orchestrator. The base class listener used `(session) => gc(session.id)` but `session:error` is emitted by subclasses as `{ sessionId, error }`, not the session object. Tests passed because the test mock also emitted the wrong shape (the full session object), so both sides had the same bug.
**Learning:** When writing test mocks for EventEmitter events, always verify that the mock emits the *exact same payload shape* as the real production emitter. If the mock emits a superset of the real payload (e.g., the full object when reality sends `{ id, error }`), listeners that destructure the wrong key will silently pass tests but fail in production. Fix requires both: (1) correcting the listener to destructure the real payload, and (2) correcting the mock to emit the real shape. Pattern for Node.js EventEmitter: document the payload type in a `@event` JSDoc comment on the `emit()` call so it's visible to listener authors.
**Applies to:** Any Node.js codebase using EventEmitter with structured event payloads, especially when base class listens to events emitted by subclasses with different payload shapes.

### 2026-03-13 - Smart project state detection for automated Claude Code session routing
**Context:** Created `proyecto-paralelo.ps1` (`pjr`) as a smarter replacement for `sembrar-remoto.ps1`. Needed a single tool that handles any project regardless of its lifecycle stage.
**Learning:** Detect project state before launching Claude Code by inspecting the claude_context directory for marker files: (1) no `CLAUDE.md` ÔåÆ new project, launch `/sembrar`; (2) `SEED_DOCUMENT.md` exists but no `PRODUCT_BACKLOG.md` ÔåÆ seeded, launch `/brotar [name]`; (3) `PRODUCT_BACKLOG.md` + `TASK_STATE.md` ÔåÆ in progress, load TASK_STATE next steps as context; (4) `PRODUCT_BACKLOG.md` without `TASK_STATE` ÔåÆ active project, open and wait for instructions. This state machine pattern eliminates the need for separate per-lifecycle scripts. Tool accepts both slug (`investigacion/ai-dev-cost-model`) and short code (`adc`) as input, using the same project registry lookup as `pj`. Lives at `C:\claude_context\tools\proyecto-paralelo.ps1`, aliased as `pjr`.
**Applies to:** Any workflow requiring smart project bootstrap that handles multiple lifecycle stages ÔÇö applicable to any Claude Code project tooling that needs to route to the correct starting action based on project maturity.

### 2026-03-13 - PowerShell tab completion for custom tools via Register-ArgumentCompleter
**Context:** Added tab completion for the `pjr` command so it could accept both project slugs and short codes, with descriptions shown in the completion menu.
**Learning:** Use `Register-ArgumentCompleter` in the PowerShell profile to add tab completion to custom functions/scripts. To integrate with a JSON project registry: (1) lazy-load the registry into a `$global:_ProjectRegistry` variable on first access via a `_Load-ProjectRegistry` helper, (2) iterate `PSObject.Properties` of the parsed JSON, (3) return `[System.Management.Automation.CompletionResult]::new($value, $listText, 'ParameterValue', $tooltip)` for each match. Pattern supports prefix matching on both the key (slug) and a short-code field. Validate after adding with: `powershell.exe -Command "& { . 'C:\path\profile.ps1'; Write-Host 'Profile OK' }"` to catch syntax errors before reloading the terminal.
**Applies to:** Any PowerShell custom tool (`pjr`, `pj`, or similar) that needs tab-completed arguments sourced from a JSON registry or other structured data source.

### 2026-03-13 - Hierarchical alerts propagation via SHARED_RULES @import chain
**Context:** Setting up a cross-project alerts system for the "jerarquicos" project group, where alerts needed to be visible when working on any of the projects in the group (FuturosSociosApi, APIJsMobile, repositorio-apimovil).
**Learning:** Use a shared rules file as an intermediary to propagate group-level alerts automatically to all projects in a classifier. Pattern: (1) Create `C:/claude_context/[classifier]/ALERTS.md` with a `Proyecto` column for cross-project tracking, (2) Add alert display directive + `@import` to `SHARED_RULES.md`, (3) Each project's `CLAUDE.md` already imports `SHARED_RULES.md` ÔÇö new projects just need to add that one import and inherit the full alert system. This avoids duplicating the alerts directive in every project's CLAUDE.md and ensures new projects get the alert system automatically. The chain is: `project CLAUDE.md` ÔåÆ `@SHARED_RULES.md` ÔåÆ `@ALERTS.md`.
**Applies to:** Any project group (classifier) with 2+ projects that need cross-project visibility of alerts, incidents, or reminders. Applicable whenever a `SHARED_RULES.md` pattern exists within a classifier.

### 2026-03-16 - PowerShell reserved variable `$Input` silently shadows function parameters
**Context:** Debugging `proyecto-paralelo.ps1` where `Resolve-ProjectSlug` function returned empty string instead of the slug passed as argument. Debug output showed `slug=[]` despite `Project=[mcp/claude-orchestrator]` being passed correctly.
**Learning:** `$Input` is an automatic variable in PowerShell that represents the pipeline input enumerator. Naming a `param([string]$Input)` in a function causes the parameter to be silently overridden by the automatic variable, returning an empty string instead of the bound argument. Renaming to any non-reserved name (e.g., `$Id`, `$Value`) fixes the issue immediately. Other PowerShell automatic variables to avoid as param names: `$Args`, `$PSItem` (`$_`), `$PSBoundParameters`, `$MyInvocation`, `$Error`, `$Host`, `$PID`, `$PSScriptRoot`, `$PSCommandPath`.
**Applies to:** Any PowerShell function or script that defines parameters ÔÇö especially helper functions inside larger scripts. The bug is silent: no error, just wrong behavior, making it hard to diagnose without debug output.



Based on my analysis of the transcript, I can identify two new reusable learnings:

### 2026-03-28 - PostgreSQL sequences desync when inserting with explicit IDs
**Context:** Syncing projects from local PA DB to LIBERTAD PA DB by inserting rows with explicit ID values. After insertion, subsequent `INSERT` without explicit ID failed because the sequence (`projects_id_seq`, `project_metadata_id_seq`) still pointed to a value lower than the max existing ID.
**Learning:** When inserting rows into PostgreSQL with explicit IDs (bypassing the sequence via `INSERT INTO ... (id, ...) VALUES (N, ...)`), the associated sequence is NOT automatically updated. The next `INSERT` relying on `DEFAULT` or `nextval()` will generate a conflicting ID. Fix after bulk insert: `SELECT setval('sequence_name', (SELECT MAX(id) FROM table_name));` for each affected sequence. This applies to any migration, sync, or seed operation that copies rows with their original IDs.
**Applies to:** Any PostgreSQL database sync, migration, or seed operation where rows are inserted with explicit primary key values

### 2026-03-28 - GitHub Push Protection blocks entire push for secrets in ANY commit in the range
**Context:** Push to GitHub was blocked by GH013 (Push Protection) because AWS keys existed in older commits (`anyoneai/final_project/CLAUDE.md`), even though the current session's commits had no secrets.
**Learning:** GitHub Push Protection scans ALL commits being pushed, not just the latest one. If any commit in the push range contains a detected secret (even commits from weeks ago that were never pushed), the entire push is blocked. Two resolution paths: (1) **Quick:** Visit the `unblock-secret` URLs provided in the error and approve each secret individually (must approve ALL flagged secrets, not just some). (2) **Correct:** Remove secrets from the file, then use `git filter-repo` or `BFG Repo-Cleaner` to purge them from history. Note: each secret type (Access Key ID, Secret Access Key) requires separate approval even if they're in the same file. The approval must be done per-secret, not per-file.
**Applies to:** Any git repository pushing to GitHub that has ever had secrets committed, even if the secrets are in old/historical commits

