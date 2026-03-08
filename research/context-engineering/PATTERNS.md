# Patrones y Anti-Patrones de Gestion de Contexto
**Fecha:** 2026-02-25 | **Version:** 1.0
**Historia:** CE-005 | **Investigador:** Claude (Context Engineering)

---

## Patrones (que funciona)

### P-001: Arquitectura de memoria en capas
**Categoria:** organizacion
**Contexto:** Cualquier flujo de trabajo con IA que involucre multiples proyectos y sesiones recurrentes.
**Problema:** El conocimiento necesario para trabajar en un proyecto es una mezcla de preferencias personales (globales), convenciones del proyecto, y conocimiento tecnico acumulado. Sin estructura, todo termina en un unico archivo que crece sin limite o se fragmenta en archivos dispersos sin jerarquia.
**Solucion:** Separar la memoria en tres capas con propositos distintos: (1) User Memory con preferencias globales y referencias a la metodologia, (2) Project Memory con un puntero al repositorio centralizado, y (3) Context Repository con el conocimiento real organizado por proyecto. Cada capa se carga automaticamente al inicio de sesion mediante @imports. La capa global se comparte entre todos los proyectos; la capa de proyecto es especifica.
**Ejemplo real:** El sistema actual usa `~/.claude/CLAUDE.md` (User Memory) con @imports a `C:/claude_context/metodologia_general/` (6 archivos core), y cada proyecto tiene su propio directorio en `C:/claude_context/[clasificador]/[proyecto]/` con CLAUDE.md, TASK_STATE.md, LEARNINGS.md, etc. Cuando se trabaja en Sprint Backlog Manager, se cargan automaticamente la metodologia general + las decisiones especificas de SBM (PostgreSQL en vez de SQLite, IDs atomicos via sequences).
**Evidencia:** Definido en `06-memory-sync.md`. Operativo en 10+ proyectos activos. Incidente INC-2026-02-04 (overhead de contexto) demostro que sin esta estructura, 15+ documentos se cargaban sin discriminacion; la reorganizacion en capas resolvio el problema.
**Trade-offs:** Requiere disciplina para mantener la separacion (no mezclar conocimiento global con especifico). El patron de redireccion (punteros en el proyecto a archivos en claude_context) agrega una indirecta que puede confundir a nuevos usuarios. Overhead de setup inicial para proyectos nuevos.

---

### P-002: Registro-antes-de-investigar
**Categoria:** resiliencia
**Contexto:** Cualquier sesion de debugging, testing manual, o investigacion exploratoria donde se encuentran errores o comportamientos inesperados.
**Problema:** Cuando se encuentra un error, el instinto natural es investigar la causa inmediatamente. Pero si la sesion se interrumpe durante la investigacion, se pierde tanto el error como el progreso del debugging. La siguiente sesion no sabe que error se encontro ni que hipotesis se descartaron.
**Solucion:** Al encontrar un error: (1) copiar el error textualmente al TASK_STATE o test log, (2) anotar contexto (que paso se ejecuto, que se esperaba), (3) recien entonces investigar. Esta secuencia invierte la prioridad natural: primero preservar, despues analizar.
**Ejemplo real:** En LinkedIn Transcript Extractor (INC-2026-02-10), multiples sesiones de debugging del CollectionCaptureOrchestrator (discovery returning 0 courses) se interrumpieron sin registrar las hipotesis descartadas. Cada sesion nueva repetia el mismo diagnostico. Despues de implementar "registrar PRIMERO", el incidente INC-2026-02-25 del Orchestrator E2E mostro que los pasos ejecutados SI quedaron registrados y la sesion siguiente pudo retomar sin repetir trabajo.
**Evidencia:** Directiva 12a en `03-obligatory-directives.md`. Incidente INC-2026-02-10 como motivacion. Incidente INC-2026-02-25 como evidencia de efectividad.
**Trade-offs:** Agrega ~30 segundos antes de cada investigacion. Puede sentirse como "burocracia" cuando el fix parece obvio. Pero el costo de NO hacerlo es 30-60 minutos de re-descubrimiento por sesion interrumpida.

