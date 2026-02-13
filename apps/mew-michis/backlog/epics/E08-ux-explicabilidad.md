# Epic 8: UX y Explicabilidad (E8)

**Version:** v1.1
**Objetivo:** Mejorar la confianza del usuario mediante explicaciones claras y feedback visual.
**Valor de negocio:** Reduce errores de uso, aumenta confianza y retencion.
**Story Points Total:** 29
**Status:** EN PROGRESO (3 de 8 historias completadas, 11 de 29 pts)

---

## Historias

| ID | Titulo | Points | Priority | Status |
|----|--------|--------|----------|--------|
| MEW-019 | Onboarding guiado inicial | 5 | Critical | Done |
| MEW-020 | Desglose explicativo del calculo nutricional | 3 | High | Done |
| MEW-021 | Tooltips de justificacion nutricional | 3 | High | Done |
| MEW-022 | Badge de seguridad nutricional en menu | 3 | High | Pending |
| MEW-023 | Errores accionables en validaciones | 5 | High | Pending |
| MEW-024 | Alertas de valores atipicos en perfil | 3 | Medium | Pending |
| MEW-025 | Score nutricional semanal | 5 | Medium | Pending |
| MEW-026 | Indicador de completitud de receta | 2 | Medium | Pending |

---

## Progreso

- **Completadas:** 3 historias (MEW-019, 020, 021) = 11 pts
- **Pendientes:** 5 historias (MEW-022 a 026) = 18 pts
- **Porcentaje:** 38% en pts, 37.5% en historias

---

## Dependencias entre Historias

```
MEW-019 (Onboarding) - Independiente, ya completado
MEW-020 (Desglose calculo) - Independiente, ya completado
MEW-021 (Tooltips) - Independiente, ya completado

MEW-022 (Badge seguridad) - Depende de ValidationService existente (E4)
MEW-023 (Errores accionables) - Depende de ValidationService existente (E4)
MEW-024 (Alertas atipicos) - Independiente
MEW-025 (Score nutricional) - Depende de MEW-022/023 (sistema de validacion mejorado)
MEW-026 (Indicador completitud) - Independiente

Historias pendientes sin dependencias entre si (excepto MEW-025):
  MEW-022, MEW-023, MEW-024, MEW-026 pueden desarrollarse en paralelo
  MEW-025 es mejor despues de MEW-022/023
```

---

## Dependencias con Otros Epics

- **E4 (Menu Semanal):** MEW-022, 023, 025 operan sobre el menu y ValidationService
- **E3 (Motor Nutricional):** MEW-020 expone formulas de CalculationService
- **E2 (Catalogo):** MEW-021 tooltips en recetas, MEW-026 indicador en catalogo
- **E1 (Perfil):** MEW-024 alertas en pantalla de perfil

---

## Detalle de Historias Pendientes

### MEW-022: Badge de seguridad nutricional en menu
**Story Points:** 3 | **Priority:** High | **Status:** Pending | **DoR Level:** 1

**As a** cuidador de gatos
**I want** ver claramente cuando mi menu es nutricionalmente seguro
**So that** tenga tranquilidad de que estoy alimentando bien a mis gatos

**AC1:** Badge verde en menu valido: "Menu nutricionalmente seguro"
**AC2:** Badge amarillo con warnings: "Menu con advertencias"
**AC3:** Badge rojo con errores: "Correccion necesaria"
**AC4:** Actualizacion reactiva al modificar menu

**Technical Notes:** Integrar con ValidationSummaryCard existente. Colores green/amber/red. Animar transiciones.

---

### MEW-023: Errores accionables en validaciones
**Story Points:** 5 | **Priority:** High | **Status:** Pending | **DoR Level:** 2

**As a** cuidador de gatos
**I want** que los errores de validacion me digan exactamente que corregir
**So that** pueda arreglar el menu sin adivinar

**AC1:** Mensaje con dia especifico: "Pescado excedido: Lunes, Miercoles, Viernes (max 2 por semana)"
**AC2:** Sugerencia de accion concreta
**AC3:** Navegacion al dia problematico
**AC4:** Errores priorizados por severidad

**Technical Notes:** Extender ValidationResult para incluir dias afectados. Agregar suggestedAction. Navegacion desde error a slot.

---

### MEW-024: Alertas de valores atipicos en perfil
**Story Points:** 3 | **Priority:** Medium | **Status:** Pending | **DoR Level:** 1

**As a** cuidador de gatos
**I want** que el sistema me alerte si ingreso valores inusuales
**So that** evite errores de tipeo que afecten los calculos

**AC1:** Warning peso < 2kg
**AC2:** Warning peso > 30kg
**AC3:** Warning > 10 gatos
**AC4:** Confirmacion explicita que no se repite

**Technical Notes:** Dialogos de confirmacion. Persistir confirmacion para no repetir.

---

### MEW-025: Score nutricional semanal
**Story Points:** 5 | **Priority:** Medium | **Status:** Pending | **DoR Level:** 2

**As a** cuidador de gatos
**I want** ver una puntuacion de mi menu semanal
**So that** tenga una metrica clara de que tan bien esta balanceado

**AC1:** Score 0-100 con indicador visual
**AC2:** Calculo basado en variedad, limites, suplementos, completitud
**AC3:** Desglose del score con breakdown
**AC4:** Actualizacion en tiempo real

**Technical Notes:** Variedad 25pts, Limites 25pts, Suplementos 25pts, Completitud 25pts. CircularProgressIndicator.

---

### MEW-026: Indicador de completitud de receta
**Story Points:** 2 | **Priority:** Medium | **Status:** Pending | **DoR Level:** 1

**As a** cuidador de gatos
**I want** ver rapidamente si una receta es completa o requiere algo mas
**So that** sepa que recetas puedo usar directamente

**AC1:** Indicador verde si completa
**AC2:** Indicador amarillo si requiere suplemento adicional
**AC3:** Visible en lista y detalle

**Technical Notes:** Chip o badge. Integrar con RecipeCard y RecipeDetailScreen.

---

## Priorizacion MoSCoW (dentro del epic)

- **Must Have:** MEW-019 (done), MEW-022, MEW-023
- **Should Have:** MEW-020 (done), MEW-021 (done), MEW-024, MEW-026
- **Could Have:** MEW-025

---

## Orden de Implementacion Sugerido

1. MEW-022 (Badge seguridad) + MEW-024 (Alertas atipicos) - en paralelo
2. MEW-023 (Errores accionables) + MEW-026 (Indicador completitud) - en paralelo
3. MEW-025 (Score nutricional) - despues de 022/023

---

## Notas de Implementacion (historias completadas)

### MEW-019 (Completado 2026-02-02)
- 4 pantallas: Bienvenida, Taurina, Calcio, Limites
- Provider Riverpod + redirect go_router
- 15 tests

### MEW-020 (Completado 2026-02-05)
- calculation_step_card.dart, calculation_breakdown_sheet.dart, recipe_scaling_breakdown_sheet.dart
- 20 tests

### MEW-021 (Completado 2026-02-05)
- nutritional_explanations.dart, info_tooltip.dart
- Tooltips en ingredient_list, supplement_section, scaled_ingredient_row, validation_summary_card
- 46 tests (30 unit + 16 widget)
