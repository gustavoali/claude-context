# YouTube RAG MVP - Documentación del Proyecto

## 📋 Información General

### Descripción del Proyecto
Sistema de RAG (Retrieval-Augmented Generation) para análisis semántico de videos de YouTube con capacidades de búsqueda avanzada, transcripción automática y OCR de imágenes.

### Estado Actual
- **Backend**: ✅ Operativo en http://localhost:8000
- **Frontend**: ✅ Operativo en http://localhost:3003
- **Base de Datos**: ✅ SQLite configurada y tablas creadas
- **Autenticación**: ✅ Google OAuth integrado completamente

---

## 🏗️ Arquitectura del Sistema

### Backend (FastAPI)
```
backend/
├── app/
│   ├── main.py                    # Punto de entrada principal
│   ├── main_simple.py            # Versión simplificada (actualmente en uso)
│   ├── api/
│   │   └── api_v1/
│   │       └── endpoints/
│   │           └── auth.py       # Endpoints de autenticación OAuth
│   ├── core/
│   │   ├── config.py            # Configuración de la aplicación
│   │   ├── database.py          # Configuración de base de datos
│   │   └── security.py          # JWT y seguridad
│   ├── models/
│   │   └── user.py              # Modelo de usuario con OAuth
│   └── services/
│       └── oauth.py             # Servicio Google OAuth
```

### Frontend (React + TypeScript + Vite)
```
frontend/src/
├── App.tsx                       # Componente principal con rutas protegidas
├── components/
│   ├── Layout/Layout.tsx         # Layout principal con navegación
│   └── LoadingSpinner/           # Componente de carga
├── hooks/
│   └── useAuth.ts               # Hook de autenticación
├── pages/
│   ├── LoginPage.tsx            # Página de login con OAuth
│   ├── DashboardPage.tsx        # Dashboard principal
│   └── [otras páginas...]
├── services/
│   └── api.ts                   # Cliente API con interceptores
├── store/
│   └── index.ts                 # Estados globales (Zustand)
└── types/
    └── index.ts                 # Definiciones TypeScript
```

---

## 🔐 Sistema de Autenticación

### Google OAuth 2.0 - Implementación Completa

#### Backend Components
1. **OAuth Service** (`backend/app/services/oauth.py`)
   - `get_authorization_url()`: Genera URL de autorización Google
   - `exchange_code_for_tokens()`: Intercambia código por tokens
   - `get_user_info()`: Obtiene información del usuario
   - `authenticate_with_google()`: Proceso completo de autenticación

2. **API Endpoints** (`backend/app/api/api_v1/endpoints/auth.py`)
   - `GET /api/v1/auth/google`: Obtiene URL de autorización
   - `POST /api/v1/auth/google/exchange`: Intercambia código OAuth
   - `POST /api/v1/auth/login`: Login tradicional
   - `POST /api/v1/auth/register`: Registro de usuarios
   - `GET /api/v1/auth/me`: Perfil del usuario

#### Frontend Components
1. **LoginPage** (`frontend/src/pages/LoginPage.tsx`)
   - Botón "Continue with Google" para OAuth
   - Formulario tradicional email/password
   - Manejo de callbacks OAuth automático
   - Estados de loading y error

2. **Auth Hook** (`frontend/src/hooks/useAuth.ts`)
   - `handleGoogleLogin()`: Inicia flujo OAuth
   - `handleGoogleCallback()`: Procesa callback OAuth
   - `handleLogin()` y `handleRegister()`: Métodos tradicionales
   - Inicialización automática con token guardado

3. **Protected Routes** (`frontend/src/App.tsx`)
   - `ProtectedRoute` component para rutas autenticadas
   - Redirección automática a /login si no autenticado
   - LoadingSpinner durante verificación de auth

### Base de Datos
```sql
-- Tabla users actualizada para OAuth
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    hashed_password VARCHAR(255), -- Nullable para OAuth
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    is_active BOOLEAN DEFAULT 1,
    is_superuser BOOLEAN DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Campos OAuth
    google_id VARCHAR(100) UNIQUE, -- ID único de Google
    auth_provider VARCHAR(20) DEFAULT 'local' -- 'local' o 'google'
);
```

---

## 🛠️ Configuración y Instalación

### Variables de Entorno (.env)
```env
# Base de datos
DATABASE_URL=sqlite:///./youtube_rag.db

# JWT
SECRET_KEY=your-super-secret-key-here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Google OAuth
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
GOOGLE_REDIRECT_URI=http://localhost:8000/auth/google/callback
```

