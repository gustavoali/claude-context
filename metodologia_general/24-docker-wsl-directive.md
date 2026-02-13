# Directiva: Docker en WSL (No Docker Desktop)

**Version:** 1.0
**Fecha:** 2026-02-09
**Estado:** OBLIGATORIO para agentes devops-engineer y database-expert
**Aplica a:** Cualquier proyecto que requiera contenedores Docker

---

## Regla Principal

**Cuando se necesite Docker para bases de datos u otros servicios, usar Docker Engine en WSL2, NO Docker Desktop.**

---

## Justificacion

1. **Licenciamiento:** Docker Desktop requiere licencia comercial para empresas >250 empleados o >$10M de ingresos
2. **Performance:** Docker en WSL2 nativo tiene mejor rendimiento que Docker Desktop
3. **Recursos:** Menor consumo de memoria y CPU
4. **Simplicidad:** Un solo entorno Linux (WSL2) para desarrollo

---

## Configuracion Requerida

### Prerequisitos

1. WSL2 instalado con una distribucion Linux (Ubuntu recomendado)
2. Docker Engine instalado DENTRO de WSL2 (no Docker Desktop)

### Instalacion en WSL2 (Ubuntu)

```bash
# Dentro de WSL2
sudo apt-get update
sudo apt-get install -y docker.io docker-compose-v2

# Agregar usuario al grupo docker
sudo usermod -aG docker $USER

# Iniciar servicio
sudo service docker start

# Verificar
docker --version
docker compose version
```

### Configuracion de Inicio Automatico

```bash
# Agregar a ~/.bashrc o ~/.zshrc
if service docker status 2>&1 | grep -q "is not running"; then
    sudo service docker start
fi
```

---

## Comandos para Agentes

### Para devops-engineer

Cuando necesites crear infraestructura Docker:

```bash
# SIEMPRE ejecutar dentro de WSL2
wsl -d Ubuntu -e bash -c "docker compose up -d"

# O entrar a WSL primero
wsl -d Ubuntu
cd /mnt/c/path/to/project
docker compose up -d
```

### Para database-expert

Cuando necesites bases de datos en contenedores:

```bash
# PostgreSQL
wsl -d Ubuntu -e bash -c "docker run -d --name postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  postgres:16"

# MongoDB
wsl -d Ubuntu -e bash -c "docker run -d --name mongo \
  -p 27017:27017 \
  mongo:7"

# Redis
wsl -d Ubuntu -e bash -c "docker run -d --name redis \
  -p 6379:6379 \
  redis:7"
```

---

## Paths y Volumenes

### Conversion de Paths

| Windows | WSL2 |
|---------|------|
| `C:\projects\myapp` | `/mnt/c/projects/myapp` |
| `D:\data` | `/mnt/d/data` |

### Volumenes Recomendados

Para mejor performance, guardar datos de contenedores DENTRO de WSL2:

```bash
# Crear directorio para datos en WSL2 (mejor performance)
mkdir -p ~/docker-data/postgres
mkdir -p ~/docker-data/mongo

# Usar en docker run
docker run -d --name postgres \
  -v ~/docker-data/postgres:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:16
```

---

## docker-compose.yml Estandar

Ubicar en el proyecto Windows, ejecutar desde WSL2:

```yaml
# docker-compose.yml
version: '3.8'

services:
  postgres:
    image: postgres:16
    container_name: project-postgres
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: mydb
    ports:
      - "5432:5432"
    volumes:
      # Usar path WSL2 para performance
      - postgres-data:/var/lib/postgresql/data

volumes:
  postgres-data:
    driver: local
```

---

## Conexion desde Windows

Los contenedores en WSL2 son accesibles desde Windows via localhost:

```
# Desde Windows, conectar a PostgreSQL en WSL2
Host: localhost
Port: 5432
User: postgres
Password: postgres
```

---

## Checklist para Agentes

Antes de usar Docker, verificar:

- [ ] El proyecto requiere contenedores Docker
- [ ] WSL2 esta disponible (`wsl --list --verbose`)
- [ ] Docker Engine esta instalado en WSL2 (no Docker Desktop)
- [ ] El servicio Docker esta corriendo (`wsl -e service docker status`)
- [ ] Los comandos Docker se ejecutan DENTRO de WSL2

---

## Errores Comunes

### "Cannot connect to Docker daemon"

```bash
# El servicio no esta corriendo
wsl -e sudo service docker start
```

### "Permission denied"

```bash
# Usuario no esta en grupo docker
wsl -e sudo usermod -aG docker $USER
# Cerrar y reabrir terminal WSL
```

### Paths de Windows no funcionan

```bash
# Convertir path
# Windows: C:\projects\myapp
# WSL2: /mnt/c/projects/myapp
```

---

## Proyectos Afectados

Esta directiva aplica a:

- `sprint-backlog-manager` - PostgreSQL para persistencia
- Cualquier proyecto futuro que requiera bases de datos
- Proyectos con docker-compose.yml

---

**Esta directiva es OBLIGATORIA para agentes devops-engineer y database-expert.**
**Cualquier uso de Docker Desktop debe ser rechazado y redirigido a WSL2.**
