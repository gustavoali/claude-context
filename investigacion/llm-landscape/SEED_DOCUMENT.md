# LLM Landscape - Documento Semilla
**Fecha:** 2026-03-13
**Origen:** Alerta #22 del ecosistema + conocimiento propio (sin documento fuente externo)
**Alineado con:** Lectura de Dario Amodei "Machines of Loving Grace"

---

## Vision del Proyecto

Mapeo completo y actualizado del ecosistema de Large Language Models: modelos existentes, frameworks y herramientas, aplicaciones por dominio, y proyecciones a futuro. Un recurso de referencia personal para entender el panorama actual de la IA generativa y tomar decisiones informadas sobre tecnologia, capacitacion y proyectos.

---

## Objetivo

Construir una base de conocimiento estructurada que responda tres preguntas clave:

1. **¿Que existe?** Inventario de modelos LLM por proveedor con capacidades, benchmarks y costos.
2. **¿Que se puede construir?** Catalogo de frameworks, herramientas y plataformas para desarrollar con LLMs.
3. **¿A donde va?** Tendencias, proyecciones y el impacto transformador que describe Amodei en "Machines of Loving Grace".

---

## Alcance

### Dimension 1: Modelos LLM

**Proveedores principales:**
- OpenAI (GPT-4o, GPT-4.1, o3/o4, Reasoning series)
- Anthropic (Claude 3.5/4.x, Opus/Sonnet/Haiku)
- Google (Gemini 2.x Flash/Pro, Gemma 3 open source)
- Meta (Llama 3.x, open weights)
- Mistral AI (Mistral Large, Mixtral, Le Chat)
- xAI (Grok 3)
- Cohere (Command R+)
- AI21 Labs (Jamba)
- 01.AI (Yi series)
- DeepSeek (DeepSeek-V3, R1)

**Dimensiones de comparacion:**
- Capacidades: texto, codigo, vision, audio, video, multimodal
- Benchmarks: MMLU, HumanEval, MATH, GPQA, LiveCodeBench, ELO (Chatbot Arena)
- Contexto: tamano de ventana (4K → 1M+ tokens)
- Costos: input/output por millon de tokens (USD)
- Velocidad: tokens/segundo, TTFT (Time To First Token)
- Open vs Closed: licencias, acceso a pesos
- Modalidades especiales: razonamiento extendido (o3, Claude 3.7 Thinking), function calling, structured outputs

### Dimension 2: Herramientas y Frameworks

**Orquestacion y Agentes:**
- LangChain / LangGraph
- LlamaIndex
- AutoGen (Microsoft)
- CrewAI
- Claude Agent SDK (Anthropic)
- Semantic Kernel (Microsoft)
- Haystack
- Dify

**Plataformas de despliegue:**
- OpenAI API
- Anthropic API
- Google AI Studio / Vertex AI
- AWS Bedrock
- Azure OpenAI
- Groq (inferencia rapida)
- Together AI
- Replicate
- Ollama (local)
- LM Studio (local)

**Bases de datos vectoriales:**
- Pinecone
- Weaviate
- Chroma
- Qdrant
- pgvector (PostgreSQL)
- Milvus

**Evaluacion y Observabilidad:**
- LangSmith
- Weights & Biases
- Arize AI
- Helicone
- Langfuse

**Developer Tools:**
- Claude Code (Anthropic)
- GitHub Copilot
- Cursor
- Aider
- Codeium / Windsurf

### Dimension 3: Aplicaciones por Dominio

| Dominio | Aplicaciones actuales | Potencial segun Amodei |
|---------|----------------------|----------------------|
| Salud | Diagnostico asistido, transcripcion clinica, drug discovery | Comprimir 50 anos de biomedica en 5-10 anos |
| Codigo | Completado, revision, generacion full-stack, debugging | Programadores virtuales autonomos |
| Educacion | Tutores personalizados, generacion de contenido | Profesor de nivel universitario accesible a todos |
| Legal | Redaccion, revision de contratos, investigacion | Democratizacion del acceso a asesoramiento legal |
| Ciencia | Generacion de hipotesis, analisis de papers, laboratorio virtual | Aceleracion del ritmo de descubrimiento cientifico |
| Entretenimiento | Generacion de guiones, personajes, mundos | Creatividad aumentada, nuevos formatos |
| Finanzas | Analisis, reportes, asistentes personales | Asesoramiento financiero democratizado |
| Productividad | Emails, resumen de documentos, asistentes personales | Eliminacion del trabajo de bajo valor |

