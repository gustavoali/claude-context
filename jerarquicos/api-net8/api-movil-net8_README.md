# ApiMovil .NET 8

## 🏥 Descripción

ApiMovil es una API REST desarrollada en .NET 8 para la gestión integral de socios de obra social. La aplicación se comunica con microservicios backend para acceder a los datos, siguiendo una arquitectura de microservicios y principios de Clean Architecture.

## 🚀 Características Principales

- ✅ **Clean Architecture** con separación clara de responsabilidades
- ✅ **Comunicación con Microservicios** usando HttpClient con Polly para resiliencia
- ✅ **Autenticación JWT** con refresh tokens
- ✅ **Autorización basada en roles** y recursos
- ✅ **Validación de datos** con FluentValidation
- ✅ **Mapeo automático** con AutoMapper
- ✅ **Logging estructurado** con Serilog
- ✅ **Health Checks** para monitoreo
- ✅ **Cache distribuido** con Redis
- ✅ **Documentación API** con Swagger/OpenAPI
- ✅ **Tests exhaustivos** (Unitarios, Integración, Seguridad)
- ✅ **CI/CD Pipeline** con GitHub Actions
- ✅ **Containerización** con Docker
- ✅ **Monitoreo** con Application Insights y New Relic

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────┐
│                 ApiMovil API                    │
├─────────────────────────────────────────────────┤
│  Controllers (Presentation Layer)              │
├─────────────────────────────────────────────────┤
│  Application Services (Application Layer)      │
├─────────────────────────────────────────────────┤
│  HTTP Repositories (Infrastructure Layer)      │
├─────────────────────────────────────────────────┤
│  Domain Entities & DTOs (Domain Layer)         │
├─────────────────────────────────────────────────┤
│  Shared Utilities (Shared Layer)               │
└─────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────┐
│            Backend Microservices                │
│  (Socios, Credenciales, Autorizaciones, etc.)  │
└─────────────────────────────────────────────────┘
```

## 📦 Estructura del Proyecto

```
ApiMovil/
├── src/
│   ├── ApiMovil.Api/              # Capa de presentación
│   ├── ApiMovil.Application/      # Lógica de aplicación
│   ├── ApiMovil.Domain/           # Entidades de dominio
│   ├── ApiMovil.Infrastructure/   # Infraestructura
│   └── ApiMovil.Shared/           # Utilidades compartidas
├── tests/
│   ├── ApiMovil.Api.Tests/        # Tests de controladores
│   ├── ApiMovil.Application.Tests/# Tests de servicios
│   ├── ApiMovil.Domain.Tests/     # Tests de dominio
│   ├── ApiMovil.Infrastructure.Tests/ # Tests de infraestructura
│   └── ApiMovil.Integration.Tests/# Tests de integración
├── scripts/                       # Scripts de utilidad
├── deploy/                        # Scripts de despliegue
├── .github/workflows/             # CI/CD pipelines
└── docs/                          # Documentación
```

## 🛠️ Tecnologías Utilizadas

### Backend
- **.NET 8.0** - Framework principal
- **ASP.NET Core 8.0** - Web API framework
- **C# 12** - Lenguaje de programación

### Comunicación
- **HttpClient** - Cliente HTTP para microservicios
- **Polly** - Políticas de resiliencia (Retry, Circuit Breaker, Timeout)

### Autenticación y Seguridad
- **JWT Bearer Tokens** - Autenticación
- **ASP.NET Core Identity** - Gestión de usuarios
- **HTTPS** - Comunicación segura
- **Rate Limiting** - Protección contra abuso

### Persistencia y Cache
- **Redis** - Cache distribuido
- **Memory Cache** - Cache en memoria

### Logging y Monitoreo
- **Serilog** - Logging estructurado
- **Application Insights** - Telemetría y métricas
- **New Relic** - Monitoreo de aplicaciones
- **Seq** - Análisis de logs

### Testing
- **NUnit** - Framework de testing
- **FluentAssertions** - Assertions fluidas
- **Moq** - Mocking framework
- **Coverlet** - Cobertura de código

### DevOps
- **Docker** - Containerización
- **GitHub Actions** - CI/CD
- **Nginx** - Reverse proxy (producción)

## 🚀 Inicio Rápido

### Prerrequisitos

- [.NET 8.0 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- [Docker](https://www.docker.com/get-started) (opcional)
- [Redis](https://redis.io/) (para cache distribuido)

### Instalación Local

1. **Clonar el repositorio**
   ```bash
   git clone <repository-url>
   cd api-movil-net8
   ```

2. **Restaurar dependencias**
   ```bash
   dotnet restore
   ```

3. **Configurar settings**
   ```bash
   # Copiar configuración de ejemplo
   cp src/ApiMovil.Api/appsettings.json src/ApiMovil.Api/appsettings.Development.json
   # Editar configuración según necesidades
   ```

4. **Ejecutar la aplicación**
   ```bash
   dotnet run --project src/ApiMovil.Api
   ```

5. **Acceder a la API**
   - API: `https://localhost:7001`
   - Swagger: `https://localhost:7001/swagger`
   - Health Check: `https://localhost:7001/health`

### Instalación con Docker

