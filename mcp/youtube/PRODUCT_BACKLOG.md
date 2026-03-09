# Backlog - YouTube Content Intelligence MCP
**Version:** 1.0 | **Actualizacion:** 2026-03-08

## Resumen
| Metrica | Valor |
|---------|-------|
| Total historias | 8 |
| Total puntos | 21 |
| Completadas | 0 |
| En progreso | 0 |
| Pendientes | 8 |

## Vision
Construir un sistema de ingestion y busqueda de videos de YouTube que almacene metadata y transcripts en SQLite con FTS5, permitiendo a LLMs acceder al contenido via MCP tools. Separado del modulo library (archivos locales) para mantener responsabilidades claras.

## Epics
| Epic | Historias | Puntos | Status |
|------|-----------|--------|--------|
| EPIC-001 YouTube Video Ingestion | YTM-001 a YTM-008 | 21 | Pendiente |

## Pendientes (con detalle)

### YTM-001: YouTube Ingestion Schema & Database Layer
**Points:** 3 | **Priority:** Critical
**Detalle:** [backlog/stories/YTM-001-ingestion-schema.md](backlog/stories/YTM-001-ingestion-schema.md)

### YTM-002: Single Video Metadata Ingestion
**Points:** 2 | **Priority:** Critical
**Detalle:** [backlog/stories/YTM-002-single-metadata-ingestion.md](backlog/stories/YTM-002-single-metadata-ingestion.md)

### YTM-003: Single Video Transcript Ingestion
**Points:** 2 | **Priority:** Critical
**Detalle:** [backlog/stories/YTM-003-single-transcript-ingestion.md](backlog/stories/YTM-003-single-transcript-ingestion.md)

### YTM-004: Combined Single Video Ingestion Pipeline
**Points:** 3 | **Priority:** High
**Detalle:** [backlog/stories/YTM-004-combined-ingestion-pipeline.md](backlog/stories/YTM-004-combined-ingestion-pipeline.md)

### YTM-005: Batch Ingestion with Resume Capability
**Points:** 3 | **Priority:** High
**Detalle:** [backlog/stories/YTM-005-batch-ingestion-resume.md](backlog/stories/YTM-005-batch-ingestion-resume.md)

### YTM-006: FTS5 Search Across Ingested Videos
**Points:** 3 | **Priority:** High
**Detalle:** [backlog/stories/YTM-006-fts5-search.md](backlog/stories/YTM-006-fts5-search.md)

### YTM-007: MCP Tool Exposure
**Points:** 3 | **Priority:** High
**Detalle:** [backlog/stories/YTM-007-mcp-tools.md](backlog/stories/YTM-007-mcp-tools.md)

### YTM-008: Takeout Integration as Ingestion Source
**Points:** 2 | **Priority:** Medium
**Detalle:** [backlog/stories/YTM-008-takeout-integration.md](backlog/stories/YTM-008-takeout-integration.md)

## Completadas (indice)
| ID | Titulo | Puntos | Fecha | Detalle |
|----|--------|--------|-------|---------|
| - | - | - | - | - |

## ID Registry
| Rango | Estado |
|-------|--------|
| YTM-001 a YTM-008 | Asignados (EPIC-001) |
| YTM-009+ | Disponible |
| EPIC-001 | Asignado |
| EPIC-002+ | Disponible |
Proximo ID: YTM-009
