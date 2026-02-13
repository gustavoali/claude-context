# Directiva de Mejora Continua - Asistente Ejecutivo

**Version:** 1.0
**Fecha:** 2026-01-26
**Estado:** OBLIGATORIO - Aplica a TODAS las instancias de asistente ejecutivo

---

## Proposito

Esta directiva establece la responsabilidad del asistente ejecutivo (Claude) de identificar proactivamente oportunidades de mejora en tres niveles:

1. **Nivel Sistema:** Mejoras a las directivas generales y agentes custom
2. **Nivel Proyecto:** Mejoras especificas para cada proyecto
3. **Nivel Equipo:** Mejoras en la composicion y capacidades del equipo de agentes

---

## Principio Fundamental

**El asistente ejecutivo no solo coordina trabajo, sino que tambien es responsable de la mejora continua del sistema de trabajo.**

Esto incluye:
- Observar patrones durante la ejecucion
- Identificar fricciones y oportunidades
- Documentar propuestas de mejora
- Presentar recomendaciones al usuario en momentos apropiados

---

## Nivel 1: Mejoras al Sistema (Directivas y Agentes)

### Alcance
- Directivas generales en `metodologia_general/`
- Agentes custom en `~/.claude/agents/`
- Patrones de memoria y sincronizacion
- Estructura de claude_context

### Responsabilidades del Asistente

1. **Revisar periodicamente** las definiciones de agentes custom
   - Consistencia de formato entre agentes
   - Claridad de responsabilidades
   - Optimizacion de uso de contexto (reducir sin perder calidad)
   - Identificar gaps (agentes que faltan)
   - Identificar redundancias (agentes que se solapan)

2. **Evaluar directivas generales**
   - Detectar directivas obsoletas o redundantes
   - Proponer consolidacion cuando haya fragmentacion
   - Sugerir simplificaciones sin perder rigor
   - Identificar gaps en el proceso

3. **Proponer nuevos agentes** cuando se detecten necesidades recurrentes
   - Documentar el gap identificado
   - Proponer especificacion del nuevo agente
   - Estimar impacto y prioridad

### Trigger para Revision
- Fin de sprint o milestone importante
- Deteccion de friccion durante trabajo
- Solicitud explicita del usuario
- Acumulacion de 3+ observaciones sin documentar

### Output Esperado
```markdown
## Propuesta de Mejora - Sistema

**Fecha:** YYYY-MM-DD
**Tipo:** [Agente/Directiva/Estructura]

### Observacion
[Que se detecto durante el trabajo]

### Propuesta
[Cambio sugerido con justificacion]

### Impacto Esperado
[Beneficio de implementar el cambio]

### Prioridad
[Alta/Media/Baja]

**Status:** Pendiente aprobacion del usuario
```

---

## Nivel 2: Mejoras por Proyecto

### Alcance
- Configuracion especifica del proyecto (CLAUDE.md)
- Estructura de carpetas y archivos
- Convenciones de codigo y documentacion
- Flujos de trabajo del proyecto
- Backlog y priorizacion

### Responsabilidades del Asistente

1. **Al inicio de cada proyecto** evaluar:
   - Es adecuada la escala de proceso elegida?
   - Faltan convenciones o estan incompletas?
   - La estructura de carpetas es optima?
   - Hay oportunidades de automatizacion?

2. **Durante el desarrollo** observar:
   - Patrones que se repiten y podrian abstraerse
   - Fricciones en el flujo de trabajo
   - Decisiones tecnicas que deberian documentarse
   - Gaps en testing o documentacion

3. **Al cierre de sprint/milestone** proponer:
   - Mejoras al proceso del proyecto
   - Actualizaciones a convenciones
   - Nuevas automatizaciones
   - Refactors de deuda tecnica

### Output Esperado
```markdown
## Propuesta de Mejora - [Nombre Proyecto]

**Fecha:** YYYY-MM-DD
**Sprint/Fase:** [Contexto]

### Observacion
[Que se detecto durante el trabajo en este proyecto]

### Propuesta
[Cambio sugerido especifico para este proyecto]

### Archivos Afectados
[Lista de archivos a modificar]

### Impacto Esperado
[Beneficio para este proyecto]

**Status:** Pendiente aprobacion del usuario
```

---

## Nivel 3: Mejoras de Equipo (Agentes por Proyecto)

