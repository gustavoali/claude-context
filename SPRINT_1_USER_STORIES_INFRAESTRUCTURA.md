# User Stories de Infraestructura - Sprint 1

**Objetivo:** Formalizar las tareas de infraestructura como User Stories con Acceptance Criteria y Definition of Done para poder ser estimadas y planificadas correctamente en el Sprint.

---

## 🐳 US-048: Contenedorización con Docker y Docker Compose

**Como** DevOps Engineer / Developer
**Quiero** contenedorizar la aplicación con Docker
**Para** garantizar consistencia entre entornos de desarrollo, testing, staging y producción

**Story Points:** 13
**Prioridad:** MUST HAVE
**Epic:** DevOps & Testing Infrastructure
**Dependencias:** US-003 (API REST Base debe existir)

---

### Acceptance Criteria

#### AC-048.1: Dockerfile Multi-Stage Optimizado
```gherkin
Given que necesito un Dockerfile production-ready
When creo el Dockerfile
Then debe tener:
  - Stage 1: Build (mcr.microsoft.com/dotnet/sdk:8.0-alpine)
  - Stage 2: Publish (optimización de artifacts)
  - Stage 3: Runtime (mcr.microsoft.com/dotnet/aspnet:8.0-alpine)
  - Non-root user (appuser)
  - Health check integrado
  - Variables de ambiente configurables
And la imagen final debe ser <150MB
And debe cachear correctamente las layers de restore
```

**Ejemplo esperado:**
```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build
WORKDIR /src
COPY *.sln .
COPY src/**/*.csproj ./src/
RUN dotnet restore
# ... resto del Dockerfile
```

---

#### AC-048.2: Docker Compose para Development
```gherkin
Given que necesito levantar el stack completo localmente
When ejecuto `docker-compose up -d`
Then debe levantar:
  - Servicio API (.NET 8)
  - MySQL 8.0.35 con puerto 3306 expuesto
  - Redis 7.2-alpine con puerto 6379 expuesto
  - Seq (logging) con puerto 5341 expuesto
And todos los servicios deben tener health checks
And debe usar volumes para persistencia de datos
And debe usar networks para aislamiento
```

**docker-compose.yml esperado:**
```yaml
services:
  api:
    build: .
    ports: ["5000:8080"]
    depends_on:
      mysql: { condition: service_healthy }
    environment:
      - ConnectionStrings__DefaultConnection=Server=mysql;...
  mysql:
    image: mysql:8.0.35
    healthcheck: {...}
  redis:
    image: redis:7.2-alpine
  seq:
    image: datalust/seq:2024.1
```

---

#### AC-048.3: Docker Compose Overrides por Ambiente
```gherkin
Given diferentes ambientes (dev, staging, prod)
When necesito configurar específicamente cada ambiente
Then debo crear:
  - docker-compose.yml (base, commiteado)
  - docker-compose.override.yml (development, auto-loaded, commiteado)
  - docker-compose.staging.yml (staging config, commiteado)
  - docker-compose.prod.yml (production config, commiteado)
And cada override debe tener configuraciones específicas de:
  - Environment variables
  - Logging levels
  - Resource limits (cpu, memory)
  - Restart policies
```

---

#### AC-048.4: Scripts de Utilidad
```gherkin
Given que el equipo necesita comandos simplificados
When creo scripts de utilidad
Then debo crear:
  - scripts/docker-build.sh → Build de imagen
  - scripts/docker-up.sh → Levantar stack en dev
  - scripts/docker-up-staging.sh → Levantar en staging
  - scripts/docker-logs.sh → Ver logs de todos los servicios
  - scripts/docker-migrate.sh → Ejecutar migrations
  - scripts/docker-clean.sh → Limpiar containers y volumes
And todos los scripts deben tener permisos de ejecución (chmod +x)
And deben funcionar en Linux, macOS y Windows (Git Bash)
```

---

