# Technical Debt Register - LinkedIn Transcript Extractor

**Version:** 0.10.0
**Fecha:** 2026-01-18
**Ultima Revision:** Software Architect
**Estado:** ACTIVO

---

## Resumen Ejecutivo

| Metrica | Original | Actual | Cambio |
|---------|----------|--------|--------|
| **Interest Rate Total** | 19.7h/sprint | 10.3h/sprint | **-48%** |
| **Fix Cost Total** | 112h | 74h | **-34%** |
| **Items CLOSED** | 0 | 1 | +1 |
| **Items PARTIAL** | 0 | 4 | +4 |
| **Items OPEN** | 7 | 2 | -5 |

---

## Active Technical Debt

| ID | Descripcion | Severidad | Status | Interest | Fix Cost | ROI | Sprint Target |
|----|-------------|-----------|--------|----------|----------|-----|---------------|
| **TD-004** | Estado global complejo (background.js 839 lineas) | HIGH | OPEN | 5h/sprint | 20h | **5.0x** | Sprint N+1 |
| **TD-001** | Falta de tests (config jest rota) | CRITICAL | PARTIAL 40% | 3.2h/sprint | 24h | 2.7x | Sprint N |
| **TD-003** | Scripts desorganizados | MEDIUM | PARTIAL 60% | 0.8h/sprint | 5h | 3.2x | Sprint N+1 |
| **TD-005** | Matching basico (solo keywords) | MEDIUM | PARTIAL 30% | 0.7h/sprint | 11h | 1.3x | Defer |
| **TD-007** | Sin schema validation | LOW | OPEN | 0.5h/sprint | 10h | 1.0x | Defer |
| **TD-006** | DOM selectors fragiles | MEDIUM | PARTIAL 50% | 0.1h/sprint | 4h | 0.5x | Defer |

---

## Paid Technical Debt (Completado)

| ID | Descripcion | Closed Date | Cost Actual | Value Delivered |
|----|-------------|-------------|-------------|-----------------|
| **TD-002** | Duplicacion parsing VTT | 2026-01-18 | ~6h | **3h/sprint saved** (ROI 10.0x) |

**Evidence TD-002:**
- `extension/vtt-parser.js` consolidado (147 lineas)
- Funciones centralizadas: `parseVTT()`, `parseTimestamp()`, `formatTimestamp()`, `cleanVTTTags()`
- 64 scripts deprecados movidos a `scripts/deprecated/`

---

## Detalle por Item

### TD-004: Estado Global Complejo (background.js)
**Status:** OPEN | **Priority:** HIGH | **ROI:** 5.0x

**Problema:**
- `background.js` tiene 839 lineas (god object)
- 7+ variables de estado global: `captionsByTab`, `captionContentByTab`, `pageContextByTab`, `savedVideosSet`, `requestContextMap`, `lockedContextByTab`, `nativeHostQueue`
- ~15 funciones mutando estado global
- Dificil de testear, mantener y extender

**Solucion Propuesta:**
```
background/
├── state-manager.js      # Gestion centralizada de estado
├── caption-detector.js   # Deteccion de captions VTT
├── context-manager.js    # Gestion de contexto de pagina
├── native-messaging.js   # Comunicacion con native host
└── background.js         # Orchestrator (<200 lineas)
```

**Acceptance Criteria:**
- [ ] Ningun modulo >400 lineas
- [ ] Estado encapsulado en state-manager
- [ ] Tests unitarios para cada modulo
- [ ] Funcionalidad identica post-refactor

---

### TD-001: Falta de Tests
**Status:** PARTIAL 40% | **Priority:** CRITICAL | **ROI:** 2.7x

**Progreso:**
- [x] Tests creados: `background.test.js`, `native-host.test.js`, `vtt-parser.test.js`
- [x] 68/71 tests pasan (95% pass rate)
- [ ] Coverage: 0% (jest config issue)
- [ ] Tests para `content.js`: 0
- [ ] Tests para `match-transcripts.js`: 0

