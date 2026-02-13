# Normalized Schema Design - LinkedIn Transcript Extractor

**Version:** 1.0
**Fecha:** 2026-01-29
**Autor:** Database Expert (Claude)
**Estado:** PROPUESTA

---

## 1. Diagrama ER (Entity-Relationship)

```
                              DOMAIN ENTITIES
    ============================================================================

    +-------------------+       +-------------------+       +-------------------+
    |     courses       |       |     chapters      |       |      videos       |
    +-------------------+       +-------------------+       +-------------------+
    | PK id (INTEGER)   |<------| PK id (INTEGER)   |<------| PK id (INTEGER)   |
    |    slug (UNIQUE)  |   1:N | FK course_id      |   1:N | FK chapter_id     |
    |    title          |       |    slug           |       |    slug           |
    |    description    |       |    title          |       |    title          |
    |    instructor     |       |    index          |       |    index          |
    |    duration_mins  |       |    created_at     |       |    duration_secs  |
    |    video_count    |       |    updated_at     |       |    created_at     |
    |    created_at     |       +-------------------+       |    updated_at     |
    |    updated_at     |              |                    +-------------------+
    +-------------------+              |                           |
                                       |                           | 1:N
                                       v                           v
                              +-------------------+       +-------------------+
                              |   (derived from   |       |    transcripts    |
                              |    videos count)  |       +-------------------+
                              +-------------------+       | PK id (INTEGER)   |
                                                          | FK video_id (UNQ) |
                                                          |    content (TEXT) |
                                                          |    language       |
                                                          |    format         |
                                                          |    content_hash   |
                                                          |    captured_at    |
                                                          |    updated_at     |
                                                          +-------------------+


                            TRANSIENT ENTITIES (Capture Process)
    ============================================================================

    +-------------------+       +-------------------+       +-------------------+
    |  unassigned_vtts  |       | visited_contexts  |       |available_captions |
    +-------------------+       +-------------------+       +-------------------+
    | PK id (INTEGER)   |       | PK id (INTEGER)   |       | PK id (INTEGER)   |
    |    content_hash   |       |    course_slug    |       |    video_id       |
    |    (UNIQUE)       |       |    video_slug     |       |    caption_id     |
    |    content        |       |    video_title    |       |    (UNIQUE pair)  |
    |    text_preview   |       |    course_title   |       |    language_code  |
    |    course_slug    |       |    chapter_slug   |       |    language_name  |
    |    hint_video_slug|       |    chapter_title  |       |    manifest_url   |
    |    url            |       |    chapter_index  |       |    fetched        |
    |    matched        |       |    url            |       |    discovered_at  |
    |    matched_to     |       |    visited_at     |       |    fetched_at     |
    |    captured_at    |       |    visit_order    |       +-------------------+
    |    saved_at       |       |    matched        |
    +-------------------+       |    matched_vtt_hash|
                                |    saved_at       |
                                +-------------------+


                            RELATIONSHIPS DETAIL
    ============================================================================

    courses ----< chapters ----< videos ----< transcripts
       |             |             |
       | 1:N         | 1:N         | 1:1 (one transcript per video+language)
       |             |             |
       +-------------+-------------+
                     |
          All linked by foreign keys
          with ON DELETE CASCADE


    MATCHING WORKFLOW:
    ==================

    unassigned_vtts  ---------> transcripts
          |                         ^
          | (matched_to)            |
          v                         |
    visited_contexts ---------------+
          |
          | (matched_vtt_hash)
          +---> Links to unassigned_vtts.content_hash

```

---

## 2. DDL Completo (CREATE TABLE Statements)

