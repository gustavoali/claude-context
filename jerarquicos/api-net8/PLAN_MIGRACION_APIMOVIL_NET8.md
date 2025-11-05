# Plan de Migración ApiMovil a .NET 8

## Resumen Ejecutivo

Este documento describe el plan completo para migrar la solución **ApiMovil** desde **.NET Framework 4.7.2** a **.NET 8**, utilizando como base el template **RestApiTemplateNet8** y adaptándolo para la arquitectura de microservicios existente.

### Características del Sistema Actual
- **ApiMovil**: API Gateway/Orchestrator para plataforma de obra social/seguro médico
- **36 controladores principales** con funcionalidad completa
- **Arquitectura de Microservicios**: Sin acceso directo a BD, todo a través de BackendServices
- **Dominios de negocio**: Autorizaciones médicas, credenciales digitales, reintegros, gestión de socios, servicios financieros, red de prestadores

## Arquitectura Objetivo

### Estructura de Solución Propuesta
```
ApiMovil.NET8/
├── src/
│   ├── ApiMovil.Domain/                 # Modelos de dominio y contratos
│   │   ├── Entities/                    # Entidades de dominio
│   │   ├── Interfaces/                  # Contratos de microservicios
│   │   └── ValueObjects/                # Objetos de valor
│   │
│   ├── ApiMovil.Dto/                    # DTOs y modelos de transferencia
│   │   ├── Request/                     # DTOs de entrada
│   │   ├── Response/                    # DTOs de respuesta
│   │   └── Shared/                      # DTOs compartidos
│   │
│   ├── ApiMovil.Infrastructure/         # Acceso a microservicios
│   │   ├── HttpClients/                 # Clientes HTTP para microservicios
│   │   ├── Repositories/                # Implementaciones de repositorios
│   │   └── Configuration/               # Configuración de servicios externos
│   │
│   ├── ApiMovil.Application/            # Lógica de negocio y orquestación
│   │   ├── Services/                    # Servicios de aplicación
│   │   ├── Interfaces/                  # Contratos de servicios
│   │   └── Mappers/                     # Perfiles de AutoMapper
│   │
│   └── ApiMovil.Api/                    # Controladores y punto de entrada
│       ├── Controllers/                 # Controladores REST
│       ├── Middleware/                  # Middleware personalizado
│       ├── Filters/                     # Filtros y atributos
│       └── Configuration/               # Configuración de API
│
└── tests/                               # Proyectos de testing
    ├── ApiMovil.Api.Test/
    ├── ApiMovil.Application.Test/
    ├── ApiMovil.Infrastructure.Test/
    └── ApiMovil.Integration.Test/
```

### Adaptación para Microservicios

A diferencia del template original que usa **Dapper** para acceso a BD, ApiMovil utilizará:
- **HttpClient** con **Polly** para comunicación resiliente con microservicios
- **Repository Pattern** adaptado para llamadas HTTP
- **Circuit Breaker**, **Retry** y **Timeout** policies
- **Service Discovery** para endpoints dinámicos

## Etapas de Construcción

### **FASE 1: Preparación y Estructura Base (Semana 1-2)**

#### 1.1 Crear Estructura de Proyectos
- [ ] Copiar y adaptar proyectos del template
- [ ] Renombrar namespaces y referencias
- [ ] Actualizar archivos `.csproj` con dependencias correctas
- [ ] Crear solución `ApiMovil.sln`

#### 1.2 Configurar Dependencias Base
```xml
<!-- ApiMovil.Infrastructure.csproj -->
<PackageReference Include="Microsoft.Extensions.Http" Version="8.0.0" />
<PackageReference Include="Microsoft.Extensions.Http.Polly" Version="8.0.8" />
<PackageReference Include="Polly" Version="8.4.1" />
<PackageReference Include="Polly.Extensions.Http" Version="3.0.0" />
```

#### 1.3 Configurar Logging y Monitoreo
- [ ] Serilog con múltiples sinks
- [ ] Graylog para centralización de logs
- [ ] Health checks para microservicios
- [ ] Métricas con Application Insights

