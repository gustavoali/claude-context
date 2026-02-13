# Estructura de Archivos de Backlog - Directiva Obligatoria

**Version:** 1.0
**Fecha:** 2026-02-01
**Estado:** OBLIGATORIO - Aplica a TODOS los proyectos

---

## Proposito

Mantener los backlogs manejables y navegables, evitando archivos monoliticos de miles de lineas que dificultan la lectura y aumentan el consumo de contexto.

---

## Principio Fundamental

**El archivo PRODUCT_BACKLOG.md es un INDICE, no un repositorio de detalles.**

Cada historia debe tener:
- Una linea de resumen en el indice
- Un archivo separado con los detalles completos (si aplica)

---

## Estructura de Archivos

```
C:/claude_context/[proyecto]/
├── PRODUCT_BACKLOG.md          # Indice principal (max 300 lineas)
├── backlog/
│   ├── epics/
│   │   ├── EPIC-001-quality-foundations.md
│   │   ├── EPIC-002-validation.md
│   │   └── ...
│   ├── stories/
│   │   ├── LTE-001-unificar-parser.md
│   │   ├── LTE-002-tests-unitarios.md
│   │   └── ...
│   └── archive/
│       ├── 2026-Q1-completed.md
│       └── ...
└── TASK_STATE.md               # Estado de trabajo en curso
```

---

## Formato del Indice (PRODUCT_BACKLOG.md)

### Estructura Requerida

```markdown
# Product Backlog - [Proyecto]

**Version:** X.Y
**Ultima actualizacion:** YYYY-MM-DD

---

## Resumen

| Metrica | Valor |
|---------|-------|
| Historias pendientes | X |
| Historias en progreso | Y |
| Historias completadas | Z |
| Story points pendientes | N |

---

## Backlog Activo

| ID | Titulo | Puntos | Prioridad | Estado | Archivo |
|----|--------|--------|-----------|--------|---------|
| LTE-044 | Nueva feature X | 5 | High | Pending | [detalle](backlog/stories/LTE-044.md) |
| LTE-045 | Mejora Y | 3 | Medium | In Progress | [detalle](backlog/stories/LTE-045.md) |

---

## Completadas (ultimas 10)

| ID | Titulo | Completada | Archivo |
|----|--------|------------|---------|
| LTE-043 | Documentacion modular | 2026-01-30 | [archivo](backlog/archive/2026-Q1-completed.md#lte-043) |

Ver archivo completo: [2026-Q1-completed.md](backlog/archive/2026-Q1-completed.md)

---

## ID Registry

| Rango | Asignado a |
|-------|------------|
| LTE-001 a LTE-050 | Asignados |
| LTE-051+ | Disponibles |

**Proximo ID:** LTE-051
```

### Reglas del Indice

1. **Maximo 300 lineas** - Si excede, archivar historias antiguas
2. **Una linea por historia** - Solo ID, titulo, puntos, estado
3. **Links a archivos de detalle** - No duplicar contenido
4. **Ultimas 10 completadas** - El resto va al archivo

---

## Formato de Historia Individual

### Archivo: `backlog/stories/LTE-XXX-titulo.md`

```markdown
# LTE-XXX: Titulo de la Historia

**Estado:** Pending | In Progress | Done
**Story Points:** N
**Prioridad:** Critical | High | Medium | Low
**Sprint:** (si asignado)
**Creada:** YYYY-MM-DD
**Completada:** YYYY-MM-DD (si aplica)

---

## User Story

**As a** [tipo de usuario]
**I want** [objetivo]
**So that** [beneficio]

---

## Acceptance Criteria

**AC1: [Nombre]**
- Given [contexto]
- When [accion]
- Then [resultado]

**AC2: [Nombre]**
...

---

## Technical Notes

[Notas tecnicas relevantes]

---

## Archivos Afectados

- `path/to/file1.js`
- `path/to/file2.js`

---

## Resultado (si completada)

**Implementacion:**
- [Resumen de lo implementado]

**Tests:**
- X tests agregados

**Archivos creados/modificados:**
- [Lista]
```

