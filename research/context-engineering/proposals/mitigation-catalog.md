# Catalogo de Mitigaciones de Contexto
**Fecha:** 2026-02-25 | **Version:** 1.0
**Historia:** CE-003 | **Investigador:** Claude (Context Engineering)

---

## 1. Inventario de Mitigaciones

### M-001: Arquitectura de 3 capas de memoria
**Fuente:** `06-memory-sync.md` (seccion "Arquitectura de 3 Capas")
**Tipo:** Preventiva
**Descripcion:** Estructura el conocimiento persistente en tres niveles jerarquicos: User Memory (preferencias globales en `~/.claude/CLAUDE.md`), Project Memory (contexto del proyecto en `[proyecto]/.claude/CLAUDE.md` con patron de redireccion), y Context Repository (repositorio centralizado en `C:/claude_context/`). Cada capa tiene un proposito distinto y se carga automaticamente al inicio de sesion.
**Tipos de perdida que mitiga:** perdida_de_estado, re-descubrimiento, perdida_inter-proyecto
**Efectividad estimada:** Alta. Es el mecanismo estructural mas importante: garantiza que conocimiento critico se cargue en cada sesion nueva sin intervencion manual. La separacion en capas permite que el conocimiento global (metodologia) se comparta entre proyectos.
**Limitaciones:** Solo protege lo que fue explicitamente escrito en los archivos. No captura conocimiento que quedo exclusivamente en la conversacion. Depende de que Claude (o el usuario) escriba la informacion en la capa correcta. No hay mecanismo que fuerce la escritura.

### M-002: Patron de redireccion (settings centralizados)
**Fuente:** `03-obligatory-directives.md` (directiva 9), `06-memory-sync.md` (seccion "Patron de Redireccion")
**Tipo:** Preventiva
**Descripcion:** Los archivos CLAUDE.md de cada proyecto son punteros (@import) al archivo real en `claude_context`. Esto centraliza la configuracion y evita que el conocimiento quede disperso en multiples repositorios donde podria quedar desactualizado o inaccesible.
**Tipos de perdida que mitiga:** re-descubrimiento, duplicacion_de_trabajo, perdida_inter-proyecto
**Efectividad estimada:** Alta. Resuelve elegantemente el problema de tener configuracion duplicada en cada repositorio. Cualquier actualizacion se propaga automaticamente.
**Limitaciones:** Si el archivo centralizado crece demasiado, se vuelve ineficiente (mitigado por M-003). No previene perdida de conocimiento que nunca se escribio.

### M-003: Limites de tamano por archivo y limpieza obligatoria
**Fuente:** `07-project-memory-management.md` (secciones 1, 2, 4)
**Tipo:** Preventiva + Detectiva
**Descripcion:** Define limites estrictos de lineas por archivo de contexto (CLAUDE.md: 150, TASK_STATE: 200, BACKLOG: 300, ARCHITECTURE: 400, LEARNINGS: 200). Incluye triggers de limpieza (inicio de sesion, historia completada, cierre de sesion, epic completado) y un proceso de archivado (mover informacion historica a `archive/`).
**Tipos de perdida que mitiga:** crecimiento_sin_limpieza, perdida_por_compresion (indirectamente)
**Efectividad estimada:** Media-Alta. Los limites son claros y la estructura de archivado es buena. Sin embargo, la ejecucion depende enteramente de que Claude detecte el exceso y lo corrija. No hay tooling que alerte o fuerce la limpieza. En la practica, los archivos pueden exceder limites durante sesiones largas sin que se detecte.
**Limitaciones:** El archivado mueve info fuera del contexto activo, lo que puede causar que se pierda acceso rapido a decisiones recientes. La regla "Claude ejecuta automaticamente al detectar exceso" no tiene mecanismo de enforcement: es una directiva de comportamiento, no un hook o script.

