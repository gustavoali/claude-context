# Análisis OpenViking - Hallazgos y Ideas para claude_context
**Fecha:** 2026-03-24 | **Versión:** 1.0
**Repo:** github.com/AnyoneClown/openviking (ByteDance)

---

## 1. Qué es OpenViking

Base de datos de contexto para agentes AI. Reemplaza pipelines RAG fragmentados con un
sistema unificado que organiza contexto como un filesystem virtual (URIs tipo `viking://scope/path`).

**Stack:** Python 3.10+ (core), Rust (CLI), Go (AGFS storage), C++ (extensions)

**Resultado medido:** 52% task completion (vs 35% baseline) con 91% reducción de tokens.

---

## 2. Patrones Clave

### 2.1 Tiered Loading (L0/L1/L2)

Modelo de 3 capas para balancear eficiencia y completitud:

| Capa | Archivo | Tokens | Propósito |
|------|---------|--------|-----------|
| **L0** | `.abstract.md` | ~100 | Vector search, filtrado rápido |
| **L1** | `.overview.md` | ~2K | Rerank, navegación de contenido |
| **L2** | Archivos originales | Ilimitado | Contenido completo, bajo demanda |

**Generación:** Bottom-up (hojas -> padres -> raíz). Los abstracts de hijos se agregan
en el overview del padre, formando navegación jerárquica.

**Diseño clave:** Parsing y semántica están separados. El parser NO llama al LLM;
la generación semántica es async (SemanticQueue).

### 2.2 Retrieval Jerárquico (Intent -> Search -> Rerank)

Búsqueda en 3 etapas:

1. **Intent Analysis (LLM):** Analiza query + contexto de sesión, genera 0-5 TypedQueries
   con tipo (memory/resource/skill) y prioridad
2. **Hierarchical Retrieval:** Priority queue que explora directorios recursivamente
   - Score propagation: `0.5 * embedding_score + 0.5 * parent_score`
   - Convergencia: para después de 3 rondas sin cambios en topk
3. **Rerank:** LLM refina scoring de candidatos

**Insight clave:** La búsqueda NO es flat (como RAG tradicional). Navega la jerarquía
de directorios, propagando scores del padre a los hijos. Esto permite encontrar
contenido relevante sin vectorizar TODO el contenido (solo L0).

### 2.3 Session Management y Memory Extraction

Lifecycle: Create -> Interact -> Commit

Al hacer `commit()`:
1. Incrementa compression_index
2. Copia mensajes al archivo (archive_NNN/)
3. Genera summary estructurado (LLM)
4. Limpia mensajes actuales
5. **Extrae memorias** en 6 categorías:

| Categoría | Owner | Mergeable | Descripción |
|-----------|-------|-----------|-------------|
| profile | user | Si | Identidad, atributos |
| preferences | user | Si | Preferencias del usuario |
| entities | user | Si | Personas, proyectos |
| events | user | No | Eventos, decisiones |
| cases | agent | No | Problema + solución |
| patterns | agent | Si | Patrones reutilizables |

**Dedup flow:** Candidatos -> Vector pre-filter -> LLM decide (skip/create/merge/delete)

### 2.4 URI System (viking://)

6 scopes con semántica clara:

```
viking://resources/   # Recursos independientes (proyectos, docs)
viking://user/        # Datos del usuario (perfil, preferencias, entidades)
viking://agent/       # Datos del agente (skills, memorias, instrucciones)
viking://session/     # Datos transitorios de sesión
viking://queue/       # Cola de procesamiento (interno)
viking://temp/        # Archivos temporales (durante parsing)
```

### 2.5 Code Skeleton Extraction (AST Mode)

Para archivos de código, usa tree-sitter para extraer esqueleto estructural
(imports, clases, signatures) SIN llamar al LLM. Soporta Python, JS/TS, Rust, Go, Java, C/C++.

3 modos: `ast` (default, sin LLM), `llm` (siempre LLM), `ast_llm` (AST + LLM refine).

---

## 3. Analogías con claude_context

