# Backlog - LLM Landscape
**Version:** 1.0.0 | **Actualizacion:** 2026-03-16

## Resumen
| Metrica | Valor |
|---------|-------|
| Total stories | 30 |
| Total puntos | 82 |
| Historias completadas | 30 |
| Proxima sesion | Revision de calidad + reading_notes |

## Vision
Mapeo completo del ecosistema LLM: modelos, frameworks, aplicaciones y proyecciones. Recurso de referencia para responder "que modelo usar para X con presupuesto Y" en menos de 2 minutos, y base para decisiones tecnicas en proyectos del ecosistema.

## Epics
| Epic | Descripcion | Stories | Puntos | Fase |
|------|-------------|---------|--------|------|
| EPIC-1 | Inventario de Modelos | LLM-001 a LLM-008 | 24 | Fase 1 |
| EPIC-2 | Ecosistema de Herramientas | LLM-011 a LLM-016 | 18 | Fase 2 |
| EPIC-3 | Aplicaciones por Dominio | LLM-021 a LLM-024 | 14 | Fase 3 |
| EPIC-4 | Proyeccion y Analisis | LLM-031 a LLM-035 | 17 | Fase 4 |
| EPIC-5 | Infraestructura del Repositorio | LLM-041 a LLM-043 | 9 | Transversal |

## Stories Pendientes

### EPIC-1: Inventario de Modelos (Fase 1)

#### LLM-001: Ficha de proveedor OpenAI
**Points:** 3 | **Priority:** Critical
**As a** investigador del ecosistema LLM **I want** ficha completa del portfolio de OpenAI **So that** pueda consultar capacidades, precios y modelos activos rapidamente
**AC1:** Given `models/providers/openai.md`, When la consulto, Then contiene todos los modelos activos (GPT-4o, GPT-4.1, o3, o4-mini) con precios, contexto y modalidades
**AC2:** Given modelos legacy, When reviso, Then aparecen en seccion separada sin detalle excesivo
**AC3:** Given "Capacidades Distintivas", When la leo, Then identifica fortalezas unicas vs competencia
**Tech:** Template "Ficha de Proveedor LLM" (ARCHITECTURE_ANALYSIS.md). Fuente de precios: openai.com/pricing.

#### LLM-002: Ficha de proveedor Anthropic
**Points:** 3 | **Priority:** Critical
**As a** investigador **I want** ficha completa de Anthropic **So that** pueda consultar capacidades y diferenciadores de Claude
**AC1:** Given `models/providers/anthropic.md`, When la consulto, Then contiene Claude 4.x (Opus, Sonnet, Haiku) con precios, contexto y modalidades
**AC2:** Given experiencia propia con Claude Code, When reviso "Notas y Observaciones", Then incluye insights de uso real
**AC3:** Given razonamiento extendido (Thinking), When lo busco, Then esta documentado como capacidad distintiva
**Tech:** Template "Ficha de Proveedor LLM". Incluir experiencia propia con Claude Code.

#### LLM-003: Ficha de proveedor Google
**Points:** 3 | **Priority:** Critical
**As a** investigador **I want** ficha de Google (Gemini, Gemma) **So that** pueda evaluar opciones propietarias y open source
**AC1:** Given `models/providers/google.md`, When la consulto, Then cubre Gemini 2.x y Gemma 3 con sus diferencias
**AC2:** Given modelos propietarios y open source, When reviso, Then ambas lineas documentadas con trade-offs
**Tech:** Template "Ficha de Proveedor LLM". Cubrir Google AI Studio y Vertex AI.

#### LLM-004: Ficha de proveedor Meta (Llama)
**Points:** 2 | **Priority:** High
**As a** investigador **I want** ficha del portfolio open weights de Meta **So that** pueda evaluar Llama como alternativa open source
**AC1:** Given `models/providers/meta.md`, When la consulto, Then cubre Llama 3.x con variantes, licencia y opciones de deployment
**AC2:** Given que es open weights, When reviso, Then documenta opciones de hosting (Ollama, Together, Replicate)
**Tech:** Template "Ficha de Proveedor LLM". Enfasis en licencia y self-hosting.

