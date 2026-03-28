### MSG-010: Crear scripts Stop-Gateway.ps1 y Get-GatewayStatus.ps1
**Points:** 2 | **Priority:** Medium

**As a** developer
**I want** scripts para detener el gateway y consultar su estado
**So that** tenga control completo del lifecycle del gateway

#### Acceptance Criteria
**AC1:** Given el gateway corriendo, When ejecuto `Stop-Gateway.ps1`, Then detiene mcp-proxy y los 3 servers Python limpiamente
**AC2:** Given el gateway corriendo, When ejecuto `Get-GatewayStatus.ps1`, Then muestra tabla con nombre, puerto, PID y estado (UP/DOWN) de cada proceso
**AC3:** Given el gateway detenido, When ejecuto `Get-GatewayStatus.ps1`, Then muestra todos los procesos como DOWN

#### Technical Notes
- Stop: usar PID guardado por Start-Gateway o buscar por puerto
- Status: verificar puertos con Test-NetConnection o HTTP health check
- Considerar output formateado (tabla PowerShell)

#### DoD
- [ ] Stop detiene todos los procesos
- [ ] Status muestra estado de cada componente
- [ ] Ambos scripts probados en PowerShell 7
