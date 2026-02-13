# Agent Team - LinkedIn Transcript Extractor

**Version:** 1.0
**Date:** 2026-01-15
**Project:** LinkedIn Transcript Extractor v0.8.2
**Status:** APPROVED

---

## Executive Summary

Este documento define el equipo de agentes de Claude Code necesarios para ejecutar el plan de resolucion de deuda tecnica y backlog del proyecto LinkedIn Transcript Extractor.

### Stack Tecnologico del Proyecto

| Capa | Tecnologia | Lenguaje |
|------|------------|----------|
| Chrome Extension | Manifest V3 | JavaScript (ES6+) |
| Native Host | Node.js | JavaScript |
| MCP Server | Node.js + SDK | JavaScript |
| Database | NeDB | JavaScript |
| Testing | Jest | JavaScript |

---

## Analisis de Agentes Disponibles vs Requeridos

### Agentes Disponibles en Claude Code

| Agente | Especialidad | Aplica al Proyecto? | Uso |
|--------|--------------|---------------------|-----|
| `test-engineer` | Testing, Jest, coverage | **SI** | Setup Jest, escribir tests |
| `code-reviewer` | Code review, best practices | **SI** | Review de PRs y codigo |
| `database-expert` | SQL/NoSQL, queries | **PARCIAL** | NeDB queries (NoSQL) |
| `devops-engineer` | CI/CD, Docker, infra | **SI** | GitHub Actions |
| `software-architect` | System design | **SI** | Decisiones arquitectura |
| `project-manager` | Planning, tracking | **SI** | Sprint management |
| `product-owner` | User stories, backlog | **SI** | Refinamiento backlog |
| `Explore` | Codebase exploration | **SI** | Analisis de codigo |
| `dotnet-backend-developer` | .NET/C# | **NO** | Stack es Node.js |
| `frontend-react-developer` | React | **NO** | Extension usa vanilla JS |
| `frontend-angular-developer` | Angular | **NO** | No aplica |
| `general-purpose` | Multi-step tasks | **SI** | Tareas generales |
| `Bash` | Command execution | **SI** | npm, git, etc |

### Gap Analysis - Agentes Faltantes

| Rol Necesario | Agente Ideal | Agente Sustituto | Estrategia |
|---------------|--------------|------------------|------------|
| **Node.js Backend Developer** | `nodejs-backend-developer` (no existe) | `general-purpose` | Prompts detallados con contexto Node.js |
| **Chrome Extension Developer** | `chrome-extension-developer` (no existe) | `general-purpose` | Prompts con Manifest V3 context |
| **JavaScript Developer** | `javascript-developer` (no existe) | `general-purpose` | Prompts con ES6+ patterns |

---

## Equipo de Agentes Configurado

### Rol 1: Test Engineer

**Agente:** `test-engineer`

**Responsabilidades:**
- Setup de Jest testing framework
- Escribir unit tests para VTT parser
- Escribir integration tests para storage
- Configurar coverage reports
- Crear GitHub Actions workflow para CI

**Asignacion por Sprint:**
| Sprint | Horas | Tareas |
|--------|-------|--------|
| 1 | 8h | US-TD-003: Setup Jest + tests core |
| 2 | 0h | - |
| 3 | 2h | Tests para language features |
| 4 | 2h | Tests para course features |

**Skills Verificados:**
- Jest configuration
- Test patterns (AAA, Given-When-Then)
- Coverage analysis
- Mocking strategies

**Prompt Template:**
```
Como test-engineer para el proyecto LinkedIn Transcript Extractor:

**Stack:** Node.js + Jest + Chrome Extension APIs
**Ubicacion:** C:\mcp\linkedin

**Tarea:** [descripcion]

**Contexto tecnico:**
- VTT parser en: extension/vtt-parser.js
- Storage en: native-host/host.js (NeDB)
- Chrome APIs mockeadas con jest-chrome

**Output esperado:**
- Tests en __tests__/ directory
- Coverage >70% para modulos criticos
- npm test debe pasar
```

---

### Rol 2: Backend Developer (Node.js)

**Agente:** `general-purpose` (con contexto Node.js)

**Responsabilidades:**
- Refactoring de scripts (consolidacion)
- Implementar logging estructurado
- Externalizar configuracion
- Logica de language sync
- Storage model para courses

**Asignacion por Sprint:**
| Sprint | Horas | Tareas |
|--------|-------|--------|
| 1 | 5h | US-TD-001: Consolidar scripts |
| 2 | 7h | US-TD-004 + US-TD-005: Config + Logging |
| 3 | 7h | US-BL-001 + US-BL-005: Language sync |
| 4 | 9h | US-BL-002 + BL-003 + BL-004: Courses |