#### AC-048.5: Validación de Consistencia de Versiones
```gherkin
Given que necesito garantizar consistencia entre entornos
When reviso las versiones de dependencias
Then debo validar:
  - Dockerfile usa .NET 8.0 (versión específica)
  - docker-compose usa MySQL 8.0.35 (versión exacta, NO :latest)
  - docker-compose usa Redis 7.2-alpine (versión exacta)
  - docker-compose usa Seq 2024.1 (versión exacta)
  - .github/workflows usa mismas versiones en CI
And debe documentarse en ESTRATEGIA_ENTORNOS_CONSISTENTES.md
```

---

#### AC-048.6: Documentación de Docker Setup
```gherkin
Given que nuevos developers necesitan levantar el ambiente
When lean la documentación
Then debe incluir:
  - README.md con sección "Getting Started with Docker"
  - Prerrequisitos (Docker Desktop instalado)
  - Comandos básicos (up, down, logs, exec)
  - Troubleshooting común
  - Cómo ejecutar migrations en container
  - Cómo acceder a MySQL desde host
And debe incluir capturas de pantalla o GIFs
```

---

### Definition of Done

**Código:**
- [ ] Dockerfile multi-stage creado y optimizado
- [ ] docker-compose.yml base creado con los 4 servicios
- [ ] docker-compose.override.yml (dev) creado
- [ ] docker-compose.staging.yml creado
- [ ] docker-compose.prod.yml creado
- [ ] .dockerignore configurado correctamente

**Scripts:**
- [ ] 6 scripts de utilidad creados en /scripts/
- [ ] Permisos de ejecución configurados
- [ ] Scripts probados en Linux y Windows

**Testing:**
- [ ] `docker-compose build` ejecuta correctamente
- [ ] `docker-compose up -d` levanta todos los servicios
- [ ] Health checks de todos los servicios pasan
- [ ] API responde en http://localhost:5000/health
- [ ] Swagger accesible en http://localhost:5000/swagger
- [ ] MySQL accesible desde host en localhost:3306
- [ ] Seq accesible en http://localhost:5341
- [ ] Probado en Windows, Linux y macOS

**Documentación:**
- [ ] README.md actualizado con sección Docker
- [ ] Comandos documentados con ejemplos
- [ ] Troubleshooting guide publicado
- [ ] Variables de ambiente documentadas

**Code Review:**
- [ ] Pull Request creado
- [ ] Revisado por Tech Lead
- [ ] Aprobado por al menos 1 developer

**Demo:**
- [ ] Demo funcionando en laptop del developer
- [ ] Demostrado al equipo en Daily Standup

---

### Technical Notes

#### Estructura de Archivos:
```
/
├── Dockerfile
├── .dockerignore
├── docker-compose.yml
├── docker-compose.override.yml
├── docker-compose.staging.yml
├── docker-compose.prod.yml
├── scripts/
│   ├── docker-build.sh
│   ├── docker-up.sh
│   ├── docker-up-staging.sh
│   ├── docker-logs.sh
│   ├── docker-migrate.sh
│   └── docker-clean.sh
└── README.md
```

#### .dockerignore:
```
# Build outputs
**/bin/
**/obj/
**/publish/

# IDE
.vs/
.vscode/
.idea/

# Git
.git/
.gitignore

# Docs
*.md
!README.md

# Tests
**/tests/

# Logs
**/logs/
```

#### Comando de Test:
```bash
# Test completo
./scripts/docker-build.sh && \
./scripts/docker-up.sh && \
sleep 30 && \
curl http://localhost:5000/health && \
./scripts/docker-migrate.sh && \
./scripts/docker-logs.sh api
```

---

## 🔄 US-049: Pipeline CI/CD con GitHub Actions

**Como** DevOps Engineer
**Quiero** automatizar build, test, y deployment con GitHub Actions
**Para** garantizar calidad del código y despliegues rápidos y seguros

**Story Points:** 13
**Prioridad:** MUST HAVE
**Epic:** DevOps & Testing Infrastructure
**Dependencias:** US-048 (Docker), US-045 (Tests Automatizados - o crear placeholder)

