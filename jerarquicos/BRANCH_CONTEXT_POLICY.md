# Politica de Contexto por Branch - Proyectos Jerarquicos

**Version:** 1.0
**Fecha:** 2026-02-25
**Aplica a:** TODOS los proyectos bajo `claude_context/jerarquicos/`

---

## Principio

En proyectos de Jerarquicos, cada branch de trabajo (feature, bugfix, hotfix) se trata como un **proyecto independiente** dentro del contexto. Esto evita mezclar estado entre ramas y permite retomar cualquier branch sin perder contexto.

## Estructura

```
claude_context/jerarquicos/[Proyecto]/
  CLAUDE.md                          # Contexto general del proyecto (permanente)
  PRODUCT_BACKLOG.md                 # Backlog general (permanente)
  backlog/stories/                   # Historias individuales (permanente)
  features/                          # Carpeta de branches activas
    [id]-[nombre-corto]/             # Una subcarpeta por branch
      TASK_STATE.md                  # Estado de trabajo en esta branch
      postman/                       # Colecciones de test (si aplica)
      notes/                         # Notas, analisis, decisiones
      ...                            # Cualquier artefacto de la branch
  archive/                           # Branches completadas
    features/[id]-[nombre-corto]/    # Se mueve aca al completar
```

## Reglas

### 1. Crear contexto de branch al iniciar trabajo

Al comenzar trabajo en una branch, crear la subcarpeta:

```bash
mkdir -p claude_context/jerarquicos/[Proyecto]/features/[id]-[nombre-corto]
```

El `[id]` corresponde al ID del item de trabajo (Azure DevOps, Jira, etc.) y `[nombre-corto]` es un slug descriptivo.

### 2. TASK_STATE.md vive en la branch, no en la raiz

El TASK_STATE.md de la raiz del proyecto es solo para estado general. Cada branch tiene su propio TASK_STATE.md con el estado especifico de esa branch.

### 3. Artefactos de la branch van en su carpeta

Todo lo que sea especifico de una branch (colecciones Postman, scripts de test, notas de investigacion, etc.) va dentro de la carpeta de la branch, no en la raiz del proyecto.

### 4. CLAUDE.md del proyecto registra branches activas

El CLAUDE.md del proyecto debe tener una seccion "Features Activas" con tabla de branches:

```markdown
## Features Activas

Cada feature/branch tiene su propio contexto en `features/[id]-[nombre]/`.
Al iniciar sesion en una feature, cargar su TASK_STATE.md para retomar.

| Feature | Branch | Estado | Contexto |
|---------|--------|--------|----------|
| 185688 ApiLocalizacion | `feature/185688_reemplazo_llamada_dao_x_ApiLocalization` | En progreso | `features/185688-apilocalizacion/` |
```

### 5. Al iniciar sesion, cargar contexto de la branch

Verificar en que branch esta el repo (`git branch --show-current`) y cargar el TASK_STATE.md correspondiente de `features/`.

### 6. Al completar una branch, archivar

Mover la carpeta de `features/` a `archive/features/`:

```bash
mv features/[id]-[nombre] archive/features/[id]-[nombre]
```

Actualizar la tabla en CLAUDE.md (estado = Completada, o remover de activas).

### 7. El backlog es del proyecto, no de la branch

Las historias en PRODUCT_BACKLOG.md y `backlog/stories/` pertenecen al proyecto general. Una branch puede trabajar en una o mas historias del backlog, pero el backlog no se duplica por branch.

---

## Ejemplo Completo

```
claude_context/jerarquicos/FuturosSociosApi/
  CLAUDE.md                                    # Contexto general
  PRODUCT_BACKLOG.md                           # Backlog del proyecto
  backlog/stories/FS-001-xxx.md                # Historia detallada
  features/
    185688-apilocalizacion/                    # Branch feature/185688_...
      TASK_STATE.md                            # Estado de esta branch
      postman/                                 # Colecciones Postman
  archive/
    features/                                  # Branches completadas
```

---

**Version:** 1.0 | **Ultima actualizacion:** 2026-02-25
