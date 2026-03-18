# Arquitectura de Informacion - LLM Landscape
**Version:** 0.1.0 | **Fecha:** 2026-03-16

## Mapa Conceptual (ASCII)

```
                    +---------------------------+
                    |     LLM LANDSCAPE         |
                    |   (Base de Conocimiento)  |
                    +---------------------------+
                               |
         +----------+----------+----------+----------+
         |          |          |          |          |
    +--------+ +--------+ +--------+ +--------+ +--------+
    | models | | frame- | | appli- | |futures | |reading |
    |        | | works  | | cations| |        | | _notes |
    +--------+ +--------+ +--------+ +--------+ +--------+
         |          |          |          |          |
    providers  orchestr.  by-domain  scaling    papers
    benchmarks deploym.   case-stud. agentic   articulos
    open-vs-   vector-st            economic
    closed     eval-obs.            amodei
               dev-tools            timeline

    +--------+
    |resourc.|  glossary.md, links.md
    +--------+

    Relaciones clave:
    models --[se usan en]--> applications
    models --[se acceden via]--> frameworks/deployment
    frameworks --[habilitan]--> applications
    futures --[proyecta]--> models, frameworks, applications
    reading_notes --[alimenta]--> todas las dimensiones
```

## Componentes del Repositorio

| Seccion | Proposito | Contenido | Formato |
|---------|-----------|-----------|---------|
| `models/providers/` | Inventario por proveedor | 1 archivo por proveedor con todos sus modelos | Ficha de proveedor |
| `models/benchmarks/` | Comparativas cuantitativas | Tablas centralizadas de benchmarks y costos | Tablas markdown |
| `models/open-vs-closed.md` | Analisis estrategico | Comparacion open weights vs propietario | Ensayo estructurado |
| `frameworks/orchestration/` | Catalogo de orquestacion | 1 archivo por framework (LangChain, CrewAI, etc.) | Ficha de framework |
| `frameworks/deployment/` | Plataformas de deploy | 1 archivo por plataforma (APIs, cloud, local) | Ficha de framework |
| `frameworks/vector-stores/` | Bases de datos vectoriales | 1 archivo por vector store | Ficha de framework |
| `frameworks/eval-observability/` | Evaluacion y monitoring | 1 archivo por herramienta | Ficha de framework |
| `frameworks/developer-tools/` | Herramientas de desarrollo | 1 archivo por tool (Claude Code, Copilot, etc.) | Ficha de framework |
| `applications/by-domain/` | Aplicaciones por industria | 1 archivo por dominio (salud, codigo, legal, etc.) | Ficha de dominio |
| `applications/case-studies/` | Casos concretos | Implementaciones reales con resultados | Caso de estudio |
| `futures/` | Proyecciones y tendencias | Archivos tematicos (scaling, agentes, economia) | Ensayo + timeline |
| `reading_notes/` | Notas de lectura | Papers, articulos, reportes procesados | Ficha de lectura |
| `resources/glossary.md` | Glosario tecnico | Terminos clave del ecosistema LLM | Definiciones A-Z |
| `resources/links.md` | Links curados | Referencias externas organizadas por tema | Lista categorizada |

## Esquemas de Contenido

### Template: Ficha de Proveedor LLM

```markdown
# [Proveedor] - LLM Portfolio
**Ultima actualizacion:** YYYY-MM-DD
**Sitio:** [URL]
**API docs:** [URL]

## Overview
[2-3 lineas: que es el proveedor, posicion en el mercado]

## Modelos Activos

| Modelo | Release | Contexto | Modalidades | Razonamiento | Precio In/Out (1M tok) |
|--------|---------|----------|-------------|--------------|----------------------|

## Modelos Descontinuados / Legacy
[Tabla similar, colapsada]

## Capacidades Distintivas
- [Que hace este proveedor mejor que otros]

## API y Acceso
- Tipo: [Cloud API / Open weights / Ambos]
- Rate limits: [Si aplica]
- Regiones: [Disponibilidad]

## Notas y Observaciones
- [Experiencia propia, quirks, limitaciones encontradas]

## Historial de Cambios
| Fecha | Cambio |
|-------|--------|
```

