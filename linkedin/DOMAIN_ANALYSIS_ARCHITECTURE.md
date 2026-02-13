# Analisis de Dominio - LinkedIn Transcript Extractor

**Fecha:** 2026-01-29
**Version del Sistema:** 0.13.0
**Analista:** Software Architect (Claude)
**Metodologia:** Domain-Driven Design (DDD)

---

## Executive Summary

Este documento presenta un analisis de dominio riguroso del sistema LinkedIn Transcript Extractor (LTE), distinguiendo entre hechos observados directamente en el codigo fuente y hipotesis que requieren verificacion adicional.

El sistema LTE es una solucion de captura y consulta de transcripciones de LinkedIn Learning, compuesto por multiples bounded contexts que colaboran para interceptar, almacenar, y exponer contenido de video para consumo por LLMs.

---

## 1. Modelo de Dominio

### Clasificacion de Conceptos

```
┌─────────────────────────────────────────────────────────────┐
│  ENTIDADES DE DOMINIO (Contenido)                           │
│  - Course (agregado raiz)                                   │
│      └── Chapter (value object)                             │
│           └── Video (value object)                          │
│                └── Transcript (entidad)                     │
├─────────────────────────────────────────────────────────────┤
│  ENTIDADES TRANSITORIAS (Captura)                           │
│  - UnassignedVtt (VTT pendiente de asignar)                 │
│  - VisitedContext (contexto de video visitado)              │
├─────────────────────────────────────────────────────────────┤
│  CONCEPTOS DE INFRAESTRUCTURA (Operaciones)                 │
│  - Crawl (proceso de captura de un curso)                   │
│  - Batch (orquestacion de multiples capturas)               │
└─────────────────────────────────────────────────────────────┘
```

---

### 1.1 Entidades de Dominio (Contenido)

#### Transcript (Entidad)

**[HECHO]** Observado en `scripts/lib/database.js` lineas 85-103:

```
Tabla: transcripts
Columnas:
- id (INTEGER PRIMARY KEY AUTOINCREMENT)
- courseSlug (TEXT NOT NULL)
- videoSlug (TEXT NOT NULL)
- content (TEXT NOT NULL) -- Contenido VTT completo
- language (TEXT)
- capturedAt (TEXT DEFAULT CURRENT_TIMESTAMP)
- source (TEXT DEFAULT 'extension')
- matchMethod (TEXT) -- hint_direct, semantic, order, translation
- matchScore (REAL)
- matchedAt (TEXT)
- hintSlug (TEXT) -- Pista de matching desde VTT interceptor

Index unico: (courseSlug, videoSlug)
```

**Invariantes [HECHO]:**
- Un transcript pertenece a exactamente un video (courseSlug + videoSlug)
- El contenido es obligatorio (NOT NULL)
- La combinacion courseSlug/videoSlug es unica

**Invariantes [HIPOTESIS]:**
- El contenido siempre esta en formato VTT valido (no hay validacion explicita)
- El idioma detectado siempre es correcto (basado en heuristicas)

---

### 1.2 Entidades Transitorias (Captura)

Estas entidades existen temporalmente durante el proceso de captura y matching.

#### UnassignedVtt

**[HECHO]** Observado en `scripts/lib/database.js` lineas 105-123:

```
Tabla: unassigned_vtts
Columnas:
- id (INTEGER PRIMARY KEY AUTOINCREMENT)
- url (TEXT NOT NULL)
- content (TEXT NOT NULL)
- contentHash (TEXT NOT NULL UNIQUE)
- capturedAt (TEXT DEFAULT CURRENT_TIMESTAMP)
- language (TEXT)
- source (TEXT DEFAULT 'extension')
- hintSlug (TEXT) -- Agregado en v0.13.0

Index: contentHash (unico)
```

**Invariantes [HECHO]:**
- Cada VTT tiene un hash de contenido unico (deduplicacion)
- El URL de origen es obligatorio
- Es una entidad temporal hasta ser asignada a un transcript

**Ciclo de Vida [HECHO]:**
1. Capturado por extension o crawler
2. Almacenado en unassigned_vtts
3. Procesado por match-transcripts.js
4. Movido a transcripts (si hay match) o eliminado

---

#### VisitedContext

**[HECHO]** Observado en `scripts/lib/database.js` lineas 125-147:

```
Tabla: visited_contexts
Columnas:
- id (INTEGER PRIMARY KEY AUTOINCREMENT)
- courseSlug (TEXT NOT NULL)
- videoSlug (TEXT NOT NULL)
- chapterSlug (TEXT)
- chapterTitle (TEXT)
- chapterIndex (INTEGER)
- videoTitle (TEXT)
- videoIndex (INTEGER)
- visitedAt (TEXT DEFAULT CURRENT_TIMESTAMP)
- matched (INTEGER DEFAULT 0) -- boolean

Index unico: (courseSlug, videoSlug)
```

**Proposito [HECHO]:**
- Registrar videos visitados durante el crawl
- Proporcionar contexto para el matching diferido
- Trackear estado de matching (matched = 0/1)

