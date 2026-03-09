# Sistema de Agentes Especializados

**Version:** 3.0
**Fecha:** 2026-02-15
**Estado:** ACTIVO

---

## Concepto: Herencia de Perfiles

Los agentes se especializan mediante composicion de documentos. Un documento **base** define principios y metodologia comunes, y un documento de **especializacion** agrega conocimiento de dominio.

```
AGENT_[ROL]_BASE.md          # Comun a todas las variantes del rol
  + AGENT_[ROL]_[DOMINIO].md # Especializacion por dominio
    + Contexto del proyecto   # Proporcionado por Claude al delegar
```

## Como Componer el Prompt al Delegar

Cuando Claude (coordinador) necesita un agente especializado:

1. Leer el documento BASE del rol (o standalone si no tiene base)
2. Leer el documento de ESPECIALIZACION correspondiente (si existe)
3. Agregar el contexto especifico del proyecto/tarea
4. Componer un unico prompt y delegar al agente subyacente

### Ejemplo de Composicion

```
Necesidad: Implementar un nuevo endpoint en el Web Monitor backend (Node.js)

Claude lee:
  1. agents/AGENT_DEVELOPER_BASE.md     → Principios, metodologia, formato de entrega
  2. agents/AGENT_DEVELOPER_NODEJS.md   → Patrones Node.js, Fastify, ESM, checklist
  3. Contexto del proyecto              → Stack, archivos, specs, restricciones

Claude compone prompt para `nodejs-backend-developer`:
  "Contexto del rol: [contenido BASE + NODEJS]
   Proyecto: Web Monitor
   Tarea: Implementar endpoint GET /api/projects con filtros
   ..."
```

## Perfiles Disponibles

### Developers (BASE + Especializacion)

| Perfil | Base | Especializacion | Agente |
|--------|------|-----------------|--------|
| .NET Developer | `AGENT_DEVELOPER_BASE.md` | `AGENT_DEVELOPER_DOTNET.md` | `dotnet-backend-developer` |
| Node.js Developer | `AGENT_DEVELOPER_BASE.md` | `AGENT_DEVELOPER_NODEJS.md` | `nodejs-backend-developer` |
| Angular Developer | `AGENT_DEVELOPER_BASE.md` | `AGENT_DEVELOPER_ANGULAR.md` | `frontend-angular-developer` |
| React Developer | `AGENT_DEVELOPER_BASE.md` | `AGENT_DEVELOPER_REACT.md` | `frontend-react-developer` |
| Flutter Developer | `AGENT_DEVELOPER_BASE.md` | `AGENT_DEVELOPER_FLUTTER.md` | `flutter-developer` |
| Python Developer | `AGENT_DEVELOPER_BASE.md` | `AGENT_DEVELOPER_PYTHON.md` | `python-backend-developer` |

### Architects (BASE + Especializacion)

| Perfil | Base | Especializacion | Agente |
|--------|------|-----------------|--------|
| Frontend Architect | `AGENT_ARCHITECT_BASE.md` | `AGENT_ARCHITECT_FRONTEND.md` | `software-architect` |
| Backend Architect | `AGENT_ARCHITECT_BASE.md` | `AGENT_ARCHITECT_BACKEND.md` | `software-architect` |

### Code Reviewer (BASE + Especializacion opcional)

| Perfil | Base | Especializacion | Agente |
|--------|------|-----------------|--------|
| Code Reviewer (general) | `AGENT_REVIEWER_BASE.md` | (standalone o + stack) | `code-reviewer` |

**Nota:** REVIEWER_BASE funciona standalone. Se puede componer con especializacion por stack cuando se creen (ej: `AGENT_REVIEWER_DOTNET.md`).

### Test Engineer (BASE + Especializacion opcional)

| Perfil | Base | Especializacion | Agente |
|--------|------|-----------------|--------|
| Test Engineer (general) | `AGENT_TESTER_BASE.md` | (standalone o + stack) | `test-engineer` |

**Nota:** TESTER_BASE funciona standalone. Se puede componer con especializacion por stack cuando se creen (ej: `AGENT_TESTER_DOTNET.md`).

### Standalone Roles

| Perfil | Documento | Agente |
|--------|-----------|--------|
| MCP Server Developer | `AGENT_MCP_SERVER.md` | `mcp-server-developer` |
| DevOps Engineer | `AGENT_DEVOPS.md` | `devops-engineer` |
| Database Expert | `AGENT_DATABASE_EXPERT.md` | `database-expert` |
| Product Owner | `AGENT_PRODUCT_OWNER.md` | `product-owner` |
| Project Manager | `AGENT_PROJECT_MANAGER.md` | `project-manager` |
| Business Stakeholder | `AGENT_BUSINESS_STAKEHOLDER.md` | `business-stakeholder` |

