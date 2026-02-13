# Feature: Comprobantes Electronicos

**Historias:** 179610, 178134
**Estado:** Completado
**Fecha trabajo:** Enero 2026

---

## Descripcion

Implementacion de endpoints para listar y descargar comprobantes electronicos (facturas) del socio autenticado.

---

## Arquitectura Multi-Cliente

Esta funcionalidad existe en dos clientes con diferentes backends:

| Cliente | Proyecto | Backend | Protocolo |
|---------|----------|---------|-----------|
| **App Movil (Kotlin)** | Repositorio-ApiMovil | API REST | HTTP/JSON |
| **Portal Web MiJS** | MiJsFrontEnd | ServiciosJs (WCF) | SOAP/WCF |

### Diferencias de Implementacion

| Aspecto | App Movil | Portal MiJS |
|---------|-----------|-------------|
| **Metodo** | `GetComprobantesElectronicos()` | `FacturasElectronicasPersona(int idPersona)` |
| **Parametros** | Ninguno (usa token Bearer) | `idPersona` |
| **Autenticacion** | Token JWT | Sesion web o Hash valido |
| **Ruta** | `GET /api/facturacion/comprobantesElectronicos` | `GET /Facturacion/FacturasElectronicasPersona?idPersona={id}` |
| **Service Agent** | `BackendServices` (HTTP Client) | `ServiciosJs.ServiceAgent.Servicio` (WCF) |

---

## Endpoints Implementados

| Metodo | Ruta | Descripcion | Historia |
|--------|------|-------------|----------|
| GET | `/api/facturacion/comprobantesElectronicos` | Listado de comprobantes del usuario | 179610 |
| GET | `/api/facturacion/descargarComprobante/{id}` | Descarga de comprobante en PDF | 178134 |

---

## Ramas Git

| Historia | Rama | Proposito |
|----------|------|-----------|
| 179610 | `feature/179610_endpoint_comprobantes_electronicos` | Listado de comprobantes |
| 178134 | `feature/178134_descarga_comprobante_electronico` | Descarga PDF |

---

## Archivos Clave

### Controllers
- `Api/Controllers/FacturacionController.cs`

### DTOs
- `Api/Models/Facturacion/ComprobanteElectronicoModel.cs`

### Utilidades
- `Api/Utils/ReportesUtil.cs` - Generacion de PDFs via servicio de reportes

### Services
- `BackendServices/` - Cliente de servicio backend de facturacion
- `ServiceFactory.ReportesApi` - Servicio de generacion de reportes PDF

---

## Estructura de Respuesta

### Listado de Comprobantes (GET /api/facturacion/comprobantesElectronicos)

```json
{
    "Exito": true,
    "Mensaje": "Comprobantes obtenidos correctamente",
    "Modelo": [
        {
            "Id": 12345,
            "Fecha": "2024-01-15T00:00:00",
            "Tipo": "B",
            "Numero": "0057-10371787",
            "Importe": 15000.50
        }
    ],
    "Notificacion": {
        "Mensaje": "",
        "Tipo": 0
    }
}
```

### Campos del Modelo

| Campo | Tipo | Descripcion |
|-------|------|-------------|
| Id | int | Identificador unico - usar para descarga PDF |
| Fecha | DateTime | Fecha de emision (ISO 8601) |
| Tipo | string | Tipo de factura: 'A', 'B', 'C' |
| Numero | string | Numero completo: 'PPPP-NNNNNNNN' (PuntoVenta-NumeroComprobante) |
| Importe | decimal | Monto total |

### Modelo UI (Kotlin)

```kotlin
data class ComprobanteElectronicoModelUi(
    val id: Long,
    val fecha: String,
    val tipo: String,
    val importe: Double,
    val nro: String
)
```

### Descarga PDF (GET /api/facturacion/descargarComprobante/{id})

**Parametro de ruta:**
| Parametro | Tipo | Descripcion |
|-----------|------|-------------|
| id | int | ID del comprobante (obtenido del listado) |

**Respuesta exitosa:**
- HTTP 200 OK
- Content-Type: `application/octet-stream`
- Content-Disposition: `attachment; filename=Comprobante_{id}.pdf`
- Body: Bytes del archivo PDF

**Respuestas de error:**
| Codigo | Descripcion |
|--------|-------------|
| 400 Bad Request | Comprobante sin documento generado ("Sin documentos") |
| 401 Unauthorized | Sin autenticacion o token invalido |
| 500 Internal Server Error | Error en generacion del reporte |

**Implementacion tecnica:**
```
Endpoint → ReportesUtil.GenerarPDFReporte() → ServiceFactory.ReportesApi.ReporteGenerico()
                    ↓
            Parametros:
            - NombreReporte: "ComprobanteElectronico"
            - IdComprobanteElectronico: {id}
            - ServidorReporte: (desde Web.config)
```

---

## Notas Tecnicas

### App Movil (Repositorio-ApiMovil)

**Listado (179610):**
- Requiere autenticacion del socio (Bearer token)
- Los comprobantes se obtienen via WCF `AgenteServiciosJs.Generico.Buscar()`
- Filtra por `IdPersona` del token y `FechaBaja == null`
- Ordenamiento: Fecha DESC, Letra ASC, PuntoVenta ASC, Numero DESC
- Lista vacia retorna `Modelo: []` con `Exito: true`

**Descarga PDF (178134):**
- Requiere autenticacion del socio (Bearer token)
- Usa `ReportesUtil.GenerarPDFReporte()` con nombre de reporte `"ComprobanteElectronico"`
- El servicio de reportes se configura en `Web.config` → `ServidorReporte`
- Metodo asincrono con `ConfigureAwait(false)` para evitar deadlocks
- Retorna el PDF como `application/octet-stream` con Content-Disposition attachment

### Portal MiJS (MiJsFrontEnd)
- Archivo: `UI.MVC/Controllers/FacturacionController.cs`
- Metodo: `FacturasElectronicasPersona(int idPersona)`
- Valida que `idPersona` corresponda al usuario logueado
- Usa `ServiciosJs.ServiceAgent.Servicio().Generico.Buscar()` (WCF)
- Filtra por tipo de socio (autonomo/asalariado) y punto de venta
- Limita a comprobantes de los ultimos 18 meses para asalariados
- Vista parcial: `_FacturasElectronicasPersona.cshtml`

### Servicio WCF Compartido
Ambos clientes consultan la misma fuente de datos (`VistaComprobanteElectronicoDTO`) pero con diferentes:
- Filtros (idPersona en MiJS, idUsuario del token en API Movil)
- Transformaciones (MiJS aplica reglas de negocio adicionales)

---

## Archivos en esta carpeta

- `README.md` - Esta documentacion
- `response_listado.json` - Ejemplo de respuesta del listado
- `response_errors.json` - Ejemplos de respuestas de error
