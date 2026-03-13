# Registro de Incidentes del Ecosistema

**Creado:** 2026-03-08
**Proposito:** Registro centralizado de incidentes para evaluar salud del ecosistema y medir mejoras.

---

## Como Registrar un Incidente

Cualquier agente/sesion que detecte un incidente del ecosistema debe agregar una entrada aqui.

**Formato:**
```markdown
### INC-NNN: [Titulo corto]
- **Fecha:** YYYY-MM-DD HH:MM
- **Proyecto:** [donde se detecto]
- **Componente:** [DB | Servicio | Networking | Hook | Docker | Otro]
- **Severidad:** [critico | alto | medio | bajo]
- **Sintoma:** [que se observo]
- **Causa raiz:** [si se identifico]
- **Resolucion:** [que se hizo para resolver]
- **Tiempo deteccion:** [manual | automatico] - [minutos hasta detectar]
- **Tiempo resolucion:** [minutos hasta resolver]
- **Recurrente:** [si/no] - [INC-NNN relacionados]
```

---

## Incidentes Activos

(ninguno)

---

## Historial de Incidentes

### INC-007: WSL2 auto-suspend causa crash loops en todos los Docker containers
- **Fecha:** 2026-03-09 (recurrente, en curso desde semanas)
- **Proyecto:** ecosistema completo (todos los containers Docker)
- **Componente:** Docker
- **Severidad:** critico
- **Sintoma:** Todos los containers muestran "Up X seconds" simultaneamente. PostgreSQL logs: 150+ "not properly shut down" en project-admin-pg, 152 en sprint-backlog-pg. Ciclo exacto de ~70 segundos entre kills. 55 restarts el 9 de marzo.
- **Causa raiz:** WSL2 se auto-suspende cuando la maquina esta idle. Tres mecanismos contribuyen: (1) vmIdleTimeout default 60s apaga la VM, (2) instanceIdleTimeout apaga instancias WSL individuales, (3) autoMemoryReclaim=gradual reclama paginas de memoria de servicios activos causando crashes silenciosos.
- **Resolucion:** Configuracion triple en `C:/Users/gdali/.wslconfig`: `vmIdleTimeout=-1` + `autoMemoryReclaim=disabled` + `instanceIdleTimeout=-1` (bajo seccion [general]). Containers PG recreados con Docker healthcheck (`pg_isready`). Verificado: containers sobreviven 5+ min sin restart (antes no pasaban 70s).
- **Tiempo deteccion:** manual - detectado al investigar logs de PG
- **Tiempo resolucion:** ~25 min
- **Recurrente:** si - relacionado con INC-001 (mismo root cause: WSL suspend). Este fix deberia resolver ambos.

### INC-001: WSL2 port forwarding silenciosamente deja de funcionar
- **Fecha:** 2026-03-08 (recurrente, multiples ocurrencias previas)
- **Proyecto:** claude-orchestrator (detectado), afecta todo el ecosistema
- **Componente:** Networking
- **Severidad:** alto
- **Sintoma:** Docker container running, port mapping configurado, pero conexion desde Windows rechazada (ECONNREFUSED). `netstat` no muestra el puerto en LISTENING.
- **Causa raiz:** Bug conocido de WSL2 mirrored networking mode. El port forwarding TCP puede romperse silenciosamente y no se recupera solo.
- **Resolucion:** `wsl --shutdown` + reiniciar containers + re-levantar servicios
- **Tiempo deteccion:** manual - variable (a veces minutos, a veces descubierto al intentar usar el servicio)
- **Tiempo resolucion:** ~2 min (shutdown + restart)
- **Recurrente:** si - incidente mas frecuente del ecosistema

### INC-002: Hook auto-learnings colgado 13 horas
- **Fecha:** 2026-03-04
- **Proyecto:** ecosystem (hooks globales)
- **Componente:** Hook
- **Severidad:** critico
- **Sintoma:** Hook `auto-learnings.ps1` se ejecuto y nunca termino, consumiendo recursos por 13 horas.
- **Causa raiz:** Timeout en settings.json configurado como `120000` pensando que era milisegundos, pero la unidad es **segundos**. 120000 seg = 33.3 horas.
- **Resolucion:** Corregido: timeout a `120` (segundos). Scripts reescritos con Start-Job + Wait-Job + cleanup de procesos.
- **Tiempo deteccion:** manual - horas (descubierto al notar proceso zombie)
- **Tiempo resolucion:** ~1h (diagnostico + fix)
- **Recurrente:** no (post-fix)

