# AnyoneAI Final Project - Financial Advisor Chatbot
**Version:** 0.2.0 | **Tests:** 13 passing | **Coverage:** 0%
**Inicio:** 2026-03-24

## Repositorios
| Repo | Ubicacion | Remote | Proposito |
|------|-----------|--------|-----------|
| **Team (Elloisa)** | C:/Anyone_AI/final_project-team | github.com/Elloisa/Financial_advisor_chatbot | Trabajo colaborativo del equipo |
| **Personal** | C:/Anyone_AI/final_project-personal | github.com/gustavoali/anyoneai-final-project (private) | Nuestro trabajo en paralelo |
| **Assignment** | C:/Anyone_AI/final_project | (sin remote) | Template original + contenidos del curso |

## Stack
- Python 3.11, LangChain, ChromaDB, sentence-transformers/all-MiniLM-L6-v2
- OpenAI gpt-4o-mini, FastAPI, Chainlit, Docker Compose
- PDF extraction: PyMuPDF + pdfplumber
- Dataset: ~10K PDFs financieros NASDAQ en AWS S3

## Componentes
| Componente | Ubicacion | Estado |
|------------|-----------|--------|
| EDA Notebook | notebooks/01_eda.ipynb | Completado |
| PDF Extraction | src/preprocessing.py | Completado (141/141 PDFs) |
| Chunking + Indexing | src/indexing.py | Completado (~75K chunks) |
| RAG Pipeline | src/rag.py | Completado |
| FastAPI | src/api.py | Completado |
| Chainlit UI | src/app.py | Completado |
| Docker | docker-compose.yml | Completado |
| Tests | tests/test_preprocessing.py | 13 passing |

## Dataset S3
- Bucket: s3://anyoneai-datasets/nasdaq_annual_reports/
- Key: AKIA2JHUK4EGBVSQ5RUW
- Secret: 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

## Entregable
- Nombre: FinAdvisor_Gustavo_Ali.zip
- Max: 100 MB, sin datos ni modelos

## Comandos
```bash
# Activar venv
.venv/Scripts/activate
# API
uvicorn src.api:app --reload
# UI
chainlit run src/app.py
# Docker
docker-compose up --build
# Tests
pytest tests/ -v
```

## Agentes Recomendados
| Tarea | Agente |
|-------|--------|
| Pipeline RAG, API, extraccion | python-backend-developer |
| Calidad de datos / EDA | data-quality-analyst |
| Dockerizacion | devops-engineer |
| Tests | test-engineer |
| Code review | code-reviewer |

## Docs
@C:/claude_context/anyoneai/final_project/TASK_STATE.md