#### LLM-005: Fichas de proveedores secundarios (Mistral, xAI, DeepSeek, Cohere, AI21, 01.AI)
**Points:** 5 | **Priority:** Medium
**As a** investigador **I want** fichas de los 6 proveedores secundarios **So that** el inventario este completo
**AC1:** Given cada proveedor, When creo ficha en `models/providers/`, Then cada una sigue template con overview, modelos activos, precios, diferenciadores
**AC2:** Given 6 proveedores, When completo, Then existen: `mistral.md`, `xai.md`, `deepseek.md`, `cohere.md`, `ai21.md`, `01ai.md`
**Tech:** Template "Ficha de Proveedor LLM". Fichas compactas; foco en diferenciadores unicos.

#### LLM-006: Tabla de benchmark scores
**Points:** 3 | **Priority:** Critical
**As a** investigador **I want** tabla centralizada de benchmarks **So that** pueda comparar capacidades objetivas entre modelos
**AC1:** Given `models/benchmarks/benchmark-scores.md`, When lo consulto, Then tiene scores de top 10 modelos en MMLU, HumanEval, MATH, GPQA y Arena ELO
**AC2:** Given cada score, When verifico fuente, Then tiene fecha de medicion y referencia al leaderboard
**Tech:** Template "Benchmarks" (ARCHITECTURE_ANALYSIS.md). Fuentes: LMSYS Chatbot Arena, OpenLLM Leaderboard.

#### LLM-007: Comparativa de costos de APIs
**Points:** 3 | **Priority:** Critical
**As a** investigador **I want** tabla centralizada de precios de APIs **So that** pueda responder "modelo mas barato para tarea X"
**AC1:** Given `models/benchmarks/cost-comparison.md`, When lo consulto, Then tiene precios in/out por 1M tokens de al menos 15 modelos
**AC2:** Given "Costo estimado por caso de uso", When consulto, Then incluye 5+ escenarios (chatbot, RAG, code gen, summarization, classification)
**AC3:** Given precios, When verifico, Then corresponden a paginas oficiales con fecha de consulta
**Tech:** Template "cost-comparison.md" (ARCHITECTURE_ANALYSIS.md). Precios de paginas oficiales.

#### LLM-008: Matriz de capacidades multimodales
**Points:** 2 | **Priority:** High
**As a** investigador **I want** matriz de capacidades por modelo **So that** pueda filtrar modelos por capacidad requerida
**AC1:** Given `models/benchmarks/capability-matrix.md`, When consulto, Then tiene 15+ modelos con: Texto, Codigo, Vision, Audio, Video, Tools, Structured Output, Reasoning
**AC2:** Given cada celda, When la leo, Then indica S/N/Parcial con nota si es "Parcial"
**Tech:** Template "capability-matrix.md" (ARCHITECTURE_ANALYSIS.md).

### EPIC-2: Ecosistema de Herramientas (Fase 2)

#### LLM-011: Catalogo de frameworks de orquestacion
**Points:** 5 | **Priority:** High
**As a** investigador **I want** fichas de frameworks de orquestacion **So that** pueda elegir el adecuado por proyecto
**AC:** Fichas en `frameworks/orchestration/` para: LangChain/LangGraph, LlamaIndex, AutoGen, CrewAI, Claude Agent SDK, Semantic Kernel, Haystack, Dify. Cada una con "Cuando usarlo" y "Cuando NO usarlo". Template "Ficha de Framework/Herramienta".

#### LLM-012: Catalogo de plataformas de deployment
**Points:** 3 | **Priority:** High
**As a** investigador **I want** fichas de plataformas de deployment **So that** pueda decidir donde desplegar segun costo y latencia
**AC:** Fichas en `frameworks/deployment/` para: OpenAI API, Anthropic API, Vertex AI, AWS Bedrock, Azure OpenAI, Groq, Together AI, Ollama, LM Studio. Separar cloud vs local. Template de framework.

#### LLM-013: Comparativa de vector stores
**Points:** 3 | **Priority:** Medium
**As a** investigador **I want** fichas de vector stores **So that** pueda elegir el adecuado para proyectos RAG
**AC:** Fichas en `frameworks/vector-stores/` para: Pinecone, Weaviate, Chroma, Qdrant, pgvector, Milvus. pgvector relevante para proyectos propios (PG en Docker).

#### LLM-014: Catalogo de herramientas de eval y observabilidad
**Points:** 2 | **Priority:** Medium
**As a** investigador **I want** fichas de eval/observabilidad **So that** pueda monitorear calidad de apps LLM
**AC:** Fichas en `frameworks/eval-observability/` para: LangSmith, W&B, Arize AI, Helicone, Langfuse. Relevante para Agent Token Economics.

