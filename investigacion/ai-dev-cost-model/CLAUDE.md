# AI Development Cost Model - Project Context
**Version:** 0.1.0 | **Estado:** Semilla
**Short:** `aicm` | **Categoria:** investigacion
**Ubicacion:** `C:/investigacion/ai-dev-cost-model`
**Context:** `C:/claude_context/investigacion/ai-dev-cost-model`

## Descripcion

Sistema de costeo de desarrollo de software basado en tokens (no dias-hombre). Modela el costo real en USD de tareas de desarrollo IA, compara con modelo tradicional, y proyecta la transicion de equipos humanos a equipos IA-supervisados.

## Stack

- Python 3.11 (`C:/Users/gdali/AppData/Local/Programs/Python/Python311/python.exe`)
- Pandas, NumPy, Matplotlib, Plotly, Jupyter
- Markdown (documentacion y frameworks conceptuales)
- YAML/JSON (parametros del modelo)

## Componentes Principales

| Componente | Descripcion | Estado |
|------------|-------------|--------|
| C1: Token Cost Model | Estimacion USD por historia dado tipo + complejidad | Pendiente |
| C2: Task Framework | Baselines por tipo de tarea (feature, bugfix, etc.) | Pendiente |
| C3: Traditional Comparison | Comparativa tokens vs. dias-hombre | Pendiente |
| C4: Transition Model | Proyeccion fases 0-4 + punto de inflexion | Pendiente |

## Comandos

```bash
# Python
C:/Users/gdali/AppData/Local/Programs/Python/Python311/python.exe -m pip install -r requirements.txt

# Jupyter
C:/Users/gdali/AppData/Local/Programs/Python/Python311/python.exe -m jupyter notebook

# Ejecutar modelo
C:/Users/gdali/AppData/Local/Programs/Python/Python311/python.exe models/cost_estimator.py
```

## Agentes Recomendados

| Tarea | Agente |
|-------|--------|
| Desarrollo de modelos Python | `python-backend-developer` |
| Analisis de datos / visualizaciones | `data-quality-analyst` |
| Comparativa de datasets | `matching-specialist` |
| Review de codigo | `code-reviewer` |
| Tests | `test-engineer` |

## Preguntas de Investigacion (ver SEED_DOCUMENT.md)

PQ-001 a PQ-010 documentadas en SEED_DOCUMENT.md.

## Docs

@C:/claude_context/investigacion/ai-dev-cost-model/SEED_DOCUMENT.md
@C:/claude_context/investigacion/ai-dev-cost-model/TASK_STATE.md
