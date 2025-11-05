# YouTube RAG MVP - Roadmap de Implementación

## 📋 Información del Documento

**Versión:** 1.0
**Fecha:** 2025-01-05
**Tipo:** Roadmap Técnico de Implementación
**Estado:** Planificación Detallada

## 🎯 Estrategia de Implementación

### Enfoque por Fases
Implementación incremental con **releases funcionales** cada 1-2 semanas, permitiendo feedback temprano y ajustes de prioridades.

## 🚀 FASE 1: MVP Web Básico (Semanas 1-2)
**Objetivo:** Interfaz web funcional con Streamlit

### Sprint 1.1: Setup Base (Días 1-3)
```bash
# Estructura propuesta
youtube_rag_mvp/
├── streamlit_app/
│   ├── main.py              # App principal
│   ├── pages/               # Páginas múltiples
│   │   ├── upload.py       # Subida de videos
│   │   ├── search.py       # Búsqueda
│   │   └── results.py      # Resultados
│   ├── components/         # Componentes reutilizables
│   └── utils/              # Utilidades UI
├── docker/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── requirements-web.txt
└── config/
    └── streamlit_config.toml
```

**Tareas Específicas:**
- [ ] **Setup entorno Streamlit**
  ```bash
  pip install streamlit plotly pandas
  streamlit --version
  ```

- [ ] **Crear aplicación base**
  ```python
  # streamlit_app/main.py
  import streamlit as st
  
  st.set_page_config(
      page_title="YouTube RAG MVP",
      page_icon="🎥",
      layout="wide"
  )
  
  st.title("🎥 YouTube RAG - Búsqueda Inteligente de Videos")
  ```

- [ ] **Configurar navegación multipágina**
- [ ] **Integrar con FastAPI backend existente**
- [ ] **Setup Docker básico**

**Entregables Sprint 1.1:**
- ✅ Aplicación Streamlit funcional
- ✅ Navegación entre páginas
- ✅ Conexión con API existente
- ✅ Docker container básico

### Sprint 1.2: Funcionalidad Upload (Días 4-7)
**Tareas:**
- [ ] **Página de upload de videos**
  ```python
  # Componentes UI
  uploaded_file = st.file_uploader("Subir video", type=['mp4', 'avi', 'mov'])
  youtube_url = st.text_input("O ingresa URL de YouTube")
  every_seconds = st.slider("Frames cada X segundos", 2, 10, 4)
  ```

- [ ] **Progress tracking en tiempo real**
  ```python
  # Progress bar con WebSocket o polling
  progress_bar = st.progress(0)
  status_text = st.empty()
  
  # Update progress via session state
  if 'processing_status' in st.session_state:
      progress_bar.progress(st.session_state.processing_status)
  ```

- [ ] **Manejo de errores UI**
- [ ] **Validación de inputs**

**Entregables Sprint 1.2:**
- ✅ Upload funcional de videos
- ✅ Integración con pipeline existente
- ✅ Feedback visual de progreso
- ✅ Manejo básico de errores

### Sprint 1.3: Búsqueda y Resultados (Días 8-14)
**Tareas:**
- [ ] **Interface de búsqueda**
  ```python
  # Search interface
  query = st.text_input("Buscar en el video...", placeholder="¿De qué trata el video?")
  col1, col2 = st.columns([3, 1])
  
  with col1:
      video_selector = st.selectbox("Seleccionar video", available_videos)
  with col2:
      top_k = st.number_input("Resultados", 1, 20, 5)
  ```

- [ ] **Visualización de resultados**
  ```python
  # Results display
  for hit in text_results:
      with st.expander(f"[{hit['start']:.1f}s] Score: {hit['score']:.3f}"):
          st.write(hit['text'])
          st.audio(audio_segment)  # Si disponible
  
  # Image gallery
  st.subheader("Frames Relevantes")
  cols = st.columns(2)
  for i, img_hit in enumerate(image_results[:4]):
      with cols[i % 2]:
          st.image(img_hit['path'])
          st.caption(f"Score: {img_hit['score']:.3f}")
  ```

