# YouTube RAG MVP - Guía de Deployment Escalable

## 📋 Información del Deployment

**Versión:** 2.0 (Escalable)
**Fecha:** 2025-01-05
**Tipo:** Aplicación Escalable React + Microservicios
**Estado:** Listo para Deployment

---

## 🎯 Arquitectura Implementada

Hemos implementado la **Opción B: Aplicación Escalable** de nuestro documento de propuestas:

### Stack Tecnológico Completo

#### Frontend
- ✅ **React 18** + TypeScript + Vite
- ✅ **Material-UI v5** para componentes
- ✅ **Zustand** para state management
- ✅ **TanStack Query** para manejo de API
- ✅ **React Router** para navegación
- ✅ **WebSocket** para actualizaciones en tiempo real

#### Backend
- ✅ **FastAPI** con mejoras de escalabilidad
- ✅ **SQLAlchemy** + PostgreSQL para datos estructurados
- ✅ **Redis** para cache y message broker
- ✅ **Celery** para procesamiento asíncrono
- ✅ **MinIO** para almacenamiento de archivos
- ✅ **JWT Authentication** + RBAC

#### Infraestructura
- ✅ **Docker** + **Docker Compose** para todos los servicios
- ✅ **Nginx** como reverse proxy con rate limiting
- ✅ **Prometheus** + **Grafana** para monitoreo
- ✅ **Flower** para monitoreo de Celery

#### Procesamiento ML/AI
- ✅ Mantiene todo el pipeline original (CLIP, Whisper, FAISS)
- ✅ Procesamiento asíncrono no-blocking
- ✅ Progress tracking en tiempo real
- ✅ Fault tolerance y retry logic

---

## 🚀 Instrucciones de Deployment

### 1. Preparación del Entorno

```bash
# 1. Clonar el repositorio
git clone <your-repo>
cd youtube_rag_mvp

# 2. Instalar dependencias del sistema
# Ubuntu/Debian:
sudo apt update && sudo apt install -y docker.io docker-compose-plugin curl

# CentOS/RHEL:
sudo yum install -y docker docker-compose curl

# 3. Configurar Docker (si es necesario)
sudo usermod -aG docker $USER
sudo systemctl enable docker
sudo systemctl start docker
```

### 2. Configuración

```bash
# 1. Navegar al directorio de deployment
cd infrastructure/docker

# 2. Configurar variables de entorno
cp .env.example .env

# 3. Editar configuración (IMPORTANTE!)
nano .env
```

#### Configuración Crítica en .env:

```bash
# Seguridad (CAMBIAR en producción)
POSTGRES_PASSWORD=TuPasswordSeguro123!
SECRET_KEY=tu-super-secret-key-de-minimo-32-caracteres-muy-seguro
MINIO_ROOT_PASSWORD=TuMinIOPassword123!

# Base de datos
DATABASE_URL=postgresql://postgres:TuPasswordSeguro123!@postgres:5432/youtube_rag

# Configuración de aplicación
DEBUG=false
ALLOWED_ORIGINS=http://localhost:3000,http://tu-dominio.com

# Funcionalidades
ENABLE_USER_REGISTRATION=true
MAX_VIDEO_DURATION=7200
MAX_CONCURRENT_JOBS=5
```

### 3. Deployment

```bash
# 1. Crear directorios necesarios
mkdir -p ../../data/{videos,uploads,logs}
mkdir -p ./ssl

# 2. Construir e iniciar todos los servicios
docker-compose up -d

# 3. Verificar que todos los servicios estén corriendo
docker-compose ps

# 4. Ver logs en tiempo real
docker-compose logs -f
```

### 4. Inicialización

```bash
# 1. Esperar a que la base de datos esté lista
docker-compose logs postgres | grep "database system is ready"

# 2. Ejecutar migraciones de base de datos
docker-compose exec api alembic upgrade head

# 3. Crear usuario administrador
docker-compose exec api python -c "
from app.core.database import SessionLocal
from app.core.security import security_manager
from app.models.user import User, UserRole
import uuid

db = SessionLocal()
admin = User(
    id=uuid.uuid4(),
    email='admin@tudominio.com',
    username='admin',
    hashed_password=security_manager.create_password_hash('AdminPass123!'),
    role=UserRole.ADMIN,
    is_active=True,
    is_verified=True
)
db.add(admin)
db.commit()
print('✅ Usuario admin creado: admin@tudominio.com / AdminPass123!')
"

# 4. Verificar health checks
curl http://localhost/health
curl http://localhost:8000/health
```

---

## 🌐 URLs de Acceso

Una vez deployado, los servicios estarán disponibles en:

| Servicio | URL | Credenciales |
|----------|-----|--------------|
| **Aplicación Web** | http://localhost | Registrate o usa admin |
| **API Backend** | http://localhost:8000 | - |
| **API Documentation** | http://localhost:8000/docs | - |
| **Celery Monitoring** | http://localhost:5555 | admin/admin123 |
| **MinIO Console** | http://localhost:9001 | minioadmin/TuPassword |
| **Grafana Dashboards** | http://localhost:3001 | admin/admin123 |
| **Prometheus Metrics** | http://localhost:9090 | - |

---

## 👥 Funcionalidades Implementadas

### Para Usuarios Finales

