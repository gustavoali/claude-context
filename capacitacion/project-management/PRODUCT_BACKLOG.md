# Backlog - Project Management Tools
**Version:** 1.0 | **Actualizacion:** 2026-03-21

## Resumen
| Metrica | Valor |
|---------|-------|
| Total Stories | 16 |
| Total Points | 26 |
| Epics | 5 |
| Completadas | 0 |

## Vision
Dominar herramientas de gestion de proyectos de forma practica, comenzando por Trello y expandiendo a otras plataformas. Cada fase construye sobre la anterior, priorizando hands-on sobre teoria.

## DoD Global (aplica a todas las stories)
- [ ] Actividad completada hands-on (no solo lectura)
- [ ] Evidencia documentada (screenshot o log)

## Epics
| Epic | Historias | Puntos | Status |
|------|-----------|--------|--------|
| EPIC-001: Trello Fundamentos | PM-001 a PM-004 | 5 | Pendiente |
| EPIC-002: Trello Intermedio | PM-005 a PM-008 | 6 | Pendiente |
| EPIC-003: Trello Automatizacion | PM-009 a PM-011 | 6 | Pendiente |
| EPIC-004: Trello API (Opcional) | PM-012 a PM-014 | 7 | Pendiente |
| EPIC-005: Expansion Otras Herramientas | PM-015 a PM-016 | 2 | Pendiente |

## Pendientes (con detalle)

### EPIC-001: Trello Fundamentos

### PM-001: Crear cuenta y explorar interfaz de Trello
**Points:** 1 | **Priority:** Critical | **Epic:** EPIC-001
**As a** learner **I want** crear mi cuenta en Trello y familiarizarme con la interfaz **So that** tenga acceso a la plataforma y entienda su estructura basica.
**AC1:** Given que no tengo cuenta, When accedo a trello.com y completo el registro, Then tengo cuenta activa y puedo hacer login.
**AC2:** Given que estoy logueado, When recorro la interfaz, Then puedo identificar y describir: workspace, boards, sidebar y menu superior.
**Notas:** Registrarse con Google o email. Version gratuita suficiente.
**Evidencia:** Screenshot de pantalla principal anotado con elementos identificados.

### PM-002: Crear board con listas basicas
**Points:** 1 | **Priority:** Critical | **Epic:** EPIC-001
**As a** learner **I want** crear un board con la estructura clasica de Kanban **So that** entienda el flujo basico de trabajo en Trello.
**AC1:** Given que estoy en mi workspace, When creo un nuevo board, Then aparece con nombre descriptivo.
**AC2:** Given que tengo un board nuevo, When creo listas "To Do", "In Progress" y "Done", Then se muestran de izquierda a derecha en ese orden.
**Notas:** Usar tema de proyecto real o ficticio. Probar cambiar fondo del board.
**Evidencia:** Screenshot del board con las 3 listas.

### PM-003: Crear cards y moverlas entre listas
**Points:** 1 | **Priority:** Critical | **Epic:** EPIC-001
**As a** learner **I want** crear tarjetas y moverlas entre listas **So that** entienda el flujo de trabajo Kanban.
**AC1:** Given que tengo listas, When creo 3+ cards en "To Do", Then cada card aparece con su titulo visible.
**AC2:** Given cards en "To Do", When arrastro una a "In Progress", Then se mueve y desaparece de la lista anterior.
**AC3:** Given card en "In Progress", When la muevo a "Done", Then refleja el flujo completo To Do -> In Progress -> Done.
**Notas:** Probar drag & drop y menu contextual.
**Evidencia:** Screenshot mostrando cards en diferentes listas.

### PM-004: Enriquecer cards con descripcion, checklist y due dates
**Points:** 2 | **Priority:** Critical | **Epic:** EPIC-001
**As a** learner **I want** agregar detalles a tarjetas **So that** pueda gestionar tareas con informacion completa.
**AC1:** Given que abro una card, When agrego descripcion Markdown, Then se muestra formateada al guardar.
**AC2:** Given que edito una card, When agrego checklist con 3+ items, Then puedo marcar/desmarcar y veo progreso (ej: 1/3).
**AC3:** Given que edito una card, When asigno due date, Then la fecha aparece en la card con indicador visual.
**AC4:** Given due date vencida, When miro el board, Then la card muestra indicador rojo.
**Notas:** Markdown basico en descripciones. Due dates: proximo (amarillo), vencido (rojo), completado (verde).
**Evidencia:** Screenshot de card con descripcion + checklist + due date.

### EPIC-002: Trello Intermedio

### PM-005: Usar labels para categorizar cards
**Points:** 1 | **Priority:** High | **Epic:** EPIC-002
**As a** learner **I want** categorizar tarjetas con etiquetas de colores **So that** pueda filtrar y visualizar el tipo de cada tarea.
**AC1:** Given que estoy en un board, When creo 3+ labels con nombres y colores, Then estan disponibles para asignar.
**AC2:** Given labels definidos, When asigno 1-2 a una card, Then los colores se muestran en la card del board.
**AC3:** Given cards con labels, When filtro por un label, Then solo se muestran las cards con ese label.
**Notas:** Labels son por board. Shortcut "F" para filtro rapido.
**Evidencia:** Screenshot del board filtrado por label.

