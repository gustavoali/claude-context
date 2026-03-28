# Arquitectura - MCP Shared Gateway
**Version:** 0.1.0 | **Fecha:** 2026-03-28

## Resumen Ejecutivo

Reducir ~1.8 GB de RAM (73% de stateless, 48% total) eliminando la duplicacion
de MCP servers entre sesiones de Claude Code. La solucion usa `mcp-proxy`
(punkpeye) en modo stateless, un proceso por server, exponiendo cada MCP
server stdio como endpoint HTTP en su propio puerto. Python servers corren
HTTP nativo via FastMCP. Claude Code se conecta con `type: "http"`.

**CORRECCION POST-PoC:** `--named-server-config` NO existe en mcp-proxy v6.4.4.
El proxy es 1:1 (un comando stdio, un endpoint HTTP). Se usa un mcp-proxy
por server Node.js stateless (3 instancias, puertos 9800-9802).

## Diagrama de Componentes

```
+-------------------------------------------------------+
|  Windows Host                                          |
|                                                        |
|  +------------------+  +------------------+            |
|  | Claude Code S1   |  | Claude Code S2   |  ...      |
|  | (type: "http")   |  | (type: "http")   |           |
|  +--------+---------+  +--------+---------+            |
|           |                      |                     |
|           +----------+-----------+                     |
|                      |                                 |
|                      v                                 |
|  +-------------------------------------------+        |
|  |  mcp-proxy (port 9800)                     |        |
|  |  --named-server-config servers.json        |        |
|  |                                            |        |
|  |  /servers/project-admin/mcp     (HTTP)     |        |
|  |  /servers/google-drive/mcp      (HTTP)     |        |
|  |  /servers/youtube-transcript/mcp(HTTP)     |        |
|  |  /servers/playwright/mcp        (HTTP) *   |        |
|  |  /servers/playwright-hl/mcp     (HTTP) *   |        |
|  |  /servers/orchestrator/mcp      (HTTP) *   |        |
|  +-------------------------------------------+        |
|           |          |           |                     |
|           v          v           v                     |
|  +-----------+ +-----------+ +----------+              |
|  | stdio:    | | stdio:    | | stdio:   |              |
|  | project-  | | google-   | | yt-trans |  ...         |
|  | admin     | | drive     | | cript    |              |
|  +-----------+ +-----------+ +----------+              |
|                                                        |
|  +-------------------------------------------+        |
|  |  Python servers (HTTP nativo, puerto propio)  |     |
|  |  youtube    :9801/mcp                      |        |
|  |  narrador   :9802/mcp                      |        |
|  |  llm-router :9803/mcp                      |        |
|  +-------------------------------------------+        |
+-------------------------------------------------------+

* = servers stateful (ver ADR-003)
```

## Flujo de Datos

```
1. Claude Code envia JSON-RPC request
2. Transporte HTTP POST -> http://localhost:9800/servers/<name>/mcp
3. mcp-proxy recibe, identifica named server, forward via stdio al proceso
4. Proceso MCP server responde via stdout
5. mcp-proxy forward respuesta HTTP al cliente
6. Claude Code recibe JSON-RPC response

Para Python servers (conexion directa):
1. Claude Code envia JSON-RPC via HTTP POST -> http://localhost:980X/mcp
2. FastMCP server procesa directamente
3. Respuesta HTTP al cliente
```

Latencia adicional esperada: <5ms por hop de proxy (localhost loopback).

## ADRs

### ADR-001: Approach General
**Status:** PROPUESTO

**Contexto:** Necesitamos eliminar la duplicacion de procesos MCP server entre
sesiones de Claude Code. Existen paquetes que ya resuelven esto.

**Opciones evaluadas:**

1. **`@nano-step/shared-mcp-proxy` as-is**
   - (+) Solucion llave en mano: install, generate, start
   - (+) Auto-restart en crash, logging configurable, enable/disable servers
   - (+) Genera configs para Claude Code automaticamente
   - (-) Orientado a Docker containers (host.docker.internal), no a nuestro caso
   - (-) Solo genera configs con `type: "sse"` (deprecated)
   - (-) Bash scripts (install.sh, generate.sh, start.sh) asumen Linux/Mac
   - (-) Dependencia opaca: wrapper de 62 KB sobre mcp-proxy sin documentacion interna

