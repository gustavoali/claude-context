# Estado del Arte - Context Engineering
**Fecha:** 2026-02-26 | **Version:** 1.0
**Historia:** CE-007 | **Investigador:** Claude (Context Engineering)

---

## 1. Panorama General

Context Engineering se consolido como disciplina diferenciada de Prompt Engineering a mediados de 2025, cuando Tobi Lutke (CEO de Shopify) y Andrej Karpathy (ex-OpenAI/Tesla) respaldaron publicamente el termino. Lutke lo describio como "the art of providing all the context for the task to be plausibly solvable by the LLM", mientras Karpathy lo definio como "the delicate art and science of filling the context window with just the right information for the next step." En septiembre de 2025, Anthropic formalizo el concepto en su blog de ingenieria, definiendolo como "the set of strategies for curating and maintaining the optimal set of tokens during LLM inference."

La distincion clave respecto de prompt engineering es de alcance: prompt engineering se ocupa del *como preguntar*, mientras que context engineering se ocupa del *que informacion proveer*. En sistemas de agentes en produccion, el prompt representa una fraccion minima del contexto total; la mayor parte es estado del sistema, historial de conversacion, resultados de herramientas, datos externos y memoria persistente.

En 2025-2026, dos fenomenos tecnicos impulsan la disciplina: **Context Rot** (degradacion del rendimiento a medida que crece la ventana de contexto) y **Lost in the Middle** (los modelos atienden fuertemente al inicio y final del contexto, pero pobremente al medio). Investigacion de Chroma (2025) demostro que los 18 modelos frontier testeados exhiben context rot, con caidas de rendimiento superiores al 30% cuando la informacion relevante esta en el medio del contexto.

La profesionalizacion del campo es evidente: Cognizant anuncio en agosto 2025 el despliegue de 1,000 "context engineers" en asociacion con Workfabric AI, marcando la primera adopcion corporativa a gran escala de context engineering como rol dedicado.

---

## 2. Practicas y Herramientas

### 2.1 Anthropic: Context Engineering para Agentes
**Fuente:** anthropic.com/engineering/effective-context-engineering-for-ai-agents
**Problema:** Agentes de IA que operan por multiples turnos necesitan estrategias para mantener contexto relevante sin saturar la ventana.
**Solucion:** Anthropic propone cuatro estrategias principales: (1) **Compresion de contexto** - pasar el historial al modelo para resumir, preservando decisiones arquitectonicas y bugs sin resolver mientras descarta outputs de herramientas redundantes. (2) **Subagentes con contexto aislado** - cada subagente trabaja con su propia ventana limpia y retorna solo un resumen condensado (1,000-2,000 tokens) al orquestador. (3) **Memoria externa via archivos** - el memory tool lanzado con Sonnet 4.5 permite a los agentes almacenar informacion fuera de la ventana de contexto en un sistema basado en archivos. (4) **Auto-compactacion** - el Claude Agent SDK detecta cuando el contexto se acerca al limite y automaticamente resume mensajes previos.
**Fortalezas:** Marco conceptual completo. Integrado directamente en Claude Code. Combina multiples estrategias complementarias.
**Debilidades:** Las estrategias de compresion dependen de la calidad del resumen del modelo. No hay garantia de que la compactacion preserve exactamente lo que el usuario considera critico.
**Relevancia:** Alta. Nuestra metodologia ya implementa varias de estas ideas (TASK_STATE como memoria externa, subagentes con contexto delegado), pero la auto-compactacion y los PreCompact hooks son mecanismos que no explotamos.

---

