# Descubrimiento de Subtítulos Multi-Idioma en LinkedIn Learning

**Fecha:** 2026-01-29
**Investigador:** Claude (Software Architect)
**Estado:** INVESTIGACIÓN COMPLETADA - Hipótesis Refutada

> **RESULTADO FINAL:** LinkedIn NO usa HLS manifests para subtítulos.
> Envía TODOS los 47 idiomas directamente como archivos VTT separados.
> Ver: `MULTILANGUAGE_DISCOVERY_RESULTS.md` para detalles completos.

---

## Resumen Ejecutivo

### Problema Original
El sistema actual solo captura UN subtítulo por video (el que LinkedIn envía por defecto basado en preferencias del usuario). El usuario quiere capturar TODOS los idiomas disponibles.

### Hallazgos Clave

1. **URL Structure:**
   ```
   https://dms.licdn.com/playlist/vid/v2/{VIDEO_ID}/video-captions-webvtt/{CAPTION_ID}/0/0?...
   ```
   - `VIDEO_ID`: Identificador único del video (ej: `D560DAQFZOItRdPlKYA`)
   - `CAPTION_ID`: Identificador opaco del track de subtítulos (ej: `B4EZb4dRufHkEM-`)

2. **CAPTION_ID es Opaco:**
   - No codifica el idioma de manera decodificable
   - Todos empiezan con prefijo `B4EZ` (posiblemente versión/tipo)
   - Longitud fija de 15 caracteres
   - Es un identificador interno de LinkedIn

3. **Confirmado: Múltiples CAPTION_IDs por Video:**
   - Video `D560DAQEYJESwEoPv1A` tiene:
     - `B4EZgM0XJ7H4Eg-`
     - `B4EZb4dRufHkEM-`
   - Esto confirma que diferentes idiomas tienen diferentes CAPTION_IDs

4. **El Problema Real:**
   - LinkedIn NO expone una lista de idiomas disponibles en la URL
   - La única forma de saber qué idiomas existen es interceptar el manifest HLS o un API call

---

## Hipótesis de Solución

### Hipótesis 1: HLS Manifest (Más Probable)

LinkedIn usa HLS (HTTP Live Streaming) para video. Los manifests `.m3u8` típicamente listan todos los tracks de subtítulos disponibles:

```
#EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="subs",NAME="English",DEFAULT=YES,LANGUAGE="en",URI="captions-en.m3u8"
#EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="subs",NAME="Español",DEFAULT=NO,LANGUAGE="es",URI="captions-es.m3u8"
#EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="subs",NAME="Português",DEFAULT=NO,LANGUAGE="pt",URI="captions-pt.m3u8"
```

**Acción Requerida:** Interceptar archivos `.m3u8` para extraer lista de subtítulos.

### Hipótesis 2: API de Video

LinkedIn podría tener un endpoint API que devuelve metadata del video incluyendo tracks de subtítulos:

```
GET /learning/api/videos/{videoId}/captions
Response: {
  "availableCaptions": [
    { "language": "en", "captionId": "B4EZ...", "name": "English" },
    { "language": "es", "captionId": "B4EZ...", "name": "Español" }
  ]
}
```

**Acción Requerida:** Interceptar llamadas API que contengan "caption" o "subtitle".

### Hipótesis 3: Player Initialization

El reproductor de video recibe configuración inicial con los tracks disponibles. Esta configuración podría estar:
- Embebida en el HTML como JSON
- Cargada via JavaScript
- En el objeto `<video>` como `textTracks`

---

## Propuesta de Arquitectura

### Fase 1: Modo CaptureAll (Inmediato)

Usar el modo existente `filterMode: 'captureAll'` para capturar TODOS los VTTs sin filtro de idioma.

```javascript
// En crawler config
await setupVttInterception(page, courseSlug, {
  filterMode: 'captureAll',
  saveToDb: true
});
```

**Beneficio:** Captura todo lo que LinkedIn envía.
**Limitación:** Solo captura lo que LinkedIn decide enviar (usualmente 1 idioma).

### Fase 2: Intercepción de Manifest (Siguiente Paso)

Modificar `vtt-interceptor.js` para también interceptar manifests:

```javascript
// Nuevos patrones a interceptar
const MANIFEST_PATTERNS = [
  /\.m3u8/i,
  /manifest/i,
  /playlist.*vid/i
];

// En setupVttInterception, agregar:
if (MANIFEST_PATTERNS.some(p => p.test(url))) {
  const content = await fetchManifestContent(url);
  const captionTracks = parseHLSManifest(content);
  // Guardar lista de tracks disponibles
  await saveAvailableCaptionTracks(videoId, captionTracks);
}
```

### Fase 3: Fetch de Todos los Idiomas

Una vez que tenemos la lista de CAPTION_IDs disponibles:

```javascript
async function fetchAllCaptions(videoId, captionTracks) {
  for (const track of captionTracks) {
    const vttUrl = buildCaptionUrl(videoId, track.captionId);
    const content = await fetch(vttUrl);
    await saveVttWithLanguage(videoId, track.language, content);
  }
}
```

