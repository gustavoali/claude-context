# Sugerencia: Resiliencia de Sesion - Acciones para Minimizar Perdida de Contexto
**Fecha:** 2026-02-25 | **Origen:** Perdida real de sugerencias en sesion interrumpida de Gaia Protocol
**Proyecto afectado:** Metodologia General (todos los proyectos)
**Estado:** Propuesta para revision del usuario

---

## Problema Observado

Durante el desarrollo de Gaia Protocol, una sesion fue interrumpida por limite de contexto. Se perdieron:
- Sugerencias sobre herramientas MCP adicionales que se necesitaban
- Contexto de decisiones tomadas durante la conversacion
- El "por que" detras de ciertas elecciones de implementacion

Las directivas 12a (pruebas manuales) y 12b (sugerencias/decisiones) mitigan parte del problema. Pero hay mas puntos vulnerables en el flujo de trabajo.

---

## Analisis: Puntos de Vulnerabilidad en una Sesion

| Momento | Que se pierde si la sesion muere | Probabilidad | Impacto |
|---------|----------------------------------|-------------|---------|
| Durante planificacion/analisis | Razonamiento, alternativas consideradas, trade-offs | Alta | Alto |
| Despues de lanzar agentes en paralelo | Resultados parciales, contexto de coordinacion | Media | Alto |
| Durante debugging | Hipotesis probadas, lo que funciono/no funciono | Alta | Critico |
| Despues de code review | Hallazgos, items a corregir, prioridad de fixes | Media | Alto |
| Durante conversacion de diseño | Decisiones arquitectonicas, constraints discutidos | Media | Alto |
| Entre olas de trabajo paralelo | Estado de ola completada, plan para siguiente ola | Media | Medio |

---

## Acciones Propuestas

### Accion 1: Checkpoints de estado entre operaciones mayores

**Antes de lanzar agentes en paralelo**, escribir en TASK_STATE:
- Que agentes se van a lanzar y con que tarea
- Que resultado se espera de cada uno
- Cual es el plan post-agentes (siguiente ola, review, etc.)

**Despues de recibir resultados de agentes**, escribir en TASK_STATE:
- Resumen de lo que cada agente produjo
- Archivos creados/modificados
- Problemas encontrados o pendientes

**Costo:** ~1 min por checkpoint. **Beneficio:** Retomar trabajo en 5 min en lugar de 30+.

### Accion 2: WIP commits mas agresivos

Actualmente se commitea al final de un grupo de historias. Propongo:

| Evento | Accion |
|--------|--------|
| Agente completa una historia | `git add` archivos + WIP commit |
| Code review identifica fixes | Commit pre-fix como checkpoint |
| Antes de lanzar Ola 2 de trabajo | Commit Ola 1 como WIP |
| Antes de pruebas manuales | Commit (ya cubierto por 12a) |

El commit WIP se puede squashear al final si se prefiere un historial limpio. Lo importante es que el codigo esta resguardado.

### Accion 3: Documentar razonamiento de diseño inline

Cuando se toma una decision de diseño durante la conversacion (ej: "usamos GPU instancing en vez de StaticBatchingUtility"), documentar inmediatamente en:
- Un comentario en el codigo si es tecnico-local
- `ARCHITECTURE_ANALYSIS.md` si es arquitectonico
- `LEARNINGS.md` si es un patron aprendido

**No esperar al cierre de sesion.** El conocimiento del "por que" es mas valioso que el "que" y es lo que mas se pierde.

### Accion 4: Resumen ejecutivo periodico en TASK_STATE

Cada ~30 minutos de trabajo activo (o despues de cada hito significativo), actualizar la seccion "Sesion Activa" de TASK_STATE con un mini-resumen:

```markdown
## Sesion Activa
**Ultimo update:** HH:MM
**Progreso:** GP-022 Done, GP-027 Done, GP-030 en review
**Archivos nuevos:** InfluenceOverlay.cs, HexPool.cs, PerformanceMonitor.cs
**Pendiente esta sesion:** Aplicar fixes de review, luego GP-031
**Contexto critico:** StaticBatchingUtility rompe HexSelector - decidimos usar GPU instancing
```

### Accion 5: Log de resultados de code review

Los hallazgos de code review son especialmente vulnerables porque:
- Son output de un agente (no persisten automaticamente)
- Requieren accion (fixes) que puede interrumpirse a mitad
- El contexto de "que se encontro" y "que se fixeo" se pierde facilmente

Propuesta: Al recibir resultado de code-reviewer, escribir un resumen estructurado en TASK_STATE:

```markdown
## Code Review: [historias revisadas]
**Criticos:** C-01 [descripcion], C-02 [descripcion]
**Mayores:** M-01 [descripcion], ...
**Aplicados:** C-01 (fixed), M-01 (fixed)
**Pendientes:** M-03 (en progreso)
```

### Accion 6: Plan de trabajo escrito antes de ejecutar

Cuando el usuario pide trabajo complejo (ej: "implementa las 4 historias pendientes en paralelo"), antes de lanzar agentes, escribir el plan en TASK_STATE:

```markdown
## Plan de Ejecucion
**Ola 1 (paralelo):** GP-022 + GP-027 + GP-030
**Ola 2 (secuencial):** GP-031 (depende de ActionFeedback de Ola 1)
**Post-implementacion:** Code review riguroso, luego commit
**Estimacion:** 2 olas + review + commit
```

Esto permite que si la sesion muere en la mitad de Ola 2, la siguiente sesion sabe exactamente donde retomar.

---

## Resumen de Acciones

| # | Accion | Cuando | Costo | Impacto |
|---|--------|--------|-------|---------|
| 1 | Checkpoints entre operaciones mayores | Pre/post agentes | ~1 min | Alto |
| 2 | WIP commits mas agresivos | Post-historia, pre-ola | ~30 seg | Alto |
| 3 | Razonamiento de diseño inline | Al decidir | ~1 min | Medio-Alto |
| 4 | Resumen ejecutivo periodico | Cada ~30 min | ~2 min | Alto |
| 5 | Log de resultados de code review | Post-review | ~2 min | Alto |
| 6 | Plan de trabajo escrito antes de ejecutar | Pre-ejecucion compleja | ~2 min | Medio |

**Costo total estimado:** ~10 min por sesion de trabajo de 2-4 horas.
**Beneficio:** Reduccion de ~80% en tiempo de retomar trabajo tras interrupcion.

---

## Recomendacion

Integrar las acciones 1-6 como sub-puntos de la directiva 12 ("Proteccion de Contexto ante Interrupciones"). Son complementarias a 12a (pruebas manuales) y 12b (sugerencias/decisiones) y cubren los gaps restantes del flujo de trabajo.

**Accion recomendada:** Que el usuario revise estas propuestas y confirme cuales incorporar a la directiva 12.
