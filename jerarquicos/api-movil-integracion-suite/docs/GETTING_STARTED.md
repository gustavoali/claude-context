# 🚀 Guía de Inicio Rápido - Suite de Pruebas de Integración

Esta guía te ayudará a configurar y ejecutar la suite de pruebas de integración en 15 minutos.

## ⚡ Inicio Rápido (5 minutos)

### 1. Verificar Prerrequisitos

```powershell
# Verificar .NET 8
dotnet --version
# Debe mostrar: 8.x.x

# Verificar Docker
docker --version
# Debe mostrar: Docker version x.x.x
```

### 2. Clonar y Configurar

```bash
cd C:\jerarquicos\api-movil-integracion-suite
dotnet restore src/ApiMovil.IntegrationTests/ApiMovil.IntegrationTests.csproj
dotnet build src/ApiMovil.IntegrationTests/ApiMovil.IntegrationTests.csproj --configuration Release
```

### 3. Ejecutar Pruebas de Humo

```powershell
# Windows
.\scripts\run-integration-tests.ps1 -TestCategory Smoke

# O manualmente
dotnet test src/ApiMovil.IntegrationTests/ApiMovil.IntegrationTests.csproj --filter "Category=smoke"
```

¡Si las pruebas de humo pasan, está todo listo! 🎉

## 🔧 Configuración Detallada

### Configuración de APIs

Asegúrate de que ambas APIs estén ejecutándose:

```powershell
# Legacy API (ejemplo)
# Debería estar disponible en https://localhost:44301

# NET 8 API (ejemplo)
# Debería estar disponible en https://localhost:7001
```

### Configuración de Base de Datos

La suite puede usar:

1. **TestContainers** (recomendado): Base de datos aislada en Docker
2. **LocalDB**: Base de datos local de SQL Server
3. **SQL Server remoto**: Para ambientes de integración

```json
// appsettings.test.json
{
  "TestSettings": {
    "UseTestContainers": true,  // false para usar BD externa
  },
  "ConnectionStrings": {
    "TestDatabase": "Server=(localdb)\\mssqllocaldb;Database=ApiMovilIntegrationTest;Trusted_Connection=true;"
  }
}
```

## 📊 Tipos de Ejecución

### 1. Desarrollo Local

```powershell
# Pruebas básicas durante desarrollo
dotnet test --filter "Category=smoke"

# Pruebas de una funcionalidad específica
dotnet test --filter "FullyQualifiedName~Authentication"
```

### 2. Validación Completa

```powershell
# Todas las pruebas excepto performance
.\scripts\run-integration-tests.ps1 -TestCategory Integration -GenerateReport
```

### 3. Validación de Performance

```powershell
# Solo en ambientes estables
.\scripts\run-integration-tests.ps1 -TestCategory Performance -Environment Staging
```

## 🐛 Solución de Problemas Comunes

### Error: "APIs no disponibles"

```
✅ Verificar que ambas APIs estén ejecutándose
✅ Verificar URLs en appsettings.test.json
✅ Verificar certificados SSL (pueden ser autofirmados en dev)
```

### Error: "TestContainers no puede iniciar"

```powershell
# Verificar Docker Desktop
docker info

# Si Docker no funciona, deshabilitar TestContainers
# En appsettings.test.json: "UseTestContainers": false
```

### Error: "Base de datos no accesible"

```sql
-- Verificar LocalDB
sqllocaldb info mssqllocaldb

-- Crear base de datos manualmente si es necesario
CREATE DATABASE ApiMovilIntegrationTest
```

### Error: "Pruebas fallan intermitentemente"

```powershell
# Ejecutar con más timeout
$env:INTEGRATION_TEST_RequestTimeoutSeconds = "60"
dotnet test
```

## 📈 Interpretando Resultados

### Resultados Exitosos
```
✅ Test Run Successful.
Total tests: 25
     Passed: 25
     Failed: 0
     Skipped: 0
 -  Failed: 0, Passed: 25, Skipped: 0, Total: 25, Duration: 2 min
```

### Resultados con Fallas
```
❌ Test Run Failed.
Total tests: 25
     Passed: 22
     Failed: 3
     Skipped: 0

Failed tests:
- AuthenticationSteps.LoginTest: API Legacy returned 401
- SociosCrudSteps.SearchTest: Response times differ by 1500ms
- HealthSteps.HealthCheck: NET 8 API not responding
```

## 📋 Checklist de Validación

Antes de considerar la migración completa:

- [ ] ✅ Todas las pruebas de humo pasan
- [ ] ✅ Todas las pruebas de integración pasan
- [ ] ✅ Diferencias de performance < 200ms
- [ ] ✅ Cobertura de pruebas > 80%
- [ ] ✅ No hay regresiones en lógica de negocio
- [ ] ✅ Manejo de errores es consistente
- [ ] ✅ Autenticación funciona igual en ambas APIs

## 🔄 Automatización

### GitHub Actions

El pipeline automático ejecuta:

```yaml
# .github/workflows/integration-tests.yml
- Smoke tests (siempre)
- Integration tests (en PR y main)
- Performance tests (solo scheduled o con [perf] en commit)
```

### Ejecución Programada

```powershell
# Daily smoke tests
schtasks /create /sc daily /tn "API Integration Tests" /tr "powershell .\scripts\run-integration-tests.ps1 -TestCategory Smoke"
```

## 📞 Obtener Ayuda

### Logs Detallados

```powershell
# Habilitar logs detallados
$env:INTEGRATION_TEST_LogLevel = "Debug"
dotnet test --verbosity detailed
```

### Revisar Archivos de Resultado

```powershell
# Ver último resultado
Get-ChildItem TestResults\*.trx | Sort-Object LastWriteTime -Descending | Select-Object -First 1
```

### Contacto

- 💬 **Teams**: Canal #integration-testing
- 📧 **Email**: qa-team@company.com
- 📱 **Issues**: [GitHub Issues](https://github.com/yourorg/api-movil-integracion-suite/issues)

---

**🎯 Siguiente paso**: Una vez que domines lo básico, revisa [Advanced Usage](ADVANCED_USAGE.md) para configuraciones avanzadas.