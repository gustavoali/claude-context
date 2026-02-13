# Sprint N - Plan Formal

**Proyecto:** LinkedIn Transcript Extractor v0.10.0
**Sprint:** N (Sprint Actual)
**Duración:** 2026-01-18 → 2026-01-31 (10 días laborables)
**Team:** 1 Developer (Technical Lead)
**Metodología:** Scrum adaptado para solo developer

---

## 🎯 Sprint Goal

**"Eliminar deuda técnica crítica de duplicación, establecer fundamentos de testing, y validar el sistema de matching diferido v0.10.0 con datos reales para garantizar confiabilidad del producto"**

### Success Criteria

Al final del sprint, el proyecto debe tener:

1. ✅ **Duplicación de parsing eliminada** - Un solo punto de parseo VTT (ROI 10x)
2. ✅ **Tests automatizados básicos** - >40% coverage en archivos core
3. ✅ **Sistema de matching validado** - Precision >85% con dataset real
4. ✅ **0 errores de linting** - ESLint configurado y código limpio
5. ✅ **Build exitoso** - Extension funciona sin warnings

### Out of Scope

- ❌ Refactorización completa de background.js (Sprint N+1)
- ❌ Consolidación de scripts utility (Sprint N+2)
- ❌ CI/CD pipeline (Sprint N+2)
- ❌ Mejoras de algoritmo de matching (solo validar actual)

---

## 📅 Sprint Dates

| Milestone | Fecha | Descripción |
|-----------|-------|-------------|
| **Sprint Start** | 2026-01-18 (Sábado) | Sprint planning, setup |
| **Day 3 Checkpoint** | 2026-01-20 (Lunes) | LTE-001 completado |
| **Mid-Sprint Review** | 2026-01-23 (Jueves) | 50% stories done |
| **Day 8 Checkpoint** | 2026-01-28 (Martes) | Validación de matching |
| **Sprint End** | 2026-01-31 (Viernes) | Review + Retrospective |

---

## 📊 Capacity Planning

### Formula Base

```
Capacity (horas) = Team Days × Hours/Day × Efficiency × Availability
```

### Cálculo Detallado

```
Team Size:           1 developer
Sprint Duration:     10 días laborables (2 semanas)
Hours per Day:       6h efectivas (8h - 2h overhead)
                     Overhead breakdown:
                       - Meetings/email: 0.5h
                       - Breaks: 0.5h
                       - Context switching: 0.5h
                       - Admin tasks: 0.5h

Efficiency:          80% (0.80)
                     Factores:
                       - Imprevistos: -5%
                       - Interrupciones: -5%
                       - Debugging: -5%
                       - Learning curve: -5%

Availability:        98% (0.98)
                     Factores:
                       - Sick days estimado: 2%
                       - No vacaciones este sprint

Raw Capacity:
  = 1 × 10 × 6 × 0.80 × 0.98
  = 47.04 horas ≈ 47h
```

### Conversión a Story Points

```
Historical velocity: No disponible (primer sprint formal)
Estimación inicial:  1 story point = 2 horas de trabajo

Story Points Capacity:
  = 47h / 2h per point
  = 23.5 story points

Commitment (80% de capacity para buffer):
  = 23.5 × 0.80
  = 18.8 ≈ 18 story points committed

Buffer Reserved (20%):
  = 23.5 - 18
  = 5.5 story points (~11h)
  Uso esperado del buffer:
    - Bugs urgentes
    - Documentación adicional
    - Code reviews
    - Investigación técnica
```

### Summary Table

| Métrica | Valor | Notas |
|---------|-------|-------|
| **Raw Capacity** | 47h | Capacity teórica total |
| **Story Points Total** | 23.5 pts | @ 2h/point |
| **Committed** | 18 pts | 80% commitment |
| **Buffer** | 5.5 pts | 20% reserved |
| **Risk Level** | 🟢 LOW | Commitment conservador |

---

## 📋 Selected Stories - Committed

### LTE-001: Eliminar Duplicación de Parsing VTT

**Priority:** CRITICAL (ROI 10x)
**Story Points:** 3
**Estimated Hours:** 6h
**Owner:** Developer (TL)
**Dependencies:** None

#### User Story

**As a** developer
**I want** una única implementación de parsing VTT
**So that** los bugs se arreglan en un solo lugar y el comportamiento es consistente

#### Acceptance Criteria

**AC1: Parser unificado funcional**
- Given un archivo VTT válido
- When es parseado por el parser unificado
- Then devuelve estructura normalizada con segments array
- And cada segment tiene `start`, `end`, `text` válidos

**AC2: Migración de background.js**
- Given background.js tiene lógica de parsing VTT
- When se migra a usar `parseVTT()` de vtt-parser.js
- Then background.js NO contiene lógica de parsing duplicada
- And todos los tests de background pasan

**AC3: Migración de content.js**
- Given content.js tiene lógica de detección de VTT
- When se refactoriza para usar helpers compartidos
- Then content.js NO duplica detección de patterns
- And la detección sigue funcionando correctamente

**AC4: Tests comprueban no-duplicación**
- Given el código base refactorizado
- When se ejecutan tests de regresión
- Then todos los flows de parsing funcionan
- And no hay código VTT-parsing duplicado detectable

#### Task Breakdown

| Task ID | Descripción | Estimado | Owner |
|---------|-------------|----------|-------|
| T-001-1 | Auditar duplicación actual (grep, análisis) | 1h | Dev |
| T-001-2 | Crear `shared-utils.js` con parsing unificado | 2h | Dev |
| T-001-3 | Refactorizar background.js imports | 1h | Dev |
| T-001-4 | Refactorizar content.js imports | 1h | Dev |
| T-001-5 | Tests unitarios del parser | 1h | Dev |
| **Total** | | **6h** | |

#### Testing Strategy

- **Unit tests:** `parseVTT()`, `parseLinkedInLearningUrl()`, `extractKeywords()`
- **Integration test:** background.js + content.js usando shared utils
- **Manual test:** Extension funciona en video real de LinkedIn Learning

#### Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Romper detección de VTT | Medium | High | Tests exhaustivos antes de merge |
| Performance regression | Low | Medium | Benchmark parsing antes/después |

---

### LTE-002: Setup Test Infrastructure (Subset)

