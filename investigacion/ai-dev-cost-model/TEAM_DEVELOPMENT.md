# Equipo de Desarrollo - AI Development Cost Model
**Fecha:** 2026-03-13 | **Estado:** Semilla (equipo no activo aun)

## Composicion del Equipo de Desarrollo

### Backend / Data Developer (Python)
**Agente:** `python-backend-developer`
**Responsabilidades:**
- Implementar los modulos Python del directorio `models/`
- Desarrollar `cost_estimator.py`, `transition_model.py`, `token_calculator.py`
- Escribir funciones de carga y procesamiento de datos (`data_loader.py`)
- Crear archivos de configuracion YAML/JSON

**Primera historia sugerida:** Implementar `token_calculator.py` con funcion base `calculate_cost(tokens_input, tokens_output, model_id)` con tabla de precios configurables.

---

### Data Analyst / Notebook Developer
**Agente:** `python-backend-developer` (con foco en analisis)
**Responsabilidades:**
- Crear y mantener Jupyter Notebooks
- Implementar visualizaciones con Matplotlib/Plotly
- Analisis exploratorio de datos de consumo
- Producir graficos para el documento ejecutivo

**Primera historia sugerida:** Crear `01_exploracion_tokens.ipynb` con analisis de consumo de tokens por tipo de tarea usando datos del ecosistema.

---

### Test Engineer
**Agente:** `test-engineer`
**Responsabilidades:**
- Escribir unit tests para modulos Python
- Validar que el modelo produce outputs coherentes
- Crear fixtures con datos de prueba realistas
- Verificar edge cases (precio 0, tokens negativos, etc.)

**Estrategia de testing:**
- Unit tests: `pytest` para funciones de calculo
- Integration tests: validar pipeline completo con datos sample
- Regression tests: resultados del modelo deben ser reproducibles

---

### Code Reviewer
**Agente:** `code-reviewer`
**Responsabilidades:**
- Review riguroso antes de cada PR
- Verificar correctitud de formulas matematicas
- Detectar errores numericos (division por cero, overflow, etc.)
- Validar calidad de codigo Python (PEP8, type hints, docstrings donde aplique)

---

## Convenciones del Proyecto

### Codigo Python
- Type hints en todas las funciones publicas
- Docstrings en modulos y clases
- Constantes en MAYUSCULAS
- Nombres descriptivos (no abreviaciones obscuras)

### Notebooks
- Celda de titulo + descripcion al inicio
- Celdas de markdown entre secciones
- Variables con nombres claros (no `df2`, `result_final2`)
- Ejecutar en orden limpio antes de commitear

### Datos
- `data/` solo datos de referencia (no datos personales ni billing real sin anonimizar)
- `sample_projects/` con datos anonimizados o generados

### Git
- Commits en ingles: `feat:`, `fix:`, `data:`, `notebook:`, `docs:`
- No commitear outputs de notebooks (usar `.gitignore`)

---

## Setup del Entorno de Desarrollo

```bash
# Crear entorno virtual
C:/Users/gdali/AppData/Local/Programs/Python/Python311/python.exe -m venv venv
source venv/Scripts/activate  # Windows Git Bash

# Instalar dependencias
pip install pandas numpy matplotlib plotly jupyterlab pyyaml pytest

# Guardar dependencias
pip freeze > requirements.txt

# Ejecutar tests
pytest tests/ -v

# Jupyter
jupyter lab
```

---

## Historias Tecnicas Iniciales (Sugeridas)

| ID | Titulo | Agente | Prioridad |
|----|--------|--------|-----------|
| AICM-001 | Setup inicial del proyecto Python (venv, estructura, requirements) | python-backend-developer | Alta |
| AICM-002 | Implementar `token_calculator.py` con tabla de precios LLM | python-backend-developer | Alta |
| AICM-003 | Crear `task_baselines.json` con datos iniciales (5 tipos de tarea) | python-backend-developer | Alta |
| AICM-004 | Implementar `cost_estimator.py` (formula base del Componente 1) | python-backend-developer | Alta |
| AICM-005 | Notebook `01_exploracion_tokens.ipynb` con datos del ecosistema | python-backend-developer | Media |
| AICM-006 | Implementar `transition_model.py` con fases 0-4 | python-backend-developer | Media |
| AICM-007 | Notebook `04_punto_inflexion.ipynb` con curva de cruce | python-backend-developer | Alta |
| AICM-008 | Tests para modulos de calculo | test-engineer | Media |
| AICM-009 | Documento ejecutivo (2 paginas, stakeholder-ready) | (coordinador + docs) | Baja |

---

**Version:** 1.0 | **Fecha:** 2026-03-13