---

### Acceptance Criteria

#### AC-049.1: Workflow de Continuous Integration (CI)
```gherkin
Given un commit pusheado a cualquier branch
When GitHub Actions ejecuta el workflow CI
Then debe ejecutar los siguientes jobs:
  - Setup: Checkout code, Setup .NET 8.0.101
  - Restore: Restore NuGet dependencies
  - Build: Build solution en Release mode
  - Test: Run unit tests con coverage report
  - Code Quality: Upload coverage a SonarCloud
  - Validate: Fail si coverage <90% o tests fallan
And debe completar en <10 minutos
And debe cachear dependencies para velocidad
```

**Workflow esperado:**
```yaml
name: CI
on: [push, pull_request]
jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '8.0.x'
      - run: dotnet restore
      - run: dotnet build --no-restore
      - run: dotnet test --no-build --verbosity normal
```

---

#### AC-049.2: Docker Build en CI
```gherkin
Given un commit en branch main o develop
When el workflow de CI pasa exitosamente
Then debe ejecutar job de Docker Build:
  - Build Docker image usando el Dockerfile
  - Tag con SHA del commit (ej: erp-api:sha-abc123)
  - Tag con nombre de branch (ej: erp-api:main)
  - Push a Docker Hub (o GitHub Container Registry)
  - Usar cache de GitHub Actions para layers
And debe completar en <5 minutos
```

---

#### AC-049.3: Deployment Automático a Staging
```gherkin
Given un merge a branch develop
When el Docker image está pusheado
Then debe ejecutar job de Deploy to Staging:
  - Conectarse al servidor Staging vía SSH
  - Hacer pull del nuevo Docker image
  - Ejecutar docker-compose up -d con override de staging
  - Ejecutar migrations automáticamente
  - Esperar 30 segundos para warmup
  - Ejecutar smoke tests (curl /health, curl /api/v1/health)
  - Notificar resultado en Slack
And debe fallar el deployment si smoke tests fallan
And debe hacer rollback automático si falla
```

---

#### AC-049.4: Manual Approval para Production
```gherkin
Given un merge a branch main
When el Docker image está pusheado
Then debe:
  - Esperar manual approval en GitHub Environments
  - Notificar en Slack que hay deployment pendiente
  - Mostrar diff de cambios desde último deploy
And solo Tech Lead o Product Owner pueden aprobar
And tiene timeout de 7 días (luego cancela)
```

---

#### AC-049.5: Deployment a Production
```gherkin
Given manual approval aprobado
When se ejecuta job de Deploy to Production
Then debe:
  - Conectarse al servidor Production vía SSH
  - Hacer pull del Docker image EXACTO que pasó staging
  - Ejecutar docker-compose up -d --no-deps api (solo API, no DB)
  - Ejecutar migrations con backup previo
  - Esperar 30 segundos
  - Ejecutar smoke tests
  - Si falla: Rollback al tag anterior
  - Si pasa: Notificar en Slack con link al release
```

---

#### AC-049.6: Security y Secrets Management
```gherkin
Given que el pipeline necesita acceso a recursos
When se configuran secrets
Then debe tener en GitHub Secrets:
  - DOCKER_USERNAME, DOCKER_PASSWORD
  - STAGING_HOST, STAGING_USER, STAGING_SSH_KEY
  - PROD_HOST, PROD_USER, PROD_SSH_KEY
  - SONAR_TOKEN
  - SLACK_WEBHOOK
And NINGÚN secret debe estar hardcodeado en el workflow
And debe usar GitHub Environments para staging/production
```

---

#### AC-049.7: Notificaciones y Observabilidad
```gherkin
Given que un workflow se ejecuta
When completa (éxito o fallo)
Then debe:
  - Notificar en Slack con status y link al workflow
  - Incluir información relevante (branch, commit, author)
  - Si falla: Incluir logs del paso que falló
  - Si deploy a prod: Incluir release notes
And debe crear GitHub Release automáticamente en deploys a main
```

