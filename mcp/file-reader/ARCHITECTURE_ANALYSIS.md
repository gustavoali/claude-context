# Arquitectura - File Reader
**Version:** 0.1.0 | **Fecha:** 2026-02-16

---

## Diagrama de Componentes

```
                    +-------------------+
                    |   Client (Agent   |
                    |   or Script)      |
                    +--------+----------+
                             | HTTP (localhost:8000)
                             v
                    +-------------------+
                    |   FastAPI App      |
                    |  (file_tool_server)|
                    +-------------------+
                    |  Auth Middleware   |  <-- X-API-Key validation
                    +-------------------+
                    |  Route Handler     |  <-- GET /read, GET /health
                    +--------+----------+
                             |
               +-------------+-------------+
               v                           v
    +-------------------+       +-------------------+
    |  Path Validator   |       |  Config Module    |
    |  - resolve path   |       |  - allowed_dirs   |
    |  - check sandbox  |       |  - allowed_exts   |
    |  - check ext      |       |  - max_file_size  |
    |  - check size     |       |  - api_key        |
    +--------+----------+       +-------------------+
             |
             v
    +-------------------+
    |  Filesystem       |       +-------------------+
    |  (read-only)      |       |  Access Logger    |
    +-------------------+       |  (logs/access.log)|
                                +-------------------+
```

## Data Flow

```
1. Client --> GET /read?path=sandbox/file.txt
              Header: X-API-Key: <key>

2. Auth Middleware:
   - Extract X-API-Key header
   - Compare against configured key (constant-time)
   - 401 if missing/invalid --> STOP

3. Route Handler receives validated request

4. Path Validator:
   a. Normalize path (resolve .., symlinks)
   b. Check resolved path starts with an allowed base dir
   c. Check file extension against allowlist
   d. Check file exists
   e. Check file size <= 2MB
   f. 400/403/404/413 on failure --> STOP

5. Read file content (UTF-8, with fallback to latin-1)

6. Log access: timestamp, client_ip, path, status, size

7. Return JSON response:
   { "path": "sandbox/file.txt", "content": "...", "size": 1234,
     "extension": ".txt", "encoding": "utf-8" }
```

## Folder Structure

```
/file-reader
  file_tool_server.py       # FastAPI app, routes, auth middleware
  config.py                 # Settings via env vars / .env
  path_validator.py         # Path resolution, sandbox check, ext check
  access_logger.py          # Structured access logging
  requirements.txt          # Dependencies
  .env.example              # Documented config template
  .gitignore
  tests/
    conftest.py             # Fixtures: test client, temp sandbox, env vars
    test_read_endpoint.py   # Happy path + error cases
    test_path_validator.py  # Unit tests for path validation
    test_auth.py            # Auth middleware tests
    test_security.py        # Traversal attempts, symlink attacks
  logs/                     # Git-ignored, created at startup
    .gitkeep
  sandbox/                  # Default sandbox directory
    .gitkeep
```

---

## ADRs

### ADR-001: Estructura del Proyecto - Flat vs Modular
**Status:** PROPUESTO
**Contexto:** El seed document propone todo en `file_tool_server.py`. Necesitamos decidir si mantener flat (1-2 archivos) o separar en modulos.
**Opciones evaluadas:**
1. **Single file** (`file_tool_server.py` con todo) - Pros: simplicidad maxima, facil de leer de un vistazo. Cons: dificil de testear unitariamente, path validator mezclado con routing.
2. **Flat modular** (4 archivos: server, config, validator, logger) - Pros: cada archivo < 100 lineas, testeable por separado, sin packages ni `__init__.py`. Cons: ligeramente mas archivos.
3. **Package structure** (`app/` con subdirectorios) - Pros: escalable. Cons: over-engineering para un micro-servicio de 1 endpoint.
**Decision:** Opcion 2 - Flat modular. Cuatro archivos en raiz. Suficiente separacion para testing sin complejidad de packages. Si el roadmap evolutivo requiere mas endpoints, migrar a package.
**Consecuencias:**
- (+) Cada modulo testeable de forma independiente
- (+) Menos de 100 lineas por archivo
- (-) Import paths simples pero requieren que la raiz sea el working directory

