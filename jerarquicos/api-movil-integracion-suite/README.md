# 🧪 API Móvil - Suite de Pruebas de Integración

[![Integration Tests](https://github.com/yourorg/api-movil-integracion-suite/workflows/Integration%20Tests%20Suite/badge.svg)](https://github.com/yourorg/api-movil-integracion-suite/actions)
[![Coverage](https://img.shields.io/badge/coverage-85%25-brightgreen)](https://github.com/yourorg/api-movil-integracion-suite)
[![SpecFlow](https://img.shields.io/badge/BDD-SpecFlow-blue)](https://specflow.org/)

Suite completa de pruebas de integración para validar la migración de la API Móvil desde .NET Framework 4.7.2 a .NET 8, asegurando equivalencia funcional y de rendimiento entre ambas versiones.

## 📋 Tabla de Contenidos

- [🎯 Propósito](#-propósito)
- [🏗️ Arquitectura](#️-arquitectura)
- [⚙️ Configuración](#️-configuración)
- [🚀 Ejecución](#-ejecución)
- [📊 Reportes](#-reportes)
- [🔧 Desarrollo](#-desarrollo)
- [📚 Documentación](#-documentación)

## 🎯 Propósito

Esta suite de pruebas automatizadas valida que:

- ✅ **Equivalencia Funcional**: Ambas APIs retornan los mismos resultados
- ✅ **Consistencia de Contratos**: Los endpoints mantienen compatibilidad
- ✅ **Rendimiento Comparable**: Las diferencias de performance están dentro de límites aceptables
- ✅ **Manejo de Errores**: Los códigos y mensajes de error son consistentes
- ✅ **Lógica de Negocio**: Las reglas de negocio se mantienen idénticas

## 🏗️ Arquitectura

```
├── 📁 src/ApiMovil.IntegrationTests/
│   ├── 📁 Features/                 # Archivos .feature (Gherkin/BDD)
│   │   ├── Authentication.feature
│   │   ├── SociosCrud.feature
│   │   ├── HealthAndVersion.feature
│   │   └── BusinessLogic.feature
│   ├── 📁 StepDefinitions/         # Implementación pasos BDD
│   │   ├── CommonSteps.cs
│   │   ├── AuthenticationSteps.cs
│   │   └── SociosCrudSteps.cs
│   └── 📁 Support/                 # Infraestructura de pruebas
│       ├── 📁 ApiClients/          # Clientes para ambas APIs
│       ├── 📁 TestData/            # Modelos y datos de prueba
│       ├── 📁 Infrastructure/      # TestContainers y configuración
│       └── 📁 Configuration/       # Configuraciones de ambiente
├── 📁 scripts/                    # Scripts de ejecución
├── 📁 docs/                       # Documentación adicional
└── 📁 TestResults/                # Resultados y reportes
```

### 🔧 Stack Tecnológico

- **🧪 Testing Framework**: xUnit + SpecFlow (BDD)
- **🌐 HTTP Client**: RestSharp
- **🐳 Containers**: TestContainers para aislamiento
- **📊 Assertions**: FluentAssertions
- **⚡ Performance**: NBomber para pruebas de carga
- **📈 Reporting**: Living Documentation + TRX

## ⚙️ Configuración

### Prerrequisitos

- ✅ .NET 8 SDK
- ✅ Docker Desktop (para TestContainers)
- ✅ APIs ejecutándose (Legacy y NET 8)

### Configuración de Ambiente

1. **Clonar el repositorio**:
```bash
git clone https://github.com/yourorg/api-movil-integracion-suite.git
cd api-movil-integracion-suite
```

2. **Configurar `appsettings.test.json`**:
```json
{
  "ApiUrls": {
    "Legacy": "https://localhost:44301",
    "Net8": "https://localhost:7001"
  },
  "ConnectionStrings": {
    "TestDatabase": "Server=(localdb)\\mssqllocaldb;Database=ApiMovilIntegrationTest;Trusted_Connection=true;"
  },
  "TestSettings": {
    "UseTestContainers": true,
    "EnablePerformanceTests": false,
    "RequestTimeoutSeconds": 30
  }
}
```

3. **Instalar dependencias**:
```bash
dotnet restore
```

4. **Construir el proyecto**:
```bash
dotnet build --configuration Release
```

## 🚀 Ejecución

### Ejecución Rápida (PowerShell)

```powershell
# Ejecutar todas las pruebas
.\scripts\run-integration-tests.ps1

# Solo pruebas de humo
.\scripts\run-integration-tests.ps1 -TestCategory Smoke

# Pruebas con reporte
.\scripts\run-integration-tests.ps1 -TestCategory All -GenerateReport

# Ambiente específico
.\scripts\run-integration-tests.ps1 -Environment Staging -TestCategory Performance
```

### Ejecución Manual (.NET CLI)

```bash
# Todas las pruebas
dotnet test --configuration Release

# Solo pruebas de autenticación
dotnet test --filter "FullyQualifiedName~Authentication"

# Pruebas con cobertura
dotnet test --collect:"XPlat Code Coverage"

# Pruebas de performance
dotnet test --filter "Category=performance"
```

### Categorías de Pruebas

| Categoría | Descripción | Filtro |
|---|---|---|
| 🔥 **Smoke** | Pruebas básicas de conectividad | `Category=smoke` |
| 🧪 **Integration** | Pruebas funcionales completas | `Category!=performance&Category!=smoke` |
| ⚡ **Performance** | Pruebas de rendimiento | `Category=performance` |
| 🔐 **Auth** | Pruebas de autenticación | `FullyQualifiedName~Authentication` |
| 📊 **CRUD** | Operaciones de socios | `FullyQualifiedName~SociosCrud` |

## 📊 Reportes

### Reportes Generados

1. **📋 Test Results (TRX)**: `TestResults/results-*.trx`
2. **📊 Code Coverage**: `TestResults/coverage.cobertura.xml`
3. **📖 Living Documentation**: `TestResults/LivingDoc-*.html`
4. **⚡ Performance Reports**: `TestResults/performance-*.html`

### Ejemplo de Reporte BDD

```gherkin
✅ Característica: Autenticación en APIs
  ✅ Escenario: Login exitoso en ambas APIs debe retornar tokens válidos
    ✅ Dado que tengo las credenciales de prueba configuradas
    ✅ Cuando inicio sesión en API Legacy con credenciales válidas
    ✅ Y inicio sesión en API NET 8 con las mismas credenciales
    ✅ Entonces ambas respuestas deben ser exitosas
    ✅ Y ambos tokens deben ser válidos
```

### Dashboard de Resultados

Los resultados se integran con:
- 📊 **GitHub Actions**: CI/CD automático
- 📈 **Azure DevOps**: Integración con pipelines
- 🔔 **Microsoft Teams**: Notificaciones automáticas
- 📧 **Email**: Reportes programados

## 🔧 Desarrollo

### Agregar Nuevas Pruebas

1. **Crear Feature BDD**:
```gherkin
# Features/NuevaFuncionalidad.feature
Característica: Nueva Funcionalidad
  Escenario: Validar nueva funcionalidad
    Dado que tengo los datos necesarios
    Cuando ejecuto la operación en ambas APIs
    Entonces los resultados deben ser equivalentes
```

2. **Implementar Step Definitions**:
```csharp
[Binding]
public class NuevaFuncionalidadSteps
{
    [Given(@"que tengo los datos necesarios")]
    public void GivenQueTengoLosDatosNecesarios()
    {
        // Implementación
    }
}
```

3. **Ejecutar pruebas**:
```bash
dotnet test --filter "FullyQualifiedName~NuevaFuncionalidad"
```

### Estructura de Datos de Prueba

```csharp
// TestData/Models/NuevoDto.cs
public class NuevoDto
{
    public int Id { get; set; }
    public string Nombre { get; set; }
    // ... propiedades
}
```

### Configuración de API Clients

```csharp
// ApiClients/NuevoApiClient.cs
public class NuevoApiClient : BaseApiClient
{
    public async Task<NuevoDto> OperacionAsync(int id)
    {
        return await GetAsync<NuevoDto>($"api/nuevo/{id}");
    }
}
```

## 📚 Documentación

### Enlaces Útiles

- 📖 [SpecFlow Documentation](https://docs.specflow.org/)
- 🐳 [TestContainers .NET](https://dotnet.testcontainers.org/)
- ⚡ [NBomber Performance Testing](https://nbomber.com/)
- 📊 [FluentAssertions](https://fluentassertions.com/)

### Convenciones de Nombrado

- **Features**: PascalCase descriptivo (`SociosCrud.feature`)
- **Steps**: Español con sintaxis clara (`Dado que`, `Cuando`, `Entonces`)
- **Classes**: PascalCase con sufijo `Steps` o `Client`
- **Methods**: PascalCase descriptivo
- **Variables**: camelCase

### Buenas Prácticas

1. ✅ **Independencia**: Cada prueba debe ser independiente
2. ✅ **Cleanup**: Limpiar datos después de cada prueba
3. ✅ **Datos**: Usar factory pattern para datos de prueba
4. ✅ **Assertions**: Usar FluentAssertions para mejor legibilidad
5. ✅ **Performance**: Medir y comparar tiempos de respuesta
6. ✅ **Logging**: Log detallado para debugging
7. ✅ **Retry**: Implementar retry para pruebas flaky

---

## 🤝 Contribución

1. Fork el repositorio
2. Crear rama para feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit cambios (`git commit -am 'Add nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crear Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver `LICENSE` para más detalles.

## 📞 Soporte

- 📧 **Email**: support@company.com
- 💬 **Teams**: Canal de Integration Testing
- 📱 **Issues**: [GitHub Issues](https://github.com/yourorg/api-movil-integracion-suite/issues)

---

**🎯 Objetivo**: Garantizar una migración sin riesgos con confianza del 100% en la equivalencia funcional entre APIs.