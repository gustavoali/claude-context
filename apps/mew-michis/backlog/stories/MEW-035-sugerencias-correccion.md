# MEW-035: Sugerencias automaticas de correccion
**Epic:** E10 - Funcionalidades Avanzadas
**Version:** v1.3
**Story Points:** 5
**Priority:** Low
**Status:** Pending
**DoR Level:** 2

---

## User Story

**As a** cuidador de gatos
**I want** que el sistema sugiera como corregir errores del menu
**So that** no tenga que adivinar la solucion

---

## Acceptance Criteria

**AC1: Boton de sugerir correccion**
- Given que mi menu tiene errores de validacion
- When veo un error
- Then aparece boton: "Sugerir correccion"
- And esta junto al error

**AC2: Sugerencia concreta**
- Given que tengo pescado 3 veces
- When toco "Sugerir correccion"
- Then el sistema sugiere: "Cambiar Viernes de Receta C a Receta A"
- And la sugerencia es especifica

**AC3: Aplicar sugerencia**
- Given que veo una sugerencia
- When toco "Aplicar"
- Then el sistema hace el cambio automaticamente
- And el error desaparece

**AC4: Multiples opciones (si aplica)**
- Given que hay varias formas de corregir
- When pido sugerencia
- Then muestra 2-3 opciones ordenadas por impacto
- And puedo elegir cual aplicar

---

## Technical Notes
- Algoritmo: identificar dia problematico, buscar receta alternativa valida
- Priorizar cambios minimos
- Validar sugerencia antes de mostrar
- Integrar con ValidationService existente

---

## Dependencies
- MEW-023 (Errores accionables) - base para mostrar errores con contexto
- MEW-033 (Modo avanzado) - recomendado

---

## Definition of Done
- [ ] Algoritmo de sugerencia
- [ ] UI de sugerencias
- [ ] Aplicar sugerencia automaticamente
- [ ] Unit tests para algoritmo
- [ ] Widget tests
- [ ] Code review aprobado
- [ ] Build 0 warnings
