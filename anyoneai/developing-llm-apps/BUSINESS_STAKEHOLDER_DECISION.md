# Business Stakeholder Decision - LLM-based Recruitment Tool
**Fecha:** 2026-03-23 | **Decision:** GO | **Evaluador:** Business Stakeholder

## 1. Alineacion Estrategica

El proyecto se alinea directamente con los 5 learning objectives de la especializacion:

| Learning Objective | Cobertura en Backlog |
|--------------------|---------------------|
| LLM fundamentals | Fase 2: Gemini integration, prompt templates |
| Prompt engineering | Fase 2-3: system prompts, recruitment-specific prompts |
| RAG pipeline (retrieval + embeddings + chunking) | Fase 1-2: PDF ingestion, HF embeddings, Chroma, MMR retrieval |
| Tools, agents, chat memory | Fase 2-3: LangChain agents, conversation memory |
| Aplicacion funcional entregable | Fase 4: testing, packaging, delivery como .zip |

Cobertura estimada: 100% de los objectives tienen historias dedicadas.

## 2. Evaluacion

| Criterio | Score (1-5) | Comentario |
|----------|:-----------:|-----------|
| Business value (aprendizaje + portfolio) | 5 | Demuestra competencias LLM end-to-end. Pieza de portfolio diferenciadora. |
| User impact (utilidad) | 3 | Herramienta funcional pero acotada a demo. Sin datos reales de produccion. |
| ROI (tiempo vs conocimiento) | 4 | 63 pts (~3-4 semanas) por dominio completo del stack RAG. Alto retorno educativo. |
| Risk (no completar / completar mal) | 3 | Riesgo medio: 1 developer, stack nuevo. Mitigado por backlog bien estructurado (4 fases). |
| Time-to-market (factibilidad timeline) | 4 | 22 stories en 4 fases con dependencias claras. Factible si se respeta orden de fases. |
| **Score ponderado** | **3.9/5** | |

## 3. Decision: GO

**Justificacion:**
- El proyecto cubre el 100% del curriculum como aplicacion practica integrada.
- El backlog de 22 stories con 4 fases provee un roadmap claro y ejecutable.
- El stack (LangChain + Chroma + Gemini + Chainlit) es exactamente lo requerido por el curso.
- La arquitectura de 12 componentes demuestra diseho profesional sin over-engineering.
- El analisis de seguridad (10 amenazas con mitigaciones) excede lo esperado para un proyecto educativo.

## 4. Metricas de Exito

| Metrica | Target | Medicion |
|---------|--------|----------|
| Stories completadas | 22/22 (100%) | Backlog tracking |
| RAG pipeline funcional | Query E2E en <5s | Manual test con PDFs de prueba |
| Chat UI operativa | Conversacion multi-turn funcional | Demo manual en Chainlit |
| Recruitment features | Skill analysis + job matching operativos | 3 consultas de prueba con respuestas coherentes |
| Entregable | .zip sin datos/modelos, ejecutable con instrucciones | Descomprimir en maquina limpia y ejecutar |
| Coverage academico | 5/5 learning objectives demostrados | Checklist contra objectives del curso |

## 5. Riesgos a Monitorear

| # | Riesgo | Probabilidad | Impacto | Mitigacion |
|---|--------|:------------:|:-------:|-----------|
| R1 | Gemini API rate limits o costos inesperados | Media | Alto | Usar free tier, cachear respuestas durante dev |
| R2 | Scope creep en recruitment features | Media | Medio | Respetar MoSCoW del backlog, Fase 3 es "should have" |
| R3 | Problemas de calidad en chunking/retrieval | Alta | Alto | Testear con PDFs reales desde Fase 1, iterar parametros |
| R4 | Dependencia de versiones LangChain (breaking changes) | Baja | Medio | Fijar versiones en requirements.txt |
| R5 | Tiempo insuficiente para Fase 4 (testing/delivery) | Media | Alto | No sacrificar Fase 4; reducir scope de Fase 3 si es necesario |

## 6. Condiciones de Re-evaluacion

Reconsiderar approach si ocurre alguna de estas situaciones:

1. **Fase 1 toma >2x lo estimado** - indica subestimacion sistematica; re-planificar todo el backlog.
2. **Gemini free tier se agota o cambia pricing** - evaluar switch a modelo local (Ollama) o OpenAI.
3. **RAG pipeline no produce respuestas coherentes al cierre de Fase 2** - pivotar a retrieval mas simple (keyword search + LLM).
4. **Quedan <5 dias y Fase 3 no arranco** - skip Fase 3, entregar Fase 1+2+4 como MVP funcional.
5. **Cambio en requisitos de entrega del curso** - adaptar backlog inmediatamente.

---
**Score final: 3.9/5 | Decision: GO | Sin condiciones bloqueantes.**
