# Roadmap: Ecosistema Local Integrado

**Fecha:** 2026-02-21
**Autor:** software-architect
**Escala:** Micro (1 developer)
**Estimacion total:** 8-12 horas

---

## Diagrama de Arquitectura del Ecosistema

```
                          ┌─────────────────────────────────────────────────────┐
                          │                    CLIENTS                           │
                          ├─────────────────────────────────────────────────────┤
                          │                                                     │
                          │  ┌──────────────────┐    ┌──────────────────────┐   │
                          │  │ web-monitor       │    │ flutter-monitor      │   │
                          │  │ Angular :4200     │    │ Desktop app          │   │
                          │  │ C:/apps/web-mon.. │    │ C:/apps/claude-code..│   │
                          │  └──────┬────┬───────┘    └──────────┬───────────┘   │
                          │    HTTP │    │ WS                    │ WS            │
                          └─────┬──┼────┼────────────────────────┼──────────────┘
                                │  │    │                        │
              ┌─────────────────▼──┘    │                        │
              │                         │                        │
┌─────────────▼──────────────┐  ┌───────▼────────────────────────▼──────────────┐
│ project-admin              │  │ claude-orchestrator                            │
│ Fastify :3001 (CAMBIADO)   │  │ WS :8765 + HTTP :3000                         │
│ C:/mcp/project-admin       │  │ C:/mcp/claude-orchestrator                    │
│                            │  │                                               │
│ REST API:                  │  │ Interfaces:                                   │
│  GET /api/projects         │  │  WS: Flutter + Angular (real-time)            │
│  GET /api/projects/:id     │  │  HTTP: REST API (sessions, health)            │
│  GET /api/health           │  │  MCP: Claude Code (stdio)                     │
│  /docs (Swagger)           │  │                                               │
│                            │  │ Integracion:                                  │
│ MCP Server (stdio)         │  │  backlog-client → sprint-backlog-manager      │
│  pa_list_projects          │  │                                               │
│  pa_scan_directory         │  └────────────────────┬──────────────────────────┘
│  pa_project_health         │                       │ MCP/stdio (child process)
│  ...                       │                       │
└────────────┬───────────────┘  ┌────────────────────▼──────────────────────────┐
             │                  │ sprint-backlog-manager                         │
             │                  │ MCP Server (stdio only)                        │
             │                  │ C:/mcp/sprint-backlog-manager                  │
             │                  │                                               │
             │                  │ MCP Tools:                                    │
             │                  │  create_story, update_story, list_stories     │
             │                  │  create_sprint, get_sprint, move_story        │
             │                  │  ...15 tools total                            │
             └────┬─────────────┘────────────────────┬──────────────────────────┘
                  │                                  │
        ┌─────────▼──────────┐              ┌────────▼──────────┐
        │ PostgreSQL 17      │              │ PostgreSQL 16     │
        │ Docker WSL :5434   │              │ Docker WSL :5435  │
        │ project_admin      │              │ sprint_backlog    │
        │ project-admin-pg   │              │ sprint-backlog-pg │
        └────────────────────┘              └───────────────────┘
```

### Mapa de Puertos (propuesto)

| Puerto | Servicio                     | Protocolo | Estado actual       |
|--------|------------------------------|-----------|---------------------|
| 3000   | claude-orchestrator HTTP API  | HTTP      | OK (sin cambios)    |
| 3001   | project-admin REST API        | HTTP      | CAMBIAR de 3000     |
| 4200   | web-monitor dev server        | HTTP      | OK (sin cambios)    |
| 5434   | PostgreSQL project-admin      | TCP       | OK                  |
| 5435   | PostgreSQL sprint-backlog     | TCP       | ROTO (sin mapping)  |
| 8765   | claude-orchestrator WebSocket | WS        | OK (sin cambios)    |

---

## Problemas Detectados (Diagnostico)

### P1. CRITICO: sprint-backlog-pg sin port mapping

El container `sprint-backlog-pg` no tiene port bindings. La config espera `127.0.0.1:5435`
pero el container no expone ningun puerto al host.

