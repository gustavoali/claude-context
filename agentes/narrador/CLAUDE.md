# Narrador - Project Context
**Version:** 0.1.0 | **Tests:** 121 pasando | **Coverage:** ~80%
**Ubicacion:** C:/agentes/narrador
**Estado:** Etapa 1 TTS completa (10/12 historias)

## Descripcion
MCP server en Python que transforma texto en contenido multimedia: audio hablado (TTS) e imagenes generadas. Expone tools via FastMCP para uso desde Claude Code.

## Stack
- Python 3.11+
- FastMCP (mcp[cli])
- TTS: edge-tts (default gratis), openai, elevenlabs
- Image Gen: openai (DALL-E), diffusers (Stable Diffusion local)
- Audio: pydub, soundfile
- Testing: pytest
- Config: python-dotenv

## Componentes
| Componente | Ubicacion | Estado |
|------------|-----------|--------|
| MCP Server | src/narrador/server.py | Done (narrate_text, list_voices) |
| TTS Providers | src/narrador/tts/ | Done (edge-tts, openai, elevenlabs) |
| Image Providers | src/narrador/imagegen/ | Pendiente (Etapa 2) |
| Text Chunker | src/narrador/text/chunker.py | Done |
| Audio Assembler | src/narrador/audio/assembler.py | Done |

## Comandos
```bash
cd C:/agentes/narrador
.venv/Scripts/activate
python -m narrador.server          # Run MCP server
pytest                              # Run tests
pip install -e ".[dev]"            # Install with dev deps
```

## Agentes Recomendados
| Tarea | Agente |
|-------|--------|
| Implementar providers/server | python-backend-developer |
| Arquitectura | software-architect + backend |
| Tests | test-engineer |
| Code review | code-reviewer |

## Reglas del Proyecto
- Strategy pattern para providers (nunca eliminar un provider operativo)
- Edge TTS como default (gratis, sin API key)
- API keys via .env, nunca hardcodeadas
- Output de audio/imagenes en carpeta configurable

## Docs
@C:/claude_context/agentes/narrador/SEED_DOCUMENT.md
@C:/claude_context/agentes/narrador/TASK_STATE.md
@C:/claude_context/agentes/narrador/ARCHITECTURE_ANALYSIS.md
@C:/claude_context/agentes/narrador/PRODUCT_BACKLOG.md
