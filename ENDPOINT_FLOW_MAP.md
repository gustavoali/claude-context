# Mapa de Flujo de Endpoints - YouTube RAG API

## Fecha: 2025-09-20
## Estado: POST-LIMPIEZA - CÓDIGO UNIFICADO

---

## 🎯 SISTEMA LIMPIO - CERO DUPLICACIÓN

### ✅ PRINCIPIO APLICADO
**UN ENDPOINT = UN ARCHIVO = UNA FUNCIÓN ESPECÍFICA**

---

## 📍 ENDPOINTS ACTIVOS Y SUS ARCHIVOS

### 1. AUTENTICACIÓN - `/api/v1/auth`
**Archivo**: `backend/app/api/api_v1/endpoints/auth.py` (14,848 bytes)

**Endpoints**:
- `POST /auth/login` → Autenticación con email/password
- `POST /auth/register` → Registro de nuevos usuarios
- `GET /auth/google` → Inicio de OAuth con Google
- `POST /auth/google/callback` → Callback de Google OAuth
- `POST /auth/refresh` → Renovación de tokens
- `POST /auth/logout` → Cierre de sesión
- `GET /auth/me` → Información del usuario actual

**Flujo de Código**:
```
Request → auth.py → authenticate_user() → create_tokens_for_user() → Database
```

**Dependencias**:
- `app.core.security` - Manejo de tokens JWT
- `app.services.oauth` - Integración con Google
- `app.models.user` - Modelo de usuario en BD

---

### 2. USUARIOS - `/api/v1/users`
**Archivo**: `backend/app/api/api_v1/endpoints/users.py` (2,402 bytes)

**Endpoints**:
- `GET /users/me` → Perfil del usuario actual
- `PUT /users/me` → Actualizar perfil

**Flujo de Código**:
```
Request → users.py → get_current_active_user() → Database
```

---

### 3. VIDEOS - `/api/v1/videos`
**Archivo**: `backend/app/api/api_v1/endpoints/videos.py` (33,026 bytes)

**Endpoints**:
- `GET /videos/` → Listar videos del usuario
- `POST /videos/` → Subir nuevo video
- `GET /videos/{video_id}` → Obtener video específico
- `PUT /videos/{video_id}` → Actualizar video
- `DELETE /videos/{video_id}` → Eliminar video
- `POST /videos/{video_id}/reprocess` → Reprocesar video

**Flujo de Código**:
```
Request → videos.py → JobManager → ProcessingService → Database
```

**Dependencias**:
- `app.services.job_manager` - Gestión de trabajos de procesamiento
- `app.services.storage` - Almacenamiento de archivos
- `app.models.video` - Modelo de video en BD

---

### 4. BÚSQUEDA - `/api/v1/search`
**Archivo**: `backend/app/api/api_v1/endpoints/search.py` (18,616 bytes)

**Endpoints**:
- `POST /search/` → Búsqueda en videos usando RAG
- `GET /search/history` → Historial de búsquedas
- `GET /search/suggestions` → Sugerencias de búsqueda

**Flujo de Código**:
```
Request → search.py → EmbeddingService → VectorSearch → Database
```

**Dependencias**:
- `app.services.embedding` - Generación de embeddings
- `app.services.vector_search` - Búsqueda vectorial
- `app.models.search` - Modelos de búsqueda

---

### 5. TRABAJOS - `/api/v1/jobs`
**Archivo**: `backend/app/api/api_v1/endpoints/jobs.py` (16,881 bytes)

**Endpoints**:
- `GET /jobs/` → Listar trabajos de procesamiento
- `GET /jobs/{job_id}` → Estado de trabajo específico
- `POST /jobs/{job_id}/cancel` → Cancelar trabajo

**Flujo de Código**:
```
Request → jobs.py → JobManager → ProcessingJob → Database
```

---

### 6. WEBSOCKETS - `/ws`
**Archivo**: `backend/app/api/api_v1/endpoints/websocket.py` (3,961 bytes)

**Endpoints**:
- `WS /chat` → Chat en tiempo real
- `WS /notifications` → Notificaciones push

**Flujo de Código**:
```
WebSocket → websocket.py → ConnectionManager → BroadcastService
```

---

### 7. ARCHIVOS - `/api/v1/files`
**Archivo**: `backend/app/api/api_v1/endpoints/files.py` (14,871 bytes)

**Endpoints**:
- `GET /files/{file_id}` → Descargar archivo
- `POST /files/upload` → Subir archivo
- `DELETE /files/{file_id}` → Eliminar archivo

**Flujo de Código**:
```
Request → files.py → StorageService → FileSystem/S3 → Database
```

---

## 🗂️ ORGANIZACIÓN DE CÓDIGO LIMPIA

### Estructura Actual (POST-LIMPIEZA):
```
backend/app/api/api_v1/endpoints/
├── __init__.py
├── auth.py          ✅ ÚNICO - Autenticación completa
├── files.py         ✅ ÚNICO - Gestión de archivos
├── jobs.py          ✅ ÚNICO - Trabajos de procesamiento
├── search.py        ✅ ÚNICO - Búsqueda RAG
├── users.py         ✅ ÚNICO - Gestión de usuarios
├── videos.py        ✅ ÚNICO - CRUD de videos
└── websocket.py     ✅ ÚNICO - WebSockets completo
```

