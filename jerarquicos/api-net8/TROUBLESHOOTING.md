# 🔧 Guía de Troubleshooting - ApiMovil .NET 8

## 🚨 Problemas Comunes

### 1. Errores de Autenticación

#### Error: "JWT token invalid or expired"

**Síntomas:**
- HTTP 401 Unauthorized en todas las APIs
- Logs muestran "JWT validation failed"
- Headers de autenticación presentes pero rechazados

**Causas posibles:**
1. Token JWT expirado
2. Secret JWT incorrecto o cambiado
3. Clock skew entre servidor y cliente
4. Token malformado o corrupto

**Soluciones:**

```bash
# 1. Verificar configuración del JWT Secret
echo $JWT_SECRET | wc -c  # Debe ser >= 32 caracteres

# 2. Verificar tiempo del servidor
date
ntpq -p  # Verificar sincronización NTP

# 3. Obtener nuevo token
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"numeroDocumento":"12345678","pin":"1234","tipoDocumento":"DNI"}'

# 4. Validar token JWT (usando jwt.io o herramienta CLI)
jwt decode <your-token>
```

**Logs relevantes:**
```bash
docker logs apimovil-api | grep -i "jwt\|auth\|unauthorized"
```

#### Error: "User not found or inactive"

**Síntomas:**
- Login falla con credenciales aparentemente correctas
- Logs muestran "User validation failed"

**Soluciones:**

```bash
# Verificar conectividad con microservicio de usuarios
curl -v http://backend-services/api/socios/health

# Verificar logs del servicio de autenticación
kubectl logs -l app=auth-service

# Verificar estado del socio en base de datos
# (esto requiere acceso al microservicio correspondiente)
```

### 2. Errores de Comunicación con Microservicios

#### Error: "HttpRequestException: Connection refused"

**Síntomas:**
- APIs devuelven HTTP 502 Bad Gateway
- Timeout en llamadas a microservicios
- Logs muestran errores de conexión HTTP

**Diagnóstico:**

```bash
# 1. Verificar conectividad de red
curl -v http://backend-services/api/health
ping backend-services

# 2. Verificar configuración de endpoints
kubectl get configmap apimovil-config -o yaml
# o
cat src/ApiMovil.Api/appsettings.json | jq '.MicroservicesSettings'

# 3. Verificar estado de los microservicios
kubectl get pods -l component=microservice
docker-compose ps

# 4. Verificar logs de la aplicación
docker logs apimovil-api | grep -i "httpclient\|microservice\|timeout"
```

**Soluciones:**

```bash
# 1. Reiniciar servicios problemáticos
kubectl rollout restart deployment/socios-service

# 2. Verificar service discovery
kubectl get services
kubectl get endpoints

# 3. Ajustar timeouts si es necesario
# Editar appsettings.json:
"MicroservicesSettings": {
  "Timeout": 60,  // Aumentar timeout
  "Retries": 5    // Aumentar reintentos
}
```

#### Error: "Circuit breaker is OPEN"

**Síntomas:**
- APIs fallan inmediatamente sin intentar llamada
- Logs muestran "Circuit breaker open"
- Errores en cascada por servicio caído

**Diagnóstico:**

```bash
# Verificar estado del circuit breaker en logs
docker logs apimovil-api | grep -i "circuit\|breaker\|polly"

# Verificar health check del servicio problemático
curl -f http://backend-services/api/socios/health
```

**Soluciones:**

```bash
# 1. Esperar a que el circuit breaker se recupere automáticamente
# (por defecto 30 segundos)

# 2. Reiniciar la aplicación para resetear circuit breakers
kubectl rollout restart deployment/apimovil-api

# 3. Verificar y arreglar el servicio caído
kubectl describe pod socios-service-pod
kubectl logs socios-service-pod
```

### 3. Problemas de Performance

#### Error: "Slow response times"

**Síntomas:**
- Respuestas > 5 segundos
- Timeouts esporádicos
- Alta utilización de CPU/memoria

**Diagnóstico:**

```bash
# 1. Verificar métricas de performance
kubectl top pods
docker stats

# 2. Verificar logs de performance
docker logs apimovil-api | grep -i "slow\|performance\|timeout"

# 3. Verificar conexiones de base de datos/cache
redis-cli info stats
redis-cli client list

# 4. Verificar Application Insights o New Relic
# (revisar dashboard de métricas)
```