| OpenViking | claude_context | Similitud | Gap |
|------------|----------------|-----------|-----|
| L0 (.abstract.md, ~100 tokens) | CLAUDE.md (max 150 líneas) | Alta | Nuestro L0 es más grande, no auto-generado |
| L1 (.overview.md, ~2K tokens) | TASK_STATE / BACKLOG | Media | No tenemos overview auto-generado por directorio |
| L2 (archivos originales) | archive/ + archivos fuente | Alta | Equivalente funcional |
| Session compression | /close-session + observation masking | Alta | Nuestro es manual, el de ellos es automático |
| Memory extraction (6 cats) | Auto-memory de Claude Code | Media | Ellos categorizan formalmente, nosotros es free-form |
| Retrieval trajectory | Directiva 12d (observabilidad) | Baja | Nosotros no logueamos qué contexto se cargó |
| URI system (viking://) | Paths del filesystem (C:/claude_context/) | Media | Nosotros usamos paths reales, no virtuales |
| Vector index | Grep + Glob | Baja | No tenemos búsqueda semántica |
| Intent analysis pre-retrieval | No existe | Nula | Cargamos todo el contexto siempre |
| Score propagation jerárquico | No existe | Nula | No tenemos scoring de relevancia |
| Bottom-up L0/L1 generation | Manual (escritura humana/Claude) | Baja | No auto-generamos resúmenes |
| AST skeleton extraction | No existe | Nula | No resumimos código automáticamente |

---

## 4. Ideas Accionables para claude_context

### 4.1 ADOPTAR (alto valor, bajo esfuerzo)

#### IDEA-A1: Formalizar categorías de memoria
Nuestro auto-memory es free-form. OpenViking usa 6 categorías con semántica clara.
Podríamos formalizar nuestras categorías (ya tenemos user, feedback, project, reference)
y agregar `cases` (problema + solución) y `patterns` (patrones reutilizables).

**Acción:** Revisar si las categorías de auto-memory de Claude Code cubren el mismo espacio.
Considerar agregar `cases` para debugging recurrente.

#### IDEA-A2: Observation masking mejorado con formato de summary
OpenViking genera summaries estructurados al comprimir sesiones:
```
One-line overview: [Topic]: [Intent] | [Result] | [Status]
Analysis: Key steps
Primary Request: Core goal
Key Concepts: Technical concepts
Pending Tasks: Unfinished
```
Nuestro observation masking (directiva 1b) es ad-hoc. Podríamos formalizar el formato.

**Acción:** Actualizar template de TASK_STATE "Sesión Activa" con formato structured summary.

#### IDEA-A3: Log de retrieval trajectory
OpenViking tiene DebugService/observer para ver qué consultó el agente.
Nosotros no logueamos qué archivos de contexto se cargaron ni cuáles fueron útiles.

**Acción:** Crear mecanismo para registrar qué archivos se cargaron al inicio de sesión
y cuáles se referenciaron realmente. Podría ser un campo en TASK_STATE o un hook.

### 4.2 ADAPTAR (alto valor, esfuerzo medio)

#### IDEA-B1: Auto-generación de L0 (abstracts) para directorios de contexto
OpenViking genera `.abstract.md` automáticamente para cada directorio.
Nosotros escribimos CLAUDE.md manualmente. Podríamos crear un script/hook que
genere un abstract de cada directorio de proyecto en claude_context/.

**Acción:** Script que recorra claude_context/[clasificador]/[proyecto]/ y genere
un one-liner por proyecto. Alimentaría un índice global para búsqueda rápida.

#### IDEA-B2: Intent-based context loading
OpenViking analiza el intent ANTES de recuperar contexto.
Nosotros cargamos TODO el contexto del proyecto (CLAUDE.md + @imports) sin filtrar.
Para proyectos grandes, esto desperdicia tokens.

**Acción:** Investigar si podemos implementar carga condicional basada en la tarea.
Ej: si la tarea es "fix bug en auth", cargar solo los docs relevantes a auth.
Limitación: Claude Code carga @imports automáticamente, no tenemos control fino.

#### IDEA-B3: Dedup de memorias con vector pre-filter
OpenViking hace vector search ANTES de decidir si una memoria es duplicada.
Nuestro auto-memory depende de que Claude "recuerde" si ya guardó algo similar.

**Acción:** Evaluar si podemos agregar un paso de dedup al guardar memorias de proyecto.
Podría ser un grep del contenido de MEMORY.md antes de escribir.

### 4.3 INVESTIGAR (valor potencial alto, requiere más análisis)

#### IDEA-C1: Filesystem virtual para contexto
OpenViking abstrae todo detrás de URIs (viking://). Esto permite operaciones
uniformes (ls, tree, grep, mv) sin importar el backend de storage.
Nosotros dependemos del filesystem real de Windows, lo cual funciona pero
no permite operaciones como "buscar en todo el contexto" fácilmente.

**Acción:** Evaluar si un MCP server de contexto (similar a project-admin pero
con búsqueda semántica) agregaría valor. Costo: alto. Beneficio: depende del scale.

#### IDEA-C2: Score propagation para priorizar contexto
El algoritmo de `0.5 * embedding + 0.5 * parent_score` es elegante para
navegar jerarquías grandes. Si nuestro claude_context crece mucho, podríamos
necesitar algo similar para decidir qué cargar.

**Acción:** No implementar ahora. Anotar como patrón para cuando tengamos >50 proyectos.

#### IDEA-C3: AST skeleton para contexto de código
Generar resúmenes de código via tree-sitter sin LLM. Útil para proyectos grandes
donde el agente necesita entender la estructura sin leer todo el código.

**Acción:** Evaluar si esto complementa nuestro uso de `Explore` agent.
El Explore agent ya hace algo similar pero on-demand, no pre-computed.

---

## 5. Comparación de Diseño: Filosofías

| Aspecto | OpenViking | claude_context |
|---------|------------|----------------|
| **Storage** | Base de datos (vector + FS virtual) | Archivos planos en disco |
| **Búsqueda** | Semántica (embeddings + rerank) | Textual (grep + glob) |
| **Generación de resúmenes** | Automática (LLM async) | Manual (Claude + usuario) |
| **Compresión de sesión** | Automática al commit | Semi-manual (/close-session) |
| **Escalabilidad** | Diseñado para miles de recursos | Diseñado para ~20-50 proyectos |
| **Complejidad** | Alta (requiere LLM + vector DB + AGFS) | Baja (solo archivos + convenciones) |
| **Costo operativo** | Alto (embeddings + LLM calls constantes) | Bajo (sin infra adicional) |
| **Latencia** | ms (pre-computed) | Inmediata (carga directa) |
| **Vendor lock-in** | Volcengine (ByteDance) primary | Ninguno |

**Conclusión:** OpenViking resuelve un problema de escala enterprise (miles de recursos,
múltiples agentes, equipos). Nuestra infra es para 1 developer con ~20-50 proyectos.
No necesitamos la complejidad de OpenViking, pero sus PATRONES de diseño
(tiered loading, intent analysis, memory categorization) son valiosos como inspiración.

---

## 6. Métricas de OpenViking

- **Task completion:** 52.08% vs 35.65% baseline (+46% mejora relativa)
- **Token reduction:** 91% menos tokens consumidos
- **Benchmark:** SWE-bench coding tasks

---

## 7. Deep Dive: Algoritmos Core

### 7.1 Hierarchical Retriever - Algoritmo Detallado

**Archivo:** `openviking/retrieve/hierarchical_retriever.py`

**Constantes clave:**
- `SCORE_PROPAGATION_ALPHA = 0.5` (50% embedding + 50% parent score)
- `MAX_CONVERGENCE_ROUNDS = 3` (para si topk no cambia en 3 rondas)
- `GLOBAL_SEARCH_TOPK = 5` (candidatos iniciales)
- `HOTNESS_ALPHA = 0.2` (80% semántico + 20% recencia/frecuencia)

**Algoritmo:**
1. Generar vector de la query (dense + sparse)
2. Búsqueda global → top 5 entry points
3. Separar archivos L2 (hits directos) de directorios (para recursión)
4. Priority queue (max-heap por score):
   - Pop directorio con mayor score
   - Buscar hijos en vector index
   - Para cada hijo: `score = 0.5 * vector_score + 0.5 * parent_score`
   - Si supera threshold y NO es hoja → push a la queue
   - Convergencia: si topk no cambió en 3 rondas → stop
5. Hotness boost final: `(1 - 0.2) * semantic + 0.2 * hotness(frequency, recency)`

**Hotness score:** `sigmoid(log1p(access_count)) * exp(-decay * age_days)` con half-life 7 días.

**Insight para nosotros:** El score propagation es simple pero efectivo. Si alguna vez
necesitamos buscar en claude_context/ (>50 proyectos), este patrón de "explorar
directorios con herencia de score" es adoptable sin vector DB.

### 7.2 Memory Extraction Pipeline - Compressor

**Archivo:** `openviking/session/compressor.py` (SessionCompressor)

**Pipeline completo:**
```
Messages → [1] Extract (LLM, 6+2 categorías) → Candidates
  → [2a] Profile? → siempre merge (sin dedup)
  → [2b] Tool/Skill? → merge por nombre (determinístico)
  → [2c] Otros? → Vector pre-filter → LLM dedup decision
  → [3] Apply (create/merge/delete)
  → [4] Index (chunk + vectorize)
  → [5] Queue semantic regeneration (L0/L1)
```

**8 categorías reales** (no 6 como dice la doc):

| Categoría | Owner | Mergeable | Storage |
|-----------|-------|-----------|---------|
| profile | user | Si (siempre) | `memories/profile.md` (singleton) |
| preferences | user | Si | `memories/preferences/` |
| entities | user | Si | `memories/entities/` |
| events | user | No | `memories/events/` |
| cases | agent | No | `memories/cases/` |
| patterns | agent | Si | `memories/patterns/` |
| tools | agent | Si | `memories/tools/` (por nombre) |
| skills | agent | Si | `memories/skills/` (por nombre) |

**Dedup flow (MemoryDeduplicator):**
1. Embed candidate (abstract + content)
2. Vector search en categoría → top 5 similares
3. Check batch-internal (evita duplicados en misma extracción)
4. LLM decide: SKIP (duplicado) / CREATE (nuevo) / NONE (solo modificar existentes)
5. Per-existing actions: MERGE (incorporar) o DELETE (conflicto)

**Chunking:** Memorias largas se dividen en chunks con overlap, cada chunk
tiene su propio vector. Break preferido en párrafos (\n\n).

### 7.3 Memory Updater - Operaciones Mecánicas

**Archivo:** `openviking/session/memory/memory_updater.py`

4 operaciones: WRITE, EDIT, EDIT_OVERVIEW, DELETE

**3 estrategias de merge por campo:**
- **PATCH:** Para strings, usa SEARCH/REPLACE blocks
- **SUM:** Para numéricos, suma al valor actual
- **IMMUTABLE:** Una vez seteado, no cambia (created_at)

**Insight para nosotros:** La separación entre "razonar" (LLM) y "ejecutar" (updater)
es limpia. Nuestro auto-memory hace ambas cosas en un paso. El pattern de merge ops
es interesante para memorias que evolucionan (ej: perfil del usuario).

---

## 8. Evaluación de Ideas para Implementar

### Criterios de Evaluación

| Criterio | Peso |
|----------|------|
| Valor inmediato para productividad | 40% |
| Esfuerzo de implementación | 30% |
| Riesgo de romper algo existente | 20% |
| Alineación con dirección futura | 10% |

### Ranking Final

| # | Idea | Valor | Esfuerzo | Riesgo | Score |
|---|------|-------|----------|--------|-------|
| 1 | A2: Structured summary format | Alto | Bajo | Nulo | 9/10 |
| 2 | A3: Retrieval trajectory log | Medio-Alto | Bajo | Nulo | 8/10 |
| 3 | A1: Formalizar categorías memoria | Alto | Bajo-Medio | Bajo | 7/10 |
| 4 | B1: Auto-generación abstracts | Alto | Medio | Bajo | 6/10 |
| 5 | B2: Intent-based loading | Alto | Medio-Alto | Medio | 5/10 |
| 6 | C1: Filesystem virtual MCP | Alto | Alto | Medio | 3/10 |

### Recomendación: Implementar A2 primero

**A2 (Structured summary format)** es el quick win más claro:
- Cero riesgo (solo cambia un template en la metodología)
- Mejora inmediata en la calidad de TASK_STATE al cerrar sesión
- Inspirado directamente en el formato de summary de OpenViking
- Compatible con nuestro observation masking existente

**Siguiente:** A3 (log de retrieval) como hook, luego A1 (categorías) como mejora al auto-memory.
