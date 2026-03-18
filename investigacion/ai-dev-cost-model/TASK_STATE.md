# Estado - AI Development Cost Model
**Actualizacion:** 2026-03-13 | **Version:** 0.2.0

## Resumen Ejecutivo

Sprint 1-4 completado. 11/12 historias Done (42/44 pts). Unica pendiente: AICM-009 (doc ejecutivo, 2 pts).

## Completado

| Historia | Resultado clave |
|----------|-----------------|
| AICM-001 setup | venv Python 3.11, pytest OK |
| AICM-002 token_calculator | $0.60 verificado (100k/20k tokens sonnet) |
| AICM-003 task_baselines | 13 tipos, 5 completamente parametrizados |
| AICM-010 market_salaries | 5 regiones, derived_metrics al root del JSON |
| AICM-004 cost_estimator | feature-new M = $0.6057, CLI funciona |
| AICM-011 comparison_calculator | AR ROI = 50,333% |
| AICM-006 transition_model | startup AR Phase 0->4: $13,500->$179, inflexion=Phase 1 |
| AICM-005 notebook exploracion | 13 celdas, 4 PNGs en data/plots/ |
| AICM-007 notebook inflexion | 15 celdas, 4 PNGs en data/plots/ |
| AICM-008 tests | 33/33 PASS, 77% coverage |
| AICM-012 notebook comparativa | 12 celdas, 3 PNGs, ratio 1:594 (AR) y 1:2377 (US) |

## Pendiente

| Historia | Estado | Notas |
|----------|--------|-------|
| AICM-009 | Pendiente | Documento ejecutivo 2 pags, depende de todos los modulos y notebooks |

## Proximos Pasos

1. Lanzar AICM-009 si el usuario quiere cerrar el sprint completo
   - Agente coordinador genera `docs/executive_summary.md`
   - Inputs: hallazgos de los 3 notebooks + cifras clave de los modelos
   - Output: MD 2 paginas, stakeholder-ready
2. Commit pendiente: `git add . && git commit -m "feat: sprint completo - 11 historias, 42 pts"`

## Decisiones Tomadas

- Short code: `aicm`
- Stack: Python + Markdown (sin backend web)
- derived_metrics en market_salaries.json al nivel RAIZ del JSON, no dentro de regions
- int(91770 * 0.70) = 64238 por IEEE 754 — comportamiento esperado
- Fallback a "feature-new" en notebooks para tipos no definidos (data-pipeline, testing)
- 11 PNGs generados en data/plots/; 1 HTML interactivo (transition_monthly_cost.html)

## Hallazgos Clave del Modelo

- Costo IA por historia (feature-new M, sonnet): ~$0.61 USD
- Costo humano AR senior por historia equivalente: ~$305 USD
- ROI promedio AR: ~50,000%
- 20 historias (2 proyectos): AI $14.77 vs Humano AR $8,773 vs Humano US $35,093
- Ratio total: 1:594 (AR) y 1:2,377 (US)
- Punto de inflexion startup AR: Phase 1 (supervisor + AI workers)
