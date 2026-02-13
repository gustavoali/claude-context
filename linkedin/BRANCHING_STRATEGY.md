# Estrategia de Branching - LinkedIn Transcript Extractor

**Version:** 0.10.0
**Fecha:** 2026-01-18
**Estado:** ACTIVO

---

## Estructura de Branches

```
master (protected)
   │
   └── Release tags (v0.10.0, v0.11.0, etc.)

dev (default branch para desarrollo)
   │
   ├── feature/LTE-XXX_descripcion
   ├── bugfix/LTE-XXX_descripcion
   ├── hotfix/descripcion-urgente
   └── refactor/LTE-XXX_descripcion
```

---

## Branches Principales

### `master`
- **Propósito:** Código de producción estable
- **Protección:** Solo merge desde `dev` via PR
- **Tags:** Cada release se tagea (v0.10.0, v0.11.0)
- **Nunca:** Commits directos

### `dev`
- **Propósito:** Integración de features completadas
- **Base:** Siempre actualizada con código estable
- **Workflow:** Todas las features/bugfixes se integran aquí
- **Estado:** Siempre debe pasar tests

---

## Branches de Trabajo

### `feature/LTE-XXX_descripcion`
```bash
# Crear desde dev
git checkout dev
git pull origin dev
git checkout -b feature/LTE-001_consolidar-parsing
```

**Convención de nombres:**
- `feature/LTE-001_consolidar-parsing` - Nueva funcionalidad
- `bugfix/LTE-015_fix-memory-leak` - Corrección de bug
- `refactor/LTE-002_tests-unitarios` - Refactoring
- `hotfix/critical-crash` - Fix urgente para producción

---

## Workflow con Worktrees

### Cuándo Usar Worktrees

Usar worktrees cuando:
- Múltiples tareas independientes del Sprint
- Necesidad de contexto switching sin stash
- Trabajo paralelo en diferentes historias

### Estructura de Worktrees

```
C:\mcp\
├── linkedin\                    # Main worktree (dev)
│   └── .git\                    # Git database compartida
│
├── linkedin-LTE-001\            # Worktree: feature/LTE-001
├── linkedin-LTE-002\            # Worktree: feature/LTE-002
└── linkedin-LTE-020\            # Worktree: feature/LTE-020
```

### Comandos de Worktree

```bash
# Crear worktree para nueva feature
cd C:\mcp\linkedin
git worktree add ../linkedin-LTE-001 -b feature/LTE-001_consolidar-parsing

# Listar worktrees activos
git worktree list

# Remover worktree después de merge
git worktree remove ../linkedin-LTE-001
```

---

## Sprint N - Worktrees Planificados

Basado en el SPRINT_N_PLAN.md:

| Historia | Branch | Worktree Path | Owner |
|----------|--------|---------------|-------|
| LTE-001 | `feature/LTE-001_consolidar-parsing` | `linkedin-LTE-001` | dotnet-backend-developer |
| LTE-002 | `feature/LTE-002_tests-unitarios` | `linkedin-LTE-002` | test-engineer |
| LTE-020 | `feature/LTE-020_validar-matching` | `linkedin-LTE-020` | test-engineer |
| LTE-021 | `feature/LTE-021_eslint-config` | `linkedin-LTE-021` | code-reviewer |

---

## Workflow de Merge

### Feature → Dev

```bash
# En worktree de la feature
git add .
git commit -m "feat(LTE-001): Consolidate VTT parsing logic

- Extract shared parsing to scripts/lib/vtt-parser.js
- Remove duplicate implementations
- Add unit tests

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"

# Push branch
git push -u origin feature/LTE-001_consolidar-parsing

# Crear PR o merge directo
git checkout dev
git merge --no-ff feature/LTE-001_consolidar-parsing
git push origin dev

# Limpiar
git branch -d feature/LTE-001_consolidar-parsing
git worktree remove ../linkedin-LTE-001
```

### Dev → Master (Release)

```bash
# Asegurar dev está estable
cd C:\mcp\linkedin
git checkout dev
npm test
npm run lint  # cuando esté configurado

# Merge a master
git checkout master
git merge --no-ff dev -m "Release v0.11.0"
git tag -a v0.11.0 -m "Version 0.11.0 - Sprint N completion"
git push origin master --tags

# Volver a dev
git checkout dev
```

---

## Convenciones de Commits

### Formato
```
<tipo>(<scope>): <descripción corta>

[cuerpo opcional]

[footer opcional]
Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

### Tipos
- `feat`: Nueva funcionalidad
- `fix`: Corrección de bug
- `refactor`: Refactoring sin cambio funcional
- `test`: Agregar o modificar tests
- `docs`: Documentación
- `chore`: Mantenimiento (deps, config)
- `style`: Formato, linting

### Ejemplos
```
feat(LTE-001): Consolidate VTT parsing into shared library
fix(LTE-015): Resolve memory leak in background script
test(LTE-002): Add unit tests for vtt-parser
refactor(LTE-003): Extract state management from background.js
```

---

## Coordinación de Agentes

Cuando múltiples agentes trabajan en paralelo:

1. **Asignar paths absolutos** a cada agente
2. **No overlapping de archivos** entre worktrees
3. **Sync frecuente** con dev para evitar conflictos
4. **Code review** antes de merge

### Archivos con Riesgo de Conflicto

| Archivo | Riesgo | Estrategia |
|---------|--------|------------|
| `background.js` | ALTO | Solo una persona a la vez |
| `package.json` | MEDIO | Coordinar cambios de deps |
| `scripts/lib/database.js` | MEDIO | Una persona owner |
| `extension/manifest.json` | BAJO | Cambios mínimos |

---

## Estado Actual

```
master: eba9857 (v0.8.1 - Initial)
   │
dev: 6edcc98 (v0.10.0-rc1 unified)
   │
   └── Ready for Sprint N worktrees
```

**Próximo paso:** Crear worktrees para LTE-001, LTE-002, LTE-020, LTE-021

---

**Última actualización:** 2026-01-18
**Versión del documento:** 1.0
