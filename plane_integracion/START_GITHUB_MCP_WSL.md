# Guía Rápida: Iniciar GitHub MCP Integration en WSL con Docker

**Fecha**: 16 de Octubre, 2025
**Entorno**: WSL2 Ubuntu + Docker

---

## 🚀 Inicio Rápido (5 comandos)

```bash
# 1. Abrir WSL
wsl

# 2. Navegar al proyecto
cd /mnt/c/tools/plane/plane-app

# 3. Iniciar todos los servicios
docker-compose -f docker-compose-local.yml up -d

# 4. Ver logs (opcional)
docker-compose -f docker-compose-local.yml logs -f

# 5. Acceder a la aplicación
# http://localhost:8000
```

---

## 📋 Paso a Paso Detallado

### Paso 1: Abrir WSL

```bash
# Desde PowerShell o CMD en Windows
wsl
```

### Paso 2: Navegar al Proyecto

```bash
# El proyecto en Windows C:\tools\plane está montado en WSL como:
cd /mnt/c/tools/plane/plane-app

# Verificar que estás en el directorio correcto
ls docker-compose-local.yml
# Deberías ver el archivo
```

### Paso 3: Verificar Configuración

```bash
# Verificar que el .env tiene las credenciales GitHub
cat apps/api/.env | grep GITHUB

# Deberías ver:
# GITHUB_CLIENT_ID="Ov23lizdr7bvBrVGmfEC"
# GITHUB_CLIENT_SECRET="b76c5a750fea840e80ffda375916bd451320b1a9"
# GITHUB_CALLBACK_URL="http://localhost:8000/api/auth/github/callback"
```

### Paso 4: Iniciar Servicios

```bash
# Iniciar todos los contenedores en background
docker-compose -f docker-compose-local.yml up -d

# Ver el estado
docker-compose -f docker-compose-local.yml ps

# Deberías ver estos servicios RUNNING:
# - plane-db (PostgreSQL)
# - plane-redis (Redis/Valkey)
# - plane-mq (RabbitMQ)
# - plane-minio (MinIO S3)
# - api (Django API)
# - worker (Celery Worker)
# - beat-worker (Celery Beat)
# - migrator (Migraciones - se ejecuta una vez y sale)
```

### Paso 5: Verificar que las Migraciones se Aplicaron

El contenedor `migrator` aplica las migraciones automáticamente al iniciar.

```bash
# Ver logs del migrator
docker-compose -f docker-compose-local.yml logs migrator

# Deberías ver algo como:
# "Applying db.0108_githubwebhookevent... OK"
# "Applying db.0109_githubsyncjob... OK"
```

**Si las migraciones NO se aplicaron automáticamente:**

```bash
# Ejecutar migraciones manualmente
docker-compose -f docker-compose-local.yml exec api python manage.py migrate

# O reiniciar el migrator
docker-compose -f docker-compose-local.yml up migrator
```

### Paso 6: Verificar que Todo Funciona

```bash
# Verificar logs del API
docker-compose -f docker-compose-local.yml logs -f api

# Deberías ver:
# "Starting development server at http://0.0.0.0:8000/"
# "Quit the server with CONTROL-C."

# Verificar logs del worker (Celery)
docker-compose -f docker-compose-local.yml logs -f worker

# Deberías ver las tareas registradas:
# "github_mcp.sync_repository"
# "github_mcp.periodic_sync_all"
# etc.

# Verificar logs del beat (Scheduler)
docker-compose -f docker-compose-local.yml logs -f beat-worker
```

### Paso 7: Probar la API

```bash
# Desde WSL o desde Windows, probar el endpoint de health
curl http://localhost:8000/api/health/

# Deberías recibir una respuesta JSON
```

---

## 🧪 Ejecutar Tests

### Tests de MCP Services

```bash
# Ejecutar tests dentro del contenedor
docker-compose -f docker-compose-local.yml exec api pytest plane/tests/services/mcp/ -v

# Resultado esperado:
# ==================== 144 passed ====================
```

### Tests de API Endpoints

```bash
# Tests de integración
docker-compose -f docker-compose-local.yml exec api pytest plane/tests/views/integration/ -v

# Tests de webhooks
docker-compose -f docker-compose-local.yml exec api pytest plane/tests/views/webhook/ -v
```

### Tests con Coverage

