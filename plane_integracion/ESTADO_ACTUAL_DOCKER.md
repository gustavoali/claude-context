# Estado Actual de Docker - Plane Integration

**Fecha**: 2025-10-17
**Shell actual**: Git Bash (MINGW64)

---

## 🔍 Diagnóstico

### Entorno Detectado
- **Sistema**: MINGW64_NT-10.0-26100 (Git Bash en Windows)
- **Docker instalado**: ✅ Versión 28.3.3, build 980b856
- **Docker corriendo**: ❌ No accesible desde Git Bash

### Error Actual
```
error during connect: Get "http://%2F%2F.%2Fpipe%2FdockerDesktopLinuxEngine/v1.51/containers/json...
The system cannot find the file specified.
```

Este error indica que:
1. Docker daemon no está corriendo, **O**
2. Docker está configurado para WSL pero estamos en Git Bash

---

## 🎯 Opciones para Continuar

### Opción 1: Usar WSL Directamente (Recomendado)

Para usar Docker en WSL como está documentado:

```powershell
# En PowerShell
wsl

# Dentro de WSL
cd /mnt/c/tools/plane/plane-app

# Verificar Docker
docker --version
docker compose ps

# Si Docker no está corriendo en WSL:
sudo service docker start

# Aplicar migraciones
docker compose exec plane-api python manage.py migrate
```

### Opción 2: Usar PowerShell Directamente

```powershell
# En PowerShell (Windows)
cd C:\tools\plane\plane-app

# Verificar Docker
docker --version
docker compose ps

# Aplicar migraciones
docker compose exec plane-api python manage.py migrate
```

### Opción 3: Iniciar Docker Daemon

Si Docker está instalado pero no corriendo:

**En WSL**:
```bash
sudo service docker start
sudo service docker status
```

**En Windows** (si usas Docker Desktop):
- Iniciar Docker Desktop desde el menú de inicio
- Esperar a que el ícono de Docker en la bandeja del sistema muestre "running"

---

## 📋 Comandos para Aplicar Migraciones

Una vez que Docker esté corriendo, ejecuta en **WSL** o **PowerShell**:

### 1. Verificar servicios
```bash
cd C:\tools\plane\plane-app  # En PowerShell
# O
cd /mnt/c/tools/plane/plane-app  # En WSL

docker compose ps
```

### 2. Si los servicios no están corriendo
```bash
docker compose up -d
```

### 3. Aplicar migraciones
```bash
# Migración 0108: GitHub Webhook Events
docker compose exec plane-api python manage.py migrate db 0108

# Migración 0109: GitHub Sync Jobs
docker compose exec plane-api python manage.py migrate db 0109

# O todas las migraciones pendientes
docker compose exec plane-api python manage.py migrate
```

### 4. Verificar migraciones aplicadas
```bash
docker compose exec plane-api python manage.py showmigrations db | grep -E "(0108|0109)"
```

### 5. Verificar tablas creadas en PostgreSQL
```bash
docker compose exec plane-postgres psql -U plane -d plane -c "\dt github_*"
```

---

## ✅ Resultado Esperado

Después de aplicar las migraciones, deberías ver:

```bash
$ docker compose exec plane-api python manage.py showmigrations db | grep -E "(0108|0109)"
 [X] 0108_githubwebhookevent
 [X] 0109_githubsyncjob
```

Y en PostgreSQL:

```bash
$ docker compose exec plane-postgres psql -U plane -d plane -c "\dt github_*"
                      List of relations
 Schema |         Name          | Type  | Owner
--------+-----------------------+-------+-------
 public | github_webhook_events | table | plane
 public | github_sync_jobs      | table | plane
```

---

## 🔧 Troubleshooting

### Problema: "Cannot connect to Docker daemon"

**Causa**: Docker no está corriendo

**Solución WSL**:
```bash
# Verificar estado
sudo service docker status

# Iniciar Docker
sudo service docker start

# Habilitar auto-start
sudo systemctl enable docker
```

**Solución Windows**:
- Abrir Docker Desktop desde el menú de inicio
- Esperar a que inicie completamente

### Problema: "docker compose command not found"

**Causa**: Docker Compose no instalado o no en PATH

**Solución**:
```bash
# Verificar versión
docker compose version

# Si no funciona, intenta con guión
docker-compose version

# Instalar Docker Compose (si falta)
# En WSL:
sudo apt-get update
sudo apt-get install docker-compose-plugin
```

### Problema: "Error response from daemon: network not found"

**Causa**: Red de Docker Compose no creada

**Solución**:
```bash
# Recrear servicios
docker compose down
docker compose up -d
```

### Problema: "Permission denied" en WSL

**Causa**: Usuario no tiene permisos para Docker

**Solución**:
```bash
# Agregar usuario a grupo docker
sudo usermod -aG docker $USER

# Logout y login de WSL
exit
wsl
```

---

## 📚 Documentación Relacionada

- **Setup completo**: `DOCKER_WSL_SETUP.md`
- **Comandos rápidos**: `COMANDOS_RAPIDOS.md`
- **Próximos pasos**: `NEXT_STEPS_IMPLEMENTATION.md`
- **Estado del proyecto**: `PROJECT_STATUS.md`

---

## 🎯 Próxima Acción Recomendada

Para continuar con las migraciones, te recomiendo:

1. **Abrir una terminal WSL** (si usas WSL):
   ```powershell
   wsl
   ```

2. **O usar PowerShell** directamente:
   ```powershell
   cd C:\tools\plane\plane-app
   docker compose ps
   ```

3. **Verificar que Docker está corriendo** antes de aplicar migraciones

4. **Aplicar migraciones** con los comandos listados arriba

---

**Documentado por**: Claude Code
**Fecha**: 2025-10-17
**Estado**: Listo para aplicar migraciones (requiere Docker corriendo)
