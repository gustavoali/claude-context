# MCP Shared Gateway - Seed Document

## Problema

Cada sesion de Claude Code levanta todos los MCP servers configurados como subprocesos independientes. Con 6+ servers y 2-3 sesiones simultaneas, esto genera 12-18 procesos redundantes consumiendo ~1 GB de RAM solo en MCP servers.

### Medicion real (2026-03-27)
- 6 MCP servers Node.js x 2 sesiones = 12 procesos = 748 MB
- MCP servers Python (narrador, youtube, llm-router) = 283 MB
- **Total: ~1 GB solo en MCP servers duplicados**
- VmmemWSL (Docker containers): 1.2 GB adicionales
- 3 instancias Claude Code: 3.2 GB totales

## Objetivo

Reducir el consumo de memoria eliminando la duplicacion de MCP servers entre sesiones de Claude Code, manteniendo la funcionalidad completa.

## Hallazgos de Investigacion

### Transportes MCP soportados
1. **Stdio** (actual): 1 proceso por sesion por server. No permite sharing.
2. **SSE** (deprecated): HTTP-based, permite multiples clientes por server.
3. **Streamable HTTP** (moderno): Reemplazo de SSE. Stateful (session ID) o stateless. Cross-platform.

### Paquetes existentes relevantes
| Paquete | Version | Descripcion |
|---------|---------|-------------|
| `mcp-proxy` | 6.4.4 | Convierte stdio -> SSE. Permite compartir un server stdio entre clientes |
| `@nano-step/shared-mcp-proxy` | 1.4.4 | "Run MCP servers once, share across tools". Match exacto al caso de uso |
| `nuwax-mcp-stdio-proxy` | 1.4.10 | Agrega multiples servers (stdio + HTTP + SSE). Convert & proxy modes |
| `@anyshift/mcp-proxy` | - | Proxy generico con truncation, file writing, JQ |

### Arquitectura propuesta

```
Sesion Claude Code 1 ──┐
Sesion Claude Code 2 ──┤──> MCP Gateway (HTTP/SSE :8080)
Sesion Claude Code 3 ──┘         |
                                 ├── project-admin (1 instancia)
                                 ├── playwright (1 instancia)
                                 ├── playwright-headless (1 instancia)
                                 ├── google-drive (1 instancia)
                                 ├── youtube-transcript (1 instancia)
                                 ├── claude-orchestrator (1 instancia)
                                 ├── youtube (Python, 1 instancia)
                                 ├── narrador (Python, 1 instancia)
                                 └── llm-router (Python, 1 instancia)
```

**Resultado esperado:** De ~18 procesos (6 servers x 3 sesiones) a ~10 (1 gateway + 9 servers).
Ahorro estimado: 500-700 MB de RAM.

### Consideraciones criticas

1. **Estado por sesion:** Playwright mantiene browsers separados por sesion. El gateway necesita manejar esto (session IDs o instancias separadas para servers con estado).
2. **Servers stateless vs stateful:**
   - Stateless (pueden compartirse): project-admin, youtube-transcript, llm-router, narrador
   - Stateful (necesitan aislamiento): playwright (browser instances), claude-orchestrator (sessions)
3. **Configuracion en Claude Code:** Claude Code soporta `type: "sse"` y `type: "streamable-http"` ademas de `type: "stdio"` en `~/.claude.json`.
4. **Fallback:** Si el gateway cae, las sesiones pierden acceso a todos los tools. Considerar health checks y auto-restart.

## Opciones de Implementacion

### Opcion A: Usar `@nano-step/shared-mcp-proxy` as-is
- Menor esfuerzo, paquete existente
- Evaluar si cubre todos los servers (Node + Python)
- Riesgo: dependencia de terceros, posibles limitaciones

### Opcion B: Gateway custom con MCP SDK
- Usar `StreamableHTTPServerTransport` del SDK oficial
- Control total sobre routing, estado, health checks
- Mayor esfuerzo pero mas flexible

### Opcion C: Perfiles de MCP + servers como servicios
- Sin gateway: cada server corre como servicio HTTP independiente
- Claude Code se conecta directo a cada server por HTTP
- Perfiles definen que servers carga cada sesion
- Mas simple, menos overhead de proxy

### Opcion D: Hibrida (C + A)
- Perfiles para reducir servers innecesarios
- Proxy compartido para los servers que todas las sesiones usan
- Mejor balance esfuerzo/resultado

## Preguntas a Resolver

1. Claude Code puede conectarse a MCP servers via HTTP/SSE sin modificaciones?
2. Los MCP servers Python (FastMCP) soportan Streamable HTTP out of the box?
3. Cual es el overhead del proxy vs conexion directa?
4. Como manejar el lifecycle (auto-start del gateway al abrir Claude Code)?
5. El paquete `@nano-step/shared-mcp-proxy` soporta servers Python?

## Criterios de Exito

- Reduccion >= 50% en memoria consumida por MCP servers (de ~1 GB a ~500 MB)
- Todas las tools MCP siguen funcionando correctamente
- No hay degradacion perceptible de latencia
- Setup reproducible (documentado, scripteable)
- Funciona en Windows + WSL (entorno actual)

## Stack Propuesto

- Node.js (gateway/proxy)
- MCP SDK `@modelcontextprotocol/sdk` (transporte HTTP)
- Posiblemente `@nano-step/shared-mcp-proxy` o `mcp-proxy`
- PowerShell para lifecycle management (auto-start)

## Relaciones

- **project-admin** (mcp): server candidato a compartir
- **claude-orchestrator** (mcp): server con estado, necesita analisis especial
- **youtube** (mcp): server Python, evaluar compatibilidad
- **narrador** (mcp): server Python, evaluar compatibilidad
- **llm-router** (mcp): server Python, evaluar compatibilidad
- **context-engineering** (research): patrones de optimizacion de recursos
- **agent-token-economics** (research): metricas de costo/eficiencia