---

#### Course (Agregado Raiz)

**[HECHO]** No existe tabla explicita. Se deriva de transcripts mediante agregacion.

Observado en `server/http-server.js` lineas 180-210:

```javascript
function getCourses() {
  const rows = db.prepare(`
    SELECT DISTINCT courseSlug,
           COUNT(*) as videoCount,
           MIN(capturedAt) as firstCaptured,
           MAX(capturedAt) as lastCaptured
    FROM transcripts
    GROUP BY courseSlug
  `).all();
  return rows;
}
```

**Estructura Jerarquica [HECHO]:**
```
Course (courseSlug)
  └── Chapter[] (chapterSlug, chapterTitle, chapterIndex)
        └── Video[] (videoSlug, videoTitle, videoIndex)
              └── Transcript (content, language)
```

**[HIPOTESIS]:** Course podria beneficiarse de ser una entidad explicita con metadata propia (titulo, descripcion, instructor, duracion total).

---

#### Chapter (Value Object dentro de Course)

**[HECHO]** Observado en `visited_contexts` tabla, columnas agregadas en LTE-023:

```
Atributos (almacenados en visited_contexts):
- chapterSlug (TEXT) -- Identificador del capitulo
- chapterTitle (TEXT) -- Titulo legible del capitulo
- chapterIndex (INTEGER) -- Posicion ordinal dentro del curso
```

**[HECHO]** Captura implementada en:
- `extension/background.js`: sendContextToNativeHost() envia chapter info
- `native-host/host.js`: handleSaveContext() persiste chapter info
- `scripts/lib/database.js`: Schema incluye las 3 columnas de chapter

**Invariantes [HECHO]:**
- Un capitulo pertenece a exactamente un curso
- chapterIndex indica el orden dentro del curso
- Multiples videos pueden pertenecer al mismo capitulo

**Invariantes [HIPOTESIS]:**
- chapterSlug es unico dentro de un curso (no hay constraint explicito)
- Los capitulos siempre tienen titulo (puede ser NULL en la practica)

**Uso en el Dominio:**
- Permite agrupar videos por seccion tematica
- Facilita navegacion estructurada del contenido
- Util para generar tablas de contenido (TOC)

---

### 1.3 Conceptos de Infraestructura (Operaciones)

Estos conceptos representan procesos operacionales, no entidades de negocio. El usuario final no piensa en "crawls" o "batches" - piensa en cursos y transcripts.

#### Batch

**[HECHO]** Observado en `crawler/batch-manager.js`:

```javascript
// Estado persistido en data/batches/{batch-id}.json
{
  batchId: string,
  status: 'pending' | 'crawling' | 'paused' | 'completed' | 'failed',
  courses: [
    { url, slug, status, startedAt?, completedAt?, error?, stats? }
  ],
  createdAt: timestamp,
  startedAt?: timestamp,
  completedAt?: timestamp,
  stats: { total, completed, failed, pending }
}
```

**Invariantes [HECHO]:**
- Solo un curso puede procesarse a la vez (cola secuencial)
- Estado se persiste en archivo JSON
- Rate limiting entre cursos (configurable)

**Relacion con Crawl:**
Un Batch orquesta multiples capturas secuenciales. Internamente no crea entidades Crawl explicitas - gestiona su propia cola de cursos.

---

#### Crawl

**[HECHO]** Observado en `server/http-server.js` lineas 443-520:

```javascript
// Estado en memoria + directorio data/crawls/
const crawlProcesses = new Map(); // crawlId -> { process, status, stats }

// Estructura de crawl
{
  crawlId: string,
  status: 'pending' | 'running' | 'completed' | 'failed',
  url: string,
  startedAt: timestamp,
  completedAt?: timestamp,
  stats: { videosProcessed, transcriptsCaptured, errors }
}
```

**Uso:**
- `POST /api/crawl` inicia un Crawl individual (un curso)
- `POST /api/batch-crawl` inicia un Batch que procesa multiples cursos secuencialmente

---

### 1.2 Value Objects

#### ContentHash

**[HECHO]** Observado en `native-host/host.js` y `crawler/vtt-interceptor.js`:

```javascript
// Normalizacion para hash
const normalizedContent = content
  .replace(/\r\n/g, '\n')
  .replace(/\s+/g, ' ')
  .trim();
const contentHash = crypto.createHash('md5')
  .update(normalizedContent)
  .digest('hex');
```

**Proposito:** Deduplicacion de VTTs identicos independiente de whitespace.

---

#### VideoIdentifier

**[HECHO]** Compuesto por:
- `courseSlug`: Identificador del curso (ej: "azure-ai-for-developers")
- `videoSlug`: Identificador del video (ej: "introduction-to-azure-speech")

**Derivacion [HECHO]** desde URL:
```
https://www.linkedin.com/learning/{courseSlug}/videos/{videoSlug}
```

---

#### MatchScore

**[HECHO]** Observado en `scripts/match-transcripts.js`:

