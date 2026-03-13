# Product Backlog - PR Analyzer Multi-Domain

**Proyecto:** AtlasOps - PR Analyzer Feature
**Product Owner:** Usuario (validado por Claude)
**Fecha:** 2026-01-26
**Estado:** ACTIVO
**Version:** 1.0

---

## Product Vision

**Vision:** Sistema automatizado de analisis de Pull Requests que detecta el dominio/tecnologia del codigo, selecciona agentes especializados, ejecuta analisis en paralelo, y postea un comentario consolidado con feedback accionable.

**Objetivo de Negocio:** Automatizar code review para equipos de desarrollo, reduciendo tiempo de revision y mejorando la calidad del codigo.

**Success Criteria:**
- Webhook de GitHub procesa PRs en <30 segundos
- Deteccion correcta de dominio en >95% de los casos
- Analisis paralelo de multiples archivos
- Comentario consolidado con findings accionables
- Soporte para .NET, Python, TypeScript, y analisis generico

---

## Dominios Soportados

| Dominio | Analisis Especifico | Agente |
|---------|---------------------|--------|
| .NET | Nullable refs, async/await, EF queries, SOLID, dependency injection | dotnet-analyzer |
| Python | Type hints, PEP8, imports, async patterns, docstrings | python-analyzer |
| TypeScript | Types strictness, null checks, React patterns, ESLint rules | typescript-analyzer |
| Generic | Complejidad ciclomatica, duplicacion, seguridad basica, code smells | generic-analyzer |

---

## Priorizacion RICE - PR Analyzer Stories

| ID | Story | Reach | Impact | Confidence | Effort | RICE Score | Priority |
|----|-------|-------|--------|------------|--------|------------|----------|
| ATLAS-043 | GitHub Webhook Handler | 10 | 3 | 100% | 3 | **100** | Must Have |
| ATLAS-044 | Domain Detection Engine | 10 | 3 | 90% | 5 | **54** | Must Have |
| ATLAS-045 | Generic Code Analyzer | 10 | 2 | 100% | 3 | **67** | Must Have |
| ATLAS-046 | .NET Analyzer Agent | 8 | 2 | 90% | 5 | **29** | Must Have |
| ATLAS-047 | Python Analyzer Agent | 8 | 2 | 90% | 5 | **29** | Must Have |
| ATLAS-048 | TypeScript Analyzer Agent | 8 | 2 | 90% | 5 | **29** | Must Have |
| ATLAS-049 | Parallel Execution Engine | 10 | 3 | 80% | 5 | **48** | Must Have |
| ATLAS-050 | Result Consolidator | 10 | 2 | 100% | 3 | **67** | Must Have |
| ATLAS-051 | GitHub Comment Poster | 10 | 3 | 100% | 2 | **150** | Must Have |
| ATLAS-052 | PR Analysis Persistence | 6 | 1 | 100% | 2 | **30** | Should Have |
| ATLAS-053 | Rate Limiting & Throttling | 5 | 2 | 90% | 2 | **45** | Should Have |
| ATLAS-054 | Webhook Signature Validation | 8 | 2 | 100% | 1 | **160** | Must Have |
| ATLAS-055 | Analysis Dashboard API | 4 | 1 | 80% | 3 | **11** | Could Have |
| ATLAS-056 | Custom Rules Configuration | 3 | 1 | 70% | 5 | **4** | Could Have |

---

## Epic Breakdown

### Epica 1: Webhook & GitHub Integration (ATLAS-043, ATLAS-051, ATLAS-054)

**Goal:** Recibir webhooks de GitHub y postear comentarios en PRs
**Story Points Total:** 6 pts
**Sprint:** Sprint 5 (Dias 1-3)
**Priority:** Must Have (MVP Core)

---

#### ATLAS-043: GitHub Webhook Handler

**Story Points:** 3
**Priority:** Must Have (RICE: 100)
**Sprint:** Sprint 5

**As a** developer
**I want** que el sistema reciba webhooks de GitHub cuando se crea/actualiza un PR
**So that** el analisis se ejecute automaticamente

**Acceptance Criteria:**

**AC1: Endpoint de webhook funcional**
- Given el endpoint POST /webhooks/github configurado
- When GitHub envia un webhook de tipo "pull_request"
- Then el sistema parsea correctamente el payload
- And extrae: repo, PR number, branch, archivos modificados
- And responde 200 OK en <500ms

**AC2: Filtrado de eventos**
- Given un webhook de GitHub
- When el evento es "pull_request" con action "opened" o "synchronize"
- Then se inicia el proceso de analisis
- And si es otro tipo de evento se ignora con log

**AC3: Extraccion de archivos modificados**
- Given un PR con archivos modificados
- When se procesa el webhook
- Then se obtiene la lista de archivos via GitHub API
- And se descarga el contenido de cada archivo modificado
- And se almacena temporalmente para analisis

**AC4: Manejo de errores**
- Given un webhook malformado o incompleto
- When se intenta procesar
- Then se retorna 400 Bad Request con mensaje descriptivo
- And se loggea el error con correlation ID

**Technical Notes:**
```typescript
// Orchestrator - apps/orchestrator-ts/src/routes/webhooks.ts
interface GitHubWebhookPayload {
  action: 'opened' | 'synchronize' | 'closed' | 'reopened';
  pull_request: {
    number: number;
    title: string;
    head: { sha: string; ref: string };
    base: { ref: string };
    user: { login: string };
  };
  repository: {
    full_name: string;
    clone_url: string;
  };
}

// Archivos a crear:
// - src/routes/webhooks/github.ts
// - src/services/github-client.ts
// - src/types/github.ts
```

