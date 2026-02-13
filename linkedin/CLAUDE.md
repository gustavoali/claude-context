# LinkedIn Transcript Extractor (LTE) - Project Context

**Version:** 0.12.0
**Ubicacion:** C:/mcp/linkedin
**Estado:** Funcional - En desarrollo activo

---

## Descripcion

Chrome Extension + MCP Server para capturar y consultar transcripts de LinkedIn Learning. Optimizado para consumo por LLMs (ChatGPT, Claude).

### Stack Tecnologico
- **Extension:** JavaScript (Chrome Manifest V3)
- **Backend:** Node.js + SQLite (better-sqlite3)
- **Servidor:** Express.js (HTTP) + MCP SDK
- **Crawler:** Playwright

---

## Componentes

| Componente | Ubicacion | Estado |
|------------|-----------|--------|
| Chrome Extension | `/extension/` | Funcional |
| Native Host | `/native-host/host.js` | SQLite |
| MCP Server | `/server/index.js` | Funcional |
| HTTP Server | `/server/http-server.js` | Funcional |
| Auto-Crawler | `/crawler/auto-crawler.js` | Funcional |
| DB Library | `/scripts/lib/database.js` | Central |

---

## Base de Datos

**Archivo:** `data/lte.db` (SQLite)

| Tabla | Contenido |
|-------|-----------|
| transcripts | 107 videos, 6 cursos |
| unassigned_vtts | VTTs pendientes de asignar |
| visited_contexts | Contextos visitados por crawler |

**Backup:** `npm run db:backup`

---

## Comandos Frecuentes

```bash
# Desarrollo
npm test                          # Tests (29% coverage)
npm run lint                      # ESLint

# Servidores
cd server && npm run start:http   # HTTP (ChatGPT via ngrok)
cd server && npm start            # MCP (Claude Desktop)

# Crawler
npm run crawl -- --url "URL"      # Crawl curso
npm run crawl:setup               # Setup sesion LinkedIn

# Base de datos
npm run db:backup                 # Crear backup
npm run db:backup:verify          # Verificar backup
```

---

## URLs y Endpoints

### HTTP Server (puerto 3456)
- `GET /api/status` - Estado
- `GET /api/courses` - Lista cursos
- `GET /api/courses/:slug` - Estructura curso
- `GET /api/search?q=query` - Buscar
- `POST /api/ask` - Preguntar sobre contenido
- `GET /openapi.json` - OpenAPI spec

### MCP Tools (11 herramientas)
`list_courses`, `get_course_structure`, `get_video_transcript`, `search_transcripts`, `ask_about_content`, `get_topics_overview`, `compare_videos`, `get_full_course_content`, `find_prerequisites`, `check_for_updates`, `list_learnings`

---

## Estado del Desarrollo

### Completado
- [x] Migracion SQLite (v0.12.0)
- [x] Sistema de backup
- [x] Organizacion de scripts (LTE-004)
- [x] ESLint configurado (LTE-021)
- [x] Validacion de matching (LTE-020)

### En Progreso
- [ ] Tests unitarios - 29% coverage (LTE-002)

### Pendiente Prioritario
- LTE-001: Unificar parser VTT
- LTE-003: Centralizar storage
- LTE-022: API crawl desde ChatGPT

---

## Agentes Recomendados

| Tarea | Agente |
|-------|--------|
| Backend Node.js | `nodejs-backend-developer` |
| Extension Chrome | `chrome-extension-developer` |
| Tests | `test-engineer` |
| Code Review | `code-reviewer` |
| **Gestion de Backlog** | `product-owner` |

### Regla de Gestion de Backlog

**OBLIGATORIO:** Antes de crear o modificar historias en el backlog, delegar al agente `product-owner` para:
1. Verificar el ID Registry en PRODUCT_BACKLOG.md
2. Asignar el proximo ID disponible
3. Definir user story con formato correcto y acceptance criteria
4. Actualizar el ID Registry

Esto evita colisiones de IDs entre sesiones.

---

## Documentacion Relacionada

- `TASK_STATE.md` - Estado de tareas activas
- `PRODUCT_BACKLOG.md` - Backlog del producto (v2.0)
- `ARCHITECTURE_ANALYSIS.md` - Analisis de arquitectura
