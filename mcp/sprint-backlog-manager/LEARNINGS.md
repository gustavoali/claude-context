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

## 2026-02-15 - GitHub Sync + Integration Tests

### promisify + jest.mock incompatibility
- `util.promisify(child_process.execFile)` uses a custom `[Symbol.for('nodejs.util.promisify.custom')]` that returns `{stdout, stderr}`
- When mocking with `jest.mock('child_process')`, this symbol is lost
- `promisify(mockFn)` then returns only the first callback arg (stdout as string), not `{stdout, stderr}`
- Solution: use a manual Promise wrapper instead of `promisify`:
```js
function execFileAsync(cmd, args) {
  return new Promise((resolve, reject) => {
    execFile(cmd, args, { encoding: 'utf8' }, (error, stdout, stderr) => {
      if (error) reject(error);
      else resolve({ stdout, stderr });
    });
  });
}
```

### PostgreSQL Docker (sprint-backlog-pg)
- Container: sprint-backlog-pg en WSL2
- Puerto 5435 (5432 en conflicto con plane-db)
- WSL2 port forwarding puede ser intermitente
- Volume: sprint-backlog-pgdata
