# Cross-Project Learnings
**Version:** 1.2 | **Actualizacion:** 2026-03-12

Patrones reutilizables extraidos de proyectos del ecosistema. Se carga via @import en todos los proyectos.

---

## Delegacion a Agentes

### L-001: Incluir contenido, no solo referencias
**Fuente:** Claude Monitor (Flutter) | **Aplica a:** Todos
Al delegar a un agente, incluir el contenido de docs de referencia en el prompt, no solo mencionarlos. El agente no tiene acceso al contexto del coordinador. Incluir: nombres exactos de clases/archivos, schemas de datos, contenido de ARCHITECTURE.md.

### L-002: Agentes asumen lo que no reciben
**Fuente:** Claude Monitor (Flutter) | **Aplica a:** Todos
Si el agente no recibe nombres exactos de entidades, inventara nombres coherentes pero diferentes. Esto genera retrabajo de renaming o arquitectura divergente.

---

## Base de Datos

### L-003: PostgreSQL GENERATED ALWAYS AS para metricas calculadas
**Fuente:** Sprint Backlog Manager | **Aplica a:** Proyectos con PostgreSQL
Usar columnas generadas para valores derivados (ej: ROI = interest * sprints / cost). Evita inconsistencias y simplifica queries.

### L-004: JSONB para datos semi-estructurados
**Fuente:** Sprint Backlog Manager | **Aplica a:** Proyectos con PostgreSQL
Acceptance criteria, configuracion flexible, metadata variable: usar JSONB en lugar de tablas normalizadas. Permite queries con operadores JSON sin perder flexibilidad.

### L-005: Puertos Docker - evitar conflictos
**Fuente:** Sprint Backlog Manager | **Aplica a:** Todos con Docker
Documentar puerto usado por cada container en CLAUDE.md del proyecto. Conflictos de puertos causan errores silenciosos o confusos.

### L-012: WSL2 auto-suspend mata Docker containers silenciosamente
**Fuente:** Claude Orchestrator (INC-007) | **Aplica a:** Todos con Docker en WSL2
Windows 11 + WSL2 suspende la VM cuando esta idle, matando todos los containers sin shutdown graceful. Configurar en `C:/Users/<user>/.wslconfig`: `vmIdleTimeout=-1` (seccion [wsl2]), `autoMemoryReclaim=disabled` (seccion [wsl2]), `instanceIdleTimeout=-1` (seccion [general]). Las tres son necesarias (solo vmIdleTimeout no alcanza, ver WSL issue #13291).

### L-013: Containers PostgreSQL siempre con healthcheck
**Fuente:** Claude Orchestrator (INC-007) | **Aplica a:** Todos con Docker + PG
Al crear containers PG standalone, agregar `--health-cmd "pg_isready -U postgres -d <db>" --health-interval=30s --health-timeout=5s --health-retries=3 --health-start-period=10s`. Sin healthcheck, Docker no tiene visibilidad del estado real de PG y reporta "Up" incluso durante recovery.

---

## Testing

### L-006: promisify + jest.mock son incompatibles
**Fuente:** Sprint Backlog Manager | **Aplica a:** Proyectos Node.js con Jest
`util.promisify(child_process.execFile)` pierde el symbol custom cuando se mockea con `jest.mock`. Solucion: usar wrapper manual con `new Promise` en lugar de `promisify`.

### L-007: Busqueda LIKE sobre JSON serializado da falsos positivos
**Fuente:** Recetario | **Aplica a:** Proyectos con SQLite/Drift
Buscar "sal" matchea "salsa". Usar busqueda tokenizada o full-text search en lugar de LIKE sobre campos JSON serializados.

---

## Validacion

### L-008: Una sola libreria de validacion por proyecto
**Fuente:** ApiJsMobile (.NET) | **Aplica a:** Proyectos .NET
No mezclar FluentValidation con DataAnnotations. Elegir una y eliminar la otra. La duplicacion causa confusion sobre cual se ejecuta realmente.

---

## Flutter / Mobile

### L-009: Firebase condicional para MVP local
**Fuente:** Recetario | **Aplica a:** Proyectos Flutter con Firebase
Firebase.initializeApp() sin config crashea toda la app. Hacer dependencias de Firebase condicionales para que el MVP local funcione sin servicios cloud.

### L-010: File change detection por modification date
**Fuente:** Claude Monitor | **Aplica a:** Apps que leen archivos periodicamente
Antes de leer un archivo, verificar si lastModified cambio. Evita I/O innecesario en polling.

---

## Claude Code / MCP

### L-014: MCP servers se configuran en ~/.claude.json, NO en ~/.claude/settings.json
**Fuente:** Narrador, YouTube MCP | **Aplica a:** Todos los proyectos MCP
Claude Code lee MCP servers exclusivamente de `~/.claude.json` (clave `mcpServers`). El archivo `~/.claude/settings.json` es para permisos, hooks y config general; si se pone `mcpServers` ahi, se ignora silenciosamente. El server arranca correctamente al probarlo manualmente pero nunca aparece como tool disponible. Usar `claude mcp add` o editar `~/.claude.json` directamente. Formato requerido: `{"type": "stdio", "command": "...", "args": [...], "env": {}}`.

---

## Scraping / Parsing

### L-011: JSON-LD Schema.org como primer intento de parsing
**Fuente:** Recetario | **Aplica a:** Proyectos de web scraping
JSON-LD es el formato mas confiable. Fallback: headings con sinonimos en espanol/ingles. Muchos sitios latinos no usan formatos estandar.
