# Product Backlog - Ecosystem Improvements
**Version:** 1.0 | **Fecha:** 2026-03-05
**Scope:** Mejoras al ecosistema derivadas de AI SDK Provider (IDEA-044) + Agente Autonomo (IDEA-043)

---

## Resumen

| Metrica | Valor |
|---------|-------|
| Epics | 3 |
| Historias | 16 |
| Puntos totales | 89 |
| MVP | 21 pts (ECO-001 a ECO-005) |

## Vision

Evolucionar el ecosistema de un conjunto de herramientas MCP operadas manualmente a una plataforma con capacidad de ejecucion autonoma, UI web con streaming, y testing robusto de MCP servers. El usuario pasa de coordinar sesiones a supervisar un agente que coordina por el.

---

## Epics

| Epic | Nombre | Historias | Puntos | Iniciativa |
|------|--------|-----------|--------|------------|
| EPIC-001 | AI SDK Integration | ECO-001 a ECO-005 | 21 | IDEA-044 (M1, M2, M3) |
| EPIC-002 | Monitor Enhancement | ECO-006 a ECO-008 | 16 | IDEA-044 (M4) |
| EPIC-003 | Autonomous Agent | ECO-009 a ECO-016 | 52 | IDEA-043 |

---

## Pendientes (con detalle)

---

### EPIC-001: AI SDK Integration

---

### ECO-001: Mid-session message injection en Orchestrator
**Points:** 5 | **Priority:** Critical
**Depends on:** ninguna

**As a** orchestrator consumer (Claude Code, Flutter app, o agente autonomo)
**I want** inyectar mensajes a una sesion en ejecucion entre tool calls
**So that** pueda redirigir, corregir o dar contexto adicional a un agente sin terminar y reiniciar la sesion

#### Acceptance Criteria

**AC1: Enqueue de mensaje durante ejecucion**
- Given una sesion activa ejecutando una instruccion
- When envio un mensaje via `inject_message(sessionId, text)`
- Then el mensaje se encola internamente
- And recibo confirmacion con `{ queued: true, position: N }`

**AC2: Delivery entre tool calls**
- Given un mensaje encolado y la sesion procesando tool calls
- When la sesion termina un tool call y antes de comenzar el siguiente
- Then el mensaje inyectado se entrega al agente como input adicional
- And el agente lo procesa como parte de su contexto activo

**AC3: Multiples mensajes en cola**
- Given 3 mensajes encolados (A, B, C)
- When se entregan entre tool calls
- Then se entregan en orden FIFO
- And cada uno se marca como `delivered` en el estado de la cola

**AC4: Sesion sin ejecucion activa**
- Given una sesion idle (sin instruccion en curso)
- When intento inyectar un mensaje
- Then recibo error `{ error: 'session_idle', hint: 'use send_instruction instead' }`

**AC5: Exposicion en todas las interfaces**
- Given la funcionalidad implementada en session-manager
- When la uso via MCP tool, WebSocket message, o HTTP POST
- Then funciona identicamente en las tres interfaces

#### Technical Notes
- Implementar patron queue+promise inspirado en AI SDK Provider (`streamingInput: 'always'`)
- Requiere que el Agent SDK soporte streaming input. Verificar version minima requerida.
- Nuevo MCP tool: `inject_message`. Nuevo WS event: `session:inject`. Nuevo HTTP endpoint: `POST /api/sessions/:id/inject`
- La cola debe limpiarse al finalizar la instruccion en curso

#### Definition of Done
- [ ] Codigo implementado con queue+promise pattern
- [ ] Unit tests para cola FIFO, delivery, edge cases
- [ ] Integration test E2E con sesion real
- [ ] Documentado en README
- [ ] 0 errors, 0 warnings

---

### ECO-002: MCP server testing in-process con createCustomMcpServer
**Points:** 3 | **Priority:** High
**Depends on:** ninguna

**As a** developer del ecosistema
**I want** ejecutar integration tests de project-admin y sprint-backlog-manager sin levantar procesos stdio
**So that** los tests sean mas rapidos, confiables y no dependan de procesos externos

#### Acceptance Criteria

**AC1: Test harness con MCP in-process para project-admin**
- Given el MCP server de project-admin con sus tool handlers
- When creo un test usando createCustomMcpServer() con las tools registradas
- Then puedo invocar `pa_list_projects`, `pa_get_project`, `pa_project_health` directamente
- And los resultados son identicos a invocar via stdio