### 2.2 Claude Code: CLAUDE.md y Sistema de Memoria
**Fuente:** code.claude.com/docs/en/memory; comunidad de usuarios
**Problema:** Mantener contexto de proyecto consistente entre sesiones de desarrollo asistido por IA.
**Solucion:** Sistema de tres niveles: (1) **CLAUDE.md** - archivos markdown mantenidos por el usuario con instrucciones, reglas y preferencias, cargados automaticamente al inicio de sesion. Soportan @imports para composicion modular. (2) **Auto Memory** - notas que Claude escribe automaticamente en `~/.claude/projects/<project>/memory/`, persistiendo patrones descubiertos y preferencias observadas. (3) **Hooks** - scripts que se ejecutan en eventos del ciclo de vida (PreCompact, PostToolUse, etc.), permitiendo salvaguardar contexto critico en el momento exacto de la compresion. La comunidad ha desarrollado patrones como PreCompact hooks que crean snapshots de emergencia.
**Fortalezas:** Automatizacion parcial (auto memory). Extensibilidad via hooks. Ampliamente adoptado.
**Debilidades:** CLAUDE.md es "naively dropped into context" - se carga completo sin discriminar relevancia. Los limites de tamanio no se enforcement automaticamente.
**Relevancia:** Directa. Nuestro sistema de 3 capas de memoria (User/Project/Context Repository) extiende este modelo base con estructura mas rigida y limites explicitos.

---

### 2.3 LangGraph: Estado con Checkpointing y Memoria por Capas
**Fuente:** docs.langchain.com; github.com/langchain-ai/langgraph
**Problema:** Agentes que operan como grafos de estado necesitan persistir su estado para tolerancia a fallos y continuidad entre sesiones.
**Solucion:** LangGraph implementa un sistema de dos capas: (1) **Memoria a corto plazo** (thread-scoped) - estado persistido via checkpointers (InMemorySaver, SqliteSaver, PostgresSaver) que captura el estado completo del grafo en cada nodo. Permite "time travel" - volver a cualquier checkpoint anterior. (2) **Memoria a largo plazo** - datos que persisten entre threads/sesiones, tipicamente en bases de datos o vector stores, para preferencias de usuario y hechos acumulados. El sistema de checkpointing es automatico: cada transicion de estado genera un checkpoint sin intervencion del desarrollador.
**Fortalezas:** Checkpointing automatico y transparente. Time travel para debugging. Modelo bien definido (TypedDict con reducers).
**Debilidades:** Requiere definir el esquema de estado explicitamente. El checkpointing persiste todo sin discriminar relevancia. Orientado a grafos programaticos, no a flujos conversacionales libres.
**Relevancia:** Media-alta. El concepto de checkpointing automatico es lo que intentamos lograr manualmente con WIP commits y TASK_STATE updates cada 30 minutos. LangGraph lo automatiza a nivel de framework.

---

### 2.4 Mem0: Capa de Memoria Universal para Agentes
**Fuente:** mem0.ai; arxiv.org/abs/2504.19413
**Problema:** Los agentes pierden contexto entre conversaciones porque la ventana de contexto es efimera. Enviar todo el historial de chat como contexto es costoso e ineficiente.
**Solucion:** Mem0 extrae dinamicamente informacion saliente de conversaciones, la consolida en representaciones compactas de memoria, y la recupera selectivamente cuando es relevante. Una variante avanzada usa grafos de memoria (graph memory) para capturar relaciones complejas entre entidades. Benchmarks muestran 26% mayor precision que OpenAI memory, 91% menor latencia p95, y >90% ahorro en tokens.
**Fortalezas:** Extraccion automatica de memorias (no requiere intervencion manual). Altamente eficiente en tokens. Disponible como servicio o self-hosted.
**Debilidades:** La extraccion automatica puede perder matices que un humano preservaria. Requiere integracion con el framework del agente. No ofrece control granular sobre que se recuerda.
**Relevancia:** Media. Nuestra metodologia opta por memoria explicita (el usuario/Claude decide que persistir), no automatica. Mem0 representa el enfoque opuesto: maximizar automatizacion a costa de control.

---

