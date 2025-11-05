# Estrategia de Entornos Consistentes - ERP Multinacional

**Versión:** 1.0
**Fecha:** 2025-10-11
**Objetivo:** Garantizar paridad entre Development, Testing, Staging y Production para minimizar issues causados por diferencias ambientales

---

## 🎯 Principio Fundamental: Dev/Prod Parity

> **"El mismo código, las mismas dependencias, la misma configuración, el mismo comportamiento - en todos los entornos."**

**Basado en [12-Factor App - Factor X: Dev/prod parity](https://12factor.net/dev-prod-parity)**

### Gaps a Minimizar:

| Gap | Descripción | Solución |
|-----|-------------|----------|
| **Time Gap** | Código escrito hace semanas va a producción | CI/CD continuo, deploys frecuentes |
| **Personnel Gap** | Developers escriben, ops deploya | DevOps culture, developers deployean |
| **Tools Gap** | SQLite en dev, MySQL en prod | **Docker - Mismo stack en todos lados** |

---

## 🏗️ Arquitectura de Entornos

### Diagrama de Flujo

```
┌─────────────────┐
│  LOCAL DEV      │  ← Developer laptop
│  Docker Compose │     - .NET 8 en container
│  MySQL 8.0      │     - MySQL 8.0 en container
│  Redis          │     - Redis en container
└────────┬────────┘
         │ git push
         ↓
┌─────────────────┐
│  CI (GitHub     │  ← GitHub Actions
│  Actions)       │     - Build en Docker
│  Docker Build   │     - Tests en Docker
│  Run Tests      │     - Same image para todos
└────────┬────────┘
         │ merge to main
         ↓
┌─────────────────┐
│  STAGING        │  ← Pre-production
│  Docker Deploy  │     - Mismo Docker image de CI
│  MySQL 8.0      │     - MySQL 8.0 (misma versión)
│  Redis          │     - Config similar a Prod
└────────┬────────┘
         │ manual approval
         ↓
┌─────────────────┐
│  PRODUCTION     │  ← Production
│  Docker Deploy  │     - EXACTAMENTE mismo image
│  MySQL 8.0      │     - MySQL 8.0 (misma versión)
│  Redis          │     - Misma config que Staging
└─────────────────┘
```

---

## 🐳 Estrategia 1: Contenedorización con Docker

### 1.1. Docker como Garantía de Consistencia

**Principio:**
> "Si funciona en el container de desarrollo, funcionará en el container de producción"

#### Dockerfile Multi-Stage (Producción)

```dockerfile
# syntax=docker/dockerfile:1
# ==================================
# Stage 1: Build
# ==================================
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build
WORKDIR /src

# Copy solution and project files
COPY *.sln .
COPY src/Domain/*.csproj ./src/Domain/
COPY src/Application/*.csproj ./src/Application/
COPY src/Infrastructure/*.csproj ./src/Infrastructure/
COPY src/API/*.csproj ./src/API/

# Restore dependencies (cached layer)
RUN dotnet restore

# Copy source code
COPY src/ ./src/

# Build
WORKDIR /src/API
RUN dotnet build -c Release -o /app/build --no-restore

# ==================================
# Stage 2: Publish
# ==================================
FROM build AS publish
RUN dotnet publish -c Release -o /app/publish --no-restore \
    /p:UseAppHost=false

# ==================================
# Stage 3: Runtime
# ==================================
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS runtime

# Install dependencies for MySQL and timezone data
RUN apk add --no-cache \
    icu-libs \
    tzdata

# Create non-root user for security
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

WORKDIR /app

# Copy published app
COPY --from=publish /app/publish .

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# Environment variables (overridable)
ENV ASPNETCORE_ENVIRONMENT=Production \
    ASPNETCORE_URLS=http://+:8080 \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

# Entry point
ENTRYPOINT ["dotnet", "ERP.API.dll"]
```

**Ventajas de este Dockerfile:**
- ✅ Multi-stage build (imagen final pequeña ~120MB)
- ✅ Alpine Linux (seguro y ligero)
- ✅ Non-root user (security)
- ✅ Health check integrado
- ✅ Cachea dependencias (restore layer)
- ✅ Mismo Dockerfile para todos los entornos

---

### 1.2. Docker Compose para Development

```yaml
# docker-compose.yml
version: '3.8'

services:
  # ==================================
  # API Service
  # ==================================
  api:
    build:
      context: .
      dockerfile: Dockerfile
      target: runtime
    container_name: erp-api
    ports:
      - "5000:8080"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ConnectionStrings__DefaultConnection=Server=mysql;Database=erp_dev;User=root;Password=dev_password_123;
      - ConnectionStrings__Redis=redis:6379
      - CurrencyApi__BaseUrl=https://api.exchangerate-api.com/v4/latest/
      - Jwt__Secret=super_secret_dev_key_change_in_production_min_32_chars
      - Jwt__Issuer=erp-api-dev
      - Jwt__Audience=erp-client-dev
      - Serilog__MinimumLevel__Default=Debug
    depends_on:
      mysql:
        condition: service_healthy
      redis:
        condition: service_started
    networks:
      - erp-network
    volumes:
      - ./logs:/app/logs  # Logs persistentes
    restart: unless-stopped

  # ==================================
  # MySQL Database
  # ==================================
  mysql:
    image: mysql:8.0.35  # Version EXACTA (no usar :latest)
    container_name: erp-mysql
    ports:
      - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: dev_password_123
      MYSQL_DATABASE: erp_dev
      MYSQL_USER: erp_user
      MYSQL_PASSWORD: erp_pass_123
      TZ: UTC
    volumes:
      - mysql-data:/var/lib/mysql  # Datos persistentes
      - ./scripts/mysql/init.sql:/docker-entrypoint-initdb.d/init.sql:ro
    command:
      - --character-set-server=utf8mb4
      - --collation-server=utf8mb4_unicode_ci
      - --default-time-zone=+00:00
      - --max_connections=200
      - --innodb_buffer_pool_size=256M
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - erp-network
    restart: unless-stopped

  # ==================================
  # Redis Cache
  # ==================================
  redis:
    image: redis:7.2-alpine  # Version EXACTA
    container_name: erp-redis
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes --requirepass redis_dev_pass
    volumes:
      - redis-data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5
    networks:
      - erp-network
    restart: unless-stopped

  # ==================================
  # Seq (Structured Logging)
  # ==================================
  seq:
    image: datalust/seq:2024.1  # Version EXACTA
    container_name: erp-seq
    ports:
      - "5341:80"  # UI
      - "5342:5341"  # Ingestion
    environment:
      ACCEPT_EULA: Y
    volumes:
      - seq-data:/data
    networks:
      - erp-network
    restart: unless-stopped

  # ==================================
  # Hangfire Dashboard (Background Jobs)
  # ==================================
  # Comentado porque Hangfire corre dentro de la API
  # Descomentar si quieres un dashboard separado

# ==================================
# Networks
# ==================================
networks:
  erp-network:
    driver: bridge

# ==================================
# Volumes (Datos Persistentes)
# ==================================
volumes:
  mysql-data:
    driver: local
  redis-data:
    driver: local
  seq-data:
    driver: local
```

**Docker Compose Override para diferentes entornos:**

```yaml
# docker-compose.override.yml (Development - auto-loaded)
version: '3.8'

services:
  api:
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - Serilog__MinimumLevel__Default=Debug
    volumes:
      - ./src:/src:cached  # Hot reload (opcional)
```

```yaml
# docker-compose.staging.yml
version: '3.8'

services:
  api:
    environment:
      - ASPNETCORE_ENVIRONMENT=Staging
      - Serilog__MinimumLevel__Default=Information
    # NO volumes de código fuente
```

```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  api:
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - Serilog__MinimumLevel__Default=Warning
    restart: always
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
```

---

### 1.3. Comandos Docker Compose por Entorno

```bash
# Development (local)
docker-compose up -d

# Staging
docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d

# Production
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Rebuild después de cambios
docker-compose up -d --build

# Ver logs
docker-compose logs -f api

# Ejecutar migrations
docker-compose exec api dotnet ef database update

# Acceder al container
docker-compose exec api sh
```

---

## 🔧 Estrategia 2: Configuration Management

### 2.1. Jerarquía de Configuración

**Orden de precedencia (menor a mayor):**
1. `appsettings.json` (base, commiteado)
2. `appsettings.{Environment}.json` (por ambiente, commiteado)
3. **Environment Variables** (runtime, NO commiteadas)
4. **Secrets Manager** (producción, NO commiteadas)

### 2.2. appsettings.json (Base)

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=erp;User=root;Password=CHANGE_ME;",
    "Redis": "localhost:6379"
  },
  "Jwt": {
    "Secret": "CHANGE_ME_MINIMUM_32_CHARACTERS_SECRET_KEY",
    "Issuer": "erp-api",
    "Audience": "erp-client",
    "ExpirationMinutes": 480,
    "RefreshTokenExpirationDays": 30
  },
  "CurrencyApi": {
    "BaseUrl": "https://api.exchangerate-api.com/v4/latest/",
    "ApiKey": "",
    "CacheDurationMinutes": 60,
    "FallbackToManualRates": true
  },
  "Hangfire": {
    "DashboardPath": "/hangfire",
    "EnableDashboard": false,
    "WorkerCount": 5
  },
  "Serilog": {
    "MinimumLevel": {
      "Default": "Information",
      "Override": {
        "Microsoft": "Warning",
        "Microsoft.Hosting.Lifetime": "Information",
        "Microsoft.EntityFrameworkCore": "Warning"
      }
    },
    "WriteTo": [
      {
        "Name": "Console",
        "Args": {
          "outputTemplate": "[{Timestamp:HH:mm:ss} {Level:u3}] {Message:lj} {Properties:j}{NewLine}{Exception}"
        }
      },
      {
        "Name": "File",
        "Args": {
          "path": "logs/erp-.log",
          "rollingInterval": "Day",
          "retainedFileCountLimit": 30,
          "outputTemplate": "{Timestamp:yyyy-MM-dd HH:mm:ss.fff zzz} [{Level:u3}] [{SourceContext}] {Message:lj} {Properties:j}{NewLine}{Exception}"
        }
      }
    ],
    "Enrich": ["FromLogContext", "WithMachineName", "WithThreadId"]
  },
  "AllowedHosts": "*"
}
```

### 2.3. appsettings.Development.json

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=erp_dev;User=root;Password=dev_password_123;",
    "Redis": "localhost:6379,password=redis_dev_pass"
  },
  "Jwt": {
    "Secret": "dev_secret_key_minimum_32_chars_for_hmacsha256_algorithm",
    "ExpirationMinutes": 43200  // 30 días en dev para comodidad
  },
  "Hangfire": {
    "EnableDashboard": true
  },
  "Serilog": {
    "MinimumLevel": {
      "Default": "Debug"
    },
    "WriteTo": [
      {
        "Name": "Console"
      },
      {
        "Name": "Seq",
        "Args": {
          "serverUrl": "http://localhost:5341"
        }
      }
    ]
  },
  "DetailedErrors": true,
  "Swagger": {
    "Enabled": true
  }
}
```