**AC2: Test harness para sprint-backlog-manager**
- Given el MCP server de sprint-backlog-manager
- When creo un test usando createCustomMcpServer()
- Then puedo invocar tools de stories, sprints y projects
- And las operaciones CRUD funcionan contra la DB real de test

**AC3: Tiempo de ejecucion**
- Given una suite de 20 integration tests
- When ejecuto via in-process vs via stdio
- Then el tiempo in-process es al menos 3x mas rapido

**AC4: Paquete compartido o template**
- Given el patron de testing in-process
- When otro MCP server del ecosistema necesita tests
- Then existe un template o helper reutilizable documentado

#### Technical Notes
- Usar `createCustomMcpServer()` del package `ai-sdk-provider-claude-code` o implementar equivalente propio
- Las tools se definen con Zod schemas; mapear desde los JSON schemas existentes
- Requiere que los MCP servers expongan sus handlers de forma importable (no solo como entry point stdio)
- Posible refactor: extraer handlers a modulos separados del entry point

#### Definition of Done
- [ ] Test harness funcional para project-admin (min 10 tests)
- [ ] Test harness funcional para sprint-backlog-manager (min 10 tests)
- [ ] Template documentado para nuevos MCP servers
- [ ] CI ejecuta tests in-process

---

### ECO-003: UI Web - Backend con AI SDK streaming
**Points:** 5 | **Priority:** High
**Depends on:** ninguna

**As a** usuario del ecosistema
**I want** un backend que exponga streaming de sesiones del orchestrator via AI SDK
**So that** pueda construir una UI web que muestre ejecucion de agentes en tiempo real

#### Acceptance Criteria

**AC1: Endpoint de streaming**
- Given el backend corriendo
- When hago POST /api/stream con `{ sessionId, instruction }`
- Then recibo un Server-Sent Events stream con tokens, tool calls y tool results
- And cada evento sigue el formato AI SDK StreamPart

**AC2: Integracion con Orchestrator existente**
- Given una sesion creada en el orchestrator
- When la conecto al backend AI SDK
- Then los eventos del Agent SDK se traducen a AI SDK stream parts
- And el sessionId del orchestrator se preserva en providerMetadata

**AC3: Tool call visualization data**
- Given un agente ejecutando tool calls
- When el stream emite eventos de tools
- Then incluye tool-input-start, tool-input-delta, tool-input-end, tool-call, tool-result
- And cada evento tiene toolCallId y toolName

**AC4: Metadata de costos y duracion**
- Given una instruccion completada
- When el stream finaliza
- Then el ultimo evento incluye costUsd, durationMs e inputTokens/outputTokens

#### Technical Notes
- Implementar como modulo dentro del HTTP server existente del orchestrator (puerto 3000) o como servicio separado
- Usar `ai-sdk-provider-claude-code` como dependencia para streaming translation
- Evaluar si conviene wrappear el orchestrator o conectar directamente al Agent SDK
- SSE endpoint compatible con `useChat()` / `useCompletion()` del AI SDK React

#### Definition of Done
- [ ] Endpoint SSE funcional con streaming real
- [ ] Unit tests para traduccion de eventos
- [ ] Documentacion de API
- [ ] Ejemplo de consumo con fetch/EventSource

---

### ECO-004: UI Web - Frontend React con streaming
**Points:** 5 | **Priority:** Medium
**Depends on:** ECO-003

**As a** usuario del ecosistema
**I want** una interfaz web donde ver y controlar sesiones del orchestrator
**So that** no dependa exclusivamente de la app Flutter o del MCP tool para monitorear agentes

#### Acceptance Criteria

**AC1: Lista de sesiones activas**
- Given sesiones corriendo en el orchestrator
- When abro la UI web
- Then veo una lista con sessionId, nombre, estado, duracion y proyecto
- And la lista se actualiza en tiempo real via WebSocket

**AC2: Vista de sesion con streaming**
- Given una sesion activa
- When la selecciono
- Then veo el output del agente en streaming token-by-token
- And los tool calls se muestran con nombre, input y resultado

**AC3: Enviar instruccion**
- Given una sesion seleccionada
- When escribo una instruccion y la envio
- Then el agente la procesa y veo la respuesta en streaming
- And puedo enviar instrucciones sucesivas

**AC4: Crear sesion**
- Given la UI web abierta
- When hago click en "Nueva sesion" y selecciono un directorio de trabajo
- Then se crea una sesion en el orchestrator
- And aparece en la lista de sesiones activas

