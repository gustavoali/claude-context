# Git Worktrees con Agentes en Paralelo

**Versión:** 1.0
**Fecha:** 2025-10-24
**Estado:** ACTIVO
**Nivel:** Avanzado

---

## 🎯 Propósito

Esta metodología documenta una **técnica avanzada** para maximizar la productividad en Claude Code mediante:

1. **Git Worktrees** - Múltiples branches checkeados simultáneamente
2. **Agentes Especializados** - Trabajando en paralelo en diferentes worktrees
3. **Coordinación Centralizada** - Una sesión de Claude Code orquestando todo

---

## 🧠 Conceptos Fundamentales

### ¿Qué son los Git Worktrees?

Los Git Worktrees permiten tener **múltiples branches del mismo repositorio checkeadas en diferentes directorios** al mismo tiempo, compartiendo el mismo historial de Git.

```
Repositorio-ApiMovil/              (main worktree - branch: develop)
├── .git/                          (Git database compartida)
├── Api/
├── BackendServices/
└── ...

Repositorio-ApiMovil-feature1/     (linked worktree - branch: feature/165030)
├── Api/
├── BackendServices/
└── ...

Repositorio-ApiMovil-bugfix/       (linked worktree - branch: bugfix/urgent-fix)
├── Api/
├── BackendServices/
└── ...
```

**Ventajas:**
- ✅ Mismo historial de Git compartido
- ✅ Aislamiento completo de archivos
- ✅ Sin necesidad de `git stash` o cambios de branch
- ✅ Trabajo paralelo sin conflictos

### Dos Enfoques de Trabajo en Paralelo

#### Enfoque 1: Múltiples Sesiones de Claude Code
```
Sesión 1 → C:\jerarquicos\Repositorio-ApiMovil (develop)
Sesión 2 → C:\jerarquicos\Repositorio-ApiMovil-feature1 (feature/165030)
Sesión 3 → C:\jerarquicos\Repositorio-ApiMovil-bugfix (bugfix/urgent)
```

**Ventajas:**
- Aislamiento total entre sesiones
- Contexto independiente para cada tarea
- Sin comunicación entre sesiones

**Desventajas:**
- Sin coordinación centralizada
- Tres interfaces separadas para monitorear
- No hay visibilidad del progreso global

#### Enfoque 2: Una Sesión con Múltiples Agentes (RECOMENDADO)
```
Sesión Principal (Claude Code)
│
├─ Agente 1 (dotnet-backend-developer)
│  └─ Trabajando en: C:\...\Repositorio-ApiMovil-feature1
│     Tarea: Implementar nueva funcionalidad X
│
├─ Agente 2 (test-engineer)
│  └─ Trabajando en: C:\...\Repositorio-ApiMovil-feature1
│     Tarea: Escribir tests para funcionalidad X
│
└─ Agente 3 (database-expert)
   └─ Trabajando en: C:\...\Repositorio-ApiMovil-bugfix
      Tarea: Optimizar query lento
```

**Ventajas:**
- ✅ **Coordinación centralizada**: Claude ve todo el progreso
- ✅ **Visibilidad total**: Un solo TODO list con todas las tareas
- ✅ **Comunicación entre tareas**: Los agentes reportan al coordinador
- ✅ **Contexto compartido**: Decisiones basadas en progreso de todos
- ✅ **Menos overhead**: Una sola sesión
- ✅ **Orquestación inteligente**: Claude distribuye tareas estratégicamente

**Desventajas:**
- Requiere más coordinación
- El contexto de la sesión crece más rápido

---

## 🚀 Guía de Implementación

### Paso 1: Crear Worktrees

#### Crear worktree con nuevo branch
```bash
cd C:\jerarquicos\Repositorio-ApiMovil
git worktree add ../Repositorio-ApiMovil-feature1 -b feature/165030_conectar_endpoint
```

