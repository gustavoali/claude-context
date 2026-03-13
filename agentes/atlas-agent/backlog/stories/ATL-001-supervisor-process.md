# ATL-001: Supervisor Process (spawn + watchdog)

**Points:** 3 | **Priority:** Critical | **Depends on:** Ninguna

## User Story

**As a** operador del ecosistema
**I want** un proceso supervisor que lance y mantenga viva la meta-sesion de Atlas
**So that** el agente autonomo se recupere automaticamente de crashes sin intervencion manual

## Acceptance Criteria

**AC1: Spawn de meta-sesion**
- Given el supervisor iniciado con configuracion valida
- When lanza la meta-sesion
- Then ejecuta Claude Code CLI con: system prompt, MCP servers configurados, y cwd correcto
- And la meta-sesion comienza su loop de supervision

**AC2: Watchdog y restart**
- Given la meta-sesion corriendo
- When el proceso de Claude Code termina inesperadamente (exit code != 0)
- Then el supervisor espera 5 segundos y relanza la meta-sesion
- And registra el evento en el log con timestamp y exit code

**AC3: Backoff exponencial**
- Given 3 crashes consecutivos en menos de 5 minutos
- When el supervisor detecta el patron
- Then incrementa el delay entre restarts (5s, 15s, 45s, max 2min)
- And envia alerta (si Telegram esta disponible)

**AC4: Graceful shutdown**
- Given el supervisor recibiendo SIGTERM
- When procesa la senal
- Then envia SIGTERM a la meta-sesion
- And espera hasta 30 segundos para que termine
- And registra el shutdown en el log

**AC5: Configuracion via env/args**
- Given el supervisor
- When se lanza con variables de entorno
- Then lee: ATLAS_SYSTEM_PROMPT_PATH, ATLAS_MCP_CONFIG, ATLAS_LOG_LEVEL
- And aplica defaults sensatos si no se proporcionan

## Technical Notes

- Script Node.js de ~100 lineas usando child_process.spawn
- Lanza: `claude --print --output-format stream-json -p "$(cat system-prompt.md)"`
- O alternativamente via Agent SDK: `query({ prompt: systemPrompt, options: { ... } })`
- Evaluar cual de los dos modos es mas robusto para long-running sessions
- Log a stdout con formato estructurado (JSON lines)
- PID file para evitar multiples instancias

## Definition of Done

- [ ] Supervisor lanza meta-sesion correctamente
- [ ] Restart automatico ante crash con backoff
- [ ] Graceful shutdown con SIGTERM
- [ ] Log estructurado
- [ ] Tests unitarios
- [ ] README con instrucciones de uso