---

### P-003: Persistencia inmediata de sugerencias
**Categoria:** resiliencia
**Contexto:** Cualquier sesion donde surgen ideas, sugerencias, o recomendaciones como parte natural de la conversacion, especialmente cuando no son el foco principal del trabajo.
**Problema:** Las sugerencias que surgen durante el trabajo (herramientas nuevas, mejoras de proceso, features para otros proyectos) son el tipo de contexto mas vulnerable porque no son "trabajo en curso" (no hay codigo), no son errores (no hay stack trace), son efimeras por naturaleza, y su valor solo se reconoce cuando se necesitan.
**Solucion:** Escribir toda sugerencia a un archivo persistente INMEDIATAMENTE al formularla, antes de continuar con otro trabajo. Usar destinos claros segun tipo: sugerencia al proyecto actual en TASK_STATE (seccion "Sugerencias Pendientes"), sugerencia de proceso en CONTINUOUS_IMPROVEMENT.md, idea de feature en PRODUCT_BACKLOG.md, hallazgo tecnico en LEARNINGS.md.
**Ejemplo real:** En Gaia Protocol (INC-2026-02-25), sugerencias sobre herramientas MCP para Unity quedaron solo en la conversacion. La sesion se interrumpio por limite de contexto. El usuario pregunto por las sugerencias en la sesion siguiente y no se pudieron recuperar. Costo: 30 minutos de re-analisis y posible perdida de matices del razonamiento original.
**Evidencia:** Directiva 12b en `03-obligatory-directives.md`. Incidente INC-2026-02-25 (Gaia Protocol) como motivacion directa.
**Trade-offs:** Interrumpe el flujo de pensamiento. Las sugerencias menores ("tal vez convendria...") pueden no alcanzar el umbral percibido de "importancia" y se pierden igual. No hay mecanismo automatico que detecte sugerencias no persistidas.

---

### P-004: WIP commits como checkpoints
**Categoria:** resiliencia
**Contexto:** Cualquier sesion de desarrollo donde se generan cambios de codigo, especialmente antes de transiciones de actividad (coding a testing, antes de lanzar agentes, antes de operaciones largas).
**Problema:** El codigo no commiteado es vulnerable a multiples tipos de perdida: interrupcion de sesion, error del agente que sobreescribe archivos, reset accidental. Un stash o un worktree sin commit es codigo en riesgo.
**Solucion:** Hacer commits WIP (Work In Progress) agresivamente en momentos clave: despues de que un agente completa una historia, antes de lanzar la siguiente ola de trabajo, despues de code review como checkpoint pre-fix, antes de pruebas manuales. Los commits WIP se pueden squashear al final para mantener un historial limpio.
**Ejemplo real:** Definido como politica en la directiva 12c. En Sprint Backlog Manager, antes de cada ola de implementacion paralela se hacian WIP commits del trabajo de la ola anterior, lo que permitia volver a un estado conocido si los agentes introducian regresiones.
**Evidencia:** Directiva 12c, seccion "WIP commits agresivos" en `03-obligatory-directives.md`. La decision de SBM de usar PostgreSQL sequences para IDs (en vez de archivos de texto) tambien aplica este principio: usar mecanismos con persistencia garantizada.
**Trade-offs:** Historial de git mas ruidoso (mitigable con squash). Requiere disciplina para hacer el commit en el momento justo. No protege conocimiento contextual, solo codigo.

---

