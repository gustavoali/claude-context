# Epic 4: Menu Semanal (E4)

**Version:** MVP
**Objetivo:** Constructor de menu de 7 dias con validaciones automaticas.
**Valor de negocio:** Permite planificacion completa con reglas de negocio aplicadas.
**Story Points Total:** 13
**Status:** COMPLETADO

---

## Historias

| ID | Titulo | Points | Priority | Status |
|----|--------|--------|----------|--------|
| MEW-011 | Crear menu semanal con calendario | 5 | Critical | Done |
| MEW-012 | Validar restricciones semanales | 5 | Critical | Done |
| MEW-013 | Persistir menu semanal | 3 | High | Done |

---

## Dependencias entre Historias

```
MEW-011 (Crear menu con calendario)
  --> MEW-012 (Validar restricciones) [valida el menu armado]
  --> MEW-013 (Persistir menu) [guarda el menu creado]

MEW-011 es la base del epic
MEW-012 depende de MEW-011 (necesita menu para validar)
MEW-013 depende de MEW-011 (necesita modelo para persistir)
MEW-012 y MEW-013 son independientes entre si
```

---

## Dependencias con Otros Epics

- **E2 (Catalogo):** REQUIERE E2 - necesita recetas para asignar a slots
- **E3 (Motor Nutricional):** REQUIERE E3 - necesita escalado para mostrar cantidades
- **E5 (Lista Compras):** E5 depende de E4 - genera lista desde el menu
- **E6 (Presupuesto):** E6 depende indirectamente via E5
- **E7 (Bugs):** MEW-018 (SnackBar) esta relacionado con variaciones en menu
- **E8 (UX):** MEW-022 (badge seguridad), MEW-023 (errores accionables), MEW-025 (score) aplican sobre menu

---

## Notas Tecnicas

- **Modelo:** MenuSemanal con 7 slots (dia, receta_id, variacion_json)
- **Tablas:** menu_semanal, menu_slot
- **Validaciones:** pescado <=2/semana, higado <=2/semana, aceite obligatorio si no pescado, suplementos siempre
- **Clasificacion errores:** Error (bloquea), Warning (confirmar), Info (informativo)
- **Auto-save:** Guardado automatico al modificar
- **UI:** Grid/lista de 7 slots con asignacion, variacion, copiar, limpiar

---

## Resumen de Completitud

- Todas las historias completadas
- Calendario semanal con 7 slots funcional
- Motor de validaciones con 3 niveles de severidad
- Persistencia automatica offline
- ValidationSummaryCard implementado (reutilizado por E8)
- **Archivado en:** `backlog/archive/2026-Q1-mvp-completed.md`