```sql
-- ============================================================================
-- LINKEDIN TRANSCRIPT EXTRACTOR - NORMALIZED SCHEMA
-- Version: 1.0
-- Date: 2026-01-29
-- ============================================================================

-- Enable foreign key enforcement (SQLite requires this per connection)
PRAGMA foreign_keys = ON;

-- ============================================================================
-- DOMAIN ENTITIES
-- ============================================================================

-- -----------------------------------------------------------------------------
-- COURSES - Root aggregate for LinkedIn Learning courses
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS courses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    slug TEXT NOT NULL UNIQUE,
    title TEXT,
    description TEXT,
    instructor TEXT,
    duration_minutes INTEGER,
    video_count INTEGER DEFAULT 0,
    chapter_count INTEGER DEFAULT 0,
    linkedin_url TEXT,
    thumbnail_url TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Course slug is the primary lookup key
CREATE INDEX IF NOT EXISTS idx_courses_slug ON courses(slug);
CREATE INDEX IF NOT EXISTS idx_courses_title ON courses(title);

-- -----------------------------------------------------------------------------
-- CHAPTERS - Logical groupings within a course
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS chapters (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    course_id INTEGER NOT NULL,
    slug TEXT,
    title TEXT NOT NULL,
    index_order INTEGER NOT NULL DEFAULT 0,
    video_count INTEGER DEFAULT 0,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now')),

    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    UNIQUE(course_id, slug),
    UNIQUE(course_id, index_order)
);

-- Chapters are always queried by course
CREATE INDEX IF NOT EXISTS idx_chapters_course ON chapters(course_id);
CREATE INDEX IF NOT EXISTS idx_chapters_order ON chapters(course_id, index_order);

-- -----------------------------------------------------------------------------
-- VIDEOS - Individual video content within chapters
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS videos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    chapter_id INTEGER NOT NULL,
    slug TEXT NOT NULL,
    title TEXT,
    index_order INTEGER NOT NULL DEFAULT 0,
    duration_seconds INTEGER,
    linkedin_video_id TEXT,
    linkedin_url TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now')),

    FOREIGN KEY (chapter_id) REFERENCES chapters(id) ON DELETE CASCADE,
    UNIQUE(chapter_id, slug)
);

-- Videos queried by chapter and by slug (for URL lookups)
CREATE INDEX IF NOT EXISTS idx_videos_chapter ON videos(chapter_id);
CREATE INDEX IF NOT EXISTS idx_videos_slug ON videos(slug);
CREATE INDEX IF NOT EXISTS idx_videos_order ON videos(chapter_id, index_order);
CREATE INDEX IF NOT EXISTS idx_videos_linkedin_id ON videos(linkedin_video_id);

-- -----------------------------------------------------------------------------
-- TRANSCRIPTS - Actual transcript content (one per video per language)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS transcripts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    video_id INTEGER NOT NULL,
    content TEXT NOT NULL,
    language TEXT NOT NULL DEFAULT 'es',
    format TEXT DEFAULT 'vtt',
    content_hash TEXT NOT NULL,
    word_count INTEGER,
    captured_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now')),

    FOREIGN KEY (video_id) REFERENCES videos(id) ON DELETE CASCADE,
    UNIQUE(video_id, language)
);

-- Transcripts queried by video and language
CREATE INDEX IF NOT EXISTS idx_transcripts_video ON transcripts(video_id);
CREATE INDEX IF NOT EXISTS idx_transcripts_language ON transcripts(language);
CREATE INDEX IF NOT EXISTS idx_transcripts_hash ON transcripts(content_hash);

-- Full-text search on transcript content (optional, for search functionality)
-- CREATE VIRTUAL TABLE IF NOT EXISTS transcripts_fts USING fts5(
--     content,
--     content='transcripts',
--     content_rowid='id'
-- );


-- ============================================================================
-- TRANSIENT ENTITIES (Capture Process)
-- ============================================================================

-- -----------------------------------------------------------------------------
-- UNASSIGNED_VTTS - VTT files captured but not yet matched to videos
-- Used during the crawl process before matching algorithm runs
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS unassigned_vtts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    content_hash TEXT NOT NULL UNIQUE,
    content TEXT NOT NULL,
    text_preview TEXT,
    course_slug TEXT,
    hint_video_slug TEXT,
    url TEXT,
    matched INTEGER NOT NULL DEFAULT 0,
    matched_to TEXT,
    captured_at INTEGER,
    saved_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Efficient lookup by hash and filtering by match status
CREATE INDEX IF NOT EXISTS idx_unassigned_vtts_hash ON unassigned_vtts(content_hash);
CREATE INDEX IF NOT EXISTS idx_unassigned_vtts_course ON unassigned_vtts(course_slug);
CREATE INDEX IF NOT EXISTS idx_unassigned_vtts_matched ON unassigned_vtts(matched);
CREATE INDEX IF NOT EXISTS idx_unassigned_vtts_captured ON unassigned_vtts(captured_at);

-- -----------------------------------------------------------------------------
-- VISITED_CONTEXTS - Page contexts visited during crawl
-- Records video pages visited so VTTs can be matched to them
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS visited_contexts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    course_slug TEXT NOT NULL,
    video_slug TEXT NOT NULL,
    video_title TEXT,
    course_title TEXT,
    chapter_slug TEXT,
    chapter_title TEXT,
    chapter_index INTEGER,
    url TEXT,
    visited_at TEXT,
    visit_order INTEGER,
    matched INTEGER NOT NULL DEFAULT 0,
    matched_vtt_hash TEXT,
    saved_at TEXT NOT NULL DEFAULT (datetime('now')),

    UNIQUE(course_slug, video_slug)
);

-- Efficient matching queries
CREATE INDEX IF NOT EXISTS idx_visited_contexts_course ON visited_contexts(course_slug);
CREATE INDEX IF NOT EXISTS idx_visited_contexts_video ON visited_contexts(video_slug);
CREATE INDEX IF NOT EXISTS idx_visited_contexts_order ON visited_contexts(visit_order);
CREATE INDEX IF NOT EXISTS idx_visited_contexts_matched ON visited_contexts(matched);

-- -----------------------------------------------------------------------------
-- AVAILABLE_CAPTIONS - Caption tracks discovered from HLS manifests
-- Enables multi-language support by tracking all available caption options
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS available_captions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    video_id TEXT NOT NULL,
    course_slug TEXT,
    video_slug TEXT,
    caption_id TEXT NOT NULL,
    language_code TEXT,
    language_name TEXT,
    manifest_url TEXT,
    fetched INTEGER NOT NULL DEFAULT 0,
    discovered_at INTEGER,
    fetched_at INTEGER,

    UNIQUE(video_id, caption_id)
);

-- Caption discovery and fetch status queries
CREATE INDEX IF NOT EXISTS idx_available_captions_video ON available_captions(video_id);
CREATE INDEX IF NOT EXISTS idx_available_captions_course ON available_captions(course_slug);
CREATE INDEX IF NOT EXISTS idx_available_captions_lang ON available_captions(language_code);
CREATE INDEX IF NOT EXISTS idx_available_captions_fetched ON available_captions(fetched);


-- ============================================================================
-- VIEWS FOR BACKWARD COMPATIBILITY AND CONVENIENCE
-- ============================================================================

-- -----------------------------------------------------------------------------
-- VIEW: transcripts_denormalized
-- Provides backward-compatible flat view matching current schema
-- -----------------------------------------------------------------------------
CREATE VIEW IF NOT EXISTS transcripts_denormalized AS
SELECT
    c.slug || '/' || v.slug AS id,
    c.slug AS course_slug,
    c.title AS course_title,
    ch.slug AS chapter_slug,
    ch.title AS chapter_title,
    ch.index_order AS chapter_index,
    v.slug AS video_slug,
    v.title AS video_title,
    v.index_order AS video_index,
    t.content AS transcript,
    t.language,
    v.duration_seconds,
    t.captured_at,
    t.updated_at
FROM transcripts t
INNER JOIN videos v ON t.video_id = v.id
INNER JOIN chapters ch ON v.chapter_id = ch.id
INNER JOIN courses c ON ch.course_id = c.id
ORDER BY c.slug, ch.index_order, v.index_order;

-- -----------------------------------------------------------------------------
-- VIEW: course_summary
-- Provides course-level statistics
-- -----------------------------------------------------------------------------
CREATE VIEW IF NOT EXISTS course_summary AS
SELECT
    c.id,
    c.slug,
    c.title,
    c.instructor,
    c.duration_minutes,
    COUNT(DISTINCT ch.id) AS chapter_count,
    COUNT(DISTINCT v.id) AS video_count,
    COUNT(DISTINCT t.id) AS transcript_count,
    MAX(t.updated_at) AS last_updated
FROM courses c
LEFT JOIN chapters ch ON ch.course_id = c.id
LEFT JOIN videos v ON v.chapter_id = ch.id
LEFT JOIN transcripts t ON t.video_id = v.id
GROUP BY c.id
ORDER BY c.title;

-- -----------------------------------------------------------------------------
-- VIEW: chapter_details
-- Provides chapter-level details with video counts
-- -----------------------------------------------------------------------------
CREATE VIEW IF NOT EXISTS chapter_details AS
SELECT
    ch.id,
    ch.course_id,
    c.slug AS course_slug,
    c.title AS course_title,
    ch.slug AS chapter_slug,
    ch.title AS chapter_title,
    ch.index_order,
    COUNT(DISTINCT v.id) AS video_count,
    COUNT(DISTINCT t.id) AS transcript_count
FROM chapters ch
INNER JOIN courses c ON ch.course_id = c.id
LEFT JOIN videos v ON v.chapter_id = ch.id
LEFT JOIN transcripts t ON t.video_id = v.id
GROUP BY ch.id
ORDER BY c.slug, ch.index_order;


-- ============================================================================
-- TRIGGERS FOR DATA INTEGRITY
-- ============================================================================

-- -----------------------------------------------------------------------------
-- TRIGGER: Update course video_count when video inserted
-- -----------------------------------------------------------------------------
CREATE TRIGGER IF NOT EXISTS trg_update_course_video_count_insert
AFTER INSERT ON videos
BEGIN
    UPDATE courses
    SET video_count = (
        SELECT COUNT(*) FROM videos v
        INNER JOIN chapters ch ON v.chapter_id = ch.id
        WHERE ch.course_id = (
            SELECT course_id FROM chapters WHERE id = NEW.chapter_id
        )
    ),
    updated_at = datetime('now')
    WHERE id = (SELECT course_id FROM chapters WHERE id = NEW.chapter_id);

    UPDATE chapters
    SET video_count = (
        SELECT COUNT(*) FROM videos WHERE chapter_id = NEW.chapter_id
    ),
    updated_at = datetime('now')
    WHERE id = NEW.chapter_id;
END;

-- -----------------------------------------------------------------------------
-- TRIGGER: Update course video_count when video deleted
-- -----------------------------------------------------------------------------
CREATE TRIGGER IF NOT EXISTS trg_update_course_video_count_delete
AFTER DELETE ON videos
BEGIN
    UPDATE courses
    SET video_count = (
        SELECT COUNT(*) FROM videos v
        INNER JOIN chapters ch ON v.chapter_id = ch.id
        WHERE ch.course_id = (
            SELECT course_id FROM chapters WHERE id = OLD.chapter_id
        )
    ),
    updated_at = datetime('now')
    WHERE id = (SELECT course_id FROM chapters WHERE id = OLD.chapter_id);

    UPDATE chapters
    SET video_count = (
        SELECT COUNT(*) FROM videos WHERE chapter_id = OLD.chapter_id
    ),
    updated_at = datetime('now')
    WHERE id = OLD.chapter_id;
END;

-- -----------------------------------------------------------------------------
-- TRIGGER: Update course chapter_count when chapter inserted
-- -----------------------------------------------------------------------------
CREATE TRIGGER IF NOT EXISTS trg_update_course_chapter_count_insert
AFTER INSERT ON chapters
BEGIN
    UPDATE courses
    SET chapter_count = (
        SELECT COUNT(*) FROM chapters WHERE course_id = NEW.course_id
    ),
    updated_at = datetime('now')
    WHERE id = NEW.course_id;
END;

-- -----------------------------------------------------------------------------
-- TRIGGER: Update course chapter_count when chapter deleted
-- -----------------------------------------------------------------------------
CREATE TRIGGER IF NOT EXISTS trg_update_course_chapter_count_delete
AFTER DELETE ON chapters
BEGIN
    UPDATE courses
    SET chapter_count = (
        SELECT COUNT(*) FROM chapters WHERE course_id = OLD.course_id
    ),
    updated_at = datetime('now')
    WHERE id = OLD.course_id;
END;

-- -----------------------------------------------------------------------------
-- TRIGGER: Update transcript word_count on insert/update
-- -----------------------------------------------------------------------------
CREATE TRIGGER IF NOT EXISTS trg_update_transcript_word_count
AFTER INSERT ON transcripts
BEGIN
    UPDATE transcripts
    SET word_count = (
        SELECT length(NEW.content) - length(replace(NEW.content, ' ', '')) + 1
    )
    WHERE id = NEW.id;
END;
```

