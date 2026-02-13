# ADR-001: Consolidacion de Bases de Datos - courses.db vs transcripts.db

**Estado:** Propuesta
**Fecha:** 2026-01-23
**Autor:** Software Architect (Claude)
**Impacto:** Alto - Cambio arquitectonico fundamental

---

## Contexto y Problema

### Situacion Actual

El proyecto LinkedIn Transcript Extractor (LTE) utiliza 4 bases de datos NeDB:

| Base de Datos | Proposito Original | Estado Actual |
|---------------|-------------------|---------------|
| `courses.db` | Metadata de cursos (titulo, capitulos) | DESINCRONIZADA - Solo 3 cursos |
| `transcripts.db` | Transcripts de videos | SOURCE OF TRUTH - 107 videos, 6 cursos |
| `unassigned_vtts.db` | VTTs pendientes de asignar | Operacional |
| `visited_contexts.db` | Contextos visitados por crawler | Operacional |

### Problema Identificado

Existe una **desincronizacion critica** entre `courses.db` y `transcripts.db`:

```
courses.db (DESACTUALIZADA):
  - enterprise-architecture-in-practice (0 transcripts)
  - hands-on-ai-build-an-autonomous-agent-with-the-claude-agent-sdk (6 transcripts)
  - learning-kubernetes-16086900 (0 transcripts)

transcripts.db (SOURCE OF TRUTH):
  - ai-trends: 66 videos
  - build-with-ai-create-an-agent-with-gpt-oss: 15 videos
  - build-with-ai-leverage-claude-code-subagents-in-software-projects: 7 videos
  - hands-on-ai-build-an-autonomous-agent-with-the-claude-agent-sdk: 6 videos
  - model-context-protocol-mcp-for-beginners-by-microsoft: 11 videos
  - Posiblemente mas cursos...
```

### Causa Raiz

1. **Flujo de datos fragmentado:** El native host (`host.js`) escribe a ambas DBs en `saveTranscript()`, pero la logica de actualizacion de `courses.db` solo se ejecuta al guardar un transcript nuevo, no cuando se actualiza uno existente.

2. **Datos derivados inconsistentes:** `courses.db` almacena metadata que puede derivarse de `transcripts.db` (lista de cursos, capitulos, conteos de videos).

3. **Falta de sincronizacion:** No existe mecanismo para reconciliar las dos bases de datos.

### Impacto del Problema

- **HTTP Server** muestra datos incorrectos (fix temporal aplicado)
- **MCP Server** usa `coursesDb` para `list_courses` y `get_course_structure`, mostrando datos incorrectos
- **Confusion del usuario:** ChatGPT/Claude ven cursos inexistentes o con 0 videos

---

## Analisis de Uso Actual

### Componentes que ESCRIBEN a courses.db

| Archivo | Operacion | Ubicacion |
|---------|-----------|-----------|
| `native-host/host.js` | INSERT/UPDATE | `saveTranscript()` lineas 342-369 |

### Componentes que LEEN de courses.db

| Archivo | Operacion | Proposito |
|---------|-----------|-----------|
| `server/index.js` | `listCourses()` | MCP tool list_courses |
| `server/index.js` | `getCourseStructure()` | MCP tool get_course_structure |
| `server/index.js` | `get_status` | Conteo de cursos |
| `server/http-server.js` | (deshabilitado) | Ya deriva de transcriptsDb |

### Campos en courses.db

```javascript
{
  _id: "course-slug",           // Clave primaria
  title: "Course Title",        // Titulo del curso
  chapters: {                   // Mapa de capitulos
    "chapter-slug": {
      title: "Chapter Title",
      index: 0
    }
  },
  createdAt: "ISO timestamp",
  updatedAt: "ISO timestamp"
}
```

### Campos en transcripts.db (relevantes para derivar cursos)

```javascript
{
  _id: "course-slug/video-slug",
  courseSlug: "course-slug",    // Se puede agrupar
  courseTitle: "Course Title",  // Titulo disponible
  chapterSlug: "chapter-slug",  // Capitulo disponible
  chapterTitle: "Chapter Title",
  chapterIndex: 0,
  videoSlug: "video-slug",
  videoTitle: "Video Title",
  // ... otros campos
}
```

---

## Opciones Evaluadas

### Opcion A: Eliminar courses.db Completamente

**Descripcion:** Derivar toda la metadata de cursos desde `transcripts.db` en tiempo de consulta.

#### Cambios Requeridos

