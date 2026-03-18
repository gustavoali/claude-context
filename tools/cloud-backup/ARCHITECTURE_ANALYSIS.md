# Arquitectura - Cloud Backup
**Version:** 0.1.0 | **Fecha:** 2026-03-18

## Diagrama de Componentes

```
                          +------------------+
                          |  Task Scheduler  |
                          |  (Windows / cron)|
                          +--------+---------+
                                   |
                                   v
+------------------------------------------------------------------+
|                         backup.ps1                                |
|                    (Orquestador Principal)                        |
|                                                                   |
|  +-------------+  +-------------+  +-------------+  +----------+ |
|  | SQLite       |  | PostgreSQL  |  | Secrets     |  | Config   | |
|  | Collector    |  | Collector   |  | Collector   |  | Collector| |
|  |              |  |             |  |             |  |          | |
|  | sqlite3      |  | docker exec |  | copy + tar  |  | copy    | |
|  | .backup API  |  | pg_dump     |  |             |  |          | |
|  +------+-------+  +------+------+  +------+------+  +-----+---+ |
|         |                 |                |               |      |
|         +--------+--------+--------+-------+               |      |
|                  |                 |                        |      |
|                  v                 v                        |      |
|           staging/db/       staging/secrets/                |      |
|           (plaintext)       (plaintext, efimero)            |      |
|                  |                 |                        |      |
|                  |          +------v-------+                |      |
|                  |          | rclone crypt |                |      |
|                  |          | (encriptacion)|               |      |
|                  |          +------+-------+                |      |
|                  |                 |                        |      |
|                  +--------+--------+                        |      |
|                           |                                 |      |
|                  +--------v---------+                       |      |
|                  |   rclone sync    |<----------------------+      |
|                  | (upload a GDrive)|                              |
|                  +--------+---------+                             |
|                           |                                       |
|                  +--------v---------+                             |
|                  |  Cleanup Module  |                             |
|                  | staging + retain |                             |
|                  +------------------+                             |
|                                                                   |
|  +------------------+  +------------------+                      |
|  | Logger           |  | Manifest Loader  |                      |
|  | logs/YYYY-MM-DD  |  | backup-manifest  |                      |
|  +------------------+  +------------------+                      |
+------------------------------------------------------------------+
         |                                          |
         v                                          v
  +-------------+                         +------------------+
  | Google Drive |                         | ALERTS.md        |
  | ecosystem-   |                         | (si falla)       |
  | backups/     |                         +------------------+
  +-------------+

+------------------------------------------------------------------+
|                        restore.ps1                                |
|                   (Restauracion on-demand)                        |
|                                                                   |
|  rclone copy GDrive -> staging/ -> decrypt -> restore target      |
+------------------------------------------------------------------+
```

## Data Flow End-to-End

### Backup Flow

```
1. INIT
   backup.ps1 recibe parametros (--tier, --dry-run)
   Carga backup-manifest.json
   Filtra items segun tier solicitado
   Crea staging/ dir temporal

2. COLLECT (por cada item del manifest)
   2a. SQLite:
       sqlite3 "{source_path}" ".backup '{staging}/sqlite/{filename}'"
       (API .backup es safe para archivos en uso concurrente)

   2b. PostgreSQL:
       docker inspect {container} -> verificar status
       Si UP:  docker exec {container} pg_dump -U postgres {db} | gzip > staging/postgres/{name}.sql.gz
       Si DOWN: log warning, skip, continuar

   2c. Secrets:
       Copiar archivos a staging/secrets/
       tar + gzip -> staging/secrets/bundle.tar.gz

   2d. Config:
       Copiar archivos a staging/config/

3. ENCRYPT
   rclone crypt encripta staging/secrets/ -> staging/encrypted/
   Borrar staging/secrets/ (plaintext efimero)

4. UPLOAD
   rclone sync staging/ -> gdrive:ecosystem-backups/{tier}/{date}/
   rclone check (verificar integridad post-upload)

5. RETENTION
   Listar backups en GDrive
   Borrar daily/ > 7 dias
   Borrar weekly/ > 4 semanas

6. CLEANUP
   Borrar staging/ completo
   Escribir log en logs/YYYY-MM-DD.log
   Si hubo error: append a C:/claude_context/ALERTS.md
```

