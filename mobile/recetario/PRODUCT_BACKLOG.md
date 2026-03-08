# Product Backlog - Recetario

**Ultima actualizacion:** 2026-02-14

## ID Registry

**Ultimo ID usado:** REC-029
**Proximo ID disponible:** REC-030

## Epics

| Epic ID | Nombre | Stories | Estado |
|---------|--------|---------|--------|
| EPIC-001 | Estabilizacion y Firebase Condicional | REC-001, REC-002, REC-006 (parcial), REC-016, REC-021, REC-022 | Parcial (4/6 done) |
| EPIC-002 | Mejora del Importador de Recetas | REC-003, REC-004, REC-005, REC-007, REC-008, REC-011 | Completado |
| EPIC-003 | Mejora de UX/UI | REC-010, REC-012, REC-013, REC-014, REC-015, REC-017, REC-019, REC-020, REC-027 | Pendiente |
| EPIC-004 | Sync y Performance | REC-009, REC-018 | Pendiente |
| EPIC-005 | Features Nuevas | REC-023, REC-024, REC-025, REC-026, REC-028, REC-029 | Pendiente |

## Backlog Summary

### CRITICO

| ID | Titulo | Prioridad | Pts | Epic | Estado |
|----|--------|-----------|-----|------|--------|
| REC-001 | Firebase.initializeApp crashea sin google-services.json | CRITICO | 3 | EPIC-001 | Completada |
| REC-002 | Dependencia dura de Firebase bloquea build/run | CRITICO | 5 | EPIC-001 | Completada |

### HIGH

| ID | Titulo | Prioridad | Pts | Epic | Estado |
|----|--------|-----------|-----|------|--------|
| REC-003 | RecipeParser falla con sitios que usan headings como seccion | HIGH | 5 | EPIC-002 | Completada |
| REC-004 | Sin timeout ni manejo de redirects en HTTP request del parser | HIGH | 2 | EPIC-002 | Completada |
| REC-005 | RecipeParser no maneja HowToSection en JSON-LD | HIGH | 3 | EPIC-002 | Completada |
| REC-006 | Sin tests para import/parser, OCR, auth ni sync | HIGH | 13 | EPIC-001 | Pendiente |
| REC-007 | No hay validacion de seguridad en URL import - SSRF potencial | HIGH | 2 | EPIC-002 | Completada |
| REC-008 | OcrService no dispone TextRecognizer correctamente | HIGH | 2 | EPIC-002 | Completada |
| REC-009 | SyncEngine descarga TODAS las recetas en cada sync | HIGH | 3 | EPIC-004 | Pendiente |
| REC-010 | sourceUrl no se puede abrir - TODO pendiente | HIGH | 1 | EPIC-003 | Pendiente |

### MEDIUM

| ID | Titulo | Prioridad | Pts | Epic | Estado |
|----|--------|-----------|-----|------|--------|
| REC-011 | Mensaje generico cuando parser no encuentra receta | MEDIUM | 2 | EPIC-002 | Completada |
| REC-012 | Recipe.copyWith no permite limpiar campos nullables | MEDIUM | 2 | EPIC-003 | Pendiente |
| REC-013 | Duplicacion masiva entre FormScreen y PreviewScreen | MEDIUM | 5 | EPIC-003 | Pendiente |
| REC-014 | No hay drag-to-reorder para ingredientes y pasos | MEDIUM | 3 | EPIC-003 | Pendiente |
| REC-015 | RecipeCard no muestra imagenes locales | MEDIUM | 2 | EPIC-003 | Pendiente |
| REC-016 | Auth/Sync providers usan StateNotifier legacy | MEDIUM | 2 | EPIC-001 | Pendiente |
| REC-017 | No hay cache de imagenes de red | MEDIUM | 2 | EPIC-003 | Pendiente |
| REC-018 | Busqueda hace LIKE sobre JSON raw serializado | MEDIUM | 3 | EPIC-004 | Pendiente |
| REC-019 | Dark mode sin toggle manual en UI | MEDIUM | 2 | EPIC-003 | Pendiente |
| REC-020 | Sin confirmacion al salir del formulario con cambios | MEDIUM | 2 | EPIC-003 | Pendiente |
| REC-021 | _VersionCard usa dynamic sin type safety | MEDIUM | 1 | EPIC-001 | Completada |
| REC-022 | ProfileScreen usa dynamic user sin type safety | MEDIUM | 1 | EPIC-001 | Completada |

### LOW

| ID | Titulo | Prioridad | Pts | Epic | Estado |
|----|--------|-----------|-----|------|--------|
| REC-023 | Soporte para categorias y colecciones | LOW | 8 | EPIC-005 | Pendiente |
| REC-024 | Compartir recetas entre usuarios | LOW | 5 | EPIC-005 | Pendiente |
| REC-025 | Escalar porciones con ajuste proporcional | LOW | 5 | EPIC-005 | Pendiente |
| REC-026 | Timer/cronometro integrado en pasos | LOW | 5 | EPIC-005 | Pendiente |
| REC-027 | Animaciones hero entre lista y detalle | LOW | 2 | EPIC-003 | Pendiente |
| REC-028 | Exportar recetas a PDF o texto plano | LOW | 3 | EPIC-005 | Pendiente |
| REC-029 | Lista de compras desde ingredientes | LOW | 8 | EPIC-005 | Pendiente |

## Metricas del Backlog

| Metrica | Valor |
|---------|-------|
| Total stories | 29 |
| Completadas | 10 stories (26 pts) |
| Pendientes | 19 stories (82 pts) |
| HIGH pendientes | 3 stories (17 pts) |
| MEDIUM pendientes | 10 stories (23 pts) |
| LOW pendientes | 7 stories (42 pts) |