```javascript
// Rango: 0.0 - 1.0
// Threshold para match semantico: 0.3
// Metodos de matching con score implicito:
// - hint_direct: 1.0 (match exacto por hintSlug)
// - semantic: 0.3 - 1.0 (similitud de keywords)
// - order: 0.0 (fallback por orden temporal)
// - translation: 0.0 (fallback por traduccion)
```

---

#### Language

**[HECHO]** Observado en multiples archivos:

```javascript
// Valores conocidos
const SUPPORTED_LANGUAGES = ['es', 'en', 'pt', 'fr', 'de', 'it', 'ja', 'ko', 'zh'];

// Deteccion usando tinyld
const { detect } = require('tinyld');
const language = detect(textContent);
```

**[HIPOTESIS]:** El sistema prioriza espanol pero la logica de filtrado varia entre componentes.

---

### 1.3 Diagrama de Entidades y Relaciones

```
┌─────────────────────────────────────────────────────────────────────┐
│                         MODELO DE DOMINIO                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────┐         1:N         ┌──────────────────┐         │
│  │    Course    │◄────────────────────│    Transcript    │         │
│  │  (derivado)  │                     │   (agregado)     │         │
│  ├──────────────┤                     ├──────────────────┤         │
│  │ courseSlug   │                     │ id               │         │
│  │ videoCount   │                     │ courseSlug (FK)  │         │
│  │ firstCaptured│                     │ videoSlug        │         │
│  │ lastCaptured │                     │ content          │         │
│  └──────────────┘                     │ language         │         │
│                                       │ matchMethod      │         │
│                                       │ matchScore       │         │
│                                       │ hintSlug         │         │
│                                       └────────┬─────────┘         │
│                                                │                    │
│                                       ┌────────┴─────────┐         │
│                                       │    Matching      │         │
│                                       │    Process       │         │
│                                       └────────┬─────────┘         │
│                                                │                    │
│         ┌──────────────────┐          ┌───────┴────────┐          │
│         │  UnassignedVtt   │◄─────────│ VisitedContext │          │
│         │  (transitorio)   │  match   │  (tracking)    │          │
│         ├──────────────────┤          ├────────────────┤          │
│         │ id               │          │ id             │          │
│         │ url              │          │ courseSlug     │          │
│         │ content          │          │ videoSlug      │          │
│         │ contentHash      │          │ chapterSlug    │          │
│         │ language         │          │ chapterTitle   │          │
│         │ hintSlug         │          │ videoTitle     │          │
│         └──────────────────┘          │ matched        │          │
│                                       └────────────────┘          │
│                                                                     │
│  ┌──────────────┐         1:N         ┌──────────────────┐         │
│  │    Batch     │◄────────────────────│     Crawl        │         │
│  │ (orquestador)│                     │   (proceso)      │         │
│  ├──────────────┤                     ├──────────────────┤         │
│  │ batchId      │                     │ crawlId          │         │
│  │ status       │                     │ url              │         │
│  │ courses[]    │                     │ status           │         │
│  │ stats        │                     │ stats            │         │
│  └──────────────┘                     └──────────────────┘         │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 2. Ubiquitous Language (Glosario de Terminos)

### Terminos del Dominio

| Termino | Definicion | Fuente [HECHO] |
|---------|------------|----------------|
| **Transcript** | Contenido textual de las captions de un video, almacenado en formato VTT | database.js:85 |
| **VTT** | WebVTT - formato de subtitulos con timestamps | extension/vtt-parser.js |
| **Course** | Agrupacion logica de videos en LinkedIn Learning | Derivado de transcripts |
| **Video** | Unidad atomica de contenido, identificada por courseSlug + videoSlug | URLs de LinkedIn |
| **Slug** | Identificador URL-friendly derivado del titulo | Convencion LinkedIn |
| **Caption** | Sinonimo de subtitle/transcript en contexto de video | background.js |
| **Chapter** | Seccion dentro de un curso que agrupa videos relacionados | visited_contexts |
| **Crawl** | Proceso automatizado de navegacion y captura de un curso | auto-crawler.js |
| **Batch** | Coleccion de crawls ejecutados secuencialmente | batch-manager.js |
| **Match** | Asociacion de un VTT no asignado con su video correspondiente | match-transcripts.js |
| **Hint** | Pista de matching extraida del nombre de archivo VTT | vtt-interceptor.js |
| **Content Hash** | Hash MD5 del contenido normalizado para deduplicacion | host.js |
| **Native Host** | Proceso Node.js que recibe mensajes de la extension Chrome | host.js |
| **MCP** | Model Context Protocol - protocolo para exponer herramientas a LLMs | server/index.js |

### Terminos Tecnicos

| Termino | Definicion | Contexto |
|---------|------------|----------|
| **Service Worker** | Contexto de ejecucion de la extension Chrome (Manifest V3) | background.js |
| **webRequest** | API de Chrome para interceptar requests de red | background.js |
| **page.route()** | API de Playwright para interceptar requests | vtt-interceptor.js |
| **Native Messaging** | Protocolo Chrome para comunicacion con procesos nativos | host.js |
| **StorageManager** | Modulo para gestionar estado con patron hibrido (memoria + storage) | extension/storage-manager.js |

### Estados del Sistema

| Estado | Entidad | Significado |
|--------|---------|-------------|
| **pending** | Crawl/Batch | En cola, esperando ejecucion |
| **crawling/running** | Crawl/Batch | En proceso de captura |
| **paused** | Batch | Detenido temporalmente por usuario |
| **completed** | Crawl/Batch | Finalizado exitosamente |
| **failed** | Crawl/Batch | Finalizado con error |
| **matched** | VisitedContext | VTT asignado exitosamente |
| **unmatched** | VisitedContext | Pendiente de asignacion |

---

## 3. Bounded Contexts

### 3.1 Diagrama de Bounded Contexts

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        LINKEDIN TRANSCRIPT EXTRACTOR                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────┐      ┌─────────────────────────┐              │
│  │    CAPTURE CONTEXT      │      │    MATCHING CONTEXT     │              │
│  │   (Captura de VTTs)     │      │  (Asignacion diferida)  │              │
│  ├─────────────────────────┤      ├─────────────────────────┤              │
│  │ - background.js         │      │ - match-transcripts.js  │              │
│  │ - vtt-interceptor.js    │──────│ - Algoritmos:           │              │
│  │ - content.js            │ VTT  │   * hint_direct         │              │
│  │                         │      │   * semantic            │              │
│  │ Responsabilidades:      │      │   * order-based         │              │
│  │ - Detectar VTT URLs     │      │   * translation         │              │
│  │ - Filtrar por idioma    │      │                         │              │
│  │ - Extraer contexto      │      │ Responsabilidades:      │              │
│  │ - Deduplicar            │      │ - Asociar VTT a video   │              │
│  └─────────────────────────┘      │ - Calcular scores       │              │
│                                   │ - Mover a transcripts   │              │
│                                   └─────────────────────────┘              │
│                                                                             │
│  ┌─────────────────────────┐      ┌─────────────────────────┐              │
│  │   STORAGE CONTEXT       │      │    CRAWL CONTEXT        │              │
│  │  (Persistencia datos)   │      │ (Automatizacion)        │              │
│  ├─────────────────────────┤      ├─────────────────────────┤              │
│  │ - database.js           │      │ - auto-crawler.js       │              │
│  │ - host.js               │      │ - batch-manager.js      │              │
│  │                         │      │ - folder-parser.js      │              │
│  │ Responsabilidades:      │      │                         │              │
│  │ - CRUD transcripts      │◄─────│ Responsabilidades:      │              │
│  │ - CRUD unassigned_vtts  │      │ - Navegar cursos        │              │
│  │ - CRUD visited_contexts │      │ - Expandir TOC          │              │
│  │ - Backup/Restore        │      │ - Reproducir videos     │              │
│  │ - Migraciones           │      │ - Gestionar cola batch  │              │
│  └─────────────────────────┘      └─────────────────────────┘              │
│                                                                             │
│  ┌─────────────────────────┐      ┌─────────────────────────┐              │
│  │     API CONTEXT         │      │   EXTENSION CONTEXT     │              │
│  │  (Exposicion datos)     │      │     (UI Chrome)         │              │
│  ├─────────────────────────┤      ├─────────────────────────┤              │
│  │ - http-server.js        │      │ - popup.js              │              │
│  │ - index.js (MCP)        │      │ - popup.html            │              │
│  │                         │      │                         │              │
│  │ Responsabilidades:      │      │ Responsabilidades:      │              │
│  │ - REST API (ChatGPT)    │      │ - Mostrar VTTs          │              │
│  │ - MCP Tools (Claude)    │      │ - Copy to clipboard     │              │
│  │ - OpenAPI spec          │      │ - Configuracion         │              │
│  │ - Busqueda semantica    │      │                         │              │
│  └─────────────────────────┘      └─────────────────────────┘              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### 3.2 Capture Context (Contexto de Captura)

**Responsabilidad:** Interceptar y extraer VTTs de LinkedIn Learning.

**Componentes [HECHO]:**
- `extension/background.js` - Service worker con webRequest listeners
- `extension/content.js` - Extractor de contexto de pagina
- `crawler/vtt-interceptor.js` - Interceptor Playwright

**Entidades Manejadas:**
- UnassignedVtt (creacion)
- VisitedContext (creacion)

**Flujo Principal [HECHO]:**

```
1. Usuario/Crawler navega a video LinkedIn Learning
2. Extension detecta URL de VTT via webRequest.onBeforeRequest
3. content.js extrae contexto (courseSlug, videoSlug, chapter info)
4. background.js fetch el contenido VTT
5. Deteccion de idioma (tinyld)
6. Envio a Native Host via Native Messaging
7. Host guarda en unassigned_vtts con contentHash
```

**Patrones de URL VTT [HECHO]:**
```javascript
// Observado en vtt-interceptor.js
const VTT_PATTERNS = [
  /\.vtt(\?|$)/i,
  /captions.*\.vtt/i,
  /subtitles.*\.vtt/i,
  /transcript.*\.vtt/i
];
```

**Estrategia de Hint [HECHO]:**
```javascript
// vtt-interceptor.js - Extraccion de hint desde URL
// URL: /captions/azure-speech-intro_es.vtt
// Hint: azure-speech-intro
const hintSlug = extractSlugFromVttUrl(url);
```

**Anti-Corruption Layer [HECHO]:**
- Normalizacion de contenido antes de hash
- Filtrado de VTTs no-espanol (configurable)
- Deduplicacion por contentHash

---

### 3.3 Matching Context (Contexto de Emparejamiento)

**Responsabilidad:** Asociar VTTs no asignados con sus videos correspondientes.

**Componentes [HECHO]:**
- `scripts/match-transcripts.js` - Motor de matching

**Algoritmos de Matching [HECHO]:**

```
Prioridad 1: HINT_DIRECT
- VTT tiene hintSlug que coincide exactamente con videoSlug
- Score: 1.0
- Confianza: ALTA