**Soluciones:**

```bash
# 1. Escalar horizontalmente
kubectl scale deployment apimovil-api --replicas=5

# 2. Optimizar cache
redis-cli flushdb  # Solo si es seguro
redis-cli config set maxmemory-policy allkeys-lru

# 3. Ajustar límites de recursos
kubectl patch deployment apimovil-api -p '{"spec":{"template":{"spec":{"containers":[{"name":"apimovil-api","resources":{"limits":{"memory":"1Gi","cpu":"1000m"}}}]}}}}'
```

#### Error: "High memory usage"

**Síntomas:**
- Pods siendo killed por OOMKiller
- Garbage collection frecuente
- Memory leaks aparentes

**Diagnóstico:**

```bash
# 1. Verificar uso de memoria
kubectl describe pod apimovil-api-pod | grep -A 10 "Limits:"

# 2. Analizar dumps de memoria
kubectl exec -it apimovil-api-pod -- dotnet-dump collect

# 3. Verificar logs de GC
docker logs apimovil-api | grep -i "gc\|memory\|collect"
```

### 4. Problemas de Cache (Redis)

#### Error: "Redis connection failed"

**Síntomas:**
- Cache misses al 100%
- Logs de error de conexión a Redis
- Performance degradada

**Diagnóstico:**

```bash
# 1. Verificar estado de Redis
redis-cli ping
kubectl get pods -l app=redis

# 2. Verificar conectividad
telnet redis-server 6379
nc -zv redis-server 6379

# 3. Verificar configuración de conexión
kubectl get secret redis-secret -o yaml
```

**Soluciones:**

```bash
# 1. Reiniciar Redis
kubectl rollout restart deployment/redis

# 2. Verificar password/autenticación
redis-cli -h redis-server -a your-password ping

# 3. Fallback a memoria local temporalmente
# Editar appsettings.json:
"CacheSettings": {
  "Provider": "Memory"  // Cambiar de "Redis" a "Memory"
}
```

### 5. Problemas de Despliegue

#### Error: "ImagePullBackOff"

**Síntomas:**
- Pods no pueden iniciar
- Kubernetes no puede descargar imagen Docker
- Estado "ImagePullBackOff" o "ErrImagePull"

**Soluciones:**

```bash
# 1. Verificar que la imagen existe
docker pull apimovil:v1.0.0

# 2. Verificar autenticación del registry
kubectl describe pod apimovil-api-pod | grep -A 10 "Events:"

# 3. Usar imagen local (desarrollo)
kubectl set image deployment/apimovil-api apimovil-api=apimovil:latest --record

# 4. Verificar secrets de registry
kubectl get secret regcred -o yaml
```

#### Error: "CrashLoopBackOff"

**Síntomas:**
- Pods se reinician continuamente
- Estado "CrashLoopBackOff"
- Aplicación no puede iniciar

**Diagnóstico:**

```bash
# 1. Ver logs del pod
kubectl logs apimovil-api-pod --previous

# 2. Describir el pod
kubectl describe pod apimovil-api-pod

# 3. Verificar health checks
kubectl get pod apimovil-api-pod -o yaml | grep -A 20 "livenessProbe"
```

**Soluciones comunes:**

```bash
# 1. Verificar variables de entorno
kubectl describe deployment apimovil-api | grep -A 20 "Environment:"

# 2. Ajustar health check timing
# Aumentar initialDelaySeconds y timeoutSeconds

# 3. Verificar dependencias (Redis, microservicios)
kubectl get pods -o wide
```

### 6. Problemas de Logging

#### Error: "Logs not appearing in Seq/Application Insights"

**Síntomas:**
- Logs locales funcionan pero no aparecen en sistemas centralizados
- Missing structured data en logs
- Logs truncados o malformados

**Diagnóstico:**

```bash
# 1. Verificar configuración de Serilog
cat src/ApiMovil.Api/appsettings.json | jq '.Serilog'

# 2. Verificar conectividad con Seq
curl -f http://seq-server:5341/api/events/raw

# 3. Verificar Application Insights
# Revisar instrumentationKey en configuración
```

**Soluciones:**

