# Seed Document - Agent Token Economics
**Fecha:** 2026-03-09
**Origen:** Analisis de consumo real del ecosistema + investigacion web

## Vision
Investigacion aplicada sobre la optimizacion economica del uso de tokens en el diseno de agentes AI. El objetivo es identificar antipatrones de consumo, establecer patrones de diseno eficientes, y crear un framework de evaluacion que se aplique a todos los agentes del ecosistema.

## Motivacion (Caso Real)
Analisis del ecosistema del usuario (semana Mar 3-9, 2026) revelo consumo significativo:

### Datos de consumo observados
| Proyecto | Tamano logs | Sesiones | Observacion |
|----------|-------------|----------|-------------|
| AnyoneAI Sprint 4 | 45 MB | 11 | Sesiones largas de capacitacion |
| Atlas Agent | 39 MB | 112 | Meta-sesion con polling cada 30s |
| Claude Orchestrator | 36 MB | 117 | Sesiones spawneadas por orchestrator |
| AnyoneAI Assignment | 33 MB | 57 | Capacitacion + assignment |
| YouTube MCP | 30 MB | 70 | Desarrollo + debugging |
| Workspace Global | 16 MB | 61 | Sesiones ad-hoc |

### Antipatron detectado: Idle Polling
Atlas Agent usa una meta-sesion continua que hace polling cada 30 segundos via `tg_get_updates()`. Cada iteracion consume ~100 tokens aunque no haya mensajes. A 2880 iteraciones/dia = ~288K tokens/dia en idle. En 2 dias activos: ~500-600K tokens solo de polling vacio.

### Arquitectura del Atlas Agent (referencia)
```
Meta-Sesion (1 sola, continua, loop cada 30s)
  ├─ tg_get_updates() → revisa buffer Telegram
  ├─ list_sessions() → monitorea workers
  └─ sleep 30

  Al recibir instruccion:
  └─ create_session() → worker para ejecutar tarea
```
- Meta-sesion: consumo continuo bajo pero constante
- Workers: consumo alto pero solo cuando hay trabajo real
- Problema: el ratio idle/trabajo es muy alto

## Analisis por Proyecto (Auditoria Ecosistema)

### Atlas Agent (39 MB, 112 sesiones)
**Tipo:** Agente autonomo con meta-sesion continua
**Antipatrones activos:** AP-01 (idle polling 30s), AP-04 (multi-agent: meta + workers)
**Hallazgos:**
- Meta-sesion polling cada 30s: ~288K tokens/dia en idle
- Workers on-demand son eficientes, pero la meta-sesion idle domina el costo
- Ratio idle/trabajo muy alto cuando no hay instrucciones
**Recomendacion:** Adaptive polling o event-driven (webhooks Telegram)

### Claude Orchestrator (36 MB, 117 sesiones)
**Tipo:** MCP server de coordinacion de sesiones
**Antipatrones activos:** AP-03 (tool bloat: 15 tools), AP-01 parcial (cleanup polling fijo)
**Hallazgos positivos:**
- Arquitectura bien disenada: sin quadratic growth, context assembly lean
- Session resume sin replay de contexto (SDK mode)
- CLI mode con args minimos
**Hallazgos negativos:**
- 15 MCP tool definitions enviadas en cada ListTools call
- Cleanup polling cada 5 min incluso sin sesiones activas
- Health checker polling 5+ targets cada 30-60s (I/O, no tokens directamente)
- Activity log puede crecer entre persistence saves (cap 100 entries)
- Session timeout default 60 min (dead sessions persisten en memoria)
**Recomendacion:** Combinar tools relacionados, suprimir polling cuando no hay sesiones

### YouTube MCP (30 MB, 70 sesiones)
**Tipo:** MCP server de desarrollo activo
**Antipatrones activos:** AP-03 (63 tool functions), AP-05 (270 lineas de context files), AP-07 (data-heavy sessions)
**Hallazgos:**
- 63 async tool functions registradas en FastMCP (~3600 lineas de server code)
- Context files: CLAUDE.md (117 lineas) + LEARNINGS (54) + TASK_STATE (32) + BACKLOG (67) = 270 lineas cargadas en CADA sesion
- Sesiones de desarrollo leen transcripts completos (37.2h de contenido en DB)
- 10 sesiones/dia durante desarrollo activo, cada una recarga todo el contexto
- Estimacion: ~6000-8000 tokens/sesion de overhead * 70 sesiones = ~420K-560K tokens/semana solo en overhead
**Recomendacion:** Extraer tool docs, archivar learnings viejos, lazy-load artifact generators

