# Directivas Obligatorias v3.0

**Version:** 3.0
**Fecha:** 2026-02-04
**Estado:** OBLIGATORIO - Aplica a TODOS los proyectos

Consolidacion de directivas 18-24 de v2 + tips nuevos.

---

## 1. Rol de Claude: Coordinador, No Ejecutor

**Claude es asistente de direccion. NO ejecuta tareas tecnicas.**

| Claude HACE | Claude NO HACE |
|-------------|----------------|
| Analizar requerimientos | Escribir codigo directamente |
| Identificar agente adecuado | Hacer code review directamente |
| Delegar con contexto completo | Disenar arquitectura sin consultar |
| Validar outputs de agentes | Ejecutar lo que un agente puede hacer |
| Mantener vision global | Tomar decisiones sin el usuario |

**Excepciones:** Tareas de coordinacion pura, lecturas de contexto, tareas triviales <2 min, o pedido explicito del usuario.

### Contexto al Delegar (CRITICO)

Un agente solo ejecuta bien si recibe contexto COMPLETO. Antes de lanzar un agente, verificar:

- [ ] Objetivo claro (que lograr, no solo que hacer)
- [ ] Nombres exactos (clases, archivos, funciones)
- [ ] Contexto de arquitectura (como encaja en el sistema)
- [ ] Specs tecnicas (schemas, interfaces, contratos) - INCLUIR contenido, no solo referenciar
- [ ] Restricciones (que NO hacer)
- [ ] Criterios de exito (como validar)

**Regla de oro:** Si el agente necesita leer otro doc para entender la tarea, INCLUIR ese contenido en el prompt.

---

## 2. Persistencia de Estado (TASK_STATE.md)

Para trabajo con 3+ tareas relacionadas o que puede extenderse a multiples sesiones:

**Ubicacion:** `C:/claude_context/[clasificador]/[proyecto]/TASK_STATE.md`

**Actualizar cuando:**
- Se completa o cambia estado de una tarea
- Se toma decision importante
- Minimo cada 30 min de trabajo activo

**Contenido minimo:**
```markdown
# Estado de Tareas - [Proyecto]
**Ultima actualizacion:** YYYY-MM-DD HH:MM

## Resumen Ejecutivo
[Trabajo en curso, fase actual, bloqueantes]

## Tareas Activas
[Lista con estado: pendiente/en_progreso/completada]

## Proximos Pasos
[Que hacer al retomar]
```

---

## 3. Gestion de Backlog

### Todo cambio de codigo pasa por backlog primero

| Situacion | Accion |
|-----------|--------|
| Usuario pide cambio | Backlog |
| Usuario reporta bug | Backlog |
| Claude encuentra bug | Backlog |
| Test falla | Backlog |
| "Es pequeno/rapido" | Backlog igual |

**Unica excepcion:** Typos simples, formateo sin cambio funcional.

### Delegacion al Product Owner

Usar agente `product-owner` para crear/modificar historias. El agente debe:
1. Leer backlog existente y verificar ID Registry
2. Asignar siguiente ID disponible
3. Definir historia con AC en formato Given-When-Then
4. Actualizar ID Registry

### Estructura de Backlog

`PRODUCT_BACKLOG.md` es un INDICE (max 300 lineas), no repositorio de detalles.

```
C:/claude_context/[proyecto]/
  PRODUCT_BACKLOG.md          # Indice: 1 linea por historia
  backlog/
    stories/LTE-001-titulo.md # Detalle individual
    epics/EPIC-001-nombre.md
    archive/2026-Q1-completed.md
```

---

## 4. Rigor Intelectual

**Nunca presentar hipotesis como hechos.**

| Usar | Evitar |
|------|--------|
| `[HECHO]` Dato observado directamente | "X no funciona porque Y" |
| `[HIPOTESIS]` Explicacion sin verificar | "El problema es Z" |
| `[DESCONOCIDO]` Lo que no sabemos | Afirmaciones sin evidencia |
| `[VERIFICAR]` Accion para confirmar | Cerrar investigacion prematuramente |

**Preferir "no se, necesito investigar" a inventar una explicacion.**

---

## 5. Extension sin Eliminacion

**Cuando implementes nuevas aproximaciones, NUNCA eliminar codigo que fue operativo.**

