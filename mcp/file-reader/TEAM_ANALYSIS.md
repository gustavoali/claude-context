# File Reader - Equipo de Analisis

**Fecha:** 2026-02-16

---

## Composicion

| Rol | Agente | Responsabilidad |
|-----|--------|-----------------|
| Arquitecto Backend | `software-architect` + BACKEND | Disenar arquitectura del servidor, ADRs, contratos de API |
| Analista de Seguridad | `code-reviewer` (modo seguridad) | Threat modeling, validacion de path traversal, auth design |
| Product Owner | `product-owner` | Definir historias, priorizar backlog, AC en Given-When-Then |

## Metodologia

**Escala:** Micro (1 dev)
**Proceso:** Simplificado (3 fases)

### Fase A: Quick Diagnosis (1 sesion)
1. Arquitecto revisa el SEED_DOCUMENT y propone arquitectura detallada
2. Analista de seguridad evalua riesgos y define controles
3. Output: ARCHITECTURE_ANALYSIS.md con ADRs

### Fase B: Backlog Creation (1 sesion)
1. Product Owner crea historias basadas en arquitectura aprobada
2. Priorizar por fases del plan de implementacion
3. Output: PRODUCT_BACKLOG.md con historias estimadas

## Entregables

| Entregable | Responsable | Ubicacion |
|------------|-------------|-----------|
| ARCHITECTURE_ANALYSIS.md | Arquitecto Backend | claude_context/mcp/file-reader/ |
| PRODUCT_BACKLOG.md | Product Owner | claude_context/mcp/file-reader/ |
| Threat Model | Analista Seguridad | Incluido en ARCHITECTURE_ANALYSIS.md |
