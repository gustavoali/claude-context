### REC-008: OcrService no dispone TextRecognizer correctamente

**Points:** 2 | **Priority:** HIGH | **DoR Level:** L1
**Epic:** EPIC-002 - Mejora del Importador de Recetas

**As a** usuario de Recetario
**I want** que el servicio OCR libere correctamente los recursos del TextRecognizer
**So that** no se acumulen instancias abiertas que consuman memoria y potencialmente causen crashes

#### Acceptance Criteria

**AC1: TextRecognizer se cierra al destruir el servicio**
- Given que el OcrService creo un TextRecognizer para procesar una imagen
- When el provider que contiene el OcrService se invalida o se destruye
- Then se llama a `textRecognizer.close()` para liberar recursos nativos

**AC2: Multiples invocaciones reutilizan el mismo TextRecognizer**
- Given que el OcrService tiene un TextRecognizer abierto
- When el usuario procesa una segunda imagen sin haber destruido el provider
- Then se reutiliza el mismo TextRecognizer existente
- And no se crea una nueva instancia

**AC3: Error en close no crashea la app**
- Given que el TextRecognizer esta siendo cerrado
- When el close lanza una excepcion (e.g., ya estaba cerrado)
- Then la excepcion se captura y se loguea
- And la app continua funcionando normalmente

#### Technical Notes

- Archivos afectados:
  - `lib/features/import/data/services/ocr_service.dart` - Agregar metodo dispose y singleton del recognizer
  - `lib/features/import/presentation/providers/import_provider.dart` - Llamar dispose al invalidar
- Patron: Lazy initialization del TextRecognizer + dispose explicito
- En Riverpod, usar `ref.onDispose()` para llamar al close del recognizer
- Google ML Kit TextRecognizer es un recurso nativo que DEBE cerrarse

#### DoD

- [ ] Codigo implementado con dispose correcto
- [ ] Tests unitarios verificando que close se llama al dispose
- [ ] Manual testing: procesar 2+ imagenes sin memory leak
- [ ] Build 0 warnings
