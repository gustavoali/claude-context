# Estado de Tareas - LinkedIn Transcript Extractor

**Ultima actualizacion:** 2026-02-20
**Version:** 0.17.0
**Branch activo:** master

---

## Estado Actual

- **Tests:** 2,724 pasando (62 suites), 0 failing
- **DB:** 33 cursos, 839 videos, 673 transcripts normalizados
- **Tabla legacy `transcripts`:** ELIMINADA (migration 012)
- **Epic 10 (Collection Management):** COMPLETADO
- **Epic 11 (Legacy Data Migration):** COMPLETADO

---

## Completado Esta Sesion (2026-02-20)

### Epic 11: Legacy Data Migration (17 pts) - DONE

| ID | Titulo | Commit |
|----|--------|--------|
| LTE-069 | Migrate orphan transcripts (113 migrados) | `32068f6` |
| LTE-070 | Migrate SearchRepository to normalized | `e75078e` |
| LTE-071 | Enrich course listing with completion | `31159af` |
| LTE-073 | Update course_summary view | `cc402e5` |
| LTE-072 | Drop legacy transcripts table | `e7a485b` |

### Epic 10: Collection Management (36 pts) - DONE

| ID | Titulo | Commit |
|----|--------|--------|
| LTE-062 | Voyager API discovery interceptor | `ce024ee` |
| LTE-063 | Collection management strategy pattern | `0acc5b4` |
| LTE-064 | DOM automation strategy | `90ab53a` |
| LTE-065 | Voyager API strategy | `7cdfec8` |
| LTE-066 | Database collections local state | `32977c8` |
| LTE-067 | Collection management REST endpoints | `1a687ac` |
| LTE-068 | Extension UI collection management panel | `ad020af` |

### Code Review Fixes - `407eb8f`

- C2: CSS selector injection prevention
- C3: Auth tokens in-memory only (not persisted)
- I1: Singleton crash fix (storageService passed to routes)
- I2: collectionId validation (positive integer)
- I3: courseSlug validation (regex pattern)
- I4: Timestamped backup filenames

---

## Proximos Pasos

1. **21 transcripts sin migrar:** Necesitan re-discovery de 5 cursos para poblar estructura normalizada
2. **31 cursos sin titulo:** Discovery no siempre captura titulo (mostrados como "Unknown Course")
3. **Known issues sin resolver:**
   - ai-trends duplicate chapters (ES + EN cuando cambia locale)
   - Folder-parser includes nav links
   - CollectionCaptureOrchestrator discovery: Found 0 courses (broken)
4. Etapa 3 Versioning (LTE-050 a LTE-053) - DEFERRED

---

## Comandos Rapidos

```bash
npm test                          # 2,724 tests
cd server && npm run start:http   # HTTP server (puerto 3456)
cd server && npm start            # MCP server
```