### Restore Flow

```
1. INIT
   restore.ps1 recibe parametros (--date, --item, --target)
   Si --date "latest": listar GDrive, tomar fecha mas reciente

2. DOWNLOAD
   rclone copy gdrive:ecosystem-backups/{tier}/{date}/ -> staging/

3. DECRYPT (si secrets)
   rclone crypt descifra staging/encrypted/ -> staging/secrets/

4. RESTORE (segun tipo)
   4a. SQLite:  cp staging/sqlite/{file} -> {target_path}
   4b. PostgreSQL:
       docker exec {container} -- verificar UP
       gunzip | docker exec -i {container} psql -U postgres {db}
   4c. Secrets:  tar xzf -> {target_paths}
   4d. Config:   cp -> {target_paths}

5. CLEANUP
   Borrar staging/
```

## Folder Structure

```
C:/tools/cloud-backup/
  backup.ps1                      # Script principal de backup
  restore.ps1                     # Script de restauracion
  config/
    backup-manifest.json          # Inventario: que resguardar, paths, tiers
    rclone.conf                   # Config rclone (gitignored, contiene tokens)
  logs/                           # Logs de ejecucion (gitignored)
    YYYY-MM-DD.log
  staging/                        # Dir temporal durante ejecucion (gitignored)
    sqlite/
    postgres/
    secrets/                      # Plaintext efimero, borrado post-encrypt
    encrypted/                    # Output de rclone crypt
    config/
  .claude/
    CLAUDE.md                     # Puntero a claude_context
  .gitignore
```

## Interfaces y Contratos

### backup-manifest.json Schema

```json
{
  "version": "1.0",
  "staging_dir": "staging",
  "remote": "gdrive:ecosystem-backups",
  "retention": {
    "daily_days": 7,
    "weekly_weeks": 4
  },
  "items": [
    {
      "id": "youtube-ingestion-db",
      "name": "YouTube Ingestion DB",
      "tier": 1,
      "type": "sqlite",
      "source": "~/.youtube-mcp/youtube.db",
      "remote_path": "sqlite/youtube.db",
      "enabled": true
    },
    {
      "id": "sprint-backlog-pg",
      "name": "Sprint Backlog PostgreSQL",
      "tier": 1,
      "type": "postgres",
      "container": "sprint-backlog-pg",
      "database": "sprint_backlog",
      "pg_user": "postgres",
      "remote_path": "postgres/sprint-backlog.sql.gz",
      "enabled": true
    },
    {
      "id": "oauth-tokens-youtube",
      "name": "YouTube OAuth Tokens",
      "tier": 1,
      "type": "secret",
      "sources": [
        "~/.youtube-mcp/token.json",
        "~/.youtube-mcp/client_secret.json"
      ],
      "remote_path": "secrets/youtube-oauth.tar.gz",
      "enabled": true
    },
    {
      "id": "env-files-mcp",
      "name": "MCP .env Files",
      "tier": 1,
      "type": "secret",
      "sources_glob": "C:/mcp/*/.env",
      "remote_path": "secrets/mcp-env-files.tar.gz",
      "enabled": true
    },
    {
      "id": "claude-config",
      "name": "Claude CLI Config",
      "tier": 1,
      "type": "config",
      "sources": [
        "~/.claude.json",
        "~/.claude/settings.json"
      ],
      "remote_path": "config/claude-cli.tar.gz",
      "enabled": true
    }
  ]
}
```

**Campos por type:**

| Type | Campos requeridos | Campos opcionales |
|------|-------------------|-------------------|
| `sqlite` | id, name, tier, type, source, remote_path | enabled |
| `postgres` | id, name, tier, type, container, database, pg_user, remote_path | enabled |
| `secret` | id, name, tier, type, remote_path + (sources o sources_glob) | enabled |
| `config` | id, name, tier, type, sources, remote_path | enabled |

### CLI Interface