```
$ docker inspect sprint-backlog-pg --format '{{json .HostConfig.PortBindings}}'
{}
```

**Impacto:** sprint-backlog-manager no puede conectar a su base de datos.
**Fix:** Recrear el container con `-p 5435:5432`.

### P2. CRITICO: Conflicto de puerto 3000

Tanto `claude-orchestrator` (HTTP API) como `project-admin` (Fastify API) usan puerto 3000.
No pueden correr simultaneamente.

**Impacto:** Solo uno de los dos puede estar activo a la vez.
**Fix:** Mover project-admin a puerto 3001.

### P3. MODERADO: web-monitor apunta a project-admin en :3000

`environment.ts` tiene `projectAdminUrl: 'http://localhost:3000'`, que tras el fix de P2
debe cambiar a `:3001`.

### P4. MENOR: project-admin CORS no incluye puerto 4200 correctamente

El CORS de project-admin permite `http://localhost:3000` (si mismo) y `http://localhost:4200`.
Tras el cambio de puerto, verificar que siga funcionando.

### P5. MENOR: No hay startup script unificado

Cada servicio se inicia manualmente. No hay forma de verificar que todo esta arriba.

### P6. INFO: orchestrator no tiene configurada la integracion backlog

El `.env` del orchestrator no tiene `BACKLOG_MCP_PATH` configurado. La integracion con
sprint-backlog-manager esta deshabilitada.

---

## Fases de Implementacion

### Fase 0: Fix Criticos (Prerequisitos)

**Esfuerzo:** 1 hora
**Prioridad:** Bloqueante - nada funciona sin esto

#### Tarea 0.1: Recrear container sprint-backlog-pg con port mapping

```bash
# En WSL:
docker stop sprint-backlog-pg
docker rm sprint-backlog-pg
docker run -d \
  --name sprint-backlog-pg \
  -p 5435:5432 \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=sprint_backlog \
  -e POSTGRES_HOST_AUTH_METHOD=scram-sha-256 \
  -e POSTGRES_INITDB_ARGS="--auth-host=scram-sha-256" \
  -v sprint-backlog-pgdata:/var/lib/postgresql/data \
  --restart unless-stopped \
  postgres:16
```

**Riesgo:** Si el volume `sprint-backlog-pgdata` ya existe con datos, se preservan.
Verificar con `docker volume ls | grep sprint-backlog`. Si no tiene datos previos,
ejecutar migraciones despues: `cd C:/mcp/sprint-backlog-manager && npm run migrate`.

**Archivos:** Ninguno. Solo infra Docker.
**Validacion:** `docker port sprint-backlog-pg` debe mostrar `5432/tcp -> 0.0.0.0:5435`.

#### Tarea 0.2: Resolver conflicto de puerto 3000

Cambiar project-admin de :3000 a :3001. El orchestrator mantiene :3000 porque es el que
tiene mas integraciones (Flutter, Angular, MCP).

**Archivos afectados:**

1. `C:/mcp/project-admin/.env`
   ```
   API_PORT=3001    # Antes: 3000
   ```

2. `C:/mcp/project-admin/.env.example`
   ```
   API_PORT=3001    # Antes: 3000
   ```

3. `C:/mcp/project-admin/src/server.js` - Actualizar CORS origins
   ```javascript
   // Linea 25: agregar puerto 3001 y mantener 4200
   await fastify.register(cors, {
     origin: ['http://localhost:3001', 'http://127.0.0.1:3001', 'http://localhost:4200']
   });
   ```

4. `C:/apps/web-monitor/src/environments/environment.ts`
   ```typescript
   projectAdminUrl: 'http://localhost:3001',  // Antes: 3000
   ```

5. `C:/mcp/claude-orchestrator/src/http/server.js` - Agregar :3001 a CORS
   ```
   CORS_ALLOWED_ORIGINS=http://localhost:4200,http://127.0.0.1:4200,http://localhost:3001
   ```
   O editar la linea del default en el codigo para incluir :3001.

**Validacion:**
- `curl http://localhost:3001/health` debe responder OK.
- `curl http://localhost:3000/api/health` (orchestrator) debe responder OK.
- web-monitor en :4200 debe poder llamar a ambos.

