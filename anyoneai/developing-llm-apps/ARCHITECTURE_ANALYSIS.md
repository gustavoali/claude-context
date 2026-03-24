# Arquitectura - LLM-based Recruitment Tool
**Version:** 0.1.0 | **Fecha:** 2026-03-23

## Diagrama de Componentes

```
                          assignment/
  ┌─────────────────────────────────────────────────────────────┐
  │                        backend/                             │
  │                                                             │
  │  ┌──────────┐  ┌─────────────┐  ┌────────────────────────┐ │
  │  │ config.py│  │llm_factory.py│  │       utils.py         │ │
  │  │ Settings │  │  get_llm()  │  │ extract_text_from_pdf()│ │
  │  └────┬─────┘  └──────┬──────┘  │ pdf_to_markdown() TODO │ │
  │       │               │          └───────────┬────────────┘ │
  │       │               │                      │              │
  │  ┌────┴───────────────┴──────────────────────┴────────────┐ │
  │  │                     app.py (Chainlit)                   │ │
  │  │  Profile 1: Vanilla ChatGPT                             │ │
  │  │  Profile 2: Jobs Finder Assistant                       │ │
  │  │  Profile 3: Jobs Agent                                  │ │
  │  └──┬──────────────────┬─────────────────────┬────────────┘ │
  │     │                  │                     │              │
  │  ┌──┴──────────┐  ┌───┴──────────────┐  ┌───┴───────────┐ │
  │  │ chatgpt_    │  │ jobs_finder.py   │  │jobs_finder_   │ │
  │  │ clone.py    │  │ JobsFinder       │  │agent.py       │ │
  │  │ ChatAssist. │  │ Assistant        │  │JobsFinder     │ │
  │  │ TODO        │  │ TODO             │  │Agent          │ │
  │  └─────────────┘  └──┬──────┬────────┘  └──┬──────┬─────┘ │
  │                       │      │              │      │       │
  │               ┌───────┘  ┌───┘         ┌────┘  ┌───┘       │
  │               │          │             │       │           │
  │  ┌────────────┴───┐  ┌──┴──────────┐  │  ┌────┴────────┐ │
  │  │resume_summary_ │  │retriever.py │  │  │cover_letter │ │
  │  │chain.py        │  │ Retriever   │  │  │writing TODO │ │
  │  │TODO             │  │ (Chroma)    │  │  └─────────────┘ │
  │  └────────────────┘  └──────┬──────┘  │                   │
  │                              │         │                   │
  └──────────────────────────────┼─────────┘───────────────────┘
                                 │
  ┌──────────────────────────────┴──────────────────────────────┐
  │  etl.py (offline)                                           │
  │  dataset/jobs.csv -> ETLProcessor -> Chroma (./chroma/)     │
  │  TODOs: text_splitter, load_data                            │
  └─────────────────────────────────────────────────────────────┘
```

## Componentes

| Componente | Archivo | Responsabilidad | Estado |
|------------|---------|-----------------|--------|
| Config | `config.py` | Pydantic Settings: env vars, paths, model names | COMPLETO |
| LLM Factory | `llm_factory.py` | `get_llm()` -> `ChatGoogleGenerativeAI` | COMPLETO |
| PDF Utils | `utils.py` | Extraer texto/markdown de PDFs | PARCIAL |
| Retriever | `retriever.py` | Wrapper sobre Chroma `similarity_search` | COMPLETO |
| ETL Pipeline | `etl.py` | Ingestar jobs.csv en Chroma vector store | PARCIAL |
| Chat App | `app.py` | Chainlit UI con 3 chat profiles + file upload | COMPLETO |
| ChatAssistant | `models/chatgpt_clone.py` | Chat simple: LLMChain + memory | TODO |
| JobsFinderAssistant | `models/jobs_finder.py` | RAG: resume + retriever + LLMChain | TODO |
| ResumeSummarizerChain | `models/resume_summarizer_chain.py` | Chain para resumir CVs | TODO |
| JobsFinderAgent | `models/jobs_finder_agent.py` | Agent con tools (jobs + cover letter) | PARCIAL |

## Flujos de Datos

### Flujo 1: ETL (offline, ejecucion unica)

```
jobs.csv (76MB)
  -> pd.read_csv() + filter 7 columns + dropna    [TODO: load_data]
    -> Documents con metadata (employment_type, seniority_level,
       company, location, post_url, title)
      -> RecursiveCharacterTextSplitter(500, 100)  [TODO: text_splitter]
        -> SentenceTransformerEmbeddings(paraphrase-MiniLM-L6-v2)
          -> Chroma.from_documents() en batches de 32
            -> Persistido en ./chroma/
```