### M-004: TASK_STATE.md como estado de trabajo persistente
**Fuente:** `03-obligatory-directives.md` (directiva 2), `07-project-memory-management.md` (template TASK_STATE)
**Tipo:** Preventiva
**Descripcion:** Para proyectos con 3+ tareas relacionadas o trabajo multi-sesion, se mantiene un archivo TASK_STATE.md con: resumen ejecutivo, tareas activas con estado, y proximos pasos. Se debe actualizar cada vez que se completa una tarea, se toma decision importante, o cada ~30 minutos de trabajo activo.
**Tipos de perdida que mitiga:** perdida_de_estado, re-descubrimiento, duplicacion_de_trabajo
**Efectividad estimada:** Alta cuando se cumple. El template esta bien definido y la informacion que captura es exactamente la que se necesita para retomar trabajo. Es el mecanismo mas directo contra la perdida de estado.
**Limitaciones:** Depende de disciplina de escritura. No hay nada que fuerce la actualizacion cada 30 minutos. En sesiones intensas de coding, es facil olvidar actualizar TASK_STATE porque el foco esta en el codigo. La directiva dice "minimo cada 30 min" pero no hay timer ni recordatorio.

### M-005: Seccion "Sesion Activa" en TASK_STATE
**Fuente:** `03-obligatory-directives.md` (directiva 12a, seccion "Sesion Activa")
**Tipo:** Preventiva
**Descripcion:** TASK_STATE debe incluir una seccion que capture el contexto inmediato de trabajo: fecha/hora de inicio, actividad actual (implementando/testeando/debuggeando/investigando), detalle de la tarea, hipotesis en curso, y ultimo resultado. Se actualiza en cada transicion de actividad.
**Tipos de perdida que mitiga:** perdida_de_estado, re-descubrimiento
**Efectividad estimada:** Media. Cuando se mantiene, es extremadamente util para retomar. Pero la granularidad requerida (cada transicion de actividad) es alta y facil de omitir. En la practica, se actualiza con menos frecuencia de la requerida.
**Limitaciones:** Misma limitacion que M-004: depende de disciplina sin enforcement. Ademas, la seccion debe borrarse al cerrar sesion, lo que crea una ventana donde no hay registro si la sesion muere antes de actualizar.

### M-006: Registro en tiempo real de pruebas manuales
**Fuente:** `03-obligatory-directives.md` (directiva 12a)
**Tipo:** Preventiva
**Descripcion:** Toda prueba manual se documenta MIENTRAS se ejecuta, no despues. Define un formato con pre-condiciones, pasos ejecutados con resultado PASS/FAIL, detalle de errores, y resultado final. Ubicacion en TASK_STATE o `archive/tests/`.
**Tipos de perdida que mitiga:** perdida_de_estado, re-descubrimiento, duplicacion_de_trabajo
**Efectividad estimada:** Alta para el dominio especifico de testing. El formato es claro y la regla "registrar MIENTRAS se ejecuta" es el patron correcto. Cubre un punto de vulnerabilidad critico (sesiones de debugging que mueren a mitad).
**Limitaciones:** Solo aplica a pruebas manuales. No cubre debugging ad-hoc, investigacion exploratoria, o experimentacion con diferentes enfoques. El formato puede ser verbose para tests simples.

### M-007: Checkpoint de codigo antes de pruebas
**Fuente:** `03-obligatory-directives.md` (directiva 12a, seccion "Checkpoint de codigo")
**Tipo:** Preventiva
**Descripcion:** Antes de iniciar pruebas manuales, asegurar que el codigo esta resguardado via commit (puede ser WIP) o `git stash`. Regla: nunca empezar pruebas con cambios sin commitear o stashear.
**Tipos de perdida que mitiga:** perdida_de_estado (codigo no guardado)
**Efectividad estimada:** Alta. Es una regla simple y verificable. Un commit WIP es rapido de hacer y protege el codigo de forma definitiva.
**Limitaciones:** Solo protege codigo, no conocimiento contextual. Solo se activa antes de pruebas manuales, no en otros momentos de vulnerabilidad (antes de operaciones largas, antes de lanzar agentes, etc.).

### M-008: Documentar sugerencias y decisiones inmediatamente
**Fuente:** `03-obligatory-directives.md` (directiva 12b)
**Tipo:** Preventiva
**Descripcion:** Toda sugerencia, recomendacion o decision importante debe quedar por escrito ANTES de continuar con otro trabajo. Define un formato minimo y una tabla de destinos segun tipo (sugerencia al proyecto -> TASK_STATE, sugerencia a proceso -> CONTINUOUS_IMPROVEMENT, decision arquitectonica -> ARCHITECTURE, idea de feature -> BACKLOG, hallazgo tecnico -> LEARNINGS).
**Tipos de perdida que mitiga:** perdida_de_sugerencia, re-descubrimiento
**Efectividad estimada:** Media-Alta. La directiva es clara y los destinos estan bien definidos. Pero "documentar INMEDIATAMENTE" compite con el flujo natural de trabajo. Claude puede generar una sugerencia como parte de una respuesta larga y no interrumpirse para escribirla a archivo.
**Limitaciones:** No hay mecanismo que detecte cuando Claude menciona una sugerencia sin haberla persistido. Es puramente una directiva de comportamiento. Las sugerencias menores o informales ("tal vez convendria...") son las mas propensas a perderse porque no alcanzan el umbral percibido de "importancia".

