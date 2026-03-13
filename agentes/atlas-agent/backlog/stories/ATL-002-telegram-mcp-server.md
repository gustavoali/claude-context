# ATL-002: Telegram MCP Server

**Points:** 5 | **Priority:** Critical | **Depends on:** Ninguna

## User Story

**As a** agente autonomo (meta-sesion)
**I want** comunicarme con el usuario via Telegram usando MCP tools
**So that** pueda reportar progreso, escalar decisiones, y recibir instrucciones remotas

## Acceptance Criteria

**AC1: Tool send_message**
- Given el MCP server corriendo con bot token valido
- When invoco send_message({ chat_id, text, parse_mode? })
- Then el mensaje se envia al chat de Telegram especificado
- And recibo confirmacion con message_id

**AC2: Tool ask_user (blocking con timeout)**
- Given una decision que necesita input del usuario
- When invoco ask_user({ chat_id, question, options[], timeout_seconds })
- Then se envia mensaje con inline keyboard (botones para cada opcion)
- And la tool queda bloqueada esperando respuesta
- And cuando el usuario toca un boton, retorna la opcion seleccionada
- And si expira el timeout, retorna { timeout: true, default: options[0] }

**AC3: Tool get_updates**
- Given mensajes nuevos del usuario en el chat
- When invoco get_updates({ chat_id, limit? })
- Then retorna los ultimos N mensajes no procesados
- And cada mensaje incluye: text, date, message_id

**AC4: Comandos basicos**
- Given el bot recibiendo mensajes
- When el usuario envia /status, /pause, /resume, /stop
- Then el bot los reconoce como comandos especiales
- And los retorna con metadata { is_command: true, command: 'status' }

**AC5: Rate limiting**
- Given multiples mensajes en rapida sucesion
- When se envian mas de 20 mensajes por minuto
- Then los excedentes se encolan con delay
- And no se pierde ningun mensaje

## Technical Notes

- Stack: Node.js + @modelcontextprotocol/sdk + node-telegram-bot-api (o grammy)
- Transport: stdio (standard MCP)
- Bot token: via env var TELEGRAM_BOT_TOKEN
- Chat ID: via env var TELEGRAM_CHAT_ID (o configurable per-call)
- ask_user usa callback_query de Telegram para inline keyboards
- Considerar long-polling vs webhook para get_updates
- Reutilizar bot token existente del claude-monitor si aplica

## Definition of Done

- [ ] 3 tools funcionales (send_message, ask_user, get_updates)
- [ ] Rate limiting implementado
- [ ] Manejo de comandos especiales
- [ ] Tests con Telegram API mockeada
- [ ] README con setup (bot token, chat ID)
- [ ] package.json con scripts