### 2.4. appsettings.Staging.json

```json
{
  "Serilog": {
    "MinimumLevel": {
      "Default": "Information"
    }
  },
  "Hangfire": {
    "EnableDashboard": true  // Habilitado en Staging para debugging
  },
  "Swagger": {
    "Enabled": true  // Habilitado en Staging
  }
}
```

### 2.5. appsettings.Production.json

```json
{
  "Serilog": {
    "MinimumLevel": {
      "Default": "Warning"
    }
  },
  "Hangfire": {
    "EnableDashboard": false  // DESHABILITADO en producción por seguridad
  },
  "Swagger": {
    "Enabled": false  // DESHABILITADO en producción
  },
  "DetailedErrors": false
}
```

### 2.6. Secrets Management (Production)

**NUNCA commitear secrets en git. Usar:**

#### Opción A: Environment Variables (Docker)
```bash
# .env.production (NO commitear, en .gitignore)
CONNECTIONSTRINGS__DEFAULTCONNECTION=Server=prod-mysql.example.com;Database=erp_prod;User=erp_prod_user;Password=SUPER_SECRET_PASSWORD
JWT__SECRET=PRODUCTION_SECRET_KEY_MINIMUM_64_CHARACTERS_HIGHLY_SECURE
CURRENCYAPI__APIKEY=prod_api_key_xyz123
```

