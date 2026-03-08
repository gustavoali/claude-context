# Framework de Metricas de Calidad de Contexto
**Fecha:** 2026-02-25 | **Version:** 1.0
**Historia:** CE-006 | **Investigador:** Claude (Context Engineering)

---

## 1. Dimensiones de Calidad

El contexto de trabajo humano-IA se puede evaluar en seis dimensiones independientes:

| Dimension | Definicion | Pregunta clave |
|-----------|-----------|----------------|
| **Completitud** | El contexto contiene toda la informacion necesaria para trabajar | Falta algo para entender el estado actual? |
| **Frescura** | El contexto refleja el estado real y actual del proyecto | Hay informacion desactualizada que confunde? |
| **Accesibilidad** | El contexto es facil de encontrar y cargar | Cuanto esfuerzo cuesta localizar lo que se necesita? |
| **Resiliencia** | El contexto sobrevive a interrupciones, cambios de sesion y compresion | Que se perderia si la sesion muriera ahora mismo? |
| **Eficiencia** | El contexto cargado es relevante y no contiene ruido | Cuanto del contexto cargado es realmente util para la tarea actual? |
| **Transferibilidad** | El contexto puede ser transmitido a otros (agentes, sesiones futuras, proyectos) | Otro agente o sesion podria continuar el trabajo sin re-descubrir? |

---

## 2. Metricas

### MET-001: Tiempo de Retoma (Time to Productivity)
**Dimension:** Resiliencia
**Definicion:** Tiempo transcurrido desde el inicio de una nueva sesion hasta que se produce el primer output util (commit, decision, delegacion a agente). Mide cuanto cuesta "ponerse al dia" con el estado del proyecto.
**Formula/Metodo de medicion:** Cronometrar (o estimar) desde el primer mensaje del usuario en la sesion hasta el primer acto productivo. Excluir tiempo de carga automatica de @imports.
**Unidad:** Minutos
**Baseline:** 10-20 min para proyectos complejos sin TASK_STATE actualizado. 2-5 min para proyectos con TASK_STATE al dia (basado en incidente orchestrator-test-e2e donde el TASK_STATE permitia retomar directamente, estimado 10-15 min de re-setup vs ~0 min de re-entendimiento).
**Target:** <= 5 min para cualquier proyecto con contexto gestionado.
**Frecuencia de medicion:** Al inicio de cada sesion (anotar en TASK_STATE como parte de "Sesion Activa").
**Ejemplo:** Sesion de LinkedIn Transcript Extractor: el usuario pide continuar debugging. Claude lee TASK_STATE, encuentra hipotesis descartadas, estado actual del bug, y servicios necesarios. Tiempo hasta primer accion: 3 min (lectura de contexto) + 2 min (levantar servicios documentados) = 5 min. Sin TASK_STATE (incidente real): 30-60 min re-descubriendo hipotesis ya probadas.

### MET-002: Tasa de Re-descubrimiento (Rediscovery Rate)
**Dimension:** Resiliencia + Completitud
**Definicion:** Proporcion de sesiones en las que se re-investiga algo que ya fue decidido, probado o descartado en una sesion anterior. Mide la efectividad de la persistencia de decisiones y hallazgos.
**Formula/Metodo de medicion:** En un periodo de N sesiones, contar cuantas veces se investigo o discutio algo que ya tenia respuesta en archivos persistentes o en sesiones previas. `Tasa = sesiones con re-descubrimiento / total sesiones`.
**Unidad:** Porcentaje (%)
**Baseline:** ~30-40% en proyectos sin gestion de contexto (basado en incidente linkedin-debugging donde multiples sesiones repetian las mismas hipotesis). ~10-15% en proyectos con TASK_STATE y LEARNINGS actualizados.
**Target:** <= 10%
**Frecuencia de medicion:** Retrospectiva semanal o al cerrar sprint/milestone. Registrar cada incidente de re-descubrimiento cuando se detecte.
**Ejemplo:** En 10 sesiones del proyecto Recetario, 2 veces se re-analizo un patron de extraccion que ya estaba documentado en LEARNINGS. Tasa = 2/10 = 20%. Causa: LEARNINGS no tenia el patron documentado con suficiente detalle.