### ADR-002: Estrategia de Autenticacion
**Status:** PROPUESTO
**Contexto:** El servidor necesita autenticar requests. Solo se espera un unico cliente (agente/script interno).
**Opciones evaluadas:**
1. **API Key en .env, validacion en middleware** - Pros: simple, estandar, configurable. Cons: key en plaintext en disco (mitigado: .env en .gitignore, solo localhost).
2. **API Key hardcoded en codigo** - Pros: cero config. Cons: no configurable, imposible rotar sin deploy, riesgo de commit accidental.
3. **mTLS / certificados** - Pros: seguridad fuerte. Cons: complejidad desproporcionada para localhost.
**Decision:** Opcion 1. API Key leida de variable de entorno `FILE_READER_API_KEY`, validada en un middleware FastAPI con comparacion constant-time (`hmac.compare_digest`). Si la variable no esta seteada, el servidor NO arranca (fail-fast).
**Consecuencias:**
- (+) Key rotable sin cambiar codigo
- (+) Fail-fast previene arranque inseguro
- (-) Requiere archivo .env o export manual

### ADR-003: Estrategia de Validacion de Paths
**Status:** PROPUESTO
**Contexto:** La principal superficie de ataque es path traversal. Necesitamos garantizar que solo se lean archivos dentro de directorios autorizados.
**Opciones evaluadas:**
1. **`pathlib.Path.resolve()` + `str.startswith()`** - Pros: resuelve `..`, symlinks, normaliza. Cons: `startswith` en strings puede fallar con prefijos parciales (ej: `/sandbox2` matchea `/sandbox`).
2. **`os.path.realpath()` + `os.path.commonpath()`** - Pros: `commonpath` es mas robusto que `startswith`, handles edge cases. Cons: levemente mas verboso.
3. **Chroot/namespace isolation** - Pros: seguridad a nivel OS. Cons: requiere privilegios, complejidad operativa innecesaria para localhost.
**Decision:** Opcion 2 como base, combinada con `Path.resolve()` de pathlib. Flujo: resolver path absoluto con `Path.resolve(strict=False)`, luego verificar con `os.path.commonpath([resolved, allowed_dir]) == str(allowed_dir)`. Adicionalmente, rechazar symlinks que apunten fuera del sandbox.
**Consecuencias:**
- (+) Robusto contra traversal, prefijos parciales y symlinks
- (+) Sin dependencias externas
- (-) Requiere tests exhaustivos de edge cases

### ADR-004: Estrategia de Logging
**Status:** PROPUESTO
**Contexto:** Necesitamos auditar accesos para seguridad y debugging.
**Opciones evaluadas:**
1. **Python `logging` module a archivo rotado** - Pros: stdlib, RotatingFileHandler previene disco lleno, formato configurable. Cons: no structured por default (mitigado: usar JSON formatter).
2. **Libreria structlog** - Pros: structured logging nativo, bonito en consola. Cons: dependencia adicional para un proyecto micro.
3. **Print statements** - Pros: cero config. Cons: no rotacion, no niveles, no timestamps automaticos.
**Decision:** Opcion 1. Usar `logging` stdlib con formato JSON manual (un dict serializado por linea). `RotatingFileHandler` con max 5MB, 3 backups. Dos loggers: `access` (cada request) y `app` (errores, startup).
**Consecuencias:**
- (+) Cero dependencias adicionales
- (+) Rotacion previene llenado de disco
- (-) JSON formatting manual (aceptable para volumen bajo)

