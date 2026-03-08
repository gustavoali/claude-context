# EPIC-004: Sync y Performance

**Estado:** Pendiente
**Prioridad:** MEDIUM
**Total Story Points:** 6
**Ultima actualizacion:** 2026-02-13

## Objetivo

Optimizar la sincronizacion con Firestore para que sea incremental (no descargue todo cada vez) y mejorar la busqueda local para que sea eficiente y correcta.

## Contexto

El SyncEngine actual descarga TODAS las recetas del servidor en cada sincronizacion, ignorando el metodo `downloadRecipesSince()` que ya existe en el codigo. La busqueda local hace LIKE sobre JSON serializado en lugar de buscar en columnas individuales, lo que produce resultados incorrectos y es ineficiente.

## Stories Incluidas

| ID | Titulo | Pts | Prioridad | Estado |
|----|--------|-----|-----------|--------|
| REC-009 | SyncEngine descarga TODAS las recetas en cada sync | 3 | HIGH | Pendiente |
| REC-018 | Busqueda hace LIKE sobre JSON raw serializado | 3 | MEDIUM | Pendiente |

## Orden de Ejecucion Sugerido

1. **REC-009** (HIGH) - Impacto directo en performance y uso de datos
2. **REC-018** (MEDIUM) - Mejora calidad de busqueda

## Criterios de Exito del Epic

- SyncEngine usa timestamp de ultima sincronizacion para descargas incrementales
- Busqueda opera sobre columnas individuales (titulo, descripcion, ingredientes, tags)
- Sync completo solo ocurre en primera sincronizacion o forzado manual
- Busqueda retorna resultados correctos sin falsos positivos por JSON artifacts

## Riesgos

| Riesgo | Probabilidad | Impacto | Mitigacion |
|--------|-------------|---------|------------|
| Sync incremental pierde recetas si timestamps no estan sincronizados | Media | Alto | Usar server timestamp de Firestore, no local |
| Migracion de busqueda requiere cambio en schema Drift | Baja | Medio | Verificar schema actual antes de implementar |

## Dependencias

- EPIC-001 debe estar resuelto (Firebase condicional) para poder testear sync
- REC-018 puede ejecutarse independientemente de Firebase
