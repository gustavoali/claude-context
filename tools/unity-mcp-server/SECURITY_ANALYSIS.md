# SECURITY_ANALYSIS.md - Unity MCP Server

**Version:** 1.0 | **Date:** 2026-02-22 | **Scope:** Pre-implementation threat model
**Reviewer:** code-reviewer (security mode)

---

## 1. Threat Model

### 1.1 Attack Surface

| Surface | Entry Point | Protocol |
|---------|------------|----------|
| Named pipe `\\.\pipe\unity-mcp-{pid}` | Any local process that knows the PID | JSON-RPC 2.0 |
| Bridge process stdin | Parent process (Claude Code) | JSON-RPC 2.0 |
| Tool parameters (JSON) | All 22 tool handlers | Deserialized JObject |
| File system writes | `create_prefab`, `save_scene`, `create_material` | Unity AssetDatabase |
| Type resolution | `add_component`, `get_component_info` | `Type.GetType()` reflection |
| Reflection-based discovery | `[McpTool]` attribute scan | Assembly reflection |

### 1.2 Threat Actors

| Actor | Motivation | Capability | Likelihood |
|-------|-----------|------------|------------|
| Malicious local process | Hijack pipe to manipulate project | Send arbitrary JSON-RPC | LOW |
| Compromised MCP client | Prompt injection causes harmful tool calls | Full tool access | MEDIUM |
| Malicious UPM package (supply chain) | Register rogue tools via [McpTool] | Code execution in Editor | LOW |

### 1.3 Protected Assets

| Asset | Impact if Compromised |
|-------|----------------------|
| Unity project files (scenes, prefabs, scripts) | Data loss, corruption |
| Files outside project (path traversal) | Arbitrary file overwrite |
| Unity Editor stability | Crash or hang blocks development |
| Developer machine resources | DoS via infinite loops or memory exhaustion |

---

## 2. Evaluation by Area

### 2.1 Named Pipe Security -- MEDIUM

**Risk:** Windows named pipes accessible by any process running as the same user.

**Mitigations:**
- Set explicit `PipeSecurity` ACL restricting access to current user SID only
- Use random token in pipe name: `unity-mcp-{pid}-{random}`
- Accept exactly ONE connection (single-client)

```csharp
var security = new PipeSecurity();
var currentUser = WindowsIdentity.GetCurrent().User;
security.AddAccessRule(new PipeAccessRule(
    currentUser, PipeAccessRights.FullControl, AccessControlType.Allow));
var pipe = NamedPipeServerStreamAcl.Create(
    pipeName, PipeDirection.InOut, 1, PipeTransmissionMode.Byte,
    PipeOptions.Asynchronous, 65536, 65536, security);
```

### 2.2 Input Validation (JSON-RPC) -- HIGH

**Risk:** Malformed, oversized, or deeply nested JSON can crash server or exhaust memory.

**Mitigations:**
- Max message size: 1 MB before parsing
- Max JSON depth: 32 levels via JsonLoadSettings
- String length limits: 512 chars for names/paths
- Schema validation before tool execution

### 2.3 Type.GetType Security -- HIGH

**Risk:** `add_component` resolves arbitrary types. Could instantiate dangerous types.

**Mitigations:**
- Verify type derives from `UnityEngine.Component` (critical gate)
- Allowlist assemblies: Unity engine + project assemblies only
- Block `System.*`, `Microsoft.*`, `Mono.*` namespaces

```csharp
var type = TypeResolver.Resolve(typeName);
if (type == null) return McpToolResult.Error($"Type '{typeName}' not found");
if (!typeof(Component).IsAssignableFrom(type))
    return McpToolResult.Error($"Type '{typeName}' is not a Component");
```

### 2.4 File System Access (Path Traversal) -- CRITICAL

**Risk:** File-writing tools accept paths. Without validation, path traversal writes outside project.

**Mitigations:**
- Only accept relative paths starting with `Assets/`
- Reject paths containing `..` or rooted paths
- Canonicalize and validate against `Application.dataPath`
- Use AssetDatabase API (naturally scoped to project)

