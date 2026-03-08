### REC-007: No hay validacion de seguridad en URL import - SSRF potencial

**Points:** 2 | **Priority:** HIGH | **DoR Level:** L1
**Epic:** EPIC-002 - Mejora del Importador de Recetas

**As a** usuario de Recetario
**I want** que la app solo acepte URLs publicas HTTP/HTTPS para importar recetas
**So that** no se puedan explotar vulnerabilidades de SSRF accediendo a recursos internos o protocolos no seguros

#### Acceptance Criteria

**AC1: Solo se aceptan URLs con esquema HTTP o HTTPS**
- Given que el usuario ingresa una URL con esquema `file://`, `ftp://`, `javascript:` u otro
- When intenta iniciar la importacion
- Then la app rechaza la URL con mensaje "Solo se permiten URLs con http:// o https://"
- And no se realiza ninguna solicitud de red

**AC2: URLs de red local son rechazadas**
- Given que el usuario ingresa una URL apuntando a `localhost`, `127.0.0.1`, `10.x.x.x`, `172.16-31.x.x`, `192.168.x.x` o `0.0.0.0`
- When intenta iniciar la importacion
- Then la app rechaza la URL con mensaje "No se permiten URLs de red local"
- And no se realiza ninguna solicitud de red

**AC3: URLs validas se procesan normalmente**
- Given que el usuario ingresa una URL publica valida como `https://www.recetasgratis.net/receta-de-empanadas-123.html`
- When intenta iniciar la importacion
- Then la app procesa la URL normalmente sin bloquearla

**AC4: Validacion en el cliente antes del request**
- Given que se implementa la validacion
- When se analiza el flujo de ejecucion
- Then la validacion ocurre ANTES de hacer el `http.get`, no despues
- And la validacion esta en el servicio (recipe_parser.dart), no solo en la UI

#### Technical Notes

- Archivos afectados:
  - `lib/features/import/data/services/recipe_parser.dart` - Validacion antes del request
  - `lib/features/import/presentation/screens/url_import_screen.dart` - Validacion en UI para feedback inmediato
- Crear un metodo `_isUrlSafe(Uri uri)` que verifique:
  1. Esquema es `http` o `https`
  2. Host no es localhost, 127.0.0.1, ni rangos privados (RFC 1918)
  3. Host no es un IP literal IPv6 de loopback (::1)
- La validacion debe estar duplicada: en UI para UX y en servicio para seguridad

#### DoD

- [ ] Codigo implementado con validacion en servicio y UI
- [ ] Tests unitarios para cada tipo de URL rechazada y aceptada
- [ ] Manual testing con URLs locales y publicas
- [ ] Build 0 warnings