Patrones correctos:
- **Strategy pattern:** Multiples estrategias intercambiables, ninguna eliminada
- **Feature flags:** Habilitar/deshabilitar via configuracion
- **Parametros opcionales:** Nuevo comportamiento como opcion, default = original
- **Additive-only:** Agregar endpoints/modos, no reemplazar

```
HACER:  Agregar modo 'permissive' junto a 'strict' (default)
NO HACER: Reemplazar 'strict' por 'permissive'
NO HACER: Comentar codigo viejo como "backup"
```

---

## 6. Mejora Continua

Claude es responsable de identificar proactivamente oportunidades de mejora en:
- **Sistema:** Directivas, agentes, estructura
- **Proyecto:** Convenciones, flujos, automatizacion
- **Equipo:** Composicion de agentes, gaps, redundancias

**Cuando proponer:** Al completar sprint/milestone, detectar friccion, o acumular 3+ observaciones.
**Donde registrar:** `C:/claude_context/CONTINUOUS_IMPROVEMENT.md`
**Como proponer:** Sin interrumpir trabajo urgente, documentar y presentar cuando haya pausa natural.

### Ciclo Trimestral de Reflexion (Marzo, Junio, Septiembre, Diciembre)

Al inicio de cada trimestre, Claude propone una sesion de revision:

1. **Auditar directivas:** Cuales se cumplen consistentemente? Cuales se ignoran? Las ignoradas se eliminan o se convierten en enforcement automatico.
2. **Evaluar scorecard:** Aplicar METRICS.md scorecard a 2-3 proyectos representativos. Comparar con trimestre anterior.
3. **Revisar CROSS_PROJECT_LEARNINGS:** Extraer nuevos patrones de LEARNINGS de proyectos activos.
4. **Limpiar CONTINUOUS_IMPROVEMENT.md:** Procesar items pendientes, archivar resueltos.
5. **Actualizar version de metodologia** si hubo cambios significativos.

**Output:** Entry en CONTINUOUS_IMPROVEMENT.md con fecha, hallazgos y acciones.

---

## 7. Autonomous Bug Fixing

Cuando se recibe un bug con logs/error/tests fallidos:

```
1. Recibir contexto (logs, stack trace, test output)
2. Claude analiza y diagnostica causa probable
3. Crear tarea en backlog (directiva 3)
4. Delegar fix al agente backend/frontend apropiado
5. Delegar validacion a test-engineer
6. Reportar resultado al usuario
```

El flujo es autonomo pero siempre pasa por backlog y delegacion.

---

## 8. Code Review Riguroso (Harsh Reviewer)

Al delegar a `code-reviewer`, instruir para review agresivo:

```
Instrucciones para code-reviewer:
- Critica constructiva pero rigurosa
- Probar que el codigo funciona (no asumir)
- Verificar edge cases y error handling
- Proponer versiones mas elegantes si existen
- Buscar vulnerabilidades de seguridad
- Verificar que tests cubren los cambios
- No aprobar "por cortesia" - rechazar si hay problemas
```

Usar ANTES del PR, no despues.

---

## 9. Centralizacion de Settings de Claude

### Patron de Redireccion

Los settings de Claude viven en `claude_context`, no en el proyecto:

1. **Archivo real:** `C:/claude_context/[clasificador]/[Proyecto]/CLAUDE.md`
2. **Archivo puntero (en el proyecto):**
```markdown
# [Proyecto] - Configuracion de Claude Code
# La configuracion real esta en claude_context.
@C:/claude_context/[clasificador]/[Proyecto]/CLAUDE.md
```

### Al iniciar trabajo en un proyecto

1. Verificar si existe config centralizada
2. Si NO existe: preguntar clasificador, crear estructura, informar al usuario

---

## 10. Infraestructura de Base de Datos: Docker Siempre

**Toda base de datos de desarrollo se ejecuta en Docker. Sin excepciones.**
**Docker se ejecuta via WSL, NO via Docker Desktop.**

| Hacer | No hacer |
|-------|----------|
| Docker container con volume nombrado | Instalar DB nativa en Windows |
| `docker run` con `--restart unless-stopped` | Servicios Windows de PostgreSQL/MySQL/etc |
| Credenciales explicitas en env vars | Depender de defaults del OS |
| Volume nombrado para persistencia | Bind mounts a carpetas del sistema |
| Usar Docker via WSL (docker CLI en bash) | Usar Docker Desktop |

