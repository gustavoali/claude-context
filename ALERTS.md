# Alertas del Ecosistema
**Ultima revision:** 2026-03-06

## Alertas Activas
| Fecha | Tipo | Mensaje | Accion |
|-------|------|---------|--------|
| 2026-03-05 | recordatorio | Revision trimestral Marzo 2026 pendiente (directiva 6) | Iniciar en sesion dedicada |
| 2026-03-05 | recordatorio | Iniciar preparacion certificacion AWS (IDEA-034) | Revisar roadmap y planificar primeros pasos |
| 2026-03-05 | recordatorio | Avanzar capacitacion en Anthropic Academy | Continuar cursos pendientes |
| 2026-03-05 | recordatorio | Avanzar capacitacion en DeepLearning.AI | Relevar cursos y comenzar |
| 2026-03-09 | recordatorio | Watch Later MCP: 490 videos pendientes. Cuota agotada (intentado 2026-03-09 10:36 ART, aun sin reset). Ejecutar `cd C:/mcp/youtube && .venv/Scripts/python scripts/continue_watch_later_import.py`. Repetir hasta "Import COMPLETE". | Reintentar mas tarde hoy o manana temprano (~3 dias de cuota a 180 videos/dia) |
| 2026-03-09 | recordatorio | Capacitacion Gen AI Training de Intive (Become AI Ready). URL: https://smtsoftwareservices.sharepoint.com/SitePages/Gen-AI-Training-at-intive--Become-AI-Ready.aspx | Revisar contenido y planificar avance |
| 2026-03-09 | estado | Project Admin DB caido (ECONNREFUSED :5434). Pendiente registrar: mandarin-chinese, cloud-backup, narrador | Levantar container y ejecutar `pa_create_project` + `pa_set_metadata` para los 3 |
| 2026-03-09 | recordatorio | Cloud Backup (`pj cb`): proyecto sembrado, implementar y probar backup.ps1 con rclone + Google Drive | Instalar rclone, configurar Google Drive, implementar script, primer backup manual |

## Historial
| Fecha | Tipo | Mensaje | Resolucion |
|-------|------|---------|------------|
| 2026-03-09 | recordatorio | Investigar agente TTS + generacion de imagenes | Proyecto creado: `pj nr` (narrador), repo: github.com/gustavoali/narrador |
| 2026-03-09 | recordatorio | Crear proyecto investigacion Chino Mandarin | Proyecto creado: `pj mc`, repo: github.com/gustavoali/mandarin-chinese |
| 2026-03-09 | recordatorio | Crear proyecto AI Futures Research (Amodei + otros) | Proyecto creado: `pj af`, repo: github.com/gustavoali/ai-futures-research |
| 2026-03-09 | recordatorio | Crear herramienta/skill de cierre de sesion automatizado | Implementado como skill `/close-session` en `~/.claude/commands/close-session.md` |
| 2026-03-06 | recordatorio | Verificar si todavia se puede cargar el proyecto de Anyone AI | Sprint 1 project recreado desde cero, 11/11 tests passing |
| 2026-03-04 | incidente | Hook auto-learnings colgado 13h (timeout en seg no ms) | Corregido: timeouts + scripts reescritos |