---

### Definition of Done

**Workflows:**
- [ ] `.github/workflows/ci.yml` creado y funcional
- [ ] `.github/workflows/deploy-staging.yml` creado
- [ ] `.github/workflows/deploy-production.yml` creado
- [ ] Workflows probados en branch de prueba

**GitHub Configuration:**
- [ ] Secrets configurados en GitHub
- [ ] Environments creados (staging, production)
- [ ] Protection rules configuradas (main branch)
- [ ] Manual approval configurado para production

**Integration:**
- [ ] SonarCloud project creado y configurado
- [ ] Slack webhook configurado
- [ ] Docker Hub repository creado

**Testing:**
- [ ] Pipeline CI ejecutado exitosamente en al menos 5 commits
- [ ] Docker build exitoso y pusheado
- [ ] Deployment a staging exitoso
- [ ] Smoke tests pasando en staging
- [ ] Manual approval testeado

**Documentación:**
- [ ] README.md sección "CI/CD Pipeline"
- [ ] Diagrama de flujo del pipeline
- [ ] Runbook de rollback documentado
- [ ] Troubleshooting de CI/CD

**Code Review:**
- [ ] PR aprobado por Tech Lead
- [ ] Revisado por al menos 2 developers

---

### Technical Notes

#### Estructura de Workflows:
```
.github/
└── workflows/
    ├── ci.yml                 # CI en cada push
    ├── deploy-staging.yml     # Deploy automático a staging
    ├── deploy-production.yml  # Deploy manual a prod
    └── cleanup.yml            # Limpieza de artifacts viejos
```

#### Ejemplo de Job con Services:
```yaml
jobs:
  integration-tests:
    runs-on: ubuntu-latest
    services:
      mysql:
        image: mysql:8.0.35
        env:
          MYSQL_ROOT_PASSWORD: test_password
          MYSQL_DATABASE: erp_test
        options: >-
          --health-cmd="mysqladmin ping"
          --health-interval=10s
```

---

## 🌐 US-050: Setup de Entorno Staging y Monitoring Básico

**Como** DevOps Engineer
**Quiero** provisionar y configurar el entorno de Staging con monitoring
**Para** tener un ambiente de pre-producción que replique producción y detectar problemas temprano

**Story Points:** 13
**Prioridad:** MUST HAVE
**Epic:** DevOps & Testing Infrastructure
**Dependencias:** US-048 (Docker), US-049 (CI/CD)

---

### Acceptance Criteria

#### AC-050.1: Provisionar Servidor de Staging
```gherkin
Given que necesito un servidor para Staging
When provisiono la infraestructura
Then debe:
  - Crear VM en cloud provider (AWS EC2, Azure VM, o DigitalOcean Droplet)
  - Especificaciones: 4GB RAM, 2 vCPUs, 50GB SSD (mínimo)
  - Ubuntu 22.04 LTS
  - Firewall configurado (solo puertos 80, 443, 22)
  - IP estática asignada
  - DNS configurado (staging-api.erp.example.com)
And debe documentarse en terraform/cloudformation (Infrastructure as Code)
```

---

#### AC-050.2: Configurar Servidor Staging
```gherkin
Given un servidor Ubuntu recién provisionado
When configuro el servidor
Then debe tener instalado:
  - Docker Engine (última versión estable)
  - Docker Compose v2
  - Git
  - Nginx (reverse proxy)
  - Certbot (SSL/TLS con Let's Encrypt)
  - UFW (firewall) configurado
And debe tener:
  - Usuario non-root para deployments (deploy)
  - SSH keys configuradas (no passwords)
  - Automatic security updates habilitado
```

---

#### AC-050.3: Configurar Nginx como Reverse Proxy
```gherkin
Given que la API corre en Docker puerto 8080
When configuro Nginx
Then debe:
  - Proxear requests de puerto 80/443 a localhost:8080
  - Configurar SSL/TLS con Let's Encrypt
  - Auto-renovación de certificados
  - Headers de seguridad (HSTS, X-Frame-Options, etc.)
  - Timeouts apropiados (60s)
  - Request size limit (10MB)
  - Logging de access y errors
And debe responder en https://staging-api.erp.example.com
```

