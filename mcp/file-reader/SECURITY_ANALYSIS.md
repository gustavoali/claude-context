# Security Analysis - File Reader
**Fecha:** 2026-02-16 | **Reviewer:** code-reviewer (modo seguridad)
**Base:** ARCHITECTURE_ANALYSIS.md v0.1.0, SEED_DOCUMENT.md

---

## 1. Threat Model (STRIDE)

| Categoria | Amenaza | Vector | Prob. | Impacto | Mitigacion |
|-----------|---------|--------|-------|---------|------------|
| **Spoofing** | Suplantacion de cliente | Request desde otro proceso en localhost con key robada | Baja | Alto | API Key en .env (no en codigo), permisos restrictivos en .env (600) |
| **Spoofing** | Key extraida de memoria | Dump de proceso o /proc/self/environ | Baja | Alto | Fuera de scope para localhost; documentar riesgo residual |
| **Tampering** | Modificacion de config en runtime | Edicion de .env mientras el server corre | Baja | Alto | Config se carga al startup; restart requerido para cambios |
| **Tampering** | Modificacion de archivos en sandbox | Proceso externo altera contenido | Media | Medio | Fuera de scope (read-only server); documentar que integridad del sandbox es responsabilidad del host |
| **Repudiation** | Accesos no rastreables | Requests sin logging | Baja | Medio | Access logger JSON en cada request, incluyendo failures |
| **Repudiation** | Log tampering | Proceso con acceso a logs/ los edita | Baja | Medio | SHOULD: permisos restrictivos en directorio logs/ |
| **Info Disclosure** | Path traversal | ../sequences, encoding tricks, symlinks | Alta | Alto | resolve() + commonpath + symlink check (ver seccion 3) |
| **Info Disclosure** | Lectura de secretos en sandbox | .env, keys, credentials dentro de allowed dirs | Media | Alto | Pattern exclusion por nombre + extension allowlist |
| **Info Disclosure** | Error messages revelan paths internos | Stack traces o detail messages con rutas absolutas | Media | Bajo | MUST: sanitizar error messages, nunca exponer paths absolutos del host |
| **DoS** | Lecturas masivas repetidas | Loop de requests al archivo de 2MB | Baja | Bajo | Solo localhost; COULD: rate limiting opcional |
| **DoS** | Log flooding | Requests invalidos en loop llenan disco | Baja | Medio | RotatingFileHandler (5MB x 3 backups = 15MB max) |
| **EoP** | Escape de sandbox via path manipulation | Traversal, symlinks, junctions | Alta | Alto | Controles multicapa (ver seccion 3) |

---

## 2. OWASP Top 10 Evaluation

| # | Vulnerabilidad | Aplica | Estado | Notas |
|---|---------------|--------|--------|-------|
| A01 | Broken Access Control | Si | Mitigado | API Key + path sandbox. MUST: validar que /health no exponga info sensible |
| A02 | Cryptographic Failures | Parcial | Aceptable | Key en plaintext en .env; aceptable para localhost. No hay datos cifrados |
| A03 | Injection | Si | Mitigado | No hay shell execution, no SQL, no templates. pathlib-only es correcto |
| A04 | Insecure Design | No | N/A | Diseño es security-first para el caso de uso |
| A05 | Security Misconfiguration | Si | Mitigado con condiciones | Fail-fast si no hay key. MUST: no servir con debug=True en produccion |
| A06 | Vulnerable Components | Parcial | Monitorear | FastAPI/uvicorn son mantenidos. SHOULD: pinear versiones en requirements.txt |
| A07 | Auth Failures | Si | Mitigado | Constant-time compare, fail-fast. Key unica es suficiente para localhost |
| A08 | Software/Data Integrity | No | N/A | No hay deserialization de datos del cliente mas alla del query param |
| A09 | Logging Failures | Si | Mitigado | Access logger cubre requests exitosos y fallidos |
| A10 | SSRF | No | N/A | El servidor no hace requests salientes |

---

## 3. Path Traversal - Deep Analysis