```
backup.ps1 [-Tier <int>] [-DryRun] [-Verbose]
  -Tier      Filtrar por tier (1, 2, 3). Sin especificar = todos.
  -DryRun    Mostrar que haria sin ejecutar.
  -Verbose   Output detallado.

restore.ps1 -Date <string> [-Item <string>] [-Target <string>] [-DryRun]
  -Date      Fecha del backup (YYYY-MM-DD) o "latest".
  -Item      ID del item a restaurar. Sin especificar = todos.
  -Target    Path destino override (default: ubicacion original).
  -DryRun    Mostrar que haria sin ejecutar.
```

### Log Format

```
[YYYY-MM-DD HH:MM:SS] [LEVEL] [COMPONENT] Message
```

Levels: INFO, WARN, ERROR. Components: INIT, SQLITE, POSTGRES, SECRETS, CONFIG, UPLOAD, RETAIN, CLEANUP.

### Exit Codes

| Code | Significado |
|------|-------------|
| 0 | Backup completo sin errores |
| 1 | Backup completo con warnings (items skipped) |
| 2 | Error fatal (rclone fallo, staging no se pudo crear) |

## ADRs

### ADR-001: Lenguaje del Script Principal
**Status:** ACEPTADO
**Contexto:** Necesitamos un script que corra en Windows 11, interactue con docker (via WSL), sqlite3, rclone, y Task Scheduler. Debe ser mantenible por 1 developer.
**Opciones evaluadas:**
  1. **PowerShell** - Nativo en Windows, integracion directa con Task Scheduler, manejo robusto de paths Windows, buena gestion de errores con try/catch. (-) Sintaxis menos familiar para desarrolladores Linux-centric. (-) Interaccion con docker/WSL requiere `wsl` prefix o bash relay.
  2. **Bash (via WSL)** - Natural para docker/sqlite3/rclone que corren en Linux. Familiar. (-) Task Scheduler no ejecuta bash directamente, requiere wrapper. (-) Paths Windows/WSL son un pain point constante (C:/ vs /mnt/c/).
  3. **Python** - Potente, cross-platform, librerias para todo. (-) Overhead de runtime/venv para un script de infra. (-) No agrega valor para lo que es basicamente orquestacion de CLI tools.
**Decision:** PowerShell. El script principal es orquestacion de herramientas CLI. PowerShell es nativo, se integra limpiamente con Task Scheduler, y maneja paths Windows sin traduccion. Los comandos que necesitan Linux (docker, sqlite3, rclone) se invocan via `wsl` cuando es necesario.
**Consecuencias:** (+) Zero-dependency en Windows. (+) Task Scheduler integration trivial. (+) Error handling con try/catch/finally. (-) Comandos docker/rclone necesitan prefix `wsl` o invocarse via bash.

### ADR-002: Destino de Backup en la Nube
**Status:** ACEPTADO
**Contexto:** Necesitamos almacenamiento cloud para ~400-550MB de backups con sync incremental, encriptacion de secretos, y costo minimo.
**Opciones evaluadas:**
  1. **Google Drive via rclone** - El usuario ya tiene Google Drive integrado en el ecosistema (MCP tools). rclone soporta Google Drive nativamente, con sync incremental y crypt overlay. Costo: $0 (storage existente). (-) Requiere OAuth setup inicial para rclone.
  2. **AWS S3** - Standard de la industria, lifecycle policies nativas, versionado. (-) Costo mensual (bajo, pero no cero). (-) Requiere cuenta AWS configurada. (-) Overengineering para un ecosistema personal.
  3. **Backblaze B2** - Mas barato que S3, compatible con rclone. (-) Otra cuenta y credenciales que mantener. (-) Sin beneficio real sobre GDrive para este volumen.
**Decision:** Google Drive via rclone. Cero costo adicional, infraestructura ya existente, rclone maneja sync incremental y encriptacion.
**Consecuencias:** (+) $0 costo. (+) Reutiliza infraestructura existente. (+) rclone crypt para encriptacion transparente. (-) Dependencia de storage personal de Google. (-) Sin lifecycle policies nativas (implementar en el script).

