# Backlog - Narrador
**Version:** 1.3 | **Actualizacion:** 2026-03-13

## Resumen
| Metrica | Valor |
|---------|-------|
| Total historias | 15 |
| Puntos totales | 45 |
| Epics | 5 |
| Completadas | 11 |
| Pendientes | 4 |

## Vision
MCP server en Python que transforma texto en contenido multimedia. Etapa 1: TTS con strategy
pattern para multiples providers (Edge TTS gratis como default). Etapa 2: imagenes. FastMCP.

## Epics
| Epic | Historias | Puntos | Status |
|------|-----------|--------|--------|
| EPIC-001: Project Setup | NRR-001, NRR-002 | 4 | Done |
| EPIC-002: TTS Core | NRR-003..NRR-008 | 20 | Done |
| EPIC-003: MCP Server | NRR-009, NRR-010 | 6 | Done |
| EPIC-004: Image Gen (Etapa 2) | NRR-011, NRR-012 | 6 | Placeholder |
| EPIC-005: Translation | NRR-015 | 5 | Pendiente |

## Pendientes (con detalle)

### NRR-011: Image provider base + DALL-E 3 (Etapa 2 placeholder)
**Points:** 3 | **Priority:** Low | **MoSCoW:** Won't Have (this release)

ImageProvider ABC + DALL-E 3 provider. No implementar hasta Etapa 1 completa.

---

### NRR-012: Text-to-prompt builder para imagenes (Etapa 2 placeholder)
**Points:** 3 | **Priority:** Low | **MoSCoW:** Won't Have (this release)

PromptBuilder: texto -> prompt optimizado para image generation. No implementar hasta Etapa 1 completa.

---

### NRR-014: narrate_pdf - Tool MCP para narrar archivos PDF
**Points:** 3 | **Priority:** Medium | **MoSCoW:** Should Have

**As a** usuario de Claude Code
**I want** pasar el path a un PDF y recibir un archivo de audio con su contenido narrado
**So that** no tenga que extraer el texto manualmente

#### Acceptance Criteria

**AC1: PDF valido genera audio**
- Given un path valido a un PDF con texto
- When invoco `narrate_pdf(pdf_path)`
- Then se extrae el texto, se genera el audio y se retorna el path al MP3

**AC2: PDF inexistente retorna error claro**
- Given un path a un PDF inexistente o inaccesible
- When invoco `narrate_pdf(pdf_path)`
- Then retorna un mensaje de error claro indicando que el archivo no existe o no es accesible

**AC3: PDF multipagina se narra completo en orden**
- Given un PDF con multiples paginas
- When invoco `narrate_pdf(pdf_path)`
- Then se narra el contenido completo en orden de paginas

**AC4: Parametro pages filtra rango de paginas**
- Given el parametro `pages` (ej: "1-3", "2")
- When invoco `narrate_pdf(pdf_path, pages="1-3")`
- Then solo se narra el rango de paginas indicado

**AC5: Parametro play reproduce automaticamente**
- Given `play=True`
- When se genera el audio del PDF
- Then se reproduce automaticamente al finalizar

#### Technical Notes
- Usar `pypdf` o `pdfplumber` para extraccion de texto (agregar a dependencias en pyproject.toml)
- Reutilizar internamente `narrate_text` (mismos providers, voice, lang, audio_format, play)
- Parametros: `pdf_path: str`, `pages: str = ""`, `provider: str = ""`, `voice: str = ""`, `lang: str = ""`, `audio_format: str = "mp3"`, `play: bool = False`
- El tool se expone en `server.py` con `@mcp.tool`

#### Definition of Done
- [ ] Tool `narrate_pdf` implementado en server.py
- [ ] Dependencia pypdf/pdfplumber agregada a pyproject.toml
- [ ] Tests unitarios con PDF mock
- [ ] Manual testing con PDF real
- [ ] Build 0 errores, 0 warnings

---

### NRR-015: Traduccion automatica de texto antes de narracion TTS
**Points:** 5 | **Priority:** High | **MoSCoW:** Should Have
**Epic:** EPIC-005: Translation

**As a** usuario de Claude Code
**I want** pasar un parametro `translate_to` en `narrate_text` o `narrate_pdf` indicando el idioma destino
**So that** pueda recibir audio narrado en castellano (u otro idioma) a partir de contenido originalmente en ingles u otro idioma, sin tener que traducir manualmente

#### Acceptance Criteria

**AC1: Traduccion basica en narrate_text**
- Given un texto en ingles y `translate_to="es-AR"`
- When invoco `narrate_text(text="Hello world", translate_to="es-AR")`
- Then el texto se traduce al espanol antes de sintetizar y el audio resultante contiene la narracion en espanol

**AC2: Traduccion en narrate_pdf**
- Given un PDF con contenido en ingles y `translate_to="es-AR"`
- When invoco `narrate_pdf(pdf_path="doc.pdf", translate_to="es-AR")`
- Then se extrae el texto del PDF, se traduce al espanol, y se narra

