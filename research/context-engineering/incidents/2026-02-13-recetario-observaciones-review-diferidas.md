## Incidente: Observaciones de code review registradas como "diferidas" sin mecanismo de seguimiento
**Fecha:** 2026-02-14 | **Proyecto:** Recetario (Flutter)
**Tipo:** perdida_de_sugerencia
**Severidad:** bajo
**Detectado por:** Observacion directa (TASK_STATE.md del proyecto)

## Descripcion
Durante la sesion del 2026-02-14, se ejecuto un code review formal (agente `code-reviewer`) sobre el EPIC-002 del proyecto Recetario. El review identifico observaciones de mejora que fueron registradas en TASK_STATE como "diferidas":

- Response size limit para evitar OOM con HTML gigantes
- Normalizar image URLs relativas a absolutas
- Deduplicar logica de extraccion de imagenes entre heuristic y headings

Estas observaciones quedaron listadas en TASK_STATE.md pero NO fueron trasladadas al PRODUCT_BACKLOG.md como historias formales. Dependen de que una sesion futura las encuentre en TASK_STATE y las procese.

## Contexto perdido
- No se perdio la observacion en si (esta registrada), pero se perdio el IMPULSO de procesarla
- El detalle tecnico del code review (que patrones especificos tienen el problema, donde exactamente esta la duplicacion) quedo solo como descripcion de una linea
- La severidad relativa de cada observacion no se documento

## Impacto
- Riesgo de que las observaciones queden permanentemente diferidas sin procesarse
- Si TASK_STATE se limpia o archiva (directiva 7 de limites), las observaciones podrian perderse
- Tiempo minimo para recuperar contexto si se quiere actuar: ~15 min de re-analisis del codigo

## Causa raiz
1. El flujo "code review -> observaciones -> backlog" no se completo en la misma sesion
2. El TASK_STATE funciono como buffer temporal, pero no hay mecanismo para procesar items diferidos
3. La directiva 12b ("documentar sugerencias inmediatamente") se cumplio parcialmente: se documentaron, pero no se convirtieron en items accionables del backlog

## Mitigacion aplicada
- Las observaciones estan registradas en TASK_STATE.md del proyecto
- Tambien se documento en CODE_REVIEW_LEARNINGS.md reglas derivadas del review (R001 y R002)

## Prevencion propuesta
- Completar el flujo en la misma sesion: code review -> observaciones -> historias en backlog
- Alternativa: crear un checklist de cierre de sesion que incluya "procesar items diferidos"
- Mejorar directiva 12b para especificar que las observaciones de code review deben convertirse en historias de backlog, no quedarse como notas en TASK_STATE

## Leccion aprendida
Las observaciones "diferidas" son un tipo de deuda de proceso: informacion que se capturo pero no se transformo en accion. A diferencia de las sugerencias completamente perdidas (incidente Gaia Protocol), estas sugerencias estan registradas pero en un formato no-accionable. El riesgo es que se conviertan en ruido que eventualmente se ignora o se limpia sin procesar.
