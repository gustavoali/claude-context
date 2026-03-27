# Estado - Ecosystem Hub
**Actualizacion:** 2026-03-27 | **Version:** 0.1.0

## Completado Esta Sesion (2026-03-25/27)

**Overview:** EPIC-03 Ideas UI: completar 3 historias pendientes | 3/3 Done | Build OK, testing pendiente

**Pasos clave:**
- EH-015 delegado a agente angular, implemento dialog "Crear Proyecto" con slug suggestion, flujo POST proyecto + PUT idea
- EH-016 implementado manualmente (agente rate-limited): columna Proyecto en tabla, link/unlink, filtro por proyecto
- EH-017 implementado: seccion "Ideas Relacionadas" en detalle de proyecto con navegacion cruzada

| ID | Titulo | Resultado |
|----|--------|-----------|
| EH-015 | Ideas - transicion idea a proyecto | Dialog pre-llenado, createProject() en ProjectsService, slug validation, flujo 2-step (POST project + PUT idea) |
| EH-016 | Ideas - vinculacion proyectos | Boton vincular/desvincular, columna Proyecto con tag, filtro dropdown (incl "Sin proyecto") |
| EH-017 | Ideas - vista por proyecto | Seccion en ProjectsComponent dialog, navigateToIdea() con router |

**Archivos modificados:**
- `src/app/core/services/projects.service.ts` - createProject() Observable
- `src/app/features/ideas/ideas.component.ts` - EH-015 + EH-016
- `src/app/features/projects/projects.component.ts` - EH-017

### Progreso general
- EPIC-01 (Backend): DONE (5/5)
- EPIC-02 (Dashboard+Alertas): DONE (7/7)
- EPIC-03 (Ideas): DONE (5/5)
- EPIC-04 (Polish): 0/5

### Issue detectado en testing
- Playwright no pudo abrir Chrome (conflicto user-data-dir con sesion existente)
- Los 3 API calls (ideas, ideas/summary, projects) retornaron 200 OK
- Pero tabla mostraba vacia y summary cards en 0 - posible bug de mapeo o timing
- Build compila sin errores ni warnings
- **Requiere testing manual en browser para confirmar**

## Proximos Pasos
1. Testing manual en browser de EH-015/016/017 (abrir http://localhost:4200/ideas)
2. Investigar por que tabla muestra vacia con API 200 OK (posible race condition o mapeo)
3. EPIC-04: EH-018 sync escritura alertas a ALERTS.md (3 pts, high)
4. EPIC-04: EH-019 sync escritura ideas a archivos MD (3 pts)
5. EPIC-04: EH-020 Docker Compose, EH-021 tests E2E, EH-022 docs

## Decisiones Pendientes
- Ninguna