**Definition of Done:**
- [ ] Endpoint POST /webhooks/github implementado
- [ ] Parsing de payload GitHub
- [ ] Integracion con GitHub API para obtener archivos
- [ ] Tests unitarios (>80% coverage)
- [ ] Tests de integracion con payload mock
- [ ] Documentacion de setup en GitHub

**Dependencies:** None (entrada del sistema)

---

#### ATLAS-054: Webhook Signature Validation

**Story Points:** 1
**Priority:** Must Have (RICE: 160)
**Sprint:** Sprint 5

**As a** security engineer
**I want** que los webhooks de GitHub sean validados con signature
**So that** solo webhooks legitimos sean procesados

**Acceptance Criteria:**

**AC1: Validacion de HMAC signature**
- Given un webhook con header X-Hub-Signature-256
- When se recibe el request
- Then se valida el HMAC-SHA256 contra el secret configurado
- And si es invalido se retorna 401 Unauthorized

**AC2: Rechazo de requests sin signature**
- Given un request al endpoint de webhook
- When no tiene header X-Hub-Signature-256
- Then se retorna 401 Unauthorized
- And se loggea el intento

**AC3: Secret configurable**
- Given la variable de entorno GITHUB_WEBHOOK_SECRET
- When se inicia el servicio
- Then se carga el secret para validacion
- And si falta se falla el startup con error claro

**Technical Notes:**
```typescript
// Middleware de validacion
import { createHmac, timingSafeEqual } from 'crypto';

function validateGitHubWebhook(
  payload: Buffer,
  signature: string,
  secret: string
): boolean {
  const expected = `sha256=${createHmac('sha256', secret)
    .update(payload)
    .digest('hex')}`;
  return timingSafeEqual(
    Buffer.from(signature),
    Buffer.from(expected)
  );
}
```

**Definition of Done:**
- [ ] Middleware de validacion implementado
- [ ] Variable de entorno documentada
- [ ] Tests con signatures validos e invalidos
- [ ] Logging de intentos fallidos

**Dependencies:** ATLAS-043

---

#### ATLAS-051: GitHub Comment Poster

**Story Points:** 2
**Priority:** Must Have (RICE: 150)
**Sprint:** Sprint 5

**As a** developer
**I want** que los resultados del analisis se posteen como comentario en el PR
**So that** pueda ver el feedback directamente en GitHub

**Acceptance Criteria:**

**AC1: Posteo de comentario exitoso**
- Given resultados de analisis consolidados
- When se completa el analisis
- Then se postea un comentario en el PR via GitHub API
- And el comentario incluye: summary, findings por categoria, suggestions

**AC2: Formato Markdown estructurado**
- Given el comentario a postear
- When se genera el contenido
- Then usa Markdown con headers, listas, y code blocks
- And incluye badges de severidad (critical, warning, info)
- And tiene collapsible sections para detalles

**AC3: Actualizacion de comentario existente**
- Given un PR que ya tiene un comentario de analisis previo
- When se ejecuta un nuevo analisis (PR actualizado)
- Then se actualiza el comentario existente en lugar de crear uno nuevo
- And se agrega timestamp de ultima actualizacion

**AC4: Manejo de errores de API**
- Given un intento de postear comentario
- When la GitHub API falla (rate limit, permisos)
- Then se reintenta con exponential backoff (max 3 intentos)
- And si falla definitivamente se loggea y notifica

**Technical Notes:**
```typescript
// Template del comentario
const commentTemplate = `
## PR Analysis Report

**Analyzed:** {{timestamp}}
**Files:** {{fileCount}} | **Issues:** {{issueCount}}

### Summary
{{summary}}

<details>
<summary>Critical Issues ({{criticalCount}})</summary>

