# MEW-037: Modelo de recetas extendidas
**Epic:** E11 - Recetas Personalizadas
**Version:** v2.0
**Story Points:** 8
**Priority:** Low
**Status:** Pending
**DoR Level:** 2

---

## User Story

**As a** desarrollador
**I want** un modelo de datos que soporte recetas personalizadas
**So that** los usuarios puedan crear variaciones seguras de las recetas base

---

## Acceptance Criteria

**AC1: Entidad ExtendedRecipe**
- Given que defino el modelo
- When incluyo los campos
- Then tiene: id, base_recipe_id, name, author, modifications[], type (custom/imported)
- And hereda estructura de receta base

**AC2: Modificaciones controladas**
- Given que modelo las modificaciones
- When defino la estructura
- Then permite: cambio de proteina, ajuste de porcentajes, sustituciones
- And cada modificacion tiene limites

**AC3: Validacion obligatoria**
- Given que creo una receta extendida
- When la guardo
- Then pasa por validacion del motor nutricional
- And no se guarda si es invalida

**AC4: Diferenciacion visual**
- Given que tengo recetas extendidas
- When las veo en el catalogo
- Then tienen badge diferente (custom vs official)
- And es claro cual es cual

---

## Technical Notes
- Tabla: extended_recipes (id, base_recipe_id, name, author, type, created_at)
- Tabla: recipe_modifications (recipe_id, modification_type, value)
- Validacion via ValidationService existente
- Requiere migracion de base de datos Drift

---

## Dependencies
- Ninguna directa - es la base para MEW-038, MEW-039, MEW-040

---

## Database Migration
- Nueva tabla `extended_recipes` en Drift schema
- Nueva tabla `recipe_modifications` en Drift schema
- Relacion con tabla de recetas base existente

---

## Definition of Done
- [ ] Modelo de datos implementado
- [ ] Migracion SQLite (Drift)
- [ ] Validacion integrada
- [ ] Unit tests
- [ ] Widget tests para diferenciacion visual
- [ ] Code review aprobado
- [ ] Build 0 warnings
