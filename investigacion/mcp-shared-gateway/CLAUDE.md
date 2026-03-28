# MCP Shared Gateway - Project Context
**Version:** 0.3.0 | **Estado:** Implementado (pendiente activacion)
**Ubicacion:** C:/investigacion/mcp-shared-gateway
**Contexto:** C:/claude_context/investigacion/mcp-shared-gateway

## Proposito
Eliminar la duplicacion de MCP servers entre sesiones de Claude Code mediante proxies mcp-proxy compartidos. **Resultado medido: ahorro de 1.6 GB (63% de stateless, 41% total) con 5 sesiones.**

## Stack
- Node.js (mcp-proxy, named-server-config)
- Python FastMCP (HTTP nativo para youtube, narrador, llm-router)
- PowerShell (lifecycle scripts)
- Transporte: Streamable HTTP

## Decisiones Arquitectonicas Clave
- mcp-proxy directo (no @nano-step wrapper) - ADR-001
- Streamable HTTP (no SSE deprecated) - ADR-002
- Servers stateful (playwright, orchestrator) excluidos del proxy - ADR-003
- PowerShell wrapper con auto-restart - ADR-004

## Agentes Recomendados
| Tarea | Agente |
|-------|--------|
| Implementar scripts/config | `nodejs-backend-developer` |
| PowerShell lifecycle | `devops-engineer` |
| Testing E2E | `test-engineer` |

## Puertos
| Puerto | Server |
|--------|--------|
| 9800 | project-admin |
| 9801 | google-drive |
| 9802 | youtube-transcript |
| 9803 | youtube (Python) |
| 9804 | narrador (Python) |
| 9805 | llm-router (Python) |

## Comandos
```bash
# Arrancar gateway (6 servers)
pwsh C:/investigacion/mcp-shared-gateway/scripts/Start-Gateway.ps1
# Parar gateway
pwsh C:/investigacion/mcp-shared-gateway/scripts/Stop-Gateway.ps1
# Estado y memoria
pwsh C:/investigacion/mcp-shared-gateway/scripts/Get-GatewayStatus.ps1
```

## Activacion
Ver `docs/claude-json-config.md` para los cambios en `~/.claude.json`.
Requiere: (1) arrancar gateway, (2) cambiar servers a type:http, (3) reiniciar sesiones.

## Documentacion
@C:/claude_context/investigacion/mcp-shared-gateway/SEED_DOCUMENT.md
@C:/claude_context/investigacion/mcp-shared-gateway/ARCHITECTURE_ANALYSIS.md
@C:/claude_context/investigacion/mcp-shared-gateway/PRODUCT_BACKLOG.md