### MET-003: Cobertura de Persistencia (Persistence Coverage)
**Dimension:** Completitud + Resiliencia
**Definicion:** Proporcion del contexto valioso que esta escrito en archivos persistentes vs. que existe solo en la conversacion activa. Mide que tan expuesto esta el trabajo a una interrupcion abrupta.
**Formula/Metodo de medicion:** En un momento dado de la sesion, evaluar: (1) listar los tipos de contexto activo (estado de tarea, decisiones tomadas, hipotesis en curso, sugerencias, planes, errores encontrados), (2) verificar cuantos estan escritos en archivos. `Cobertura = items persistidos / items totales`.
**Unidad:** Porcentaje (%)
**Baseline:** ~40-50% a mitad de sesion (basado en incidentes: el incidente Gaia Protocol tenia 0% de persistencia para sugerencias; el incidente orchestrator-test tenia ~60% gracias a directiva 12a).
**Target:** >= 80% en todo momento de la sesion.
**Frecuencia de medicion:** Evaluacion puntual cada ~30 min de trabajo activo (coincide con la directiva 12c de resumen periodico). Autoevaluacion rapida: "si la sesion muriera ahora, que se perderia?"
**Ejemplo:** Sesion de desarrollo con 3 historias. Estado actual: (1) historia A completada y commiteada [persistido], (2) historia B a mitad con codigo sin commitear [NO persistido], (3) decision de usar strategy pattern para B [NO persistido], (4) sugerencia de refactorizar modulo X [NO persistido], (5) plan de ola 2 [persistido en TASK_STATE]. Cobertura = 2/5 = 40%. Accion: commit WIP de B, escribir decision y sugerencia.

### MET-004: Indice de Frescura de Contexto (Context Freshness Index)
**Dimension:** Frescura
**Definicion:** Proporcion de archivos de contexto activo que reflejan el estado real y actual del proyecto (version, metricas, endpoints, arquitectura). Mide cuanto del contexto cargado es veraz.
**Formula/Metodo de medicion:** Revisar los archivos de contexto activo del proyecto (CLAUDE.md, TASK_STATE, BACKLOG, ARCHITECTURE). Para cada uno, verificar si: la version mencionada es la actual, las metricas son correctas, los endpoints/APIs listados existen, la arquitectura descrita coincide con el codigo. `Frescura = archivos actualizados / total archivos`.
**Unidad:** Porcentaje (%)
**Baseline:** ~60-70% (es comun que ARCHITECTURE quede desactualizado despues de refactors, y CLAUDE.md tenga metricas de la version anterior).
**Target:** >= 90%
**Frecuencia de medicion:** Al inicio de cada sesion (como parte del protocolo de inicio M-016) y al cerrar sprint/milestone.
**Ejemplo:** Proyecto Web Monitor. CLAUDE.md dice "Version 0.5.0" pero el package.json dice "0.7.0". ARCHITECTURE menciona 3 componentes pero se agregaron 2 mas. TASK_STATE esta al dia. BACKLOG esta al dia. Frescura = 2/4 = 50%.

### MET-005: Ratio de Eficiencia de Contexto (Context Efficiency Ratio)
**Dimension:** Eficiencia
**Definicion:** Proporcion del contexto cargado en la sesion que es relevante para la tarea actual. Mide el "ruido" contextual: informacion que se carga pero no se usa.
**Formula/Metodo de medicion:** Al final de la sesion (o retrospectivamente), evaluar cuantos de los archivos/secciones cargados via @import fueron realmente consultados o relevantes para el trabajo realizado. `Eficiencia = contexto utilizado / contexto cargado`.
**Unidad:** Porcentaje (%)
**Baseline:** ~50-60% (basado en incidente metodologia-overhead donde 15 @imports se cargaban pero solo una fraccion era relevante para cada tarea). Despues de la consolidacion v3: ~70-80%.
**Target:** >= 75%
**Frecuencia de medicion:** Retrospectiva mensual o cuando se detecta lentitud o saturacion de contexto.
**Ejemplo:** Sesion de bugfix simple en proyecto Recetario. Se cargan: CLAUDE.md (usado), TASK_STATE (usado), BACKLOG (no usado), ARCHITECTURE (no usado), LEARNINGS (no usado), + 6 archivos de metodologia general (2 usados). Total cargados: 11. Usados: 4. Eficiencia = 4/11 = 36%. Conclusion: para bugfixes simples, la carga es excesiva.

