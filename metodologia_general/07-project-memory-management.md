# Gestion de Memoria de Proyecto v1.0

**Version:** 1.0
**Fecha:** 2026-02-13
**Estado:** OBLIGATORIO - Aplica a todos los proyectos con claude_context

---

## Principio

Los archivos de contexto se cargan en CADA sesion. **Si esta en contexto activo, debe ser util AHORA.** Informacion historica, sesiones pasadas e historias completadas se archivan fuera del contexto activo.

---

## 1. Limites de Tamaño

| Archivo | Max lineas | Contenido permitido |
|---------|-----------|---------------------|
| `CLAUDE.md` | 150 | Descripcion, stack, comandos, endpoints, agentes, metricas actuales |
| `TASK_STATE.md` | 200 | Solo sesion actual + proximos pasos + decisiones pendientes |
| `PRODUCT_BACKLOG.md` | 300 | Indice (1 linea/historia) + detalle SOLO de historias PENDIENTES |
| `ARCHITECTURE_ANALYSIS.md` | 400 | Arquitectura ACTUAL, TD activo, decisiones vigentes |
| `LEARNINGS.md` | 200 | Patrones y decisiones vigentes |

**Regla:** Si un archivo supera su limite, ejecutar limpieza ANTES de continuar trabajando.

---

## 1b. Observation Masking en TASK_STATE

Al actualizar TASK_STATE, aplicar masking: preservar **decisiones y razonamiento**, descartar **outputs de herramientas y datos transitorios**.

| Preservar | Descartar |
|-----------|-----------|
| Decisiones tomadas y su razon | Output completo de herramientas (grep, build, etc.) |
| Hipotesis confirmadas o descartadas | Listados de archivos intermedios |
| Errores encontrados (mensaje clave) | Stack traces completos (guardar solo la linea relevante) |
| Nombres de archivos creados/modificados | Contenido completo de archivos leidos |
| Plan de trabajo y siguiente paso | Respuestas raw de APIs |

**Ejemplo - Antes (sin masking, 15 lineas):**
```
Ejecute grep en 45 archivos, encontre 12 matches en:
  src/auth/login.ts:23, src/auth/login.ts:45, src/auth/register.ts:12...
Build output: 342 archivos compilados, 0 errores, 2 warnings en...
El error era "Cannot find module '@/utils/hash'" porque...
Decidi usar bcrypt en lugar de argon2 porque el proyecto ya tiene bcrypt como dependencia.
```

**Ejemplo - Despues (con masking, 3 lineas):**
```
Busqueda en src/auth/ revelo 12 usos del modulo hash.
Error: "Cannot find module '@/utils/hash'" - resuelto corrigiendo import path.
Decision: bcrypt (no argon2) porque ya es dependencia del proyecto.
```

---

## 2. Que Mantener vs Que Archivar

| Informacion | Contexto activo | Archivar | Descartar |
|-------------|----------------|----------|-----------|
| Sesion actual (en progreso) | Si | - | - |
| Sesion anterior con cambios significativos | No | `archive/sessions/` | - |
| Sesion anterior trivial (consulta/lectura) | No | - | Si |
| Historia PENDIENTE (AC, tech notes) | Si | - | - |
| Historia DONE compleja (>3 pts) | 1 linea en indice | `archive/stories/` | - |
| Historia DONE trivial (<= 3 pts) | 1 linea en indice | - | Detalle si |
| TD activo | Si | - | - |
| TD resuelto | 1 linea "RESOLVED" | - | Detalle si |
| Arquitectura version anterior | No | `archive/architecture/` | - |
| Metricas obsoletas | No | - | Si |

---

## 3. Estructura de Archivos

```
C:/claude_context/[clasificador]/[proyecto]/
  CLAUDE.md                    # Contexto activo (max 150)
  TASK_STATE.md                # Sesion actual (max 200)
  PRODUCT_BACKLOG.md           # Indice + pendientes (max 300)
  ARCHITECTURE_ANALYSIS.md     # Arquitectura actual (max 400)
  LEARNINGS.md                 # Patrones vigentes (max 200)
  archive/
    sessions/YYYY-MM-DD-descripcion.md
    stories/ID-slug.md
    architecture/vX.Y.Z-analysis.md
```

---

## 4. Proceso de Limpieza

### Triggers

| Trigger | Accion |
|---------|--------|
| Inicio de sesion + archivo excede limite | Limpiar antes de trabajar |
| Historia completada | Reducir a 1 linea en indice, archivar detalle |
| Cierre de sesion | Reducir TASK_STATE a proximos pasos |
| Epic completado | Archivar historias del epic, compactar backlog |
| Trimestralmente | Revisar y actualizar ARCHITECTURE_ANALYSIS |

### Checklist

```
1. [ ] TASK_STATE: Archivar sesiones anteriores -> archive/sessions/
2. [ ] TASK_STATE: Dejar solo sesion actual + proximos pasos
3. [ ] BACKLOG: Historias DONE -> 1 linea en tabla-indice, detalle -> archive/stories/
4. [ ] CLAUDE.md: Actualizar metricas (version, tests, coverage)
5. [ ] CLAUDE.md: Remover items obsoletos
6. [ ] ARCHITECTURE: Verificar que refleja version actual del proyecto
7. [ ] Verificar que ningun archivo excede su limite
```

**Responsable:** Claude ejecuta automaticamente al detectar exceso. El usuario puede solicitar
limpieza explicita con: "limpia la memoria del proyecto".

---

