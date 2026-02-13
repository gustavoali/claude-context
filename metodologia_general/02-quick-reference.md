# Quick Reference - Cheatsheet Operativo v3.0

**Version:** 3.0
**Fecha:** 2026-02-04

---

## Comandos Frecuentes

### Git
```bash
# Nueva rama
git checkout develop && git pull origin develop
git checkout -b feature/ID-descripcion

# Merge
git checkout develop && git pull origin develop
git merge --no-ff feature/ID-descripcion
git push origin develop

# Worktrees (trabajo paralelo)
git worktree add ../proyecto-feature -b feature/nueva
git worktree list
git worktree remove ../proyecto-feature
```

### Build y Testing (.NET)
```bash
taskkill /F /IM dotnet.exe          # Matar procesos
dotnet clean                         # Limpiar
dotnet build --no-incremental        # Build completo (SIEMPRE antes de test)
dotnet test --configuration Release  # Tests
dotnet run --environment Development # Ejecutar
# NUNCA: dotnet run --no-build
```

---

## Delegacion de Agentes

| Necesito | Agente |
|----------|--------|
| Implementar codigo .NET | `dotnet-backend-developer` |
| Implementar codigo Node.js | `nodejs-backend-developer` |
| Implementar codigo Python | `python-backend-developer` |
| Frontend React | `frontend-react-developer` |
| Escribir/ejecutar tests | `test-engineer` |
| Revisar codigo (riguroso) | `code-reviewer` |
| Disenar arquitectura | `software-architect` |
| Optimizar queries DB | `database-expert` |
| Setup CI/CD | `devops-engineer` |
| Crear user stories | `product-owner` |
| Plan de proyecto | `project-manager` |
| Analisis calidad de datos | `data-quality-analyst` |
| Correlacion/matching entre datasets | `matching-specialist` |
| Deteccion idioma, traduccion, i18n | `localization-analyst` |

**Regla:** Tarea >30 min y existe agente? DELEGAR.

### Template de Delegacion
```
Objetivo: [Que lograr]
Path: [Ruta absoluta al worktree/proyecto]
Tareas: [Lista numerada]
Specs exactas: [Nombres de clases, interfaces, schemas]
Restricciones: [Que NO hacer]
AC: [Criterios de exito]
```

---

## Custom Slash Commands (/skills)

### Cuando crear un Skill
Si haces una tarea >1 vez por dia, convertirla en skill.

**Ejemplos de skills utiles:**
- `/commit` - Commit con formato estandar
- `/build-test` - Build completo + run tests
- `/create-story` - Crear historia en backlog con formato
- `/review` - Code review riguroso pre-PR

### Como crear un Skill
Crear archivo `.claude/commands/nombre.md` en el proyecto:
```markdown
Descripcion del skill y pasos a ejecutar.
Puede incluir $ARGUMENTS para parametros del usuario.
```

---

## Terminal Setup

### Recomendaciones
- **Statusline:** Configurar para mostrar branch actual + uso de contexto
- **Voice dictation:** ~3x mas rapido para instrucciones largas
- **Terminal moderno:** Ghostty, Windows Terminal, iTerm2

---

## Testing Manual - Template

```markdown
## Manual Test: [ID]
**Fecha:** YYYY-MM-DD | **Build:** [commit]

### AC1: [Descripcion]
- Status: PASS/FAIL
- Steps: [1, 2, 3...]
- Expected: [que deberia pasar]
- Actual: [que paso]

### Overall: READY / NEEDS FIXES
```

---

## User Story Format

```markdown
### [ID]: [Titulo]
**Points:** [1/2/3/5/8/13] | **Priority:** [Critical/High/Medium/Low]

**As a** [user type]
**I want** [goal]
**So that** [benefit]

#### Acceptance Criteria
**AC1:** Given [context], When [action], Then [outcome]
**AC2:** ...

#### DoD
- [ ] Codigo implementado
- [ ] Tests escritos (>70% coverage)
- [ ] Manual testing completado
- [ ] Code review aprobado
- [ ] Build 0 warnings
```

---

## Priorizacion Rapida

### RICE Score
```
RICE = (Reach x Impact x Confidence) / Effort
```

### MoSCoW
- **Must Have:** Critico para MVP
- **Should Have:** Importante, no bloqueante
- **Could Have:** Nice to have
- **Won't Have:** Fuera de scope

---

## Archivos por Feature (proceso completo)

```
DIAGNOSTIC_REPORT_[FEATURE].md
PROJECT_PLAN_[FEATURE].md
PRODUCT_BACKLOG_[FEATURE].md
BUSINESS_STAKEHOLDER_DECISION_[FEATURE].md
```

---

**Version:** 3.0 | **Ultima actualizacion:** 2026-02-04
