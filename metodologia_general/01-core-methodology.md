# Metodologia General - Core v3.0

**Version:** 3.0
**Fecha:** 2026-02-04
**Estado:** ACTIVO

---

## Escala por Defecto: Micro (1 Developer)

La mayoria de los proyectos son escala micro. El proceso se adapta al proyecto, no al reves.

| Escala | Team | Proceso | DoR Level | Two-Track |
|--------|------|---------|-----------|-----------|
| **Micro** | 1 dev | 3 fases simplificadas | Level 1 (mayoria) | Opcional |
| Small | 2-3 devs | 4 fases | L1 + L2 | Recomendado |
| Medium | 4-8 devs | 5 fases | L2 default | Obligatorio |
| Large | 9-20 devs | 6 fases completas | L2 + L3 | Obligatorio |

Para proyectos medium/large, cargar `05-advanced-practices.md` con @import.

---

## Proceso de Desarrollo

### Proceso Simplificado (US <= 3 pts, mayorIA de tareas)

```
Fase A: Quick Diagnosis (30min)
  - Que archivos tocar, que patron seguir
  - Sin documento formal

Fase B: Implementation (2-4h)
  - Codigo + tests + manual testing
  - Delegar a agentes especializados

Fase C: Review & Done (30min)
  - Self-review o code-reviewer agent
  - Merge a develop/main
```

**Total: 3-5 horas por US. Velocidad: 3-5 US/dia.**

### Proceso Completo (Epics >30 pts, features criticas)

```
Fase 1: Diagnostico Tecnico → DIAGNOSTIC_REPORT.md
Fase 2: Planificacion → PROJECT_PLAN.md
Fase 3: Product Backlog → PRODUCT_BACKLOG.md (via product-owner agent)
Fase 4: Validacion Negocio → BUSINESS_STAKEHOLDER_DECISION.md
Fase 5: Ejecucion con Agentes (delegar, coordinar, validar)
Fase 6: Validacion y Cierre (tests E2E, retrospectiva)
```

### Cuando usar cual

| Criterio | Simplificado | Completo |
|----------|-------------|----------|
| Story points | <= 3 | > 8 o Epic |
| Impacto usuario | Bajo | Alto/Critico |
| Riesgo seguridad | Bajo | Alto |
| Archivos afectados | 1-3 | Muchos |
| Necesita Business decision | No | Si |

---

## Roles

**Usuario:** Toma decisiones (Technical Lead + PM + PO + Business Stakeholder)
**Claude:** Asistente de direccion. Coordina, analiza, delega. NO ejecuta codigo directamente.
**Agentes:** Ejecutan tareas especializadas.

| Necesidad | Agente |
|-----------|--------|
| Backend .NET | `dotnet-backend-developer` |
| Backend Node.js | `nodejs-backend-developer` |
| Backend Python | `python-backend-developer` |
| Frontend React | `frontend-react-developer` |
| Frontend Angular | `frontend-angular-developer` |
| Flutter | `flutter-developer` |
| Tests | `test-engineer` |
| Code review | `code-reviewer` |
| Arquitectura Frontend | `software-architect` + perfil frontend |
| Arquitectura Backend | `software-architect` + perfil backend |
| Arquitectura General | `software-architect` |
| Base de datos | `database-expert` |
| DevOps/CI-CD | `devops-engineer` |
| User stories | `product-owner` |
| Project planning | `project-manager` |
| Business decisions | `business-stakeholder` |
| Calidad de datos, anomalias | `data-quality-analyst` |
| Matching/correlacion datasets | `matching-specialist` |
| Idiomas, traduccion, i18n | `localization-analyst` |

**Regla de delegacion:** Si la tarea toma >30 min y existe un agente, DELEGAR.
**Regla de validacion:** Al recibir output de un agente, revisar "Asunciones de Contexto". Si el agente asumio algo que no recibio, re-delegar con contexto corregido.

### Agentes Especializados (Perfiles con Herencia)

Algunos agentes tienen perfiles especializados que se componen al delegar:

```
BASE (principios comunes) + ESPECIALIZACION (dominio) + Contexto del proyecto
```

Ver `claude_context/metodologia_general/agents/README.md` para el sistema completo.

Al delegar a un agente especializado, Claude DEBE:
1. Leer el documento BASE del rol
2. Leer el documento de ESPECIALIZACION
3. Incluir ambos contenidos en el prompt del agente
4. Agregar el contexto especifico de la tarea/proyecto

---

## Definition of Ready (Resumen)

| Level | Uso | Tiempo prep | Checklist clave |
|-------|-----|-------------|-----------------|
| **L1 Minimum** | US <= 3pts, refactors, TD | 30min-1h | ID, titulo, 2+ AC basicos, TL approval |
| **L2 Standard** | US 3-8pts, features con UI/API | 2-4h | 10 secciones: AC Given-When-Then, deps resueltas, tech reqs, tests |
| **L3 Comprehensive** | US >8pts, auth, payments, criticas | 8-20h | Todo L2 + security audit, rollback plan, monitoring, multi-approval |

**Regla rapida:**
- Critico para negocio o datos sensibles? → L3
- Internal-only, <= 3pts? → L1
- Else → L2

---

## Calidad

### Siempre
- Rebuild completo antes de testing (`dotnet build --no-incremental`)
- 0 errores, 0 warnings en build
- Validar AC manualmente con evidencia
- Delegar a agentes especializados
- Trabajo en paralelo cuando sea posible

### Nunca
- Usar `--no-build` durante testing
- Marcar Done sin testing completo
- Duplicar codigo o configuracion
- Hardcodear valores (usar configuracion)
- Hacer trabajo secuencial cuando puede ser paralelo

### Targets
- **Test Coverage:** >70% por historia, >60% overall
- **Build:** 0 errors, 0 warnings
- **AC Validation:** 100% con evidencia
- **P0 Bugs:** 0 al final del sprint

---

## Git Workflow

```bash
# Crear rama
git checkout -b feature/ID-descripcion  # o bugfix/ o enhancement/

# Desarrollo + testing + review

# Merge
git checkout develop && git pull
git merge --no-ff feature/ID-descripcion
git push origin develop

# Cleanup
git branch -d feature/ID-descripcion
```

---

## Documentos de la Metodologia

| Archivo | Contenido | Carga |
|---------|-----------|-------|
| `01-core-methodology.md` | Proceso, roles, calidad (este archivo) | Siempre |
| `02-quick-reference.md` | Cheatsheet operativo, comandos | Siempre |
| `03-obligatory-directives.md` | Reglas de coordinacion y trabajo | Siempre |
| `04-worktrees-parallel.md` | Git worktrees + agentes paralelos | Siempre |
| `05-advanced-practices.md` | Two-track, TD, capacity, DoR completo | Bajo demanda |
| `06-memory-sync.md` | Sincronizacion CLAUDE.md <-> claude_context | Siempre |

**Backup de v2:** `metodologia_general_backup_pre_v3/`

---

**Version:** 3.0 | **Ultima actualizacion:** 2026-02-04
