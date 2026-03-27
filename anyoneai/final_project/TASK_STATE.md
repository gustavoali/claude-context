# Estado - AnyoneAI Final Project (Financial Advisor Chatbot)
**Actualizacion:** 2026-03-27 01:00 | **Version:** 0.4.1

## Repos
| Repo | Path | Remote |
|------|------|--------|
| **Team** | C:/Anyone_AI/final_project-team | github.com/Elloisa/Financial_advisor_chatbot |
| **Personal** | C:/Anyone_AI/final_project-personal | github.com/gustavoali/anyoneai-final-project |
| **Assignment** | C:/Anyone_AI/final_project/Assignment | (sin remote, venv aqui) |
| **References** | C:/Anyone_AI/final_project/references/ | backend-rag, frontend-rag, agente-financiero |

## Decision de Equipo (reunion con Andy)
- **Scope MVP:** Magnificent 7 (AAPL, MSFT, GOOGL, AMZN, NVDA, META, TSLA)
- **Extraccion:** Azure Document Intelligence (Miguel gestiona credenciales)
- **Deadline:** Martes - metadata + queries base para feedback de Claudio
- **Mi tarea:** 35 PDFs (7 empresas x 5 anos) en capa Raw

## Completado Esta Sesion
**Overview:** S3 completo + OpenSearch + mejoras retrieval + informe equipo | Completado | Pendiente unificar fuentes

**Pasos clave:**
- Codigo adaptado al repo del equipo (branch feat/rag-pipeline)
- S3 nuevas credenciales OK, descarga completa: 9,775 PDFs (0 errores)
- Ingestion reescrita para S3 PDFs (download_s3.py + extraction.py con pdfplumber)
- Migrado ChromaDB -> OpenSearch 2.19.1 (busqueda hibrida kNN+BM25)
- Mejoras de repos referencia: chunk 1500, retrieval 2 fases, whitespace normalization
- Analisis disponibilidad: S3 tiene 25/35, SEC EDGAR tiene 63/35 (cobertura total)
- Informe PDF generado para el equipo (docs/informe-datos-magnificent7.pdf)
- WIP commit en repo personal (ed50120)

**Conceptos clave:**
- S3 no tiene GOOGL. META esta como NASDAQ_FB. SEC EDGAR cubre todo 2017-2025
- Push a claude_context bloqueado por AWS keys en CLAUDE.md (limpiar historial)

## Disponibilidad Magnificent 7
| Ticker | S3 | SEC EDGAR |
|--------|-----|-----------|
| AAPL | 4 (2019-2022) | 9 (2017-2025) |
| MSFT | 3 (2019-2021) | 9 (2017-2025) |
| GOOGL | 0 | 9 (2017-2025) |
| AMZN | 5 (2017-2021) | 9 (2017-2025) |
| NVDA | 4 (2019-2022) | 9 (2017-2025) |
| META | 4 como FB (2018-2021) | 9 (2017-2025) |
| TSLA | 5 (2016-2020) | 9 (2017-2025) |

## Proximos Pasos
1. Unificar ambas fuentes (S3 PDFs + SEC EDGAR HTML) en data/processed/ para Magnificent 7
2. Descargar SEC EDGAR 10-K para Magnificent 7 (2017-2025)
3. Extraer texto de ambas fuentes, indexar en OpenSearch
4. Configurar OPENAI_API_KEY para test E2E
5. Reportar al equipo (informe PDF listo)

## Decisiones Pendientes
- Confirmar con equipo si complementamos S3 con SEC EDGAR para faltantes
- Definir si Azure Document Intelligence reemplaza pdfplumber o conviven
- Limpiar AWS keys del historial de claude_context para poder pushear
