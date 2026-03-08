# Taxonomia de Tipos de Contexto
**Fecha:** 2026-02-25 | **Version:** 1.0
**Historia:** CE-004 | **Investigador:** Claude (Context Engineering)

---

## 1. Modelo General

El contexto en un flujo de trabajo humano-IA no es monolitico. Es un conjunto heterogeneo de informacion con diferentes origenes, ciclos de vida, niveles de volatilidad y costos de perdida. Tratarlo como una masa indiferenciada lleva a dos extremos: o se persiste todo (saturando la ventana), o no se persiste nada (perdiendo informacion critica).

Esta taxonomia organiza el contexto en **tres categorias principales** segun su naturaleza:

- **Operacional:** Contexto sobre el trabajo en curso (que estoy haciendo, que paso, que sigue).
- **Estructural:** Contexto sobre el sistema y sus decisiones (como esta diseñado, por que se eligio X).
- **Relacional:** Contexto sobre las interacciones entre actores (que necesita un agente, que prefiere el usuario, que aprendio otro proyecto).

Dentro de cada categoria se identifican tipos especificos con atributos medibles que permiten diseñar estrategias de gestion diferenciadas.

### Dimensiones de cada tipo

| Dimension | Descripcion |
|-----------|-------------|
| **Volatilidad** | Con que frecuencia cambia. Alta = cambia dentro de una sesion. Media = cambia entre sesiones. Baja = cambia entre sprints o menos. |
| **Valor relativo** | Que tan costoso es perderlo, medido en tiempo de re-descubrimiento y riesgo de errores. |
| **Ventana de relevancia** | Periodo durante el cual el contexto es util. Puede ser minutos, horas, dias, o permanente. |

---

## 2. Tipos de Contexto

### T-001: Estado de Tarea Activa
**Categoria:** Operacional
**Volatilidad:** Alta - cambia con cada accion dentro de la sesion
**Valor relativo:** Critico - perderlo obliga a repetir trabajo o tomar decisiones sin informacion
**Ciclo de vida:**
- **Nace:** Al iniciar o retomar una tarea concreta
- **Pico de valor:** Durante la ejecucion activa y al momento de una interrupcion
- **Decae:** Al completar la tarea (se transforma en registro historico)
- **Caduca:** Cuando la tarea se archiva y sus resultados estan integrados en el producto
**Persistencia recomendada:** TASK_STATE.md, seccion "En Progreso". Actualizar en cada transicion de fase (coding -> testing -> debugging -> fix). Frecuencia minima: cada 30 minutos.
**Perdida tipica:** Interrupcion abrupta de sesion sin haber actualizado el estado. Incidente de referencia: orchestrator-test-e2e-interrumpido (pasos 4-6 quedaron como "PENDIENTE" sin saber si se intentaron).
**Ejemplo concreto:** En el proyecto Claude Orchestrator, una sesion de pruebas E2E tenia 6 pasos. Los primeros 3 se registraron con resultado PASS. La sesion se interrumpio y los pasos 4-6 quedaron marcados como pendientes en TASK_STATE, permitiendo retomar exactamente desde ese punto.

---

### T-002: Hipotesis de Debugging
**Categoria:** Operacional
**Volatilidad:** Alta - se generan, prueban y descartan en minutos
**Valor relativo:** Alto - las hipotesis descartadas son "trabajo negativo" cuya perdida causa circulos de re-investigacion
**Ciclo de vida:**
- **Nace:** Al encontrar un error o comportamiento inesperado
- **Pico de valor:** Mientras se investiga el problema (tanto las confirmadas como las descartadas)
- **Decae:** Al resolver el problema (las descartadas pierden valor pero mantienen utilidad de referencia)
- **Caduca:** Cuando el codigo subyacente cambia tanto que las hipotesis ya no aplican
**Persistencia recomendada:** TASK_STATE.md, seccion "Sesion Activa" campo "Hipotesis en curso". Registrar cada hipotesis ANTES de probarla. Marcar resultado (confirmada/descartada). Al resolver, mover la causa raiz a LEARNINGS.md si es un patron reutilizable.
**Perdida tipica:** Sesion de debugging interrumpida donde las hipotesis quedan solo en la conversacion. Incidente de referencia: linkedin-debugging-multisesion (30-60 min perdidos por sesion repitiendo hipotesis ya descartadas).
**Ejemplo concreto:** En LinkedIn Transcript Extractor, el problema "CollectionCaptureOrchestrator discovery returning 0 courses" requirio multiples sesiones. Cada sesion nueva repetia las mismas hipotesis que la anterior ya habia descartado, porque no habia registro del camino de investigacion.