#### Crear worktree desde branch existente
```bash
git worktree add ../Repositorio-ApiMovil-bugfix bugfix/fix-performance
```

#### Listar todos los worktrees activos
```bash
git worktree list
```

**Output esperado:**
```
C:/jerarquicos/Repositorio-ApiMovil         7519b29a [develop]
C:/jerarquicos/Repositorio-ApiMovil-feature1  d2c1e348 [feature/165030_conectar_endpoint]
C:/jerarquicos/Repositorio-ApiMovil-bugfix   71b1b678 [bugfix/fix-performance]
```

### Paso 2: Configurar Entorno en Cada Worktree

**IMPORTANTE:** Cada worktree necesita su propia configuración de entorno.

#### Para proyectos .NET:
```bash
cd C:\jerarquicos\Repositorio-ApiMovil-feature1

# Restaurar paquetes NuGet
dotnet restore

# Build inicial
dotnet build

# Verificar que todo compila
dotnet build --no-incremental --configuration Release
```

#### Para proyectos Node.js:
```bash
cd proyecto-feature1
npm install
npm run build
```

#### Para proyectos Python:
```bash
cd proyecto-feature1
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
```

### Paso 3: Orquestar Agentes en Claude Code

#### Template de Coordinación

```markdown
Voy a coordinar trabajo en paralelo usando worktrees:

**Worktree 1:** C:\jerarquicos\Repositorio-ApiMovil-feature1 (feature/165030)
**Worktree 2:** C:\jerarquicos\Repositorio-ApiMovil-bugfix (bugfix/urgent)

Delegando tareas en paralelo:

**Agente 1 - dotnet-backend-developer:**
- **Ubicación:** Repositorio-ApiMovil-feature1
- **Tarea:** Implementar endpoint de entidades de salud
- **Archivos:** Api/Controllers/CartillaController.cs
- **Output esperado:** Endpoint funcionando con DTOs

**Agente 2 - test-engineer:**
- **Ubicación:** Repositorio-ApiMovil-bugfix
- **Tarea:** Escribir tests de regresión para fix de performance
- **Archivos:** Tests/CartillaControllerTests.cs
- **Output esperado:** Suite de tests completa

Mientras tanto, yo monitoreando progreso y resolviendo bloqueos.
```

#### Uso del Task Tool con Paths Absolutos

Los agentes deben recibir **instrucciones explícitas** sobre qué worktree usar:

```markdown
TASK: Implementar nueva funcionalidad en feature branch

IMPORTANTE: Debes trabajar en el worktree:
C:\jerarquicos\Repositorio-ApiMovil-feature1

Todos los archivos que leas/edites deben usar este path base:
- Read: C:\jerarquicos\Repositorio-ApiMovil-feature1\Api\Controllers\...
- Edit: C:\jerarquicos\Repositorio-ApiMovil-feature1\BackendServices\...
- Bash: cd C:\jerarquicos\Repositorio-ApiMovil-feature1 && dotnet build

Tareas:
1. Implementar endpoint FindByFilters
2. Crear DTOs necesarios
3. Actualizar .csproj

Output esperado: Código compilando sin errores
```

### Paso 4: Monitorear Progreso

Como coordinador, Claude mantiene un **TODO list unificado**:

```markdown
## Todo List - Trabajo en Paralelo

### Feature Branch (Worktree 1)
- [x] Crear DTOs para EntidadSalud
- [IN PROGRESS] Implementar método FindByFilters
- [ ] Agregar tests unitarios
- [ ] Actualizar documentación

### Bugfix Branch (Worktree 2)
- [x] Diagnosticar query lento
- [x] Optimizar con índices
- [IN PROGRESS] Validar con profiler
- [ ] Escribir tests de performance

### Coordinación
- [ ] Revisar conflictos potenciales entre branches
- [ ] Preparar estrategia de merge
```

### Paso 5: Integración y Cleanup

#### Cuando un agente completa su trabajo:

```bash
# En el worktree correspondiente
cd C:\jerarquicos\Repositorio-ApiMovil-feature1

# Commit los cambios
git add .
git commit -m "Implementar endpoint EntidadSalud FindByFilters"

# Push a remote
git push origin feature/165030_conectar_endpoint
```

#### Eliminar worktree cuando ya no se necesita:

```bash
cd C:\jerarquicos\Repositorio-ApiMovil

# Remover worktree (los commits ya están en el branch)
git worktree remove ../Repositorio-ApiMovil-feature1

# Eliminar branch local si ya se mergeó
git branch -d feature/165030_conectar_endpoint
```

---

## 📋 Casos de Uso Recomendados

### ✅ Cuándo Usar Worktrees + Agentes

1. **Desarrollo de múltiples features en paralelo**
   - Feature grande que requiere múltiples agentes especializados
   - Diferentes partes del sistema (frontend + backend + DB)

2. **Hotfix urgente durante desarrollo de feature**
   - Feature en progreso en develop
   - Bug crítico necesita fix inmediato
   - No quieres perder contexto del trabajo actual

3. **Experimentación con múltiples enfoques**
   - Probar dos soluciones arquitectónicas diferentes
   - A/B testing de implementaciones
   - Comparar performance de diferentes estrategias

4. **Testing en diferentes configuraciones**
   - Branch con cambios de configuración
   - Branch con datos de prueba diferentes
   - Validación en múltiples versiones

5. **Refactoring grande + mantener estabilidad**
   - Refactor en un worktree
   - Bugfixes en otro worktree
   - Main worktree para emergencias

### ❌ Cuándo NO Usar Esta Técnica

1. **Tareas simples de un solo archivo**
   - Overhead innecesario
   - Mejor usar branch normal

2. **Proyecto muy pequeño**
   - No justifica la complejidad

3. **Sin suficiente RAM/disco**
   - Cada worktree duplica archivos
   - Builds consumen recursos

4. **Cambios que afectan mismos archivos**
   - Alto riesgo de conflictos
   - Mejor trabajar secuencialmente

---

## 🎯 Patrones de Coordinación

### Patrón 1: Pipeline Paralelo

```
Agente 1 (Backend)     Agente 2 (Tests)      Agente 3 (Docs)
     ↓                       ↓                      ↓
Implementa API    →   Espera completar  →   Espera tests
     ↓                       ↓                      ↓
  DONE            →   Escribe tests     →   Documenta API
                             ↓                      ↓
                          DONE           →      DONE
```

### Patrón 2: Trabajo Completamente Independiente

```
Agente 1 (Feature A)     Agente 2 (Feature B)     Agente 3 (Bugfix C)
  Worktree 1                Worktree 2              Worktree 3
       ↓                         ↓                        ↓
  Trabaja solo            Trabaja solo            Trabaja solo
       ↓                         ↓                        ↓
    DONE                      DONE                     DONE
       ↓                         ↓                        ↓
       └─────────────────────────┴────────────────────────┘
                                 ↓
                          Merge coordinado
```

### Patrón 3: Refactor + Bugfixes

```
Agente 1 (Refactor)                    Agente 2 (Bugfixes)
  Worktree 1                             Worktree 2
  (long-running)                         (high-priority)
       ↓                                      ↓
  Refactoriza                        Fix Bug 1 → Merge
       ↓                                      ↓
  Sigue trabajando...                  Fix Bug 2 → Merge
       ↓                                      ↓
  Termina refactor                     Fix Bug 3 → Merge
       ↓
   Merge final
```

---

## 🛠️ Troubleshooting

### Problema 1: "fatal: 'path' is already checked out"

**Causa:** Estás intentando crear un worktree con un branch que ya está checkeado en otro worktree.

**Solución:**
```bash
# Ver dónde está checkeado
git worktree list

# Remover el worktree viejo si ya no lo usas
git worktree remove ../old-path
```