- [ ] **Filtros avanzados**
- [ ] **Export de resultados**

**Entregables Sprint 1.3:**
- ✅ Búsqueda funcional multimodal
- ✅ Visualización rica de resultados
- ✅ Filtros básicos de búsqueda
- ✅ Export CSV/JSON de resultados

## 🏗 FASE 2: Mejoras Operacionales (Semanas 3-4)
**Objetivo:** Procesamiento asíncrono y persistencia

### Sprint 2.1: Queue Asíncrono (Días 15-21)
**Tareas:**
- [ ] **Setup Celery + Redis**
  ```python
  # requirements adicionales
  celery>=5.3.0
  redis>=4.5.0
  flower>=1.2.0  # Monitoring UI
  ```

- [ ] **Refactor pipeline a tareas async**
  ```python
  # tasks/video_processing.py
  from celery import Celery
  
  app = Celery('youtube_rag')
  app.config_from_object('config.celery_config')
  
  @app.task(bind=True)
  def process_video_async(self, video_url, user_id, config):
      try:
          # Progress updates
          self.update_state(state='DOWNLOADING', meta={'progress': 10})
          # ... pipeline steps with progress updates
          return {'status': 'SUCCESS', 'video_id': result['video_id']}
      except Exception as e:
          return {'status': 'FAILURE', 'error': str(e)}
  ```

- [ ] **Job monitoring en Streamlit**
- [ ] **Queue dashboard con Flower**

**Entregables Sprint 2.1:**
- ✅ Procesamiento no-blocking
- ✅ Progress tracking real-time
- ✅ Error handling robusto
- ✅ Monitoring de jobs

### Sprint 2.2: Base de Datos (Días 22-28)
**Tareas:**
- [ ] **Setup PostgreSQL**
  ```sql
  -- Schema inicial
  CREATE TABLE videos (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      video_id VARCHAR(50) UNIQUE NOT NULL,
      title TEXT,
      url TEXT,
      status VARCHAR(20) DEFAULT 'processing',
      created_at TIMESTAMP DEFAULT NOW(),
      metadata JSONB
  );
  
  CREATE TABLE embeddings (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      video_id UUID REFERENCES videos(id),
      content_type VARCHAR(20), -- 'text' or 'image'
      start_time FLOAT,
      end_time FLOAT,
      content TEXT,
      embedding_path TEXT,
      created_at TIMESTAMP DEFAULT NOW()
  );
  ```

- [ ] **Migración de datos existentes**
- [ ] **ORM con SQLAlchemy**
  ```python
  # models/video.py
  from sqlalchemy import Column, String, Float, DateTime, Text
  from sqlalchemy.dialects.postgresql import UUID, JSONB
  
  class Video(Base):
      __tablename__ = 'videos'
      
      id = Column(UUID(as_uuid=True), primary_key=True)
      video_id = Column(String(50), unique=True, nullable=False)
      title = Column(Text)
      status = Column(String(20), default='processing')
      metadata = Column(JSONB)
  ```

- [ ] **API endpoints CRUD**

**Entregables Sprint 2.2:**
- ✅ Persistencia estructurada
- ✅ Metadata searchable
- ✅ Video management UI
- ✅ Database migrations

## 🎨 FASE 3: UX Avanzada (Semanas 5-6)
**Objetivo:** Interface moderna con React

### Sprint 3.1: Frontend Base (Días 29-35)
**Setup del proyecto:**
```bash
# Crear aplicación React
npm create vite@latest youtube-rag-frontend -- --template react-ts
cd youtube-rag-frontend
npm install

# Dependencias principales
npm install @mui/material @emotion/react @emotion/styled
npm install @tanstack/react-query axios
npm install react-router-dom @types/node
npm install zustand  # State management
```

