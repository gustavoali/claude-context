# Quick Reference - Cheatsheet

**Versión:** 1.0
**Fecha:** 2025-10-16
**Para:** Uso diario y referencia rápida

---

## ⚡ Comandos Frecuentes

### Git Workflow

```bash
# Crear rama nueva desde develop
git checkout develop
git pull origin develop
git checkout -b YRUS-XXXX_descripcion_funcionalidad

# Mergear a develop al completar
git checkout develop
git pull origin develop
git merge --no-ff YRUS-XXXX_descripcion_funcionalidad
git push origin develop

# Eliminar rama local (opcional)
git branch -d YRUS-XXXX_descripcion_funcionalidad
```

### Git Worktrees (Trabajo en Paralelo)

```bash
# Crear worktree con nuevo branch
git worktree add ../proyecto-feature1 -b feature/nueva-funcionalidad

# Crear worktree desde branch existente
git worktree add ../proyecto-bugfix bugfix/urgent-fix

# Listar todos los worktrees activos
git worktree list

# Remover worktree (mantiene commits en el branch)
git worktree remove ../proyecto-feature1

# Configurar entorno en nuevo worktree (.NET)
cd ../proyecto-feature1
dotnet restore
dotnet build

# Configurar entorno en nuevo worktree (Node.js)
cd ../proyecto-feature1
npm install
npm run build

# Ver documentación completa
# Leer: metodologia_general/16-git-worktrees-parallel-agents.md
```

### Testing y Build

```bash
# Matar procesos antes de testing
taskkill /F /IM dotnet.exe

# Build completo (SIEMPRE antes de testing)
dotnet build --no-incremental

# Build Release para testing final
dotnet build --no-incremental --configuration Release

# Ejecutar tests
dotnet test --configuration Release --verbosity normal

# Limpiar y rebuild completo
dotnet clean
dotnet build --no-incremental --configuration Release
```

### Ejecución

```bash
# Development (Mock, Sin Auth)
dotnet run --environment Development

# Testing (Memory, Sin Auth)
dotnet run --environment Testing

# Production (Real, Full Auth)
dotnet run --environment Production

# NUNCA usar --no-build durante testing
dotnet run  # ✅ CORRECTO
dotnet run --no-build  # ❌ INCORRECTO
```

---

## 📋 Checklists Rápidos

### Antes de Empezar Historia

- [ ] Historia tiene ID: `YRUS-XXXX`
- [ ] AC claramente definidos
- [ ] DoD revisado
- [ ] Rama creada desde develop actualizado
- [ ] Ambiente de desarrollo funcionando

### Durante Desarrollo

- [ ] Siguiendo Clean Architecture
- [ ] SOLID principles aplicados
- [ ] Build exitoso (0 errores, 0 warnings)
- [ ] Tests automatizados escritos
- [ ] Código revisado por `code-reviewer`

### Antes de Marcar como Done

- [ ] ✅ Full rebuild (`dotnet build --no-incremental`)
- [ ] ✅ Todos los tests pasando
- [ ] ✅ Testing manual COMPLETADO
- [ ] ✅ TODOS los AC validados con evidencia
- [ ] ✅ No hay regresiones
- [ ] ✅ Documentación actualizada
- [ ] ✅ Code review aprobado

### Antes de Mergear a Develop

- [ ] DoD 100% completo
- [ ] Build exitoso sin warnings
- [ ] Develop actualizado localmente
- [ ] Sin conflictos
- [ ] Manual test report documentado

### Fin de Sprint

- [ ] Todas las historias mergeadas
- [ ] Regresión automática ejecutada
- [ ] Testing manual completo de todas las historias
- [ ] Sprint Validation Report creado
- [ ] No hay P0 bugs abiertos
- [ ] Product Owner sign-off
- [ ] Retrospectiva documentada

---

## 🤖 Delegación de Agentes

### Matriz Rápida

