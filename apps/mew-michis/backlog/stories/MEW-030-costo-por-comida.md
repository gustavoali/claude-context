# MEW-030: Costo por comida individual
**Epic:** E9 - Exportacion y Compartir
**Version:** v1.2
**Story Points:** 3
**Priority:** Medium
**Status:** Pending
**DoR Level:** 1

---

## User Story

**As a** cuidador de gatos
**I want** ver el costo de cada comida individual
**So that** tenga una metrica mas tangible que el costo semanal

---

## Acceptance Criteria

**AC1: Costo por dia visible**
- Given que veo el menu semanal con precios
- When miro cada dia
- Then muestra el costo de ese dia
- And el formato es claro (ej: "$2.150")

**AC2: Costo en resumen**
- Given que veo el resumen de presupuesto
- When reviso las metricas
- Then muestra: costo promedio por comida, costo diario promedio
- And puedo comparar dias

**AC3: Desglose por dia**
- Given que toco el costo de un dia
- When veo el detalle
- Then muestra los ingredientes de ese dia con sus costos
- And suma total del dia

---

## Technical Notes
- Calcular: costo_dia = sum(ingredientes_dia * precio_unitario)
- Mostrar en MenuDayCard
- Reutilizar logica de MEW-017

---

## Definition of Done
- [ ] Costo por dia en menu
- [ ] Metricas en resumen de presupuesto
- [ ] Desglose por dia
- [ ] Unit tests