**Estructura propuesta:**
```
frontend/
├── src/
│   ├── components/           # Componentes reutilizables
│   │   ├── VideoUpload/
│   │   ├── SearchInterface/
│   │   ├── ResultsList/
│   │   └── ProgressTracker/
│   ├── pages/               # Páginas principales
│   │   ├── Dashboard.tsx
│   │   ├── Upload.tsx
│   │   ├── Search.tsx
│   │   └── VideoDetail.tsx
│   ├── hooks/               # Custom hooks
│   ├── services/            # API calls
│   ├── store/               # Zustand stores
│   └── types/               # TypeScript types
├── public/
└── package.json
```

**Tareas:**
- [ ] **Setup Material-UI theme**
  ```typescript
  // theme/index.ts
  import { createTheme } from '@mui/material/styles';
  
  export const theme = createTheme({
    palette: {
      primary: { main: '#1976d2' },
      secondary: { main: '#dc004e' }
    },
    components: {
      MuiButton: {
        styleOverrides: {
          root: { textTransform: 'none' }
        }
      }
    }
  });
  ```

- [ ] **Routing con React Router**
- [ ] **State management con Zustand**
- [ ] **API client con TanStack Query**

### Sprint 3.2: Componentes Core (Días 36-42)
**Tareas:**
- [ ] **VideoUpload Component**
  ```typescript
  interface VideoUploadProps {
    onUploadStart: (file: File) => void;
    onUrlSubmit: (url: string) => void;
  }
  
  export const VideoUpload: React.FC<VideoUploadProps> = ({
    onUploadStart,
    onUrlSubmit
  }) => {
    // Drag & drop, URL input, validation
    return (
      <Paper>
        <Dropzone onDrop={handleFileDrop}>
          {/* Upload UI */}
        </Dropzone>
        <TextField 
          label="YouTube URL"
          onChange={handleUrlChange}
        />
      </Paper>
    );
  };
  ```

- [ ] **SearchInterface Component**
- [ ] **ResultsList Component con virtualization**
- [ ] **ProgressTracker con WebSocket**

**Entregables Sprint 3.2:**
- ✅ Componentes UI completos
- ✅ Upload drag-and-drop
- ✅ Search avanzado con filtros
- ✅ Results con pagination

## 🔒 FASE 4: Seguridad y Producción (Semanas 7-8)

### Sprint 4.1: Autenticación (Días 43-49)
**Tareas:**
- [ ] **JWT Authentication**
  ```python
  # auth/jwt.py
  from fastapi_users import FastAPIUsers
  from fastapi_users.authentication import JWTAuthentication
  
  SECRET = "your-secret-key"
  auth_backend = JWTAuthentication(secret=SECRET, lifetime_seconds=3600)
  
  fastapi_users = FastAPIUsers(
      user_manager,
      [auth_backend],
  )
  ```

- [ ] **User registration/login endpoints**
- [ ] **Protected routes en React**
  ```typescript
  // hooks/useAuth.ts
  export const useAuth = () => {
    const [user, setUser] = useState<User | null>(null);
    const [loading, setLoading] = useState(true);
    
    const login = async (credentials: LoginCredentials) => {
      const response = await api.post('/auth/login', credentials);
      const { access_token, user } = response.data;
      localStorage.setItem('token', access_token);
      setUser(user);
    };
    
    return { user, login, logout, loading };
  };
  ```

- [ ] **Role-based access control**

### Sprint 4.2: Deployment (Días 50-56)
**Tareas:**
- [ ] **Docker Compose completo**
  ```yaml
  # docker-compose.prod.yml
  version: '3.8'
  services:
    frontend:
      build: ./frontend
      ports: ["3000:80"]
      
    api:
      build: ./backend
      ports: ["8000:8000"]
      environment:
        - DATABASE_URL=postgresql://user:pass@postgres:5432/db
      depends_on: [postgres, redis]
      
    worker:
      build: ./backend
      command: celery worker -A tasks.celery:app
      depends_on: [redis, postgres]
      
    postgres:
      image: postgres:15
      environment:
        POSTGRES_DB: youtube_rag
        POSTGRES_USER: postgres
        POSTGRES_PASSWORD: password
      volumes:
        - postgres_data:/var/lib/postgresql/data
        
    redis:
      image: redis:7-alpine
      
    nginx:
      image: nginx:alpine
      ports: ["80:80", "443:443"]
      volumes:
        - ./nginx/nginx.conf:/etc/nginx/nginx.conf
        - ./ssl:/etc/ssl/certs
  ```

