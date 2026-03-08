# Project Admin - Business Stakeholder Decision

**Proyecto:** Project Admin - Fase 1
**Fecha:** 2026-02-13
**Decision:** GO (con scope ajustado)
**Stakeholder:** Business Stakeholder Agent

---

## 1. Decision: GO CONDICIONAL

**Veredicto: GO para Fase 1 con scope reducido.**

La iniciativa Project Admin resuelve un problema real: 26 proyectos dispersos en 4 directorios sin catalogo central ni forma programatica de consultarlos desde Claude Code. El valor principal esta en los MCP tools que permiten a Claude Code tener vision global del ecosistema durante sesiones de trabajo.

Sin embargo, el scope propuesto en el Seed Document es excesivo para un solo desarrollador con un dolor moderado. La Fase 1 tal como esta planteada (2-3 sprints, 18-23 stories, 4 epics) tiene riesgo de over-engineering. A continuacion se detalla el scope aprobado con ajustes.

### Justificacion del GO

1. **El problema existe y es frecuente.** Cada vez que se inicia sesion en un proyecto, no hay forma rapida de responder "donde esta X", "que stack usa Y", "que relacion tiene con Z". Esto se resuelve hoy con busqueda manual en el filesystem o en claude_context, lo cual es lento e incompleto.

2. **MCP tools son el canal correcto.** El usuario trabaja primariamente con Claude Code. Exponer la informacion de proyectos via MCP tools es el mecanismo de mayor impacto porque se integra directamente en el flujo de trabajo existente.

3. **El costo es razonable si se acota.** Un scope ajustado de 1.5 sprints (~55h de trabajo efectivo) es una inversion aceptable para el valor esperado.

4. **Habilita futuro sin comprometer presente.** La REST API es un costo marginal adicional sobre los services ya necesarios para MCP, y deja la puerta abierta al dashboard Angular sin obligar a construirlo.

---

## 2. Evaluacion de Valor por Componente

### 2.1 Registro Centralizado de Proyectos

| Dimension | Evaluacion |
|-----------|------------|
| **Valor** | ALTO. Es el core del producto. Sin esto, nada mas tiene sentido. |
| **Esfuerzo** | MEDIO. Schema PostgreSQL + CRUD es straightforward con la experiencia de SBM. |
| **ROI** | Positivo. Se usa multiples veces por dia una vez disponible. |
| **Veredicto** | MUST HAVE |

El registro centralizado es la razon de ser del proyecto. La tabla `projects` con slug, path, stack, status y category cubre el 80% de las consultas que un desarrollador necesita. Los campos JSONB (health, config) agregan flexibilidad sin complejidad excesiva.

**Observacion critica:** El modelo de datos propuesto tiene 5 tablas (projects, project_tags, project_relationships, project_metadata, scan_history). Para Fase 1 con 26 proyectos, esto es mas estructura de la necesaria. La tabla `project_metadata` en particular es un patron de extensibilidad prematura; los campos JSONB en `projects` ya cubren metadata flexible.

### 2.2 MCP Tools para Claude Code

| Dimension | Evaluacion |
|-----------|------------|
| **Valor** | MUY ALTO. Es el principal punto de contacto con el usuario. |
| **Esfuerzo** | MEDIO. Depende de que los services esten listos. |
| **ROI** | El mas alto de todos los componentes. Uso diario garantizado. |
| **Veredicto** | MUST HAVE |

Los MCP tools son donde se materializa el valor de negocio. Sin embargo, de los 13 tools propuestos para Fase 1, no todos tienen el mismo valor:

**Tools de alto impacto (uso diario):**
- `pa_list_projects` - Listar y filtrar proyectos
- `pa_get_project` - Detalle de un proyecto
- `pa_search_projects` - Busqueda cross-project
- `pa_get_ecosystem_stats` - Vista rapida del ecosistema

**Tools de impacto medio (uso semanal):**
- `pa_project_health` - Health check
- `pa_scan_directory` - Registrar proyecto nuevo
- `pa_create_project` / `pa_update_project` - CRUD manual

**Tools de bajo impacto (uso ocasional):**
- `pa_delete_project` - Raramente necesario
- `pa_add_relationship` / `pa_get_relationships` - Las relaciones son utiles pero no criticas con 26 proyectos
- `pa_set_metadata` - Sobra si se usa JSONB directamente
- `pa_scan_all` - Util una vez, luego incremental

### 2.3 REST API para Dashboard Futuro

