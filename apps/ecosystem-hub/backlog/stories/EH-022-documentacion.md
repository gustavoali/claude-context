### EH-022: Documentacion de setup y uso
**Points:** 2 | **Priority:** Medium
**Epic:** EPIC-04: Polish & Integracion
**Dependencies:** EH-020 (Docker Compose)

**As a** future developer (or future me)
**I want** clear documentation on how to set up and use Ecosystem Hub
**So that** the project can be resumed after weeks of inactivity

#### Acceptance Criteria

**AC1: README con quick start**
- Given the project root
- When README.md is read
- Then it explains: what the project does, how to start it (`docker compose up`), how to access it (URLs)

**AC2: Arquitectura documentada**
- Given the README or ARCHITECTURE doc
- When read
- Then it explains: frontend (Angular), backend (Fastify extension), data sources (files), and how they connect

**AC3: API endpoints documentados**
- Given the backend has multiple endpoints
- When the docs are consulted
- Then all endpoints are listed with: method, path, query params, response shape

**AC4: Config documentada**
- Given the project has configurable paths (ALERTS.md, IDEAS_INDEX, etc.)
- When the docs are consulted
- Then all configurable environment variables are listed with defaults

#### Technical Notes
- README.md en raiz del proyecto
- API docs: puede ser seccion en README o Fastify swagger auto-generated
- Actualizar CLAUDE.md en claude_context con version, endpoints, comandos finales

#### Definition of Done
- [ ] README con quick start
- [ ] Arquitectura explicada
- [ ] API endpoints documentados
- [ ] Config variables listadas