{{#each criticalIssues}}
- **{{file}}:{{line}}** - {{message}}
{{/each}}

</details>

<details>
<summary>Warnings ({{warningCount}})</summary>

{{#each warnings}}
- **{{file}}:{{line}}** - {{message}}
{{/each}}

</details>

---
*Analyzed by AtlasOps PR Analyzer*
`;
```

**Definition of Done:**
- [ ] GitHub API client para comentarios
- [ ] Template Markdown configurable
- [ ] Logica de update vs create
- [ ] Retry logic implementada
- [ ] Tests con mocks de GitHub API

**Dependencies:** ATLAS-043, ATLAS-050

---

### Epica 2: Domain Detection (ATLAS-044)

**Goal:** Detectar automaticamente el dominio/tecnologia de los archivos
**Story Points Total:** 5 pts
**Sprint:** Sprint 5 (Dias 2-4)
**Priority:** Must Have (MVP Core)

---

#### ATLAS-044: Domain Detection Engine

**Story Points:** 5
**Priority:** Must Have (RICE: 54)
**Sprint:** Sprint 5

**As a** system
**I want** detectar automaticamente el dominio de cada archivo en el PR
**So that** pueda seleccionar el agente analizador correcto

**Acceptance Criteria:**

**AC1: Deteccion por extension de archivo**
- Given un archivo con extension conocida
- When se analiza el archivo
- Then se detecta el dominio primario:
  - .cs, .csproj, .sln -> .NET
  - .py, .pyi -> Python
  - .ts, .tsx, .js, .jsx -> TypeScript
  - Otros -> Generic

**AC2: Deteccion por contenido (heuristicas)**
- Given un archivo sin extension clara
- When se analiza el contenido
- Then se detecta por patrones:
  - `using System;`, `namespace` -> .NET
  - `import`, `def `, `class ` (con indentacion) -> Python
  - `import React`, `interface `, `type ` -> TypeScript

**AC3: Deteccion de dominio mixto**
- Given un PR con archivos de multiples dominios
- When se procesa el PR
- Then se agrupa archivos por dominio
- And se retorna mapa de dominio -> archivos

**AC4: Dominio por defecto**
- Given un archivo no reconocible
- When no se puede detectar dominio especifico
- Then se asigna dominio "generic"
- And se aplica analisis generico

**AC5: Deteccion de proyecto root**
- Given un repositorio con archivos de configuracion
- When se encuentra: .csproj, package.json, requirements.txt, pyproject.toml
- Then se infiere el dominio principal del proyecto
- And se usa como hint para archivos ambiguos

**Technical Notes:**
```python
# Agent Service - apps/agents-py/app/services/domain_detector.py
from enum import Enum
from pathlib import Path
from typing import Dict, List

class Domain(Enum):
    DOTNET = "dotnet"
    PYTHON = "python"
    TYPESCRIPT = "typescript"
    GENERIC = "generic"

class DomainDetector:
    EXTENSION_MAP = {
        ".cs": Domain.DOTNET,
        ".csproj": Domain.DOTNET,
        ".sln": Domain.DOTNET,
        ".py": Domain.PYTHON,
        ".pyi": Domain.PYTHON,
        ".ts": Domain.TYPESCRIPT,
        ".tsx": Domain.TYPESCRIPT,
        ".js": Domain.TYPESCRIPT,
        ".jsx": Domain.TYPESCRIPT,
    }

    def detect(self, filename: str, content: str) -> Domain:
        # 1. Extension-based
        ext = Path(filename).suffix.lower()
        if ext in self.EXTENSION_MAP:
            return self.EXTENSION_MAP[ext]

        # 2. Content-based heuristics
        return self._detect_by_content(content)

    def detect_batch(self, files: List[dict]) -> Dict[Domain, List[dict]]:
        result = {d: [] for d in Domain}
        for file in files:
            domain = self.detect(file["filename"], file["content"])
            result[domain].append(file)
        return result
```

**Definition of Done:**
- [ ] DomainDetector service implementado
- [ ] Soporte para 4 dominios
- [ ] Heuristicas por contenido
- [ ] Tests con archivos de ejemplo de cada dominio
- [ ] Metricas de precision de deteccion

**Dependencies:** ATLAS-043

---

### Epica 3: Analyzers Especializados (ATLAS-045 a ATLAS-048)

**Goal:** Agentes especializados para cada dominio de codigo
**Story Points Total:** 18 pts
**Sprint:** Sprint 5-6 (Dias 3-8)
**Priority:** Must Have (MVP Core)

---

#### ATLAS-045: Generic Code Analyzer

**Story Points:** 3
**Priority:** Must Have (RICE: 67)
**Sprint:** Sprint 5

**As a** developer
**I want** un analizador generico de codigo
**So that** cualquier archivo tenga al menos analisis basico

**Acceptance Criteria:**

**AC1: Analisis de complejidad ciclomatica**
- Given un archivo de codigo
- When se ejecuta el analisis
- Then se calcula complejidad ciclomatica
- And se reporta warning si >10 por funcion

**AC2: Deteccion de duplicacion**
- Given multiples archivos en el PR
- When se ejecuta el analisis
- Then se detectan bloques de codigo duplicados (>5 lineas)
- And se reporta la ubicacion de los duplicados

**AC3: Deteccion de seguridad basica**
- Given codigo con posibles vulnerabilidades
- When se ejecuta el analisis
- Then se detectan patrones como:
  - Hardcoded secrets (API keys, passwords)
  - SQL injection basico
  - Uso de eval/exec
- And se reportan como criticos

**AC4: Code smells genericos**
- Given codigo con problemas de calidad
- When se ejecuta el analisis
- Then se detectan:
  - Funciones muy largas (>50 lineas)
  - Archivos muy largos (>500 lineas)
  - Demasiados parametros (>5)
  - TODO/FIXME sin issue

**Technical Notes:**
```python
# Agent Service - apps/agents-py/app/agents/generic_analyzer.py
from dataclasses import dataclass
from typing import List
from anthropic import Anthropic

@dataclass
class Finding:
    severity: str  # "critical", "warning", "info"
    category: str  # "security", "complexity", "duplication", "smell"
    file: str
    line: int
    message: str
    suggestion: str

class GenericAnalyzer:
    def __init__(self, anthropic_client: Anthropic):
        self.client = anthropic_client
        self.system_prompt = """You are a code quality analyzer.
        Analyze the given code for:
        1. Cyclomatic complexity
        2. Code duplication
        3. Security vulnerabilities (hardcoded secrets, injection risks)
        4. Code smells (long functions, too many parameters)

        Return findings in structured JSON format."""

    async def analyze(self, file: dict) -> List[Finding]:
        response = await self.client.messages.create(
            model="claude-sonnet-4-20250514",
            max_tokens=4096,
            system=self.system_prompt,
            messages=[{
                "role": "user",
                "content": f"Analyze this code:\n\nFilename: {file['filename']}\n\n```\n{file['content']}\n```"
            }]
        )
        return self._parse_findings(response.content)
```

**Definition of Done:**
- [ ] GenericAnalyzer implementado
- [ ] 4 tipos de analisis funcionando
- [ ] Prompt engineering optimizado
- [ ] Tests con codigo de ejemplo
- [ ] Documentacion de findings

**Dependencies:** ATLAS-044

---

#### ATLAS-046: .NET Analyzer Agent

**Story Points:** 5
**Priority:** Must Have (RICE: 29)
**Sprint:** Sprint 5-6

**As a** .NET developer
**I want** un analizador especializado en codigo .NET
**So that** reciba feedback relevante para el ecosistema .NET

**Acceptance Criteria:**

**AC1: Nullable reference types**
- Given codigo C# con NRT habilitado
- When se ejecuta el analisis
- Then se detectan:
  - Variables que podrian ser null sin null check
  - Uso de `!` (null forgiving) sin justificacion
  - Missing `?` en tipos nullables

**AC2: Async/await patterns**
- Given codigo con metodos async
- When se ejecuta el analisis
- Then se detectan:
  - Async void (excepto event handlers)
  - Falta de ConfigureAwait(false) en librerias
  - Task.Result o .Wait() (deadlock risk)
  - Fire-and-forget sin manejo de excepciones

**AC3: Entity Framework patterns**
- Given codigo con DbContext
- When se ejecuta el analisis
- Then se detectan:
  - N+1 queries potenciales
  - Missing Include() para eager loading
  - Raw SQL sin parametrizar
  - DbContext con lifetime incorrecto

**AC4: SOLID violations**
- Given codigo C# con clases y metodos
- When se ejecuta el analisis
- Then se detectan:
  - Single Responsibility: clases con >5 dependencias
  - Open/Closed: switch sobre tipos
  - Dependency Inversion: new concreto en lugar de DI

**AC5: Dependency Injection issues**
- Given codigo con servicios
- When se ejecuta el analisis
- Then se detectan:
  - Service Locator pattern
  - Constructor con >7 dependencias
  - Scoped service inyectado en Singleton

**Technical Notes:**
```python
# Agent Service - apps/agents-py/app/agents/dotnet_analyzer.py
class DotNetAnalyzer:
    def __init__(self, anthropic_client: Anthropic):
        self.client = anthropic_client
        self.system_prompt = """You are a senior .NET developer and code reviewer.

        Analyze the given C# code for:

        1. NULLABLE REFERENCES:
           - Missing null checks before dereferencing
           - Inappropriate use of null-forgiving operator (!)
           - Missing nullable annotations on reference types

        2. ASYNC/AWAIT:
           - async void methods (except event handlers)
           - Missing ConfigureAwait(false) in library code
           - Using .Result or .Wait() which can cause deadlocks
           - Fire-and-forget tasks without exception handling

        3. ENTITY FRAMEWORK:
           - N+1 query patterns (querying in loops)
           - Missing Include() for navigation properties
           - Non-parameterized raw SQL queries
           - DbContext lifetime issues (singleton DbContext)

        4. SOLID PRINCIPLES:
           - Classes with too many responsibilities (>300 lines, >5 dependencies)
           - Switch statements on type instead of polymorphism
           - Direct instantiation of dependencies instead of DI

        5. DEPENDENCY INJECTION:
           - Service Locator anti-pattern
           - Constructors with too many dependencies (>7)
           - Captive dependency (scoped in singleton)

        Return findings as structured JSON with severity, category, file, line, message, and suggestion."""
```

**Definition of Done:**
- [ ] DotNetAnalyzer implementado
- [ ] 5 categorias de analisis
- [ ] Tests con codigo C# real
- [ ] Ejemplos documentados de cada finding

**Dependencies:** ATLAS-045 (hereda estructura)

---

#### ATLAS-047: Python Analyzer Agent

**Story Points:** 5
**Priority:** Must Have (RICE: 29)
**Sprint:** Sprint 5-6

**As a** Python developer
**I want** un analizador especializado en codigo Python
**So that** reciba feedback relevante para el ecosistema Python

**Acceptance Criteria:**

**AC1: Type hints analysis**
- Given codigo Python
- When se ejecuta el analisis
- Then se detectan:
  - Funciones publicas sin type hints
  - Type hints incorrectos o demasiado genericos (Any)
  - Incompatibilidad de tipos en asignaciones

**AC2: PEP8 compliance**
- Given codigo Python
- When se ejecuta el analisis
- Then se detectan:
  - Nombres que violan convenciones (snake_case)
  - Lineas demasiado largas (>88 chars)
  - Espaciado incorrecto
  - Import order incorrecto

**AC3: Import patterns**
- Given imports en archivos Python
- When se ejecuta el analisis
- Then se detectan:
  - Import circulares potenciales
  - Star imports (from x import *)
  - Unused imports
  - Missing __init__.py

**AC4: Async patterns**
- Given codigo con async/await
- When se ejecuta el analisis
- Then se detectan:
  - Mixing sync and async incorrectamente
  - Missing await en coroutines
  - Blocking calls en contexto async

**AC5: Docstrings y documentacion**
- Given funciones y clases
- When se ejecuta el analisis
- Then se detectan:
  - Funciones publicas sin docstring
  - Docstrings desactualizados (parametros no coinciden)
  - Missing return type documentation

**Technical Notes:**
```python
# Agent Service - apps/agents-py/app/agents/python_analyzer.py
class PythonAnalyzer:
    def __init__(self, anthropic_client: Anthropic):
        self.client = anthropic_client
        self.system_prompt = """You are a senior Python developer following best practices.

        Analyze the given Python code for:

        1. TYPE HINTS (PEP 484, 585):
           - Public functions without type hints
           - Use of Any when more specific types exist
           - Incorrect or inconsistent type annotations

        2. PEP8 STYLE:
           - Variable/function naming (should be snake_case)
           - Class naming (should be PascalCase)
           - Line length (max 88 for black, 79 for strict PEP8)
           - Import ordering (stdlib, third-party, local)

        3. IMPORTS:
           - Star imports (from x import *)
           - Unused imports
           - Potential circular imports
           - Missing __all__ in __init__.py

        4. ASYNC/AWAIT:
           - Blocking calls in async context
           - Missing await on coroutines
           - Mixing sync and async incorrectly

        5. DOCUMENTATION:
           - Public functions without docstrings
           - Docstrings with wrong parameters
           - Missing return documentation

        Return findings as structured JSON."""
```

**Definition of Done:**
- [ ] PythonAnalyzer implementado
- [ ] 5 categorias de analisis
- [ ] Tests con codigo Python real
- [ ] Ejemplos documentados

**Dependencies:** ATLAS-045

---

#### ATLAS-048: TypeScript Analyzer Agent

**Story Points:** 5
**Priority:** Must Have (RICE: 29)
**Sprint:** Sprint 5-6

**As a** TypeScript/React developer
**I want** un analizador especializado en codigo TypeScript
**So that** reciba feedback relevante para el ecosistema TypeScript/React

**Acceptance Criteria:**

**AC1: TypeScript strictness**
- Given codigo TypeScript
- When se ejecuta el analisis
- Then se detectan:
  - Uso de `any` cuando se puede ser mas especifico
  - Missing return types en funciones
  - Type assertions inseguras (as unknown as X)
  - Non-null assertions sin justificacion (!)

**AC2: Null/undefined handling**
- Given codigo con posibles null/undefined
- When se ejecuta el analisis
- Then se detectan:
  - Acceso a propiedades sin optional chaining
  - Missing null checks antes de usar valores
  - Nullish coalescing opportunities

**AC3: React patterns (si aplica)**
- Given codigo React (JSX/TSX)
- When se ejecuta el analisis
- Then se detectan:
  - Missing key en listas/maps
  - useEffect con dependencias incorrectas
  - useState con objeto que deberia usar useReducer
  - Prop drilling excesivo (>3 niveles)
  - Missing memo/useMemo para performance

**AC4: ESLint-like rules**
- Given codigo TypeScript/JavaScript
- When se ejecuta el analisis
- Then se detectan:
  - == en lugar de ===
  - Variables no usadas
  - Console.log en produccion
  - Magic numbers/strings

**AC5: Import/export patterns**
- Given estructura de imports/exports
- When se ejecuta el analisis
- Then se detectan:
  - Barrel files problematicos (index.ts con re-exports)
  - Circular dependencies
  - Missing default exports cuando esperado

**Technical Notes:**
```python
# Agent Service - apps/agents-py/app/agents/typescript_analyzer.py
class TypeScriptAnalyzer:
    def __init__(self, anthropic_client: Anthropic):
        self.client = anthropic_client
        self.system_prompt = """You are a senior TypeScript and React developer.

        Analyze the given TypeScript code for:

        1. TYPE SAFETY:
           - Use of 'any' when more specific types exist
           - Missing return type annotations
           - Unsafe type assertions (as unknown as X)
           - Non-null assertions (!) without justification

        2. NULL HANDLING:
           - Missing optional chaining (?.)
           - Missing nullish coalescing (??)
           - Potential null/undefined access

        3. REACT PATTERNS (if JSX/TSX):
           - Missing key prop in lists
           - useEffect with missing/wrong dependencies
           - Complex state that should use useReducer
           - Prop drilling (>3 levels)
           - Missing memo/useMemo for expensive operations

        4. CODE QUALITY:
           - == instead of ===
           - Unused variables
           - console.log in production code
           - Magic numbers/strings

        5. IMPORTS:
           - Problematic barrel files
           - Circular dependencies
           - Inconsistent import style

        Return findings as structured JSON."""
```

**Definition of Done:**
- [ ] TypeScriptAnalyzer implementado
- [ ] 5 categorias de analisis
- [ ] Deteccion especial para React
- [ ] Tests con codigo TS/React real

**Dependencies:** ATLAS-045

---

### Epica 4: Orquestacion y Consolidacion (ATLAS-049, ATLAS-050)

**Goal:** Ejecutar analizadores en paralelo y consolidar resultados
**Story Points Total:** 8 pts
**Sprint:** Sprint 6 (Dias 5-7)
**Priority:** Must Have (MVP Core)

---

#### ATLAS-049: Parallel Execution Engine

**Story Points:** 5
**Priority:** Must Have (RICE: 48)
**Sprint:** Sprint 6

**As a** system
**I want** ejecutar multiples analizadores en paralelo
**So that** el analisis de PRs grandes sea rapido

**Acceptance Criteria:**

**AC1: Ejecucion paralela por dominio**
- Given archivos agrupados por dominio
- When se inicia el analisis
- Then se lanzan analizadores en paralelo (uno por dominio)
- And se espera a que todos terminen (Promise.all / asyncio.gather)

**AC2: Timeout por analizador**
- Given un analizador ejecutandose
- When pasan mas de 60 segundos
- Then se cancela la ejecucion
- And se reporta timeout en los resultados
- And otros analizadores continuan

**AC3: Manejo de errores aislado**
- Given un analizador que falla
- When ocurre una excepcion
- Then se captura el error sin afectar otros analizadores
- And se incluye el error en los resultados parciales

**AC4: Concurrencia limitada**
- Given un PR con muchos archivos
- When se ejecutan analisis
- Then se limita a max 5 analizadores simultaneos
- And se usa semaforo para controlar concurrencia

**AC5: Progress tracking**
- Given analisis en progreso
- When se consulta el estado
- Then se puede ver: archivos procesados / total
- And tiempo transcurrido

**Technical Notes:**
```python
# Agent Service - apps/agents-py/app/services/parallel_executor.py
import asyncio
from typing import List, Dict
from dataclasses import dataclass

@dataclass
class AnalysisTask:
    domain: str
    files: List[dict]
    analyzer: callable

@dataclass
class AnalysisResult:
    domain: str
    findings: List[Finding]
    duration_ms: int
    status: str  # "success", "timeout", "error"
    error: str | None = None

class ParallelExecutor:
    def __init__(self, max_concurrency: int = 5, timeout_seconds: int = 60):
        self.semaphore = asyncio.Semaphore(max_concurrency)
        self.timeout = timeout_seconds

    async def execute_all(self, tasks: List[AnalysisTask]) -> List[AnalysisResult]:
        async def run_with_timeout(task: AnalysisTask) -> AnalysisResult:
            async with self.semaphore:
                try:
                    start = time.time()
                    findings = await asyncio.wait_for(
                        task.analyzer(task.files),
                        timeout=self.timeout
                    )
                    return AnalysisResult(
                        domain=task.domain,
                        findings=findings,
                        duration_ms=int((time.time() - start) * 1000),
                        status="success"
                    )
                except asyncio.TimeoutError:
                    return AnalysisResult(
                        domain=task.domain,
                        findings=[],
                        duration_ms=self.timeout * 1000,
                        status="timeout",
                        error=f"Analyzer timed out after {self.timeout}s"
                    )
                except Exception as e:
                    return AnalysisResult(
                        domain=task.domain,
                        findings=[],
                        duration_ms=0,
                        status="error",
                        error=str(e)
                    )

        return await asyncio.gather(*[run_with_timeout(t) for t in tasks])
```

**Definition of Done:**
- [ ] ParallelExecutor implementado
- [ ] Timeout funcional
- [ ] Error handling aislado
- [ ] Semaphore para concurrencia
- [ ] Tests de ejecucion paralela

**Dependencies:** ATLAS-044, ATLAS-045, ATLAS-046, ATLAS-047, ATLAS-048

---

#### ATLAS-050: Result Consolidator

**Story Points:** 3
**Priority:** Must Have (RICE: 67)
**Sprint:** Sprint 6

**As a** system
**I want** consolidar resultados de multiples analizadores
**So that** el comentario final sea coherente y organizado

**Acceptance Criteria:**

**AC1: Merge de findings**
- Given resultados de multiples analizadores
- When se consolidan
- Then se combinan todos los findings en una lista unificada
- And se ordenan por: severidad (critical > warning > info), luego por archivo

**AC2: Deduplicacion**
- Given findings que pueden solaparse
- When se consolidan
- Then se eliminan duplicados (mismo archivo, linea, mensaje)
- And se prefiere el finding mas especifico

**AC3: Agrupacion por categoria**
- Given findings consolidados
- When se genera el reporte
- Then se agrupan por:
  - Security issues
  - Performance issues
  - Code quality
  - Style/formatting

**AC4: Summary generation**
- Given todos los findings
- When se genera el summary
- Then incluye:
  - Total de archivos analizados
  - Conteo por severidad
  - Top 3 issues mas criticos
  - Recomendacion general

**AC5: Formato de salida configurable**
- Given findings consolidados
- When se exportan
- Then se puede obtener en:
  - Markdown (para GitHub comment)
  - JSON (para API)
  - SARIF (para integraciones)

**Technical Notes:**
```python
# Agent Service - apps/agents-py/app/services/result_consolidator.py
@dataclass
class ConsolidatedReport:
    summary: str
    total_files: int
    findings_by_severity: Dict[str, int]
    critical_findings: List[Finding]
    warnings: List[Finding]
    info: List[Finding]
    by_category: Dict[str, List[Finding]]
    analysis_duration_ms: int
    analyzers_status: Dict[str, str]

class ResultConsolidator:
    def consolidate(self, results: List[AnalysisResult]) -> ConsolidatedReport:
        all_findings = []
        for result in results:
            all_findings.extend(result.findings)

        # Deduplicate
        unique_findings = self._deduplicate(all_findings)

        # Sort by severity
        sorted_findings = sorted(
            unique_findings,
            key=lambda f: (self.SEVERITY_ORDER[f.severity], f.file, f.line)
        )

        return ConsolidatedReport(
            summary=self._generate_summary(sorted_findings),
            total_files=len(set(f.file for f in sorted_findings)),
            findings_by_severity=self._count_by_severity(sorted_findings),
            critical_findings=[f for f in sorted_findings if f.severity == "critical"],
            warnings=[f for f in sorted_findings if f.severity == "warning"],
            info=[f for f in sorted_findings if f.severity == "info"],
            by_category=self._group_by_category(sorted_findings),
            analysis_duration_ms=sum(r.duration_ms for r in results),
            analyzers_status={r.domain: r.status for r in results}
        )

    def to_markdown(self, report: ConsolidatedReport) -> str:
        # Generate GitHub-friendly markdown
        pass

    def to_sarif(self, report: ConsolidatedReport) -> dict:
        # Generate SARIF format for IDE integration
        pass
```

**Definition of Done:**
- [ ] ResultConsolidator implementado
- [ ] Deduplicacion funcional
- [ ] Markdown output
- [ ] JSON output
- [ ] Tests de consolidacion

**Dependencies:** ATLAS-049

---

### Epica 5: Persistencia y Observabilidad (ATLAS-052, ATLAS-053)

**Goal:** Persistir resultados y controlar rate limits
**Story Points Total:** 4 pts
**Sprint:** Sprint 6 (Dias 7-8)
**Priority:** Should Have

---

#### ATLAS-052: PR Analysis Persistence

**Story Points:** 2
**Priority:** Should Have (RICE: 30)
**Sprint:** Sprint 6

**As a** system administrator
**I want** que los resultados de analisis se persistan en DB
**So that** pueda ver historico y metricas

**Acceptance Criteria:**

**AC1: Tabla de analisis**
- Given un analisis completado
- When se persiste
- Then se guarda en tabla `pr_analyses` con:
  - id, repo, pr_number, commit_sha
  - analysis_result (JSONB)
  - findings_count, critical_count
  - duration_ms, created_at

**AC2: Query de historial**
- Given un repositorio
- When se consulta el historial
- Then se pueden ver ultimos N analisis
- And filtrar por fecha, severidad, PR

**AC3: Metricas agregadas**
- Given datos historicos
- When se consultan metricas
- Then se puede obtener:
  - Promedio de findings por PR
  - Tendencia de calidad (mejora/empeora)
  - Top archivos problematicos

**Technical Notes:**
```sql
-- Platform API - migrations
CREATE TABLE pr_analyses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    repository VARCHAR(255) NOT NULL,
    pr_number INT NOT NULL,
    commit_sha VARCHAR(40) NOT NULL,
    analysis_result JSONB NOT NULL,
    total_findings INT NOT NULL,
    critical_count INT NOT NULL,
    warning_count INT NOT NULL,
    duration_ms INT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),

    UNIQUE(repository, pr_number, commit_sha)
);

CREATE INDEX idx_pr_analyses_repo ON pr_analyses(repository);
CREATE INDEX idx_pr_analyses_created ON pr_analyses(created_at);
```

**Definition of Done:**
- [ ] Tabla creada con migration
- [ ] API de persistencia en Platform
- [ ] Query de historial
- [ ] Metricas basicas

**Dependencies:** ATLAS-050

---

#### ATLAS-053: Rate Limiting & Throttling

**Story Points:** 2
**Priority:** Should Have (RICE: 45)
**Sprint:** Sprint 6

**As a** system
**I want** rate limiting en el procesamiento de webhooks
**So that** no se sobrecargue el sistema ni la API de Claude

**Acceptance Criteria:**

**AC1: Rate limit por repositorio**
- Given multiples webhooks del mismo repo
- When se reciben >5 en 1 minuto
- Then se encolan los excedentes
- And se procesan gradualmente

**AC2: Throttling de API de Claude**
- Given llamadas al LLM
- When se acerca al rate limit de Anthropic
- Then se reduce la concurrencia automaticamente
- And se espera antes de reintentar

**AC3: Queue de procesamiento**
- Given webhooks entrantes
- When el sistema esta ocupado
- Then se encolan en Redis
- And se procesan FIFO con prioridad por repo

**Technical Notes:**
```typescript
// Orchestrator - rate limiter
import { RateLimiter } from 'limiter';

const limiterByRepo = new Map<string, RateLimiter>();

function getRateLimiter(repo: string): RateLimiter {
    if (!limiterByRepo.has(repo)) {
        limiterByRepo.set(repo, new RateLimiter({
            tokensPerInterval: 5,
            interval: 'minute'
        }));
    }
    return limiterByRepo.get(repo)!;
}
```

**Definition of Done:**
- [ ] Rate limiter implementado
- [ ] Queue en Redis
- [ ] Throttling de Claude API
- [ ] Tests de rate limiting

**Dependencies:** ATLAS-043

---

### Epica 6: Configuracion Avanzada (ATLAS-055, ATLAS-056)

**Goal:** Dashboards y reglas personalizadas
**Story Points Total:** 8 pts
**Sprint:** Backlog (Post-MVP)
**Priority:** Could Have

---

#### ATLAS-055: Analysis Dashboard API

**Story Points:** 3
**Priority:** Could Have (RICE: 11)
**Sprint:** Backlog

**As a** team lead
**I want** un API para consultar metricas de analisis
**So that** pueda monitorear la calidad del codigo del equipo

**Acceptance Criteria:**

**AC1: Endpoint de metricas**
- Given el API de Platform
- When se consulta GET /api/analytics/pr-analysis
- Then se obtienen metricas agregadas por repo/periodo

**AC2: Filtros temporales**
- Given el endpoint de metricas
- When se especifica date range
- Then se filtran los resultados

**Technical Notes:**
- Implementar en Platform API (.NET)
- Usar Entity Framework para queries agregadas

**Definition of Done:**
- [ ] Endpoints de analytics
- [ ] Filtros funcionales
- [ ] Tests

**Dependencies:** ATLAS-052

---

#### ATLAS-056: Custom Rules Configuration

**Story Points:** 5
**Priority:** Could Have (RICE: 4)
**Sprint:** Backlog

**As a** tech lead
**I want** configurar reglas personalizadas por repositorio
**So that** el analisis se adapte a nuestras convenciones

**Acceptance Criteria:**

**AC1: Archivo de configuracion**
- Given un archivo .atlasops.yml en el repo
- When se ejecuta el analisis
- Then se respetan las reglas configuradas

**AC2: Override de severidades**
- Given configuracion personalizada
- When especifica severity overrides
- Then se ajustan las severidades de findings

**Technical Notes:**
```yaml
# .atlasops.yml
version: 1
analyzers:
  dotnet:
    enabled: true
    rules:
      nullable-reference: warning  # Override default severity
      async-void: ignore  # Disable this rule
  typescript:
    enabled: true
    react: true  # Enable React-specific rules
  generic:
    max-complexity: 15  # Custom threshold
```

**Definition of Done:**
- [ ] Parser de configuracion
- [ ] Override de severidades
- [ ] Disable de reglas
- [ ] Documentacion

**Dependencies:** ATLAS-044

---

## MVP Definition (Must Have)

**MVP Scope:**

| ID | Story | Points | Epic |
|----|-------|--------|------|
| ATLAS-043 | GitHub Webhook Handler | 3 | Webhook & GitHub |
| ATLAS-054 | Webhook Signature Validation | 1 | Webhook & GitHub |
| ATLAS-051 | GitHub Comment Poster | 2 | Webhook & GitHub |
| ATLAS-044 | Domain Detection Engine | 5 | Domain Detection |
| ATLAS-045 | Generic Code Analyzer | 3 | Analyzers |
| ATLAS-046 | .NET Analyzer Agent | 5 | Analyzers |
| ATLAS-047 | Python Analyzer Agent | 5 | Analyzers |
| ATLAS-048 | TypeScript Analyzer Agent | 5 | Analyzers |
| ATLAS-049 | Parallel Execution Engine | 5 | Orchestration |
| ATLAS-050 | Result Consolidator | 3 | Orchestration |

**Total MVP:** 37 Story Points

**Estimacion de tiempo:**
- Asumiendo 8-10 pts/sprint por developer
- MVP completable en ~4 sprints (2 semanas)

---

## Sprint Planning Sugerido

### Sprint 5 (Dias 1-5)
- ATLAS-043: GitHub Webhook Handler (3 pts)
- ATLAS-054: Webhook Signature Validation (1 pt)
- ATLAS-044: Domain Detection Engine (5 pts)
- ATLAS-045: Generic Code Analyzer (3 pts)
- **Total:** 12 pts

### Sprint 6 (Dias 6-10)
- ATLAS-046: .NET Analyzer Agent (5 pts)
- ATLAS-047: Python Analyzer Agent (5 pts)
- **Total:** 10 pts

### Sprint 7 (Dias 11-15)
- ATLAS-048: TypeScript Analyzer Agent (5 pts)
- ATLAS-049: Parallel Execution Engine (5 pts)
- **Total:** 10 pts

### Sprint 8 (Dias 16-18)
- ATLAS-050: Result Consolidator (3 pts)
- ATLAS-051: GitHub Comment Poster (2 pts)
- **Total:** 5 pts

---

## Definition of Done (Global)

Todas las historias deben cumplir:

- [ ] Codigo implementado y funcionando
- [ ] Unit tests escritos (>70% coverage)
- [ ] Integration tests para flujos criticos
- [ ] Code review aprobado
- [ ] Documentacion actualizada
- [ ] Sin errores de linting
- [ ] Desplegable en ambiente de desarrollo

---

## ID Registry (Evitar Colisiones)

| ID | Descripcion | Status | Sprint |
|----|-------------|--------|--------|
| ATLAS-043 | GitHub Webhook Handler | Pending | S5 |
| ATLAS-044 | Domain Detection Engine | Pending | S5 |
| ATLAS-045 | Generic Code Analyzer | Pending | S5 |
| ATLAS-046 | .NET Analyzer Agent | Pending | S6 |
| ATLAS-047 | Python Analyzer Agent | Pending | S6 |
| ATLAS-048 | TypeScript Analyzer Agent | Pending | S7 |
| ATLAS-049 | Parallel Execution Engine | Pending | S7 |
| ATLAS-050 | Result Consolidator | Pending | S8 |
| ATLAS-051 | GitHub Comment Poster | Pending | S8 |
| ATLAS-052 | PR Analysis Persistence | Pending | Backlog |
| ATLAS-053 | Rate Limiting & Throttling | Pending | Backlog |
| ATLAS-054 | Webhook Signature Validation | Pending | S5 |
| ATLAS-055 | Analysis Dashboard API | Pending | Backlog |
| ATLAS-056 | Custom Rules Configuration | Pending | Backlog |

**Proximo ID disponible:** ATLAS-057

---

## Diagrama de Arquitectura

```
                     GitHub
                        │
                        ▼ Webhook (PR created/updated)
┌───────────────────────────────────────────────────────────────┐
│                    ORCHESTRATOR (TypeScript)                   │
│                                                                │
│  POST /webhooks/github ──► Validate Signature                 │
│         │                                                      │
│         ▼                                                      │
│  Extract PR Files ──► GitHub API                              │
│         │                                                      │
│         ▼                                                      │
│  Send to Agent Service                                         │
└────────────────────────────┬──────────────────────────────────┘
                             │
                             ▼
┌───────────────────────────────────────────────────────────────┐
│                    AGENT SERVICE (Python)                      │
│                                                                │
│  ┌─────────────────┐                                          │
│  │ Domain Detector │ ──► Group files by domain                │
│  └────────┬────────┘                                          │
│           │                                                    │
│           ▼                                                    │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │              PARALLEL EXECUTOR                           │  │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐   │  │
│  │  │  .NET    │ │  Python  │ │   TS     │ │ Generic  │   │  │
│  │  │ Analyzer │ │ Analyzer │ │ Analyzer │ │ Analyzer │   │  │
│  │  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘   │  │
│  │       │            │            │            │          │  │
│  │       └────────────┴────────────┴────────────┘          │  │
│  │                        │                                 │  │
│  │                        ▼                                 │  │
│  │              ┌─────────────────┐                        │  │
│  │              │   Consolidator   │                        │  │
│  │              └────────┬────────┘                        │  │
│  └───────────────────────┼─────────────────────────────────┘  │
│                          │                                     │
└──────────────────────────┼─────────────────────────────────────┘
                           │
                           ▼
┌───────────────────────────────────────────────────────────────┐
│                  ORCHESTRATOR (Response)                       │
│                                                                │
│  Post Comment to GitHub ◄── Markdown Report                   │
│         │                                                      │
│         ▼                                                      │
│  [Optional] Save to Platform API                              │
└───────────────────────────────────────────────────────────────┘
```

---

## Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigacion |
|--------|--------------|---------|------------|
| Rate limit de Claude API | Media | Alto | Implementar throttling, cache de respuestas similares |
| PRs muy grandes (>100 archivos) | Baja | Medio | Limitar a 50 archivos, procesar en batches |
| Falsos positivos en deteccion | Media | Medio | Permitir feedback y ajustar prompts |
| Latencia alta en analisis | Media | Alto | Timeouts, procesamiento paralelo, respuesta parcial |
| GitHub API rate limits | Baja | Medio | Usar GitHub App con mayor limite, cache |

---

## Metricas de Exito

| Metrica | Target | Como Medir |
|---------|--------|------------|
| Tiempo de analisis (p95) | <30s | Logs de duracion |
| Precision de deteccion | >95% | Feedback manual |
| Cobertura de dominios | 4/4 | Analisis de PRs procesados |
| Uptime del servicio | >99% | Health checks |
| Issues criticos detectados | >80% | Comparar con review manual |

---

**Documento creado por:** Product Owner Agent
**Fecha:** 2026-01-26
**Version:** 1.0
**Proximo review:** Al completar Sprint 5
