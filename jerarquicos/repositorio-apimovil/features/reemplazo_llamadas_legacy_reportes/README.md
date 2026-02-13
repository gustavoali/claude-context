# Feature: Reemplazo de llamadas legacy a reportes

**Rama:** feature/reemplazo_llamadas_legacy_reportes
**Estado:** En Progreso - Requiere restaurar validaciones de ownership
**Fecha trabajo:** Febrero 2026

---

## Descripcion

Reemplazo de todas las llamadas legacy de generacion de reportes por llamadas al nuevo `ApiReportesClient` (HTTP REST). El proyecto tenia dos patrones legacy:

1. **Crystal Reports directo** (`CrystalDecisions.CrystalReports.Engine.ReportDocument`) - Carga .rpt en memoria, setea parametros, exporta a PDF
2. **ServiceFactory.ReportesApi** (`SolicitudReporte` + `ServiceFactory.ReportesApi.ReporteGenerico()`) - Proxy WCF intermedio

Ambos se reemplazan por: `new ApiReportesClient().GenerarReporteAsync(nombreReporte, parametros)`

---

## Estado por Controller

### Ya migrados (commits anteriores a esta sesion)

| Controller | Metodo | Reporte | Commit |
|---|---|---|---|
| CuentaCorrienteController | DescargarGastosDeSalud | ReporteCertificadoPagoServiciosSalud | 74d54313 |
| CuentaCorrienteController | DescargarResumenTarjeta | ReporteResumenTarjetaJS | 74d54313 |
| CuentaCorrienteController | DescargarDetallePlanSalud | ReporteDetallePlanSalud | 74d54313 |
| ComprasComerciosController | DescargarResumenTarjetaJSAsync | ReporteResumenTarjetaJS | 74d54313 |
| FacturacionController | DescargarComprobante | ReporteComprobanteElectronico | 74d54313 |

### Migrados en esta sesion (commit 97c8c858)

| Controller | Metodo | Reporte | Patron anterior | Validaciones |
|---|---|---|---|---|
| BoletaPagoController | DescargarBoletaPago | ReporteBoletaPago | ServiceFactory | Sin ownership (pre-existente) |
| GestionSolicitudesUtil | 3 metodos Generar* | Solicitudes varias | ServiceFactory | OK |
| GestionSolicitudesUtil | 3 metodos Descargar* | Solicitudes varias | ServiceFactory | OK |
| CredencialesController | DescargarProvisorio | ReporteCertificadoProvisorio | Crystal Reports | **OWNERSHIP ELIMINADO - RESTAURAR** |
| PracticasLiberadasController | DescargarComprobante | Liberada/RequiereAutorizacion | Crystal Reports | OK (WCF mantenido para seleccion reporte) |
| ReintegrosController | DescargarResumenAnualDeReintegros | ReporteResumenAnualReintegros | Crystal Reports | **LOGICA NEGOCIO ELIMINADA - RESTAURAR** |
| ReintegrosController | DescargarReintegro | ReporteReintegroLiquidado | Crystal Reports | **OWNERSHIP ELIMINADO - RESTAURAR** |

---

## Hallazgo critico: API Reportes NO valida

El servidor de API Reportes (C:\jerarquicos\apireportes) es un pass-through puro:
- Sin autenticacion (no tiene [Authorize])
- Sin validacion de ownership
- Sin filtrado de datos
- Solo valida que parametros obligatorios esten presentes

**Todas las validaciones de seguridad deben hacerse en ApiMovil ANTES de llamar a ApiReportesClient.**

---

## Validaciones a restaurar

### 1. CredencialesController.DescargarProvisorio

**Llamada WCF a restaurar:** `AgenteServiciosJs.Generico.Buscar(solicitud)` con CertificadoProvisorioDTO

**Validaciones:**
- Que el certificado exista (respuesta.Resultado == Exito)
- Que el DTO no sea vacio
- Que el certificado pertenezca al socio: `certificado.Socio.Numero == numeroSocio`

### 2. ReintegrosController.DescargarResumenAnualDeReintegros

**Llamada WCF a restaurar:** `AgenteServiciosJs.ReintegroRecibido.ObtenerReintegrosGrupoSocial(solicitud)`

**Validaciones/Logica:**
- Calcular fechaDesde/fechaHasta (logica especial para 2014)
- Filtrar reintegros con MontoLiquidado > 0
- Retornar NoContent si no hay reintegros liquidados

### 3. ReintegrosController.DescargarReintegro

**Llamada WCF a restaurar:** `AgenteServiciosJs.ReintegroRecibido.ObtenerDetalleReintegroLiquidado(solicitud)`

**Validaciones:**
- Que el reintegro exista
- Si es adherente (ordenSocio > 0): verificar que NumeroSocio Y OrdenSocio coincidan
- Si es titular (ordenSocio == 0): verificar que NumeroSocio coincida

---

## Enum ReporteEnums.NombreReporte

Valores agregados en esta rama:

```
ReporteBoletaPago
ReporteSolicitudDocumentacionFaltante
SolicitudServicioAnulacion
SolicitudServicioResolucion
ReporteCertificadoProvisorio
ReportePracticaLiberada
ReportePracticaRequiereAutorizacion
ReporteResumenAnualReintegros
ReporteReintegroLiquidado
```

---

## Historial de commits en la rama

| Commit | Descripcion | Nota |
|---|---|---|
| 2c37482e | reemplazo wcf por api reportes, creo apiclient | Crea BackendServices/ApiReportes/ |
| 74d54313 | reemplazo de todas las llamadas | Migra CuentaCorriente, ComprasComercios, elimina ReportesUtil |
| 732010d3 | cambios en la politica de dependencias de Crystal report | Config |
| 47882533 | cambios en reemplazos | Migra BoletaPago y GestionSolicitudes |
| 54ce6241 | Revert "cambios en reemplazos" | Revert por error |
| 97c8c858 | reemplazos | Re-aplica 47882533 + migra Credenciales, PracticasLiberadas, Reintegros |

---

## Archivos clave

### ApiMovil (cliente)
- `BackendServices/ApiReportes/Services/ApiReportesClient.cs` - Cliente HTTP
- `BackendServices/ApiReportes/Enums/ReporteEnums.cs` - Catalogo de reportes
- `BackendServices/ApiReportes/Models/ReporteResponseDto.cs` - DTO respuesta
- `BackendServices/ApiReportes/ApiReportesServiceConfig.cs` - Config URLs

### API Reportes (servidor) - C:\jerarquicos\apireportes
- `Api/Controllers/ReporteGenericoController.cs` - Endpoint principal
- `Api/Utils/Utils.cs` - Generacion Crystal Reports
- `Api/Recursos/AccesoDirecto.cs` - Acceso a BD config reportes
- Tabla BD: `ORIGEN_DATOS_REPORTE` - Registro de reportes disponibles
- Tabla BD: `PARAMETRO_REPORTE` - Parametros por reporte

---

## Proximos pasos

1. Restaurar validaciones WCF en CredencialesController, ReintegrosController (2 metodos)
2. Agregar null check de `respuesta.Reporte` antes de MemoryStream en los 4 metodos nuevos
3. Code review final
4. Merge a develop
