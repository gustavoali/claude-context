### MSG-006: Configurar youtube MCP (Python) en HTTP nativo
**Points:** 3 | **Priority:** High

**As a** developer
**I want** que el server youtube (Python/FastMCP) corra en HTTP en puerto 9801
**So that** se comparta entre sesiones sin pasar por el proxy Node.js

#### Acceptance Criteria
**AC1:** Given el server youtube con FastMCP, When lo arranco con `--transport streamable-http --port 9801`, Then escucha en el puerto sin errores
**AC2:** Given el server corriendo en HTTP, When configuro Claude Code con tipo streamable-http apuntando a `http://localhost:9801/mcp`, Then todas las tools de youtube funcionan correctamente
**AC3:** Given 2 sesiones usando el server, When ambas hacen requests simultaneos, Then no hay errores de concurrencia

#### Technical Notes
- R-002: verificar estabilidad de FastMCP en modo HTTP
- Si FastMCP no soporta streamable-http, probar `--transport sse`
- Puerto asignado: 9801 (segun gateway-config.json)
- Stderr debe redirigirse correctamente (L-020)

#### DoD
- [ ] Server youtube corriendo en HTTP
- [ ] Todas las tools responden via HTTP
- [ ] Test concurrencia con 2 sesiones
- [ ] Comando de arranque documentado