2. **`mcp-proxy` directo con config propia**
   - (+) Es el motor que usa @nano-step internamente
   - (+) Soporta SSE y Streamable HTTP nativamente
   - (+) `--named-server-config` permite definir multiples servers en un JSON
   - (+) Control total sobre puertos, transporte, opciones
   - (+) Bien mantenido (101 versiones, punkpeye/glama.ai)
   - (-) Requiere escribir nuestro propio config y scripts de lifecycle
   - (-) No tiene auto-restart built-in

3. **Gateway custom con MCP SDK**
   - (+) Control absoluto
   - (-) Esfuerzo desproporcionado para escala micro
   - (-) Reimplementar lo que mcp-proxy ya hace

4. **Cada server como servicio HTTP independiente (sin proxy)**
   - (+) Sin overhead de proxy
   - (+) Mas simple conceptualmente
   - (-) N puertos a gestionar (uno por server)
   - (-) Los servers Node.js actuales son stdio-only, requieren modificacion
   - (-) Mayor complejidad de lifecycle (N servicios vs 1)

**Decision:** Opcion 2 - `mcp-proxy` directo con config propia.

**Razonamiento:** @nano-step es un wrapper delgado sobre mcp-proxy que no
agrega valor para nuestro caso (no usamos Docker containers, queremos HTTP
no SSE, necesitamos Windows/PowerShell). Usar mcp-proxy directamente nos da
el mismo motor con control total. Gateway custom es over-engineering para
escala micro.

**Consecuencias:**
- (+) Dependencia unica y bien mantenida (mcp-proxy)
- (+) Soporta streamable HTTP (recomendado por Claude Code docs)
- (+) Named servers permite un unico proceso para todos los servers Node.js
- (-) Debemos escribir lifecycle scripts en PowerShell (~100 lineas)
- (-) Debemos escribir servers.json manualmente (una vez)

---

### ADR-002: Transporte
**Status:** PROPUESTO

**Contexto:** Claude Code soporta stdio, SSE, y HTTP (streamable HTTP).
Debemos elegir que transporte expone el proxy a los clientes.

**Opciones evaluadas:**

1. **SSE (Server-Sent Events)**
   - (+) Funciona, probado por @nano-step
   - (-) Deprecated en el protocolo MCP
   - (-) Claude Code docs recomiendan HTTP

2. **Streamable HTTP**
   - (+) Recomendado por Claude Code docs y protocolo MCP
   - (+) Soportado nativamente por mcp-proxy (`/mcp` endpoint)
   - (+) Stateful (session ID) o stateless
   - (+) Mas simple: request/response HTTP estandar
   - (-) Marginalmente mas nuevo (pero ya es el default)

**Decision:** Streamable HTTP.

**Razonamiento:** Es el transporte recomendado oficialmente. mcp-proxy lo
expone por defecto en `/servers/<name>/mcp`. Claude Code lo soporta con
`claude mcp add --transport http`.

**Consecuencias:**
- (+) Alineado con la direccion del protocolo MCP
- (+) Config en Claude Code: `type: "http"` (no deprecated)
- (-) Ninguna significativa

---

### ADR-003: Manejo de Servers Stateful
**Status:** PROPUESTO

**Contexto:** Playwright mantiene instancias de browser por sesion. Claude
Orchestrator mantiene sesiones de trabajo. Compartir estos servers entre
sesiones de Claude Code podria causar interferencia.

**Opciones evaluadas:**

1. **Compartir todos, incluso stateful**
   - (+) Maximo ahorro de memoria
   - (-) Riesgo de interferencia entre sesiones (playwright navega a
     pagina de sesion 1 mientras sesion 2 tambien lo usa)
   - (-) Claude Orchestrator mantiene estado de sesion que se mezclaria

2. **Excluir stateful del proxy, mantenerlos como stdio**
   - (+) Sin riesgo de interferencia
   - (+) Playwright y Orchestrator siguen funcionando como antes
   - (-) Menor ahorro de memoria (~50-100 MB menos de ahorro)
   - (-) Config hibrida: algunos servers HTTP, otros stdio

3. **Instancias separadas del proxy para stateful servers**
   - (+) Aislamiento por sesion
   - (-) Complejidad: multiples instancias del proxy
   - (-) No ahorra memoria para esos servers

**Decision:** Opcion 2 - Excluir stateful del proxy.

**Razonamiento:** El ahorro principal viene de los servers stateless (6 de 9
servers, incluyendo los 3 Python que son los mas pesados). Playwright y
Orchestrator representan ~100-150 MB que no justifican la complejidad de
gestion de estado multi-sesion. La config hibrida es sencilla: unos pocos
servers con `type: "stdio"` y el resto con `type: "http"`.

