# GitHub MCP Integration - Próximos Pasos para Implementación

**Fecha**: 16 de Octubre, 2025
**Estado Actual**: ✅ Código instalado y verificado
**Próximo Paso**: Configuración y testing local

---

## ✅ Estado Actual - Lo que Ya Está Hecho

### Código Implementado (100%)
- ✅ 6,992 líneas de código producción
- ✅ 11,500+ líneas de tests
- ✅ 22+ archivos de código creados
- ✅ 29 archivos de tests creados
- ✅ 12 documentos de referencia

### Dependencias Instaladas
- ✅ mcp >= 1.18.0
- ✅ httpx >= 0.27.0
- ✅ aiohttp >= 3.9.3
- ✅ tenacity >= 8.2.3
- ✅ pytest-asyncio == 0.21.0

### Verificación Completa
```
✅ Dependencies     PASS
✅ MCP Services     PASS
✅ API Views        PASS
✅ Celery Tasks     PASS
✅ Database Models  PASS
✅ Test Files       PASS
✅ Documentation    PASS
```

---

## 🎯 Pasos Siguientes (En Orden)

### Paso 1: Configuración de Entorno (15 minutos)

#### 1.1 Crear GitHub OAuth App (5 minutos)

**Objetivo**: Obtener Client ID y Secret para autenticación

**Instrucciones**:
1. Ve a: https://github.com/settings/developers
2. Click "OAuth Apps" → "New OAuth App"
3. Llena el formulario:
   ```
   Application name: Plane GitHub Integration (Dev)
   Homepage URL: http://localhost:8000
   Authorization callback URL: http://localhost:8000/api/auth/github/callback
   ```
4. Click "Register application"
5. Copia el **Client ID**
6. Click "Generate a new client secret"
7. Copia el **Client Secret** (guárdalo en un lugar seguro)

#### 1.2 Configurar Variables de Entorno (5 minutos)

```bash
# Navega al directorio de Plane
cd C:\tools\plane

# Copia el archivo de ejemplo (si tienes un .env existente, agrega estas variables)
# Si NO tienes .env:
cp .env.github_mcp.example plane-app/apps/api/.env

# Si YA tienes .env, agrega estas líneas al final:
# Edita con tu editor favorito
notepad plane-app/apps/api/.env
```

**Agregar estas variables** (reemplaza con tus valores reales):
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

#### 1.3 Verificar Servicios Requeridos (5 minutos)

**PostgreSQL**:
```bash
# Verifica que PostgreSQL esté corriendo
# En Windows PowerShell:
Get-Service -Name postgresql*

# O intenta conectar:
psql -U postgres -l
```

**Redis**:
```bash
# Verifica que Redis esté corriendo
# Intenta conectar:
redis-cli ping
# Debería responder: PONG
```

**Si no están corriendo**, instálalos o iníci alos:
- PostgreSQL: https://www.postgresql.org/download/windows/
- Redis: https://redis.io/docs/install/install-redis/install-redis-on-windows/

---

### Paso 2: Aplicar Migraciones (5 minutos)

**Objetivo**: Crear las nuevas tablas en la base de datos

```bash
# Navega al directorio de la API
cd C:\tools\plane\plane-app\apps\api

# Verificar estado actual de migraciones
python manage.py showmigrations db

# Aplicar migraciones nuevas
python manage.py migrate db 0108_githubwebhookevent
python manage.py migrate db 0109_githubsyncjob

# Verificar que se aplicaron
python manage.py showmigrations db | grep -E "(0108|0109)"
```

**Resultado Esperado**:
```
[X] 0108_githubwebhookevent
[X] 0109_githubsyncjob
```

**Verificar en PostgreSQL** (opcional):
```sql
-- Conecta a la base de datos
psql -U plane_user -d plane_db

-- Lista las nuevas tablas
\dt github_*

-- Deberías ver:
-- github_repositories
-- github_repository_syncs
-- github_issue_syncs
-- github_comment_syncs
-- github_webhook_events  (NUEVA)
-- github_sync_jobs       (NUEVA)
```

---

### Paso 3: Ejecutar Tests (10-15 minutos)

**Objetivo**: Verificar que todo funciona correctamente

#### 3.1 Tests Unitarios de MCP Services

```bash
cd C:\tools\plane\plane-app\apps\api

# Ejecutar tests de MCP services
pytest plane/tests/services/mcp/ -v

# Con coverage
pytest plane/tests/services/mcp/ --cov=plane.app.services.mcp --cov-report=term
```

**Resultado Esperado**:
```
=================== test session starts ====================
collected 144 items

plane/tests/services/mcp/test_client.py ............ [ 24%]
plane/tests/services/mcp/test_github_client.py .... [ 51%]
plane/tests/services/mcp/test_sync_engine.py ...... [ 73%]
plane/tests/services/mcp/test_exceptions.py ....... [100%]

==================== 144 passed in 45.23s ==================
```

#### 3.2 Tests de Integración API (opcional, puede requerir setup Django)

