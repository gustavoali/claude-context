# Angular Web Monitor - Business Stakeholder Decision

**Version:** 1.0
**Fecha:** 2026-02-14
**Evaluador:** Business Stakeholder (agente)
**Estado:** DECISION EMITIDA

---

## 1. Business Value Assessment

### 1.1 Problema de Negocio

El ecosistema de desarrollo actual carece de una interfaz centralizada que permita:
- Ver el estado de todos los proyectos en una sola pantalla
- Monitorear sprints con metricas visuales (burndown, velocity)
- Observar sesiones de agentes Claude en tiempo real
- Tomar decisiones informadas basadas en datos agregados

El Flutter Monitor existente cubre parcialmente esta necesidad, pero esta orientado a mobile/desktop nativo y ofrece funcionalidad basica de monitoreo, no una experiencia completa de gestion.

### 1.2 Valor Esperado

| Dimension | Impacto | Justificacion |
|-----------|---------|---------------|
| Visibilidad operacional | ALTO | Vista unificada de 10+ proyectos, sprints y sesiones. Actualmente se consultan multiples fuentes. |
| Toma de decisiones | ALTO | Burndown y velocity charts permiten detectar desvios tempranamente y reasignar esfuerzo. |
| Eficiencia del developer | MEDIO | Reduccion de context-switching entre herramientas. Estimado: 15-30 min/dia ahorrados. |
| Monitoreo de agentes AI | MEDIO-ALTO | Sesiones Claude representan un costo operacional (tokens). Visibilidad real-time es critica para optimizar uso. |
| Gestion de deuda tecnica | MEDIO | Registro visual de TD con ROI ayuda a priorizar refactors objetivamente. |

### 1.3 Cuantificacion

- **Ahorro estimado por eficiencia:** 15-30 min/dia x 250 dias/anio = 62-125 horas/anio
- **Reduccion de riesgo:** Deteccion temprana de desvios en sprints puede evitar 1-2 sprints fallidos/anio
- **Optimizacion de costos AI:** Visibilidad de token usage puede reducir desperdicio en un 10-20%

### 1.4 Evaluacion: Angular vs Ampliar Flutter

| Criterio | Peso | Angular (nuevo) | Flutter (ampliar) |
|----------|------|-----------------|-------------------|
| Experiencia desktop/browser | 25% | 9/10 | 6/10 |
| Riqueza de componentes (tablas, charts, kanban) | 20% | 9/10 | 7/10 |
| Costo de desarrollo (stack nuevo) | 20% | 5/10 | 8/10 |
| Mantenimiento a largo plazo (2 apps vs 1) | 15% | 4/10 | 8/10 |
| Accesibilidad (solo browser, sin instalacion) | 10% | 9/10 | 5/10 |
| Ecosistema de librerias para dashboards | 10% | 9/10 | 6/10 |

**Score ponderado:**
- Angular: (9x25 + 9x20 + 5x20 + 4x15 + 9x10 + 9x10) = 225 + 180 + 100 + 60 + 90 + 90 = **745/1000**
- Flutter: (6x25 + 7x20 + 8x20 + 8x15 + 5x10 + 6x10) = 150 + 140 + 160 + 120 + 50 + 60 = **680/1000**

**Conclusion:** Angular gana por 65 puntos. La ventaja principal es la experiencia nativa de browser para sesiones de trabajo prolongadas y la riqueza de componentes de dashboard. La desventaja (costo de nuevo stack y mantenimiento de 2 apps) es real pero manejable dado que el backend ya existe y Angular es un consumidor puro de API.

**IMPORTANTE:** Esta decision se justifica SOLO si el Flutter Monitor se mantiene como companion mobile/desktop ligero y NO se duplican features entre ambas aplicaciones. Si el Flutter Monitor se ampliara para cubrir todo, el Angular Monitor no se justifica.

---

## 2. Feature Prioritization

### 2.1 Clasificacion MoSCoW

#### MUST HAVE (Fase A - MVP)

| Feature | Justificacion de Negocio |
|---------|-------------------------|
| Dashboard con project cards | Core del producto. Sin esto no hay valor. |
| Tabla con sorting y paginacion | Navegacion eficiente cuando hay 10+ proyectos. |
| Filtros por clasificador y estado | Reduccion de ruido. El usuario necesita encontrar proyectos rapido. |
| Detalle de proyecto | Contexto completo sin saltar a otra herramienta. |
| Responsive desktop-first | El caso de uso principal es browser en desktop. |

#### SHOULD HAVE (Fase B - Sprint Tracking)

| Feature | Justificacion de Negocio |
|---------|-------------------------|
| Burndown chart | Deteccion temprana de desvios. Alto valor para toma de decisiones. |
| Velocity chart | Capacidad de planificacion basada en datos historicos. |
| Lista de stories con filtros | Gestion visual del backlog activo. |
| Story detail | Contexto completo de cada historia sin saltar a archivos. |

