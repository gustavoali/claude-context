# YouTube RAG MVP (Texto + Imágenes + OCR)

Este proyecto es un MVP para:
1) Descargar un video de YouTube
2) Extraer audio y transcribir (Whisper / Faster-Whisper)
3) Muestrear frames y aplicar OCR
4) Crear embeddings (texto + visión) e indexar con FAISS
5) Consultar vía FastAPI (RAG simple).

> **Nota**: Es un MVP educativo. Ajusta modelos, tamaños y manejo de errores para producción.

---

## Requisitos

- **Python 3.10+**
- **FFmpeg** instalado y en el PATH
- **Tesseract OCR** instalado y en el PATH
- (Opcional) GPU CUDA para acelerar `faster-whisper` y CLIP

### Windows (resumen)
- FFmpeg: descarga binarios de ffmpeg.org o gyan.dev, descomprime y agrega `/bin` a **PATH**.
- Tesseract: instala desde UB Mannheim (tesseract-ocr-w32/w64). Asegúrate que `tesseract.exe` quede en PATH.

### Linux/macOS
- FFmpeg: `sudo apt-get install ffmpeg` (Debian/Ubuntu) o `brew install ffmpeg` (macOS).
- Tesseract: `sudo apt-get install tesseract-ocr` o `brew install tesseract`.

---

## Instalación

```bash
python -m venv .venv
# Windows
.venv\Scripts\activate
# Linux/macOS
source .venv/bin/activate

pip install --upgrade pip
pip install -r requirements.txt
```

Crea tu archivo `.env` a partir de `.env.example` si vas a usar un LLM externo:
```bash
cp .env.example .env
# y completa OPENAI_API_KEY si quieres respuesta generativa (opcional)
```

---

## Uso rápido (línea de comando)

**1) Ingesta de un video:**
```bash
python ingest/index.py --url "https://www.youtube.com/watch?v=XXXXXXXXXXX" --every 4
```
- Descarga el video, extrae audio, transcribe, extrae frames cada 4s (ajustable) y hace OCR.
- Crea embeddings (texto+visión) e indexa con FAISS en `data/<video_id>`.

**2) Servir la API:**
```bash
uvicorn app.main:app --reload
```
- Endpoint de consulta:
  - `GET /ask?q=tu+pregunta&top_k=5`
- Endpoint de ingesta:
  - `POST /ingest` con JSON: `{ "url": "https://www.youtube.com/watch?v=..." , "every": 4 }`

**Ejemplo:**
```bash
curl "http://127.0.0.1:8000/ask?q=¿De%20qué%20trata%20este%20video?&top_k=5"
```

---

## Estructura

```
.
├─ app/
│  ├─ main.py        # FastAPI (ingest + ask)
│  ├─ rag.py         # Búsqueda en índices + síntesis (opcional vía LLM)
│  └─ config.py      # Carga de .env, rutas, helpers
├─ ingest/
│  ├─ download.py    # yt-dlp (descarga y metadatos)
│  ├─ transcribe.py  # Whisper / Faster-Whisper
│  ├─ frames.py      # Extracción de frames
│  ├─ ocr.py         # OCR por frame
│  └─ index.py       # Orquestación e indexación (CLI)
├─ utils/
│  ├─ audio.py       # ffmpeg (wav 16k mono)
│  ├─ text.py        # chunking de texto
│  ├─ embeddings.py  # texto (Sentence-Transformers)
│  └─ vision.py      # CLIP (imagen + texto->espacio CLIP)
├─ data/             # salidas por video_id
├─ requirements.txt
├─ .env.example
└─ README.md
```

---

## Notas de rendimiento

- Cambia los modelos si tu máquina es modesta:
  - `faster-whisper` con modelo `"base"` o `"small"`
  - Sentence-Transformers `"all-MiniLM-L6-v2"` (rápido y decente)
  - CLIP `"openai/clip-vit-base-patch32"` (ligero)
- Baja `--every` (por ejemplo, 6 u 8 segundos) para menos frames/embeddings.
- En GPU: `torch` con CUDA acelera CLIP y faster-whisper.

---

## Licencia

MIT (ajústala si necesitas otra).