Prioridad 2: SEMANTIC
- Extraccion de keywords de videoTitle
- Calculo de similitud con contenido VTT
- Threshold: 0.3
- Score: 0.3 - 1.0
- Confianza: MEDIA

Prioridad 3: ORDER
- Matching por orden temporal de captura
- Score: 0.0 (implicito)
- Confianza: BAJA

Prioridad 4: TRANSLATION
- Para VTTs en idioma diferente al esperado
- Intenta match con contextos sin VTT asignado
- Confianza: BAJA
```

**Proceso de Matching [HECHO]:**

```javascript
// match-transcripts.js - Fases
async function runMatching(options) {
  // Fase 1: Cargar datos
  const vtts = database.getUnassignedVtts();
  const contexts = database.getUnmatchedContexts();

  // Fase 2: Matching por prioridad
  for (const vtt of vtts) {
    // 2a: Hint direct
    let match = findHintMatch(vtt, contexts);

    // 2b: Semantic
    if (!match) match = findSemanticMatch(vtt, contexts);

    // 2c: Order-based
    if (!match) match = findOrderMatch(vtt, contexts);
  }

  // Fase 3: Guardar matches
  for (const match of matches) {
    database.saveTranscript(match);
    database.markContextMatched(match.contextId);
  }

  // Fase 4: Cleanup VTTs matched
  database.deleteMatchedVtts();
}
```

**Invariantes de Matching [HECHO]:**
- Un VTT solo puede asignarse a un video
- Un video solo tiene un transcript activo (puede tener versiones archivadas)
- Matches con hint_direct tienen prioridad absoluta

**[HIPOTESIS]:**
- El threshold semantico de 0.3 puede ser demasiado bajo para algunos casos
- El fallback por orden puede introducir errores sistematicos
- No hay mecanismo de rollback si un match es incorrecto

---

### 3.4 Storage Context (Contexto de Almacenamiento)

**Responsabilidad:** Persistencia y recuperacion de datos.

**Componentes [HECHO]:**
- `scripts/lib/database.js` - API de base de datos SQLite
- `native-host/host.js` - Bridge para extension

**Tablas [HECHO]:**

| Tabla | Proposito | Indices |
|-------|-----------|---------|
| transcripts | Transcripciones asignadas | (courseSlug, videoSlug) UNIQUE |
| unassigned_vtts | VTTs pendientes | contentHash UNIQUE |
| visited_contexts | Videos visitados | (courseSlug, videoSlug) UNIQUE |

**Operaciones Principales [HECHO]:**

```javascript
// database.js - Operaciones CRUD
saveTranscript(courseSlug, videoSlug, content, options)
getTranscript(courseSlug, videoSlug)
getAllTranscripts()
searchTranscripts(query)

