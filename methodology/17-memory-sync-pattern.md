# Patrón de Sincronización de Memoria

**Versión:** 1.0
**Fecha:** 2025-10-24
**Estado:** ACTIVO
**Nivel:** Fundacional

---

## 🎯 Propósito

Este documento define el **patrón de sincronización bidireccional** entre:
1. **CLAUDE.md** (memoria activa cargada automáticamente por Claude Code)
2. **claude_context** (repositorio centralizado de contexto y aprendizajes)

Este patrón asegura que el conocimiento persista, sea versionable, y esté disponible en todas las sesiones.

---

## 🏗️ Arquitectura de Memoria

### Dos Capas de Memoria

```
┌─────────────────────────────────────────────────────────────┐
│                    User Memory Layer                        │
│          ~/.claude/CLAUDE.md (Global - Todos los proyectos) │
│                                                               │
│  - Metodología general (@imports a claude_context)           │
│  - Preferencias personales                                   │
│  - Comportamientos de Claude                                 │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                   Project Memory Layer                       │
│        proyecto/.claude/CLAUDE.md (Específico del proyecto) │
│                                                               │
│  - Arquitectura y tecnologías                                │
│  - Convenciones del proyecto (@imports a claude_context)     │
│  - Work in progress                                          │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                 Context Repository Layer                     │
│          C:/claude_context/ (Versionable, Centralizado)     │
│                                                               │
│  metodologia_general/    → Docs de metodología               │
│  proyecto-x/             → Contexto del proyecto X           │
│    ├── README.md         → Visión general                    │
│    ├── LEARNINGS.md      → Patrones aprendidos              │
│    ├── ARCHITECTURE.md   → Diseño técnico                   │
│    └── analysis-reports/ → Análisis detallados              │
└─────────────────────────────────────────────────────────────┘
```

### Flujo de Carga (Inicio de Sesión)

```
1. Claude Code inicia
        ↓
2. Carga User Memory (~/.claude/CLAUDE.md)
        ↓
3. @imports cargan archivos desde claude_context/metodologia_general/
        ↓
4. Carga Project Memory (./.claude/CLAUDE.md)
        ↓
5. @imports cargan archivos desde claude_context/[proyecto]/
        ↓
6. Claude tiene contexto completo disponible
```

---

## 📝 Estructura de Archivos

### User Memory
**Ubicación:** `~/.claude/CLAUDE.md` (Windows: `C:\Users\[usuario]\.claude\CLAUDE.md`)

**Propósito:** Preferencias y metodología que aplican a TODOS los proyectos.

**Contenido típico:**
```markdown
# User Memory - [Nombre]

## Metodología General
@C:/claude_context/metodologia_general/01-resumen-ejecutivo.md
@C:/claude_context/metodologia_general/10-quick-reference.md
@C:/claude_context/metodologia_general/16-git-worktrees-parallel-agents.md

## Preferencias Personales
- Usar TodoWrite para tareas complejas
- No usar emojis
- Build con 0 warnings

## Sincronización
[Instrucciones de sincronización con claude_context]
```

### Project Memory
**Ubicación:** `[proyecto]/.claude/CLAUDE.md`

**Propósito:** Contexto específico del proyecto actual.

**Contenido típico:**
```markdown
# [Proyecto] - Project Context

## Documentación del Proyecto
@C:/claude_context/[proyecto]/README.md
@C:/claude_context/[proyecto]/LEARNINGS.md
@C:/claude_context/[proyecto]/ARCHITECTURE.md

## Tecnologías
- Framework: X
- Lenguaje: Y

## Convenciones
[Patrones específicos del proyecto]

## Sincronización
[Referencia a claude_context del proyecto]
```

### Context Repository
**Ubicación:** `C:/claude_context/`

**Propósito:** Repositorio centralizado de conocimiento versionable.

**Estructura:**
```
C:/claude_context/
├── metodologia_general/
│   ├── README.md
│   ├── 01-resumen-ejecutivo.md
│   ├── 10-quick-reference.md
│   ├── 16-git-worktrees-parallel-agents.md
│   └── 17-memory-sync-pattern.md (este documento)
│
└── [proyecto]/
    ├── README.md               → Visión general del proyecto
    ├── LEARNINGS.md            → Patrones y decisiones técnicas
    ├── ARCHITECTURE.md         → Diseño arquitectónico
    ├── GETTING_STARTED.md      → Guía de inicio rápido
    ├── analysis-reports/
    │   ├── Component_Analysis_1.md
    │   └── Component_Analysis_2.md
    └── api-suite/
        ├── SUITE_SUMMARY.md
        └── GETTING_STARTED.md
```

