# Backlog - MCP Shared Gateway
**Version:** 1.0 | **Actualizacion:** 2026-03-27

## Resumen
| Metrica | Valor |
|---------|-------|
| Total historias | 13 |
| Puntos totales | 34 |
| Epics | 4 |
| Completadas | 8 (21 pts) |
| Pendientes | 5 (13 pts) |

## Vision
Eliminar la duplicacion de MCP servers entre sesiones de Claude Code mediante un gateway proxy compartido basado en `mcp-proxy` y HTTP nativo para servers Python. Objetivo: reducir >= 50% el consumo de RAM (~1 GB a ~500 MB) manteniendo funcionalidad completa, con lifecycle automatizado y setup reproducible.

## Epics
| Epic | Historias | Puntos | Status |
|------|-----------|--------|--------|
| EPIC-A: PoC | MSG-001, MSG-002, MSG-003 | 8 | Done |
| EPIC-B: Node.js Stateless | MSG-004, MSG-005 | 5 | Done |
| EPIC-C: Python HTTP | MSG-006, MSG-007, MSG-008 | 8 | Done (via mcp-proxy) |
| EPIC-D: Lifecycle y Produccion | MSG-009, MSG-010, MSG-011, MSG-012, MSG-013 | 13 | 8 pts done, 5 pendientes |

## Pendientes (con detalle)

### MSG-001: Instalar y validar mcp-proxy con un server Node.js
**Points:** 2 | **Priority:** Critical

**As a** developer
**I want** verificar que mcp-proxy funciona con named-server-config y streamable HTTP
**So that** confirme la viabilidad tecnica antes de invertir en el resto del proyecto

**AC1:** Given mcp-proxy instalado via npm, When ejecuto con `servers.json` conteniendo project-admin, Then el proxy arranca en puerto 9800 sin errores
**AC2:** Given el proxy corriendo, When hago request HTTP a `http://localhost:9800/servers/project-admin/mcp`, Then recibo respuesta MCP valida
**AC3:** Given el proxy corriendo, When invoco una tool de project-admin via HTTP, Then ejecuta correctamente

**Tech:** `npx @punkpeye/mcp-proxy --port 9800 --named-server-config servers.json`. R-001, R-006 (cmd /c wrapper).

**DoD:** proxy ejecuta, project-admin responde, comando exacto documentado, workarounds documentados.

---

### MSG-002: Conectar Claude Code al proxy via streamable HTTP
**Points:** 3 | **Priority:** Critical

**As a** developer
**I want** que Claude Code use project-admin a traves del proxy en vez de stdio
**So that** valide el flujo end-to-end desde la perspectiva del usuario

**AC1:** Given `~/.claude.json` con project-admin tipo streamable-http a `localhost:9800/servers/project-admin/mcp`, When inicio sesion, Then project-admin aparece como tool disponible
**AC2:** Given sesion activa, When uso `pa_list_projects`, Then resultado identico a stdio
**AC3:** Given proxy con 1 server, When abro 2 sesiones simultaneas, Then ambas usan project-admin sin conflicto

**Tech:** Backup `~/.claude.json`. Si falla streamable-http, probar sse. Gate de Fase A.

**DoD:** Claude Code conecta, tool funciona, 2 sesiones validadas, config documentada.

---

### MSG-003: Medir baseline de memoria pre-gateway
**Points:** 3 | **Priority:** Critical

**As a** developer
**I want** medir consumo de memoria actual vs con PoC
**So that** tenga datos objetivos para calcular ahorro real

**AC1:** Given 2 sesiones con todos MCP servers en stdio, When mido memoria, Then registro consumo total
**AC2:** Given 2 sesiones con project-admin via proxy, When mido, Then registro consumo y calculo delta
**AC3:** Given ambas mediciones, When comparo, Then documento ahorro real extrapolado al setup completo

**Tech:** Script PowerShell, medir RSS por proceso. Guardar en `docs/measurements/`.

**DoD:** Baseline medido, medicion PoC documentada, ahorro calculado, decision GO/NO-GO.

---

### MSG-004: Configurar todos los servers Node.js stateless en mcp-proxy
**Points:** 3 | **Priority:** High

