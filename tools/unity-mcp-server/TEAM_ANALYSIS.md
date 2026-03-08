# Unity MCP Server - Equipo de Analisis

## Composicion

| Rol | Agente | Responsabilidad |
|-----|--------|-----------------|
| Arquitecto General | `software-architect` | Arquitectura MCP server, threading model, extensibilidad |
| Product Owner | `product-owner` | Backlog, historias, priorizacion de tools |
| Project Manager | `project-manager` | Planning, milestones, dependencias con proyectos consumidores |
| Business Stakeholder | `business-stakeholder` | Validacion de scope, decisiones de herramienta vs manual |

## Notas
- El arquitecto define el patron de extensibilidad (agregar tools sin tocar core)
- El PO prioriza tools basandose en cuales desbloquean mas trabajo manual en proyectos consumidores
- El PM coordina dependencias: Gaia Protocol (GP-033) depende de UMS EPIC-001 + EPIC-003
- El business stakeholder evalua ROI: horas ahorradas en setup manual vs horas de desarrollo del server