**Priority:** HIGH
**Story Points:** 5
**Estimated Hours:** 10h
**Owner:** Developer (TL)
**Dependencies:** None

#### User Story

**As a** developer
**I want** tests automatizados para componentes core
**So that** los cambios futuros no rompan funcionalidad existente

**Nota:** Esta historia es un SUBSET de LTE-002 completa (13 pts). En Sprint N solo setup + tests críticos. Resto en Sprint N+1.

#### Acceptance Criteria (Sprint N Subset)

**AC1: Test infrastructure configurada**
- Given el proyecto actual sin tests
- When se configura Jest + Chrome Extension testing utilities
- Then `npm test` ejecuta suite de tests
- And coverage report es generado automáticamente

**AC2: VTT Parser tests (>80% coverage)**
- Given vtt-parser.js y shared-utils.js
- When se ejecutan tests
- Then cubre: parsing exitoso, VTT inválido, timestamps incorrectos, caracteres especiales
- And coverage >80%

**AC3: Smoke tests básicos para background.js**
- Given funciones críticas de background.js
- When se ejecutan smoke tests
- Then cubre: VTT detection patterns, language filtering (español)
- And mocks de chrome.webRequest funcionan

**AC4: CI-ready configuration**
- Given configuración de tests
- When se documenta setup
- Then README incluye instrucciones de testing
- And package.json tiene scripts claros (test, test:watch, test:coverage)

#### Task Breakdown

| Task ID | Descripción | Estimado | Owner |
|---------|-------------|----------|-------|
| T-002-1 | Investigar Jest + chrome extension mocks | 1h | Dev |
| T-002-2 | Configurar Jest (jest.config.js, package.json) | 1h | Dev |
| T-002-3 | Setup jest-chrome (mocks de chrome.* APIs) | 1h | Dev |
| T-002-4 | Tests para vtt-parser.js (10 test cases) | 2h | Dev |
| T-002-5 | Tests para shared-utils.js | 2h | Dev |
| T-002-6 | Smoke tests background.js (detección VTT) | 2h | Dev |
| T-002-7 | Documentar testing en README | 1h | Dev |
| **Total** | | **10h** | |

#### Testing Strategy

**Test Cases Prioritarios:**

1. **VTT Parser:**
   - Valid VTT parsing
   - Invalid format handling
   - Empty VTT file
   - Malformed timestamps
   - Special characters (UTF-8)
   - Large VTT (1000+ segments)

2. **Shared Utils:**
   - `parseLinkedInLearningUrl()` - valid URLs
   - `parseLinkedInLearningUrl()` - malformed URLs
   - `extractKeywords()` - Spanish text
   - `extractKeywords()` - English text

3. **Background.js Smoke:**
   - VTT pattern detection (LinkedIn Learning URLs)
   - Spanish language filtering
   - chrome.webRequest mock

#### Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Jest incompatible con Manifest v3 | Low | High | Research primero (Task T-002-1) |
| Mocks de chrome.* complejos | Medium | Medium | Usar jest-chrome (battle-tested) |
| Tests toman mucho tiempo | Low | Low | Subset mínimo este sprint |

---

### LTE-020: Validar Sistema de Matching Diferido (NUEVO - CRÍTICO)

**Priority:** CRITICAL
**Story Points:** 8
**Estimated Hours:** 16h
**Owner:** Developer (TL)
**Dependencies:** Sistema de matching v0.10.0 existente

**Contexto Crítico:**
El análisis arquitectónico reveló que el sistema de matching semántico v0.10.0 **nunca fue validado con datos reales**. Esto es un riesgo crítico para la confiabilidad del producto.

#### User Story

**As a** Technical Lead
**I want** validar el sistema de matching diferido con datos reales
**So that** conozco la precision/recall real y puedo confiar en el sistema en producción

#### Acceptance Criteria

**AC1: Dataset de validación creado**
- Given un curso de LinkedIn Learning conocido (50+ videos)
- When se ejecuta crawler completo
- Then se capturan VTTs y contexts separadamente
- And se guardan en `test-data/validation-dataset/`
- And dataset incluye metadata real (titles, slugs)

**AC2: Matching ejecutado y medido**
- Given dataset de validación
- When se ejecuta match-transcripts.js
- Then se calculan métricas:
  - Semantic match rate (% matched por semántica vs orden)
  - Precision (matches correctos / total matches)
  - Recall (videos matched / videos totales)
  - Average semantic score
- And métricas se guardan en JSON

**AC3: Validación manual completada**
- Given matches generados
- When se valida muestra aleatoria de 30 matches
- Then se marca cada match como: CORRECT / INCORRECT / UNCERTAIN
- And se calcula precision real
- And errores se documentan con análisis de causa raíz

