# IDEA-030: Investigar Harness de Software

**Fecha:** 2026-02-22
**Categoria:** general
**Estado:** Seed
**Prioridad:** Sin definir

---

## Descripcion

Investigacion del concepto de "harness" en software: una infraestructura que envuelve, controla y gestiona la ejecucion de un componente (ya sea para testing, integracion con APIs, simulacion o ejecucion de agentes IA). El concepto esta evolucionando rapidamente en 2026 con el surgimiento de los "agent harnesses" como disciplina propia.

## Hallazgos

### 1. Definicion General

Un **software harness** es una infraestructura de soporte que envuelve un componente de software para controlarlo, observarlo o probarlo en un entorno gestionado. El harness actua como intermediario entre el componente y su entorno real, proporcionando:

- **Control de ejecucion:** Iniciar, detener, pausar, reintentar
- **Gestion de contexto:** Proveer inputs, configuracion, estado
- **Observabilidad:** Logging, metricas, trazas
- **Aislamiento:** Separar el componente de dependencias externas
- **Manejo de fallos:** Retry logic, fallbacks, circuit breakers

La metafora viene de la industria aeroespacial: un "harness" (arnes) es el cableado estructurado que conecta, alimenta y protege componentes dentro de un sistema mayor.

### 2. Tipos Principales

#### 2.1 Test Harness

El mas conocido y documentado. Es una coleccion de stubs, drivers, scripts y datos de prueba que automatizan y gestionan la ejecucion de tests bajo condiciones controladas.

**Componentes:**
- **Test driver:** Invoca el componente bajo prueba
- **Stubs:** Simulan dependencias (APIs, DBs, servicios)
- **Test scripts:** Definen logica de validacion
- **Input data:** Alimentan escenarios diferentes
- **Expected results:** Definen criterios de exito
- **Reporting:** Informan pass/fail y defectos

**Subtipos:**
- **Unit test harness:** Prueba componentes individuales en aislamiento
- **Integration test harness:** Combina componentes para detectar defectos de integracion
- **System test harness:** Prueba el flujo completo de la aplicacion end-to-end

**Ejemplo:** xUnit, NUnit, Jest son frameworks que proporcionan harness de testing. MATLAB/Simulink tiene "test harnesses" especificos para modelos de simulacion.

#### 2.2 API Harness / Wrapper

Infraestructura que envuelve una API externa para:
- Normalizar interfaces (adaptar formatos de request/response)
- Agregar retry logic y circuit breakers
- Cachear respuestas
- Manejar autenticacion y rate limiting
- Loggear todas las interacciones
- Permitir swap entre API real y mock

**Diferencia con un simple wrapper:** El harness agrega comportamiento de gestion (retry, logging, monitoring), no solo traduce interfaces.

**Ejemplo:** Un harness sobre la API de Anthropic que maneja streaming, retry en errores 429, logging de tokens consumidos, y fallback a respuestas cacheadas.

#### 2.3 Runtime Harness

Infraestructura que gestiona la ejecucion de un componente en runtime:
- Lifecycle management (init, run, shutdown)
- Health checks y self-healing
- Resource management (memoria, conexiones)
- Configuration injection
- Graceful degradation

**Ejemplo:** Application servers (Kestrel en .NET, Fastify en Node.js) son runtime harnesses para aplicaciones web. Docker es un runtime harness para containers.

#### 2.4 Simulation Harness

Infraestructura para ejecutar simulaciones controladas:
- Gestiona el loop de simulacion (ticks, turnos, eventos)
- Inyecta condiciones iniciales y parametros
- Recolecta metricas durante la ejecucion
- Permite reproducibilidad (seeds, determinismo)
- Soporta escenarios "what-if"

**Ejemplo:** Harness de simulacion en MATLAB/Simulink para modelos fisicos. Game engines como Unity/Unreal funcionan como simulation harnesses.

#### 2.5 Agent Harness (Emergente 2025-2026)

La evolucion mas reciente y significativa del concepto. Segun Martin Fowler y OpenAI, un **agent harness** es la infraestructura que envuelve un modelo de IA para gestionar tareas de larga duracion de forma confiable.

