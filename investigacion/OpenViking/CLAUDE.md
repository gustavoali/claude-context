# OpenViking - Project Context
**Version:** 0.1.0 | **Tipo:** Investigacion / Analisis
**Ubicacion:** C:/proyectos/investigacion/OpenViking/
**Inicio:** 2026-03-24

## Proposito
Analizar OpenViking (Context Database for AI Agents de ByteDance) para extraer ideas
aplicables a nuestra infraestructura de contexto en claude_context/.

## Stack
- Python 3.10+ (core)
- Rust (CLI)
- Go 1.22+ (AGFS components)
- C++ (core extensions)
- Docker (deployment)

## Puntos de Interes
1. **Filesystem paradigm** - Organizacion de contexto como sistema de archivos virtual
2. **Tiered loading L0/L1/L2** - Carga progresiva de contexto (100 -> 2K tokens)
3. **Session management** - Compresion automatica y extraccion de memoria long-term
4. **Retrieval trajectory** - Observabilidad de que informacion consulto el agente
5. **Directory recursive retrieval** - Posicionamiento por directorio + busqueda semantica

## Analogias con Nuestra Infraestructura
| OpenViking | claude_context/ |
|------------|----------------|
| Virtual filesystem | Estructura de carpetas real |
| L0 summary | CLAUDE.md (resumen, max 150 lineas) |
| L1 detail | TASK_STATE / BACKLOG (detalle activo) |
| L2 full | archive/ (detalle completo) |
| Session management | /close-session + observation masking |
| Retrieval trajectory | Directiva 12d (observabilidad de contexto) |

## Objetivo del Analisis
- Que patrones de OpenViking podemos adoptar/adaptar?
- Hay ideas para mejorar nuestro sistema de archivado y carga progresiva?
- El concepto de "retrieval trajectory" puede formalizarse mejor en nuestra metodologia?

## Documentacion
@C:/claude_context/investigacion/OpenViking/TASK_STATE.md

## Agentes Recomendados
| Tarea | Agente |
|-------|--------|
| Analisis de arquitectura | `software-architect` |
| Exploracion de codigo | `Explore` agent |
| Comparacion con nuestra infra | Coordinador (Claude) |