### P-005: Backlog como gate de cambios
**Categoria:** organizacion
**Contexto:** Cualquier proyecto donde se realizan multiples cambios a lo largo del tiempo, incluyendo features, bugfixes, refactors, y deuda tecnica.
**Problema:** Sin un registro centralizado, los cambios se hacen ad-hoc, se pierde la trazabilidad, y diferentes sesiones pueden trabajar en el mismo problema sin saberlo. Los bugs encontrados durante una sesion se arreglan "en el momento" y no quedan registrados como trabajo realizado.
**Solucion:** TODO cambio de codigo pasa por backlog primero, sin excepcion (salvo typos y formateo). Bugs reportados, features pedidos, bugs encontrados por Claude, tests fallidos: todo se registra como historia con ID unico antes de implementar. Usar agente product-owner para crear historias con formato estandar.
**Ejemplo real:** En Sprint Backlog Manager, la colision de IDs (INC-2026-02-05) ocurrio exactamente porque el backlog se gestionaba manualmente sin garantias de atomicidad. La solucion fue mover el ID Registry a PostgreSQL con sequences atomicas. Antes de eso, sesiones concurrentes podian asignar el mismo ID a historias diferentes.
**Evidencia:** Directiva 3 en `03-obligatory-directives.md`. Incidente INC-2026-02-05 como caso donde la falta de un registro centralizado causo colisiones. LEARNINGS.md de SBM documenta "ID Registry en DB: evita colisiones de IDs entre sesiones."
**Trade-offs:** Agrega overhead a cambios triviales. Puede incentivar saltear el proceso para "algo rapido." Pero el costo de no hacerlo es trabajo no trackeado, duplicacion, y colisiones.

---

### P-006: Extension sin eliminacion
**Categoria:** persistencia
**Contexto:** Cuando se necesita cambiar un comportamiento existente o agregar una nueva aproximacion a un problema ya resuelto.
**Problema:** Eliminar codigo operativo para reemplazarlo por una nueva version destruye conocimiento implicito: como funcionaba antes, que edge cases cubria, por que se diserio asi. Si la nueva version tiene problemas, no hay referencia para volver atras.
**Solucion:** Al implementar nuevas aproximaciones, NUNCA eliminar codigo operativo. Usar strategy pattern (multiples estrategias intercambiables), feature flags (habilitar/deshabilitar via configuracion), parametros opcionales (nuevo comportamiento como opcion, default = original), o additive-only (agregar endpoints/modos, no reemplazar).
**Ejemplo real:** En YouTube RAG (INC-2025-09-20), la violacion de este principio causo la creacion de main_test.py, main_real.py, main_simple.py: cada sesion creo una "nueva version" sin saber que existian las anteriores. La mitigacion fue consolidar en un unico main.py con variables de entorno para cada modo (PROCESSING_MODE=mock|real|hybrid). En Recetario (Flutter), el code review (CODE_REVIEW_LEARNINGS.md, R001) definio un patron estandar para features opcionales usando providers condicionales.
**Evidencia:** Directiva 5 en `03-obligatory-directives.md`. Incidente INC-2025-09-20 como caso de violacion. DEVELOPMENT_GUIDELINES.md como prevencion documentada. CODE_REVIEW_LEARNINGS.md R001 como implementacion en Flutter.
**Trade-offs:** Puede llevar a acumulacion de estrategias no usadas. Requiere limpieza periodica de opciones verdaderamente obsoletas. Codigo mas complejo por la coexistencia de multiples modos.

---

### P-007: Contexto completo al delegar
**Categoria:** delegacion
**Contexto:** Cuando se delega trabajo a agentes especializados (backend developer, test engineer, code reviewer, etc.) via herramientas de sub-tareas.
**Problema:** Un agente que recibe contexto parcial produce output incorrecto, incompleto, o basado en asunciones que no coinciden con la realidad del proyecto. Esto genera re-trabajo y a veces introduce bugs.
**Solucion:** Antes de delegar, verificar checklist: objetivo claro (que lograr, no solo que hacer), nombres exactos (clases, archivos, funciones), contexto de arquitectura (como encaja en el sistema), specs tecnicas (INCLUIR contenido completo, no solo referenciar), restricciones (que NO hacer), criterios de exito. Regla de oro: si el agente necesita leer otro documento para entender la tarea, INCLUIR ese contenido en el prompt.
**Ejemplo real:** El sistema de herencia de perfiles de agentes (BASE + ESPECIALIZACION + contexto) estandariza la composicion de contexto. Cuando se delega a un nodejs-backend-developer, se incluye AGENT_DEVELOPER_BASE.md + AGENT_DEVELOPER_NODEJS.md + contexto especifico del proyecto. Sin esta composicion, el agente no conoce las convenciones del stack ni las restricciones del proyecto.
**Evidencia:** Directiva 1 en `03-obligatory-directives.md`. Sistema de herencia definido en `agents/README.md`. Gap 5 del catalogo de mitigaciones identifica que la validacion post-delegacion aun es debil.
**Trade-offs:** Preparar contexto completo toma tiempo (1-5 minutos segun complejidad). Puede consumir mucha ventana de contexto del agente. El juicio sobre que es "suficiente" es subjetivo. Pero el costo de contexto insuficiente es mucho mayor: output inutilizable + tiempo de correccion.

