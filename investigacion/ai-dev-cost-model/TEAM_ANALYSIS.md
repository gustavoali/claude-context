# Equipo de Analisis - AI Development Cost Model
**Fecha:** 2026-03-13 | **Estado:** Semilla (equipo no activo aun)

## Composicion del Equipo de Analisis

### Arquitecto / Diseñador del Modelo
**Agente:** `software-architect` (perfil backend)
**Responsabilidades:**
- Disenar la arquitectura del modelo de costeo
- Definir las interfaces entre componentes (C1-C4)
- Evaluar enfoques alternativos para el modelo de transicion
- Validar la metodologia de medicion

**Primera tarea sugerida:** Revisar SEED_DOCUMENT.md y proponer arquitectura detallada del modulo `models/`. Definir interfaces Python para `CostEstimator`, `TransitionModel`, `TokenCalculator`.

---

### Product Owner / Investigador Principal
**Agente:** `product-owner`
**Responsabilidades:**
- Traducir preguntas de investigacion (PQ-001 a PQ-010) en historias de usuario
- Priorizar el backlog de investigacion
- Definir criterios de aceptacion para cada entregable

**Primera tarea sugerida:** Crear PRODUCT_BACKLOG.md a partir de las preguntas de investigacion del SEED_DOCUMENT.md y los criterios de exito.

---

### Analista de Seguridad / Etica
**Agente:** `business-stakeholder`
**Responsabilidades:**
- Evaluar implicaciones eticas del modelo (uso para justificar reemplazos)
- Definir el framing correcto del documento ejecutivo
- Validar que los criterios de exito alinean con el objetivo real
- Identificar audiencias y casos de uso del modelo

**Primera tarea sugerida:** Revisar riesgos eticos identificados en SEED_DOCUMENT.md y proponer guia de uso responsable del modelo.

---

## Plan de Analisis Inicial

### Fase A: Validacion del Framework (1-2 sesiones)
1. Revisar taxonomia de tareas (C2) contra proyectos reales del ecosistema
2. Validar supuestos del modelo tradicional (C3) con datos de mercado
3. Calibrar multiplicadores de complejidad con historias reales

### Fase B: Recoleccion de Datos (1-2 sesiones)
1. Extraer datos de consumo de tokens de proyectos del ecosistema
2. Compilar tabla de precios actuales de LLM providers
3. Recopilar datos de salarios de mercado (AR, US como minimo)

### Fase C: Construccion del Modelo (2-4 sesiones)
1. Implementar `cost_estimator.py` con datos reales
2. Implementar `transition_model.py` y calcular punto de inflexion
3. Crear notebooks interactivos

### Fase D: Validacion y Comunicacion (1 sesion)
1. Validar modelo contra proyectos del ecosistema
2. Escribir documento ejecutivo
3. Crear notebook de demo interactiva

---

## Fuentes de Datos a Explorar

| Fuente | Tipo | Disponibilidad |
|--------|------|----------------|
| Anthropic Console billing | Tokens reales por sesion | Inmediata (requiere login) |
| TASK_STATE.md de proyectos | Proxy de trabajo realizado | Inmediata |
| Git commits del ecosistema | Volumen de output (lineas) | Inmediata |
| GitHub Copilot Impact Study 2022 | Benchmarks velocidad | Publica |
| McKinsey "The economic potential of generative AI" (2023) | Productividad IA | Publica |
| SWE-bench leaderboard | Capacidad de agentes en codigo | Publica |
| Glassdoor / levels.fyi | Salarios de mercado | Publica |
| Encuesta sysarmy Argentina | Salarios dev AR | Publica |

---

**Version:** 1.0 | **Fecha:** 2026-03-13