---

## Formato de Epic

### Archivo: `backlog/epics/EPIC-XXX-nombre.md`

```markdown
# Epic XXX: Nombre del Epic

**Estado:** Active | Completed
**Total Story Points:** N
**Historias:** X completadas / Y total

---

## Objetivo

[Descripcion del objetivo del epic]

---

## Historias

| ID | Titulo | Puntos | Estado |
|----|--------|--------|--------|
| LTE-001 | Historia 1 | 3 | Done |
| LTE-002 | Historia 2 | 5 | Done |
| LTE-003 | Historia 3 | 8 | Pending |

---

## Metricas de Completitud

- Fecha inicio: YYYY-MM-DD
- Fecha fin: YYYY-MM-DD (si completado)
- Velocity promedio: X pts/sprint
```

---

## Formato de Archivo de Historias Completadas

### Archivo: `backlog/archive/YYYY-QN-completed.md`

```markdown
# Historias Completadas - YYYY QN

**Periodo:** YYYY-MM-DD a YYYY-MM-DD
**Total historias:** X
**Total story points:** Y

---

## LTE-001: Titulo

**Completada:** YYYY-MM-DD
**Story Points:** N

**Resumen:** [1-2 lineas describiendo que se hizo]

**Archivos principales:**
- `path/to/main/file.js`

---

## LTE-002: Titulo
...
```

---

## Proceso de Trabajo

### Al Crear Nueva Historia

1. Asignar ID del registry
2. Crear archivo `backlog/stories/LTE-XXX-titulo.md` con template
3. Agregar linea al indice en PRODUCT_BACKLOG.md
4. Actualizar contador de proximo ID

### Al Completar Historia

1. Actualizar estado en archivo de historia
2. Agregar fecha de completitud y resultado
3. Mover linea del indice a seccion "Completadas"
4. Si hay mas de 10 completadas en indice, mover las antiguas al archivo de archivo

### Mantenimiento Trimestral

1. Crear nuevo archivo de archivo `YYYY-QN-completed.md`
2. Mover historias completadas del trimestre anterior
3. Comprimir archivos de historias individuales completadas (opcional)

---

## Migracion de Backlogs Existentes

Para proyectos con backlogs monoliticos:

1. Crear estructura de carpetas `backlog/epics/`, `backlog/stories/`, `backlog/archive/`
2. Extraer historias completadas a archivo de archivo
3. Extraer historias pendientes a archivos individuales
4. Reducir PRODUCT_BACKLOG.md a formato de indice
5. Verificar que todos los links funcionen

---

## Beneficios

1. **Indice navegable** - Max 300 lineas, facil de escanear
2. **Detalles bajo demanda** - Solo se lee lo necesario
3. **Menor consumo de contexto** - Claude no carga 1000+ lineas
4. **Historial organizado** - Archivos trimestrales de completadas
5. **Escalable** - Funciona para 10 o 1000 historias

---

## Futura Evolucion: Base de Datos Centralizada

### Propuesta a Evaluar

Desarrollar un sistema de gestion de backlogs con:

**Backend:**
- SQLite o PostgreSQL para almacenar historias
- API REST para CRUD de historias
- Soporte multi-proyecto

**Integracion Claude:**
- MCP Server para consultar/modificar backlog
- Herramientas: `list_stories`, `get_story`, `create_story`, `update_story`
- Generacion automatica de reportes

**Ventajas:**
- Consultas avanzadas (filtrar por estado, prioridad, sprint)
- Metricas automaticas (velocity, burndown)
- Sincronizacion entre sesiones
- Backup centralizado

**Ubicacion propuesta:** `C:/mcp/backlog-manager/`

**Estado:** PROPUESTA - Evaluar despues de validar estructura de archivos

---

## Historial de Cambios

| Fecha | Version | Cambio |
|-------|---------|--------|
| 2026-02-01 | 1.0 | Creacion inicial de la directiva |

---

**Esta directiva es OBLIGATORIA para todos los proyectos con backlog.**
**Implementar en proyectos existentes de forma gradual.**
