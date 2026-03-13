# Arquitectura - Narrador
**Version:** 0.1.0 | **Fecha:** 2026-03-10

## Diagrama de Componentes

```
+------------------------------------------------------------------+
|                        FastMCP Server                             |
|  server.py                                                        |
|  +------------------------------------------------------------+  |
|  | @mcp.tool narrate_text(text, voice, lang, provider, ...)   |  |
|  | @mcp.tool list_voices(provider, lang)                      |  |
|  | @mcp.tool generate_image(text, provider, style, size, ...) |  |
|  +------------------------------------------------------------+  |
+----------|-------------------|--------------------|---------------+
           |                   |                    |
     +-----v------+    +------v-------+    +-------v--------+
     | TTS Engine |    | ImageGen     |    | Config         |
     | tts/       |    | Engine       |    | config.py      |
     |            |    | imagegen/    |    | .env           |
     +-----+------+    +------+-------+    +----------------+
           |                  |
  +--------+--------+   +----+----------+
  | TTSProvider      |   | ImageProvider |
  | (ABC)            |   | (ABC)        |
  +--+----+----+--+--+   +--+-----+----+
     |    |    |  |          |     |
  Edge OpenAI EL Offline  DALLE  SD
  TTS  TTS   TTS  TTS     API  Local
```

```
narrate_text flow:
  text --> [TextChunker] --> chunks[]
              |
              v
  chunks --> [TTSProvider.synthesize()] --> audio_bytes[]
              |
              v
  audio_bytes --> [AudioAssembler.concatenate()] --> final.mp3
              |
              v
  return path to final.mp3 (str)
```

## Componentes

| Componente | Archivo | Responsabilidad |
|------------|---------|-----------------|
| MCP Server | `src/narrador/server.py` | Definir tools, orquestar flujo, progress reporting |
| Config | `src/narrador/config.py` | Cargar .env, defaults, validar settings |
| TTS Base | `src/narrador/tts/base.py` | ABC para providers TTS + dataclasses compartidas |
| Edge TTS | `src/narrador/tts/edge_tts_provider.py` | Provider gratuito Microsoft Edge |
| OpenAI TTS | `src/narrador/tts/openai_tts.py` | Provider OpenAI TTS API |
| ElevenLabs TTS | `src/narrador/tts/elevenlabs_tts.py` | Provider ElevenLabs |
| Text Chunker | `src/narrador/text/chunker.py` | Dividir texto en segmentos para TTS |
| Audio Assembler | `src/narrador/audio/assembler.py` | Concatenar audio chunks en archivo final |
| ImageGen Base | `src/narrador/imagegen/base.py` | ABC para providers de imagen |
| DALL-E | `src/narrador/imagegen/dalle.py` | Provider OpenAI DALL-E 3 |
| Prompt Builder | `src/narrador/text/prompt_builder.py` | Texto -> prompt para generacion de imagen |

## Flujo de Datos

### narrate_text (Etapa 1)

```
1. Cliente MCP invoca narrate_text(text, provider?, voice?, lang?)
2. server.py resuelve provider (default: edge-tts)
3. server.py resuelve output_dir (config o default ~/narrador_output/)
4. TextChunker.chunk(text) -> list[TextChunk]
   - Divide por parrafos, luego por oraciones si excede max_chars
   - Preserva orden y metadata (indice, texto original)
5. Para cada chunk: TTSProvider.synthesize(chunk.text, voice, lang) -> bytes
   - ctx.report_progress(i, total_chunks) para feedback
6. AudioAssembler.concatenate(audio_segments, output_path, format) -> Path
   - Concatena bytes de audio en archivo final
7. Retorna str con path absoluto al archivo generado
```

### generate_image (Etapa 2)

```
1. Cliente MCP invoca generate_image(text, provider?, style?, size?)
2. server.py resuelve provider (default: dalle)
3. PromptBuilder.build(text, style) -> str (prompt optimizado)
4. ImageProvider.generate(prompt, size) -> bytes
5. Guarda imagen en output_dir con nombre unico
6. Retorna str con path absoluto al archivo generado
```

### list_voices (auxiliar)

```
1. Cliente invoca list_voices(provider?, lang?)
2. TTSProvider.list_voices(lang) -> list[VoiceInfo]
3. Retorna lista formateada como texto
```

## Folder Structure

```
C:/agentes/narrador/
  src/
    narrador/
      __init__.py
      server.py              # FastMCP server, tool definitions
      config.py              # Settings dataclass, env loading
      tts/
        __init__.py
        base.py              # TTSProvider ABC, VoiceInfo, SynthesisResult
        edge_tts_provider.py # Edge TTS (default, gratis)
        openai_tts.py        # OpenAI TTS API
        elevenlabs_tts.py    # ElevenLabs API
      imagegen/
        __init__.py
        base.py              # ImageProvider ABC, ImageResult
        dalle.py             # DALL-E 3 via OpenAI API
      text/
        __init__.py
        chunker.py           # TextChunker: texto -> chunks
        prompt_builder.py    # Texto -> prompt de imagen
      audio/
        __init__.py
        assembler.py         # Concatenar segmentos de audio
  tests/
    __init__.py
    test_chunker.py
    test_assembler.py
    test_edge_tts.py
    test_server.py
    conftest.py
  .env.example
  pyproject.toml
  README.md
```

