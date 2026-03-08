### REC-004: Sin timeout ni manejo de redirects en HTTP request del parser

**Points:** 2 | **Priority:** HIGH | **DoR Level:** L1
**Epic:** EPIC-002 - Mejora del Importador de Recetas

**As a** usuario de Recetario
**I want** que las solicitudes HTTP del importador tengan timeout y limites razonables
**So that** la app no se quede colgada indefinidamente cuando un sitio no responde o responde con contenido excesivo

#### Acceptance Criteria

**AC1: Timeout en requests HTTP**
- Given que el usuario ingresa una URL para importar
- When el servidor no responde dentro de 10 segundos
- Then la solicitud se cancela automaticamente
- And se muestra un mensaje de error indicando que el sitio no respondio a tiempo

**AC2: Limite de tamanio de respuesta**
- Given que el servidor responde con un contenido mayor a 5 MB
- When la app recibe la respuesta
- Then se trunca o rechaza la respuesta
- And se muestra un mensaje indicando que la pagina es demasiado grande para procesar

**AC3: Headers apropiados en la solicitud**
- Given que el usuario inicia una importacion por URL
- When la app hace la solicitud HTTP
- Then incluye un header `Accept: text/html` para indicar el tipo de contenido esperado
- And incluye un `User-Agent` razonable que no sea bloqueado por WAFs comunes

**AC4: Manejo de errores HTTP**
- Given que el servidor responde con un codigo de error (4xx, 5xx)
- When la app recibe la respuesta
- Then se muestra un mensaje especifico segun el codigo (404: pagina no encontrada, 403: acceso denegado, 500: error del servidor)

#### Technical Notes

- Archivo afectado: `lib/features/import/data/services/recipe_parser.dart` (lineas 37-44)
- Reemplazar `http.get(uri)` por `http.get(uri).timeout(Duration(seconds: 10))`
- Agregar headers: `{'Accept': 'text/html', 'User-Agent': 'Recetario/1.0'}`
- Para limite de tamanio, usar `http.Client` con `maxContentLength` o verificar `content-length` header
- Manejar `TimeoutException`, `SocketException`, `HttpException`

#### DoD

- [ ] Codigo implementado con timeout, headers y limite de tamanio
- [ ] Tests unitarios para timeout y errores HTTP (mock http client)
- [ ] Manual testing con URL lenta y URL inexistente
- [ ] Build 0 warnings