### AnyoneAI Sprint 4 (78 MB total, 68 sesiones)
**Tipo:** Proyecto de capacitacion ML (no agente, pero instructivo)
**Antipatrones activos:** AP-07 (data-heavy), AP-08 (notebook bloat)
**Hallazgos:**
- Notebook Jupyter de 4.2 MB / 94K lineas con outputs acumulados (embeddings, plots base64)
- Embeddings CSV de 638 MB leido repetidamente para debugging
- Dataset de 52K productos con 49,689 imagenes
- 57 sesiones en Assignment = workflow iterativo tipico de data science (try-fail-debug-repeat)
- Cada sesion recarga notebook completo + datos + outputs previos
- Consumo NORMAL para ML coursework, no es un antipatron de diseno sino de workflow
**Recomendacion:** Limpiar outputs de notebooks antes de guardar, cargar samples en vez de datasets completos, separar EDA de training

## Nuevos Antipatrones (descubiertos en auditoria)

### AP-07: Data-Heavy Sessions sin Sampling
**Descripcion:** Sesiones que leen datasets completos (CSVs, transcripts, embeddings) en contexto cuando un sample bastaria.
**Impacto:** 1-5 MB por lectura de archivo grande. Multiplicado por N sesiones.
**Caso real:** AnyoneAI leyendo 638 MB embeddings CSV; YouTube MCP procesando transcripts completos.
**Solucion:** Hooks de preprocessing que filtran/sampleen antes de que Claude vea los datos. Cargar head/sample, no el archivo completo.

### AP-08: Notebook Output Accumulation
**Descripcion:** Jupyter notebooks acumulan outputs de ejecuciones anteriores (plots base64, training logs, dataframes renderizados). Cada sesion carga todo.
**Impacto:** Notebooks de 4+ MB cuando el codigo solo son ~100 KB.
**Caso real:** AnyoneAI Sprint 4 con notebook de 94K lineas.
**Solucion:** `jupyter nbconvert --clear-output` antes de trabajar. Separar notebooks de EDA vs training.

### AP-09: Fixed Infrastructure Polling sin Session Awareness
**Descripcion:** Procesos de mantenimiento (cleanup, health checks) que corren a intervalos fijos independientemente de si hay sesiones activas.
**Impacto:** Bajo por iteracion, pero acumulativo 24/7.
**Caso real:** Orchestrator con cleanup cada 5 min + health checks cada 30-60s, incluso con 0 sesiones.
**Solucion:** Suprimir polling cuando no hay sesiones activas. Reactivar al crear primera sesion.

## Antipatrones Identificados (investigacion)

### AP-01: Idle Polling Loop
**Descripcion:** Agente con loop de polling constante que consume tokens en cada iteracion aunque no haya trabajo.
**Impacto:** ~288K tokens/dia en idle (caso Atlas Agent con 30s interval)
**Solucion:** Event-driven architecture (webhooks), adaptive polling (backoff exponencial en idle), sleep mode.

### AP-02: Quadratic Token Growth
**Descripcion:** En conversaciones multi-turn, cada turno re-envia todo el historial. Turn 1 = 200 tokens, Turn 10 = 50x tokens de un single pass.
**Impacto:** Un loop de reflexion de 10 ciclos puede consumir 50x los tokens de una llamada lineal.
**Solucion:** Compactacion agresiva, sliding window, dynamic turn limits.

### AP-03: Context Bloat por MCP Tools
**Descripcion:** Cada MCP server agrega tool definitions al contexto, incluso cuando no se usan.
**Impacto:** Tools idle consumen espacio de contexto en cada mensaje.
**Solucion:** Tool search automatico (deferred loading), CLI tools en vez de MCP cuando sea posible, deshabilitar servers no usados.

### AP-04: Multi-Agent Overhead
**Descripcion:** Sistemas multi-agente consumen 4-15x mas tokens que llamadas simples si no se optimizan.
**Impacto:** Agent teams usan ~7x mas tokens que sesiones estandar.
**Solucion:** Mantener equipos pequenos, tareas focalizadas, limpiar agents idle.

### AP-05: System Prompt Amplification
**Descripcion:** CLAUDE.md grande se carga en cada sesion. Si contiene instrucciones para workflows especificos, esos tokens estan presentes incluso haciendo trabajo no relacionado.
**Impacto:** Proporcional al tamano del CLAUDE.md x cantidad de sesiones.
**Solucion:** Skills on-demand en vez de instrucciones en CLAUDE.md. Mantener CLAUDE.md < 500 lineas.

### AP-06: Unconstrained Agent Iterations
**Descripcion:** Agente sin limite de iteraciones que sigue intentando sin probabilidad de exito.
**Impacto:** $5-8 por tarea para resolver issues de software sin limites.
**Solucion:** Dynamic turn limits basados en probabilidad de exito. Corta costos 24% manteniendo solve rate.

