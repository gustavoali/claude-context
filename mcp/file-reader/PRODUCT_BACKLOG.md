# Backlog - File Reader
**Version:** 1.1 | **Actualizacion:** 2026-02-18

## Resumen

| Metrica | Valor |
|---------|-------|
| Total Stories | 16 |
| Total Points | 39 |
| Completadas | 16 stories, 39 pts |
| Pendientes | 0 stories, 0 pts |

## Vision
Servidor local de lectura segura de archivos. FastAPI + Python 3.11+. Solo localhost, API Key auth, sandbox con allowlist de directorios y extensiones.

## Epics

| Epic | Historias | Puntos | Status |
|------|-----------|--------|--------|
| EPIC-01: Server Base | FR-001 a FR-004 | 8 | Done |
| EPIC-02: Seguridad | FR-005 a FR-010 | 15 | Done |
| EPIC-03: Testing | FR-011 a FR-013 | 8 | Done |
| EPIC-04: Documentacion | FR-014, FR-015 | 4 | Done |
| EPIC-05: Deploy | FR-016 | 4 | Done |

---
## Pendientes (con detalle)

_(Sin historias pendientes. Todas completadas.)_

---
## Completadas (indice)

| ID | Titulo | Puntos | Fecha |
|----|--------|--------|-------|
| FR-001 | Setup del proyecto y estructura base | 2 | 2026-02-16 |
| FR-002 | Modulo de configuracion (Pydantic Settings) | 2 | 2026-02-16 |
| FR-003 | Health endpoint | 1 | 2026-02-16 |
| FR-004 | Read endpoint (happy path basico) | 3 | 2026-02-16 |
| FR-005 | Auth middleware (API Key validation) | 3 | 2026-02-16 |
| FR-006 | Path validator - traversal prevention y sandbox check | 3 | 2026-02-16 |
| FR-007 | Extension allowlist | 2 | 2026-02-16 |
| FR-008 | Size limit validation | 1 | 2026-02-16 |
| FR-009 | Sensitive pattern exclusion | 2 | 2026-02-16 |
| FR-010 | Access logging | 2 | 2026-02-16 |
| FR-011 | Unit tests (auth, path validator, config) | 3 | 2026-02-16 |
| FR-012 | Integration tests (read endpoint completo) | 3 | 2026-02-16 |
| FR-013 | Security tests (traversal vectors, pentest basico) | 2 | 2026-02-16 |
| FR-014 | README con instrucciones de uso | 2 | 2026-02-16 |
| FR-015 | .env.example documentado | 2 | 2026-02-16 |
| FR-016 | Script de arranque y verificacion de setup | 4 | 2026-02-16 |

## ID Registry

| Rango | Estado |
|-------|--------|
| FR-001 a FR-016 | Completados |
| FR-017+ | Disponibles |

Proximo ID: FR-017
