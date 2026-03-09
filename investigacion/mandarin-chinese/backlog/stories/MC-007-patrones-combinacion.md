# MC-007: Analizar patrones de combinacion semantica entre caracteres
**Points:** 4 | **Priority:** Medium | **Epic:** EPIC-02 | **Deps:** MC-002

**As a** estudiante de mandarin
**I want** entender los patrones logicos por los cuales dos caracteres se combinan para formar palabras
**So that** pueda inferir significados de palabras compuestas nuevas

## Acceptance Criteria

**AC1: Patrones de combinacion documentados**
- Given que las palabras compuestas siguen patrones semanticos recurrentes
- When investigo los patrones
- Then documento al menos 6 patrones (ej: modificador+nucleo, verbo+objeto, sujeto+predicado, coordinacion, etc.)
- And cada patron tiene 5+ ejemplos con pinyin y significado

**AC2: Reglas de orden**
- Given que el orden de los caracteres importa (fei ji vs ji fei)
- When documento las combinaciones
- Then explico las reglas que determinan el orden en cada tipo de patron
- And incluyo contraejemplos donde invertir el orden cambia o destruye el significado

**AC3: Productividad de caracteres clave**
- Given que ciertos caracteres son extremadamente productivos en combinaciones
- When investigo
- Then identifico al menos 10 caracteres "productivos" con 5+ palabras compuestas cada uno

## Technical Notes
- Conecta directamente con la tesis del video base (el chino como juego de construccion)
- Output: notes/patrones-combinacion.md