| Archivo | Cambio | Esfuerzo |
|---------|--------|----------|
| `server/index.js` | Reescribir `listCourses()` para agrupar desde transcriptsDb | 1h |
| `server/index.js` | Reescribir `getCourseStructure()` para construir desde transcriptsDb | 1.5h |
| `server/index.js` | Actualizar `get_status` para contar cursos unicos | 0.5h |
| `native-host/host.js` | Eliminar escritura a coursesDb en `saveTranscript()` | 0.5h |
| `scripts/lib/database.js` | Remover export de coursesDb | 0.25h |
| `scripts/match-transcripts.js` | Verificar que no use coursesDb | 0.25h |
| Tests | Actualizar mocks | 1h |
| Cleanup | Eliminar archivo courses.db | 0.1h |

**Esfuerzo Total:** ~5 horas

#### Pros

- **Simplicidad:** Una sola fuente de verdad (transcripts.db)
- **Consistencia garantizada:** Imposible desincronizar
- **Menos codigo:** Elimina logica de sincronizacion en host.js
- **Menos mantenimiento:** Una DB menos que administrar
- **Menor riesgo de bugs:** No hay estado duplicado

#### Contras

- **Performance:** Cada llamada a `listCourses` requiere scan completo de transcripts.db
  - Mitigacion: Agregar indices, cache en memoria
- **Perdida de metadata:** Si courses.db tenia info no disponible en transcripts.db
  - Analisis: Los campos pueden derivarse de transcripts.db

#### Performance Analysis

```javascript
// Consulta actual (courses.db)
dbFind(coursesDb, {})  // O(n) donde n = num cursos (~5-10)

// Consulta derivada (transcripts.db)
dbFind(transcriptsDb, {})  // O(m) donde m = num videos (~100-500)
// + groupBy en memoria: O(m)

// Impacto: 10-50x mas registros a procesar
// Tiempo estimado: <50ms vs <5ms
// Aceptable para operacion poco frecuente
```

#### Riesgos

| Riesgo | Probabilidad | Impacto | Mitigacion |
|--------|--------------|---------|------------|
| Performance degradada con muchos videos | Media | Bajo | Cache en memoria, indices |
| Perdida de datos en courses.db | Baja | Bajo | Verificar que todo es derivable |
| Regresion en MCP server | Media | Alto | Tests antes de eliminar |

---

### Opcion B: Sincronizar courses.db Automaticamente

**Descripcion:** Mantener courses.db como cache de metadata, sincronizada automaticamente.

#### Cambios Requeridos

| Archivo | Cambio | Esfuerzo |
|---------|--------|----------|
| `native-host/host.js` | Mejorar logica de upsert en saveTranscript() | 1.5h |
| Nuevo script | `sync-courses-db.js` para reconciliacion inicial | 2h |
| `server/index.js` | Mantener queries actuales | 0h |
| Cron/trigger | Sincronizacion periodica o event-driven | 2h |
| Tests | Tests de sincronizacion | 2h |

**Esfuerzo Total:** ~7.5 horas

#### Pros

- **Performance optima:** Queries directas a courses.db (pocos registros)
- **Estructura existente:** Menos cambios de API
- **Metadata enriquecida:** Posibilidad de agregar campos no derivables

#### Contras

- **Complejidad:** Dos DBs que mantener sincronizadas
- **Puntos de falla:** Sincronizacion puede fallar o quedar desactualizada
- **Codigo adicional:** Logica de reconciliacion y triggers
- **Deuda tecnica:** Historial muestra que ya fallo antes
- **No resuelve causa raiz:** Solo aplica parche al problema

#### Riesgos

| Riesgo | Probabilidad | Impacto | Mitigacion |
|--------|--------------|---------|------------|
| Desincronizacion futura | Alta | Alto | Monitoreo, reconciliacion periodica |
| Complejidad de bugs | Media | Medio | Tests exhaustivos |
| Performance de sync | Baja | Bajo | Incremental sync |

---

### Opcion C: Hybrid - Cache con Invalidacion

**Descripcion:** Eliminar courses.db como DB persistente, usar cache en memoria con invalidacion.

#### Cambios Requeridos

| Archivo | Cambio | Esfuerzo |
|---------|--------|----------|
| Nuevo modulo | `courses-cache.js` - Cache en memoria con TTL | 3h |
| `server/index.js` | Usar cache en lugar de coursesDb | 1.5h |
| `server/http-server.js` | Usar cache compartido | 0.5h |
| `native-host/host.js` | Eliminar escritura a coursesDb | 0.5h |
| Invalidacion | Trigger al guardar transcript | 1h |
| Tests | Cache tests | 1.5h |

**Esfuerzo Total:** ~8 horas

#### Pros

- **Performance optima:** Cache en memoria, solo rebuild cuando necesario
- **Consistencia:** Cache se invalida al cambiar datos
- **Simplicidad de persistencia:** Solo transcripts.db

#### Contras

