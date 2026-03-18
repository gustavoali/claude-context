# Backlog - AI Development Cost Model
**Version:** 1.0 | **Actualizacion:** 2026-03-13

## Resumen
| Metrica | Valor |
|---------|-------|
| Total historias | 12 |
| Pendientes | 1 |
| Completadas | 11 |
| Story points totales | 44 |
| Epics | 5 |

## Vision
Sistema de costeo de desarrollo basado en tokens de agentes IA. Permite estimar costo USD
de cualquier historia, comparar con dias-hombre tradicional, y proyectar la transicion economica
de equipos humanos a IA-supervisados con punto de inflexion calculado.

## Epics
| Epic | Historias | Puntos | Status |
|------|-----------|--------|--------|
| E1: Infraestructura | AICM-001 | 2 | Done |
| E2: Token Cost Model (C1) | AICM-002, 003, 004 | 10 | Done |
| E3: Traditional Comparison (C3) | AICM-010, 011, AICM-005 | 11 | Done |
| E4: Transition Model (C4) | AICM-006, 007 | 11 | Done |
| E5: Validacion y Cierre | AICM-008, 012, 009 | 10 | Parcial (009 pendiente) |

## Dependencias
```
AICM-001 (setup) --> TODO lo demas
AICM-002 (token_calculator) + AICM-003 (baselines) --> AICM-004 (cost_estimator)
AICM-004 --> AICM-005 (notebook exploracion), AICM-010 (salarios), AICM-011 (comparativa)
AICM-004 + AICM-010 --> AICM-006 (transition_model)
AICM-006 --> AICM-007 (notebook inflexion)
AICM-004 --> AICM-008 (tests)
AICM-007 + AICM-011 --> AICM-012 (notebook comparativa)
Todo --> AICM-009 (documento ejecutivo)
```

---

## Pendientes (Sprint 1 - detalle completo)

### AICM-001: Setup inicial del proyecto Python
**Points:** 2 | **Priority:** Critical | **Sprint:** 1 | **Epic:** E1

**As a** developer
**I want** un entorno Python configurado con estructura de carpetas, venv y dependencias
**So that** pueda comenzar a implementar los modulos del modelo de costeo

**AC1: Estructura de carpetas creada**
- Given el repositorio clonado
- When ejecuto el setup
- Then existen los directorios: `models/`, `data/`, `notebooks/`, `research/`, `docs/`, `tests/`

**AC2: Entorno virtual funcional**
- Given Python 3.11 instalado en el sistema
- When ejecuto `source venv/Scripts/activate && python --version`
- Then reporta Python 3.11.x

**AC3: Dependencias instaladas**
- Given el venv activado
- When ejecuto `pip install -r requirements.txt`
- Then se instalan: pandas, numpy, matplotlib, plotly, jupyterlab, pyyaml, pytest
- And `pytest --version` retorna sin error

**AC4: Gitignore configurado**
- Given el proyecto inicializado
- When reviso `.gitignore`
- Then excluye: `venv/`, `__pycache__/`, `.ipynb_checkpoints/`, `*.pyc`, `.env`

**Technical Notes**
- Python path: `C:/Users/gdali/AppData/Local/Programs/Python/Python311/python.exe`
- Crear `__init__.py` en `models/` y `tests/` para importabilidad
- Incluir `conftest.py` basico en `tests/`

**DoD**
- [ ] Estructura creada y commiteada
- [ ] venv funcional con requirements.txt
- [ ] pytest ejecuta sin errores (0 tests collected OK)
- [ ] .gitignore configurado
- [ ] README.md con instrucciones de setup

---

### AICM-002: Implementar token_calculator.py con tabla de precios LLM
**Points:** 3 | **Priority:** Critical | **Sprint:** 1 | **Epic:** E2

**As an** investigador
**I want** una funcion que calcule el costo en USD dados tokens input/output y modelo LLM
**So that** pueda estimar el costo monetario de cualquier tarea de desarrollo IA

**AC1: Calculo basico de costo**
- Given tokens_input=100000, tokens_output=20000, model="claude-sonnet-4-6"
- When llamo `calculate_cost(tokens_input, tokens_output, model)`
- Then retorna un dict con `cost_input_usd`, `cost_output_usd`, `cost_total_usd`
- And los valores son correctos segun la tabla de precios

**AC2: Tabla de precios configurable**
- Given un archivo `data/token_prices.json` con precios por modelo
- When se carga el calculador
- Then usa los precios del JSON (no hardcodeados)
- And incluye al menos: claude-sonnet-4-6, claude-opus-4-6, gpt-4o, gpt-4o-mini, gemini-2.0-flash

**AC3: Modelo no encontrado**
- Given model_id="modelo-inexistente"
- When llamo `calculate_cost(1000, 500, model_id)`
- Then lanza `ValueError` con mensaje descriptivo

**AC4: Inputs invalidos**
- Given tokens negativos o no numericos
- When llamo `calculate_cost(-100, 500, "claude-sonnet-4-6")`
- Then lanza `ValueError`