---

## Cambios de Schema de Base de Datos

### Tabla Nueva: `available_captions`

```sql
CREATE TABLE available_captions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  video_id TEXT NOT NULL,
  course_slug TEXT,
  video_slug TEXT,
  caption_id TEXT NOT NULL,
  language_code TEXT,
  language_name TEXT,
  discovered_at INTEGER,
  manifest_url TEXT,
  UNIQUE(video_id, caption_id)
);
```

### Modificar: `unassigned_vtts`

Agregar columna `language_code` detectado:

```sql
ALTER TABLE unassigned_vtts ADD COLUMN detected_language TEXT;
ALTER TABLE unassigned_vtts ADD COLUMN caption_id TEXT;
```

### Modificar: `transcripts`

Agregar soporte multi-idioma:

```sql
ALTER TABLE transcripts ADD COLUMN language_code TEXT DEFAULT 'es';
ALTER TABLE transcripts ADD COLUMN caption_id TEXT;
-- Cambiar UNIQUE constraint para permitir múltiples idiomas
```

---

## Plan de Implementación

### Sprint 1: Investigación Activa (4h) - PARCIALMENTE COMPLETADO

1. [ ] Ejecutar script `investigate-hls-manifest.js` con sesión real
2. [ ] Capturar y analizar manifest HLS de LinkedIn
3. [ ] Documentar estructura exacta del manifest
4. [ ] Identificar cómo LinkedIn lista los caption tracks
5. [x] **HALLAZGO:** Usuario reportó ver 47 transcripts por video en la extensión

### Sprint 2: Implementación Básica (8h) - COMPLETADO

1. [x] Modificar `vtt-interceptor.js` para capturar manifests
   - Agregados patrones `HLS_MANIFEST_PATTERNS` (v2.2.1 - corregidos)
   - Agregada función `parseHlsManifestForCaptions()`
   - Agregada función `extractVideoIdFromUrl()`
   - Nueva opción `captureManifests: true` en config
   - **v2.2.1:** Agregado `MANIFEST_EXCLUSIONS` para evitar falsos positivos (PWA manifests)
2. [x] Crear parser de manifest HLS
   - Extrae `#EXT-X-MEDIA:TYPE=SUBTITLES` entries
   - Parsea LANGUAGE, NAME, URI, DEFAULT attributes
   - Extrae CAPTION_ID del URI
3. [x] Agregar tabla `available_captions` a SQLite
   - Columnas: video_id, caption_id, language_code, language_name, fetched, etc.
   - Índices para búsquedas eficientes
4. [x] Guardar tracks descubiertos en DB
   - `saveAvailableCaption()` function
   - `getAvailableCaptionsByVideo()`, `getAvailableCaptionsByCourse()`
   - `getUnfetchedCaptions()`, `markCaptionAsFetched()`
5. [x] **Evidencia de multi-idioma en datos actuales**
   - 3 videos tienen múltiples CAPTION_IDs (idiomas diferentes)
   - Idiomas detectados: Español, Portugués, Catalán
   - Total VTTs capturados: 92

**Scripts creados:**
- `scripts/test-manifest-parsing.js` - Tests de parsing (8/8 pasando)
- `scripts/crawl-with-manifest-capture.js` - Crawl de prueba con captura de manifests

**Tests:** 591 tests pasando

### Sprint 3: Fetch Multi-Idioma (6h)

1. [ ] Implementar función para construir URL de cualquier caption
2. [ ] Crear flujo para fetch de todos los idiomas
3. [ ] Modificar schema para soportar múltiples idiomas por video
4. [ ] Actualizar MCP/HTTP server para exponer idiomas disponibles

### Sprint 4: Testing y Polish (4h)

1. [ ] Tests para parser de manifest
2. [ ] Tests para fetch multi-idioma
3. [ ] Validar que todos los idiomas se capturan correctamente
4. [ ] Documentar nuevos endpoints de API

---

## Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| LinkedIn no usa HLS estándar | Media | Alto | Investigar formato propietario |
| Manifests autenticados | Alta | Medio | Usar misma sesión que video |
| Rate limiting por múltiples fetches | Media | Medio | Delays entre requests |
| CAPTION_ID expira | Baja | Alto | Capturar durante playback |

---

## Próximos Pasos Inmediatos

1. **AHORA:** Ejecutar investigación activa con sesión de LinkedIn real
2. **HOY:** Documentar estructura del manifest
3. **DESPUÉS:** Implementar según hallazgos

---

## Apéndice: Scripts de Investigación Creados

| Script | Propósito |
|--------|-----------|
| `scripts/research-caption-discovery.js` | Análisis de URLs de VTT |
| `scripts/decode-caption-id.js` | Intento de decodificar CAPTION_ID |
| `scripts/investigate-hls-manifest.js` | Interceptar manifest HLS |

---

**Conclusión:** El descubrimiento de todos los idiomas disponibles requiere interceptar el manifest HLS. La arquitectura actual solo captura lo que LinkedIn envía por defecto. La solución propuesta agrega capacidad de descubrimiento y fetch multi-idioma.