### Instalación Backend
```bash
cd backend
pip install -r requirements.txt
PYTHONPATH=. python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

### Instalación Frontend
```bash
cd frontend
npm install
npm run dev  # Se ejecuta en puerto 3003
```

---

## 🔄 Estado de Desarrollo

### ✅ Completado
1. **Infraestructura Base**
   - Configuración FastAPI + React
   - Base de datos SQLite
   - Sistema de rutas y navegación

2. **Autenticación Google OAuth**
   - Servicio OAuth backend completo
   - Endpoints API de autenticación
   - Componente LoginPage con UI completa
   - Hook de autenticación con manejo de estados
   - Rutas protegidas implementadas
   - Intercepción y manejo de tokens JWT

3. **Stores y Estado Global**
   - AuthStore con integración OAuth
   - VideoStore actualizado con API client
   - SearchStore para búsquedas semánticas
   - JobStore para trabajos de procesamiento

4. **Upload de Videos - Frontend**
   - ✅ Página de upload completa (`frontend/src/pages/UploadPage.tsx`)
   - ✅ Interfaz con tabs para archivos locales y URLs de YouTube
   - ✅ Drag & drop para subida de archivos con validación
   - ✅ Validación de archivos (tipo de video, tamaño máx. 500MB)
   - ✅ Soporte para URLs de YouTube con validación regex
   - ✅ Configuración avanzada de procesamiento:
     - Transcripción automática
     - OCR de imágenes
     - Extracción de frames configurables (intervalo personalizable)
     - Generación de resúmenes automáticos
   - ✅ Estados de loading, error y éxito con UX completa
   - ✅ Lista de archivos seleccionados con opción de eliminar
   - ✅ Redirección automática a página de videos post-upload

5. **Upload de Videos - Backend**
   - ✅ Endpoints API completos (`backend/app/api/api_v1/endpoints/videos.py`)
   - ✅ Subida de archivos con validación (500MB max, tipos soportados)
   - ✅ Procesamiento de URLs de YouTube con yt-dlp
   - ✅ Validación de URLs y extracción de metadata
   - ✅ Almacenamiento en base de datos con tracking de progreso
   - ✅ Autenticación y autorización con JWT
   - ✅ Sistema completo de CRUD para videos:
     - `GET /videos/` - Listado con filtros y paginación
     - `POST /videos/upload` - Subida de archivos
     - `POST /videos/from-url` - Procesamiento desde URL
     - `GET /videos/{id}` - Obtener detalles
     - `PATCH /videos/{id}` - Actualizar metadata
     - `DELETE /videos/{id}` - Eliminar video
     - `POST /videos/{id}/reprocess` - Reprocesar con nueva config

### 🚧 En Progreso / Pendiente
1. **Sistema de Procesamiento en Background**
   - Tasks para procesamiento de videos subidos
   - Pipeline de descarga de YouTube
   - Integración con Celery/Redis

2. **Pipeline de Procesamiento**
   - Transcripción automática de audio
   - OCR de imágenes/frames
   - Extracción de embeddings semánticos

3. **Búsqueda Semántica**
   - Implementación de vector database
   - Algoritmos de similarity search
   - Interfaz de búsqueda avanzada

---

## 📊 Logs y Monitoreo

### Backend Logs
- Servidor corriendo en puerto 8000
- Conexión a base de datos exitosa
- Peticiones OAuth registradas correctamente

### Frontend Logs  
- Servidor Vite corriendo en puerto 3003
- Hot reload funcionando
- Módulos de autenticación cargados correctamente

---

## 🐛 Problemas Resueltos

1. **Unicode Encoding Error**: Emojis no compatibles con consola Windows
   - **Solución**: Reemplazados con texto ASCII

2. **SQLAlchemy Compatibility**: JSONB no soportado en SQLite
   - **Solución**: Cambiado a JSON para compatibilidad

3. **Import Resolution**: Alias '@' no funcionaba en Vite
   - **Solución**: Configurado vite.config.ts correctamente

4. **Authentication Flow**: Rutas no protegidas inicialmente
   - **Solución**: Implementadas rutas protegidas con redirección automática

---

## 🎯 Próximos Pasos

1. **Video Upload Implementation**
   - Crear componente de upload
   - Implementar validación de archivos
   - Configurar almacenamiento

2. **Processing Pipeline**
   - Integrar servicios de transcripción
   - Implementar OCR para frames
   - Crear sistema de jobs/workers

3. **Semantic Search**
   - Configurar vector database
   - Implementar embeddings generation
   - Crear interfaz de búsqueda

---

*Documentación actualizada: $(date)*