---

### P-008: Limites de archivo con limpieza proactiva
**Categoria:** limpieza
**Contexto:** Proyectos con multiples sesiones de trabajo acumulado donde los archivos de contexto crecen con cada sesion.
**Problema:** Sin limites, los archivos de contexto crecen indefinidamente. Un CLAUDE.md de 500 lineas consume ventana de contexto sin aportar valor proporcional. La informacion historica (historias completadas, sesiones anteriores, decisiones ya implementadas) diluye la informacion actual y relevante.
**Solucion:** Definir limites estrictos de lineas por archivo (CLAUDE.md: 150, TASK_STATE: 200, BACKLOG: 300, ARCHITECTURE: 400, LEARNINGS: 200). Cuando un archivo excede su limite, ejecutar limpieza ANTES de continuar trabajando. Mover informacion historica a `archive/` (sessions, stories, architecture). Principio: "Si esta en contexto activo, debe ser util AHORA."
**Ejemplo real:** En Metodologia General (INC-2026-02-04), 15+ @imports se cargaban en cada sesion de cada proyecto, consumiendo ventana de contexto con directivas no siempre relevantes. La consolidacion de v2 a v3 redujo de 15 documentos a 6 core + 1 bajo demanda. Los limites de archivo se definieron como consecuencia directa de este incidente.
**Evidencia:** `07-project-memory-management.md` completo. Incidente INC-2026-02-04 como motivacion. Principio "Si esta en contexto activo, debe ser util AHORA" operativo en el sistema de archivado.
**Trade-offs:** El archivado mueve informacion fuera del acceso inmediato. Decisiones recientes archivadas pueden necesitar re-cargarse. La limpieza consume tiempo (5-15 min). La decision de que archivar requiere juicio sobre que es "actual" vs "historico."

---

### P-009: Seccion "Sesion Activa" como buffer de contexto inmediato
**Categoria:** resiliencia
**Contexto:** Cualquier sesion de trabajo activo, especialmente cuando involucra debugging, testing manual, o trabajo complejo multi-paso.
**Problema:** El TASK_STATE captura estado de largo plazo (tareas, proximos pasos), pero no el contexto inmediato de "que estoy haciendo AHORA MISMO." Si la sesion se interrumpe, la siguiente sesion sabe que tareas hay pero no en que paso especifico se estaba, que hipotesis se tenia, o que resultado se acaba de observar.
**Solucion:** Mantener una seccion "Sesion Activa" en TASK_STATE que capture: fecha/hora de inicio, actividad actual (implementando/testeando/debuggeando/investigando), detalle de la tarea, hipotesis en curso (si esta investigando), ultimo resultado (output, error, estado). Actualizar en cada transicion de actividad (coding a testing, testing a debugging, etc.). Al cerrar sesion, archivar o borrar esta seccion.
**Ejemplo real:** En el incidente del Orchestrator E2E (INC-2026-02-25), los pasos 1-3 del test estaban registrados con resultado PASS, los servicios activos documentados (orchestrator en :8765/:3000, web-monitor en :4200), y los pasos 4-6 marcados como PENDIENTE. La sesion siguiente pudo determinar exactamente donde retomar.
**Evidencia:** Directiva 12a en `03-obligatory-directives.md`, seccion "Sesion Activa". Incidente INC-2026-02-25 como caso donde el patron funciono parcialmente (pasos ejecutados registrados, pero se perdio si los pendientes se intentaron o no).
**Trade-offs:** Requiere actualizacion frecuente (cada transicion de actividad). Compite con la urgencia del trabajo inmediato. La seccion debe borrarse al cerrar sesion, creando una ventana de vulnerabilidad entre la ultima actualizacion y el cierre.