- [ ] **CI/CD Pipeline**
  ```yaml
  # .github/workflows/deploy.yml
  name: Deploy
  on:
    push:
      branches: [main]
      
  jobs:
    test:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v3
        - name: Run tests
          run: |
            pip install -r requirements.txt
            pytest tests/
            
    deploy:
      needs: test
      runs-on: ubuntu-latest
      steps:
        - name: Deploy to production
          run: |
            docker-compose -f docker-compose.prod.yml up -d
  ```

- [ ] **Monitoring con Prometheus + Grafana**
- [ ] **Logs centralizados con ELK Stack**

**Entregables Fase 4:**
- ✅ Autenticación completa
- ✅ Deploy automatizado
- ✅ Monitoreo en producción
- ✅ Logs y alertas

## 📊 Timeline y Recursos

### Estimaciones de Tiempo
| Fase | Duración | Desarrolladores | Complejidad |
|------|----------|----------------|-------------|
| Fase 1 (Streamlit MVP) | 2 semanas | 1 | Baja |
| Fase 2 (Async + DB) | 2 semanas | 1-2 | Media |
| Fase 3 (React UI) | 2 semanas | 2 | Alta |
| Fase 4 (Prod Ready) | 2 semanas | 2 | Media |
| **Total** | **8 semanas** | **1-2 devs** | **Media-Alta** |

### Hitos Principales
- **Semana 2**: ✅ Demo funcional con Streamlit
- **Semana 4**: ✅ Procesamiento escalable
- **Semana 6**: ✅ UI profesional
- **Semana 8**: ✅ Producción ready

### Criterios de Éxito por Fase
**Fase 1:**
- [ ] Upload y procesamiento via web UI
- [ ] Búsqueda multimodal funcional
- [ ] Deploy en container local

**Fase 2:**
- [ ] Procesamiento sin blocking UI
- [ ] Múltiples videos en paralelo
- [ ] Persistencia de resultados

**Fase 3:**
- [ ] UX moderna y responsiva
- [ ] Performance < 2s load time
- [ ] Mobile-friendly

**Fase 4:**
- [ ] Autenticación segura
- [ ] Deploy en producción
- [ ] Monitoreo 24/7

## 🛠 Herramientas y Setup de Desarrollo

### Entorno de Desarrollo
```bash
# Setup completo
git clone <repo>
cd youtube_rag_mvp

# Backend
python -m venv .venv
source .venv/bin/activate  # Linux/Mac
.venv\Scripts\activate     # Windows
pip install -r requirements.txt
pip install -r requirements-dev.txt  # Testing, linting

# Frontend (Fase 3)
cd frontend
npm install
npm run dev

# Servicios locales
docker-compose -f docker-compose.dev.yml up -d
```

### Testing Strategy
```bash
# Backend tests
pytest tests/ -v --cov=app

# Frontend tests  
npm test -- --coverage

# Integration tests
docker-compose -f docker-compose.test.yml up --abort-on-container-exit
```

### Code Quality
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/psf/black
    rev: 22.3.0
    hooks:
      - id: black
  - repo: https://github.com/pycqa/isort
    rev: 5.10.1
    hooks:
      - id: isort
  - repo: https://github.com/pycqa/flake8
    rev: 4.0.1
    hooks:
      - id: flake8
```

---

*Roadmap generado el 2025-01-05 como guía de implementación detallada para las mejoras del proyecto YouTube RAG MVP.*