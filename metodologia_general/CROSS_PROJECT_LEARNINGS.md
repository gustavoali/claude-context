# Cross-Project Learnings
**Version:** 2.0 | **Actualizacion:** 2026-03-19

Patrones reutilizables extraidos de proyectos del ecosistema. Se carga via @import en todos los proyectos.

---

## Delegacion a Agentes

### L-001: Incluir contenido, no solo referencias
**Fuente:** Claude Monitor (Flutter) | **Aplica a:** Todos
Al delegar a un agente, incluir el contenido de docs de referencia en el prompt, no solo mencionarlos. El agente no tiene acceso al contexto del coordinador. Incluir: nombres exactos de clases/archivos, schemas de datos, contenido de ARCHITECTURE.md.

### L-002: Agentes asumen lo que no reciben
**Fuente:** Claude Monitor (Flutter) | **Aplica a:** Todos
Si el agente no recibe nombres exactos de entidades, inventara nombres coherentes pero diferentes. Esto genera retrabajo de renaming o arquitectura divergente.

### L-015: Meta-agents deben ser thin coordination layers
**Fuente:** Atlas Agent | **Aplica a:** Sistemas multi-agente
No darle responsabilidades de dominio al meta-agent. Meta-agent = comunicacion con usuario + lifecycle de sesiones + escalacion. Logica de dominio en worker sessions.

### L-016: Waves de implementacion con orden de dependencias
**Fuente:** Atlas Agent | **Aplica a:** Todos
Agrupar historias en "olas" donde las historias dentro de cada ola son independientes. Implementar ola, test suite, commit, siguiente ola. Da rollback points limpios.

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

### L-017: SQLite ALTER TABLE idempotente via try/except
**Fuente:** YouTube MCP | **Aplica a:** Proyectos Python con SQLite
SQLite no soporta `IF NOT EXISTS` para `ALTER TABLE ADD COLUMN`. Patron: wrap cada ALTER en `try/except sqlite3.OperationalError: pass`. Ejecutar individualmente, no en batch.

---

## Testing

### L-006: promisify + jest.mock son incompatibles
**Fuente:** Sprint Backlog Manager | **Aplica a:** Proyectos Node.js con Jest
`util.promisify(child_process.execFile)` pierde el symbol custom cuando se mockea con `jest.mock`. Solucion: usar wrapper manual con `new Promise` en lugar de `promisify`.

### L-007: Busqueda LIKE sobre JSON serializado da falsos positivos
**Fuente:** Recetario | **Aplica a:** Proyectos con SQLite/Drift
Buscar "sal" matchea "salsa". Usar busqueda tokenizada o full-text search en lugar de LIKE sobre campos JSON serializados.

### L-018: ESM Jest: `jest` no es global, hay que importarlo
**Fuente:** Claude Orchestrator | **Aplica a:** Node.js ESM con Jest
En ESM mode (`--experimental-vm-modules`), `jest.fn()`, `jest.mock()` NO son globals. Importar: `import { jest, describe, it, expect } from '@jest/globals';` en cada test.

### L-019: EventEmitter mock payload debe matchear shape real
**Fuente:** Personal Workspace | **Aplica a:** Node.js EventEmitter con payloads estructurados
Si mock emite superset del payload real, tests pasan pero produccion falla. Verificar que mock emite exactamente la misma shape. Documentar via `@event` JSDoc.

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
Claude Code lee MCP servers exclusivamente de `~/.claude.json` (clave `mcpServers`). El archivo `~/.claude/settings.json` es para permisos, hooks y config general; si se pone `mcpServers` ahi, se ignora silenciosamente. Usar `claude mcp add` o editar `~/.claude.json` directamente.

### L-020: MCP stdio servers: todo log a stderr
**Fuente:** Personal Workspace | **Aplica a:** Todos los MCP servers
MCP stdio transport requiere cero output no-JSON-RPC en stdout. Python structlog: `PrintLoggerFactory(file=sys.stderr)`. FastMCP: usar `run_stdio_async()`.

### L-021: FastMCP import path es `mcp.server.fastmcp`, no `fastmcp`
**Fuente:** Narrador | **Aplica a:** Proyectos Python MCP
Import correcto: `from mcp.server.fastmcp import FastMCP, Context`. El paquete `mcp[cli]` lo incluye dentro de `mcp.server.fastmcp`.

### L-022: `@mcp.tool()` requiere parentesis en mcp >= 1.26
**Fuente:** Narrador | **Aplica a:** Proyectos Python MCP >= 1.26
Decorador debe llamarse con parentesis: `@mcp.tool()`. Sin parentesis (`@mcp.tool`) da TypeError al cargar el modulo.

### L-023: MCP notifications (sin `id`) no producen respuesta
**Fuente:** LLM Landscape | **Aplica a:** Clientes MCP custom
Mensajes MCP sin `id` son notifications: el server NO debe responder. Si el cliente hace `readline()` despues de enviar notification, bloquea para siempre.

---

## Windows / Shell / CLI

### L-024: Git Bash convierte flags `/X` en paths
**Fuente:** Claude Orchestrator, YouTube MCP | **Aplica a:** Todos en Windows + Git Bash
`taskkill /PID`, `tasklist /FI` se convierten en `C:/Program Files/Git/PID`. Usar doble slash: `taskkill //PID //F`. Afecta todos los comandos Windows con flags `/flag` desde Git Bash.

