# Business Stakeholder Decision - Gaia Protocol
**Fecha:** 2026-02-21 | **Decision:** GO

## Contexto
Gaia Protocol es un proyecto indie personal de un solo developer. Juego 4X por turnos para Android con diferenciador ecologico. No hay inversion externa ni presion de inversores. El costo es tiempo personal y el retorno esperado es satisfaccion creativa, portfolio y potencial monetizacion futura. El backlog esta definido (119 pts, 7 sprints, 31 historias) y la arquitectura validada.

## Evaluacion
| Criterio | Score (1-5) | Comentario |
|----------|-------------|------------|
| Business value | 3 | Portfolio solido + nicho desatendido. Sin revenue inmediato |
| User impact | 4 | Propuesta unica en mobile 4X: ecologia sin militarismo |
| ROI | 3 | Costo = tiempo personal. ROI positivo si se completa MVP jugable |
| Risk | 3 | Riesgo principal es abandono por complejidad. Mitigable con scope control |
| Time-to-market | 3 | 7 sprints es razonable para 1 dev. Sin presion de competencia directa |

**Score promedio: 3.2/5** - Viable para proyecto indie con expectativas calibradas.

## Analisis de Viabilidad
- **119 pts / 1 developer:** Asumiendo 15-20 pts/sprint, son 6-8 sprints reales. Alineado con el plan de 7 sprints.
- **Velocidad critica:** Si despues de Sprint 2 la velocidad es menor a 12 pts/sprint, re-evaluar scope.
- **Complejidad tecnica:** Los 7 engines son el riesgo mayor. Empezar con Economy + Climate (Sprint 2) valida la arquitectura temprano. Si el pipeline de engines funciona para 2, funciona para 7.
- **Unity + Android:** El rendering hexagonal y la UI movil son los puntos de mayor incertidumbre en esfuerzo. Sprint 1 los aborda temprano, lo cual es correcto.

## Diferenciacion de Mercado
- **Mobile 4X:** Dominado por Civilization clones con combate militar. Polytopia, Hexonia, etc.
- **Nicho ecologico:** Terra Nil (puzzle, no 4X), Eco (PC multiplayer sandbox). No hay 4X mobile ecologico.
- **Ventaja:** First-mover en la interseccion "4X mobile + ecologia + conquista blanda".
- **Riesgo:** Nicho puede ser demasiado pequeno. Mitigacion: el juego es 4X primero, ecologico segundo. Jugadores de 4X que quieren algo diferente son el mercado real.
- **Narrativa de marketing:** "Civilization meets sustainability" es un pitch claro y diferenciado.

## Riesgos de Negocio
| Riesgo | Probabilidad | Impacto | Mitigacion |
|--------|-------------|---------|------------|
| Abandono por complejidad | Media | Critico | Milestones cortos. Cada sprint produce algo jugable |
| Scope creep (mas engines/epicas) | Alta | Alto | MVP cerrado. Todo extra va a backlog post-MVP |
| Balance de gameplay pobre | Media | Alto | Harness IA vs IA desde Sprint 2. Iterar con datos |
| Performance Android insuficiente | Baja | Alto | Profiling temprano en Sprint 1. Mapa 25x25 es manejable |
| Mercado no responde al nicho | Media | Medio | Validar con prototipo jugable antes de pulir. Feedback temprano |
| Perdida de motivacion | Media | Critico | Cada sprint entrega valor visible. Compartir progreso publicamente |

## Metricas de Exito
| Fase | KPI | Target |
|------|-----|--------|
| Desarrollo | Velocidad por sprint | >= 15 pts/sprint promedio |
| Desarrollo | Build Android sin crashes | Desde Sprint 1 |
| MVP completado | Partida jugable 30+ turnos | Sin crashes ni deadlocks |
| MVP completado | Tiempo de turno en Android | < 3 segundos |
| Post-lanzamiento | Descargas primer mes | > 500 (organico, sin paid ads) |
| Post-lanzamiento | Retencion D7 | > 15% |
| Post-lanzamiento | Rating Play Store | >= 3.5 estrellas |

## Condiciones de Re-evaluacion
| Trigger | Accion |
|---------|--------|
| Velocidad < 10 pts/sprint por 2 sprints consecutivos | Reducir scope MVP (cortar Council o Epics) |
| Sprint 3 completado sin partida jugable basica | Pausa. Evaluar si la arquitectura es viable |
| Performance Android inaceptable en Sprint 1 | Pivotar a PC/WebGL primero |
| Perdida total de motivacion por > 3 semanas | Pausa formal. Documentar estado para retomar |
| Post-MVP: < 100 descargas en 2 meses | No invertir en contenido adicional. Evaluar pivot |

## Decision: GO
El proyecto es viable para un developer indie. El riesgo es bajo (costo = tiempo personal), la diferenciacion es real (no hay competencia directa en el nicho), y la arquitectura esta bien planificada con milestones incrementales. Cada sprint produce valor visible, lo que mitiga el riesgo de abandono. El MVP esta correctamente acotado.

**Condicion de la aprobacion:** Mantener discipline de scope. El MVP tiene 31 historias y 119 puntos. No agregar historias al MVP sin remover otras de igual o mayor peso.

## Proximos Pasos
1. Iniciar Sprint 1 (Foundation): repo, estructura Unity, modelos base, hex grid render
2. Establecer velocidad real despues de Sprint 1 y ajustar plan si es necesario
3. Configurar build Android desde Sprint 1 para validar performance temprano
4. Crear harness de simulacion en Sprint 2 para balance con datos reales
5. Compartir progreso publicamente desde Sprint 3 para feedback y motivacion
