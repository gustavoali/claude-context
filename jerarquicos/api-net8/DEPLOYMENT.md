# 🚀 Guía de Despliegue - ApiMovil .NET 8

## 📋 Prerrequisitos

### Infraestructura Requerida

**Ambientes de Desarrollo:**
- .NET 8.0 SDK
- Docker Desktop
- Redis (local o contenedor)
- Seq (opcional para logs)

**Ambientes de Staging/Producción:**
- Docker Engine / Docker Swarm / Kubernetes
- Redis Cluster (alta disponibilidad)
- Load Balancer (Nginx/HAProxy)
- Monitoreo (Application Insights, New Relic, Seq)
- SSL/TLS Certificates

### Variables de Entorno Requeridas

#### Desarrollo
```bash
ASPNETCORE_ENVIRONMENT=Development
JWT_SECRET=dev-secret-key-minimum-256-bits
```

#### Staging
```bash
ASPNETCORE_ENVIRONMENT=Staging
JWT_SECRET=${SECURE_JWT_SECRET}
REDIS_CONNECTION_STRING=${REDIS_URL}
SEQ_URL=${SEQ_SERVER_URL}
SEQ_API_KEY=${SEQ_API_KEY}
APPINSIGHTS_INSTRUMENTATIONKEY=${AI_KEY}
```

#### Producción
```bash
ASPNETCORE_ENVIRONMENT=Production
JWT_SECRET=${PRODUCTION_JWT_SECRET}
REDIS_CONNECTION_STRING=${PRODUCTION_REDIS_URL}
SEQ_URL=${PRODUCTION_SEQ_URL}
SEQ_API_KEY=${PRODUCTION_SEQ_KEY}
APPINSIGHTS_INSTRUMENTATIONKEY=${PRODUCTION_AI_KEY}
NEWRELIC_LICENSE_KEY=${NEWRELIC_KEY}
```

## 🛠️ Métodos de Despliegue

### 1. Despliegue Local (Desarrollo)

```bash
# Opción 1: Ejecutar directamente
dotnet run --project src/ApiMovil.Api --environment Development

# Opción 2: Con Docker Compose
docker-compose up -d

# Opción 3: Script automatizado
chmod +x deploy/deploy-development.sh
./deploy/deploy-development.sh
```

**Servicios disponibles después del despliegue:**
- API: http://localhost:8080
- Swagger: http://localhost:8080/swagger
- Health Checks: http://localhost:8080/health
- Redis: localhost:6379
- Seq: http://localhost:5341

### 2. Despliegue a Staging

```bash
# Configurar variables de entorno
export JWT_SECRET="your-staging-jwt-secret-256-bits"
export REDIS_CONNECTION_STRING="redis-staging:6379"
export SEQ_URL="https://seq-staging.company.com"
export SEQ_API_KEY="your-seq-api-key"
export APPINSIGHTS_INSTRUMENTATIONKEY="your-ai-key"

# Ejecutar despliegue
chmod +x deploy/deploy-staging.sh
./deploy/deploy-staging.sh
```

### 3. Despliegue a Producción

```bash
# IMPORTANTE: Configurar todas las variables de entorno de producción
export JWT_SECRET="your-production-jwt-secret-256-bits"
export REDIS_CONNECTION_STRING="redis-cluster-prod:6379"
export SEQ_URL="https://seq.company.com"
export SEQ_API_KEY="your-production-seq-key"
export APPINSIGHTS_INSTRUMENTATIONKEY="your-production-ai-key"
export NEWRELIC_LICENSE_KEY="your-newrelic-key"

# Ejecutar despliegue con confirmación manual
chmod +x deploy/deploy-production.sh
./deploy/deploy-production.sh
```

## 🐳 Despliegue con Docker

### Construcción de Imagen

```bash
# Construcción simple
docker build -t apimovil:latest .

# Construcción con optimizaciones
docker build -t apimovil:v1.0.0 --compress --rm .

# Multi-stage build para producción
docker build -t apimovil:production --target runtime .
```

### Docker Compose - Producción

```bash
# Despliegue con alta disponibilidad
docker-compose -f docker-compose.production.yml up -d

# Verificar estado
docker-compose -f docker-compose.production.yml ps

# Ver logs
docker-compose -f docker-compose.production.yml logs -f apimovil-api

# Escalado horizontal
docker-compose -f docker-compose.production.yml up -d --scale apimovil-api=3
```

## ☸️ Despliegue en Kubernetes

### Configuración Básica

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: apimovil-api
  labels:
    app: apimovil-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: apimovil-api
  template:
    metadata:
      labels:
        app: apimovil-api
    spec:
      containers:
      - name: apimovil-api
        image: apimovil:v1.0.0
        ports:
        - containerPort: 8080
        env:
        - name: ASPNETCORE_ENVIRONMENT
          value: "Production"
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: apimovil-secrets
              key: jwt-secret
        livenessProbe:
          httpGet:
            path: /health/live
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
```

```yaml
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: apimovil-service
spec:
  selector:
    app: apimovil-api
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: LoadBalancer
```

```bash
# Aplicar configuración
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Verificar despliegue
kubectl get pods
kubectl get services
kubectl logs -l app=apimovil-api
```

## 🔄 CI/CD con GitHub Actions

### Flujo Automatizado

El pipeline CI/CD incluye:

1. **Build & Test** - Compilación y ejecución de tests
2. **Security Scan** - Análisis de vulnerabilidades
3. **Code Quality** - Análisis estático
4. **Deploy Staging** - Despliegue automático a staging
5. **Deploy Production** - Despliegue manual a producción

### Configuración de Secrets

En GitHub Repository Settings > Secrets:

```
JWT_SECRET_STAGING=your-staging-secret
JWT_SECRET_PRODUCTION=your-production-secret
REDIS_CONNECTION_STRING_STAGING=redis-staging-url
REDIS_CONNECTION_STRING_PRODUCTION=redis-prod-url
APPINSIGHTS_KEY_STAGING=ai-staging-key
APPINSIGHTS_KEY_PRODUCTION=ai-production-key
DOCKER_USERNAME=your-docker-username
DOCKER_PASSWORD=your-docker-password
```

## 🔒 Consideraciones de Seguridad

### Certificados SSL/TLS

```bash
# Generar certificados auto-firmados para desarrollo
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes

