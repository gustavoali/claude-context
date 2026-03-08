# IDEA-022: Analisis de costos de desarrollo en tokens/USD y optimizacion de procesos

**Fecha:** 2026-02-16
**Categoria:** improvements
**Estado:** Seed
**Prioridad:** Alta

---

## Descripcion

Reemplazar la estimacion de costos de desarrollo en "dias de trabajo" (metrica irreal para desarrollo asistido por AI) por una estimacion en tokens consumidos y su equivalente en USD. Complementar con analisis de los procesos de desarrollo para identificar formas de usar las herramientas disponibles (agentes, skills, MCP) de manera mas eficiente en funcion del gasto real.

## Motivacion

1. **Dias de trabajo no es real.** Un developer asistido por Claude no trabaja como un developer tradicional. La unidad de medida natural es tokens/USD, no horas/dias.
2. **Visibilidad de costos.** Hoy no hay metricas de cuanto cuesta en tokens/USD brotar un proyecto, implementar una historia, o hacer un code review. Sin visibilidad no hay optimizacion.
3. **Optimizacion de procesos.** Algunos pasos del workflow pueden ser innecesariamente costosos en tokens (contexto excesivo, agentes que leen demasiado, prompts largos). Medir permite optimizar.
4. **Decision informada.** Saber que "brotar un proyecto cuesta ~$X" o "una historia de 3 pts cuesta ~$Y" permite tomar mejores decisiones de priorizacion y scope.

## Alcance Estimado

Mediano - Requiere:
1. Definir metricas (tokens in/out por operacion, costo USD por modelo)
2. Instrumentar los procesos clave (brotar, implementar story, code review, testing)
3. Analizar donde se gasta mas y si ese gasto es justificado
4. Proponer optimizaciones concretas (reducir contexto innecesario, elegir modelo apropiado por tarea, paralelizar mejor)
5. Actualizar metodologia con guidelines de eficiencia de costos

## Proyectos Relacionados

- Metodologia General v3.0 (impacta estimaciones, capacity planning, delegacion)
- Todos los proyectos (impacto transversal)

## Ideas Iniciales

### Metricas a capturar
- Tokens consumidos por tipo de operacion (brotar, implementar, review, test)
- Modelo usado por operacion (Opus vs Sonnet vs Haiku)
- Ratio tokens/story point
- Costo USD por story point

### Optimizaciones a explorar
- Usar Haiku para tareas simples (lectura, busqueda) en lugar de Opus
- Reducir contexto enviado a agentes (solo lo necesario, no "por las dudas")
- Cachear resultados de lecturas frecuentes
- Evaluar si algunos pasos del proceso pueden eliminarse o simplificarse
- Medir overhead de la metodologia misma (cuanto cuestan los documentos de proceso vs el codigo)

### Preguntas abiertas
- Hay forma de obtener el consumo de tokens desde Claude Code programaticamente?
- Se puede instrumentar sin agregar friccion al workflow?
- Cual es el baseline actual? (cuanto cuesta un /brotar tipico?)

## Notas

- Idea propuesta por el usuario durante el brotado de file-reader
- Alineada con el principio de mejora continua de la metodologia

---

## Historial

| Fecha | Evento |
|-------|--------|
| 2026-02-16 | Idea capturada durante brotado de file-reader |