| Vector | Ejemplo | Mitigacion en arquitectura | Riesgo residual |
|--------|---------|---------------------------|-----------------|
| Dot-dot sequences | `../../etc/passwd` | `Path.resolve()` colapsa `..` antes de commonpath check | Ninguno si resolve() se ejecuta primero |
| URL encoding | `%2e%2e%2f` | FastAPI/Starlette decodifica query params automaticamente; resolve() opera sobre el string decodificado | Bajo. MUST: testear que FastAPI decodifica antes de llegar al validator |
| Double URL encoding | `%252e%252e` | FastAPI decodifica una vez. Si el path llega con `%2e%2e` literal, resolve() lo trata como nombre de archivo (no traversal) | MUST: testear este caso explicitamente |
| Null bytes | `file%00.txt` | Python 3 raise ValueError en operaciones de path con null bytes. MUST: capturar ValueError y retornar 400 | Ninguno si se captura la excepcion |
| Unicode normalization | Caracteres que normalizan a `.` o `/` | `Path.resolve()` usa el filesystem subyacente. En Windows, NTFS normaliza. SHOULD: rechazar paths con caracteres no-ASCII como hardening adicional |
| Symlinks | Link dentro del sandbox apuntando afuera | ADR-003: resolver symlinks y verificar destino real con commonpath | Ninguno si se verifica post-resolve |
| Junction points (Windows) | NTFS junction apuntando afuera | `Path.resolve()` en Windows sigue junctions. Misma proteccion que symlinks: el resolved path se verifica con commonpath | MUST: testear con junctions reales en CI Windows |
| Long paths (Windows) | Path >260 chars o con `\\?\` prefix | MUST: rechazar paths que excedan 260 chars o contengan `\\?\`. Python puede manejarlos pero son vector de bypass | Medio si no se valida longitud |
| Case sensitivity (Windows) | `Sandbox/../SANDBOX/../../secret` | `Path.resolve()` normaliza case en Windows (devuelve case real del filesystem). commonpath opera sobre resolved paths | Bajo. SHOULD: testear case variations en CI |
| Trailing dots/spaces (Windows) | `file.txt.` o `file.txt ` (NTFS los stripea) | NTFS silenciosamente remueve trailing dots/spaces. `Path.resolve()` devuelve el path real | MUST: testear que `file.txt.` no bypasea extension check |
| Alternate Data Streams (Windows) | `file.txt:secret_stream` | NTFS ADS. MUST: rechazar paths que contengan `:` (excepto drive letter) | Alto si no se valida |

**Recomendacion critica:** La combinacion resolve() + commonpath es solida, pero DEBE complementarse con:
1. Rechazo de null bytes (capturar ValueError)
2. Rechazo de `:` en path (excepto drive letter en posicion 1)
3. Limite de longitud de path (260 chars)
4. Tests especificos para cada vector en Windows

---

## 4. Secret Exposure Analysis

### Patrones actuales (del ARCHITECTURE_ANALYSIS)
- `*.env*`, `*secret*`, `*credential*`, `*password*`, `.git/`

### Patrones adicionales recomendados (MUST)
- `*token*`, `*apikey*`, `*api_key*`, `*api-key*`
- `*.pem`, `*.key`, `*.p12`, `*.pfx`, `*.jks` (certificados/keys)
- `*id_rsa*`, `*id_ed25519*`, `*.ppk` (SSH keys)
- `*.keystore`, `*.truststore`
- `*aws_access*`, `*aws_secret*`

### Patrones adicionales recomendados (SHOULD)
- `.npmrc`, `.pypirc`, `.netrc` (tokens de package managers)
- `*kubeconfig*`, `*.kube/config`
- `.docker/config.json`
- `*vault*token*`

### Implementacion
MUST: pattern matching case-insensitive (Windows filenames son case-insensitive).
MUST: verificar contra el basename del archivo, no el path completo (evitar false positives con directorios que contengan "password" en el nombre).
SHOULD: log cuando se bloquea un archivo por pattern sensible (auditoria).

---

## 5. Recomendaciones de Hardening (priorizadas)

### MUST (bloquean deployment si no se implementan)
1. **Sanitizar error messages** - Nunca exponer paths absolutos del host en responses. Devolver solo el path relativo que envio el cliente.
2. **Rechazar Alternate Data Streams** - Validar que el path no contenga `:` (excepto drive letter `C:`).
3. **Capturar null byte ValueError** - Python 3 lo hace, pero debe ser un catch explicito con response 400.
4. **Limitar longitud de path** - Rechazar paths > 260 caracteres.
5. **Ampliar patrones sensibles** - Agregar los patrones de la seccion 4 marcados como MUST.
6. **Pattern matching case-insensitive** - Windows no distingue case en filenames.
7. **Doble encoding test** - Verificar que `%252e%252e` no bypasea controles.
8. **Permisos del .env** - Documentar que .env debe tener permisos 600 (o ACL restrictivo en Windows).

### SHOULD (recomendados, implementar si el timeline lo permite)
9. **Rechazar caracteres non-ASCII en paths** - Elimina vectores de Unicode normalization.
10. **Rate limiting basico** - Max 100 req/s por IP (protege contra log flooding).
11. **Health endpoint sin version** - O mover version detras de auth. Exponer version facilita fingerprinting.
12. **Log permisos restrictivos** - Directorio logs/ con permisos 700.
13. **Pinear dependencias** - `requirements.txt` con versiones exactas + hashes.
14. **Security headers** - `X-Content-Type-Options: nosniff`, `Cache-Control: no-store`.

### COULD (nice-to-have para hardening extra)
15. **Content-type sniffing** - Verificar que el contenido del archivo coincide con la extension (magic bytes).
16. **Request ID** - UUID por request para correlacion en logs.
17. **Startup self-test** - Verificar que los allowed_dirs existen y son accesibles al arrancar.

---

## 6. Veredicto

**SEGURA CON CONDICIONES**

La arquitectura propuesta es solida para el caso de uso (servidor local localhost-only). Los controles de autenticacion, path validation y logging son apropiados. Las decisiones arquitectonicas (ADR-002 constant-time, ADR-003 resolve+commonpath) son correctas.

**Condiciones para considerar SEGURA:**
1. Implementar los 8 items MUST de la seccion 5 (especialmente ADS, null bytes, error sanitization)
2. Tests de seguridad exhaustivos en Windows (junctions, ADS, case, trailing dots)
3. Patrones sensibles ampliados con matching case-insensitive

**Riesgo residual aceptado:**
- API Key en plaintext en .env (aceptable para localhost)
- No hay proteccion contra procesos maliciosos con acceso al mismo host (fuera de scope)
- Integridad del sandbox es responsabilidad del operador, no del servidor

---

**Lineas:** ~150 | **Generado:** 2026-02-16
