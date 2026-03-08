# Seed Document - MCP Telegram Research

**Fuente:** IDEA-046: Investigar MCP Servers existentes para Telegram
**Fecha:** 2026-03-06

---

## Objetivo

Investigar, evaluar y documentar el ecosistema de MCP servers para Telegram. Mantener un registro actualizado de alternativas disponibles, comparaciones con nuestra implementacion custom, y recomendaciones de adopcion.

## Alcance

- Relevamiento periodico de MCP servers para Telegram (Bot API y MTProto)
- Evaluacion de features, calidad, mantenimiento y compatibilidad
- Comparacion continua con el telegram-mcp custom de Atlas Agent
- Identificacion de features que podrian adoptarse o contribuirse upstream
- Documentacion de patrones comunes de integracion MCP + messaging

## Estado Inicial (2026-03-06)

### Hallazgos clave

- 9 MCP servers encontrados (6 Bot API, 3 MTProto)
- Mejor candidato: electricessence/Telegram-Bridge-MCP (features superiores, pero pre-release, 1 star)
- Recomendacion: mantener custom (~200 LOC, controlado, con rate limiting)
- Monitorear electricessence para features avanzadas (voice, files, live status)

### Candidatos relevantes (Bot API)

| Proyecto | Stars | Features destacadas |
|----------|-------|---------------------|
| electricessence/Telegram-Bridge-MCP | 1 | ask/choose/confirm, live status, voice, files |
| qpd-v/mcp-communicator-telegram | 43 | Simple ask_user + notify |
| guangxiangdebizi/telegram-mcp | 1 | CRUD mensajes, fotos, docs |
| siavashdelkhosh81/telegram-bot-mcp-server | 7 | Messaging + user mgmt |
| IQAIcom/mcp-telegram | 5 | Channels, forwarding, pinning |
| ParthJadhav/telegram-notify-mcp | 5 | Solo notificaciones |

## Entregables

- `FINDINGS.md` - Hallazgos detallados con comparaciones
- `CANDIDATES.md` - Registro de candidatos evaluados (actualizable)
- `RECOMMENDATIONS.md` - Recomendaciones y decisiones tomadas
- Actualizaciones periodicas cuando el ecosistema evolucione

## Proyectos Relacionados

- Atlas Agent (C:/agents/atlas-agent) - consumer principal del telegram-mcp
- IDEA-047 / mcp-whatsapp-research - investigacion hermana (WhatsApp)
- IDEA-012 - investigacion general de MCP servers