1. **🔐 Autenticación Completa**
   - Registro de usuarios
   - Login/logout seguro con JWT
   - Sesiones persistentes
   - Recuperación de contraseña

2. **📹 Gestión de Videos**
   - Upload de archivos de video
   - Ingesta desde URLs de YouTube
   - Monitoreo de progreso en tiempo real
   - Gestión de videos personales

3. **🔍 Búsqueda Inteligente**
   - Búsqueda multimodal (texto + imágenes)
   - Filtros avanzados por video, tiempo, tipo
   - Historial de búsquedas
   - Guardado de búsquedas favoritas

4. **📊 Dashboard Personal**
   - Estadísticas de uso
   - Videos recientes
   - Jobs de procesamiento activos
   - Configuración personal

### Para Administradores

1. **👨‍💼 Panel de Administración**
   - Gestión de usuarios
   - Monitoreo del sistema
   - Estadísticas globales
   - Configuración de la aplicación

2. **📈 Monitoreo en Tiempo Real**
   - Métricas de Prometheus
   - Dashboards de Grafana
   - Logs centralizados
   - Health checks automatizados

---

## ⚙️ Configuración de Producción

### Seguridad

```bash
# 1. Generar certificados SSL
mkdir -p ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/key.pem -out ssl/cert.pem

# 2. Habilitar HTTPS en nginx.conf
# Descomenta el bloque server HTTPS

# 3. Configurar firewall
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### Optimización de Performance

```yaml
# docker-compose.override.yml para producción
version: '3.8'
services:
  api:
    deploy:
      replicas: 3
      resources:
        limits:
          memory: 1G
        reservations:
          memory: 512M

  worker:
    deploy:
      replicas: 2
    command: celery -A app.tasks.celery worker --concurrency=4 --max-tasks-per-child=100

  nginx:
    deploy:
      resources:
        limits:
          memory: 512M
```

### Backup Automatizado

```bash
# 1. Crear script de backup
cat > backup.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="backups/$DATE"
mkdir -p $BACKUP_DIR

# Database backup
docker-compose exec -T postgres pg_dump -U postgres youtube_rag > $BACKUP_DIR/database.sql

# MinIO backup
docker run --rm -v docker_minio_data:/data -v $PWD/$BACKUP_DIR:/backup alpine \
  tar czf /backup/files.tar.gz -C /data .

echo "Backup completed: $BACKUP_DIR"
EOF

chmod +x backup.sh

# 2. Configurar cron job
crontab -e
# Agregar: 0 2 * * * /path/to/your/backup.sh
```

---

## 🔧 Mantenimiento

### Actualizaciones

```bash
# 1. Actualizar imágenes
docker-compose pull

# 2. Recrear servicios
docker-compose up -d --force-recreate

# 3. Limpiar imágenes antiguas
docker image prune -f
```

### Escalado Horizontal

```bash
# Escalar servicios específicos
docker-compose up -d --scale api=3
docker-compose up -d --scale worker=5

# Verificar balanceadores
docker-compose ps
```

### Troubleshooting

```bash
# Ver logs de todos los servicios
docker-compose logs --tail=100 -f

# Ver logs específicos
docker-compose logs api
docker-compose logs worker
docker-compose logs postgres

# Reiniciar servicio problemático
docker-compose restart api

# Verificar recursos del sistema
docker stats
docker system df
```

---

## 📊 Métricas y Monitoreo

### Dashboards de Grafana

1. **System Overview**: CPU, RAM, disk, network
2. **Application Metrics**: Requests/sec, response times, errors
3. **Video Processing**: Jobs en cola, tiempo de procesamiento
4. **Database Performance**: Conexiones, queries, locks
5. **Storage Metrics**: Espacio usado, operaciones I/O

### Alertas Importantes

- 🔴 **API Down**: Servicio no responde
- 🟡 **High Memory**: Uso de RAM >85%
- 🟡 **Queue Backlog**: >10 jobs pendientes
- 🟡 **Disk Space**: <10% espacio libre
- 🔴 **Database Down**: PostgreSQL no accesible

---

## 🎉 Resultado Final

Has implementado exitosamente la **solución escalable B** con:

✅ **Frontend moderno** React con TypeScript
✅ **Backend robusto** FastAPI con microservicios
✅ **Base de datos** PostgreSQL con modelos completos
✅ **Procesamiento asíncrono** Celery + Redis
✅ **Almacenamiento distribuido** MinIO
✅ **Monitoreo completo** Prometheus + Grafana
✅ **Conteneirización** Docker con orchestración
✅ **Seguridad** JWT + RBAC + Rate limiting
✅ **Escalabilidad horizontal** Load balancing
✅ **Observabilidad** Logs + Métricas + Health checks

El sistema ahora puede:
- 👥 Soportar múltiples usuarios concurrentes
- 🚀 Procesar varios videos en paralelo
- 📈 Escalar horizontalmente según demanda  
- 🔍 Ofrecer búsquedas multimodales avanzadas
- 💾 Persistir datos de forma confiable
- 📊 Monitorearse automáticamente
- 🔒 Operar de forma segura en producción

¡La transformación de MVP a aplicación escalable está completa!

---

*Documentación de deployment generada el 2025-01-05 para YouTube RAG MVP v2.0*