#### LLM-015: Catalogo de developer tools para LLM
**Points:** 3 | **Priority:** High
**As a** investigador **I want** fichas de developer tools **So that** pueda comparar coding assistants
**AC:** Fichas en `frameworks/developer-tools/` para: Claude Code, GitHub Copilot, Cursor, Aider, Codeium/Windsurf. Claude Code con experiencia propia extensa.

#### LLM-016: Analisis open weights vs propietario
**Points:** 2 | **Priority:** Medium
**As a** investigador **I want** analisis open vs closed **So that** pueda decidir cuando usar cada tipo
**AC:** `models/open-vs-closed.md` comparando: costo total, control, privacidad, capacidad, latencia, mantenimiento. Guia por escenario (startup, enterprise, hobby). Cruzar con LLM-007 y LLM-008.

### EPIC-3: Aplicaciones por Dominio (Fase 3)

#### LLM-021: Aplicaciones LLM en codigo y desarrollo de software
**Points:** 3 | **Priority:** High
**As a** investigador **I want** mapeo de LLMs en desarrollo de software **So that** pueda evaluar herramientas para mi flujo
**AC:** `applications/by-domain/coding.md` cubriendo: code completion, review, debugging, test gen, docs, full-stack gen. Modelos recomendados por tarea con justificacion. Experiencia propia integrada. Template "Ficha de Aplicacion por Dominio".

#### LLM-022: Aplicaciones LLM en salud y ciencia
**Points:** 3 | **Priority:** Medium
**As a** investigador **I want** mapeo de LLMs en salud y ciencia **So that** entienda el potencial transformador de Amodei
**AC:** `applications/by-domain/healthcare.md` cubriendo: diagnostico, drug discovery, transcripcion, papers. Conectar con vision de Amodei.

#### LLM-023: Aplicaciones LLM en educacion, legal y finanzas
**Points:** 3 | **Priority:** Medium
**As a** investigador **I want** fichas para educacion, legal y finanzas **So that** tenga panorama de dominios de alto impacto
**AC:** 3 archivos en `applications/by-domain/`: `education.md`, `legal.md`, `finance.md`. Al menos 3 aplicaciones existentes con modelos usados por ficha.

#### LLM-024: Aplicaciones LLM en productividad y entretenimiento
**Points:** 5 | **Priority:** Low
**As a** investigador **I want** fichas para productividad y entretenimiento **So that** el catalogo de dominios este completo
**AC:** `applications/by-domain/productivity.md` y `entertainment.md`. Diferenciar apps genericas de especializadas.

### EPIC-4: Proyeccion y Analisis (Fase 4)

#### LLM-031: Analisis de "Machines of Loving Grace" de Amodei
**Points:** 5 | **Priority:** High
**As a** investigador **I want** analisis estructurado del ensayo de Amodei **So that** tenga marco de referencia para el futuro del ecosistema
**AC:** `futures/amodei-essay.md` con: resumen, ideas clave por dominio, analisis critico propio. Conectar "donde estamos" con "a donde dice Amodei que vamos". Template "Reading Notes" extendido.

#### LLM-032: Tendencias de scaling y compute
**Points:** 3 | **Priority:** Medium
**As a** investigador **I want** analisis de tendencias de scaling **So that** entienda fuerzas que impulsan el progreso
**AC:** `futures/scaling-trends.md` cubriendo: scaling laws, post-training (RLHF/RLAIF), inference-time compute, multimodalidad. Datos cuantitativos.

#### LLM-033: Sistemas agenticos y multi-agente
**Points:** 3 | **Priority:** High
**As a** investigador **I want** analisis de sistemas agenticos **So that** pueda evaluar oportunidades para Orchestrator y Atlas
**AC:** `futures/agentic-systems.md` cubriendo: agentes autonomos, multi-agent, computer use, tool use. Conexion con proyectos propios.

#### LLM-034: Tendencias economicas del ecosistema LLM
**Points:** 3 | **Priority:** Medium
**As a** investigador **I want** analisis de tendencias economicas **So that** pueda anticipar cambios en pricing
**AC:** `futures/economic-trends.md` cubriendo: caida de costos, commoditizacion, open weights, modelos de negocio. Cruzar con LLM-007.