### Problema 2: Agente trabaja en el worktree equivocado

**Causa:** No se especificaron paths absolutos en las instrucciones.

**Solución:**
```markdown
❌ INCORRECTO:
"Edita Api/Controllers/CartillaController.cs"

✅ CORRECTO:
"Edita C:\jerarquicos\Repositorio-ApiMovil-feature1\Api\Controllers\CartillaController.cs"
```

### Problema 3: Builds fallan por dependencias desactualizadas

**Causa:** El worktree no tiene paquetes NuGet/npm instalados.

**Solución:**
```bash
cd C:\jerarquicos\Repositorio-ApiMovil-feature1
dotnet restore
dotnet build
```

### Problema 4: Conflictos al mergear worktrees

**Causa:** Múltiples agentes editaron los mismos archivos.

**Prevención:**
- Asignar archivos no-overlapping a cada agente
- Coordinar cambios en archivos compartidos
- Usar feature flags para aislar cambios

### Problema 5: Alto uso de disco

**Causa:** Múltiples worktrees duplican archivos.

**Solución:**
```bash
# Limpiar worktrees que ya no usas
git worktree list
git worktree remove ../worktree-old

# Limpiar builds en worktrees
cd worktree-path
dotnet clean
```

---

## 📊 Métricas de Éxito

### Indicadores de que esta técnica funciona:

- ✅ **Reducción de tiempo total**: Tareas completadas en <50% del tiempo secuencial
- ✅ **Sin conflictos de merge**: <5% de conflictos al integrar branches
- ✅ **Alta utilización de agentes**: >80% del tiempo con múltiples agentes activos
- ✅ **Coordinación eficiente**: <10% del tiempo en sincronización

### Red Flags para dejar de usar:

- ❌ Conflictos constantes al mergear (>20%)
- ❌ Agentes bloqueados esperando por otros (>50% del tiempo)
- ❌ Overhead de coordinación > tiempo ahorrado
- ❌ Dificultad para trackear qué agente hace qué

---

## 🎓 Ejemplo Completo: Feature + Tests + Docs

### Contexto
Necesitas implementar un nuevo endpoint de EntidadesSalud con:
- Backend API
- Tests unitarios
- Tests de integración
- Documentación

### Setup Inicial

```bash
cd C:\jerarquicos\Repositorio-ApiMovil

# Crear worktree para feature principal
git worktree add ../Repositorio-ApiMovil-feature165030 -b feature/165030_entidades_salud

# Configurar entorno
cd ../Repositorio-ApiMovil-feature165030
dotnet restore
dotnet build
```

### Coordinación en Claude Code

```markdown
Voy a coordinar el desarrollo de la feature 165030 usando worktrees y agentes en paralelo.

**Worktree:** C:\jerarquicos\Repositorio-ApiMovil-feature165030
**Branch:** feature/165030_entidades_salud

## Plan de Trabajo Paralelo

### Fase 1: Backend + DTOs (Paralelo)

**Agente 1 - dotnet-backend-developer:**
- Path: C:\jerarquicos\Repositorio-ApiMovil-feature165030
- Tarea: Implementar ApiPrestadoresClient.EntidadSaludFindByFilters
- Archivos:
  - BackendServices/ApiPrestadores/Services/ApiPrestadoresClient.cs
  - BackendServices/ApiPrestadores/Interfaces/IApiPrestadoresClient.cs
- Output: Método implementado con ConfigureAwait(false)

**Agente 2 - dotnet-backend-developer:**
- Path: C:\jerarquicos\Repositorio-ApiMovil-feature165030
- Tarea: Crear DTOs para EntidadSaludFindByFilters
- Archivos:
  - BackendServices/ApiPrestadores/Models/EntidadSaludFindByFiltersRequestDto.cs
  - BackendServices/ApiPrestadores/Models/EntidadSaludFindByFiltersResponseDto.cs
  - BackendServices/ApiPrestadores/Models/EntidadSaludFindByFiltersPaginatedResponseDto.cs
- Output: DTOs completos con propiedades y validación

### Fase 2: Controller + Tests (Paralelo)

**Agente 3 - dotnet-backend-developer:**
- Path: C:\jerarquicos\Repositorio-ApiMovil-feature165030
- Tarea: Actualizar CartillaController con nuevo endpoint
- Depende de: Agentes 1 y 2
- Archivos:
  - Api/Controllers/CartillaController.cs
- Output: Método GetInstitucionesRadioNProtegido actualizado

**Agente 4 - test-engineer:**
- Path: C:\jerarquicos\Repositorio-ApiMovil-feature165030
- Tarea: Escribir tests unitarios
- Depende de: Agente 3
- Archivos:
  - Tests/Api.Tests/Controllers/CartillaControllerTests.cs
- Output: Tests con >80% coverage

### Fase 3: Validación Final (Secuencial)

Yo (Claude coordinador):
1. Revisar código de todos los agentes
2. Ejecutar build completo
3. Ejecutar suite de tests
4. Validar manualmente
5. Preparar commit y merge
```