## Interfaces y Contratos

### Dataclasses

```python
from dataclasses import dataclass, field
from pathlib import Path
from enum import Enum

class AudioFormat(str, Enum):
    MP3 = "mp3"
    WAV = "wav"

@dataclass(frozen=True)
class TextChunk:
    index: int
    text: str
    char_offset: int  # posicion en texto original

@dataclass(frozen=True)
class VoiceInfo:
    id: str              # ID del provider (ej: "es-AR-TomasNeural")
    name: str            # nombre legible
    lang: str            # codigo idioma (ej: "es-AR")
    gender: str          # "Male" | "Female"
    provider: str        # "edge-tts" | "openai" | "elevenlabs"

@dataclass(frozen=True)
class SynthesisResult:
    audio_data: bytes
    format: AudioFormat
    duration_ms: int     # duracion estimada, 0 si no disponible

@dataclass
class NarradorConfig:
    output_dir: Path = field(default_factory=lambda: Path.home() / "narrador_output")
    default_tts_provider: str = "edge-tts"
    default_image_provider: str = "dalle"
    default_voice: str = ""           # vacio = default del provider
    default_lang: str = "es-AR"
    default_audio_format: AudioFormat = AudioFormat.MP3
    chunk_max_chars: int = 4000       # max caracteres por chunk
    openai_api_key: str = ""
    elevenlabs_api_key: str = ""
```

### Abstract Base Classes

```python
from abc import ABC, abstractmethod

class TTSProvider(ABC):
    """Base para todos los providers de text-to-speech."""

    @abstractmethod
    async def synthesize(
        self, text: str, voice: str, lang: str
    ) -> SynthesisResult:
        """Convierte texto a audio. Retorna bytes del audio."""
        ...

    @abstractmethod
    async def list_voices(self, lang: str = "") -> list[VoiceInfo]:
        """Lista voces disponibles, opcionalmente filtradas por idioma."""
        ...

    @abstractmethod
    def is_available(self) -> bool:
        """True si el provider esta configurado y listo para usar."""
        ...

class ImageProvider(ABC):
    """Base para todos los providers de generacion de imagenes."""

    @abstractmethod
    async def generate(
        self, prompt: str, size: str, n: int
    ) -> list[bytes]:
        """Genera n imagenes a partir del prompt. Retorna lista de bytes PNG."""
        ...

    @abstractmethod
    def is_available(self) -> bool:
        """True si el provider esta configurado y listo para usar."""
        ...
```

### Text Processing

```python
class TextChunker:
    def __init__(self, max_chars: int = 4000) -> None: ...

    def chunk(self, text: str) -> list[TextChunk]:
        """Divide texto en chunks respetando limites de oracion/parrafo."""
        ...

class AudioAssembler:
    @staticmethod
    async def concatenate(
        segments: list[bytes],
        output_path: Path,
        audio_format: AudioFormat,
    ) -> Path:
        """Concatena segmentos de audio en un unico archivo. Retorna path."""
        ...
```

### MCP Tools (signatures)

```python
from fastmcp import FastMCP, Context

mcp = FastMCP("Narrador")

@mcp.tool
async def narrate_text(
    text: str,
    provider: str = "",        # "edge-tts" | "openai" | "elevenlabs"
    voice: str = "",           # voice ID, vacio = default del provider
    lang: str = "",            # "es-AR", "en-US", etc. vacio = config default
    audio_format: str = "mp3", # "mp3" | "wav"
    ctx: Context = ...,
) -> str:
    """Convierte texto a audio hablado. Retorna path al archivo generado."""
    ...

@mcp.tool
async def list_voices(
    provider: str = "",
    lang: str = "",
    ctx: Context = ...,
) -> str:
    """Lista voces disponibles para el provider indicado."""
    ...

@mcp.tool
async def generate_image(
    text: str,
    provider: str = "",       # "dalle"
    style: str = "",          # estilo visual (ej: "realistic", "illustration")
    size: str = "1024x1024",
    ctx: Context = ...,
) -> str:
    """Genera una imagen basada en el texto. Retorna path al archivo."""
    ...
```

## ADRs (Architecture Decision Records)

### ADR-001: Return type de MCP tools - str path vs FastMCP native types

**Contexto:** FastMCP soporta `Image(path=...)`, `Audio(path=...)`, `File(path=...)` como return types nativos (base64 embebido). Alternativa: retornar `str` con path.

