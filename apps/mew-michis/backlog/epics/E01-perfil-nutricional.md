# Epic 1: Perfil Nutricional (E1)

**Version:** MVP
**Objetivo:** Permitir al usuario configurar el perfil de sus gatos para calcular necesidades alimentarias.
**Valor de negocio:** Fundamento para todos los calculos del sistema.
**Story Points Total:** 10
**Status:** COMPLETADO

---

## Historias

| ID | Titulo | Points | Priority | Status |
|----|--------|--------|----------|--------|
| MEW-001 | Configurar perfil nutricional basico | 3 | Critical | Done |
| MEW-002 | Calcular necesidades diarias y semanales | 5 | Critical | Done |
| MEW-003 | Persistir perfil en SQLite | 2 | Critical | Done |

---

## Dependencias entre Historias

```
MEW-001 (Configurar perfil)
  --> MEW-002 (Calcular necesidades) [necesita datos del perfil]
  --> MEW-003 (Persistir perfil) [necesita modelo del perfil]

MEW-002 depende de MEW-001
MEW-003 depende de MEW-001
MEW-002 y MEW-003 son independientes entre si
```

---

## Dependencias con Otros Epics

- **E2 (Catalogo Recetas):** Independiente de E1, puede desarrollarse en paralelo
- **E3 (Motor Nutricional):** DEPENDE de E1 - necesita peso y temporada del perfil para escalar
- **E4 (Menu Semanal):** Depende indirectamente via E3
- **E5 (Lista Compras):** Depende indirectamente via E3
- **E6 (Presupuesto):** Depende indirectamente via E5

---

## Notas Tecnicas

- **Database:** Tabla perfil_nutricional con Drift (SQLite)
- **State:** Riverpod 2.x con @riverpod annotation
- **Modelo:** Freezed para entidades inmutables
- **UI:** Formulario con inputs numericos y selectores
- **Calculo:** Formula base peso_kg * factor_actividad * 30-40g, ajuste invierno +10%

---

## Resumen de Completitud

- Todas las historias completadas
- Tests unitarios y de widget pasando
- Perfil funcional con persistencia offline
- Calculos reactivos implementados
- **Archivado en:** `backlog/archive/2026-Q1-mvp-completed.md`
