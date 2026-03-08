## Incidente: Sesiones de debugging sin registro que motivaron la directiva 12a
**Fecha:** 2026-02-10 (aprox) | **Proyecto:** LinkedIn Transcript Extractor
**Tipo:** re-descubrimiento
**Severidad:** alto
**Detectado por:** Usuario (observado durante multiples sesiones de debugging)

## Descripcion
Durante el desarrollo del LinkedIn Transcript Extractor (un proyecto con 2,700+ tests y multiples modulos complejos como crawling, matching y collection capture), se experimentaron multiples sesiones de debugging donde:
1. Se identificaba un problema (ej: CollectionCaptureOrchestrator discovery returning 0 courses)
2. Se formulaban hipotesis y se probaban
3. La sesion se interrumpia o cerraba antes de resolver completamente
4. La siguiente sesion no tenia conocimiento de las hipotesis ya descartadas ni del progreso del debugging

El TASK_STATE archivado (2026-02-10) muestra evidencia de trabajo complejo multi-sesion con 2,366 tests, epics de 26+ puntos, y problemas conocidos que persistian entre sesiones (ej: "CollectionCaptureOrchestrator discovery: Found 0 courses (broken)" listado como known issue pendiente en TASK_STATE).

## Contexto perdido
- Hipotesis de debugging ya probadas y descartadas
- Stack traces y mensajes de error exactos encontrados
- Pasos de reproduccion que se habian identificado
- Causas raiz parcialmente identificadas
- El "camino" seguido durante el debugging (que se probo en que orden)

## Impacto
- Re-descubrimiento: la sesion siguiente repetia los mismos pasos de diagnostico
- Hipotesis circulares: se probaban las mismas hipotesis que ya se habian descartado
- Tiempo perdido estimado: 30-60 min por sesion de debugging interrumpida
- Problemas que persistian como "known issues" sin registro del progreso de debugging

## Causa raiz
1. No existia una directiva que obligara a registrar el progreso de debugging en tiempo real
2. El debugging es un proceso exploratorio donde el conocimiento se genera en la conversacion, no en archivos
3. Las hipotesis descartadas son "trabajo negativo" (probar que algo NO es la causa) que rara vez se documenta
4. El TASK_STATE solo registraba resultados finales, no el proceso intermedio

## Mitigacion aplicada
- Creacion de la directiva 12a: "Registro en tiempo real de pruebas manuales"
- Formato estandar de registro de pasos con PASS/FAIL
- Regla: "Errores: registrar PRIMERO, investigar DESPUES"
- Seccion "Sesion Activa" en TASK_STATE con campo "Hipotesis en curso"

## Prevencion implementada
- Directiva 12a completa con checklist de que registrar y cuando
- Template de test manual con pre-condiciones, pasos, resultados
- Regla de actualizar TASK_STATE al cambiar de fase (Coding -> Testing -> Debugging -> Fix)
- Registro de servicios activos (snapshot de puertos y procesos)

## Leccion aprendida
El debugging es el tipo de trabajo MAS vulnerable a la perdida de contexto porque:
1. El conocimiento valioso son las hipotesis descartadas (trabajo negativo), no solo la solucion final
2. El proceso es no-lineal: se salta entre archivos, logs, configs
3. El estado mental del debugger (que sospechas, que probaste) no se persiste naturalmente
4. Una sesion interrumpida durante debugging pierde TODO el progreso, a diferencia de coding donde al menos queda el codigo escrito

La directiva 12a fue una respuesta directa a este tipo de incidentes repetidos.
