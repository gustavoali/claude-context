# Flujo de Solicitudes de Cambio - Directiva Obligatoria

**Version:** 1.1
**Fecha:** 2026-02-03
**Estado:** OBLIGATORIO - Aplica a TODOS los proyectos

---

## Proposito

Establecer un proceso ordenado para manejar solicitudes de cambio, correcciones de bugs y nuevas funcionalidades, evitando cambios ad-hoc que dificultan el seguimiento y control del proyecto.

---

## Regla Fundamental

**CAMBIO DE CODIGO = BACKLOG PRIMERO**

No hay decisiones que tomar en el momento. La regla es simple y sin excepciones:

| Situacion | Accion |
|-----------|--------|
| Usuario pide cambio | → Backlog |
| Usuario reporta bug | → Backlog |
| Claude encuentra bug | → Backlog |
| Test falla | → Backlog |
| Se necesita fix para continuar | → Backlog |
| "Es pequeño/rapido" | → Backlog igual |

**NO importa si el cambio parece pequeño, trivial, o urgente. Siempre backlog primero.**

---

## Directiva Principal

**Cuando se identifique cualquier necesidad de cambio de codigo - ya sea por solicitud del usuario O por descubrimiento de Claude durante el trabajo - NO se debe actuar de inmediato.**

En su lugar, se debe:
1. Crear una historia/tarea en el backlog
2. Priorizarla segun su urgencia e impacto
3. Asignarla a un sprint o iteracion
4. Trabajarla en una rama separada (delegando a agentes)
5. Mergear a la rama principal al completar

---

## Proceso Detallado

### Paso 0: Cuando Claude Encuentra un Problema

**CRITICO:** Esto aplica cuando Claude descubre un problema durante el trabajo, no solo cuando el usuario lo reporta.

**Situaciones comunes:**
- Test falla y Claude identifica la causa
- Claude nota codigo que necesita fix
- Error durante ejecucion que requiere correccion
- Refactor necesario para continuar

**Respuesta CORRECTA de Claude:**
```
"Encontre un problema: [descripcion].
Voy a crear una tarea en el backlog para resolverlo.
Prioridad sugerida: [X] porque [razon].
¿Procedemos con esto o hay algo mas urgente?"
```

**Respuesta INCORRECTA (NO HACER):**
```
"Encontre un problema. Lo arreglo rapidamente..."
[Claude edita el codigo directamente]
```

**Ejemplo real (2026-02-03):**
- Situacion: Test "should handle stop errors gracefully" fallaba
- MAL: Claude edito parallel-completion-manager.js directamente
- BIEN: Debio crear tarea "Fix error handling en stop()", priorizarla, delegarla

### Paso 1: Recepcion de Solicitud

Cuando el usuario reporta:
- Bug encontrado durante testing
- Solicitud de cambio de funcionalidad
- Nueva feature o mejora
- Correccion de comportamiento

**Respuesta de Claude:**
```
"Entendido. Voy a crear una historia en el backlog para [descripcion breve].
¿Cual es la prioridad? (Critical/High/Medium/Low)
¿Hay algo que bloquee mientras tanto?"
```

### Paso 2: Crear Historia en Backlog

Usar el agente `product-owner` para:
- Asignar ID unico (segun registry del proyecto)
- Definir acceptance criteria basicos
- Clasificar tipo: Bug / Enhancement / Feature
- Asignar prioridad inicial

**Formato minimo:**
```markdown
### [ID]: [Titulo descriptivo]
**Tipo:** Bug / Enhancement / Feature
**Prioridad:** Critical / High / Medium / Low
**Status:** Pending
**Reportado:** [Fecha]

**Descripcion:**
[Que se solicita o que problema se encontro]

**Acceptance Criteria:**
- AC1: [Criterio minimo]
```

### Paso 3: Priorizar y Asignar

- **Critical:** Bloquea uso de la app → Atender en el sprint actual
- **High:** Afecta funcionalidad importante → Proximo sprint
- **Medium:** Mejora deseable → Cuando haya capacidad
- **Low:** Nice to have → Backlog para futuro

### Paso 4: Trabajar en Rama Separada

**Convencion de ramas:**
```
feature/[ID]-descripcion-breve
bugfix/[ID]-descripcion-breve
enhancement/[ID]-descripcion-breve
```

**Ejemplo:**
```bash
git checkout -b bugfix/MEW-018-fix-snackbar-duration
```

### Paso 5: Desarrollo y Testing

- Implementar cambio en la rama
- Testear localmente
- Verificar que no hay regresiones