---

## 3. Indices Recomendados

### Indices Primarios (Ya incluidos en DDL)

| Tabla | Indice | Columnas | Proposito |
|-------|--------|----------|-----------|
| courses | idx_courses_slug | slug | Lookup por URL slug |
| courses | idx_courses_title | title | Busqueda por titulo |
| chapters | idx_chapters_course | course_id | JOIN con courses |
| chapters | idx_chapters_order | course_id, index_order | Ordenamiento |
| videos | idx_videos_chapter | chapter_id | JOIN con chapters |
| videos | idx_videos_slug | slug | Lookup por URL |
| videos | idx_videos_order | chapter_id, index_order | Ordenamiento |
| transcripts | idx_transcripts_video | video_id | JOIN con videos |
| transcripts | idx_transcripts_language | language | Filtro por idioma |
| transcripts | idx_transcripts_hash | content_hash | Deduplicacion |

### Indices Adicionales Recomendados (Para Queries Frecuentes)

```sql
-- Busqueda de video por course_slug + video_slug (lookup directo)
CREATE INDEX IF NOT EXISTS idx_videos_course_video_lookup ON videos(slug)
WHERE slug IS NOT NULL;

-- Busqueda full-text en transcripts (si se habilita FTS5)
-- Requiere trigger para mantener sincronizado
CREATE TRIGGER IF NOT EXISTS trg_transcripts_fts_insert AFTER INSERT ON transcripts
BEGIN
    INSERT INTO transcripts_fts(rowid, content) VALUES (NEW.id, NEW.content);
END;

CREATE TRIGGER IF NOT EXISTS trg_transcripts_fts_delete AFTER DELETE ON transcripts
BEGIN
    DELETE FROM transcripts_fts WHERE rowid = OLD.id;
END;

CREATE TRIGGER IF NOT EXISTS trg_transcripts_fts_update AFTER UPDATE ON transcripts
BEGIN
    DELETE FROM transcripts_fts WHERE rowid = OLD.id;
    INSERT INTO transcripts_fts(rowid, content) VALUES (NEW.id, NEW.content);
END;

-- Indice compuesto para matching workflow
CREATE INDEX IF NOT EXISTS idx_matching_course_video
ON visited_contexts(course_slug, video_slug, matched);
```

