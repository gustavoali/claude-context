# Backlog - Developing LLM Apps (Assignment)
**Version:** 2.0 | **Actualizacion:** 2026-03-23

## Resumen
| Metrica | Valor |
|---------|-------|
| Total Stories | 10 |
| Total Points | 24 |
| Epics | 5 |

## Vision
Completar los TODOs del assignment AnyoneAI: LLM-based Recruitment Tool.
El codigo base ya existe; el trabajo es rellenar los TODOs y pasar los tests pre-escritos.

## Epics
| Epic | Nombre | Stories | Puntos | Status |
|------|--------|---------|--------|--------|
| EPIC-001 | Environment Setup | 1 | 2 | Pendiente |
| EPIC-002 | Week 1 - LLM Basics & Prompt Engineering | 2 | 5 | Pendiente |
| EPIC-003 | Week 2 - ETL & RAG Retrieval | 2 | 6 | Pendiente |
| EPIC-004 | Week 3 - Agents & Tools | 2 | 6 | Pendiente |
| EPIC-005 | Testing & Delivery | 3 | 5 | Pendiente |

## Pendientes

### EPIC-001: Environment Setup

**DLA-001: Venv Setup y Configuracion de .env** | 2 pts | Critical
As a developer I want a working Python venv with all dependencies and a valid .env
so that I can run tests and the Chainlit app locally.

**AC1:** Given a fresh clone, When I run `python -m venv .venv && pip install -r assignment/requirements.txt`, Then install completes with 0 errors.
**AC2:** Given env.example, When I copy to .env and set a valid GOOGLE_API_KEY, Then `python -c "from backend.config import settings; print(settings.GOOGLE_API_KEY)"` prints the key.
**AC3:** Given venv active, When I run `chainlit run assignment/backend/app.py`, Then the Chainlit UI opens on localhost:8000 without import errors.

Tech: Python 3.8+. Copy env.example to .env, fill GOOGLE_API_KEY.

---

### EPIC-002: Week 1 - LLM Basics & Prompt Engineering

**DLA-002: pdf_to_markdown() en backend/utils.py** | 3 pts | Critical
As a developer I want to complete the pdf_to_markdown function
so that PDFs can be converted to markdown using the LLM's vision capabilities.

**AC1:** Given pdf_bytes (BytesIO), When pdf_to_markdown is called, Then it reads raw bytes and encodes them with `base64.standard_b64encode()`.
**AC2:** Given encoded PDF, When invoking the LLM, Then it creates a HumanMessage with a list containing a text block (instructions) and a media block (`mime_type: "application/pdf"`, `data: b64`).
**AC3:** Given the LLM is invoked, When Gemini returns a list of dicts instead of a string, Then the function unwraps/joins the text parts and returns a single string.
**AC4:** Given any valid PDF, When pdf_to_markdown is called, Then it returns markdown text (non-empty string).

Tech: File `backend/utils.py` lines 67-82. Uses `get_llm()`, `HumanMessage`, `base64.standard_b64encode`.

**DLA-003: ChatAssistant en backend/models/chatgpt_clone.py** | 2 pts | Critical
As a developer I want to complete the ChatAssistant class
so that `test_structure_chat_assistant` passes.

**AC1:** Given ChatAssistant is instantiated, Then `self.prompt` is a `PromptTemplate` with `input_variables=["history", "human_input"]`.
**AC2:** Given ChatAssistant is instantiated, Then `self.llm` is the return value of `get_llm(model=llm_model, api_key=api_key, temperature=temperature)` and is a `ChatGoogleGenerativeAI`.
**AC3:** Given ChatAssistant is instantiated, Then `self.model` is an `LLMChain` with `llm=self.llm`, `prompt=self.prompt`, `memory=ConversationBufferWindowMemory(k=history_length)`, `output_key="output"`, `verbose=settings.LANGCHAIN_VERBOSE`.
**AC4:** Given all TODOs filled, When `pytest tests/backend/models/test_chatgpt_clone.py` runs, Then test_structure_chat_assistant PASSES.

Tech: File `backend/models/chatgpt_clone.py` lines 27-47. String template needs `{history}` and `{human_input}` placeholders.

---

### EPIC-003: Week 2 - ETL & RAG Retrieval

**DLA-004: ETLProcessor TODOs en backend/etl.py** | 3 pts | Critical
As a developer I want to complete the ETLProcessor class
so that `test_run_etl` passes.

**AC1:** Given `__init__` is called, Then `self.text_splitter` is `RecursiveCharacterTextSplitter(chunk_size=chunk_size, chunk_overlap=chunk_overlap, length_function=len, add_start_index=True)`.
**AC2:** Given `load_data()` is called, Then it calls `pd.read_csv(self.dataset_path)`, keeps only columns `["description", "Employment type", "Seniority level", "company", "location", "post_url", "title"]`, and drops rows with NaN.
**AC3:** Given all TODOs filled, When `pytest tests/backend/test_etl.py` runs, Then test_run_etl PASSES (mocks verify exact call signatures).

Tech: File `backend/etl.py` lines 66-86. Test mocks `pd.read_csv` and `RecursiveCharacterTextSplitter` and asserts exact kwargs.

**DLA-005: Ejecutar ETL para crear Chroma DB** | 1 pt | High
As a developer I want to run the ETL pipeline
so that the Chroma vector store is populated with job descriptions for retrieval.