### Ejecución

```markdown
🚀 Iniciando Fase 1...

[Lanza Agente 1 y Agente 2 en paralelo con Task tool]

⏳ Esperando completar Fase 1...

✅ Agente 1 completó: ApiPrestadoresClient.EntidadSaludFindByFilters
✅ Agente 2 completó: 3 DTOs creados

🚀 Iniciando Fase 2...

[Lanza Agente 3 y luego Agente 4 secuencialmente]

✅ Agente 3 completó: CartillaController actualizado
✅ Agente 4 completó: 15 tests escritos, coverage 85%

🔍 Validación Final...

[Build y tests]
✅ Build exitoso (0 errores, 0 warnings)
✅ Todos los tests pasando (15/15)
✅ Manual testing completado

📝 Preparando commit...
```

### Resultado

**Tiempo total:** 2 horas (vs 4+ horas secuencial)
**Reducción:** 50%
**Tests:** 15 nuevos, 85% coverage
**Conflictos:** 0
**Calidad:** Alta (code review aprobado)

---

## 🔗 Referencias

### Documentación Oficial
- [Claude Code - Common Workflows (Git Worktrees)](https://docs.claude.com/en/docs/claude-code/common-workflows.md#run-parallel-claude-code-sessions-with-git-worktrees)
- [Git Documentation - git-worktree](https://git-scm.com/docs/git-worktree)

### Otros Documentos de la Metodología
- `07-uso-agentes-paralelismo.md` - Directivas generales de uso de agentes
- `04-workflow-git-branches.md` - Git workflow estándar
- `10-quick-reference.md` - Comandos rápidos

---

## 📌 Checklist Rápido

### Antes de Empezar:
- [ ] Identificar tareas que pueden ejecutarse en paralelo
- [ ] Verificar que las tareas no editan los mismos archivos
- [ ] Confirmar recursos disponibles (RAM, disco)
- [ ] Crear worktrees necesarios
- [ ] Configurar entorno en cada worktree

### Durante la Ejecución:
- [ ] Proveer paths absolutos a cada agente
- [ ] Mantener TODO list unificado actualizado
- [ ] Monitorear progreso de cada agente
- [ ] Resolver bloqueos inmediatamente
- [ ] Coordinar dependencias entre agentes

### Al Terminar:
- [ ] Validar trabajo de todos los agentes
- [ ] Build completo exitoso
- [ ] Tests pasando
- [ ] Commit y push changes
- [ ] Remover worktrees no necesarios
- [ ] Documentar lecciones aprendidas

---

**Última actualización:** 2025-10-24
**Versión:** 1.0
**Autor:** Claude Code
**Estado:** ACTIVO - Técnica Avanzada Recomendada