### Template: Ficha de Framework/Herramienta

```markdown
# [Nombre] - [Categoria]
**Ultima actualizacion:** YYYY-MM-DD
**Repo/Sitio:** [URL]
**Licencia:** [MIT/Apache/Propietario/etc.]

## Que Es
[2-3 lineas: proposito, problema que resuelve]

## Cuando Usarlo
- [Caso de uso ideal 1]
- [Caso de uso ideal 2]

## Cuando NO Usarlo
- [Anti-patron o alternativa mejor]

## Stack y Requisitos
- Lenguaje: [Python/JS/etc.]
- Dependencias clave: [Si aplica]

## Integraciones
| Se integra con | Como |
|----------------|------|

## Experiencia Propia
[Notas de uso real en proyectos del ecosistema. Si no se uso, marcar "Sin experiencia directa"]

## Alternativas
| Alternativa | Diferencia principal |
|-------------|---------------------|

## Historial de Cambios
| Fecha | Cambio |
|-------|--------|
```

### Template: Ficha de Aplicacion por Dominio

```markdown
# [Dominio] - Aplicaciones LLM
**Ultima actualizacion:** YYYY-MM-DD

## Estado Actual
[Madurez del uso de LLMs en este dominio: emergente/creciente/maduro]

## Aplicaciones Existentes

| Aplicacion | Tipo | Modelos usados | Madurez |
|------------|------|----------------|---------|

## Modelos Recomendados por Tarea

| Tarea | Modelo recomendado | Alternativa | Razon |
|-------|-------------------|-------------|-------|

## Desafios del Dominio
- [Regulacion, datos sensibles, precision requerida, etc.]

## Proyeccion (segun Amodei / tendencias)
[Que se espera en 2-5 anos para este dominio]

## Notas
[Observaciones propias]
```

### Template: Benchmarks y Comparativas

Tres archivos centralizados en `models/benchmarks/`:

**benchmark-scores.md:**
```markdown
# Benchmark Scores - LLM
**Ultima actualizacion:** YYYY-MM-DD
**Fuente principal:** [URL del leaderboard]

## Tabla Principal

| Modelo | MMLU | HumanEval | MATH | GPQA | Arena ELO | Fecha medicion |
|--------|------|-----------|------|------|-----------|----------------|

Notas:
- Scores solo comparables si son del mismo benchmark run/fecha
- Arena ELO: https://chat.lmsys.org
```

**cost-comparison.md:**
```markdown
# Comparativa de Costos - LLM APIs
**Ultima actualizacion:** YYYY-MM-DD

## Precios por Millon de Tokens (USD)

| Proveedor | Modelo | Input | Output | Contexto | Notas |
|-----------|--------|-------|--------|----------|-------|

## Costo Estimado por Caso de Uso

| Caso de uso | Tokens aprox | Modelo recomendado | Costo estimado |
|-------------|-------------|-------------------|----------------|
```

**capability-matrix.md:**
```markdown
# Matriz de Capacidades - LLM
**Ultima actualizacion:** YYYY-MM-DD

| Modelo | Texto | Codigo | Vision | Audio | Video | Tools | Structured Output | Reasoning |
|--------|-------|--------|--------|-------|-------|-------|-------------------|-----------|
[S/N/Parcial por celda]
```

### Template: Reading Notes

```markdown
# [Titulo del Paper/Articulo]
**Autor(es):** [nombres]
**Fecha publicacion:** YYYY-MM-DD
**Fecha lectura:** YYYY-MM-DD
**Tipo:** [paper/articulo/report/blog post]
**URL:** [link]

## Resumen (3-5 lineas)
[De que trata, cual es la tesis principal]

## Ideas Clave
1. [Idea 1]
2. [Idea 2]
3. [Idea N]

## Relevancia para el Ecosistema
[Como se conecta con proyectos propios o decisiones pendientes]

## Citas Destacadas
> [Cita textual relevante]

## Conexiones
- Relacionado con: [otros archivos del repo]
```

## ADRs

### ADR-001: Granularidad de fichas de modelos