```bash
# 1. Verificar variables de entorno
echo $SEQ_URL
echo $APPINSIGHTS_INSTRUMENTATIONKEY

# 2. Cambiar nivel de log temporalmente
kubectl set env deployment/apimovil-api Serilog__MinimumLevel__Default=Debug

# 3. Reiniciar para aplicar cambios
kubectl rollout restart deployment/apimovil-api
```

## 🔍 Herramientas de Diagnóstico

### Comandos Útiles

```bash
# Estado general del sistema
kubectl get all -n apimovil-namespace
docker-compose ps
systemctl status docker

# Logs en tiempo real
kubectl logs -f deployment/apimovil-api
docker-compose logs -f apimovil-api

# Métricas de sistema
kubectl top nodes
kubectl top pods
docker stats

# Network debugging
kubectl get svc
kubectl get endpoints
nslookup backend-services

# Storage debugging
kubectl get pv,pvc
docker volume ls
df -h
```

### Health Check Completo

```bash
#!/bin/bash
# Script para verificar estado completo del sistema

echo "=== ApiMovil Health Check ==="

# 1. Verificar API principal
if curl -f http://localhost:8080/health >/dev/null 2>&1; then
    echo "✅ API principal: OK"
else
    echo "❌ API principal: FAIL"
fi

# 2. Verificar Redis
if redis-cli ping >/dev/null 2>&1; then
    echo "✅ Redis: OK"
else
    echo "❌ Redis: FAIL"
fi

# 3. Verificar microservicios
services=("socios" "credenciales" "autorizaciones")
for service in "${services[@]}"; do
    if curl -f "http://backend-services/api/$service/health" >/dev/null 2>&1; then
        echo "✅ $service service: OK"
    else
        echo "❌ $service service: FAIL"
    fi
done

# 4. Verificar Seq
if curl -f http://seq:5341 >/dev/null 2>&1; then
    echo "✅ Seq: OK"
else
    echo "❌ Seq: FAIL"
fi

echo "=== Fin Health Check ==="
```

### Log Analysis Scripts

```bash
# Script para analizar patrones de error
#!/bin/bash
echo "=== Análisis de Errores ==="

# Contar errores por tipo
kubectl logs deployment/apimovil-api | grep -i error | \
  sed 's/.*\[Error\]//' | sort | uniq -c | sort -nr

# Top 10 endpoints más lentos
kubectl logs deployment/apimovil-api | grep "HTTP Response" | \
  grep -o "in [0-9]*\.*[0-9]*ms" | sed 's/in //;s/ms//' | \
  sort -nr | head -10

# Errores de microservicios
kubectl logs deployment/apimovil-api | grep -i "microservice.*error" | \
  tail -20
```

## 🚑 Acciones de Emergencia

### Procedimiento de Emergencia

1. **Identificar el problema**
   ```bash
   kubectl get pods -o wide
   kubectl describe pod problema-pod
   ```

2. **Rollback inmediato si es crítico**
   ```bash
   kubectl rollout undo deployment/apimovil-api
   ```

3. **Escalar recursos temporalmente**
   ```bash
   kubectl scale deployment/apimovil-api --replicas=10
   ```

4. **Bypasser cache si causa problemas**
   ```bash
   redis-cli flushall
   kubectl set env deployment/apimovil-api CACHE_ENABLED=false
   ```

5. **Activar modo degradado**
   ```bash
   kubectl set env deployment/apimovil-api DEGRADED_MODE=true
   ```

### Contactos de Emergencia

- **Desarrollo**: dev-team@company.com
- **DevOps**: devops@company.com  
- **Producción 24/7**: +1-XXX-XXX-XXXX
- **Slack**: #apimovil-emergency

## 📞 Escalación

### Nivel 1 (Self-Service)
- Verificar health checks
- Revisar logs básicos
- Reiniciar servicios

### Nivel 2 (Team Lead)
- Análisis de performance
- Cambios de configuración
- Rollbacks

### Nivel 3 (Architecture Team)
- Problemas de diseño
- Escalado de infraestructura
- Integraciones complejas

### Nivel 4 (Executive)
- Outages críticos
- Problemas de seguridad
- Impacto en negocio

---

**Recuerda**: Siempre documentar el problema y la solución aplicada para futuras referencias.