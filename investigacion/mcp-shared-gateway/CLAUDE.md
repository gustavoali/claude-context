# MCP Shared Gateway - Project Context
**Version:** 0.2.0 | **Estado:** Brote (listo para desarrollar)
**Ubicacion:** C:/investigacion/mcp-shared-gateway
**Contexto:** C:/claude_context/investigacion/mcp-shared-gateway

## Proposito
Eliminar la duplicacion de MCP servers entre sesiones de Claude Code mediante un gateway/proxy compartido basado en `mcp-proxy` (punkpeye). Objetivo: reducir >= 50% el consumo de RAM (~1 GB a ~500 MB).

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

## Comandos
```bash
# Arrancar gateway (pendiente implementacion)
pwsh scripts/Start-Gateway.ps1
# Parar gateway
pwsh scripts/Stop-Gateway.ps1
# Estado
pwsh scripts/Get-GatewayStatus.ps1
```

## Documentacion
@C:/claude_context/investigacion/mcp-shared-gateway/SEED_DOCUMENT.md
@C:/claude_context/investigacion/mcp-shared-gateway/ARCHITECTURE_ANALYSIS.md
@C:/claude_context/investigacion/mcp-shared-gateway/PRODUCT_BACKLOG.md
