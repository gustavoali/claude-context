# Plane GitHub MCP Integration - Docker WSL Setup

**Proyecto**: GitHub MCP Integration para Plane.so
**Entorno**: Docker sobre WSL (Windows Subsystem for Linux)
**Fecha**: 2025-10-17
**Estado**: En configuración

---

## 📋 Resumen del Proyecto

### Objetivo
Integrar Plane.so con GitHub usando Model Context Protocol (MCP) para:
- Sincronización bidireccional de issues entre Plane y GitHub
- Webhooks en tiempo real
- OAuth 2.0 authentication
- Background processing con Celery
- UI de administración completa

### Stack Tecnológico

**Backend**:
- Python 3.10+
- Django 4.2
- Django REST Framework 3.15
- Celery 5.4
- Redis 5.0
- PostgreSQL
- MCP 0.9.0

**Frontend**:
- React 18+
- TypeScript
- Next.js

**Infrastructure**:
- Docker + Docker Compose
- WSL (Windows Subsystem for Linux)

---

## 🐳 Arquitectura Docker WSL

### Ventajas de Docker sobre WSL
1. **Aislamiento**: Cada servicio en su propio contenedor
2. **Reproducibilidad**: Mismo entorno en dev/staging/prod
3. **Performance**: WSL2 ofrece performance casi nativa de Linux
4. **Facilidad**: Un comando levanta todo el stack

### Servicios Docker

El proyecto usa `docker-compose.yml` con los siguientes servicios:

```yaml
services:
  # PostgreSQL - Base de datos principal
  plane-postgres:
    image: postgres:15
    environment:
      POSTGRES_USER: plane
      POSTGRES_PASSWORD: plane
      POSTGRES_DB: plane
    volumes:
      - postgres-data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  # Redis - Cache y message broker
  plane-redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data

  # RabbitMQ - Message queue (opcional)
  plane-mq:
    image: rabbitmq:3-management
    environment:
      RABBITMQ_DEFAULT_USER: plane
      RABBITMQ_DEFAULT_PASS: plane
    ports:
      - "5672:5672"
      - "15672:15672"  # Management UI

  # MinIO - S3-compatible storage
  plane-minio:
    image: minio/minio
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: plane
      MINIO_ROOT_PASSWORD: plane123
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - minio-data:/data

  # Plane API (Django)
  plane-api:
    build:
      context: ./apps/api
      dockerfile: Dockerfile
    command: python manage.py runserver 0.0.0.0:8000
    volumes:
      - ./apps/api:/app
    ports:
      - "8000:8000"
    depends_on:
      - plane-postgres
      - plane-redis
    environment:
      - DATABASE_HOST=plane-postgres
      - REDIS_HOST=plane-redis

  # Celery Worker (Background tasks)
  plane-celery:
    build:
      context: ./apps/api
      dockerfile: Dockerfile
    command: celery -A plane worker -l info
    volumes:
      - ./apps/api:/app
    depends_on:
      - plane-postgres
      - plane-redis
    environment:
      - DATABASE_HOST=plane-postgres
      - REDIS_HOST=plane-redis

volumes:
  postgres-data:
  redis-data:
  minio-data:
```

---

## 🔧 Configuración del Entorno

### Archivo .env

El proyecto está configurado para Docker con las siguientes variables:

```bash
# Database Settings
POSTGRES_USER="plane"
POSTGRES_PASSWORD="plane"
POSTGRES_DB="plane"
PGDATA="/var/lib/postgresql/data"

# Redis Settings
REDIS_HOST="plane-redis"
REDIS_PORT="6379"

# RabbitMQ Settings
RABBITMQ_HOST="plane-mq"
RABBITMQ_PORT="5672"
RABBITMQ_USER="plane"
RABBITMQ_PASSWORD="plane"
RABBITMQ_VHOST="plane"

# AWS/MinIO Settings
AWS_REGION=""
AWS_ACCESS_KEY_ID="access-key"
AWS_SECRET_ACCESS_KEY="secret-key"
AWS_S3_ENDPOINT_URL="http://plane-minio:9000"
AWS_S3_BUCKET_NAME="uploads"
FILE_SIZE_LIMIT=5242880

# Docker
DOCKERIZED=1
USE_MINIO=1

# Networking
LISTEN_HTTP_PORT=80
LISTEN_HTTPS_PORT=443
TRUSTED_PROXIES=0.0.0.0/0

# API Rate Limiting
API_KEY_RATE_LIMIT="60/minute"
```

### Variables Adicionales para GitHub MCP (Agregar)

```bash
# GitHub OAuth
GITHUB_CLIENT_ID=tu_client_id_aqui
GITHUB_CLIENT_SECRET=tu_client_secret_aqui
GITHUB_CALLBACK_URL=http://localhost:8000/api/auth/github/callback

# MCP Server
MCP_GITHUB_SERVER_URL=https://api.githubcopilot.com/mcp/
MCP_CONNECTION_TIMEOUT=30
MCP_MAX_RETRIES=3
MCP_RETRY_DELAY=1

# Feature Flags
ENABLE_GITHUB_MCP_INTEGRATION=true
GITHUB_MCP_MAX_SYNC_BATCH_SIZE=100
GITHUB_MCP_DEFAULT_SYNC_INTERVAL=300
```

