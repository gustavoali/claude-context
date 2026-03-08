# LinkedIn Transcript Extractor (LTE) - Project Context

**Version:** 0.17.0
**Ubicacion:** C:/mcp/linkedin
**Estado:** Funcional - Desarrollo activo

---

## Descripcion

Chrome Extension + MCP Server para capturar y consultar transcripts de LinkedIn Learning. Optimizado para consumo por LLMs (ChatGPT, Claude).

### Stack

- **Extension:** JavaScript (Chrome Manifest V3)
- **Backend:** Node.js + SQLite (better-sqlite3)
- **Servidor:** Express.js (HTTP) + MCP SDK
- **Crawler:** Playwright
- **Testing:** Jest (~85% coverage, 2,724 tests)

---

## Arquitectura

6 modulos en `modules/`: shared, capture, storage, matching, crawl, api

**Detalle:** Ver `ARCHITECTURE_ANALYSIS.md`

---

## Base de Datos

**Archivo:** `data/lte.db` (SQLite)

Tablas principales: `courses_normalized`, `chapters_normalized`, `videos_normalized`, `transcripts_normalized`, `unassigned_vtts`, `visited_contexts`, `collections`, `collection_memberships`, `collection_operations`

---

## Comandos

```bash
npm test                          # 2,724 tests
npm run lint                      # ESLint
npm run db:backup                 # Backup SQLite

cd server && npm run start:http   # HTTP (puerto 3456)
cd server && npm start            # MCP (Claude Desktop)

node crawler/auto-crawler.js <slug>              # Crawl secuencial
node crawler/auto-crawler.js <slug> --parallel   # Crawl paralelo
```

---

## Agentes Recomendados

| Tarea | Agente |
|-------|--------|
| Backend Node.js | `nodejs-backend-developer` |
| Extension Chrome | `chrome-extension-developer` |
| Tests | `test-engineer` |
| Code Review | `code-reviewer` |
| Gestion de Backlog | `product-owner` |

### Regla de Backlog

**OBLIGATORIO:** Delegar al agente `product-owner` para crear/modificar historias. Verificar ID Registry (proximo: LTE-074).

### Regla de Versionado

**OBLIGATORIO:** Todos los componentes deben mantener la misma version general del proyecto. Al incrementar version, actualizar TODOS los archivos:
- `package.json` (raiz)
- `extension/manifest.json` (version de la extension)
- `CLAUDE.md` (version en header)
- `ARCHITECTURE_ANALYSIS.md` (version en header)
- Cualquier otro archivo que declare version del proyecto

---

## Documentacion

- `TASK_STATE.md` - Estado actual y proximos pasos
- `PRODUCT_BACKLOG.md` - Backlog del producto
- `ARCHITECTURE_ANALYSIS.md` - Arquitectura v0.16.0
- `archive/` - Historial completo archivado
