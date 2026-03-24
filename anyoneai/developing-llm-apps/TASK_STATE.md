# Estado - Developing LLM-Based Applications
**Actualizacion:** 2026-03-23 22:00 | **Version:** 0.2.1

## En Progreso
Proyecto brotado y re-calibrado con proyecto real descargado de Google Drive.

## Completado Esta Sesion
| # | Descripcion | Resultado |
|---|-------------|-----------|
| 1 | Brotado inicial (arquitectura, seguridad, backlog, business) | 4 documentos generados |
| 2 | Descarga proyecto base desde Google Drive | assignment/ con codigo + TODOs |
| 3 | Analisis del codigo real | 10 archivos, 6 con TODOs, 7 tests pre-escritos |
| 4 | Re-generacion de ARCHITECTURE y BACKLOG | Alineados con proyecto real |

## Contexto Critico
- El proyecto es un assignment con TODOs pre-escritos, NO desde cero
- Dataset: jobs.csv (76MB, job listings), no PDFs de candidatos
- 3 chat profiles: Vanilla ChatGPT, Jobs Finder, Jobs Agent
- Tests ya escritos que validan estructura exacta (kwargs, tipos, atributos)
- Dependencia critica: resume_summarizer se importa a nivel de modulo en jobs_finder.py (linea 9)

## Proximos Pasos
1. Configurar entorno: venv + .env con GOOGLE_API_KEY (DLA-001)
2. Completar TODOs semana 1: pdf_to_markdown + ChatAssistant (DLA-002, DLA-003)
3. Completar TODOs semana 2: ETLProcessor + ejecutar ETL (DLA-004, DLA-005)
4. Completar TODOs semana 3: JobsFinder + ResumeSummarizer + Agent (DLA-006, DLA-007)
5. Pasar todos los tests + E2E + empaquetar (DLA-008, DLA-009, DLA-010)

## Decisiones Pendientes
- Necesitas proveer tu GOOGLE_API_KEY para .env