**AC5: Inyeccion mid-session**
- Given una sesion ejecutando una instruccion
- When escribo un mensaje y lo envio como inyeccion
- Then se encola via inject_message
- And veo confirmacion visual de que fue encolado y luego entregado

#### Technical Notes
- React + Vite + AI SDK React hooks (`useChat`, `useCompletion`)
- Conectar a WebSocket :8765 para lista/estado y a SSE :3000 para streaming
- UI minima: sidebar con sesiones + panel principal con output
- Considerar Tailwind o shadcn/ui para UI rapida

#### Definition of Done
- [ ] UI funcional con lista de sesiones y streaming
- [ ] Creacion e inyeccion de sesiones desde la UI
- [ ] Build produccion sin errores
- [ ] README con instrucciones de setup

---

### ECO-005: Configuracion de MCP servers del ecosistema via AI SDK
**Points:** 3 | **Priority:** Medium
**Depends on:** ECO-003

**As a** usuario de la UI web
**I want** que las sesiones creadas desde la UI tengan acceso a project-admin y sprint-backlog-manager
**So that** los agentes puedan gestionar proyectos y backlogs desde la interfaz web

#### Acceptance Criteria

**AC1: MCP servers preconfigurados**
- Given la UI web creando una sesion
- When la sesion se inicializa
- Then tiene acceso automatico a project-admin y sprint-backlog-manager como MCP servers
- And las tools aparecen con prefijo `mcp__project-admin__` y `mcp__sprint-backlog-manager__`

**AC2: Configuracion editable**
- Given la UI web
- When abro configuracion de sesion
- Then puedo agregar/remover MCP servers disponibles
- And los cambios aplican a nuevas sesiones

#### Technical Notes
- Los MCP servers se configuran como stdio en el orchestrator; exponer esta config en la UI
- Definir preset de "ecosystem MCP servers" con paths hardcoded o configurables via .env

#### Definition of Done
- [ ] Sesiones con MCP servers preconfigurados
- [ ] UI de configuracion funcional
- [ ] Tests de integracion

---

### EPIC-002: Monitor Enhancement

---

### ECO-006: Subagent hierarchy tracking en Monitor Flutter
**Points:** 5 | **Priority:** High
**Depends on:** ninguna

**As a** usuario del monitor Flutter
**I want** visualizar la jerarquia de subagentes cuando un agente spawna Tasks
**So that** entienda la estructura de ejecucion y pueda identificar que subagente esta trabajando en que

#### Acceptance Criteria

**AC1: Deteccion de subagentes**
- Given una sesion con agente que usa Task tool para crear subagentes
- When el orchestrator reporta eventos con parentToolCallId
- Then el monitor construye un arbol de relaciones padre-hijo

**AC2: Visualizacion jerarquica**
- Given un arbol de agentes (raiz -> sub1, sub2; sub1 -> sub1.1)
- When veo la vista de sesion en el monitor
- Then los subagentes se muestran como nodos hijos indentados bajo su padre
- And cada nodo muestra estado (running/completed/error), duracion y tarea

**AC3: Expansion/colapso**
- Given un arbol con 3+ niveles
- When toco un nodo padre
- Then puedo expandir/colapsar sus hijos
- And el estado de expansion se preserva durante la sesion

**AC4: Datos via WebSocket**
- Given el orchestrator emitiendo eventos de sesion
- When un evento incluye parentToolCallId
- Then el monitor lo asocia al agente padre correcto
- And actualiza el arbol en tiempo real

#### Technical Notes
- El AI SDK Provider usa Map (no stack) para Tasks paralelas; replicar en el monitor
- Requiere que el orchestrator exponga parentToolCallId en sus eventos WebSocket
- Posible: nuevo evento WS `session:subagent_started` y `session:subagent_completed`
- Flutter widget: TreeView o custom con AnimatedList

#### Definition of Done
- [ ] Widget de arbol de subagentes funcional
- [ ] Actualizacion en tiempo real via WebSocket
- [ ] Tests de widget
- [ ] Screenshot en README

---

### ECO-007: Tool execution timeline en Monitor
**Points:** 5 | **Priority:** Medium
**Depends on:** ninguna

**As a** usuario del monitor Flutter
**I want** ver un timeline de tool calls ejecutadas por un agente
**So that** entienda que herramientas uso, en que orden, y cuanto tardo cada una

#### Acceptance Criteria

**AC1: Timeline visual**
- Given una sesion con 10+ tool calls completadas
- When abro la vista de timeline
- Then veo cada tool call como un bloque en una linea temporal horizontal
- And cada bloque muestra toolName, duracion y status (success/error)

