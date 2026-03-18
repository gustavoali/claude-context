### EH-020: Docker Compose unificado
**Points:** 2 | **Priority:** Medium
**Epic:** EPIC-04: Polish & Integracion
**Dependencies:** EH-006 (Angular app existe)

**As a** developer
**I want** a Docker Compose file that runs the full stack
**So that** the entire ecosystem hub can be started with one command

#### Acceptance Criteria

**AC1: Compose up levanta todo**
- Given docker-compose.yml exists in the project root
- When `docker compose up` is executed
- Then three services start: frontend (Angular), backend (Fastify), postgres
- And all health checks pass within 60 seconds

**AC2: Frontend accesible**
- Given compose is running
- When navigating to http://localhost:4201
- Then the Angular app loads and shows the dashboard

**AC3: Backend accesible**
- Given compose is running
- When calling http://localhost:3001/api/alerts
- Then the backend responds with JSON data

**AC4: Volumes para persistencia**
- Given postgres runs in the compose stack
- When the stack is stopped and restarted
- Then postgres data persists via named volume

**AC5: Hot reload en dev**
- Given the compose stack is running in dev mode
- When source files are modified on the host
- Then the Angular dev server and/or backend hot reload

#### Technical Notes
- Reutilizar container PostgreSQL existente (`project-admin-pg`, port 5433) o crear uno nuevo
- Frontend: multi-stage Dockerfile (build + nginx) for prod, bind mount for dev
- Backend: extends Project Admin, same container or separate
- Consider `docker compose --profile dev` for dev-specific configs

#### Definition of Done
- [ ] `docker compose up` levanta los 3 servicios
- [ ] Frontend y backend accesibles
- [ ] PG con volume persistente
- [ ] Documentado en README