#### LLM-035: Timeline de hitos y proyecciones
**Points:** 3 | **Priority:** Low
**As a** investigador **I want** timeline de hitos pasados y proyecciones **So that** tenga perspectiva historica del ritmo de avance
**AC:** `futures/timeline.md` desde GPT-3 (2020) al presente. Proyecciones marcadas como [PROYECCION] con fuente.

### EPIC-5: Infraestructura del Repositorio

#### LLM-041: README del repositorio
**Points:** 2 | **Priority:** High
**As a** consultor del repositorio **I want** README como punto de entrada **So that** pueda navegar al recurso correcto en <30 seg
**AC:** `README.md` con: descripcion, estructura de carpetas con links, guia de consulta, estado de completitud por fase. Generar post-Fase 1.

#### LLM-042: Glosario tecnico del ecosistema LLM
**Points:** 3 | **Priority:** Medium
**As a** consultor **I want** glosario de terminos tecnicos **So that** pueda consultar definiciones sin salir del repo
**AC:** `resources/glossary.md` con 40+ terminos organizados A-Z. Construir incrementalmente con cada fase.

#### LLM-043: Links de referencia curados
**Points:** 4 | **Priority:** Low
**As a** consultor **I want** lista curada de links por tema **So that** tenga acceso rapido a fuentes confiables
**AC:** `resources/links.md` organizado por categoria (leaderboards, pricing, papers, blogs, cursos). Todos verificados como activos.

## Completadas (indice)
| ID | Titulo | Puntos | Fecha |
|----|--------|--------|-------|
| LLM-001 | Ficha proveedor OpenAI | 3 | 2026-03-16 |
| LLM-002 | Ficha proveedor Anthropic | 3 | 2026-03-16 |
| LLM-003 | Ficha proveedor Google | 3 | 2026-03-16 |
| LLM-004 | Ficha proveedor Meta | 2 | 2026-03-16 |
| LLM-005 | Fichas proveedores secundarios (6) | 5 | 2026-03-16 |
| LLM-006 | Benchmark scores | 3 | 2026-03-16 |
| LLM-007 | Comparativa de costos | 3 | 2026-03-16 |
| LLM-008 | Capability matrix | 2 | 2026-03-16 |
| LLM-011 | Frameworks de orquestacion (8) | 5 | 2026-03-16 |
| LLM-012 | Plataformas de deployment (9) | 3 | 2026-03-16 |
| LLM-013 | Vector stores (6) | 3 | 2026-03-16 |
| LLM-014 | Eval y observabilidad (5) | 2 | 2026-03-16 |
| LLM-015 | Developer tools (5) | 3 | 2026-03-16 |
| LLM-016 | Open weights vs propietario | 2 | 2026-03-16 |
| LLM-021 | Aplicaciones en coding | 3 | 2026-03-16 |
| LLM-022 | Aplicaciones en salud y ciencia | 3 | 2026-03-16 |
| LLM-023 | Aplicaciones en educacion, legal, finanzas | 3 | 2026-03-16 |
| LLM-024 | Aplicaciones en productividad y entretenimiento | 5 | 2026-03-16 |
| LLM-031 | Analisis Amodei essay | 5 | 2026-03-16 |
| LLM-032 | Scaling trends | 3 | 2026-03-16 |
| LLM-033 | Agentic systems | 3 | 2026-03-16 |
| LLM-034 | Economic trends | 3 | 2026-03-16 |
| LLM-035 | Timeline LLM | 3 | 2026-03-16 |
| LLM-041 | README del repositorio | 2 | 2026-03-16 |
| LLM-042 | Glosario tecnico (50 terminos) | 3 | 2026-03-16 |
| LLM-043 | Links de referencia curados | 4 | 2026-03-16 |

## ID Registry
| Rango | Status |
|-------|--------|
| LLM-001 a LLM-008 | Fase 1 - Modelos |
| LLM-009 a LLM-010 | Reservado Fase 1 |
| LLM-011 a LLM-016 | Fase 2 - Frameworks |
| LLM-017 a LLM-020 | Reservado Fase 2 |
| LLM-021 a LLM-024 | Fase 3 - Aplicaciones |
| LLM-025 a LLM-030 | Reservado Fase 3 |
| LLM-031 a LLM-035 | Fase 4 - Futuro |
| LLM-036 a LLM-040 | Reservado Fase 4 |
| LLM-041 a LLM-043 | Infraestructura |
| LLM-044 a LLM-050 | Reservado Infraestructura |
Proximo ID: LLM-044