### 2.5 Zep: Grafo de Conocimiento Temporal para Memoria de Agentes
**Fuente:** getzep.com; arxiv.org/abs/2501.13956
**Problema:** Los agentes necesitan recordar no solo hechos sino como cambian en el tiempo, y combinar datos conversacionales con datos estructurados del negocio.
**Solucion:** Zep usa Graphiti, un motor de grafo de conocimiento temporalmente consciente que sintetiza datos conversacionales no estructurados y datos de negocio estructurados, manteniendo relaciones historicas. Combina busqueda basada en grafos con busqueda vectorial. Supera a MemGPT en el benchmark Deep Memory Retrieval.
**Fortalezas:** Consciencia temporal (sabe cuando se aprendio algo y si cambio). Combina datos conversacionales y empresariales. Modelo rico de relaciones.
**Debilidades:** Complejidad de infraestructura. Requiere grafo de conocimiento como dependencia. Overhead para proyectos simples.
**Relevancia:** Baja-media. La dimension temporal es interesante - nuestro sistema no rastrea cuando se tomo una decision ni si fue actualizada, excepto por fechas en LEARNINGS.md.

---

### 2.6 Cursor y Windsurf: Indexacion de Codebase como Contexto
**Fuente:** cursor.com; windsurf.com
**Problema:** Los IDE con IA necesitan entender proyectos de codigo completos que exceden la ventana de contexto.
**Solucion:** Ambos herramientas indexan el codebase completo usando embeddings semanticos y RAG. **Cursor** requiere mencion explicita de archivos (@codebase, @files) para incluir contexto, dando control al usuario. **Windsurf** usa un "context engine" automatico que indexa estructura del proyecto, acciones pasadas e intenciones, sin requerir seleccion manual. Windsurf agrega "Memories" - contexto persistente entre sesiones, tanto creado por el usuario como generado automaticamente. Su feature "Codemaps" genera mapas visuales anotados de la estructura de codigo.
**Fortalezas:** Acceso a codebase completo sin cargar todo en contexto. Windsurf: automatizacion progresiva y visual. Cursor: control explicito.
**Debilidades:** Dependen de RAG, que puede fallar en recuperar el contexto relevante. No aplican a flujos no-IDE.
**Relevancia:** Media. Nuestro flujo usa glob/grep para navegacion (similar a Cursor), pero no tenemos indexacion semantica del codebase ni memories automaticas como Windsurf.

---

### 2.7 AgentFold: Gestion Proactiva de Contexto
**Fuente:** arxiv.org/abs/2510.24699
**Problema:** Agentes web que ejecutan tareas de horizonte largo acumulan historial de acciones hasta saturar el contexto, degradando rendimiento.
**Solucion:** AgentFold trata el contexto como un "workspace cognitivo dinamico" que debe ser "esculpido activamente" en vez de un "log pasivo que se llena". Inspirado en la consolidacion retrospectiva humana, el agente aprende a ejecutar operaciones de "folding" que comprimen su trayectoria historica a multiples escalas. En lugar de simplemente truncar o resumir, el agente reorganiza proactivamente su contexto.
**Fortalezas:** El concepto de contexto como workspace activo (no log pasivo) es poderoso. Multi-escala: comprime a diferentes niveles de detalle.
**Debilidades:** Requiere entrenamiento especifico del modelo para la operacion de folding. Resultados en ambiente de investigacion, no produccion.
**Relevancia:** Alta conceptualmente. Nuestra directiva de limites de tamanio (CLAUDE.md 150 lineas, TASK_STATE 200 lineas) intenta lo mismo manualmente: forzar la curaduria activa del contexto.

---

### 2.8 JetBrains: Simple Observation Masking vs LLM Summarization
**Fuente:** blog.jetbrains.com/research/2025/12/efficient-context-management/
**Problema:** El contexto de agentes crece con outputs de herramientas verbosos que contienen informacion ya procesada.
**Solucion:** Comparan dos estrategias: (1) **Observation masking** - preserva el historial de acciones y razonamiento completo pero oculta los outputs verbosos de herramientas de turnos anteriores. (2) **LLM summarization** - comprime todo (acciones, razonamiento, outputs) en resumen compacto. Hallazgo clave: observation masking es tan efectivo como summarization, con ~50% reduccion de costo, sin degradar rendimiento en tareas downstream.
**Fortalezas:** Resultado contraintuitivo y practico: la solucion simple funciona igual que la compleja. Preserva razonamiento intacto.
**Debilidades:** Solo aplica a contextos con outputs de herramientas; no generaliza a toda la conversacion.
**Relevancia:** Alta. Nuestro sistema podria beneficiarse de masking selectivo: cuando TASK_STATE se compacta, preservar decisiones y razonamiento pero descartar outputs detallados de comandos.

