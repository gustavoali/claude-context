# Learnings - Gaia Protocol



### 2026-03-05 - Unity Editor: Application.logMessageReceived requires domain reload handling
**Context:** Building a ReadConsoleTool for Unity MCP server that subscribes to `Application.logMessageReceived` to capture console logs.
**Learning:** Static event subscriptions in Unity Editor tools need `[InitializeOnLoad]` + static constructor to handle domain reloads (assembly recompilation). Without this, the static `_listening` flag resets to false on reload but the old subscription dies with the old domain, so you get clean re-subscription anyway ÔÇö but explicitly handling it is safer and documents the behavior. Also, use `logMessageReceivedThreaded` instead of `logMessageReceived` if you already have thread-safe locking, to capture logs from background threads too.
**Applies to:** Any Unity Editor extension that subscribes to static events or maintains static state.

### 2026-03-05 - Unity: GameObject.Find() only finds active objects
**Context:** Multiple MCP tools needed to find GameObjects by scene path, but `GameObject.Find()` silently returns null for inactive objects.
**Learning:** `GameObject.Find(path)` only finds active GameObjects. To find inactive ones, traverse the scene hierarchy manually: get root objects via `SceneManager.GetActiveScene().GetRootGameObjects()`, match the first path segment, then use `Transform.Find()` for remaining segments (which DOES find inactive children). This pattern should be extracted to a shared helper when multiple tools need it.
**Applies to:** Unity Editor tools/extensions that operate on scene objects by path.

### 2026-03-05 - Unity: EditorApplication.isPlaying = true is asynchronous
**Context:** PlayModeTool sets `EditorApplication.isPlaying = true` and returns immediately.
**Learning:** Setting `EditorApplication.isPlaying = true` doesn't enter Play Mode immediately ÔÇö the transition happens on the next frame. Any tool call executed right after may see inconsistent state. Document this in the tool's response so callers know to wait or check status before proceeding.
**Applies to:** Unity Editor automation that toggles Play Mode programmatically.

### 2026-03-05 - Type resolution in Unity: detect ambiguity on short names
**Context:** RemoveComponentTool had a type resolver that returned the first match for short type names, while AddComponentTool properly detected ambiguous matches.
**Learning:** When resolving C# types by short name (class name without namespace) across all loaded assemblies, always collect ALL matches and check for ambiguity. Returning the first match can silently resolve to the wrong type. Pattern: 1) `Type.GetType()` exact, 2) search all assemblies by full name, 3) search by short name collecting all matches ÔÇö return single match or error on multiple. Extract to shared helper when used by multiple tools.
**Applies to:** Any Unity/C# tool that resolves types by name from user input.