---

## 🚀 Comandos Docker WSL

### 1. Verificar WSL y Docker

```bash
# Verificar versión de WSL
wsl --version

# Verificar que WSL2 está activo
wsl -l -v

# Verificar Docker Desktop
docker --version
docker-compose --version

# Verificar que Docker está usando WSL2 backend
docker info | grep "Operating System"
```

### 2. Iniciar Servicios

```bash
# Navegar al directorio del proyecto (en WSL)
cd /mnt/c/tools/plane/plane-app

# O desde Windows PowerShell
cd C:\tools\plane\plane-app

# Iniciar todos los servicios
docker-compose up -d

# Ver logs de todos los servicios
docker-compose logs -f

# Ver logs de un servicio específico
docker-compose logs -f plane-api
docker-compose logs -f plane-celery
docker-compose logs -f plane-postgres
```

### 3. Verificar Estado de Servicios

```bash
# Ver servicios corriendo
docker-compose ps

# Ver recursos utilizados
docker stats

# Verificar salud de PostgreSQL
docker-compose exec plane-postgres pg_isready -U plane

# Verificar Redis
docker-compose exec plane-redis redis-cli ping
# Debe responder: PONG

# Verificar RabbitMQ (Management UI)
# Abrir: http://localhost:15672
# Usuario: plane / plane
```

### 4. Acceder a Contenedores

```bash
# Acceder al contenedor de la API
docker-compose exec plane-api bash

# Acceder a PostgreSQL
docker-compose exec plane-postgres psql -U plane -d plane

# Acceder a Redis CLI
docker-compose exec plane-redis redis-cli
```

### 5. Ejecutar Comandos Django

```bash
# Aplicar migraciones
docker-compose exec plane-api python manage.py migrate

# Crear superusuario
docker-compose exec plane-api python manage.py createsuperuser

# Ejecutar shell de Django
docker-compose exec plane-api python manage.py shell

# Ejecutar tests
docker-compose exec plane-api pytest

# Ver estado de migraciones
docker-compose exec plane-api python manage.py showmigrations
```

### 6. Gestión de Servicios

```bash
# Detener todos los servicios
docker-compose stop

# Detener un servicio específico
docker-compose stop plane-celery

# Reiniciar un servicio
docker-compose restart plane-api

# Reconstruir y reiniciar servicios
docker-compose up -d --build

# Detener y eliminar contenedores (mantiene volúmenes)
docker-compose down

# Detener y eliminar TODO (incluyendo volúmenes/datos)
docker-compose down -v
```

### 7. Logs y Debugging

```bash
# Ver logs en tiempo real
docker-compose logs -f

# Ver últimas 100 líneas de logs
docker-compose logs --tail=100

# Ver logs de un servicio
docker-compose logs -f plane-api

# Ver logs de Celery worker
docker-compose logs -f plane-celery

# Buscar en logs
docker-compose logs | grep "ERROR"
```

### 8. Gestión de Volúmenes

```bash
# Listar volúmenes
docker volume ls

# Ver detalles de un volumen
docker volume inspect plane-app_postgres-data

# Hacer backup de PostgreSQL
docker-compose exec plane-postgres pg_dump -U plane plane > backup_$(date +%Y%m%d).sql

# Restaurar backup
cat backup_20251017.sql | docker-compose exec -T plane-postgres psql -U plane plane
```

---

## 📦 Aplicar Migraciones del Proyecto

### Migraciones Pendientes

El proyecto GitHub MCP Integration tiene 2 migraciones pendientes:

1. **0108_githubwebhookevent.py**
   - Crea tabla `github_webhook_events`
   - Trackea eventos de webhooks de GitHub
   - Campos: delivery_id, event_type, status, payload, result

2. **0109_githubsyncjob.py**
   - Crea tabla `github_sync_jobs`
   - Trackea trabajos de sincronización
   - Campos: job_id, status, direction, items_total, items_synced

### Comando para Aplicar

```bash
# Desde Windows PowerShell o WSL
cd C:\tools\plane\plane-app

# Opción 1: Aplicar todas las migraciones pendientes
docker-compose exec plane-api python manage.py migrate

# Opción 2: Aplicar migraciones específicas
docker-compose exec plane-api python manage.py migrate db 0108
docker-compose exec plane-api python manage.py migrate db 0109

# Verificar que se aplicaron
docker-compose exec plane-api python manage.py showmigrations db | grep -E "(0108|0109)"
```

### Verificar en la Base de Datos

```bash
# Conectar a PostgreSQL
docker-compose exec plane-postgres psql -U plane -d plane

# Dentro de psql:
\dt github_*

# Deberías ver:
# - github_webhook_events
# - github_sync_jobs

# Ver estructura de la tabla
\d github_webhook_events
\d github_sync_jobs

# Salir de psql
\q
```

---

## 🔧 Troubleshooting

