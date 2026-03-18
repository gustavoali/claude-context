# Arquitectura - Ecosystem Hub
**Version:** 0.1.0 | **Fecha:** 2026-03-17

## Diagrama de Componentes

```
                    localhost:4200
               +---------------------+
               |   Angular 20 App    |
               |   (web-monitor)     |
               +----+-----+-----+----+
                    |     |     |
         +----------+ +--+  +--+-----------+
         |            |                     |
/api/v1/projects /api/v1/ideas   /api/v1/alerts
/api/v1/ecosystem /api/v1/deadlines
         |            |                     |
         +-----+------+--------------------+
               |
         localhost:3001
    +-----------+------------+
    |   Fastify 5.x (PA)    |
    |  routes/ services/     |
    |  repos/  db/           |
    +-----------+------------+
               |
         localhost:5434
    +-----------+------------+
    |  PostgreSQL 17         |
    |  projects, tags, rels  |
    |  ideas, alerts,        |
    |  deadlines             |
    +------------------------+
```

## Flujo de Datos

```
Usuario -> Angular lazy-loaded feature -> signal store -> HTTP service
  -> PA REST API (Fastify route validates -> service -> repository -> SQL)
  -> Response: repo -> service -> route -> HTTP -> store signal -> template
```

**Data layer strategy (ADR-003):** DB es fuente primaria. Sync job exporta a MD para que Claude/skills sigan leyendo archivos. Migracion one-time importa datos existentes de archivos a DB.

## Estructura de Archivos Nuevos

### Backend (C:/mcp/project-admin/src/)
```
api/routes/    ideas.js, alerts.js, deadlines.js
services/      idea-service.js, alert-service.js, deadline-service.js
repositories/  idea-repository.js, alert-repository.js, deadline-repository.js
db/migrations/ 002_ideas_alerts_deadlines.sql
```

### Frontend (C:/apps/web-monitor/src/app/)
```
features/
  ideas/       ideas.routes.ts, idea-list/, idea-detail/
  alerts/      alerts.routes.ts, alert-list/, alert-detail/
  deadlines/   deadlines.routes.ts, deadline-list/
core/services/ idea.service.ts, alert.service.ts, deadline.service.ts
               idea.store.ts, alert.store.ts, deadline.store.ts
core/models/   idea.model.ts, alert.model.ts, deadline.model.ts
```

---

## ADR-001: Extender web-monitor vs crear nueva app Angular

**Estado:** Decidido | **Fecha:** 2026-03-17

**Opciones:** A) Extender web-monitor. B) Nueva app Angular standalone. C) Monorepo Nx.

**Decision: A - Extender web-monitor**

**Justificacion:** Reusar layout, sidebar, theme, error handling, interceptors y environment config (15+ archivos). Lazy loading elimina impacto en bundle existente. Coherencia UX: un solo lugar para proyectos, sesiones, ideas, alertas. Stack identico (Angular 20.2 + PrimeNG 20.5 + Signals + OnPush). Si se necesita separar en el futuro, extraer features es mecanico.

**Consecuencias:** Sidebar crece de 4 a 7 items (agrupar si supera 8). El nombre "web-monitor" queda impreciso; no renombrar ahora.

---

## ADR-002: Backend - Extender PA inline vs plugin separado

**Estado:** Decidido | **Fecha:** 2026-03-17

**Opciones:** A) Agregar routes/services/repos directamente en PA. B) Fastify plugin encapsulado en `src/plugins/ecosystem-hub/`.

**Decision: A - Agregar directamente en PA**

**Justificacion:** PA ya ES el backend del ecosistema. Las nuevas entidades tienen FK a `projects` y siguen el mismo patron (route -> service -> repo). Introducir plugin encapsulation para 3 entidades CRUD agrega indirection sin beneficio. PA crece de 6 a 9 route modules, aceptable.

**Consecuencias:** A 15+ route modules, reconsiderar plugin encapsulation. Nuevas entidades deben seguir exactamente los patrones existentes.

