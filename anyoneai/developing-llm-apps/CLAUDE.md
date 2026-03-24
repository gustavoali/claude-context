# Developing LLM-Based Applications - Project Context
**Programa:** AnyoneAI - Especializacion LLM
**Version:** 0.2.1 | **Tests:** 0/7 passing | **Coverage:** N/A | **Estado:** Brotado
**Ubicacion:** C:/Anyone_AI/developing-llm-apps/
**Inicio:** 2026-03-23

## Descripcion
Especializacion de AnyoneAI enfocada en desarrollo de aplicaciones basadas en LLMs.
Cubre fundamentos de LLMs, prompt engineering, RAG (retrieval + embeddings + chunking),
tools/agents/memory, y monitoreo/evaluacion de sistemas RAG.
Proyecto final: LLM-based Recruitment Tool.

## Stack
- Python 3.8+
- Google Colab (notebooks de teoria)
- LangChain
- Chainlit (chat UI)
- Chroma (vector DB)
- Gemini / OpenAI (LLM providers)
- Hugging Face

## Estructura del Curso

| # | Capitulo | Lecciones | Tipo |
|---|----------|-----------|------|
| 1 | Introduction | 2 | Textos |
| 2 | Basics of Large Language Models | 3 | PDF 41p + Colab + Quiz |
| 3 | Prompt Engineering | 3 | PDF + Colab + Quiz |
| 4 | Information Retrieval, Embeddings, Chunking | 3 | PDF + 2 Colabs + Quiz |
| 5 | Tools, Agents and Chat Memory | 2 | PDF + 2 Colabs |
| 6 | Monitoring and Evaluating RAG Systems | 2 | PDF + Colab |
| 7 | Deliver your Project | 3 | Descripcion + Instrucciones + Upload |

## Notebooks (Google Colab)
| Tema | Colab ID |
|------|----------|
| Basic LLMs | 1Ejlme-nhhRttT6Cm0a5od8kvxBD20vDV |
| Prompt Engineering | 18qJFFbPxJp-pXd0CNH_ifUZ_b3_LaxMv |
| Vector DBs, Retrieval, Embeddings | 1hQ1904RIi5vxTFR18iU73B9rB7FQ1x77 |
| Chunking | 1Lc4FCocu0xKy1quVn8rFTWQH_MCtJjg8 |
| Tools and Agents | 1bsfU9CkpXEVwVl18B2tcLoQpnlZ6iiEH |
| Memory | 1Dj5wScpM3xS-ogli77ZPaQaHWbSQaUZ9 |
| Monitoring & Evaluating RAG | 1aP3LjZtElM7BYCnX0hEAQsBjVeGd8M0o |

## Proyecto Final: LLM-based Recruitment Tool
- Assignment con TODOs a completar (no desde cero)
- 3 chat profiles: Vanilla ChatGPT, Jobs Finder, Jobs Agent
- Dataset: jobs.csv (76MB, job listings)
- Resume upload via PDF → markdown conversion via LLM vision
- RAG: Chroma + SentenceTransformers (paraphrase-MiniLM-L6-v2)
- Agent con 2 tools: jobs_finder + cover_letter_writing

## Comandos
```bash
# Setup
cd assignment
pip install -r requirements.txt
cp env.example .env  # fill GOOGLE_API_KEY
# ETL (crear Chroma DB)
python backend/etl.py
# Run app
python -m chainlit run -w backend/app.py
# Tests
python -m pytest tests/ -v
# Code style
black --line-length=88 .
```

## Agentes Recomendados
| Tarea | Agente |
|-------|--------|
| Implementar backend Python | `python-backend-developer` |
| Arquitectura RAG | `software-architect` |
| Tests | `test-engineer` |
| Code review | `code-reviewer` |

## Reglas del Proyecto
- Notebooks de teoria son de solo lectura (experimentar en Colab)
- El proyecto final se entrega como .zip sin datos ni modelos
- Usar LangChain como framework principal (no raw API calls)

## Docs
@C:/claude_context/anyoneai/developing-llm-apps/TASK_STATE.md
@C:/claude_context/anyoneai/developing-llm-apps/SEED_DOCUMENT.md
@C:/claude_context/anyoneai/developing-llm-apps/ARCHITECTURE_ANALYSIS.md
@C:/claude_context/anyoneai/developing-llm-apps/PRODUCT_BACKLOG.md
@C:/claude_context/anyoneai/developing-llm-apps/SECURITY_ANALYSIS.md
@C:/claude_context/anyoneai/developing-llm-apps/BUSINESS_STAKEHOLDER_DECISION.md
