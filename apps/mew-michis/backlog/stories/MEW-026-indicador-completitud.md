# MEW-026: Indicador de completitud de receta
**Epic:** E8 - UX y Explicabilidad
**Version:** v1.1
**Story Points:** 2
**Priority:** Medium
**Status:** Pending
**DoR Level:** 1

---

## User Story

**As a** cuidador de gatos
**I want** ver rapidamente si una receta es completa o requiere algo mas
**So that** sepa que recetas puedo usar directamente

---

## Acceptance Criteria

**AC1: Indicador verde - completa**
- Given que veo una receta en el catalogo
- When la receta incluye todos los suplementos
- Then muestra indicador verde
- And tooltip dice "Receta completa"

**AC2: Indicador amarillo - requiere suplemento**
- Given que veo una receta
- When la receta requiere suplemento adicional segun variacion
- Then muestra indicador amarillo
- And tooltip dice "Requiere: [suplemento]"

**AC3: Indicador en lista y detalle**
- Given que navego el catalogo de recetas
- When veo la lista o el detalle
- Then el indicador es visible en ambas vistas
- And es consistente

---

## Technical Notes
- Usar chip o badge pequeno
- Colores: verde (completa), amarillo (requiere algo)
- Integrar con RecipeCard y RecipeDetailScreen

---

## Definition of Done
- [ ] Indicador en lista de recetas
- [ ] Indicador en detalle de receta
- [ ] Logica de completitud
- [ ] Widget tests