### Paso 6: Merge a Rama Principal

```bash
git checkout main  # o develop segun el proyecto
git merge --no-ff [rama-feature]
git push origin main
git branch -d [rama-feature]  # opcional: eliminar rama local
```

### Paso 7: Actualizar Backlog

- Marcar historia como Done
- Documentar resultado si es relevante

---

## Excepciones

### Cambios que NO requieren historia:

1. **Typos simples** - Errores de escritura obvios
2. **Formateo de codigo** - Sin cambio funcional
3. **Actualizacion de documentacion menor** - README, comentarios

### Cambios que SI requieren historia:

1. **Cualquier cambio de comportamiento**
2. **Bugs reportados por usuario**
3. **Nuevas funcionalidades**
4. **Modificaciones de UI/UX**
5. **Cambios en logica de negocio**
6. **Optimizaciones de performance**

---

## Requisitos de Repositorio

**OBLIGATORIO:** Cada proyecto debe tener su repositorio Git inicializado.

### Verificacion al inicio de proyecto:
```bash
git status
```

Si no existe repositorio:
```bash
git init
git add .
git commit -m "Initial commit"
```

### Estructura de ramas recomendada:

- `main` - Rama principal, siempre estable
- `develop` - Rama de desarrollo (opcional para proyectos micro)
- `feature/*` - Ramas de features
- `bugfix/*` - Ramas de correcciones
- `release/*` - Ramas de release (para proyectos grandes)

---

## Comunicacion con Usuario

### Al recibir solicitud de cambio:
```
"Voy a crear la historia [ID] en el backlog: [descripcion].
Prioridad sugerida: [X]. ¿Correcto?
¿La trabajamos ahora o hay algo mas urgente?"
```

### Al completar:
```
"Historia [ID] completada y mergeada a main.
[Resumen del cambio]
¿Probamos o seguimos con el backlog?"
```

---

## Beneficios

1. **Trazabilidad:** Historial claro de cambios
2. **Priorizacion:** Trabajo ordenado por importancia
3. **Control de versiones:** Cambios aislados en ramas
4. **Rollback facil:** Si algo falla, revertir es simple
5. **Documentacion:** Backlog como registro de decisiones

---

## Integracion con Otras Directivas

### Con 18-claude-coordinator-role.md:
- Claude coordina, no ejecuta cambios ad-hoc

### Con 20-backlog-management-directive.md:
- Usar agente product-owner para crear historias
- Mantener ID Registry actualizado

### Con 04-workflow-git-branches.md:
- Seguir convenciones de ramas del proyecto

---

## Checklist Rapido

Antes de hacer un cambio:
- [ ] ¿Es un typo/formato simple? → Hacer directo
- [ ] ¿Cambia comportamiento? → Crear historia
- [ ] ¿El proyecto tiene repo git? → Verificar/crear
- [ ] ¿Existe rama para el cambio? → Crear si no
- [ ] ¿Esta priorizado? → Confirmar con usuario

---

## Por Que Esta Directiva es Critica

### El Problema de los "Fixes Rapidos"

Cuando Claude encuentra un problema y lo "arregla rapido":
1. **Sin trazabilidad** - No queda registro del cambio
2. **Sin revision** - Nadie valida que el fix es correcto
3. **Sin contexto** - Futuras sesiones no saben que se cambio
4. **Sin priorizacion** - Se interrumpe el trabajo planificado
5. **Sin delegacion** - Claude ejecuta en lugar de coordinar

### La Solucion: Backlog Siempre

El backlog no es burocracia, es **control y visibilidad**:
- Todo cambio queda registrado con ID unico
- Se puede priorizar vs otras tareas
- Se delega al agente apropiado
- Se trabaja en rama separada
- Se puede hacer rollback si falla

### Regla de Oro

> **Si voy a usar Edit, Write, o Bash para modificar codigo,
> PRIMERO debo haber creado una tarea en el backlog.**

---

## Historial de Cambios

| Fecha | Version | Cambio |
|-------|---------|--------|
| 2026-01-31 | 1.0 | Creacion inicial de la directiva |
| 2026-02-03 | 1.1 | Agregada Regla Fundamental y Paso 0 (cuando Claude encuentra problema). Reforzada la directiva con ejemplo real y seccion "Por Que es Critica" |

---

**Esta directiva es OBLIGATORIA para TODOS los proyectos.**
**Claude debe seguirla proactivamente, incluso cuando el encuentra problemas durante el trabajo.**