---

## ADR-003: Data Layer - File-based vs DB-only

**Estado:** Decidido | **Fecha:** 2026-03-17

**Opciones:** A) DB-only desde inicio (rompe flujo actual de Claude). B) File-first con API facade (fragil, sin transacciones). C) DB fuente primaria + sync export a MD.

**Decision: C - DB primaria + sync a archivos**

**Justificacion:** La DB ya existe. Filtros, paginacion y busqueda son SQL nativo. El sync exporta a MD para que Claude/skills sigan leyendo archivos. Migracion gradual: importar a DB -> skills migran a API -> archivos se vuelven read-only export.

**Consecuencias:** Script de importacion one-time necesario. Endpoint `/api/v1/sync/export` para exportar. Documentar que DB es fuente de verdad, archivos son derivados.

---

## ADR-004: Agrupacion por Tema en UI

**Estado:** Decidido | **Fecha:** 2026-03-17

**Opciones:** A) Tabs fijos por categoria. B) Filtros combinables con PrimeNG DataTable. C) Vista hibrida: summary cards + tabla filtrable.

**Decision: C - Vista hibrida**

**Justificacion:** El dashboard ya usa este patron (EcosystemSummaryComponent + ProjectTableComponent). Las cards permiten accion rapida (click filtra tabla). La tabla filtrable escala a volumen grande. PrimeNG provee ambos componentes out-of-the-box.

**Consecuencias:** Cada feature sigue patron SummaryCards + FilterableTable. Endpoints `/summary` retornan conteos agrupados. Endpoint list soporta filtros via query params.

---

## API Endpoints Nuevos

### Ideas
| Metodo | Ruta | Descripcion |
|--------|------|-------------|
| GET | `/api/v1/ideas` | Listar (category, status, priority, search, page, limit) |
| GET | `/api/v1/ideas/summary` | Conteos por category y status |
| GET | `/api/v1/ideas/:id` | Detalle |
| POST | `/api/v1/ideas` | Crear |
| PUT | `/api/v1/ideas/:id` | Actualizar |
| DELETE | `/api/v1/ideas/:id?confirm=true` | Eliminar |

### Alertas
| Metodo | Ruta | Descripcion |
|--------|------|-------------|
| GET | `/api/v1/alerts` | Listar (scope, type, status, page, limit) |
| GET | `/api/v1/alerts/summary` | Conteos por scope, type, status |
| GET/POST/PUT | `/api/v1/alerts[/:id]` | CRUD estandar |
| POST | `/api/v1/alerts/:id/resolve` | Resolver (status + resolution_notes) |
| POST | `/api/v1/alerts/:id/reopen` | Reabrir |

### Deadlines
| Metodo | Ruta | Descripcion |
|--------|------|-------------|
| GET | `/api/v1/deadlines` | Listar (status, priority, project_id, page, limit) |
| GET | `/api/v1/deadlines/summary` | Conteos por status + overdue count |
| GET/POST/PUT/DELETE | `/api/v1/deadlines[/:id]` | CRUD estandar |

### Sync
| Metodo | Ruta | Descripcion |
|--------|------|-------------|
| POST | `/api/v1/sync/export` | Exportar DB a archivos MD |
| POST | `/api/v1/sync/import` | Importar archivos MD a DB |

**Formato respuesta** (consistente con PA): `{ success: true, data: {}, meta: { total, page, limit, timestamp } }`

## Modelos de Datos

### Tablas Nuevas (migracion 002)

**ideas:** id, title, description, category (projects|features|improvements|general), status (Seed|Evaluating|Approved|In Progress|Implemented|Paused|Discarded), priority (1-5), project_id FK nullable, source_file, created_at, updated_at

**alerts:** id, scope (global|jerarquicos|slug), type (recordatorio|incidente|hallazgo-ce|estado), message, action, project_id FK nullable, status (active|resolved), resolved_at, resolution_notes, created_at

