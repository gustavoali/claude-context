### REC-003: RecipeParser falla con sitios que usan headings como seccion

**Points:** 5 | **Priority:** HIGH | **DoR Level:** L2
**Epic:** EPIC-002 - Mejora del Importador de Recetas

**As a** usuario de Recetario
**I want** que el importador de recetas funcione con sitios que usan headings HTML para separar secciones
**So that** pueda importar recetas de sitios como El Destape Web y otros que no usan clases CSS especificas

#### Acceptance Criteria

**AC1: Parser detecta ingredientes por heading h2/h3**
- Given una pagina web donde los ingredientes estan debajo de un heading `<h2>Ingredientes</h2>` o `<h3>Ingredientes</h3>`
- When el parser procesa la pagina y los metodos JSON-LD, meta tags y heuristica por clases fallan
- Then el parser extrae correctamente la lista de ingredientes del contenido bajo el heading
- And los ingredientes se presentan como lista individual (un ingrediente por linea)

**AC2: Parser detecta pasos por heading h2/h3**
- Given una pagina web donde los pasos estan debajo de un heading como `<h2>Pasos a seguir</h2>` o `<h2>Preparacion</h2>`
- When el parser procesa la pagina
- Then el parser extrae correctamente los pasos de preparacion
- And los pasos se presentan como lista ordenada

**AC3: Sinonimos en espanol e ingles**
- Given una pagina web con headings en espanol o ingles
- When el parser busca secciones por heading
- Then reconoce sinonimos en espanol: "Ingredientes", "Ingredientes de la receta", "Que necesitas"
- And reconoce sinonimos en ingles: "Ingredients", "What you need"
- And reconoce sinonimos para pasos: "Preparacion", "Pasos", "Pasos a seguir", "Procedimiento", "Instrucciones", "Directions", "Instructions", "Steps", "Method"

**AC4: Fallback es el 4to en la cadena**
- Given que los metodos JSON-LD, meta tags y heuristica por clases CSS no encontraron resultado
- When se ejecuta el 4to fallback por headings
- Then se intenta extraer por headings antes de declarar que no se encontro receta

**AC5: Contenido entre headings se extrae correctamente**
- Given una pagina con multiples headings donde el contenido relevante esta entre dos headings
- When el parser extrae por heading "Ingredientes"
- Then captura todo el contenido (ul, ol, p) entre ese heading y el siguiente heading del mismo nivel o superior
- And no incluye contenido de secciones posteriores

#### Technical Notes

- Archivo afectado: `lib/features/import/data/services/recipe_parser.dart`, metodo `_parseHeuristic`
- Agregar un nuevo metodo `_parseByHeadings` que se ejecute como 4to fallback
- Usar el paquete `html` para navegar el DOM y encontrar headings
- La busqueda de sinonimos debe ser case-insensitive y trim whitespace
- Extraer contenido entre el heading encontrado y el siguiente heading hermano del mismo nivel

#### DoD

- [ ] Codigo implementado con metodo `_parseByHeadings`
- [ ] Tests unitarios con HTML de ejemplo (minimo 3 sitios reales)
- [ ] Manual testing con URLs reales de sitios que usan headings
- [ ] Build 0 warnings
- [ ] `flutter analyze` sin issues