**AC2: Detalle de tool call**
- Given el timeline visible
- When toco un bloque de tool call
- Then veo un panel con input (truncado a 500 chars) y output (truncado a 500 chars)
- And puedo copiar el contenido completo al clipboard

**AC3: Filtrado por tipo**
- Given un timeline con herramientas variadas (Read, Write, Bash, MCP)
- When filtro por tipo "Bash"
- Then solo veo las tool calls de tipo Bash
- And el timeline se reajusta sin gaps

#### Technical Notes
- Reutilizar datos de eventos WebSocket existentes
- El lifecycle es: tool-input-start -> tool-call -> tool-result/tool-error
- Calcular duracion como delta entre tool-input-start y tool-result
- Considerar CustomPainter para el timeline o paquete timeline_tile

#### Definition of Done
- [ ] Timeline widget funcional
- [ ] Filtrado por tipo de tool
- [ ] Panel de detalle con copy
- [ ] Tests de widget

---

### ECO-008: Notificacion Telegram de subagent completion
**Points:** 6 | **Priority:** Medium
**Depends on:** ECO-006

**As a** usuario remoto
**I want** recibir notificaciones en Telegram cuando un subagente completa o falla
**So that** pueda monitorear ejecuciones largas sin tener la app abierta

#### Acceptance Criteria

**AC1: Notificacion de completion**
- Given una sesion con subagentes monitoreada via Telegram
- When un subagente completa exitosamente
- Then recibo mensaje con: nombre del agente, tarea, duracion, resultado resumido

**AC2: Notificacion de error**
- Given un subagente que falla
- When el error ocurre
- Then recibo mensaje con: nombre del agente, tarea, mensaje de error
- And el mensaje incluye un boton inline "Reintentar" y "Ignorar"

**AC3: Configuracion de verbosidad**
- Given la integracion Telegram activa
- When configuro verbosidad en "summary"
- Then solo recibo notificacion al completar la sesion raiz (no cada subagente)
- And cuando configuro "verbose" recibo cada subagente

#### Technical Notes
- Extender la integracion Telegram existente en claude-monitor
- Reutilizar el arbol de subagentes de ECO-006
- Rate limiting: maximo 1 mensaje por segundo para evitar flood

#### Definition of Done
- [ ] Notificaciones Telegram funcionales
- [ ] Configuracion de verbosidad
- [ ] Rate limiting implementado
- [ ] Tests de integracion

---

### EPIC-003: Autonomous Agent

---

### ECO-009: Session lifecycle management autonomo
**Points:** 5 | **Priority:** Critical
**Depends on:** ninguna

**As a** agente autonomo
**I want** gestionar el ciclo de vida completo de sesiones del orchestrator
**So that** pueda crear, monitorear, pausar y reanudar sesiones sin intervencion humana

#### Acceptance Criteria

**AC1: Creacion de sesion con contexto completo**
- Given una tarea asignada (historia del backlog)
- When el agente autonomo crea una sesion
- Then la sesion se crea con: cwd correcto, nombre descriptivo, MCP servers relevantes
- And la instruccion inicial incluye contexto del proyecto (CLAUDE.md) y de la historia (AC, tech notes)

**AC2: Monitoreo de estado**
- Given una sesion en ejecucion
- When el agente autonomo la monitorea
- Then detecta: progreso (output parcial), bloqueo (sin output por >5 min), error, o completion
- And registra el estado en un log interno

**AC3: Reintento automatico**
- Given una sesion que falla con error recuperable (timeout, rate limit)
- When el agente detecta el error
- Then reintenta con backoff exponencial (30s, 1m, 2m, max 3 intentos)
- And si los 3 intentos fallan, escala al usuario

**AC4: Cleanup de sesiones**
- Given una sesion completada o fallida definitivamente
- When el agente la procesa
- Then cierra la sesion via end_session
- And registra el resultado (exito/fallo, duracion, output resumido)

#### Technical Notes
- Implementar como proceso Node.js standalone que consume la API del orchestrator
- Usar WebSocket para monitoreo en tiempo real y HTTP para operaciones CRUD
- Patron: event loop con polling cada 10s para sesiones activas
- Mantener estado en memoria con persistencia periodica a disco (JSON)

#### Definition of Done
- [ ] Lifecycle completo funcional (create, monitor, retry, cleanup)
- [ ] Tests unitarios para cada fase
- [ ] Log de operaciones consultable
- [ ] Documentacion de arquitectura

---

