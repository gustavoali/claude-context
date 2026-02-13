# Colecciones Postman - API Reportes Migration Tests

## Descripcion

Esta coleccion contiene los endpoints migrados de WCF/Legacy a API Reportes REST.

## Archivos

| Archivo | Descripcion |
|---------|-------------|
| `ApiReportes_Migration_Tests.postman_collection.json` | Coleccion con todos los endpoints |
| `ApiReportes_Local.postman_environment.json` | Environment para testing local |
| `ApiReportes_Dev.postman_environment.json` | Environment para servidor de desarrollo |

## Endpoints Incluidos

### Facturacion
- **GET** `/api/facturacion/descargarComprobanteElectronico/{id}` - Comprobante electronico

### Compras Comercios
- **GET** `/api/comprascomercios/descargarResumenTarjeta/{idResumenTarjeta}` - Resumen tarjeta JS

### Cuenta Corriente
- **GET** `/api/CuentaCorriente/descargarGastosDeSalud/{numeroSocio}/{anio}` - Certificado gastos salud
- **GET** `/api/CuentaCorriente/descargarResumenTarjeta/{idComprobante}/{idTipoComprobante}` - Resumen tarjeta JS
- **GET** `/api/CuentaCorriente/descargarPdfCcteSalud/{idCuentaCorriente}` - Detalle plan salud

## Como Usar

### 1. Importar en Postman

1. Abrir Postman
2. Click en **Import** (Ctrl+O)
3. Seleccionar `ApiReportes_Migration_Tests.postman_collection.json`
4. Importar tambien el environment deseado (`ApiReportes_Local.postman_environment.json`)

### 2. Configurar Variables

Seleccionar el environment importado y configurar las variables:

| Variable | Descripcion | Ejemplo |
|----------|-------------|---------|
| `base_url` | URL base de la API | `http://localhost:5000` |
| `access_token` | Token JWT de autenticacion | `eyJhbGciOiJIUzI1...` |
| `id_comprobante` | ID del comprobante electronico | `12345` |
| `id_resumen_tarjeta` | ID del resumen de tarjeta | `67890` |
| `numero_socio` | Numero de socio | `123456` |
| `anio` | Anio para certificado de salud | `2025` |
| `id_tipo_comprobante` | Tipo de comprobante | `1` |
| `id_cuenta_corriente` | ID de cuenta corriente | `11111` |

### 3. Obtener Token de Autenticacion

Antes de ejecutar los endpoints, necesitas obtener un token valido:

1. Autenticarte en la API (endpoint de login)
2. Copiar el `access_token` de la respuesta
3. Pegarlo en la variable `access_token` del environment

### 4. Ejecutar Tests

Cada endpoint incluye tests automaticos que verifican:
- Status code 200
- Content-Type es PDF o octet-stream
- Header Content-Disposition presente
- Body no esta vacio

## Reportes y Parametros

| Endpoint | Reporte | Parametros |
|----------|---------|------------|
| Comprobante Electronico | `ReporteComprobanteElectronico` | `@idCuentaCorriente`, `PathQRFacturacionElectronica` |
| Resumen Tarjeta (Comercios) | `ReporteResumenTarjetaJS` | `@idResumen`, `@idPersona` |
| Resumen Tarjeta (CC) | `ReporteResumenTarjetaJS` | `@idResumen`, `@idPersona` |
| Gastos Salud | `ReporteCertificadoPagoServiciosSalud` | `@NumeroSocio`, `@Anio`, `RutaEncabezado` |
| Detalle Plan Salud | `ReporteDetallePlanSalud` | `@idPersona`, `@idCuentaCorriente` |

## Notas

- Todos los endpoints requieren autenticacion (Bearer token)
- Las respuestas son archivos PDF (application/octet-stream)
- El parametro `@idPersona` se obtiene automaticamente del token en el servidor

---

## Test de Regresion - Comparar DEV vs LOCAL

Para verificar que la migracion no cambio el comportamiento, usar el script de comparacion.

### Archivos

| Archivo | Descripcion |
|---------|-------------|
| `Compare-Endpoints.ps1` | Script PowerShell de comparacion |
| `config.json` | Archivo de configuracion con variables |
| `run-comparison.bat` | Wrapper para ejecutar facilmente |

### Configuracion

El script usa `config.json` para almacenar configuracion. Estructura:

```json
{
  "environments": {
    "dev": { "base_url": "https://tu-servidor-dev.com" },
    "local": { "base_url": "http://localhost:5000" }
  },
  "authentication": {
    "token": "tu_token_jwt"
  },
  "test_data": {
    "id_comprobante": "12345",
    "id_resumen_tarjeta": "67890",
    "numero_socio": "123456",
    "anio": "2025",
    "id_tipo_comprobante": "1",
    "id_cuenta_corriente": "11111"
  },
  "settings": {
    "output_dir": ".\\comparison_results",
    "timeout_seconds": 30
  }
}
```

### Uso

#### Opcion 1: Modo interactivo (recomendado)

Ejecutar sin parametros. El script pedira los valores faltantes:

```powershell
.\Compare-Endpoints.ps1
```

El script:
1. Carga `config.json`
2. Muestra valores actuales
3. Pide valores faltantes interactivamente
4. Pregunta si guardar cambios al config

#### Opcion 2: Usar config existente sin prompts

```powershell
.\Compare-Endpoints.ps1 -SkipPrompts
```

**Nota:** Fallara si el token no esta configurado.

#### Opcion 3: Resetear configuracion

```powershell
.\Compare-Endpoints.ps1 -ResetConfig
```

Crea un `config.json` nuevo con valores por defecto.

#### Opcion 4: Ejecutar el .bat

1. Configurar `config.json` con los valores correctos
2. Doble-click en `run-comparison.bat`

### Parametros del Script

| Parametro | Descripcion |
|-----------|-------------|
| `-ConfigFile` | Path al archivo de configuracion (default: `.\config.json`) |
| `-SkipPrompts` | No pedir valores interactivamente |
| `-SaveConfig` | Guardar cambios automaticamente sin preguntar |
| `-ResetConfig` | Resetear configuracion a valores por defecto |

### Output

El script genera:
- `comparison_results/` - Carpeta con los PDFs descargados
  - `dev_*.pdf` - PDFs del servidor DEV
  - `local_*.pdf` - PDFs del servidor LOCAL
- `comparison_report_YYYYMMDD_HHMMSS.txt` - Reporte de la comparacion

### Interpretacion de Resultados

| Resultado | Significado |
|-----------|-------------|
| **PASS** | Los PDFs son identicos (mismo hash MD5) |
| **DIFFERENT** | Los PDFs son diferentes - revisar manualmente |
| **SKIPPED** | Faltan parametros por configurar |
| **ERROR** | Fallo la descarga de uno de los servidores |

### Nota sobre Diferencias

Los PDFs pueden tener diferencias en:
- **Metadata** (fecha de generacion, software, etc)
- **Timestamps** embebidos en el documento

Si el hash es diferente pero el contenido visual es igual, la migracion es correcta.
Para verificar visualmente, abrir ambos PDFs lado a lado.