Nota: `run_etl()` toma solo los primeros 100 documentos (`[:100]`).

### Flujo 2: Vanilla ChatGPT (Profile 1)

```
User msg
  -> ChatAssistant.predict(human_input)
    -> LLMChain(
         prompt: template con {history} + {human_input},
         llm: get_llm(model, api_key, temperature),
         memory: ConversationBufferWindowMemory(k=history_length)
       )
      -> Gemini response
```

Sin upload de PDF. Sin retrieval.

### Flujo 3: Jobs Finder Assistant (Profile 2)

```
User uploads PDF
  -> pdf_to_markdown(pdf) -> resume text          [TODO]
    -> resume_summarizer_chain.invoke(resume)      [TODO]
      -> resume_summary (para queries de retrieval)

User msg
  -> Retriever.search(human_input + resume_summary, k=4)
    -> Chroma similarity_search -> jobs
  -> LLMChain.invoke({
       resume, search_results: jobs,
       history, human_input
     })
    -> Gemini response con jobs relevantes
```

### Flujo 4: Jobs Agent (Profile 3)

```
User uploads PDF
  -> pdf_to_markdown(pdf) -> resume text          [TODO]

User msg
  -> AgentExecutor.invoke({input, chat_history})
    -> create_tool_calling_agent decide tool:
       Tool 1: "jobs_finder"
         -> JobsFinderAssistant.predict(input) -> jobs
       Tool 2: "cover_letter_writing"              [TODO]
         -> LLMChain({resume, job_description}) -> cover letter
    -> Agent compone respuesta final

Memory: lista de HumanMessage/AIMessage, ultimos k*2 mensajes
```

## Folder Structure

```
assignment/
  README.md                          # Instrucciones del assignment
  specialization_plan.md             # Sprint planning (3 semanas)
  requirements.txt                   # Dependencias pineadas
  env.example                        # GOOGLE_API_KEY, GEMINI_LLM_MODEL
  .gitignore
  dataset/
    jobs.csv                         # 76MB, job listings
  backend/
    __init__.py
    config.py                        # Pydantic Settings
    llm_factory.py                   # get_llm() factory
    utils.py                         # PDF extraction utilities
    retriever.py                     # Chroma similarity search
    etl.py                           # ETL pipeline
    app.py                           # Chainlit entry point
    models/
      __init__.py
      chatgpt_clone.py               # ChatAssistant (Profile 1)
      jobs_finder.py                 # JobsFinderAssistant (Profile 2)
      resume_summarizer_chain.py     # Resume summarizer chain
      jobs_finder_agent.py           # JobsFinderAgent (Profile 3)
  tests/
    __init__.py
    conftest.py                      # Dummy GOOGLE_API_KEY fixture
    backend/
      test_utils.py                  # Tests extract_text_from_pdf
      test_etl.py                    # Tests ETLProcessor (mocked)
      test_retriever.py              # Tests Retriever.search (mocked)
      models/
        test_chatgpt_clone.py        # Tests ChatAssistant structure
        test_jobs_finder.py          # Tests JobsFinderAgent (duplicate)
        test_jobs_finder_agent.py    # Tests JobsFinderAgent tools
        test_resume_summarizer_chain.py  # Tests chain construction
```

## ADRs (Architecture Decision Records)

### ADR-001: Embedding Model

**Decision:** `paraphrase-MiniLM-L6-v2` via `SentenceTransformerEmbeddings`.
**Donde:** `config.py` campo `EMBEDDINGS_MODEL`, instanciado en `etl.py` y `retriever.py`.
**Razon:** Modelo ligero (22M params), corre en CPU, gratis, buena calidad para semantic
similarity en ingles. Suficiente para matching job descriptions.
**Consecuencias:** No requiere GPU. El modelo se descarga al primer uso (~90MB).
Si se cambia, hay que re-indexar Chroma.

### ADR-002: Chunking Strategy

**Decision:** `RecursiveCharacterTextSplitter` con chunk_size=500, chunk_overlap=100.
**Donde:** `etl.py` `__main__` block y TODO en `__init__`.
**Razon:** Los job descriptions son textos cortos-medianos; 500 chars preserva contexto
de un parrafo completo. `add_start_index=True` permite rastrear posicion del chunk.
**Alternativas descartadas por el template:**
- `CharacterTextSplitter` (no recursivo, cortes mas bruscos)
- Semantic chunking (mas complejo, innecesario para job descriptions estructuradas)