### ADR-003: Estrategia de Encriptacion de Secretos
**Status:** ACEPTADO
**Contexto:** Los secretos (.env, OAuth tokens, claude.json) deben subirse encriptados a la nube. La solucion debe ser simple, sin key management externo.
**Opciones evaluadas:**
  1. **rclone crypt** - Overlay nativo de rclone. Encripta filenames y contenido con NaCl SecretBox (XSalsa20 + Poly1305). Password almacenado en rclone.conf local. (-) Si se pierde rclone.conf, se pierden las keys de decryption.
  2. **GPG** - Standard, keys manejables, ampliamente soportado. (-) Key management manual. (-) Paso extra en el pipeline (encrypt antes de rclone, decrypt despues). (-) Mas complejo de automatizar.
  3. **age** - Moderno, simple, sin configuracion. (-) Herramienta adicional a instalar. (-) Mismo overhead de paso extra que GPG.
**Decision:** rclone crypt. Se integra nativamente en el flujo de rclone (zero-friction), encriptacion fuerte con NaCl, y no requiere herramientas adicionales. El rclone.conf con la password es el unico archivo critico a proteger localmente.
**Consecuencias:** (+) Integrado en rclone, sin paso extra. (+) Encriptacion fuerte (XSalsa20+Poly1305). (+) Decrypt transparente con `rclone copy` desde el remote crypt. (-) rclone.conf es single point of failure para decryption. (-) Password del crypt vive en rclone.conf, que debe protegerse.

### ADR-004: Granularidad del Manifest
**Status:** ACEPTADO
**Contexto:** El sistema necesita saber que resguardar. Esto puede estar hardcodeado en el script o externalizado en configuracion.
**Opciones evaluadas:**
  1. **Manifest JSON externo** - Archivo backup-manifest.json con todos los items, paths, tiers, tipos. El script es generico y lee el manifest. (+) Agregar/remover items sin tocar codigo. (+) Separacion datos/logica. (-) Schema a mantener. (-) Posible drift si el path de un item cambia.
  2. **Hardcoded en el script** - Items definidos como arrays/hashtables dentro de backup.ps1. (+) Todo en un lugar, simple. (-) Cada cambio de inventario requiere editar el script. (-) Mezcla datos con logica.
**Decision:** Manifest JSON externo. La lista de items va a cambiar (proyectos nuevos, containers renombrados, items deprecados). Mantener eso separado del script permite modificar el inventario sin riesgo de romper logica.
**Consecuencias:** (+) Extensible sin tocar codigo. (+) Versionable y diffable. (+) Permite dry-run que muestre items del manifest. (-) Schema a documentar y validar.

### ADR-005: Manejo de PostgreSQL via Docker en WSL
**Status:** ACEPTADO
**Contexto:** Los containers PostgreSQL corren en Docker dentro de WSL. El script principal es PowerShell en Windows. Necesitamos ejecutar pg_dump dentro del container.
**Opciones evaluadas:**
  1. **`wsl docker exec` desde PowerShell** - Invocar docker CLI a traves de WSL desde el script PS1. El comando seria: `wsl docker exec {container} pg_dump -U postgres {db}`. (+) Directo, sin intermediarios. (-) Requiere que WSL y Docker daemon esten running.
  2. **Script bash auxiliar en WSL** - PowerShell llama a un script .sh que corre en WSL y ejecuta todos los comandos Docker/rclone. (+) Comandos Linux nativos. (-) Dos scripts a mantener. (-) Coordinacion entre PS1 y .sh agrega complejidad.
**Decision:** `wsl docker exec` desde PowerShell. Un solo script, sin coordinacion entre lenguajes. La sintaxis `wsl docker ...` es directa y funciona bien para comandos individuales.
**Consecuencias:** (+) Un solo script a mantener. (+) Sin overhead de coordinacion. (-) Cada invocacion a docker/rclone/sqlite3 requiere prefix `wsl`. (-) Paths deben traducirse a formato WSL (/mnt/c/...) para argumentos que los necesiten.

## Testing Strategy

### Validacion Pre-Release