```bash
# Con reporte de cobertura
docker-compose -f docker-compose-local.yml exec api pytest plane/tests/services/mcp/ \
  --cov=plane.app.services.mcp \
  --cov-report=term-missing \
  --cov-report=html

# El reporte HTML estará en: apps/api/htmlcov/index.html
```

---

## 🔍 Comandos Útiles

### Ver Logs en Tiempo Real

```bash
# Todos los servicios
docker-compose -f docker-compose-local.yml logs -f

# Solo API
docker-compose -f docker-compose-local.yml logs -f api

# Solo Worker
docker-compose -f docker-compose-local.yml logs -f worker

# Solo Beat
docker-compose -f docker-compose-local.yml logs -f beat-worker
```

### Ejecutar Comandos Django

```bash
# Django shell
docker-compose -f docker-compose-local.yml exec api python manage.py shell

# Crear superusuario
docker-compose -f docker-compose-local.yml exec api python manage.py createsuperuser

# Ver migraciones
docker-compose -f docker-compose-local.yml exec api python manage.py showmigrations

# Aplicar migraciones específicas
docker-compose -f docker-compose-local.yml exec api python manage.py migrate db 0108
docker-compose -f docker-compose-local.yml exec api python manage.py migrate db 0109
```

### Acceder al Contenedor

```bash
# Bash dentro del contenedor API
docker-compose -f docker-compose-local.yml exec api bash

# Ahora estás dentro del contenedor, puedes hacer:
# - python manage.py ...
# - pytest ...
# - cat .env
# - etc.

# Para salir:
exit
```

### Reiniciar Servicios

```bash
# Reiniciar un servicio específico
docker-compose -f docker-compose-local.yml restart api

# Reiniciar todos
docker-compose -f docker-compose-local.yml restart

# Detener todos
docker-compose -f docker-compose-local.yml stop

# Iniciar de nuevo
docker-compose -f docker-compose-local.yml start
```

### Limpiar y Reconstruir

```bash
# Detener y eliminar contenedores
docker-compose -f docker-compose-local.yml down

# Detener, eliminar contenedores Y volúmenes (CUIDADO: borra la BD)
docker-compose -f docker-compose-local.yml down -v

# Reconstruir imágenes (si cambias Dockerfile)
docker-compose -f docker-compose-local.yml build

# Reconstruir y reiniciar
docker-compose -f docker-compose-local.yml up -d --build
```

---

## 🗄️ Acceder a la Base de Datos

### Desde WSL

```bash
# Conectar a PostgreSQL
docker-compose -f docker-compose-local.yml exec plane-db psql -U plane -d plane

# Ahora estás en psql, puedes hacer:
\dt github_*

# Deberías ver las tablas:
# - github_repositories
# - github_repository_syncs
# - github_issue_syncs
# - github_comment_syncs
# - github_webhook_events  (NUEVA)
# - github_sync_jobs       (NUEVA)

# Ver datos de una tabla
SELECT * FROM github_webhook_events LIMIT 5;

# Salir
\q
```

### Desde Windows (GUI)

Puedes usar cualquier cliente PostgreSQL (DBeaver, pgAdmin, etc.):

```
Host: localhost
Port: 5432
Database: plane
User: plane
Password: plane
```

---

## 📊 Monitorear Servicios

### RabbitMQ Management UI

```
URL: http://localhost:15672
User: plane
Password: plane
```

### MinIO Console

```
URL: http://localhost:9090
User: access-key (del .env)
Password: secret-key (del .env)
```

### Redis

```bash
# Conectar a Redis
docker-compose -f docker-compose-local.yml exec plane-redis redis-cli

# Ver keys
KEYS *

# Ver una key específica
GET github_sync_job_12345

# Salir
exit
```

---

## 🧪 Verificación Completa

### Checklist de Verificación

```bash
# 1. Servicios corriendo
docker-compose -f docker-compose-local.yml ps
# Todos deberían estar "Up"

# 2. Migraciones aplicadas
docker-compose -f docker-compose-local.yml exec api python manage.py showmigrations | grep -E "(0108|0109)"
# Ambas deberían tener [X]

# 3. API responde
curl http://localhost:8000/api/health/
# Debería retornar JSON

# 4. Worker tiene tareas GitHub MCP
docker-compose -f docker-compose-local.yml logs worker | grep github_mcp
# Deberías ver las 5 tareas registradas

# 5. Tests pasan
docker-compose -f docker-compose-local.yml exec api pytest plane/tests/services/mcp/ -v
# Deberían pasar 144 tests
```