### ADR-003: LLMChain (langchain-classic) vs LCEL

**Decision:** Usar `LLMChain` de `langchain-classic` en todos los modelos.
**Donde:** Imports en `chatgpt_clone.py`, `jobs_finder.py`, `resume_summarizer_chain.py`,
`jobs_finder_agent.py`. Todos importan `from langchain_classic.chains import LLMChain`.
**Razon:** El template del assignment fue disenado con LLMChain como patron pedagogico.
Todos los TODOs esperan instanciar `LLMChain(prompt=, llm=, memory=, output_key=)`.
**Consecuencias:** Verbose comparado con LCEL, pero explicito y facil de seguir.
`ConversationBufferWindowMemory` se integra directamente con LLMChain.

### ADR-004: Agent Framework

**Decision:** `create_tool_calling_agent` + `AgentExecutor` de `langchain-classic`.
**Donde:** `jobs_finder_agent.py`, metodo `create_agent()`.
**Razon:** Tool-calling agents son el patron recomendado por LangChain para modelos
que soportan function calling (Gemini lo soporta).
**Consecuencias:** El agente maneja su propia memoria (lista de `HumanMessage`/`AIMessage`,
truncada a `k*2`) en lugar de `ConversationBufferWindowMemory`. Esto es intencional:
`AgentExecutor` no integra bien con `Memory` objects de langchain-classic.

## Interfaces Clave (Signatures de TODOs)

### utils.py: pdf_to_markdown

```python
def pdf_to_markdown(pdf_bytes: BytesIO) -> str:
    # 1. base64_data = base64.standard_b64encode(pdf_bytes.read())
    # 2. llm = get_llm()
    # 3. msg = HumanMessage(content=[
    #      {"type": "text", "text": "Convert this PDF to clean markdown..."},
    #      {"type": "media", "mime_type": "application/pdf", "data": base64_data}
    #    ])
    # 4. response = llm.invoke([msg])
    # 5. return response.content (str o join de parts)
```

### etl.py: text_splitter + load_data

```python
# __init__: self.text_splitter = RecursiveCharacterTextSplitter(
#     chunk_size=chunk_size, chunk_overlap=chunk_overlap,
#     length_function=len, add_start_index=True)

# load_data() -> pd.DataFrame:
#   df = pd.read_csv(self.dataset_path)
#   df = df[["description", "Employment type", "Seniority level",
#            "company", "location", "post_url", "title"]]
#   df = df.dropna()
#   return df
```

### chatgpt_clone.py: ChatAssistant.__init__

```python
# template: str con {history} y {human_input}
# self.prompt = PromptTemplate(input_variables=["history", "human_input"],
#                              template=template)
# self.llm = get_llm(model=llm_model, api_key=api_key,
#                     temperature=temperature)
# self.model = LLMChain(llm=self.llm, prompt=self.prompt,
#     memory=ConversationBufferWindowMemory(k=history_length),
#     output_key="output")
```

### resume_summarizer_chain.py: get_resume_summarizer_chain

```python
# template: str con {resume} -> instruccion de summarizar skills
# prompt = PromptTemplate(input_variables=["resume"], template=template)
# llm = get_llm(temperature=0)
# resume_summarizer_chain = LLMChain(llm=llm, prompt=prompt)
# return resume_summarizer_chain
```

### jobs_finder.py: JobsFinderAssistant.__init__ + predict

```python
# template: str con {resume}, {history}, {search_results}, {human_input}
# self.prompt = PromptTemplate(
#     input_variables=["resume", "history", "search_results", "human_input"],
#     template=template)
# self.llm = get_llm(model=llm_model, api_key=api_key,
#                     temperature=temperature)
# self.model = LLMChain(llm=self.llm, prompt=self.prompt, memory=_memory,
#     output_key="output")
#
# predict(): jobs = self.retriever.search(human_input + self.resume_summary)
```

### jobs_finder_agent.py: build_cover_letter_writing + self.llm

```python
# build_cover_letter_writing(llm, resume):
#   template: str con {resume} y {job_description}
#   prompt = PromptTemplate(
#       input_variables=["resume", "job_description"], template=template)
#   cover_letter_writing_chain = LLMChain(llm=llm, prompt=prompt)
#   return cover_letter_writing_chain.invoke({resume, job_description})
#
# __init__: self.llm = get_llm(model=llm_model, api_key=api_key,
#                               temperature=temperature)
```