---

## 🔄 Flujos de Sincronización

### Flujo 1: Inicio de Sesión (Read)

**Trigger:** Abrir Claude Code en un proyecto

**Proceso:**
1. Claude lee `~/.claude/CLAUDE.md`
2. Procesa @imports desde `claude_context/metodologia_general/`
3. Claude lee `./.claude/CLAUDE.md` del proyecto
4. Procesa @imports desde `claude_context/[proyecto]/`
5. Contexto completo disponible

**Responsabilidad:** Automática (Claude Code)

### Flujo 2: Aprendizaje Durante Sesión (Write)

**Trigger:** Usuario descubre patrón importante o usa `#` para agregar memoria

**Proceso:**
1. Usuario: `# Siempre usar ConfigureAwait(false) en Framework 4.7.2`
2. Claude pregunta: ¿User o Project memory?
3. Se actualiza el archivo CLAUDE.md correspondiente
4. **Si es significativo:** También actualizar `claude_context/[proyecto]/LEARNINGS.md`

**Decisión de sincronización:**
- ✅ **Sincronizar si:**
  - Es un patrón arquitectónico importante
  - Es una decisión técnica que afecta el proyecto
  - Es conocimiento que debe preservarse entre sesiones

- ❌ **No sincronizar si:**
  - Es work in progress temporal
  - Es un recordatorio de sesión única
  - Es información volátil

### Flujo 3: Actualización de Metodología (Bidireccional)

**Trigger:** Se descubre mejora en la metodología general

**Proceso:**
1. Se actualiza documento en `claude_context/metodologia_general/`
2. User Memory ya tiene @import, cambio se refleja automáticamente en próxima sesión
3. Opcionalmente: Agregar nota en User Memory si es cambio crítico

**Ejemplo:**
```markdown
# Mejora descubierta: Git Worktrees + Agentes

# Paso 1: Crear/actualizar documento
Editar: C:/claude_context/metodologia_general/16-git-worktrees-parallel-agents.md

# Paso 2: Verificar @import existe
User Memory ya tiene: @C:/claude_context/metodologia_general/16-git-worktrees-parallel-agents.md

# Paso 3: Próxima sesión carga cambios automáticamente
✅ Sin acción adicional necesaria
```

---

## 📋 Guía de Decisión: ¿Dónde Guardar?

### User Memory (~/.claude/CLAUDE.md)
**Usar para:**
- Preferencias personales de trabajo
- Comportamientos de Claude que quiero en todos los proyectos
- Referencias a metodología general

**Ejemplos:**
- "Siempre usar TodoWrite para tareas complejas"
- "No usar emojis"
- "Build con 0 warnings obligatorio"

### Project Memory (./.claude/CLAUDE.md)
**Usar para:**
- Convenciones específicas del proyecto
- Tecnologías y frameworks del proyecto
- Work in progress actual

**Ejemplos:**
- "Framework: ASP.NET 4.7.2"
- "Branch principal: develop"
- "API Client pattern: try/catch con retorno vacío"

### Context Repository (claude_context/)
**Usar para:**
- Documentación permanente
- Análisis técnicos detallados
- Patrones arquitectónicos descubiertos
- Decisiones técnicas importantes

**Ejemplos:**
- Análisis de componente completo
- Documentación de migración WCF → API
- Patrones de performance descubiertos

---

## 🛠️ Operaciones Comunes

### Crear Memoria para Nuevo Proyecto

```bash
# 1. Crear estructura en proyecto
mkdir proyecto/.claude
touch proyecto/.claude/CLAUDE.md

# 2. Crear estructura en context repository
mkdir C:/claude_context/proyecto
touch C:/claude_context/proyecto/README.md
touch C:/claude_context/proyecto/LEARNINGS.md

# 3. Editar Project Memory con @imports
# proyecto/.claude/CLAUDE.md:
@C:/claude_context/proyecto/README.md
@C:/claude_context/proyecto/LEARNINGS.md
```

### Agregar Memoria Rápida Durante Sesión

```
# Recordar que AccesoPorDerivacion debe incluirse en instituciones
```

Claude preguntará dónde guardarlo → Elegir Project Memory

### Sincronizar Aprendizaje Importante