---

### T-003: Resultados de Errores y Logs
**Categoria:** Operacional
**Volatilidad:** Alta - cada ejecucion genera nuevos mensajes
**Valor relativo:** Alto - un stack trace exacto es la diferencia entre diagnostico rapido y horas de re-reproduccion
**Ciclo de vida:**
- **Nace:** Al ejecutar codigo que falla o produce output inesperado
- **Pico de valor:** Inmediatamente al aparecer (contexto fresco para diagnostico)
- **Decae:** Al resolver el error (pero mantiene valor como referencia si el error recurre)
- **Caduca:** Cuando el codigo cambia y el error ya no es reproducible
**Persistencia recomendada:** TASK_STATE.md, copiar textualmente ANTES de investigar (regla: "registrar PRIMERO, investigar DESPUES"). Para errores recurrentes, documentar en LEARNINGS.md con patron de resolucion.
**Perdida tipica:** Investigar un error sin copiarlo primero, sesion se interrumpe, y el error no puede reproducirse facilmente. Incidente de referencia: linkedin-debugging-multisesion (stack traces no registrados entre sesiones).
**Ejemplo concreto:** El proyecto LinkedIn Learning Tracker tenia 2,700+ tests. Un fallo en CollectionCaptureOrchestrator producia mensajes de error que se perdian entre sesiones porque no se copiaban textualmente antes de empezar a investigar.

---

### T-004: Plan de Trabajo
**Categoria:** Operacional
**Volatilidad:** Media - se define al inicio de una sesion o sprint, se ajusta durante la ejecucion
**Valor relativo:** Alto - sin plan, el trabajo se vuelve reactivo y descoordinado
**Ciclo de vida:**
- **Nace:** Al planificar una sesion de trabajo, sprint, o ola de agentes paralelos
- **Pico de valor:** Durante la ejecucion (guia las decisiones de priorizacion)
- **Decae:** Al completar el trabajo planificado
- **Caduca:** Al cerrar la sesion o sprint (el plan se transforma en registro de lo ejecutado)
**Persistencia recomendada:** TASK_STATE.md, seccion "Plan de Ejecucion" con olas, dependencias y plan post-implementacion. Escribir ANTES de ejecutar. Actualizar al completar cada ola.
**Perdida tipica:** Iniciar trabajo complejo sin documentar el plan; si la sesion se interrumpe a mitad, no hay forma de saber que olas faltaban ni que dependencias existian.
**Ejemplo concreto:** En sesiones de trabajo paralelo con multiples agentes (worktrees + olas de delegacion), el plan escrito permite que una sesion nueva retome exactamente la ola pendiente sin re-analizar dependencias.

---

### T-005: Sugerencias e Ideas
**Categoria:** Operacional
**Volatilidad:** Alta - surgen espontaneamente durante la conversacion y desaparecen con ella
**Valor relativo:** Alto - son semillas de mejora cuyo valor solo se reconoce cuando se necesitan (despues de perderse)
**Ciclo de vida:**
- **Nace:** Espontaneamente durante el trabajo, como derivacion lateral del tema principal
- **Pico de valor:** En el momento de surgir (cuando el contexto que la motivo esta presente)
- **Decae:** Rapidamente si no se registra: en minutos pierde los matices y el razonamiento que la motivo
- **Caduca:** Cuando las condiciones que la motivaron cambian (ej: se refactoreo el modulo que tenia el problema)
**Persistencia recomendada:** Escritura INMEDIATA al surgir. Destino segun tipo: TASK_STATE seccion "Sugerencias Pendientes" para el proyecto actual, PRODUCT_BACKLOG como historia para features, CONTINUOUS_IMPROVEMENT.md para mejoras al proceso, LEARNINGS.md para hallazgos tecnicos.
**Perdida tipica:** Quedan solo en la conversacion como comentario casual ("tal vez convendria...") y se pierden con la sesion. Incidente de referencia: gaia-protocol-sugerencias-perdidas (~30 min de re-analisis para reconstruir sugerencias sobre herramientas MCP).
**Ejemplo concreto:** Durante desarrollo de Gaia Protocol, se discutieron sugerencias sobre herramientas adicionales para el Unity MCP Server. La sesion se interrumpio por limite de contexto. Las sugerencias no se habian escrito a archivo. La sesion siguiente tuvo que re-analizar desde cero, perdiendo matices del razonamiento original.