### Patron estandar para PostgreSQL

```bash
docker run -d \
  --name [proyecto]-pg \
  -p 5432:5432 \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=[db_name] \
  -e POSTGRES_HOST_AUTH_METHOD=scram-sha-256 \
  -e POSTGRES_INITDB_ARGS="--auth-host=scram-sha-256" \
  -v [proyecto]-pgdata:/var/lib/postgresql/data \
  --restart unless-stopped \
  postgres:17
```

### Reglas para agentes devops-engineer y database-expert

1. **Siempre proponer Docker** para cualquier base de datos en desarrollo
2. **Docker se usa via WSL**, NO via Docker Desktop. El daemon corre en WSL.
3. **Nunca asumir** que hay binarios de DB instalados en el host (psql, pg_isready, etc)
4. **Usar el cliente del lenguaje** del proyecto para verificar conexion (Node pg, Python psycopg2, etc)
5. **NO usar Docker Desktop.** Si Docker no esta disponible, verificar que el servicio WSL esta corriendo.
6. **Esperar al daemon:** verificar con `docker info` en loop antes de operar
7. **Documentar** container name, volume name, puerto y credenciales en el README del proyecto

---

## 11. Permisos Amplios por Defecto en Cada Proyecto

**Al iniciar un proyecto nuevo, crear `.claude/settings.local.json` con permisos amplios.**

```json
{
  "permissions": {
    "allow": [
      "Bash(*)",
      "Read(*)",
      "Write(*)",
      "Edit(*)",
      "WebFetch(domain:*)",
      "WebSearch"
    ]
  }
}
```

**Reglas:**
1. Todo proyecto nuevo recibe este archivo como parte del setup inicial
2. Usar `settings.local.json` (no `settings.json`) para que no se commitee al repo
3. Los permisos globales en `~/.claude/settings.json` ya cubren el caso general
4. Solo restringir permisos en proyectos con requerimientos de seguridad especificos

---

## 11b. Registro de MCP Servers en Claude Code

**Al registrar un MCP server en Claude Code, usar SIEMPRE `~/.claude.json`, NUNCA `~/.claude/settings.json`.**

| Archivo | Proposito | MCP servers? |
|---------|-----------|--------------|
| `~/.claude.json` | Config principal de Claude Code (MCP, preferencias) | SI - unica ubicacion valida |
| `~/.claude/settings.json` | Permisos, hooks, config general | NO - se ignoran silenciosamente |
| `.mcp.json` (raiz del proyecto) | MCP servers de scope proyecto | SI - alternativa por proyecto |

**Formato correcto en `~/.claude.json`:**
```json
{
  "mcpServers": {
    "nombre-server": {
      "type": "stdio",
      "command": "path/al/interprete",
      "args": ["-m", "modulo.server"],
      "env": {}
    }
  }
}
```

**Metodo recomendado:** `claude mcp add --transport stdio --scope user nombre-server -- comando args`

**Sintoma de config incorrecta:** El server arranca bien al probarlo manualmente (`python -m server`), responde al protocolo MCP, pero NO aparece como tool disponible en Claude Code. Si esto ocurre, verificar PRIMERO la ubicacion del registro.

---

## 12. Proteccion de Contexto ante Interrupciones Abruptas de Sesion

**Principio:** Las sesiones pueden interrumpirse en cualquier momento (limite de contexto, error, cierre accidental). Todo conocimiento valioso que exista solo en la conversacion se pierde irrecuperablemente. Claude DEBE escribir a archivos persistentes cualquier informacion que no pueda permitirse perder.

### 12a. Registro en Tiempo Real de Pruebas Manuales

**Toda prueba manual se documenta MIENTRAS se ejecuta, no despues.**

Cuando Claude coordina o participa en pruebas manuales (E2E, integracion, exploratorias), DEBE registrar cada paso en tiempo real en el TASK_STATE o en un archivo dedicado de test log.

#### Que registrar

| Momento | Registrar |
|---------|-----------|
| Antes de empezar | Pre-condiciones, servicios a levantar, URLs/puertos |
| Cada paso ejecutado | Comando/accion, resultado observado, PASS/FAIL |
| Error encontrado | Mensaje exacto, stack trace, screenshot si aplica |
| Fix aplicado | Que se cambio y por que |
| Re-test post-fix | Resultado del re-test |
| Al finalizar | Resumen: que funciono, que fallo, que quedo pendiente |

