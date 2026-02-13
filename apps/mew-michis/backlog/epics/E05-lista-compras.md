# Epic 5: Lista de Compras (E5)

**Version:** MVP
**Objetivo:** Generar lista de compras consolidada desde el menu semanal.
**Valor de negocio:** Facilita la compra de ingredientes con cantidades exactas.
**Story Points Total:** 8
**Status:** COMPLETADO

---

## Historias

| ID | Titulo | Points | Priority | Status |
|----|--------|--------|----------|--------|
| MEW-014 | Generar lista de compras semanal | 5 | Critical | Done |
| MEW-015 | Agrupar ingredientes por categoria | 3 | High | Done |

---

## Dependencias entre Historias

```
MEW-014 (Generar lista)
  --> MEW-015 (Agrupar por categoria) [organiza la lista generada]

MEW-014 es la base del epic
MEW-015 depende de MEW-014 (necesita lista para agrupar)
```

---

## Dependencias con Otros Epics

- **E3 (Motor Nutricional):** REQUIERE E3 - necesita escalado para cantidades
- **E4 (Menu Semanal):** REQUIERE E4 - itera slots del menu para generar lista
- **E6 (Presupuesto):** E6 depende de E5 - aplica precios sobre la lista
- **E9 (Exportacion):** MEW-027 (exportar lista), MEW-028 (modo compra), MEW-036 (sustituciones) operan sobre la lista

---

## Notas Tecnicas

- **Algoritmo:** iterar slots -> escalar recetas -> agrupar ingredientes -> sumar cantidades
- **Redondeo:** Carnes a 50g, suplementos a 5mg, huevos enteros
- **Categorias:** Carnes, Visceras, Pescados, Vegetales, Huevos/Lacteos, Suplementos, Aceites
- **Orden:** Por categoria con items alfabeticos dentro de cada una
- **Checkboxes:** Estado de "comprado" persistido en SQLite
- **Menu incompleto:** Genera lista parcial con advertencia

---

## Resumen de Completitud

- Todas las historias completadas
- Consolidacion de ingredientes funcional
- 7 categorias con secciones colapsables
- Checkboxes con persistencia
- Manejo de menu incompleto
- **Archivado en:** `backlog/archive/2026-Q1-mvp-completed.md`