#### Opción B: Azure Key Vault
```csharp
// Program.cs
var builder = WebApplication.CreateBuilder(args);

if (builder.Environment.IsProduction())
{
    var keyVaultUrl = builder.Configuration["KeyVault:Url"];
    builder.Configuration.AddAzureKeyVault(
        new Uri(keyVaultUrl),
        new DefaultAzureCredential());
}
```

#### Opción C: AWS Secrets Manager
```csharp
builder.Configuration.AddSecretsManager(
    region: RegionEndpoint.USEast1,
    configurator: options => {
        options.SecretFilter = entry => entry.Name.StartsWith("erp/");
    });
```

---

## 🗄️ Estrategia 3: Database Consistency

### 3.1. Migrations como Source of Truth

**Principio:**
> "La estructura de la base de datos se define en código (Migrations), no manualmente en DB"

#### Flujo de Trabajo:

```bash
# 1. Developer crea nueva entidad o modifica existente
# Domain/Entities/Cliente.cs

# 2. Developer genera migration
dotnet ef migrations add AddClienteEntity --project src/Infrastructure --startup-project src/API

# 3. Migration se commitea a git
git add src/Infrastructure/Migrations/
git commit -m "Add Cliente entity migration"

# 4. CI/CD aplica migration automáticamente en cada entorno
# GitHub Actions ejecuta:
dotnet ef database update --project src/Infrastructure --startup-project src/API
```