### ADR-005: Manejo de Configuracion
**Status:** PROPUESTO
**Contexto:** El servidor necesita configuracion para API key, directorios permitidos, extensiones, limites.
**Opciones evaluadas:**
1. **Pydantic Settings (BaseSettings + .env)** - Pros: validacion de tipos, .env automatico, documentable. Cons: depende de pydantic-settings (ya incluido con FastAPI).
2. **`os.environ` directo con defaults** - Pros: cero dependencias. Cons: sin validacion de tipos, facil olvidar un default, parsing manual de listas.
3. **Archivo YAML/TOML** - Pros: legible. Cons: dependencia extra, mas complejo que .env para config simple.
**Decision:** Opcion 1. Pydantic `BaseSettings` con `model_config = SettingsConfigDict(env_file=".env")`. Valores con prefijo `FILE_READER_`. Listas (allowed_dirs, allowed_exts) como strings separados por coma, parseados en validator.
**Consecuencias:**
- (+) Validacion automatica al arrancar
- (+) Defaults documentados en la clase
- (+) .env file support sin codigo adicional
- (-) Minima dependencia en pydantic-settings (ya presente via FastAPI)

---

## Interfaces y Contratos

### GET /health
**Descripcion:** Health check. Sin autenticacion.
```
Response 200:
{ "status": "ok", "version": "0.1.0" }
```

### GET /read
**Descripcion:** Lee un archivo del sandbox.
**Headers:** `X-API-Key: <key>` (obligatorio)
**Query Params:** `path` (string, obligatorio) - ruta relativa al sandbox o absoluta dentro de un allowed_dir.

```
Response 200 (exito):
{
  "path": "sandbox/example.txt",
  "content": "file content here...",
  "size": 1234,
  "extension": ".txt",
  "encoding": "utf-8"
}

Response 400 (path no proporcionado o invalido):
{
  "error": "invalid_path",
  "detail": "Path parameter is required"
}

Response 401 (auth fallida):
{
  "error": "unauthorized",
  "detail": "Invalid or missing API key"
}

Response 403 (path fuera del sandbox):
{
  "error": "forbidden",
  "detail": "Path is outside allowed directories"
}

Response 404 (archivo no encontrado):
{
  "error": "not_found",
  "detail": "File does not exist"
}

Response 413 (archivo muy grande):
{
  "error": "file_too_large",
  "detail": "File exceeds 2MB limit"
}

Response 422 (extension no permitida):
{
  "error": "extension_not_allowed",
  "detail": "Extension .exe is not in the allowlist"
}
```

### Error Format (consistente en todos los endpoints)
```json
{
  "error": "<error_code>",
  "detail": "<human_readable_message>"
}
```

---

## Configuracion (.env.example)

```bash
# Obligatorio - el servidor no arranca sin esto
FILE_READER_API_KEY=cambiar-esta-key-antes-de-usar

# Directorios permitidos (comma-separated, absolutos)
FILE_READER_ALLOWED_DIRS=C:/mcp/file-reader/sandbox

# Extensiones permitidas (comma-separated, con punto)
FILE_READER_ALLOWED_EXTENSIONS=.txt,.md,.json,.csv,.xml,.yaml,.yml,.log,.py,.js,.ts,.html,.css

# Limite de tamano en bytes (default: 2MB)
FILE_READER_MAX_FILE_SIZE=2097152

# Logging
FILE_READER_LOG_DIR=logs
FILE_READER_LOG_MAX_BYTES=5242880
FILE_READER_LOG_BACKUP_COUNT=3

# Server
FILE_READER_HOST=127.0.0.1
FILE_READER_PORT=8000
```

---

## Testing Strategy

**Framework:** pytest + httpx (AsyncClient de FastAPI TestClient)
**Coverage target:** >80% (proyecto de seguridad, coverage alta justificada)

| Suite | Archivo | Cobertura |
|-------|---------|-----------|
| Auth | test_auth.py | Middleware: key valida, invalida, ausente, header incorrecto |
| Path Validation | test_path_validator.py | resolve, traversal, symlinks, ext check, size check |
| Read Endpoint | test_read_endpoint.py | Happy path, errores, encodings, archivos vacios |
| Security | test_security.py | Path traversal vectors, null bytes, unicode tricks |

**Test fixtures:**
- Sandbox temporal (`tmp_path`) con archivos de prueba
- Env vars mockeados para config
- FastAPI TestClient sin necesidad de servidor corriendo

