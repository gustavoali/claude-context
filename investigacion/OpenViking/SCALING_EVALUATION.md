# Evaluación de Escalabilidad: claude_context para Multi-Developer
**Fecha:** 2026-03-25 | **Origen:** Investigación OpenViking + metodología actual
**Estado:** Análisis prospectivo — no implementar hasta que el equipo escale

---

## 1. Estado Actual (Micro: 1 Developer)

### Qué funciona bien hoy

| Aspecto | Implementación actual | Por qué funciona |
|---------|----------------------|------------------|
| Storage | Archivos planos en disco (claude_context/) | 1 persona = 0 conflictos de concurrencia |
| Búsqueda | Grep + Glob + lectura directa | ~30 proyectos, todo cabe en la cabeza de 1 dev |
| Contexto | @imports carga todo al inicio | Token budget alcanza para 1 proyecto a la vez |
| Memoria | Auto-memory de Claude Code (4 tipos) | 1 dev = 1 perfil, sin ambigüedad |
| Backlog | PRODUCT_BACKLOG.md por proyecto | 1 dev no necesita asignación |
| Sesiones | TASK_STATE.md singleton | No hay sesiones concurrentes en el mismo proyecto |
| Metodología | Directivas en claude_context/metodologia_general/ | Todos los proyectos del mismo dev |

### Qué se rompe al escalar

| De 1 a N devs | Problema | Severidad |
|----------------|----------|-----------|
| TASK_STATE.md singleton | 2 devs trabajando en el mismo proyecto = conflicto de estado | Crítica |
| Auto-memory compartida | Preferencias de dev A sobreescriben las de dev B | Alta |
| @imports carga todo | Más proyectos = más contexto = token overflow | Media |
| Sin búsqueda semántica | Grep no escala a 100+ proyectos con docs extensos | Media |
| Backlog sin asignación | Quién trabaja en qué? Sin ownership visible | Alta |
| Sin control de acceso | Todo dev ve todo contexto (ok para equipo confiable, no para org grande) | Baja |
| Directivas centralizadas | Preferences de equipo vs preferences individuales | Media |

---

## 2. Escenarios de Escalamiento

### Small (2-3 devs) — Escenario más probable

Cada dev tiene su instancia de Claude Code con su propia memoria. El conflicto
principal es en archivos compartidos (backlog, arquitectura, task state).

**Cambios necesarios:**

| Área | Cambio | Esfuerzo | Patrón OpenViking |
|------|--------|----------|-------------------|
| TASK_STATE | 1 archivo por dev: `TASK_STATE_[dev].md` | Bajo | Session scoping por session_id |
| Backlog | Agregar columna `Asignado` a historias | Bajo | N/A (OpenViking no maneja backlog) |
| Auto-memory | Separar memorias user/ por developer | Medio | `viking://user/{user_space}/memories/` |
| Metodología | Separar preferencias personales de estándares de equipo | Bajo | user vs agent scopes |
| Code review | Review cruzado (dev A revisa dev B) | Bajo | Ya está en nuestra metodología |
| Git | Branch naming con iniciales: `feature/GA-001-titulo` | Bajo | N/A |

**No necesario aún:**
- Búsqueda semántica (grep sigue alcanzando)
- Intent analysis (cada dev trabaja en su proyecto)
- Auto-generación de L0/L1 (manual sigue siendo viable)

### Medium (4-8 devs) — Escenario aspiracional

Múltiples devs en el mismo proyecto, posiblemente con especialización
(frontend/backend/infra). La coordinación se vuelve el cuello de botella.

**Cambios necesarios (adicionales a Small):**

| Área | Cambio | Esfuerzo | Patrón OpenViking |
|------|--------|----------|-------------------|
| Contexto compartido | MCP server de contexto con scoping por rol | Alto | VikingFS + Viking URI scopes |
| Búsqueda | Índice semántico (embeddings) sobre docs de proyecto | Alto | Vector index + hierarchical retrieval |
| Tiered loading | Auto-generación de L0 por directorio de contexto | Medio | SemanticQueue + bottom-up generation |
| Intent filtering | Cargar solo contexto relevante a la tarea actual | Alto | IntentAnalyzer + TypedQuery |
| Memory scoping | Memorias de equipo (compartidas) vs personales (privadas) | Medio | user_space vs agent_space |
| Concurrencia | Locking o merge automático de archivos de contexto | Alto | Transacciones en VikingFS |
| Observabilidad | Dashboard de quién cargó qué contexto | Medio | Retrieval trajectory (12e escalado) |

### Large (9+ devs) — Escenario enterprise

A esta escala, claude_context como archivos planos no alcanza.
Se necesitaría migrar a algo como OpenViking o construir un sistema similar.

**En este punto conviene evaluar:**
- Adoptar OpenViking directamente (BSD-licensed, self-hosteable)
- Construir un MCP server de contexto custom inspirado en sus patrones
- Migrar a una solución SaaS si existe

---

## 3. Roadmap de Cambios por Fase

### Fase 0: Preparación sin costo (AHORA, 1 dev)
**Objetivo:** Dejar la infraestructura lista para que escalar sea incremental.

| # | Cambio | Archivo | Estado |
|---|--------|---------|--------|
| F0-1 | Structured summary format | 07-project-memory-management.md | HECHO (A2) |
| F0-2 | Retrieval trajectory log | 03-obligatory-directives.md (12e) | HECHO (A3) |
| F0-3 | Learnings de context engineering | CROSS_PROJECT_LEARNINGS.md | HECHO (L-040 a L-044) |
| F0-4 | Documentar patrones de OpenViking | ANALYSIS_OPENVIKING.md | HECHO |
| F0-5 | Este documento de evaluación | SCALING_EVALUATION.md | HECHO |