---

### Fase 1: Verificacion Individual de Servicios

**Esfuerzo:** 1-2 horas
**Prioridad:** Alta
**Dependencia:** Fase 0 completada

#### Tarea 1.1: Verificar databases

```bash
# Desde Windows (Node.js script o curl)
# project-admin DB
node -e "
  const { Client } = require('pg');
  const c = new Client({connectionString:'postgresql://postgres:postgres@127.0.0.1:5434/project_admin'});
  c.connect().then(() => c.query('SELECT 1')).then(r => {console.log('project-admin DB: OK'); c.end()}).catch(e => {console.error('FAIL:', e.message); c.end()});
"

# sprint-backlog DB
node -e "
  const { Client } = require('pg');
  const c = new Client({connectionString:'postgresql://postgres:postgres@127.0.0.1:5435/sprint_backlog'});
  c.connect().then(() => c.query('SELECT 1')).then(r => {console.log('sprint-backlog DB: OK'); c.end()}).catch(e => {console.error('FAIL:', e.message); c.end()});
"
```

#### Tarea 1.2: Verificar migraciones

```bash
cd C:/mcp/project-admin && npm run migrate:status
cd C:/mcp/sprint-backlog-manager && npm run migrate
```

#### Tarea 1.3: Iniciar y verificar cada servicio por separado

```bash
# 1. project-admin (en terminal 1)
cd C:/mcp/project-admin && npm run start:api
# Verificar: curl http://localhost:3001/health

# 2. claude-orchestrator (en terminal 2)
cd C:/mcp/claude-orchestrator && npm run server
# Verificar: curl http://localhost:3000/api/health

# 3. web-monitor (en terminal 3)
cd C:/apps/web-monitor && npm start
# Verificar: abrir http://localhost:4200

# sprint-backlog-manager no tiene server propio (solo MCP stdio)
# Se verifica via orchestrator o Claude Code
```

---

### Fase 2: Integracion entre Servicios

**Esfuerzo:** 2-3 horas
**Prioridad:** Alta
**Dependencia:** Fase 1 completada

#### Tarea 2.1: Habilitar integracion orchestrator <-> sprint-backlog-manager

Configurar backlog-client en orchestrator.

**Archivo:** `C:/mcp/claude-orchestrator/.env`
```
BACKLOG_MCP_PATH=C:/mcp/sprint-backlog-manager/src/index.js
BACKLOG_PROJECT_ID=1
```

**Validacion:** Reiniciar orchestrator, verificar logs que diga "Backlog client initialized"
o similar. Probar asignar una story a una sesion.

#### Tarea 2.2: Verificar web-monitor <-> project-admin

1. Iniciar project-admin en :3001
2. Iniciar web-monitor en :4200
3. Verificar en el browser que la lista de proyectos se carga correctamente
4. Verificar que el health check de project-admin aparece en la UI

#### Tarea 2.3: Verificar web-monitor <-> orchestrator

1. Iniciar orchestrator (WS :8765 + HTTP :3000)
2. Abrir web-monitor en :4200
3. Verificar que el WebSocket conecta (indicador de conexion)
4. Verificar que se pueden listar sesiones
5. Crear una sesion de prueba, enviar un prompt

#### Tarea 2.4: Verificar flutter-monitor <-> orchestrator

1. Con orchestrator corriendo
2. Ejecutar flutter app
3. Verificar conexion WebSocket
4. Verificar listado de sesiones

---

### Fase 3: Startup Script y Health Checks

**Esfuerzo:** 2-3 horas
**Prioridad:** Media (mejora DX significativa)
**Dependencia:** Fase 2 completada

#### Tarea 3.1: Crear script de startup del ecosistema

**Archivo nuevo:** `C:/mcp/ecosystem-start.sh`

