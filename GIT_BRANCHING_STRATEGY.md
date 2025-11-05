# Estrategia de Branching Git - ERP Multinacional

**Versión:** 1.0
**Fecha:** 2025-10-11
**Proyecto:** Sistema ERP Multinacional
**Estrategia Base:** Git Flow Adaptado

---

## 🌳 Estructura de Ramas

### Ramas Principales (Permanentes)

#### `main` (o `master`)
- **Propósito:** Código en producción
- **Protección:** ALTA - Requiere Pull Request + Aprobación
- **Deploy:** Automático a producción (con approval manual)
- **Tags:** Cada merge recibe un tag semántico (v1.0.0, v1.1.0, etc.)
- **Regla:** SOLO recibe merges de ramas `release/`
- **Estado:** SIEMPRE estable y deployable

#### `develop`
- **Propósito:** Rama de integración para próximo release
- **Protección:** MEDIA - Requiere Pull Request + Tests passing
- **Deploy:** Automático a staging
- **Regla:** Recibe merges de:
  - Ramas `US-XXX-*` (User Stories completadas)
  - Ramas `bugfix/*` (bugs en develop)
  - Ramas `hotfix/*` (después de mergear a main)
- **Estado:** Estable, con features en desarrollo integradas

---

## 🔀 Ramas de Trabajo (Temporales)

### 1. Ramas de User Story: `US-XXX-descripcion-corta`

**Formato:** `US-{número}-{descripción-kebab-case}`

**Ejemplos:**
- `US-001-multi-tenancy-context`
- `US-002-database-multi-tenant`
- `US-003-api-rest-swagger`
- `US-007-currency-api`

**Workflow:**
```bash
# 1. Crear rama desde develop
git checkout develop
git pull origin develop
git checkout -b US-003-api-rest-swagger

# 2. Trabajar en la US (commits frecuentes)
git add .
git commit -m "feat: agregar API versioning"
git commit -m "feat: configurar FluentValidation"
git commit -m "test: agregar tests de validación"

# 3. Al terminar, push y crear Pull Request a develop
git push origin US-003-api-rest-swagger
# Crear PR en GitHub: US-003-api-rest-swagger → develop

# 4. Después de aprobación y merge, eliminar rama local
git checkout develop
git pull origin develop
git branch -d US-003-api-rest-swagger
```

**Criterios de Merge a `develop`:**
- ✅ Todos los Acceptance Criteria cumplidos
- ✅ Definition of Done completado
- ✅ Tests pasando (>90% coverage)
- ✅ Code review aprobado
- ✅ CI/CD pipeline green
- ✅ No merge conflicts

---

### 2. Ramas de Épica: `epic/nombre-epica`

**Formato:** `epic/{nombre-epica-kebab-case}`

**Ejemplos:**
- `epic/multi-tenancy-foundation`
- `epic/inventory-management`
- `epic/tax-engines`

**Cuándo usar:**
- Cuando una épica es muy grande (5+ User Stories)
- Cuando necesitas integración entre múltiples US antes de mergear a develop
- Para features experimentales que necesitan validación antes de develop

**Workflow:**
```bash
# 1. Crear rama de épica desde develop
git checkout develop
git checkout -b epic/inventory-management

# 2. Crear US desde la rama de épica
git checkout -b US-004-estructura-regional
# ... trabajar en US-004 ...
git push origin US-004-estructura-regional
# PR: US-004-estructura-regional → epic/inventory-management

# 3. Continuar con más US en la misma épica
git checkout epic/inventory-management
git checkout -b US-005-catalogo-productos
# ... trabajar ...
# PR: US-005-catalogo-productos → epic/inventory-management

# 4. Al completar toda la épica, mergear a develop
# PR: epic/inventory-management → develop
```

**Criterios de Merge a `develop`:**
- ✅ Todas las US de la épica completadas
- ✅ Tests de integración entre US pasando
- ✅ Epic Definition of Done cumplido
- ✅ Demo aprobada por Product Owner

---

### 3. Ramas de Release: `release/vX.Y.Z`

**Formato:** `release/v{major}.{minor}.{patch}`

**Ejemplos:**
- `release/v1.0.0` - Primera release (Sprint 1-2)
- `release/v1.1.0` - Segunda release (Sprint 3-4)
- `release/v2.0.0` - Release con breaking changes

