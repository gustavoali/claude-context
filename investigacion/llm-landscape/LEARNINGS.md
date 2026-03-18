# Learnings - LLM Landscape

### 2026-03-17 - DeepSeek, Groq, and Ollama are OpenAI SDK-compatible
**Context:** Building a multi-model smoke test script to compare LLM APIs
**Learning:** DeepSeek, Groq, and Ollama all expose OpenAI-compatible chat completion endpoints. You only need the `openai` Python SDK with a custom `base_url`: DeepSeek (`https://api.deepseek.com`), Groq (`https://api.groq.com/openai/v1`), Ollama (`http://localhost:11434/v1`). This means a single `call_openai_compat(config, prompt)` function handles all three. Ollama doesn't require a real API key (pass any string like `"ollama"`).
**Applies to:** Any project calling multiple LLM providers; avoid writing separate client code per provider when OpenAI-compat exists.

### 2026-03-17 - Gemini SDK token usage has different attribute names
**Context:** Extracting token counts from Gemini API responses for cost calculation
**Learning:** The `google-generativeai` SDK reports token usage via `response.usage_metadata` with attributes `prompt_token_count` and `candidates_token_count` (not `prompt_tokens`/`completion_tokens` like OpenAI). Use `getattr()` with defaults since the metadata object may vary across model versions.
**Applies to:** Any project using Gemini API that needs token counting or cost estimation.

### 2026-03-17 - Groq free tier provides high-quality LLM access at zero cost
**Context:** Looking for zero-cost LLM API options for testing and evaluation
**Learning:** Groq offers a free tier with Llama 3.3 70B (`llama-3.3-70b-versatile`) at 0 cost, with rate limits of ~6K tokens/min and 30 requests/min. Combined with Ollama for local inference, this gives two zero-cost options for development and testing. Register at console.groq.com for an API key.
**Applies to:** Any project needing LLM API access for development/testing without budget; good for CI/CD smoke tests.

### 2026-03-17 - PowerShell $_ variables get mangled by bash extglob expansion
**Context:** Trying to check RAM usage via `powershell -Command` with `$_` pipeline variable from a bash shell
**Learning:** When running PowerShell commands from bash (e.g., `powershell -Command "... | ForEach-Object { $_.Property }"`), bash's extglob feature replaces `$_` with unexpected values (shows as `extglob.Property` in the error). Workaround: use `/proc/meminfo` (available on Windows via WSL/Git Bash) or `wmic` instead of PowerShell for system queries. For RAM specifically: `cat /proc/meminfo | grep -E "MemTotal|MemFree"` works reliably from bash on Windows.
**Applies to:** Any project where Claude runs system diagnostic commands from a bash shell on Windows. Avoid PowerShell one-liners with `$_` from bash; prefer Linux-style commands available in Git Bash.

### 2026-03-17 - Ollama supports cloud-proxied models alongside local ones
**Context:** Listing Ollama models on a machine with 64GB RAM, found models with `-cloud` suffix
**Learning:** Ollama can proxy to cloud-hosted models (suffix `-cloud` in model name, e.g., `deepseek-v3.1:671b-cloud`, `gpt-oss:120b-cloud`). These show SIZE as `-` in `ollama list` (vs actual GB for local models). They use the same OpenAI-compatible API (`localhost:11434/v1`) but execute remotely. This means `ollama list` output needs filtering to distinguish local vs cloud models when estimating RAM requirements.
**Applies to:** Any project using Ollama where RAM capacity matters for model selection; don't assume all listed models consume local resources.

### 2026-03-17 - Launching Windows GUI apps from Git Bash requires Unix-style paths
**Context:** Trying to open a file in Notepad++ from Claude Code's bash shell on Windows
**Learning:** On Windows with Git Bash, launching GUI applications like Notepad++ fails with `cmd //c` or `start` wrappers but works with the Unix-style path directly: `"/c/Program Files/Notepad++/notepad++.exe" "C:/path/to/file" &`. Use `find "/c/Program Files" -name "app.exe"` to locate the executable first, then invoke it with the `/c/...` path prefix and `&` to background it.
**Applies to:** Any project where Claude needs to open files in external editors or launch Windows GUI applications from a bash shell.



### 2026-03-17 - Google AI Studio free tier is blocked by region (Argentina)
**Context:** Trying to use Gemini API with multiple API keys created from different Google accounts
**Learning:** Google AI Studio's free tier for Gemini API returns `limit: 0` quotas from Argentina, regardless of account type (Workspace or personal @gmail.com). The error shows `RESOURCE_EXHAUSTED` with `limit: 0` on all free tier metrics. This is a regional restriction, not a per-project or per-account issue. The only workaround is to enable billing on the Google Cloud project, which unlocks paid-tier access at $0.10/1M tokens (input) for Gemini 2.0 Flash. Legacy models (gemini-1.5-flash) return 404 on v1beta API as of March 2026.
**Applies to:** Any project using Google Gemini API from Argentina or other restricted regions; always budget for paid tier when planning Gemini integration from LATAM.

### 2026-03-17 - Playwright MCP fails when Chrome is already running with user profile
**Context:** Trying to automate browser navigation to Google AI Studio using Playwright MCP
**Learning:** The Playwright MCP server (`mcp__playwright__browser_navigate`) fails with "Failed to launch the browser process" when Chrome is already running with the user's profile. Chrome outputs "Abriendo en una sesion existente del navegador" and exits immediately (exitCode=0) instead of launching a new debuggable instance. The `--user-data-dir` flag conflicts with the existing Chrome session. Workaround: close all Chrome windows before using Playwright MCP, or use `mcp__playwright-headless__` (headless variant) which uses its own browser binary.
**Applies to:** Any project using Playwright MCP on Windows where Chrome is the user's daily browser; prefer headless variant for automation that doesn't need visible browser.

### 2026-03-17 - MCP notifications (JSON-RPC without id) don't produce responses
**Context:** Testing an MCP server via stdio with a Python subprocess, the test script hung after sending `notifications/initialized`
**Learning:** In the MCP protocol (JSON-RPC 2.0), messages without an `id` field are **notifications** ÔÇö the server must NOT respond to them. If your test client calls `readline()` after sending a notification (e.g., `notifications/initialized`), it will block forever waiting for a response that never comes. Split your send logic into `send(msg)` (request with id ÔåÆ wait for response) and `notify(msg)` (notification without id ÔåÆ fire and forget, no readline).
**Applies to:** Any project implementing MCP client tests or custom MCP clients via stdio. The `initialize` request gets a response, but the follow-up `notifications/initialized` does not.

