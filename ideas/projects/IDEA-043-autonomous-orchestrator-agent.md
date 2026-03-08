# IDEA-043: Agente Autonomo sobre Orchestrator con Telegram

**Fecha:** 2026-03-05
**Categoria:** projects
**Estado:** In Progress
**Prioridad:** Alta

---

## Descripcion

Agente autonomo que se monta sobre el Claude Orchestrator existente, centralizando la operacion de todas las sesiones abiertas. Opera de forma autonoma conduciendo las sesiones y se comunica via Telegram con el usuario cuando necesita instrucciones o aprobacion.

## Motivacion

Actualmente el orchestrator es pasivo: crea sesiones y envia instrucciones cuando se le pide. No hay un "cerebro" que coordine autonomamente multiples sesiones, priorice trabajo, detecte bloqueos, y tome decisiones de ruteo. El usuario debe estar presente en la terminal para dirigir. Con un agente autonomo + Telegram, el usuario puede supervisar remotamente desde el celular mientras el agente trabaja.

## Capacidades del Agente

1. **Gestion autonoma de sesiones**: Crear, monitorear, pausar, reanudar sesiones segun prioridades
2. **Coordinacion multi-proyecto**: Detectar dependencias entre sesiones, secuenciar trabajo
3. **Deteccion de bloqueos**: Identificar cuando una sesion esta estancada y tomar accion
4. **Escalamiento via Telegram**: Consultar al usuario cuando necesita decisiones (aprobacion, clarificacion, prioridad)
5. **Reporte de progreso**: Notificar via Telegram avances, completados, errores
6. **Manejo de backlog**: Tomar historias del sprint backlog y asignarlas a sesiones

## Alcance Estimado

Grande

## Proyectos Relacionados

- Claude Orchestrator (C:/mcp/claude-orchestrator) - Base sobre la que se monta
- Claude Monitor Flutter (integracion Telegram existente)
- Sprint Backlog Manager (fuente de trabajo)
- Project Admin (registro de proyectos)
- AI SDK Provider Claude Code (patrones de mid-session injection y subagent tracking)

## Arquitectura Preliminar

```
┌──────────────────────────────────────────────────┐
│              AUTONOMOUS AGENT                      │
│                                                    │
│  ┌────────────┐  ┌─────────────┐  ┌───────────┐  │
│  │ Decision    │  │ Session     │  │ Telegram  │  │
│  │ Engine      │  │ Conductor   │  │ Bridge    │  │
│  │             │  │             │  │           │  │
│  │ - Priorizar │  │ - Crear     │  │ - Notify  │  │
│  │ - Asignar   │  │ - Instruir  │  │ - Ask     │  │
│  │ - Escalar   │  │ - Monitorear│  │ - Report  │  │
│  └──────┬──────┘  └──────┬──────┘  └─────┬─────┘  │
│         │                │                │        │
│         └────────────────┼────────────────┘        │
│                          │                          │
└──────────────────────────┼──────────────────────────┘
                           │
              ┌────────────▼────────────┐
              │   CLAUDE ORCHESTRATOR    │
              │   (MCP + WS + HTTP)     │
              └────────────┬────────────┘
                           │
              ┌────────────▼────────────┐
              │   AGENT SESSIONS        │
              │   Session 1..N          │
              └─────────────────────────┘
```

## Notas

- El Flutter app ya tiene integracion Telegram bidireccional que podria reutilizarse
- El ai-sdk-provider-claude-code tiene patron de mid-session injection util para interrumpir sesiones
- Podria implementarse como otro MCP server o como proceso standalone
- Considerar si el agente autonomo es un Claude Code session que usa el orchestrator como MCP tool (meta-nivel)

---

## Historial

| Fecha | Evento |
|-------|--------|
| 2026-03-05 | Idea capturada |
| 2026-03-05 | Sembrado: proyecto atlas-agent creado con ADRs y backlog (8 historias, 44 pts) |
| 2026-03-05 | Brotado: ARCHITECTURE_ANALYSIS.md + scaffolding completo. Listo para desarrollo. |