```markdown
# Durante la sesión
1. Descubro: "API clients deben usar ConfigureAwait(false)"
2. Uso: # API clients deben usar ConfigureAwait(false)
3. Claude guarda en .claude/CLAUDE.md

# Después de la sesión (si es importante)
4. Actualizar C:/claude_context/proyecto/LEARNINGS.md:

## API Client Patterns (2025-10-24)
- Todos los async/await deben usar ConfigureAwait(false)
- Razón: ASP.NET Framework 4.7.2 performance
- Implementado en: ApiPrestadoresClient, ApiLocalizacionClient
```

### Actualizar Metodología General

```markdown
# 1. Editar documento en claude_context
Editar: C:/claude_context/metodologia_general/[documento].md

# 2. Verificar @import en User Memory
~/.claude/CLAUDE.md debe tener:
@C:/claude_context/metodologia_general/[documento].md

# 3. Cambios disponibles en próxima sesión
✅ Automático
```

---

## ✅ Checklist de Sincronización

### Al Inicio de Proyecto Nuevo
- [ ] Crear `.claude/CLAUDE.md` en el proyecto
- [ ] Crear carpeta en `claude_context/[proyecto]/`
- [ ] Crear archivos base: README.md, LEARNINGS.md
- [ ] Agregar @imports en Project Memory
- [ ] Documentar arquitectura inicial

### Durante Desarrollo
- [ ] Usar `#` para capturar memorias rápidas
- [ ] Decidir: ¿Es memoria de sesión o conocimiento permanente?
- [ ] Si es permanente → Actualizar claude_context correspondiente

### Al Completar Feature Importante
- [ ] Actualizar `LEARNINGS.md` con patrones descubiertos
- [ ] Actualizar `ARCHITECTURE.md` si cambió diseño
- [ ] Actualizar Work in Progress en Project Memory
- [ ] Considerar crear informe de análisis en `analysis-reports/`

### Al Descubrir Mejora Metodológica
- [ ] Actualizar documento en `metodologia_general/`
- [ ] Verificar @imports existen
- [ ] Considerar agregar a quick-reference si es comando común
- [ ] Notificar en próxima sesión si es cambio crítico

---

## 🎯 Ejemplos Prácticos

### Ejemplo 1: Nuevo Proyecto .NET

**Setup inicial:**
```bash
# Estructura en proyecto
mkdir MiProyecto/.claude
```

**Project Memory (MiProyecto/.claude/CLAUDE.md):**
```markdown
# MiProyecto - Context

## Documentación
@C:/claude_context/mi-proyecto/README.md
@C:/claude_context/mi-proyecto/ARCHITECTURE.md

## Framework
- ASP.NET Core 8.0
- Database: PostgreSQL

## Convenciones
- Tests coverage >80%
- ConfigureAwait en todos los await
```

**Context Repository:**
```
C:/claude_context/mi-proyecto/
├── README.md           → "API REST para gestión de..."
├── ARCHITECTURE.md     → "Clean Architecture con..."
└── LEARNINGS.md        → (vacío inicialmente)
```

### Ejemplo 2: Descubrimiento de Patrón

**Durante sesión:**
```
Usuario: Implementa el endpoint de usuarios

Claude: [implementa]

Claude: He notado que todos los controllers siguen un patrón consistente.
        Voy a documentarlo.

# 1. Agregar a memoria rápida
# Controllers deben validar entrada con FluentValidation antes del handler

# 2. Actualizar LEARNINGS.md
```

**C:/claude_context/mi-proyecto/LEARNINGS.md:**
```markdown
## Controller Patterns (2025-10-24)

### Input Validation
- Todos los controllers validan entrada con FluentValidation
- Validators en carpeta Application/Validators/
- Retornar 400 BadRequest con errores de validación
- Ejemplo: UserController.cs:45
```

### Ejemplo 3: Migración Técnica Importante

**Contexto:** Migración de WCF a API REST

**Durante la sesión:**
1. Se completa migración exitosamente
2. Se documentan patrones y decisiones
3. Se actualiza memoria del proyecto

**Actualizaciones:**

**Project Memory (.claude/CLAUDE.md):**
```markdown
## 🚧 Work in Progress
### Última Feature Implementada
- Migración de WCF a API REST completada
- Patrón: ApiPrestadoresClient con ConfigureAwait
- Ver: C:/claude_context/jerarquicos/analysis-reports/WCF_TO_API_MIGRATION.md
```