| Feature | Clasificacion Ajustada | Nota |
|---------|----------------------|------|
| Kanban board drag-drop | COULD HAVE | Bonito pero no esencial si las stories se gestionan via archivos. El drag-drop agrega complejidad significativa. Recomiendo lista simple con columnas de estado en lugar de kanban interactivo. |
| Technical debt register | COULD HAVE | Util pero el TD register vive en archivos. Mostrar read-only es suficiente. |

#### COULD HAVE (Fase C - Sesiones Claude)

| Feature | Justificacion de Negocio |
|---------|-------------------------|
| Lista de sesiones activas | Visibilidad de que agentes estan corriendo. |
| Token usage por sesion | Control de costos operacionales. |
| Historial de sesiones | Auditoria y optimizacion. |

| Feature | Clasificacion Ajustada | Nota |
|---------|----------------------|------|
| Streaming live de mensajes | COULD HAVE | Interesante pero el developer ya ve el output en su terminal. Valor incremental bajo. |
| Crear/detener sesiones desde web | WON'T HAVE (Fase actual) | Complejidad alta, riesgo de acciones accidentales, valor marginal. |

#### WON'T HAVE (Fase D - Descartado o diferido indefinidamente)

| Feature | Razon de Rechazo |
|---------|-----------------|
| Dashboard configurable drag-drop | Over-engineering para 1 usuario. Layout fijo bien disenado es suficiente. |
| Reportes exportables PDF/CSV | Sin audiencia. El usuario tiene acceso directo a la data. |
| Dark mode | Nice-to-have puro. Si el UI framework lo soporta trivialmente, aceptable. De lo contrario, no invertir tiempo. |
| Comparativa entre proyectos | Sin caso de uso claro. Los proyectos son independientes. |
| Timeline cross-proyecto | Complejidad alta, valor incierto. |
| Notificaciones browser | El developer ya esta en la terminal. Notificaciones web agregan ruido. |

### 2.2 Resumen de Priorizacion

| Fase | Scope Aprobado | Scope Ajustado | Estimacion |
|------|---------------|----------------|------------|
| A (MVP) | Dashboard de proyectos | Sin cambios. Aprobar completo. | 2-3 sprints |
| B | Sprint tracking | Simplificar kanban a lista con columnas. Sin drag-drop. | 2-3 sprints |
| C | Sesiones Claude | Solo lista + metricas. Sin streaming ni control remoto. | 1-2 sprints |
| D | Avanzado | RECHAZADO. No implementar. Reevaluar en 6 meses si hay demanda. | N/A |

---

## 3. Risk Assessment

### 3.1 Riesgos Identificados

| ID | Riesgo | Probabilidad | Impacto | Severidad | Mitigacion |
|----|--------|-------------|---------|-----------|------------|
| R1 | Backend API no esta lista o cambia frecuentemente | Media | Alto | ALTO | Definir API contracts ANTES de comenzar. Mock API para desarrollo independiente. |
| R2 | Scope creep: agregar features no aprobados | Alta | Medio | ALTO | Respetar estrictamente la clasificacion MoSCoW. Todo cambio pasa por backlog y re-evaluacion. |
| R3 | Overhead de mantenimiento de 2 frontends (Angular + Flutter) | Media | Medio | MEDIO | Definir claramente que hace cada uno. Angular = desktop/browser completo. Flutter = mobile/desktop ligero. Sin duplicacion. |
| R4 | NgRx agrega complejidad innecesaria para el volumen de datos | Media | Bajo | BAJO | Evaluar si signals de Angular 17+ son suficientes para Fase A. NgRx solo si la complejidad lo justifica (Fase B+). |
| R5 | El developer invierte mas tiempo en el monitor que en los proyectos que monitorea | Baja | Alto | MEDIO | Time-box: maximo 40% del tiempo del developer en el monitor durante desarrollo activo. |
| R6 | Backend no soporta todos los endpoints necesarios | Media | Alto | ALTO | Mapear endpoints requeridos por fase ANTES de comenzar. Coordinar con backend. |

### 3.2 Dependencias Criticas

| Dependencia | Estado | Riesgo |
|-------------|--------|--------|
| Project Admin Backend REST API | Phase 1 completada | BAJO - ya existe, pero verificar endpoints especificos |
| Sprint Backlog Manager integracion | Pendiente verificacion | MEDIO - confirmar formato de datos |
| Claude Orchestrator WebSocket | Existente | BAJO para Fase C (diferida) |

---

## 4. Condiciones y Recomendaciones

### 4.1 Condiciones para GO