- **Mas codigo:** Nuevo modulo de cache
- **Memoria:** Cache ocupa RAM (minimo para este volumen)
- **Complejidad:** Logica de invalidacion
- **Cold start:** Primera consulta requiere rebuild

#### Riesgos

| Riesgo | Probabilidad | Impacto | Mitigacion |
|--------|--------------|---------|------------|
| Cache inconsistente | Baja | Medio | Invalidacion agresiva |
| Memory leaks | Baja | Bajo | TTL y limits |
| Complejidad debugging | Media | Bajo | Logging |

---

## Comparacion de Opciones

| Criterio | Opcion A (Eliminar) | Opcion B (Sincronizar) | Opcion C (Cache) |
|----------|---------------------|------------------------|------------------|
| **Esfuerzo** | 5h | 7.5h | 8h |
| **Simplicidad** | Alta | Baja | Media |
| **Consistencia** | Garantizada | Requiere sync | Garantizada |
| **Performance** | Aceptable | Optima | Optima |
| **Mantenibilidad** | Alta | Baja | Media |
| **Riesgo regresion** | Medio | Bajo | Medio |
| **Deuda tecnica** | Reduce | Aumenta | Neutral |
| **Escalabilidad** | Buena (con indices) | Buena | Muy buena |

---

## Recomendacion

### Opcion A: Eliminar courses.db

**Justificacion:**

1. **Principio KISS:** La solucion mas simple que resuelve el problema.

2. **Single Source of Truth:** Elimina la posibilidad de desincronizacion futura.

3. **Menor esfuerzo:** 5 horas vs 7.5-8 horas de las alternativas.

4. **Reduccion de deuda tecnica:** Menos codigo, menos puntos de falla.

5. **Performance aceptable:** Con ~100-500 videos, la derivacion en tiempo real toma <50ms, aceptable para operaciones no frecuentes como `list_courses`.

6. **Evidencia historica:** El problema actual demuestra que mantener dos DBs sincronizadas es fragil.

### Plan de Implementacion

#### Fase 1: Preparacion (1h)

1. Crear backup de courses.db
2. Documentar estructura actual
3. Verificar que toda la info es derivable de transcripts.db

#### Fase 2: Migracion del MCP Server (2h)

1. Modificar `listCourses()` para derivar de transcriptsDb
2. Modificar `getCourseStructure()` para construir desde transcriptsDb
3. Actualizar `get_status` para contar cursos unicos
4. Tests locales

#### Fase 3: Migracion del Native Host (0.5h)

1. Eliminar escritura a coursesDb en `saveTranscript()`
2. Verificar que no hay side effects

#### Fase 4: Cleanup (1h)

1. Eliminar export de coursesDb en `scripts/lib/database.js`
2. Verificar scripts que usan coursesDb
3. Actualizar tests
4. Eliminar archivo `data/courses.db`

#### Fase 5: Validacion (0.5h)

1. Test end-to-end con MCP client
2. Test end-to-end con HTTP server
3. Verificar que ChatGPT ve los cursos correctos

### Rollback Plan

Si se detectan problemas post-implementacion:

1. Restaurar backup de courses.db
2. Revertir cambios en index.js y host.js (git revert)
3. Evaluar Opcion B o C como alternativa

---

## Decision

**Opcion seleccionada:** A - Eliminar courses.db

**Razon principal:** Simplicidad y eliminacion de deuda tecnica. El problema actual demuestra que mantener dos bases de datos sincronizadas es fragil y propenso a errores.

**Fecha de implementacion prevista:** Sprint actual

**Responsable:** nodejs-backend-developer (agente)

---

## Consecuencias

### Positivas

- Una sola fuente de verdad para datos de cursos
- Imposibilidad de desincronizacion
- Reduccion de 30+ lineas de codigo
- Simplificacion de flujo de datos

### Negativas

- Performance ligeramente menor en listCourses (aceptable)
- Si en el futuro se necesita metadata no derivable, requiere reconsideracion

### Neutras

- Los scripts que usan coursesDb necesitan actualizacion (cleanup de deuda)

---

## Referencias

- Archivo: `C:/mcp/linkedin/server/index.js` - MCP server con funciones a modificar
- Archivo: `C:/mcp/linkedin/native-host/host.js` - Native host con logica de escritura
- Archivo: `C:/mcp/linkedin/server/http-server.js` - Ya implementa derivacion de transcriptsDb
- Documento: `C:/claude_context/linkedin/ARCHITECTURE_ANALYSIS.md` - Analisis arquitectonico

---

## Historial de Cambios

| Fecha | Version | Cambio |
|-------|---------|--------|
| 2026-01-23 | 1.0 | Creacion inicial |
