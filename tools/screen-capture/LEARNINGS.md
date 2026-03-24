# Learnings - Screen Capture MCP

### 2026-03-23 - MCP stdio config needs `cwd` when using `-m` module syntax
**Context:** Registering the screen-capture MCP server in `~/.claude.json` with `python -m src.server`
**Learning:** When an MCP server uses `python -m src.server` (module syntax with relative package), the `cwd` field must be set in the MCP config in `~/.claude.json`. Without it, Python can't resolve the module path and the server fails to start. Example: `"cwd": "C:/tools/screen-capture"`.
**Applies to:** All MCP servers registered with `-m` module syntax in `~/.claude.json`

### 2026-03-23 - mss screenshot BGRA raw format conversion
**Context:** Converting mss screen captures to PNG using Pillow
**Learning:** mss captures use BGRA byte order (accessible via `.bgra` property). To convert to a standard RGB PNG: `Image.frombytes("RGB", screenshot.size, screenshot.bgra, "raw", "BGRX")`. The "BGRX" decoder tells Pillow to read BGR channels and skip the 4th byte (alpha).
**Applies to:** Python screen capture with mss + Pillow

### 2026-03-23 - win32gui.EnumWindows early-stop raises exception
**Context:** Implementing window search by title using win32gui on Windows
**Learning:** `win32gui.EnumWindows(callback, param)` raises a `pywintypes.error` when the callback returns `False` to stop enumeration early. This is by design (not a bug). Wrap the call in `try/except Exception: pass` when using early-stop pattern. Store results via `nonlocal` variable in the callback.
**Applies to:** Windows desktop automation with pywin32

### 2026-03-23 - mss captures by screen coordinates, not by window content
**Context:** Testing `sc_capture_window` tool - captured Chrome window showed the terminal instead because it was in the foreground
**Learning:** `mss` captures screenshots based on screen region coordinates, not actual window content. When using `sc_capture_window`, if the target window is behind another window, the capture will show whatever is visually on screen at those coordinates, not the target window's content. To capture the actual window content, you'd need to call `win32gui.SetForegroundWindow(hwnd)` before capturing to bring the window to front.
**Applies to:** Python screen capture with mss + win32gui on Windows

