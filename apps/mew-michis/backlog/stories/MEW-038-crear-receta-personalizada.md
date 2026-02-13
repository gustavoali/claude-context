# MEW-038: Crear receta personalizada
**Epic:** E11 - Recetas Personalizadas
**Version:** v2.0
**Story Points:** 8
**Priority:** Low
**Status:** Pending
**DoR Level:** 2

---

## User Story

**As a** cuidador de gatos
**I want** crear mi propia receta basada en una receta oficial
**So that** pueda adaptarla a mis necesidades manteniendo la seguridad

---

## Acceptance Criteria

**AC1: Iniciar desde receta base**
- Given que estoy viendo una receta oficial
- When toco "Crear variacion"
- Then se abre editor con la receta como base
- And puedo modificar dentro de limites

**AC2: Modificar ingredientes**
- Given que estoy en el editor
- When cambio una proteina o porcentaje
- Then el sistema valida en tiempo real
- And muestra warning si me acerco a limites

**AC3: Guardar receta personalizada**
- Given que mi receta es valida
- When toco "Guardar"
- Then se guarda como receta custom
- And aparece en mi catalogo con badge correspondiente

**AC4: Usar en menu**
- Given que tengo recetas custom
- When armo el menu semanal
- Then puedo usarlas igual que las oficiales
- And las validaciones semanales las incluyen

---

## Technical Notes
- Editor basado en RecipeDetailScreen
- Validacion en tiempo real
- Guardar como ExtendedRecipe (modelo de MEW-037)
- Reutilizar componentes de UI de recetas existentes

---

## Dependencies
- MEW-037 (Modelo recetas extendidas) - OBLIGATORIO, define el modelo de datos

---

## Definition of Done
- [ ] UI de editor de receta
- [ ] Validacion en tiempo real
- [ ] Persistencia de receta custom
- [ ] Integracion con menu semanal
- [ ] Unit tests
- [ ] Widget tests
- [ ] Integration tests
- [ ] Code review aprobado
- [ ] Build 0 warnings
