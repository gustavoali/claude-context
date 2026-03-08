# Product Backlog - LinkedIn Transcript Extractor

**Version:** 8.0
**Ultima actualizacion:** 2026-02-20
**Product Owner:** Technical Lead

---

## Resumen

| Metrica | Valor |
|---------|-------|
| Historias completadas | 73 |
| Historias pendientes | 4 |
| Story points completados | ~375 |
| Story points pendientes | 24 |
| Test coverage | ~85% |
| Tests pasando | 2,724 |

---

## Product Vision

Chrome Extension + MCP Server para capturar y consultar transcripts de LinkedIn Learning, optimizado para LLMs.

---

## Epics (Resumen)

| Epic | Historias | Story Points | Status |
|------|-----------|--------------|--------|
| Quality Foundations | 5 | ~25 | DONE |
| Validation & Reliability | 5 | 20 | DONE |
| Developer Experience | 4 | 10 | DONE |
| Advanced Features | 4 | 21 | DONE |
| External Integrations | 1 | 8 | DONE |
| Batch Crawl | 4 | 18 | DONE |
| Modular Architecture | 16 | 100 | DONE |
| Crawl por Fases | 10 | 68 | Etapa 1+2 DONE, Etapa 3 Deferred |
| Collection-Driven Capture | 4 | 24 | DONE |
| Collection Management | 7 | 36 | DONE |
| Legacy Data Migration | 5 | 17 | DONE |

---

## Historias Pendientes

### Etapa 3: Versioning (DEFERRED)

| ID | Titulo | Puntos | Prioridad | Estado |
|----|--------|--------|-----------|--------|
| LTE-050 | Transcript Version History | 8 | Low | Backlog |
| LTE-051 | Change Detection Algorithm | 8 | Low | Backlog |
| LTE-052 | Scheduled Update Checks | 5 | Low | Backlog |
| LTE-053 | Manual Update Trigger | 3 | Low | Backlog |

**Revisitar cuando:** Feedback de usuario, estrategia de storage definida, prioridades altas completadas.

---

## Technical Debt

| ID | Descripcion | Status |
|----|-------------|--------|
| TD-001 | Tests unitarios incompletos | RESOLVED (~85%) |
| TD-002 | Duplicacion parsing VTT | RESOLVED |
| TD-003 | Scripts desorganizados | RESOLVED |
| TD-004 | Estado global complejo | RESOLVED |
| TD-006 | DOM selectors fragiles | RESOLVED |

---

## Known Issues

| Issue | Descripcion | Severidad |
|-------|-------------|-----------|
| ai-trends duplicates | StructureExtractor crea chapters ES + EN al cambiar locale | Medium |
| folder-parser nav links | Nav links de LinkedIn parseados como cursos | Low |
| CollectionCapture discovery | Found 0 courses para collection URL (broken) | High |
| 21 transcripts sin migrar | Necesitan re-discovery de 5 cursos | Medium |
| 31 cursos sin titulo | Discovery no siempre captura titulo | Low |

---

## ID Registry

| Rango | Estado |
|-------|--------|
| LTE-001 a LTE-061 | Completados |
| LTE-062 a LTE-068 | Completados (Epic 10) |
| LTE-069 a LTE-073 | Completados (Epic 11) |
| LTE-074+ | Disponibles |

**Proximo ID disponible:** LTE-074

---

## Completadas Recientes

| ID | Titulo | Fecha |
|----|--------|-------|
| LTE-062 | Voyager API Discovery | 2026-02-20 |
| LTE-063 | Collection Management Strategy Pattern | 2026-02-20 |
| LTE-064 | DOM Automation Strategy | 2026-02-20 |
| LTE-065 | Voyager API Strategy | 2026-02-20 |
| LTE-066 | Database Collections Local State | 2026-02-20 |
| LTE-067 | Collection Management REST Endpoints | 2026-02-20 |
| LTE-068 | Extension UI Collection Management Panel | 2026-02-20 |
| LTE-069 | Migrate Orphan Data | 2026-02-20 |
| LTE-070 | Migrate SearchRepository | 2026-02-20 |
| LTE-071 | Enrich Course Listing | 2026-02-20 |
| LTE-072 | Drop Legacy Transcripts Table | 2026-02-20 |
| LTE-073 | Update course_summary View | 2026-02-20 |
| LTE-061 | Integrar Discovery en flujo de Crawl | 2026-02-10 |

**Historial completo:** `archive/2026-02-13/PRODUCT_BACKLOG_full.md`
