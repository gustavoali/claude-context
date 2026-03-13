# Backlog - Project Admin
**Version:** 1.1 | **Actualizacion:** 2026-02-15

## Resumen
| Metrica | Valor |
|---------|-------|
| Total stories (Fase 1+1b+standalone) | 27 |
| Total puntos (Fase 1+1b+standalone) | 83 |
| Epics completados | 5 (Fase 1 + 1b) |
| Epics totales (todas las fases) | 8 |

## Vision
Project Admin es el backend central del ecosistema de desarrollo. Registra, cataloga y conecta 26+ proyectos dispersos en el filesystem, proporcionando un punto unico de consulta y gestion via MCP tools (Claude Code) y REST API (dashboards). Enriquecido con metadata de GitHub repos.

## Epics

| Epic | Fase | Stories | Puntos | Status |
|------|------|---------|--------|--------|
| EPIC-PA-001: Project Registry CRUD | Fase 1 | 7 (PA-001 a PA-007) | 22 | Done |
| EPIC-PA-002: Filesystem Scanner | Fase 1 | 4 (PA-008 a PA-011) | 16 | Done |
| EPIC-PA-003: MCP Server | Fase 1 | 5 (PA-012 a PA-016) | 14 | Done |
| EPIC-PA-004: REST API | Fase 1 | 6 (PA-017 a PA-022) | 15 | Done |
| EPIC-PA-005: GitHub Repo Metadata Sync | Fase 1b | 4 (PA-023 a PA-026) | 13 | Done |
| EPIC-PA-006: SBM Integration | Fase 2 | TBD | TBD | Backlog |
| EPIC-PA-007: CO Integration | Fase 2 | TBD | TBD | Backlog |
| EPIC-PA-008: Angular Dashboard | Fase 2+ | TBD | TBD | Backlog |

## Completadas (indice)
| ID | Titulo | Puntos | Fecha |
|----|--------|--------|-------|
| PA-001 a PA-022 | Fase 1 completa (CRUD, Scanner, MCP, REST) | 67 | 2026-02-14 |
| PA-023 | GitHub CLI wrapper (gh-cli.js) | 2 | 2026-02-15 |
| PA-024 | GitHub sync service | 5 | 2026-02-15 |
| PA-025 | MCP tools github-sync (pa_github_sync, pa_github_sync_all) | 3 | 2026-02-15 |
| PA-026 | REST endpoints github-sync | 3 | 2026-02-15 |

## Pendientes

### PA-027: Auto-sync project-registry.json on project changes
**Points:** 3 | **Priority:** Medium | **MoSCoW:** Should Have
As a developer using the PowerShell `proyecto` command, I want project-admin to auto-sync `project-registry.json` when projects change, so that new projects are immediately navigable without manual JSON editing.
**AC:** 8 criterios (create, update, delete, metadata short/context_path, file integrity, missing file, atomic write)
**Detalle:** `backlog/stories/PA-027-sync-project-registry-json.md`

## ID Registry
| Rango | Estado |
|-------|--------|
| PA-001 a PA-022 | Done (Fase 1) |
| PA-023 a PA-026 | Done (Fase 1b) |
| PA-027 | Pendiente (standalone, quality-of-life) |
| PA-028+ | Reservado para Fase 2+ |
Proximo ID: PA-028
