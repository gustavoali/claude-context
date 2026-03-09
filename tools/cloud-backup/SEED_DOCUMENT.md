# Seed Document - Cloud Backup
**Fecha:** 2026-03-09
**Fuente:** Inventario del ecosistema de proyectos

## Objetivo
Implementar un sistema de backup en la nube para todos los datos del ecosistema que NO estan cubiertos por `git push` a GitHub. Debe soportar ejecucion manual y scheduled.

---

## Inventario de Datos a Resguardar

### TIER 1 - Backup Diario (Critico)

| Dato | Path | Size | Tipo |
|------|------|------|------|
| YouTube ingestion DB | `~/.youtube-mcp/youtube.db` | 2.2M | SQLite |
| YouTube library DB | `~/.youtube-mcp/library.db` | 72K | SQLite |
| LinkedIn LTE DB (activa) | `C:/mcp/linkedin/data/lte.db` | 19M | SQLite |
| Sprint Backlog PG | Docker vol `sprint-backlog-pgdata` | ~50-100M | PostgreSQL |
| Project Admin PG | Docker vol `project-admin-pgdata` | ~20-50M | PostgreSQL |
| OAuth tokens YouTube | `~/.youtube-mcp/token.json` + `client_secret.json` | <1M | Secretos |
| .env files (todos los MCP) | `C:/mcp/*/.env` | ~5K total | Secretos |
| Claude CLI config | `~/.claude.json` | 76K | Config |
| Claude settings | `~/.claude/settings.json` | 2.1K | Config |

### TIER 2 - Backup Semanal

| Dato | Path | Size | Tipo |
|------|------|------|------|
| LinkedIn pre-migration snapshots | `C:/mcp/linkedin/data/backups/` | 69M | SQLite backups |
| Sprint 3 PG (AnyoneAI) | Docker vol `sprint_3_postgres_data` | ~50M | PostgreSQL |
| Plane PG (legacy) | Docker vol `plane-app_pgdata` | ~100-200M | PostgreSQL |
| Atlas Ops PG (legacy) | Docker vol `atlasops-postgres-data` | ~20-50M | PostgreSQL |

### TIER 3 - Archivo (una vez)

| Dato | Path | Size | Tipo |
|------|------|------|------|
| LinkedIn NeDB legacy | `C:/mcp/linkedin/data/deprecated-nedb-backup/` | 1.7M | Archivo |
| LinkedIn transcript backups viejos | `C:/mcp/linkedin/data/backups/transcripts*.db` | 462K | SQLite |

### Excluidos (transitorios/recuperables)
- Test databases (`test-*.db`)
- Cache directories
- Browser profiles (chrome-profile*)
- Docker unnamed volumes (hex)
- Redis volumes

---

## Estimacion de Volumen Total

| Tier | Volumen | Frecuencia |
|------|---------|------------|
| Tier 1 | ~150-200M | Diario |
| Tier 2 | ~250-350M | Semanal |
| Tier 3 | ~2M | Una vez |
| **Total** | **~400-550M** | - |

---

## Solucion Propuesta: rclone + Google Drive

### Por que rclone
- CLI maduro y confiable (40+ providers de cloud)
- Google Drive ya integrado en el ecosistema (MCP tools configuradas)
- Encriptacion opcional via `rclone crypt`
- Sync incremental (solo sube lo que cambio)
- Cero costo (usa storage de Google Drive existente)

### Arquitectura

```
backup-ecosystem.ps1 (o .sh)
  |
  |-- 1. SQLite: sqlite3 .backup -> staging/
  |-- 2. PostgreSQL: docker exec pg_dump -> staging/
  |-- 3. Secrets: copy .env, token.json, etc -> staging/encrypted/
  |-- 4. rclone sync staging/ -> gdrive:ecosystem-backups/
  |-- 5. Cleanup staging/
  |
  Schedule: Windows Task Scheduler (diario 03:00 AM)
```

### Estructura en Google Drive

```
ecosystem-backups/
  daily/
    YYYY-MM-DD/
      sqlite/
        youtube.db
        library.db
        lte.db
      postgres/
        sprint-backlog.sql.gz
        project-admin.sql.gz
      secrets/          (encriptado con rclone crypt)
        env-files.tar.gz
        oauth-tokens.tar.gz
        claude-config.tar.gz
  weekly/
    YYYY-MM-DD/
      linkedin-backups/
      postgres-legacy/
  archive/
    nedb-legacy.tar.gz
```

### Retencion

| Tier | Retencion | Limpieza |
|------|-----------|----------|
| Daily | 7 dias | Borrar backups >7d |
| Weekly | 4 semanas | Borrar >4 semanas |
| Archive | Indefinido | Manual |

---

## Modos de Ejecucion

### Manual
```bash
./backup.ps1                    # Backup completo
./backup.ps1 --tier 1           # Solo tier 1
./backup.ps1 --dry-run          # Preview sin ejecutar
./backup.ps1 --restore latest   # Restaurar ultimo backup
```

### Scheduled
- Windows Task Scheduler: diario a las 03:00 AM
- Trigger: solo si la PC esta encendida (no despertar)
- Log: `C:/tools/cloud-backup/logs/YYYY-MM-DD.log`
- Alerta si falla: escribir en `C:/claude_context/ALERTS.md`

---

## Pasos de Implementacion

1. Instalar y configurar rclone con Google Drive
2. Implementar script de backup (PowerShell o bash)
3. Implementar script de restore
4. Configurar rclone crypt para secretos
5. Configurar Windows Task Scheduler
6. Primer backup completo (manual)
7. Documentar procedimiento de restore
8. Monitoring: log + alertas

---

## Riesgos

| Riesgo | Mitigacion |
|--------|-----------|
| Google Drive storage lleno | Politica de retencion + monitoring |
| PostgreSQL container caido al hacer dump | Verificar container status antes, skip si caido |
| SQLite locked durante backup | Usar sqlite3 .backup API (safe concurrent) |
| Secrets en texto plano en staging | Staging en temp dir, borrar post-upload, usar rclone crypt |
| Backup corrupto | Verificacion post-upload (rclone check) |
| PC apagada a las 03:00 | Ejecutar al proximo encendido (Task Scheduler setting) |