| Dimension | Evaluacion |
|-----------|------------|
| **Valor** | BAJO en Fase 1 (no hay consumidor). MEDIO como inversion estrategica. |
| **Esfuerzo** | BAJO si se construye sobre los mismos services que MCP. |
| **ROI** | Neutro ahora. Positivo solo si se construye el dashboard. |
| **Veredicto** | SHOULD HAVE (implementar basico, no pulir) |

La REST API no tiene consumidor inmediato. Su valor depende enteramente de que se construya el Angular Dashboard (Fase 2+), lo cual no esta garantizado. Sin embargo, el costo marginal de exponerla es bajo porque Fastify + los mismos services ya necesarios para MCP requieren solo agregar route handlers. La recomendacion es implementar los endpoints basicos de projects sin invertir en paginacion sofisticada, Swagger completo ni endpoints de tags/relationships/ecosystem separados.

### 2.4 Auto-Discovery de Proyectos (Filesystem Scanner)

| Dimension | Evaluacion |
|-----------|------------|
| **Valor** | MEDIO. Util para el seed inicial. Bajo valor recurrente. |
| **Esfuerzo** | MEDIO-ALTO. Deteccion de stack, git integration, heuristicas. |
| **ROI** | Bajo. Se usa una vez para poblar la DB. Despues, los proyectos nuevos son raros (~2-3/mes). |
| **Veredicto** | COULD HAVE (simplificar drasticamente) |

**Analisis critico:** El scan-service propuesto es la feature con peor relacion valor/esfuerzo de Fase 1. Las razones:

1. Se necesita exactamente UNA VEZ para registrar los 26 proyectos existentes. Despues de eso, los proyectos nuevos se pueden registrar manualmente con `pa_create_project` (mas rapido y preciso).

2. La deteccion automatica de stack por archivos presentes es fragil. Un `package.json` no distingue entre un proyecto Express, un proyecto Fastify, un CLI tool o un monorepo. El usuario sabe mejor que el scanner que stack usa cada proyecto.

3. El esfuerzo estimado (scan-service + fs-scanner + git-utils + tests) es ~12h. Ese tiempo se puede invertir mejor en pulir los MCP tools de alto impacto.

**Alternativa recomendada:** Un script de seed data simple (no un servicio completo) que lea los 4 directorios, detecte subdirectorios con `.git`, y genere registros basicos. La deteccion de stack se puede hacer manualmente para 26 proyectos en 30 minutos. Luego agregar auto-scan como mejora futura si se detecta necesidad real.

### 2.5 Health Checks

| Dimension | Evaluacion |
|-----------|------------|
| **Valor** | MEDIO-BAJO. Interesante pero no critico para 1 developer. |
| **Esfuerzo** | MEDIO. Git commands en Windows pueden ser lentos, necesita caching. |
| **ROI** | Bajo. El developer ya sabe intuitivamente el estado de sus proyectos activos. |
| **Veredicto** | COULD HAVE |

**Analisis critico:** Los health checks (git branch, ultimo commit, working tree status) son datos que el developer ya conoce para los ~10 proyectos activos. Para los ~16 proyectos legacy/inciertos, saber si tienen cambios uncommitted no cambia ninguna decision. El mayor valor seria detectar proyectos "olvidados" con trabajo sin commitear, pero eso es un problema infrecuente.

**Recomendacion:** Implementar health check basico (existe directorio, tiene .git, ultimo commit date) como parte del seed data, sin un servicio dedicado con caching y refresh on-demand. Si se demuestra uso frecuente del tool `pa_project_health`, expandir despues.

---

## 3. Preguntas Clave Respondidas

### "Un registro central de proyectos con MCP tools, aporta suficiente valor al workflow diario con Claude Code?"

**Si, con matices.** El valor esta concentrado en 4-5 MCP tools de uso frecuente (list, get, search, stats). Estos tools eliminan la friccion de "en que directorio esta X" y "que stack usa Y" que hoy requiere navegacion manual. Para un developer con 26 proyectos en 4 directorios distintos, tener esto accesible via lenguaje natural en Claude Code es un upgrade significativo.

El matiz importante: el valor se materializa SOLO si los datos estan completos y actualizados. Un registro a medias (con 10 de 26 proyectos, sin stack, sin relaciones) tiene valor cercano a cero porque el developer no puede confiar en el y vuelve a buscar manualmente. La calidad del seed data inicial es mas critica que la cantidad de features.

### "La inversion de 2-3 sprints para Fase 1 se justifica?"

**No al scope completo. Si a un scope reducido de 1.5 sprints.**

El scope original (4 epics, 18-23 stories, 2-3 sprints) incluye demasiada ingenieria para el problema a resolver. Especificamente:

- 5 tablas de base de datos para 26 registros es excesivo
- 13 MCP tools cuando 6-8 cubren el 90% del uso
- REST API completa con paginacion, Swagger, CORS para un servicio sin consumidor inmediato
- Filesystem scanner completo para un evento puntual (seed data)
- Health service con caching para datos que cambian poco

**Inversion recomendada:** 1.5 sprints (~55h), enfocados en: schema core (3 tablas), services CRUD, 8 MCP tools esenciales, REST API basica, seed data manual+script, tests de services.

### "El auto-scan de filesystem es must-have o nice-to-have?"

**Nice-to-have, tirando a no necesario para Fase 1.** El auto-scan resuelve un problema puntual (registrar 26 proyectos) que se puede resolver de forma mas simple y precisa con un script de seed data + revision manual. El developer crea ~2-3 proyectos nuevos por mes; registrarlos manualmente con `pa_create_project` toma 30 segundos cada uno.

El auto-scan se vuelve valioso solo si la cantidad de proyectos crece significativamente (>100) o si multiples developers necesitan mantener el catalogo sincronizado. Ninguna de estas condiciones aplica hoy.

---

## 4. Scope Aprobado (MoSCoW)

### Must Have (Sprint 1 completo)

| Componente | Detalle |
|------------|---------|
| Schema PostgreSQL | Tablas: `projects`, `project_tags`, `project_relationships`. Sin `project_metadata` ni `scan_history`. Metadata va en JSONB de `projects.config`. |
| Docker PostgreSQL | Container en puerto 5433, volume nombrado, restart policy. |
| Project Service + Repository | CRUD completo de proyectos. |
| Tag Service + Repository | Asignar/remover tags. |
| Relationship Service + Repository | Relaciones entre proyectos (depends_on, replaces, etc.). |
| MCP Server | Entry point funcional con @modelcontextprotocol/sdk. |
| MCP Tools core (8) | `pa_list_projects`, `pa_get_project`, `pa_create_project`, `pa_update_project`, `pa_delete_project`, `pa_search_projects`, `pa_add_relationship`, `pa_get_ecosystem_stats` |
| Seed data | Script que registre los 26 proyectos con datos completos (slug, name, path, stack, status, category, tags). Puede ser parcialmente manual. |
| Tests unitarios | >70% coverage en services. |
| Migration system | migrate.js basico (up only en Fase 1, reversible en futuro). |

### Should Have (Sprint 2, primera mitad)

| Componente | Detalle |
|------------|---------|
| REST API basica | Endpoints de projects CRUD + search. Sin Swagger elaborado. |
| `pa_project_health` tool | Health check basico (directorio existe, tiene .git, ultimo commit). |
| `pa_get_relationships` tool | Consultar relaciones de un proyecto. |
| Tests de integracion | API endpoints y MCP tools. |
| README | Instrucciones de setup y uso. |

### Could Have (Sprint 2, si hay tiempo)

| Componente | Detalle |
|------------|---------|
| REST API de tags y relationships | Endpoints separados. |
| `pa_scan_directory` tool | Scan de un directorio individual. |
| Swagger/OpenAPI | Documentacion auto-generada. |
| Health service con caching | TTL de 5 minutos para scan results. |
| `pa_set_metadata` tool | Si se mantiene JSONB, no es necesario como tool separado. |

### Won't Have (Fase 1)

| Componente | Razon |
|------------|-------|
| `pa_scan_all` tool | Over-engineering. Seed data manual es suficiente. |
| Tabla `scan_history` | Sin scanner automatico, no hay historial que registrar. |
| Tabla `project_metadata` separada | JSONB en `projects.config` cubre el caso. Agregar tabla si se demuestra necesidad. |
| WebSocket server | Es de Fase 2. |
| Integracion con SBM/CO | Es de Fase 2. |
| ESLint/Prettier | Nice to have, no bloquea valor. Agregar cuando haya friccion. |

---

## 5. Riesgos de Negocio