**El modelo genera respuestas. El harness gestiona todo lo demas:**
- Prompt presets y context engineering
- Tool orchestration (que herramientas puede usar el agente)
- Filesystem access controlado
- Sub-agent management
- Human approvals (cuando escalar al humano)
- State persistence entre ejecuciones
- Lifecycle hooks (init, before_tool_call, after_response, error)
- Planning y replanning
- Garbage collection del contexto

**Insight clave de 2026:** "El modelo es commodity (Claude, GPT-4, Gemini rinden similar). El harness determina si los agentes tienen exito o fracasan."

**Ejemplo real:** OpenAI tardo 5 meses en construir el harness de Codex. El repositorio tiene ~1 millon de lineas de codigo, con el harness gestionando mas de 1500 PRs mergeados por 7 ingenieros (3.5 PRs/ingeniero/dia).

### 3. Patrones de Implementacion Comunes

#### 3.1 Patron Sandwich (Wrap-Execute-Unwrap)

```
Harness recibe request
  → Pre-procesamiento (validacion, logging, context setup)
    → Componente ejecuta su logica
  → Post-procesamiento (logging, cleanup, transformacion)
Harness retorna resultado
```

#### 3.2 Patron Pipeline

```
Input → Stage 1 (parse) → Stage 2 (validate) → Stage 3 (execute) → Stage 4 (format) → Output
```

Cada stage tiene su propio error handling y puede ser reemplazado independientemente.

#### 3.3 Patron Lifecycle Hooks

```csharp
interface IHarness<T> {
    void OnInitialize(HarnessContext ctx);
    T OnBeforeExecute(Request req);
    Result OnExecute(T prepared);
    void OnAfterExecute(Result result);
    void OnError(Exception ex);
    void OnShutdown();
}
```

#### 3.4 Patron Strategy (Swappable Core)

El harness mantiene la infraestructura fija pero permite intercambiar el componente central:

```
Harness [fijo: logging, retry, auth, monitoring]
  └── Strategy [intercambiable: MockProcessor, RealProcessor, HybridProcessor]
```

#### 3.5 Patron Observer/Event-Driven

```
Harness emite eventos en cada paso:
  → onRequestReceived
  → onPreProcessed
  → onExecutionStarted
  → onExecutionCompleted / onExecutionFailed
  → onResponseSent

Observers se suscriben para: logging, metricas, alertas, auditing
```

### 4. Casos de Uso Reales

| Caso | Tipo de Harness | Ejemplo |
|------|----------------|---------|
| Testing de microservicios | Test harness | WireMock, Mountebank (stubs de APIs) |
| SDK de APIs de IA | API harness | OpenAI SDK, Anthropic SDK |
| CI/CD pipelines | Runtime harness | GitHub Actions runners, Jenkins agents |
| Simulacion fisica | Simulation harness | MATLAB/Simulink test harnesses |
| Coding assistants | Agent harness | OpenAI Codex harness, Claude Code |
| Game testing | Simulation harness | Unity Test Framework |
| Load testing | Test harness | k6, Locust (harness de carga) |

### 5. Diferencia entre Harness, Wrapper, Adapter y Facade

| Concepto | Proposito | Complejidad | Comportamiento propio |
|----------|-----------|-------------|----------------------|
| **Wrapper** | Encapsular y simplificar acceso a un componente | Baja | Minimo (thin layer) |
| **Adapter** | Hacer compatible una interfaz con otra existente | Media | No agrega, solo traduce |
| **Facade** | Proveer interfaz simplificada a un subsistema complejo | Media | Orquesta pero no agrega logica |
| **Harness** | Controlar, observar y gestionar la ejecucion completa | Alta | Si: retry, logging, lifecycle, state |

**Relacion jerarquica:**
- Un **wrapper** es la capa mas fina: solo encapsula.
- Un **adapter** traduce entre interfaces incompatibles.
- Una **facade** simplifica multiples componentes detras de una interfaz unica.
- Un **harness** es la capa mas gruesa: envuelve, controla, observa, gestiona el ciclo de vida completo y agrega comportamiento propio significativo.

**Regla practica:**
- Si solo cambias la interfaz → Adapter
- Si solo simplificas el acceso → Facade
- Si solo encapsulas → Wrapper
- Si controlas ejecucion, manejas errores, loggeas, gestionas estado y ciclo de vida → Harness

Un harness puede CONTENER adapters, wrappers y facades internamente como parte de su implementacion.