---

### P-010: Plan de trabajo escrito antes de ejecutar
**Categoria:** organizacion
**Contexto:** Trabajo complejo que involucra multiples historias, olas de trabajo paralelo, o coordinacion de multiples agentes.
**Problema:** Sin un plan escrito, el trabajo complejo se ejecuta de forma ad-hoc. Si la sesion se interrumpe, la siguiente sesion no sabe cuantas olas habia, que agentes se lanzaron, que dependencias existen entre historias, ni cual era el plan post-implementacion.
**Solucion:** Antes de trabajo complejo, documentar el plan en TASK_STATE: olas de trabajo (que historias en cada ola), dependencias entre historias/olas, agentes a lanzar y con que tarea, plan post-implementacion (review, commit, merge). Incluir estado esperado de cada agente (que resultado se espera, que archivos deberia tocar).
**Ejemplo real:** En Sprint Backlog Manager, el desarrollo se organizo en olas: primera ola con setup de base de datos + esquema, segunda ola con implementacion de tools MCP en paralelo (4 agentes simultaneos), tercera ola con tests de integracion. El plan escrito permitio coordinar los 4 agentes sin conflictos.
**Evidencia:** Directiva 12c, seccion "Plan de trabajo escrito antes de ejecutar" en `03-obligatory-directives.md`. Directiva 12c, seccion "Checkpoints pre/post agentes paralelos."
**Trade-offs:** Overhead de 5-10 minutos antes de empezar. Puede sentirse innecesario para trabajo "simple" que resulta complejo. El plan puede quedar desactualizado si surgen problemas inesperados durante la ejecucion.

---

### P-011: Rigor intelectual con etiquetado explicito
**Categoria:** transferencia
**Contexto:** Cualquier conversacion donde se mezclan hechos observados con hipotesis, especialmente durante debugging o analisis de problemas.
**Problema:** Cuando informacion de diferentes niveles de certeza se mezcla sin distinguir, la sesion siguiente (o un agente delegado) no puede determinar que es un hecho confirmado y que es una conjetura. Esto lleva a tratar hipotesis como hechos o a re-verificar hechos ya confirmados.
**Solucion:** Etiquetar explicitamente informacion como [HECHO] (dato observado directamente), [HIPOTESIS] (explicacion sin verificar), [DESCONOCIDO] (lo que no sabemos), o [VERIFICAR] (accion para confirmar). Preferir "no se, necesito investigar" a inventar una explicacion.
**Ejemplo real:** En LinkedIn Transcript Extractor (INC-2026-02-10), las sesiones de debugging repetian hipotesis ya descartadas porque no habia registro de cuales eran hechos confirmados vs hipotesis en investigacion. "CollectionCaptureOrchestrator discovery returning 0 courses" aparecia como known issue pero sin indicar si la causa raiz era un [HECHO] confirmado o una [HIPOTESIS] sin verificar.
**Evidencia:** Directiva 4 en `03-obligatory-directives.md`. Incidente INC-2026-02-10 como caso donde la falta de etiquetado llevo a hipotesis circulares.
**Trade-offs:** Agrega friccion a la comunicacion natural. Las etiquetas solo son utiles si se persisten en archivos; en la conversacion efimera, se pierden con el contexto. Requiere juicio sobre que merece ser etiquetado.

---