### ECO-010: Sprint backlog integration
**Points:** 3 | **Priority:** Critical
**Depends on:** ECO-009

**As a** agente autonomo
**I want** leer historias del sprint activo y asignarlas a sesiones
**So that** ejecute el trabajo planificado automaticamente

#### Acceptance Criteria

**AC1: Lectura del sprint activo**
- Given un sprint activo en sprint-backlog-manager con historias en estado "To Do"
- When el agente autonomo consulta el backlog
- Then obtiene la lista ordenada por prioridad
- And cada historia incluye: ID, titulo, puntos, AC, dependencias

**AC2: Asignacion a sesion**
- Given una historia seleccionada para ejecucion
- When el agente crea una sesion para ella
- Then la historia se marca como "In Progress" en el backlog
- And la sesion se registra con assign_story en el orchestrator

**AC3: Actualizacion al completar**
- Given una sesion que completa exitosamente la historia
- When el agente procesa el resultado
- Then la historia se marca como "Done" en el backlog
- And se registra fecha de completion y resultado

**AC4: Respeto de dependencias**
- Given historia B que depende de historia A
- When A no esta completada
- Then el agente NO inicia B
- And B permanece en la cola hasta que A se complete

#### Technical Notes
- Usar MCP client de sprint-backlog-manager (ya existe backlog-client.js en orchestrator)
- Mapear estados del backlog: To Do -> In Progress -> Done / Blocked
- Secuenciacion: topological sort de dependencias antes de asignar

#### Definition of Done
- [ ] Lectura y filtrado de historias funcional
- [ ] Asignacion y actualizacion de estado bidireccional
- [ ] Respeto de dependencias verificado con tests
- [ ] Integration test con backlog real

---

### ECO-011: Multi-project coordination
**Points:** 8 | **Priority:** High
**Depends on:** ECO-009, ECO-010

**As a** agente autonomo
**I want** coordinar trabajo entre multiples proyectos del ecosistema
**So that** cambios que afectan a varios proyectos se ejecuten en el orden correcto

#### Acceptance Criteria

**AC1: Deteccion de proyecto por historia**
- Given una historia del backlog con campo "project" o tag de proyecto
- When el agente la procesa
- Then determina el cwd correcto usando project-admin (pa_get_project)
- And configura la sesion con el path del proyecto

**AC2: Sesiones paralelas en proyectos independientes**
- Given historias A (proyecto X) y B (proyecto Y) sin dependencia entre si
- When el agente las ejecuta
- Then crea sesiones en paralelo (respetando MAX_CONCURRENT_SESSIONS)
- And ambas progresan simultaneamente

**AC3: Secuenciacion cross-project**
- Given historia C (proyecto X) que depende de historia D (proyecto Y)
- When D se completa exitosamente
- Then el agente inicia C automaticamente
- And la instruccion de C incluye contexto del resultado de D

**AC4: Limite de concurrencia**
- Given 8 historias listas y MAX_CONCURRENT_SESSIONS=5
- When el agente las procesa
- Then ejecuta maximo 5 en paralelo
- And las restantes 3 se encolan y se lanzan cuando hay slot libre

#### Technical Notes
- Usar project-admin para resolver proyecto -> path
- Usar relaciones de project-admin (pa_get_relationships) para inferir dependencias cross-project
- Cola de prioridad: Critical > High > Medium > Low, con dependency awareness
- Circuit breaker: si un proyecto falla 3 veces seguidas, pausar ese proyecto y notificar

#### Definition of Done
- [ ] Coordinacion multi-proyecto funcional
- [ ] Paralelismo con respeto de limites
- [ ] Secuenciacion cross-project verificada
- [ ] Circuit breaker implementado
- [ ] Tests con 3+ proyectos simultaneos

---

### ECO-012: Deteccion de bloqueos y auto-recovery
**Points:** 5 | **Priority:** High
**Depends on:** ECO-009

**As a** agente autonomo
**I want** detectar cuando una sesion esta bloqueada y tomar accion correctiva
**So that** no se desperdicien recursos en sesiones estancadas

#### Acceptance Criteria

**AC1: Deteccion por inactividad**
- Given una sesion sin output nuevo por mas de 5 minutos
- When el agente evalua su estado
- Then la marca como "possibly_stuck"
- And envia un inject_message preguntando "Are you stuck? Report your current status."

**AC2: Deteccion por loop**
- Given una sesion que repite el mismo tool call 3+ veces con el mismo input
- When el agente detecta el patron
- Then la marca como "in_loop"
- And envia inject_message con "You appear to be in a loop. Try a different approach."

