# IDEA-014: Extractor de transcripciones de YouTube

**Fecha:** 2026-02-12
**Categoria:** projects
**Estado:** Seed
**Prioridad:** Sin definir

---

## Descripcion

Desarrollar una herramienta similar a LTE pero orientada a YouTube. Extraer transcripciones/subtitulos de videos de YouTube para consumo, busqueda y analisis posterior.

## Puntos a definir

- **Formato:** Chrome Extension (como LTE), MCP server, CLI, o combinacion
- **Fuente de subtitulos:** YouTube API (captions), auto-generated, scraping de la pagina
- **Almacenamiento:** SQLite (como LTE), PostgreSQL, o integrar con algun sistema existente
- **Features posibles:** extraccion batch, busqueda full-text en transcripciones, export, organizacion por playlists/canales
- **Diferencia con YouTube RAG:** los proyectos RAG existentes (MVP, .NET, Old) apuntaban a RAG con embeddings. Este seria mas enfocado en extraccion y organizacion, no necesariamente RAG.

## Proyectos Relacionados

- LTE (C:/mcp/linkedin) - modelo a seguir, mismo concepto aplicado a LinkedIn Learning
- YouTube RAG MVP (C:/agents/youtube_rag_mvp) - iteracion previa con enfoque RAG
- YouTube MCP (C:/mcp/youtube) - PRD existente sin codigo, podria ser el mismo proyecto
- YouTube Jupyter (C:/agents/youtube_jupyter) - notebooks experimentales

## Notas

- Evaluar si retomar el PRD de YouTube MCP (ya tiene documentacion en claude_context) o arrancar de cero
- La experiencia con LTE (Chrome Extension + backend + DB) es directamente transferible
- YouTube tiene API oficial de captions, a diferencia de LinkedIn Learning que requiere scraping

---

## Historial

| Fecha | Evento |
|-------|--------|
| 2026-02-12 | Idea capturada |
