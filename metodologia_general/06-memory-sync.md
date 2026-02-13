# Sincronizacion de Memoria v3.0

**Version:** 3.0
**Fecha:** 2026-02-04
**Estado:** ACTIVO

---

## Arquitectura de 3 Capas

```
User Memory (~/.claude/CLAUDE.md)
  → Preferencias globales + @imports a metodologia_general/

Project Memory ([proyecto]/.claude/CLAUDE.md)
  → Contexto del proyecto + @imports a claude_context/[proyecto]/

Context Repository (C:/claude_context/)
  → Repositorio centralizado de conocimiento
  metodologia_general/  → Docs de metodologia (aplica a todos)
  [clasificador]/
    [proyecto]/          → Contexto especifico del proyecto
      CLAUDE.md          → Config real centralizada
      LEARNINGS.md       → Patrones aprendidos
      ARCHITECTURE.md    → Diseno tecnico
      TASK_STATE.md      → Estado de trabajo en curso
      PRODUCT_BACKLOG.md → Indice de backlog
      backlog/           → Stories individuales
```

---

## Al Iniciar Sesion en un Proyecto

1. Verificar si existe `C:/claude_context/[clasificador]/[Proyecto]/CLAUDE.md`
2. Verificar si `[proyecto]/.claude/CLAUDE.md` tiene patron de redireccion
3. Si NO existe:
   - Preguntar clasificador al usuario
   - Crear estructura en claude_context
   - Crear puntero en proyecto
4. Revisar TASK_STATE.md si existe (retomar trabajo pendiente)

---

## Donde Guardar Que

| Tipo de Informacion | Ubicacion |
|---------------------|-----------|
| Preferencias personales (todos los proyectos) | `~/.claude/CLAUDE.md` |
| Metodologia general | `claude_context/metodologia_general/` |
| Config del proyecto (real) | `claude_context/[clasificador]/[proyecto]/CLAUDE.md` |
| Puntero en proyecto | `[proyecto]/.claude/CLAUDE.md` → @import al real |
| Patrones aprendidos del proyecto | `claude_context/[proyecto]/LEARNINGS.md` |
| Arquitectura del proyecto | `claude_context/[proyecto]/ARCHITECTURE.md` |
| Estado de trabajo en curso | `claude_context/[proyecto]/TASK_STATE.md` |
| Backlog del proyecto | `claude_context/[proyecto]/PRODUCT_BACKLOG.md` |

---

## Cuando Sincronizar

**Sincronizar a claude_context si:**
- Patron arquitectonico importante descubierto
- Decision tecnica que afecta el proyecto largo plazo
- Conocimiento que debe preservarse entre sesiones

**NO sincronizar si:**
- Work in progress temporal
- Recordatorio de sesion unica
- Informacion que cambiara pronto

---

## Patron de Redireccion

**Archivo puntero** (en el proyecto):
```markdown
# [Proyecto] - Configuracion de Claude Code
# La configuracion real esta centralizada en claude_context.
@C:/claude_context/[clasificador]/[Proyecto]/CLAUDE.md
```

**Archivo real** (en claude_context):
```markdown
# [Proyecto] - Project Context

## Documentacion
@C:/claude_context/[clasificador]/[Proyecto]/LEARNINGS.md
@C:/claude_context/[clasificador]/[Proyecto]/ARCHITECTURE.md

## Tecnologias
[Stack del proyecto]

## Convenciones
[Patrones especificos]
```

---

## Estructura de claude_context

```
C:/claude_context/
  metodologia_general/        → Aplica a todos los proyectos
  DEVELOPMENT_GUIDELINES.md   → Guidelines generales de desarrollo
  CONTINUOUS_IMPROVEMENT.md   → Registro de mejoras propuestas
  [clasificador]/             → Carpeta organizadora
    [Proyecto]/               → Mismo nombre que carpeta del proyecto
```

Clasificadores comunes: `jerarquicos`, `agents`, `personal`, `linkedin`, etc.
Si no existe el clasificador, preguntar al usuario.

---

**Version:** 3.0 | **Ultima actualizacion:** 2026-02-04
