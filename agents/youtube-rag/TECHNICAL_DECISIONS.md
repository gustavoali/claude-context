# YouTube RAG MVP - Decisiones Técnicas

## 📋 Información del Documento

**Versión:** 1.0
**Fecha:** 2025-01-05
**Tipo:** Architecture Decision Records (ADRs)
**Estado:** Propuestas para Evaluación

## 🎯 Metodología de Decisiones

Este documento utiliza el formato **Architecture Decision Record (ADR)** para documentar decisiones técnicas importantes, incluyendo el contexto, opciones consideradas, decisión tomada y consecuencias.

---

## ADR-001: Elección de Frontend Framework

**Estado:** Propuesta
**Fecha:** 2025-01-05
**Decidido por:** Arquitecto de Soluciones

### Contexto
El proyecto necesita una interfaz web para reemplazar la interacción actual vía Jupyter Notebook y API REST directa. Se requiere una solución que sea:
- Rápida de implementar
- Mantenible a largo plazo
- Escalable para múltiples usuarios
- Integrable con el stack Python existente

### Opciones Consideradas

#### Opción A: Streamlit
**Pros:**
- ✅ Desarrollo ultrarrápido (1-2 semanas)
- ✅ Stack Python puro, sin JavaScript
- ✅ Componentes especializados para ML/Data Science
- ✅ Deploy sencillo
- ✅ Integración directa con código existente

**Contras:**
- ⚠️ Limitaciones de customización UI
- ⚠️ No ideal para aplicaciones muy complejas
- ⚠️ Menos control sobre UX avanzada

#### Opción B: React + TypeScript
**Pros:**
- ✅ UX moderna y profesional
- ✅ Ecosistema maduro y robusto
- ✅ Escalabilidad real para producción
- ✅ Control total sobre UI/UX
- ✅ Preparado para funcionalidades complejas

**Contras:**
- ⚠️ Desarrollo más lento (3-4 semanas)
- ⚠️ Requiere expertise en frontend
- ⚠️ Stack splitting (Python + JavaScript)

#### Opción C: Gradio
**Pros:**
- ✅ Setup inmediato (1 día)
- ✅ Especializado para demos ML
- ✅ Sharing automático

**Contras:**
- ⚠️ Muy limitado para aplicaciones reales
- ⚠️ No escalable

### Decisión
**Estrategia Híbrida por Fases:**

1. **Fase 1 (MVP Inmediato):** Streamlit
   - Para demostrar valor rápidamente
   - Validar funcionalidades con usuarios
   - Permitir iteración temprana

2. **Fase 2 (Producto):** React + TypeScript
   - Una vez validadas las funcionalidades
   - Cuando se justifique la inversión en UX
   - Para escalar a múltiples usuarios

### Consecuencias
**Positivas:**
- ✅ Time-to-market rápido con Streamlit
- ✅ Migración gradual sin reescritura completa
- ✅ Aprendizaje del usuario antes de UX final

**Negativas:**
- ⚠️ Doble desarrollo a largo plazo
- ⚠️ Posible technical debt temporal

---

## ADR-002: Arquitectura de Procesamiento Asíncrono

**Estado:** Propuesta
**Fecha:** 2025-01-05

### Contexto
El procesamiento actual es síncrono y bloquea la API durante minutos. Necesitamos soporte para:
- Múltiples usuarios concurrentes
- Procesamiento de videos largos
- Feedback de progreso en tiempo real
- Recovery de fallos

### Opciones Consideradas

#### Opción A: Celery + Redis
**Pros:**
- ✅ Estándar de facto en Python
- ✅ Excelente monitoring con Flower
- ✅ Soporte para retry automático
- ✅ Escalabilidad horizontal

**Contras:**
- ⚠️ Complejidad adicional (Redis dependency)
- ⚠️ Setup y configuración extra

#### Opción B: FastAPI BackgroundTasks
**Pros:**
- ✅ Built-in en FastAPI
- ✅ Simple para casos básicos
- ✅ No dependencias externas

