# MEW-040: Importacion de recetas externas
**Epic:** E11 - Recetas Personalizadas
**Version:** v2.0
**Story Points:** 10
**Priority:** Low
**Status:** Pending
**DoR Level:** 2

---

## User Story

**As a** usuario de Mew Michis
**I want** importar recetas creadas por otros
**So that** pueda usar recetas compartidas por la comunidad

---

## Acceptance Criteria

**AC1: Importar archivo SER**
- Given que tengo un archivo .ser.json
- When toco "Importar receta"
- Then el sistema lee el archivo
- And comienza validacion

**AC2: Validacion de importacion**
- Given que importo una receta
- When el sistema la valida
- Then verifica: formato correcto, reglas nutricionales, version compatible
- And muestra resultado

**AC3: Resultado de validacion**
- Given que la validacion termina
- When veo el resultado
- Then es: aceptada, aceptada con ajustes, o rechazada
- And explica por que

**AC4: Receta importada en catalogo**
- Given que la receta es aceptada
- When confirmo importacion
- Then aparece en mi catalogo con badge "importada"
- And puedo usarla normalmente

**AC5: Rechazo con explicacion**
- Given que la receta es rechazada
- When veo el resultado
- Then explica que regla viola
- And sugiere como corregirla

---

## Technical Notes
- Parsear JSON con validacion de schema
- Validar contra reglas nutricionales del motor
- Permitir ajustes automaticos si son menores
- Usar file_picker para seleccionar archivo
- Considerar seguridad: sanitizar datos importados

---

## Dependencies
- MEW-037 (Modelo recetas extendidas) - OBLIGATORIO
- MEW-039 (Formato SER) - OBLIGATORIO, define el formato de importacion
- Package file_picker

---

## Definition of Done
- [ ] Importacion de archivo .ser.json
- [ ] Validacion completa (formato + reglas nutricionales)
- [ ] UI de resultados de validacion
- [ ] Integracion con catalogo de recetas
- [ ] Manejo de errores y rechazo con explicacion
- [ ] Unit tests
- [ ] Widget tests
- [ ] Integration tests
- [ ] Code review aprobado
- [ ] Build 0 warnings
