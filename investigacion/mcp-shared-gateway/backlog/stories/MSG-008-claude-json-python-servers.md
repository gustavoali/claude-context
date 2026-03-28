### MSG-008: Actualizar ~/.claude.json con servers Python via HTTP
**Points:** 2 | **Priority:** High

**As a** developer
**I want** que `~/.claude.json` incluya los 3 servers Python como streamable-http
**So that** Claude Code se conecte directamente a los servers Python por HTTP

#### Acceptance Criteria
**AC1:** Given la config actualizada con youtube, narrador y llm-router como streamable-http, When inicio sesion de Claude Code, Then los 3 servers Python aparecen disponibles
**AC2:** Given todos los servers (Node.js via proxy + Python via HTTP directo), When uso tools de cualquier server, Then todas funcionan correctamente
**AC3:** Given la config completa, When listo los servers en una sesion, Then veo 6 stateless (3 Node.js + 3 Python) via HTTP y 3 stateful via stdio

#### Technical Notes
- URLs: youtube `http://localhost:9801/mcp`, narrador `http://localhost:9802/mcp`, llm-router `http://localhost:9803/mcp`
- Verificar path exacto del endpoint (puede ser `/mcp` o `/sse` segun transporte)

#### DoD
- [ ] Config completa en `~/.claude.json`
- [ ] 9 servers totales funcionando (6 HTTP + 3 stdio)
- [ ] Validacion end-to-end de todas las tools