## Aplicacion a Proyectos Propios

### Claude Personal (Harness .NET sobre API de Anthropic)

El proyecto Claude Personal es, por definicion, un **API harness + Agent harness** sobre la API de Anthropic:

- **API harness:** Envuelve la API REST de Anthropic con retry logic, manejo de streaming, logging de tokens, rate limiting, y error handling robusto
- **Agent harness:** Si el proyecto gestiona conversaciones de larga duracion, tools, y estado persistente, entonces actua como agent harness
- **Componentes tipicos del harness:**
  - `AnthropicClient` → API wrapper (capa fina)
  - `ConversationManager` → Lifecycle management
  - `ToolOrchestrator` → Gestion de herramientas disponibles
  - `TokenTracker` → Observabilidad
  - `RetryPolicy` → Resiliencia
  - `PromptTemplateEngine` → Context engineering

**Valor del framing "harness":** Pensar en Claude Personal como un harness (no solo un wrapper o cliente) da claridad sobre que responsabilidades le corresponden: no es solo "llamar a la API", es gestionar toda la experiencia de interaccion con el modelo.

### Gaia Protocol (Balance Harness para Simulacion IA vs IA)

Gaia Protocol encaja como un **simulation harness + agent harness dual:**

- **Simulation harness:** Gestiona el loop de simulacion donde dos IAs interactuan
  - Turnos/rondas de interaccion
  - Condiciones iniciales (prompts, personalidades, objetivos)
  - Recoleccion de metricas (coherencia, creatividad, convergencia)
  - Reproducibilidad (seeds para el random)
- **Balance harness:** Componente especifico que asegura equidad entre los dos agentes
  - Mismo tiempo/tokens por turno
  - Mismo acceso a herramientas
  - Evaluacion simetrica
  - Deteccion de loops o estancamiento
- **Agent harness dual:** Cada IA tiene su propio harness individual
  - Gestion de contexto independiente
  - State management por agente
  - Tool access controlado por agente

**Arquitectura sugerida:**

```
SimulationHarness (loop principal, metricas, reproducibilidad)
  ├── AgentHarness[A] (modelo A, contexto A, tools A)
  ├── AgentHarness[B] (modelo B, contexto B, tools B)
  └── BalanceHarness (arbitraje, equidad, evaluacion)
```

## Notas