### Dimension 4: Proyeccion a Futuro

**Tendencias de scaling:**
- Scaling laws: compute, datos, parametros
- Post-training: RLHF, RLAIF, Constitutional AI
- Inference-time compute: razonamiento extendido (o3, Claude Thinking)
- Multimodalidad nativa: texto + vision + audio + video + herramientas

**Tendencias economicas:**
- Caida del costo de inferencia: -10x por ano historicamente
- Commoditizacion de modelos base vs diferenciacion en fine-tuning/RAG
- Open weights (Llama, Mistral, Gemma) presionando costos

**Agentes autonomos:**
- De asistentes a agentes: completar tareas de larga duracion
- Multi-agent systems: equipos de agentes especializados
- Computer use: agentes que controlan interfaces graficas
- Tool use generalizado: agentes que usan APIs reales

**Impacto transformador (segun Amodei):**
- "Machines of Loving Grace": IA como herramienta de compresion del progreso humano
- Salud: cura de enfermedades tratadas como problemas de ingenieria
- Pobreza: acceso democratico a experticia de alto nivel
- Ciencia: aceleracion del descubrimiento en biologia, fisica, quimica
- Riesgos: alineamiento, concentracion de poder, mal uso

---

## Estructura del Repositorio

```
llm-landscape/
  README.md
  models/
    providers/           # Un archivo por proveedor
      openai.md
      anthropic.md
      google.md
      meta.md
      mistral.md
      ...
    benchmarks/          # Comparativas entre modelos
      capability-matrix.md
      cost-comparison.md
      benchmark-scores.md
    open-vs-closed.md    # Analisis open weights vs propietario
  frameworks/
    orchestration/       # LangChain, AutoGen, CrewAI, etc.
    deployment/          # APIs, plataformas cloud, local
    vector-stores/       # Bases de datos vectoriales
    eval-observability/  # LangSmith, W&B, etc.
    developer-tools/     # Claude Code, Copilot, Cursor, etc.
  applications/
    by-domain/           # Una entrada por dominio de aplicacion
    case-studies/        # Casos de uso concretos
  futures/
    scaling-trends.md    # Tendencias de scaling y compute
    agentic-systems.md   # Agentes autonomos, multi-agent
    economic-trends.md   # Costos, commoditizacion, open source
    amodei-essay.md      # Analisis de "Machines of Loving Grace"
    timeline.md          # Hitos pasados y proyecciones
  reading_notes/         # Notas de papers y articulos
  resources/
    glossary.md          # Glosario tecnico
    links.md             # Links de referencia curados
```

---

## Stack

- Formato: Markdown puro (sin codigo ejecutable inicialmente)
- Lenguaje opcional: Python para scripts de actualizacion de precios/benchmarks
- Sin dependencias externas en la primera fase

---

## Criterios de Exito

1. Poder responder en < 2 min: "¿Cual es el mejor modelo para tarea X con presupuesto Y?"
2. Comparativa de costos actualizada con precios reales de API
3. Analisis de "Machines of Loving Grace" integrado con el estado actual
4. Base para tomar decisiones en proyectos del ecosistema (que modelo usar, que framework)

---

## Fases de Construccion

### Fase 1: Inventario de Modelos (semana 1-2)
- Mapear proveedores principales con fichas por modelo
- Comparativa de costos y benchmarks
- Tabla de capacidades multimodales

### Fase 2: Ecosistema de Herramientas (semana 3-4)
- Catalogo de frameworks de orquestacion
- Guia de plataformas de deployment
- Comparativa de vector stores

### Fase 3: Aplicaciones y Casos de Uso (semana 5-6)
- Mapeo por dominio
- Casos de uso concretos con modelos recomendados

### Fase 4: Proyeccion y Analisis (semana 7-8)
- Analisis de tendencias
- Resena de "Machines of Loving Grace"
- Timeline de hitos y proyecciones

---

## Notas Contextuales

- Este proyecto es un recurso personal de investigacion, no un producto de software.
- Se actualiza de forma continua a medida que el ecosistema evoluciona.
- Sirve como input para decisiones tecnicas en otros proyectos del ecosistema.
- Complementa la lectura de AI Futures Research (`pj af`).
