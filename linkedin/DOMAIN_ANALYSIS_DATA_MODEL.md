# Analisis del Modelo de Datos - LinkedIn Transcript Extractor

**Version:** 1.0
**Fecha de Analisis:** 2026-01-29
**Analista:** Database Expert (Claude)
**Base de Datos:** SQLite (data/lte.db)
**Libreria:** better-sqlite3 via scripts/lib/database.js

---

## Resumen Ejecutivo

El modelo de datos de LTE implementa un sistema de **captura diferida con matching posterior** (deferred matching). Los datos fluyen a traves de tablas intermedias antes de consolidarse en la tabla final de transcripts.

### Metricas Actuales

| Tabla | Registros | Proposito |
|-------|-----------|-----------|
| transcripts | 166 | Transcripts finales asignados a videos |
| unassigned_vtts | 139 | VTTs capturados pendientes/procesados |
| visited_contexts | 158 | Contextos de videos visitados |
| available_captions | 139 | Captions multi-idioma descubiertos |

### Clasificacion de Tablas por Tipo de Entidad

```
┌─────────────────────────────────────────────────────────────┐
│  ENTIDADES DE DOMINIO (Contenido)                           │
│  - transcripts: Almacena Course > Chapter > Video > Content │
│    (Tabla desnormalizada que contiene la jerarquia)         │
├─────────────────────────────────────────────────────────────┤
│  ENTIDADES TRANSITORIAS (Captura)                           │
│  - unassigned_vtts: VTTs pendientes de matching             │
│  - visited_contexts: Contextos visitados durante crawl      │
│  - available_captions: Captions descubiertos (multi-idioma) │
├─────────────────────────────────────────────────────────────┤
│  CONCEPTOS DE INFRAESTRUCTURA (Operaciones)                 │
│  - data/batches/*.json: Estado de batch crawls              │
│  - data/crawls/: Estado de crawls individuales              │
│  (No son tablas SQLite - archivos JSON)                     │
└─────────────────────────────────────────────────────────────┘
```

### Jerarquia de Dominio (Desnormalizada en transcripts)

```
Course (courseSlug, courseTitle)
  └── Chapter (chapterSlug, chapterTitle, chapterIndex)
       └── Video (videoSlug, videoTitle, videoIndex)
            └── Transcript (content, language)
```

**Nota:** La tabla `transcripts` contiene la jerarquia completa desnormalizada. No existen tablas separadas para Course, Chapter o Video.

---

## Diagrama Entidad-Relacion (ASCII)

```
+-------------------+
|   LINKEDIN        |
|   LEARNING        |
|   (External)      |
+--------+----------+
         |
         | Crawl/Intercept
         v
+-------------------+         +-------------------+
|  unassigned_vtts  |         |  visited_contexts |
|-------------------|         |-------------------|
| PK id             |         | PK id             |
| U  content_hash   |<------->| FK matched_vtt_   |
| FK course_slug    |   1:1   |    hash           |
|    content        |         | FK course_slug    |
|    matched        |         | FK video_slug     |
|    matched_to ----+---------+-----> (transcripts.id)
+--------+----------+         +--------+----------+
         |                             |
         | Matching Algorithm          |
         v                             v
+------------------------------------------+
|             transcripts                  |
|------------------------------------------|
| PK id (courseSlug/videoSlug)             |
|    course_slug                           |
|    course_title                          |
|    chapter_slug                          |
|    chapter_title                         |
|    chapter_index                         |
|    video_slug                            |
|    video_title                           |
|    video_index                           |
|    transcript (VTT content)              |
|    language                              |
+--------+---------------------------------+
         ^
         | Discovery (HLS Manifests)
         |
+-------------------+
| available_captions|
|-------------------|
| PK id (auto)      |
| U  (video_id,     |
|    caption_id)    |
| FK course_slug    |
| FK video_slug     |
|    language_code  |
|    fetched        |
+-------------------+

Leyenda:
  PK = Primary Key
  FK = Foreign Key (logica, no enforced)
  U  = UNIQUE constraint
  1:1 = Relacion uno a uno
```