```bash
#!/bin/bash
# Ecosystem Startup Script
# Inicia todos los servicios del ecosistema local en orden correcto

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[ECOSYSTEM]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# --- Step 1: Docker databases ---
log "Checking Docker databases..."

check_container() {
  local name=$1
  local port=$2
  if wsl docker ps --filter "name=$name" --filter "status=running" -q | grep -q .; then
    log "  $name: running (port $port)"
  else
    warn "  $name: NOT running. Starting..."
    wsl docker start "$name" 2>/dev/null || error "  Failed to start $name"
    sleep 2
  fi
}

check_container "project-admin-pg" 5434
check_container "sprint-backlog-pg" 5435

# Wait for databases to accept connections
log "Waiting for databases..."
for i in {1..10}; do
  pg1=$(node -e "const{Client}=require('pg');const c=new Client({connectionString:'postgresql://postgres:postgres@127.0.0.1:5434/project_admin'});c.connect().then(()=>{console.log('ok');c.end()}).catch(()=>{console.log('fail');c.end()})" 2>/dev/null)
  pg2=$(node -e "const{Client}=require('pg');const c=new Client({connectionString:'postgresql://postgres:postgres@127.0.0.1:5435/sprint_backlog'});c.connect().then(()=>{console.log('ok');c.end()}).catch(()=>{console.log('fail');c.end()})" 2>/dev/null)
  if [[ "$pg1" == "ok" && "$pg2" == "ok" ]]; then
    log "  Both databases ready."
    break
  fi
  sleep 2
done

# --- Step 2: Backend services ---
log "Starting project-admin on :3001..."
cd C:/mcp/project-admin
nohup node src/server.js > /tmp/project-admin.log 2>&1 &
PA_PID=$!

log "Starting claude-orchestrator on :8765 (WS) + :3000 (HTTP)..."
cd C:/mcp/claude-orchestrator
nohup node src/server.js > /tmp/orchestrator.log 2>&1 &
ORCH_PID=$!

sleep 3

# --- Step 3: Health checks ---
log "Running health checks..."

check_http() {
  local url=$1
  local name=$2
  local status=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
  if [[ "$status" == "200" ]]; then
    log "  $name: OK ($url)"
  else
    error "  $name: FAIL (HTTP $status at $url)"
  fi
}

check_http "http://localhost:3001/health" "project-admin"
check_http "http://localhost:3000/api/health" "orchestrator-http"

# WebSocket check (basic TCP)
if nc -z localhost 8765 2>/dev/null; then
  log "  orchestrator-ws: OK (port 8765)"
else
  warn "  orchestrator-ws: port 8765 not reachable"
fi

# --- Step 4: Frontend (optional) ---
log ""
log "Backend services started."
log "  project-admin PID: $PA_PID (log: /tmp/project-admin.log)"
log "  orchestrator PID:  $ORCH_PID (log: /tmp/orchestrator.log)"
log ""
log "To start web-monitor:  cd C:/apps/web-monitor && npm start"
log "To stop all:           kill $PA_PID $ORCH_PID"
```

#### Tarea 3.2: Crear script de health check del ecosistema

**Archivo nuevo:** `C:/mcp/ecosystem-health.sh`

```bash
#!/bin/bash
# Ecosystem Health Check - Quick status of all services

echo "=== Ecosystem Health Check ==="
echo ""

# Databases
echo "--- Databases ---"
for name in project-admin-pg sprint-backlog-pg; do
  status=$(wsl docker inspect "$name" --format '{{.State.Status}}' 2>/dev/null || echo "not found")
  echo "  $name: $status"
done

echo ""
echo "--- Services ---"

# project-admin
status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3001/health 2>/dev/null)
echo "  project-admin (:3001): HTTP $status"

# orchestrator HTTP
status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/health 2>/dev/null)
echo "  orchestrator HTTP (:3000): HTTP $status"

# orchestrator WS
if nc -z localhost 8765 2>/dev/null; then
  echo "  orchestrator WS (:8765): OK"
else
  echo "  orchestrator WS (:8765): DOWN"
fi

# web-monitor
status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:4200 2>/dev/null)
echo "  web-monitor (:4200): HTTP $status"

echo ""
echo "--- Port Map ---"
echo "  3000  orchestrator HTTP API"
echo "  3001  project-admin REST API + Swagger"
echo "  4200  web-monitor (Angular)"
echo "  5434  PostgreSQL project-admin"
echo "  5435  PostgreSQL sprint-backlog"
echo "  8765  orchestrator WebSocket"
```

