# AnyoneAI Final Project - Financial Advisor Chatbot
**Version:** 0.0.0 | **Tests:** 0 | **Coverage:** 0%
**Ubicacion:** C:/Anyone_AI/final_project

## Stack
- Python 3.11, LangChain, ChromaDB, sentence-transformers/all-MiniLM-L6-v2
- OpenAI gpt-4o-mini, FastAPI, Chainlit, Docker Compose
- PDF extraction: PyMuPDF + pdfplumber
- Dataset: ~10K PDFs financieros NASDAQ en AWS S3

## Componentes
| Componente | Ubicacion | Estado |
|------------|-----------|--------|
| EDA Notebook | notebooks/eda.ipynb | Pendiente |
| PDF Extraction | src/extraction.py | Pendiente |
| Chunking + Indexing | src/indexing.py | Pendiente |
| RAG Pipeline | src/rag.py | Pendiente |
| FastAPI | src/api.py | Pendiente |
| Chainlit UI | src/app.py | Pendiente |
| Docker | docker-compose.yml | Pendiente |

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
