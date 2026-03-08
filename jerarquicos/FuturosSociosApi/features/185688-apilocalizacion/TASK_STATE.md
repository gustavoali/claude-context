# Estado - feature/185688_reemplazo_llamada_dao_x_ApiLocalization
**Actualizacion:** 2026-02-25 | **Historia:** FS-001

## Resumen
Reemplazar consultas locales a DB (LocalidadDAO, ProvinciaDAO) por llamadas HTTP a ApiLocalizacion en el endpoint GET /api/Aplicacion/OpcionesGenerales.

## Estado: Implementacion completa, pendiente fixes de code review

### Commit actual: `7437db0`
- ApiLocalizacionClient implementado en BackendServices (Config, Interface, Service, Models)
- AplicacionController.ObtenerOpcionesGenerales usa ApiLocalizacion
- FuturosSociosApiMovilSettings con RutaApiLocalizacion
- Startup.cs con registro DI + HttpClient
- 5 appsettings configurados por ambiente
- Cambio no commiteado: `&OrderBy=Nombre+ASC` en query strings (usuario va a commitear)

### Build: OK
- ReportingApi falla (pre-existente, .NET Framework 4.7 sin VS targets)
- BackendServices, FuturosSociosApiMovil, Tests: compilan correctamente

### Code Review: CHANGES REQUIRED
**Criticos (fix antes de merge):**
- C1: El catch en ApiLocalizacionClient silencia errores sin setear `response.Success = false` ni `ErrorMessage`. Funciona por accidente (bool default = false). Opciones: (A) agregar `throw;` como patron existente, o (B) setear response completo.
- C2: ObtenerOpcionesGenerales no tiene early return en errores. Si localidades/provincias fallan, sigue ejecutando todo y al final setea `Exito = true`, sobreescribiendo errores. Agregar `return respuesta;` despues de cada check de error.

**Importantes (recomendados):**
- I1: Mapeo manual vs AutoMapper (aceptable por logica custom)
- I2: PageSize hardcodeado (10000/100) - extraer a constantes
- I3: AuthenticationHeaderValue mal usado (defecto heredado de todos los clientes)

**Sugerencia:** Ejecutar localidades y provincias en paralelo con `Task.WhenAll`

## Artefactos
- Colecciones Postman: `postman/` (4 archivos: collection + 3 environments)

## Proximos Pasos
1. Resolver C1 y C2 del code review
2. Ajustar URL base en FeatureBranch.postman_environment.json segun donde se levante
3. Testear con Postman: comparar Staging (antes) vs Feature Branch (despues)
4. PR a develop
