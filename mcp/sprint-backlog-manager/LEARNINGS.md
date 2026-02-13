# Sprint Backlog Manager - Learnings

## 2026-02-05 - Inicio del Proyecto

### Origen
- Evolucion de `C:/mcp/sprint-tracker/` (CLI puro, JSON, zero deps)
- Incorpora propuesta de backlog-as-database de `24-backlog-file-structure.md`
- Unifica sprint tracking + backlog management en un MCP Server

### Decisiones Arquitecturales

**PostgreSQL en lugar de SQLite:**
- Multi-proyecto requiere concurrencia
- ROI calculado como columna generada (GENERATED ALWAYS AS)
- JSONB para acceptance_criteria y config flexible
- Indices especificos para queries frecuentes (stories por status, debt por ROI)

**MCP como interfaz primaria:**
- Claude interactua directamente con el backlog
- Elimina friccion de delegar a product-owner para operaciones simples
- CLI mantenido como interfaz secundaria

**ID Registry en DB:**
- Evita colisiones de IDs entre sesiones (problema historico)
- Secuencial por proyecto y tipo de entidad
- Atomico via PostgreSQL sequences

### Sprint-tracker Features Preservadas
- Kanban board view (ahora via MCP tool get_sprint_board)
- Task model completo (title, type, status, priority, points, owner, branch, AC, notes)
- Technical debt tracking con ROI
- GitHub sync (a implementar en fase futura)
- Markdown export (via MCP tool o CLI)