---

## Descripcion de Tablas

### 1. transcripts (Tabla Principal)

**Proposito:** Almacena los transcripts finales asignados a videos especificos.

| Columna | Tipo | Nullable | Default | Descripcion |
|---------|------|----------|---------|-------------|
| id | TEXT | NO (PK) | - | Clave compuesta: `{courseSlug}/{videoSlug}` |
| course_slug | TEXT | NO | - | Identificador del curso (slug URL) |
| course_title | TEXT | SI | NULL | Titulo legible del curso |
| chapter_slug | TEXT | SI | NULL | Identificador del capitulo |
| chapter_title | TEXT | SI | NULL | Titulo del capitulo |
| chapter_index | INTEGER | SI | NULL | Orden del capitulo (1-based) |
| video_slug | TEXT | NO | - | Identificador del video (slug URL) |
| video_title | TEXT | SI | NULL | Titulo legible del video |
| video_index | INTEGER | SI | NULL | Orden del video dentro del capitulo |
| transcript | TEXT | SI | NULL | Contenido VTT completo |
| language | TEXT | SI | 'es' | Codigo ISO 639-1 del idioma |
| duration_seconds | INTEGER | SI | NULL | Duracion del video |
| captured_at | TEXT | SI | NULL | Timestamp ISO de captura |
| updated_at | TEXT | SI | NULL | Timestamp ISO de ultima actualizacion |

**[HECHO] Patron de ID:** `{course_slug}/{video_slug}`
- Ejemplo: `ai-trends/gemini-diffusion-model-26217408`
- Ejemplo: `_posts/post-1769604937947` (para posts de LinkedIn)

**[HECHO] Indices:**
- `idx_transcripts_course` ON (course_slug)
- `idx_transcripts_chapter` ON (course_slug, chapter_slug)
- `idx_transcripts_video_order` ON (course_slug, chapter_index, video_index)
- `idx_transcripts_language` ON (language)
- `idx_transcripts_video` ON (video_index)

**[HECHO] Datos Actuales:**
- Total registros: 166
- Idiomas: es (162), en (4)
- Con chapter_slug: 158 (95%)
- Sin chapter_slug: 8 (5%)
- Cursos unicos: 7

---

### 2. unassigned_vtts (Tabla de Staging)

**Proposito:** Almacena VTTs capturados que aun no han sido asignados a un video, o que ya fueron procesados (matched).

| Columna | Tipo | Nullable | Default | Descripcion |
|---------|------|----------|---------|-------------|
| id | TEXT | NO (PK) | - | Formato: `vtt_{content_hash}` |
| content | TEXT | SI | NULL | Contenido VTT crudo completo |
| text_preview | TEXT | SI | NULL | Primeros ~500 chars del texto |
| content_hash | TEXT | NO (UNIQUE) | - | Hash MD5/SHA del contenido (8 chars hex) |
| captured_at | INTEGER | SI | NULL | Unix timestamp de captura |
| course_slug | TEXT | SI | NULL | Hint del curso (puede ser inexacto) |
| hint_video_slug | TEXT | SI | NULL | Hint del video (de URL interceptada) |
| url | TEXT | SI | NULL | URL original del VTT |
| matched | INTEGER | SI | 0 | Flag booleano: 0=pendiente, 1=procesado |
| matched_to | TEXT | SI | NULL | Referencia al transcript asignado |
| saved_at | TEXT | SI | NULL | Timestamp ISO de guardado |
| detected_language | TEXT | SI | NULL | Idioma detectado automaticamente |

**[HECHO] Patron de ID:** `vtt_{content_hash}` donde hash es 16 chars hex

**[HECHO] Constraint UNIQUE:** content_hash - Previene duplicados por contenido identico

**[HECHO] Indices:**
- `idx_unassigned_vtts_hash` ON (content_hash)
- `idx_unassigned_vtts_course` ON (course_slug)
- `idx_unassigned_vtts_matched` ON (matched)
- `idx_unassigned_vtts_language` ON (detected_language)

