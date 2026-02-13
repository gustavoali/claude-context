# Angular Web Monitor - Project Context

## Descripcion
Dashboard web para monitoreo del ecosistema de desarrollo. Interfaz Angular que consume REST API del Project Admin Backend.

## Ubicacion
- **Codigo:** C:/apps/web-monitor/
- **Contexto:** C:/claude_context/apps/web-monitor/
- **Clasificador:** apps

## Stack Tecnologico
- **Framework:** Angular 17+
- **Lenguaje:** TypeScript 5.x
- **UI Library:** Angular Material o PrimeNG (por definir)
- **State Management:** NgRx
- **Graficos:** ngx-charts o Chart.js
- **Testing:** Jasmine + Karma (unit), Cypress o Playwright (E2E)

## Documentacion del Proyecto
@C:/claude_context/apps/web-monitor/SEED_DOCUMENT.md
@C:/claude_context/apps/web-monitor/TEAM_PLANNING.md
@C:/claude_context/apps/web-monitor/TEAM_DEVELOPMENT.md

## Ecosistema
Consume datos de:
- Project Admin Backend (REST API) - fuente principal
- Claude Orchestrator (WebSocket) - sesiones real-time
- Sprint Backlog Manager (via Project Admin) - sprints y metricas

## Dependencias
Requiere Project Admin Backend operativo (Phase 1 completada).

## Estado
**Fase:** Planificacion completada, pendiente implementacion (Phase 2+).

---

**Ultima actualizacion:** 2026-02-12