### M-009: Checkpoints de estado pre/post agentes paralelos
**Fuente:** `03-obligatory-directives.md` (directiva 12c, seccion "Antes de lanzar agentes en paralelo" y "Despues de recibir resultados")
**Tipo:** Preventiva
**Descripcion:** Antes de lanzar agentes: escribir en TASK_STATE que agentes se lanzan, con que tarea, que se espera, y el plan post-agentes. Despues de recibir resultados: resumen de output, archivos creados/modificados, problemas encontrados.
**Tipos de perdida que mitiga:** perdida_de_estado, contexto_insuficiente_para_agente (indirectamente, al obligar a explicitar las tareas)
**Efectividad estimada:** Media. El costo es bajo (~1 min) y el beneficio es alto cuando se cumple. Pero en la practica, lanzar agentes en paralelo es un momento de alta presion cognitiva donde es tentador saltear el checkpoint para ir directo a la accion.
**Limitaciones:** Solo cubre el momento de delegacion a agentes, no otras transiciones de actividad. No garantiza que el contexto DADO a los agentes sea suficiente (eso lo cubre M-014).

### M-010: WIP commits agresivos
**Fuente:** `03-obligatory-directives.md` (directiva 12c, seccion "WIP commits agresivos")
**Tipo:** Preventiva
**Descripcion:** Commit WIP en momentos clave: despues de que un agente completa una historia, antes de lanzar la siguiente ola de trabajo, despues de code review pre-fix. Se puede squashear al final.
**Tipos de perdida que mitiga:** perdida_de_estado (codigo), duplicacion_de_trabajo
**Efectividad estimada:** Alta. Es el mecanismo mas confiable para proteger codigo porque git es persistente e inmutable. Un commit WIP es barato y reversible. Es la unica mitigacion que protege trabajo parcial de forma definitiva.
**Limitaciones:** Solo protege archivos trackeados por git. No protege conocimiento contextual, razonamiento, ni planes que estan solo en la conversacion. La granularidad depende de disciplina (cada historia vs cada grupo).

### M-011: Razonamiento de diseno inline
**Fuente:** `03-obligatory-directives.md` (directiva 12c, seccion "Razonamiento de diseno inline")
**Tipo:** Preventiva
**Descripcion:** Cuando se toma una decision de diseno durante la conversacion, documentar inmediatamente en: comentario en el codigo (si es tecnico-local), ARCHITECTURE (si es arquitectonico), LEARNINGS (si es un patron aprendido). No esperar al cierre de sesion.
**Tipos de perdida que mitiga:** perdida_de_sugerencia, re-descubrimiento
**Efectividad estimada:** Media. El "por que" detras de decisiones es el tipo de conocimiento mas valioso y mas propenso a perderse. Cuando se cumple, previene re-descubrimiento costoso. Pero requiere interrumpir el flujo de razonamiento para escribir a archivo.
**Limitaciones:** Solo cubre decisiones de diseno, no otras formas de conocimiento contextual. La frontera entre "decision de diseno" y "observacion casual" es difusa. Requiere juicio sobre que merece ser documentado.

### M-012: Resumen ejecutivo periodico en TASK_STATE
**Fuente:** `03-obligatory-directives.md` (directiva 12c, seccion "Resumen ejecutivo periodico")
**Tipo:** Preventiva
**Descripcion:** Cada ~30 minutos de trabajo activo o despues de cada hito, actualizar "Sesion Activa" en TASK_STATE con progreso, archivos nuevos, pendientes de la sesion, y contexto critico.
**Tipos de perdida que mitiga:** perdida_de_estado, re-descubrimiento
**Efectividad estimada:** Media. Es una version mas lightweight de M-005. El intervalo de 30 min es razonable pero no hay timer. La seccion "Contexto critico" es especialmente valiosa si se usa bien.
**Limitaciones:** Redundante con M-005 (son el mismo mecanismo con diferente granularidad). La periodicidad no se puede forzar. En sesiones muy activas, 30 minutos de contexto no escrito pueden contener decisiones criticas.

