# Estado - AnyoneAI Final Project (Financial Advisor Chatbot)
**Actualizacion:** 2026-03-25 10:30 | **Version:** 0.3.0

## Repos
| Repo | Path | Remote |
|------|------|--------|
| **Team** | C:/Anyone_AI/final_project-team | github.com/Elloisa/Financial_advisor_chatbot |
| **Personal** | C:/Anyone_AI/final_project-personal | github.com/gustavoali/anyoneai-final-project |
| **Assignment** | C:/Anyone_AI/final_project/Assignment | (sin remote, venv + data aqui) |

## Plan de Ejecucion
- Fase 0: Setup y Exploracion S3 - COMPLETADA
- Fase 1: EDA y Preprocesamiento - COMPLETADA
- Fase 2: Chunking e Indexacion - COMPLETADA (migrado a OpenSearch)
- Fase 3: Pipeline RAG - COMPLETADA (busqueda hibrida kNN+BM25)
- Fase 4: API FastAPI - COMPLETADA (con filtros year/mode)
- Fase 5: UI Chainlit - COMPLETADA
- Fase 6: Dockerizacion - COMPLETADA (OpenSearch + API + UI)
- Fase 7: Testing y Demo - EN PROGRESO

## Migracion OpenSearch - COMPLETADA
- Docker: opensearch 2.19.1 single-node, puerto 9200
- Index mapping: knn_vector (384 dims, HNSW cosine) + text (BM25) + metadata
- Busqueda hibrida: 70% semantica + 30% keyword, configurable
- Filtros: por ticker y por year
- Test exitoso: AAPL+MSFT (2544 chunks), retrieval hibrida OK
- Indexacion completa (141 filings) en curso en background

## Archivos modificados para OpenSearch
- src/retrieval/indexing.py - ChromaDB -> OpenSearch + sentence-transformers
- src/generation/rag.py - Busqueda hibrida (semantic/keyword/hybrid)
- src/api/main.py - Agregado filtro year y mode, /tickers via aggregation
- ui/app.py - Actualizado score display
- docker-compose.yml - Agregado servicio opensearch
- docker/Dockerfile - Removido chromadb data
- requirements.txt - opensearch-py reemplaza chromadb

## Pendiente
1. Esperar indexacion completa (~90K chunks)
2. Configurar OPENAI_API_KEY para test E2E
3. Test manual pipeline completo
4. Actualizar tests para OpenSearch
5. Commit inicial en repo personal