### PM-006: Asignar members y usar comments
**Points:** 2 | **Priority:** High | **Epic:** EPIC-002
**As a** learner **I want** asignar miembros y comunicarme via comentarios **So that** entienda el flujo colaborativo.
**AC1:** Given que estoy en un board, When me asigno a una card, Then mi avatar aparece en la card.
**AC2:** Given que estoy en una card, When escribo un comentario, Then aparece en el activity log con timestamp.
**AC3:** Given card con comentarios, When reviso Activity log, Then veo historial completo ordenado cronologicamente.
**Notas:** Auto-asignarse si se trabaja solo. Comments soportan @menciones.
**Evidencia:** Screenshot de card con member + comentario + activity log.

### PM-007: Adjuntar archivos a cards
**Points:** 1 | **Priority:** High | **Epic:** EPIC-002
**As a** learner **I want** adjuntar archivos e imagenes a tarjetas **So that** pueda centralizar informacion en cada tarea.
**AC1:** Given una card abierta, When adjunto archivo local, Then aparece como attachment con preview si es imagen.
**AC2:** Given una card abierta, When adjunto link externo, Then aparece como attachment con titulo.
**Notas:** Free tier: 10MB max por archivo. Probar imagen, PDF y link.
**Evidencia:** Screenshot de card con attachments.

### PM-008: Filtros avanzados y busqueda
**Points:** 2 | **Priority:** High | **Epic:** EPIC-002
**As a** learner **I want** usar filtros y busqueda para encontrar cards **So that** pueda navegar eficientemente en boards grandes.
**AC1:** Given board con 5+ cards, When filtro por label + member + due date, Then solo se muestran cards que cumplen todos los criterios.
**AC2:** Given que estoy en Trello, When uso busqueda global, Then aparecen resultados de cards y boards.
**AC3:** Given que busco, When uso operadores (board:, label:, due:day), Then resultados se filtran segun operadores.
**Notas:** Shortcut "/" para busqueda global, "F" para filtro en board. Operadores: `board:`, `list:`, `label:`, `has:`, `due:`, `is:starred`.
**Evidencia:** Screenshot de busqueda con operadores. Documentar operadores mas utiles.

### EPIC-003: Trello Automatizacion y Power-Ups

### PM-009: Butler - Rules y automaciones basicas
**Points:** 2 | **Priority:** Medium | **Epic:** EPIC-003
**As a** learner **I want** crear automatizaciones con Butler **So that** pueda reducir tareas manuales repetitivas.
**AC1:** Given un board, When creo Rule que mueve cards a "Done" al completar checklist, Then la card se mueve automaticamente.
**AC2:** Given Butler abierto, When creo Card Button que asigna label + member + due date, Then al presionarlo se aplican las 3 acciones.
**AC3:** Given Rule activa, When se cumple el trigger, Then la accion se ejecuta y aparece en Activity log.
**Notas:** Butler incluido en plan gratuito (con limites). Triggers: card moved, checklist completed, due date approaching.
**Evidencia:** Screenshot de config Butler + Activity log con accion automatica.

### PM-010: Butler - Calendar y Due Date commands
**Points:** 2 | **Priority:** Medium | **Epic:** EPIC-003
**As a** learner **I want** crear comandos de calendario y fechas en Butler **So that** pueda automatizar acciones basadas en tiempo.
**AC1:** Given Butler, When creo Due Date command que comenta 1 dia antes de vencimiento, Then el comentario se agrega automaticamente.
**AC2:** Given Butler, When creo Calendar command que mueve cards vencidas a "Overdue", Then se mueven automaticamente.
**AC3:** Given Board Buttons configurados, When presiono uno, Then la accion se ejecuta sobre todo el board.
**Notas:** Calendar commands en horarios programados. Due date commands relativos al vencimiento. Board Buttons = acciones globales.
**Evidencia:** Screenshot de cada tipo de comando. Documentar automatizaciones mas utiles.

### PM-011: Power-Ups y vistas adicionales
**Points:** 2 | **Priority:** Medium | **Epic:** EPIC-003
**As a** learner **I want** activar Power-Ups para extender Trello **So that** conozca el ecosistema de extensiones.
**AC1:** Given un board, When activo Calendar Power-Up, Then puedo ver cards con due date en vista calendario.
**AC2:** Given un board, When activo Custom Fields, Then puedo agregar campos personalizados (numero, texto, dropdown).
**AC3:** Given Power-Ups activos, When reviso marketplace, Then identifico 3+ integraciones relevantes (Slack, Drive, GitHub) con su utilidad.
**Notas:** Plan gratuito: verificar limite de Power-Ups por board. Populares: Calendar, Custom Fields, Voting, Card Aging.
**Evidencia:** Screenshot de vista Calendar + Custom Fields. Lista de integraciones.

