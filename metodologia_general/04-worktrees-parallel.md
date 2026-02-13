# Git Worktrees + Agentes en Paralelo v3.0

**Version:** 3.0
**Fecha:** 2026-02-04
**Estado:** ACTIVO

---

## Concepto

Git worktrees permiten tener multiples branches checkeados en diferentes directorios simultaneamente, compartiendo el mismo historial de Git. Combinado con agentes en paralelo, reduce tiempo de desarrollo en 50%+.

```
Repositorio/              (main worktree - develop)
Repositorio-feature1/     (linked worktree - feature/X)
Repositorio-bugfix/       (linked worktree - bugfix/Y)
```

---

## Enfoque Recomendado: Una Sesion, Multiples Agentes

```
Sesion Principal (Claude coordinador)
  |-- Agente 1 (dotnet-backend-developer) → Worktree-feature1
  |-- Agente 2 (test-engineer)            → Worktree-feature1
  |-- Agente 3 (database-expert)          → Worktree-bugfix
```

Ventajas: Coordinacion centralizada, visibilidad total, menos overhead.

---

## Setup

### Crear worktree
```bash
cd C:\proyecto\Repositorio
git worktree add ../Repositorio-feature1 -b feature/nueva-funcionalidad
```

### Configurar entorno
```bash
cd ../Repositorio-feature1
dotnet restore && dotnet build   # .NET
# npm install && npm run build   # Node.js
```

### Listar / Eliminar
```bash
git worktree list
git worktree remove ../Repositorio-feature1
```

---

## Coordinacion con Agentes

### Regla critica: Paths absolutos

Los agentes DEBEN recibir paths absolutos al worktree asignado:

```
CORRECTO: "Edita C:\proyecto\Repositorio-feature1\Api\Controllers\XController.cs"
INCORRECTO: "Edita Api\Controllers\XController.cs"
```

### Template de coordinacion

```markdown
Worktree 1: C:\proyecto\Repositorio-feature1 (feature/X)
Worktree 2: C:\proyecto\Repositorio-bugfix (bugfix/Y)

Agente 1 (dotnet-backend-developer):
  Path: [Worktree 1]
  Tarea: [Descripcion]
  Output: [Esperado]

Agente 2 (test-engineer):
  Path: [Worktree 1] (depende de Agente 1)
  Tarea: [Descripcion]
```

---

## Cuando Usar

**SI usar:**
- Multiples features independientes en paralelo
- Hotfix urgente durante desarrollo de feature
- Experimentar con multiples enfoques (A/B)
- Refactor grande + bugfixes simultaneos

**NO usar:**
- Tareas simples de un archivo
- Cambios que afectan mismos archivos (alto riesgo conflicto)
- Sin suficiente RAM/disco

---

## Patrones de Coordinacion

### Pipeline (secuencial entre agentes)
```
Backend → Tests → Docs (cada uno espera al anterior)
```

### Independiente (paralelo total)
```
Feature A (WT1) | Feature B (WT2) | Bugfix C (WT3) → Merge coordinado
```

### Refactor + Mantenimiento
```
Refactor largo (WT1) | Bugfixes urgentes (WT2, merge inmediato)
```

---

## Cleanup

```bash
# Commit en worktree
cd Repositorio-feature1
git add . && git commit -m "feat: implementar X"
git push origin feature/nueva-funcionalidad

# Volver al main y remover
cd ../Repositorio
git worktree remove ../Repositorio-feature1
git branch -d feature/nueva-funcionalidad  # si ya mergeada
```

---

**Version:** 3.0 | **Ultima actualizacion:** 2026-02-04