---

## 🔧 Troubleshooting

### Problema: Contenedores no inician

```bash
# Ver logs de error
docker-compose -f docker-compose-local.yml logs

# Ver un servicio específico
docker-compose -f docker-compose-local.yml logs api
```

### Problema: Puerto ya en uso

```bash
# Ver qué está usando el puerto
netstat -ano | findstr :8000

# Cambiar el puerto en docker-compose-local.yml:
# ports:
#   - "8001:8000"  # Cambiar 8000 a 8001
```

### Problema: Migraciones no se aplican

```bash
# Ejecutar manualmente
docker-compose -f docker-compose-local.yml exec api python manage.py migrate

# Ver el error completo
docker-compose -f docker-compose-local.yml logs migrator
```

### Problema: Tests fallan

```bash
# Verificar que pytest-asyncio está instalado
docker-compose -f docker-compose-local.yml exec api pip list | grep pytest-asyncio

# Instalar si falta
docker-compose -f docker-compose-local.yml exec api pip install pytest-asyncio==0.21.0

# Reconstruir imagen si es necesario
docker-compose -f docker-compose-local.yml build api
```

---

## 🎯 Probar la Integración GitHub MCP

### 1. Crear un Superusuario

```bash
docker-compose -f docker-compose-local.yml exec api python manage.py createsuperuser
```

### 2. Obtener Token de Autenticación

```bash
# Desde Django shell
docker-compose -f docker-compose-local.yml exec api python manage.py shell

# Dentro del shell:
from rest_framework.authtoken.models import Token
from plane.db.models import User

user = User.objects.filter(is_staff=True).first()
token, created = Token.objects.get_or_create(user=user)
print(f"Token: {token.key}")
exit()
```

### 3. Probar Endpoint de Status

```bash
# Desde WSL o Windows
curl http://localhost:8000/api/workspaces/default/integrations/github-mcp/status/ \
  -H "Authorization: Bearer TU_TOKEN_AQUI"

# Si no hay integración configurada, deberías ver:
# {"detail": "GitHub MCP integration not configured for this workspace"}
# Esto es CORRECTO - significa que el endpoint funciona!
```

### 4. Probar OAuth Flow

Abre en tu navegador:
```
http://localhost:8000/api/workspaces/default/integrations/github-mcp/oauth/authorize
```

Deberías ser redirigido a GitHub para autorizar.

---

## 📝 Notas Importantes

### Archivos Importantes

- **`.env`**: Variables de entorno (ya configuradas con GitHub OAuth)
- **`docker-compose-local.yml`**: Configuración de servicios
- **`apps/api/.env`**: Configuración específica del API

### Volúmenes Docker

Los datos persisten en volúmenes Docker:
- `pgdata`: Base de datos PostgreSQL
- `redisdata`: Datos de Redis
- `uploads`: Archivos subidos (MinIO)
- `rabbitmq_data`: Datos de RabbitMQ

**IMPORTANTE**: Si haces `docker-compose down -v`, SE BORRAN todos los datos.

### Código en Tiempo Real

El código en `C:\tools\plane\plane-app\apps\api` está montado como volumen,
por lo que cualquier cambio que hagas se refleja inmediatamente en el contenedor
(no necesitas reconstruir la imagen).

---

## ✅ Estado Final Esperado

Después de seguir esta guía, deberías tener:

- ✅ 7 contenedores corriendo (db, redis, mq, minio, api, worker, beat-worker)
- ✅ Migraciones 0108 y 0109 aplicadas
- ✅ API accesible en http://localhost:8000
- ✅ 144 tests de MCP pasando
- ✅ Celery worker con tareas GitHub MCP registradas
- ✅ Celery beat programando tareas periódicas
- ✅ Endpoints GitHub MCP respondiendo

---

## 🚀 Siguiente Paso

Una vez que todo esté corriendo:

1. **Probar la integración** siguiendo `NEXT_STEPS_IMPLEMENTATION.md`
2. **Conectar un repositorio** de GitHub
3. **Ejecutar un sync** y ver que funciona
4. **Configurar webhooks** en GitHub

Para más detalles, consulta:
- `DEPLOYMENT_GUIDE_GITHUB_MCP.md`
- `NEXT_STEPS_IMPLEMENTATION.md`

---

**¿Problemas?** Revisa la sección de Troubleshooting o consulta los logs de los contenedores.