saveUnassignedVtt(url, content, options)
getUnassignedVtts()
deleteUnassignedVtt(id)

saveVisitedContext(courseSlug, videoSlug, options)
getUnmatchedContexts()
markContextMatched(id)
```

**Estrategia de Migracion [HECHO]:**
```javascript
// database.js - Migracion automatica
function initializeDatabase() {
  // Crear tablas si no existen
  // Agregar columnas nuevas con ALTER TABLE
  // Migrar datos de formatos anteriores
}
```

**Backup [HECHO]:**
```bash
npm run db:backup    # Crea backup con timestamp
npm run db:restore   # Restaura desde backup
```

---

### 3.5 Crawl Context (Contexto de Rastreo)

**Responsabilidad:** Automatizacion de navegacion y captura.

**Componentes [HECHO]:**
- `crawler/auto-crawler.js` - Crawler de cursos individuales
- `crawler/batch-manager.js` - Orquestador de batches
- `crawler/folder-parser.js` - Parser de carpetas/colecciones

**Flujo de Crawl Individual [HECHO]:**

```
1. Recibir URL de curso
2. Lanzar Playwright con extension cargada
3. Navegar a pagina del curso
4. Expandir todos los capitulos (expandAllChapters)
5. Extraer enlaces de videos del TOC (extractVideoLinksFromTOC)
6. Para cada video:
   a. Navegar a URL del video
   b. Esperar carga de player
   c. VTT Interceptor captura automaticamente
   d. Esperar tiempo configurable