### 3.2. Scripts de Migration (Idempotentes)

```csharp
// Infrastructure/Migrations/20250110_AddClienteTable.cs
public partial class AddClienteTable : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateTable(
            name: "Clientes",
            columns: table => new
            {
                Id = table.Column<int>(nullable: false)
                    .Annotation("MySQL:ValueGenerationStrategy", MySQLValueGenerationStrategy.IdentityColumn),
                RazonSocial = table.Column<string>(maxLength: 200, nullable: false),
                TaxId = table.Column<string>(maxLength: 20, nullable: false),
                TenantId = table.Column<int>(nullable: false),
                IsDeleted = table.Column<bool>(nullable: false, defaultValue: false),
                CreatedAt = table.Column<DateTime>(nullable: false, defaultValueSql: "CURRENT_TIMESTAMP")
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_Clientes", x => x.Id);
                table.ForeignKey(
                    name: "FK_Clientes_Tenants_TenantId",
                    column: x => x.TenantId,
                    principalTable: "Tenants",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Restrict);
            });

        migrationBuilder.CreateIndex(
            name: "IX_Clientes_TenantId_TaxId",
            table: "Clientes",
            columns: new[] { "TenantId", "TaxId" },
            unique: true);
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable(
            name: "Clientes");
    }
}
```

### 3.3. Versionado de Schema

**Tabla de control de versiones:**
```sql
-- Automáticamente creada por EF Core
CREATE TABLE __EFMigrationsHistory (
    MigrationId VARCHAR(150) NOT NULL PRIMARY KEY,
    ProductVersion VARCHAR(32) NOT NULL
);

-- Ejemplo de contenido
SELECT * FROM __EFMigrationsHistory;
-- MigrationId                      | ProductVersion
-- 20250110120000_InitialCreate     | 8.0.0
-- 20250111093000_AddClienteEntity  | 8.0.0
```

### 3.4. Seed Data Diferenciado por Ambiente

