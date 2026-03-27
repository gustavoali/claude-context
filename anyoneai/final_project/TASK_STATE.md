# Estado - AnyoneAI Final Project (Financial Advisor Chatbot)
**Actualizacion:** 2026-03-27 00:30 | **Version:** 0.4.0

## Repos
| Repo | Path | Remote |
|------|------|--------|
| **Team** | C:/Anyone_AI/final_project-team | github.com/Elloisa/Financial_advisor_chatbot |
| **Personal** | C:/Anyone_AI/final_project-personal | github.com/gustavoali/anyoneai-final-project |
| **Assignment** | C:/Anyone_AI/final_project/Assignment | (sin remote, venv aqui) |
| **References** | C:/Anyone_AI/final_project/references/ | 3 repos de investigacion (backend-rag, frontend-rag, agente-financiero) |

## Decision de Equipo (reunion con Andy)
- **Scope MVP:** Magnificent 7 (AAPL, MSFT, GOOGL, AMZN, NVDA, META, TSLA)
- **Extraccion:** Azure Document Intelligence (Miguel gestiona credenciales)
- **Deadline:** Martes - metadata + queries base para feedback de Claudio
- **Mi tarea:** 35 PDFs (7 empresas x 5 años) en capa Raw

## Completado Esta Sesion
**Overview:** Migracion S3 + OpenSearch + mejoras retrieval | Completado | Falta re-indexar con S3 data

**Pasos clave:**
- Adaptado proyecto al repo del equipo (branch feat/rag-pipeline, imports/paths actualizados)
- Credenciales S3 nuevas funcionando, dataset completo: 9,713 PDFs / 2,428 empresas / 29.3 GB
- Descarga completa de S3: 9,775 PDFs descargados a data/raw/ (0 errores)
- Ingestion reescrita para S3 (download_s3.py) con extraccion PDF via pdfplumber
- Migrado de ChromaDB a OpenSearch 2.19.1 (docker, busqueda hibrida kNN+BM25)
- Retrieval mejorado: 2 fases (broad search 3x -> post-filter metadata), chunk size 1500, whitespace normalization
- 3 repos de referencia clonados y analizados (backend-rag, agente-financiero, frontend-rag)

**Conceptos clave:**
- Backend-rag usa SentenceSplitter(1500, 50) + Elasticsearch + text-embedding-3-small + reranking BGE
- Agente-financiero no es RAG, es multi-agent con APIs financieras (no aplica a nuestro PDF pipeline)
- S3 no tiene GOOGL/Alphabet. META esta como NASDAQ_FB_. Varios tickers no llegan a 5 años

## Disponibilidad S3 - Magnificent 7
| Ticker | PDFs en S3 | Años | Nombre S3 |
|--------|-----------|------|-----------|
| AAPL | 4 | 2019-2022 | NASDAQ_AAPL |
| MSFT | 3 | 2019-2021 | NASDAQ_MSFT |
| GOOGL | 0 | - | No existe |
| AMZN | 5 | 2017-2021 | NASDAQ_AMZN |
| NVDA | 4 | 2019-2022 | NASDAQ_NVDA |
| META | 4 | 2018-2021 | NASDAQ_FB |
| TSLA | 5 | 2016-2020 | NASDAQ_TSLA |
| **Total** | **25/35** | | SEC EDGAR query en curso |

## Proximos Pasos
1. Completar busqueda SEC EDGAR para los faltantes de Magnificent 7 (GOOGL y años faltantes)
2. Reportar al equipo disponibilidad S3 (25/35) y proponer complementar con SEC EDGAR
3. Configurar OPENAI_API_KEY para test E2E del pipeline
4. Re-indexar en OpenSearch con datos PDF de S3 (indice limpio, listo)
5. Commit inicial en repo personal

## Decisiones Pendientes
- Confirmar con equipo si complementamos S3 con SEC EDGAR para GOOGL y faltantes
- Definir si Azure Document Intelligence reemplaza nuestro pdfplumber o conviven