**Contras:**
- ⚠️ No persiste entre restarts
- ⚠️ No escalable horizontalmente
- ⚠️ Monitoring limitado

#### Opción C: Apache Airflow
**Pros:**
- ✅ Workflow orchestration completo
- ✅ UI rica para monitoring
- ✅ Scheduling avanzado

**Contras:**
- ⚠️ Overkill para este caso de uso
- ⚠️ Complejidad muy alta
- ⚠️ Resource intensive

### Decisión
**Celery + Redis** con implementación gradual:

1. **Fase 1:** BackgroundTasks para MVP
2. **Fase 2:** Migración a Celery para escalabilidad

### Arquitectura Propuesta
```python
# Task definition
@celery_app.task(bind=True)
def process_video_async(self, video_url, config):
    stages = [
        ('DOWNLOADING', 10),
        ('EXTRACTING_AUDIO', 20),
        ('TRANSCRIBING', 50),
        ('EXTRACTING_FRAMES', 70),
        ('OCR_PROCESSING', 85),
        ('GENERATING_EMBEDDINGS', 95),
        ('INDEXING', 100)
    ]
    
    for stage, progress in stages:
        self.update_state(
            state=stage, 
            meta={'progress': progress}
        )
        # Process stage...
    
    return {'status': 'SUCCESS', 'video_id': result}
```

### Consecuencias
**Positivas:**
- ✅ Procesamiento no-blocking
- ✅ Escalabilidad horizontal
- ✅ Fault tolerance mejorado
- ✅ Progress tracking granular

**Negativas:**
- ⚠️ Complejidad operacional aumenta
- ⚠️ Debugging más complejo

---

## ADR-003: Estrategia de Almacenamiento

**Estado:** Propuesta
**Fecha:** 2025-01-05

### Contexto
Actualmente todo se almacena en filesystem local. Para escalar necesitamos:
- Persistencia confiable de metadatos
- Storage distribuido para media files
- Búsquedas eficientes en metadatos
- Backup y recovery

### Opciones Consideradas

#### Opción A: PostgreSQL + MinIO/S3
**Pros:**
- ✅ PostgreSQL: ACID, queries complejas, JSON support
- ✅ MinIO: S3-compatible, self-hosted
- ✅ Separación clara: metadatos vs archivos
- ✅ Escalable independientemente

#### Opción B: MongoDB + GridFS
**Pros:**
- ✅ Document-based, natural para metadatos JSON
- ✅ GridFS para archivos grandes
- ✅ Schema flexibility

**Contras:**
- ⚠️ Menos familiar para equipo SQL
- ⚠️ ACID limitations

#### Opción C: SQLite + Local Storage
**Pros:**
- ✅ Simplicidad máxima
- ✅ Zero-config

**Contras:**
- ⚠️ No escalable
- ⚠️ No concurrency real

### Decisión
**PostgreSQL + MinIO** con migración gradual:

**Esquema de Base de Datos:**
```sql
-- Core entities
CREATE TABLE videos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    video_id VARCHAR(50) UNIQUE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    url TEXT,
    duration INTERVAL,
    status VARCHAR(20) DEFAULT 'processing',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    metadata JSONB,
    
    -- Indexing for search
    CONSTRAINT valid_status CHECK (status IN ('processing', 'completed', 'failed'))
);

CREATE TABLE text_segments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    video_id UUID REFERENCES videos(id) ON DELETE CASCADE,
    start_time FLOAT NOT NULL,
    end_time FLOAT NOT NULL,
    content TEXT NOT NULL,
    source VARCHAR(20) DEFAULT 'transcript', -- 'transcript' | 'ocr'
    confidence FLOAT,
    embedding_vector VECTOR(384), -- pgvector extension
    created_at TIMESTAMP DEFAULT NOW(),
    
    -- Indexing
    INDEX idx_video_time (video_id, start_time),
    INDEX idx_content_search USING gin(to_tsvector('spanish', content))
);

CREATE TABLE image_segments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    video_id UUID REFERENCES videos(id) ON DELETE CASCADE,
    timestamp FLOAT NOT NULL,
    image_path TEXT NOT NULL, -- MinIO path
    thumbnail_path TEXT,
    ocr_content TEXT,
    embedding_vector VECTOR(512), -- CLIP embedding
    created_at TIMESTAMP DEFAULT NOW(),
    
    -- Indexing  
    INDEX idx_video_timestamp (video_id, timestamp)
);

-- Search performance
CREATE INDEX idx_text_embedding ON text_segments USING ivfflat (embedding_vector);
CREATE INDEX idx_image_embedding ON image_segments USING ivfflat (embedding_vector);
```

