# Unity MCP Server - Equipo de Desarrollo

## Composicion

| Rol | Agente | Responsabilidad |
|-----|--------|-----------------|
| MCP Server Developer | `mcp-server-developer` | Protocolo MCP, transport, JSON-RPC, tool dispatch |
| Backend Developer (.NET) | `dotnet-backend-developer` | Tool handlers C#, UnityEditor API, SerializedObject |
| Test Engineer | `test-engineer` | EditMode tests, integration tests, mock transport |
| Code Reviewer | `code-reviewer` | Review riguroso pre-merge, seguridad, patrones |

## Notas
- El mcp-server-developer lidera la implementacion del protocolo (EPIC-001)
- El dotnet-backend-developer implementa los tool handlers (EPIC-002 a EPIC-004)
- Ambos pueden trabajar en paralelo: transport + tools son independientes despues de definir IMcpTool
- El test-engineer crea tests EditMode que corren en Unity Test Runner
- Code reviewer aplica modo riguroso (directiva 8 de metodologia)

## Stack de Testing
- Unity Test Framework (EditMode tests)
- NUnit (incluido con Unity)
- Tests crean/destruyen GameObjects en escena temporal
- Mock transport para testear tools sin stdin/stdout real
