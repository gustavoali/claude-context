# EPIC-001: YouTube Video Ingestion Pipeline

**Status:** Pendiente
**Total Points:** 21
**Stories:** YTM-001 a YTM-008
**Created:** 2026-03-08

## Objetivo
Crear un sistema de ingestion que almacene metadata y transcripts de videos de YouTube en SQLite con FTS5, separado del modulo library (archivos locales), para consumo por LLMs via MCP tools.

## Alcance
- Nuevas tablas `youtube_videos` y `youtube_transcripts` (separadas de `videos` de library)
- Pipeline de ingestion: video IDs -> metadata (yt-dlp) -> transcript (youtube-transcript-api) -> SQLite
- Batch ingestion con progress tracking y resume
- Busqueda full-text sobre titulo + descripcion + transcript
- Exposicion como MCP tools
- Integracion con Takeout parser existente como fuente de video IDs

## Fuera de Alcance
- Whisper como fallback de transcription (fase posterior)
- Artifact generation (summary, keypoints) sobre videos ingestados (fase posterior)
- Sincronizacion automatica con playlists de YouTube

## Dependencias
- Modulo metadata existente (`src/youtube_mcp/metadata/`)
- Modulo transcript existente (`src/youtube_mcp/transcript/`)
- Modulo takeout existente (`src/youtube_mcp/playlists/takeout_import.py`)
- Error taxonomy existente (rango LIBRARY_1800-1899 o nuevo rango)

## Orden de Implementacion
```
YTM-001 (schema) ──> YTM-002 (metadata) ──> YTM-004 (combined pipeline)
                 ──> YTM-003 (transcript) ─┘         |
                                                      v
                                              YTM-005 (batch + resume)
                                                      |
                                              YTM-006 (FTS5 search)
                                                      |
                                              YTM-007 (MCP tools)
                                                      |
                                              YTM-008 (takeout integration)
```

YTM-002 y YTM-003 son paralelizables. El resto es secuencial.

## Success Metrics
- Ingestion de 500+ videos sin errores fatales
- Busqueda FTS5 retorna resultados en <100ms para bibliotecas de 1000 videos
- Resume de batch ingestion funciona tras interrupcion
- Videos privados/eliminados se registran como errores sin detener el batch