**Cuándo crear:**
- Al finalizar un Sprint o conjunto de Sprints
- Al completar una o más épicas
- Cuando `develop` está listo para producción

**Workflow:**
```bash
# 1. Crear release desde develop
git checkout develop
git pull origin develop
git checkout -b release/v1.0.0

# 2. En release: SOLO bugfixes, ajustes de versión, docs
# NO nuevas features
git commit -m "chore: bump version to 1.0.0"
git commit -m "fix: corregir bug en currency conversion"
git commit -m "docs: actualizar CHANGELOG"

# 3. Mergear a main (producción)
git checkout main
git merge --no-ff release/v1.0.0
git tag -a v1.0.0 -m "Release 1.0.0 - Multi-tenancy MVP"
git push origin main --tags

# 4. Mergear de vuelta a develop (para incluir bugfixes)
git checkout develop
git merge --no-ff release/v1.0.0
git push origin develop

# 5. Eliminar rama de release
git branch -d release/v1.0.0
git push origin --delete release/v1.0.0
```

**Contenido de Release:**
- CHANGELOG actualizado
- Version bump en archivos de configuración
- Documentation completa
- Bugfixes encontrados durante testing de release
- NO nuevas features

---

### 4. Ramas de Hotfix: `hotfix/descripcion`

**Formato:** `hotfix/{descripcion-kebab-case}`

**Ejemplos:**
- `hotfix/critical-currency-bug`
- `hotfix/afip-authentication-error`

**Cuándo usar:**
- Bug crítico en producción que no puede esperar
- Security vulnerability
- Data corruption risk

**Workflow:**
```bash
# 1. Crear desde main (producción)
git checkout main
git pull origin main
git checkout -b hotfix/critical-currency-bug

# 2. Fix rápido y tests
git commit -m "fix: corregir conversión ARS->USD"
git commit -m "test: agregar regression test"

# 3. Mergear a main
git checkout main
git merge --no-ff hotfix/critical-currency-bug
git tag -a v1.0.1 -m "Hotfix: Currency conversion bug"
git push origin main --tags

# 4. Mergear a develop
git checkout develop
git merge --no-ff hotfix/critical-currency-bug
git push origin develop

# 5. Eliminar rama
git branch -d hotfix/critical-currency-bug
```

---

### 5. Ramas de Bugfix: `bugfix/descripcion`

**Formato:** `bugfix/{descripcion-kebab-case}`

**Ejemplos:**
- `bugfix/validation-error-factura`
- `bugfix/stock-negative-values`

**Cuándo usar:**
- Bugs encontrados en `develop` (no en producción)
- Durante testing de Sprint

**Workflow:**
```bash
# 1. Crear desde develop
git checkout develop
git checkout -b bugfix/validation-error-factura

# 2. Fix y tests
git commit -m "fix: agregar validación de monto en factura"
git commit -m "test: agregar test de validación"

# 3. PR a develop
git push origin bugfix/validation-error-factura
# PR: bugfix/validation-error-factura → develop
```

---

## 📋 Convenciones de Commits

### Formato Conventional Commits

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

- **feat:** Nueva funcionalidad (US, feature)
- **fix:** Bug fix
- **docs:** Solo cambios en documentación
- **style:** Cambios de formato (no afectan código)
- **refactor:** Refactoring (ni feat ni fix)
- **test:** Agregar o modificar tests
- **chore:** Mantenimiento, configuración, build

### Scopes (Ejemplos para este proyecto)

- `multi-tenancy`
- `currency`
- `inventory`
- `sales`
- `purchases`
- `accounting`
- `tax-engine`
- `api`
- `database`
- `ci-cd`

### Ejemplos

```bash
# Feature
git commit -m "feat(currency): agregar ExchangeRateService con fallback"

# Bug fix
git commit -m "fix(tax-engine): corregir cálculo de IVA Argentina"

# Tests
git commit -m "test(multi-tenancy): agregar tests de tenant isolation"

# Docs
git commit -m "docs(api): actualizar Swagger con ejemplos de currency"

# Breaking change
git commit -m "feat(api)!: cambiar estructura de response para soportar multi-currency

BREAKING CHANGE: Response format ahora incluye campo 'currency'"
```

---

## 🔄 Workflow Completo de Implementación

### Escenario: Implementar US-003 (API REST con Swagger)