### M-013: Log de resultados de code review
**Fuente:** `03-obligatory-directives.md` (directiva 12c, seccion "Log de resultados de code review")
**Tipo:** Preventiva
**Descripcion:** Al recibir resultado de code-reviewer, escribir resumen estructurado en TASK_STATE con criticos, mayores, aplicados, y pendientes.
**Tipos de perdida que mitiga:** perdida_de_estado, duplicacion_de_trabajo
**Efectividad estimada:** Media-Alta. Los hallazgos de code review son output de agentes que no persiste automaticamente. Registrarlos previene que se pierdan fixes parcialmente aplicados. El formato es conciso y accionable.
**Limitaciones:** Solo cubre code review formal. No cubre observaciones informales sobre calidad de codigo que surgen durante la conversacion. El formato asume un flujo lineal (review -> fix -> done) que no siempre ocurre.

### M-014: Contexto completo al delegar a agentes
**Fuente:** `03-obligatory-directives.md` (directiva 1, seccion "Contexto al Delegar")
**Tipo:** Preventiva
**Descripcion:** Checklist obligatorio antes de delegar: objetivo claro, nombres exactos (clases, archivos, funciones), contexto de arquitectura, specs tecnicas (INCLUIR contenido, no solo referenciar), restricciones, criterios de exito. Regla de oro: "Si el agente necesita leer otro doc para entender la tarea, INCLUIR ese contenido en el prompt."
**Tipos de perdida que mitiga:** contexto_insuficiente_para_agente
**Efectividad estimada:** Media. La checklist es buena y la regla de oro es el principio correcto. Pero es una directiva de comportamiento sin enforcement. Claude puede delegar con contexto parcial si hay presion de tiempo o si el checklist se percibe como overhead. No hay validacion de que el agente recibio contexto suficiente.
**Limitaciones:** No hay mecanismo de feedback: si el agente recibe contexto insuficiente, no hay alerta automatica. Solo se detecta cuando el agente produce output incorrecto o incompleto. La calidad del contexto depende del juicio de Claude sobre que es "suficiente".

### M-015: Sistema de herencia de perfiles de agentes
**Fuente:** `agents/README.md`, `03-obligatory-directives.md` (directiva 1)
**Tipo:** Preventiva
**Descripcion:** Los agentes se especializan mediante composicion: BASE (principios comunes) + ESPECIALIZACION (dominio) + contexto del proyecto. Claude lee ambos documentos y los incluye en el prompt del agente, asegurando que el agente reciba conocimiento de dominio estandarizado ademas del contexto especifico.
**Tipos de perdida que mitiga:** contexto_insuficiente_para_agente, re-descubrimiento (de patrones de desarrollo)
**Efectividad estimada:** Media-Alta. Estandariza el baseline de conocimiento que cada agente recibe. Evita que se "olvide" incluir principios fundamentales. Pero la composicion es manual (Claude lee y concatena).
**Limitaciones:** Solo cubre conocimiento estandarizado de dominio. El contexto especifico del proyecto sigue dependiendo de M-014. Si se actualiza un perfil BASE, no hay mecanismo que notifique a las sesiones existentes.

### M-016: Protocolo de inicio de sesion
**Fuente:** `06-memory-sync.md` (seccion "Al Iniciar Sesion en un Proyecto"), `07-project-memory-management.md` (seccion 7)
**Tipo:** Detectiva + Correctiva
**Descripcion:** Al iniciar sesion: verificar estructura claude_context, verificar tamanos contra limites, ejecutar limpieza si exceden, revisar TASK_STATE para retomar trabajo pendiente. Si no existe config centralizada, preguntar clasificador y crear estructura.
**Tipos de perdida que mitiga:** re-descubrimiento, crecimiento_sin_limpieza
**Efectividad estimada:** Media. El protocolo es bueno pero no se verifica sistematicamente. Claude puede empezar a trabajar directamente si el usuario da una instruccion urgente. No hay hook que fuerce la verificacion al inicio.
**Limitaciones:** Depende de que Claude ejecute el protocolo antes de empezar a trabajar. En la practica, si el usuario llega con un pedido urgente, el protocolo de inicio puede saltearse.