**Status:** ACEPTADO
**Contexto:** Los proveedores de LLM tienen multiples modelos (OpenAI tiene GPT-4o, o3, o4-mini, etc.). Se necesita decidir si crear un archivo por modelo individual, uno por proveedor, o un esquema mixto.

**Opciones evaluadas:**
1. **Un archivo por modelo** - Maximo detalle por modelo. Problemas: explosion de archivos (50+), redundancia de info del proveedor, dificil de mantener cuando se lanzan modelos nuevos cada mes.
2. **Un archivo por proveedor** - Todos los modelos del proveedor en una ficha. Problemas: archivos largos para proveedores como OpenAI/Google. Ventajas: contexto del proveedor junto a sus modelos, menos archivos, actualizacion centralizada.
3. **Mixto: proveedor + fichas separadas para modelos estrella** - Archivo por proveedor como indice, fichas individuales solo para modelos con analisis profundo. Problemas: criterio ambiguo de cuando crear ficha individual, duplicacion parcial.

**Decision:** Opcion 2 (un archivo por proveedor). Razones:
- Proyecto de 1 persona; menos archivos = menos overhead de mantenimiento
- Las tablas comparativas en `benchmarks/` cubren la necesidad de comparar modelos entre proveedores
- Si un proveedor crece demasiado, se puede particionar despues (extension sin eliminacion)
- Alineado con criterio de exito "responder en < 2 min": buscar por proveedor es el patron natural

**Consecuencias:**
- (+) ~10 archivos de proveedor en vez de 50+ de modelos individuales
- (+) Actualizacion mas rapida al agregar modelos nuevos
- (-) Archivos de OpenAI/Google pueden superar 150 lineas; aceptable para archivos de contenido

### ADR-002: Estrategia de actualizacion de contenido

**Status:** ACEPTADO
**Contexto:** El ecosistema LLM cambia semanalmente (nuevos modelos, cambios de precios, benchmarks actualizados). Se necesita una estrategia para mantener el contenido relevante sin que sea una carga de mantenimiento insostenible.

**Opciones evaluadas:**
1. **Actualizacion periodica fija** (mensual/quincenal) - Revisar todo el repo en una sesion dedicada. Problemas: acumula desactualizacion, sesion larga y tediosa.
2. **Actualizacion por evento** - Actualizar solo cuando ocurre un cambio relevante (nuevo modelo, cambio de precio). Problemas: requiere estar atento constantemente, facil olvidar.
3. **Mixta: date-stamp + revision trimestral** - Cada ficha tiene "Ultima actualizacion". Cuando se consulta una ficha y esta desactualizada (>2 meses), se actualiza en el momento. Revision trimestral para barrido completo.

**Decision:** Opcion 3 (mixta). Razones:
- Actualizacion lazy: solo se actualiza lo que se consulta (amortiza el costo)
- El campo "Ultima actualizacion" en cada ficha hace visible la frescura
- Revision trimestral captura cambios no detectados por uso
- Compatible con capacidad de 1 persona

**Consecuencias:**
- (+) Mantenimiento distribuido en el tiempo, no acumulado
- (+) Transparencia sobre frescura de datos (siempre visible la fecha)
- (-) Algunas fichas pueden quedar desactualizadas si no se consultan; aceptable para un recurso personal
- (-) Requiere disciplina de actualizar `Ultima actualizacion` en cada edicion

### ADR-003: Formato de benchmarks y costos

**Status:** ACEPTADO
**Contexto:** Benchmarks y costos son las dimensiones mas consultadas ("que modelo usar para X con presupuesto Y"). Se necesita decidir si esta informacion vive centralizada en tablas comparativas, distribuida en fichas de proveedor, o ambas.

**Opciones evaluadas:**
1. **Solo en fichas de proveedor** - Cada proveedor tiene sus benchmarks y costos. Problemas: imposible comparar entre proveedores sin abrir 10 archivos.
2. **Solo centralizada** - Tablas en `models/benchmarks/`. Problemas: duplicacion con fichas de proveedor, dos lugares para actualizar.
3. **Centralizada como fuente de verdad, fichas como resumen** - `benchmarks/` tiene las tablas completas y comparativas. Fichas de proveedor tienen una tabla resumida de sus modelos (precio, contexto, modalidades) sin benchmarks cross-provider.

