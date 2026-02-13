# Epic 3: Motor Nutricional (E3)

**Version:** MVP
**Objetivo:** Escalar recetas y calcular ingredientes segun perfil del usuario.
**Valor de negocio:** Automatiza calculos complejos y evita errores nutricionales.
**Story Points Total:** 13
**Status:** COMPLETADO

---

## Historias

| ID | Titulo | Points | Priority | Status |
|----|--------|--------|----------|--------|
| MEW-008 | Escalar receta por peso de gatos | 5 | Critical | Done |
| MEW-009 | Calcular suplementos obligatorios | 3 | Critical | Done |
| MEW-010 | Aplicar ajustes estacionales | 5 | High | Done |

---

## Dependencias entre Historias

```
MEW-008 (Escalar receta)
  --> MEW-009 (Suplementos) [puede usar escalado para calcular suplementos]
  --> MEW-010 (Ajustes estacionales) [aplica sobre receta escalada]

MEW-008 es la base del epic
MEW-009 depende de MEW-008 (usa el factor de escala)
MEW-010 depende de MEW-008 (ajusta sobre receta escalada)
MEW-009 y MEW-010 son independientes entre si
```

---

## Dependencias con Otros Epics

- **E1 (Perfil):** REQUIERE E1 - necesita peso_total, temporada, actividad
- **E2 (Catalogo):** REQUIERE E2 - necesita recetas con ingredientes y cantidades base
- **E4 (Menu Semanal):** E4 depende de E3 para escalar recetas en cada slot
- **E5 (Lista Compras):** E5 depende de E3 para calcular cantidades finales
- **E8 (UX):** MEW-020 (desglose calculo) expone las formulas de E3

---

## Notas Tecnicas

- **Escalado:** Factor = peso_total / 1kg (recetas base normalizadas a 1kg)
- **Redondeo:** Ingredientes a 5g, suplementos a 10mg
- **Taurina:** 250mg/kg/dia (minimo, obligatorio)
- **Calcio:** Varia segun receta, tipicamente 1g/kg
- **Ajuste invierno:** Aceite +20%
- **Ajuste cerdo >25%:** Aceite -50%
- **Ajuste pescado graso:** Aceite -100%
- **Combinacion:** Ajustes se aplican en orden y se combinan
- **Recalculo:** Reactivo ante cambios de perfil

---

## Resumen de Completitud

- Todas las historias completadas
- CalculationService implementado y testeado
- Escalado, suplementos y ajustes estacionales funcionales
- Combinacion de ajustes (variacion + estacional) validada
- **Archivado en:** `backlog/archive/2026-Q1-mvp-completed.md`