```bash
# ===================================
# FASE 1: SETUP
# ===================================

# 1. Asegurarse de estar en develop actualizado
git checkout develop
git pull origin develop

# 2. Crear rama de US
git checkout -b US-003-api-rest-swagger

# ===================================
# FASE 2: DESARROLLO
# ===================================

# 3. Implementar (con commits frecuentes)
# Crear TodoList para trackear tareas

# Task 1: API Versioning
# ... implementar ...
git add .
git commit -m "feat(api): agregar API versioning v1"

# Task 2: CORS
# ... implementar ...
git commit -m "feat(api): configurar CORS para multi-origin"

# Task 3: Result Pattern
# ... implementar ...
git commit -m "feat(api): implementar Result pattern para responses"

# Task 4: FluentValidation
# ... implementar ...
git commit -m "feat(api): configurar FluentValidation pipeline"

# Task 5: Error Handling Middleware
# ... implementar ...
git commit -m "feat(api): agregar global error handling middleware"

# Task 6: Controllers
# ... implementar ...
git commit -m "feat(api): agregar HealthController con endpoints"
git commit -m "feat(api): agregar TenantsController con CRUD"

# Task 7: Rate Limiting
# ... implementar ...
git commit -m "feat(api): configurar rate limiting por IP y tenant"

# Task 8: Swagger Improvements
# ... implementar ...
git commit -m "feat(api): mejorar Swagger con JWT y XML comments"

# Task 9: Tests
# ... implementar ...
git commit -m "test(api): agregar unit tests para controllers"
git commit -m "test(api): agregar integration tests para API"

# ===================================
# FASE 3: VALIDACIÓN
# ===================================

# 4. Ejecutar tests localmente
dotnet test
# Coverage >90% ✅

# 5. Ejecutar build
dotnet build
# Build exitoso ✅

# 6. Validar Definition of Done
# - [ ] Todos los Acceptance Criteria cumplidos ✅
# - [ ] Tests >90% coverage ✅
# - [ ] Code sin warnings ✅
# - [ ] Swagger actualizado ✅
# - [ ] Documentation actualizada ✅

# ===================================
# FASE 4: PULL REQUEST
# ===================================

# 7. Push de rama
git push origin US-003-api-rest-swagger

# 8. Crear Pull Request en GitHub
# Title: US-003: API REST Base con Swagger
# Description:
#   - Implementa API versioning (v1)
#   - CORS configurado
#   - Result pattern
#   - FluentValidation
#   - Error handling middleware
#   - HealthController y TenantsController
#   - Rate limiting
#   - Swagger mejorado con JWT
#
#   Acceptance Criteria: ✅ Todos cumplidos
#   Tests: 92% coverage
#
#   Closes #3

# Base: develop
# Compare: US-003-api-rest-swagger

# 9. Esperar aprobación
# - CI/CD pipeline ejecuta tests ✅
# - Code review por Tech Lead ✅
# - Aprobación ✅

# ===================================
# FASE 5: MERGE Y CLEANUP
# ===================================

# 10. Merge a develop (desde GitHub UI con "Squash and merge")
# O si es desde CLI:
git checkout develop
git merge --no-ff US-003-api-rest-swagger
git push origin develop

# 11. Eliminar rama local y remota
git branch -d US-003-api-rest-swagger
git push origin --delete US-003-api-rest-swagger

# 12. Actualizar develop local
git pull origin develop
```

---

## 🎯 Roadmap de Branches por Sprint

### Sprint 1 (Semanas 1-2)

```
develop
├── US-001-multi-tenancy-context → [MERGED]
├── US-002-database-multi-tenant → [MERGED]
├── US-003-api-rest-swagger → [IN PROGRESS]
└── US-007-currency-api → [TODO]

# Al final del Sprint 1
release/v0.1.0 → main (tag v0.1.0)
```

### Sprint 2 (Semanas 3-4)

```
develop
├── US-004-estructura-regional
├── US-005-catalogo-productos
├── US-006-stock-por-deposito
└── US-008-oc-multi-moneda

# Opción con épica
epic/inventory-management
├── US-004-estructura-regional → epic
├── US-005-catalogo-productos → epic
└── US-006-stock-por-deposito → epic
# Luego: epic/inventory-management → develop

# Al final del Sprint 2
release/v0.2.0 → main (tag v0.2.0)
```

### Sprint 3 (Semanas 5-6)