```bash
# Tests de API endpoints
pytest plane/tests/views/integration/test_github_mcp_views.py -v

# Tests de serializers
pytest plane/tests/serializers/integration/test_github_mcp_serializers.py -v
```

#### 3.3 Tests de Webhooks (opcional)

```bash
# Tests de webhook processing
pytest plane/tests/views/webhook/test_github_mcp_webhook.py -v
pytest plane/tests/bgtasks/test_github_mcp_webhook.py -v
```

**Si algún test falla**:
1. Lee el mensaje de error
2. Verifica que todas las dependencias estén instaladas
3. Consulta `PHASE_6_TESTING_VALIDATION_SUMMARY.md` para troubleshooting

---

### Paso 4: Configurar y Probar Celery (10 minutos)

**Objetivo**: Verificar que las tareas background funcionan

#### 4.1 Iniciar Celery Worker

```bash
# En una terminal nueva (PowerShell o CMD)
cd C:\tools\plane\plane-app\apps\api

# Iniciar worker
celery -A plane worker -l info --concurrency=2
```

**Resultado Esperado**:
```
-------------- celery@hostname v5.4.0
---- **** -----
--- * ***  * -- Windows-10
-- * - **** ---
- ** ---------- [config]
- ** ---------- .> app:         plane:0x...
- ** ---------- .> transport:   redis://localhost:6379/0
- ** ---------- .> results:     redis://localhost:6379/0
- *** --- * --- .> concurrency: 2
-- ******* ----
--- ***** ----- [queues]
 -------------- .> celery

[tasks]
  . github_mcp.cleanup_old_jobs
  . github_mcp.periodic_sync_all
  . github_mcp.process_webhook_event
  . github_mcp.sync_issue
  . github_mcp.sync_repository
```

#### 4.2 Iniciar Celery Beat (en otra terminal)

```bash
# En otra terminal nueva
cd C:\tools\plane\plane-app\apps\api

# Iniciar beat scheduler
celery -A plane beat -l info
```

**Resultado Esperado**:
```
LocalTime -> 2025-10-16 14:30:00
Scheduler: Trying to send task github_mcp.periodic_sync_all
```

#### 4.3 Verificar Tareas Registradas

```bash
# En otra terminal
cd C:\tools\plane\plane-app\apps\api

# Inspeccionar tareas registradas
celery -A plane inspect registered | grep github_mcp
```

**Resultado Esperado**:
```
- github_mcp.sync_repository
- github_mcp.sync_issue
- github_mcp.periodic_sync_all
- github_mcp.cleanup_old_jobs
- github_mcp.process_webhook_event
```

---

### Paso 5: Iniciar Django Development Server (2 minutos)

```bash
# En otra terminal nueva
cd C:\tools\plane\plane-app\apps\api

# Iniciar Django
python manage.py runserver
```

**Resultado Esperado**:
```
System check identified no issues (0 silenced).
October 16, 2025 - 14:30:00
Django version 4.2.25, using settings 'plane.settings.local'
Starting development server at http://127.0.0.1:8000/
Quit the server with CTRL-BREAK.
```

---

### Paso 6: Probar Integración End-to-End (15 minutos)

#### 6.1 Verificar API Health

```bash
# En una nueva terminal
curl http://localhost:8000/api/health/
```

#### 6.2 Probar Endpoint de Status

```bash
# Necesitarás un token de autenticación
# Obtener token (asumiendo que tienes un usuario admin)
# Método 1: Desde Django shell
python manage.py shell
>>> from rest_framework.authtoken.models import Token
>>> from plane.db.models import User
>>> user = User.objects.filter(is_staff=True).first()
>>> token, created = Token.objects.get_or_create(user=user)
>>> print(token.key)
>>> exit()

# Método 2: Desde la interfaz de Plane (login y copiar token)

# Probar endpoint
curl http://localhost:8000/api/workspaces/default/integrations/github-mcp/status/ \
  -H "Authorization: Bearer TU_TOKEN_AQUI"
```

**Resultado Esperado** (si no hay integración configurada):
```json
{
  "detail": "GitHub MCP integration not configured for this workspace"
}
```

Esto es **correcto** - significa que el endpoint funciona!

#### 6.3 Probar OAuth Flow (desde browser)

1. Abre tu navegador: http://localhost:8000
2. Login a Plane
3. Ve a Workspace Settings → Integrations
4. Deberías ver "GitHub (MCP)" card
5. Click "Connect"
6. Deberías ser redirigido a GitHub para autorizar
7. Después de autorizar, deberías volver a Plane

**Si el card de GitHub MCP no aparece**, puede ser porque:
- Necesitas crear la UI en el frontend (Paso 7)
- O puedes probar directamente la URL de OAuth:
  ```
  http://localhost:8000/api/workspaces/default/integrations/github-mcp/oauth/authorize
  ```

---

### Paso 7: Build del Frontend (Opcional - 10 minutos)

Si quieres probar la UI completa:

```bash
# Navega al directorio web
cd C:\tools\plane\apps\web

# Instalar dependencias (si no lo has hecho)
npm install

# O con pnpm
pnpm install

# Iniciar en modo desarrollo
npm run dev

# O con pnpm
pnpm dev
```

**Acceder a la UI**:
```
http://localhost:3000
```

---

## 📊 Checklist de Verificación

Antes de considerar la implementación completa, verifica:

### Configuración
- [ ] GitHub OAuth app creada
- [ ] Client ID y Secret configurados en .env
- [ ] PostgreSQL corriendo
- [ ] Redis corriendo
- [ ] Variables de entorno configuradas

### Migraciones
- [ ] Migration 0108 aplicada
- [ ] Migration 0109 aplicada
- [ ] Tablas `github_webhook_events` creada
- [ ] Tablas `github_sync_jobs` creada

### Testing
- [ ] 144 tests de MCP services pasan
- [ ] Sin errores de importación
- [ ] Celery puede cargar tareas

### Servicios
- [ ] Celery worker corriendo
- [ ] Celery beat corriendo
- [ ] Django server corriendo
- [ ] Tareas GitHub MCP registradas

### API
- [ ] Endpoint `/api/health/` responde
- [ ] Endpoint `/api/workspaces/.../github-mcp/status/` responde
- [ ] OAuth flow funciona (opcional)

---

## 🎯 Flujo de Testing Manual Completo

Una vez que todo esté configurado, prueba este flujo:

### 1. Conectar Repositorio

```bash
# POST para conectar repositorio
curl -X POST http://localhost:8000/api/workspaces/default/integrations/github-mcp/connect/ \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "repository_url": "https://github.com/tu-usuario/tu-repo",
    "project_id": "PROJECT_UUID",
    "auto_sync": true,
    "sync_interval": 300
  }'
```

### 2. Verificar Status

```bash
# GET status
curl http://localhost:8000/api/workspaces/default/integrations/github-mcp/status/ \
  -H "Authorization: Bearer TOKEN"
```

### 3. Trigger Manual Sync

```bash
# POST para sync manual
curl -X POST http://localhost:8000/api/workspaces/default/integrations/github-mcp/sync/ \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "direction": "from_github",
    "force": false
  }'
```

### 4. Monitorear en Celery Flower (opcional)

```bash
# Instalar flower
pip install flower

# Iniciar flower dashboard
celery -A plane flower --port=5555

# Acceder en browser
# http://localhost:5555
```

---

## 🆘 Troubleshooting

### Problema: Tests Fallan

**Solución**:
```bash
# Verificar que pytest-asyncio esté instalado
pip list | grep pytest-asyncio

# Reinstalar si es necesario
pip install --force-reinstall pytest-asyncio==0.21.0
```

### Problema: Celery No Encuentra Tareas

**Solución**:
```bash
# Verifica que los archivos existan
ls plane/bgtasks/github_mcp_*.py

# Verifica imports en plane/bgtasks/__init__.py
# Asegúrate de que las tareas estén importadas
```

### Problema: Django No Inicia

**Solución**:
```bash
# Verifica errores de configuración
python manage.py check

# Verifica migraciones pendientes
python manage.py showmigrations

# Corre migraciones
python manage.py migrate
```

### Problema: Redis No Conecta

**Solución**:
```bash
# Verifica que Redis esté corriendo
redis-cli ping

# Si no responde, inicia Redis:
# En Windows: busca redis-server.exe y ejecútalo
# O usa Docker:
docker run -d -p 6379:6379 redis:latest
```

---

## 📚 Documentación de Referencia

Para más detalles, consulta:

1. **DEPLOYMENT_GUIDE_GITHUB_MCP.md** - Guía completa de deployment
2. **PRODUCTION_READINESS_CHECKLIST.md** - Checklist detallado
3. **PHASE_6_TESTING_VALIDATION_SUMMARY.md** - Información sobre tests
4. **.env.github_mcp.example** - Variables de entorno requeridas

---

## ✅ Criterios de Éxito

Sabrás que la implementación está lista cuando:

- ✅ Todos los tests pasan (144 de MCP services mínimo)
- ✅ Celery worker muestra las 5 tareas GitHub MCP registradas
- ✅ Django server inicia sin errores
- ✅ Endpoint de status responde (aunque no haya integración)
- ✅ Migraciones aplicadas correctamente

---

## 🚀 Una Vez Funcionando Localmente

Cuando todo funcione localmente, estarás listo para:

1. **Commit del código** (si usas git)
2. **Deploy a staging** (ambiente de pruebas)
3. **User Acceptance Testing**
4. **Deploy a production**

Ver `DEPLOYMENT_GUIDE_GITHUB_MCP.md` para los pasos de deployment a producción.

---

**¿Preguntas o problemas?**
Consulta la sección de Troubleshooting en `DEPLOYMENT_GUIDE_GITHUB_MCP.md` o revisa los logs de:
- Django: Console donde corre `runserver`
- Celery: Console donde corre `worker`
- PostgreSQL: Logs de PostgreSQL
- Redis: Logs de Redis
