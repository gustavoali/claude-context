# MC-004: Clasificar los 6 metodos de formacion de caracteres (liushu)
**Points:** 2 | **Priority:** High | **Epic:** EPIC-01 | **Deps:** MC-001

**As a** estudiante de mandarin
**I want** entender los 6 metodos tradicionales de formacion de caracteres (liu shu)
**So that** pueda identificar que tipo de logica sigue cada caracter que encuentre

## Acceptance Criteria

**AC1: Los 6 metodos documentados**
- Given que la tradicion clasifica los caracteres en 6 categorias de formacion
- When documento los liushu
- Then cubro los 6: pictogramas, ideogramas simples, ideogramas compuestos, fonetico-semanticos, transferencia, prestamo
- And cada metodo tiene definicion clara + 5 ejemplos minimo

**AC2: Proporcion en el vocabulario moderno**
- Given que no todos los metodos son igualmente productivos
- When documento los liushu
- Then incluyo la proporcion aproximada de cada tipo en el chino moderno
- And destaco que los fonetico-semanticos representan ~80% de los caracteres

## Technical Notes
- Conecta con MC-001 (pictogramas) y MC-005 (composicion fonetico-semantica)
- Output: notes/liushu-seis-metodos.md