### Storage Strategy
```
MinIO Buckets:
├── videos/           # Original video files
│   └── {video_id}.{ext}
├── audio/            # Extracted audio
│   └── {video_id}.wav
├── frames/           # Video frames
│   └── {video_id}/
│       ├── frame_0000.jpg
│       └── ...
└── thumbnails/       # Generated thumbnails
    └── {video_id}/
        ├── thumb_0000.jpg
        └── ...
```

### Consecuencias
**Positivas:**
- ✅ Escalabilidad real
- ✅ ACID compliance para metadatos
- ✅ S3-compatible storage
- ✅ Rich querying capabilities

**Negativas:**
- ⚠️ Complejidad operacional
- ⚠️ Costo de infraestructura adicional

---

## ADR-004: Vector Search Strategy

**Estado:** Propuesta
**Fecha:** 2025-01-05

### Contexto
FAISS actual funciona pero tiene limitaciones para producción:
- No persistencia transaccional
- No metadata filtering
- Scaling horizontal limitado
- No integration con SQL queries

### Opciones Consideradas

#### Opción A: FAISS + PostgreSQL Híbrido
**Pros:**
- ✅ Mantiene performance actual
- ✅ Añade SQL capabilities
- ✅ Metadata filtering eficiente

**Implementación:**
```python
class HybridVectorStore:
    def __init__(self):
        self.faiss_index = faiss.IndexFlatIP(dimension)
        self.db = PostgreSQLDB()
    
    async def search(self, query_vector, filters=None, top_k=10):
        # 1. Apply SQL filters first
        candidate_ids = await self.db.get_candidates(filters)
        
        # 2. Vector search on subset
        if candidate_ids:
            subset_vectors = self.get_vectors_by_ids(candidate_ids)
            scores, indices = self.faiss_index.search(query_vector, top_k)
            
        # 3. Enrich with metadata
        return self.enrich_results(scores, indices)
```

#### Opción B: pgvector Extension
**Pros:**
- ✅ Todo en PostgreSQL
- ✅ ACID transactions
- ✅ SQL queries nativas
- ✅ Metadata filtering natural

**Implementación:**
```sql
-- Vector search con metadata filtering
SELECT 
    ts.content,
    ts.start_time,
    ts.end_time,
    v.title,
    (ts.embedding_vector <=> $1) as similarity
FROM text_segments ts
JOIN videos v ON ts.video_id = v.id
WHERE v.status = 'completed'
    AND ts.start_time BETWEEN $2 AND $3
ORDER BY ts.embedding_vector <=> $1
LIMIT $4;
```

#### Opción C: Weaviate/Qdrant
**Pros:**
- ✅ Purpose-built para vector search
- ✅ Metadata filtering nativo
- ✅ RESTful APIs
- ✅ Escalabilidad horizontal

**Contras:**
- ⚠️ Dependencia externa adicional
- ⚠️ Learning curve

### Decisión
**Enfoque Evolutivo:**

1. **Fase 1:** FAISS + PostgreSQL híbrido
2. **Fase 2:** Migración a pgvector puro
3. **Fase 3:** Evaluación de Qdrant si se requiere scale masivo

