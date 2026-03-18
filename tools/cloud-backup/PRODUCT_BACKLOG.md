# Backlog - Cloud Backup
**Version:** 1.0 | **Actualizacion:** 2026-03-18

## Resumen
| Metrica | Valor |
|---------|-------|
| Total historias | 15 |
| Puntos totales | 52 |
| Completadas | 0 |
| En progreso | 0 |
| Pendientes | 15 |

## Vision
Backup automatizado y manual de todos los datos del ecosistema (SQLite, PostgreSQL, secretos, config) que no estan cubiertos por git push. Ejecucion diaria scheduled + manual on-demand. Restauracion confiable y verificada.

## Epics
| Epic | Historias | Puntos | Status |
|------|-----------|--------|--------|
| EPIC-01: Setup y Configuracion | CB-001, CB-002 | 6 | Pendiente |
| EPIC-02: Backup Core | CB-003, CB-004, CB-005, CB-006 | 15 | Pendiente |
| EPIC-03: Encriptacion y Seguridad | CB-007 | 3 | Pendiente |
| EPIC-04: Upload y Sync | CB-008, CB-009 | 6 | Pendiente |
| EPIC-05: Restore | CB-010, CB-011 | 8 | Pendiente |
| EPIC-06: Scheduling y Monitoring | CB-012, CB-013 | 6 | Pendiente |
| EPIC-07: Testing y Documentacion | CB-014, CB-015 | 7 | Pendiente |

## Orden de Implementacion Recomendado

**Fase 1 - Fundacion (Sprint 1):** CB-001, CB-002, CB-003, CB-004, CB-005 (16 pts)
Resultado: Backups locales en staging de todas las fuentes.

**Fase 2 - Cloud + Orquestacion (Sprint 2):** CB-006, CB-007, CB-008 (11 pts)
Resultado: Backup completo funcional con upload a GDrive y secretos encriptados.

**Fase 3 - Restore + Testing (Sprint 3):** CB-010, CB-014 (10 pts)
Resultado: Ciclo backup-restore verificado E2E.

**Fase 4 - Automatizacion (Sprint 4):** CB-009, CB-011, CB-012, CB-013, CB-015 (15 pts)
Resultado: Sistema completo con scheduling, retencion, monitoring y documentacion.

---

## Pendientes con Detalle (Fase 1 - proxima a implementar)

### CB-001: Instalar y configurar rclone con Google Drive
**Points:** 3 | **Priority:** Critical

**As a** ecosystem administrator
**I want** rclone installed and configured with Google Drive as remote
**So that** I have the foundation to sync backups to the cloud

#### Acceptance Criteria
**AC1:** Given rclone is not installed, When I run the installation, Then rclone is available in PATH and `rclone version` returns a valid version
**AC2:** Given rclone is installed, When I configure a remote named `gdrive`, Then `rclone lsd gdrive:` lists my Drive folders without errors
**AC3:** Given rclone is configured, When I create `ecosystem-backups/` in GDrive, Then `rclone lsd gdrive:ecosystem-backups` confirms it exists
**AC4:** Given rclone config is complete, When documented in `config/rclone.conf` (reference only), Then the backup script can locate the remote by name

#### Technical Notes
- Install via `winget install Rclone.Rclone` or scoop
- Use `rclone config` interactive flow for Google Drive OAuth
- rclone.conf lives in `~/.config/rclone/rclone.conf` (default)
- The project stores a reference path, not the actual config (secrets)

---

### CB-002: Crear backup-manifest.json con inventario de datos
**Points:** 3 | **Priority:** Critical

**As a** ecosystem administrator
**I want** a declarative manifest listing all data sources, tiers, and paths
**So that** the backup script knows what to back up without hardcoding paths

#### Acceptance Criteria
**AC1:** Given the seed document inventory, When I create `config/backup-manifest.json`, Then it contains all Tier 1/2/3 items with paths, types, sizes, and tier assignments
**AC2:** Given paths with `~` or env vars, When the script reads them, Then it resolves to absolute paths at runtime
**AC3:** Given a `frequency` field per item, When the script filters by tier, Then it processes only matching items
**AC4:** Given a new data source, When one JSON entry is added, Then it is included in backups automatically

#### Technical Notes
- Schema: `{ "sources": [{ "name", "path", "type", "tier", "frequency", "size_estimate", "docker_volume?" }] }`
- PostgreSQL entries need `container_name` and `db_name` fields
- Secrets entries need `encrypt: true` flag

---

### CB-003: Implementar backup de bases SQLite
**Points:** 3 | **Priority:** Critical

**As a** ecosystem administrator
**I want** safe backups of all SQLite databases
**So that** I can restore them without corruption even if they are in use