### P-012: Resolver issues al tocar un archivo
**Categoria:** limpieza
**Contexto:** Cuando se modifica un archivo como parte de una historia o epic, y existen issues pendientes en el backlog que afectan al mismo archivo.
**Problema:** Tocar un archivo multiples veces en commits separados genera churn innecesario. Ademas, el contexto del archivo ya esta cargado cuando se trabaja en el, por lo que resolver un issue pendiente en ese momento es mas eficiente que volver al archivo en una sesion futura.
**Solucion:** Antes de modificar un archivo, revisar el backlog por issues pendientes en ese mismo archivo y resolverlos en conjunto, siempre que el fix sea <= 3 puntos y este relacionado. Si es complejo o no relacionado, crear historia separada.
**Ejemplo real:** En Recetario (Flutter), el code review definio la regla R002: "Si un archivo se modifica como parte de un EPIC o story, revisar el backlog por issues pendientes en ese mismo archivo y resolverlos en conjunto." Esto surgio de observar que la logica de extraccion de imagenes estaba duplicada entre el modo heuristic y headings, y el momento de corregirlo era mientras se trabajaba en esos archivos.
**Evidencia:** CODE_REVIEW_LEARNINGS.md del proyecto Recetario, regla R002. Incidente INC-2026-02-13 que identifico observaciones de code review diferidas.
**Trade-offs:** Puede expandir el alcance de una historia mas alla de lo planeado. Requiere revisar el backlog antes de cada modificacion (overhead menor). Solo aplica cuando el fix es trivial; issues complejos deben tener su propia historia.

---

## Anti-Patrones (que evitar)

### AP-001: Confiar en la conversacion
**Categoria:** resiliencia
**Contexto:** Aparece cuando informacion valiosa (sugerencias, decisiones, hipotesis de debugging, planes de trabajo) queda exclusivamente en el contexto de la conversacion sin escribirse a archivos persistentes.
**Problema:** La conversacion es efimera por naturaleza. Se pierde por: limite de contexto alcanzado, error del sistema, cierre accidental, compresion automatica de mensajes previos. Cuando se pierde, se pierde TODO el conocimiento que contenia y que no fue escrito a archivos.
**Sintomas:** Al retomar una sesion, el usuario pregunta "que sugerencias habia?" y no se pueden recuperar. La sesion nueva repite diagnosticos ya realizados. Se descubren "de nuevo" problemas ya identificados. El TASK_STATE no tiene seccion de sesion activa ni sugerencias pendientes.
**Solucion:** Aplicar patron P-002 (registrar antes de investigar), P-003 (persistencia inmediata de sugerencias), P-009 (seccion "Sesion Activa"). Regla general: si una pieza de informacion no puede perderse, debe estar en un archivo, no solo en la conversacion.
**Incidente relacionado:** INC-2026-02-25 (Gaia Protocol, sugerencias MCP perdidas). INC-2026-02-10 (LinkedIn, hipotesis de debugging perdidas entre sesiones).

---

### AP-002: Delegar sin contexto suficiente
**Categoria:** delegacion
**Contexto:** Aparece cuando se lanza un agente con una instruccion generica ("implementa el endpoint X") sin proveer nombres exactos, specs tecnicas, restricciones, ni contexto de arquitectura. Tambien cuando se referencia documentos en lugar de incluir su contenido.
**Problema:** El agente opera con informacion parcial y llena los vacios con asunciones. Produce output que parece correcto superficialmente pero tiene errores sutiles: nombres de archivos incorrectos, patrones inconsistentes con el proyecto, dependencias mal resueltas, edge cases ignorados.
**Sintomas:** El agente hace preguntas que deberian haberse respondido en el prompt. El output requiere correccion manual significativa. Se repite la delegacion con mas contexto (doble trabajo). El agente introduce patrones inconsistentes con el proyecto.
**Solucion:** Aplicar patron P-007 (contexto completo al delegar). Usar el sistema de herencia de perfiles (BASE + ESPECIALIZACION + contexto del proyecto). Incluir contenido de specs, no solo referencias.
**Incidente relacionado:** Gap 5 del catalogo de mitigaciones identifica que no hay validacion post-delegacion. No hay incidente especifico registrado, pero es la motivacion de la directiva 1 y el sistema de perfiles de agentes.

---

