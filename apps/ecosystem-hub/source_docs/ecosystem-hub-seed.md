# Documento Semilla: Ecosystem Hub

## Vision

Un sistema web unificado para administrar el ecosistema personal de proyectos, ideas y alertas. Reemplaza el flujo actual disperso entre archivos markdown, comandos PowerShell y sesiones de Claude por una interfaz visual que permite navegar, priorizar y actuar sobre todo el ecosistema desde un solo lugar.

---

## Problema Actual

El ecosistema tiene tres fuentes de información que hoy son islas:

| Fuente | Herramienta actual | Limitación |
|--------|-------------------|------------|
| **Proyectos** | `pj [code]` + PA MCP | Solo consultable desde terminal/Claude, sin vista cruzada |
| **Ideas** | `claude_context/ideas/*.md` + skill `/ideas` | Solo accesible desde Claude, sin priorización visual |
| **Alertas** | `ALERTS.md` + `jerarquicos/ALERTS.md` | Markdown estático, sin deadlines gestionables, sin historial navigable |

Además:
- Los deadlines no tienen una vista consolidada con días restantes
- No hay forma de relacionar una idea con el proyecto que la originó o al que pertenece
- La transición de una idea a un proyecto activo es manual y propensa a pérdida de contexto
- El estado de salud del ecosistema requiere múltiples comandos para construirse

---

## Solución Propuesta

**Ecosystem Hub**: aplicación web Angular que expone en UI todo lo que hoy vive en markdown/terminal, con tres módulos principales:

```
Ecosystem Hub
├── Dashboard          ← Resumen ejecutivo: salud, alertas urgentes, deadlines próximos
├── Proyectos          ← Vista completa del ecosistema (ya existe en web-monitor, extender)
├── Ideas              ← Gestión visual del repositorio de ideas (IDEA-NNN)
└── Alertas & Deadlines ← Centro de control de alertas + tracking de fechas límite
```

---

## Relación con el Ecosistema Existente

Este proyecto **no reemplaza** nada, **extiende** lo que existe:

| Componente | Rol en Ecosystem Hub |
|------------|---------------------|
| **Project Admin Backend** (`pj pa`) | Fuente de verdad de proyectos. Se extiende el modelo de datos para soportar ideas, alertas y deadlines |
| **Web Monitor** (`pj wm`) | Base del frontend Angular. Ecosystem Hub es su evolución natural (absorbe web-monitor o coexiste) |
| **Ideas markdown** (`claude_context/ideas/`) | Se importan al backend en arranque. Sync bidireccional opcional |
| **ALERTS.md** (global + jerarquicos) | Se importan al backend. La UI es el canal principal de gestión de aquí en adelante |
| **project-registry.json** | Sigue siendo la fuente para el comando `pj`. PA-027 lo mantiene sincronizado automáticamente |

---

## Modelo de Datos (extensión de Project Admin)

### Tablas nuevas en PostgreSQL

```sql
-- Ideas
ideas (
  id, title, description, category,   -- projects / features / improvements / general
  status,                              -- Seed / Evaluating / Approved / In Progress / Implemented / Paused / Discarded
  priority,                            -- Alta / Media / Baja / Sin definir
  project_id FK nullable,              -- si la idea ya derivó en proyecto
  source_file,                         -- path original en claude_context/ideas/ (para sync)
  created_at, updated_at
)

-- Alertas
alerts (
  id, scope,                           -- global / jerarquicos / [project_slug]
  type,                                -- recordatorio / incidente / hallazgo-ce / estado
  message, action,
  project_id FK nullable,
  status,                              -- active / resolved
  resolved_at, resolution_notes,
  created_at
)

-- Deadlines
deadlines (
  id, project_id FK nullable,
  description, due_date, priority,     -- Alta / Media / Baja
  status,                              -- pending / completed / overdue
  created_at
)
```

---

## Stack Técnico

| Capa | Tecnología |
|------|-----------|
| **Backend** | Node.js + Fastify 5.x (existente en Project Admin) |
| **Base de datos** | PostgreSQL 17 en Docker (existente, mismo container) |
| **Frontend** | Angular 20 + PrimeNG 20 (existente en web-monitor) |
| **State management** | Angular Signals (existente) |
| **Auth** | Sin auth por ahora (localhost only) |
| **Contenedores** | Docker Compose (backend + frontend + postgres) |

**Decisión clave:** reutilizar al máximo. El backend es una extensión de PA, el frontend es una extensión de web-monitor. No es un proyecto de cero.