```csharp
// Infrastructure/Persistence/ApplicationDbContextSeed.cs
public static class ApplicationDbContextSeed
{
    public static async Task SeedAsync(
        ApplicationDbContext context,
        IWebHostEnvironment environment,
        ILogger logger)
    {
        // Seed común a todos los entornos
        await SeedTenantsAsync(context);
        await SeedRolesAsync(context);

        // Seed solo en Development
        if (environment.IsDevelopment())
        {
            await SeedDevelopmentDataAsync(context);
            await SeedTestUsersAsync(context);
            await SeedSampleProductsAsync(context);
        }

        // Seed solo en Staging
        if (environment.IsStaging())
        {
            await SeedStagingDataAsync(context);
        }

        // NO seed en Production (datos reales solo via migración o import)
    }
}
```

---

## 🚀 Estrategia 4: CI/CD Pipeline Consistency

### 4.1. GitHub Actions Workflow

```yaml
# .github/workflows/ci-cd.yml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  DOTNET_VERSION: '8.0.x'
  DOCKER_IMAGE: erp-api
  MYSQL_VERSION: '8.0.35'

jobs:
  # ==================================
  # Job 1: Build & Test
  # ==================================
  build-and-test:
    runs-on: ubuntu-latest

    services:
      # Mismo MySQL que usamos en dev/staging/prod
      mysql:
        image: mysql:8.0.35
        env:
          MYSQL_ROOT_PASSWORD: test_password
          MYSQL_DATABASE: erp_test
        ports:
          - 3306:3306
        options: >-
          --health-cmd="mysqladmin ping"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=5

      redis:
        image: redis:7.2-alpine
        ports:
          - 6379:6379

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: ${{ env.DOTNET_VERSION }}

      - name: Restore dependencies
        run: dotnet restore

      - name: Build
        run: dotnet build --no-restore --configuration Release

      - name: Run Migrations
        run: dotnet ef database update --project src/Infrastructure --startup-project src/API
        env:
          ConnectionStrings__DefaultConnection: "Server=localhost;Database=erp_test;User=root;Password=test_password;"

      - name: Run Unit Tests
        run: dotnet test tests/Domain.Tests --no-build --configuration Release --logger "trx;LogFileName=unit-tests.trx"

      - name: Run Integration Tests
        run: dotnet test tests/Application.Tests --no-build --configuration Release --logger "trx;LogFileName=integration-tests.trx"
        env:
          ConnectionStrings__DefaultConnection: "Server=localhost;Database=erp_test;User=root;Password=test_password;"
          ConnectionStrings__Redis: "localhost:6379"

      - name: Generate Code Coverage
        run: |
          dotnet test --no-build --configuration Release \
            /p:CollectCoverage=true \
            /p:CoverletOutputFormat=opencover \
            /p:CoverletOutput=./coverage/

      - name: Upload Coverage to SonarCloud
        uses: SonarSource/sonarcloud-github-action@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}

      - name: Check Coverage Threshold
        run: |
          COVERAGE=$(grep -oP 'line-rate="\K[^"]+' coverage/coverage.cobertura.xml)
          if (( $(echo "$COVERAGE < 0.90" | bc -l) )); then
            echo "Coverage is below 90%: $COVERAGE"
            exit 1
          fi

  # ==================================
  # Job 2: Build Docker Image
  # ==================================
  build-docker:
    needs: build-and-test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' || github.ref == 'refs/heads/develop'

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ secrets.DOCKER_USERNAME }}/${{ env.DOCKER_IMAGE }}
          tags: |
            type=ref,event=branch
            type=sha,prefix={{branch}}-
            type=semver,pattern={{version}}

      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          file: ./Dockerfile
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

      - name: Image digest
        run: echo ${{ steps.meta.outputs.digest }}

  # ==================================
  # Job 3: Deploy to Staging
  # ==================================
  deploy-staging:
    needs: build-docker
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    environment:
      name: staging
      url: https://staging-api.erp.example.com

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Deploy to Staging Server
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.STAGING_HOST }}
          username: ${{ secrets.STAGING_USER }}
          key: ${{ secrets.STAGING_SSH_KEY }}
          script: |
            cd /opt/erp
            docker-compose -f docker-compose.yml -f docker-compose.staging.yml pull
            docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d
            docker-compose exec -T api dotnet ef database update

      - name: Run Smoke Tests
        run: |
          sleep 30  # Esperar que API levante
          curl -f https://staging-api.erp.example.com/health || exit 1
          curl -f https://staging-api.erp.example.com/api/v1/health || exit 1

      - name: Notify Slack
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: 'Deployment to Staging: ${{ job.status }}'
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}

  # ==================================
  # Job 4: Deploy to Production
  # ==================================
  deploy-production:
    needs: build-docker
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment:
      name: production
      url: https://api.erp.example.com

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Deploy to Production Server
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.PROD_HOST }}
          username: ${{ secrets.PROD_USER }}
          key: ${{ secrets.PROD_SSH_KEY }}
          script: |
            cd /opt/erp
            docker-compose -f docker-compose.yml -f docker-compose.prod.yml pull
            docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --no-deps api
            docker-compose exec -T api dotnet ef database update

      - name: Run Smoke Tests
        run: |
          sleep 30
          curl -f https://api.erp.example.com/health || exit 1

      - name: Notify Slack
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: 'Deployment to Production: ${{ job.status }}'
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

**Key Points del Pipeline:**
- ✅ Mismos services (MySQL 8.0.35, Redis 7.2) en CI que en dev/staging/prod
- ✅ Un solo Docker image buildado en CI, usado en Staging y Production
- ✅ Tests corren contra MySQL real (no SQLite)
- ✅ Migrations se aplican automáticamente
- ✅ Smoke tests validan deployment
- ✅ Manual approval para Production (GitHub Environments)

---

## 📋 Estrategia 5: Dependency Management

### 5.1. Lock de Versiones

**NUNCA usar versiones floating:**

❌ **MAL:**
```xml
<PackageReference Include="Microsoft.EntityFrameworkCore" Version="8.*" />
<PackageReference Include="Serilog.AspNetCore" Version="Latest" />
```

✅ **BIEN:**
```xml
<PackageReference Include="Microsoft.EntityFrameworkCore" Version="8.0.1" />
<PackageReference Include="Serilog.AspNetCore" Version="8.0.0" />
```

### 5.2. Renovate Bot / Dependabot

Configurar actualizaciones automáticas controladas:

```json
// .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "nuget"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 5
    target-branch: "develop"
    reviewers:
      - "tech-lead"
    labels:
      - "dependencies"
      - "automated"