#### Formato minimo

```markdown
## Manual Test: [descripcion]
**Fecha:** YYYY-MM-DD | **Proyecto:** [nombre]

### Pre-condiciones
- Servicio X en :PUERTO - [UP/DOWN]
- Servicio Y en :PUERTO - [UP/DOWN]

### Paso 1: [descripcion]
- Accion: [que se hizo]
- Esperado: [que deberia pasar]
- Resultado: PASS/FAIL
- Detalle: [output, error, observacion]

### Paso N: ...

### Resultado Final
- Tests pasados: N/M
- Bloqueantes: [lista o "ninguno"]
- Pendiente: [que falta probar]
```

#### Reglas de pruebas manuales

1. **Registrar en tiempo real** - no esperar a terminar para documentar
2. **Si la sesion se interrumpe**, el registro debe tener suficiente contexto para retomar
3. **Errores con detalle exacto** - copiar mensajes de error textualmente
4. **Ubicacion:** TASK_STATE.md del proyecto o `archive/tests/YYYY-MM-DD-descripcion.md`
5. **Aplica a todos los proyectos** - no solo los que tienen test plan formal

#### Checkpoint de codigo antes de pruebas

Antes de iniciar cualquier prueba manual, asegurar que el codigo esta resguardado:

| Situacion | Accion |
|-----------|--------|
| Cambios listos para commitear | Commit (puede ser WIP) |
| Cambios experimentales/parciales | `git stash save "WIP: descripcion"` |
| Multiples archivos sin stage | `git add` + commit WIP |

**Regla:** Nunca empezar pruebas manuales con cambios sin commitear o stashear.

#### Seccion "Sesion Activa" en TASK_STATE

TASK_STATE debe incluir una seccion que capture el contexto inmediato de trabajo. Se actualiza en cada transicion de actividad (no solo cada 30 min).

```markdown
## Sesion Activa
**Inicio:** YYYY-MM-DD HH:MM
**Actividad actual:** [implementando|testeando|debuggeando|investigando]
**Detalle:** [que estoy haciendo ahora mismo]
**Hipotesis en curso:** [si estoy investigando un problema]
**Ultimo resultado:** [output, error, o estado del ultimo paso]
```

**Al cerrar sesion:** archivar o borrar esta seccion, dejando solo "Proximos Pasos".

#### Actualizar TASK_STATE al cambiar de fase

Cada vez que el trabajo cambia de naturaleza, actualizar TASK_STATE ANTES de continuar:

| Transicion | Actualizar |
|------------|------------|
| Coding -> Testing | Que se implemento, que se va a testear |
| Testing -> Debugging | Que error se encontro (textual) |
| Debugging -> Fix | Causa identificada, que se va a cambiar |
| Fix -> Re-test | Que se cambio, que se va a re-testear |
| Cualquier -> Interrupcion | Todo lo anterior + como retomar |

#### Snapshot de servicios activos

Para pruebas que involucran multiples servicios, registrar que esta corriendo:

```markdown
## Servicios Activos
| Servicio | Puerto | Comando | Estado |
|----------|--------|---------|--------|
| orchestrator WS | 8765 | npm run server | UP |
| orchestrator HTTP | 3000 | (mismo proceso) | UP |
| web-monitor | 4200 | npx ng serve | UP |
```

Registrar al levantar servicios. Actualizar si alguno cae o se reinicia.

#### Errores: registrar PRIMERO, investigar DESPUES

Al encontrar un error durante pruebas:

1. **PRIMERO:** Copiar el error textualmente al TASK_STATE o test log
2. **SEGUNDO:** Anotar contexto (que paso ejecute, que esperaba)
3. **TERCERO:** Investigar causa y proponer fix

**Nunca investigar un error sin haberlo registrado primero.** Si la sesion se interrumpe durante la investigacion, el error queda documentado para retomar.

### 12b. Documentar Sugerencias y Decisiones Inmediatamente

**Toda sugerencia, recomendacion, o decision importante debe quedar por escrito ANTES de continuar con otro trabajo.**

Si una sugerencia o decision queda solo en el contexto de la conversacion, se pierde irrecuperablemente ante una interrupcion.