**Vectores de seguridad a testear:**
- `../../../etc/passwd`
- `sandbox/../../../etc/passwd`
- Symlinks apuntando fuera del sandbox
- Null bytes en path (`file%00.txt`)
- Unicode normalization attacks
- Extensiones dobles (`file.txt.exe`)
- Paths muy largos (>260 chars en Windows)

---

## Performance Targets

| Metrica | Target | Justificacion |
|---------|--------|---------------|
| Latencia p95 (archivo 100KB) | < 50ms | Lectura local + overhead HTTP minimo |
| Latencia p95 (archivo 2MB) | < 200ms | Lectura secuencial, sin streaming |
| Throughput | > 100 req/s | uvicorn async, un solo cliente esperado |
| Startup time | < 2s | Config validation + logger setup |
| Memory usage | < 50MB RSS | Archivo se lee completo en memoria (max 2MB) |

**Nota:** No se requiere optimizacion de performance. Estos targets son para detectar regresiones, no para tuning activo.

---

## Seguridad

### Superficie de Ataque

| Vector | Riesgo | Control |
|--------|--------|---------|
| Path traversal (`../`) | Alto | Path resolution + commonpath check |
| Symlink escape | Medio | Resolver symlinks, verificar destino real |
| API Key brute force | Bajo | Solo localhost, constant-time compare |
| Lectura de secretos (.env, keys) | Alto | Extension allowlist, pattern exclusion |
| Denegacion de servicio | Bajo | Solo localhost, file size limit |
| Inyeccion en path | Medio | No shell execution, pathlib only |
| Archivo binario como texto | Bajo | Extension allowlist filtra la mayoria |

### Controles Implementados

1. **Binding a 127.0.0.1** - No accesible desde red
2. **API Key obligatoria** - Fail-fast si no configurada
3. **Constant-time comparison** - Previene timing attacks
4. **Path resolution** - `Path.resolve()` elimina traversal
5. **Commonpath check** - Verifica containment real, no string prefix
6. **Extension allowlist** - Solo extensiones de texto explicitamente permitidas
7. **Size limit** - 2MB previene lecturas masivas
8. **Access logging** - Auditoria de cada request
9. **No shell execution** - Toda operacion via pathlib/os, nunca subprocess

### Patrones Sensibles Excluidos

Archivos que NUNCA se sirven aunque esten en el sandbox y tengan extension permitida:
- `*.env*` (variables de entorno)
- `*secret*`, `*credential*`, `*password*` (por nombre)
- `.git/` (directorio git)

---

## Decisiones Arquitectonicas Vigentes

| Decision | Fecha | Razon |
|----------|-------|-------|
| ADR-001: Flat modular (4 archivos) | 2026-02-16 | Balance entre testabilidad y simplicidad |
| ADR-002: API Key en .env | 2026-02-16 | Simple, rotable, fail-fast |
| ADR-003: resolve + commonpath | 2026-02-16 | Robusto contra traversal y prefijos parciales |
| ADR-004: stdlib logging JSON | 2026-02-16 | Cero dependencias, rotacion incluida |
| ADR-005: Pydantic Settings | 2026-02-16 | Validacion automatica, ya incluido con FastAPI |

---

## Stack

| Tecnologia | Version | Proposito |
|------------|---------|-----------|
| Python | 3.11+ | Runtime |
| FastAPI | 0.115+ | Framework HTTP |
| uvicorn | 0.34+ | ASGI server |
| pydantic-settings | 2.x | Configuracion tipada |
| pytest | 8.x | Testing |
| httpx | 0.28+ | Test client async |

---

## Technical Debt Activo

Ninguno (proyecto nuevo, pre-development).

---

## Roadmap Evolutivo (fuera de scope inicial)

| Fase | Descripcion | Impacto en Arquitectura |
|------|-------------|------------------------|
| Search endpoint | GET /search con glob patterns | Nuevo route handler, reusar path_validator |
| MCP integration | Exponer como MCP server | Agregar transport layer, mantener core |
| PDF/DOCX extraction | Leer contenido de binarios | Nuevo modulo extractor, dependencias nuevas |
| LLM chunking | Dividir contenido en chunks | Modulo de chunking post-lectura |