### Problema: Docker Desktop no inicia

**Solución**:
```powershell
# En PowerShell como administrador
Restart-Service com.docker.service

# O reiniciar Docker Desktop manualmente
```

### Problema: WSL no puede acceder a Docker

**Solución**:
```bash
# Verificar que Docker Desktop tiene WSL integration habilitado
# Docker Desktop → Settings → Resources → WSL Integration
# Habilitar integración con tu distribución WSL
```

### Problema: Puerto ya en uso

```bash
# Ver qué está usando el puerto 5432 (PostgreSQL)
netstat -ano | findstr :5432

# O en WSL
lsof -i :5432

# Detener el servicio que lo usa o cambiar el puerto en docker-compose.yml
```

### Problema: Contenedor no inicia

```bash
# Ver logs detallados
docker-compose logs plane-api

# Ver eventos de Docker
docker events

# Inspeccionar contenedor
docker inspect plane-app_plane-api_1
```

### Problema: Migraciones fallan

```bash
# Verificar conexión a base de datos
docker-compose exec plane-api python manage.py dbshell

# Si falla, verificar que PostgreSQL esté listo
docker-compose exec plane-postgres pg_isready -U plane

# Ver logs de PostgreSQL
docker-compose logs plane-postgres
```

### Problema: Permisos en WSL

```bash
# Agregar usuario a grupo docker (en WSL)
sudo usermod -aG docker $USER

# Reiniciar WSL
wsl --shutdown
wsl
```

---

## 🧪 Testing en Docker

### Ejecutar Tests

```bash
# Todos los tests
docker-compose exec plane-api pytest

# Tests específicos del MCP integration
docker-compose exec plane-api pytest plane/tests/services/mcp/ -v

# Con coverage
docker-compose exec plane-api pytest --cov=plane.app.services.mcp --cov-report=term

# Tests con output detallado
docker-compose exec plane-api pytest -vv -s
```

---

## 📊 Monitoreo

### Health Checks

```bash
# API Health
curl http://localhost:8000/api/health/

# PostgreSQL
docker-compose exec plane-postgres pg_isready -U plane

# Redis
docker-compose exec plane-redis redis-cli ping

# RabbitMQ Management
# http://localhost:15672

# MinIO Console
# http://localhost:9001
```

### Métricas de Recursos

```bash
# Ver uso de recursos en tiempo real
docker stats

# Ver uso de disco
docker system df

# Limpiar recursos no usados
docker system prune -a --volumes
```

---

## 🔐 Seguridad

### Cambiar Contraseñas por Defecto

```bash
# Actualizar en .env:
POSTGRES_PASSWORD="contraseña_segura_aqui"
RABBITMQ_PASSWORD="contraseña_segura_aqui"
AWS_SECRET_ACCESS_KEY="clave_segura_aqui"

# Reconstruir servicios
docker-compose down -v
docker-compose up -d --build
```

### Backup Regular

```bash
# Script de backup automático (agregar a cron)
#!/bin/bash
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Backup PostgreSQL
docker-compose exec -T plane-postgres pg_dump -U plane plane > \
  $BACKUP_DIR/plane_db_$DATE.sql

# Comprimir
gzip $BACKUP_DIR/plane_db_$DATE.sql

# Mantener últimos 7 días
find $BACKUP_DIR -name "plane_db_*.sql.gz" -mtime +7 -delete
```

---

## 📚 Referencias

### Documentación del Proyecto
- `PROJECT_COMPLETION_SUMMARY.md` - Estado del proyecto
- `DEPLOYMENT_GUIDE_GITHUB_MCP.md` - Guía de deployment
- `NEXT_STEPS_IMPLEMENTATION.md` - Próximos pasos
- `PHASE_5_EXECUTION_SUMMARY.md` - Resumen de implementación
- `PHASE_6_TESTING_VALIDATION_SUMMARY.md` - Testing

### Documentación Externa
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [WSL Documentation](https://docs.microsoft.com/en-us/windows/wsl/)
- [Plane.so Documentation](https://docs.plane.so/)
- [Django Documentation](https://docs.djangoproject.com/)

---

## ✅ Checklist de Verificación

Antes de empezar a trabajar:

- [ ] WSL2 instalado y configurado
- [ ] Docker Desktop instalado
- [ ] Docker Desktop con WSL2 integration habilitado
- [ ] Proyecto clonado en `C:\tools\plane\plane-app`
- [ ] Archivo `.env` configurado
- [ ] Variables GitHub OAuth configuradas
- [ ] Docker services iniciados: `docker-compose up -d`
- [ ] PostgreSQL respondiendo: `docker-compose exec plane-postgres pg_isready`
- [ ] Redis respondiendo: `docker-compose exec plane-redis redis-cli ping`
- [ ] Migraciones aplicadas: `docker-compose exec plane-api python manage.py migrate`
- [ ] API respondiendo: `curl http://localhost:8000/api/health/`

---

**Última actualización**: 2025-10-17
**Autor**: Claude Code
**Estado del proyecto**: En configuración - Listo para aplicar migraciones
