# Arquitectura - Unity MCP Server
**Version:** 0.1.0 | **Fecha:** 2026-02-22

## Diagrama de Componentes

```
+------------------+     stdio      +----------------+    named pipe    +---------------------------+
|  MCP Client      | (stdin/stdout) |  Bridge        | (\\.\pipe\unity | Unity Editor Process      |
|  (Claude Code)   |<-------------->|  Process        |  -mcp-{pid})   |                           |
|                  |  JSON-RPC 2.0  |  (.NET console) |<-------------->| +-------------------------+|
+------------------+  newline-delim +----------------+                 | | McpServer               ||
                                                                      | |   PipeTransport          ||
                                                                      | |   MessageRouter          ||
                                                                      | |   ToolRegistry           ||
                                                                      | |   MainThreadDispatcher   ||
                                                                      | |   +--------+---------+   ||
                                                                      | |   | Scene  | UI      |   ||
                                                                      | |   | Tools  | Tools   |   ||
                                                                      | +---|--------|---------|---+|
                                                                      |     v        v         v    |
                                                                      | +-------------------------+ |
                                                                      | | UnityEditor API         | |
                                                                      | | (GameObject, Prefab,    | |
                                                                      | |  SerializedObject, etc) | |
                                                                      | +-------------------------+ |
                                                                      +-----------------------------+
```

## Componentes

