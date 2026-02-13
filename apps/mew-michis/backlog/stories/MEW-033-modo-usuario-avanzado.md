# MEW-033: Modo usuario avanzado
**Epic:** E10 - Funcionalidades Avanzadas
**Version:** v1.3
**Story Points:** 5
**Priority:** Low
**Status:** Pending
**DoR Level:** 2

---

## User Story

**As a** usuario avanzado o nutricionista
**I want** activar un modo que muestre mas detalles tecnicos
**So that** pueda auditar los calculos y entender las decisiones del sistema

---

## Acceptance Criteria

**AC1: Toggle en configuracion**
- Given que estoy en Configuracion
- When activo "Modo avanzado"
- Then se habilitan features adicionales
- And aparece indicador de modo activo

**AC2: Ver reglas aplicadas**
- Given que modo avanzado esta activo
- When veo una receta escalada
- Then muestra las reglas que se aplicaron: "Ajuste invierno +20%, Cerdo -50% aceite"
- And cada regla tiene explicacion

**AC3: Ver logs de decisiones**
- Given que modo avanzado esta activo
- When veo el menu semanal
- Then puedo acceder a log de decisiones automaticas
- And muestra que ajustes hizo el motor

**AC4: Metricas detalladas**
- Given que modo avanzado esta activo
- When veo cualquier calculo
- Then muestra valores intermedios y formulas
- And es util para debugging/auditoria

---

## Technical Notes
- Flag en SharedPreferences
- Condicionar UI segun modo
- Logs en memoria (no persistir)
- Reutilizar componentes de MEW-020 (desglose calculo) y MEW-021 (tooltips)

---

## Dependencies
- MEW-020 (Desglose calculo) - Done, reutilizar componentes
- MEW-021 (Tooltips nutricionales) - Done, reutilizar componentes

---

## Definition of Done
- [ ] Toggle en configuracion
- [ ] Condicionales de UI para modo avanzado
- [ ] Seccion de reglas aplicadas
- [ ] Log de decisiones
- [ ] Unit tests
- [ ] Widget tests
- [ ] Code review aprobado
- [ ] Build 0 warnings
