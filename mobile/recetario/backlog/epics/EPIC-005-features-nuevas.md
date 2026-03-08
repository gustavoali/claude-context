# EPIC-005: Features Nuevas

**Estado:** Pendiente
**Prioridad:** LOW
**Total Story Points:** 34
**Ultima actualizacion:** 2026-02-13

## Objetivo

Agregar funcionalidades nuevas que enriquezcan la experiencia del usuario: categorias, compartir, escalar porciones, timers, exportar y lista de compras.

## Contexto

Estas features corresponden a la Fase 4 (Polish) del roadmap del proyecto. Deben implementarse despues de que la app sea estable (EPIC-001), el importador sea robusto (EPIC-002) y la UX base este pulida (EPIC-003).

## Stories Incluidas

| ID | Titulo | Pts | Prioridad | Estado |
|----|--------|-----|-----------|--------|
| REC-023 | Soporte para categorias y colecciones | 8 | LOW | Pendiente |
| REC-024 | Compartir recetas entre usuarios | 5 | LOW | Pendiente |
| REC-025 | Escalar porciones con ajuste proporcional | 5 | LOW | Pendiente |
| REC-026 | Timer/cronometro integrado en pasos | 5 | LOW | Pendiente |
| REC-028 | Exportar recetas a PDF o texto plano | 3 | LOW | Pendiente |
| REC-029 | Lista de compras desde ingredientes | 8 | LOW | Pendiente |

## Orden de Ejecucion Sugerido

1. **REC-025** (LOW, 5pts) - Alto valor percibido, complejidad moderada
2. **REC-023** (LOW, 8pts) - Organizacion fundamental
3. **REC-029** (LOW, 8pts) - Feature killer, alta utilidad practica
4. **REC-026** (LOW, 5pts) - Mejora experiencia de cocina
5. **REC-028** (LOW, 3pts) - Exportar/compartir offline
6. **REC-024** (LOW, 5pts) - Requiere Firebase activo

## Criterios de Exito del Epic

- Usuarios pueden organizar recetas en categorias/colecciones
- Porciones se escalan con ajuste proporcional de ingredientes
- Timer funciona en background con notificacion
- Recetas se exportan a PDF legible
- Lista de compras se genera desde ingredientes seleccionados
- Compartir funciona entre usuarios de la app

## Riesgos

| Riesgo | Probabilidad | Impacto | Mitigacion |
|--------|-------------|---------|------------|
| Feature creep: cada feature crece en scope | Alta | Medio | DoR estricto, MVP de cada feature |
| REC-024 (compartir) requiere Firebase funcional | Alta | Medio | Depende de EPIC-001 completado |
| Parsing de cantidades para escalar porciones es ambiguo | Media | Medio | Usar NLP basico + fallback manual |

## Dependencias

- EPIC-001 (Firebase condicional) debe estar resuelto para REC-024
- EPIC-003 (UX/UI) deberia estar resuelto para consistencia visual
- Cada story puede detallarse (DoR L2) cuando se priorice para sprint