**AC4: Reporte de validación documentado**
- Given métricas calculadas y validación manual
- When se genera reporte
- Then reporte incluye:
  - Dataset usado (curso, # videos)
  - Métricas cuantitativas
  - Ejemplos de matches correctos/incorrectos
  - Análisis de threshold 0.3
  - Recomendaciones (mantener, ajustar, rediseñar)
- And reporte guardado en `docs/VALIDATION_REPORT_v0.10.0.md`

#### Task Breakdown

| Task ID | Descripción | Estimado | Owner |
|---------|-------------|----------|-------|
| T-020-1 | Seleccionar curso para validación (50+ videos) | 0.5h | Dev |
| T-020-2 | Crawl completo del curso (capturar VTTs + contexts) | 2h | Dev |
| T-020-3 | Verificar calidad del dataset (completeness check) | 1h | Dev |
| T-020-4 | Ejecutar match-transcripts.js con dataset | 1h | Dev |
| T-020-5 | Implementar cálculo de métricas (script) | 3h | Dev |
| T-020-6 | Validación manual de muestra (30 matches) | 3h | Dev |
| T-020-7 | Análisis de errores y causa raíz | 2h | Dev |
| T-020-8 | Generar reporte de validación formal | 2h | Dev |
| T-020-9 | Documentar findings y recomendaciones | 1.5h | Dev |
| **Total** | | **16h** | |

#### Testing Strategy

**Criterios de Éxito de Validación:**

| Métrica | Target Mínimo | Target Ideal |
|---------|---------------|--------------|
| **Precision** | >85% | >90% |
| **Recall** | >90% | >95% |
| **Semantic Match Rate** | >60% | >70% |
| **Avg Semantic Score** (semantic matches) | >0.4 | >0.5 |

**Acciones según resultados:**

- ✅ **Precision >90% && Recall >95%**: Sistema aprobado, documentar y continuar
- ⚠️ **Precision 85-90% || Recall 90-95%**: Sistema aceptable, ajustar threshold en Sprint N+1
- 🔴 **Precision <85% || Recall <90%**: Sistema necesita rediseño (planear Epic urgente)

#### Dataset Selection Criteria

**Curso ideal para validación:**
- ✅ 50-100 videos (suficiente estadística, no excesivo)
- ✅ Títulos descriptivos (facilita matching semántico)
- ✅ Un solo idioma (español preferido)
- ✅ Completado recientemente (datos frescos)
- ✅ Domain técnico (keywords ricos)

**Candidatos:**
1. "Fundamentos de Python" (~80 videos)
2. "JavaScript Esencial" (~60 videos)
3. "Fundamentos de AWS" (~70 videos)

#### Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Dataset incompleto (missing VTTs) | Medium | High | Verificar completeness antes de validación |
| Precision <85% (sistema falla) | Medium | CRITICAL | Preparar plan de rediseño (Epic urgente) |
| Validación manual sesgada | Low | Medium | Sample aleatorio, criterios objetivos |
| Crawler falla mid-process | Low | Medium | Checkpoint save cada 10 videos |

---

### LTE-021: Configurar ESLint y Limpiar Código (NUEVO)

**Priority:** MEDIUM
**Story Points:** 2
**Estimated Hours:** 4h
**Owner:** Developer (TL)
**Dependencies:** None

#### User Story

**As a** developer
**I want** ESLint configurado y código limpio
**So that** el código sigue estándares consistentes y se previenen bugs comunes

#### Acceptance Criteria

**AC1: ESLint configurado**
- Given proyecto sin linting
- When se configura ESLint
- Then `.eslintrc.json` tiene reglas para Chrome Extension
- And `npm run lint` ejecuta linting
- And `npm run lint:fix` auto-corrige issues

**AC2: Código sin errores críticos**
- Given código actual con warnings/errors
- When se ejecuta `npm run lint`
- Then 0 errors
- And warnings <10 (aceptables, documentados)

**AC3: Pre-commit hook opcional**
- Given ESLint configurado
- When se documenta uso con husky (futuro)
- Then README incluye instrucciones
- And package.json tiene scripts preparados

**AC4: VSCode integration**
- Given `.vscode/settings.json`
- When developer abre proyecto
- Then ESLint auto-formatea on save
- And problems panel muestra linting issues

#### Task Breakdown

| Task ID | Descripción | Estimado | Owner |
|---------|-------------|----------|-------|
| T-021-1 | Configurar ESLint (plugin chrome extension) | 1h | Dev |
| T-021-2 | Run lint, fix auto-fixable issues | 1.5h | Dev |
| T-021-3 | Review manual warnings, fix críticos | 1h | Dev |
| T-021-4 | Documentar linting en README | 0.5h | Dev |
| **Total** | | **4h** | |

#### Testing Strategy

- **Manual:** Verificar código formateado correctamente
- **Automated:** `npm run lint` pasa sin errors

---

## 📊 Sprint Commitment Summary

| Story ID | Title | Priority | Points | Hours | Status |
|----------|-------|----------|--------|-------|--------|
| LTE-001 | Eliminar Duplicación Parsing | CRITICAL | 3 | 6h | Committed |
| LTE-002 | Setup Test Infrastructure (Subset) | HIGH | 5 | 10h | Committed |
| LTE-020 | Validar Sistema de Matching | CRITICAL | 8 | 16h | Committed |
| LTE-021 | Configurar ESLint | MEDIUM | 2 | 4h | Committed |
| **Total Committed** | | | **18 pts** | **36h** | |
| **Buffer Reserved** | | | **5.5 pts** | **11h** | |
| **Total Capacity** | | | **23.5 pts** | **47h** | |

### Commitment Analysis

```
Committed:  18 pts (36h) = 76.6% de capacity
Buffer:     5.5 pts (11h) = 23.4% de capacity

Risk Level: 🟢 LOW (commitment conservador)
Confidence: HIGH (historias bien definidas)
```

---

## 🗓️ Daily Milestones - Gantt Timeline

```
Week 1 (2026-01-18 → 2026-01-24)
─────────────────────────────────────────────────────────────
Day 1 (Sáb)  │ ██████ Sprint Planning + Setup (LTE-021 start)
Day 2 (Dom)  │ ██████ LTE-021 (ESLint) complete
Day 3 (Lun)  │ ███████████ LTE-001 (Duplicación) complete ← Checkpoint
Day 4 (Mar)  │ ████████ LTE-002 (Tests) - config + parser tests
Day 5 (Mié)  │ ████████ LTE-002 (Tests) - shared-utils + smoke tests
Day 6 (Jue)  │ ███████ LTE-002 complete + docs ← Mid-Sprint Review
Day 7 (Vie)  │ ████████ LTE-020 (Validación) - dataset creation

Week 2 (2026-01-25 → 2026-01-31)
─────────────────────────────────────────────────────────────
Day 8 (Sáb)  │ ████████ LTE-020 - matching execution + metrics
Day 9 (Dom)  │ ████████████ LTE-020 - validación manual ← Checkpoint
Day 10 (Lun) │ ████████ LTE-020 - análisis + reporte
Day 11 (Mar) │ ██████ LTE-020 complete + buffer work
Day 12 (Mié) │ ████ Buffer: Documentation updates
Day 13 (Jue) │ ████ Buffer: Code reviews, polish
Day 14 (Vie) │ ██████ Sprint Review + Retrospective ← Sprint End

Legend:
  ██ = Work hours (2h blocks)
  ← = Key checkpoint/milestone
```

### Day-by-Day Deliverables

| Day | Date | Expected Deliverables | Hours |
|-----|------|----------------------|-------|
| **Day 1** | 2026-01-18 | Sprint planning done, ESLint configured | 6h |
| **Day 2** | 2026-01-19 | ESLint complete, code cleaned | 4h |
| **Day 3** | 2026-01-20 | ✅ LTE-001 DONE - Parsing unificado | 6h |
| **Day 4** | 2026-01-21 | Jest setup, VTT parser tests passing | 5h |
| **Day 5** | 2026-01-22 | Shared-utils tests, background smoke tests | 5h |
| **Day 6** | 2026-01-23 | ✅ LTE-002 DONE - Tests infrastructure ready | 4h |
| **Day 7** | 2026-01-24 | Validation dataset captured | 6h |
| **Day 8** | 2026-01-25 | Matching executed, metrics calculated | 5h |
| **Day 9** | 2026-01-26 | Manual validation of 30 matches done | 5h |
| **Day 10** | 2026-01-27 | Error analysis complete | 4h |
| **Day 11** | 2026-01-28 | ✅ LTE-020 DONE - Validation report ready | 2h |
| **Day 12** | 2026-01-29 | Buffer: README updates, CHANGELOG | 3h |
| **Day 13** | 2026-01-30 | Buffer: Code polish, final testing | 3h |
| **Day 14** | 2026-01-31 | Sprint review + retrospective | 2h |
| **Total** | | | **60h** (capacity 47h + weekend work) |

**Nota:** Timeline asume trabajo intenso weekend (días 1-2, 8-9) para maximizar throughput en sprint de 2 semanas.

---

## 🎯 Definition of Done - Sprint Level

Checklist que TODAS las historias deben cumplir:

### Código
- [ ] Implementación completa según AC
- [ ] Código sigue convenciones del proyecto
- [ ] ESLint pasa sin errores (warnings <10 aceptables)
- [ ] Sin warnings en console del browser (extension)
- [ ] Sin código comentado (cleanup realizado)

### Testing
- [ ] Unit tests escritos para funciones nuevas/modificadas
- [ ] Coverage >40% global (Sprint N target)
- [ ] Manual testing completado con evidencia (screenshots o logs)
- [ ] Regresión verificada (features existentes funcionan)
- [ ] Probado en Chrome version estable (latest)

### Documentación
- [ ] README actualizado si aplica (nuevos scripts, comandos)
- [ ] JSDoc comments en funciones públicas nuevas
- [ ] CHANGELOG.md actualizado con cambios
- [ ] User-facing changes documentados (si aplica)
- [ ] Comentarios complejos explicados en código

### Review
- [ ] Self-review completado (checklist usado)
- [ ] Code review aprobado (si hay reviewer externo)
- [ ] No deuda técnica introducida sin documentar en TD Register
- [ ] Refactorings justificados (no prematuros)

### Deployment
- [ ] Extension funciona en modo unpacked (local testing)
- [ ] Manifest version bumped (si release)
- [ ] Git commit siguiendo Conventional Commits
- [ ] Tag de git creado para milestone (si aplica)

### Story-Specific
- [ ] **LTE-001:** Duplicación verificada eliminada (grep search clean)
- [ ] **LTE-002:** `npm test` ejecuta tests sin errors
- [ ] **LTE-020:** Validation report completado y en `docs/`
- [ ] **LTE-021:** `npm run lint` pasa con 0 errors

---

## 🧪 Acceptance Criteria Validation Plan

### LTE-001: Eliminar Duplicación Parsing

**Validation Method:**

1. **Pre-refactor Audit:**
   ```bash
   grep -r "parseLinkedInLearningUrl" extension/ | wc -l
   # Expected: 2+ occurrences (duplicated)
   ```

2. **Post-refactor Verification:**
   ```bash
   grep -r "parseLinkedInLearningUrl" extension/ | wc -l
   # Expected: 1 occurrence (in shared-utils.js)

   grep -r "import.*parseLinkedInLearningUrl" extension/
   # Expected: 2 imports (background.js, content.js)
   ```

3. **Functional Testing:**
   - Load extension in Chrome
   - Navigate to LinkedIn Learning video
   - Verify VTT detected correctly
   - Check console for parsing errors (should be 0)

4. **Unit Tests:**
   ```bash
   npm test -- vtt-parser.test.js
   npm test -- shared-utils.test.js
   # Expected: All tests passing
   ```

**Pass Criteria:**
- Zero duplicated parsing functions detected
- All imports working
- Manual test successful
- Unit tests passing

---

### LTE-002: Setup Test Infrastructure

**Validation Method:**

1. **Configuration Check:**
   ```bash
   # Verify files exist
   ls jest.config.js
   ls __tests__/

   # Verify npm scripts
   npm run test
   npm run test:watch
   npm run test:coverage
   ```

2. **Coverage Report:**
   ```bash
   npm run test:coverage
   # Expected: Coverage report generated
   # Target: >40% overall, >80% vtt-parser.js
   ```

3. **Test Execution:**
   ```bash
   npm test
   # Expected: All tests passing
   # Expected: 15+ test cases executed
   ```

**Pass Criteria:**
- Jest configured correctly
- >15 test cases passing
- Coverage >40% overall
- Coverage >80% vtt-parser.js

---

### LTE-020: Validar Sistema de Matching

**Validation Method:**

1. **Dataset Completeness:**
   ```bash
   node scripts/check-dataset-completeness.js
   # Expected: 50+ videos captured
   # Expected: 50+ VTTs captured
   # Expected: 100% pairing possible
   ```

2. **Metrics Calculation:**
   ```bash
   node scripts/calculate-matching-metrics.js
   # Expected: JSON file with:
   # {
   #   precision: 0.XX,
   #   recall: 0.XX,
   #   semanticMatchRate: 0.XX,
   #   avgSemanticScore: 0.XX
   # }
   ```

3. **Manual Validation:**
   - Open `validation-results.json`
   - Random sample of 30 matches
   - Verify each: CORRECT / INCORRECT / UNCERTAIN
   - Document errors in `validation-errors.md`

4. **Report Review:**
   - Open `docs/VALIDATION_REPORT_v0.10.0.md`
   - Verify sections: Dataset, Metrics, Analysis, Recommendations
   - Verify includes examples of correct/incorrect matches

**Pass Criteria:**
- Dataset completo (50+ videos)
- Métricas calculadas
- Manual validation de 30 matches completada
- Reporte documentado con findings

**Decision Tree:**
```
IF Precision >= 90% AND Recall >= 95%:
  → Sistema APROBADO
  → Continuar con roadmap normal

ELIF Precision >= 85% OR Recall >= 90%:
  → Sistema ACEPTABLE con mejoras
  → Planear ajustes en Sprint N+1

ELSE:
  → Sistema NECESITA REDISEÑO
  → Crear Epic urgente "Mejorar Matching Algorithm"
  → Re-priorizar backlog
```

---

### LTE-021: Configurar ESLint

**Validation Method:**

1. **Configuration Check:**
   ```bash
   ls .eslintrc.json
   ls .vscode/settings.json

   npm run lint
   # Expected: Linting completes
   # Target: 0 errors, <10 warnings
   ```

2. **Auto-fix Verification:**
   ```bash
   npm run lint:fix
   # Expected: Fixable issues auto-corrected
   ```

3. **IDE Integration:**
   - Open extension/background.js in VSCode
   - Introduce syntax error
   - Verify red squiggle appears (ESLint working)
   - Save file
   - Verify auto-format happens

**Pass Criteria:**
- ESLint configured
- `npm run lint` exits with 0 errors
- Warnings <10 (documented as acceptable)
- VSCode integration working

---

## 🔗 Dependencies & Blockers

### Internal Dependencies

```
LTE-001 (Parsing)
  ↓
LTE-002 (Tests) - Necesita código limpio para testear
  ↓
LTE-020 (Validación) - Necesita sistema estable

LTE-021 (ESLint) - Independiente, puede paralelizarse
```

**Execution Order:**
1. Day 1-2: LTE-021 (independiente)
2. Day 3: LTE-001 (bloquea a LTE-002)
3. Day 4-6: LTE-002 (bloquea a LTE-020)
4. Day 7-11: LTE-020 (requiere sistema estable)

### External Dependencies

| Dependency | Type | Status | Risk | Mitigation |
|------------|------|--------|------|------------|
| LinkedIn Learning acceso | External | ✅ Active | LOW | Usar cuenta personal activa |
| Chrome browser (latest) | External | ✅ Available | LOW | Version estable instalada |
| Node.js 18+ | External | ✅ Installed | LOW | Version verificada |
| jest-chrome library | npm | ⚠️ Unknown | MEDIUM | Investigar compatibilidad (Task T-002-1) |

### Known Blockers

**NONE IDENTIFIED** - Sprint puede comenzar sin blockers.

**Potential Blockers:**
- 🟡 **jest-chrome incompatible con Manifest v3** (LOW probability)
  - Mitigation: Task T-002-1 investiga antes de implementar
  - Fallback: Usar manual mocks si jest-chrome no funciona

- 🟡 **Dataset de validación incompleto** (MEDIUM probability)
  - Mitigation: Task T-020-3 verifica completeness
  - Fallback: Usar curso alternativo si faltan >10% VTTs

---

## 🚨 Risk Assessment

### Top Risks del Sprint

| Risk ID | Descripción | Probability | Impact | Severity | Mitigation |
|---------|-------------|-------------|--------|----------|------------|
| **R-001** | Jest incompatible con Chrome Extension Manifest v3 | LOW | HIGH | 🟡 MEDIUM | Research primero (T-002-1), usar manual mocks fallback |
| **R-002** | Validación revela Precision <85% | MEDIUM | CRITICAL | 🔴 HIGH | Preparar plan de rediseño urgente, Epic alternativo |
| **R-003** | Refactor de parsing rompe detección VTT | MEDIUM | HIGH | 🟡 MEDIUM | Tests exhaustivos antes de merge, manual testing |
| **R-004** | Dataset incompleto (missing VTTs) | MEDIUM | MEDIUM | 🟡 MEDIUM | Verificar completeness (T-020-3), curso alternativo |
| **R-005** | Tiempo insuficiente para validación manual | LOW | MEDIUM | 🟢 LOW | Priorizar validación, reducir sample si necesario |

### Contingency Plans

#### Si R-001 ocurre (Jest incompatible):
```
Plan B:
1. Usar manual mocks para chrome.* APIs
2. Escribir wrapper functions para facilitar testing
3. Reducir scope de tests en Sprint N
4. Investigar alternativa (Mocha, Vitest) en Sprint N+1

Time impact: +4h
Story points impact: LTE-002 aumenta de 5 pts → 7 pts
Mitigation: Usar buffer de 5.5 pts
```

#### Si R-002 ocurre (Precision <85%):
```
Plan A (Sprint N):
1. Completar validación de todos modos
2. Documentar findings detalladamente
3. Analizar causa raíz de errores
4. Proponer mejoras (threshold tuning, algoritmo)

Plan B (Sprint N+1):
1. Crear Epic urgente "Mejorar Matching Algorithm"
2. Re-priorizar backlog (postponer Epic 2)
3. Dedicar Sprint N+1 completo a mejoras de matching
4. Opciones: Embeddings, ML model, heuristics mejoradas

Time impact: 0h en Sprint N (solo documentación)
Product impact: CRÍTICO - Puede requerir re-arquitectura
```

#### Si R-003 ocurre (Refactor rompe detección):
```
Rollback Plan:
1. Git revert del commit de refactor
2. Re-implementar con approach más conservador
3. Tests más exhaustivos antes de re-merge

Prevention:
1. Tests unitarios ANTES de refactor (TDD)
2. Manual testing inmediato post-refactor
3. Extension cargada en browser real durante desarrollo

Time impact: +2h (testing adicional)
```

#### Si R-004 ocurre (Dataset incompleto):
```
Plan B:
1. Seleccionar curso alternativo (backup list ready)
2. Re-crawl con timeouts más largos
3. Si persiste: Reducir dataset a 30 videos (mínimo estadístico)

Backup Courses:
  - "Fundamentos de Python" (80 videos)
  - "JavaScript Esencial" (60 videos)
  - "AWS Certified Developer" (70 videos)

Time impact: +2h (re-crawl)
```

---

## 📞 Communication Plan

### Daily Standups (Solo Developer)

**Formato:** Registro escrito en `SPRINT_LOG.md`

**Estructura:**
```markdown
## Day X - YYYY-MM-DD

### What I did yesterday:
- Task completed
- Progress on ongoing task

### What I'll do today:
- Planned tasks for today

### Blockers:
- [NONE] or [Description of blocker]

### Notes:
- Learnings, decisions, etc.
```

**Frequency:** Diario (al inicio del día)
**Time investment:** 5 min/día

---

### Mid-Sprint Review (Day 6 - 2026-01-23)

**Formato:** Self-review checkpoint

**Agenda:**
1. Review sprint progress (stories completed)
2. Velocity check (on track? behind? ahead?)
3. Risk assessment update
4. Adjust plan if needed (scope, priorities)

**Output:** Updated sprint plan if adjustments needed

**Time investment:** 30 min

---

### Sprint Review (Day 14 - 2026-01-31)

**Formato:** Demo + Retrospective

**Agenda:**
1. **Demo (30 min):**
   - LTE-001: Mostrar código sin duplicación
   - LTE-002: Ejecutar `npm test`, mostrar coverage
   - LTE-020: Presentar validation report, métricas
   - LTE-021: Mostrar `npm run lint` pasando

2. **Retrospective (30 min):**
   - What went well?
   - What could be improved?
   - Action items for Sprint N+1

3. **Metrics Review (15 min):**
   - Velocity actual vs estimado
   - Story completion rate
   - Time per story point (calibrar estimaciones)

**Output:**
- SPRINT_REVIEW_N.md
- Action items for Sprint N+1
- Updated velocity estimate

**Time investment:** 1.5h

---

### Ad-hoc Communication

**Blockers:** Documentar inmediatamente en `SPRINT_LOG.md`
**Decisions:** Documentar en `DECISIONS.md` con formato ADR
**Learnings:** Agregar a project memory (`.claude/CLAUDE.md`)

---

## 📊 Metrics & Tracking

### Metrics Dashboard (Track Daily)

| Métrica | Target | Medición | Frequency |
|---------|--------|----------|-----------|
| **Story Completion Rate** | 100% | Stories done / committed | Daily |
| **Velocity** | 18 pts | Actual pts delivered | End of sprint |
| **Test Coverage** | >40% | `npm run test:coverage` | Daily (after tests added) |
| **Linting Errors** | 0 | `npm run lint` | Daily (after ESLint setup) |
| **Validation Precision** | >85% | Manual validation | Day 9 |
| **Validation Recall** | >90% | Metrics calculation | Day 8 |
| **Time per Story Point** | 2h | Actual hours / pts delivered | End of sprint |
| **Buffer Usage** | <100% | Buffer hours used / 11h | End of sprint |

### Burndown Chart (Manual Tracking)

```
Story Points Remaining
24 │ ●
22 │  ╲
20 │   ●
18 │    ╲
16 │     ●
14 │      ╲
12 │       ●
10 │        ╲
 8 │         ●
 6 │          ╲
 4 │           ●
 2 │            ╲
 0 │_____________●_____________
   Day0 Day2 Day4 Day6 Day8 Day10 Day12 Day14

Legend:
  ● = Ideal burndown (linear)
  Actual = Track manually
```

**Tracking Method:**
- Update daily in `SPRINT_LOG.md`
- Plot manually or use simple spreadsheet

---

### Story Status Tracking

| Story ID | Status | Progress | Blocked? | Notes |
|----------|--------|----------|----------|-------|
| LTE-001 | Not Started | 0% | No | Start Day 3 |
| LTE-002 | Not Started | 0% | No | Start Day 4 |
| LTE-020 | Not Started | 0% | No | Start Day 7 |
| LTE-021 | Not Started | 0% | No | Start Day 1 |

**Update Frequency:** Daily
**Update Time:** Morning standup (5 min)

---

## ✅ Sprint Success Criteria - Final Checklist

Al final del Sprint N, verificar TODOS los items:

### Sprint Goal Achievement
- [ ] **Duplicación eliminada** - Grep search shows 0 duplicates
- [ ] **Tests funcionando** - `npm test` executes successfully
- [ ] **Coverage >40%** - Coverage report confirms
- [ ] **Matching validado** - Validation report completed
- [ ] **Linting clean** - `npm run lint` exits with 0 errors

### Story Completion
- [ ] **LTE-001 DONE** - All AC validated, DoD complete
- [ ] **LTE-002 DONE** - All AC validated, DoD complete
- [ ] **LTE-020 DONE** - All AC validated, DoD complete
- [ ] **LTE-021 DONE** - All AC validated, DoD complete

### Quality Gates
- [ ] **Build successful** - Extension loads without errors
- [ ] **Manual testing passed** - Tested in real LinkedIn Learning video
- [ ] **No regressions** - Existing features still work
- [ ] **Documentation updated** - README, CHANGELOG current

### Metrics Targets
- [ ] **Velocity:** 16-18 pts delivered (target 18 pts)
- [ ] **Story completion:** 100% (4/4 stories)
- [ ] **Test coverage:** >40% overall
- [ ] **Validation precision:** >85% (if not, action plan ready)
- [ ] **Buffer usage:** <100% (ideally 50-80%)

### Deliverables
- [ ] **Code:** All code merged to main branch
- [ ] **Tests:** Test suite in `/extension/__tests__/`
- [ ] **Validation Report:** `docs/VALIDATION_REPORT_v0.10.0.md`
- [ ] **Sprint Review:** `docs/SPRINT_REVIEW_N.md`
- [ ] **CHANGELOG:** Updated with Sprint N changes

### Process
- [ ] **Daily logs:** `SPRINT_LOG.md` complete
- [ ] **Retrospective:** Completed with action items
- [ ] **Sprint N+1 Planning:** Backlog ready for next sprint
- [ ] **Technical Debt:** TD Register updated

---

## 📚 References & Resources

### Project Documentation
- **Architecture Analysis:** `C:\claude_context\linkedin\ARCHITECTURE_ANALYSIS.md`
- **Product Backlog:** `C:\claude_context\linkedin\PRODUCT_BACKLOG.md`
- **README:** `C:\mcp\linkedin\README.md`
- **Specification:** `C:\mcp\linkedin\docs\SPECIFICATION.md`

### Testing Resources
- **Jest Documentation:** https://jestjs.io/
- **jest-chrome:** https://github.com/extend-chrome/jest-chrome
- **Chrome Extension Testing:** https://developer.chrome.com/docs/extensions/mv3/tut_testing/

### Code Quality
- **ESLint Chrome Extension:** https://github.com/eslint/eslint-plugin-chrome-extensions
- **Conventional Commits:** https://www.conventionalcommits.org/

### Methodologies
- **Scrum Guide:** https://scrumguides.org/
- **Technical Debt Management:** `C:\claude_context\metodologia_general\12-technical-debt-management.md`
- **Capacity Planning:** `C:\claude_context\metodologia_general\13-capacity-planning.md`
- **Definition of Ready:** `C:\claude_context\metodologia_general\14-definition-of-ready.md`

---

## 📝 Appendix A: Story Estimation Calibration

### Fibonacci Scale Reference

| Points | Time | Complexity | Example Tasks |
|--------|------|------------|---------------|
| **1** | 1-2h | Trivial | Documentation update, config change |
| **2** | 2-4h | Simple | Small script, minor refactor |
| **3** | 4-6h | Moderate | Medium refactor, simple feature |
| **5** | 8-12h | Medium | Feature with tests, complex refactor |
| **8** | 12-20h | High | Complex feature, validation research |
| **13** | 20-30h | Very High | Epic-level work, architecture change |

### Sprint N Stories Calibration

| Story | Points | Estimated Hours | Complexity Factors | Confidence |
|-------|--------|----------------|-------------------|------------|
| LTE-001 | 3 | 6h | Moderate - Refactor con tests | HIGH |
| LTE-002 | 5 | 10h | Medium - Setup + learning curve | MEDIUM |
| LTE-020 | 8 | 16h | High - Research + manual work | MEDIUM |
| LTE-021 | 2 | 4h | Simple - Config + cleanup | HIGH |

**Confidence Factors:**
- **HIGH:** Tareas conocidas, scope claro, pocas dependencias
- **MEDIUM:** Learning curve, scope puede variar, algunas incertidumbres
- **LOW:** Muchas incógnitas, dependencias externas, scope ambiguo

**Adjustment for Next Sprint:**
- Post-sprint: Calcular `actual hours / story points`
- If ratio != 2h/pt, ajustar estimaciones futuras
- Track en `SPRINT_METRICS.md`

---

## 📝 Appendix B: Task Dependencies Graph

```
Sprint N - Task Dependencies
════════════════════════════════════════════════════════════

┌─────────────┐
│  LTE-021    │ (Independent track)
│  ESLint     │
│  Setup      │
└─────────────┘
      │
      │ (Parallel)
      ▼
┌─────────────┐
│  T-021-1    │ Configure ESLint
└─────────────┘
      │
      ▼
┌─────────────┐
│  T-021-2    │ Fix auto-fixable
└─────────────┘
      │
      ▼
┌─────────────┐
│  T-021-3    │ Manual review
└─────────────┘
      │
      ▼
┌─────────────┐
│  T-021-4    │ Documentation
└─────────────┘

═════════════════════════════════════════════════════════════

┌─────────────┐
│  LTE-001    │ (Main critical path)
│  Parsing    │
│  Unification│
└─────────────┘
      │
      ▼
┌─────────────┐
│  T-001-1    │ Audit duplication
└─────────────┘
      │
      ▼
┌─────────────┐
│  T-001-2    │ Create shared-utils
└─────────────┘
      │
      ├──────────────┬──────────────┐
      ▼              ▼              ▼
┌─────────┐    ┌─────────┐    ┌─────────┐
│ T-001-3 │    │ T-001-4 │    │ T-001-5 │
│ Refactor│    │ Refactor│    │ Tests   │
│background│    │ content │    │         │
└─────────┘    └─────────┘    └─────────┘
      │              │              │
      └──────────────┴──────────────┘
                     │
                     ▼
              ┌─────────────┐
              │  LTE-001    │
              │  COMPLETE   │
              └─────────────┘
                     │
                     │ (Blocks LTE-002)
                     ▼
              ┌─────────────┐
              │  LTE-002    │
              │  Test Infra │
              └─────────────┘
                     │
                     ▼
              ┌─────────────┐
              │  T-002-1    │ Research Jest
              └─────────────┘
                     │
                     ▼
              ┌─────────────┐
              │  T-002-2    │ Configure Jest
              └─────────────┘
                     │
                     ▼
              ┌─────────────┐
              │  T-002-3    │ Setup jest-chrome
              └─────────────┘
                     │
                     ├──────────────┬──────────────┐
                     ▼              ▼              ▼
              ┌─────────┐    ┌─────────┐    ┌─────────┐
              │ T-002-4 │    │ T-002-5 │    │ T-002-6 │
              │VTT tests│    │Utils    │    │Smoke    │
              │         │    │tests    │    │tests    │
              └─────────┘    └─────────┘    └─────────┘
                     │              │              │
                     └──────────────┴──────────────┘
                                    │
                                    ▼
                             ┌─────────────┐
                             │  T-002-7    │ Documentation
                             └─────────────┘
                                    │
                                    ▼
                             ┌─────────────┐
                             │  LTE-002    │
                             │  COMPLETE   │
                             └─────────────┘
                                    │
                                    │ (Blocks LTE-020)
                                    ▼
                             ┌─────────────┐
                             │  LTE-020    │
                             │  Validation │
                             └─────────────┘
                                    │
                                    ▼
                             ┌─────────────┐
                             │  T-020-1    │ Select course
                             └─────────────┘
                                    │
                                    ▼
                             ┌─────────────┐
                             │  T-020-2    │ Crawl dataset
                             └─────────────┘
                                    │
                                    ▼
                             ┌─────────────┐
                             │  T-020-3    │ Verify completeness
                             └─────────────┘
                                    │
                                    ▼
                             ┌─────────────┐
                             │  T-020-4    │ Execute matching
                             └─────────────┘
                                    │
                                    ▼
                             ┌─────────────┐
                             │  T-020-5    │ Calculate metrics
                             └─────────────┘
                                    │
                                    ▼
                             ┌─────────────┐
                             │  T-020-6    │ Manual validation
                             └─────────────┘
                                    │
                                    ▼
                             ┌─────────────┐
                             │  T-020-7    │ Error analysis
                             └─────────────┘
                                    │
                                    ▼
                             ┌─────────────┐
                             │  T-020-8    │ Generate report
                             └─────────────┘
                                    │
                                    ▼
                             ┌─────────────┐
                             │  T-020-9    │ Findings documentation
                             └─────────────┘
                                    │
                                    ▼
                             ┌─────────────┐
                             │  LTE-020    │
                             │  COMPLETE   │
                             └─────────────┘

Critical Path: LTE-001 → LTE-002 → LTE-020
Parallel Track: LTE-021 (can complete independently)
```

---

## 📝 Appendix C: Buffer Usage Scenarios

### Buffer Allocation: 5.5 story points (11 hours)

**Planned Use Cases:**

1. **Documentation (3h estimated):**
   - Update README with testing instructions
   - Update CHANGELOG with Sprint N changes
   - Create validation report template
   - Update CLAUDE.md project memory

2. **Code Review & Polish (3h estimated):**
   - Self-review of all code changes
   - Code cleanup (remove console.logs, comments)
   - Refine error messages
   - Improve code readability

3. **Emergencies Reserve (5h estimated):**
   - Bugs discovered during testing
   - Unexpected complexity in tasks
   - Re-work if AC not met first time
   - Learning curve for new tools

**Healthy Buffer Usage:**
- **50-80% used:** Good - Some challenges but managed
- **80-100% used:** Acceptable - Sprint was challenging
- **>100% used:** Problem - Over-commitment or underestimation

**If Buffer Exhausted:**
1. Review sprint scope
2. Identify lowest priority story (likely LTE-021)
3. Move to Sprint N+1 backlog
4. Document in retrospective

---

## 📝 Appendix D: Definition of Ready Verification

Todas las historias committed deben cumplir Definition of Ready:

### LTE-001: Eliminar Duplicación Parsing

- [x] **Story Completeness**
  - [x] ID único: LTE-001
  - [x] Título descriptivo
  - [x] User story format correcto
  - [x] Story points: 3
  - [x] Priority: CRITICAL

- [x] **Acceptance Criteria**
  - [x] 4 AC específicos
  - [x] Formato Given-When-Then
  - [x] Testeable

- [x] **Technical Requirements**
  - [x] Archivos a modificar identificados (background.js, content.js)
  - [x] Approach claro (shared-utils.js)
  - [x] No dependencies bloqueantes

- [x] **Testing Strategy**
  - [x] Unit tests definidos
  - [x] Manual testing steps documentados

- [x] **Approval**
  - [x] Technical Lead reviewed (self)

**Status:** ✅ READY

---

### LTE-002: Setup Test Infrastructure

- [x] **Story Completeness**
  - [x] ID único: LTE-002
  - [x] Título descriptivo
  - [x] User story format correcto
  - [x] Story points: 5 (subset)
  - [x] Priority: HIGH

- [x] **Acceptance Criteria**
  - [x] 4 AC específicos (subset de 13pt story)
  - [x] Formato Given-When-Then
  - [x] Coverage targets definidos

- [x] **Technical Requirements**
  - [x] Framework elegido: Jest
  - [x] Mocking strategy: jest-chrome
  - [x] Files structure definida

- [x] **Testing Strategy**
  - [x] Test cases prioritarios identificados
  - [x] Coverage targets: >40% overall, >80% vtt-parser

- [x] **Approval**
  - [x] Technical Lead reviewed

**Status:** ✅ READY

**Risk:** 🟡 jest-chrome compatibility unknown → Mitigado con Task T-002-1 (research first)

---

### LTE-020: Validar Sistema de Matching

- [x] **Story Completeness**
  - [x] ID único: LTE-020
  - [x] Título descriptivo
  - [x] User story format correcto
  - [x] Story points: 8
  - [x] Priority: CRITICAL

- [x] **Acceptance Criteria**
  - [x] 4 AC específicos
  - [x] Métricas definidas (precision, recall)
  - [x] Deliverable claro (validation report)

- [x] **Technical Requirements**
  - [x] Dataset selection criteria definido
  - [x] Metrics calculation approach claro
  - [x] Validation methodology definida

- [x] **Testing Strategy**
  - [x] Manual validation de 30 matches
  - [x] Criterios de éxito definidos (>85% precision)
  - [x] Decision tree para outcomes

- [x] **Approval**
  - [x] Technical Lead reviewed
  - [x] Justified as CRITICAL (sistema nunca validado)

**Status:** ✅ READY

**Note:** Historia NUEVA agregada basada en findings de architecture analysis (riesgo crítico identificado)

---

### LTE-021: Configurar ESLint

- [x] **Story Completeness**
  - [x] ID único: LTE-021
  - [x] Título descriptivo
  - [x] User story format correcto
  - [x] Story points: 2
  - [x] Priority: MEDIUM

- [x] **Acceptance Criteria**
  - [x] 4 AC específicos
  - [x] Target claro: 0 errors, <10 warnings
  - [x] IDE integration documentada

- [x] **Technical Requirements**
  - [x] Tool elegido: ESLint
  - [x] Plugin identificado: eslint-plugin-chrome-extensions
  - [x] Config approach claro

- [x] **Testing Strategy**
  - [x] Verification: `npm run lint` pasa
  - [x] IDE integration verificable

- [x] **Approval**
  - [x] Technical Lead reviewed

**Status:** ✅ READY

---

**All Stories:** ✅ READY TO START

---

## 🎯 Sprint N - Executive Summary

**Duración:** 2026-01-18 → 2026-01-31 (14 días calendario, 10 días laborables)

**Sprint Goal:**
Eliminar deuda técnica crítica, establecer fundamentos de testing, y validar sistema de matching v0.10.0 para garantizar confiabilidad del producto.

**Commitment:**
- 4 historias (18 story points)
- 36 horas de trabajo comprometidas
- 11 horas de buffer (20%)

**Key Deliverables:**
1. ✅ Código sin duplicación de parsing (ROI 10x)
2. ✅ Suite de tests automatizados funcionando (>40% coverage)
3. ✅ Validación formal del sistema de matching con dataset real
4. ✅ Código limpio con ESLint (0 errors)

**Risk Level:** 🟢 LOW (commitment conservador, historias bien definidas)

**Next Steps:**
1. Day 1: Sprint kickoff, comenzar LTE-021
2. Day 3: Checkpoint - LTE-001 complete
3. Day 6: Mid-sprint review - LTE-002 complete
4. Day 11: LTE-020 complete
5. Day 14: Sprint review + retrospective

---

**Document Version:** 1.0
**Created:** 2026-01-18
**Owner:** Technical Lead (Project Manager)
**Status:** APPROVED - Ready to Execute
**Next Review:** Day 6 (Mid-Sprint Review)

---

**End of Sprint N Plan**
