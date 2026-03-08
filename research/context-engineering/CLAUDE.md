# Context Engineering - Project Context
**Version:** 1.0.0 | **Entregables:** 8/8 | **Incidentes:** 7
**Ubicacion:** C:/claude_context/research/context-engineering
**Tipo:** Investigacion (no produce software)

## Descripcion
Proyecto de investigacion sobre la disciplina de disenar, gestionar y optimizar el contexto de trabajo entre operadores humanos y asistentes de IA en flujos de trabajo prolongados y multi-sesion. Genera conocimiento documentado, no codigo.

## Pregunta Central
Como minimizar la perdida de informacion valiosa entre sesiones, maximizar la eficiencia del contexto disponible, y escalar con la complejidad del proyecto?

## Estructura
```
research/context-engineering/
  SEED_DOCUMENT.md     # Vision, alcance, metodologia
  CLAUDE.md            # Este archivo
  PRODUCT_BACKLOG.md   # Backlog de investigacion
  incidents/           # Registro de incidentes observados
  proposals/           # Propuestas de mejora
  TAXONOMY.md          # 13 tipos de contexto clasificados
  PATTERNS.md          # 12 patrones + 6 anti-patrones
  METRICS.md           # 10 metricas + scorecard + niveles de madurez
  TASK_STATE.md        # Estado de trabajo
  LITERATURE.md        # Estado del arte (12 practicas, comparacion)
  SYNTHESIS.md         # Documento ejecutivo final (7 hallazgos, 8 recomendaciones)
```

## Equipo
| Rol | Agente | Responsabilidad |
|-----|--------|-----------------|
| Investigador principal | `general-purpose` (Explore) | Recopilar incidentes, analizar patrones, revisar literatura |
| Observador continuo | Claude (directiva 12d, transversal) | Detectar incidentes en tiempo real en cualquier proyecto |
| Product Owner | `product-owner` | Gestionar backlog de investigacion |
| Revisor | Usuario | Validar propuestas, aprobar cambios |

## Agentes Recomendados
| Tarea | Agente |
|-------|--------|
| Buscar incidentes en transcripts | `general-purpose` (Explore) |
| Revisar literatura online | `general-purpose` con WebSearch/WebFetch |
| Crear/organizar backlog | `product-owner` |
| Analisis de patrones | `general-purpose` |

## Fuentes de Datos
- Transcripts de sesiones: `C:/Users/gdali/.claude/projects/*/` (.jsonl)
- Metodologia General: `C:/claude_context/metodologia_general/`
- LEARNINGS de proyectos: `C:/claude_context/*/LEARNINGS.md`
- TASK_STATE de proyectos: `C:/claude_context/*/TASK_STATE.md`
- Directivas de proteccion: `03-obligatory-directives.md` (directiva 12)
- Propuesta de resiliencia: `SUGGESTION_SESSION_RESILIENCE.md`

## Reglas del Proyecto
1. No produce software - solo documentos de conocimiento
2. Formato de incidentes estandarizado (ver SEED_DOCUMENT.md seccion 4)
3. Todo hallazgo referencia la fuente (proyecto, fecha, contexto)
4. Las propuestas de mejora se aplican en Metodologia General, no aqui

## Docs
@C:/claude_context/research/context-engineering/SEED_DOCUMENT.md
@C:/claude_context/research/context-engineering/PRODUCT_BACKLOG.md
@C:/claude_context/research/context-engineering/TASK_STATE.md
