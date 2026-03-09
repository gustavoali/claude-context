# MC-002: Investigar el sistema de radicales (bushou)
**Points:** 3 | **Priority:** Critical | **Epic:** EPIC-01

**As a** estudiante de mandarin
**I want** entender el sistema de radicales y su funcion en la composicion de caracteres
**So that** pueda descomponer caracteres desconocidos en partes reconocibles

## Acceptance Criteria

**AC1: Documentar los radicales mas frecuentes**
- Given que existen 214 radicales en el sistema Kangxi
- When investigo los radicales
- Then documento al menos los 40 mas frecuentes en el chino moderno
- And cada uno incluye: radical, pinyin, significado, posicion tipica (izq, der, arriba, abajo)

**AC2: Relacion radical-significado**
- Given que los radicales aportan pista semantica al caracter
- When documento cada radical
- Then incluyo 3+ ejemplos de caracteres que lo contienen
- And explico como el radical sugiere el campo semantico del caracter

**AC3: Diferencia entre radical y componente**
- Given que no todo componente de un caracter es su radical
- When documento el sistema
- Then explico claramente la diferencia entre radical clasificatorio y componente fonetico

## Technical Notes
- Los radicales son la base para EPIC-02 (composicion)
- Output: notes/sistema-radicales.md