---

### T-006: Decisiones de Diseño y Razonamiento
**Categoria:** Estructural
**Volatilidad:** Baja - una vez tomada, una decision de diseño es estable por semanas o meses
**Valor relativo:** Critico - perder el "por que" de una decision lleva a revertirla, duplicarla, o contradecirla
**Ciclo de vida:**
- **Nace:** Al elegir entre alternativas durante diseño, implementacion, o debugging
- **Pico de valor:** Cuando alguien (otra sesion, otro agente) necesita entender por que algo esta hecho de cierta forma
- **Decae:** Lentamente; sigue siendo relevante mientras el diseño este vigente
- **Caduca:** Cuando el componente afectado se reemplaza completamente
**Persistencia recomendada:** ARCHITECTURE.md o ADR dedicado para decisiones arquitectonicas. Comentarios inline en el codigo para decisiones tecnicas locales. LEARNINGS.md para patrones generalizables. Escribir en el momento de la decision, no al cerrar sesion.
**Perdida tipica:** La decision queda en la conversacion; la siguiente sesion no sabe por que se eligio una estrategia y crea una alternativa, generando duplicacion o contradicciones. Incidente de referencia: youtube-rag-duplicacion-archivos (4 versiones de main.py porque cada sesion no sabia las decisiones de la anterior).
**Ejemplo concreto:** En YouTube RAG, la decision de por que main.py estaba estructurado de cierta forma no se persistio. Sesiones posteriores crearon main_test.py, main_real.py, y main_simple.py en lugar de parametrizar el original. La consolidacion posterior costo 2-3 horas.

---

### T-007: Conocimiento Arquitectonico
**Categoria:** Estructural
**Volatilidad:** Baja - cambia con refactors mayores, no con tareas individuales
**Valor relativo:** Critico - sin entendimiento de la arquitectura, cada cambio es una apuesta
**Ciclo de vida:**
- **Nace:** Al diseñar el sistema o al descubrir la estructura de un sistema existente
- **Pico de valor:** Permanente mientras el sistema exista; cada nueva tarea lo requiere
- **Decae:** Gradualmente a medida que la implementacion diverge de la documentacion
- **Caduca:** Al reemplazar el sistema completamente
**Persistencia recomendada:** ARCHITECTURE.md (max 400 lineas, focalizado en la version actual). Diagramas ASCII de componentes, flujos de datos, stack tecnologico con versiones. Actualizar al completar refactors significativos o al cambiar version del proyecto.
**Perdida tipica:** La arquitectura se entiende durante la sesion de diseño pero no se documenta formalmente. Sesiones futuras operan con entendimiento parcial, tomando decisiones que violan patrones existentes.
**Ejemplo concreto:** La Metodologia General v3 define limites claros para ARCHITECTURE.md (max 400 lineas) porque la experiencia demostro que documentos de arquitectura demasiado largos no se leen, y demasiado cortos no capturan las decisiones importantes.

---

