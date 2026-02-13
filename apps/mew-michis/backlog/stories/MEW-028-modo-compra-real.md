# MEW-028: Modo compra real con redondeo comercial
**Epic:** E9 - Exportacion y Compartir
**Version:** v1.2
**Story Points:** 3
**Priority:** Medium
**Status:** Pending
**DoR Level:** 1

---

## User Story

**As a** cuidador de gatos
**I want** ver las cantidades redondeadas para compra real
**So that** pueda pedir cantidades practicas en la carniceria

---

## Acceptance Criteria

**AC1: Toggle de modo compra**
- Given que estoy en la lista de compras
- When activo "Modo compra"
- Then las cantidades se redondean a valores comerciales
- And el toggle es visible y facil de usar

**AC2: Redondeo inteligente**
- Given que tengo 847g de pollo
- When activo modo compra
- Then muestra 900g o 1kg (redondeo hacia arriba)
- And carnes redondean a 50g o 100g

**AC3: Indicador de diferencia**
- Given que veo cantidades redondeadas
- When comparo con el valor exacto
- Then muestra diferencia: "900g (+53g)"
- And entiendo que estoy comprando de mas

**AC4: Suplementos sin redondeo**
- Given que tengo suplementos en la lista
- When activo modo compra
- Then los suplementos mantienen precision exacta
- And no se redondean

---

## Technical Notes
- Redondeo carnes: multiplos de 50g (hacia arriba)
- Redondeo huevos: enteros (hacia arriba)
- Suplementos: sin cambio
- Persistir preferencia de modo

---

## Definition of Done
- [ ] Toggle modo compra
- [ ] Logica de redondeo comercial
- [ ] Indicador de diferencia
- [ ] Unit tests
