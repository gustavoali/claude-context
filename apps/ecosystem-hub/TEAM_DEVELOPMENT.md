# Team Development - Ecosystem Hub

## Equipo de Desarrollo

### Frontend Angular Developer (frontend-angular-developer)
**Perfil:** `AGENT_DEVELOPER_BASE.md` + `AGENT_DEVELOPER_ANGULAR.md`
**Responsabilidades:**
- Implementar modulos UI (Dashboard, Proyectos, Ideas, Alertas)
- Componentes PrimeNG 20 con Angular Signals
- Servicios HTTP para consumir backend
- Routing y navegacion entre modulos

**Contexto clave:**
- Angular 20 + PrimeNG 20 + standalone components
- State management con Signals (no NgRx)
- Web Monitor (`C:/apps/web-monitor/`) como referencia de patrones

### Backend Node.js Developer (nodejs-backend-developer)
**Perfil:** `AGENT_DEVELOPER_BASE.md` + `AGENT_DEVELOPER_NODEJS.md`
**Responsabilidades:**
- Extender Project Admin con endpoints para ideas, alertas, deadlines
- Migraciones PostgreSQL para tablas nuevas
- Script de importacion desde markdown
- MCP tools nuevas

**Contexto clave:**
- Fastify 5.x + ESM
- PostgreSQL 17 (container `project-admin-pg`, port 5433)
- Project Admin existente (`C:/mcp/project-admin/`) como base

### Database Expert (database-expert)
**Responsabilidades:**
- Disenar migraciones para tablas ideas, alerts, deadlines
- Optimizar queries para dashboard (agregaciones, conteos)
- Indices para filtros frecuentes (status, category, priority)

### Test Engineer (test-engineer)
**Perfil:** `AGENT_TESTER_BASE.md`
**Responsabilidades:**
- Tests unitarios para servicios Angular
- Tests de integracion para endpoints REST
- Tests E2E para flujos criticos (crear alerta, resolver alerta)

### Code Reviewer (code-reviewer)
**Perfil:** `AGENT_REVIEWER_BASE.md`
**Responsabilidades:**
- Review riguroso pre-PR
- Verificar adherencia a patrones de PA y web-monitor
- Seguridad: validacion de inputs, sanitizacion

## Orden de Ejecucion
1. **Fase 1:** database-expert (migraciones) -> nodejs-backend-developer (endpoints)
2. **Fase 2:** frontend-angular-developer (dashboard + alertas) en paralelo con backend
3. **Fase 3:** frontend-angular-developer (ideas)
4. **Transversal:** test-engineer y code-reviewer en cada fase
