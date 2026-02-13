# MEW-032: Informacion individual por gato
**Epic:** E10 - Funcionalidades Avanzadas
**Version:** v1.3
**Story Points:** 5
**Priority:** Low
**Status:** Pending
**DoR Level:** 2

---

## User Story

**As a** cuidador de multiples gatos
**I want** registrar nombre y peso de cada gato individualmente
**So that** tenga un registro mas detallado (aunque el calculo use peso total)

---

## Acceptance Criteria

**AC1: Agregar gatos individuales**
- Given que estoy en el perfil
- When toco "Agregar gato"
- Then puedo ingresar nombre y peso
- And el gato se agrega a la lista

**AC2: Lista de gatos**
- Given que tengo gatos registrados
- When veo el perfil
- Then muestra lista de gatos con nombre y peso
- And la suma coincide con peso total

**AC3: Editar y eliminar**
- Given que tengo gatos en la lista
- When quiero modificar uno
- Then puedo editar nombre/peso o eliminarlo
- And el peso total se ajusta automaticamente

**AC4: Calculo sigue usando peso total**
- Given que tengo gatos individuales registrados
- When el sistema calcula necesidades
- Then usa la suma de pesos (peso total)
- And los gatos individuales son solo informativos

---

## Technical Notes
- Tabla: cats (id, profile_id, name, weight)
- Suma de pesos debe igualar weight_total del perfil
- UI: lista expandible en pantalla de perfil
- Requiere migracion de base de datos SQLite (Drift)

---

## Dependencies
- Ninguna directa, pero afecta perfil nutricional existente (E1)

---

## Database Migration
- Nueva tabla `cats` en Drift schema
- Relacion con tabla de perfil nutricional

---

## Definition of Done
- [ ] CRUD de gatos individuales
- [ ] UI de lista de gatos
- [ ] Sincronizacion con peso total
- [ ] Tests de persistencia
- [ ] Unit tests
- [ ] Widget tests
- [ ] Code review aprobado
- [ ] Build 0 warnings
