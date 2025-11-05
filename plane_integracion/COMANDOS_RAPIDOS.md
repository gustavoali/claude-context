# Comandos Rápidos - Plane GitHub MCP Integration

**Guía de referencia rápida** para comandos frecuentes del proyecto.

---

## 🚀 Inicio Rápido (5 minutos)

### 1. Iniciar Todo el Stack

```bash
# Desde PowerShell o WSL
cd C:\tools\plane\plane-app

# Iniciar todos los servicios
docker-compose up -d

# Ver que todo está corriendo
docker-compose ps

# Ver logs
docker-compose logs -f
```

### 2. Aplicar Migraciones

```bash
# Aplicar todas las migraciones pendientes
docker-compose exec plane-api python manage.py migrate

# Verificar aplicadas
docker-compose exec plane-api python manage.py showmigrations | grep -E "(0108|0109)"
```

### 3. Verificar que Funciona

```bash
# Health check de la API
curl http://localhost:8000/api/health/

# Verificar PostgreSQL
docker-compose exec plane-postgres pg_isready -U plane

# Verificar Redis
docker-compose exec plane-redis redis-cli ping
```

---

## 🐳 Docker

### Gestión de Servicios

```bash
# Ver servicios corriendo
docker-compose ps

# Iniciar servicios
docker-compose up -d

# Detener servicios
docker-compose stop

# Reiniciar un servicio
docker-compose restart plane-api

# Detener y eliminar contenedores
docker-compose down

# Detener y eliminar TODO (incluye volúmenes)
docker-compose down -v
```

### Logs

```bash
# Todos los logs en tiempo real
docker-compose logs -f

# Logs de un servicio específico
docker-compose logs -f plane-api
docker-compose logs -f plane-celery
docker-compose logs -f plane-postgres

# Últimas 50 líneas
docker-compose logs --tail=50

# Buscar errores
docker-compose logs | grep ERROR
```

### Acceder a Contenedores

```bash
# Acceder al contenedor de la API
docker-compose exec plane-api bash

# Acceder a PostgreSQL
docker-compose exec plane-postgres psql -U plane -d plane

# Acceder a Redis CLI
docker-compose exec plane-redis redis-cli

# Ejecutar comando sin entrar
docker-compose exec plane-api python manage.py --help
```

---

## 📦 Django / Plane API

### Migraciones

```bash
# Ver estado de migraciones
docker-compose exec plane-api python manage.py showmigrations

# Ver migraciones de la app 'db'
docker-compose exec plane-api python manage.py showmigrations db

# Aplicar todas las migraciones
docker-compose exec plane-api python manage.py migrate

# Aplicar migración específica
docker-compose exec plane-api python manage.py migrate db 0108

# Crear nueva migración (si modificas modelos)
docker-compose exec plane-api python manage.py makemigrations

# Ver SQL de una migración sin aplicarla
docker-compose exec plane-api python manage.py sqlmigrate db 0108
```

### Django Shell y Comandos

```bash
# Django shell (Python interactivo)
docker-compose exec plane-api python manage.py shell

# Django shell con IPython
docker-compose exec plane-api python manage.py shell_plus

# Crear superusuario
docker-compose exec plane-api python manage.py createsuperuser

# Ejecutar tests
docker-compose exec plane-api pytest

# Ejecutar tests específicos
docker-compose exec plane-api pytest plane/tests/services/mcp/ -v

# Ver configuración actual
docker-compose exec plane-api python manage.py diffsettings
```

---

## 🗄️ PostgreSQL

### Acceso y Consultas

```bash
# Conectar a PostgreSQL
docker-compose exec plane-postgres psql -U plane -d plane

# O desde fuera del contenedor (si tienes psql instalado)
psql -h localhost -U plane -d plane
```

### Comandos dentro de psql

```sql
-- Listar bases de datos
\l

-- Conectar a una base de datos
\c plane

-- Listar todas las tablas
\dt

-- Listar tablas que empiezan con 'github_'
\dt github_*

-- Ver estructura de una tabla
\d github_webhook_events
\d github_sync_jobs

-- Ver todas las columnas de una tabla
\d+ github_webhook_events

-- Ejecutar query
SELECT * FROM github_webhook_events LIMIT 10;

-- Contar registros
SELECT COUNT(*) FROM github_webhook_events;

-- Salir
\q
```