---

## Módulos de la UI

### Dashboard
- Contador de proyectos activos / en semilla / pausados
- Alertas urgentes (≤3 días o tipo incidente) destacadas
- Deadlines próximos: tabla con días restantes y semáforo
- Ideas en estado "Approved" o "In Progress" sin proyecto asociado
- Health check de los servicios del ecosistema

### Proyectos
- Tabla/cards con todos los proyectos (hereda de web-monitor)
- Filtros: categoría, estado, health
- Acciones: abrir en terminal (`pjr [slug]`), ver ideas relacionadas, ver alertas

### Ideas
- Lista con filtros por categoría, estado, prioridad
- Formulario de creación/edición inline
- Transición de idea a proyecto con un click (crea entrada en PA + registry)
- Vista de ideas relacionadas por proyecto

### Alertas & Deadlines
- Tabs: Globales / Jerarquicos / Por proyecto
- Crear/resolver alertas desde la UI (escribe a backend, no a markdown)
- CRUD de deadlines con cálculo de urgencia automático
- Historial filtrable

---

## Fases Propuestas

### Fase 1 — Backend Extension (Medium, ~3-4 días)
- Migraciones: tablas `ideas`, `alerts`, `deadlines`
- REST endpoints CRUD para los tres recursos
- MCP tools nuevas: `pa_create_alert`, `pa_list_alerts`, `pa_create_idea`, `pa_list_ideas`, `pa_create_deadline`
- Script de importación inicial desde markdown (ALERTS.md, ideas/*.md)

### Fase 2 — Dashboard + Alertas UI (Medium, ~3-4 días)
- Dashboard con resumen ejecutivo
- Módulo Alertas & Deadlines completo
- Integración con web-monitor existente (mismo Angular app o nueva)

### Fase 3 — Ideas UI (Medium, ~2-3 días)
- Módulo Ideas con CRUD y filtros
- Transición idea → proyecto
- Vinculación idea ↔ proyecto

### Fase 4 — Polish & Integración (Small, ~1-2 días)
- Sync bidireccional con markdown (backup automático)
- PA-027: auto-sync project-registry.json
- Docker Compose unificado
- Documentación

---

## Proyectos Relacionados

| Proyecto | Relación |
|----------|---------|
| `pj pa` (Project Admin) | Backend a extender — dependencia directa |
| `pj wm` (Web Monitor) | Frontend a extender o absorber |
| IDEA-001 (Agenda) | Concepto original del gestor de ideas — puede archivarse al completar este |
| IDEA-003 (PA Backend) | En progreso, base de este proyecto |
| IDEA-004 (Web Monitor) | En progreso, base del frontend |
| EPIC-PA-008 (Angular Dashboard) | Este proyecto lo implementa |
| PA-027 (registry sync) | Feature que se incluye en Fase 4 |

---

## Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|------------|
| Scope creep | Alta | Medio | Respetar fases, backlog para todo lo nuevo |
| Divergencia entre markdown y DB durante transición | Media | Medio | Script de import como paso 0, sync periódico |
| Web Monitor tiene deuda técnica que complica extensión | Media | Bajo | Evaluar si absorber o crear app separada en Fase 2 |
| PostgreSQL container caído bloquea todo | Baja | Alto | Health check + restart policy ya configurados |

---

## Decisiones Pendientes

1. **¿Extender web-monitor o crear nueva app Angular?** Recomiendo extender — ya tiene shell, PrimeNG, servicios HTTP y CI configurados.
2. **¿Sync bidireccional con markdown?** Por ahora unidireccional (markdown → DB al importar). Bidireccional es Fase 4.
3. **Nombre del proyecto:** `ecosystem-hub` (confirmado).

---

## Contexto del Ecosistema

- **Project Admin backend:** `C:/mcp/project-admin/` | contexto: `C:/claude_context/mcp/project-admin/`
- **Web Monitor frontend:** `C:/apps/web-monitor/` | Angular 20 + PrimeNG 20 + Signals
- **Ideas markdown:** `C:/claude_context/ideas/` (47 ideas, categorías: projects/features/improvements/general)
- **ALERTS.md global:** `C:/claude_context/ALERTS.md`
- **ALERTS.md jerarquicos:** `C:/claude_context/jerarquicos/ALERTS.md`
- **project-registry.json:** `C:/claude_context/project-registry.json`
- **PostgreSQL:** container `project-admin-pg`, port 5433, DB: `project_admin`