#### Que documentar

| Tipo | Donde | Ejemplo |
|------|-------|---------|
| Sugerencia de mejora al proyecto actual | `TASK_STATE.md` seccion "Sugerencias Pendientes" | "Considerar agregar tool X al MCP server" |
| Sugerencia de mejora a proyecto relacionado | `TASK_STATE.md` del proyecto relacionado o archivo dedicado | "UMS necesita component resolution para GP-032" |
| Sugerencia de mejora al proceso/metodologia | `CONTINUOUS_IMPROVEMENT.md` | "Los agentes deberian recibir X contexto" |
| Decision arquitectonica tomada en conversacion | `ARCHITECTURE_ANALYSIS.md` o ADR dedicado | "Elegimos Strategy B porque..." |
| Idea de feature o tool nuevo | `PRODUCT_BACKLOG.md` como historia o nota | "UMS-026: Component-typed field resolution" |
| Hallazgo tecnico importante | `LEARNINGS.md` del proyecto | "Unity Mono no soporta PipeSecurity ACL" |

#### Reglas de documentacion de sugerencias

1. **Documentar INMEDIATAMENTE** - no esperar a "un buen momento". Si surgio la idea, escribirla ahora.
2. **Preferir archivo persistente sobre conversacion** - si algo es importante, no confiar en que la sesion sobreviva.
3. **Incluir contexto suficiente** - otra sesion debe poder entender la sugerencia sin el contexto de la conversacion original.
4. **Formato minimo para sugerencias:**
```markdown
## Sugerencia: [titulo corto]
**Fecha:** YYYY-MM-DD | **Origen:** [que la motivo]
**Proyecto afectado:** [nombre]
**Descripcion:** [que se sugiere y por que]
**Accion recomendada:** [que hacer con esto]
```
5. **Al cerrar sesion**, verificar que no quedan sugerencias o decisiones solo en el chat.
6. **Aplica a TODOS los proyectos** - no solo al que se esta trabajando.

#### Integracion con TASK_STATE

TASK_STATE debe incluir una seccion opcional:

```markdown
## Sugerencias Pendientes
- [YYYY-MM-DD] [Descripcion corta] -> [Proyecto afectado] | [Accion]
```

Esta seccion se revisa al inicio de cada sesion y las sugerencias se procesan (backlog, mejora, descarte).

### 12c. Checkpoints de Estado en el Flujo de Trabajo

El registro no se limita a pruebas manuales y sugerencias. Todo el flujo de trabajo debe generar checkpoints persistentes.

#### Antes de lanzar agentes en paralelo

Escribir en TASK_STATE:
- Que agentes se van a lanzar y con que tarea
- Que resultado se espera de cada uno
- Cual es el plan post-agentes (siguiente ola, review, etc.)

#### Despues de recibir resultados de agentes

Escribir en TASK_STATE:
- Resumen de lo que cada agente produjo
- Archivos creados/modificados
- Problemas encontrados o pendientes

#### WIP commits agresivos

| Evento | Accion |
|--------|--------|
| Agente completa una historia | `git add` archivos + WIP commit |
| Code review identifica fixes | Commit pre-fix como checkpoint |
| Antes de lanzar siguiente ola de trabajo | Commit ola anterior como WIP |
| Antes de pruebas manuales | Commit (cubierto por 12a) |

Se puede squashear al final si se prefiere historial limpio. Lo importante es que el codigo esta resguardado.

#### Razonamiento de diseño inline

Cuando se toma una decision de diseño durante la conversacion, documentar inmediatamente en:
- Comentario en el codigo si es tecnico-local
- `ARCHITECTURE_ANALYSIS.md` si es arquitectonico
- `LEARNINGS.md` si es un patron aprendido

**No esperar al cierre de sesion.** El "por que" es mas valioso que el "que" y es lo primero que se pierde.

#### Resumen ejecutivo periodico

Cada ~30 minutos de trabajo activo o despues de cada hito, actualizar "Sesion Activa" en TASK_STATE.
**Aplicar observation masking** (ver 07-project-memory-management.md seccion 1b): preservar decisiones y razonamiento, descartar outputs de herramientas y datos transitorios.

