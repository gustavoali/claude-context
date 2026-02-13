# Epic 6: Presupuesto (E6)

**Version:** MVP
**Objetivo:** Calcular costos semanales y costo por kilo de gato.
**Valor de negocio:** Control economico de la alimentacion.
**Story Points Total:** 8
**Status:** COMPLETADO

---

## Historias

| ID | Titulo | Points | Priority | Status |
|----|--------|--------|----------|--------|
| MEW-016 | Registrar precios de ingredientes | 3 | Medium | Done |
| MEW-017 | Calcular costo semanal y por kilo | 5 | Medium | Done |

---

## Dependencias entre Historias

```
MEW-016 (Registrar precios)
  --> MEW-017 (Calcular costos) [necesita precios para calcular]

MEW-016 es la base del epic
MEW-017 depende de MEW-016 (necesita precios ingresados)
```

---

## Dependencias con Otros Epics

- **E1 (Perfil):** REQUIERE E1 - necesita peso_total para costo por kg
- **E5 (Lista Compras):** REQUIERE E5 - necesita cantidades consolidadas para aplicar precios
- **E9 (Exportacion):** MEW-029 (historico precios) extiende MEW-016, MEW-030 (costo por comida) extiende MEW-017

---

## Notas Tecnicas

- **Tabla:** precios_ingredientes (ingrediente_id, precio, unidad, updated_at)
- **Moneda:** Pesos argentinos (default)
- **Precio:** Decimal con 2 decimales, por kg o por unidad
- **Costo semanal:** sum(cantidad_ingrediente * precio_unitario)
- **Costo por kg gato:** costo_total / peso_gatos
- **Precios opcionales:** Acepta vacios, calculo parcial con advertencia
- **Actualizacion:** Reactiva ante cambios de precios o menu

---

## Resumen de Completitud

- Todas las historias completadas
- Registro de precios con persistencia
- Calculo semanal, diario y por kg
- Manejo de precios faltantes con advertencia
- Recalculo automatico
- **Archivado en:** `backlog/archive/2026-Q1-mvp-completed.md`