## 5. Templates

### CLAUDE.md (max 150 lineas)

```markdown
# [Proyecto] - Project Context
**Version:** X.Y.Z | **Tests:** N pasando | **Coverage:** N%
**Ubicacion:** [path]

## Stack
[Lista de tecnologias]

## Componentes
| Componente | Ubicacion | Estado |
|------------|-----------|--------|

## Comandos
[Max 10, solo los que se usan regularmente]

## Endpoints / APIs
[Lista concisa]

## Agentes Recomendados
| Tarea | Agente |
|-------|--------|

## Reglas del Proyecto
[Max 5, solo las que NO estan en metodologia general]

## Docs
@imports a TASK_STATE, BACKLOG, ARCHITECTURE, LEARNINGS
```

### TASK_STATE.md (max 200 lineas)

```markdown
# Estado - [Proyecto]
**Actualizacion:** YYYY-MM-DD HH:MM | **Version:** X.Y.Z

## En Progreso
### [ID]: [Titulo]
[Detalle de lo que se esta haciendo, max 30 lineas]

## Completado Esta Sesion
| ID | Titulo | Resultado |
|----|--------|-----------|

## Proximos Pasos
1. [Max 5 items]

## Decisiones Pendientes
[Solo si hay decisiones que el usuario debe tomar]
```

### PRODUCT_BACKLOG.md (max 300 lineas)

```markdown
# Backlog - [Proyecto]
**Version:** X.Y | **Actualizacion:** YYYY-MM-DD

## Resumen
| Metrica | Valor |
|---------|-------|

## Vision
[3-5 lineas]

## Epics
| Epic | Historias | Puntos | Status |
|------|-----------|--------|--------|

## Pendientes (con detalle)
### [ID]: [Titulo]
**Points:** N | **Priority:** X
[AC y tech notes SOLO para historias no completadas]

## Completadas (indice)
| ID | Titulo | Puntos | Fecha | Detalle |
|----|--------|--------|-------|---------|
[1 linea, link a archive/stories/ si existe]

## ID Registry
| Rango | Estado |
|-------|--------|
Proximo ID: LTE-NNN
```

### ARCHITECTURE_ANALYSIS.md (max 400 lineas)

```markdown
# Arquitectura - [Proyecto]
**Version:** X.Y.Z | **Fecha:** YYYY-MM-DD

## Diagrama de Componentes
[Diagrama ASCII]

## Componentes
| Componente | Archivo | Responsabilidad |
|------------|---------|-----------------|

## Flujo de Datos
[Descripcion concisa]

## Technical Debt Activo
| ID | Descripcion | Severidad | ROI |
|----|-------------|-----------|-----|

## Decisiones Arquitectonicas
| Decision | Fecha | Razon |
|----------|-------|-------|

## Stack
[Tecnologias con versiones]
```

### Sesion Archivada (archive/sessions/)

```markdown
# Sesion YYYY-MM-DD - [Descripcion]
## Historias: [ID]: [resultado 1 linea]
## Cambios: | Archivo | Cambio |
## Decisiones: [Decision]: [razon]
```

---

## 6. Metricas de Salud

| Indicador | Umbral | Accion |
|-----------|--------|--------|
| Archivo excede limite de lineas | Inmediata | Limpiar antes de trabajar |
| Mas de 2 sesiones en TASK_STATE | Inicio de sesion | Archivar anteriores |
| CLAUDE.md con info desactualizada | Al detectar | Actualizar |
| ARCHITECTURE version != proyecto | Al detectar | Actualizar o marcar obsoleto |
| Total contexto > 1000 lineas | Evaluar | Limpiar lo menos relevante |

### Validacion Post-Limpieza

1. CLAUDE.md refleja estado ACTUAL (version, metricas, endpoints)
2. TASK_STATE.md tiene contexto suficiente para retomar trabajo
3. BACKLOG tiene detalle de TODAS las historias pendientes
4. No se perdio ninguna decision arquitectonica vigente
5. ID Registry esta completo y actualizado

---

## 7. Integracion con Metodologia

**Al iniciar sesion** (complementa `06-memory-sync.md`):
1. Verificar estructura claude_context (existente)
2. Verificar tamaños contra limites (NUEVO)
3. Si exceden, ejecutar limpieza antes de trabajar (NUEVO)
4. Revisar TASK_STATE para retomar (existente)

**Al completar historia** (complementa `03-obligatory-directives.md`):
1. BACKLOG: historia -> 1 linea en indice, detalle -> archive/stories/
2. CLAUDE.md: actualizar metricas si cambiaron

**Al cerrar sesion** (complementa `02-quick-reference.md`):
1. TASK_STATE: reducir a proximos pasos + decisiones pendientes
2. Archivar sesion si fue significativa
3. CLAUDE.md: actualizar version si cambio

---

## Resumen

```
1. Si esta en contexto activo, debe ser util AHORA
2. Limites: CLAUDE 150, TASK_STATE 200, BACKLOG 300, ARCH 400
3. Historias DONE = 1 linea en indice, detalle en archive/
4. Sesiones anteriores = archivadas o descartadas, NUNCA en contexto activo
5. ARCHITECTURE debe reflejar version actual del proyecto
6. Limpiar ANTES de trabajar si se exceden limites
7. Archivar != borrar: la info se preserva fuera del contexto activo
8. Claude ejecuta limpieza automaticamente cuando detecta exceso
```

---

**Version:** 1.0 | **Ultima actualizacion:** 2026-02-13