```

### 5.3. Runtime Version Lock

**Global.json:**
```json
{
  "sdk": {
    "version": "8.0.101",
    "rollForward": "latestPatch"
  }
}
```

---

## 🔐 Estrategia 6: Security Consistency

### 6.1. Secrets NO en Código

**Checklist:**
- [ ] Ningún secret hardcodeado en código
- [ ] `.env` files en `.gitignore`
- [ ] Secrets en Environment Variables
- [ ] Production secrets en Secrets Manager
- [ ] Git hooks para detectar secrets (git-secrets, truffleHog)

### 6.2. .gitignore Robusto

```gitignore
# Secrets y configuraciones locales
appsettings.*.local.json
.env
.env.local
.env.production
*.pfx
*.key
*.pem

# Build outputs
bin/
obj/
publish/

# Docker
.docker/

# IDE
.vs/
.vscode/
.idea/
*.suo
*.user

# Logs
logs/
*.log

# OS
.DS_Store
Thumbs.db
```

---

## 🧪 Estrategia 7: Testing Consistency

### 7.1. Test Containers

Usar contenedores reales para integration tests:

```csharp
// tests/Application.Tests/IntegrationTestBase.cs
using Testcontainers.MySql;

public class IntegrationTestBase : IAsyncLifetime
{
    private readonly MySqlContainer _mySqlContainer;

    public IntegrationTestBase()
    {
        // Mismo MySQL que producción
        _mySqlContainer = new MySqlBuilder()
            .WithImage("mysql:8.0.35")
            .WithDatabase("erp_test")
            .WithUsername("root")
            .WithPassword("test_password")
            .Build();
    }

    public async Task InitializeAsync()
    {
        await _mySqlContainer.StartAsync();

        // Aplicar migrations
        var connectionString = _mySqlContainer.GetConnectionString();
        // ... aplicar migrations
    }

