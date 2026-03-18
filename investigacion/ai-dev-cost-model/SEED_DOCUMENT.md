# SEED DOCUMENT: AI Development Cost Model
**Fecha de creacion:** 2026-03-13
**Clasificador:** investigacion
**Proyecto:** ai-dev-cost-model
**Short:** aicm
**Estado:** Semilla

---

## Vision

Construir un sistema de costeo de desarrollo de software basado en **consumo de tokens** de agentes IA, como alternativa y complemento al modelo tradicional de estimacion por dias-hombre. El modelo debe poder:

- Estimar el costo real (en USD) de cualquier unidad de trabajo de software
- Comparar ese costo con el equivalente en dias-hombre
- Proyectar la transicion gradual de equipos humanos hacia equipos IA-supervisados
- Identificar el punto de inflexion economico donde la IA es mas barata que el equipo humano equivalente

---

## Problema que Resuelve

El desarrollo de software impulsado por agentes IA tiene una nueva unidad de medida natural: el **token**. Sin embargo, las organizaciones siguen estimando, planificando y presupuestando en dias-hombre, lo que genera:

- Incapacidad de comparar costos reales de desarrollo IA vs. humano
- Dificultad para justificar inversion en agentes IA ante stakeholders financieros
- Ausencia de metricas de eficiencia especificas para flujos IA-asistidos
- Incertidumbre sobre como escala el costo al aumentar la complejidad del proyecto
- Sin baseline cuantitativo, es imposible optimizar el flujo de trabajo

### Hipotesis Central

> Un equipo de 1 persona con agentes IA puede producir el equivalente a 3-10 devs tradicionales a una fraccion del costo, pero este numero no es verificable sin un modelo de costeo riguroso.

---

## Componentes del Sistema

### Componente 1: Modelo de Estimacion por Tokens

**Objetivo:** Estimar el costo en tokens (y por tanto en dolares) de desarrollar una unidad de trabajo.

**Variables del modelo:**

| Variable | Descripcion | Fuente |
|----------|-------------|--------|
| `task_type` | Tipo de tarea (feature, bugfix, etc.) | Parametro |
| `complexity` | XS / S / M / L / XL o story points | Parametro |
| `model_id` | claude-sonnet-4-6, gpt-4o, etc. | Parametro |
| `price_input` | USD por 1M tokens de input | Tabla de precios |
| `price_output` | USD por 1M tokens de output | Tabla de precios |
| `agents_involved` | Lista de agentes que participan | Framework C2 |
| `iterations` | Numero de iteraciones de refinamiento | Baseline historico |
| `context_overhead` | Tokens de coordinacion (coordinador) | Medicion propia |

**Formula base:**

```
tokens_task = context_base + sum(tokens_per_agent) + coordinator_overhead
tokens_total = tokens_task * avg_iterations
cost_usd = (tokens_total.input * price_input + tokens_total.output * price_output) / 1_000_000
```

**Output por historia:**
- Estimacion de tokens (input / output / total)
- Costo en USD (puntual + rango de confianza)
- Distribucion por agente (quien consume que porcentaje)
- Comparacion con historia similar historica

### Componente 2: Framework por Tipo de Tarea

**Objetivo:** Parametrizar el consumo de tokens segun el tipo de actividad, creando baselines replicables.

**Taxonomia de tareas:**

| Tipo | Descripcion | Agentes tipicos | Complejidad tokens |
|------|-------------|-----------------|-------------------|
| `feature-new` | Feature nueva desde cero | developer + test + reviewer | Alta |
| `feature-enhance` | Extension de feature existente | developer + reviewer | Media |
| `bugfix-minor` | Bug aislado, causa conocida | developer + test | Baja |
| `bugfix-major` | Bug sistemico, investigacion necesaria | developer + test + reviewer | Alta |
| `refactor` | Refactorizacion sin cambio funcional | developer + reviewer | Media |
| `test-coverage` | Agregar tests a codigo existente | test-engineer | Media |
| `docs` | Documentacion tecnica | (solo contexto) | Baja |
| `architecture` | Diseno de arquitectura | architect + reviewer | Muy alta |
| `setup` | Setup inicial de proyecto | developer + devops | Media |
| `research` | Investigacion tecnica exploratoria | general-purpose | Variable |
| `seed` | Creacion de semilla de proyecto | coordinador | Media |
| `review-pr` | Code review de PR | code-reviewer | Media |
| `debug-session` | Sesion de debugging interactivo | developer | Alta (iterativa) |

**Parametros por tipo (a completar con datos reales):**