**Prompt Template:**
```
Como Node.js backend developer para LinkedIn Transcript Extractor:

**Stack:** Node.js 18+, NeDB, ES6+ modules
**Ubicacion:** C:\mcp\linkedin

**Tarea:** [descripcion]

**Patrones del proyecto:**
- Async/await con try/catch
- NeDB Datastore para persistencia
- Native Messaging Protocol (stdin/stdout)
- ES6 modules (import/export)

**Archivos relevantes:**
- native-host/host.js - Native messaging host
- server/index.js - MCP server
- scripts/ - Utilidades

**Output esperado:**
- Codigo funcional sin errores
- JSDoc comments para funciones publicas
- Manejo de errores explicito
```

---

### Rol 3: Frontend Developer (Chrome Extension)

**Agente:** `general-purpose` (con contexto Chrome Extension)

**Responsabilidades:**
- UI del popup (popup.html/js)
- Options page (config UI)
- Content script updates
- Language indicator UI
- Course navigation UI

**Asignacion por Sprint:**
| Sprint | Horas | Tareas |
|--------|-------|--------|
| 1 | 0h | - |
| 2 | 5h | US-BL-008 + US-BL-009: Auto-clear + URL display |
| 3 | 4h | US-BL-001 + BL-007: Language UI |
| 4 | 6h | US-BL-002: Course list UI |

**Prompt Template:**
```
Como Chrome Extension developer para LinkedIn Transcript Extractor:

**Stack:** Manifest V3, Vanilla JavaScript, Chrome APIs
**Ubicacion:** C:\mcp\linkedin\extension

**Tarea:** [descripcion]

**APIs disponibles:**
- chrome.storage.sync/local
- chrome.webRequest
- chrome.tabs
- chrome.runtime (messaging)
- chrome.action (badge)

**Archivos:**
- manifest.json - Extension config
- background.js - Service Worker
- content.js - Injected script
- popup.html/js - Popup UI
- options.html/js - Settings page (crear si no existe)

**Restricciones Manifest V3:**
- No eval(), no remote code
- Service Worker (no persistent background)
- Promises (no callbacks legacy)

**Output esperado:**
- HTML semantico
- CSS modular (sin frameworks)
- JavaScript vanilla ES6+
- Responsive para popup (400px width max)
```

---

### Rol 4: Code Reviewer

**Agente:** `code-reviewer`

**Responsabilidades:**
- Review de codigo antes de merge
- Verificar best practices
- Security review
- Performance review
- Consistency check

**Asignacion por Sprint:**
| Sprint | Horas | Tareas |
|--------|-------|--------|
| 1 | 1h | Review tests + scripts refactor |
| 2 | 1h | Review config + logging |
| 3 | 1h | Review language sync |
| 4 | 1h | Review course organization |

**Prompt Template:**
```
Como code-reviewer para LinkedIn Transcript Extractor:

**Revisar:**
- [archivos modificados]

**Checklist:**
- [ ] No hardcoded values
- [ ] Error handling presente
- [ ] Async/await correcto
- [ ] No memory leaks
- [ ] No security issues (XSS, injection)
- [ ] Code readable y documentado
- [ ] Tests incluidos si aplica

**Output:**
- Lista de issues encontrados
- Severidad (Critical/High/Medium/Low)
- Sugerencias de fix
```

---

### Rol 5: Technical Lead (Coordinador)

**Agente:** Human (tu) + Claude Code orchestration

**Responsabilidades:**
- Sprint planning y tracking
- Coordinacion de agentes
- Decisiones arquitecturales
- Code review final
- Merge a main branch
- Release management

**Asignacion por Sprint:**
| Sprint | Horas | Tareas |
|--------|-------|--------|
| 1 | 3h | Planning + Review + Coordination |
| 2 | 3h | Planning + Review + Coordination |
| 3 | 3h | Planning + Review + Coordination |
| 4 | 3h | Planning + Review + Coordination |

---

## Matriz de Asignacion por User Story

### Sprint 1

| User Story | Agente Principal | Agente Soporte | Horas |
|------------|------------------|----------------|-------|
| US-TD-003: Testing Framework | `test-engineer` | `code-reviewer` | 8h |
| US-TD-001: Consolidar Scripts | `general-purpose` (Node.js) | `code-reviewer` | 5h |

### Sprint 2