    public async Task DisposeAsync()
    {
        await _mySqlContainer.DisposeAsync();
    }
}
```

---

## 📊 Matriz de Consistencia

| Componente | Development | CI/CD | Staging | Production | ✅ Consistente |
|------------|-------------|-------|---------|------------|---------------|
| **.NET Version** | 8.0.101 | 8.0.101 | 8.0.101 | 8.0.101 | ✅ |
| **MySQL Version** | 8.0.35 | 8.0.35 | 8.0.35 | 8.0.35 | ✅ |
| **Redis Version** | 7.2-alpine | 7.2-alpine | 7.2-alpine | 7.2-alpine | ✅ |
| **OS (Container)** | Alpine Linux | Alpine Linux | Alpine Linux | Alpine Linux | ✅ |
| **Docker Image** | N/A | Built once | Same image | Same image | ✅ |
| **Dependencies** | Locked versions | Locked versions | Locked versions | Locked versions | ✅ |
| **Migrations** | EF Core | EF Core | EF Core | EF Core | ✅ |
| **Config Source** | appsettings.json | appsettings.json | Env vars | Secrets Manager | ⚠️ Diferente origen |
| **Logging Level** | Debug | Information | Information | Warning | ⚠️ Por diseño |

---

## ✅ Checklist de Implementación

### Sprint 1 (Semanas 1-2)
- [ ] Crear Dockerfile multi-stage optimizado
- [ ] Crear docker-compose.yml base
- [ ] Crear docker-compose overrides por ambiente
- [ ] Configurar appsettings por ambiente
- [ ] Configurar .gitignore robusto
- [ ] Configurar global.json con SDK version lock
- [ ] Lock de versiones en .csproj (NuGet packages)
- [ ] Implementar ApplicationDbContextSeed con lógica por ambiente

### Sprint 2 (Semanas 3-4)
- [ ] Configurar GitHub Actions CI/CD pipeline
- [ ] Configurar Dependabot para actualizaciones
- [ ] Setup de Staging environment
- [ ] Configurar secrets en GitHub
- [ ] Implementar smoke tests post-deployment
- [ ] Configurar notificaciones Slack

### Sprint 3 (Semanas 5-6)
- [ ] Setup de Production environment
- [ ] Configurar Azure Key Vault / AWS Secrets Manager
- [ ] Implementar health checks avanzados
- [ ] Configurar backup automatizado de MySQL
- [ ] Documentar runbooks de deployment
- [ ] Configurar monitoring (Prometheus/Grafana)

---

## 🎓 Training del Equipo

### Sesión 1: Docker Fundamentals (2 horas)
- Qué es Docker y por qué lo usamos
- Dockerfile anatomy
- Docker Compose basics
- Hands-on: Levantar el stack completo

### Sesión 2: Configuration Management (1 hora)
- Jerarquía de configuración
- Secrets management
- Environment variables
- Hands-on: Configurar variables locales

### Sesión 3: CI/CD Pipeline (1.5 horas)
- GitHub Actions workflow
- Build → Test → Deploy flow
- Manual approvals
- Hands-on: Triggear deployment

---

## 📚 Recursos Adicionales

- [The Twelve-Factor App](https://12factor.net/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [EF Core Migrations](https://docs.microsoft.com/en-us/ef/core/managing-schemas/migrations/)
- [ASP.NET Core Configuration](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/configuration/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---

## 🚀 Conclusión

Con esta estrategia de entornos consistentes:

✅ **"Works on my machine"** se elimina → Mismos containers en todos lados
✅ **Configuración versionada** → Infrastructure as Code
✅ **Deployments predecibles** → Mismo Docker image
✅ **Tests confiables** → Mismas dependencias que producción
✅ **Debugging facilitado** → Staging idéntico a Production
✅ **Rollbacks seguros** → Tags de Docker versionados

**Resultado:** Menos bugs, más confianza, deploys más rápidos.

---

**Última Actualización:** 2025-10-11
**Versión:** 1.0
**Autor:** Tech Lead
