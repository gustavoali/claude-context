# MEW-024: Alertas de valores atipicos en perfil
**Epic:** E8 - UX y Explicabilidad
**Version:** v1.1
**Story Points:** 3
**Priority:** Medium
**Status:** Pending
**DoR Level:** 1

---

## User Story

**As a** cuidador de gatos
**I want** que el sistema me alerte si ingreso valores inusuales
**So that** evite errores de tipeo que afecten los calculos

---

## Acceptance Criteria

**AC1: Warning para peso muy bajo**
- Given que ingreso peso total menor a 2 kg
- When guardo el perfil
- Then aparece warning: "El peso ingresado es muy bajo. Es correcto?"
- And puedo confirmar o corregir

**AC2: Warning para peso muy alto**
- Given que ingreso peso total mayor a 30 kg
- When guardo el perfil
- Then aparece warning: "El peso ingresado es inusualmente alto para gatos domesticos."
- And puedo confirmar o corregir

**AC3: Warning para muchos gatos**
- Given que ingreso mas de 10 gatos
- When guardo el perfil
- Then aparece warning: "Verificar: muchos gatos puede requerir planificacion especial."
- And es informativo, no bloquea

**AC4: Confirmacion explicita**
- Given que veo un warning
- When confirmo que el valor es correcto
- Then el sistema acepta el valor
- And no vuelve a mostrar warning para ese valor

---

## Technical Notes
- Umbrales: peso < 2kg (bajo), > 30kg (alto), gatos > 10
- Dialogo de confirmacion con opcion de corregir
- Persistir confirmacion para no repetir

---

## Definition of Done
- [ ] Validacion de rangos atipicos
- [ ] Dialogos de confirmacion
- [ ] Persistencia de confirmacion
- [ ] Unit tests