### Analisis de Performance de Indices

| Query Pattern | Indice Usado | Notas |
|---------------|--------------|-------|
| `SELECT * FROM courses WHERE slug = ?` | idx_courses_slug | O(1) lookup |
| `SELECT * FROM chapters WHERE course_id = ? ORDER BY index_order` | idx_chapters_order | Covering index |
| `SELECT * FROM videos WHERE chapter_id = ? ORDER BY index_order` | idx_videos_order | Covering index |
| `SELECT * FROM transcripts WHERE video_id = ?` | idx_transcripts_video | FK lookup |
| `SELECT * FROM transcripts WHERE language = ?` | idx_transcripts_language | Filtro global |
| `SELECT ... FROM transcripts WHERE content LIKE '%query%'` | Full scan (o FTS5) | Usar FTS5 para mejor performance |

---

## 4. Estrategia de Migracion

### Overview

La migracion debe ser **no-destructiva** y **reversible**. Se mantiene el schema actual como backup y se migran los datos a las nuevas tablas normalizadas.

### Fases de Migracion

```
FASE 1: Preparacion (Sin cambios en produccion)
=========================================================
1.1. Crear backup de lte.db
1.2. Crear nuevo archivo lte_normalized.db
1.3. Crear todas las tablas nuevas (vacias)
1.4. Verificar integridad del schema

FASE 2: Migracion de Datos
=========================================================
2.1. Extraer cursos unicos -> INSERT INTO courses
2.2. Extraer capitulos unicos -> INSERT INTO chapters
2.3. Extraer videos unicos -> INSERT INTO videos
2.4. Migrar transcripts -> INSERT INTO transcripts (nuevo)
2.5. Verificar conteos (old.count == new.count)

FASE 3: Actualizacion de Codigo
=========================================================
3.1. Actualizar database.js con nuevas funciones
3.2. Mantener funciones legacy con deprecation warnings
3.3. Actualizar tests
3.4. Probar en ambiente de desarrollo

FASE 4: Deployment
=========================================================
4.1. Backup final de produccion
4.2. Ejecutar migracion en produccion
4.3. Monitorear errores
4.4. Rollback si es necesario

FASE 5: Cleanup (Post-verificacion)
=========================================================
5.1. Eliminar tablas legacy despues de 2 semanas
5.2. Eliminar funciones deprecated despues de 1 mes
5.3. Actualizar documentacion
```

