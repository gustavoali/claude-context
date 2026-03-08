# IDEA-027: Investigar TensorLake - Plataforma de ingestion de documentos

**Fecha:** 2026-02-22
**Categoria:** general
**Estado:** Seed
**Prioridad:** Sin definir

---

## Descripcion

TensorLake es una plataforma open source para transformar documentos no estructurados (PDFs, DOCX, spreadsheets, presentaciones, imagenes, texto) en datos listos para IA. Ofrece ingestion de documentos a markdown, extraccion de datos estructurados con JSON Schema/Pydantic, y un runtime serverless para pipelines de procesamiento de datos.

## Motivacion

Herramienta potencialmente util para varios proyectos propios que trabajan con documentos:
- LinkedIn MCP / LTE: extraccion de transcripciones
- YouTube MCP: procesamiento de contenido
- Claude Personal: tool de lectura/analisis de documentos
- File Reader MCP: alternativa o complemento

## Ubicacion actual

`C:/claude_context/agents/tensorlake/` (solo README y docs, no es un clone completo)

## Que investigar

- Calidad de extraccion de PDFs comparado con PyMuPDF
- Capacidad de extraccion de tablas, figuras, firmas
- API de deploy serverless (util para pipelines)
- Integracion posible con nuestros MCP servers
- Costos del servicio cloud vs self-hosted
- Repo oficial: github.com/tensorlakeai/tensorlake

## Notas

- Instalacion: `pip install tensorlake`
- Tiene SDK de Python
- No es un proyecto propio, es herramienta de terceros para estudio

---

## Historial

| Fecha | Evento |
|-------|--------|
| 2026-02-22 | Idea registrada para investigacion futura |
