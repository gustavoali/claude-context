# MEW-022: Badge de seguridad nutricional en menu
**Epic:** E8 - UX y Explicabilidad
**Version:** v1.1
**Story Points:** 3
**Priority:** High
**Status:** Pending
**DoR Level:** 1

---

## User Story

**As a** cuidador de gatos
**I want** ver claramente cuando mi menu es nutricionalmente seguro
**So that** tenga tranquilidad de que estoy alimentando bien a mis gatos

---

## Acceptance Criteria

**AC1: Badge visible en menu valido**
- Given que mi menu semanal pasa todas las validaciones
- When veo la pantalla del menu
- Then aparece badge verde: "Menu nutricionalmente seguro"
- And el badge es prominente pero no intrusivo

**AC2: Badge de advertencia**
- Given que mi menu tiene warnings (pero no errores)
- When veo la pantalla del menu
- Then aparece badge amarillo: "Menu con advertencias"
- And puedo tocar para ver las advertencias

**AC3: Badge de error**
- Given que mi menu tiene errores criticos
- When veo la pantalla del menu
- Then aparece badge rojo: "Correccion necesaria"
- And el badge indica cuantos errores hay

**AC4: Actualizacion reactiva**
- Given que modifico el menu
- When agrego o quito recetas
- Then el badge se actualiza automaticamente
- And refleja el nuevo estado de validacion

---

## Technical Notes
- Integrar con ValidationSummaryCard existente
- Colores: green/amber/red segun severidad
- Animar transiciones de estado

---

## Definition of Done
- [ ] Badge implementado con 3 estados
- [ ] Integracion con sistema de validacion
- [ ] Actualizacion reactiva
- [ ] Widget tests
