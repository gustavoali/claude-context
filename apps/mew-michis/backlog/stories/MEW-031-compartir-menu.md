# MEW-031: Compartir menu semanal
**Epic:** E9 - Exportacion y Compartir
**Version:** v1.3
**Story Points:** 5
**Priority:** Low
**Status:** Pending
**DoR Level:** 2

---

## User Story

**As a** cuidador de gatos
**I want** compartir mi menu semanal con otros
**So that** pueda mostrar mi planificacion o pedir feedback

---

## Acceptance Criteria

**AC1: Boton compartir menu**
- Given que tengo un menu semanal completo
- When toco "Compartir menu"
- Then se genera una imagen o texto del menu
- And puedo compartir via apps del sistema

**AC2: Formato visual para imagen**
- Given que comparto como imagen
- When se genera
- Then muestra los 7 dias con recetas
- And incluye badge de seguridad nutricional

**AC3: Formato texto para mensaje**
- Given que comparto como texto
- When se genera
- Then lista: "Lunes: Receta A, Martes: Receta B..."
- And incluye metadata basica

**AC4: Vista previa antes de compartir**
- Given que voy a compartir
- When preparo el compartir
- Then veo preview de lo que se enviara
- And puedo cancelar o confirmar

---

## Technical Notes
- Generar imagen con RepaintBoundary o screenshot
- Texto plano como alternativa
- Usar share_plus package

---

## Dependencies
- MEW-022 (Badge seguridad) para incluir en imagen compartida
- Package share_plus

---

## Definition of Done
- [ ] Generacion de imagen del menu
- [ ] Formato texto alternativo
- [ ] Preview antes de compartir
- [ ] Integracion con share sheet
- [ ] Unit tests
- [ ] Widget tests
- [ ] Code review aprobado
- [ ] Build 0 warnings
