# MC-001: Catalogar los pictogramas fundamentales (xiang xing zi)
**Points:** 3 | **Priority:** Critical | **Epic:** EPIC-01

**As a** estudiante de mandarin
**I want** un catalogo documentado de los pictogramas fundamentales con su origen visual
**So that** pueda entender las "semillas" del sistema de escritura chino

## Acceptance Criteria

**AC1: Cobertura minima de pictogramas**
- Given que el sistema de escritura parte de pictogramas basicos
- When compilo el catalogo
- Then incluye al menos 30 pictogramas fundamentales (naturaleza, cuerpo, objetos)
- And cada entrada tiene: caracter, pinyin, significado, dibujo original o evolucion grafica

**AC2: Organizacion por categoria semantica**
- Given que los pictogramas representan elementos observables
- When organizo el catalogo
- Then los agrupa por categoria (naturaleza, cuerpo humano, animales, objetos cotidianos)
- And cada categoria tiene al menos 3 ejemplos

**AC3: Fuentes verificadas**
- Given que la informacion debe ser confiable
- When documento cada pictograma
- Then cito al menos una fuente por cada evolucion grafica presentada

## Technical Notes
- Buscar videos del canal Decode Mandarin Chinese sobre pictogramas
- Complementar con recursos academicos sobre evolucion de caracteres oracle bone -> moderno
- Output: notes/pictogramas-fundamentales.md