### Script de Migracion

```sql
-- ============================================================================
-- MIGRATION SCRIPT: Denormalized -> Normalized Schema
-- Run this AFTER creating the new tables (DDL above)
-- ============================================================================

-- Disable foreign keys during migration for performance
PRAGMA foreign_keys = OFF;

-- -----------------------------------------------------------------------------
-- STEP 1: Extract unique courses
-- -----------------------------------------------------------------------------
INSERT INTO courses (slug, title, created_at, updated_at)
SELECT DISTINCT
    course_slug,
    course_title,
    MIN(captured_at),
    MAX(updated_at)
FROM transcripts_old
WHERE course_slug IS NOT NULL
GROUP BY course_slug;

-- Verify: SELECT COUNT(*) FROM courses;

-- -----------------------------------------------------------------------------
-- STEP 2: Extract unique chapters
-- -----------------------------------------------------------------------------
INSERT INTO chapters (course_id, slug, title, index_order, created_at, updated_at)
SELECT DISTINCT
    c.id,
    t.chapter_slug,
    COALESCE(t.chapter_title, 'Main Content'),
    COALESCE(t.chapter_index, 0),
    MIN(t.captured_at),
    MAX(t.updated_at)
FROM transcripts_old t
INNER JOIN courses c ON c.slug = t.course_slug
WHERE t.chapter_slug IS NOT NULL OR t.chapter_index IS NOT NULL
GROUP BY c.id, t.chapter_slug, t.chapter_index;

-- Handle videos without chapter info (create default chapter)
INSERT INTO chapters (course_id, slug, title, index_order, created_at, updated_at)
SELECT
    c.id,
    '_default',
    'Main Content',
    0,
    c.created_at,
    c.updated_at
FROM courses c
WHERE NOT EXISTS (
    SELECT 1 FROM chapters ch WHERE ch.course_id = c.id
);

-- Verify: SELECT COUNT(*) FROM chapters;

-- -----------------------------------------------------------------------------
-- STEP 3: Extract unique videos
-- -----------------------------------------------------------------------------
INSERT INTO videos (chapter_id, slug, title, index_order, duration_seconds, created_at, updated_at)
SELECT DISTINCT
    ch.id,
    t.video_slug,
    t.video_title,
    COALESCE(t.video_index, 0),
    t.duration_seconds,
    MIN(t.captured_at),
    MAX(t.updated_at)
FROM transcripts_old t
INNER JOIN courses c ON c.slug = t.course_slug
INNER JOIN chapters ch ON ch.course_id = c.id
    AND (ch.slug = t.chapter_slug OR (ch.slug = '_default' AND t.chapter_slug IS NULL))
WHERE t.video_slug IS NOT NULL
GROUP BY ch.id, t.video_slug;

-- Verify: SELECT COUNT(*) FROM videos;

-- -----------------------------------------------------------------------------
-- STEP 4: Migrate transcripts
-- -----------------------------------------------------------------------------
INSERT INTO transcripts (video_id, content, language, content_hash, captured_at, updated_at)
SELECT
    v.id,
    t.transcript,
    COALESCE(t.language, 'es'),
    -- Generate hash if not available
    lower(hex(randomblob(16))),
    t.captured_at,
    t.updated_at
FROM transcripts_old t
INNER JOIN courses c ON c.slug = t.course_slug
INNER JOIN chapters ch ON ch.course_id = c.id
    AND (ch.slug = t.chapter_slug OR (ch.slug = '_default' AND t.chapter_slug IS NULL))
INNER JOIN videos v ON v.chapter_id = ch.id AND v.slug = t.video_slug
WHERE t.transcript IS NOT NULL;

-- Verify: SELECT COUNT(*) FROM transcripts;

-- -----------------------------------------------------------------------------
-- STEP 5: Update denormalized counts
-- -----------------------------------------------------------------------------
UPDATE courses SET
    video_count = (
        SELECT COUNT(*) FROM videos v
        INNER JOIN chapters ch ON v.chapter_id = ch.id
        WHERE ch.course_id = courses.id
    ),
    chapter_count = (
        SELECT COUNT(*) FROM chapters WHERE course_id = courses.id
    );

UPDATE chapters SET
    video_count = (
        SELECT COUNT(*) FROM videos WHERE chapter_id = chapters.id
    );

-- Re-enable foreign keys
PRAGMA foreign_keys = ON;

-- -----------------------------------------------------------------------------
-- VERIFICATION QUERIES
-- -----------------------------------------------------------------------------

-- Compare old vs new counts
SELECT 'Old transcripts' as source, COUNT(*) as count FROM transcripts_old
UNION ALL
SELECT 'New transcripts (via view)', COUNT(*) FROM transcripts_denormalized;

-- Verify all courses migrated
SELECT 'Courses' as entity, COUNT(*) FROM courses
UNION ALL
SELECT 'Chapters', COUNT(*) FROM chapters
UNION ALL
SELECT 'Videos', COUNT(*) FROM videos
UNION ALL
SELECT 'Transcripts', COUNT(*) FROM transcripts;

-- Verify no orphans
SELECT 'Orphan chapters' as issue, COUNT(*) as count
FROM chapters WHERE course_id NOT IN (SELECT id FROM courses)
UNION ALL
SELECT 'Orphan videos', COUNT(*)
FROM videos WHERE chapter_id NOT IN (SELECT id FROM chapters)
UNION ALL
SELECT 'Orphan transcripts', COUNT(*)
FROM transcripts WHERE video_id NOT IN (SELECT id FROM videos);
```