**[HECHO] Datos Actuales:**
- Total: 139
- Matched: 93 (67%)
- Unmatched: 46 (33%)

**[HECHO] Valores especiales en matched_to:**
- Patron normal: `{course_slug}/{video_slug}` (referencia a transcripts.id)
- Patron duplicado: `duplicate_of_{content_hash}` (indica VTT redundante)

---

### 3. visited_contexts (Tabla de Staging)

**Proposito:** Registra los videos visitados durante el crawl, con metadata extraida del DOM/JSON-LD.

| Columna | Tipo | Nullable | Default | Descripcion |
|---------|------|----------|---------|-------------|
| id | TEXT | NO (PK) | - | Formato: `ctx_{courseSlug}_{videoSlug}` |
| course_slug | TEXT | NO | - | Slug del curso visitado |
| video_slug | TEXT | NO | - | Slug del video visitado |
| video_title | TEXT | SI | NULL | Titulo extraido de la pagina |
| course_title | TEXT | SI | NULL | Titulo del curso extraido |
| chapter_slug | TEXT | SI | NULL | Slug del capitulo |
| chapter_title | TEXT | SI | NULL | Titulo del capitulo |
| chapter_index | INTEGER | SI | NULL | Orden del capitulo |
| url | TEXT | SI | NULL | URL completa visitada |
| visited_at | TEXT | SI | NULL | Timestamp ISO de la visita |
| visit_order | INTEGER | SI | NULL | Orden secuencial de visita |
| matched | INTEGER | SI | 0 | Flag booleano: 0=sin VTT, 1=con VTT |
| matched_vtt_hash | TEXT | SI | NULL | Hash del VTT asignado |
| saved_at | TEXT | SI | NULL | Timestamp ISO de guardado |

**[HECHO] Patron de ID:** `ctx_{course_slug}_{video_slug}`

**[HECHO] Indices:**
- `idx_visited_contexts_order` ON (visit_order)
- `idx_visited_contexts_course` ON (course_slug)
- `idx_visited_contexts_video` ON (video_slug)
- `idx_visited_contexts_matched` ON (matched)

**[HECHO] Datos Actuales:**
- Total: 158
- Matched: 135 (85%)
- Unmatched: 23 (15%)

---

### 4. available_captions (Tabla de Discovery)

**Proposito:** Almacena caption tracks descubiertos en manifiestos HLS, soportando multi-idioma.

| Columna | Tipo | Nullable | Default | Descripcion |
|---------|------|----------|---------|-------------|
| id | INTEGER | NO (PK) | AUTOINCREMENT | ID secuencial |
| video_id | TEXT | NO | - | ID de video LinkedIn (de URL) |
| course_slug | TEXT | SI | NULL | Slug del curso |
| video_slug | TEXT | SI | NULL | Slug del video |
| caption_id | TEXT | NO | - | ID del caption track (de URL) |
| language_code | TEXT | SI | NULL | Codigo ISO 639-1 |
| language_name | TEXT | SI | NULL | Nombre del idioma (ej: "Spanish") |
| discovered_at | INTEGER | SI | NULL | Unix timestamp de descubrimiento |
| manifest_url | TEXT | SI | NULL | URL del manifiesto HLS |
| fetched | INTEGER | SI | 0 | Flag: 0=pendiente, 1=descargado |
| fetched_at | INTEGER | SI | NULL | Unix timestamp de descarga |

**[HECHO] Constraint UNIQUE:** (video_id, caption_id)

**[HECHO] Patron de video_id:** Identificador LinkedIn del video (ej: `D560DAQFZOItRdPlKYA`)

**[HECHO] Patron de caption_id:** Identificador del track (ej: `B4EZb4dRufHkEM-`)

