# MC-010: Crear listas de vocabulario de estudio con caracteres frecuentes
**Points:** 2 | **Priority:** Low | **Epic:** EPIC-03

**As a** estudiante de mandarin
**I want** listas de estudio basadas en frecuencia de uso
**So that** pueda priorizar el aprendizaje de los caracteres mas utiles

## Acceptance Criteria

**AC1: Lista de los 100 caracteres mas frecuentes**
- Given que un numero reducido de caracteres cubre gran parte de los textos
- When compilo la lista
- Then incluyo los 100 caracteres mas frecuentes con: caracter, pinyin, significado, ejemplo de uso
- And cito la fuente de los datos de frecuencia

**AC2: Agrupacion por radical**
- Given que agrupar por radical facilita la memorizacion
- When organizo la lista
- Then ofrezco una vista alternativa agrupada por radical compartido

## Technical Notes
- Output: vocabulary/caracteres-frecuentes.md