```yaml
feature-new:
  context_base_tokens: 15000      # Contexto inicial (CLAUDE.md, arquitectura, etc.)
  tokens_per_iteration: 8000      # Developer + reviewer por vuelta
  avg_iterations: 3               # Iteraciones promedio hasta Done
  coordinator_overhead_pct: 0.15  # Claude coordinador = 15% del total
  agents: [developer, test-engineer, code-reviewer]

bugfix-minor:
  context_base_tokens: 8000
  tokens_per_iteration: 4000
  avg_iterations: 2
  coordinator_overhead_pct: 0.10
  agents: [developer, test-engineer]
```

**Multiplicadores por complejidad:**

| Complejidad | Story Points | Multiplicador tokens |
|-------------|-------------|---------------------|
| XS | 1 | 0.5x |
| S | 2 | 1.0x (baseline) |
| M | 3 | 1.8x |
| L | 5 | 3.5x |
| XL | 8+ | 6-10x |

### Componente 3: Comparativa con Modelo Tradicional

**Objetivo:** Traducir costos en tokens a metricas comparables con dias-hombre.

**Supuestos del modelo tradicional:**

| Parametro | Valor tipico AR/LATAM | Valor tipico US |
|-----------|----------------------|-----------------|
| Salario dev senior/mes | $3,000-8,000 USD | $12,000-20,000 USD |
| Horas productivas/dia | 5-6h | 5-6h |
| Dias laborables/mes | 22 | 22 |
| Costo real (con overhead 1.5x) | $4,500-12,000 | $18,000-30,000 |
| Costo/hora productivo | $30-90 USD | $120-220 USD |
| Historias/dia (promedio) | 1-2 (S/M) | 1-2 (S/M) |

**Metricas de conversion:**

```
costo_dia_hombre = salario_mensual * overhead_factor / dias_laborables

tokens_equivalentes_dia = (costo_dia_hombre / costo_por_token_promedio)

factor_velocidad = historias_IA_por_dia / historias_humano_por_dia

ROI_IA = (costo_dev_humano - costo_IA) / costo_IA * 100
```

**Dimensiones de comparacion:**

| Dimension | Modelo Tradicional | Modelo IA |
|-----------|--------------------|-----------|
| Unidad de costo | Salario (fijo mensual) | Tokens (variable por uso) |
| Escala | Lineal (+ devs = + costo) | Sub-lineal (paralelo sin costo extra) |
| Velocidad tipica | 1-2 historias S/dia | 5-15 historias S/dia |
| Costo marginal (+ feature) | Alto (tiempo + salario) | Bajo (tokens incrementales) |
| Costo en inactividad | Salario completo | $0 |
| Consistencia de calidad | Variable (fatiga, contexto) | Alta (sin fatiga) |
| Costo de onboarding | Alto (semanas) | Bajo (contexto en prompt) |
| Technical debt | Acumulacion implicita | Medible via tokens de refactor |
| Curva de aprendizaje | Lenta | Inmediata (con buen contexto) |
| Escalado a spike de trabajo | Lento (hiring) | Inmediato (mas agentes) |

### Componente 4: Modelo de Proyeccion de Transicion

**Objetivo:** Modelar la evolucion de un equipo desde 100% humano hasta 100% IA-supervisado, identificando fases, roles que mutan y el punto de inflexion economico.

**Fases del modelo de transicion:**

```
FASE 0: 100% Humano (baseline)
  Equipo: N devs senior + M devs junior + QA + PM
  Estimacion: dias-hombre
  Herramientas IA: ninguna o solo autocompletado basico
  Velocidad relativa: 1x
  Costo relativo: 100%

FASE 1: IA como Asistente (10-30% tareas IA)
  Equipo: mismos roles, +prompt literacy
  IA hace: autocompletado, generacion de boilerplate, busqueda de bugs obvios
  Humano hace: todo el diseño, review, decision
  Estimacion: dias-hombre (sin cambio formal)
  Velocidad relativa: 1.2-1.5x
  Costo relativo: 95-100% (inversion en licencias IA)
  Roles que mutan: devs aprenden prompting, QA aprende test automation con IA

FASE 2: IA como Par (30-60% tareas IA)
  Equipo: -1 junior por cada 3 seniors, nuevo rol "AI Coordinator"
  IA hace: implementacion de features S/M con supervision, tests, docs
  Humano hace: arquitectura, decisiones clave, review de output IA, features L/XL
  Estimacion: mixta (dias-hombre + tokens para subsistemas)
  Velocidad relativa: 2-4x
  Costo relativo: 60-75%
  Roles que mutan: junior → reviewer/QA de output IA; senior → coordinator/architect

FASE 3: IA como Ejecutor (60-85% tareas IA)
  Equipo: 1-2 seniors como directores tecnicos, 0-1 junior revisor
  IA hace: mayoria de features, refactors, tests, docs, bugs
  Humano hace: vision arquitectonica, decisions de negocio, validacion final, stakeholders
  Estimacion: tokens (dias-hombre como referencia para stakeholders)
  Velocidad relativa: 4-10x
  Costo relativo: 25-40%
  Roles que mutan: senior → Technical Director / AI Supervisor

FASE 4: 100% IA Supervisada (85-100% tareas IA)
  Equipo: 1 Technical Director + 1 Quality Supervisor (pueden ser part-time)
  IA hace: todo el desarrollo, testing, documentacion, planning tecnico
  Humano hace: estrategia, vision de producto, validacion de negoico, relacion con clientes
  Estimacion: tokens
  Velocidad relativa: 10-50x
  Costo relativo: 10-20% del modelo tradicional equivalente
```