### MET-006: Score de Transferibilidad a Agentes (Agent Context Score)
**Dimension:** Transferibilidad
**Definicion:** Proporcion de delegaciones a agentes que producen output correcto y completo sin necesidad de re-delegacion o correccion por contexto insuficiente. Mide la calidad del contexto transmitido a agentes.
**Formula/Metodo de medicion:** En N delegaciones a agentes, contar cuantas requirieron re-trabajo por falta de contexto (el agente hizo asunciones incorrectas, produjo output incompleto, o pregunto por informacion que debio recibir). `Score = delegaciones exitosas / total delegaciones`.
**Unidad:** Porcentaje (%)
**Baseline:** ~70-80% (estimado; no hay registro sistematico de delegaciones fallidas, pero la experiencia sugiere que ~1 de cada 4-5 delegaciones requiere algun ajuste por contexto).
**Target:** >= 90%
**Frecuencia de medicion:** Registrar resultado de cada delegacion (exitosa/re-trabajo) en TASK_STATE. Consolidar al cierre de sprint.
**Ejemplo:** Sprint con 8 delegaciones a agentes. 6 produjeron output correcto. 1 requirio re-delegacion porque el agente no tenia el schema de la DB (no incluido en el prompt). 1 requirio ajuste porque asumio un patron de error handling diferente al del proyecto. Score = 6/8 = 75%.

### MET-007: Indice de Cumplimiento de Archivado (Archival Compliance Index)
**Dimension:** Frescura + Eficiencia
**Definicion:** Proporcion de archivos de contexto activo que estan dentro de los limites de tamano establecidos (CLAUDE.md: 150, TASK_STATE: 200, BACKLOG: 300, ARCHITECTURE: 400, LEARNINGS: 200 lineas). Mide la salud de la gestion de memoria del proyecto.
**Formula/Metodo de medicion:** Contar lineas de cada archivo de contexto activo. Verificar si cada uno esta dentro de su limite. `Indice = archivos dentro de limite / total archivos`.
**Unidad:** Porcentaje (%)
**Baseline:** ~60-70% (es frecuente que TASK_STATE o BACKLOG excedan limites durante trabajo activo).
**Target:** 100% al inicio de sesion (puede bajar durante trabajo activo, pero debe restaurarse al cierre).
**Frecuencia de medicion:** Al inicio y cierre de cada sesion.
**Ejemplo:** Proyecto LinkedIn. CLAUDE.md: 120 lineas (OK). TASK_STATE: 280 lineas (EXCEDE 200). BACKLOG: 350 lineas (EXCEDE 300). ARCHITECTURE: 390 lineas (OK). LEARNINGS: 180 lineas (OK). Indice = 3/5 = 60%.

### MET-008: Tasa de Supervivencia de Sugerencias (Suggestion Survival Rate)
**Dimension:** Completitud + Resiliencia
**Definicion:** Proporcion de sugerencias, ideas y observaciones que se generan durante sesiones y que llegan a ser procesadas (convertidas en items de backlog, aplicadas como mejoras, o descartadas deliberadamente). Mide cuantas sugerencias sobreviven al ciclo completo.
**Formula/Metodo de medicion:** En un periodo, contar: (1) sugerencias generadas en conversaciones (estimacion o registro en TASK_STATE "Sugerencias Pendientes"), (2) sugerencias que llegaron a backlog, LEARNINGS, o CONTINUOUS_IMPROVEMENT, (3) sugerencias procesadas (implementadas o descartadas deliberadamente). `Tasa = procesadas / generadas`.
**Unidad:** Porcentaje (%)
**Baseline:** ~30-40% (basado en incidentes Gaia Protocol y Recetario: las sugerencias que no se escriben inmediatamente se pierden con alta probabilidad, y las que se escriben como "diferidas" tienen ~50% de probabilidad de procesarse).
**Target:** >= 70%
**Frecuencia de medicion:** Mensual. Revisar "Sugerencias Pendientes" de TASK_STATE de todos los proyectos activos.
**Ejemplo:** En febrero, proyecto Orchestrator genero ~10 sugerencias (3 sobre tooling MCP, 4 sobre UX del web monitor, 3 sobre testing). De esas: 5 se escribieron en TASK_STATE o BACKLOG, 3 se implementaron, 1 se descarto deliberadamente, 1 quedo pendiente, 5 se perdieron con las sesiones. Tasa = 4 procesadas / 10 generadas = 40%.