#### Acceptance Criteria
**AC1:** Given a SQLite path from the manifest, When backup runs, Then it uses `sqlite3 <db> ".backup '<staging>/<name>.db'"` for a consistent copy
**AC2:** Given a locked SQLite file, When backup runs, Then `.backup` completes successfully (handles WAL mode)
**AC3:** Given staging dir does not exist, When backup starts, Then it creates `staging/sqlite/`
**AC4:** Given a SQLite path that does not exist, When backup runs, Then it logs a warning and continues (no abort)

#### Technical Notes
- Requires `sqlite3` CLI in PATH
- Staging dir: `C:/tools/cloud-backup/staging/sqlite/`
- Tier 1: youtube.db, library.db, lte.db
- Tier 2: linkedin backup snapshots (file copy, not .backup)

---

### CB-004: Implementar backup de bases PostgreSQL via Docker
**Points:** 5 | **Priority:** Critical

**As a** ecosystem administrator
**I want** backups of all PostgreSQL databases running in Docker containers
**So that** I can restore them independently without needing the Docker volume

#### Acceptance Criteria
**AC1:** Given a PG entry with `container_name` and `db_name`, When backup runs, Then it executes `docker exec <container> pg_dump -U postgres <db> | gzip > staging/postgres/<name>.sql.gz`
**AC2:** Given a container not running, When backup tries to dump, Then it logs a warning and skips (no abort)
**AC3:** Given Docker via WSL, When script runs `docker info`, Then it confirms daemon is available before dumps
**AC4:** Given Tier 1, When backup runs, Then it dumps only sprint-backlog and project-admin
**AC5:** Given dump completes, When gzipped file is in staging, Then file size is >0 (empty = error logged)

#### Technical Notes
- Docker runs via WSL, not Docker Desktop. Use `wsl docker exec` from PowerShell
- Tier 1: sprint-backlog-pg (5433), project-admin-pg (5434)
- Tier 2: sprint_3_postgres, plane-app_pgdata, atlasops-postgres

---

### CB-005: Implementar backup de secretos y configuracion
**Points:** 2 | **Priority:** Critical

**As a** ecosystem administrator
**I want** all secrets, tokens, and config files collected into staging
**So that** they can be encrypted and uploaded in subsequent steps

#### Acceptance Criteria
**AC1:** Given secret/config entries in manifest, When backup runs, Then it copies each to `staging/secrets/`
**AC2:** Given `.env` files across `C:/mcp/*/`, When collected, Then each is named with project prefix (e.g., `youtube-mcp.env`)
**AC3:** Given `~/.youtube-mcp/token.json` and `client_secret.json`, When collected, Then both are in staging
**AC4:** Given `~/.claude.json` and `~/.claude/settings.json`, When collected, Then both are in staging
**AC5:** Given a missing secret file, When backup runs, Then it logs a warning and continues

#### Technical Notes
- Files encrypted by CB-007 before upload. Staging dir: `staging/secrets/`

---

## Pendientes sin Detalle (Fases 2-4, detalle en backlog/stories/)

| ID | Titulo | Pts | Priority | Fase | Detalle |
|----|--------|-----|----------|------|---------|
| CB-006 | Script principal backup.ps1 con orquestacion | 5 | Critical | 2 | backlog/stories/CB-006-backup-script.md |
| CB-007 | Configurar rclone crypt para secretos | 3 | High | 2 | backlog/stories/CB-007-rclone-crypt.md |
| CB-008 | Upload a Google Drive con rclone | 3 | High | 2 | backlog/stories/CB-008-upload-gdrive.md |
| CB-009 | Politica de retencion y limpieza remota | 3 | Medium | 4 | backlog/stories/CB-009-retention-policy.md |
| CB-010 | Implementar restore.ps1 | 5 | High | 3 | backlog/stories/CB-010-restore-script.md |
| CB-011 | Restore selectivo por tipo y tier | 3 | Medium | 4 | backlog/stories/CB-011-restore-selective.md |
| CB-012 | Windows Task Scheduler para backup diario | 3 | Medium | 4 | backlog/stories/CB-012-task-scheduler.md |
| CB-013 | Monitoring con logs y alertas | 3 | Medium | 4 | backlog/stories/CB-013-monitoring-alerts.md |
| CB-014 | Testing E2E backup-restore | 5 | High | 3 | backlog/stories/CB-014-e2e-testing.md |
| CB-015 | Documentar procedimientos de operacion | 2 | Medium | 4 | backlog/stories/CB-015-documentation.md |

## Completadas (indice)
| ID | Titulo | Puntos | Fecha | Detalle |
|----|--------|--------|-------|---------|
| - | - | - | - | - |

## ID Registry
| Rango | Estado |
|-------|--------|
| CB-001 a CB-015 | Asignados |
| CB-016+ | Disponible |
Proximo ID: CB-016