**deadlines:** id, project_id FK nullable, description, due_date DATE, priority (Alta|Media|Baja), status (pending|completed|overdue), created_at

**Indices:** category+status en ideas, scope+status en alerts, status+due_date en deadlines, project_id en las tres.

### TypeScript Interfaces (clave)

```typescript
export interface Idea {
  id: number; title: string; description: string;
  category: 'projects'|'features'|'improvements'|'general';
  status: 'Seed'|'Evaluating'|'Approved'|'In Progress'|'Implemented'|'Paused'|'Discarded';
  priority: number; projectId: number|null; projectSlug?: string;
  sourceFile?: string; createdAt: string; updatedAt: string;
}

export interface Alert {
  id: number; scope: string; type: 'recordatorio'|'incidente'|'hallazgo-ce'|'estado';
  message: string; action: string; projectId: number|null; projectSlug?: string;
  status: 'active'|'resolved'; resolvedAt: string|null;
  resolutionNotes: string|null; createdAt: string;
}

export interface Deadline {
  id: number; projectId: number|null; projectSlug?: string;
  description: string; dueDate: string; priority: 'Alta'|'Media'|'Baja';
  status: 'pending'|'completed'|'overdue'; daysUntilDue: number; createdAt: string;
}
```

Summary interfaces: `IdeaSummary`, `AlertSummary`, `DeadlineSummary` con total + conteos agrupados por cada dimension.

## Performance & Seguridad

| Metrica | Target |
|---------|--------|
| API p95 response | < 200ms |
| Initial page load | < 2s |
| DB query time | < 50ms |

- **Volumen:** ~100 entidades totales. No se necesita WebSocket, SSE, background jobs ni queues.
- **Caching:** Frontend cache 30s en services (patron existente en ProjectAdminService).
- **Paginacion server-side:** Desde el inicio (patron ya existe en project-repository.js).
- **Sin auth:** Localhost-only, single user (como PA existente).
- **CORS:** Ya configurado para localhost:4200.
- **Validacion:** JSON Schema en routes + queries parametrizadas en repos.
- **XSS:** Angular sanitiza por default.

## Testing Strategy

| Capa | Herramienta | Coverage |
|------|-------------|----------|
| Repository/Service | Jest (--experimental-vm-modules) | 70-80% |
| Routes | Fastify inject (integration) | 70% |
| Angular stores | Jasmine (solo logica compleja) | 60% |
| E2E | Manual (browser) | Critical paths |

## Riesgos

| Riesgo | Prob | Mitigacion |
|--------|------|------------|
| Sync DB-to-files conflictos con edicion manual | Media | DB es fuente de verdad, sync es export-only |
| Parseo de ideas/*.md falla con formatos inesperados | Media | Import con log de errores, no aborta en fallo parcial |
| PA crece y se vuelve monolito | Baja | A 15+ route modules, evaluar plugin encapsulation |

## Fases de Implementacion

| Fase | Entregable | Dep | Est |
|------|-----------|-----|-----|
| 1 | Migracion 002 + repos + services + routes (ideas, alerts, deadlines) | - | 1-2d |
| 2 | Scripts importacion (ideas MD, alerts MD a DB) | F1 | 0.5d |
| 3 | Frontend: models + services + stores | F1 | 0.5d |
| 4 | Frontend: ideas feature (list + detail) | F3 | 1d |
| 5 | Frontend: alerts feature (list + resolve) | F3 | 1d |
| 6 | Frontend: deadlines feature | F3 | 0.5d |
| 7 | Dashboard: summary cards ideas/alerts/deadlines | F4-6 | 0.5d |
| 8 | Sync export endpoint | F1 | 0.5d |

## Open Questions

1. **Prioridad de ideas:** Se asume 1-5 numerico. Confirmar con usuario.
2. **Deadlines overdue:** Calcularlo en el query (`due_date < NOW() AND status='pending'`), no mutar estado.
3. **Renombrar web-monitor:** No ahora. Cosmetico, alto costo de refactor.