### Implementación Propuesta
```python
# Nuevo motor de búsqueda híbrido
class ProductionRAGEngine:
    def __init__(self):
        self.vector_store = HybridVectorStore()
        self.text_embedder = TextEmbedder()
        self.vision_embedder = CLIPEncoder()
    
    async def search_multimodal(self, 
                               query: str,
                               video_filters: dict = None,
                               time_range: tuple = None,
                               top_k: int = 10):
        
        # Text search
        text_vector = self.text_embedder.encode([query])
        text_results = await self.vector_store.search_text(
            text_vector, 
            filters=video_filters,
            time_range=time_range,
            top_k=top_k
        )
        
        # Image search  
        image_vector = self.vision_embedder.encode_text([query])
        image_results = await self.vector_store.search_images(
            image_vector,
            filters=video_filters,
            time_range=time_range, 
            top_k=min(4, top_k)
        )
        
        return {
            'text_results': text_results,
            'image_results': image_results,
            'combined_score': self._compute_multimodal_score(text_results, image_results)
        }
```

---

## ADR-005: Monitoring y Observabilidad

**Estado:** Propuesta
**Fecha:** 2025-01-05

### Contexto
Para producción necesitamos visibilidad completa del sistema:
- Performance monitoring
- Error tracking  
- Business metrics
- Health checks
- Alerting

### Decisión: Stack de Observabilidad

#### Logging: Structured Logging
```python
import structlog
import logging.config

# Configuración de logging estructurado
logging.config.dictConfig({
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "json": {
            "()": structlog.stdlib.ProcessorFormatter,
            "processor": structlog.dev.ConsoleRenderer(colors=False),
        },
    },
    "handlers": {
        "default": {
            "level": "INFO",
            "class": "logging.StreamHandler",
            "formatter": "json",
        },
    },
    "loggers": {
        "": {
            "handlers": ["default"],
            "level": "INFO",
        },
    }
})

logger = structlog.get_logger()

# Usage
logger.info("video_processing_started", 
           video_id=video_id, 
           user_id=user_id,
           duration_estimate=estimated_duration)
```

#### Metrics: Prometheus + Grafana
```python
from prometheus_client import Counter, Histogram, Gauge, Info

# Business metrics
videos_processed = Counter('videos_processed_total', 
                          'Total videos processed', 
                          ['status', 'source'])

processing_duration = Histogram('video_processing_seconds',
                               'Time spent processing videos',
                               ['stage'])

active_jobs = Gauge('active_processing_jobs', 
                   'Number of videos currently being processed')

system_info = Info('youtube_rag_system', 'System information')
```

#### Health Checks
```python
@app.get("/health")
async def health_check():
    checks = {
        "database": await check_database_connection(),
        "redis": await check_redis_connection(),
        "storage": await check_storage_connection(),
        "vector_index": await check_vector_index_health(),
        "worker_queue": await check_worker_queue_health()
    }
    
    all_healthy = all(checks.values())
    status_code = 200 if all_healthy else 503
    
    return Response(
        content=json.dumps({
            "status": "healthy" if all_healthy else "unhealthy",
            "timestamp": datetime.now().isoformat(),
            "checks": checks,
            "version": get_version()
        }),
        status_code=status_code,
        media_type="application/json"
    )
```

---

## 📊 Resumen de Decisiones

| ADR | Decisión | Rationale | Impacto |
|-----|----------|-----------|---------|
| ADR-001 | Streamlit → React | Time-to-market vs UX final | Alto |
| ADR-002 | Celery + Redis | Escalabilidad y fault tolerance | Medio |
| ADR-003 | PostgreSQL + MinIO | Datos estructurados + media | Alto |
| ADR-004 | FAISS → pgvector | Integración SQL + vector search | Medio |
| ADR-005 | Prometheus + Grafana | Observabilidad production-ready | Medio |

## 🔄 Proceso de Revisión

**Periodicidad:** Revisión trimestral de ADRs
**Criterios de Revisión:**
- ¿La decisión sigue siendo válida?
- ¿Han aparecido mejores alternativas?
- ¿Las consecuencias fueron las esperadas?
- ¿Requiere actualización o deprecation?

**Próxima Revisión:** 2025-04-05

---

*Decisiones técnicas documentadas el 2025-01-05 como parte del proceso de arquitectura del proyecto YouTube RAG MVP.*