**AC3: Auto-recovery fallido**
- Given una sesion marcada como stuck que no responde al inject_message en 2 minutos
- When el timeout expira
- Then el agente termina la sesion
- And la reintenta con instruccion reformulada que incluye el contexto del bloqueo

**AC4: Escalacion al usuario**
- Given una sesion que falla 2 veces por el mismo motivo
- When el segundo reintento falla
- Then el agente escala al usuario via Telegram con: historia, error, intentos realizados
- And pausa la historia hasta recibir respuesta

#### Technical Notes
- Requiere ECO-001 (inject_message) para la comunicacion con sesiones activas
- Heuristicas de deteccion: timeout, loop detection (hash de tool calls), error patterns
- Estado de sesiones: active -> possibly_stuck -> recovering -> [active | failed | escalated]
- Log de recovery attempts para post-mortem

#### Definition of Done
- [ ] Deteccion de inactividad funcional
- [ ] Deteccion de loops funcional
- [ ] Auto-recovery con reintento
- [ ] Escalacion cuando falla recovery
- [ ] Tests para cada tipo de bloqueo

---

### ECO-013: Escalacion y comunicacion via Telegram
**Points:** 5 | **Priority:** Critical
**Depends on:** ECO-009

**As a** usuario supervisando el agente autonomo
**I want** recibir notificaciones y poder responder via Telegram
**So that** pueda supervisar y tomar decisiones sin abrir la computadora

#### Acceptance Criteria

**AC1: Reporte de progreso periodico**
- Given el agente autonomo ejecutando un sprint
- When pasan 30 minutos de actividad
- Then recibo resumen en Telegram: historias completadas, en progreso, bloqueadas

**AC2: Escalacion de decision**
- Given una situacion que requiere decision del usuario (error ambiguo, dependencia circular, conflicto)
- When el agente escala
- Then recibo mensaje con: contexto, opciones (botones inline), y deadline para responder
- And si no respondo en 15 min, el agente toma la opcion conservadora (pausar)

**AC3: Respuesta del usuario**
- Given un mensaje de escalacion con opciones A, B, C
- When toco la opcion B
- Then el agente recibe la decision y continua con la opcion elegida
- And confirma la accion tomada con un mensaje de seguimiento

**AC4: Comando de status**
- Given el agente corriendo
- When envio "/status" via Telegram
- Then recibo: sesiones activas, historias en cola, errores recientes, metricas de la sesion

**AC5: Comando de pausa/resume**
- Given el agente corriendo
- When envio "/pause" via Telegram
- Then el agente no inicia nuevas sesiones (las activas continuan hasta completar)
- And cuando envio "/resume", retoma la cola

#### Technical Notes
- Reutilizar integracion Telegram existente de claude-monitor (bot token, chat_id)
- Inline keyboards de Telegram para opciones de decision
- Comando handling: /status, /pause, /resume, /abort, /history
- Persistir conversacion de escalacion para contexto

#### Definition of Done
- [ ] Reportes periodicos funcionales
- [ ] Escalacion con inline keyboards
- [ ] Respuesta del usuario procesada correctamente
- [ ] Comandos /status, /pause, /resume implementados
- [ ] Tests de integracion con Telegram API mock

---

### ECO-014: Planning engine para seleccion de historias
**Points:** 8 | **Priority:** High
**Depends on:** ECO-010

**As a** agente autonomo
**I want** decidir inteligentemente que historias ejecutar y en que orden
**So that** maximice el throughput y respete restricciones de dependencias y recursos

#### Acceptance Criteria

**AC1: Priorizacion por RICE score**
- Given historias con prioridades Critical, High, Medium, Low
- When el agente construye el plan de ejecucion
- Then ordena por: Critical primero, luego High, luego por story points ascendente dentro de cada nivel

**AC2: Dependency-aware scheduling**
- Given un grafo de dependencias entre historias
- When el agente planifica
- Then genera un plan topologicamente ordenado
- And detecta y reporta dependencias circulares como error

**AC3: Resource-aware batching**
- Given 10 historias listas y MAX_CONCURRENT_SESSIONS=3
- When el agente planifica
- Then agrupa en batches de 3 maximizando paralelismo
- And dentro de cada batch, las historias son independientes entre si

**AC4: Re-planning ante cambios**
- Given un plan en ejecucion
- When una historia falla o se agrega una historia Critical al backlog
- Then el agente re-planifica el resto del sprint
- And la historia Critical se inserta en el siguiente batch disponible

