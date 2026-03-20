# Estado - Ecosystem Hub
**Actualizacion:** 2026-03-20 | **Version:** 0.1.0

## Completado Esta Sesion (2026-03-20)
| ID | Titulo | Resultado |
|----|--------|-----------|
| EH-001 | Parser ALERTS.md | Ya existia (alert-parser.js) |
| EH-002 | Parser IDEAS_INDEX.md | Ya existia (idea-parser.js) |
| EH-003 | REST endpoints alertas | CRUD completo con DB (resolve/reopen) |
| EH-004 | REST endpoints ideas | CRUD completo con DB |
| EH-005 | REST endpoint deadlines | CRUD completo con DB + days_until_due |
| - | Import script | 32/32 alertas + 47/47 ideas importadas |
| - | Code review fixes | 2 criticos + 4 mayores + 3 menores corregidos |

### Archivos creados/modificados en C:/mcp/project-admin/
**Nuevos (9):** migration 002, 3 repositories, 3 services, deadlines route, import script
**Modificados (4):** alerts.js, ideas.js, index.js (DB-backed CRUD), package.json

### Decisiones tomadas
- Tipos de alerta ampliados: + `pendiente`, `code-review` (datos de jerarquicos lo requerian)
- `overdue` en deadlines es computado (no settable por API), alineado con ADR en ARCHITECTURE
- DB CHECK constraint actualizado en runtime (ALTER TABLE) + migration file

## Proximos Pasos
1. Commit WIP en project-admin (cambios de EPIC-01)
2. Verificar que frontend conecta correctamente al backend (modelos, URLs)
3. Avanzar EPIC-02: wiring frontend services a API real
4. Actualizar PRODUCT_BACKLOG: marcar EH-001 a EH-005 como Done
5. Evaluar si frontend necesita ajustes por cambio de ID (IDEA-xxx string -> numeric)