| Opcion | Pros | Contras |
|--------|------|---------|
| A: `Image`/`Audio` nativos | Embebido en respuesta, sin acceso a FS | Audio >1MB en base64, overhead |
| B: `str` path al archivo | Eficiente, archivo persistido | Requiere acceso local al FS |

**Decision:** B. Audio puede ser varios MB; base64 no escala. Server corre local (stdio), cliente siempre tiene acceso al FS. Reconsiderar para imagenes (mas chicas).

### ADR-002: Provider resolution - Factory con lazy init

**Contexto:** Resolver provider dado un string ("edge-tts", "openai").

| Opcion | Pros | Contras |
|--------|------|---------|
| A: Dict estatico | Simple, O(1) | Sin lazy init ni verificacion |
| B: Factory + lazy init + cache | Instancia solo si se usa, verifica disponibilidad | Mas codigo |
| C: Plugin system (entry_points) | Extensible sin tocar core | Over-engineering |

**Decision:** B. Providers con API keys no deben instanciarse si no se usan. Factory cachea instancias y verifica `is_available()` antes de retornar.

```python
_providers: dict[str, TTSProvider] = {}

def get_tts_provider(name: str, config: NarradorConfig) -> TTSProvider:
    if name in _providers:
        return _providers[name]
    provider = _create_provider(name, config)
    if not provider.is_available():
        raise ToolError(f"Provider '{name}' not available. Check API keys.")
    _providers[name] = provider
    return provider
```

### ADR-003: Chunking strategy - hibrido parrafo + oracion

**Contexto:** Providers TTS tienen limites de chars (OpenAI 4096, Edge TTS ~64K).

| Opcion | Pros | Contras |
|--------|------|---------|
| A: Solo parrafos | Simple | Parrafos largos exceden limites |
| B: Solo oraciones | Granular | Demasiados chunks, audio fragmentado |
| C: Hibrido parrafo-primero | Estructura natural + maneja largos | Edge cases puntuacion |

**Decision:** C. Algoritmo: (1) dividir por parrafos, (2) si excede `chunk_max_chars` dividir por oraciones, (3) agrupar oraciones hasta llenar chunk, (4) nunca cortar a mitad de oracion.

### ADR-004: Audio concatenation - pydub

**Contexto:** Chunks de audio deben concatenarse en archivo final.

| Opcion | Pros | Contras |
|--------|------|---------|
| A: pydub (AudioSegment) | Crossfade, normalizacion, multi-formato | Requiere ffmpeg |
| B: Raw bytes append | Sin deps, rapido | Requiere mismo codec/bitrate exacto |

**Decision:** A. pydub es estandar, crossfade elimina cortes abruptos, maneja diferencias de sample rate. ffmpeg instalable via `imageio-ffmpeg`.

### ADR-005: Output file naming - timestamp + hash

**Contexto:** Archivos generados necesitan nombre unico.

| Opcion | Pros | Contras |
|--------|------|---------|
| A: UUID4 | Unico, simple | No informativo |
| B: Timestamp ISO | Ordenable | Colision si mismo segundo |
| C: Timestamp + hash corto | Ordenable, rastreable, unico | Nombre mas largo |

**Decision:** C. Formato: `2026-03-10T14-30-00_a1b2c3.mp3` (timestamp filename-safe + 6 chars SHA256 del input).

## Testing Strategy

- **Unit tests** (sin deps externas): TextChunker, AudioAssembler (mock pydub), provider factory (mock providers), Config
- **Integration tests** (`@pytest.mark.integration`): Edge TTS synthesize (internet), OpenAI TTS (API key), narrate_text E2E
- **Mocking:** providers con `AsyncMock` para tests de server. Fixtures en `conftest.py` con config de test, texto ejemplo, `tmp_path`
- **Coverage targets:** TextChunker >90%, AudioAssembler >80%, Server tools >70%, Overall >70%

## Performance Targets

| Metrica | Target |
|---------|--------|
| narrate_text 1K chars (Edge TTS) | <5s |
| narrate_text 10K chars (Edge TTS) | <30s |
| Chunker 50K chars | <100ms |
| Memory peak | <200MB |
| Server startup | <2s |

## Technical Debt a Monitorear

| ID | Descripcion | Cuando actuar |
|----|-------------|---------------|
| TD-001 | Sin retry/backoff en providers API | Si se usa en batch/produccion |
| TD-002 | Chunker regex simple para oraciones | Si se agregan idiomas CJK |
| TD-003 | Audio segments en memoria completa | Si textos >50K chars |
| TD-004 | Sin streaming de audio | Si se necesita feedback real-time |
| TD-005 | Provider cache global (module-level) | Si multi-tenancy |

## Stack

Python 3.11+, FastMCP (mcp[cli]), edge-tts, openai, elevenlabs, pydub, python-dotenv, pytest, pytest-asyncio
