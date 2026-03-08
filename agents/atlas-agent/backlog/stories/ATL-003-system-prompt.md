# ATL-003: System Prompt de Coordinador

**Points:** 5 | **Priority:** Critical | **Depends on:** Ninguna

## User Story

**As a** meta-sesion de Claude Code
**I want** un system prompt que defina mi comportamiento como coordinador autonomo
**So that** ejecute sprints de forma consistente, segura y con escalacion apropiada

## Acceptance Criteria

**AC1: Loop de supervision definido**
- Given el system prompt cargado
- When la meta-sesion arranca
- Then sigue el loop: leer backlog -> crear sesiones -> monitorear -> reportar -> repetir
- And el loop es explicito en el prompt (no inferido)

**AC2: Reglas de autonomia claras**
- Given una situacion que requiere decision
- When el agente evalua si puede actuar solo
- Then sigue la tabla de autonomia:
  - Puede solo: crear sesion, enviar instruccion, reintentar error conocido
  - Debe consultar: merge, push, cambio de scope, error desconocido, gasto > threshold
  - Nunca: eliminar archivos de produccion, push a main, cambiar configuracion de otros proyectos

**AC3: Formato de reportes estandarizado**
- Given un reporte periodico (cada 30 min)
- When el agente lo construye
- Then sigue el formato: sesiones activas, historias completadas/en progreso/bloqueadas, errores
- And es conciso (max 500 chars para Telegram)

**AC4: Escalacion con contexto**
- Given una escalacion al usuario
- When el agente la formula
- Then incluye: que paso, que intento, opciones disponibles, su recomendacion
- And presenta opciones como botones de Telegram (via ask_user)

**AC5: Limites de recursos**
- Given el prompt
- When el agente opera
- Then respeta: max N sesiones concurrentes, presupuesto de tokens por sesion, timeout por historia
- And estos limites son configurables via variables en el prompt

## Technical Notes

- Archivo markdown en prompts/coordinator.md
- Variables configurables: MAX_SESSIONS, TOKEN_BUDGET, REPORT_INTERVAL, ESCALATION_TIMEOUT
- Incluir ejemplos de cada tipo de situacion (happy path, error, bloqueo, escalacion)
- El prompt debe ser iterable: versionarlo y ajustar basado en experiencia
- Considerar incluir la metodologia general (directiva 1: contexto completo al delegar)
- Referencia: system prompts de Devin, OpenHands, SWE-agent como inspiracion

## Definition of Done

- [ ] Prompt completo con loop, reglas, formatos, limites
- [ ] Tabla de autonomia explicita
- [ ] Ejemplos de cada situacion
- [ ] Versionado (v1.0)
- [ ] Review por el usuario antes de usar en produccion
