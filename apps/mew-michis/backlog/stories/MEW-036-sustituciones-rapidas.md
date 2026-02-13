# MEW-036: Sustituciones rapidas en lista de compras
**Epic:** E10 - Funcionalidades Avanzadas
**Version:** v1.3
**Story Points:** 3
**Priority:** Low
**Status:** Pending
**DoR Level:** 1

---

## User Story

**As a** cuidador de gatos
**I want** poder sustituir ingredientes desde la lista de compras
**So that** pueda adaptarme si no encuentro algo

---

## Acceptance Criteria

**AC1: Boton de sustituir**
- Given que estoy en la lista de compras
- When toco un ingrediente
- Then aparece opcion "Sustituir"
- And muestra alternativas permitidas

**AC2: Alternativas validas**
- Given que quiero sustituir pollo
- When veo las alternativas
- Then solo muestra sustitutos permitidos (pavo, etc.)
- And no muestra opciones invalidas

**AC3: Aplicar sustitucion**
- Given que elijo un sustituto
- When confirmo
- Then la lista se actualiza con el nuevo ingrediente
- And las cantidades se recalculan si es necesario

**AC4: Validacion post-sustitucion**
- Given que hago una sustitucion
- When se aplica
- Then el sistema revalida el menu
- And muestra warning si la sustitucion causa problemas

---

## Technical Notes
- Usar matriz de sustituciones de recetas
- Recalcular cantidades si ratio diferente
- Disparar revalidacion del menu
- Integrar con ValidationService existente

---

## Dependencies
- MEW-014 (Lista de compras) - Done
- MEW-012 (Validar restricciones) - Done

---

## Definition of Done
- [ ] UI de sustitucion
- [ ] Logica de alternativas validas
- [ ] Recalculo de cantidades
- [ ] Revalidacion automatica
- [ ] Unit tests
- [ ] Widget tests
- [ ] Code review aprobado
- [ ] Build 0 warnings