# Para producción, usar Let's Encrypt o certificados comerciales
certbot certonly --webroot -w /var/www/html -d apimovil.company.com
```

### Hardening de Contenedores

```dockerfile
# Usar usuario no-root
RUN adduser --disabled-password --home /app --gecos '' --shell /bin/bash appuser
USER appuser

# Solo lectura en filesystem
--read-only --tmpfs /tmp

# Capabilities mínimas
--cap-drop=ALL --cap-add=NET_BIND_SERVICE

# Security options
--security-opt=no-new-privileges:true
```

## 📊 Monitoreo Post-Despliegue

### Health Checks

```bash
# Verificar estado de la aplicación
curl -f http://localhost:8080/health

# Health check completo
curl -s http://localhost:8080/health | jq '.'

# Readiness probe
curl -f http://localhost:8080/health/ready

# Liveness probe
curl -f http://localhost:8080/health/live
```

### Métricas y Logs

**Application Insights:**
- Dashboard de métricas en tiempo real
- Alertas configuradas automáticamente
- Distributed tracing habilitado

**Seq (Logs):**
- Logs estructurados en tiempo real
- Queries y filtros avanzados
- Dashboard personalizable

**New Relic (Producción):**
- APM completo
- Infrastructure monitoring
- Alertas inteligentes

### Comandos de Monitoreo

```bash
# Ver logs en tiempo real
docker-compose logs -f apimovil-api

# Estadísticas de contenedores
docker stats

# Métricas de Kubernetes
kubectl top pods
kubectl top nodes

# Conectar a contenedor para debugging
docker exec -it apimovil-api bash
kubectl exec -it pod-name -- bash
```

## 🚨 Troubleshooting

### Problemas Comunes

**1. Error de conexión a microservicios**
```bash
# Verificar conectividad
curl -v http://backend-services/api/health

# Revisar configuración de endpoints
kubectl get configmap apimovil-config -o yaml
```

**2. Error de autenticación JWT**
```bash
# Verificar secret JWT
echo $JWT_SECRET | wc -c  # Debe ser >= 32 caracteres

# Verificar configuración
kubectl get secret apimovil-secrets -o yaml
```

**3. Problemas de cache Redis**
```bash
# Conectar a Redis
redis-cli -h redis-server -p 6379 ping

# Ver estadísticas
redis-cli info stats
```

**4. Alta utilización de memoria**
```bash
# Verificar métricas
kubectl top pods

# Ver logs de garbage collection
docker logs apimovil-api | grep "GC"
```

### Logs de Diagnóstico

```bash
# Habilitar logs detallados temporalmente
kubectl set env deployment/apimovil-api ASPNETCORE_ENVIRONMENT=Development

# Revert después del diagnóstico
kubectl set env deployment/apimovil-api ASPNETCORE_ENVIRONMENT=Production
```

## 📋 Checklist de Despliegue

### Pre-Despliegue
- [ ] Variables de entorno configuradas
- [ ] Secrets y certificados actualizados
- [ ] Tests pasando al 100%
- [ ] Security scan sin vulnerabilidades críticas
- [ ] Backup de configuración actual
- [ ] Plan de rollback preparado

### Post-Despliegue
- [ ] Health checks respondiendo OK
- [ ] Smoke tests ejecutados exitosamente
- [ ] Logs sin errores críticos
- [ ] Métricas dentro de rangos normales
- [ ] Load balancer distribuyendo tráfico
- [ ] Monitoreo y alertas funcionando

### Producción Específico
- [ ] DNS apuntando a nueva versión
- [ ] SSL/TLS funcionando correctamente
- [ ] Rate limiting configurado
- [ ] Backup automático habilitado
- [ ] Team notification enviada
- [ ] Documentación actualizada

## 🔄 Estrategias de Rollback

### Rollback Inmediato (Docker Compose)
```bash
# Rollback automático en script de producción
docker-compose -f docker-compose.production.yml down
docker-compose -f backup/docker-compose-previous.yml up -d
```

### Rollback Kubernetes
```bash
# Ver historial de despliegues
kubectl rollout history deployment/apimovil-api

# Rollback a versión anterior
kubectl rollout undo deployment/apimovil-api

# Rollback a versión específica
kubectl rollout undo deployment/apimovil-api --to-revision=2

# Verificar rollback
kubectl rollout status deployment/apimovil-api
```

### Blue-Green Deployment
```bash
# Cambiar tráfico gradualmente
kubectl patch service apimovil-service -p '{"spec":{"selector":{"version":"green"}}}'

# Rollback instantáneo
kubectl patch service apimovil-service -p '{"spec":{"selector":{"version":"blue"}}}'
```

## 📞 Contacto de Soporte

- **Desarrollo**: dev-team@company.com
- **DevOps**: devops@company.com
- **Producción 24/7**: production-support@company.com
- **Slack**: #apimovil-support

---

**Nota**: Siempre ejecutar primero en staging antes de producción. Mantener documentación actualizada con cada despliegue.