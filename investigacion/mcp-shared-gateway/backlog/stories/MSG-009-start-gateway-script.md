### MSG-009: Crear script Start-Gateway.ps1
**Points:** 3 | **Priority:** High

**As a** developer
**I want** un script PowerShell que levante el proxy y los servers Python con un solo comando
**So that** no tenga que arrancar manualmente cada proceso al iniciar trabajo

#### Acceptance Criteria
**AC1:** Given todos los servers detenidos, When ejecuto `Start-Gateway.ps1`, Then arranca mcp-proxy (puerto 9800) y los 3 servers Python (puertos 9801-9803)
**AC2:** Given el script ejecutandose, When un proceso falla al arrancar, Then muestra error claro indicando cual fallo y los demas siguen corriendo
**AC3:** Given el gateway ya corriendo, When ejecuto Start-Gateway.ps1 de nuevo, Then detecta que ya esta corriendo y no duplica procesos

#### Technical Notes
- Verificar puertos antes de arrancar (netstat o Test-NetConnection)
- Arrancar procesos en background (Start-Process o jobs)
- Log de arranque a archivo para debugging
- Considerar auto-restart si un proceso muere (watchdog basico)

#### DoD
- [ ] Script arranca todos los procesos
- [ ] Manejo de errores implementado
- [ ] Idempotente (no duplica procesos)
- [ ] Probado en PowerShell 7