### Fase 1: Multi-developer básico (2-3 devs)
**Trigger:** Se incorpora un segundo developer al ecosistema.
**Estimación:** 1-2 días de setup.

| # | Cambio | Detalle |
|---|--------|---------|
| F1-1 | TASK_STATE por developer | Renombrar a `TASK_STATE_[iniciales].md`. Cada dev mantiene el suyo. |
| F1-2 | Backlog con asignación | Agregar columna `Owner` a PRODUCT_BACKLOG.md. PO asigna. |
| F1-3 | Memory scoping | Cada dev tiene su `~/.claude/` con preferencias propias. Memorias de equipo van en claude_context/metodologia_general/. |
| F1-4 | Convenciones de equipo | Separar `CLAUDE.md` global (estándares de equipo, inmutable) de `~/.claude/CLAUDE.md` (preferencias personales, mutable). |
| F1-5 | Git workflow | Branches con iniciales. PR review cruzado obligatorio. |
| F1-6 | Onboarding doc | `claude_context/ONBOARDING.md` con setup inicial para nuevo dev. |

### Fase 2: Búsqueda y contexto inteligente (4+ devs o 50+ proyectos)
**Trigger:** Grep ya no alcanza para encontrar contexto relevante, o se detecta token waste frecuente.
**Estimación:** 1-2 semanas.

| # | Cambio | Detalle | Inspiración OpenViking |
|---|--------|---------|----------------------|
| F2-1 | MCP server de contexto | Tool `context_search(query, scope)` que busca en claude_context/ con embeddings | VikingFS + SearchService |
| F2-2 | Auto-generación de L0 | Script que genera `.abstract.md` para cada directorio de proyecto | SemanticQueue, bottom-up |
| F2-3 | Intent-based loading | Pre-análisis del intent de la tarea para cargar solo contexto relevante | IntentAnalyzer |
| F2-4 | Score propagation | Búsqueda jerárquica por directorios con herencia de scores | HierarchicalRetriever |
| F2-5 | Memory dedup automatizado | Vector pre-filter + LLM decision para evitar memorias duplicadas | MemoryDeduplicator |

### Fase 3: Enterprise (9+ devs)
**Trigger:** El equipo crece significativamente.
**Decisión:** Build vs Buy.

| Opción | Pro | Contra |
|--------|-----|--------|
| Adoptar OpenViking | Listo, probado por ByteDance, BSD license | Dependencia Volcengine, setup complejo |
| MCP server custom | Control total, integrado con nuestro ecosistema | Desarrollo significativo |
| Solución SaaS | Zero maintenance | Vendor lock-in, costo recurrente |

---

## 4. Patrones de OpenViking Relevantes por Fase

| Patrón | Fase 0 | Fase 1 | Fase 2 | Fase 3 |
|--------|--------|--------|--------|--------|
| Tiered L0/L1/L2 | Informal (CLAUDE/TASK/archive) | Mismo | Auto-generado | Nativo |
| URI scoping | Paths del filesystem | Paths con convención de nombres | MCP URIs custom | viking:// o similar |
| Session management | TASK_STATE singleton | TASK_STATE per-dev | TASK_STATE + session DB | Session service |
| Memory categorization | 4 tipos (user/feedback/project/ref) | Mismo + team vs personal | Mismo + dedup automático | 8 categorías con merge ops |
| Retrieval | Grep + lectura directa | Mismo | Embeddings + hierarchical | Full retrieval pipeline |
| Intent analysis | No | No | Pre-filtrado básico | LLM intent decomposition |
| Observabilidad | 12e (manual) | 12e per-dev | Dashboard automático | Full trajectory logging |
| Score propagation | No | No | Básico (por directorio) | Completo (con hotness) |

---

## 5. Qué Preservar en Cualquier Escala

Independientemente de cuántos developers haya, estos principios se mantienen:

1. **Claude como coordinador, no ejecutor** — escala mejor con más devs
2. **Todo pasa por backlog** — más crítico con más personas
3. **Extension sin eliminación** — protege contra conflictos de merge
4. **Observation masking** — el formato structured summary escala sin cambios
5. **Directivas centralizadas** — se vuelven estándares de equipo
6. **Learnings cross-project** — más valiosos con más perspectivas
7. **Archivos planos como base** — migrar a DB solo cuando sea necesario

---

## 6. Señales de que es Hora de Escalar

| Señal | Fase a activar |
|-------|---------------|
| Se incorpora segundo developer | Fase 1 |
| Grep tarda >5s o da >100 resultados irrelevantes | Fase 2 |
| Token waste >30% (contexto cargado pero no usado) | Fase 2 |
| Conflictos frecuentes en archivos de contexto | Fase 2 |
| Más de 3 developers simultáneos | Evaluar Fase 3 |
| Onboarding de nuevo dev tarda >1 día | Mejorar docs + evaluar tooling |

---

## 7. Decisiones Pendientes (para cuando escale)

1. **TASK_STATE per-dev vs per-session:** OpenViking usa session_id. Nosotros podríamos
   usar iniciales del dev. Evaluar cuando haya 2+ devs.

2. **Memorias de equipo:** Dónde viven? En claude_context/ (compartido via git) o
   en un servicio centralizado? Git es simple pero no permite búsqueda semántica.

3. **MCP server de contexto:** Construir basado en OpenViking patterns o adoptar
   OpenViking directamente? Depende del scale y del budget.

4. **Embeddings provider:** OpenAI (text-embedding-3-large), local (Ollama), o
   Volcengine (como OpenViking)? Evaluar costo, latencia, y privacidad.