**AC3: Sin translate_to el comportamiento no cambia**
- Given un texto en cualquier idioma sin parametro `translate_to`
- When invoco `narrate_text(text="Hola mundo")`
- Then el texto se narra tal cual, sin traduccion, sin invocar ningun translation provider

**AC4: Texto largo se traduce por chunks**
- Given un texto de mas de 4000 caracteres en ingles y `translate_to="es-AR"`
- When invoco `narrate_text(text=texto_largo, translate_to="es-AR")`
- Then el texto se divide en chunks (respetando limites de parrafo/oracion), cada chunk se traduce secuencialmente, y el texto traducido completo se pasa al flujo normal de TTS

**AC5: Provider de traduccion no disponible retorna error claro**
- Given `translate_to="es-AR"` pero OPENAI_API_KEY no esta configurada
- When invoco `narrate_text(text="Hello", translate_to="es-AR")`
- Then retorna ToolError con mensaje indicando que el translation provider no esta disponible

**AC6: El parametro lang de TTS se ajusta automaticamente**
- Given `translate_to="es-AR"` y sin parametro `lang` explicito
- When se traduce el texto y se pasa a TTS
- Then `lang` para el TTS provider se resuelve al idioma destino; si el usuario paso `lang` explicitamente, prevalece

**AC7: Traduccion preserva estructura de parrafos**
- Given un texto con multiples parrafos separados por lineas vacias
- When se traduce con `translate_to="es-AR"`
- Then el texto traducido mantiene la separacion de parrafos original

#### Technical Notes
- `TranslationProvider` ABC en `src/narrador/translation/base.py`: `async def translate(text, target_lang, source_lang="") -> str` + `def is_available() -> bool`
- `OpenAITranslationProvider` en `src/narrador/translation/openai_translation.py` usando `gpt-4o-mini`
- Factory `get_translation_provider` con lazy init + cache (consistente con TTS factory)
- Chunking para traduccion: reutilizar `TextChunker` con ~3000 chars/chunk; traducir secuencialmente
- Config: `NARRADOR_TRANSLATION_PROVIDER=openai`, `NARRADOR_TRANSLATION_MODEL=gpt-4o-mini` en `.env.example`
- Sin dependencias nuevas (openai ya esta en pyproject.toml)

#### Definition of Done
- [ ] `TranslationProvider` ABC implementado
- [ ] `OpenAITranslationProvider` implementado con gpt-4o-mini
- [ ] Factory con lazy init y cache
- [ ] Parametro `translate_to` en `narrate_text` y `narrate_pdf`
- [ ] Auto-resolucion de `lang` cuando `translate_to` esta presente
- [ ] Config keys en `NarradorConfig` y `.env.example`
- [ ] Tests unitarios y de error (provider no disponible, idioma invalido)
- [ ] Tests existentes siguen pasando
- [ ] Build 0 errores, 0 warnings | Coverage >70% en modulos nuevos

---

## Completadas (indice)
| ID | Titulo | Puntos | Fecha | Detalle |
|----|--------|--------|-------|---------|
| NRR-001 | Scaffolding proyecto | 2 | 2026-03-11 | pyproject.toml, estructura, venv |
| NRR-002 | Config y API keys | 2 | 2026-03-11 | NarradorConfig, load_config, .env |
| NRR-003 | TTS provider base | 3 | 2026-03-11 | ABC, dataclasses, factory con cache |
| NRR-004 | Edge TTS provider | 3 | 2026-03-11 | Default gratis, voice resolution |
| NRR-005 | Text chunker | 3 | 2026-03-11 | Hibrido parrafo+oracion |
| NRR-006 | Audio assembler | 3 | 2026-03-11 | pydub async, generate_output_filename |
| NRR-007 | OpenAI TTS | 3 | 2026-03-11 | 6 voces, tts-1, lazy client |
| NRR-008 | ElevenLabs TTS | 3 | 2026-03-11 | API + fallback hardcoded |
| NRR-009 | Server narrate_text | 3 | 2026-03-11 | Tool MCP, progress reporting |
| NRR-010 | Server list_voices | 3 | 2026-03-11 | Tool MCP, tabla formateada |
| NRR-013 | play parameter en narrate_text | 1 | 2026-03-12 | Parametro `play=True` para reproducir audio con Start-Process PowerShell |

## ID Registry
| Rango | Estado |
|-------|--------|
| NRR-001 a NRR-015 | Asignados |
| NRR-016+ | Disponibles |
Proximo ID: NRR-016

## Orden de Implementacion
```
Ola 1 (setup):     NRR-001, NRR-002 (paralelo)
Ola 2 (core TTS):  NRR-003 -> NRR-004, NRR-005 (secuencial -> paralelo)
Ola 3 (assembly):  NRR-006 (depende de NRR-004 + NRR-005)
Ola 4 (MCP):       NRR-009 (depende de NRR-003..006) -> NRR-010
Ola 5 (providers): NRR-007, NRR-008 (paralelo, independientes)
Ola 6 (Etapa 2):   NRR-011, NRR-012 (post-MVP)
```