**Decision:** Opcion 3 (centralizada + resumen en fichas). Razones:
- Las comparativas cross-provider DEBEN estar en un solo lugar (criterio de exito #1)
- Las fichas de proveedor necesitan contexto basico de sus modelos (no ir a benchmarks/ para saber el precio de Claude Sonnet)
- Single source of truth para benchmarks = `models/benchmarks/benchmark-scores.md`
- Single source of truth para costos = `models/benchmarks/cost-comparison.md`

**Consecuencias:**
- (+) Respuesta rapida a "mejor modelo para X con presupuesto Y" desde benchmarks/
- (+) Fichas de proveedor auto-contenidas para consulta individual
- (-) Precios aparecen en dos lugares; mitigar con nota "fuente de verdad: cost-comparison.md"

### ADR-004: Naming conventions para archivos

**Status:** ACEPTADO
**Contexto:** Se necesita una convencion consistente para nombrar archivos en todo el repositorio.

**Decision:** Aplicar las siguientes reglas:
- Nombres en **kebab-case** y en **ingles** (estandar del ecosistema tech)
- Proveedores: nombre oficial en minusculas (`openai.md`, `anthropic.md`, `deepseek.md`)
- Frameworks: nombre oficial en minusculas (`langchain.md`, `crewai.md`, `ollama.md`)
- Dominios: nombre del dominio (`healthcare.md`, `coding.md`, `education.md`)
- Reading notes: `YYYY-MM-DD-slug-descriptivo.md` (fecha de lectura, no de publicacion)
- Case studies: `slug-descriptivo.md`

**Consecuencias:**
- (+) Predecible: cualquiera puede adivinar el nombre del archivo sin buscarlo
- (+) Ordenamiento natural por fecha en reading_notes/

## Estrategia de Mantenimiento

### Naming Conventions

Ver ADR-004. Resumen:
- Archivos: kebab-case, ingles, nombre oficial del sujeto
- Reading notes: prefijo `YYYY-MM-DD-`
- Sin versionado en nombres de archivo (la fecha esta dentro del archivo)

### Versionado y Fechas

Cada ficha incluye `**Ultima actualizacion:** YYYY-MM-DD` en el header. No se versiona por archivo individual; el historial esta en git.

**Indicador de frescura:**
- < 2 meses: datos probablemente vigentes
- 2-6 meses: revisar antes de tomar decisiones
- > 6 meses: marcar como `[REVISAR]` en proxima consulta

### Proceso de Actualizacion

1. **Al consultar una ficha:** si `Ultima actualizacion` > 2 meses, actualizar datos clave (precios, modelos nuevos) antes de responder.
2. **Al enterarse de un cambio relevante:** actualizar ficha afectada + tablas de benchmarks/costos si aplica.
3. **Trimestralmente:** barrido completo. Para cada ficha, verificar si hay cambios no capturados. Actualizar o marcar `[REVISAR]`.
4. **Commit messages:** usar prefijo `content:` para cambios de contenido, `structure:` para cambios de organizacion.

## Technical Debt Conocido

| ID | Descripcion | Severidad | Cuando Resolver |
|----|-------------|-----------|-----------------|
| TD-001 | Sin scripts de validacion de frescura (detectar fichas > 2 meses sin update) | Low | Fase 2+ si el repo crece a 30+ archivos |
| TD-002 | Sin indice automatico (README.md con links a todas las fichas) | Low | Al completar Fase 1 (generar indice manual) |
| TD-003 | Benchmarks requieren actualizacion manual; sin scraping de leaderboards | Low | Solo si se consulta frecuentemente y el overhead manual es alto |
| TD-004 | Duplicacion parcial precios en fichas de proveedor y cost-comparison.md | Low | Monitorear; si causa inconsistencias, eliminar de fichas |
| TD-005 | `applications/case-studies/` puede quedar vacio largo tiempo | Informational | Poblar cuando surjan casos reales de proyectos propios |