### **FASE 2: Modelos de Dominio y DTOs (Semana 3-4)**

#### 2.1 Crear Entidades de Dominio

**ApiMovil.Domain/Entities/**
```csharp
// Principales entidades identificadas
├── Autorizacion.cs              # Autorizaciones médicas
├── Credencial.cs                # Credenciales digitales
├── Socio.cs                     # Datos de socios
├── Reintegro.cs                 # Reembolsos médicos
├── Prestador.cs                 # Red de prestadores
├── Consumo.cs                   # Consumos de servicios
├── CuentaCorriente.cs           # Estados de cuenta
├── Notificacion.cs              # Sistema de notificaciones
└── Comercio.cs                  # Comercios afiliados
```

#### 2.2 Crear DTOs de Request/Response

**ApiMovil.Dto/Request/** (Ejemplos principales)
```csharp
├── Autorizaciones/
│   ├── SolicitudAutorizacionRequestDto.cs
│   ├── BuscarAutorizacionesRequestDto.cs
│   └── ActualizarAutorizacionRequestDto.cs
├── Credenciales/
│   ├── SolicitudCredencialRequestDto.cs
│   └── ValidarCredencialRequestDto.cs
├── Reintegros/
│   ├── SolicitudReintegroRequestDto.cs
│   └── BuscarReintegrosRequestDto.cs
└── [Más dominios...]
```

#### 2.3 Interfaces de Microservicios

**ApiMovil.Domain/Interfaces/**
```csharp
├── IApiCredencialesRepository.cs
├── IApiSociosRepository.cs
├── IApiAutorizacionesRepository.cs
├── IApiReintegrosRepository.cs
├── IApiCartillaRepository.cs
├── IApiComerciosRepository.cs
└── [Más interfaces...]
```

### **FASE 3: Capa de Infraestructura - Comunicación con Microservicios (Semana 5-6)**

#### 3.1 Implementar HttpClients Base
```csharp
// ApiMovil.Infrastructure/HttpClients/BaseHttpClient.cs
public abstract class BaseHttpClient
{
    protected readonly HttpClient _httpClient;
    protected readonly ILogger _logger;
    
    // Métodos comunes: GET, POST, PUT, DELETE
    // Manejo de errores y logging
    // Deserialización automática
}
```

#### 3.2 Clientes Específicos por Microservicio
```csharp
// Ejemplos de implementación
├── ApiCredencialesHttpClient.cs
├── ApiSociosHttpClient.cs  
├── ApiAutorizacionesHttpClient.cs
├── ApiReintegrosHttpClient.cs
├── ApiCartillaHttpClient.cs
└── [Más clientes...]
```

#### 3.3 Configurar Políticas de Resiliencia
```csharp
// Startup.cs - Configuración de Polly
services.AddHttpClient<IApiSociosRepository, ApiSociosHttpClient>()
    .AddPolicyHandler(GetRetryPolicy())
    .AddPolicyHandler(GetCircuitBreakerPolicy())
    .AddPolicyHandler(GetTimeoutPolicy());
```

### **FASE 4: Capa de Aplicación - Servicios de Negocio (Semana 7-8)**

#### 4.1 Crear Servicios de Aplicación
```csharp
// ApiMovil.Application/Services/
├── AutorizacionesService.cs        # Orquesta múltiples microservicios
├── CredencialesService.cs          # Lógica de credenciales digitales
├── SociosService.cs               # Gestión de datos de socios
├── ReintegrosService.cs           # Procesamiento de reintegros
├── CartillaService.cs             # Búsqueda de prestadores
└── [Más servicios...]
```

#### 4.2 Implementar Lógica de Orquestación
Ejemplo para **AutorizacionesService**:
```csharp
public async Task<AutorizacionResponseDto> SolicitudAutorizacion(
    SolicitudAutorizacionRequestDto request)
{
    // 1. Validar socio en ApiSocios
    var socio = await _apiSociosRepo.GetSocioAsync(request.NumeroSocio);
    
    // 2. Verificar cobertura en ApiCobertura
    var cobertura = await _apiCoberturaRepo.VerificarCoberturaAsync(request);
    
    // 3. Crear solicitud en ApiAutorizaciones
    var autorizacion = await _apiAutorizacionesRepo.CrearSolicitudAsync(request);
    
    // 4. Enviar notificación
    await _notificacionesRepo.EnviarNotificacionAsync(autorizacion);
    
    return _mapper.Map<AutorizacionResponseDto>(autorizacion);
}
```

### **FASE 5: Capa de API - Controladores (Semana 9-10)**

#### 5.1 Crear Controladores Base
```csharp
// ApiMovil.Api/Controllers/BaseApiController.cs
[ApiController]
[Route("api/v1/[controller]")]
public abstract class BaseApiController : ControllerBase
{
    // Funcionalidad común
    // Manejo de errores
    // Validación de tokens JWT
    // Headers de correlación
}
```

#### 5.2 Implementar Controladores Principales (Prioridad por impacto)

**Grupo 1 - ALTA PRIORIDAD (Core Business)**
```csharp
├── AutorizacionesController.cs      # 1,975 líneas → Crítico para negocio
├── CredencialesController.cs        # 2,191 líneas → Credenciales digitales
├── ReintegrosController.cs          # 1,646 líneas → Reembolsos médicos
└── PerfilSocioController.cs         # 1,326 líneas → Gestión de usuarios
```

**Grupo 2 - MEDIA PRIORIDAD (Support Services)**
```csharp
├── CartillaController.cs            # 1,274 líneas → Red de prestadores
├── CuentaCorrienteController.cs     # 1,395 líneas → Estados financieros
├── DatosPersonalesController.cs     # 1,052 líneas → Datos personales
└── SolicitudController.cs           # 1,134 líneas → Gestión solicitudes
```

**Grupo 3 - BAJA PRIORIDAD (Auxiliary Services)**
```csharp
├── NotificacionesController.cs      # 245 líneas → Push notifications
├── ComerciosController.cs           # 321 líneas → Comercios afiliados
├── RecetaElectronicaController.cs   # 233 líneas → Recetas digitales
└── [Resto de controladores...]
```

### **FASE 6: Autenticación y Seguridad (Semana 11)**

#### 6.1 Migrar Sistema de Autenticación
- [ ] JWT Bearer authentication con .NET 8
- [ ] Configurar Identity Server o Auth0
- [ ] Migrar claims y roles existentes
- [ ] Implementar refresh tokens

#### 6.2 Configurar Seguridad
```csharp
// Program.cs
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options => {
        // Configuración JWT
    });

builder.Services.AddAuthorization(options => {
    // Políticas de autorización
});
```

### **FASE 7: Testing y Validación (Semana 12-13)**

#### 7.1 Tests Unitarios
- [ ] Services de Application (lógica de negocio)
- [ ] HttpClients (mocking de microservicios)
- [ ] Controladores (validación de endpoints)

#### 7.2 Tests de Integración
- [ ] Comunicación end-to-end con microservicios
- [ ] Validación de flujos completos
- [ ] Performance testing

#### 7.3 Tests de Carga
- [ ] Stress testing de endpoints críticos
- [ ] Validación de políticas de resiliencia
- [ ] Monitoreo de memoria y CPU

### **FASE 8: Despliegue y Monitoreo (Semana 14)**

#### 8.1 Configuración de Entornos
- [ ] Configuraciones por ambiente (Dev, Test, Staging, Production)
- [ ] Secrets management con Azure Key Vault
- [ ] Variables de entorno para endpoints de microservicios

#### 8.2 CI/CD Pipeline
```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
    - develop
    - main

stages:
- stage: Build
  jobs:
  - job: BuildAndTest
    steps:
    - task: DotNetCoreCLI@2
      inputs:
        command: 'build'
        projects: '**/*.csproj'
    - task: DotNetCoreCLI@2
      inputs:
        command: 'test'
        projects: '**/*Test.csproj'

