### REC-006: Sin tests para import/parser, OCR, auth ni sync

**Points:** 13 | **Priority:** HIGH | **DoR Level:** L2
**Epic:** EPIC-001 - Estabilizacion y Firebase Condicional

**As a** desarrollador de Recetario
**I want** tener una suite de tests completa que cubra import/parser, OCR, auth y sync
**So that** pueda hacer cambios con confianza de no introducir regresiones y validar que las funcionalidades operan correctamente

#### Acceptance Criteria

**AC1: Tests unitarios para RecipeParser - JSON-LD**
- Given HTML de ejemplo con JSON-LD valido de Schema.org/Recipe
- When se ejecutan los tests del parser JSON-LD
- Then se verifica extraccion correcta de titulo, ingredientes, pasos, imagen, tiempos
- And se cubren los formatos: HowToStep simple, HowToSection, strings planos, mixto

**AC2: Tests unitarios para RecipeParser - Heuristica**
- Given HTML de ejemplo sin JSON-LD pero con estructura heuristica (clases CSS, headings)
- When se ejecutan los tests de parsing heuristico
- Then se verifica extraccion por clases CSS comunes (recipe-ingredients, recipe-instructions)
- And se verifica extraccion por headings (fallback)
- And se verifica el manejo de sitios sin estructura reconocible (retorna error descriptivo)

**AC3: Tests unitarios para RecipeParser - HTTP**
- Given un mock de http.Client
- When se ejecutan los tests de la capa HTTP del parser
- Then se verifica manejo de timeout
- And se verifica manejo de errores 4xx/5xx
- And se verifica validacion de URL (SSRF)
- And se verifica limite de tamanio de respuesta

**AC4: Tests unitarios para OcrService**
- Given un mock de TextRecognizer
- When se ejecutan los tests del servicio OCR
- Then se verifica procesamiento de imagen con texto reconocido
- And se verifica manejo de imagen sin texto
- And se verifica dispose correcto del TextRecognizer

**AC5: Tests unitarios para AuthService**
- Given mocks de FirebaseAuth y GoogleSignIn
- When se ejecutan los tests del servicio de autenticacion
- Then se verifica login exitoso con Google
- And se verifica manejo de login cancelado por usuario
- And se verifica logout
- And se verifica comportamiento cuando Firebase no esta disponible (retorna estado "disabled")

**AC6: Tests unitarios para SyncEngine**
- Given mocks de Firestore y repositorio local
- When se ejecutan los tests del motor de sincronizacion
- Then se verifica upload de recetas nuevas
- And se verifica download incremental (solo recetas nuevas/modificadas)
- And se verifica deteccion de conflictos
- And se verifica comportamiento cuando Firebase no esta disponible

**AC7: Test de widget para pantalla principal**
- Given la app configurada sin Firebase
- When se renderiza la pantalla principal
- Then el widget test pasa sin crash
- And se verifica la estructura basica de la UI (AppBar, lista, FAB)

**AC8: Coverage minimo**
- Given todos los tests ejecutados
- When se genera el reporte de coverage
- Then el coverage es >70% para archivos de parser, OCR, auth y sync
- And el coverage global es >60%

#### Technical Notes

- Directorio de tests: `test/`
- Estructura sugerida:
  ```
  test/
    features/
      import/
        data/services/
          recipe_parser_test.dart
          recipe_parser_jsonld_test.dart
          recipe_parser_heuristic_test.dart
        ocr_service_test.dart
      auth/
        data/services/auth_service_test.dart
      sync/
        data/services/sync_engine_test.dart
    widget_test.dart (corregir el existente)
  ```
- Usar `mocktail` o `mockito` para mocks
- Para tests de parser, crear fixtures con HTML real de sitios populares
- El widget test existente falla porque intenta inicializar Firebase; corregir para que funcione sin Firebase (depende de REC-001/REC-002)
- Considerar dividir esta story en sub-tareas para distribuir el trabajo

#### DoD

- [ ] Tests unitarios para RecipeParser (JSON-LD + heuristica + HTTP)
- [ ] Tests unitarios para OcrService
- [ ] Tests unitarios para AuthService
- [ ] Tests unitarios para SyncEngine
- [ ] Widget test corregido y pasando
- [ ] Coverage >70% para archivos afectados
- [ ] Coverage global >60%
- [ ] `flutter test` pasa al 100%
- [ ] Build 0 warnings