**Punto de Inflexion Economico:**

El punto de inflexion es donde la curva de costo IA cruza la curva de costo humano.

Variables del calculo:
- `C_human(t)` = costo mensual del equipo humano (fijo + escalado)
- `C_ai(t)` = costo mensual IA = tokens_consumidos * precio_token + supervision_humana
- Inflexion: punto donde `C_ai(t) < C_human(t_equivalente)`

Factores que adelantan el inflexion:
- Salarios altos del mercado objetivo
- Proyectos con alta repeticion (mucho boilerplate)
- Calidad de prompting y contexto del equipo

Factores que retrasan el inflexion:
- Alta incertidumbre de requisitos (iteraciones costosas)
- Proyectos de alta innovacion sin precedentes
- Pobre calidad de contexto / sin metodologia definida

---

## Marco Conceptual: Token Economics del Desarrollo

### La "Hora-Token"

Analogia con hora-hombre: una **hora-token** es la cantidad de tokens consumida para producir el equivalente de 1 hora de trabajo de un dev senior.

```
hora_token = tokens_consumidos / factor_velocidad_vs_senior
```

Esta metrica permite:
- Comparar eficiencia entre modelos LLM
- Medir mejora del equipo IA con el tiempo
- Presupuestar proyectos en terminos familiares para PMs

### Costo de Contexto vs. Costo de Ejecucion

Todo token consumido es de uno de dos tipos:

| Tipo | Descripcion | Optimizacion |
|------|-------------|--------------|
| **Costo de contexto** | Tokens para "entender" el proyecto (CLAUDE.md, arquitectura, historia previa) | Minimizar con contexto comprimido, buenas semillas |
| **Costo de ejecucion** | Tokens para producir el output real (codigo, tests, docs) | Optimizar con prompts precision-focused |

La metodologia actual (CLAUDE.md + context engineering) ya es una forma implicita de optimizar el costo de contexto.

### Token Waste Patterns

Patrones que generan tokens sin valor correspondiente:

1. **Re-contextualizacion** - El agente no recibe contexto suficiente y genera output incorrecto → iteracion costosa
2. **Ambiguedad en specs** - Requisitos poco claros → multiples iteraciones de refinamiento
3. **Context pollution** - El agente lee archivos irrelevantes → tokens de contexto desperdiciados
4. **Coordinator overhead** - Claude coordinador generando plans demasiado verbosos
5. **Hallucination loops** - El agente produce output incorrecto, el revisor lo rechaza → ciclo costoso

---

## Datos de Entrada Disponibles

### Datos Propios (ecosistema actual)

- Logs de billing de Anthropic Console (tokens por sesion)
- Historias completadas en proyectos del ecosistema (claude_context)
- TASK_STATE.md de proyectos activos (registro de trabajo)
- Commits del ecosistema (proxy de volumen de output)

### Datos Externos

- Precios publicos de modelos LLM (Anthropic, OpenAI, Google, Meta)
- Benchmarks de velocidad publicados (SWE-bench, HumanEval)
- Estudios de productividad IA (GitHub Copilot impact, McKinsey 2023)
- Salarios de mercado (Glassdoor, levels.fyi, encuestas locales)

---

## Stack Tecnico

| Tecnologia | Version | Uso |
|------------|---------|-----|
| Python | 3.11+ | Modelos cuantitativos, analisis |
| Pandas | 2.x | Manipulacion de datos |
| NumPy | 1.x | Calculos numericos |
| Matplotlib | 3.x | Graficos estaticos |
| Plotly | 5.x | Visualizaciones interactivas |
| Jupyter | latest | Notebooks de exploracion |
| PyYAML | 6.x | Parametros del modelo |
| Markdown | - | Documentacion, frameworks conceptuales |

---

## Estructura del Proyecto

