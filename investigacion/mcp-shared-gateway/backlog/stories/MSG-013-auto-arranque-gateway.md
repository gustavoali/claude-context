### MSG-013: Integrar arranque del gateway al inicio de sesion
**Points:** 3 | **Priority:** Medium

**As a** developer
**I want** que el gateway se levante automaticamente al abrir Claude Code
**So that** no tenga que recordar ejecutar Start-Gateway.ps1 manualmente

#### Acceptance Criteria
**AC1:** Given el gateway detenido, When inicio una sesion de Claude Code, Then el gateway se levanta automaticamente (via hook o scheduled task)
**AC2:** Given el gateway ya corriendo, When inicio otra sesion, Then no se duplican procesos (Start-Gateway.ps1 es idempotente)
**AC3:** Given el mecanismo automatico configurado, When cierro todas las sesiones de Claude Code, Then el gateway sigue corriendo (no se detiene automaticamente, se detiene con Stop-Gateway.ps1)

#### Technical Notes
- Opcion 1: Hook de Claude Code (`preToolCall` o custom hook en settings.json)
- Opcion 2: Windows Scheduled Task al login
- Opcion 3: Script en profile de PowerShell
- Evaluar cual es menos invasivo y mas confiable

#### DoD
- [ ] Mecanismo de auto-arranque implementado
- [ ] Idempotencia verificada
- [ ] No interfiere con sesiones existentes
- [ ] Documentado en README