| Necesito | Uso este agente |
|----------|----------------|
| Implementar código .NET | `dotnet-backend-developer` |
| Escribir/ejecutar tests | `test-engineer` |
| Revisar código | `code-reviewer` |
| Diseñar arquitectura | `software-architect` |
| Optimizar queries DB | `database-expert` |
| Setup CI/CD | `devops-engineer` |
| Crear user stories | `product-owner` |
| Plan de proyecto | `project-manager` |

### Template de Delegación

```markdown
Delegando [TAREA] a [AGENTE]:

**Objetivo:** [Objetivo principal]

**Tareas específicas:**
1. [Tarea 1]
2. [Tarea 2]

**Output esperado:**
- [Archivo/resultado 1]

**Criterios de aceptación:**
- [ ] Criterio 1
- [ ] Criterio 2

Mientras tanto, yo: [SIGUIENTE_TAREA]
```

### Pregunta Obligatoria

> **¿Debería delegar esto a un agente especializado?**
>
> Si la tarea toma >30 minutos → **SÍ, DELEGAR**

### Trabajo en Paralelo con Worktrees

> **¿Tengo múltiples tareas independientes?**
>
> Considera usar Git worktrees + múltiples agentes en una sesión:
> - ✅ Coordinación centralizada
> - ✅ Visibilidad total del progreso
> - ✅ Aislamiento de código entre tareas
> - ✅ Reducción de 50%+ en tiempo total
>
> Ver: `16-git-worktrees-parallel-agents.md`

---

## 🧪 Testing Manual - Template Rápido

```markdown
## Manual Test Report: YRUS-XXXX

**Fecha:** [YYYY-MM-DD HH:MM]
**Build:** [Git commit hash]

### AC1: [Descripción]
- **Status:** ✅ PASS / ❌ FAIL
- **Test Steps:**
  1. [Paso 1]
  2. [Paso 2]
- **Expected:** [Qué debería pasar]
- **Actual:** [Qué pasó]
- **Evidence:** [Screenshot/log]

### AC2: [Descripción]
[Repetir...]

### Overall Status
- **Story Status:** ✅ READY / ❌ NEEDS FIXES
- **Confidence:** HIGH / MEDIUM / LOW
```

---

## 📊 Formato de User Story

```markdown
### US-XXX: [Título]
**Story Points:** [1/2/3/5/8/13]
**Priority:** [Critical/High/Medium/Low]
**Sprint:** [Número]

**As a** [user type]
**I want** [goal]
**So that** [benefit]

#### Acceptance Criteria

**AC1: [Nombre]**
- Given [context]
- When [action]
- Then [outcome]

**AC2: [Nombre]**
- Given [context]
- When [action]
- Then [outcome]

#### Definition of Done
- [ ] Código implementado
- [ ] Tests escritos (>70% coverage)
- [ ] Manual testing completado
- [ ] Code review aprobado
- [ ] Build exitoso (0 warnings)
- [ ] Documentación actualizada
```

---

## 🚨 Reglas de Oro

### SIEMPRE:

```
✅ Rebuild completo antes de testing
✅ Delegar a agentes especializados
✅ Validar AC manualmente con evidencia
✅ Trabajo en paralelo
✅ Documentar decisiones
✅ 0 errores, 0 warnings
```

### NUNCA:

```
❌ Usar --no-build durante testing
❌ Marcar Done sin testing completo
❌ Duplicar configuración
❌ Hardcodear valores
❌ Trabajo secuencial innecesario
❌ Mergear con P0 bugs abiertos
```

---

## 🔢 Targets de Calidad

### Por Historia:
- **Test Coverage:** >70%
- **Build:** 0 errors, 0 warnings
- **AC Validation:** 100% con evidencia
- **Manual Testing:** Completado y documentado

### Por Sprint:
- **Velocity:** 75-85 story points
- **Test Coverage Overall:** >60%
- **Critical Paths Coverage:** >80%
- **Regression Pass Rate:** >85%
- **P0 Bugs:** 0 al final del sprint

---

## 📁 Archivos Obligatorios por Feature