**Clasificacion de servers:**

| Server | Estado | Proxy? | Razon |
|--------|--------|--------|-------|
| project-admin | stateless | Si | CRUD puro, sin estado |
| google-drive | stateless | Si | API calls, sin estado local |
| youtube-transcript | stateless | Si | Fetch transcripts, sin estado |
| youtube (Python) | stateless | Si (directo) | FastMCP HTTP nativo |
| narrador (Python) | stateless | Si (directo) | FastMCP HTTP nativo |
| llm-router (Python) | stateless | Si (directo) | FastMCP HTTP nativo |
| playwright | stateful | No | Browser instances por sesion |
| playwright-headless | stateful | No | Browser instances por sesion |
| claude-orchestrator | stateful | No | Sessions de trabajo activas |

**Consecuencias:**
- (+) Sin riesgo de interferencia entre sesiones
- (+) Ahorro estimado: 400-500 MB (de ~1 GB a ~500-600 MB)
- (-) No se elimina 100% de la duplicacion, pero si la mayoria

---

### ADR-004: Lifecycle Management
**Status:** PROPUESTO

**Contexto:** El proxy debe arrancar antes de que Claude Code intente
conectar, y debe recuperarse de crashes.

**Opciones evaluadas:**

1. **Script manual (start/stop)**
   - (+) Simple, transparente
   - (-) Hay que recordar ejecutarlo antes de abrir Claude Code
   - (-) Sin auto-recovery

2. **PowerShell scheduled task / Windows service**
   - (+) Auto-start con Windows
   - (+) Auto-recovery configurable
   - (-) Over-engineering para uso personal
   - (-) Complejidad de setup

3. **PowerShell wrapper con auto-restart + hook de sesion**
   - (+) Auto-restart en crash (loop con watchdog)
   - (+) Se puede integrar con session hooks de Claude Code
   - (+) Idiomatico con el ecosistema existente (PowerShell scripts)
   - (-) No arranca automaticamente con Windows (requiere primer start manual)

**Decision:** Opcion 3 - PowerShell wrapper con auto-restart.

**Razonamiento:** Consistente con el ecosistema actual (hooks de Claude Code
en PowerShell). El wrapper hace loop + watchdog. Se puede agregar un hook
`PreToolUse` o un alias de PowerShell para auto-start si no esta corriendo.
Si en el futuro el start manual molesta, se puede agregar scheduled task.

**Consecuencias:**
- (+) Recovery automatico de crashes
- (+) Integrado con herramientas existentes
- (-) Primer arranque manual por sesion de Windows (aceptable)

## Folder Structure

```
C:/investigacion/mcp-shared-gateway/
  package.json                  # Dependencia: mcp-proxy
  servers.json                  # Named server config para mcp-proxy
  gateway-config.json           # Config propia: puertos, servers Python
  scripts/
    Start-Gateway.ps1           # Arranca proxy + servers Python
    Stop-Gateway.ps1            # Para todo
    Get-GatewayStatus.ps1       # Health check + memory usage
  .claude/
    CLAUDE.md                   # Puntero a claude_context
    settings.local.json         # Permisos amplios
```

## Interfaces y Contratos

### servers.json (config para mcp-proxy --named-server-config)

Formato: `{ "<name>": { "command": "...", "args": [...], "env": {...} } }`
Cada entry es un server stdio que mcp-proxy expone en `/servers/<name>/mcp`.
Servers a incluir: project-admin, google-drive, youtube-transcript.

### gateway-config.json (config propia del proyecto)

Define puertos del proxy (9800) y de los Python servers (9801-9803).
Cada Python server entry tiene: name, command, args, cwd, port, transport.

### ~/.claude.json (resultado final)

| Server | type | url |
|--------|------|-----|
| project-admin | http | `http://localhost:9800/servers/project-admin/mcp` |
| google-drive | http | `http://localhost:9800/servers/google-drive/mcp` |
| youtube-transcript | http | `http://localhost:9800/servers/youtube-transcript/mcp` |
| youtube | http | `http://localhost:9801/mcp` |
| narrador | http | `http://localhost:9802/mcp` |
| llm-router | http | `http://localhost:9803/mcp` |
| playwright | stdio | (sin cambios, command + args) |
| playwright-headless | stdio | (sin cambios, command + args) |
| claude-orchestrator | stdio | (sin cambios, command + args) |