#### Tarea 3.3: Crear script de shutdown

**Archivo nuevo:** `C:/mcp/ecosystem-stop.sh`

```bash
#!/bin/bash
echo "Stopping ecosystem services..."

# Find and kill Node.js services by port
for port in 3000 3001; do
  pid=$(lsof -ti:$port 2>/dev/null)
  if [ -n "$pid" ]; then
    echo "  Killing process on port $port (PID: $pid)"
    kill "$pid" 2>/dev/null
  fi
done

echo "Done. Docker databases left running (use 'wsl docker stop <name>' to stop)."
```

---

### Fase 4: Configuracion y Documentacion

**Esfuerzo:** 1-2 horas
**Prioridad:** Media
**Dependencia:** Fase 2 completada

#### Tarea 4.1: Actualizar .env.example de todos los proyectos

Asegurar que cada `.env.example` refleje los puertos finales y todas las variables
necesarias para integracion.

**Archivos:**
- `C:/mcp/claude-orchestrator/.env.example` - Agregar `BACKLOG_MCP_PATH` descomentado como ejemplo
- `C:/mcp/project-admin/.env.example` - Puerto 3001
- `C:/mcp/sprint-backlog-manager/.env.example` - Puerto 5435 en DATABASE_URL

#### Tarea 4.2: Actualizar CORS en orchestrator para incluir :3001

Si project-admin necesita llamar al orchestrator (future), agregar :3001 a CORS.

**Archivo:** `C:/mcp/claude-orchestrator/.env`
```
CORS_ALLOWED_ORIGINS=http://localhost:4200,http://127.0.0.1:4200,http://localhost:3001
```

#### Tarea 4.3: Registrar ecosistema en project-admin

Usar el MCP tool `pa_scan_all` o registrar manualmente cada proyecto para que
project-admin conozca todo el ecosistema.

```bash
# Via MCP (desde Claude Code con project-admin como MCP server)
# O via REST API:
curl -X POST http://localhost:3001/api/projects -H 'Content-Type: application/json' -d '{
  "name": "claude-orchestrator",
  "path": "C:/mcp/claude-orchestrator",
  "classifier": "mcp",
  "stack": "node",
  "status": "active"
}'
# Repetir para cada proyecto
```

---

### Fase 5: Mejoras Opcionales (Nice-to-have)

**Esfuerzo:** 2-3 horas total
**Prioridad:** Baja
**Dependencia:** Fases 0-2 completadas

#### Tarea 5.1: Health check cruzado en orchestrator

Agregar endpoint `GET /api/health/ecosystem` en orchestrator que verifique:
- Su propia salud
- Conexion a sprint-backlog-manager (si configurado)
- project-admin health (opcional)

**Archivo:** `C:/mcp/claude-orchestrator/src/http/routes/health.js`

#### Tarea 5.2: Health check cruzado en web-monitor

Agregar panel de status en web-monitor que muestre:
- Estado de conexion WebSocket con orchestrator
- Estado de project-admin API
- Contadores de sesiones activas

#### Tarea 5.3: npm workspace o meta-script en raiz

Crear un `package.json` en `C:/mcp/` como monorepo workspace (opcional):

```json
{
  "name": "ecosystem",
  "private": true,
  "scripts": {
    "start": "bash ecosystem-start.sh",
    "stop": "bash ecosystem-stop.sh",
    "health": "bash ecosystem-health.sh"
  }
}
```

---

## Orden de Arranque (Dependencias)

```
1. Docker WSL (databases)
   ├── project-admin-pg (:5434)
   └── sprint-backlog-pg (:5435)

2. project-admin (:3001)
   └── Depende de: project-admin-pg

3. claude-orchestrator (:8765 WS + :3000 HTTP)
   └── Depende de: sprint-backlog-pg (indirecto, via backlog-client)
   └── Opcional: project-admin (para ecosystem health)

4. web-monitor (:4200)
   └── Depende de: orchestrator + project-admin

5. flutter-monitor
   └── Depende de: orchestrator
```