---

### 2.9 Cognizant ContextFabric: Context Engineering Empresarial
**Fuente:** news.cognizant.com (agosto 2025)
**Problema:** Las empresas necesitan que los agentes de IA entiendan procesos, reglas, roles y workflows organizacionales para funcionar en produccion.
**Solucion:** ContextFabric (de Workfabric AI) transforma el "DNA organizacional" - workflows, datos, reglas, procesos - en contexto accionable para agentes. Cognizant define context engineering como la combinacion de expertise de dominio, funcional y tecnico para entregar contexto relevante a agentes. Metricas reportadas: hasta 3X mayor precision, 70% menos alucinaciones, ciclos de deployment mas rapidos.
**Fortalezas:** Primera profesionalizacion del rol a escala. Reconoce que context engineering requiere conocimiento de dominio, no solo tecnico.
**Debilidades:** Orientado a enterprise, no a desarrolladores individuales. Producto cerrado (no open source). Metricas auto-reportadas.
**Relevancia:** Baja para implementacion directa, pero valida la tesis de que context engineering es una disciplina real que justifica dedicacion profesional.

---

### 2.10 OpenAI Agents SDK: Memoria Estructurada por Scopes
**Fuente:** developers.openai.com/cookbook/examples/agents_sdk/
**Problema:** Agentes necesitan diferentes tipos de memoria (conversacional, de usuario, de proyecto) con diferentes ciclos de vida.
**Solucion:** El RunContextWrapper del SDK permite definir objetos de estado estructurado que persisten entre ejecuciones. Implementan separacion por scope: memoria por conversacion (short-term via Sessions), por usuario (preferencias durables), y por proyecto. La documentacion recomienda como baseline mantener solo los ultimos N turnos de usuario, donde un "turno" es un mensaje de usuario + todo lo que sigue hasta el siguiente mensaje.
**Fortalezas:** Modelo de scopes explicitamente separados. Integracion nativa con el SDK. Guias practicas publicadas.
**Debilidades:** Requiere programacion explicita de la logica de persistencia. No hay auto-extraccion de memorias.
**Relevancia:** Media. La separacion por scopes es similar a nuestras 3 capas (global/proyecto/sesion). La regla de "ultimos N turnos" es un patron que podriamos formalizar.

---

### 2.11 Agentic Context Engineering (ACE) - Paper Academico
**Fuente:** arxiv.org/abs/2510.04618
**Problema:** Los prompts de sistema y la memoria de agentes son tipicamente estaticos o ad-hoc. No hay proceso sistematico para evolucionarlos.
**Solucion:** ACE trata los contextos como "playbooks evolutivos" que acumulan, refinan y organizan estrategias a traves de un proceso modular de generacion, reflexion y curaduria. Optimiza tanto contextos offline (prompts de sistema) como online (memoria de agentes). Resultados: +10.6% en tareas de agentes, +8.6% en finanzas vs baselines fuertes.
**Fortalezas:** Proceso sistematico de evolucion de contexto. Aplica tanto a instrucciones como a memoria en runtime. Resultados cuantitativos.
**Debilidades:** Framework de investigacion, no herramienta deployable. Requiere ciclos de reflexion que agregan latencia.
**Relevancia:** Alta conceptualmente. Nuestra directiva de mejora continua (directiva 6) y CONTINUOUS_IMPROVEMENT.md intentan algo similar: evolucionar las directivas basandose en incidentes. ACE lo formaliza con un ciclo explicito de generacion-reflexion-curaduria.