**Technical Notes**
- Type hints en funciones publicas
- `token_prices.json` con estructura: `{model_id: {price_input_per_m: float, price_output_per_m: float}}`
- Funcion pura sin side effects

**DoD**
- [ ] `models/token_calculator.py` implementado
- [ ] `data/token_prices.json` con al menos 5 modelos
- [ ] Type hints y docstrings
- [ ] Importable desde otros modulos

---

### AICM-003: Crear task_baselines.json con datos iniciales
**Points:** 3 | **Priority:** Critical | **Sprint:** 1 | **Epic:** E2

**As an** investigador
**I want** baselines de consumo de tokens por tipo de tarea documentados en JSON
**So that** el modelo pueda estimar tokens para cualquier combinacion tipo+complejidad

**AC1: Estructura del archivo**
- Given el archivo `data/task_baselines.json`
- When lo cargo
- Then contiene al menos 5 tipos: feature-new, feature-enhance, bugfix-minor, bugfix-major, refactor

**AC2: Parametros por tipo**
- Given cualquier tipo de tarea en el JSON
- When inspecciono sus parametros
- Then incluye: `context_base_tokens`, `tokens_per_iteration`, `avg_iterations`, `coordinator_overhead_pct`, `agents`

**AC3: Multiplicadores de complejidad**
- Given el JSON cargado
- When accedo a la seccion de multiplicadores
- Then contiene: XS=0.5, S=1.0, M=1.8, L=3.5, XL con rango [6, 10]

**AC4: Datos coherentes**
- Given los baselines cargados
- When comparo feature-new vs bugfix-minor
- Then feature-new tiene mayor context_base_tokens y mas agentes involucrados

**Technical Notes**
- Valores iniciales basados en estimaciones del SEED_DOCUMENT (calibrar luego con datos reales)
- Incluir los 13 tipos de la taxonomia del seed, con al menos 5 completamente parametrizados
- Los tipos restantes pueden tener valores placeholder marcados con `"estimated": true`

**DoD**
- [ ] `data/task_baselines.json` creado y validable
- [ ] Al menos 5 tipos completamente parametrizados
- [ ] Validador o schema documentado
- [ ] Consistencia interna verificada

---

### AICM-004: Implementar cost_estimator.py con formula base C1
**Points:** 4 | **Priority:** Critical | **Sprint:** 2 | **Epic:** E2

**As an** investigador
**I want** un estimador que calcule costo USD de una historia dado tipo + complejidad + modelo
**So that** pueda responder PQ-001, PQ-002, PQ-003 con un solo llamado

**AC1: Estimacion basica**
- Given tipo="feature-new", complejidad="M", modelo="claude-sonnet-4-6"
- When llamo `estimate_story_cost(task_type, complexity, model_id)`
- Then retorna: tokens_input, tokens_output, cost_usd, breakdown_by_agent, confidence_range

**AC2: Formula correcta**
- Given los baselines cargados
- When estimo una historia
- Then tokens = (context_base + sum(tokens_per_agent)) * multiplier * avg_iterations
- And coordinator_overhead se agrega como porcentaje del total

**AC3: Rango de confianza**
- Given una estimacion
- When inspecciono confidence_range
- Then incluye low, expected, high (ej: +/- 30% para datos estimados)

**AC4: Breakdown por agente**
- Given tipo="feature-new" con agents=[developer, test-engineer, code-reviewer]
- When estimo la historia
- Then el breakdown muestra tokens y costo por cada agente + coordinador

**Technical Notes**
- Depende de: AICM-002 (token_calculator), AICM-003 (task_baselines)
- Usar composicion: cost_estimator importa token_calculator y data_loader
- Implementar `data_loader.py` como parte de esta historia (carga JSON)

**DoD**
- [ ] `models/cost_estimator.py` + `models/data_loader.py` implementados
- [ ] Formula validada manualmente con 2-3 ejemplos
- [ ] Type hints y docstrings
- [ ] Ejecutable desde CLI: `python -m models.cost_estimator --type feature-new --complexity M`

---

## Pendientes (Sprint 2+ - indice)

### AICM-010: Crear market_salaries.json con datos de mercado
**Points:** 2 | **Priority:** High | **Sprint:** 2 | **Epic:** E3

**As an** investigador **I want** datos de salarios dev por region (AR, US, EU)
**So that** pueda calcular costo dia-hombre para la comparativa C3.
**AC:** JSON con salarios senior/mid/junior por region, overhead factor, horas productivas/dia.
Deps: ninguna. Agente: python-backend-developer.

### AICM-011: Implementar comparison_calculator.py (C3)
**Points:** 4 | **Priority:** High | **Sprint:** 2 | **Epic:** E3

**As an** investigador **I want** funciones que conviertan costo-tokens a dias-hombre equivalentes
**So that** pueda comparar cuantitativamente IA vs. tradicional (PQ-005).
**AC:** Funciones: `tokens_to_manhours()`, `calculate_roi()`, `compare_story()`. Output: tabla comparativa.
Deps: AICM-004, AICM-010. Agente: python-backend-developer.