### Archivos Eliminados (DUPLICADOS):
```
❌ auth_simple.py      → Respaldado, implementación mock eliminada
❌ test_websocket.py   → Respaldado, funcionalidad integrada en websocket.py
❌ config_original.py  → Respaldado, reemplazado por config unificado
```

---

## 🔧 FLUJO DE REGISTRO DE ENDPOINTS

### En `app/api/api_v1/api.py`:
```python
from app.api.api_v1.endpoints import auth, videos, search, users, jobs, websocket, files

api_router = APIRouter()

# Registro ÚNICO de cada funcionalidad
api_router.include_router(auth.router, prefix="/auth", tags=["authentication"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(videos.router, prefix="/videos", tags=["videos"])
api_router.include_router(search.router, prefix="/search", tags=["search"])
api_router.include_router(jobs.router, prefix="/jobs", tags=["jobs"])
api_router.include_router(websocket.router, tags=["websocket"])
api_router.include_router(files.router, prefix="/files", tags=["files"])
```

### En `app/main.py`:
```python
# Registro del router principal
app.include_router(api_router, prefix=settings.API_V1_STR)
```

---

## 🎯 MAPA DE DEPENDENCIAS ACTIVAS

### Servicios Core:
```
app/core/
├── config.py        → Configuración unificada (ÚNICO)
├── database.py      → Conexión a BD
├── security.py      → JWT y autenticación
└── metrics.py       → Métricas y monitoring
```

### Servicios de Aplicación:
```
app/services/
├── job_manager.py           → Gestión de trabajos de procesamiento
├── oauth.py                 → Integración OAuth (Google)
├── storage/                 → Almacenamiento de archivos
├── embedding/               → Generación de embeddings
├── vector_search/           → Búsqueda vectorial
└── real_processing/         → Procesamiento real de videos
```

### Modelos de Base de Datos:
```
app/models/
├── user.py          → Usuario y autenticación
├── video.py         → Videos y metadatos
├── search.py        → Búsquedas y resultados
└── job.py           → Trabajos de procesamiento
```

---

## 📋 SCRIPTS ORGANIZADOS (POST-LIMPIEZA)

### Testing Scripts:
```
backend/scripts/testing/
├── test_admin_login.py
├── test_auth.py
├── test_basic_setup.py
├── test_api_directly.py     ← Movido desde root
├── test_crud_api.py         ← Movido desde root
├── test_improved_crud.py    ← Movido desde root
└── test_token_renewal.py    ← Movido desde root
```

### Root Scripts Organizados:
```
scripts/
├── testing/
│   ├── simple_test.py       ← Movido y organizado
│   ├── test_backend_api.py  ← Movido y organizado
│   └── test_client.py       ← Movido y organizado
├── video_processing/
│   ├── simple_transcript_generator.py
│   └── reprocess_*.py       ← Movidos y organizados
├── maintenance/
│   └── simple_video_check.py
├── backup_deprecated/
│   ├── video_crud_client.py         ← Versión original
│   └── video_crud_client_backup.py  ← Backup duplicado
└── video_crud_client.py     ← ÚNICO cliente (versión enhanced)
```

---

## ✅ GARANTÍAS POST-LIMPIEZA

### 1. CERO DUPLICACIÓN DE FUNCIONALIDAD
- ✅ Un solo archivo de autenticación
- ✅ Un solo archivo de configuración
- ✅ Un solo endpoint por funcionalidad
- ✅ Un solo cliente de testing

### 2. FLUJO DE CÓDIGO CLARO
- ✅ Cada endpoint tiene una función específica
- ✅ Dependencias claramente mapeadas
- ✅ Sin archivos "fantasma" o código muerto

### 3. ORGANIZACIÓN SISTEMÁTICA
- ✅ Scripts agrupados por función
- ✅ Tests en ubicaciones predecibles
- ✅ Backups conservados pero separados

### 4. PRINCIPIO APLICADO
- ✅ **UN SOLO PUNTO DE VERDAD** para cada funcionalidad
- ✅ **CÓDIGO ACTIVO IDENTIFICABLE** sin ambigüedad
- ✅ **MANTENIMIENTO SIMPLIFICADO** sin múltiples versiones

---

## 🔄 PROCESO DE VERIFICACIÓN CONTINUA

### Para verificar que no hay duplicación:
```bash
# Verificar endpoints únicos
ls backend/app/api/api_v1/endpoints/

# Verificar imports en API router
grep "include_router" backend/app/api/api_v1/api.py

# Verificar scripts organizados
find scripts/ -name "*.py" | sort
```

### Regla de Oro:
**Si encuentras dos archivos que hacen lo mismo → ELIMINAR UNO INMEDIATAMENTE**

---

**✅ SISTEMA COMPLETAMENTE LIMPIO Y SIN DUPLICACIÓN**
**✅ FLUJO DE CÓDIGO CLARO Y DOCUMENTADO**
**✅ PRINCIPIO "NO DUPLICACIÓN" APLICADO EXITOSAMENTE**