**[HECHO] Indices:**
- `idx_available_captions_video` ON (video_id)
- `idx_available_captions_course` ON (course_slug)
- `idx_available_captions_lang` ON (language_code)
- `idx_available_captions_fetched` ON (fetched)

**[HECHO] Datos Actuales:**
- Total: 139

---

## Relaciones Identificadas

### Relacion 1: visited_contexts <-> unassigned_vtts (1:1)

**[HECHO] Tipo:** Uno a Uno (logica, no enforced)
**Mecanismo:** `visited_contexts.matched_vtt_hash` = `unassigned_vtts.content_hash`
**Direccion:** Bidireccional
- Context apunta al VTT via `matched_vtt_hash`
- VTT apunta al transcript via `matched_to`

**[DESCONOCIDO]** No hay foreign key constraint, la integridad depende del codigo de matching.

### Relacion 2: unassigned_vtts -> transcripts (N:1)

**[HECHO] Tipo:** Muchos a Uno
**Mecanismo:** `unassigned_vtts.matched_to` contiene el valor de `transcripts.id`
**Observacion:** Un transcript puede tener multiples VTTs apuntando (duplicados marcados como `duplicate_of_*`)

### Relacion 3: visited_contexts -> transcripts (Implicita)

**[HECHO] Tipo:** Derivada via matching
**Mecanismo:** No hay FK directa. La relacion se establece:
1. `visited_contexts` define `course_slug` + `video_slug`
2. El `id` de `transcripts` es `{course_slug}/{video_slug}`
3. El matching algorithm conecta los datos

### Relacion 4: available_captions -> transcripts (Logica)

**[HECHO] Tipo:** Muchos a Uno (logica)
**Mecanismo:** `course_slug` + `video_slug` pueden construir `transcripts.id`
**Observacion:** No enforced, es informativo

---

## Ciclo de Vida de Entidades

### 1. Flujo de Captura de Transcript

```
Etapa 1: CRAWL
  +------------------+        +-------------------+
  | Extension visita |  --->  | visited_contexts  |
  | pagina de video  |        | (INSERT)          |
  +------------------+        | matched = 0       |
                              +-------------------+

Etapa 2: INTERCEPT
  +------------------+        +-------------------+
  | Extension        |  --->  | unassigned_vtts   |
  | intercepta VTT   |        | (INSERT)          |
  +------------------+        | matched = 0       |
                              +-------------------+

Etapa 3: MATCHING (post-crawl)
  +-------------------+       +-------------------+
  | match-transcripts |  <--> | visited_contexts  |
  | algorithm         |       | (UPDATE matched=1)|
  +--------+----------+       +-------------------+
           |
           |                  +-------------------+
           +----------------> | unassigned_vtts   |
           |                  | (UPDATE matched=1)|
           |                  +-------------------+
           |
           v
  +-------------------+
  | transcripts       |
  | (INSERT/UPDATE)   |
  +-------------------+

Etapa 4: DISCOVERY (opcional, v0.14.0+)
  +------------------+        +-------------------+
  | HLS manifest     |  --->  | available_captions|
  | parsing          |        | (INSERT)          |
  +------------------+        | fetched = 0       |
                              +-------------------+
```

### 2. Estados de unassigned_vtts

| matched | matched_to | Estado |
|---------|------------|--------|
| 0 | NULL | Pendiente de matching |
| 1 | `{course}/{video}` | Asignado a transcript |
| 1 | `duplicate_of_{hash}` | Duplicado descartado |

### 3. Estados de visited_contexts

| matched | matched_vtt_hash | Estado |
|---------|-----------------|--------|
| 0 | NULL | Video sin VTT capturado |
| 1 | `{hash}` | VTT asignado exitosamente |

---

## Observaciones sobre el Diseno

### Fortalezas

1. **[HECHO] Deduplicacion por contenido:** El `content_hash` UNIQUE previene duplicados exactos.

2. **[HECHO] Separacion de concerns:** Tablas de staging (`unassigned_vtts`, `visited_contexts`) separadas de datos finales (`transcripts`).

