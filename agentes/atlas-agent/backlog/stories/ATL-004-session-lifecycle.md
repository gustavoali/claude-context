# ATL-004: Session Lifecycle Management

**Points:** 5 | **Priority:** Critical | **Depends on:** ECO-001 (orchestrator)

## User Story

**As a** agente autonomo
**I want** gestionar el ciclo de vida completo de sesiones del orchestrator
**So that** pueda crear, monitorear, reintentar y cerrar sesiones sin intervencion humana

## Acceptance Criteria

**AC1: Creacion de sesion con contexto completo**
- Given una tarea asignada (historia del backlog)
- When el agente crea una sesion
- Then usa create_session con: cwd del proyecto (via project-admin), nombre descriptivo
- And la instruccion inicial incluye contexto del proyecto y de la historia

**AC2: Monitoreo de estado**
- Given una sesion en ejecucion
- When el agente la monitorea (cada 30s via list_sessions/get_session)
- Then detecta: progreso, bloqueo (sin output >5 min), error, completion
- And registra el estado internamente

**AC3: Reintento automatico**
- Given una sesion que falla con error recuperable (timeout, rate limit)
- When el agente detecta el error
- Then reintenta con backoff (30s, 1m, 2m, max 3 intentos)
- And si los 3 intentos fallan, escala al usuario via Telegram

**AC4: Cleanup de sesiones**
- Given una sesion completada o fallida definitivamente
- When el agente la procesa
- Then cierra via end_session
- And registra resultado (exito/fallo, duracion, output resumido)

**AC5: Mid-session intervention**
- Given una sesion activa que necesita correccion
- When el agente decide intervenir
- Then usa inject_message (ECO-001) para enviar instrucciones adicionales
- And monitorea si la sesion responde positivamente

## Technical Notes

- El agente usa los MCP tools existentes del orchestrator: create_session, send_instruction, list_sessions, get_session, inject_message, end_session
- NO escribir logica imperativa de lifecycle - el system prompt de ATL-003 guia al agente
- El "monitoreo cada 30s" se implementa como instruccion en el system prompt, no como timer en codigo
- La meta-sesion de Claude Code hace tool calls para monitorear; no hay polling programatico
- ECO-001 es BLOQUEANTE: sin inject_message, AC5 no es posible

## Definition of Done

- [ ] Agente crea sesiones con contexto completo
- [ ] Monitoreo detecta estados correctamente
- [ ] Reintento con backoff funcional
- [ ] Cleanup automatico
- [ ] Mid-session intervention via inject_message
- [ ] Tests E2E con orchestrator real