7. Post-crawl: Ejecutar matching
8. Reportar estadisticas
```

**Flujo de Batch [HECHO]:**

```
1. Recibir URL de carpeta/coleccion
2. folder-parser extrae lista de cursos
3. batch-manager crea cola con estado persistido
4. Para cada curso en cola:
   a. Actualizar estado a 'crawling'
   b. Ejecutar crawl individual
   c. Actualizar estado a 'completed' o 'failed'
   d. Esperar delay configurable (rate limiting)
5. Finalizar batch cuando cola vacia
```

**Estados de Batch [HECHO]:**
```
pending → crawling → completed
                  ↘ failed
          ↙ paused (manual)
```

**Rate Limiting [HECHO]:**
```javascript
// batch-manager.js
const DELAY_BETWEEN_COURSES_MS = 60000; // 60 segundos
```

---

### 3.6 API Context (Contexto de Exposicion)

**Responsabilidad:** Exponer datos para consumo externo (LLMs).

**Componentes [HECHO]:**
- `server/http-server.js` - REST API para ChatGPT
- `server/index.js` - MCP Server para Claude

**Endpoints REST [HECHO]:**

| Endpoint | Metodo | Proposito |
|----------|--------|-----------|
| /api/status | GET | Health check |
| /api/courses | GET | Lista de cursos |
| /api/courses/:slug | GET | Estructura de curso |
| /api/courses/:slug/transcript | GET | Transcript completo |
| /api/search | GET | Busqueda en transcripts |
| /api/ask | POST | Pregunta sobre contenido |
| /api/crawl | POST | Iniciar crawl |
| /api/crawl/:id/status | GET | Estado de crawl |
| /api/batch-crawl | POST | Iniciar batch |
| /api/batch-crawl/:id/status | GET | Estado de batch |
| /openapi.json | GET | OpenAPI spec |

**MCP Tools [HECHO]:**

```javascript
// server/index.js - 11 herramientas
const TOOLS = [
  'list_courses',
  'get_course_structure',
  'get_video_transcript',
  'search_transcripts',
  'ask_about_content',
  'get_topics_overview',
  'compare_videos',
  'get_full_course_content',
  'find_prerequisites',
  'check_for_updates',
  'list_learnings'
];
```

---

## 4. Flujos de Datos

### 4.1 Flujo: Captura via Extension (Manual)

```
┌────────┐     ┌───────────┐     ┌────────────┐     ┌───────────┐     ┌──────────┐
│ Usuario│────▶│ LinkedIn  │────▶│ Chrome     │────▶│ Native    │────▶│ SQLite   │
│        │     │ Learning  │     │ Extension  │     │ Host      │     │ Database │
└────────┘     └───────────┘     └────────────┘     └───────────┘     └──────────┘
                    │                   │                 │                 │
                    │  1. Load video    │                 │                 │
                    │──────────────────▶│                 │                 │
                    │                   │                 │                 │
                    │  2. VTT request   │                 │                 │
                    │──────────────────▶│                 │                 │
                    │                   │                 │                 │
                    │  3. Intercept     │                 │                 │
                    │                   │─────────────────│                 │
                    │                   │  4. Context     │                 │
                    │                   │  extraction     │                 │
                    │                   │─────────────────│                 │
                    │                   │                 │                 │
                    │                   │  5. Native Msg  │                 │
                    │                   │────────────────▶│                 │
                    │                   │                 │                 │
                    │                   │                 │  6. Save VTT    │
                    │                   │                 │────────────────▶│
                    │                   │                 │                 │
```

### 4.2 Flujo: Captura via Crawler (Automatizado)

```
┌────────┐     ┌───────────┐     ┌────────────┐     ┌───────────┐     ┌──────────┐
│ API    │────▶│ Crawler   │────▶│ Playwright │────▶│ VTT       │────▶│ SQLite   │
│ Server │     │           │     │ Browser    │     │Interceptor│     │ Database │
└────────┘     └───────────┘     └────────────┘     └───────────┘     └──────────┘
     │               │                 │                 │                 │
     │ 1. POST       │                 │                 │                 │
     │  /api/crawl   │                 │                 │                 │
     │──────────────▶│                 │                 │                 │
     │               │                 │                 │                 │
     │               │ 2. Launch       │                 │                 │
     │               │────────────────▶│                 │                 │
     │               │                 │                 │                 │
     │               │ 3. Navigate     │                 │                 │
     │               │────────────────▶│                 │                 │
     │               │                 │                 │                 │
     │               │                 │ 4. Intercept    │                 │
     │               │                 │ VTT requests    │                 │
     │               │                 │────────────────▶│                 │
     │               │                 │                 │                 │
     │               │                 │                 │ 5. Save         │
     │               │                 │                 │────────────────▶│
     │               │                 │                 │                 │
     │               │ 6. Run matching │                 │                 │
     │               │─────────────────│─────────────────│────────────────▶│
     │               │                 │                 │                 │
