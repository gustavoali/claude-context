# Team Analysis - Ecosystem Hub

## Equipo de Analisis

### Arquitecto (software-architect)
**Perfil:** Frontend + Backend
**Responsabilidades:**
- Definir como extender Project Admin backend con modulos de ideas/alertas/deadlines
- Decidir si absorber web-monitor o crear app Angular separada
- Disenar modelo de datos para migracion de markdown a DB
- Asegurar que el MVP con lectura directa de archivos sea extensible a DB

**Documentos base:**
- `AGENT_ARCHITECT_BASE.md` + `AGENT_ARCHITECT_FRONTEND.md` (para decisiones UI)
- `AGENT_ARCHITECT_BASE.md` + `AGENT_ARCHITECT_BACKEND.md` (para extension PA)

### Product Owner (product-owner)
**Responsabilidades:**
- Definir backlog inicial basado en SEED_DOCUMENT.md
- Priorizar modulos por valor (Dashboard > Alertas > Ideas)
- Definir AC para cada historia
- Gestionar transicion MVP (archivos) -> Full (DB)

### Analista de Datos (data-quality-analyst)
**Responsabilidades:**
- Validar calidad de datos en IDEAS_INDEX.md (47 ideas)
- Verificar consistencia entre ALERTS.md, project-registry.json y PA DB
- Detectar duplicados, inconsistencias, datos faltantes
- Definir reglas de importacion markdown -> DB

## Decisiones Pendientes de Analisis
1. Extender web-monitor vs nueva app Angular (recomendacion: extender)
2. Esquema de agrupacion por temas para el MVP
3. Estrategia de sync markdown <-> DB