### T-008: Estado de Entorno de Ejecucion
**Categoria:** Operacional
**Volatilidad:** Alta - servicios suben y bajan, puertos cambian, procesos mueren
**Valor relativo:** Medio - perderlo no causa errores logicos pero cuesta tiempo de re-setup
**Ciclo de vida:**
- **Nace:** Al levantar servicios, compilar, o configurar el entorno de trabajo
- **Pico de valor:** Durante pruebas manuales o integracion multi-servicio
- **Decae:** Al cerrar la sesion o apagar los servicios
- **Caduca:** Inmediatamente al terminar la sesion de testing (los puertos y procesos son efimeros)
**Persistencia recomendada:** TASK_STATE.md, seccion "Servicios Activos" con tabla de servicio, puerto, comando, estado. Registrar al levantar; actualizar si alguno cae o se reinicia.
**Perdida tipica:** La sesion siguiente no sabe en que puerto corria cada servicio ni con que comando se levanto. Incidente de referencia: orchestrator-test-e2e-interrumpido (servicios documentados como UP permitieron retomar, pero el re-setup igual costo 10-15 min).
**Ejemplo concreto:** En las pruebas E2E de Claude Orchestrator + Web Monitor, se documentaron tres servicios: orchestrator WS en :8765, orchestrator HTTP en :3000, y web-monitor en :4200. Gracias al snapshot, la sesion siguiente sabia exactamente que levantar.

---

### T-009: Contexto de Delegacion a Agentes
**Categoria:** Relacional
**Volatilidad:** Media - se construye una vez por delegacion, pero varia entre delegaciones
**Valor relativo:** Alto - contexto insuficiente produce output incorrecto que cuesta mas que hacer la tarea directamente
**Ciclo de vida:**
- **Nace:** Al preparar la delegacion de una tarea a un agente especializado
- **Pico de valor:** Durante la ejecucion del agente (es todo lo que el agente tiene para trabajar)
- **Decae:** Al recibir el resultado del agente (el contexto de entrada se integra en el output)
- **Caduca:** Cuando la tarea se completa; el contexto de delegacion ya no se necesita, pero el patron de "que contexto fue necesario" es valioso para futuras delegaciones
**Persistencia recomendada:** TASK_STATE.md, seccion pre-agentes (que agentes se lanzan, con que tarea, que se espera). El contexto en si no se persiste separadamente, pero la directiva 1 define un checklist: objetivo, nombres exactos, arquitectura, specs (contenido incluido, no referenciado), restricciones, criterios de exito.
**Perdida tipica:** Delegacion con contexto parcial: el agente no recibe nombres exactos de archivos, o recibe una referencia a un documento sin su contenido. Solo se detecta cuando el output es incorrecto. Catalogo de mitigaciones identifica como Gap 5 la ausencia de validacion post-delegacion.
**Ejemplo concreto:** El sistema de herencia de perfiles de agentes (BASE + ESPECIALIZACION + contexto del proyecto) fue diseñado para estandarizar el baseline de conocimiento. Sin el, cada delegacion dependia del juicio ad-hoc de Claude sobre que incluir.

---

### T-010: Preferencias y Convenciones del Usuario
**Categoria:** Relacional
**Volatilidad:** Baja - cambian con poca frecuencia; se acumulan incrementalmente
**Valor relativo:** Medio - no perderlas no causa errores, pero ignorarlas causa friccion y re-trabajo por desalineacion
**Ciclo de vida:**
- **Nace:** Al expresar el usuario una preferencia o al observarse un patron en sus decisiones
- **Pico de valor:** En cada interaccion (deben aplicarse siempre)
- **Decae:** Muy lentamente; solo si el usuario cambia de opinion
- **Caduca:** Rara vez; algunas preferencias son permanentes
**Persistencia recomendada:** User Memory (`~/.claude/CLAUDE.md`) para preferencias globales. Project CLAUDE.md para convenciones del proyecto. La capa de User Memory se carga automaticamente en toda sesion.
**Perdida tipica:** Preferencias expresadas verbalmente en una sesion que no se escriben al User Memory. La sesion siguiente no las conoce. No hay incidente especifico registrado, pero la seccion "Preferencias Personales de Trabajo" del User Memory actual es evidencia del mecanismo de proteccion.
**Ejemplo concreto:** El usuario tiene preferencias documentadas: "No usar emojis", "respuestas concisas", "siempre usar TaskCreate para tareas multi-paso", "build 0 errores 0 warnings siempre". Estas se cargan en cada sesion via User Memory y se aplican automaticamente.

---

