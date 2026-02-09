# ==============================================================================
# Compare-Endpoints.ps1
# Compara los resultados de endpoints entre servidor DEV (legacy) y LOCAL (nuevo)
# ==============================================================================

param(
    [string]$DevBaseUrl = "https://dev-api.example.com",
    [string]$LocalBaseUrl = "http://localhost:5000",
    [string]$Token = "",
    [string]$OutputDir = ".\comparison_results"
)

# Colores para output
function Write-Success { param($msg) Write-Host $msg -ForegroundColor Green }
function Write-Failure { param($msg) Write-Host $msg -ForegroundColor Red }
function Write-Info { param($msg) Write-Host $msg -ForegroundColor Cyan }

# Crear directorio de output
if (!(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$reportFile = "$OutputDir\comparison_report_$timestamp.txt"

# Header del reporte
$report = @"
================================================================================
REPORTE DE COMPARACION - API Reportes Migration
Fecha: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
DEV Server: $DevBaseUrl
LOCAL Server: $LocalBaseUrl
================================================================================

"@

# Definir los endpoints a probar
# IMPORTANTE: Completar con IDs reales de datos de prueba
$endpoints = @(
    @{
        Name = "Comprobante Electronico"
        Path = "/api/facturacion/descargarComprobanteElectronico/{id_comprobante}"
        Params = @{ id_comprobante = "COMPLETAR_ID" }
        FileName = "comprobante_electronico.pdf"
    },
    @{
        Name = "Resumen Tarjeta (Comercios)"
        Path = "/api/comprascomercios/descargarResumenTarjeta/{id_resumen}"
        Params = @{ id_resumen = "COMPLETAR_ID" }
        FileName = "resumen_tarjeta_comercios.pdf"
    },
    @{
        Name = "Gastos de Salud"
        Path = "/api/CuentaCorriente/descargarGastosDeSalud/{numero_socio}/{anio}"
        Params = @{ numero_socio = "COMPLETAR_SOCIO"; anio = "2025" }
        FileName = "gastos_salud.pdf"
    },
    @{
        Name = "Resumen Tarjeta (Cuenta Corriente)"
        Path = "/api/CuentaCorriente/descargarResumenTarjeta/{id_comprobante}/{id_tipo}"
        Params = @{ id_comprobante = "COMPLETAR_ID"; id_tipo = "1" }
        FileName = "resumen_tarjeta_cc.pdf"
    },
    @{
        Name = "Detalle Plan Salud"
        Path = "/api/CuentaCorriente/descargarPdfCcteSalud/{id_cuenta_corriente}"
        Params = @{ id_cuenta_corriente = "COMPLETAR_ID" }
        FileName = "detalle_plan_salud.pdf"
    }
)

# Funcion para reemplazar parametros en la URL
function Get-ResolvedUrl {
    param($baseUrl, $path, $params)

    $url = $baseUrl + $path
    foreach ($key in $params.Keys) {
        $url = $url -replace "\{$key\}", $params[$key]
    }
    return $url
}

# Funcion para descargar archivo
function Get-EndpointFile {
    param($url, $outputPath, $token)

    try {
        $headers = @{
            "Authorization" = "Bearer $token"
        }

        Invoke-WebRequest -Uri $url -Headers $headers -OutFile $outputPath -ErrorAction Stop
        return $true
    }
    catch {
        Write-Failure "  ERROR: $($_.Exception.Message)"
        return $false
    }
}

# Funcion para calcular hash MD5
function Get-FileHashMD5 {
    param($filePath)

    if (Test-Path $filePath) {
        return (Get-FileHash -Path $filePath -Algorithm MD5).Hash
    }
    return $null
}

# Funcion para comparar archivos byte a byte
function Compare-FilesContent {
    param($file1, $file2)

    if (!(Test-Path $file1) -or !(Test-Path $file2)) {
        return $false
    }

    $bytes1 = [System.IO.File]::ReadAllBytes($file1)
    $bytes2 = [System.IO.File]::ReadAllBytes($file2)

    if ($bytes1.Length -ne $bytes2.Length) {
        return $false
    }

    for ($i = 0; $i -lt $bytes1.Length; $i++) {
        if ($bytes1[$i] -ne $bytes2[$i]) {
            return $false
        }
    }

    return $true
}

# Verificar token
if ([string]::IsNullOrEmpty($Token)) {
    Write-Failure "ERROR: Debe proporcionar un token de autenticacion"
    Write-Info "Uso: .\Compare-Endpoints.ps1 -Token 'tu_token_jwt' -DevBaseUrl 'https://dev..' -LocalBaseUrl 'http://localhost:5000'"
    exit 1
}

Write-Info "Iniciando comparacion de endpoints..."
Write-Info "DEV: $DevBaseUrl"
Write-Info "LOCAL: $LocalBaseUrl"
Write-Host ""

$totalTests = 0
$passedTests = 0
$failedTests = 0
$skippedTests = 0

foreach ($endpoint in $endpoints) {
    $totalTests++
    Write-Host "[$totalTests] Probando: $($endpoint.Name)" -ForegroundColor Yellow

    # Verificar si tiene IDs configurados
    $hasPlaceholders = $false
    foreach ($value in $endpoint.Params.Values) {
        if ($value -like "COMPLETAR*") {
            $hasPlaceholders = $true
            break
        }
    }

    if ($hasPlaceholders) {
        Write-Info "  SKIPPED: Faltan parametros por configurar"
        $skippedTests++
        $report += "[$totalTests] $($endpoint.Name): SKIPPED (faltan parametros)`n"
        continue
    }

    $devUrl = Get-ResolvedUrl -baseUrl $DevBaseUrl -path $endpoint.Path -params $endpoint.Params
    $localUrl = Get-ResolvedUrl -baseUrl $LocalBaseUrl -path $endpoint.Path -params $endpoint.Params

    $devFile = "$OutputDir\dev_$($endpoint.FileName)"
    $localFile = "$OutputDir\local_$($endpoint.FileName)"

    Write-Host "  DEV URL: $devUrl"
    Write-Host "  LOCAL URL: $localUrl"

    # Descargar de DEV
    Write-Host "  Descargando de DEV..." -NoNewline
    $devSuccess = Get-EndpointFile -url $devUrl -outputPath $devFile -token $Token
    if ($devSuccess) {
        Write-Success " OK"
    }

    # Descargar de LOCAL
    Write-Host "  Descargando de LOCAL..." -NoNewline
    $localSuccess = Get-EndpointFile -url $localUrl -outputPath $localFile -token $Token
    if ($localSuccess) {
        Write-Success " OK"
    }

    # Comparar resultados
    if ($devSuccess -and $localSuccess) {
        $devHash = Get-FileHashMD5 -filePath $devFile
        $localHash = Get-FileHashMD5 -filePath $localFile

        $devSize = (Get-Item $devFile).Length
        $localSize = (Get-Item $localFile).Length

        Write-Host "  DEV   - Size: $devSize bytes, MD5: $devHash"
        Write-Host "  LOCAL - Size: $localSize bytes, MD5: $localHash"

        if ($devHash -eq $localHash) {
            Write-Success "  RESULTADO: IDENTICOS (MD5 match)"
            $passedTests++
            $report += "[$totalTests] $($endpoint.Name): PASS (MD5: $devHash)`n"
        }
        else {
            # Los PDFs pueden tener metadata diferente (fecha de generacion, etc)
            # pero el contenido visual ser igual
            Write-Failure "  RESULTADO: DIFERENTES"
            Write-Info "  NOTA: Puede ser por metadata (fecha/hora). Revisar manualmente."
            $failedTests++
            $report += "[$totalTests] $($endpoint.Name): DIFFERENT`n"
            $report += "    DEV MD5: $devHash (Size: $devSize)`n"
            $report += "    LOCAL MD5: $localHash (Size: $localSize)`n"
        }
    }
    else {
        Write-Failure "  RESULTADO: ERROR en descarga"
        $failedTests++
        $report += "[$totalTests] $($endpoint.Name): ERROR (fallo descarga)`n"
    }

    Write-Host ""
}

# Resumen
$report += @"

================================================================================
RESUMEN
================================================================================
Total tests: $totalTests
Passed: $passedTests
Failed: $failedTests
Skipped: $skippedTests
================================================================================
"@

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "RESUMEN" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "Total tests: $totalTests"
Write-Success "Passed: $passedTests"
if ($failedTests -gt 0) { Write-Failure "Failed: $failedTests" } else { Write-Host "Failed: $failedTests" }
Write-Info "Skipped: $skippedTests"
Write-Host ""
Write-Host "Archivos descargados en: $OutputDir"
Write-Host "Reporte guardado en: $reportFile"

# Guardar reporte
$report | Out-File -FilePath $reportFile -Encoding UTF8

Write-Host ""
if ($failedTests -eq 0 -and $skippedTests -eq 0) {
    Write-Success "TODOS LOS TESTS PASARON - La migracion es correcta!"
}
elseif ($failedTests -gt 0) {
    Write-Failure "HAY DIFERENCIAS - Revisar los archivos PDF manualmente"
    Write-Info "Tip: Abrir ambos PDFs y comparar visualmente, o usar una herramienta de diff de PDF"
}