| User Story | Agente Principal | Agente Soporte | Horas |
|------------|------------------|----------------|-------|
| US-TD-004: Config Externa | `general-purpose` (Node.js) | `code-reviewer` | 4h |
| US-TD-005: Logging | `general-purpose` (Node.js) | - | 3h |
| US-BL-009: URL/Title | `general-purpose` (Extension) | - | 2h |
| US-BL-008: Auto-clear | `general-purpose` (Extension) | - | 3h |

### Sprint 3

| User Story | Agente Principal | Agente Soporte | Horas |
|------------|------------------|----------------|-------|
| US-BL-001: Language Sync | `general-purpose` (Node.js + Extension) | `test-engineer` | 8h |
| US-BL-005: Auto-detect | `general-purpose` (Node.js) | - | 3h |
| US-BL-007: Language UI | `general-purpose` (Extension) | - | 2h |

### Sprint 4

| User Story | Agente Principal | Agente Soporte | Horas |
|------------|------------------|----------------|-------|
| US-BL-002: Course Org | `general-purpose` (Node.js + Extension) | `database-expert` | 8h |
| US-BL-003: Course History | `general-purpose` (Node.js) | - | 3h |
| US-BL-004: Export | `general-purpose` (Node.js) | - | 5h |

---

## Protocolos de Comunicacion

### Entre Agentes

Los agentes no se comunican directamente. La coordinacion es via:

1. **Technical Lead (Claude orchestrator)** recibe output de Agente A
2. **Technical Lead** procesa y genera prompt para Agente B
3. **Technical Lead** integra resultados

### Handoff Protocol

```
Agente A completa tarea
    |
    v
Output documentado (archivos + summary)
    |
    v
Technical Lead valida
    |
    v
Si OK: Siguiente tarea o Agente B
Si NO: Agente A itera
```

### Escalation Protocol

```
Agente encuentra blocker
    |
    v
Documenta blocker con contexto
    |
    v
Technical Lead evalua
    |
    v
Opcion A: Resolver y continuar
Opcion B: Escalar a software-architect
Opcion C: Mover a backlog como technical debt
```

---

## Metricas de Performance por Agente

### KPIs por Rol

| Rol | KPI | Target |
|-----|-----|--------|
| Test Engineer | Coverage achieved | >70% |
| Backend Developer | Code quality (review pass rate) | >90% |
| Frontend Developer | UI bugs introduced | <2 per sprint |
| Code Reviewer | Issues found | Document all |
| Technical Lead | Sprint goal success | 100% |

### Tracking

Despues de cada sprint, documentar:
- Horas estimadas vs reales por agente
- Calidad de output por agente
- Ajustes necesarios para siguiente sprint

---

## Contingencias

### Si un Agente No Puede Completar Tarea

1. **Intentar con prompts mas especificos** (2 intentos max)
2. **Escalar a software-architect** para guidance
3. **Dividir tarea** en subtareas mas pequenas
4. **Technical Lead** completa manualmente si es critico

### Si Falta Capacidad de Agente

Para tareas que requieren agentes no disponibles (ej: Chrome Extension specialist):
1. Usar `general-purpose` con contexto detallado
2. Incluir documentacion de APIs relevantes en prompt
3. Proveer ejemplos de codigo existente como referencia

---

## Onboarding de Nuevos Agentes (Futuro)

Si se agregan agentes especializados al sistema:

### nodejs-backend-developer (Deseado)
- Especializado en Node.js patterns
- Conocimiento de npm ecosystem
- Async patterns avanzados

### chrome-extension-developer (Deseado)
- Manifest V3 expertise
- Chrome APIs completas
- Extension security patterns

**Proceso de incorporacion:**
1. Actualizar este documento
2. Migrar tareas de `general-purpose` al especializado
3. Ajustar prompts templates

---

## Checklist Pre-Ejecucion

- [x] Agentes disponibles identificados
- [x] Gaps documentados con estrategia de mitigacion
- [x] Prompt templates creados
- [x] Asignacion por sprint definida
- [x] Protocolos de comunicacion establecidos
- [ ] Sprint 1 ready to start

---

## Aprobacion

**Documento aprobado por:** Technical Lead
**Fecha:** 2026-01-15
**Version:** 1.0

**Proximos pasos:**
1. Iniciar Sprint 1 con US-TD-003 (Testing Framework)
2. Usar `test-engineer` para setup Jest
3. Usar `general-purpose` (Node.js context) para consolidar scripts

---

**END OF AGENT TEAM DOCUMENTATION**