```
develop
├── US-011-tax-engine-factory
├── US-012-argentina-tax-engine
├── US-013-mexico-tax-engine
└── US-016-facturacion-multi-pais

# Con épica
epic/tax-engines
├── US-011-tax-engine-factory → epic
├── US-012-argentina-tax-engine → epic
├── US-013-mexico-tax-engine → epic
└── US-016-facturacion-multi-pais → epic
# Luego: epic/tax-engines → develop

# Al final del Sprint 3
release/v0.3.0 → main (tag v0.3.0)
```

---

## 🚨 Casos Especiales

### Caso 1: Bug Crítico en Producción (Hotfix)

```bash
# Producción tiene bug crítico en currency conversion
git checkout main
git checkout -b hotfix/currency-precision-bug
# ... fix ...
git commit -m "fix(currency): aumentar precisión a 6 decimales"

# Mergear a main
git checkout main
git merge --no-ff hotfix/currency-precision-bug
git tag -a v0.1.1 -m "Hotfix: Currency precision bug"
git push origin main --tags

# Mergear a develop
git checkout develop
git merge --no-ff hotfix/currency-precision-bug
git push origin develop

# Mergear a todas las ramas activas de US
git checkout US-007-currency-api
git merge develop
git push origin US-007-currency-api
```

### Caso 2: Conflictos durante Merge

```bash
# Al intentar mergear US a develop hay conflictos
git checkout develop
git merge US-003-api-rest-swagger
# CONFLICT!

# Resolver conflictos
git status  # Ver archivos en conflicto
# Editar archivos, resolver conflictos
git add .
git commit -m "merge: resolver conflictos US-003 con develop"
git push origin develop
```

### Caso 3: Rebase para actualizar US con develop

```bash
# US-003 lleva varios días, develop avanzó
git checkout US-003-api-rest-swagger
git fetch origin
git rebase origin/develop

# Si hay conflictos, resolver y continuar
git add .
git rebase --continue

git push origin US-003-api-rest-swagger --force-with-lease
```

---

## 📊 Branch Protection Rules (GitHub)

### `main`
```yaml
Protection Rules:
  - Require pull request before merging: ✅
  - Require approvals: 2
  - Dismiss stale reviews: ✅
  - Require review from Code Owners: ✅
  - Require status checks to pass: ✅
    - CI/CD Pipeline
    - Tests (>90% coverage)
    - SonarCloud Quality Gate
  - Require branches to be up to date: ✅
  - Require conversation resolution: ✅
  - Require signed commits: ✅ (opcional)
  - Include administrators: ❌ (admins bypass)
  - Restrict who can push: Tech Lead, DevOps
```

### `develop`
```yaml
Protection Rules:
  - Require pull request before merging: ✅
  - Require approvals: 1
  - Dismiss stale reviews: ✅
  - Require status checks to pass: ✅
    - CI/CD Pipeline
    - Tests (>85% coverage)
  - Require branches to be up to date: ✅
  - Require conversation resolution: ✅
  - Allow force pushes: ❌
```

---

## 🎯 Checklist antes de Merge

### Antes de PR de US → develop

- [ ] Todos los commits siguen Conventional Commits
- [ ] Rama actualizada con develop (rebase si es necesario)
- [ ] Tests pasando localmente (>90% coverage)
- [ ] Build sin warnings
- [ ] Definition of Done completado
- [ ] Documentation actualizada
- [ ] No hay console.logs o código de debug
- [ ] No hay TODOs críticos pendientes

### Antes de PR de develop → release

- [ ] Todas las US del Sprint mergeadas
- [ ] Tests de integración pasando
- [ ] Performance testing OK
- [ ] Security scan OK
- [ ] Demo aprobada por Product Owner
- [ ] CHANGELOG actualizado
- [ ] Version bump realizado

### Antes de PR de release → main

- [ ] Testing exhaustivo en staging
- [ ] QA approval
- [ ] Product Owner approval
- [ ] Documentation completa
- [ ] Rollback plan documentado
- [ ] Monitoring configurado
- [ ] Announcement preparado

---

## 📚 Referencias

- [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Flow](https://guides.github.com/introduction/flow/)
- [Trunk Based Development](https://trunkbaseddevelopment.com/)

---

**FIN DE ESTRATEGIA DE BRANCHING**

**Próximo paso:** Crear rama `US-003-api-rest-swagger` y comenzar implementación

---

**Autor:** Claude Code
**Versión:** 1.0
**Última actualización:** 2025-10-11
