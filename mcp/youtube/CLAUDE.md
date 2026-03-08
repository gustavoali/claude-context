# YouTube Content Intelligence MCP Server - Project Context
**Version:** 0.2.0 | **Tests:** 10 archivos | **Coverage:** 73%
**Ubicacion:** C:\mcp\youtube
**Branch principal:** master

## Stack
- Python 3.10+
- FastMCP (MCP server framework)
- yt-dlp (metadata + audio download)
- youtube-transcript-api (subtitulos)
- OpenAI Whisper (transcripcion fallback)
- Pydantic v2 + pydantic-settings (modelos + config)
- structlog (logging estructurado)
- SQLite + FTS5 (library index)
- pytest + pytest-asyncio (testing)
- Hatchling (build system)
- Docker (packaging)

## Componentes
| Componente | Ubicacion | Responsabilidad |
|------------|-----------|-----------------|
| URL Normalizer | `src/youtube_mcp/url/` | Parseo y normalizacion de URLs de YouTube |
| Metadata Extractor | `src/youtube_mcp/metadata/` | Extraccion de titulo, canal, duracion via yt-dlp |
| Transcript Extractor | `src/youtube_mcp/transcript/` | Subtitulos via youtube-transcript-api |
| Whisper Transcriber | `src/youtube_mcp/whisper/` | Transcripcion de audio como fallback |
| Text Processing | `src/youtube_mcp/processing/` | Normalizacion, dedup, deteccion idioma |
| Artifact Generator | `src/youtube_mcp/artifacts/` | Summary, key points, timeline, claims |
| **Library** | `src/youtube_mcp/library/` | **Indice local de videos, scan, search, tags, YouTube linking** |
| MCP Server | `src/youtube_mcp/mcp/` | Tools MCP via FastMCP |
| Cache Manager | `src/youtube_mcp/cache/` | Cache en disco con TTL |
| Observability | `src/youtube_mcp/observability/` | Logging estructurado + error taxonomy |
| Config | `src/youtube_mcp/config.py` | Configuracion centralizada via env vars |
| Entry Point | `src/youtube_mcp/server.py` | Punto de entrada del servidor |

## Comandos
```bash
# Activar venv
.venv\Scripts\activate       # Windows
source .venv/bin/activate    # Linux

# Instalar
pip install -e ".[dev]"      # Dev
pip install -e ".[whisper]"  # Con Whisper

# Tests
pytest
pytest --cov=src/youtube_mcp --cov-report=term-missing

# Lint
ruff check src/ tests/
ruff format src/ tests/

# Type check
mypy src/

# Ejecutar servidor
youtube-mcp
python -m youtube_mcp.server
```

## MCP Tools
| Tool | Descripcion |
|------|-------------|
| `youtube.get_transcript` | Transcript verificado de un video |
| `youtube.get_digest` | Analisis completo (transcript + artifacts) |
| `youtube.export_markdown` | Exportar analisis como Markdown |
| `system.health` | Health check + stats de cache |
| `library.scan_folder` | Escanear carpeta local e indexar videos |
| `library.list_folders` | Listar carpetas registradas |
| `library.list_videos` | Listar videos indexados |
| `library.get_video` | Detalle de un video especifico |
| `library.search_videos` | Busqueda full-text en biblioteca |
| `library.tag_video` | Agregar/quitar tags a un video |
| `library.link_youtube` | Vincular video local con YouTube |
| `library.auto_link_youtube` | Auto-detectar links por filename yt-dlp |
| `library.sync_transcript` | Sincronizar transcript de YouTube |
| `library.get_stats` | Estadisticas de la biblioteca |
| `library.remove_folder` | Eliminar carpeta registrada |

## Library Module
- **DB:** SQLite con FTS5 en `~/.youtube-mcp/library.db`
- **Scanner:** Recorre carpetas, detecta videos por extension, extrae metadata con ffprobe
- **Auto-link:** Detecta video_id de YouTube del patron `[VIDEO_ID]` en filenames yt-dlp
- **Search:** Full-text search en filename/notes, filtros por tags, extension, duracion, resolucion
- **Config:** `LIBRARY_ENABLED`, `LIBRARY_DB_PATH`, `LIBRARY_SCAN_EXTENSIONS`, `LIBRARY_FFPROBE_TIMEOUT`

## Error Codes
| Rango | Categoria |
|-------|-----------|
| URL_1000-1099 | URL validation/parsing |
| TRANSCRIPT_1100-1199 | Subtitle extraction |
| METADATA_1200-1299 | Metadata extraction |
| WHISPER_1300-1399 | Audio transcription |
| PROCESSING_1400-1499 | Text processing |
| ARTIFACT_1500-1599 | Artifact generation |
| CACHE_1600-1699 | Caching |
| SYSTEM_1700-1799 | System-level |
| LIBRARY_1800-1899 | Library management |

## Agentes Recomendados
| Tarea | Agente |
|-------|--------|
| Implementar features | `python-backend-developer` |
| Tests | `test-engineer` |
| Code review | `code-reviewer` |
| MCP specifics | `mcp-server-developer` |
| Docker/CI | `devops-engineer` |

## Reglas del Proyecto
- Subtitulos primero, Whisper solo como fallback
- Output JSON deterministico
- Cache-first para performance
- Library: SQLite para indice local, ffprobe graceful degradation

## Docs
@C:/claude_context/mcp/youtube/TASK_STATE.md
@C:/claude_context/mcp/youtube/LEARNINGS.md
