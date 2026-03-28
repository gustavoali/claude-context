### MSG-012: Documentar setup completo y configuracion
**Points:** 2 | **Priority:** Medium

**As a** developer
**I want** documentacion completa del setup del gateway
**So that** pueda reproducir la configuracion y resolver problemas

#### Acceptance Criteria
**AC1:** Given la documentacion creada, When un usuario sigue los pasos desde cero, Then logra levantar el gateway con todos los servers
**AC2:** Given la documentacion, When busco troubleshooting, Then encuentro los problemas comunes y sus soluciones (proxy no arranca, server falla, puerto ocupado)
**AC3:** Given la documentacion, When busco la config de `~/.claude.json`, Then encuentro el JSON exacto a usar

#### Technical Notes
- Actualizar CLAUDE.md del proyecto con version, estado, comandos
- README.md con quick start, arquitectura, troubleshooting
- Incluir config exacta de `~/.claude.json`

#### DoD
- [ ] README.md con setup completo
- [ ] CLAUDE.md actualizado
- [ ] Troubleshooting con problemas conocidos
- [ ] Config de ejemplo incluida