| Componente | Archivo | Responsabilidad |
|------------|---------|-----------------|
| McpServer | Editor/Core/McpServer.cs | Lifecycle: start pipe server, stop, coordinate components |
| McpBridge | Bridge/McpBridge.cs | Standalone .NET console app: stdio <-> named pipe relay |
| PipeTransport | Editor/Transport/PipeTransport.cs | Named pipe server, read/write newline-delimited JSON |
| MessageRouter | Editor/Transport/MessageRouter.cs | Dispatch JSON-RPC: initialize, tools/list, tools/call |
| JsonRpcTypes | Editor/Transport/JsonRpcTypes.cs | Request, Response, Error, Notification data types |
| ToolRegistry | Editor/Core/ToolRegistry.cs | Register, lookup, list tools by name |
| MainThreadDispatcher | Editor/Core/MainThreadDispatcher.cs | Thread-safe queue drained on EditorApplication.update |
| Tool Handlers | Editor/Tools/*.cs | One class per tool, implements IMcpTool |

## Flujo de Datos

```
1. Claude Code sends JSON-RPC request to bridge process stdin (newline-delimited JSON)
2. Bridge reads stdin line, forwards bytes to named pipe \\.\pipe\unity-mcp-{pid}
3. PipeTransport.ReadMessageAsync() reads line from pipe, deserializes to JsonRpcRequest
4. MessageRouter inspects method field:
   - "initialize"       -> return ServerInfo + capabilities
   - "notifications/initialized" -> no-op acknowledgement
   - "tools/list"       -> return ToolRegistry.ListTools()
   - "tools/call"       -> extract tool name, dispatch to ToolRegistry
5. ToolRegistry.GetTool(name) returns IMcpTool instance
6. MainThreadDispatcher.EnqueueAsync(tool.ExecuteAsync) queues work
7. EditorApplication.update callback drains queue, executes on main thread
8. Tool performs UnityEditor API calls, registers Undo, returns McpToolResult
9. MessageRouter wraps result in JsonRpcResponse
10. PipeTransport.WriteMessageAsync() serializes + writes line to pipe
11. Bridge reads pipe, writes to stdout
12. Claude Code receives response
```

## Interfaces Clave

```csharp
// --- Tool Contract ---
public interface IMcpTool
{
    string Name { get; }
    string Description { get; }
    JObject InputSchema { get; }  // JSON Schema describing parameters
    Task<McpToolResult> ExecuteAsync(JObject parameters, CancellationToken ct);
}

// --- Registry ---
public interface IToolRegistry
{
    void Register(IMcpTool tool);
    bool TryGetTool(string name, out IMcpTool tool);
    IReadOnlyList<McpToolInfo> ListTools();
}

// --- Transport ---
public interface ITransport : IDisposable
{
    Task<JsonRpcRequest> ReadMessageAsync(CancellationToken ct);
    Task WriteMessageAsync(JsonRpcResponse message, CancellationToken ct);
    Task StartAsync(CancellationToken ct);
}

// --- Main Thread ---
public interface IMainThreadDispatcher
{
    Task<T> EnqueueAsync<T>(Func<T> action);
    Task EnqueueAsync(Action action);
}

// --- Data Types ---
public class McpToolResult
{
    public bool IsError { get; set; }
    public List<McpContent> Content { get; set; }

    public static McpToolResult Success(string text);
    public static McpToolResult Error(string message);
}

public class McpContent
{
    public string Type { get; set; }  // "text"
    public string Text { get; set; }
}

public class McpToolInfo
{
    public string Name { get; set; }
    public string Description { get; set; }
    public JObject InputSchema { get; set; }
}

public class JsonRpcRequest
{
    public string Jsonrpc { get; set; }  // "2.0"
    public string Method { get; set; }
    public JObject Params { get; set; }
    public object Id { get; set; }       // string or int, null for notifications
}

public class JsonRpcResponse
{
    public string Jsonrpc { get; set; }  // "2.0"
    public object Id { get; set; }
    public JToken Result { get; set; }   // present on success
    public JsonRpcError Error { get; set; }  // present on error
}

public class JsonRpcError
{
    public int Code { get; set; }
    public string Message { get; set; }
    public JToken Data { get; set; }
}
```

## ADRs (Architecture Decision Records)

### ADR-001: stdio vs HTTP transport
**Context:** MCP client needs to communicate with the server inside Unity Editor.
| Option | Pros | Cons |
|--------|------|------|
| A: stdio | Native MCP, no ports, no firewall | Single client, needs bridge (ADR-004) |
| B: HTTP | Multi-client, browser debuggable | Port conflicts, firewall, extra deps |
**Decision:** Option A (stdio). MCP natively supports stdio. Single-client expected. Bridge solves Unity limitation.

### ADR-002: UPM package vs Editor script drop-in
| Option | Pros | Cons |
|--------|------|------|
| A: UPM local package | Reusable, versioned, clean separation | Slightly more setup |
| B: Loose Editor scripts | Simplest drop-in | Not portable, no versioning |
**Decision:** Option A. Reusability is a core goal. UPM provides versioning and standard workflow.

### ADR-003: Undo strategy
**Decision:** Every tool registers with Unity Undo system. Batch operations group via `Undo.SetCurrentGroupName` + `Undo.CollapseUndoOperations`. No tool may skip Undo registration.

### ADR-004: Bridge process for Unity Editor connectivity
**Context:** Unity Editor is not a CLI process. No stdin/stdout exposed for external communication. Critical risk from seed.
| Option | Pros | Cons |
|--------|------|------|
| A: Bridge + named pipe | Clean separation, stdio standard, pipe fast IPC | Extra process, slightly more complexity |
| B: HTTP localhost | No bridge, Unity can host HTTP | Port conflicts, firewall, not native MCP |
| C: TCP socket direct | Fast, no bridge | Port management, not MCP-standard |
**Decision:** Option A. Bridge is minimal .NET console app (~100 lines) relaying stdio to named pipe. Unity opens `NamedPipeServerStream` on `EditorApplication.delayCall`. Named pipes are fast, no firewall, work on Windows and Unix (domain sockets as fallback).

### ADR-005: JSON serialization library
**Context:** `System.Text.Json` is NOT available in Unity without manual DLL management.
| Option | Pros | Cons |
|--------|------|------|
| A: System.Text.Json | Modern, fast | Not available in Unity, IL2CPP issues |
| B: Newtonsoft.Json (com.unity.nuget.newtonsoft-json) | Official UPM, mature, IL2CPP safe | Slightly slower, larger API |
| C: Unity JsonUtility | Zero deps, built-in | Cannot handle dynamic JSON, no JObject |
**Decision:** Option B. Official UPM package since Unity 2022+. Handles dynamic JSON (JObject/JToken) for JSON-RPC params and tool schemas.

### ADR-006: Tool discovery mechanism
| Option | Pros | Cons |
|--------|------|------|
| A: Reflection (scan for IMcpTool) | Zero-config | Slower startup, order not guaranteed |
| B: Manual registration | Explicit, predictable | Must update registration code per tool |
| C: Attribute + reflection | Explicit opt-in, auto-discovery | Balance of both |
**Decision:** Option C. Tools marked with `[McpTool]` attribute. ToolRegistry scans assembly at startup. Alphabetical by name for deterministic tools/list.

### ADR-007: Error handling strategy
**Decision:** Three-layer error handling:
1. **Tool level:** Domain exceptions -> `McpToolResult.Error(message)`
2. **Dispatch level:** MessageRouter try-catch -> JSON-RPC error -32603
3. **Transport level:** Malformed JSON -> JSON-RPC parse error -32700. Never propagates to Unity.

## Package Structure (UPM)

```
Packages/com.tools.unity-mcp-server/
  package.json
  Editor/
    Tools.UnityMcpServer.Editor.asmdef
    Core/
      McpServer.cs
      ToolRegistry.cs
      MainThreadDispatcher.cs
      McpToolAttribute.cs
    Transport/
      PipeTransport.cs
      MessageRouter.cs
      JsonRpcTypes.cs
    Tools/
      Scene/
        CreateGameObjectTool.cs
        AddComponentTool.cs
        SetTransformTool.cs
        FindGameObjectTool.cs
        DeleteGameObjectTool.cs
      UI/
        CreateCanvasTool.cs
        CreateUiElementTool.cs
        SetRectTransformTool.cs
        SetSerializedFieldTool.cs
      Prefab/
        CreatePrefabTool.cs
        InstantiatePrefabTool.cs
        SaveSceneTool.cs
      Query/
        GetHierarchyTool.cs
        GetComponentInfoTool.cs
      Advanced/
        CreateMaterialTool.cs
        SetLayerTagTool.cs
        BatchOperationsTool.cs
    Util/
      UndoHelper.cs
      SerializedPropertyHelper.cs
  Tests/
    Editor/
      Tools.UnityMcpServer.Editor.Tests.asmdef
      Core/
        ToolRegistryTests.cs
        MainThreadDispatcherTests.cs
      Transport/
        MessageRouterTests.cs
        JsonRpcTypesTests.cs
      Tools/
        CreateGameObjectToolTests.cs
        (one test file per tool)
      Mocks/
        MockTransport.cs
Bridge/
  McpBridge.csproj
  Program.cs
```

## Threading Model

```
[Background Thread]                    [Main Thread (Unity)]
PipeTransport.ReadLoop()               EditorApplication.update
  reads newline from pipe                MainThreadDispatcher.DrainQueue()
  deserializes JsonRpcRequest              foreach queued (Func<T>, TCS<T>):
  MessageRouter.HandleAsync()                execute on main thread
    if tools/call:                           set TaskCompletionSource result
      tool = registry.GetTool(name)
      result = await dispatcher          PipeTransport.WriteResponse()
        .EnqueueAsync(tool.Execute)        serialize + write line to pipe
      build JsonRpcResponse
```

- `ConcurrentQueue<(Delegate, object tcs)>` for the queue
- `EditorApplication.update += DrainQueue` registered on server start
- DrainQueue processes up to 10 items per frame to avoid Editor freezing
- Long-running tools (>100ms) should yield or chunk work

## Testing Strategy

| Component | Test Type | Approach |
|-----------|-----------|----------|
| JsonRpcTypes | Unit (EditMode) | Serialize/deserialize known payloads, round-trip |
| MessageRouter | Unit (EditMode) | Mock transport, verify routing |
| ToolRegistry | Unit (EditMode) | Register, lookup, list, duplicate rejection |
| MainThreadDispatcher | Integration (EditMode) | Enqueue, verify execution on update |
| Each Tool | Integration (EditMode) | Create/verify/cleanup GOs in temp scene, assert Undo |
| PipeTransport | Integration (EditMode) | Mock pipe with MemoryStream, verify framing |
| Bridge | Unit (.NET) | Separate project, mock streams |
| End-to-end | Manual + scripted | Send JSON-RPC via pipe, verify scene state |

## Performance Targets

| Metric | Target |
|--------|--------|
| Simple tool call latency (create GO) | < 50ms |
| Complex tool call (UI hierarchy) | < 200ms |
| Bridge relay overhead | < 5ms |
| Server startup to ready | < 500ms |
| Memory overhead (idle) | < 10MB |

## Compatibility: Unity 2022.3 vs Unity 6

| Aspect | Unity 2022.3 | Unity 6 (6000.x) | Impact |
|--------|-------------|-------------------|--------|
| C# version | 9.0 | 9.0 | None |
| .NET profile | .NET Standard 2.1 | .NET Standard 2.1 | None |
| Newtonsoft.Json UPM | Available | Available | None |
| NamedPipeServerStream | Available | Available | None |
| TextMeshPro | Package | Built-in | Minor: check import |

No `#if` preprocessor directives expected for MVP.

## Technical Debt (initial)

| ID | Description | Severity | Notes |
|----|-------------|----------|-------|
| TD-001 | Bridge process built separately from UPM package | Low | Future: distribute as dotnet tool |

## Stack

| Technology | Version | Usage |
|------------|---------|-------|
| C# | 9.0 | Implementation (Unity and Bridge) |
| Unity Editor API | 2022.3+ / 6000.x | Scene manipulation, Undo, SerializedObject |
| Newtonsoft.Json | 13.x (com.unity.nuget.newtonsoft-json 3.x) | JSON-RPC serialization |
| MCP Protocol | 2025-03-26 | Client-server communication |
| Named Pipes | .NET BCL | IPC between bridge and Unity Editor |
| TextMeshPro | Unity built-in/package | UI text elements |
| NUnit | Unity Test Framework | EditMode tests |
