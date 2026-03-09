# MC-008: Compilar vocabulario moderno por campo semantico
**Points:** 3 | **Priority:** Medium | **Epic:** EPIC-03 | **Deps:** MC-007

**As a** estudiante de mandarin
**I want** un vocabulario organizado por campos semanticos modernos (tecnologia, vida cotidiana, etc.)
**So that** pueda ver como el sistema de composicion se aplica a conceptos actuales

## Acceptance Criteria

**AC1: Al menos 4 campos semanticos cubiertos**
- Given que el vocabulario moderno abarca multiples dominios
- When compilo el vocabulario
- Then cubro al menos: tecnologia, vida cotidiana, emociones, naturaleza
- And cada campo tiene 15+ palabras con caracteres, pinyin y descomposicion logica

**AC2: Descomposicion etimologica**
- Given que el valor del ejercicio esta en entender la logica, no solo memorizar
- When documento cada palabra
- Then incluyo la descomposicion: componentes individuales -> significado compuesto
- And destaco la logica de por que esa combinacion expresa ese concepto

## Technical Notes
- Output: vocabulary/vocabulario-moderno.md