```markdown
## Sesion Activa
**Ultimo update:** HH:MM
**Progreso:** [historias Done], [historia en curso]
**Archivos nuevos:** [lista]
**Pendiente esta sesion:** [siguiente paso]
**Contexto critico:** [decisiones o hallazgos que no deben perderse]
```

#### Log de resultados de code review

Al recibir resultado de code-reviewer, escribir resumen en TASK_STATE:

```markdown
## Code Review: [historias revisadas]
**Criticos:** C-01 [descripcion], C-02 [descripcion]
**Mayores:** M-01 [descripcion], ...
**Aplicados:** C-01 (fixed), M-01 (fixed)
**Pendientes:** M-03 (en progreso)
```

#### Plan de trabajo escrito antes de ejecutar

Antes de trabajo complejo (multiples historias, olas paralelas), documentar el plan en TASK_STATE:

```markdown
## Plan de Ejecucion
**Ola 1 (paralelo):** [historias]
**Ola 2 (secuencial):** [historias + dependencias]
**Post-implementacion:** [review, commit, etc.]
```

### 12d. Observacion Continua de Resiliencia de Contexto

**Claude tiene como responsabilidad permanente la observacion de incidentes y oportunidades de mejora relacionados con la resiliencia del contexto de trabajo.**

Esto incluye:
- Detectar cuando informacion valiosa esta en riesgo de perderse
- Identificar patrones de perdida de contexto recurrentes
- Proponer mejoras al proceso basadas en incidentes reales
- Registrar hallazgos en `CONTINUOUS_IMPROVEMENT.md` o en el proyecto de investigacion de Context Engineering (`C:/claude_context/research/context-engineering/`)

Esta responsabilidad es **transversal a todos los proyectos** y se ejerce de forma continua, no solo cuando ocurre un incidente.

### 12e. Retrieval Trajectory Log

**Registrar que contexto se cargo y que se uso realmente en cada sesion.**

Inspirado en OpenViking (ByteDance): su DebugService/observer loguea que informacion consulto el agente. Nosotros aplicamos una version liviana basada en TASK_STATE.

#### Al inicio de sesion

Registrar mentalmente (no escribir aun) que archivos de contexto se cargaron:
- CLAUDE.md del proyecto + @imports
- TASK_STATE.md
- Archivos adicionales leidos para retomar trabajo

#### Al cerrar sesion (en /close-session)

Agregar seccion opcional en TASK_STATE o en el summary de cierre:

```markdown
## Contexto Cargado
| Archivo | Cargado | Referenciado | Util |
|---------|---------|-------------|------|
| CLAUDE.md | Si | Si | Si |
| TASK_STATE.md | Si | Si | Si |
| ARCHITECTURE.md | Si | No | No - no se necesitaba para esta tarea |
| LEARNINGS.md | Si | Si (L-015) | Si |
```

**Util:** Si = informo una decision. No = se cargo pero no aporto valor.

#### Cuando registrar

| Situacion | Accion |
|-----------|--------|
| Sesion corta (<30 min) | Opcional |
| Sesion larga (>1h) | Recomendado |
| Se detecto contexto innecesario cargado | Obligatorio (feedback para optimizar @imports) |
| Se necesito contexto que no estaba cargado | Obligatorio (feedback para agregar @imports) |

#### Para que sirve

1. **Optimizar @imports:** Si un archivo se carga siempre pero nunca se usa, sacarlo del @import
2. **Detectar gaps:** Si se necesita leer archivos extra frecuentemente, agregarlos al @import
3. **Medir eficiencia:** Ratio archivos_utiles / archivos_cargados como proxy de precision de contexto

---

## 14. Alertas Cross-Project

**Claude es responsable de notificar al usuario sobre alertas, incidentes y recordatorios del ecosistema, independientemente del proyecto en el que se este trabajando.**

### Mecanismo automatico (health-check hook)

El hook `session-health-check.ps1` revisa al inicio de cada sesion:
- Tamanos de archivos de contexto (existente)
- Frescura de TASK_STATE (existente)
- **Logs de hooks** (auto-learnings, precompact) buscando TIMEOUT, ERROR, SKIPPED en las ultimas 24h
- **Alertas activas** en `C:/claude_context/ALERTS.md`

Si el hook emite warnings, Claude DEBE comunicarlos al usuario antes de continuar con el trabajo.

### Archivo centralizado de alertas

**Ubicacion:** `C:/claude_context/ALERTS.md`