### INC-003: Puerto 5434 conflicto con wslrelay
- **Fecha:** 2026-02 (fecha exacta no registrada)
- **Proyecto:** project-admin
- **Componente:** Networking
- **Severidad:** medio
- **Sintoma:** Puerto PostgreSQL original (5433) no funcionaba por conflicto con wslrelay.
- **Causa raiz:** wslrelay ocupaba el puerto. Conflicto de puertos entre servicios WSL.
- **Resolucion:** Cambio de puerto a 5434. Documentado en MEMORY.md de project-admin.
- **Tiempo deteccion:** manual
- **Tiempo resolucion:** ~30 min
- **Recurrente:** no (cambio de puerto permanente)

### INC-004: AggregateError message vacio en Node.js 20+
- **Fecha:** 2026-02 (fecha exacta no registrada)
- **Proyecto:** project-admin
- **Componente:** Servicio
- **Severidad:** medio
- **Sintoma:** Errores de conexion a DB mostraban mensaje vacio, dificultando diagnostico.
- **Causa raiz:** Node.js 20+ genera AggregateError cuyo `.message` puede ser vacio. Hay que usar `.errors[0]?.code`.
- **Resolucion:** Ajustado error handling para leer `.errors[0]?.code`.
- **Tiempo deteccion:** manual
- **Tiempo resolucion:** ~15 min
- **Recurrente:** no (post-fix)

### INC-005: CLAUDECODE env var heredada en child processes
- **Fecha:** 2026-03 (fecha exacta no registrada)
- **Proyecto:** claude-orchestrator
- **Componente:** Servicio
- **Severidad:** alto
- **Sintoma:** Sesiones CLI del orchestrator fallaban o se comportaban erroneamente porque el child process de Claude CLI heredaba la variable CLAUDECODE del parent.
- **Causa raiz:** Al iniciar orchestrator desde dentro de Claude Code, `process.env.CLAUDECODE` se hereda a los child processes que spawnean sesiones.
- **Resolucion:** Implementado `buildCleanEnv()` en `utils/clean-env.js` que remueve CLAUDECODE antes de spawn.
- **Tiempo deteccion:** manual - ~30 min debugging
- **Tiempo resolucion:** ~1h
- **Recurrente:** no (post-fix)

### INC-006: Pool de conexiones cacheaba errores permanentemente
- **Fecha:** 2026-02 (fecha exacta no registrada)
- **Proyecto:** project-admin
- **Componente:** DB
- **Severidad:** alto
- **Sintoma:** Despues de un fallo transitorio de conexion a DB, el servicio nunca se recuperaba. Requeria restart manual.
- **Causa raiz:** El pool de conexiones cacheaba el estado de error y no reintentaba.
- **Resolucion:** Destruir pool en caso de error de conexion, reintentar en proximo call.
- **Tiempo deteccion:** manual
- **Tiempo resolucion:** ~30 min
- **Recurrente:** no (post-fix)

---

## Metricas

### Por Componente
| Componente | Total | Resueltos | Recurrentes |
|------------|-------|-----------|-------------|
| Networking | 2 | 2 | 1 (INC-001) |
| Hook | 1 | 1 | 0 |
| Servicio | 2 | 2 | 0 |
| DB | 1 | 1 | 0 |
| Docker | 1 | 1 | 1 (INC-007, mismo root cause que INC-001) |

### Por Severidad
| Severidad | Total | Recurrentes |
|-----------|-------|-------------|
| Critico | 2 | 1 |
| Alto | 3 | 1 |
| Medio | 2 | 0 |

### Tendencia
| Periodo | Incidentes | Recurrentes | Deteccion automatica |
|---------|-----------|-------------|---------------------|
| Pre-supervisor (hasta 2026-03-08) | 6 | 1 | 0% |
| 2026-03-09 | 1 (INC-007) | 1 | 0% |

---

## ID Registry
Proximo ID: INC-008