### T-011: Estado Compartido entre Sesiones
**Categoria:** Relacional
**Volatilidad:** Media - cambia entre sesiones pero debe ser consistente en cada momento
**Valor relativo:** Alto - inconsistencias causan colisiones, conflictos y confusion
**Ciclo de vida:**
- **Nace:** Al crear un recurso compartido (ID Registry, backlog, configuracion)
- **Pico de valor:** Cuando multiples sesiones (o agentes) necesitan operar sobre el mismo recurso
- **Decae:** Nunca mientras el recurso este activo; su consistencia es permanentemente critica
- **Caduca:** Al deprecar el recurso
**Persistencia recomendada:** Para estado simple: archivos con convencion de escritura estricta (PRODUCT_BACKLOG.md con ID Registry). Para estado que requiere atomicidad: base de datos (PostgreSQL via Docker, como Sprint Backlog Manager). La eleccion depende de la frecuencia de acceso concurrente.
**Perdida tipica:** Colision de IDs cuando dos sesiones leen el mismo ID Registry sin mecanismo de locking. Incidente de referencia: sbm-colision-ids-entre-sesiones (15-30 min por colision para renumerar y actualizar referencias).
**Ejemplo concreto:** Antes de Sprint Backlog Manager, los IDs de historias se gestionaban en archivos de texto. Sesiones concurrentes asignaban el mismo ID (ej: LTE-015) a historias diferentes, causando conflictos al merge.

---

### T-012: Contexto Meta-Metodologico
**Categoria:** Estructural
**Volatilidad:** Baja - cambia solo cuando se actualiza la metodologia
**Valor relativo:** Medio - no afecta el trabajo directo, pero su crecimiento descontrolado degrada toda la ventana de contexto
**Ciclo de vida:**
- **Nace:** Al crear directivas, procesos, templates, o mejoras a la forma de trabajar
- **Pico de valor:** En cada sesion donde se aplique (es contexto "always-on")
- **Decae:** Cuando la directiva se vuelve habito internalizado o se consolida en otra mas amplia
- **Caduca:** Cuando se reemplaza por una version actualizada (ej: v2 -> v3)
**Persistencia recomendada:** `metodologia_general/` con carga selectiva. Core (01-04) siempre. Avanzado (05) bajo demanda. Limites estrictos: cada adicion de contexto meta-metodologico tiene un costo directo en ventana disponible para trabajo real.
**Perdida tipica:** No se pierde por interrupcion sino por crecimiento: la acumulacion de directivas diluye la atencion y satura la ventana. Incidente de referencia: metodologia-overhead-contexto (~15 @imports que consumian parte significativa de la ventana antes de la consolidacion v3).
**Ejemplo concreto:** La Metodologia General crecio de v1 a v2 con ~15 documentos separados cargados via @import en cada sesion. La consolidacion a v3 redujo a 6 archivos core. El contexto meta-metodologico es el unico tipo que causa daño no por perderse, sino por acumularse.

---

### T-013: Conocimiento Inter-Proyecto
**Categoria:** Relacional
**Volatilidad:** Baja - los learnings de un proyecto cambian infrecuentemente
**Valor relativo:** Medio - perderlo no afecta el proyecto actual pero causa re-descubrimiento en proyectos futuros
**Ciclo de vida:**
- **Nace:** Al descubrir un patron, limitacion, o solucion en un proyecto que aplica a otros
- **Pico de valor:** Cuando se trabaja en un proyecto diferente que enfrenta el mismo problema
- **Decae:** Cuando las tecnologias subyacentes cambian (ej: un workaround para un bug que se fixeo)
- **Caduca:** Cuando todos los proyectos que podrian beneficiarse ya lo incorporaron
**Persistencia recomendada:** LEARNINGS.md de cada proyecto para learnings especificos. Actualmente NO existe un mecanismo de broadcast inter-proyecto. El catalogo de mitigaciones identifica esto como Gap 2: los proyectos son silos de conocimiento.
**Perdida tipica:** Un patron valioso queda en el LEARNINGS.md de un proyecto y no se carga cuando se trabaja en otro proyecto con el mismo stack. El conocimiento existe pero es inaccesible.
**Ejemplo concreto:** La directiva "extension sin eliminacion" surgio en un proyecto especifico pero se generalizo a la metodologia. Sin embargo, learnings mas especificos (ej: patrones de testing, quirks de un framework) quedan aislados en sus proyectos de origen.