### Health Check

- `GET http://localhost:9800/ping` -> 200 OK (mcp-proxy built-in)
- Python servers: `GET http://localhost:980X/mcp` responden a initialize
- `Get-GatewayStatus.ps1` verifica todos los endpoints y reporta estado

## Testing Strategy

### Fase 1: Validacion de conectividad
- Arrancar mcp-proxy con 1 server de prueba (project-admin)
- Verificar que `claude mcp add --transport http` lo registra
- Abrir Claude Code y ejecutar un tool del server

### Fase 2: Multi-sesion
- Abrir 2 sesiones de Claude Code simultaneas
- Ejecutar tools desde ambas sesiones
- Verificar que solo hay 1 proceso del server (no 2)

### Fase 3: Servers Python
- Arrancar youtube/narrador/llm-router en modo HTTP
- Conectar Claude Code via `type: "http"`
- Ejecutar tools de cada server

### Fase 4: Servers stateful
- Verificar que playwright sigue funcionando como stdio
- Verificar que orchestrator sigue funcionando como stdio
- Confirmar aislamiento (cada sesion tiene su propia instancia)

### Fase 5: Resilience
- Matar el proceso mcp-proxy, verificar auto-restart
- Matar un server Python, verificar que los demas siguen
- Verificar que Claude Code reconecta automaticamente

## Performance Targets

| Metrica | Target | Medicion |
|---------|--------|----------|
| RAM total MCP servers (3 sesiones) | <= 500 MB | Task Manager / ps |
| Reduccion vs baseline | >= 50% | Comparar con medicion 2026-03-27 |
| Latencia adicional por proxy | < 10 ms | Timestamp en logs |
| Tiempo de startup del gateway | < 10 s | Script timing |
| Recovery post-crash | < 15 s | Kill + medir restart |

### Baseline (medicion 2026-03-27)
- 6 Node.js servers x 2 sesiones = 748 MB
- 3 Python servers = 283 MB
- Total: ~1031 MB

### Estimacion post-gateway
- 1 mcp-proxy + 6 Node.js servers (1 instancia) = ~125 MB
- 3 Python servers (1 instancia) = ~140 MB
- 3 stateful servers x 2 sesiones = ~200 MB
- **Total estimado: ~465 MB (reduccion 55%)**

## Technical Debt y Riesgos

| ID | Riesgo/TD | Severidad | Mitigacion |
|----|-----------|-----------|------------|
| R-001 | `--named-server-config` NO EXISTE en mcp-proxy v6.4.4 | RESUELTA | Usar 1 mcp-proxy por server (1:1). Probado en PoC: funciona |
| R-002 | Python servers FastMCP: verificar que `run(transport="http")` funciona estable | Media | Probar con un server aislado primero |
| R-003 | Windows path handling en servers.json (backslashes) | Media | Usar forward slashes en JSON, probar |
| R-004 | Claude Code reconexion: si gateway cae, todas las tools caen | Alta | Auto-restart agresivo (<5s). Stateful servers no afectados |
| R-005 | Puerto conflictos (9800-9803) con otros servicios | Baja | Puertos altos, poco probable. Documentar en CLAUDE.md |
| R-006 | `cmd /c` wrapper necesario para npx en Windows nativo | Media | Probar si mcp-proxy maneja esto internamente |

### Preguntas del Seed - Resueltas

| # | Pregunta | Respuesta |
|---|----------|-----------|
| 1 | Claude Code via HTTP? | Si. `claude mcp add --transport http` o `"type": "http"` |
| 2 | FastMCP Streamable HTTP? | Si. `mcp.run(transport="http", port=XXXX)` |
| 3 | Overhead del proxy? | [VERIFICAR] Esperado <10ms. Medir en PoC |
| 4 | Lifecycle? | PowerShell wrapper + hook opcional |
| 5 | @nano-step + Python? | Si (external servers). Pero usamos mcp-proxy directo |

## Plan de Implementacion

| Fase | Tiempo | Entregable | Gate |
|------|--------|------------|------|
| A: PoC | 2-3h | mcp-proxy + 1 server + Claude Code conectado | Funciona? Si -> continuar |
| B: Node.js | 1-2h | Todos los stateless Node.js en servers.json | Tools responden |
| C: Python | 1-2h | 3 servers Python en HTTP nativo | Tools responden |
| D: Lifecycle | 1-2h | Start/Stop/Status scripts, medicion final | Ahorro >= 50% |