---

### 2.12 Context Rot y Lost in the Middle - Investigacion Fundamental
**Fuente:** research.trychroma.com/context-rot; arxiv.org/abs/2307.03172
**Problema:** Los modelos degradan rendimiento a medida que crece el contexto, incluso cuando la informacion relevante esta presente.
**Solucion:** La investigacion documenta tres causas: (1) **Lost in the middle** - los modelos atienden fuertemente al inicio y final, no al medio (curva U). (2) **Escalamiento cuadratico de atencion** - mas tokens = exponencialmente mas relaciones a trackear. (3) **Distractores semanticamente similares** - informacion irrelevante pero similar al target interfiere. Un paper de octubre 2025 demostro que incluso con retrieval perfecto al 100%, el rendimiento cae 13.9-85% al aumentar el input, aun reemplazando tokens irrelevantes con whitespace.
**Fortalezas:** Evidencia empirica robusta. Aplica a todos los modelos frontier testeados (18/18 en estudio de Chroma).
**Debilidades:** No propone soluciones directas, solo documenta el fenomeno. Las mitigaciones son responsabilidad del usuario del modelo.
**Relevancia:** Critica. Fundamenta por que nuestros limites de tamanio (CLAUDE.md 150 lineas, TASK_STATE 200) no son arbitrarios: mas contexto puede ser *peor* que menos. Tambien explica por que poner informacion critica al inicio/final de documentos importa.

---

## 3. Comparacion con Nuestra Metodologia

### 3.1 Gaps (lo que la industria hace y nosotros no)

| Gap | Descripcion | Fuente | Impacto estimado |
|-----|-------------|--------|-----------------|
| **Checkpointing automatico** | LangGraph genera checkpoints en cada transicion de estado automaticamente. Nosotros dependemos de WIP commits manuales y actualizaciones de TASK_STATE cada ~30 min. | LangGraph | Alto - la automatizacion eliminaria el riesgo de sesion interrumpida entre checkpoints manuales |
| **Indexacion semantica del codebase** | Cursor/Windsurf indexan el proyecto completo con embeddings. Nosotros usamos glob/grep (busqueda lexica). | Cursor, Windsurf | Medio - para proyectos grandes, la busqueda semantica encontraria contexto relevante que glob no encuentra |
| **Extraccion automatica de memorias** | Mem0 y Windsurf Memories extraen y persisten informacion saliente automaticamente. Nosotros dependemos 100% de que Claude siga directivas de comportamiento para persistir. | Mem0, Windsurf | Alto - nuestro hallazgo CE-003 confirma que "100% de mitigaciones son directivas de comportamiento, ninguna tiene enforcement automatico" |
| **Consciencia temporal** | Zep rastrea cuando se aprendio algo y como cambia en el tiempo. Nuestro LEARNINGS.md no tiene dimensionamiento temporal sistematico. | Zep/Graphiti | Bajo - para nuestra escala, las fechas manuales son suficientes |
| **Observation masking** | JetBrains demostro que ocultar outputs de herramientas previos reduce 50% el contexto sin degradar rendimiento. No aplicamos esta tecnica. | JetBrains Research | Medio - reduciria la presion sobre nuestra ventana de contexto en sesiones largas |
| **PreCompact hooks** | Claude Code soporta hooks que se ejecutan justo antes de la compactacion. No los usamos para salvaguardar contexto critico. | Claude Code comunidad | Alto - es infraestructura existente que no estamos aprovechando |

### 3.2 Ventajas (lo que hacemos y la industria no)