---

## 3. Matriz de Tipos

| ID | Nombre | Categoria | Volatilidad | Valor | Ventana de Relevancia | Persistencia Principal |
|----|--------|-----------|-------------|-------|-----------------------|------------------------|
| T-001 | Estado de Tarea Activa | Operacional | Alta | Critico | Horas (sesion) | TASK_STATE.md |
| T-002 | Hipotesis de Debugging | Operacional | Alta | Alto | Horas a dias | TASK_STATE.md |
| T-003 | Resultados de Errores y Logs | Operacional | Alta | Alto | Horas a dias | TASK_STATE.md |
| T-004 | Plan de Trabajo | Operacional | Media | Alto | Horas a sprint | TASK_STATE.md |
| T-005 | Sugerencias e Ideas | Operacional | Alta | Alto | Minutos (si no se registra) | TASK_STATE / BACKLOG |
| T-006 | Decisiones de Diseño | Estructural | Baja | Critico | Semanas a meses | ARCHITECTURE.md / ADR |
| T-007 | Conocimiento Arquitectonico | Estructural | Baja | Critico | Permanente (mientras exista el sistema) | ARCHITECTURE.md |
| T-008 | Estado de Entorno de Ejecucion | Operacional | Alta | Medio | Horas (sesion de testing) | TASK_STATE.md |
| T-009 | Contexto de Delegacion | Relacional | Media | Alto | Minutos a horas (vida del agente) | TASK_STATE.md (pre/post) |
| T-010 | Preferencias del Usuario | Relacional | Baja | Medio | Permanente | User Memory |
| T-011 | Estado Compartido entre Sesiones | Relacional | Media | Alto | Permanente (mientras el recurso exista) | Archivo + DB |
| T-012 | Contexto Meta-Metodologico | Estructural | Baja | Medio | Permanente (pero con costo acumulativo) | metodologia_general/ |
| T-013 | Conocimiento Inter-Proyecto | Relacional | Baja | Medio | Meses a permanente | LEARNINGS.md (aislado) |

---

## 4. Relaciones entre Tipos

Los tipos de contexto no existen en aislamiento. Forman una red de dependencias y transformaciones:

```
                    T-012 Meta-Metodologico
                     |  (gobierna como se gestionan todos los demas)
                     v
  T-010 Preferencias -----> T-009 Contexto de Delegacion
         |                        |
         v                        v
  T-004 Plan de Trabajo ---> T-001 Estado de Tarea Activa
         |                    |            |
         |                    v            v
         |              T-002 Hipotesis   T-003 Errores/Logs
         |                    |            |
         |                    v            v
         |              T-006 Decisiones de Diseño
         |                    |
         v                    v
  T-011 Estado Compartido  T-007 Arquitectura
         |                    |
         v                    v
  T-013 Conocimiento Inter-Proyecto
```

### Transformaciones clave

1. **Hipotesis -> Decision:** Una hipotesis de debugging confirmada (T-002) se transforma en una decision de diseño (T-006) cuando el fix implica un cambio arquitectonico. Si la hipotesis no se registro, la decision pierde su justificacion.

2. **Sugerencia -> Plan -> Tarea:** Una idea (T-005) que se formaliza entra al plan de trabajo (T-004) y eventualmente se convierte en estado de tarea activa (T-001). Si la sugerencia se perdio, la cadena nunca se inicia.

3. **Error -> Hipotesis -> Decision -> Arquitectura:** Un error (T-003) genera hipotesis de debugging (T-002), que al confirmarse produce una decision (T-006), que modifica el conocimiento arquitectonico (T-007). Cada transformacion puede perder contexto.

4. **Tarea -> Delegacion -> Resultado -> Estado:** El estado de tarea (T-001) genera contexto de delegacion (T-009). El resultado del agente actualiza el estado de tarea. Si el contexto de delegacion fue incompleto, el resultado es deficiente y el estado se contamina.