### M-017: Gestion de backlog como gate de cambios
**Fuente:** `03-obligatory-directives.md` (directiva 3)
**Tipo:** Preventiva
**Descripcion:** Todo cambio de codigo pasa por backlog primero, sin excepcion (salvo typos/formateo). Bugs reportados, features pedidos, bugs encontrados por Claude, tests fallidos: todo va a backlog antes de implementar. Usa agente product-owner para crear historias con formato estandar e ID unico.
**Tipos de perdida que mitiga:** duplicacion_de_trabajo, re-descubrimiento
**Efectividad estimada:** Alta para su proposito (evitar trabajo no trackeado). El backlog actua como registro persistente de TODO el trabajo planificado y ejecutado. Los IDs unicos permiten rastrear historias a lo largo del tiempo.
**Limitaciones:** No previene perdida de contexto conversacional. El backlog registra el QUE pero no siempre el POR QUE detallado. Agregar overhead a cambios triviales puede incentivar saltear el proceso.

### M-018: Extension sin eliminacion (additive-only)
**Fuente:** `03-obligatory-directives.md` (directiva 5)
**Tipo:** Preventiva
**Descripcion:** Al implementar nuevas aproximaciones, NUNCA eliminar codigo operativo. Usar strategy pattern, feature flags, parametros opcionales, o additive-only (agregar endpoints/modos, no reemplazar). El codigo anterior sirve como documentacion viva del comportamiento previo.
**Tipos de perdida que mitiga:** re-descubrimiento (de comportamiento previo), duplicacion_de_trabajo (re-implementar algo que se elimino)
**Efectividad estimada:** Alta para su dominio especifico. Previene la perdida de implementaciones que podrian ser necesarias en el futuro. Es verificable en code review.
**Limitaciones:** No aplica a contexto conversacional. Puede llevar a codigo complejo si se acumulan muchas estrategias sin limpiar las obsoletas.

### M-019: Rigor intelectual (hechos vs hipotesis)
**Fuente:** `03-obligatory-directives.md` (directiva 4)
**Tipo:** Preventiva (de calidad de contexto)
**Descripcion:** Etiquetar explicitamente informacion como [HECHO], [HIPOTESIS], [DESCONOCIDO], o [VERIFICAR]. Preferir "no se, necesito investigar" a inventar una explicacion.
**Tipos de perdida que mitiga:** re-descubrimiento (de la naturaleza de una afirmacion: era un hecho confirmado o una hipotesis?)
**Efectividad estimada:** Media. Cuando se aplica, mejora la calidad del contexto significativamente. Pero es una practica de comunicacion, no de persistencia. Las etiquetas se pierden si la conversacion se pierde.
**Limitaciones:** Solo util si el conocimiento etiquetado se persiste en archivos. En la conversacion, las etiquetas se pierden con el contexto. No hay enforcement.

### M-020: Actualizacion de TASK_STATE al cambiar de fase
**Fuente:** `03-obligatory-directives.md` (directiva 12a, seccion "Actualizar TASK_STATE al cambiar de fase")
**Tipo:** Preventiva
**Descripcion:** Cada vez que el trabajo cambia de naturaleza (coding -> testing, testing -> debugging, debugging -> fix, fix -> re-test), actualizar TASK_STATE ANTES de continuar. Registrar que se implemento, que error se encontro, que se va a cambiar, etc.
**Tipos de perdida que mitiga:** perdida_de_estado, re-descubrimiento
**Efectividad estimada:** Media. Cubre los momentos de transicion que son los mas vulnerables. El formato es especifico para cada transicion. Pero la regla "ANTES de continuar" compite con la urgencia de resolver el problema.
**Limitaciones:** Requiere que Claude identifique correctamente el cambio de fase (no siempre es discreto, a veces coding y debugging se mezclan). La regla "ANTES de continuar" puede ser ignorada si el fix parece rapido.

### M-021: Snapshot de servicios activos
**Fuente:** `03-obligatory-directives.md` (directiva 12a, seccion "Snapshot de servicios activos")
**Tipo:** Preventiva
**Descripcion:** Para pruebas que involucran multiples servicios, registrar que esta corriendo (servicio, puerto, comando, estado). Actualizar si alguno cae o se reinicia.
**Tipos de perdida que mitiga:** perdida_de_estado (entorno de ejecucion)
**Efectividad estimada:** Media. Util para proyectos con microservicios o multiples procesos. Previene el clasico "no me acuerdo en que puerto corria X". Es un tipo de contexto muy especifico pero frecuentemente perdido.
**Limitaciones:** Solo aplica a testing con servicios. Es un formato rigido para algo que cambia constantemente durante debugging.