### L-025: Docker `--format` con Go templates falla en Windows shells
**Fuente:** Claude Orchestrator | **Aplica a:** Docker CLI en Windows
Double braces `{{json .}}` se interpretan mal. Usar `docker inspect` (retorna JSON sin templates) como alternativa portable.

### L-026: PowerShell `$Input` es variable reservada
**Fuente:** Personal Workspace | **Aplica a:** Scripts PowerShell
`$Input` es variable automatica (pipeline enumerator). Usarla como parametro silenciosamente la sobreescribe con string vacio. Renombrar a otro nombre.

### L-027: Launching Windows GUI apps desde Git Bash
**Fuente:** LLM Landscape | **Aplica a:** Windows + Git Bash
Usar path Unix-style: `"/c/Program Files/Notepad++/notepad++.exe" "path" &`. Los wrappers `cmd //c` y `start` no funcionan bien.

---

## Context Engineering

### L-028: Hook timeout en SEGUNDOS, no milisegundos
**Fuente:** Context Engineering Research | **Aplica a:** Configuracion de hooks Claude Code
`timeout: 120000` en settings.json = 33.3 horas, no 2 minutos. Usar `timeout: 120` para 2 minutos.

### L-029: Windows no mata child processes cuando muere el parent
**Fuente:** Context Engineering Research | **Aplica a:** Scripts PowerShell con subprocesos
Implementar cleanup recursivo de descendientes usando `Get-CimInstance Win32_Process` para recorrer el arbol de procesos.

### L-030: Patron hang-proof para `claude --print` en hooks
**Fuente:** Context Engineering Research | **Aplica a:** Hooks que invocan Claude
4 protecciones: (1) `Start-Job` + `Wait-Job -Timeout`, (2) prompt a temp file en vez de pipe stdin, (3) cleanup recursivo en trap/finally, (4) re-entrance guard via env var.

### L-031: Recovery de sesion interrumpida via git diff
**Fuente:** Personal Workspace | **Aplica a:** Todos
Cuando TASK_STATE esta stale post-interrupcion, `git status` + `git diff HEAD` reconstruye el trabajo. Cambios uncommitted = registro completo desde ultimo commit.

---

## LLM Providers

### L-032: DeepSeek, Groq, Ollama son OpenAI SDK-compatible
**Fuente:** LLM Landscape | **Aplica a:** Proyectos multi-modelo
Usar `openai` Python SDK con custom `base_url`: DeepSeek (`api.deepseek.com`), Groq (`api.groq.com/openai/v1`), Ollama (`localhost:11434/v1`). Evita codigo provider-specific.

### L-033: Groq free tier: LLM de calidad a costo cero
**Fuente:** LLM Landscape | **Aplica a:** Desarrollo/testing
Groq ofrece Llama 3.3 70B gratis. Rate limits ~6K tokens/min, 30 req/min. Bueno para dev/test combinado con Ollama local.

### L-034: Google Gemini free tier bloqueado por region (Argentina)
**Fuente:** LLM Landscape | **Aplica a:** Proyectos con Gemini desde Argentina
AI Studio free tier retorna `limit: 0` desde Argentina. Error: `RESOURCE_EXHAUSTED`. Workaround: habilitar billing (~$0.10/1M input tokens para Flash).

---

## YouTube / Google APIs

### L-035: YouTube API v3 no accede a playlists del sistema
**Fuente:** YouTube MCP | **Aplica a:** Proyectos YouTube API
Watch Later (`WL`) y Liked Videos (`LL`) retornan 403 incluso con auth correcta. Solo playlists creadas por el usuario. Workaround: Google Takeout.

### L-036: YouTube API v3 quota: 10K units/dia
**Fuente:** YouTube MCP | **Aplica a:** Operaciones bulk YouTube API
Read = 1 unit, write = 50 units. Batch playlist inserts: ~180/dia max. Quota reset midnight Pacific. Delete+insert = costo doble.

### L-037: youtube-transcript-api IP bans; Whisper como fallback
**Fuente:** YouTube MCP | **Aplica a:** Extraccion de transcripts YouTube
YouTube bloquea por IP. Implementar: (1) Whisper fallback automatico, (2) cookie support via `YOUTUBE_COOKIE_FILE`, (3) `force_whisper=True`. Base model CPU ~12x realtime.

---

## Scraping / Parsing

### L-011: JSON-LD Schema.org como primer intento de parsing
**Fuente:** Recetario | **Aplica a:** Proyectos de web scraping
JSON-LD es el formato mas confiable. Fallback: headings con sinonimos en espanol/ingles. Muchos sitios latinos no usan formatos estandar.

---

## Unity / Game Development

### L-038: `GameObject.Find()` solo encuentra objetos activos
**Fuente:** Gaia Protocol | **Aplica a:** Unity Editor extensions
Retorna null silenciosamente para objetos inactivos. Para encontrar inactivos: `SceneManager.GetActiveScene().GetRootGameObjects()` + `Transform.Find()` recursivo.

### L-039: `EditorApplication.isPlaying = true` es asincrono
**Fuente:** Gaia Protocol | **Aplica a:** Automatizacion Unity Editor
La transicion ocurre en el siguiente frame. Herramientas que setean Play Mode deben documentar que el caller necesita esperar.
