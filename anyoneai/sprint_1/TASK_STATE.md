# Estado - AnyoneAI Sprint 1
**Actualizacion:** 2026-03-06 | **Proyecto:** `C:/Anyone_AI/sprint_1/`

## Resumen Ejecutivo
Sprint COMPLETADO y ENTREGADO como `Sprint_01_Gustavo_Ali.zip`.
Sprint project recreado desde cero en `C:/Anyone_AI/sprint_1/project/assignment/`.

## Sprint Project Recreado - COMPLETADO
Pipeline ELT de e-commerce Olist (Brasil) - 11/11 tests passing.

### Archivos implementados
| Archivo | Descripcion |
|---------|-------------|
| `src/extract.py` | get_public_holidays() - API Nager.at + limpieza |
| `src/load.py` | load() - DataFrames a SQLite con to_sql() |
| `queries/global_amount_order_status.sql` | COUNT por order_status |
| `queries/delivery_date_difference.sql` | AVG diferencia estimada vs real por estado |
| `queries/revenue_per_state.sql` | Top 10 estados por revenue |
| `queries/revenue_by_month_year.sql` | Revenue mensual por anio (2016-2018) |
| `queries/top_10_revenue_categories.sql` | Top 10 categorias por revenue |
| `queries/top_10_least_revenue_categories.sql` | Top 10 categorias con menos revenue |
| `queries/real_vs_estimated_delivered_time.sql` | Tiempo real vs estimado por mes/anio |
| `src/transform.py` | freight/weight relationship + orders/holidays 2017 |
| `src/plots.py` | scatterplot freight/weight + lineplot orders/holidays |

### Tests
- `tests/test_extract.py`: 2/2 PASSED
- `tests/test_transform.py`: 9/9 PASSED

## Proximos Pasos
1. [OPCIONAL] Implementar DAG de Airflow para orquestar el pipeline
2. Ejecutar el notebook completo `AnyoneAI - Sprint Project 01.ipynb` para generar visualizaciones