```csharp
static bool IsValidAssetPath(string path)
{
    if (string.IsNullOrEmpty(path)) return false;
    if (path.Contains("..")) return false;
    if (Path.IsPathRooted(path)) return false;
    if (!path.StartsWith("Assets/")) return false;
    var full = Path.GetFullPath(Path.Combine(Application.dataPath, "..", path));
    return full.StartsWith(Path.GetFullPath(Application.dataPath));
}
```

### 2.5 SerializedObject Manipulation -- MEDIUM

**Risk:** `set_serialized_field` could corrupt assets with type-mismatched values.

**Mitigations:**
- Validate value matches SerializedPropertyType before assignment
- Limit array sizes (max 10,000 elements)
- Check `SerializedProperty.editable` before writing

### 2.6 Batch Operations (DoS) -- MEDIUM

**Risk:** Unbounded batch could hang Editor. Nested batches could stack overflow.

**Mitigations:**
- Max 100 operations per batch
- No nested batch_operations allowed
- 30-second timeout with CancellationToken

```csharp
const int MaxBatchSize = 100;
if (operations.Count > MaxBatchSize)
    return McpToolResult.Error($"Batch exceeds maximum of {MaxBatchSize} operations");
if (operations.Any(op => op.GetValue<string>("name") == "batch_operations"))
    return McpToolResult.Error("Nested batch_operations not allowed");
```

### 2.7 Reflection-Based Tool Discovery -- LOW

**Risk:** [McpTool] scan could register tools from malicious assemblies.

**Mitigations:**
- Only scan Tools.UnityMcpServer assembly (namespace filter)
- Log all discovered tools to Unity Console for audit

---

## 3. OWASP Evaluation (Adapted)

| OWASP Category | Applicable | Finding | Severity |
|----------------|-----------|---------|----------|
| A03: Injection | YES | Path traversal, type name injection | CRITICAL/HIGH |
| A01: Broken Access Control | YES | Named pipe accessible to local processes | MEDIUM |
| A05: Security Misconfiguration | YES | Predictable pipe name, no size limits | MEDIUM |
| A04: Insecure Design | PARTIAL | No rate limiting, no batch limits | MEDIUM |
| A06: Vulnerable Components | LOW | Newtonsoft.Json mature; keep updated | LOW |
| A08: Data Integrity | LOW | Reflection could load rogue tools | LOW |

---

## 4. Summary by Severity

| # | Finding | Severity | Mitigation |
|---|---------|----------|------------|
| S1 | Path traversal in file-writing tools | CRITICAL | Validate Assets/ prefix, reject `..` and absolute paths |
| S2 | Type.GetType resolves arbitrary types | HIGH | Component check + namespace allowlist |
| S3 | No input size/depth limits | HIGH | Max 1 MB, depth 32, string 512 chars |
| S4 | Named pipe accessible locally | MEDIUM | PipeSecurity ACL + random token + single connection |
| S5 | Batch operations unbounded | MEDIUM | Max 100 ops, no recursion, 30s timeout |
| S6 | SerializedProperty type mismatch | MEDIUM | Validate type match, limit array sizes |
| S7 | Predictable pipe name | MEDIUM | Random suffix in pipe name |
| S8 | Reflection scans all assemblies | LOW | Namespace filter, log discoveries |
| S9 | Newtonsoft.Json dependency | LOW | Pin version, monitor CVEs |

---

## 5. Recommendation

Security mitigations should be integrated INTO existing tool stories (not standalone stories):
- S1 (path validation) -> utility in UndoHelper/PathValidator, used by UMS-015, UMS-017, UMS-020
- S2 (type resolution) -> built into UMS-007 (add_component)
- S3 (input validation) -> built into UMS-003 (pipe transport) and UMS-004 (message routing)
- S4 (pipe security) -> built into UMS-003
- S5 (batch limits) -> built into UMS-022
- Estimated overhead: +3-5 points distributed across existing stories
