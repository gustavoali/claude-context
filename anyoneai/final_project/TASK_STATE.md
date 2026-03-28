# Estado - AnyoneAI Final Project (Financial Advisor Chatbot)
**Actualizacion:** 2026-03-27 21:00 | **Version:** 0.5.0

## Repos
| Repo | Path | Remote | Ramas activas |
|------|------|--------|---------------|
| **Team** | C:/Anyone_AI/final_project-team | github.com/Elloisa/Financial_advisor_chatbot | feat/connect-s3, feat/save-raw-data, feat/download-sample |
| **Personal** | C:/Anyone_AI/final_project-personal | github.com/gustavoali/anyoneai-final-project | master, integration/team-sync, proposal/shared-environment |
| **Assignment** | C:/Anyone_AI/final_project/Assignment | (sin remote, venv aqui) | - |
| **Test (ad-hoc)** | C:/Anyone_AI/final_project-test | clone local de team repo | feat/download-sample |

## Decision de Equipo (reunion con Andy)
- **Scope MVP:** Magnificent 7 (AAPL, MSFT, GOOGL, AMZN, NVDA, META, TSLA)
- **Extraccion:** Azure Document Intelligence (Miguel gestiona credenciales)
- **Trello:** https://trello.com/b/WuSgKbrQ/financial-advisor-chatbot

## Completado Esta Sesion
**Overview:** Data ingestion pipeline completo (S3 + SEC EDGAR) con Docker, tests, docs, PRs y Trello actualizado

**Pasos clave:**
- Reorganizacion datos: raw/s3/ (PDFs) + raw/sec-edgar/ (HTMLs) + processed/ + metadata/manifest.json
- SEC EDGAR descarga 2017-2026: 68 filings para Mag7, incluyendo FY2025 (5 tickers)
- Scripts para team repo: download_s3.py + download_sec.py en src/ingestion/
- Docker Compose con 3 servicios de ingestion (probado en entorno ad-hoc limpio)
- 55 unit tests (35 S3 + 20 EDGAR), todos passing, sin credenciales
- Documentacion: data-download-guide.md (cobertura, flags, troubleshooting) + manual-test-guide.md
- Propuesta entorno compartido (Codespaces + Tailscale) en rama proposal/shared-environment
- 3 PRs creados en team repo (#2, #3, #4)
- 3 tarjetas Trello: checklists 100%, comentarios, movidas a Code Review
- Datos compartidos en Google Drive (PDFs 92.8 MB + HTMLs 14.2 MB, links publicos)
- Rama integration/team-sync creada y pusheada al repo personal

**Conceptos clave:**
- S3 no tiene GOOGL, META esta como FB. SEC EDGAR cubre todo
- AAPL/MSFT fiscal year no-calendario (Sep/Jun), FY2025 aun no disponible para ellos
- No pushear al team repo sin consultar primero

## Disponibilidad Magnificent 7 (actualizada)
| Ticker | S3 (PDF) | SEC EDGAR (HTML) | Combinado |
|--------|----------|------------------|-----------|
| AAPL | 4 (2019-2022) | 9 (FY2016-2024) | 9 años |
| MSFT | 3 (2019-2021) | 9 (FY2016-2024) | 9 años |
| GOOGL | 0 | 10 (FY2016-2025) | 10 años |
| AMZN | 5 (2017-2021) | 10 (FY2016-2025) | 10 años |
| NVDA | 4 (2019-2022) | 10 (FY2016-2025) | 10 años |
| META | 4 como FB (2018-2021) | 10 (FY2016-2025) | 10 años |
| TSLA | 5 (2016-2020) | 10 (FY2016-2025) | 10 años |

## Proximos Pasos
1. Extraer texto de ambas fuentes (PDF con pdfplumber, HTML con parser) y unificar en processed/
2. Indexar en OpenSearch (busqueda hibrida kNN+BM25)
3. Configurar OPENAI_API_KEY para test E2E del chatbot
4. Presentar propuesta de entorno compartido al equipo
5. Revisar PR #1 de Pedro (extract.py) y sugerir merge de nuestras ramas

## Decisiones Pendientes
- Definir si Azure Document Intelligence reemplaza pdfplumber o conviven
- Limpiar AWS keys del historial de claude_context para poder pushear
- Pulir tool de Google Drive MCP para soportar "anyone with link" sin email
