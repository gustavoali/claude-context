# Persistencia de Estado de Tareas - Directiva Obligatoria

**Version:** 1.0
**Fecha:** 2026-01-24
**Estado:** OBLIGATORIO - Aplica a TODOS los proyectos

---

## Proposito

Garantizar que el estado de trabajo se preserve entre sesiones, permitiendo retomar tareas sin perdida de contexto en caso de:
- Salidas de sesion no previstas
- Interrupciones del usuario
- Cambios de contexto entre proyectos
- Sesiones largas con multiples tareas

---

## Directiva Principal

**Claude DEBE mantener un archivo TASK_STATE.md actualizado en `claude_context/[proyecto]/` para cualquier trabajo que involucre multiples tareas o fases.**

---

## Cuando Crear TASK_STATE.md

Crear el archivo cuando:
- Se inicia un trabajo con 3+ tareas relacionadas
- Se usa TaskCreate para trackear trabajo
- El trabajo puede extenderse a multiples sesiones
- Hay riesgo de interrupcion (migraciones, refactors grandes)

---

## Cuando Actualizar TASK_STATE.md

Actualizar el archivo cuando:
- Se completa una tarea
- Se cambia el estado de una tarea (pending -> in_progress -> completed)
- Se toma una decision importante
- Se descubre informacion relevante para continuar
- Se va a delegar trabajo a un agente
- **Minimo:** Al menos una vez cada 30 minutos de trabajo activo

---

## Estructura del Archivo

```markdown
# Estado de Tareas - [Nombre del Proyecto]

**Ultima actualizacion:** YYYY-MM-DD HH:MM
**Sesion activa:** Si/No

---

## Resumen Ejecutivo

**Trabajo en curso:** [Descripcion breve]
**Fase actual:** [Fase o tarea actual]
**Bloqueantes:** [Lista o "Ninguno"]

---

## Tareas Activas

### #[ID] [ESTADO] Titulo de la tarea
- **Estado:** pendiente/en_progreso/completada
- **Descripcion:** [Que hace esta tarea]
- **Archivos afectados:** [Lista de archivos]
- **Resultado:** [Solo si completada]

[Repetir para cada tarea...]

---

## Contexto Tecnico

[Informacion tecnica relevante para continuar el trabajo]
- Estado de sistemas
- Configuraciones
- Dependencias
- Decisiones tomadas

---

## Proximos Pasos

1. [Paso inmediato siguiente]
2. [Paso 2]
3. [...]

---

## Historial de Sesiones

### YYYY-MM-DD (actual/anterior)
- [Resumen de lo realizado]
- [Decisiones tomadas]
- [Problemas encontrados]

---

## Notas para Retomar

[Instrucciones especificas para retomar este trabajo]
- Comandos a ejecutar
- Verificaciones necesarias
- Contexto critico
```

---

## Ubicacion del Archivo

El archivo TASK_STATE.md debe ubicarse en:

```
C:/claude_context/[clasificador]/[proyecto]/TASK_STATE.md
```

Ejemplo:
- `C:/claude_context/linkedin/TASK_STATE.md`
- `C:/claude_context/jerarquicos/APIJsMobile/TASK_STATE.md`

---

## Flujo de Trabajo

### Al Iniciar Sesion

```
1. Verificar si existe TASK_STATE.md para el proyecto
2. Si existe:
   - Leer el archivo
   - Verificar estado de tareas pendientes
   - Continuar desde "Proximos Pasos"
3. Si no existe y hay trabajo multi-tarea:
   - Crear TASK_STATE.md
   - Documentar tareas iniciales
```

### Durante la Sesion

```
1. Actualizar TASK_STATE.md al:
   - Completar una tarea
   - Cambiar estado de tarea
   - Tomar decision importante
   - Antes de delegar a agente

2. Mantener sincronizado con TaskList:
   - TASK_STATE.md es persistencia a disco
   - TaskList es estado en memoria de sesion
```

### Al Finalizar Sesion (si es posible)

```
1. Actualizar TASK_STATE.md con estado final
2. Marcar "Sesion activa: No"
3. Documentar proximos pasos claros
```

---

## Ejemplo Practico

### Escenario: Migracion de Base de Datos

**Inicio de sesion:**
```
Usuario: "Continuemos con la migracion de DB"
Claude: [Lee TASK_STATE.md]
Claude: "Segun el estado guardado, completamos Fase 1 (backup).
         La siguiente tarea es Fase 2 (migrar native-host).
         Procedo?"
```

**Durante trabajo:**
```
[Completa tarea]
Claude: [Actualiza TASK_STATE.md]
        - Marca tarea como completada
        - Actualiza "Fase actual"
        - Documenta resultado
```

**Interrupcion inesperada:**
```
[Sesion se corta]
...
[Nueva sesion]
Usuario: "Retomamos"
Claude: [Lee TASK_STATE.md]
Claude: "La ultima sesion se interrumpio durante Fase 2.
         Estado: host.js parcialmente migrado.
         Archivos modificados: [lista]
         Continuo desde donde quedo?"
```

---

## Integracion con Otras Directivas

### Con 18-claude-coordinator-role.md
- Antes de delegar a agente, actualizar TASK_STATE.md con contexto
- Al recibir resultado de agente, actualizar estado

### Con 17-memory-sync-pattern.md
- TASK_STATE.md es parte de claude_context del proyecto
- Se sincroniza automaticamente con el patron de memoria

### Con TaskCreate/TaskUpdate
- TaskList es estado en memoria (sesion actual)
- TASK_STATE.md es estado persistido (entre sesiones)
- Mantener ambos sincronizados

---

## Campos Obligatorios

Todo TASK_STATE.md debe incluir **minimo**:

1. **Ultima actualizacion** - Timestamp
2. **Resumen ejecutivo** - 3 lineas max
3. **Lista de tareas** - Con estado claro
4. **Proximos pasos** - Que hacer al retomar
5. **Notas para retomar** - Contexto critico

---

## Anti-Patrones a Evitar

1. **No crear TASK_STATE.md** para trabajo multi-fase
2. **No actualizar** al completar tareas
3. **Informacion insuficiente** para retomar
4. **Duplicar** informacion que ya esta en otros docs
5. **Actualizaciones muy frecuentes** (cada comando) - solo cambios significativos

---

## Checklist de Verificacion

Al crear/actualizar TASK_STATE.md, verificar:

- [ ] Timestamp actualizado
- [ ] Estados de tareas correctos
- [ ] Proximos pasos claros y accionables
- [ ] Contexto tecnico suficiente para retomar
- [ ] Sin informacion sensible (passwords, tokens)

---

## Beneficios

1. **Continuidad:** Retomar trabajo sin perdida de contexto
2. **Transparencia:** Usuario ve estado actual del trabajo
3. **Coordinacion:** Facilita delegacion a agentes
4. **Auditoria:** Historial de decisiones y progreso
5. **Eficiencia:** Menos tiempo recapitulando

---

**Esta directiva es OBLIGATORIA para todo trabajo multi-tarea.**
**Claude debe crear y mantener TASK_STATE.md proactivamente.**