### Rollback Strategy

```sql
-- ============================================================================
-- ROLLBACK SCRIPT: If migration fails
-- ============================================================================

-- Drop new tables (in reverse dependency order)
DROP TABLE IF EXISTS transcripts;
DROP TABLE IF EXISTS videos;
DROP TABLE IF EXISTS chapters;
DROP TABLE IF EXISTS courses;

-- Drop views
DROP VIEW IF EXISTS transcripts_denormalized;
DROP VIEW IF EXISTS course_summary;
DROP VIEW IF EXISTS chapter_details;

-- Rename old table back
ALTER TABLE transcripts_old RENAME TO transcripts;

-- Restore original indexes
-- (run original initializeTables code)
```

---

## 5. Queries de Ejemplo (JOINs Tipicos)

### Query 1: Obtener estructura completa de un curso

```sql
-- Equivalent to current getCourseStructure()
SELECT
    c.slug AS course_slug,
    c.title AS course_title,
    ch.slug AS chapter_slug,
    ch.title AS chapter_title,
    ch.index_order AS chapter_index,
    v.slug AS video_slug,
    v.title AS video_title,
    v.index_order AS video_index,
    v.duration_seconds,
    CASE WHEN t.id IS NOT NULL THEN 1 ELSE 0 END AS has_transcript,
    t.language
FROM courses c
INNER JOIN chapters ch ON ch.course_id = c.id
INNER JOIN videos v ON v.chapter_id = ch.id
LEFT JOIN transcripts t ON t.video_id = v.id
WHERE c.slug = ?
ORDER BY ch.index_order, v.index_order;
```

### Query 2: Buscar en transcripts

```sql
-- Equivalent to current searchTranscripts()
SELECT
    c.slug AS course_slug,
    c.title AS course_title,
    ch.slug AS chapter_slug,
    ch.title AS chapter_title,
    v.slug AS video_slug,
    v.title AS video_title,
    t.language,
    substr(t.content, 1, 500) AS snippet
FROM transcripts t
INNER JOIN videos v ON t.video_id = v.id
INNER JOIN chapters ch ON v.chapter_id = ch.id
INNER JOIN courses c ON ch.course_id = c.id
WHERE t.content LIKE '%' || ? || '%'
ORDER BY c.slug, ch.index_order, v.index_order
LIMIT 50;

-- With FTS5 (much faster for large datasets):
SELECT
    c.slug AS course_slug,
    v.slug AS video_slug,
    snippet(transcripts_fts, 0, '<mark>', '</mark>', '...', 64) AS snippet
FROM transcripts_fts
INNER JOIN transcripts t ON transcripts_fts.rowid = t.id
INNER JOIN videos v ON t.video_id = v.id
INNER JOIN chapters ch ON v.chapter_id = ch.id
INNER JOIN courses c ON ch.course_id = c.id
WHERE transcripts_fts MATCH ?
ORDER BY rank
LIMIT 50;
```

### Query 3: Listar cursos con estadisticas

```sql
-- Equivalent to current getCourseList()
SELECT
    c.slug,
    c.title,
    c.video_count AS videoCount,
    c.chapter_count AS chapterCount,
    (
        SELECT MAX(t.updated_at)
        FROM transcripts t
        INNER JOIN videos v ON t.video_id = v.id
        INNER JOIN chapters ch ON v.chapter_id = ch.id
        WHERE ch.course_id = c.id
    ) AS lastUpdated
FROM courses c
ORDER BY c.title;

-- Or use the view:
SELECT slug, title, video_count, chapter_count, last_updated
FROM course_summary
ORDER BY title;
```

