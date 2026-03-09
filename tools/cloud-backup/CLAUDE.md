# Cloud Backup - Project Context
**Version:** 0.1.0 | **Inicio:** 2026-03-09
**Ubicacion:** C:/tools/cloud-backup
**Tipo:** Herramienta de infraestructura del ecosistema

## Proposito
Backup automatizado y manual de todos los datos del ecosistema que no estan cubiertos
por git push a GitHub: databases (SQLite, PostgreSQL), secretos (.env, OAuth tokens),
configuracion de Claude CLI.

## Stack
- PowerShell (script principal, compatible Windows nativo)
- rclone (sync a Google Drive)
- rclone crypt (encriptacion de secretos)
- sqlite3 CLI (backup safe de SQLite)
- docker exec pg_dump (backup de PostgreSQL)
- Windows Task Scheduler (scheduling)

## Estructura
```
cloud-backup/
  backup.ps1           # Script principal
  restore.ps1          # Script de restauracion
  config/
    backup-manifest.json  # Que resguardar (paths, tiers, frecuencias)
    rclone.conf           # Config de rclone (referencia)
  logs/                   # Logs de ejecucion
```

## Comandos
```bash
./backup.ps1                    # Backup completo
./backup.ps1 --tier 1           # Solo tier 1
./backup.ps1 --dry-run          # Preview
./backup.ps1 --restore latest   # Restaurar ultimo backup
```

## Documentacion
@C:/claude_context/tools/cloud-backup/SEED_DOCUMENT.md
@C:/claude_context/tools/cloud-backup/LEARNINGS.md

## Reglas
- Secretos SIEMPRE encriptados antes de subir
- Staging dir se limpia despues de cada ejecucion
- Logs persistentes para diagnostico
- Si un container esta caido, skip (no fallar todo el backup)