**nginx.conf esperado:**
```nginx
server {
    listen 443 ssl http2;
    server_name staging-api.erp.example.com;

    ssl_certificate /etc/letsencrypt/live/.../fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/.../privkey.pem;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

---

#### AC-050.4: Setup de Base de Datos Staging
```gherkin
Given que necesito una base de datos para Staging
When configuro MySQL
Then debe:
  - MySQL 8.0.35 corriendo en Docker
  - Volume persistente en /opt/mysql-data
  - Backup automático diario a S3/Azure Blob
  - Retention de 7 días
  - Acceso solo desde localhost (no expuesto)
  - Usuario y password en secrets (no hardcodeado)
And debe tener datos de seed similar a producción (pero ofuscados)
```

---

#### AC-050.5: Health Checks y Uptime Monitoring
```gherkin
Given que necesito monitorear la disponibilidad de Staging
When configuro monitoring
Then debe:
  - UptimeRobot (o Pingdom) monitoreando /health cada 5 minutos
  - Alertas por email/Slack si API cae
  - Dashboard público de status
  - SLA target: 95% uptime
And debe monitorear:
  - https://staging-api.erp.example.com/health → 200 OK
  - Latencia <1s
```

---

#### AC-050.6: Logging Centralizado
```gherkin
Given que necesito ver logs de todos los servicios
When configuro logging
Then debe:
  - Seq corriendo en Docker (puerto 5341)
  - API enviando logs estructurados a Seq
  - Nginx logs parseados y enviados a Seq
  - MySQL slow query log monitoreado
  - Retention de logs: 30 días
And debe ser accesible en https://staging-logs.erp.example.com
And debe tener autenticación (usuario/password)
```

---

#### AC-050.7: Backup y Disaster Recovery
```gherkin
Given que necesito proteger datos de Staging
When configuro backups
Then debe:
  - Backup diario de MySQL a S3/Azure Blob
  - Backup semanal de todo el server (snapshot)
  - Backup de volumes de Docker
  - Script de restore probado y documentado
  - RTO (Recovery Time Objective): <4 horas
  - RPO (Recovery Point Objective): <24 horas
And debe tener runbook de disaster recovery
```

---

### Definition of Done

**Infraestructura:**
- [ ] Servidor provisionado en cloud provider
- [ ] DNS configurado y resolviendo correctamente
- [ ] SSH acceso configurado (keys, no passwords)
- [ ] Firewall (UFW) configurado

**Software:**
- [ ] Docker y Docker Compose instalados
- [ ] Nginx configurado como reverse proxy
- [ ] SSL/TLS funcionando (Let's Encrypt)
- [ ] MySQL 8.0.35 corriendo en container

**Deployment:**
- [ ] GitHub Actions puede deployar a Staging exitosamente
- [ ] docker-compose.staging.yml corriendo
- [ ] Migrations aplicadas
- [ ] API accesible en https://staging-api.erp.example.com

**Monitoring:**
- [ ] UptimeRobot monitoreando /health
- [ ] Alertas configuradas en Slack
- [ ] Seq accesible para logs
- [ ] Metrics básicos visibles

**Backups:**
- [ ] Backup automático de MySQL configurado
- [ ] Backup testeado (restore exitoso)
- [ ] Runbook de disaster recovery escrito

**Testing:**
- [ ] Smoke tests pasando en Staging
- [ ] Performance test básico (500 requests/min)
- [ ] SSL Labs grade A o superior

**Documentación:**
- [ ] README con sección "Environments"
- [ ] Runbook de deployment a Staging
- [ ] Runbook de rollback
- [ ] Runbook de disaster recovery
- [ ] Inventario de infraestructura actualizado

**Code Review:**
- [ ] Scripts de provisioning revisados
- [ ] Configuraciones de nginx revisadas
- [ ] Aprobado por Tech Lead

---

### Technical Notes

#### Terraform Example (AWS):
```hcl
resource "aws_instance" "staging" {
  ami           = "ami-ubuntu-22.04"
  instance_type = "t3.medium"

  tags = {
    Name        = "erp-staging"
    Environment = "staging"
  }

  vpc_security_group_ids = [aws_security_group.staging.id]
}