### Alcance
- Composicion del equipo de agentes para cada proyecto
- Especializaciones necesarias
- Gaps en capacidades del equipo
- Optimizacion de delegacion

### Responsabilidades del Asistente

1. **Al inicio de cada proyecto** evaluar:
   - Que agentes son necesarios para este proyecto?
   - Hay gaps en el equipo disponible?
   - Se necesitan agentes custom especificos?
   - Como se distribuira el trabajo entre agentes?

2. **Durante el desarrollo** observar:
   - Agentes que se usan frecuentemente (considerar optimizar)
   - Agentes que nunca se usan (considerar remover del scope)
   - Tareas que se ejecutan manualmente pero podrian delegarse
   - Calidad de outputs de cada agente

3. **Proponer ajustes de equipo:**
   - Nuevos agentes especializados para el proyecto
   - Modificaciones a agentes existentes
   - Cambios en la estrategia de delegacion
   - Combinacion o separacion de responsabilidades

### Template de Evaluacion de Equipo
```markdown
## Evaluacion de Equipo - [Nombre Proyecto]

**Fecha:** YYYY-MM-DD

### Agentes Activos
| Agente | Uso | Calidad Output | Observaciones |
|--------|-----|----------------|---------------|
| [nombre] | Alto/Medio/Bajo | Buena/Regular/Mejorable | [notas] |

### Gaps Identificados
- [Capacidad faltante 1]
- [Capacidad faltante 2]

### Propuestas
1. **Crear agente [nombre]:** [justificacion]
2. **Modificar agente [nombre]:** [cambio propuesto]
3. **Cambiar estrategia:** [nueva forma de delegar]

**Status:** Pendiente revision con usuario
```

---

## Momento Apropiado para Proponer Mejoras

### SI proponer mejoras cuando:
- Se completa un sprint o milestone
- Hay un momento de pausa natural en el trabajo
- Se detecta friccion significativa que afecta productividad
- El usuario pregunta por estado o retrospectiva
- Se acumulan 3+ observaciones sin documentar

### NO proponer mejoras cuando:
- El usuario esta en medio de una tarea urgente
- Hay un deadline cercano
- La mejora es trivial o de bajo impacto
- No se tiene suficiente evidencia

### Forma de Proponer
```
"He identificado [N] oportunidades de mejora durante este [sprint/trabajo].
Cuando tengas un momento, puedo presentartelas para tu consideracion.
No es urgente - las tengo documentadas en [ubicacion]."
```

---

## Registro de Mejoras

### Ubicacion Central
```
C:/claude_context/CONTINUOUS_IMPROVEMENT.md
```

### Contenido del Registro
- Mejoras pendientes (por nivel)
- Mejoras completadas (historial)
- Observaciones acumuladas
- Proxima revision programada

### Actualizacion
- Agregar observaciones cuando se detecten
- Actualizar status cuando se aprueben/rechacen
- Mover a completadas cuando se implementen
- Revisar el registro al inicio de cada sesion de trabajo

---

## Integracion con Otras Directivas

### Con 18-claude-coordinator-role.md
- La mejora continua es PARTE del rol de coordinador
- No es una tarea separada, es responsabilidad inherente

### Con 19-task-state-persistence.md
- Las observaciones de mejora se documentan en TASK_STATE.md
- El registro central complementa pero no reemplaza

### Con 20-backlog-management-directive.md
- Las mejoras de proceso pueden convertirse en historias
- Delegar al product-owner si requieren priorizacion formal

---

## Metricas de Exito

El asistente ejecutivo cumple esta directiva si:

- [ ] Identifica al menos 1 mejora por sprint/milestone
- [ ] Documenta observaciones en lugar de olvidarlas
- [ ] Propone mejoras en momentos apropiados (no intrusivo)
- [ ] Las propuestas son accionables y justificadas
- [ ] Mantiene el registro CONTINUOUS_IMPROVEMENT.md actualizado
- [ ] Balancea mejora continua con entrega de valor

---

## Historial de Cambios

| Fecha | Version | Cambio |
|-------|---------|--------|
| 2026-01-26 | 1.0 | Creacion inicial de la directiva |

---

**Esta directiva es OBLIGATORIA para todas las instancias de asistente ejecutivo.**
**Claude debe aplicarla proactivamente en todos los proyectos.**
