# Claude Personal - Equipo de Analisis

## Composicion

| Rol | Agente | Responsabilidad |
|-----|--------|-----------------|
| Arquitecto Backend | `software-architect` + perfil backend | Arquitectura del sistema, API client, tool registry, memoria |
| Product Owner | `product-owner` | Backlog, user stories, priorizacion de tools por tier |
| Project Manager | `project-manager` | Planning, sprints, milestones |
| Business Stakeholder | `business-stakeholder` | Validacion de scope MVP, decisiones de integraciones |

## Notas
- El arquitecto define la interfaz ITool y el patron de plugins
- El PO prioriza tools dentro de cada tier
- El PM coordina sprints alineados a los tiers de integracion
- Seguridad es transversal: cada tool debe pasar review de permisos
