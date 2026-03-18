### EH-003: REST endpoints alertas
**Points:** 3 | **Priority:** Critical
**Epic:** EPIC-01: Backend - File Parsers & REST
**Dependencies:** EH-001 (parser de ALERTS.md)

**As a** frontend developer
**I want** REST endpoints to query alerts
**So that** the Angular app can display and filter alerts

#### Acceptance Criteria

**AC1: GET /api/alerts**
- Given the backend is running and ALERTS.md files are accessible
- When a GET request is made to `/api/alerts`
- Then it returns HTTP 200 with an array of all alerts (active + resolved) from all scopes
- And each alert has: `id` (generated), `date`, `type`, `message`, `action`, `status`, `scope`, `resolution`

**AC2: Filtro por scope**
- Given alerts exist with scopes "global" and "jerarquicos"
- When GET `/api/alerts?scope=global` is called
- Then only global alerts are returned

**AC3: Filtro por status**
- Given there are active and resolved alerts
- When GET `/api/alerts?status=active` is called
- Then only active alerts are returned

**AC4: Filtro por tipo**
- Given alerts have types: recordatorio, incidente, hallazgo-ce, estado
- When GET `/api/alerts?type=incidente` is called
- Then only alerts of that type are returned

**AC5: Combinacion de filtros**
- Given multiple filter parameters are provided
- When GET `/api/alerts?scope=global&status=active&type=recordatorio` is called
- Then all filters are applied conjunctively (AND)

#### Technical Notes
- Registrar rutas en el servidor Fastify existente de Project Admin
- Prefix: `/api/alerts` (no colisiona con endpoints PA existentes `/api/projects`)
- IDs generados en runtime (hash de date+message o indice secuencial)
- JSON schema validation para query params con Fastify schema

#### Definition of Done
- [ ] Endpoint implementado en Fastify
- [ ] Filtros por scope, status y type funcionando
- [ ] Tests de integracion con datos reales
- [ ] Documentacion de API (schema en Fastify autoGenerateSchema o comentarios)