resource "aws_security_group" "staging" {
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

#### Backup Script:
```bash
#!/bin/bash
# /opt/scripts/backup-mysql.sh
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
docker exec erp-mysql mysqldump -u root -p$MYSQL_ROOT_PASSWORD erp_staging > /tmp/backup_$TIMESTAMP.sql
aws s3 cp /tmp/backup_$TIMESTAMP.sql s3://erp-backups-staging/
rm /tmp/backup_$TIMESTAMP.sql
```

---

## 📊 Resumen de User Stories de Infraestructura

| US ID | User Story | Story Points | Epic |
|-------|-----------|--------------|------|
| US-048 | Contenedorización con Docker | 13 | DevOps & Testing |
| US-049 | Pipeline CI/CD con GitHub Actions | 13 | DevOps & Testing |
| US-050 | Setup Entorno Staging + Monitoring | 13 | DevOps & Testing |
| **TOTAL** | **3 User Stories** | **39 pts** | |

---

## 🎯 Integración con Sprint 1

### Propuesta: Sprint 1 Ajustado

**Original Sprint 1:**
- US-001: Multi-Tenancy (8 pts)
- US-002: Base de Datos (13 pts)
- US-003: API REST Base (8 pts)
- US-007: Currency API (5 pts)
- **Total:** 34 pts

**Sprint 1 Completo con Infraestructura:**
- US-001: Multi-Tenancy (8 pts)
- US-002: Base de Datos (13 pts)
- US-003: API REST Base (8 pts)
- US-007: Currency API (5 pts)
- **US-048: Docker** (13 pts)
- **TOTAL:** **47 pts**

**Recomendación:** Mover US-049 y US-050 a Sprint 2, porque 47 pts es manejable pero 73 pts sería sobrecarga.

---

### Opción Alternativa: Sprint Dedicado a Infraestructura

**Sprint 0 (Pre-Sprint de Infraestructura):**
- US-048: Docker (13 pts)
- US-049: CI/CD (13 pts)
- US-050: Staging Setup (13 pts)
- **Total:** 39 pts
- **Duración:** 1 semana (sprint corto)

**Ventajas:**
- ✅ Infraestructura lista antes de desarrollo
- ✅ Developers pueden empezar con ambiente completo
- ✅ CI/CD desde el primer commit

**Desventajas:**
- ⚠️ Requiere 1 semana extra
- ⚠️ Necesita algo de código base para testear (puede usar API "Hello World")

---

## 🔗 Actualización del Product Backlog

Estas 3 User Stories deben agregarse al Product Backlog principal (PRODUCT_BACKLOG_ERP_PARTE_4.md) en el Epic 9: DevOps & Testing Infrastructure.

**Epic 9 Actualizado:**
- US-044: Pipeline CI/CD básico (ya existía, ahora es US-049 con más detalle)
- US-045: Tests Automatizados (ya existía)
- US-046: Observabilidad (ya existía)
- **US-048: Contenedorización Docker** (NUEVO)
- **US-050: Staging Setup** (NUEVO, antes era parte de US-044)

---

## ✅ Next Steps

1. **Decidir:** ¿Sprint 0 dedicado a infra, o integrar en Sprint 1?
2. **Actualizar:** Product Backlog con estas 3 US formales
3. **Estimar:** Revisar estimaciones con el equipo
4. **Planificar:** Sprint Planning con todas las US incluidas

¿Prefieres que actualice el SPRINT_1_BACKLOG.md con estas User Stories formales?