| Ventaja | Descripcion | Comparacion |
|---------|-------------|-------------|
| **Limites de tamanio explicitos** | CLAUDE.md 150 lineas, TASK_STATE 200, BACKLOG 300, ARCH 400. La industria raramente impone limites cuantitativos a la memoria. | Mem0/Zep crecen sin limites; CLAUDE.md en la comunidad tiende a crecer indefinidamente |
| **Taxonomia de 13 tipos de contexto** | Clasificacion rigurosa de contexto operacional/estructural/relacional. No encontramos equivalente en la literatura abierta. | La industria habla de "short-term" vs "long-term" sin granularidad |
| **Directiva de registro-antes-de-investigar** | Politica explicita de persistir errores ANTES de investigar. No documentada en ningun framework revisado. | Los frameworks asumen que el error ya esta logueado; no abordan el orden de operaciones humano |
| **Arquitectura de 3 capas con @imports** | Composicion modular User/Project/Repository con carga automatica. Mas estructurado que CLAUDE.md flat files. | La comunidad usa CLAUDE.md monoliticos; solo OpenAI Agents SDK tiene scopes comparables |
| **Proceso de limpieza con triggers** | Limpieza obligatoria cuando se exceden limites, con checklist y responsable. Ningun framework revisado tiene proceso de curaduria forzada. | Mem0/LangGraph acumulan sin curaduria; la comunidad CLAUDE.md no define cuando limpiar |
| **Backlog-first para cambios** | Todo cambio de codigo pasa por backlog primero (directiva 3). Disciplina de trazabilidad que no es comun en flujos con IA. | Los frameworks de agentes ejecutan cambios directamente |

### 3.3 Oportunidades (ideas para incorporar)

| Oportunidad | Fuente | Descripcion | Esfuerzo | Impacto |
|-------------|--------|-------------|----------|---------|
| **Implementar PreCompact hook** | Claude Code | Crear hook que persista TASK_STATE y decisiones criticas justo antes de que el contexto se comprima. Infraestructura ya existe en Claude Code. | Bajo | Alto |
| **Aplicar observation masking** | JetBrains | Cuando se actualiza TASK_STATE, preservar decisiones y razonamiento pero descartar outputs detallados de herramientas de turnos anteriores. | Bajo | Medio |
| **Ciclo de reflexion sobre directivas** | ACE paper | Periodicamente (al cerrar un sprint o cada N sesiones), ejecutar un ciclo de reflexion sobre las directivas: que funciono, que no, que refinar. Formalizar lo que ya hacemos ad-hoc en CONTINUOUS_IMPROVEMENT.md. | Medio | Medio |
| **Posicionamiento de informacion critica** | Context Rot research | Reorganizar CLAUDE.md y TASK_STATE para poner informacion mas critica al inicio y final del documento, no en el medio (mitigar lost-in-the-middle). | Bajo | Medio |
| **Auto-extraccion de LEARNINGS** | Mem0 concepto | Crear un mecanismo (hook o directiva) que al cerrar sesion extraiga automaticamente decisiones y patrones aprendidos a LEARNINGS.md. Hoy depende de que Claude lo recuerde. | Medio | Alto |
| **Metricas de salud de contexto** | METRICS.md propio + industria | Implementar un "health check" que se ejecute al inicio de sesion: verificar limites, actualidad de TASK_STATE, coherencia de CLAUDE.md con el proyecto. | Medio | Medio |

---

## 4. Conclusiones

### Hallazgos clave

1. **Context Engineering es una disciplina establecida.** Ya no es un termino emergente: tiene definiciones formales (Anthropic, Karpathy, Lutke), roles profesionales (Cognizant), frameworks de investigacion (ACE), y herramientas dedicadas (Mem0, Zep, ContextFabric). La tesis del proyecto de investigacion queda validada.

2. **La industria converge en separar memoria a corto y largo plazo.** Todos los frameworks (LangGraph, OpenAI SDK, CrewAI, Mem0) implementan alguna version de esta separacion. Nuestra arquitectura de 3 capas es una variante mas granular de este patron universal.

3. **El enforcement automatico es la frontera.** Nuestro hallazgo previo (CE-003: "100% de mitigaciones son directivas de comportamiento") se confirma como un gap real. La industria esta moviendo hacia automatizacion: checkpointing automatico (LangGraph), extraccion automatica de memorias (Mem0), hooks (Claude Code). Las directivas de comportamiento son necesarias pero insuficientes.