**AC5: Plan visible**
- Given un plan calculado
- When consulto via /plan en Telegram o via API
- Then veo: batch actual, batches pendientes, estimacion de tiempo restante

#### Technical Notes
- Algoritmo: topological sort + greedy bin packing por concurrencia
- Re-planning: event-driven (on completion, on failure, on new story)
- Estimacion de tiempo: promedio historico de puntos -> horas (inicialmente 1pt = 1h)
- Persistir plan en disco para recovery ante restart

#### Definition of Done
- [ ] Algoritmo de scheduling implementado
- [ ] Dependency detection y topological sort
- [ ] Re-planning ante cambios
- [ ] API y Telegram para consultar plan
- [ ] Tests con grafos de dependencias variados

---

### ECO-015: Context assembly para instrucciones de agente
**Points:** 5 | **Priority:** High
**Depends on:** ECO-010

**As a** agente autonomo
**I want** construir instrucciones ricas en contexto para cada sesion
**So that** el agente ejecutor tenga toda la informacion necesaria sin buscarla

#### Acceptance Criteria

**AC1: Contexto del proyecto**
- Given una historia asignada al proyecto X
- When el agente construye la instruccion
- Then incluye: CLAUDE.md del proyecto, stack tecnologico, comandos de build/test

**AC2: Contexto de la historia**
- Given una historia con AC, tech notes y dependencias
- When el agente construye la instruccion
- Then incluye: titulo, acceptance criteria completos, notas tecnicas, archivos a modificar

**AC3: Contexto de historias previas**
- Given historia B que depende de historia A (completada)
- When el agente construye la instruccion de B
- Then incluye: resumen del resultado de A, archivos creados/modificados por A

**AC4: Instruccion accionable**
- Given todo el contexto ensamblado
- When el agente formatea la instruccion
- Then sigue el template: Objetivo > Contexto > Specs > Restricciones > Criterios de exito
- And la instruccion no supera 4000 tokens (para dejar espacio al agente)

#### Technical Notes
- Leer CLAUDE.md del proyecto via filesystem (el agente tiene acceso al disco)
- Leer historia del backlog via sprint-backlog-manager MCP
- Template de instruccion alineado con metodologia general (directiva 1: contexto completo al delegar)
- Truncar contexto si excede limite; priorizar AC > tech notes > proyecto context

#### Definition of Done
- [ ] Assembly de contexto funcional para los 3 niveles
- [ ] Template de instruccion documentado
- [ ] Truncacion inteligente implementada
- [ ] Tests con historias reales del ecosistema

---

### ECO-016: Persistencia y recovery del agente autonomo
**Points:** 5 | **Priority:** High
**Depends on:** ECO-009, ECO-014

**As a** operador del ecosistema
**I want** que el agente autonomo persista su estado y se recupere de reinicios
**So that** un crash o reinicio no pierda el progreso del sprint

#### Acceptance Criteria

**AC1: Persistencia de estado**
- Given el agente autonomo ejecutando un sprint
- When se guarda estado (cada 30 segundos)
- Then persiste a disco: plan actual, sesiones activas, cola de historias, resultados parciales

**AC2: Recovery post-crash**
- Given el agente se reinicia despues de un crash
- When carga el estado persistido
- Then identifica: sesiones que aun corren en el orchestrator, historias en progreso
- And retoma desde el ultimo estado conocido sin duplicar trabajo

**AC3: Sesiones huerfanas**
- Given sesiones del orchestrator que corrieron durante el crash del agente
- When el agente se recupera
- Then consulta el orchestrator por sesiones activas
- And las reconcilia con su estado interno (adopt o cleanup)

**AC4: Graceful shutdown**
- Given un shutdown solicitado (SIGTERM)
- When el agente lo recibe
- Then completa las sesiones activas (o las pausa con inject_message)
- And persiste estado final antes de cerrar

#### Technical Notes
- Estado en JSON file: `~/.autonomous-agent/state.json`
- Lock file para evitar multiples instancias
- Reconciliacion: comparar sesiones en estado interno vs orchestrator (list_sessions)
- Graceful shutdown: signal handler para SIGTERM/SIGINT

#### Definition of Done
- [ ] Persistencia periodica funcional
- [ ] Recovery post-crash verificado
- [ ] Reconciliacion de sesiones huerfanas
- [ ] Graceful shutdown con signal handling
- [ ] Tests de crash recovery (kill -9 + restart)

---

## Completadas (indice)

