# Estado de Tareas - Recetario

**Ultima actualizacion:** 2026-02-14

## Resumen Ejecutivo

EPIC-001 y EPIC-002 completados. El importador de recetas ahora soporta 4 estrategias de parsing (JSON-LD > microdata > CSS heuristic > headings), con timeout, validacion SSRF, disposal correcto de OCR, y mensajes de error amigables en espanol.

## Infraestructura

- **Repo GitHub:** https://github.com/gustavoali/recetario (public)
- **Branch principal:** master
- **Version:** 0.9.0+1
- **Permisos Claude:** .claude/settings.local.json configurado con permisos amplios

## Estado por Fase

| Fase | Estado | Notas |
|------|--------|-------|
| Fase 1: MVP Local | COMPLETADA | CRUD, busqueda, favoritos, Drift DB |
| Fase 2: Importacion | COMPLETADA (sin tests) | Parser 4 estrategias + OCR. Tests pendientes (REC-006) |
| Fase 3: Auth + Sync | CONDICIONAL | Firebase ahora opcional - auth/sync disponible solo con google-services.json |
| Fase 4: Polish | PENDIENTE | Dark mode system-only, resto pendiente |

## Bloqueantes Criticos

Ninguno.

## Sesion 2026-02-14 - EPIC-002

| # | Tarea | Estado |
|---|-------|--------|
| 1 | Fix rethrow en recipe_parser.dart | COMPLETADA |
| 2 | Code review formal (code-reviewer agent) | COMPLETADA |
| 3 | flutter analyze (0 issues) | COMPLETADA |
| 4 | flutter build apk (exitoso) | COMPLETADA |
| 5 | Commit 62e4e97 | COMPLETADA |

### Stories resueltas: REC-003, REC-004, REC-005, REC-007, REC-008, REC-011 (16 pts)

### Observaciones del code review (diferidas)
- Response size limit para evitar OOM con HTML gigantes
- Normalizar image URLs relativas a absolutas
- Deduplicar logica de extraccion de imagenes entre heuristic y headings

## Proximos Pasos (Prioridad)

1. **REC-006:** Agregar tests para parser, OCR, auth, sync (13 pts)
2. **EPIC-003:** Mejoras de UX/UI
3. **REC-016:** Migrar StateNotifier legacy a Notifier
