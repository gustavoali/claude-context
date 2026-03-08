# Learnings - Context Engineering Research

### 2026-03-05 - Claude Code hook timeout unit is SECONDS not milliseconds
**Context:** auto-learnings.ps1 hook hung for 13 hours after session end. All hooks in settings.json had `timeout: 120000` thinking it was milliseconds.
**Learning:** The `timeout` field in Claude Code's `settings.json` hooks configuration is in **seconds**, not milliseconds. `timeout: 120000` = 33.3 hours, not 2 minutes. Use `timeout: 120` for 2 minutes.
**Applies to:** Any Claude Code hook configuration in settings.json.

### 2026-03-05 - Windows does not auto-kill child processes when parent dies
**Context:** Even if pwsh.exe (hook script) was killed, the spawned `claude.exe` child process survived as an orphan running indefinitely.
**Learning:** On Windows, killing a parent process does NOT kill its children (no equivalent to Linux's `PR_SET_PDEATHSIG`). Scripts that spawn subprocesses must implement explicit recursive descendant cleanup using `Get-CimInstance Win32_Process` to walk the process tree.
**Applies to:** Any PowerShell script on Windows that spawns child processes (especially hooks that call `claude --print`).

### 2026-03-05 - Hang-proof pattern for claude --print in hooks
**Context:** Needed a reliable way to call `claude --print` from hook scripts without risk of hanging indefinitely.
**Learning:** Use 4 protections together: (1) `Start-Job` + `Wait-Job -Timeout` for hard wall-clock limit, (2) write prompt to temp file instead of pipe stdin (avoids EOF ambiguity), (3) recursive process tree cleanup in trap/finally, (4) re-entrance guard via env var to prevent infinite hook loops. Direct pipe (`$prompt | claude --print`) is unreliable in hook context.
**Applies to:** Any Claude Code hook (Stop, PreCompact, etc.) that invokes `claude --print` or similar subprocess.

### 2026-03-05 - Start-Job creates intermediate pwsh workers
**Context:** `Stop-ClaudeChildren` only killed direct children (`ParentProcessId -eq $myPid`) but missed the actual `claude.exe` because `Start-Job` creates an intermediate `pwsh.exe` worker process.
**Learning:** When using `Start-Job` in PowerShell, the job runs in a new `pwsh.exe` process. Process cleanup must be recursive (walk entire descendant tree), not just direct children. Use a recursive `Get-DescendantPids` function over `Get-CimInstance Win32_Process`.
**Applies to:** Any PowerShell script using `Start-Job` that needs to clean up spawned processes.

