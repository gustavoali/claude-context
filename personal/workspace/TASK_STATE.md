# Estado - Workspace Global
**Actualizacion:** 2026-03-09 | **Sesion:** #7

## Completado Esta Sesion
| # | Descripcion | Resultado |
|---|-------------|-----------|
| 1 | Diagnosticar por que Playwright MCP no carga en Claude Code | Causa raiz: `npx` como command falla silenciosamente en Windows. Los servers que funcionan (project-admin, claude-orchestrator) usan `node` con path directo. |
| 2 | Reconfigurar todos los MCP servers con node + path directo | 4 servers migrados: playwright, playwright-headless, google-drive, youtube-transcript. Instalados globalmente con `npm install -g`. |
| 3 | Limpiar entries legacy en ~/.claude/settings.json | Removida seccion mcpServers completa (4 entries npx que no funcionaban). |
| 4 | Actualizar LEARNINGS | Agregado learning sobre npx vs node en Windows para MCP servers. |

## Proximos Pasos
1. Reiniciar sesion y verificar que los 4 MCP servers cargan (playwright, playwright-headless, youtube-transcript, google-drive)
2. Si cargan: usar Playwright para verificar cuota YouTube API en Google Cloud Console
3. Reintentar migracion Watch Later despues de reset de cuota
4. Probar YouTube MCP propio (transcript del video de mandarin)

## Decisiones Pendientes
(ninguna)

## Sugerencias Pendientes
(ninguna)