### M-022: Errores: registrar PRIMERO, investigar DESPUES
**Fuente:** `03-obligatory-directives.md` (directiva 12a, seccion "Errores: registrar PRIMERO")
**Tipo:** Preventiva
**Descripcion:** Al encontrar un error durante pruebas: (1) copiar el error textualmente al TASK_STATE, (2) anotar contexto, (3) investigar. Nunca investigar sin haber registrado primero. Si la sesion se interrumpe durante la investigacion, el error queda documentado.
**Tipos de perdida que mitiga:** perdida_de_estado (errores sin documentar), re-descubrimiento (del error mismo)
**Efectividad estimada:** Alta. Es una regla simple, accionable, y con beneficio inmediato. El costo es bajo (copiar el error antes de investigar). Es especialmente valiosa durante sesiones de debugging largas.
**Limitaciones:** Solo cubre errores formales (stack traces, mensajes). No cubre comportamiento inesperado sin error explicito ("deberia hacer X pero hace Y" sin excepcion).

### M-023: Plan de trabajo escrito antes de ejecutar
**Fuente:** `03-obligatory-directives.md` (directiva 12c, seccion "Plan de trabajo escrito")
**Tipo:** Preventiva
**Descripcion:** Antes de trabajo complejo (multiples historias, olas paralelas), documentar el plan en TASK_STATE con olas, dependencias, y plan post-implementacion.
**Tipos de perdida que mitiga:** perdida_de_estado, duplicacion_de_trabajo
**Efectividad estimada:** Media-Alta. Un plan escrito permite retomar exactamente donde se dejo. Es especialmente valioso para trabajo paralelo donde la coordinacion es compleja.
**Limitaciones:** Solo se activa antes de "trabajo complejo". Trabajo mediano (2-3 historias secuenciales) puede no gatillar la escritura del plan. La definicion de "complejo" queda a juicio de Claude.

### M-024: Observacion continua de resiliencia de contexto
**Fuente:** `03-obligatory-directives.md` (directiva 12d)
**Tipo:** Detectiva
**Descripcion:** Claude tiene como responsabilidad permanente observar incidentes y oportunidades de mejora relacionados con la resiliencia del contexto. Transversal a todos los proyectos. Registrar hallazgos en CONTINUOUS_IMPROVEMENT.md o en el proyecto de Context Engineering.
**Tipos de perdida que mitiga:** Todos los tipos (meta-mitigacion: mejora el sistema de mitigaciones)
**Efectividad estimada:** Media. Es la unica mitigacion que es auto-referencial: mejora las demas mitigaciones. Pero es una directiva difusa ("observar continuamente") sin triggers especificos ni formato de reporte regular.
**Limitaciones:** Depende de que Claude dedique atencion a la meta-observacion mientras trabaja en tareas concretas. Compite con la carga cognitiva del trabajo actual. Los hallazgos van a CONTINUOUS_IMPROVEMENT que tiene tareas pendientes sin resolver.

### M-025: Integracion de sugerencias pendientes en TASK_STATE
**Fuente:** `03-obligatory-directives.md` (directiva 12b, seccion "Integracion con TASK_STATE")
**Tipo:** Preventiva + Detectiva
**Descripcion:** TASK_STATE incluye una seccion opcional "Sugerencias Pendientes" con formato `[fecha] [descripcion] -> [proyecto] | [accion]`. Se revisa al inicio de cada sesion y las sugerencias se procesan (backlog, mejora, descarte).
**Tipos de perdida que mitiga:** perdida_de_sugerencia
**Efectividad estimada:** Media. Crea un buffer para sugerencias que aun no se procesaron. La revision al inicio de sesion evita que se acumulen indefinidamente. Pero la seccion es "opcional", lo que debilita su uso.
**Limitaciones:** La seccion es opcional. Las sugerencias registradas aqui aun dependen de que Claude las escriba en el momento (lo cual es M-008). Es un mecanismo de segundo nivel que complementa M-008 pero no lo reemplaza.

---

## 2. Matriz de Cobertura