### Query 4: Obtener transcript por ID (legacy format)

```sql
-- Equivalent to current getTranscriptById('course-slug/video-slug')
SELECT
    c.slug || '/' || v.slug AS id,
    c.slug AS course_slug,
    c.title AS course_title,
    ch.slug AS chapter_slug,
    ch.title AS chapter_title,
    ch.index_order AS chapter_index,
    v.slug AS video_slug,
    v.title AS video_title,
    v.index_order AS video_index,
    t.content AS transcript,
    t.language,
    v.duration_seconds,
    t.captured_at,
    t.updated_at
FROM transcripts t
INNER JOIN videos v ON t.video_id = v.id
INNER JOIN chapters ch ON v.chapter_id = ch.id
INNER JOIN courses c ON ch.course_id = c.id
WHERE c.slug = ? AND v.slug = ?;
```

### Query 5: Guardar transcript (INSERT con lookup)

```sql
-- New saveTranscript() implementation
-- Step 1: Ensure course exists
INSERT INTO courses (slug, title) VALUES (?, ?)
ON CONFLICT(slug) DO UPDATE SET
    title = COALESCE(excluded.title, courses.title),
    updated_at = datetime('now');

-- Step 2: Ensure chapter exists
INSERT INTO chapters (course_id, slug, title, index_order)
SELECT id, ?, ?, ?
FROM courses WHERE slug = ?
ON CONFLICT(course_id, slug) DO UPDATE SET
    title = COALESCE(excluded.title, chapters.title),
    index_order = COALESCE(excluded.index_order, chapters.index_order),
    updated_at = datetime('now');

-- Step 3: Ensure video exists
INSERT INTO videos (chapter_id, slug, title, index_order, duration_seconds)
SELECT ch.id, ?, ?, ?, ?
FROM chapters ch
INNER JOIN courses c ON ch.course_id = c.id
WHERE c.slug = ? AND ch.slug = ?
ON CONFLICT(chapter_id, slug) DO UPDATE SET
    title = COALESCE(excluded.title, videos.title),
    index_order = COALESCE(excluded.index_order, videos.index_order),
    duration_seconds = COALESCE(excluded.duration_seconds, videos.duration_seconds),
    updated_at = datetime('now');

-- Step 4: Insert/Update transcript
INSERT INTO transcripts (video_id, content, language, content_hash)
SELECT v.id, ?, ?, ?
FROM videos v
INNER JOIN chapters ch ON v.chapter_id = ch.id
INNER JOIN courses c ON ch.course_id = c.id
WHERE c.slug = ? AND v.slug = ?
ON CONFLICT(video_id, language) DO UPDATE SET
    content = excluded.content,
    content_hash = excluded.content_hash,
    updated_at = datetime('now');
```

### Query 6: Estadisticas por idioma

```sql
-- Enhanced getStats()
SELECT
    t.language,
    COUNT(DISTINCT c.id) AS course_count,
    COUNT(DISTINCT v.id) AS video_count,
    COUNT(t.id) AS transcript_count,
    SUM(t.word_count) AS total_words
FROM transcripts t
INNER JOIN videos v ON t.video_id = v.id
INNER JOIN chapters ch ON v.chapter_id = ch.id
INNER JOIN courses c ON ch.course_id = c.id
GROUP BY t.language
ORDER BY transcript_count DESC;
```

---

## 6. Trade-offs y Decisiones de Diseno

### Decision 1: Normalizacion vs Desnormalizacion

| Aspecto | Schema Actual (Desnormalizado) | Schema Nuevo (Normalizado) |
|---------|-------------------------------|---------------------------|
| **Lectura** | Rapida (single table) | Requiere JOINs |
| **Escritura** | Duplica datos (course_title en cada row) | Una sola escritura por entidad |
| **Consistencia** | Puede tener inconsistencias | Garantizada por FK |
| **Storage** | Mayor (datos duplicados) | Menor (normalizacion) |
| **Flexibilidad** | Limitada | Alta (multi-idioma facil) |

**Decision:** Normalizar pero proveer VIEW para queries frecuentes.

**Justificacion:**
- El proyecto captura ~100-500 videos. El overhead de JOINs es negligible.
- La consistencia de datos es critica para un sistema de transcripts.
- La flexibilidad para multi-idioma justifica la normalizacion.

### Decision 2: INTEGER vs TEXT para Primary Keys

| Aspecto | TEXT (slug como PK) | INTEGER AUTOINCREMENT |
|---------|--------------------|-----------------------|
| **Readability** | Alta (human-readable) | Baja (opaque ID) |
| **Performance** | Menor (string comparison) | Mayor (integer comparison) |
| **Flexibility** | Baja (slug puede cambiar) | Alta (ID inmutable) |
| **FK Joins** | Mas lentos | Mas rapidos |

