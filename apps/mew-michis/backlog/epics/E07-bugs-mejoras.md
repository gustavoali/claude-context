# Epic 7: Bugs y Mejoras (E7)

**Version:** v1.1
**Objetivo:** Corregir bugs y mejoras de usabilidad detectadas post-desarrollo.
**Valor de negocio:** Estabilidad y calidad de la aplicacion.
**Story Points Total:** 2
**Status:** EN PROGRESO (1 historia pendiente)

---

## Historias

| ID | Titulo | Points | Priority | Status |
|----|--------|--------|----------|--------|
| MEW-018 | Fix SnackBar no desaparece en variaciones | 2 | Low | Pending |

---

## Dependencias entre Historias

```
MEW-018 (Fix SnackBar) - Sin dependencias, historia independiente
```

---

## Dependencias con Otros Epics

- **E2 (Catalogo):** MEW-018 esta relacionado con la funcionalidad de variaciones de MEW-007
- **E4 (Menu Semanal):** El SnackBar aparece al aplicar variaciones en slots del menu
- Sin bloqueos hacia otros epics

---

## Detalle de Historias Pendientes

### MEW-018: Fix SnackBar no desaparece en variaciones
**Story Points:** 2
**Priority:** Low
**Status:** Pending
**DoR Level:** 1

**As a** cuidador de gatos
**I want** que el mensaje de confirmacion de variacion desaparezca automaticamente
**So that** no tenga que cerrar manualmente el mensaje

**Acceptance Criteria:**

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

**Technical Notes:**
- Investigar conflicto con ScaffoldMessenger
- Considerar usar overlay o banner temporal como alternativa
- Verificar contexto del SnackBar
- SnackBar fue removido temporalmente como workaround (2026-01-31)

**Definition of Done:**
- [ ] SnackBar funciona correctamente
- [ ] Desaparece en tiempo configurado
- [ ] Widget tests pasando

---

## Notas

- Este epic se usa como contenedor para bugs y mejoras menores detectadas post-MVP
- El SnackBar fue removido temporalmente como workaround; la solucion definitiva esta pendiente
- Prioridad Low - no bloquea funcionalidad critica