| Tipo de perdida | M-001 | M-002 | M-003 | M-004 | M-005 | M-006 | M-007 | M-008 | M-009 | M-010 | M-011 | M-012 | M-013 | M-014 | M-015 | M-016 | M-017 | M-018 | M-019 | M-020 | M-021 | M-022 | M-023 | M-024 | M-025 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **perdida_de_sugerencia** | | | | | | | | X | | | ~ | | | | | | | | | | | | | ~ | X |
| **perdida_de_estado** | X | | | X | X | X | X | | X | X | | X | X | | | | | | | X | X | X | X | | |
| **ctx_insuf_agente** | | | | | | | | | ~ | | | | | X | X | | | | | | | | | | |
| **re-descubrimiento** | X | X | | X | X | X | | X | | | X | X | | | ~ | X | X | X | ~ | X | | X | | | |
| **duplicacion_trabajo** | | X | | X | | X | | | | X | | | X | | | | X | X | | | | | X | | |
| **crecimiento_sin_limpieza** | | | X | | | | | | | | | | | | | X | | | | | | | | | |
| **perdida_por_compresion** | | | ~ | | | | | | | | | | | | | | | | | | | | | | |
| **perdida_inter-proyecto** | X | X | | | | | | | | | | | | | | | | | | | | | | | |

Leyenda: **X** = cubre directamente | **~** = cubre parcialmente | (vacio) = no cubre

### Conteo de cobertura por tipo

| Tipo de perdida | Cobertura directa (X) | Parcial (~) | Total |
|---|---|---|---|
| perdida_de_sugerencia | 2 | 2 | 4 |
| perdida_de_estado | 12 | 0 | 12 |
| contexto_insuficiente_para_agente | 2 | 1 | 3 |
| re-descubrimiento | 12 | 1 | 13 |
| duplicacion_de_trabajo | 6 | 0 | 6 |
| crecimiento_sin_limpieza | 2 | 0 | 2 |
| perdida_por_compresion | 0 | 1 | 1 |
| perdida_inter-proyecto | 2 | 0 | 2 |

---

## 3. Gaps Identificados

### Gap 1: Perdida por compresion - COBERTURA CRITICA AUSENTE
**Severidad:** Alta
**Estado actual:** Solo M-003 (limites de tamano) ofrece cobertura parcial e indirecta. No hay ninguna mitigacion que aborde la compresion de mensajes previos que realiza el sistema cuando el contexto excede la ventana.
**Problema:** Cuando una sesion larga provoca compresion automatica de mensajes anteriores, se pierde informacion que estaba en la conversacion pero no se persistio a archivos. Las mitigaciones de persistencia (M-004 a M-013) reducen la cantidad de informacion vulnerable, pero no eliminan el problema.
**Causa:** La compresion ocurre a nivel de infraestructura (Anthropic-side) y no es controlable. Las mitigaciones actuales asumen que la informacion critica se escribe a archivos, pero no verifican que esto ocurra antes de la compresion.
**Posible mitigacion:** Un checkpoint FORZADO de contexto critico cuando se detecta que la sesion es larga (>50% de ventana usada). O un hook que se ejecute antes de la compresion (no existe actualmente en Claude Code).

### Gap 2: Perdida inter-proyecto - COBERTURA DEBIL
**Severidad:** Media-Alta
**Estado actual:** Solo M-001 (3 capas) y M-002 (redireccion) ofrecen cobertura, pero son mecanismos estructurales que no activamente transfieren conocimiento entre proyectos.
**Problema:** Un patron aprendido en el proyecto A (registrado en `claude_context/A/LEARNINGS.md`) no se carga cuando se trabaja en proyecto B, a menos que ambos compartan el mismo LEARNINGS. La metodologia general se comparte, pero los learnings de proyecto son aislados.
**Causa:** La arquitectura de 3 capas separa el conocimiento por proyecto. Esto es correcto para evitar contaminacion, pero crea silos. No hay mecanismo de "broadcast" de learnings relevantes.
**Posible mitigacion:** Un indice transversal de learnings (`claude_context/CROSS_PROJECT_LEARNINGS.md`) que se cargue en todos los proyectos. O un query en inicio de sesion: "hay learnings de otros proyectos relevantes para el stack actual?"