| Nivel | Que validar | Como |
|-------|-------------|------|
| Smoke | Script arranca sin errores, parsea manifest | `./backup.ps1 -DryRun` |
| Unit | Cada collector funciona individualmente | Backup de 1 item por tipo |
| Integration | Pipeline completo: collect -> encrypt -> upload -> verify | Backup tier 1 completo a GDrive |
| Restore | Round-trip: backup -> restore -> comparar | Restaurar a dir temporal, diff contra original |

### Test Cases Minimos

1. **Dry run** muestra items correctos por tier sin ejecutar nada
2. **SQLite backup** de un archivo .db produce copia identica
3. **PostgreSQL backup** con container UP produce .sql.gz valido
4. **PostgreSQL skip** con container DOWN loguea warning, exit code 1
5. **Secrets encriptados** no son legibles en GDrive sin crypt config
6. **Restore SQLite** produce archivo identico al original
7. **Restore PostgreSQL** en DB vacia reconstruye schema + datos
8. **Retention** elimina backups anteriores al umbral configurado
9. **Manifest invalido** (item con source inexistente) loguea error, continua con otros items

### Validacion Post-Backup (automatica, en cada ejecucion)

- `rclone check` compara checksums locales vs remotos
- Verificar que staging/ fue eliminado al finalizar
- Log incluye resumen: N items OK, N skipped, N errores

## Security Considerations

### Threat Model

| Amenaza | Probabilidad | Impacto | Mitigacion |
|---------|-------------|---------|-----------|
| Secretos en plaintext en staging/ | Media | Alto | Staging efimero, borrado en finally{} block. Staging en dir temporal del OS, no en path predecible |
| rclone.conf comprometido (contiene GDrive tokens + crypt password) | Baja | Critico | rclone.conf gitignored. File permissions restrictivos. Es el unico archivo que NO se sube a la nube |
| Backup corrupto sin deteccion | Baja | Alto | rclone check post-upload. Log de verificacion |
| Acceso no autorizado a GDrive | Baja | Alto | rclone crypt para secretos. GDrive con 2FA habilitado |
| Staging no se borra por crash del script | Media | Medio | try/finally en PowerShell. Cleanup al inicio de la siguiente ejecucion (si staging/ existe, borrarlo antes de empezar) |

### Reglas de Seguridad

1. **Secretos nunca en plaintext en la nube.** Todo item type=secret pasa por rclone crypt.
2. **rclone.conf es el asset mas critico.** Contiene GDrive OAuth tokens y crypt password. No se commitea, no se sube, no se copia.
3. **Staging cleanup en finally{} block.** Incluso si el script falla, staging/ se borra.
4. **Cleanup defensivo al inicio.** Si staging/ existe al arrancar, borrarlo (residuo de crash anterior).
5. **Log no contiene secretos.** Loguear paths y resultados, nunca contenido de archivos sensibles.
6. **Items con source inexistente no son error fatal.** Log warning, continuar. Evita que un path cambiado rompa todo el backup.

### Archivos Sensibles NO Versionados

| Archivo | Contenido | Proteccion |
|---------|-----------|-----------|
| `config/rclone.conf` | GDrive OAuth + crypt password | .gitignore |
| `staging/` | Datos temporales (puede incluir secrets) | .gitignore + cleanup automatico |
| `logs/` | Paths del sistema (no secretos, pero info interna) | .gitignore |

## Decisiones Arquitectonicas Vigentes

| Decision | Fecha | Razon |
|----------|-------|-------|
| PowerShell como lenguaje principal | 2026-03-18 | Nativo Windows, Task Scheduler, zero-dependency |
| Google Drive via rclone | 2026-03-18 | $0 costo, infraestructura existente |
| rclone crypt para secretos | 2026-03-18 | Integrado en rclone, sin herramientas extra |
| Manifest JSON externo | 2026-03-18 | Separar inventario de logica, extensible |
| `wsl docker exec` desde PS1 | 2026-03-18 | Un solo script, sin coordinacion multi-lenguaje |
| sqlite3 .backup API | 2026-03-18 | Safe para archivos en uso concurrente |

## Technical Debt

(Proyecto nuevo, sin TD registrado)
