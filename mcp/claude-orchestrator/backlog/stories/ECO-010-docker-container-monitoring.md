# ECO-010: Docker Container Monitoring

**Points:** 5 | **Priority:** High
**Epic:** EPIC-ECO-03: Ecosystem Support Agent
**Depends on:** ECO-009 (Health Check Engine)

---

## User Story

**As a** system operator
**I want** the orchestrator to monitor Docker containers in the ecosystem
**So that** I know immediately when a container stops, restarts unexpectedly, or becomes unhealthy, without running `docker ps` manually

---

## Acceptance Criteria

**AC1: Docker container status checks**
- Given Docker containers are configured as health check targets with type "docker"
- When the health check interval fires
- Then the engine runs `docker ps --filter name=<container> --format json` to check status
- And if the container is running and healthy, it is marked "healthy"
- And if the container is stopped, exited, or not found, it is marked "unhealthy"

**AC2: Container metadata collection**
- Given a Docker container is being monitored
- When the health check runs
- Then the engine collects: container name, status, uptime, restart count, image, ports
- And this metadata is available via `getHealthStatus()`

**AC3: Restart count anomaly detection**
- Given a Docker container's restart count is tracked over time
- When the restart count increases between consecutive checks
- Then an event `support:container_restart` is emitted with container name, old count, new count
- And this is recorded as an incident in the health status

**AC4: Docker not available handling**
- Given Docker CLI is not available (not in PATH, daemon not running)
- When the first Docker health check runs
- Then the check fails gracefully with a clear error message "Docker CLI not available"
- And the check is retried on next interval (Docker may start later)
- And the failure does not crash the health check engine or affect other targets

**AC5: Multiple containers monitored**
- Given the ecosystem has multiple Docker containers (project-admin-pg, sprint-backlog-pg)
- When health checks run
- Then each container is checked independently at its own interval
- And the status of each is tracked separately

**AC6: Container resource usage (optional)**
- Given a Docker container is running
- When the health check runs with `includeStats: true`
- Then the engine also collects CPU% and memory usage via `docker stats --no-stream`
- And this data is included in the health status response
- But stats collection is disabled by default (performance cost)

---

## Technical Notes

### Docker CLI Commands

```bash
# Check container status
docker ps --filter "name=project-admin-pg" --format "{{json .}}"
# Output: {"ID":"abc","Names":"project-admin-pg","Status":"Up 3 hours","State":"running",...}

# Check if container exists but stopped
docker ps -a --filter "name=project-admin-pg" --format "{{json .}}"

# Stats (optional, expensive)
docker stats project-admin-pg --no-stream --format "{{json .}}"
```

### Health Check Target Schema Extension

```javascript
{
  name: 'project-admin-pg',
  type: 'docker',
  containerName: 'project-admin-pg',  // Docker container name
  interval: 60000,
  includeStats: false,                 // optional CPU/mem stats
}
```

### Default Docker Targets

```javascript
const DEFAULT_DOCKER_TARGETS = [
  { name: 'project-admin-pg', type: 'docker', containerName: 'project-admin-pg', interval: 60000 },
  { name: 'sprint-backlog-pg', type: 'docker', containerName: 'sprint-backlog-pg', interval: 60000 },
];
```

### Archivos a crear/modificar

| Archivo | Cambio |
|---------|--------|
| `src/support-agent/docker-monitor.js` | Nuevo: DockerMonitor class, parseo de `docker ps` output, restart tracking |
| `src/support-agent/health-checker.js` | Integrar type "docker" delegando a DockerMonitor |
| `tests/support-agent/docker-monitor.test.js` | Tests con mocks de exec output |

### Consideraciones

- Usar `child_process.execFile('docker', [...])` con timeout, no `exec` (shell injection risk)
- Docker CLI en WSL2: los comandos corren directamente, no necesitan `wsl` prefix si el server corre en Windows con Docker accesible
- Si Docker daemon no responde, el timeout del execFile debe prevenir hang (default 10s)
- Parsear JSON output de Docker, no texto libre (mas robusto)
- Los containers Docker tambien pueden monitorearse via TCP port check (ECO-009), pero el Docker check agrega metadata (restart count, uptime, image) que TCP no provee

---

## Definition of Done

- [ ] DockerMonitor class implementada
- [ ] Health checker integra type "docker" targets
- [ ] Container metadata: name, status, uptime, restart count, image, ports
- [ ] Restart count anomaly detection con evento `support:container_restart`
- [ ] Docker CLI not available: fallo graceful sin crash
- [ ] Stats collection opcional (disabled by default)
- [ ] Tests unitarios con mocks de docker CLI output (>70% coverage)
- [ ] Tests de edge cases: container not found, Docker not available, JSON parse error
- [ ] Build: 0 errors, 0 warnings
- [ ] Tests existentes siguen pasando

---

## Historial

| Fecha | Evento |
|-------|--------|
| 2026-03-08 | Historia creada. Extiende health check engine con monitoreo Docker. |