### EPIC-004: Trello API y Automatizacion Avanzada (Opcional)

### PM-012: Explorar la API REST de Trello
**Points:** 2 | **Priority:** Low | **Epic:** EPIC-004
**As a** learner **I want** obtener API key/token y hacer llamadas basicas **So that** entienda como automatizar Trello programaticamente.
**AC1:** Given cuenta en Trello, When genero API key y token desde trello.com/app-key, Then tengo credenciales validas.
**AC2:** Given API key y token, When hago GET /1/members/me/boards, Then recibo lista de boards en JSON.
**AC3:** Given que puedo leer boards, When hago POST para crear card via API, Then la card aparece en el board.
**Notas:** Docs: developer.atlassian.com/cloud/trello/rest/. Probar con curl o Postman.
**Evidencia:** GET y POST exitosos documentados. Lista de endpoints utiles.

### PM-013: Configurar webhooks de Trello
**Points:** 2 | **Priority:** Low | **Epic:** EPIC-004
**As a** learner **I want** configurar un webhook para recibir eventos **So that** pueda reaccionar a cambios en boards.
**AC1:** Given endpoint publico (ngrok), When registro webhook via API, Then Trello confirma el registro.
**AC2:** Given webhook activo, When muevo card, Then mi endpoint recibe payload JSON con el evento.
**AC3:** Given que recibo eventos, When analizo payload, Then identifico: tipo de accion, card, board, member.
**Notas:** Necesita HTTPS (ngrok). POST /1/webhooks/. Endpoint debe responder 200 al HEAD de verificacion.
**Evidencia:** Log de 3+ eventos capturados. Documentar estructura del payload.

### PM-014: Prototipo de integracion o MCP server para Trello
**Points:** 3 | **Priority:** Low | **Epic:** EPIC-004
**As a** learner **I want** crear un script o MCP server que interactue con Trello **So that** tenga experiencia integrando Trello con herramientas propias.
**AC1:** Given que conozco la API, When creo script que lista boards y crea cards, Then funciona end-to-end.
**AC2:** Given script funcional, When lo ejecuto con parametros (board, lista, titulo), Then crea card en el lugar correcto.
**AC3:** (Opcional) Given MCP server, When implemento list_boards, create_card, move_card, Then opero Trello desde Claude Code.
**Notas:** Stack: Python (requests) o Node.js. MCP: FastMCP o MCP SDK. Ref: L-014, L-020, L-021, L-022.
**Evidencia:** Script funcional con README. Demo de 3+ operaciones.

### EPIC-005: Expansion a Otras Herramientas (Placeholder)

### PM-015: Exploracion inicial de Jira
**Points:** 1 | **Priority:** Low | **Epic:** EPIC-005
**As a** learner **I want** crear cuenta en Jira y explorar conceptos basicos **So that** pueda comparar Jira con Trello.
**AC1:** Given sin cuenta Jira, When me registro en Jira Cloud free, Then tengo acceso a un proyecto de prueba.
**AC2:** Given acceso a Jira, When creo proyecto Kanban y Scrum, Then identifico diferencias entre ambos y con Trello.
**AC3:** Given que use Trello y Jira, When documento comparativa, Then incluyo 5+ criterios: facilidad, funcionalidades, precio, escalabilidad, integraciones.
**Notas:** Jira Cloud free hasta 10 usuarios. Conceptos extra: issue types, workflows, sprints, epics, components.
**Evidencia:** Comparativa Trello vs Jira documentada.

### PM-016: Survey de herramientas de gestion de proyectos
**Points:** 1 | **Priority:** Low | **Epic:** EPIC-005
**As a** learner **I want** investigar y comparar herramientas de PM del mercado **So that** tenga mapa de opciones para diferentes contextos.
**AC1:** Given que conozco Trello, When investigo Asana, Monday.com y Linear, Then documento: target audience, precio, fortaleza, debilidad.
**AC2:** Given comparativa lista, When defino criterios de decision, Then puedo recomendar herramienta segun tamano de equipo, tipo de proyecto, presupuesto.
**Notas:** No es necesario cuenta en todas. Linear relevante para equipos de desarrollo.
**Evidencia:** Tabla comparativa 4+ herramientas. Recomendaciones por caso de uso.

## Completadas (indice)
| ID | Titulo | Puntos | Fecha | Detalle |
|----|--------|--------|-------|---------|
| - | - | - | - | - |

## ID Registry
| Rango | Estado |
|-------|--------|
| PM-001 a PM-004 | Asignado (EPIC-001: Trello Fundamentos) |
| PM-005 a PM-008 | Asignado (EPIC-002: Trello Intermedio) |
| PM-009 a PM-011 | Asignado (EPIC-003: Trello Automatizacion) |
| PM-012 a PM-014 | Asignado (EPIC-004: Trello API) |
| PM-015 a PM-016 | Asignado (EPIC-005: Expansion) |
| PM-017+ | Disponible |
Proximo ID: PM-017