| # | Riesgo | Probabilidad | Impacto | Mitigacion |
|---|--------|-------------|---------|------------|
| 1 | **Datos incompletos en seed.** Si el registro tiene datos parciales o incorrectos, el developer no confia y no usa el sistema. Valor entregado = 0. | Alta | Critico | Dedicar 2-3h exclusivamente a curar el seed data. Verificar manualmente cada uno de los 26 proyectos. No automatizar lo que se puede verificar a mano. |
| 2 | **Scope creep durante desarrollo.** El proyecto tiene un seed document muy detallado que invita a implementar todo. Riesgo de que 1.5 sprints se conviertan en 3+. | Media | Alto | Respetar estrictamente el MoSCoW de este documento. El Product Owner debe rechazar stories que no esten en Must Have o Should Have. |
| 3 | **Baja adopcion post-lanzamiento.** El developer puede seguir usando los metodos actuales (navegar filesystem, consultar claude_context) por inercia. | Media | Alto | Los MCP tools deben ser significativamente mas rapidos que la alternativa manual. Si no lo son, el proyecto fracaso. Medir uso real en las primeras 2 semanas. |
| 4 | **Otro container PostgreSQL consume recursos.** La maquina ya tiene PostgreSQL para SBM. Un segundo container usa ~200MB RAM adicional. | Baja | Bajo | Monitorear. Si es problema, evaluar compartir instancia PostgreSQL con bases separadas. |
| 5 | **Fastify learning curve.** El ecosistema existente usa Express (CO) y raw Node (SBM). Fastify es nuevo. | Baja | Bajo | La API surface de Fastify es similar a Express. El plugin system es mas estructurado pero no fundamentalmente diferente. Si genera friction, se puede pivotar a Express en Sprint 1. |
| 6 | **El proyecto se convierte en infraestructura que hay que mantener.** Una vez creado, necesita mantenimiento cuando se agregan/archivan proyectos. | Media | Medio | Mantener el sistema simple (scope reducido). Cuantas menos tablas y features, menos mantenimiento. No agregar complejidad especulativa. |

---

## 6. Metricas de Exito

### Metricas Primarias (medir a las 2 semanas post-lanzamiento)

| Metrica | Target | Como Medir |
|---------|--------|------------|
| **Uso de MCP tools** | >5 invocaciones por dia laboral | Log de requests en el MCP server |
| **Datos completos** | 100% de proyectos activos (~10) con stack, status, category, tags | Query a la DB |
| **Tiempo de respuesta percibido** | Respuesta util en <2 segundos | Percepcion subjetiva del developer |
| **Adopcion** | El developer usa `pa_list_projects` o `pa_search_projects` en lugar de buscar manualmente | Observacion cualitativa |

### Metricas Secundarias (medir al mes)

| Metrica | Target | Como Medir |
|---------|--------|------------|
| **Datos de proyectos legacy actualizados** | 100% de los 26 proyectos con datos basicos | Query a la DB |
| **Relaciones registradas** | >10 relaciones entre proyectos | Query a la DB |
| **Proyectos nuevos registrados via PA** | Todo proyecto nuevo pasa por `pa_create_project` | Verificar que no hay proyectos en disco sin registrar |

### Criterio de Exito Global

**Fase 1 es exitosa si:** El developer, al iniciar sesion de trabajo en cualquier proyecto, puede preguntarle a Claude Code "que proyectos tengo en el ecosistema MCP?" o "donde esta el proyecto X?" y obtener una respuesta completa y precisa en menos de 2 segundos, sin necesidad de navegar el filesystem.

**Fase 1 fracasa si:** Despues de 2 semanas, el developer sigue consultando manualmente los directorios porque los datos de Project Admin estan incompletos, desactualizados, o los MCP tools son mas lentos que la alternativa manual.

---

## 7. Recomendaciones para Fases Futuras

### Fase 1b (Migracion github-sync): POSTERGAR

**Recomendacion: NO iniciar Fase 1b inmediatamente despues de Fase 1.**

Razones:
1. Sprint Tracker con github-sync FUNCIONA hoy. No hay urgencia de migrar.
2. La migracion no agrega valor nuevo; solo mueve funcionalidad existente de un lugar a otro.
3. El esfuerzo (1 sprint) se invierte mejor en validar que Fase 1 entrega valor real.
4. Si Fase 1 no demuestra adopcion, todo el roadmap de Project Admin se debe reevaluar antes de invertir mas.

**Cuando hacerla:** Despues de validar metricas de exito de Fase 1 (2-4 semanas post-lanzamiento). Si las metricas son positivas, Fase 1b entra como trabajo de deuda tecnica en un sprint regular, no como iniciativa separada.

### Fase 2 (Integracion SBM + CO): EVALUAR DESPUES DE FASE 1

**Recomendacion: Decision de GO/NO-GO para Fase 2 se toma 1 mes despues de completar Fase 1.**

La integracion cross-service es donde Project Admin se convierte en algo realmente diferenciado (vista 360 de un proyecto: codigo + sprints + sesiones). Pero tambien es donde la complejidad sube significativamente (HTTP clients, error handling de servicios downstream, caching, datos eventuales).