### Backup y Restore

```bash
# Hacer backup
docker-compose exec -T plane-postgres pg_dump -U plane plane > backup_$(date +%Y%m%d).sql

# O con compresión
docker-compose exec -T plane-postgres pg_dump -U plane plane | gzip > backup_$(date +%Y%m%d).sql.gz

# Restaurar backup
cat backup_20251017.sql | docker-compose exec -T plane-postgres psql -U plane plane

# O desde comprimido
gunzip -c backup_20251017.sql.gz | docker-compose exec -T plane-postgres psql -U plane plane
```

### Queries Útiles

```sql
-- Ver tablas con más registros
SELECT
    schemaname, tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size,
    n_tup_ins as inserts
FROM pg_stat_user_tables
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
LIMIT 10;

-- Ver últimos webhooks recibidos
SELECT id, delivery_id, event_type, status, created_at
FROM github_webhook_events
ORDER BY created_at DESC
LIMIT 20;

-- Ver últimos sync jobs
SELECT id, job_id, status, direction, items_total, items_synced
FROM github_sync_jobs
ORDER BY created_at DESC
LIMIT 20;
```

---

## 🔴 Redis

### Acceso y Comandos

```bash
# Conectar a Redis
docker-compose exec plane-redis redis-cli

# Verificar conexión
docker-compose exec plane-redis redis-cli ping
# Responde: PONG
```

### Comandos dentro de redis-cli

```redis
# Ver información del servidor
INFO

# Ver todas las claves
KEYS *

# Ver claves que empiezan con 'celery'
KEYS celery*

# Ver claves que empiezan con 'github'
KEYS github*

# Ver valor de una clave
GET nombre_de_la_clave

# Ver TTL de una clave
TTL nombre_de_la_clave

# Ver memoria usada
INFO memory

# Limpiar toda la base de datos (¡CUIDADO!)
FLUSHDB

# Salir
EXIT
```

---

## ⚙️ Celery

### Gestión de Workers

```bash
# Ver logs del worker
docker-compose logs -f plane-celery

# Reiniciar worker
docker-compose restart plane-celery

# Ver tareas registradas
docker-compose exec plane-celery celery -A plane inspect registered

# Ver tareas activas
docker-compose exec plane-celery celery -A plane inspect active

# Ver workers conectados
docker-compose exec plane-celery celery -A plane inspect stats

# Purgar todas las tareas pendientes (¡CUIDADO!)
docker-compose exec plane-celery celery -A plane purge
```

### Monitoreo con Flower (Opcional)

```bash
# Instalar Flower
docker-compose exec plane-api pip install flower

# Iniciar Flower
docker-compose exec plane-api celery -A plane flower --port=5555

# Acceder en navegador
# http://localhost:5555
```

---

## 🧪 Testing

### Ejecutar Tests

```bash
# Todos los tests
docker-compose exec plane-api pytest

# Tests de MCP services
docker-compose exec plane-api pytest plane/tests/services/mcp/ -v

# Tests con coverage
docker-compose exec plane-api pytest \
  plane/tests/services/mcp/ \
  --cov=plane.app.services.mcp \
  --cov-report=term

# Tests específicos
docker-compose exec plane-api pytest plane/tests/services/mcp/test_client.py -v

# Tests con output detallado
docker-compose exec plane-api pytest -vv -s

# Tests que fallan primero
docker-compose exec plane-api pytest -x

# Re-ejecutar tests que fallaron
docker-compose exec plane-api pytest --lf
```

### Coverage Reports

```bash
# Coverage en terminal
docker-compose exec plane-api pytest --cov=plane.app.services.mcp --cov-report=term

# Coverage HTML (genera carpeta htmlcov/)
docker-compose exec plane-api pytest --cov=plane.app.services.mcp --cov-report=html

# Ver cobertura total
docker-compose exec plane-api pytest --cov=plane --cov-report=term-missing
```

---

## 🔍 Debugging

### Verificar Configuración

```bash
# Ver variables de entorno
docker-compose exec plane-api env | grep -E "(GITHUB|MCP|DATABASE|REDIS)"

# Ver settings de Django
docker-compose exec plane-api python manage.py diffsettings

# Verificar imports
docker-compose exec plane-api python -c "from plane.app.services.mcp.client import MCPClient; print('OK')"
```