### Gap 3: Enforcement - NINGUNA MITIGACION ES FORZADA
**Severidad:** Alta
**Estado actual:** Todas las mitigaciones (M-001 a M-025) son directivas de comportamiento. Ninguna tiene enforcement automatico (hooks, scripts, validaciones pre-commit).
**Problema:** Las mitigaciones dependen de que Claude las ejecute consistentemente. En momentos de alta presion (debugging urgente, usuario impaciente, sesion larga con contexto saturado), las directivas de menor prioridad percibida se saltan. La calidad de la proteccion de contexto es proporcional a la disciplina, no a la criticidad de la informacion.
**Causa:** Claude Code no ofrece hooks de sesion (on-session-start, on-context-compression, on-session-end). Las mitigaciones no pueden ser automatizadas sin tooling externo.
**Posible mitigacion:** Un MCP server o hook que valide al inicio de sesion que TASK_STATE tiene seccion activa, que archivos no exceden limites, y que al cerrar sesion se haya actualizado proximos pasos. Convertir directivas criticas en tooling verificable.

### Gap 4: Perdida de sugerencias informales - COBERTURA INSUFICIENTE
**Severidad:** Media
**Estado actual:** M-008 y M-025 cubren sugerencias explicitamente identificadas como tales. Pero muchas sugerencias valiosas surgen como comentarios casuales en la conversacion ("tal vez convendria...", "seria bueno que...", "a futuro se podria...") y no se perciben como sugerencias formales.
**Problema:** La directiva 12b dice "Toda sugerencia", pero en la practica solo las sugerencias prominentes se registran. Las observaciones incidentales, matices de razonamiento, y alternativas descartadas (que podrian ser utiles en el futuro) se pierden con la conversacion.
**Causa:** No hay mecanismo para detectar que algo en la conversacion es una sugerencia no registrada. El umbral de "importancia" es subjetivo.
**Posible mitigacion:** Un patron de "captura al final de respuesta": antes de terminar una respuesta, revisar si se menciono algo que deberia persistirse. O un formato de conversacion que separe explicitamente observaciones persistibles de comunicacion efimera.

### Gap 5: Contexto de agentes - VALIDACION POST-DELEGACION AUSENTE
**Severidad:** Media
**Estado actual:** M-014 (checklist de contexto) y M-015 (perfiles de herencia) cubren el lado de entrada. Pero no hay mecanismo que valide si el agente realmente tuvo contexto suficiente DESPUES de ejecutar.
**Problema:** Solo se detecta contexto insuficiente cuando el agente produce output incorrecto. No hay feedback loop que registre "el agente pregunto por X que no se le dio" o "el agente asumio Y incorrectamente por falta de contexto".
**Causa:** Los agentes (Tasks) operan de forma fire-and-forget. No hay mecanismo de post-mortem automatico de la calidad de la delegacion.
**Posible mitigacion:** Un paso de validacion post-agente: revisar el output y verificar si hubo asunciones incorrectas. Registrar en LEARNINGS patrones de contexto faltante por tipo de agente.

---

## 4. Resumen Cuantitativo

| Dimension | Valor |
|-----------|-------|
| Total mitigaciones catalogadas | 25 |
| Preventivas | 20 |
| Detectivas | 3 (M-003, M-016, M-024) |
| Correctivas | 1 (M-016, tambien detectiva) |
| Compensatorias | 0 |
| Con enforcement automatico | 0 |
| Puramente directivas de comportamiento | 25 (100%) |
| Tipos de perdida bien cubiertos (>=5 mitigaciones) | 3 (estado, re-descubrimiento, duplicacion) |
| Tipos de perdida mal cubiertos (<=2 mitigaciones) | 3 (compresion, inter-proyecto, crecimiento) |
| Gaps criticos identificados | 5 |

### Conclusion principal

La Metodologia General v3 tiene una cobertura amplia y profunda para **perdida de estado** y **re-descubrimiento** (los tipos mas frecuentes). Sin embargo, tiene tres debilidades estructurales:

1. **Ningun mecanismo es forzado.** Todo depende de disciplina de comportamiento. En los momentos de mayor presion (cuando la proteccion es mas necesaria), es cuando mas probable es que se salten las directivas.

2. **Perdida por compresion no tiene mitigacion directa.** Es el unico tipo de perdida que ocurre sin accion (ni falta de accion) de Claude: es un evento del sistema. Las mitigaciones existentes solo reducen la cantidad de informacion en riesgo.

3. **Los proyectos son silos de conocimiento.** La capa de metodologia general se comparte, pero los learnings y patrones de proyecto no se cruzan. Un descubrimiento valioso en un proyecto muere localmente.