1. **Usando Docker Compose**
   ```bash
   # Desarrollo
   docker-compose up -d
   
   # Staging
   docker-compose -f docker-compose.staging.yml up -d
   
   # Producción
   docker-compose -f docker-compose.production.yml up -d
   ```

2. **Servicios disponibles**
   - API: `http://localhost:8080`
   - Redis: `localhost:6379`
   - Seq (logs): `http://localhost:5341`

## 📋 Scripts Disponibles

### Testing
```bash
# Ejecutar todos los tests
./scripts/run-tests.sh

# Ejecutar tests con coverage
./scripts/run-tests.sh -r -t 80

# Windows
./scripts/run-tests.ps1 -GenerateReport -CoverageThreshold 80
```

### Despliegue
```bash
# Despliegue a desarrollo
./deploy/deploy-development.sh

# Despliegue a staging
./deploy/deploy-staging.sh

# Despliegue a producción
./deploy/deploy-production.sh
```

## 🔐 Configuración de Seguridad

### Variables de Entorno

Configurar las siguientes variables según el ambiente:

```bash
# JWT Configuration
JWT_SECRET=your-super-secret-key-256-bits-minimum
JWT_ISSUER=ApiMovil.Production
JWT_AUDIENCE=ApiMovil.Users.Production

# External Services
REDIS_CONNECTION_STRING=localhost:6379
SEQ_URL=http://seq:5341
SEQ_API_KEY=your-seq-api-key

# Monitoring
APPINSIGHTS_INSTRUMENTATIONKEY=your-app-insights-key
NEWRELIC_LICENSE_KEY=your-newrelic-key
```

### Políticas de Autorización

El sistema incluye las siguientes políticas predefinidas:

- `RequireTitular` - Solo titulares de la obra social
- `RequireBeneficiario` - Titulares y beneficiarios
- `RequireSocioActivo` - Solo socios con estado activo
- `CanManageCredentials` - Gestión de credenciales
- `CanViewFinancialInfo` - Acceso a información financiera
- `CanAccessPremiumFeatures` - Funciones premium
- `RequireAdmin` - Administradores del sistema
- `RequireOperator` - Operadores del sistema

## 📊 Monitoreo y Observabilidad

### Health Checks

La aplicación expone los siguientes endpoints de salud:

- `/health` - Estado general de la aplicación
- `/health/ready` - Readiness probe para Kubernetes
- `/health/live` - Liveness probe para Kubernetes

### Métricas

- **Application Insights**: Telemetría automática y métricas personalizadas
- **New Relic**: Monitoreo de performance y errores
- **Custom Metrics**: Métricas de negocio específicas

### Logging

Logs estructurados con múltiples destinos:

- **Console**: Logs de desarrollo
- **File**: Logs persistentes con rotación
- **Seq**: Análisis centralizado de logs
- **Application Insights**: Telemetría de logs

## 🧪 Testing

### Cobertura de Tests

- **Unitarios**: >90% cobertura de servicios de aplicación
- **Integración**: Cobertura completa de controladores
- **Seguridad**: Tests de autorización y autenticación
- **E2E**: Flujos críticos de negocio

### Ejecutar Tests

```bash
# Todos los tests con coverage
dotnet test --collect:"XPlat Code Coverage" --results-directory ./TestResults/

# Solo tests unitarios
dotnet test --filter Category=Unit

# Solo tests de integración
dotnet test --filter Category=Integration
```

## 🚀 Despliegue

### Ambientes

1. **Development**: Desarrollo local con servicios mock
2. **Staging**: Ambiente de pruebas con servicios reales
3. **Production**: Ambiente productivo con alta disponibilidad

### CI/CD Pipeline

El pipeline automatizado incluye:

1. **Build & Test**: Compilación y ejecución de tests
2. **Security Scan**: Análisis de vulnerabilidades
3. **Code Quality**: Análisis estático de código
4. **Deploy Staging**: Despliegue automático a staging
5. **Deploy Production**: Despliegue manual a producción

## 📖 Documentación Adicional

- [Guía de Desarrollo](docs/DEVELOPMENT.md)
- [API Reference](docs/API.md)
- [Guía de Despliegue](docs/DEPLOYMENT.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Arquitectura Detallada](docs/ARCHITECTURE.md)

## 🤝 Contribución

1. Fork el proyecto
2. Crear feature branch (`git checkout -b feature/amazing-feature`)
3. Commit cambios (`git commit -m 'Add amazing feature'`)
4. Push al branch (`git push origin feature/amazing-feature`)
5. Crear Pull Request

## 📄 Licencia

Este proyecto está bajo la licencia [Licencia] - ver el archivo [LICENSE.md](LICENSE.md) para detalles.

## 👥 Equipo

- **Desarrollo**: Equipo de Desarrollo ApiMovil
- **DevOps**: Equipo de Infraestructura
- **QA**: Equipo de Quality Assurance

## 📞 Soporte

Para soporte técnico:
- **Email**: support@company.com
- **Wiki**: [Internal Wiki URL]
- **Slack**: #apimovil-support

---

**Versión**: 1.0.0  
**Última actualización**: $(date +'%Y-%m-%d')  
**Estado**: ✅ Listo para Producción