# MC-005: Investigar la composicion fonetico-semantica
**Points:** 3 | **Priority:** High | **Epic:** EPIC-02 | **Deps:** MC-002

**As a** estudiante de mandarin
**I want** entender como se componen los caracteres fonetico-semanticos (xingshengzi)
**So that** pueda predecir significado y pronunciacion de caracteres desconocidos

## Acceptance Criteria

**AC1: Estructura radical semantico + componente fonetico**
- Given que ~80% de los caracteres siguen este patron
- When documento la composicion
- Then explico la estructura con al menos 15 ejemplos agrupados por radical compartido
- And muestro como el radical sugiere significado y el componente sugiere sonido

**AC2: Limitaciones del sistema**
- Given que la pronunciacion evoluciono desde que se crearon los caracteres
- When documento el sistema
- Then incluyo ejemplos donde la pista fonetica ya no es precisa en mandarin moderno
- And explico por que (cambios foneticos historicos)

## Technical Notes
- Depende de MC-002 (radicales) como prerequisito
- Output: notes/composicion-fonetico-semantica.md