### AP-003: Crecimiento sin limites de archivos de contexto
**Categoria:** limpieza
**Contexto:** Aparece en proyectos con multiples sesiones de trabajo donde cada sesion agrega informacion al CLAUDE.md, TASK_STATE.md, o PRODUCT_BACKLOG.md sin limpiar lo que ya no es relevante.
**Problema:** Los archivos de contexto crecen indefinidamente. El User Memory acumula @imports. El BACKLOG tiene historias completadas con detalle completo. El TASK_STATE tiene registros de 5 sesiones anteriores. El resultado: cada sesion nueva consume gran parte de su ventana de contexto solo en cargar informacion historica, diluyendo la atencion sobre lo que es actual y relevante.
**Sintomas:** Archivos que exceden 300-500 lineas. Sesiones que se sienten "lentas" desde el inicio. Directivas que se ignoran porque hay demasiadas. @imports que cargan documentos no relevantes para la tarea actual.
**Solucion:** Aplicar patron P-008 (limites con limpieza proactiva). Principio: "Si esta en contexto activo, debe ser util AHORA." Archivar historias completadas, sesiones anteriores, y decisiones ya implementadas.
**Incidente relacionado:** INC-2026-02-04 (Metodologia General, 15+ @imports sobrecargando el contexto). La migracion de v2 a v3 fue directamente una respuesta a este anti-patron.

---

### AP-004: Duplicar en vez de parametrizar
**Categoria:** organizacion
**Contexto:** Aparece cuando una sesion nueva necesita un comportamiento ligeramente diferente al existente y, por falta de contexto sobre las decisiones de diserio previas, crea un archivo nuevo en lugar de parametrizar el existente.
**Problema:** Se generan multiples versiones de archivos con propositos similares (main.py, main_test.py, main_real.py, main_simple.py). Nadie sabe cual es la version "oficial". Los cambios se aplican al archivo incorrecto. Las correcciones deben replicarse en multiples archivos. El debugging se complica porque no hay claridad sobre que codigo se ejecuta.
**Sintomas:** Archivos con sufijos como `_test`, `_real`, `_simple`, `_backup`, `_v2`. Multiples implementaciones de la misma funcionalidad con diferencias menores. Confusion sobre cual archivo usar en cada entorno.
**Solucion:** Aplicar patron P-006 (extension sin eliminacion) usando variables de entorno o parametros de configuracion. Un unico punto de entrada que maneje todos los modos. Documentar la decision de diserio para que sesiones futuras la conozcan. Checklist pre-creacion: "Puede resolverse con una variable de configuracion?"
**Incidente relacionado:** INC-2025-09-20 (YouTube RAG, 4 versiones de main.py). DEVELOPMENT_GUIDELINES.md creado como respuesta directa.

---

### AP-005: Observaciones diferidas sin mecanismo de seguimiento
**Categoria:** transferencia
**Contexto:** Aparece cuando el resultado de un code review, una investigacion, o una sesion de debugging genera observaciones que se registran como "diferidas" o "pendientes" en TASK_STATE sin convertirse en items accionables del backlog.
**Problema:** Las observaciones diferidas son deuda de proceso: informacion capturada pero no transformada en accion. Quedan en un limbo entre "registrado" y "procesado." Cuando el TASK_STATE se limpia (por limites de archivo o cambio de sesion), las observaciones pueden desaparecer sin haberse procesado. Incluso si persisten, se convierten en ruido que se ignora.
**Sintomas:** Seccion "Diferido" o "Pendiente" en TASK_STATE que crece entre sesiones. Observaciones de code review que no aparecen en el backlog. Items "pendientes" que llevan semanas sin procesarse. Al limpiar TASK_STATE, no hay certeza de si los items diferidos fueron procesados o descartados.
**Solucion:** Completar el flujo en la misma sesion: code review -> observaciones -> historias en backlog. Si no es posible, crear un checklist de cierre de sesion que incluya "procesar items diferidos" (convertir en historias o descartar explicitamente).
**Incidente relacionado:** INC-2026-02-13 (Recetario, observaciones de code review diferidas sin traslado al backlog).

---