## Patrones de Optimizacion

### PO-01: Prompt Caching
Reduce costos de input ~90% y latencia ~75% reutilizando tokens cacheados. Estructurar contenido estatico en bloques contiguos de >1K tokens.

### PO-02: Semantic Caching
Cache de respuestas LLM con embeddings vectoriales. Queries semanticamente similares obtienen respuestas cacheadas. Hasta 73% reduccion en workloads con alta repeticion.

### PO-03: Dynamic Model Routing
Router que clasifica complejidad y envia a modelo apropiado. Queries simples -> Haiku. Complejas -> Opus. Ahorro 40-50% en costo promedio.

### PO-04: Trajectory Reduction
Eliminar informacion inutil, redundante y expirada de trayectorias de agentes. Reduce input tokens 40-60% sin afectar performance.

### PO-05: Adaptive Polling con Backoff
En vez de polling fijo cada 30s, usar backoff exponencial: 30s -> 1min -> 5min -> 15min cuando no hay actividad. Reset a 30s al recibir mensaje.

### PO-06: Event-Driven sobre Polling
Reemplazar polling por webhooks o event streams. Cero consumo en idle. Solo se activa cuando hay evento real.

### PO-07: Subagent Delegation para Operaciones Verbose
Delegar tests, logs, docs a subagentes. Output verbose queda en contexto del subagente, solo un resumen vuelve al principal.

### PO-08: Preprocessing via Hooks
Hooks que pre-procesan data antes de que Claude la vea. En vez de leer 10K lineas de log, hook filtra y devuelve solo errores.

## Fuentes de Investigacion

### Articulos clave
- Redis Blog: LLM Token Optimization (semantic caching, prompt optimization)
- Stevens Online: Hidden Economics of AI Agents (quadratic growth, reflexion loops)
- Obvious Works: Token Optimization 2026 (80% cost savings)
- Elementor Engineers: Token Optimization in Agent-Based Assistants
- Speakeasy: Reducing MCP Token Usage by 100x (dynamic toolsets)
- Claude Code Docs: Manage Costs Effectively (official best practices)
- ArXiv: Trajectory Reduction for LLM Agent Systems (39-60% input reduction)
- ArXiv: Token-Efficient Framework for Codified Multi-Agent systems

### URLs
- https://redis.io/blog/llm-token-optimization-speed-up-apps/
- https://online.stevens.edu/blog/hidden-economics-ai-agents-token-costs-latency/
- https://www.obviousworks.ch/en/token-optimization-saves-up-to-80-percent-llm-costs/
- https://medium.com/elementor-engineers/optimizing-token-usage-in-agent-based-assistants-ffd1822ece9c
- https://www.speakeasy.com/blog/how-we-reduced-token-usage-by-100x-dynamic-toolsets-v2
- https://code.claude.com/docs/en/costs
- https://arxiv.org/pdf/2509.23586
- https://arxiv.org/pdf/2507.03254
- https://fast.io/resources/ai-agent-token-cost-optimization/
- https://tetrate.io/learn/ai/mcp/token-optimization-strategies

## Alcance del Proyecto

### Fase 1: Auditoria del Ecosistema
- Medir consumo real de tokens por proyecto/agente
- Identificar antipatrones activos en el ecosistema
- Cuantificar desperdicio en tokens y dolares
- Crear scorecard de eficiencia por agente

### Fase 2: Framework de Evaluacion
- Checklist de antipatrones para code review de agentes
- Metricas de eficiencia (tokens utiles vs tokens overhead)
- Herramienta de analisis de logs JSONL para estimar tokens

### Fase 3: Guias de Diseno
- Patrones de diseno token-efficient para agentes
- Decision tree: polling vs event-driven vs hybrid
- Template de arquitectura de agente optimizado
- Integracion con metodologia general (nueva directiva)

### Fase 4: Aplicacion
- Optimizar Atlas Agent (adaptive polling o event-driven)
- Optimizar Claude Orchestrator
- Optimizar YouTube MCP
- Medir mejora post-optimizacion

## Stack
- **Analisis:** Python (pandas, matplotlib para visualizaciones)
- **Datos:** Logs JSONL de Claude Code sessions
- **Output:** Markdown docs, graficos, directivas para metodologia
- **Herramientas:** Scripts de analisis, posible MCP tool para monitoreo

## Criterios de Exito
- Reduccion medible de >30% en consumo de tokens del ecosistema
- Framework de evaluacion aplicable a cualquier agente nuevo
- Al menos 3 agentes existentes optimizados
- Nueva directiva en metodologia general sobre eficiencia de tokens