### Verificar Base de Datos

```bash
# Verificar conexión
docker-compose exec plane-api python manage.py dbshell

# Ver estado de migraciones
docker-compose exec plane-api python manage.py showmigrations

# Verificar que las tablas existen
docker-compose exec plane-postgres psql -U plane -d plane -c "\dt github_*"
```

### Ver Uso de Recursos

```bash
# Ver recursos de Docker
docker stats

# Ver uso de disco
docker system df

# Ver detalles de un contenedor
docker inspect plane-app_plane-api_1

# Ver procesos en un contenedor
docker-compose top plane-api
```

---

## 🧹 Limpieza

### Limpiar Datos de Desarrollo

```bash
# Detener y eliminar contenedores
docker-compose down

# Detener y eliminar contenedores + volúmenes (PIERDE DATOS)
docker-compose down -v

# Limpiar imágenes y contenedores no usados
docker system prune -a

# Limpiar volúmenes no usados
docker volume prune
```

### Resetear Base de Datos

```bash
# Método 1: Eliminar volumen
docker-compose down -v
docker-compose up -d
docker-compose exec plane-api python manage.py migrate

# Método 2: Desde PostgreSQL
docker-compose exec plane-postgres psql -U plane -d plane -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
docker-compose exec plane-api python manage.py migrate
```

---

## 🔐 GitHub OAuth (Configuración Inicial)

### Crear OAuth App

1. Ve a: https://github.com/settings/developers
2. Click "OAuth Apps" → "New OAuth App"
3. Completa:
   - **Application name**: Plane GitHub Integration (Dev)
   - **Homepage URL**: http://localhost:8000
   - **Callback URL**: http://localhost:8000/api/auth/github/callback
4. Copia el **Client ID**
5. Genera y copia el **Client Secret**

### Configurar Variables

```bash
# Editar .env
cd C:\tools\plane\plane-app
notepad .env

# Agregar:
GITHUB_CLIENT_ID=tu_client_id_aqui
GITHUB_CLIENT_SECRET=tu_client_secret_aqui
GITHUB_CALLBACK_URL=http://localhost:8000/api/auth/github/callback
```

### Reiniciar Servicios

```bash
docker-compose restart plane-api
docker-compose logs -f plane-api
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

# Verificar que todos los servicios responden
docker-compose ps
```

### Ver Logs en Tiempo Real

```bash
# Todos los servicios
docker-compose logs -f

# Solo API
docker-compose logs -f plane-api

# API y Celery
docker-compose logs -f plane-api plane-celery

# Últimas 100 líneas
docker-compose logs --tail=100
```

---

## 🆘 Troubleshooting Rápido

### Problema: Servicios no inician

```bash
# Ver logs
docker-compose logs

# Verificar puertos
netstat -ano | findstr :5432
netstat -ano | findstr :8000

# Reiniciar Docker
# PowerShell como admin:
Restart-Service com.docker.service
```

### Problema: API no responde

```bash
# Ver logs de la API
docker-compose logs plane-api

# Verificar que el contenedor está corriendo
docker-compose ps plane-api

# Reiniciar API
docker-compose restart plane-api

# Reconstruir API
docker-compose up -d --build plane-api
```

### Problema: Migraciones fallan

```bash
# Verificar conexión a DB
docker-compose exec plane-api python manage.py dbshell

# Ver migraciones pendientes
docker-compose exec plane-api python manage.py showmigrations

# Ver logs de PostgreSQL
docker-compose logs plane-postgres

# Verificar que PostgreSQL está listo
docker-compose exec plane-postgres pg_isready -U plane
```

---

## 📚 Referencias Rápidas

- **Documentación completa**: Ver `C:\claude_context\plane_integracion\README.md`
- **Setup Docker WSL**: Ver `C:\claude_context\plane_integracion\DOCKER_WSL_SETUP.md`
- **Estado del proyecto**: Ver `C:\claude_context\plane_integracion\PROJECT_STATUS.md`
- **Próximos pasos**: Ver `C:\tools\plane\NEXT_STEPS_IMPLEMENTATION.md`

---

**Última actualización**: 2025-10-17