### AP-006: Investigar sin registrar hipotesis descartadas
**Categoria:** resiliencia
**Contexto:** Aparece durante sesiones de debugging donde se prueban multiples hipotesis sobre la causa de un problema. Se descarta cada hipotesis mentalmente pero no se registra que se probo ni por que se descarto.
**Problema:** El debugging es el tipo de trabajo mas vulnerable a la perdida de contexto porque el conocimiento valioso son las hipotesis descartadas ("trabajo negativo"), no solo la solucion final. Cuando la sesion se interrumpe, la siguiente sesion no sabe que caminos ya se exploraron y los recorre de nuevo.
**Sintomas:** "Ya intentaste X?" como pregunta recurrente entre sesiones. Las mismas hipotesis se prueban multiples veces. Known issues que persisten como "pendientes" sin registro del progreso de investigacion. Sensacion de "deja vu" durante debugging.
**Solucion:** Aplicar patron P-002 (registrar antes de investigar). Mantener un log de hipotesis en TASK_STATE o en un archivo dedicado de debugging con formato: hipotesis, como se probo, resultado, conclusion. Incluir campo "Hipotesis en curso" en seccion "Sesion Activa."
**Incidente relacionado:** INC-2026-02-10 (LinkedIn, sesiones de debugging repetitivas del CollectionCaptureOrchestrator).

---

## Matriz de Aplicabilidad

| Patron | Micro (1 dev) | Small (2-3) | Medium (4-8) | Large (9-20) |
|--------|:---:|:---:|:---:|:---:|
| P-001: Arquitectura de memoria en capas | Recomendado | Obligatorio | Obligatorio | Obligatorio |
| P-002: Registro-antes-de-investigar | Obligatorio | Obligatorio | Obligatorio | Obligatorio |
| P-003: Persistencia inmediata de sugerencias | Recomendado | Obligatorio | Obligatorio | Obligatorio |
| P-004: WIP commits como checkpoints | Recomendado | Obligatorio | Obligatorio | Obligatorio |
| P-005: Backlog como gate de cambios | Recomendado | Obligatorio | Obligatorio | Obligatorio |
| P-006: Extension sin eliminacion | Obligatorio | Obligatorio | Obligatorio | Obligatorio |
| P-007: Contexto completo al delegar | Obligatorio | Obligatorio | Obligatorio | Obligatorio |
| P-008: Limites de archivo con limpieza | Opcional | Recomendado | Obligatorio | Obligatorio |
| P-009: Sesion Activa como buffer | Recomendado | Obligatorio | Obligatorio | Obligatorio |
| P-010: Plan escrito antes de ejecutar | Opcional | Recomendado | Obligatorio | Obligatorio |
| P-011: Rigor intelectual con etiquetado | Recomendado | Recomendado | Obligatorio | Obligatorio |
| P-012: Resolver issues al tocar archivo | Opcional | Recomendado | Recomendado | Obligatorio |

| Anti-patron | Riesgo en Micro | Riesgo en Small | Riesgo en Medium+ |
|-------------|:---:|:---:|:---:|
| AP-001: Confiar en la conversacion | Alto | Critico | Critico |
| AP-002: Delegar sin contexto suficiente | Alto | Alto | Critico |
| AP-003: Crecimiento sin limites | Medio | Alto | Critico |
| AP-004: Duplicar en vez de parametrizar | Alto | Alto | Critico |
| AP-005: Observaciones diferidas sin seguimiento | Bajo | Medio | Alto |
| AP-006: Investigar sin registrar hipotesis | Alto | Alto | Critico |

---

## Notas Metodologicas

1. Todos los patrones documentados tienen al menos un ejemplo real de los proyectos del ecosistema.
2. Los anti-patrones estan vinculados a incidentes registrados cuando existen.
3. La matriz de aplicabilidad refleja que algunos patrones son criticos independientemente de la escala (P-002, P-006, P-007), mientras otros escalan con la complejidad del proyecto.
4. Los patrones con categoria "resiliencia" (P-002, P-003, P-004, P-009) son los mas directamente vinculados a la pregunta central del proyecto de investigacion: como minimizar la perdida de informacion valiosa entre sesiones.
5. La debilidad transversal identificada (Gap 3 del catalogo de mitigaciones) es que NINGUN patron tiene enforcement automatico. Todos dependen de disciplina de comportamiento. Esto sugiere que la linea de investigacion mas prometedora es la automatizacion via hooks o tooling (MCP servers, pre-commit hooks, scripts de validacion).

---

**Version:** 1.0 | **Ultima actualizacion:** 2026-02-25