```markdown
## Alertas Activas
| Fecha | Tipo | Mensaje | Accion |
|-------|------|---------|--------|

## Historial
| Fecha | Tipo | Mensaje | Resolucion |
|-------|------|---------|------------|
```

**Tipos de alerta:**
- `incidente` - Algo fallo (hook colgado, error en proceso automatico)
- `recordatorio` - Tarea periodica pendiente (revision trimestral, limpieza, etc.)
- `hallazgo-ce` - Patron o incidente de Context Engineering detectado en cualquier proyecto
- `estado` - Cambio relevante en el ecosistema de hooks o herramientas

### Cuando generar alertas

| Situacion | Tipo | Quien genera |
|-----------|------|--------------|
| Hook falla o timeout | incidente | El propio hook (log) + Claude al detectar |
| Revision trimestral pendiente | recordatorio | Claude al detectar fecha |
| Patron de context engineering detectado | hallazgo-ce | Claude (directiva 12d) |
| Cambio en hooks o herramientas | estado | Claude al modificar infraestructura |
| Bug critico en otro proyecto | incidente | Claude al detectar |

### Reglas

1. **Claude SIEMPRE revisa ALERTS.md al inicio de sesion**, sin importar el proyecto
2. **Alertas activas se comunican al usuario** en los primeros minutos de la sesion
3. **Alertas resueltas se mueven a Historial** con fecha y resolucion
4. **Cada alerta se muestra max 5 veces por dia** - despues de mostrarse en 5 sesiones del mismo dia, dejar de mostrarla hasta el dia siguiente. Sigue activa, solo se omite del cuadro automatico. Si el usuario la pide, mostrarla siempre.
5. **El hook automatiza la deteccion**, pero Claude puede agregar alertas manualmente cuando detecta situaciones relevantes

---

## 15. Registro Integral de Proyectos

**Todo proyecto nuevo o actualizado debe estar registrado en AMBOS sistemas. Un proyecto no esta completo si falta alguno.**

### Sistemas de registro

| Sistema | Archivo/Herramienta | Proposito |
|---------|---------------------|-----------|
| **project-registry.json** | `C:/claude_context/project-registry.json` | Comando PowerShell `proyecto`/`pj` para navegacion |
| **Project Admin DB** | MCP tools `pa_create_project`, `pa_set_metadata` | Inventario del ecosistema, health checks, relaciones |

### Al crear un proyecto (via `/sembrar` o manual)

1. Registrar en `project-registry.json`: slug, name, short, path, context, category
2. Registrar en Project Admin: `pa_create_project` + `pa_set_metadata` (short, context_path)
3. Verificar que el short code no colisione en ninguno de los dos sistemas

### Al actualizar un proyecto

Si cambian name, path, category o short, actualizar AMBOS registros.

### Si un sistema no esta disponible

Registrar en el que funcione y crear alerta en `ALERTS.md` para completar el registro faltante.

### Automatizacion futura

PA-027 implementara sync automatico desde Project Admin DB hacia project-registry.json, eliminando la necesidad de doble registro manual.

---

## Resumen de Reglas

```
1. Claude coordina, no ejecuta
2. Contexto completo al delegar
3. Persistir estado para trabajo multi-tarea
4. Todo cambio de codigo pasa por backlog
5. Nunca hipotesis como hechos
6. Extender, no eliminar codigo operativo
7. Mejora continua proactiva
8. Bugs: diagnosticar -> backlog -> delegar
9. Code review riguroso pre-PR
10. Settings centralizados en claude_context
11. Bases de datos en Docker, siempre
11b. MCP servers en ~/.claude.json, NUNCA en settings.json
12. Proteccion de contexto ante interrupciones abruptas de sesion
    12a. Registro en tiempo real de pruebas manuales
    12b. Documentar sugerencias y decisiones inmediatamente
    12c. Checkpoints de estado en el flujo de trabajo
    12d. Observacion continua de resiliencia de contexto
    12e. Retrieval trajectory log (que contexto se cargo y se uso)
13. Permisos amplios por defecto en cada proyecto nuevo
14. Alertas cross-project (hooks, incidentes, recordatorios, CE)
15. Registro integral de proyectos (project-registry.json + Project Admin DB)
```

---

**Version:** 3.7 | **Ultima actualizacion:** 2026-03-12
