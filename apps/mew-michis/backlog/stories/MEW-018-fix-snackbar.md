# MEW-018: Fix SnackBar no desaparece en variaciones
**Epic:** E7 - Bugs y Mejoras
**Version:** v1.1
**Story Points:** 2
**Priority:** Low
**Status:** Pending
**DoR Level:** 1

---

## User Story

**As a** cuidador de gatos
**I want** que el mensaje de confirmacion de variacion desaparezca automaticamente
**So that** no tenga que cerrar manualmente el mensaje

---

## Acceptance Criteria

**AC1: SnackBar desaparece automaticamente**
- Given que aplico una variacion a una receta
- When el sistema muestra el mensaje de confirmacion
- Then el SnackBar desaparece despues de 4 segundos
- And no necesito interaccion para cerrarlo

**AC2: No persiste indefinidamente**
- Given que aplique una variacion
- When pasan 4 segundos
- Then el SnackBar ya no es visible
- And la UI queda limpia

---

## Technical Notes
- Investigar conflicto con ScaffoldMessenger
- Considerar usar overlay o banner temporal como alternativa
- Verificar contexto del SnackBar

---

## Definition of Done
- [ ] SnackBar funciona correctamente
- [ ] Desaparece en tiempo configurado
- [ ] Widget tests pasando