**Condiciones para GO de Fase 2:**
- Fase 1 cumple metricas de exito (uso >5/dia, datos completos)
- El developer expresa necesidad real de ver datos de SBM/CO desde Project Admin
- SBM tiene REST API lista o el esfuerzo de agregarla es aceptable

**Condiciones para NO-GO de Fase 2:**
- Fase 1 tiene baja adopcion (<3 usos/dia)
- El developer prefiere consultar SBM y CO directamente
- El costo de mantener 3 servicios interconectados no se justifica para 1 developer

### Fase 2+ (Angular Dashboard): ESCEPTICISMO SALUDABLE

**Recomendacion: No comprometer recursos hasta que Fase 2 este completa y validada.**

Un Angular Dashboard para un solo developer es una inversion cuestionable (3-4 sprints = 150-200h). Las alternativas son significativamente mas baratas:

1. **MCP tools (ya incluidos en Fase 1):** Cubren el 80% de las consultas sin UI.
2. **Script de reporte:** Un script que genere un markdown con el estado del ecosistema, consultable desde cualquier editor. Costo: 2-3h.
3. **Flutter Monitor existente (ya en scaffolding):** Expandir para mostrar datos de Project Admin en lugar de crear un segundo frontend.

**El dashboard Angular se justifica SOLO si:**
- Hay necesidad de visualizaciones graficas complejas (grafos de dependencias, burndown charts cross-project)
- Multiples personas necesitan consultar el ecosistema (no solo el developer)
- Los MCP tools resultan insuficientes para ciertos patrones de consulta

---

## 8. Presupuesto Aprobado

| Concepto | Horas | Sprint |
|----------|-------|--------|
| Schema + DB setup + migrations | 6h | Sprint 1 |
| Services + Repositories (project, tag, relationship) | 10h | Sprint 1 |
| MCP Server + 8 tools core | 10h | Sprint 1 |
| Seed data (script + curado manual) | 4h | Sprint 1 |
| Tests unitarios services | 6h | Sprint 1 |
| **Subtotal Sprint 1** | **36h** | |
| REST API basica | 5h | Sprint 2 |
| Health check basico + tool | 3h | Sprint 2 |
| Tests integracion | 4h | Sprint 2 |
| README + documentacion | 2h | Sprint 2 |
| Buffer (bugs, ajustes, imprevistos) | 5h | Sprint 2 |
| **Subtotal Sprint 2 (parcial)** | **19h** | |
| **TOTAL APROBADO** | **~55h** | **1.5 sprints** |

**Nota:** Si Sprint 1 se completa en menos tiempo del estimado, el excedente se usa para adelantar items de Should Have. Si se excede, se recortan items de Could Have.

---

## 9. Respuestas a Preguntas Abiertas del Seed Document

| # | Pregunta | Respuesta del Stakeholder |
|---|----------|--------------------------|
| 1 | Puerto REST API 3000 | Aprobado. Verificar en runtime que no este en uso. |
| 2 | Autenticacion Angular Dashboard | No aplica en Fase 1. Cuando se llegue a Fase 2+, solo localhost sin auth es aceptable para 1 developer. |
| 3 | SBM REST API | No es problema de Fase 1. Resolver en pre-Fase 2 si se llega. |
| 4 | Worktrees de LinkedIn como proyectos | NO registrar worktrees como proyectos separados. Son branches del proyecto principal (LTE). Registrar solo el proyecto base. |
| 5 | Frecuencia de auto-scan | On-demand en Fase 1 (y simplificado). No scheduled. |
| 6 | Angular vs React para dashboard | Decision postergada hasta pre-Fase 2+. Evaluar tambien Flutter Web como alternativa que reutiliza conocimiento existente. |

---

## 10. Condiciones del GO

Este GO esta sujeto a las siguientes condiciones:

1. **El scope se respeta.** Si durante el desarrollo se detecta que el scope crece mas alla de lo aprobado aqui, se pausa y se re-evalua con el stakeholder.
2. **Seed data de calidad.** Antes de declarar Fase 1 como completa, los 26 proyectos deben estar registrados con datos verificados manualmente.
3. **Review de valor a las 2 semanas.** Se miden las metricas primarias y se decide si continuar con Should Have o pivotar.
4. **No auto-comprometer Fase 2.** La finalizacion de Fase 1 NO implica automaticamente el inicio de Fase 2. Se requiere una nueva decision de negocio.

---

**Documento creado:** 2026-02-13
**Proximo paso:** Product Owner crea PRODUCT_BACKLOG.md con stories alineadas al scope aprobado en este documento.
