### MSG-007: Configurar narrador y llm-router (Python) en HTTP nativo
**Points:** 3 | **Priority:** High

**As a** developer
**I want** que narrador (puerto 9802) y llm-router (puerto 9803) corran en HTTP nativo
**So that** los 3 servers Python se compartan entre sesiones

#### Acceptance Criteria
**AC1:** Given narrador arrancado con `--transport streamable-http --port 9802`, When uso tools de narrador desde Claude Code, Then funcionan correctamente
**AC2:** Given llm-router arrancado con `--transport streamable-http --port 9803`, When uso tools de llm-router desde Claude Code, Then funcionan correctamente
**AC3:** Given los 3 servers Python corriendo en HTTP, When 2 sesiones usan los 3 simultaneamente, Then no hay conflictos

#### Technical Notes
- Mismo patron que MSG-006, aplicado a narrador y llm-router
- Cada server en su puerto asignado
- Verificar que env vars necesarias se pasen correctamente

#### DoD
- [ ] narrador en puerto 9802 funcionando
- [ ] llm-router en puerto 9803 funcionando
- [ ] Todas las tools responden correctamente
- [ ] `~/.claude.json` actualizado con los 3 servers Python
