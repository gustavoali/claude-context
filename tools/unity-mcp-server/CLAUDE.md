# Unity MCP Server - Project Context
**Version:** 0.1.0 | **Tests:** 75 EditMode | **E2E:** 7/7 passing
**Ubicacion:** C:/tools/unity-mcp-server
**Contexto:** C:/claude_context/tools/unity-mcp-server
**Estado:** MVP completo - todos los EPICs implementados y E2E verificado

## Descripcion
MCP server inside Unity Editor via bridge (stdio -> named pipe). 17 tools for scene manipulation, UI building, prefabs, and component wiring. Used by Claude Code or any MCP client.

## Stack
- **Runtime:** C# 9.0 (.NET Standard 2.1, Unity Editor)
- **Transport:** Bridge (.NET 8 console, stdio) -> Named pipe -> Unity Editor (dedicated Thread)
- **Protocol:** MCP 2025-03-26, JSON-RPC 2.0, newline-delimited JSON
- **JSON:** Newtonsoft.Json (com.unity.nuget.newtonsoft-json 3.x)
- **Unity API:** UnityEditor namespace (Editor-only)
- **Target Unity:** Unity 6 LTS (6000.x) and Unity 2022.3 LTS
- **Package:** UPM local package (com.tools.unity-mcp-server)

## Componentes
| Componente | Ubicacion | Estado |
|------------|-----------|--------|
| McpBridge | Bridge/ | Done |
| McpServer Core | Editor/Core/ | Done |
| PipeTransport | Editor/Transport/ | Done (byte-by-byte I/O) |
| Tool Handlers (17) | Editor/Tools/ | Done |
| Utilities | Editor/Util/ | Done |
| Tests (75) | Tests/Editor/ | Done |

## Comandos
```bash
# Bridge build
cd C:/tools/unity-mcp-server && dotnet build Bridge/McpBridge.csproj -c Release

# E2E test (Unity server must be running)
dotnet Bridge/bin/Release/net8.0/McpBridge.dll --e2e <pipe-name>

# Pipe diagnostic
dotnet Bridge/bin/Release/net8.0/McpBridge.dll --diag <pipe-name>

# Unity: Tools > Unity MCP > Start/Stop Server
```

## Known Issues
- Mono/Unity StreamReader.ReadLine() has buffering bug over NamedPipeServerStream - solved with byte-by-byte reads
- PipeSecurity ACL not implemented in Mono - falls back to basic pipe (warning logged)
- Server accepts only 1 connection; stops on client disconnect (reconnect requires Stop+Start)

## Agentes Recomendados
| Tarea | Agente |
|-------|--------|
| MCP protocol + transport | `mcp-server-developer` |
| C# tool handlers | `dotnet-backend-developer` |
| Architecture | `software-architect` |
| User stories | `product-owner` |
| Testing | `test-engineer` |
| Code review | `code-reviewer` |

## Reglas del Proyecto
1. Editor-only: todas las APIs son UnityEditor, no incluir en builds de runtime
2. UPM package: distribuible como paquete local para cualquier proyecto Unity
3. Stateless tools: cada tool call es independiente
4. Fail-safe: errores en tools no crashean el Editor (3 capas de error handling)
5. Direct pipe I/O: NO usar StreamReader/StreamWriter sobre NamedPipeServerStream en Unity

## Docs
@C:/claude_context/tools/unity-mcp-server/TASK_STATE.md
@C:/claude_context/tools/unity-mcp-server/SEED_DOCUMENT.md
@C:/claude_context/tools/unity-mcp-server/PRODUCT_BACKLOG.md
@C:/claude_context/tools/unity-mcp-server/ARCHITECTURE_ANALYSIS.md
@C:/claude_context/tools/unity-mcp-server/SECURITY_ANALYSIS.md
@C:/claude_context/tools/unity-mcp-server/BUSINESS_STAKEHOLDER_DECISION.md
@C:/claude_context/tools/unity-mcp-server/TEAM_ANALYSIS.md
@C:/claude_context/tools/unity-mcp-server/TEAM_DEVELOPMENT.md
