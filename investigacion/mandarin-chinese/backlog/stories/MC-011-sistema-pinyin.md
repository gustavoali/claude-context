# MC-011: Documentar el sistema pinyin completo
**Points:** 3 | **Priority:** High | **Epic:** EPIC-04

**As a** estudiante de mandarin
**I want** una referencia completa del sistema pinyin (iniciales, finales, tonos)
**So that** pueda leer y producir correctamente la pronunciacion de cualquier caracter

## Acceptance Criteria

**AC1: Tabla de iniciales y finales**
- Given que pinyin combina iniciales y finales
- When documento el sistema
- Then incluyo tabla completa de las 21 iniciales y ~36 finales
- And cada sonido tiene descripcion articulatoria y comparacion con sonidos en espanol/ingles

**AC2: Los 4 tonos + tono neutro**
- Given que los tonos son distintivos en mandarin
- When documento los tonos
- Then incluyo: descripcion del contorno melodico, notacion numerica y con diacriticos, pares minimos
- And al menos 5 pares minimos que muestren cambio de significado por tono

**AC3: Reglas de cambio tonal (tone sandhi)**
- Given que los tonos cambian en ciertos contextos
- When documento la fonetica
- Then incluyo las reglas de sandhi (3+3, bu, yi) con ejemplos

## Technical Notes
- Output: notes/sistema-pinyin.md
