# Metodologia General v3.0

**Fecha:** 2026-02-04
**Estado:** ACTIVO

## Estructura

### Archivos Core (cargados siempre via CLAUDE.md)
| Archivo | Contenido | Lineas |
|---------|-----------|--------|
| `01-core-methodology.md` | Proceso, roles, calidad, DoR resumen, git workflow | 167 |
| `02-quick-reference.md` | Cheatsheet, comandos, delegacion, skills, templates | 165 |
| `03-obligatory-directives.md` | 10 reglas obligatorias (coordinador, backlog, rigor, etc.) | 225 |
| `04-worktrees-parallel.md` | Git worktrees + agentes en paralelo | 136 |
| `06-memory-sync.md` | Sincronizacion CLAUDE.md <-> claude_context | 116 |
| **Total cargado** | | **809** |

### Archivo Bajo Demanda (para proyectos Medium+)
| Archivo | Contenido | Lineas |
|---------|-----------|--------|
| `05-advanced-practices.md` | Two-track, TD management, capacity, DoR completo | 218 |

### Backup de v2
| Carpeta | Contenido |
|---------|-----------|
| `metodologia_general_backup_pre_v3/` | Todos los archivos de v2 (23 archivos, 7351 lineas) |

## Historial

- **v3.0** (2026-02-04): Consolidacion de 17 archivos en 6. Reduccion 89% contexto. Tips nuevos incorporados.
- **v2.1** (2025-10-16): Scale adaptation, DoR levels, strategic debt.
- **v2.0** (2025-10-16): Two-track, TD management, capacity planning, DoR.
- **v1.0** (2025-10-16): Release inicial, 10 documentos base.

## Que se incorporo nuevo en v3.0

1. **Custom Skills** (Tip 4): Guia para crear slash commands para tareas repetitivas
2. **Autonomous Bug Fixing** (Tip 5): Patron para bug fix autonomo via agentes
3. **Harsh Reviewer** (Tip 6): Code review riguroso pre-PR
4. **Terminal Setup** (Tip 7): Recomendaciones de entorno de trabajo