### MET-009: Cobertura de Tipos de Perdida (Loss Type Coverage)
**Dimension:** Resiliencia
**Definicion:** Proporcion de tipos de perdida de contexto conocidos que tienen al menos una mitigacion efectiva activa en el proyecto. Mide que tan completa es la proteccion contra perdidas conocidas.
**Formula/Metodo de medicion:** Usar la taxonomia de tipos de perdida del catalogo de mitigaciones (8 tipos: perdida_de_sugerencia, perdida_de_estado, contexto_insuficiente_para_agente, re-descubrimiento, duplicacion_de_trabajo, crecimiento_sin_limpieza, perdida_por_compresion, perdida_inter-proyecto). Para cada tipo, verificar si el proyecto tiene al menos una mitigacion activa (no solo definida en la metodologia, sino realmente practicada). `Cobertura = tipos cubiertos / 8`.
**Unidad:** Porcentaje (%)
**Baseline:** ~62% (5/8 tipos bien cubiertos en proyectos que siguen la metodologia v3; perdida_por_compresion, perdida_inter-proyecto y crecimiento_sin_limpieza tienen cobertura debil o ausente segun el catalogo de mitigaciones).
**Target:** >= 87% (7/8; la perdida por compresion es parcialmente fuera de control).
**Frecuencia de medicion:** Trimestral, o al incorporar un nuevo proyecto al ecosistema claude_context.
**Ejemplo:** Proyecto Recetario. Perdida de sugerencia: tiene TASK_STATE con seccion sugerencias (cubierto). Perdida de estado: TASK_STATE activo (cubierto). Contexto agente: usa perfiles de herencia (cubierto). Re-descubrimiento: LEARNINGS actualizado (cubierto). Duplicacion: backlog como gate (cubierto). Crecimiento: archivos exceden limites sin corregir (NO cubierto). Compresion: sin mitigacion (NO cubierto). Inter-proyecto: sin indice cruzado (NO cubierto). Cobertura = 5/8 = 62%.

### MET-010: Distancia de Sesion (Session Gap Distance)
**Dimension:** Accesibilidad + Transferibilidad
**Definicion:** Cantidad de informacion contextual que una sesion nueva necesita reconstruir antes de alcanzar el nivel de entendimiento de la sesion anterior al cerrarse. Medido como el numero de preguntas que la sesion nueva necesitaria hacer (o inferir) para estar al dia.
**Formula/Metodo de medicion:** Al inicio de una sesion que retoma trabajo previo, listar las preguntas que necesitan respuesta para continuar (ej: "que se estaba haciendo?", "que decision se tomo sobre X?", "que error se encontro?"). Contar cuantas se responden con el contexto persistido y cuantas requieren re-descubrimiento. `Distancia = preguntas sin respuesta en contexto`.
**Unidad:** Cantidad de preguntas sin respuesta (numero entero)
**Baseline:** 3-5 preguntas para proyectos con TASK_STATE parcial. 0-1 para proyectos con TASK_STATE completo. 8-10+ para proyectos sin gestion de contexto (incidente youtube-rag: la sesion nueva no sabia ni cual era el archivo correcto).
**Target:** <= 2 preguntas sin respuesta en contexto persistido.
**Frecuencia de medicion:** Al inicio de cada sesion que retoma trabajo previo.
**Ejemplo:** Sesion nueva de Orchestrator despues de interrupcion en testing E2E. Preguntas: (1) Que pasos del test se completaron? -> TASK_STATE dice pasos 1-3 PASS [OK]. (2) Que servicios necesito levantar? -> Snapshot en TASK_STATE [OK]. (3) Que error se encontro en paso 3? -> No registrado [GAP]. (4) El web monitor necesita rebuild? -> No documentado [GAP]. Distancia = 2.

---

## 3. Scorecard

Template para evaluar un proyecto en ~15 minutos:

| # | Metrica | Peso | Metodo rapido | Valor | Score (0-100) | Ponderado |
|---|---------|------|---------------|-------|---------------|-----------|
| 1 | Tiempo de Retoma (MET-001) | 15% | Estimar min hasta primer output productivo | ___ min | ___ | ___ |
| 2 | Tasa de Re-descubrimiento (MET-002) | 15% | Ultimas 5 sesiones: cuantas re-descubrieron algo? | ___% | ___ | ___ |
| 3 | Cobertura de Persistencia (MET-003) | 15% | "Si la sesion muere ahora, que se pierde?" | ___% | ___ | ___ |
| 4 | Frescura de Contexto (MET-004) | 10% | Verificar version y metricas en CLAUDE.md | ___% | ___ | ___ |
| 5 | Eficiencia de Contexto (MET-005) | 10% | De los @imports, cuantos se usaron hoy? | ___% | ___ | ___ |
| 6 | Score de Agentes (MET-006) | 10% | Ultimas 5 delegaciones: cuantas exitosas? | ___% | ___ | ___ |
| 7 | Cumplimiento de Archivado (MET-007) | 5% | Contar lineas de archivos de contexto | ___% | ___ | ___ |
| 8 | Supervivencia de Sugerencias (MET-008) | 10% | Revisar "Sugerencias Pendientes" en TASK_STATE | ___% | ___ | ___ |
| 9 | Cobertura de Tipos de Perdida (MET-009) | 5% | Recorrer 8 tipos, verificar mitigacion activa | ___% | ___ | ___ |
| 10 | Distancia de Sesion (MET-010) | 5% | Cuantas preguntas sin respuesta al retomar? | ___ preg | ___ | ___ |
| | **Total** | **100%** | | | | **___/100** |

### Tabla de conversion a score (0-100)

| Metrica | 0 | 25 | 50 | 75 | 100 |
|---------|---|----|----|-----|-----|
| MET-001 (min) | >30 | 20-30 | 10-20 | 5-10 | <5 |
| MET-002 (%) | >50% | 30-50% | 20-30% | 10-20% | <10% |
| MET-003 (%) | <20% | 20-40% | 40-60% | 60-80% | >80% |
| MET-004 (%) | <40% | 40-60% | 60-75% | 75-90% | >90% |
| MET-005 (%) | <30% | 30-50% | 50-65% | 65-75% | >75% |
| MET-006 (%) | <50% | 50-70% | 70-80% | 80-90% | >90% |
| MET-007 (%) | <40% | 40-60% | 60-80% | 80-95% | 100% |
| MET-008 (%) | <20% | 20-40% | 40-55% | 55-70% | >70% |
| MET-009 (%) | <37% | 37-50% | 50-62% | 62-87% | >87% |
| MET-010 (preg) | >8 | 5-8 | 3-5 | 1-2 | 0 |

---

## 4. Niveles de Madurez

| Nivel | Score | Descripcion | Metricas clave | Ejemplo |
|-------|-------|-------------|---------------|---------|
| **1 - Ad hoc** | 0-20 | Sin gestion de contexto. Cada sesion empieza de cero. No hay archivos de estado, backlog ni learnings. | MET-001 >30 min, MET-003 <20%, MET-010 >8 preguntas | Proyecto nuevo sin CLAUDE.md ni estructura de contexto |
| **2 - Reactivo** | 21-40 | Gestion de contexto minima. Existe CLAUDE.md basico y backlog, pero no se actualiza consistentemente. Se reacciona a perdidas pero no se previenen. | MET-001 15-25 min, MET-002 >30%, MET-004 <60% | Proyecto con CLAUDE.md desactualizado y sin TASK_STATE |
| **3 - Estructurado** | 41-60 | Estructura de contexto definida (3 capas, limites, templates). Se cumple parcialmente. Las perdidas de contexto ocurren pero se recuperan mas rapido. | MET-003 40-60%, MET-007 60-80%, MET-009 50-62% | Proyecto con claude_context configurado pero archivos parcialmente desactualizados |
| **4 - Gestionado** | 61-80 | Gestion activa de contexto. TASK_STATE al dia, LEARNINGS actualizado, delegaciones con contexto completo. Las perdidas son infrecuentes y el impacto es bajo. | MET-001 <10 min, MET-002 <20%, MET-006 >80% | Proyecto con metodologia v3 aplicada consistentemente |
| **5 - Optimizado** | 81-100 | Contexto minimo y preciso. Archivado al dia, carga selectiva, feedback loop activo. Las interrupciones casi no causan perdida. El sistema aprende de cada incidente. | MET-003 >80%, MET-005 >75%, MET-008 >70%, MET-010 <=1 | Proyecto con todas las mitigaciones activas, enforcement parcial, y mejora continua |

### Progresion tipica