```

### 4.3 Flujo: Matching Post-Crawl

```
┌────────────┐     ┌───────────┐     ┌────────────┐     ┌───────────┐
│ match-     │────▶│ unassigned│────▶│ visited_   │────▶│transcripts│
│transcripts │     │ _vtts     │     │ contexts   │     │           │
└────────────┘     └───────────┘     └────────────┘     └───────────┘
      │                  │                 │                  │
      │ 1. Load VTTs     │                 │                  │
      │─────────────────▶│                 │                  │
      │                  │                 │                  │
      │ 2. Load contexts │                 │                  │
      │─────────────────────────────────▶ │                  │
      │                  │                 │                  │
      │ 3. Match (hint/semantic/order)    │                  │
      │─────────────────│────────────────▶│                  │
      │                  │                 │                  │
      │ 4. Save matched transcripts       │                  │
      │────────────────────────────────────────────────────▶ │
      │                  │                 │                  │
      │ 5. Update        │                 │                  │
      │    matched=1     │                 │                  │
      │─────────────────────────────────▶ │                  │
      │                  │                 │                  │
      │ 6. Delete        │                 │                  │
      │    processed     │                 │                  │
      │─────────────────▶│                 │                  │
```

### 4.4 Flujo: Consulta via LLM

```
┌────────┐     ┌───────────┐     ┌────────────┐     ┌───────────┐
│ ChatGPT│────▶│ HTTP      │────▶│ database.js│────▶│ SQLite    │
│ /Claude│     │ Server    │     │            │     │           │
└────────┘     └───────────┘     └────────────┘     └───────────┘
     │               │                 │                  │
     │ 1. GET        │                 │                  │
     │  /api/search  │                 │                  │
     │  ?q=azure     │                 │                  │
     │──────────────▶│                 │                  │
     │               │                 │                  │
     │               │ 2. Search       │                  │
     │               │────────────────▶│                  │
     │               │                 │                  │
     │               │                 │ 3. FTS query     │
     │               │                 │─────────────────▶│
     │               │                 │                  │
     │               │                 │ 4. Results       │
     │               │                 │◀─────────────────│
     │               │                 │                  │
     │               │ 5. Format       │                  │
     │               │◀────────────────│                  │
     │               │                 │                  │
     │ 6. JSON       │                 │                  │
     │◀──────────────│                 │                  │
