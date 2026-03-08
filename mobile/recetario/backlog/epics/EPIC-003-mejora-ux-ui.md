# EPIC-003: Mejora de UX/UI

**Estado:** Pendiente
**Prioridad:** MEDIUM
**Total Story Points:** 22
**Ultima actualizacion:** 2026-02-13

## Objetivo

Mejorar la experiencia de usuario de la app con funcionalidades faltantes, reduccion de duplicacion de codigo en pantallas, y mejoras visuales.

## Contexto

La Fase 1 (MVP Local) esta funcional pero hay varios TODO pendientes, problemas de UX (sin confirmacion al salir de formularios, sin drag-to-reorder) y deuda tecnica en la capa de presentacion (duplicacion entre FormScreen y PreviewScreen).

## Stories Incluidas

| ID | Titulo | Pts | Prioridad | Estado |
|----|--------|-----|-----------|--------|
| REC-010 | sourceUrl no se puede abrir - TODO pendiente | 1 | HIGH | Pendiente |
| REC-012 | Recipe.copyWith no permite limpiar campos nullables | 2 | MEDIUM | Pendiente |
| REC-013 | Duplicacion masiva entre FormScreen y PreviewScreen | 5 | MEDIUM | Pendiente |
| REC-014 | No hay drag-to-reorder para ingredientes y pasos | 3 | MEDIUM | Pendiente |
| REC-015 | RecipeCard no muestra imagenes locales | 2 | MEDIUM | Pendiente |
| REC-017 | No hay cache de imagenes de red | 2 | MEDIUM | Pendiente |
| REC-019 | Dark mode sin toggle manual en UI | 2 | MEDIUM | Pendiente |
| REC-020 | Sin confirmacion al salir del formulario con cambios | 2 | MEDIUM | Pendiente |
| REC-027 | Animaciones hero entre lista y detalle | 2 | LOW | Pendiente |

## Orden de Ejecucion Sugerido

1. **REC-010** (HIGH) - Quick win, 1 punto
2. **REC-012** (MEDIUM) - Prerequisito para formularios
3. **REC-020** (MEDIUM) - UX critica para formularios
4. **REC-013** (MEDIUM) - Refactor grande, reduce deuda
5. **REC-014** (MEDIUM) - Mejora UX formularios
6. **REC-015 + REC-017** (MEDIUM) - Imagenes en paralelo
7. **REC-019** (MEDIUM) - Dark mode toggle
8. **REC-027** (LOW) - Polish visual

## Criterios de Exito del Epic

- URLs de fuente se abren en browser externo
- copyWith maneja nullables correctamente
- FormScreen y PreviewScreen comparten widgets reutilizables
- Ingredientes y pasos se reordenan con drag-and-drop
- Imagenes locales y remotas se muestran correctamente con cache
- Dark mode se puede activar/desactivar desde settings
- Al salir del form con cambios sin guardar, se muestra dialogo de confirmacion
- Build con 0 warnings

## Riesgos

| Riesgo | Probabilidad | Impacto | Mitigacion |
|--------|-------------|---------|------------|
| Refactor FormScreen/PreviewScreen introduce regresiones | Media | Alto | Tests antes del refactor, comparar comportamiento |
| ReorderableListView tiene performance issues con listas largas | Baja | Bajo | Limitar a listas razonables (<100 items) |

## Dependencias

- REC-012 es prerequisito blando para REC-013 (facilita el refactor)
- No depende de otros epics