```
Nivel 1 -> 2: Crear CLAUDE.md y PRODUCT_BACKLOG.md basicos (~1h de setup)
Nivel 2 -> 3: Implementar estructura claude_context, TASK_STATE, limites (~2h)
Nivel 3 -> 4: Disciplina de actualizacion, perfiles de agentes, checkpoints (~sprints de practica)
Nivel 4 -> 5: Optimizar carga, enforcement parcial, feedback loops (~mejora continua)
```

---

## 5. Metodo de Aplicacion

### Evaluacion rapida (15 minutos)

1. **Abrir el scorecard** (seccion 3) y el proyecto a evaluar.

2. **MET-001 (Tiempo de Retoma):** Recordar la ultima vez que se retomo este proyecto. Cuanto tomo hasta el primer output productivo? Si no se recuerda, estimar basado en la calidad del TASK_STATE.

3. **MET-002 (Re-descubrimiento):** En las ultimas 5 sesiones, hubo alguna vez que se re-investigo algo ya decidido? Contar instancias.

4. **MET-003 (Cobertura de Persistencia):** Preguntarse: "Si esta sesion muere AHORA, que se pierde?" Listar items de contexto activo y verificar cuantos estan escritos.

5. **MET-004 (Frescura):** Abrir CLAUDE.md: la version es correcta? Los endpoints existen? Abrir ARCHITECTURE: refleja el codigo actual? Contar archivos correctos vs total.

6. **MET-005 (Eficiencia):** Revisar los @imports del proyecto. Cuantos se consultaron en la sesion actual? El resto es ruido.

7. **MET-006 (Score de Agentes):** En las ultimas 5 delegaciones a agentes, cuantas funcionaron sin re-trabajo? Si no hay registro, estimar.

8. **MET-007 (Cumplimiento de Archivado):** Contar lineas de CLAUDE.md, TASK_STATE, BACKLOG, ARCHITECTURE, LEARNINGS. Cuantos estan dentro de limite?

9. **MET-008 (Supervivencia de Sugerencias):** Revisar "Sugerencias Pendientes" en TASK_STATE. Hay items viejos sin procesar? Estimar cuantas sugerencias se generaron vs cuantas sobrevivieron.

10. **MET-009 (Cobertura de Tipos):** Recorrer los 8 tipos de perdida. Para cada uno, hay al menos una mitigacion ACTIVA (no solo definida)?

11. **MET-010 (Distancia de Sesion):** Si esta retomando trabajo previo, cuantas preguntas necesito hacer/inferir para ponerse al dia? Si es sesion nueva, estimar basado en el TASK_STATE.

12. **Calcular score ponderado** usando la tabla de conversion y los pesos.

13. **Determinar nivel de madurez** segun el score total.

### Cuando evaluar

| Momento | Alcance | Duracion |
|---------|---------|----------|
| Inicio de proyecto nuevo | Scorecard completo (sera bajo, y esta bien) | 15 min |
| Cierre de sprint | Scorecard completo | 15 min |
| Despues de un incidente de perdida | Metricas afectadas por el incidente | 5 min |
| Retrospectiva trimestral | Scorecard completo + comparacion con evaluacion anterior | 30 min |

### Registro de evaluaciones

Guardar resultados en `archive/metrics/YYYY-MM-DD-proyecto.md` para trackear progresion:

```markdown
# Evaluacion de Contexto: [Proyecto]
**Fecha:** YYYY-MM-DD | **Evaluador:** [nombre]
**Score:** XX/100 | **Nivel:** N - [nombre]

| Metrica | Valor | Score |
|---------|-------|-------|
| MET-001 | X min | XX |
| ... | ... | ... |

## Observaciones
[Que mejorar, que funciona bien]

## Comparacion
[vs evaluacion anterior si existe]
```

### Acciones por nivel

| Nivel actual | Accion prioritaria |
|-------------|-------------------|
| 1 - Ad hoc | Crear estructura minima: CLAUDE.md + TASK_STATE + PRODUCT_BACKLOG |
| 2 - Reactivo | Implementar protocolo de inicio de sesion y limites de archivos |
| 3 - Estructurado | Mejorar disciplina de actualizacion: checkpoints cada 30 min, WIP commits |
| 4 - Gestionado | Optimizar carga de contexto, implementar feedback loops de delegacion |
| 5 - Optimizado | Mantener y compartir learnings entre proyectos, explorar enforcement automatizado |