```

---

## 5. Invariantes de Dominio (Reglas de Negocio)

### 5.1 Invariantes de Captura

| ID | Regla | Verificacion | Estado |
|----|-------|--------------|--------|
| INV-CAP-01 | Todo VTT capturado debe tener contentHash unico | UNIQUE constraint en DB | [HECHO] |
| INV-CAP-02 | Todo VTT debe tener URL de origen | NOT NULL constraint | [HECHO] |
| INV-CAP-03 | Contexto visitado tiene courseSlug + videoSlug unicos | UNIQUE constraint | [HECHO] |
| INV-CAP-04 | Solo se capturan VTTs en idioma preferido | Filtro en interceptor | [HIPOTESIS] - codigo comentado |

### 5.2 Invariantes de Matching

| ID | Regla | Verificacion | Estado |
|----|-------|--------------|--------|
| INV-MAT-01 | Un VTT solo puede asignarse a un video | Logica de matching exclusiva | [HECHO] |
| INV-MAT-02 | Match hint_direct tiene prioridad absoluta | Orden de algoritmos | [HECHO] |
| INV-MAT-03 | Threshold semantico >= 0.3 para aceptar match | Constante en codigo | [HECHO] |
| INV-MAT-04 | Contextos matched no participan en matching futuro | Campo matched=1 | [HECHO] |

### 5.3 Invariantes de Storage

| ID | Regla | Verificacion | Estado |
|----|-------|--------------|--------|
| INV-STO-01 | Solo un transcript activo por video | UNIQUE(courseSlug, videoSlug) | [HECHO] |
| INV-STO-02 | Transcripts no se eliminan, se archivan | Logica de versionado en host.js | [HIPOTESIS] - no verificado |
| INV-STO-03 | Backup preserva integridad referencial | Copia completa de archivo | [HECHO] |

### 5.4 Invariantes de Crawl

| ID | Regla | Verificacion | Estado |
|----|-------|--------------|--------|
| INV-CRA-01 | Solo un crawl activo por curso simultaneamente | Check de duplicados en API | [HECHO] |
| INV-CRA-02 | Batch procesa cursos secuencialmente | Cola FIFO en batch-manager | [HECHO] |
| INV-CRA-03 | Delay minimo entre cursos en batch | Constante DELAY_BETWEEN_COURSES_MS | [HECHO] |
| INV-CRA-04 | Estado de batch es persistente | Archivo JSON en data/batches/ | [HECHO] |

---

## 6. Analisis de Consistencia

### 6.1 Consistencia Eventual

**[HECHO]** El sistema usa consistencia eventual en el matching:

```
Tiempo T0: VTT capturado → unassigned_vtts
Tiempo T1: Contexto capturado → visited_contexts
Tiempo T2: Matching ejecutado → transcript creado, VTT eliminado
```

**Gap de Consistencia:** Entre T0/T1 y T2, los datos estan en estado intermedio.

**Mitigacion [HECHO]:**
- Matching se ejecuta al final de cada crawl
- Re-matching puede ejecutarse manualmente
- Estado de matching rastreable (matched=0/1)

### 6.2 Potenciales Problemas de Consistencia

| Problema | Escenario | Severidad | Estado |
|----------|-----------|-----------|--------|
| VTT huerfano | Crawl interrumpido antes de matching | Media | [HECHO] - requiere re-match manual |
| Contexto sin VTT | Video cargado pero VTT no interceptado | Alta | [HIPOTESIS] - puede ocurrir |
| Match duplicado | Mismo VTT coincide con multiples contextos | Baja | [HECHO] - logica de exclusion |
| Inconsistencia batch | Crash durante procesamiento | Media | [HECHO] - estado persistido |

---

## 7. Recomendaciones Arquitectonicas

### 7.1 Corto Plazo (Proximos 2 Sprints)

1. **[ALTA PRIORIDAD] Validar invariante INV-CAP-04**
   - El filtro de idioma espanol esta comentado
   - Verificar si es intencional o bug
   - Documentar decision

2. **[ALTA PRIORIDAD] Metricas de matching**
   - Agregar tracking de precision/recall
   - Dashboard de calidad de matching
   - Alertas para matches de baja confianza

3. **[MEDIA PRIORIDAD] Schema validation**
   - Implementar validacion JSON Schema para documentos
   - Prevenir datos malformados

### 7.2 Mediano Plazo (3-6 Meses)

1. **[MEDIA PRIORIDAD] Course como entidad explicita**
   - Crear tabla courses con metadata
   - Relacion FK desde transcripts
   - Habilitar consultas por curso mas eficientes

2. **[MEDIA PRIORIDAD] Event sourcing para audit trail**
   - Registrar todos los cambios de estado
   - Habilitar reconstruccion de historial
   - Debugging mejorado

3. **[BAJA PRIORIDAD] Mejora de algoritmo semantico**
   - Evaluar embeddings vs keywords
   - Calibrar threshold con datos reales
   - A/B testing de algoritmos

### 7.3 Largo Plazo (6+ Meses)

1. **[HIPOTESIS] Considerar arquitectura de eventos**
   - Desacoplar bounded contexts via eventos
   - Event bus para comunicacion
   - Mejor escalabilidad

2. **[HIPOTESIS] Microservicios por bounded context**
   - Solo si complejidad lo justifica
   - Evaluar trade-offs de distribucion

---

## 8. Apendices

### A. Glosario Tecnico Completo

| Termino | Definicion Tecnica |
|---------|-------------------|
| WebVTT | Web Video Text Tracks - formato estandar W3C para subtitulos |
| Manifest V3 | Version actual de Chrome Extension manifest con service workers |
| Native Messaging | Protocolo Chrome para IPC con procesos nativos via stdin/stdout |
| SQLite | Base de datos SQL embebida, single-file |
| better-sqlite3 | Binding Node.js sincrono para SQLite |
| Playwright | Framework de automatizacion de browsers de Microsoft |
| MCP | Model Context Protocol - protocolo Anthropic para integracion LLM |
| FTS | Full-Text Search - busqueda de texto completo en SQLite |
| tinyld | Libreria de deteccion de idioma ligera |

### B. Mapeo de Archivos a Bounded Contexts

| Archivo | Bounded Context | LOC |
|---------|-----------------|-----|
| extension/background.js | Capture | ~840 |
| extension/content.js | Capture | ~422 |
| extension/storage-manager.js | Capture | ~801 |
| crawler/vtt-interceptor.js | Capture | ~200 |
| scripts/match-transcripts.js | Matching | ~604 |
| scripts/lib/database.js | Storage | ~500 |
| native-host/host.js | Storage | ~661 |
| crawler/auto-crawler.js | Crawl | ~1859 |
| crawler/batch-manager.js | Crawl | ~822 |
| crawler/folder-parser.js | Crawl | ~520 |
| server/http-server.js | API | ~944 |
| server/index.js | API | ~300 |

### C. Metricas del Sistema (Estado Actual)

| Metrica | Valor | Fuente |
|---------|-------|--------|
| Total transcripts | 107 videos, 6 cursos | TASK_STATE.md |
| Test coverage | 79.29% | PRODUCT_BACKLOG.md |
| Total tests | 591 | PRODUCT_BACKLOG.md |
| Version | 0.13.0 | CLAUDE.md |

---

## Control de Documento

| Version | Fecha | Autor | Cambios |
|---------|-------|-------|---------|
| 1.0 | 2026-01-29 | Software Architect (Claude) | Creacion inicial |

---

**Proxima Revision:** Despues de implementar recomendaciones de corto plazo
**Clasificacion:** Documento interno - Arquitectura