```
C:/investigacion/ai-dev-cost-model/
  README.md
  research/
    01-token-cost-model/
      README.md                    # Descripcion del componente
      assumptions.md               # Supuestos y limitaciones
    02-task-framework/
      README.md
      task_taxonomy.md             # Taxonomia de tareas detallada
      baselines.md                 # Baselines por tipo (a completar)
    03-traditional-comparison/
      README.md
      market_data.md               # Datos de salarios y productividad
      comparison_framework.md      # Marco de comparacion
    04-transition-model/
      README.md
      phases.md                    # Descripcion detallada de fases
      roles_evolution.md           # Evolucion de roles por fase
      inflection_analysis.md       # Analisis del punto de inflexion
  models/
    cost_estimator.py              # Estimador de costo por historia
    transition_model.py            # Modelo de proyeccion de transicion
    token_calculator.py            # Calculadora de tokens/costo
    data_loader.py                 # Carga de datos (billing, historias)
  data/
    token_prices.json              # Precios actuales por modelo LLM
    task_baselines.json            # Baselines por tipo de tarea
    market_salaries.json           # Salarios de mercado por region
    sample_projects/               # Datos de proyectos reales (anonimizados)
  notebooks/
    01_exploracion_tokens.ipynb    # Analisis exploratorio de consumo
    02_comparativa_tradicional.ipynb # IA vs. dias-hombre
    03_transicion_equipos.ipynb    # Proyeccion de fases
    04_punto_inflexion.ipynb       # Calculo del punto de equilibrio
  docs/
    methodology.md                 # Metodologia de medicion y supuestos
    glossary.md                    # Glosario: token, hora-token, etc.
```

---

## Preguntas de Investigacion

| ID | Pregunta | Componente | Prioridad |
|----|----------|------------|-----------|
| PQ-001 | Cuantos tokens consume en promedio cada tipo de tarea? | C2 | Alta |
| PQ-002 | Como varia el consumo de tokens segun la complejidad (story points)? | C1, C2 | Alta |
| PQ-003 | Cual es el costo en USD de una historia tipica con el stack actual? | C1 | Alta |
| PQ-004 | Que porcentaje del total corresponde al coordinador vs. ejecutores? | C1 | Media |
| PQ-005 | En que punto el costo IA < costo humano equivalente? | C4 | Alta |
| PQ-006 | Que roles humanos se vuelven mas/menos relevantes en cada fase? | C4 | Media |
| PQ-007 | Como escala el costo con el tamano del proyecto (micro vs. large)? | C1, C3 | Media |
| PQ-008 | Cuanto cuesta el "costo de contexto" vs. el "costo de ejecucion"? | C1 | Media |
| PQ-009 | Que patrones de prompting son mas eficientes en tokens por output? | C2 | Baja |
| PQ-010 | Como cambia el ROI al variar el precio de los tokens (tendencia bajista)? | C3, C4 | Baja |

---

## Conexiones con otros Proyectos del Ecosistema

| Proyecto | Short | Conexion |
|----------|-------|----------|
| Agent Token Economics | `ate` | Complementario: ate foco en economica del agente individual, este en costeo de proyecto completo |
| Context Engineering | `ce` | Datos de eficiencia de tokens segun patron de contexto |
| Claude Orchestrator | `co` | Fuente de datos de sesiones reales con multiples agentes |
| LLM Landscape | `ll` | Datos de modelos disponibles y sus precios/capacidades |

---

## Criterios de Exito

- [ ] Modelo Python que estime costo USD de cualquier historia dado tipo + complejidad + modelo LLM
- [ ] Framework documentado con baselines empiricos para al menos 5 tipos de tarea
- [ ] Comparativa cuantitativa IA vs. tradicional para al menos 2 proyectos reales del ecosistema
- [ ] Curva de transicion con punto de inflexion para 2-3 perfiles de equipo (AR, US, startup)
- [ ] Notebook interactivo donde cualquier persona puede ingresar sus parametros y ver proyecciones
- [ ] Documento ejecutivo de 2 paginas con los hallazgos clave (formato stakeholder-ready)

---

## Riesgos e Incertidumbres

| Riesgo | Probabilidad | Impacto | Mitigacion |
|--------|-------------|---------|------------|
| Datos de tokens propios insuficientes | Media | Alto | Usar estimaciones de publicaciones + calibrar con muestras pequenas |
| Precios de tokens cambian rapido (tendencia bajista) | Alta | Medio | Parametrizar precios, hacer el modelo sensible a variaciones |
| Cada proyecto es muy diferente (alta varianza) | Alta | Alto | Categorizar por tipo, dar rangos en lugar de puntos |
| Comparacion dias-hombre es muy contextual | Alta | Medio | Ser explicito sobre supuestos de salario y region |
| El modelo puede usarse para justificar reemplazos masivos | Media | Etico | Enmarcar siempre en "augmentation", documentar limitaciones |

---

**Version:** 1.0 | **Estado:** Semilla | **Fecha:** 2026-03-13
