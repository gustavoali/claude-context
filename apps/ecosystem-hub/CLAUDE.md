# Ecosystem Hub - Project Context
**Version:** 0.1.0 | **Tests:** 0 | **Coverage:** 0%
**Ubicacion:** C:/apps/ecosystem-hub
**Contexto:** C:/claude_context/apps/ecosystem-hub

## Stack
| Capa | Tecnologia |
|------|-----------|
| Frontend | Angular 20 + PrimeNG 20 + Signals |
| Backend | Node.js + Fastify 5.x (extension de Project Admin) |
| Base de datos | PostgreSQL 17 en Docker (container `project-admin-pg`, port 5433) |
| Auth | Sin auth (localhost only) |

## Concepto
Dashboard web para visualizar y gestionar alertas, ideas, proyectos y deadlines del ecosistema personal. Agrupa items por tema para facilitar la navegacion ante gran volumen de informacion dispersa en archivos markdown.

## Fuentes de Datos (MVP)
- `C:/claude_context/ALERTS.md` - alertas globales
- `C:/claude_context/ideas/IDEAS_INDEX.md` - 47 ideas categorizadas
- `C:/claude_context/project-registry.json` - 37 proyectos registrados
- Project Admin DB (PostgreSQL) - salud, metadata, relaciones

## Modulos UI
| Modulo | Descripcion | Fase |
|--------|-------------|------|
| Dashboard | Resumen ejecutivo, alertas urgentes, deadlines | Fase 2 |
| Proyectos | Vista completa del ecosistema con filtros | Fase 2 |
| Ideas | CRUD, filtros, transicion idea->proyecto | Fase 3 |
| Alertas & Deadlines | CRUD, historial, urgencia automatica | Fase 2 |

## Fases
| Fase | Descripcion | Estado |
|------|-------------|--------|
| 1 | Backend Extension (migraciones, REST, MCP tools) | Pendiente |
| 2 | Dashboard + Alertas UI | Pendiente |
| 3 | Ideas UI | Pendiente |
| 4 | Polish & Integracion (sync, docker compose) | Pendiente |

## Comandos
```bash
# Frontend
cd C:/apps/ecosystem-hub && ng serve    # Dev server
ng build                                 # Build

# Backend (Project Admin extendido)
cd C:/mcp/project-admin && npm run dev   # Dev server
```

## Relaciones
| Proyecto | Relacion |
|----------|---------|
| Project Admin (`pj pa`) | Backend a extender |
| Web Monitor (`pj wm`) | Frontend base (Angular + PrimeNG) |

## Agentes Recomendados
| Tarea | Agente |
|-------|--------|
| Frontend Angular | `frontend-angular-developer` |
| Backend Node.js | `nodejs-backend-developer` |
| Arquitectura | `software-architect` |
| Base de datos | `database-expert` |
| Tests | `test-engineer` |
| Code review | `code-reviewer` |

## Reglas del Proyecto
1. Reutilizar al maximo: extender PA backend y web-monitor frontend
2. MVP lee archivos MD/JSON directamente; DB es fase posterior
3. Sin auth por ahora (localhost only)

## Docs
@C:/claude_context/apps/ecosystem-hub/SEED_DOCUMENT.md
@C:/claude_context/apps/ecosystem-hub/ARCHITECTURE_ANALYSIS.md
@C:/claude_context/apps/ecosystem-hub/PRODUCT_BACKLOG.md
@C:/claude_context/apps/ecosystem-hub/TEAM_ANALYSIS.md
@C:/claude_context/apps/ecosystem-hub/TEAM_DEVELOPMENT.md