## Testing Strategy

Los tests provistos validan estructura y contratos, no comportamiento E2E. Todo esta mocked.

| Test File | Que valida |
|-----------|-----------|
| `test_utils.py` | `extract_text_from_pdf` extrae texto de PDF generado con reportlab |
| `test_etl.py` | `ETLProcessor` tiene atributos correctos; `create_documents` produce `Document` |
| `test_retriever.py` | `Retriever.search` invoca `similarity_search` con args correctos (mocked) |
| `test_chatgpt_clone.py` | `ChatAssistant` tiene `.prompt`, `.llm`, `.model` como atributos |
| `test_jobs_finder.py` | `JobsFinderAgent` tiene `agent_executor` y `resume` (parece duplicado de agent test) |
| `test_jobs_finder_agent.py` | `JobsFinderAgent` tiene 2 tools: "jobs_finder" y "cover_letter_writing" |
| `test_resume_summarizer_chain.py` | `get_resume_summarizer_chain()` retorna un `LLMChain` (mocked) |

Patron comun: `conftest.py` setea `GOOGLE_API_KEY=dummy` via monkeypatch para evitar
errores de config al importar modulos.

## Dependencias entre TODOs (Orden de Implementacion)

```
Fase 1 (independientes entre si):
  [1a] etl.py: self.text_splitter     # 1 linea: RecursiveCharacterTextSplitter(...)
  [1b] etl.py: load_data()            # read_csv + filter columns + dropna
  [1c] utils.py: pdf_to_markdown()    # base64 encode + LLM multimodal invoke
  [1d] resume_summarizer_chain.py     # template + PromptTemplate + get_llm + LLMChain

Fase 2 (depende de Fase 1):
  [2a] chatgpt_clone.py               # Mismo patron que 1d (template + prompt + llm + chain)
  [2b] jobs_finder.py                 # Depende de 1d (resume_summarizer importado a modulo level)

Fase 3 (depende de Fase 2):
  [3a] jobs_finder_agent.py           # Depende de 2b (instancia JobsFinderAssistant)
       - self.llm                      # get_llm(model, api_key, temperature)
       - build_cover_letter_writing    # template + prompt + LLMChain (mismo patron)

Fase 4 (validacion):
  [4a] pytest (todos los tests deben pasar)
  [4b] python -m backend.etl (poblar Chroma)
  [4c] chainlit run backend/app.py (probar los 3 profiles)
```

Fase 1 es completamente paralelizable. Fase 2a no depende de Fase 1 directamente
(mismo patron), pero 2b SI depende de 1d porque `resume_summarizer` se importa a
nivel de modulo en `jobs_finder.py` linea 9. Fase 3 requiere 2b completo porque
`JobsFinderAgent.__init__` instancia `JobsFinderAssistant` internamente.

## Stack (del requirements.txt)

| Categoria | Paquete | Version |
|-----------|---------|---------|
| LLM Framework | langchain | 1.2.0 |
| LLM Framework (legacy) | langchain-classic | 1.0.3 |
| LLM Provider | langchain-google-genai | 4.2.1 |
| Embeddings | langchain-huggingface | 1.2.1 |
| Embeddings | sentence-transformers | 5.3.0 |
| Vector DB | langchain-chroma | 1.1.0 |
| Vector DB | chromadb | 1.5.5 |
| Chat UI | chainlit | 2.8.3 |
| Data | pandas | (pineado) |
| PDF | pypdf | (pineado) |
| PDF gen (tests) | reportlab | (pineado) |
| Config | pydantic-settings | (pineado) |
| Graphs (disponible, no usado) | langgraph | 1.0.2 |
| Eval (disponible, no usado) | ragas | 0.4.3 |

## Configuracion (env vars)

| Variable | Default | Uso |
|----------|---------|-----|
| `GOOGLE_API_KEY` | `""` | API key para Gemini |
| `GEMINI_LLM_MODEL` | `gemini-3.1-flash-lite-preview` | Modelo LLM |
| `LANGCHAIN_VERBOSE` | `False` | Debug logging de chains |
| `DATASET_PATH` | `{root}/dataset/jobs.csv` | Path al CSV de jobs |
| `CHROMA_DB_PATH` | `{root}/chroma` | Directorio de persistencia Chroma |
| `CHROMA_COLLECTION` | `jobs` | Nombre de la coleccion en Chroma |
| `EMBEDDINGS_MODEL` | `paraphrase-MiniLM-L6-v2` | Modelo de embeddings |