```
DIAGNOSTIC_REPORT_[FEATURE].md
PROJECT_PLAN_[FEATURE].md
PRODUCT_BACKLOG_[FEATURE].md
BUSINESS_STAKEHOLDER_DECISION_[FEATURE].md
SPRINT_REVIEW_[NUMBER].md
LESSONS_LEARNED_[FEATURE].md
```

---

## 📋 Persistencia de Estado de Tareas

### Cuando Crear TASK_STATE.md
- Trabajo con 3+ tareas relacionadas
- Trabajo que puede extenderse a multiples sesiones
- Migraciones, refactors grandes, riesgo de interrupcion

### Ubicacion
```
C:/claude_context/[proyecto]/TASK_STATE.md
```

### Cuando Actualizar
- Al completar una tarea
- Al cambiar estado de tarea
- Al tomar decision importante
- Minimo cada 30 minutos de trabajo activo

### Contenido Minimo
```markdown
# Estado de Tareas - [Proyecto]
**Ultima actualizacion:** YYYY-MM-DD HH:MM

## Resumen Ejecutivo
[Trabajo en curso, fase actual, bloqueantes]

## Tareas Activas
[Lista con estado: pendiente/en_progreso/completada]

## Proximos Pasos
[Que hacer al retomar]

## Notas para Retomar
[Contexto critico]
```

---

## 🎯 Priorización Rápida

### RICE Score
```
RICE = (Reach × Impact × Confidence) / Effort

Reach: 1-10 usuarios afectados
Impact: 0.25=Minimal, 0.5=Low, 1=Medium, 2=High, 3=Massive
Confidence: 50%=Low, 80%=Medium, 100%=High
Effort: Person-days
```

### MoSCoW
- **Must Have:** Crítico para MVP
- **Should Have:** Importante pero no bloqueante
- **Could Have:** Nice to have
- **Won't Have:** Fuera de scope actual

---

## ⏱️ Time Estimates Típicos

| Actividad | Tiempo |
|-----------|--------|
| Diagnóstico Técnico | 2-8 horas |
| Project Plan | 1-4 horas |
| Product Backlog | 2-4 horas |
| Business Decision | 1-2 horas |
| Implementación (Story 5pts) | 4-6 horas |
| Testing Manual (por historia) | 1-2 horas |
| Code Review | 1 hora |
| Sprint Validation | 2-4 horas |
| Retrospectiva | 1 hora |

---

## 🔗 Enlaces Rápidos

### Documentación Metodología:
- `01-resumen-ejecutivo.md` - Visión general
- `02-proceso-desarrollo-6-fases.md` - Proceso completo
- `10-quick-reference.md` - Este documento (referencia rápida)
- `11-two-track-agile.md` - Discovery + Delivery en paralelo
- `12-technical-debt-management.md` - Sistema de ROI para deuda técnica
- `13-capacity-planning.md` - Fórmula matemática de capacidad
- `14-definition-of-ready.md` - Checklist pre-desarrollo
- `15-scale-adaptation-guide.md` - Metodología por escala de proyecto
- `16-git-worktrees-parallel-agents.md` - Trabajo en paralelo con worktrees
- `17-memory-sync-pattern.md` - Sincronización de memoria CLAUDE.md ↔ claude_context
- `18-claude-coordinator-role.md` - Rol de Claude como coordinador (OBLIGATORIO)
- `19-task-state-persistence.md` - Persistencia de estado de tareas (OBLIGATORIO)
- `20-backlog-management-directive.md` - Gestion de backlog con product-owner (OBLIGATORIO)
- `21-continuous-improvement-directive.md` - Mejora continua del sistema (OBLIGATORIO)
- `22-intellectual-rigor-directive.md` - Rigor intelectual en análisis técnico (OBLIGATORIO)

### Documentación Proyecto:
- `README.md` - Overview del proyecto
- `PRODUCT_BACKLOG.md` - Backlog actual
- `TESTING_METHODOLOGY_RULES.md` - Reglas detalladas
- `.claude/AGENT_USAGE_GUIDELINES.md` - Uso de agentes

---

**Última actualización:** 2025-10-16
**Versión:** 1.0
**Mantener este documento actualizado con cada mejora de proceso**