### AICM-005: Notebook 01_exploracion_tokens.ipynb
**Points:** 5 | **Priority:** High | **Sprint:** 3 | **Epic:** E3

**As an** investigador **I want** un notebook interactivo que analice consumo de tokens por tipo de tarea
**So that** pueda visualizar patrones y validar los baselines (PQ-001, PQ-002, PQ-008).
**AC:** Graficos: distribucion por tipo, por complejidad, contexto vs ejecucion, breakdown por agente.
Deps: AICM-004. Agente: python-backend-developer.

### AICM-006: Implementar transition_model.py con fases 0-4
**Points:** 5 | **Priority:** High | **Sprint:** 3 | **Epic:** E4

**As an** investigador **I want** un modelo que proyecte costos por fase de transicion (0-4)
**So that** pueda calcular el punto de inflexion economico (PQ-005, PQ-006).
**AC:** Funcion `project_transition(team_profile, months)` retorna curvas C_human(t) y C_ai(t) por fase.
Roles por fase, velocidad relativa, costo relativo. Parametrizable por perfil de equipo (AR, US).
Deps: AICM-004, AICM-010. Agente: python-backend-developer.

### AICM-007: Notebook 04_punto_inflexion.ipynb
**Points:** 6 | **Priority:** High | **Sprint:** 3 | **Epic:** E4

**As an** investigador **I want** un notebook que grafique la curva de cruce IA vs. humano
**So that** pueda visualizar el punto de inflexion para distintos perfiles (PQ-005, PQ-010).
**AC:** Graficos interactivos (Plotly): curvas C_human vs C_ai, slider de precios tokens,
comparativa 2-3 perfiles de equipo, tabla resumen con meses-al-inflexion.
Deps: AICM-006. Agente: python-backend-developer.

### AICM-008: Tests para modulos de calculo
**Points:** 3 | **Priority:** Medium | **Sprint:** 3 | **Epic:** E5

**As a** developer **I want** tests unitarios para token_calculator, cost_estimator y transition_model
**So that** pueda confiar en que las formulas producen resultados correctos y reproducibles.
**AC:** pytest con >70% coverage en models/. Edge cases: precio 0, tokens negativos, modelo inexistente.
Fixtures con datos de prueba. Regression tests con outputs esperados fijados.
Deps: AICM-004, AICM-006. Agente: test-engineer.

### AICM-012: Notebook 02_comparativa_tradicional.ipynb
**Points:** 5 | **Priority:** Medium | **Sprint:** 4 | **Epic:** E3

**As an** investigador **I want** un notebook comparativo IA vs. dias-hombre con datos de 2 proyectos reales
**So that** pueda cuantificar el ROI y producir evidencia para el documento ejecutivo (PQ-003, PQ-007).
**AC:** Comparativa para 2 proyectos del ecosistema. Tablas: costo IA vs humano por historia,
ROI por tipo de tarea, factor de velocidad. Graficos: barras comparativas, waterfall de ahorro.
Deps: AICM-011, AICM-005. Agente: python-backend-developer.

### AICM-009: Documento ejecutivo stakeholder-ready
**Points:** 2 | **Priority:** Low | **Sprint:** 4 | **Epic:** E5

**As an** investigador **I want** un documento de 2 paginas con hallazgos clave
**So that** pueda presentar el modelo y sus conclusiones a stakeholders no tecnicos.
**AC:** PDF/MD con: resumen ejecutivo, tabla de costos IA vs humano, grafico de inflexion,
recomendaciones por fase, limitaciones. Maximo 2 paginas.
Deps: AICM-007, AICM-012. Agente: coordinador.

---

## Completadas (indice)
| ID | Titulo | Puntos | Fecha |
|----|--------|--------|-------|
| AICM-001 | Setup inicial Python | 2 | 2026-03-13 |
| AICM-002 | token_calculator.py | 3 | 2026-03-13 |
| AICM-003 | task_baselines.json | 3 | 2026-03-13 |
| AICM-004 | cost_estimator.py + data_loader.py | 4 | 2026-03-13 |
| AICM-005 | Notebook 01_exploracion_tokens (4 PNGs) | 5 | 2026-03-13 |
| AICM-006 | transition_model.py | 5 | 2026-03-13 |
| AICM-007 | Notebook 04_punto_inflexion (4 PNGs) | 6 | 2026-03-13 |
| AICM-008 | Tests suite (33/33, 77% coverage) | 3 | 2026-03-13 |
| AICM-010 | market_salaries.json (5 regiones) | 2 | 2026-03-13 |
| AICM-011 | comparison_calculator.py | 4 | 2026-03-13 |
| AICM-012 | Notebook 02_comparativa_tradicional (3 PNGs) | 5 | 2026-03-13 |

## ID Registry
| Rango | Estado |
|-------|--------|
| AICM-001 a AICM-009 | Asignados (semilla) |
| AICM-010 a AICM-012 | Asignados (backlog v1.0) |
| AICM-013+ | Disponible |

**Proximo ID:** AICM-013