**Nuevo documento en context:**
```markdown
C:/claude_context/jerarquicos/analysis-reports/WCF_TO_API_MIGRATION.md

# Migración WCF → API REST

## Resumen
Migración de servicios WCF legacy a API REST moderna...

## Patrones Aplicados
1. API Client pattern con BaseApiClient
2. ConfigureAwait(false) en todos los await
3. Try/catch con retorno de objeto vacío

## Archivos Afectados
- CartillaController.cs
- ApiPrestadoresClient.cs
[...]
```

---

## 🔍 Troubleshooting

### Problema: @imports no cargan archivos

**Síntomas:** Claude no tiene contexto esperado al inicio de sesión

**Solución:**
1. Verificar paths en @import (deben ser absolutos)
2. Verificar que archivos existan en las rutas especificadas
3. Reiniciar Claude Code para recargar memoria

### Problema: Cambios en claude_context no se reflejan

**Síntomas:** Edité archivo en claude_context pero Claude sigue usando versión vieja

**Solución:**
1. Cerrar y reabrir Claude Code (memoria se carga al inicio)
2. Verificar que @import apunta al archivo correcto
3. Usar `/memory` para verificar contenido cargado

### Problema: No sé si sincronizar un cambio

**Pregunta:** "¿Debo actualizar claude_context o solo CLAUDE.md?"

**Criterio de decisión:**
- ✅ Sincronizar si: Lo necesitarás en futuras sesiones dentro de 1+ semanas
- ✅ Sincronizar si: Es un patrón que se repetirá en el proyecto
- ✅ Sincronizar si: Documenta una decisión arquitectónica importante
- ❌ No sincronizar si: Es temporal o específico de esta sesión
- ❌ No sincronizar si: Es work in progress que cambiará pronto

---

## 📊 Métricas de Éxito

### Indicadores de que el patrón funciona:

- ✅ **Contexto disponible al inicio**: Claude conoce el proyecto desde el mensaje 1
- ✅ **Menos repetición**: No necesitas re-explicar convenciones cada sesión
- ✅ **Conocimiento preservado**: Patrones descubiertos están disponibles semanas después
- ✅ **Onboarding rápido**: Nuevos desarrolladores tienen contexto centralizado
- ✅ **Versionable**: claude_context puede estar en Git para compartir con equipo

### Red Flags:

- ❌ Duplicación de información entre CLAUDE.md y claude_context
- ❌ Archivos en claude_context desactualizados (>1 mes sin revisar)
- ❌ @imports apuntando a archivos inexistentes
- ❌ Información contradictoria entre memoria y context repository

---

## 🎓 Best Practices

### 1. Mantener DRY (Don't Repeat Yourself)
- Usar @imports en lugar de duplicar contenido
- Un solo source of truth para cada tipo de información

### 2. Organización Consistente
- Seguir estructura de carpetas estándar en claude_context
- Nombrar archivos de forma descriptiva
- Usar prefijos por fecha en LEARNINGS.md

### 3. Documentación Incremental
- No esperar a "terminar" para documentar
- Capturar patrones cuando los descubres
- Actualizar claude_context al completar features importantes

### 4. Revisión Periódica
- Revisar User Memory mensualmente
- Revisar Project Memory al inicio de cada sprint
- Limpiar información obsoleta

### 5. Compartir con Equipo
- Considerar versionar claude_context en Git
- README.md claro en cada proyecto
- Documentar convenciones de sincronización en equipo

---

## 🔗 Referencias

### Documentos Relacionados
- [Claude Code - Memory Documentation](https://docs.claude.com/en/docs/claude-code/memory.md)
- `10-quick-reference.md` - Comandos de memoria rápidos
- User Memory: `~/.claude/CLAUDE.md`

### Estructura de Directorios
- **User Memory:** `C:\Users\[usuario]\.claude\CLAUDE.md`
- **Project Memory:** `[proyecto]\.claude\CLAUDE.md`
- **Context Repository:** `C:\claude_context\`

---

## 📝 Changelog

### v1.0 (2025-10-24)
- Creación inicial del documento
- Definición de arquitectura de tres capas
- Flujos de sincronización bidireccional
- Ejemplos prácticos y troubleshooting
- Integrado en metodología general v2.1

---

**Última actualización:** 2025-10-24
**Versión:** 1.0
**Autor:** Claude Code
**Estado:** ACTIVO - Patrón Fundacional
