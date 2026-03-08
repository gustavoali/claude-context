# IDEA-028: Investigar ZeroClaw - Runtime agentico en Rust

**Fecha:** 2026-02-22
**Categoria:** general
**Estado:** Seed
**Prioridad:** Sin definir

---

## Descripcion

ZeroClaw es un runtime/OS para workflows agenticos escrito 100% en Rust. Binario unico, <5MB RAM, startup <10ms. Arquitectura trait-driven donde todo es intercambiable: providers (LLMs), channels (Telegram, Discord, WhatsApp, Slack), tools, memoria y tunnels.

## Motivacion

- Referencia de arquitectura para Claude Personal (ITool vs traits de Rust)
- Aprendizaje de Rust con un proyecto real de produccion
- Benchmark comparativo .NET vs Rust para asistentes de IA
- Inspiracion para sistema de plugins y memoria

## Ubicacion

`C:/investigacion/zeroclaw/`

## Que investigar

- Arquitectura de traits para providers/tools/channels
- Sistema de memoria hibrido (SQLite/PostgreSQL)
- Streaming y manejo de conexiones
- Sandboxing y seguridad (pairing, allowlists, workspace scoping)
- Performance: como logran <5MB RAM y <10ms startup
- Sistema de canales multi-plataforma

## Proyectos relacionados

- Claude Personal (inspiracion directa)
- Claude Orchestrator (orquestacion de agentes)

## Notas

- Repo oficial: github.com/zeroclaw-labs/zeroclaw
- Licencia: MIT / Apache 2.0
- Creado por comunidad Harvard/MIT/Sundai.Club
- 27+ contributors

---

## Historial

| Fecha | Evento |
|-------|--------|
| 2026-02-21 | Repo clonado para estudio |
| 2026-02-22 | Idea registrada, movido a C:/investigacion/ |
