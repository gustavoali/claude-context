# MEW-023: Errores accionables en validaciones
**Epic:** E8 - UX y Explicabilidad
**Version:** v1.1
**Story Points:** 5
**Priority:** High
**Status:** Pending
**DoR Level:** 2

---

## User Story

**As a** cuidador de gatos
**I want** que los errores de validacion me digan exactamente que corregir
**So that** pueda arreglar el menu sin adivinar

---

## Acceptance Criteria

**AC1: Mensaje con dia especifico**
- Given que tengo pescado 3 veces en la semana
- When veo el error de validacion
- Then dice: "Pescado excedido: Lunes, Miercoles, Viernes (max 2 por semana)"
- And resalta los dias problematicos

**AC2: Sugerencia de accion**
- Given que veo un error de validacion
- When leo el mensaje
- Then incluye sugerencia: "Elimina pescado de uno de estos dias"
- And la sugerencia es concreta

**AC3: Navegacion al dia problematico**
- Given que veo un error con dias especificos
- When toco el nombre del dia en el mensaje
- Then navego al slot de ese dia en el menu
- And puedo editarlo directamente

**AC4: Errores priorizados**
- Given que tengo multiples errores
- When veo la lista de errores
- Then estan ordenados por severidad (criticos primero)
- And cada uno tiene accion clara

---

## Technical Notes
- Extender ValidationResult para incluir dias afectados
- Agregar campo "suggestedAction" a cada tipo de error
- Implementar navegacion desde error a slot

---

## Definition of Done
- [ ] Mensajes de error incluyen dias afectados
- [ ] Sugerencias de accion en cada error
- [ ] Navegacion al dia problematico
- [ ] Unit tests para mensajes
