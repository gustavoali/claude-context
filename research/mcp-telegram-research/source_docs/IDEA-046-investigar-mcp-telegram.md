# IDEA-046: Investigar MCP Servers existentes para Telegram

**Fecha:** 2026-03-06
**Categoria:** general
**Estado:** Evaluated
**Prioridad:** Alta

---

## Descripcion

Investigar si existen MCP servers mantenidos por la comunidad que provean integracion con Telegram Bot API, para evaluar si conviene adoptar uno existente en lugar de mantener el telegram-mcp custom del proyecto Atlas Agent.

## Motivacion

Atlas Agent (IDEA-043) tiene un telegram-mcp custom con 3 tools (send_message, ask_user, get_updates). Antes de invertir mas en mantenerlo, conviene saber si hay alternativas maduras en el ecosistema MCP.

## Resultado de la Investigacion

### Candidatos encontrados (Bot API, relevantes para nuestro caso)

| Proyecto | Stars | Ultimo push | Transporte | Destaque |
|----------|-------|-------------|------------|----------|
| electricessence/Telegram-Bridge-MCP | 1 | 2026-03-06 | stdio | Mas features (ask/choose/confirm, live status, voice, files) |
| qpd-v/mcp-communicator-telegram | 43 | 2025-01-24 | stdio | Simple (ask_user + notify), sin botones ni timeout |
| guangxiangdebizi/telegram-mcp | 1 | 2025-07-23 | stdio+SSE | CRUD mensajes, fotos, docs |
| siavashdelkhosh81/telegram-bot-mcp-server | 7 | 2025-08-31 | stdio | Messaging + user mgmt |
| IQAIcom/mcp-telegram | 5 | 2026-02-12 | stdio | Channels, forwarding, pinning |
| ParthJadhav/telegram-notify-mcp | 5 | 2026-02-22 | stdio | Solo notificaciones (send) |

Tambien encontrados 3 servers MTProto (cuenta personal, no bot): chaindead (292 stars), chigwell (762 stars), sparfenyuk (172 stars). Descartados por no usar Bot API.

### Comparacion de features criticas

| Feature | Nuestro custom | electricessence (mejor candidato) | qpd-v (#2) |
|---------|---------------|-----------------------------------|-------------|
| Send message | Si | Si + severidad + MarkdownV2 | Si |
| Ask con botones inline (blocking) | Si | Si (choose 2-8 botones + ask texto + confirm yes/no) | No (solo reply texto) |
| Read/poll mensajes | Si | Si (get_updates, wait_for_message) | No |
| Rate limiting | Si (20 msg/min) | No | No |
| Timeout configurable | Si (300s) | Si | No (espera infinito) |
| Command detection | Si | Si (set_commands) | No |
| Lazy bot init | Si | No | No |
| Files/fotos/voice | No | Si (+ Whisper transcription) | Si (send_file) |
| Live status updates | No | Si (update_status, checklist in-place) | No |
| Edit/delete messages | No | Si | No |

### Recomendacion: MANTENER nuestra implementacion custom

Razones:
1. **Ningun candidato es drop-in** para nuestras 3 tools exactas con la simplicidad necesaria
2. **electricessence es superior en features** pero mucho mas complejo (~incluye Whisper, TTS, file mgmt) y es pre-release con 1 star
3. **Nuestra impl es ~200 LOC**, controlada, con rate limiting y timeout - exactamente lo que Atlas necesita
4. **Riesgo de dependencia**: todos los candidatos Bot API tienen baja adopcion (1-43 stars)

### Accion futura

Si necesitamos features avanzadas (voice, files, live status updates), evaluar integrar o contribuir a `electricessence/Telegram-Bridge-MCP` en lugar de construirlas desde cero.

## Proyectos Relacionados

- Atlas Agent (C:/agents/atlas-agent) - consumer principal
- IDEA-043: Agente autonomo sobre Orchestrator con Telegram
- IDEA-012: Investigar MCP servers en general

---

## Historial

| Fecha | Evento |
|-------|--------|
| 2026-03-06 | Idea capturada, investigacion en background |
| 2026-03-06 | Investigacion completada. Resultado: mantener custom, monitorear electricessence |
