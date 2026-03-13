# Seed Document - Narrador
**Fecha:** 2026-03-09
**Origen:** Descripcion verbal del usuario + alerta ALERTS.md

## Vision
Agente que transforma texto en contenido multimedia: audio hablado (TTS) e imagenes generadas a partir del contenido textual.

## Objetivo
Construir un MCP server en Python que exponga tools para:
1. **Etapa 1 (TTS):** Recibir texto y producir audio hablado en multiples idiomas y voces
2. **Etapa 2 (Image Gen):** Recibir texto y generar imagenes que ilustren el contenido

## Alcance

### Etapa 1 - Text-to-Speech
- Recibir texto plano o markdown como input
- Soportar multiples providers de TTS (strategy pattern):
  - OpenAI TTS API (alta calidad, pago)
  - Edge TTS (gratis, Microsoft, buena calidad)
  - ElevenLabs (alta calidad, voces custom, pago)
  - Offline local (pyttsx3 o similar, como fallback)
- Chunking inteligente: dividir textos largos en segmentos naturales (parrafos, oraciones)
- Concatenar audio chunks en un archivo final
- Soportar multiples idiomas (al menos espanol e ingles)
- Output: MP3 o WAV
- Seleccion de voz por nombre o ID del provider

### Etapa 2 - Image Generation
- Recibir texto y extraer conceptos clave para generar prompts de imagen
- Soportar multiples providers:
  - OpenAI DALL-E 3 (pago)
  - Stable Diffusion (local via diffusers, gratis)
  - Stability AI API (pago)
- Generar imagenes que ilustren secciones del texto
- Output: PNG o JPG
- Configurar estilo, tamano, cantidad de imagenes

### Futuro (fuera de scope inicial)
- Video generation combinando audio + imagenes
- Subtitulos sincronizados
- Narracion de PDFs completos con imagenes intercaladas

## Stack
- **Lenguaje:** Python 3.11+
- **MCP Framework:** FastMCP (mcp[cli])
- **TTS Providers:** openai, edge-tts, elevenlabs-python
- **Image Providers:** openai (DALL-E), diffusers + torch (Stable Diffusion local)
- **Audio processing:** pydub, soundfile
- **Text processing:** Built-in + opcional spacy para chunking avanzado
- **Config:** python-dotenv para API keys
- **Testing:** pytest

## Arquitectura (propuesta inicial)
```
narrador/
  src/
    narrador/
      __init__.py
      server.py          # FastMCP server + tools
      config.py           # Settings, env vars, defaults
      tts/
        __init__.py
        base.py           # TTSProvider abstract base
        openai_tts.py     # OpenAI TTS
        edge_tts.py       # Edge TTS (gratis)
        elevenlabs_tts.py # ElevenLabs
        offline_tts.py    # pyttsx3 fallback
      imagegen/
        __init__.py
        base.py           # ImageProvider abstract base
        dalle.py          # DALL-E 3
        stable_diffusion.py # Local SD
      text/
        __init__.py
        chunker.py        # Text splitting logic
        prompt_builder.py # Text -> image prompt
      audio/
        __init__.py
        assembler.py      # Concatenar chunks de audio
  tests/
  .env.example
  pyproject.toml
```

## Riesgos
| Riesgo | Probabilidad | Impacto | Mitigacion |
|--------|-------------|---------|------------|
| Costos de APIs (OpenAI, ElevenLabs) | Alta | Medio | Edge TTS gratis como default, APIs pagas opcionales |
| Latencia en generacion local (SD) | Alta | Medio | CUDA si disponible, fallback a API |
| Tamano de modelos locales (SD, Whisper) | Media | Alto | Descargar bajo demanda, documentar requerimientos |
| Rate limits de APIs | Media | Bajo | Retry con backoff, chunking con delays |

## Criterios de Exito Etapa 1
- Tool MCP `narrate_text` que reciba texto y devuelva path a archivo de audio
- Al menos 2 providers funcionando (Edge TTS + OpenAI)
- Soporte espanol e ingles
- Textos de hasta 10,000 caracteres procesados correctamente