4. **Context rot es un fenomeno real y cuantificable.** No es especulacion: hay evidencia empirica de que mas contexto puede degradar rendimiento. Esto fundamenta nuestros limites de tamanio como decision tecnica, no burocratica.

5. **El contexto como workspace activo (no log pasivo) es un paradigma emergente.** AgentFold y ACE proponen que el contexto debe ser activamente esculpido y evolucionado, no simplemente acumulado. Nuestras directivas de limpieza y curaduria van en esta direccion, pero podemos ser mas sistematicos.

### Tendencias

- **De prompt engineering a context engineering**: transicion ya consolidada en la industria.
- **De memoria manual a memoria automatica**: la tendencia es reducir la carga sobre el usuario/operador.
- **De contexto monolitico a contexto estructurado**: scopes, capas, grafos en vez de texto plano.
- **De acumular a curar**: los sistemas maduros priorizan que incluir y que descartar.

### Recomendaciones priorizadas

1. **(Inmediato)** Implementar PreCompact hook para salvaguardar TASK_STATE antes de compactacion.
2. **(Corto plazo)** Reorganizar documentos clave aplicando posicionamiento contra lost-in-the-middle.
3. **(Medio plazo)** Formalizar ciclo de reflexion sobre directivas (inspirado en ACE).
4. **(Medio plazo)** Explorar auto-extraccion de LEARNINGS al cerrar sesion.
5. **(Largo plazo)** Evaluar integracion de indexacion semantica para proyectos grandes.

---

## 5. Referencias

- [Anthropic: Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [Anthropic: Building Effective AI Agents](https://www.anthropic.com/research/building-effective-agents)
- [Anthropic: Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Claude Code: Memory documentation](https://code.claude.com/docs/en/memory)
- [Claude Code Auto Memory & PreCompact Hooks](https://yuanchang.org/en/posts/claude-code-auto-memory-and-hooks/)
- [LangGraph: Memory documentation](https://docs.langchain.com/oss/python/langgraph/add-memory)
- [LangGraph: State Management in 2025](https://sparkco.ai/blog/mastering-langgraph-state-management-in-2025)
- [Mem0: Production-Ready AI Agents with Scalable Long-Term Memory](https://arxiv.org/abs/2504.19413)
- [Zep: Temporal Knowledge Graph Architecture for Agent Memory](https://arxiv.org/abs/2501.13956)
- [AgentFold: Long-Horizon Web Agents with Proactive Context Management](https://arxiv.org/abs/2510.24699)
- [ACE: Agentic Context Engineering](https://arxiv.org/abs/2510.04618)
- [JetBrains: The Complexity Trap (NeurIPS 2025)](https://blog.jetbrains.com/research/2025/12/efficient-context-management/)
- [Chroma Research: Context Rot](https://research.trychroma.com/context-rot)
- [Lost in the Middle: How Language Models Use Long Contexts](https://arxiv.org/abs/2307.03172)
- [Cognizant: 1,000 Context Engineers initiative](https://news.cognizant.com/2025-08-29-Cognizant-to-Deploy-1,000-Context-Engineers,-Powered-by-ContextFabric-TM-,-to-Industrialize-Agentic-AI)
- [OpenAI Agents SDK: Context Personalization](https://developers.openai.com/cookbook/examples/agents_sdk/context_personalization/)
- [OpenAI Agents SDK: Session Memory](https://developers.openai.com/cookbook/examples/agents_sdk/session_memory/)
- [Tobi Lutke on Context Engineering](https://x.com/tobi/status/1935533422589399127)
- [Simon Willison: Context Engineering](https://simonwillison.net/2025/jun/27/context-engineering/)
- [Model Context Protocol Specification (2025-11-25)](https://modelcontextprotocol.io/specification/2025-11-25)
- [Context Rot: The Emerging Challenge](https://www.understandingai.org/p/context-rot-the-emerging-challenge)