**AC1:** Given .env configured and venv active, When `python -m backend.etl` (or `python backend/etl.py`) runs, Then it completes without errors and creates a `chroma/` directory.
**AC2:** Given ETL completed, Then the chroma directory contains a collection "jobs" with embedded documents.

Tech: Must run AFTER DLA-004. Uses `dataset/jobs.csv`. Creates `chroma/` directory.

---

### EPIC-004: Week 3 - Agents & Tools

**DLA-006: JobsFinderAssistant en backend/models/jobs_finder.py** | 3 pts | Critical
As a developer I want to complete the JobsFinderAssistant class
so that tests pass and job retrieval works with RAG.

**AC1:** Given `__init__`, Then a string template is created with 4 input variables: `resume`, `history`, `search_results`, `human_input`.
**AC2:** Given `__init__`, Then `self.prompt` is `PromptTemplate` with those 4 `input_variables`.
**AC3:** Given `__init__`, Then `self.llm` is `get_llm(model=llm_model, api_key=api_key, temperature=temperature)`.
**AC4:** Given `__init__`, Then `self.model` is `LLMChain(llm, prompt, memory=_memory, output_key="output")` where `_memory` is the already-created `ConversationBufferWindowMemory`.
**AC5:** Given `predict()`, Then `jobs` is assigned from `self.retriever.search(human_input + self.resume_summary)` (string concatenation).

Tech: File `backend/models/jobs_finder.py` lines 44-90. Memory already created at line 63; just wire it into LLMChain.

**DLA-007: Resume Summarizer Chain + Jobs Finder Agent** | 3 pts | Critical
As a developer I want to complete resume_summarizer_chain.py and jobs_finder_agent.py
so that `test_get_resume_summarizer_chain` and `test_jobs_finder_agent` pass.

**AC1 (resume_summarizer):** Given module loads, Then `template` is a module-level string with `{resume}` placeholder.
**AC2 (resume_summarizer):** Given `get_resume_summarizer_chain()`, Then it calls `PromptTemplate(input_variables=["resume"], template=template)`, `get_llm(temperature=0)`, `LLMChain(llm=llm, prompt=prompt, verbose=settings.LANGCHAIN_VERBOSE)` and returns the chain.
**AC3 (agent - cover_letter):** Given `build_cover_letter_writing()`, Then template has `{resume}` and `{job_description}`, creates `PromptTemplate` and `LLMChain`.
**AC4 (agent - init):** Given `JobsFinderAgent.__init__`, Then `self.llm = get_llm(model=llm_model, api_key=api_key, temperature=temperature)` and is `ChatGoogleGenerativeAI`.
**AC5 (agent - tools):** Given agent created, Then `agent_executor.tools` has exactly 2 tools: "jobs_finder" and "cover_letter_writing".
**AC6:** Given all TODOs filled, When `pytest tests/backend/models/test_resume_summarizer_chain.py tests/backend/models/test_jobs_finder_agent.py` runs, Then both tests PASS.

Tech: Files `backend/models/resume_summarizer_chain.py` (lines 7-27) and `backend/models/jobs_finder_agent.py` (lines 19-32, 67).

---

### EPIC-005: Testing & Delivery

**DLA-008: Full Test Suite Pass** | 2 pts | Critical
As a developer I want all pre-written tests to pass
so that the assignment is validated.

**AC1:** Given all DLA-002 through DLA-007 completed, When `python -m pytest tests/ -v` runs, Then ALL tests pass (0 failures).
**AC2:** Test list: test_extract_text_from_pdf, test_structure_chat_assistant, test_run_etl, test_get_resume_summarizer_chain, test_jobs_finder_agent (x2 files).

Tech: Run from `assignment/` directory. conftest.py sets dummy API keys.

**DLA-009: E2E Manual Validation** | 2 pts | High
As a developer I want to validate the full app works end-to-end
so that the recruitment tool functions as expected before delivery.

**AC1:** Given Chroma DB populated and .env configured, When `chainlit run backend/app.py`, Then the UI loads and responds to job search queries.
**AC2:** Given a resume is uploaded/provided, When user asks "find me a job as a software engineer", Then the assistant uses RAG retrieval and returns relevant job matches.
**AC3:** Given the agent mode, When user asks to write a cover letter, Then the agent uses the cover_letter_writing tool and returns a letter.

Tech: Requires DLA-005 (ETL run) completed first. Manual testing checklist.

**DLA-010: Package for Delivery** | 1 pt | High
As a student I want to package the project as .zip for AnyoneAI submission.

**AC1:** Given project complete, When packaged as .zip, Then it excludes chroma/, .env, __pycache__, .git/, .venv/.
**AC2:** Given extracted .zip, When evaluator runs `pip install -r requirements.txt && python -m pytest tests/`, Then all tests pass.
**AC3:** Given .zip, Then size is under 10MB.

Tech: Include .env.example. README with setup instructions.

## Completadas (indice)
| ID | Titulo | Puntos | Fecha | Detalle |
|----|--------|--------|-------|---------|

## ID Registry
| Rango | Estado |
|-------|--------|
| DLA-001 a DLA-010 | Asignados |
| DLA-011+ | Disponibles |
Proximo ID: DLA-011
