# MEW-034: Simulaciones hipoteticas
**Epic:** E10 - Funcionalidades Avanzadas
**Version:** v1.3
**Story Points:** 5
**Priority:** Low
**Status:** Pending
**DoR Level:** 2

---

## User Story

**As a** cuidador de gatos
**I want** hacer simulaciones "what if" sin guardar cambios
**So that** pueda explorar opciones antes de decidir

---

## Acceptance Criteria

**AC1: Modo simulacion en perfil**
- Given que estoy en el perfil
- When activo "Simular"
- Then puedo cambiar peso, temporada, actividad temporalmente
- And los calculos se actualizan pero no se guardan

**AC2: Indicador visual de simulacion**
- Given que estoy en modo simulacion
- When navego la app
- Then aparece banner: "Modo simulacion - cambios no guardados"
- And el banner es persistente

**AC3: Comparar con valores reales**
- Given que estoy simulando
- When veo los calculos
- Then muestra valor real vs simulado lado a lado
- And puedo ver la diferencia

**AC4: Salir de simulacion**
- Given que estoy en modo simulacion
- When toco "Salir" o navego fuera
- Then todos los valores vuelven a los reales
- And no se persiste ningun cambio

---

## Technical Notes
- Usar state temporal (no provider global)
- Banner con SafeArea
- Resetear al salir de la pantalla
- Considerar usar un provider separado para estado de simulacion

---

## Dependencies
- MEW-033 (Modo avanzado) - recomendado implementar primero

---

## Definition of Done
- [ ] Modo simulacion en perfil
- [ ] Banner indicador
- [ ] Comparacion real vs simulado
- [ ] Reset al salir
- [ ] Unit tests
- [ ] Widget tests
- [ ] Code review aprobado
- [ ] Build 0 warnings
