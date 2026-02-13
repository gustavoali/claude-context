# Epic 2: Catalogo de Recetas (E2)

**Version:** MVP
**Objetivo:** Mostrar las 6 recetas base (A-F) con sus variaciones permitidas.
**Valor de negocio:** Nucleo del sistema de alimentacion balanceada.
**Story Points Total:** 16
**Status:** COMPLETADO

---

## Historias

| ID | Titulo | Points | Priority | Status |
|----|--------|--------|----------|--------|
| MEW-004 | Definir modelo de datos de recetas base | 3 | Critical | Done |
| MEW-005 | Cargar recetas A-F predefinidas | 5 | Critical | Done |
| MEW-006 | Visualizar detalle de receta | 3 | High | Done |
| MEW-007 | Aplicar variaciones de proteinas | 5 | High | Done |

---

## Dependencias entre Historias

```
MEW-004 (Modelo de datos)
  --> MEW-005 (Cargar recetas) [necesita el modelo definido]
  --> MEW-006 (Visualizar detalle) [necesita modelo y datos]
  --> MEW-007 (Variaciones) [necesita modelo de variaciones]

MEW-005 depende de MEW-004
MEW-006 depende de MEW-004 y MEW-005
MEW-007 depende de MEW-004 y MEW-005
MEW-006 y MEW-007 son independientes entre si
```

---

## Dependencias con Otros Epics

- **E1 (Perfil):** Independiente, puede desarrollarse en paralelo
- **E3 (Motor Nutricional):** DEPENDE de E2 - necesita recetas para escalar
- **E4 (Menu Semanal):** DEPENDE de E2 - necesita catalogo para asignar a slots
- **E8 (UX):** MEW-021 (tooltips) y MEW-026 (indicador completitud) aplican sobre recetas
- **E11 (Recetas Personalizadas):** Extiende el modelo de E2

---

## Notas Tecnicas

- **Entidades:** Recipe, Ingredient, Supplement, Restriction, ProteinVariation
- **Relaciones:** Recipe 1->N Ingredient, Recipe 1->N Restriction
- **Datos:** Inmutables, seed data en primera migracion
- **Variaciones:** cerdo max 50%, merluza/cornalito max 30%, corazon max 25%
- **Ajuste aceite:** -50% si cerdo >25%, -100% si pescado graso
- **UI:** Lista con navegacion a detalle, secciones colapsables

---

## Resumen de Completitud

- Todas las historias completadas
- 6 recetas A-F cargadas como seed data
- Modelo de variaciones funcional
- Ajustes automaticos de aceite implementados
- **Archivado en:** `backlog/archive/2026-Q1-mvp-completed.md`