**As a** developer
**I want** agregar google-drive y youtube-transcript al proxy
**So that** todos los servers Node.js stateless se compartan entre sesiones

**AC1:** Given `servers.json` con 3 servers, When arranco proxy, Then los 3 inician sin errores
**AC2:** Given proxy con 3 servers, When uso tools de cada uno desde Claude Code, Then todas responden
**AC3:** Given 2 sesiones simultaneas, When ambas usan los 3 servers, Then no hay conflictos

**Tech:** Agregar incrementalmente. google-drive necesita OAuth env vars. youtube-transcript necesita cookie env vars.

**DoD:** 3 servers en servers.json, tools responden, 2 sesiones validadas, claude.json actualizado.

---

### MSG-005: Actualizar ~/.claude.json con servers Node.js via proxy
**Points:** 2 | **Priority:** High

**As a** developer
**I want** config definitiva en `~/.claude.json` para los 3 servers Node.js
**So that** todas las sesiones futuras usen el proxy automaticamente

**AC1:** Given config stdio backupeada, When reemplazo 3 servers por streamable-http, Then Claude Code los carga sin errores
**AC2:** Given servers stateful sin modificar, When inicio sesion, Then siguen funcionando via stdio
**AC3:** Given proxy NO corriendo, When inicio sesion, Then error claro de conexion (no cuelga)

**Tech:** Backup en `~/.claude.json.bak`. Stateful (playwright, orchestrator) intactos.

**DoD:** Config actualizada, stateful intactos, comportamiento sin proxy verificado, backup guardado.

## Pendientes (indice - detalle en backlog/stories/)

| ID | Titulo | Pts | Priority | Archivo |
|----|--------|-----|----------|---------|
| MSG-006 | Configurar youtube (Python) en HTTP nativo | 3 | High | stories/MSG-006-youtube-python-http.md |
| MSG-007 | Configurar narrador y llm-router en HTTP nativo | 3 | High | stories/MSG-007-narrador-llmrouter-python-http.md |
| MSG-008 | Actualizar ~/.claude.json con servers Python | 2 | High | stories/MSG-008-claude-json-python-servers.md |
| MSG-009 | Crear script Start-Gateway.ps1 | 3 | High | stories/MSG-009-start-gateway-script.md |
| MSG-010 | Crear scripts Stop y Status | 2 | Medium | stories/MSG-010-stop-status-scripts.md |
| MSG-011 | Medicion final de ahorro de memoria | 3 | High | stories/MSG-011-medicion-final-memoria.md |
| MSG-012 | Documentar setup completo | 2 | Medium | stories/MSG-012-documentacion-setup.md |
| MSG-013 | Integrar arranque automatico al inicio de sesion | 3 | Medium | stories/MSG-013-auto-arranque-gateway.md |

## Completadas (indice)
| ID | Titulo | Puntos | Fecha | Detalle |
|----|--------|--------|-------|---------|
| MSG-001 | Instalar y validar mcp-proxy con un server Node.js | 2 | 2026-03-28 | PoC OK, --stateless requerido |
| MSG-002 | Conectar Claude Code al proxy via streamable HTTP | 3 | 2026-03-28 | Config validada, E2E pendiente restart |
| MSG-003 | Medir baseline de memoria pre-gateway | 3 | 2026-03-28 | 5 sesiones, 3.2 GB total, 2.5 GB stateless |
| MSG-004 | Configurar todos los servers Node.js stateless | 3 | 2026-03-28 | 3 servers + 3 Python via mcp-proxy |
| MSG-005 | Actualizar ~/.claude.json con servers via proxy | 2 | 2026-03-28 | Documentado en docs/claude-json-config.md |
| MSG-009 | Crear script Start-Gateway.ps1 | 3 | 2026-03-28 | 6 servers, PID file, logs |
| MSG-010 | Crear scripts Stop y Status | 2 | 2026-03-28 | Kill recursivo, health check HTTP |
| MSG-011 | Medicion final de ahorro de memoria | 3 | 2026-03-28 | 1.6 GB ahorro (63% stateless) |

## ID Registry
| Rango | Estado |
|-------|--------|
| MSG-001 a MSG-013 | Asignados |
| MSG-014+ | Disponibles |

Proximo ID: MSG-014