**Problema Actual:**
Jest reporta 0% coverage aunque tests corren. Configuracion de coverage mal apuntada.

**Remaining Work:**
1. Arreglar `jest.config.js` para calcular coverage correctamente
2. Agregar tests para `extension/content.js`
3. Agregar tests para `scripts/match-transcripts.js`
4. Alcanzar 70%+ coverage global

---

### TD-003: Scripts Desorganizados
**Status:** PARTIAL 60% | **Priority:** MEDIUM | **ROI:** 3.2x

**Progreso:**
- [x] `scripts/lib/` creado con modulos compartidos
- [x] `scripts/deprecated/` con 64 scripts archivados
- [x] Scripts activos reducidos a 5 en raiz
- [ ] Falta `scripts/README.md` documentando cada script
- [ ] Sin naming convention consistente

**Remaining Work:**
1. Crear `scripts/README.md`
2. Establecer naming convention (`lte-diagnose-*`, `lte-view-*`, etc.)

---

### TD-005: Matching Basico
**Status:** PARTIAL 30% | **Priority:** LOW | **ROI:** 1.3x

**Progreso:**
- [x] Algoritmo de keywords implementado
- [x] STOP_WORDS filtering (ingles/espanol)
- [x] Sistema deferred matching funcional
- [ ] Sin TF-IDF o cosine similarity
- [ ] Sin ML/embeddings
- [ ] Sin validacion de accuracy

**Nota:** Funciona aceptablemente para el caso de uso actual. Prioridad baja.

---

### TD-007: Sin Schema Validation
**Status:** OPEN | **Priority:** LOW | **ROI:** 1.0x

**Problema:**
- No hay validacion de estructuras de datos
- Mensajes entre scripts no validados
- Datos a native host sin schema

**Solucion Propuesta:**
- Usar `ajv` (ya disponible en node_modules)
- JSON Schema para mensajes Chrome runtime
- Validacion de estructura de transcripts

---

### TD-006: DOM Selectors Fragiles
**Status:** PARTIAL 50% | **Priority:** LOW | **ROI:** 0.5x

**Progreso:**
- [x] Fallbacks implementados (13 selectores para video title)
- [x] Try/catch por selector
- [x] Logging de selector exitoso
- [ ] Sin uso de `data-*` attributes (mas estables)
- [ ] Sin monitoreo de fallos

**Nota:** Ya bastante robusto. LinkedIn puede romperlo pero hay fallbacks.

---

## Decision Rules

| ROI | Accion |
|-----|--------|
| >5x | Fix IMMEDIATELY (Sprint actual) |
| 3-5x | Fix next sprint |
| 1-3x | Fix when capacity |
| <1x | Defer o Accept |

---

## Sprint Allocation

### Sprint N (Actual)
- **LTE-001** → TD-002 (CLOSED)
- **LTE-002** → TD-001 (en progreso)

### Sprint N+1 (Propuesto)
- **TD-004** (ROI 5.0x) - Refactor background.js
- **TD-003** (ROI 3.2x) - Completar organizacion scripts

### Backlog (Defer)
- TD-005 - Mejorar matching (cuando haya accuracy issues)
- TD-007 - Schema validation (cuando haya data corruption)
- TD-006 - DOM selectors (cuando LinkedIn rompa algo)

---

## Metricas de Seguimiento

### Target Sprint N+3:
- Interest Rate: <5h/sprint (actual: 10.3h)
- Coverage: >70% (actual: 0% por bug config)
- background.js: <200 lineas (actual: 839)

### Review Cycle:
- **Frecuencia:** Cada Sprint Planning
- **Owner:** Technical Lead
- **Actualizacion:** Recalcular ROI con sprints remaining

---

**Ultima actualizacion:** 2026-01-18
**Proximo review:** Sprint N+1 Planning
