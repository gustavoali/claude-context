# Learnings - Narrador

### 2026-03-11 - FastMCP import path is `mcp.server.fastmcp`, not `fastmcp`
**Context:** Implementing MCP server for Narrador (NRR-009)
**Learning:** The `fastmcp` package is not standalone. The correct import is `from mcp.server.fastmcp import FastMCP, Context`, not `from fastmcp import FastMCP, Context`. The `mcp[cli]` package bundles FastMCP inside `mcp.server.fastmcp`.
**Applies to:** Any Python project using FastMCP/MCP SDK

### 2026-03-11 - `@mcp.tool()` requires parentheses in mcp >= 1.26
**Context:** Implementing MCP server for Narrador (NRR-009)
**Learning:** With `mcp` package version 1.26.0+, the tool decorator must be called with parentheses: `@mcp.tool()`. Using the bare `@mcp.tool` (without parens) raises `TypeError` at module load time. This is a breaking difference from some FastMCP documentation examples.
**Applies to:** Any Python MCP server project using mcp >= 1.26

### 2026-03-11 - pydub `audioop` deprecation warning on Python 3.11+
**Context:** Running tests for audio assembler
**Learning:** pydub imports `audioop` which is deprecated in Python 3.12 and will be removed in 3.13. The warning `'audioop' is deprecated and slated for removal in Python 3.13` comes from pydub internals, not project code. When upgrading to Python 3.13+, pydub will need a replacement or the `audioop-lts` package.
**Applies to:** Projects using pydub with Python >= 3.11

### 2026-03-12 - Claude Code MCP servers live in ~/.claude.json, NOT ~/.claude/settings.json
**Context:** Narrador MCP server was registered in `~/.claude/settings.json` under `mcpServers` but never appeared as a tool. Investigation via docs revealed the correct location.
**Learning:** Claude Code reads MCP server definitions from `~/.claude.json` (the main config file), NOT from `~/.claude/settings.json` (which is for permissions, hooks, plugins). The correct format requires a `type` field: `{"type": "stdio", "command": "<venv>/Scripts/python", "args": ["-m", "<module.server>"], "env": {}}`. Other scopes: project-level servers go in `.mcp.json` at repo root. The `claude mcp add` CLI command writes to the correct location automatically. Servers added manually to `settings.json` are silently ignored.
**Applies to:** Any project registering a custom MCP server with Claude Code

### 2026-03-12 - Windows MP3 playback from Python: `Start-Process`, not `Media.SoundPlayer`
**Context:** Adding `play=True` parameter to `narrate_text` to auto-play generated audio on Windows.
**Learning:** `Media.SoundPlayer` (PowerShell) only supports WAV files, not MP3. For non-blocking MP3 playback on Windows from Python, use `subprocess.Popen(["powershell", "-c", f'Start-Process -FilePath "{path}"'], creationflags=subprocess.CREATE_NO_WINDOW)`. This delegates to the OS file association (default media player), returns immediately, and avoids a visible console window. On Linux/macOS, the equivalent is `subprocess.Popen(["xdg-open", str(path)])`.
**Applies to:** Any Python application on Windows that needs to trigger audio/media playback without blocking the calling process.

### 2026-03-12 - pypdf `extract_text()` returns None for image-only pages
**Context:** Implementing `narrate_pdf` tool that extracts text from PDFs using pypdf (NRR-014)
**Learning:** `pypdf`'s `page.extract_text()` returns `None` (not empty string) for pages that contain only images or non-extractable content. Always use `page.extract_text() or ""` to safely coerce to string. After joining all pages, check `if not text.strip()` to detect completely unextractable PDFs before attempting TTS synthesis.
**Applies to:** Any Python project using pypdf for text extraction from PDFs

### 2026-03-12 - Testing async MCP tools that internally delegate to other tools
**Context:** Writing unit tests for `narrate_pdf`, which internally calls `narrate_text`
**Learning:** When an async MCP tool delegates to another async tool internally, mock the inner tool directly as `AsyncMock` (e.g., `patch("narrador.server.narrate_text", new=AsyncMock(return_value=...))`) rather than mocking the full dependency chain (providers, assembler, etc.). This isolates the unit under test cleanly and avoids brittle test setups. Only test the inner tool's full chain in its own dedicated test suite.
**Applies to:** Any Python project with async functions that compose/delegate to other async functions, especially MCP servers with layered tools.

