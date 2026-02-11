# Code Review Rules - Jerarquicos

**Version:** 1.1
**Ultima actualizacion:** 2026-02-11
**Origen:** Observaciones de code review de Guillermo Loinaz + convenciones del equipo

---

## Reglas

### R001: Usar namespaces en lugar de nombres fully qualified
**Severidad:** Media
**Aplica a:** Todos los archivos .cs

No usar nombres de tipo fully qualified (ej: `System.Threading.Tasks.Task<T>`).
En su lugar, agregar el `using` correspondiente y usar el nombre corto.

**Incorrecto:**
```csharp
public async System.Threading.Tasks.Task<HttpResponseMessage> MiMetodo()
```

**Correcto:**
```csharp
using System.Threading.Tasks;
// ...
public async Task<HttpResponseMessage> MiMetodo()
```

---

### R002: Reutilizar recursos existentes en archivos .resx
**Severidad:** Alta
**Aplica a:** Excepciones.resx, Mensajes.resx, y todos los archivos de recursos

Antes de crear un nuevo recurso en un archivo .resx, verificar si ya existe uno con el mismo proposito o significado similar.
Crear recursos duplicados con diferentes nombres genera confusion y dificulta el mantenimiento.

**Incorrecto:** Crear "SinDocumentos" cuando ya existe "ErrorAlDescargarArchivo"
**Correcto:** Reutilizar "ErrorAlDescargarArchivo"

---

### R003: Nombres de carpetas, namespaces y clases en singular para integraciones de API
**Severidad:** Alta
**Aplica a:** BackendServices/, integraciones externas

La convencion del proyecto es usar nombres **en singular** para carpetas de integracion, namespaces y clases.
Seguir el patron existente (ej: `ApiRecetaElectronica`, no `ApiRecetasElectronicas`).

**Incorrecto:** `ApiReportes`, `ApiReportesClient`, `IApiReportesClient`
**Correcto:** `ApiReporte`, `ApiReporteClient`, `IApiReporteClient`

---

### R004: Ubicar configuraciones en la seccion correcta de Web.config
**Severidad:** Media
**Aplica a:** Web.config (appSettings)

El Web.config tiene secciones organizadas con comentarios HTML (`<!-- SECCION -->`).
Al agregar nuevas keys, ubicarlas en la seccion tematica correspondiente:
- URLs de APIs van en `<!--URLS APIS-->`
- Configuracion de servidor de reportes va en `<!--CONFIGURACION SERVIDOR API REPORTES-->`
- Etc.

No mezclar keys de diferentes categorias en una misma seccion.

---

### R005: Simplificar nombres de clase, no expandirlos
**Severidad:** Media
**Aplica a:** Todos los archivos .cs

Si un `using` ya resuelve el namespace, no reemplazarlo por el nombre fully qualified.
Si se necesita el fully qualified por ambiguedad, documentar por que con un comentario.

**Incorrecto:** Cambiar `ConfigurationManager` a `System.Configuration.ConfigurationManager`
**Correcto:** Mantener `ConfigurationManager` con `using System.Configuration;`

---

### R006: Naming de keys de URLs de APIs en Web.config sigue patron UrlApi...
**Severidad:** Media
**Aplica a:** Web.config (appSettings), clases de configuracion de servicios

Las keys de URLs de APIs en Web.config siguen el patron `UrlApi[NombreServicio]`, sin "Base" ni prefijos extra.
Respetar la convencion existente en la seccion `<!--URLS APIS-->`.

**Incorrecto:** `UrlBaseApiReporte`
**Correcto:** `UrlApiReporte`

Patron de referencia:
```xml
<add key="UrlApiGS" value="..." />
<add key="UrlApiRecetaElectronica" value="..." />
<add key="UrlApiReporte" value="..." />
```

---

## Como agregar nuevas reglas

Al finalizar un code review donde se detecte un patron nuevo:

1. Asignar el siguiente ID disponible: R00N
2. Definir: Severidad (Alta/Media/Baja), Aplica a (scope)
3. Incluir ejemplo Incorrecto/Correcto
4. Agregar separador `---` entre reglas
5. Actualizar la fecha de ultima actualizacion del archivo