- stage: Deploy
  dependsOn: Build
  jobs:
  - deployment: DeployToAzure
    environment: 'production'
```

## Consideraciones Técnicas Importantes

### Comunicación con Microservicios

#### 1. **Configuración de HttpClients**
```json
// appsettings.json
{
  "MicroservicesEndpoints": {
    "ApiSocios": "https://api-socios.example.com",
    "ApiCredenciales": "https://api-credenciales.example.com",
    "ApiAutorizaciones": "https://api-autorizaciones.example.com"
  },
  "ResiliencePolicies": {
    "RetryAttempts": 3,
    "CircuitBreakerThreshold": 5,
    "TimeoutSeconds": 30
  }
}
```

#### 2. **Manejo de Errores Distribuidos**
- Logging correlacionado con X-Correlation-ID
- Circuit breaker para servicios degradados
- Fallback responses para servicios no críticos
- Health checks para monitoreo de dependencias

#### 3. **Performance y Caching**
- Response caching para datos poco cambiantes
- Memory caching para lookups frecuentes
- Distributed caching con Redis para datos compartidos

### Migración de Funcionalidad Específica

#### **Autenticación JWT**
- Mantener compatibilidad con tokens existentes
- Migración gradual de claims y roles
- Implementar refresh token rotation

#### **Manejo de Archivos**
- Mantener integración con DigitalFile
- Upload de documentos para autorizaciones y reintegros
- Generación de PDFs para credenciales

#### **Notificaciones Push**
- Migrar GCM a Firebase Cloud Messaging
- Mantener compatibilidad con apps móviles existentes

## Cronograma de Entrega

| Fase | Duración | Entregables | Responsable |
|------|----------|-------------|-------------|
| **Fase 1** | 2 semanas | Estructura base, configuración inicial | Dev Team |
| **Fase 2** | 2 semanas | Modelos de dominio, DTOs completos | Dev Team |
| **Fase 3** | 2 semanas | HttpClients, políticas de resiliencia | Dev Team |
| **Fase 4** | 2 semanas | Servicios de aplicación principales | Dev Team |
| **Fase 5** | 2 semanas | Controladores críticos (Grupo 1 y 2) | Dev Team |
| **Fase 6** | 1 semana | Autenticación y seguridad | Dev Team |
| **Fase 7** | 2 semanas | Testing completo, validación | QA + Dev |
| **Fase 8** | 1 semana | Deploy, monitoreo, documentación | DevOps + Dev |

**Total: 14 semanas (3.5 meses)**

## Riesgos y Mitigaciones

### Riesgos Técnicos
1. **Incompatibilidad de versiones de microservicios**
   - *Mitigación*: Versionado de APIs, backward compatibility

2. **Performance degradation**
   - *Mitigación*: Load testing, optimization de queries

3. **Cambios en contratos de microservicios**
   - *Mitigación*: Integration testing, contract testing

### Riesgos de Negocio
1. **Downtime durante migración**
   - *Mitigación*: Blue-green deployment, rollback plan

2. **Pérdida de funcionalidad**
   - *Mitigación*: Feature parity testing, user acceptance testing

## Métricas de Éxito

### Técnicas
- **Performance**: Response time < 2s para 95% de requests
- **Reliability**: 99.9% uptime
- **Scalability**: Soportar 10x carga actual

### Negocio
- **Zero data loss** durante migración
- **100% feature parity** con sistema actual
- **Improved developer experience** con .NET 8

---

## Conclusión

Este plan proporciona una ruta clara y estructurada para migrar ApiMovil a .NET 8, manteniendo la arquitectura de microservicios existente y mejorando significativamente la mantenibilidad, performance y escalabilidad del sistema.

La migración se realizará de forma incremental, priorizando los controladores más críticos para el negocio y asegurando que no haya interrupción del servicio durante el proceso.