# EPIC-001: Estabilizacion y Firebase Condicional

**Estado:** Pendiente
**Prioridad:** CRITICO
**Total Story Points:** 27
**Ultima actualizacion:** 2026-02-13

## Objetivo

Eliminar la dependencia dura de Firebase que impide compilar y ejecutar la app sin google-services.json configurado. Estabilizar la base de codigo con tests, type safety y migracion a APIs actuales de Riverpod.

## Contexto

La app actualmente crashea al iniciar si Firebase no esta configurado (google-services.json ausente). Esto bloquea el desarrollo de cualquier funcionalidad que no sea Firebase. La Fase 1 (MVP Local) esta completada pero la Fase 3 (Auth + Sync) introdujo dependencias que rompen el flujo basico.

## Stories Incluidas

| ID | Titulo | Pts | Prioridad | Estado |
|----|--------|-----|-----------|--------|
| REC-001 | Firebase.initializeApp crashea sin google-services.json | 3 | CRITICO | Pendiente |
| REC-002 | Dependencia dura de Firebase bloquea build/run | 5 | CRITICO | Pendiente |
| REC-006 | Sin tests para import/parser, OCR, auth ni sync (parcial) | 13 | HIGH | Pendiente |
| REC-016 | Auth/Sync providers usan StateNotifier legacy | 2 | MEDIUM | Pendiente |
| REC-021 | _VersionCard usa dynamic sin type safety | 1 | MEDIUM | Pendiente |
| REC-022 | ProfileScreen usa dynamic user sin type safety | 1 | MEDIUM | Pendiente |

## Orden de Ejecucion Sugerido

1. **REC-001** (CRITICO) - Sin esto la app no arranca
2. **REC-002** (CRITICO) - Complementa REC-001, hace Firebase opcional
3. **REC-021 + REC-022** (MEDIUM) - Quick wins de type safety
4. **REC-016** (MEDIUM) - Migrar providers a API actual
5. **REC-006** (HIGH) - Tests para validar todo lo anterior

## Criterios de Exito del Epic

- La app compila y ejecuta sin google-services.json
- Firebase se inicializa solo cuando la configuracion existe
- Los providers de auth/sync usan AsyncNotifier (API actual de Riverpod)
- No hay usos de `dynamic` en widgets de auth/profile
- Coverage de tests >70% para los archivos modificados
- Build con 0 warnings

## Riesgos

| Riesgo | Probabilidad | Impacto | Mitigacion |
|--------|-------------|---------|------------|
| Romper funcionalidad Firebase existente al hacerla condicional | Media | Alto | Tests exhaustivos antes y despues |
| Migracion de StateNotifier introduce regresiones | Baja | Medio | Migrar uno por uno con tests |

## Dependencias

- Ninguna dependencia externa
- REC-006 depende de que REC-001 y REC-002 esten resueltos para poder testear correctamente
