# Jerarquicos - Reglas Compartidas
**Aplica a TODOS los proyectos bajo `C:/claude_context/jerarquicos/`**
**Ultima actualizacion:** 2026-02-14

## Git

### Commits manuales
**Los commits en proyectos Jerarquicos los hace el usuario personalmente.**
- Claude NO debe hacer `git commit`
- Claude puede hacer `git add` (resolver conflictos, stage de archivos)
- Claude puede proponer mensajes de commit, pero NO ejecutar el commit
- Esto aplica a todos los repos: ApiJsMobile, Repositorio-ApiMovil, y cualquier otro proyecto Jerarquicos

## Contexto por Branch (OBLIGATORIO)

**Toda branch de trabajo tiene su propio contexto independiente.**
Ver politica completa: @C:/claude_context/jerarquicos/BRANCH_CONTEXT_POLICY.md

Resumen:
- Cada branch crea `features/[id]-[nombre]/` con su TASK_STATE.md y artefactos
- CLAUDE.md del proyecto registra branches activas en tabla
- Al iniciar sesion, detectar branch actual y cargar su contexto
- Al completar, mover a `archive/features/`
- El backlog es del proyecto, no de la branch