### Specialist Analysts (Standalone)

| Perfil | Documento | Agente |
|--------|-----------|--------|
| Data Quality Analyst | `AGENT_DATA_QUALITY_ANALYST.md` | `data-quality-analyst` |
| Matching Specialist | `AGENT_MATCHING_SPECIALIST.md` | `matching-specialist` |
| Localization Analyst | `AGENT_LOCALIZATION_ANALYST.md` | `localization-analyst` |

### Futuros (a crear cuando se necesiten)

| Perfil | Base | Especializacion | Agente |
|--------|------|-----------------|--------|
| Reviewer .NET | `AGENT_REVIEWER_BASE.md` | `AGENT_REVIEWER_DOTNET.md` | `code-reviewer` |
| Reviewer Node.js | `AGENT_REVIEWER_BASE.md` | `AGENT_REVIEWER_NODEJS.md` | `code-reviewer` |
| Tester .NET | `AGENT_TESTER_BASE.md` | `AGENT_TESTER_DOTNET.md` | `test-engineer` |
| Tester Node.js | `AGENT_TESTER_BASE.md` | `AGENT_TESTER_NODEJS.md` | `test-engineer` |

## Directiva Transversal: Escalacion de Incidentes

Todos los agent profiles incluyen una seccion "Escalacion de Incidentes" que instruye a los agentes a registrar problemas de infraestructura/ecosistema en `C:/claude_context/ecosystem/INCIDENT_REGISTRY.md`.

| Agente | Registra incidentes | Intenta resolver |
|--------|---------------------|------------------|
| Developer (todos) | Si | No (reporta bloqueante) |
| Test Engineer | Si | No (continua con tests posibles) |
| Code Reviewer | Si (vulnerabilidades sistematicas) | No |
| DevOps Engineer | Si | Si (registra antes, actualiza despues) |

**Regla clave:** Registrar el incidente ANTES de reportar o intentar resolver. Si la sesion se interrumpe, el incidente queda documentado.

## Reglas

1. **BASE + ESPECIALIZACION cuando exista.** Si hay especializacion para el stack, usarla. Si no, BASE funciona standalone para reviewer y tester.
2. **Standalone para roles unicos.** DevOps, DB Expert, PO, PM, etc. no necesitan base compartida.
3. **Contexto del proyecto siempre.** Ademas de los perfiles, incluir informacion del proyecto actual.
4. **No duplicar.** Si algo es comun a todos los developers, va en BASE. Si es especifico de Angular, va en ANGULAR.
5. **Extender, no modificar.** Para agregar un nuevo stack, crear un nuevo archivo de especializacion. No modificar BASE.
6. **Mantener actualizados.** Si una decision tecnica cambia, actualizar el documento correspondiente.

## Estructura de Archivos

```
claude_context/metodologia_general/agents/
  README.md                          # Este archivo (indice del sistema)
  # Architects
  AGENT_ARCHITECT_BASE.md            # Base: principios de arquitectura
  AGENT_ARCHITECT_FRONTEND.md        # Especializacion: frontend
  AGENT_ARCHITECT_BACKEND.md         # Especializacion: backend
  # Developers
  AGENT_DEVELOPER_BASE.md            # Base: principios de desarrollo
  AGENT_DEVELOPER_DOTNET.md          # Especializacion: .NET
  AGENT_DEVELOPER_NODEJS.md          # Especializacion: Node.js
  AGENT_DEVELOPER_ANGULAR.md         # Especializacion: Angular
  AGENT_DEVELOPER_REACT.md           # Especializacion: React
  AGENT_DEVELOPER_FLUTTER.md         # Especializacion: Flutter
  AGENT_DEVELOPER_PYTHON.md          # Especializacion: Python
  # Reviewer
  AGENT_REVIEWER_BASE.md             # Base/Standalone: code review
  # Tester
  AGENT_TESTER_BASE.md               # Base/Standalone: testing
  # Standalone Roles
  AGENT_MCP_SERVER.md                # MCP server development
  AGENT_DEVOPS.md                    # DevOps / infraestructura
  AGENT_DATABASE_EXPERT.md           # Base de datos
  AGENT_PRODUCT_OWNER.md             # Product ownership
  AGENT_PROJECT_MANAGER.md           # Project management
  AGENT_BUSINESS_STAKEHOLDER.md      # Business decisions
  # Specialist Analysts
  AGENT_DATA_QUALITY_ANALYST.md      # Calidad de datos
  AGENT_MATCHING_SPECIALIST.md       # Matching / correlacion
  AGENT_LOCALIZATION_ANALYST.md      # Idiomas / i18n
```

---

**Version:** 3.0 | **Ultima actualizacion:** 2026-02-15