5. **Cualquier tipo -> Conocimiento inter-proyecto:** Cualquier tipo de contexto puede generalizarse (T-013), pero solo si se detecta que es transferible. Actualmente no hay mecanismo activo para esta transformacion.

6. **Meta-metodologico -> Todos:** El contexto meta-metodologico (T-012) gobierna como se gestionan todos los demas tipos. Pero su crecimiento descontrolado reduce el espacio disponible para los tipos que gobierna, creando un conflicto inherente: mas proteccion = menos espacio para lo protegido.

---

## 5. Implicaciones para la Gestion

### 5.1 La volatilidad determina la urgencia de persistencia

Los tipos de alta volatilidad (T-001, T-002, T-003, T-005, T-008) son los mas vulnerables a interrupciones. Su regla es simple: **escribir primero, trabajar despues**. Un error no registrado, una hipotesis no documentada, o una sugerencia no escrita tienen una ventana de supervivencia de minutos si dependen unicamente de la conversacion.

Los tipos de baja volatilidad (T-006, T-007, T-010, T-012, T-013) son menos urgentes pero mas costosos de perder. Su persistencia puede planificarse, pero no debe posponerse indefinidamente.

### 5.2 El valor relativo determina el nivel de proteccion

Los dos tipos criticos (T-001: estado de tarea, T-006: decisiones de diseño) necesitan las mitigaciones mas robustas. Actualmente, T-001 tiene 12 mitigaciones directas (la mayor cobertura del sistema). T-006 tiene cobertura indirecta via ARCHITECTURE.md y LEARNINGS.md, pero el catalogo de mitigaciones muestra que el "por que" de las decisiones sigue siendo el tipo de informacion que mas se pierde en la practica.

### 5.3 El contexto relacional es el mas desprotegido

Los tipos relacionales (T-009, T-011, T-013) tienen la cobertura mas debil:
- **T-009 (delegacion):** Solo 2 mitigaciones directas + 1 parcial. El Gap 5 del catalogo confirma la ausencia de validacion post-delegacion.
- **T-011 (estado compartido):** Requiere mecanismos de atomicidad que los archivos de texto no proveen.
- **T-013 (inter-proyecto):** No tiene mitigacion activa. El Gap 2 del catalogo lo identifica como silo de conocimiento.

### 5.4 El conflicto cantidad-calidad del contexto meta-metodologico

El tipo T-012 es unico: es el unico tipo que causa daño por acumulacion, no por perdida. Cada directiva nueva mejora la proteccion de los demas tipos pero reduce el espacio disponible para ellos. La consolidacion periodica (v2 -> v3) es esencial, pero reactiva. Una politica de "presupuesto de contexto" (N lineas maximas para metodologia, el resto para trabajo) podria hacer esto proactivo.

### 5.5 Prioridades para mejorar el sistema

Basado en la combinacion de valor relativo y cobertura actual:

| Prioridad | Tipo | Razon |
|-----------|------|-------|
| 1 | T-005 Sugerencias | Valor alto, cobertura baja (2 mitigaciones directas), altamente efimero |
| 2 | T-009 Delegacion | Valor alto, sin validacion post-delegacion, afecta output de agentes |
| 3 | T-013 Inter-proyecto | Sin mitigacion activa, conocimiento valioso atrapado en silos |
| 4 | T-002 Hipotesis | Valor alto, directiva 12a existe pero el enforcement es debil |
| 5 | T-011 Estado compartido | Requiere atomicidad que los archivos no proveen |

---

## 6. Apendice: Mapeo Tipos - Incidentes

| Incidente | Tipos involucrados |
|-----------|-------------------|
| gaia-protocol-sugerencias-perdidas | T-005 (primario), T-006, T-004 |
| youtube-rag-duplicacion-archivos | T-006 (primario), T-007 |
| sbm-colision-ids-entre-sesiones | T-011 (primario) |
| orchestrator-test-e2e-interrumpido | T-001 (primario), T-008 |
| linkedin-debugging-multisesion | T-002 (primario), T-003 |
| metodologia-overhead-contexto | T-012 (primario) |
| recetario-observaciones-review-diferidas | T-005 (primario), T-009 |
