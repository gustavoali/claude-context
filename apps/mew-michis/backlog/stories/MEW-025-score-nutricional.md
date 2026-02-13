# MEW-025: Score nutricional semanal
**Epic:** E8 - UX y Explicabilidad
**Version:** v1.1
**Story Points:** 5
**Priority:** Medium
**Status:** Pending
**DoR Level:** 2

---

## User Story

**As a** cuidador de gatos
**I want** ver una puntuacion de mi menu semanal
**So that** tenga una metrica clara de que tan bien esta balanceado

---

## Acceptance Criteria

**AC1: Score visible (0-100)**
- Given que tengo un menu semanal configurado
- When veo el resumen del menu
- Then aparece score numerico (ej: 85/100)
- And tiene indicador visual (barra o circulo de progreso)

**AC2: Calculo del score**
- Given que el sistema calcula el score
- When analiza el menu
- Then considera: variedad de recetas, cumplimiento de limites, suplementos completos
- And penaliza: repeticion excesiva, warnings, dias vacios

**AC3: Desglose del score**
- Given que veo el score
- When toco para ver detalle
- Then muestra breakdown: "Variedad: 20/25, Limites: 25/25, Completitud: 40/50"
- And entiendo que mejorar

**AC4: Score actualiza en tiempo real**
- Given que modifico el menu
- When cambio una receta
- Then el score se recalcula
- And veo el nuevo valor inmediatamente

---

## Technical Notes
- Algoritmo de scoring:
  - Variedad (25 pts): penalizar repeticion
  - Limites (25 pts): cumplir higado, pescado
  - Suplementos (25 pts): taurina y calcio presentes
  - Completitud (25 pts): 7 dias llenos
- Mostrar como CircularProgressIndicator con texto

---

## Definition of Done
- [ ] Algoritmo de scoring implementado
- [ ] UI de score con breakdown
- [ ] Actualizacion reactiva
- [ ] Unit tests para algoritmo