**Orden de shutdown:** Inverso (frontends primero, databases ultimo).

---

## Tabla de Configuracion Final

### claude-orchestrator (.env)

| Variable             | Valor                                           |
|----------------------|-------------------------------------------------|
| ORCHESTRATOR_MODE    | cli                                             |
| WS_PORT              | 8765                                            |
| HTTP_PORT            | 3000                                            |
| BACKLOG_MCP_PATH     | C:/mcp/sprint-backlog-manager/src/index.js       |
| BACKLOG_PROJECT_ID   | 1                                               |
| LOG_LEVEL            | info                                            |
| CORS_ALLOWED_ORIGINS | http://localhost:4200,http://localhost:3001       |

### project-admin (.env)

| Variable          | Valor                                                       |
|-------------------|-------------------------------------------------------------|
| DATABASE_URL      | postgresql://postgres:postgres@127.0.0.1:5434/project_admin |
| API_PORT          | 3001                                                        |
| API_HOST          | 127.0.0.1                                                   |
| SCAN_DIRECTORIES  | C:/agents/,C:/apps/,C:/mcp/,C:/mobile/                      |

### sprint-backlog-manager (.env)

| Variable     | Valor                                                        |
|--------------|--------------------------------------------------------------|
| DATABASE_URL | postgresql://postgres:postgres@127.0.0.1:5435/sprint_backlog |
| DB_PORT      | 5435                                                         |
| DB_PASSWORD  | postgres                                                     |

### web-monitor (environment.ts)

| Variable          | Valor                    |
|-------------------|--------------------------|
| projectAdminUrl   | http://localhost:3001     |
| orchestratorWsUrl | ws://localhost:8765       |

---

## Resumen de Esfuerzos por Fase

| Fase | Descripcion                       | Esfuerzo | Prioridad   |
|------|-----------------------------------|----------|-------------|
| 0    | Fix criticos (puerto + Docker)    | 1h       | Bloqueante  |
| 1    | Verificacion individual           | 1-2h     | Alta        |
| 2    | Integracion entre servicios       | 2-3h     | Alta        |
| 3    | Startup scripts y health checks   | 2-3h     | Media       |
| 4    | Configuracion y documentacion     | 1-2h     | Media       |
| 5    | Mejoras opcionales                | 2-3h     | Baja        |
| **Total** |                              | **8-12h** |            |

**Recomendacion:** Ejecutar Fases 0-2 en una sesion (4-6h). Fases 3-4 en otra sesion.
Fase 5 cuando haya tiempo libre.

---

## Riesgos

| Riesgo | Probabilidad | Impacto | Mitigacion |
|--------|-------------|---------|------------|
| Volume de sprint-backlog-pg vacio tras recrear container | Media | Alto (perdida de datos) | Verificar `docker volume ls` antes. Si vacio, re-ejecutar seed/import. |
| Claude CLI no disponible en PATH para orchestrator CLI mode | Baja | Alto | Configurar `CLAUDE_CLI_PATH` en .env si no esta en PATH global. |
| Port 3001 ya ocupado por otro servicio | Baja | Medio | Verificar con `netstat -ano | findstr 3001` antes. |
| web-monitor Angular build roto por version mismatch | Baja | Medio | Ejecutar `npm install` antes de `npm start`. |
| WSL Docker daemon no iniciado al arrancar | Media | Alto | Script de startup verifica con `docker info`. |

---

## Preguntas Abiertas

1. **flutter-monitor:** Esta actualmente funcional? Necesita algun cambio de configuracion
   para conectar al orchestrator en :8765?

2. **project-admin scan:** Los directorios de scan (`C:/agents/,C:/apps/,C:/mcp/,C:/mobile/`)
   son correctos y existen todos?

3. **sprint-backlog-manager datos:** Hay datos existentes en la DB o se empieza de cero?
   Esto determina si despues de recrear el container hay que correr migraciones + seed.

4. **Orchestrator MCP en Claude Code:** Esta configurado en `~/.claude/mcp_settings.json`?
   Si no, agregarlo para poder usar los tools desde Claude Code directamente.
