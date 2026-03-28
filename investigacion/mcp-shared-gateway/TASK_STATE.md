# Estado - MCP Shared Gateway
**Actualizacion:** 2026-03-28 10:00 | **Version:** 0.3.0

## Completado Esta Sesion
**Overview:** MCP Shared Gateway: brotar + implementar Fases A-D | 8/13 historias completadas (21 pts) | Pendiente activacion

**Pasos clave:**
- Brotado: ARCHITECTURE_ANALYSIS.md + PRODUCT_BACKLOG.md (13 historias, 34 pts, 4 epics)
- Fase A PoC: mcp-proxy v6.4.4 funciona con --stateless. Hallazgo: --named-server-config NO existe, approach 1:1
- Fase B/C: 6 servers stateless configurados (3 Node.js + 3 Python) todos via mcp-proxy
- Fase D: Scripts Start/Stop/Status en PowerShell. Fix: $PID reservado, Python startup 10s
- Medicion: baseline 3.2 GB (54 procesos, 5 sesiones), gateway 950 MB -> ahorro 1.6 GB (63% stateless)

**Conceptos clave:**
- mcp-proxy es 1:1 (un proxy por server), no soporta multi-server
- --stateless obligatorio para compartir entre sesiones
- Puertos 9800-9805 para los 6 servers
- Config Claude Code: type:"http" + url:"http://localhost:PORT/mcp"

## Proximos Pasos
1. **Activar gateway:** arrancar Start-Gateway.ps1, aplicar config HTTP en ~/.claude.json (docs/claude-json-config.md), reiniciar sesiones
2. **Validar E2E:** abrir 2 sesiones, usar tools de cada server, confirmar que solo hay 1 instancia
3. **MSG-012:** Documentar setup completo (README)
4. **MSG-013:** Integrar arranque automatico al inicio de sesion (hook o scheduled task)
5. **Registrar en PA DB** (requiere WSL activo)

## Decisiones Pendientes
- MSG-006/007/008 absorbidas: Python servers van via mcp-proxy (no HTTP nativo). Simplifica approach pero agrega overhead de proxy. Re-evaluar si FastMCP HTTP nativo es mejor a futuro.

## Sugerencias Pendientes
- [2026-03-28] Agregar learning L-XXX a CROSS_PROJECT_LEARNINGS: "$PID es variable reservada en PowerShell" (similar a L-026 $Input). Aplica a todos los scripts PowerShell.
- [2026-03-28] Considerar auto-restart loop en Start-Gateway.ps1 (como lo hace @nano-step). Si un server cae, re-arrancarlo automaticamente. Actualmente no hay watchdog.