**Decision:** INTEGER AUTOINCREMENT como PK, slug como UNIQUE INDEX.

**Justificacion:**
- LinkedIn puede cambiar slugs en URLs.
- JOINs con INTEGER son 2-3x mas rapidos en SQLite.
- El ID opaco permite renombrar sin romper relaciones.

### Decision 3: Tablas Transitorias vs Normalizadas

| Aspecto | Normalizar Transitorias | Mantener Actuales |
|---------|------------------------|-------------------|
| **Complejidad** | Mayor | Menor |
| **Consistencia** | Mayor | Suficiente |
| **Uso** | Temporal (durante crawl) | Temporal |
| **Lifetime** | Se limpian despues de match | Se limpian despues de match |

**Decision:** Mantener tablas transitorias con estructura actual.

**Justificacion:**
- Son tablas de staging, no de dominio.
- Su lifetime es corto (durante crawl).
- La estructura actual funciona bien.
- Normalizarlas agregaria complejidad sin beneficio.

### Decision 4: Views vs Queries Directas

| Aspecto | Views | Queries en Codigo |
|---------|-------|-------------------|
| **Performance** | Igual (SQLite optimiza) | Igual |
| **Mantenimiento** | Centralizado en DDL | Distribuido en codigo |
| **Flexibilidad** | Menor (schema fijo) | Mayor |
| **Backward Compat** | Excelente | Requiere refactor |

**Decision:** Crear VIEW `transcripts_denormalized` para backward compatibility.

**Justificacion:**
- Permite migracion gradual del codigo.
- Funciones legacy pueden seguir funcionando.
- La vista actua como "contract" para API existente.

### Decision 5: Triggers vs Codigo de Aplicacion

| Aspecto | Triggers | Codigo de Aplicacion |
|---------|----------|---------------------|
| **Consistencia** | Garantizada (DB level) | Depende de implementacion |
| **Performance** | Overhead por operacion | Control total |
| **Debugging** | Mas dificil | Mas facil |
| **Testability** | Mas dificil | Mas facil |

**Decision:** Triggers para contadores denormalizados (video_count, chapter_count).

**Justificacion:**
- Los contadores deben estar siempre actualizados.
- El overhead es minimo (solo INSERT/DELETE).
- Evita bugs por olvidar actualizar contadores.

### Decision 6: FTS5 para Busqueda Full-Text

| Aspecto | LIKE '%query%' | FTS5 |
|---------|----------------|------|
| **Performance** | O(n) scan | O(log n) index |
| **Funcionalidad** | Basica | Rica (ranking, snippets) |
| **Storage** | Ninguno | Adicional (~30% del texto) |
| **Complejidad** | Baja | Media |

**Decision:** Opcional, habilitar si el dataset crece >1000 transcripts.

**Justificacion:**
- Actualmente ~100 transcripts, LIKE es suficiente.
- Agregar FTS5 es facil despues (sin migracion).
- El storage adicional no justifica para datasets pequenos.

---

## 7. Metricas de Evaluacion

### Storage Comparison (Estimado)

```
Schema Actual (107 videos, 6 cursos):
- transcripts table: ~2.5 MB (con duplicacion de course_title, chapter_title)

Schema Normalizado (mismo data):
- courses: ~2 KB (6 rows x 300 bytes)
- chapters: ~5 KB (25 rows x 200 bytes)
- videos: ~15 KB (107 rows x 150 bytes)
- transcripts: ~2.3 MB (107 rows, solo contenido)
- TOTAL: ~2.32 MB

Ahorro: ~7% (principalmente eliminacion de duplicados)
```

### Query Performance (Estimado)

| Query | Schema Actual | Schema Normalizado |
|-------|---------------|-------------------|
| Get transcript by ID | O(1) index lookup | O(1) + 3 JOINs |
| List courses | O(n) GROUP BY | O(1) table scan |
| Search transcripts | O(n) LIKE | O(n) LIKE (o O(log n) con FTS5) |
| Course structure | O(n) filter + GROUP | O(log n) JOINs con index |

**Nota:** Para datasets <1000 rows, la diferencia es imperceptible (<10ms).

---

## 8. Proximos Pasos

1. **Revisar propuesta** con el equipo
2. **Aprobar DDL** antes de implementar
3. **Crear rama de migracion** (`feature/normalized-schema`)
4. **Implementar migracion** paso a paso
5. **Actualizar database.js** con nuevas funciones
6. **Actualizar tests** para nuevo schema
7. **Deploy gradual** con periodo de prueba
8. **Cleanup** de codigo legacy

---

## 9. Referencias

- [SQLite Foreign Key Support](https://www.sqlite.org/foreignkeys.html)
- [SQLite FTS5](https://www.sqlite.org/fts5.html)
- [better-sqlite3 Documentation](https://github.com/WiseLibs/better-sqlite3)
- [Database Normalization (Wikipedia)](https://en.wikipedia.org/wiki/Database_normalization)

---

**Documento creado:** 2026-01-29
**Estado:** PROPUESTA - Pendiente aprobacion
**Autor:** Database Expert (Claude)
