# MC-013: Compilar errores comunes de pronunciacion para hispanohablantes
**Points:** 2 | **Priority:** Medium | **Epic:** EPIC-04 | **Deps:** MC-011

**As a** estudiante hispanohablante de mandarin
**I want** conocer los errores de pronunciacion mas comunes que cometen los hispanohablantes
**So that** pueda prestar atencion especial a esos puntos desde el inicio

## Acceptance Criteria

**AC1: Sonidos problematicos identificados**
- Given que ciertos sonidos del mandarin no existen en espanol
- When investigo los errores comunes
- Then documento al menos 8 sonidos problematicos (ej: zh/ch/sh, x/q, u/u con dieresis, tonos)
- And cada uno incluye: error tipico, sonido correcto, tecnica de correccion

**AC2: Recursos de audio recomendados**
- Given que la pronunciacion requiere input auditivo
- When compilo los errores
- Then incluyo al menos 3 recursos (apps, canales, sitios) para practicar cada sonido

## Technical Notes
- Output: notes/errores-pronunciacion-hispanohablantes.md