| ID | Titulo | Puntos | Fecha | Detalle |
|----|--------|--------|-------|---------|
| - | - | - | - | - |

---

## ID Registry

| Rango | Estado |
|-------|--------|
| ECO-001 a ECO-016 | Asignados |
| ECO-017+ | Disponible |
Proximo ID: ECO-017

---

## Orden de Implementacion Recomendado

### Fase 1 - Foundations (MVP) - 21 pts

```
Batch 1 (paralelo, sin dependencias):
  ECO-001: Mid-session injection          (5 pts) - Habilita auto-recovery
  ECO-002: MCP testing in-process         (3 pts) - Mejora calidad del ecosistema
  ECO-009: Session lifecycle autonomo     (5 pts) - Core del agente

Batch 2 (depende de batch 1):
  ECO-003: UI Web backend streaming       (5 pts) - Depende de nada, pero se beneficia de ECO-001
  ECO-010: Sprint backlog integration     (3 pts) - Depende de ECO-009
```

**Value delivery:** Con esta fase se obtiene:
- Agente autonomo basico que toma historias del backlog y las ejecuta
- Testing robusto de MCP servers
- Backend de streaming para futura UI
- Capacidad de inyectar mensajes a sesiones en ejecucion

### Fase 2 - Intelligence (28 pts)

```
Batch 3 (paralelo):
  ECO-012: Deteccion de bloqueos         (5 pts) - Depende de ECO-001, ECO-009
  ECO-013: Escalacion Telegram           (5 pts) - Depende de ECO-009
  ECO-015: Context assembly              (5 pts) - Depende de ECO-010
  ECO-006: Subagent tracking monitor     (5 pts) - Independiente

Batch 4 (depende de batch 3):
  ECO-014: Planning engine               (8 pts) - Depende de ECO-010
```

**Value delivery:** El agente se vuelve inteligente: detecta bloqueos, escala, construye contexto rico, y planifica.

### Fase 3 - Polish (26 pts)

```
Batch 5 (paralelo):
  ECO-004: UI Web frontend React         (5 pts) - Depende de ECO-003
  ECO-011: Multi-project coordination    (8 pts) - Depende de ECO-009, ECO-010
  ECO-016: Persistencia y recovery       (5 pts) - Depende de ECO-009, ECO-014

Batch 6:
  ECO-005: MCP servers en UI             (3 pts) - Depende de ECO-003
  ECO-007: Tool timeline monitor         (5 pts) - Independiente

Batch 7:
  ECO-008: Telegram subagent notif       (6 pts) - Depende de ECO-006
```

**Value delivery:** Ecosistema completo con UI web, coordinacion multi-proyecto, y recovery.

---

## MVP Definition

**MVP = Fase 1 (21 puntos, ~5 historias)**

El minimo para obtener valor es:

1. **ECO-001** (Mid-session injection): Sin esto, el agente autonomo no puede comunicarse con sesiones activas para recovery.
2. **ECO-009** (Session lifecycle): Core del agente. Sin lifecycle management no hay agente.
3. **ECO-010** (Backlog integration): Sin backlog, el agente no sabe que ejecutar.
4. **ECO-002** (MCP testing): Mejora inmediata de calidad; payback rapido.
5. **ECO-003** (UI backend streaming): Habilita la futura UI y es independiente.

**Con el MVP, el usuario puede:**
- Decirle al agente "ejecuta el sprint" y el agente toma historias del backlog, crea sesiones, las ejecuta, y actualiza el backlog.
- Si una sesion se atasca, el agente inyecta mensajes para destrabarla.
- Los MCP servers tienen tests in-process mas rapidos y confiables.
- Hay un backend listo para construir la UI web encima.

**Sin el MVP, el usuario sigue:**
- Creando sesiones manualmente via MCP tool o Flutter app.
- Monitoreando manualmente si una sesion se bloqueo.
- Sin tests in-process para MCP servers.

---

## RICE Analysis (top 5)

| ID | Reach | Impact | Confidence | Effort | RICE | Prioridad |
|----|-------|--------|------------|--------|------|-----------|
| ECO-009 | 5 | 3 | 80% | 2 | 6.0 | Critical |
| ECO-010 | 5 | 2 | 100% | 1 | 10.0 | Critical |
| ECO-001 | 4 | 2 | 80% | 2 | 3.2 | Critical |
| ECO-013 | 4 | 2 | 80% | 2 | 3.2 | Critical |
| ECO-002 | 3 | 2 | 100% | 1 | 6.0 | High |