### Fuentes principales
- [Test harness - Wikipedia](https://en.wikipedia.org/wiki/Test_harness)
- [Martin Fowler - Harness Engineering](https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html)
- [OpenAI - Harness Engineering: Leveraging Codex](https://openai.com/index/harness-engineering/)
- [Aakash Gupta - 2025 Was Agents, 2026 Is Agent Harnesses](https://aakashgupta.medium.com/2025-was-agents-2026-is-agent-harnesses-heres-why-that-changes-everything-073e9877655e)
- [Philipp Schmid - The Importance of Agent Harness in 2026](https://www.philschmid.de/agent-harness-2026)
- [InfoQ - OpenAI Introduces Harness Engineering](https://www.infoq.com/news/2026/02/openai-harness-engineering-codex/)
- [BrowserStack - What is Test Harness](https://www.browserstack.com/guide/what-is-test-harness)
- [Design Patterns: Adapter vs Facade vs Bridge (GitHub Gist)](https://gist.github.com/Integralist/d67f0f913d795f703b89)

### Observaciones
- El concepto de "harness" esta viviendo una explosion de relevancia en 2026 gracias a los agentes de IA
- Martin Fowler y OpenAI estan formalizando "Harness Engineering" como disciplina
- La frase clave: "El modelo es commodity, el harness es el diferenciador"
- Para proyectos propios, pensar en terminos de harness da mejor estructura arquitectonica que pensar en "wrappers" o "clientes"

---

## 6. Harness Engineering como Disciplina (2026)

### Definicion formal

Harness Engineering es una metodologia de ingenieria de software donde **los humanos disenan entornos y especifican intenciones, y los agentes de IA ejecutan**. El foco del ingeniero pasa de escribir codigo a:
- Disenar el entorno donde los agentes operan
- Especificar la intencion (que lograr, no como)
- Proveer feedback estructurado (via PRs)
- Mantener restricciones arquitectonicas

### Los 3 pilares (segun Martin Fowler)

1. **Context Engineering:** Base de conocimiento viva en el repositorio. Un directorio `docs/` estructurado es el "system of record". AGENTS.md es un mapa que apunta a fuentes de verdad mas profundas. Los agentes acceden a contexto dinamico: observabilidad, navegacion de browser, logs.

2. **Architectural Constraints:** Restricciones mecanicamente reforzadas (no solo convenciones). Dependencias fluyen en secuencia controlada: `Types -> Config -> Repo -> Service -> Runtime -> UI`. Linters custom y tests estructurales previenen violaciones. Los agentes estan restringidos a operar dentro de estas capas.

3. **Garbage Collection:** Agentes que corren periodicamente para encontrar inconsistencias en documentacion o violaciones de restricciones arquitectonicas. Limpieza continua de codigo obsoleto.

### Caso OpenAI Codex: Numeros reales

- 5 meses de desarrollo
- ~1 millon de lineas de codigo generadas (0 escritas manualmente)
- 1500+ PRs mergeados
- 7 ingenieros guiando agentes
- 3.5 PRs/ingeniero/dia
- Incluye: logica de aplicacion, documentacion, CI config, setup de observabilidad

### Ciclo de trabajo de un agente Codex

```
1. Recibir tarea (prompt declarativo con intencion)
2. Generar codigo basado en contexto del repo
3. Ejecutar tests automatizados
4. Validar contra restricciones arquitectonicas
5. Iterar autonomamente hasta satisfacer criterios
6. Abrir PR para review humano
7. Incorporar feedback y re-iterar si es necesario
```

### Codex App Server: Arquitectura

El App Server es un protocolo bidireccional (JSON-RPC) que desacopla la logica core del agente de sus superficies de cliente:
- CLI
- Extension VS Code
- Web app
- Desktop

Una unica API estable potencia todas las experiencias Codex.

### Cambio de paradigma para el ingeniero

| Antes | Con Harness Engineering |
|-------|------------------------|
| Escribir codigo | Disenar entornos |
| Implementar features | Especificar intencion |
| Debug manual | Proveer feedback en PRs |
| Code review | Definir restricciones arquitectonicas |
| Documentar despues | Documentar como sistema de record |

---

## 7. Implicaciones para nuestros proyectos

### Claude Personal como Harness

Reframear Claude Personal no como "un CLI que llama a la API" sino como un **agent harness completo**:

| Componente Harness | Mapeo en Claude Personal |
|--------------------|--------------------------|
| Context Engineering | Memory Store + conversation history + user facts |
| Tool Orchestration | Tool Registry + ITool implementations |
| Architectural Constraints | Permisos por tool, confirmacion de acciones destructivas |
| Garbage Collection | Compresion automatica de contexto, limpieza de memoria |
| Lifecycle Management | Sesiones, streaming, graceful shutdown |
| Observabilidad | Audit log, token tracking |

### Metodologia propia inspirada en Harness Engineering

Nuestra metodologia (CLAUDE.md, agentes especializados, delegacion, context en claude_context/) **ya es una forma de Harness Engineering**:
- `claude_context/` = sistema de record (como docs/ de Codex)
- CLAUDE.md = mapa de agentes (como AGENTS.md)
- Agentes especializados = agentes Codex por dominio
- Directivas obligatorias = restricciones arquitectonicas
- Mejora continua = garbage collection

### Fuentes adicionales
- [InfoQ - OpenAI Introduces Harness Engineering](https://www.infoq.com/news/2026/02/openai-harness-engineering-codex/)
- [OpenAI - Unlocking the Codex Harness: App Server](https://openai.com/index/unlocking-the-codex-harness/)
- [SuperGok - Codex Harness Architecture](https://supergok.com/codex-harness-architecture-app-server/)
- [Gend.co - Codex for Agent-First Engineering](https://www.gend.co/blog/codex-agent-first-engineering)
- [InfoQ - OpenAI Codex App Server Architecture](https://www.infoq.com/news/2026/02/opanai-codex-app-server/)

---

## Historial
| Fecha | Evento |
|-------|--------|
| 2026-02-22 | Investigacion iniciada y registrada |
| 2026-02-22 | Profundizacion: Harness Engineering como disciplina, caso Codex, implicaciones para proyectos propios |