3. **[HECHO] Indices bien disenados:** Cobertura para las queries mas comunes (por curso, por idioma, por estado).

4. **[HECHO] ID compuesto semantico:** `transcripts.id` = `{course}/{video}` es legible y predecible.

5. **[HECHO] Soporte multi-idioma:** Tabla `available_captions` permite descubrir y trackear multiples idiomas por video.

### Debilidades / Observaciones

1. **[HECHO] Sin foreign keys enforced:** Las relaciones son logicas, no hay constraints de integridad referencial en SQLite.

2. **[HECHO] Desnormalizacion en transcripts:** `course_title`, `chapter_title` se repiten en cada video del mismo curso/capitulo. Esto es aceptable dado el volumen bajo de datos (~166 registros).

3. **[HECHO] Timestamps inconsistentes:**
   - `unassigned_vtts.captured_at` es INTEGER (Unix timestamp)
   - `transcripts.captured_at` es TEXT (ISO 8601)
   - `available_captions.discovered_at` es INTEGER (Unix timestamp)

4. **[DESCONOCIDO] Datos huerfanos:** No hay mecanismo para limpiar `unassigned_vtts` despues de matching exitoso. Los registros permanecen con `matched=1`.

5. **[HECHO] Columnas chapter_* agregadas via migracion:** La tabla `visited_contexts` muestra las columnas chapter al final, indicando que fueron agregadas posteriormente con ALTER TABLE.

6. **[HECHO] course_title a veces NULL:** En transcripts, varios cursos tienen `course_title = NULL` (ej: azure-*, hands-on-*). El titulo se pierde si no se captura durante el crawl.

---

## Queries de Referencia

### Obtener estructura de un curso
```sql
SELECT
  course_slug,
  course_title,
  chapter_slug,
  chapter_title,
  chapter_index,
  video_slug,
  video_title,
  video_index
FROM transcripts
WHERE course_slug = 'ai-trends'
ORDER BY chapter_index, video_index;
```

### Encontrar VTTs sin asignar
```sql
SELECT id, text_preview, course_slug, hint_video_slug
FROM unassigned_vtts
WHERE matched = 0
ORDER BY captured_at;
```

### Verificar integridad de matching
```sql
-- Contextos con VTT que no existe en unassigned_vtts
SELECT vc.id, vc.matched_vtt_hash
FROM visited_contexts vc
LEFT JOIN unassigned_vtts uv ON vc.matched_vtt_hash = uv.content_hash
WHERE vc.matched = 1 AND uv.id IS NULL;
```

### Estadisticas por idioma
```sql
SELECT language, COUNT(*) as count
FROM transcripts
GROUP BY language
ORDER BY count DESC;
```

---

## Recomendaciones

### Corto Plazo

1. **Normalizar timestamps:** Elegir un formato (ISO 8601 recomendado) y aplicarlo consistentemente.

2. **Agregar constraint CHECK:** Validar que `language` sea codigo ISO 639-1 valido.

3. **Documentar estados:** Crear enum o tabla de lookup para estados de matching.

### Mediano Plazo

1. **Considerar limpieza de staging:** Opcionalmente, mover VTTs matched a tabla de archivo o eliminarlos.

2. **Normalizar course/chapter info:** Si el volumen crece, considerar tablas separadas para `courses` y `chapters`.

3. **Agregar indices faltantes:** Para busquedas full-text, considerar FTS5 de SQLite.

### Largo Plazo

1. **Migracion a PostgreSQL:** Si se requiere integridad referencial estricta o mayor escala.

2. **Versionado de transcripts:** Tabla de historial para trackear cambios en transcripts.

---

## Historial de Cambios

| Fecha | Version | Cambio |
|-------|---------|--------|
| 2026-01-29 | 1.0 | Analisis inicial del modelo de datos |

---

**Analisis realizado por:** Database Expert Agent
**Validado contra:** data/lte.db (166 transcripts, 7 cursos)
**Fuente de schema:** scripts/lib/database.js (initializeTables)