1. **API contracts definidos ANTES de escribir codigo Angular.** El frontend architect y el backend deben acordar exactamente que endpoints existen, que devuelven, y que falta.
2. **Fase D queda RECHAZADA.** No se invierte tiempo en features avanzados hasta que Fases A-C esten en produccion y se valide que el dashboard se usa regularmente (minimo 3 meses).
3. **Kanban simplificado.** No invertir en drag-drop. Lista con indicadores de estado por columna es suficiente.
4. **Evaluacion de NgRx diferida.** Para Fase A, usar state management simple (signals o servicios con BehaviorSubject). NgRx solo se justifica si Fase B demuestra necesidad de estado complejo.
5. **Time-box por fase.** Maximo 3 sprints por fase. Si una fase excede el time-box, hacer retrospectiva antes de continuar.
6. **Metricas de uso.** Despues de Fase A en produccion, medir si el dashboard se usa al menos 3 veces por semana. Si no, pausar Fases B y C.

### 4.2 Recomendaciones Adicionales

- **UI Library:** Recomiendo PrimeNG sobre Angular Material para este caso. PrimeNG tiene componentes de tabla, filtros y dashboard mas ricos out-of-the-box, lo cual reduce tiempo de desarrollo para Fase A.
- **Standalone Components:** Usar la API moderna de Angular 17+ (standalone). No usar NgModules clasicos. El proyecto es nuevo, no hay razon para usar el patron legacy.
- **SSR:** No. Dashboard interno, no necesita SEO ni server-side rendering.
- **Auth:** No para Fase A. Solo cuando haya acceso remoto (fuera de localhost).

---

## 5. Decision GO/NO-GO

### DECISION: GO CONDICIONAL

**Apruebo el inicio del proyecto Angular Web Monitor bajo las siguientes condiciones:**

| # | Condicion | Tipo |
|---|-----------|------|
| 1 | API contracts documentados antes de escribir codigo | Bloqueante |
| 2 | Fase D rechazada (reevaluar en 6 meses) | Obligatoria |
| 3 | Kanban simplificado sin drag-drop | Obligatoria |
| 4 | NgRx diferido a Fase B (evaluar necesidad real) | Recomendada |
| 5 | Time-box 3 sprints por fase | Obligatoria |
| 6 | Metricas de uso post-Fase A para validar continuidad | Obligatoria |

### Justificacion

El proyecto entrega valor real en tres dimensiones medibles:
1. **Eficiencia operacional:** Reduccion de context-switching (62-125 horas/anio)
2. **Calidad de decisiones:** Metricas visuales de sprint permiten deteccion temprana de desvios
3. **Control de costos AI:** Visibilidad de token usage de sesiones Claude

La inversion en Angular se justifica frente a ampliar Flutter porque el caso de uso principal (sesiones de trabajo prolongadas en browser) favorece una SPA web con componentes de dashboard ricos. La diferencia de score (745 vs 680) es significativa en las dimensiones que mas importan: experiencia desktop y riqueza de componentes.

El riesgo principal es el overhead de mantener 2 frontends. Este riesgo se mitiga definiendo claramente el scope de cada uno y NO duplicando features.

### Fases Aprobadas

| Fase | Decision | Condicion |
|------|----------|-----------|
| A (MVP - Dashboard) | GO | API contracts listos |
| B (Sprint Tracking) | GO CONDICIONAL | Solo si Fase A se completa en time-box y se usa regularmente |
| C (Sesiones Claude) | GO CONDICIONAL | Solo si Fases A+B validadas. Scope reducido (sin streaming live). |
| D (Avanzado) | NO-GO | Rechazado. Reevaluar en 6 meses post-produccion. |

### Proximos Pasos

1. Frontend Architect: definir API contracts con el backend (bloqueante)
2. Product Owner: crear backlog de Fase A con scope aprobado
3. Project Manager: planificar timeline con dependencias del backend
4. Frontend Developer: comenzar setup de proyecto una vez API contracts esten listos

### Review Points

| Checkpoint | Cuando | Que evaluar |
|------------|--------|-------------|
| Post-Fase A | Al completar MVP | Se usa 3+ veces/semana? Cumplio time-box? |
| Post-Fase B | Al completar Sprint Tracking | Las metricas de sprint mejoraron decision-making? |
| Pre-Fase C | Antes de iniciar sesiones | Justifica la inversion en WebSocket? |
| 6 meses post-produccion | 6 meses despues de Fase C | Reevaluar Fase D. Hay demanda real? |

---

**Decision emitida por:** Business Stakeholder (agente)
**Fecha:** 2026-02-14
**Vigencia:** Hasta completar Fase A o 3 meses (lo que ocurra primero)
**Proxima revision:** Post-Fase A
