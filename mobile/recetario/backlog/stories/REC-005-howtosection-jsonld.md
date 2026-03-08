### REC-005: RecipeParser no maneja HowToSection en JSON-LD

**Points:** 3 | **Priority:** HIGH | **DoR Level:** L1
**Epic:** EPIC-002 - Mejora del Importador de Recetas

**As a** usuario de Recetario
**I want** que el importador maneje correctamente recetas con instrucciones agrupadas en secciones (HowToSection)
**So that** pueda importar recetas de sitios que organizan los pasos en secciones como "Preparar la masa", "Preparar el relleno"

#### Acceptance Criteria

**AC1: HowToSection con HowToStep se parsea correctamente**
- Given una pagina con JSON-LD que contiene `recipeInstructions` con items de `@type: "HowToSection"`
- And cada HowToSection tiene `itemListElement` con items de `@type: "HowToStep"`
- When el parser extrae las instrucciones
- Then se extraen todos los pasos de todas las secciones en orden
- And cada paso incluye el nombre de la seccion como prefijo (e.g., "Masa: Mezclar la harina...")

**AC2: Mix de HowToStep y HowToSection**
- Given una pagina con JSON-LD donde `recipeInstructions` mezcla HowToStep directos y HowToSection
- When el parser extrae las instrucciones
- Then se extraen tanto los pasos directos como los pasos dentro de secciones
- And el orden se mantiene segun aparecen en el JSON-LD

**AC3: HowToSection sin itemListElement**
- Given una pagina con JSON-LD donde un HowToSection tiene `text` directo pero no `itemListElement`
- When el parser extrae las instrucciones
- Then se usa el campo `text` del HowToSection como un paso
- And no se produce error por ausencia de itemListElement

**AC4: Formato plano de instrucciones sigue funcionando**
- Given una pagina con JSON-LD donde `recipeInstructions` es un array de strings o array de HowToStep simples
- When el parser extrae las instrucciones
- Then se extraen correctamente como antes (sin regresion)

#### Technical Notes

- Archivo afectado: `lib/features/import/data/services/recipe_parser.dart`, metodo `_extractFromSchema`
- Schema.org define que `recipeInstructions` puede ser: string, array de strings, array de HowToStep, array de HowToSection, o mezcla
- Referencia: https://schema.org/Recipe
- El parseo debe ser recursivo o iterativo para manejar la anidacion
- Mantener compatibilidad con el parseo actual de HowToStep simple

#### DoD

- [ ] Codigo implementado manejando todos los formatos de recipeInstructions
- [ ] Tests unitarios con JSON-LD de ejemplo para cada formato
- [ ] Manual testing con al menos 2 URLs reales que usen HowToSection
- [ ] Build 0 warnings
