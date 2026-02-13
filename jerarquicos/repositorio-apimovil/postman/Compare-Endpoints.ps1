# ==============================================================================
# Compare-Endpoints.ps1
# Compara los resultados de endpoints entre servidor DEV (legacy) y LOCAL (nuevo)
# Usa archivo de configuracion config.json para variables
# ==============================================================================

param(
    [string]$ConfigFile = ".\config.json",
    [switch]$ResetConfig,
    [switch]$SkipPrompts,
    [switch]$SaveConfig
)

# Colores para output
function Write-Success { param($msg) Write-Host $msg -ForegroundColor Green }
function Write-Failure { param($msg) Write-Host $msg -ForegroundColor Red }
function Write-Info { param($msg) Write-Host $msg -ForegroundColor Cyan }
function Write-Warning { param($msg) Write-Host $msg -ForegroundColor Yellow }

# ==============================================================================
# FUNCIONES DE CONFIGURACION
# ==============================================================================

function Get-DefaultConfig {
    return @{
        environments = @{
            dev = @{
                base_url = "https://dev-api.example.com"
                description = "Servidor de desarrollo (legacy)"
            }
            local = @{
                base_url = "http://localhost:5000"
                description = "Servidor local (nuevo)"
            }
        }
        authentication = @{
            token = ""
        }
        test_data = @{
            idComprobante = ""
            idResumenTarjeta = ""
            numeroSocio = ""
            anio = "2025"
            idTipoComprobante = "1"
            idCuentaCorriente = ""
        }
        settings = @{
            output_dir = ".\comparison_results"
            timeout_seconds = 30
            save_pdfs = $true
        }
    }
}

function Load-Config {
    param([string]$Path)

    if (Test-Path $Path) {
        try {
            $jsonContent = Get-Content $Path -Raw | ConvertFrom-Json

            # Convertir PSCustomObject a Hashtable recursivamente
            $config = Convert-ToHashtable $jsonContent
            return $config
        }
        catch {
            Write-Warning "Error leyendo config: $($_.Exception.Message)"
            Write-Info "Usando configuracion por defecto..."
            return Get-DefaultConfig
        }
    }
    else {
        Write-Warning "Archivo de configuracion no encontrado: $Path"
        Write-Info "Creando configuracion por defecto..."
        $defaultConfig = Get-DefaultConfig
        Save-Config -Config $defaultConfig -Path $Path
        return $defaultConfig
    }
}

function Convert-ToHashtable {
    param($InputObject)

    if ($null -eq $InputObject) { return $null }

    if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]) {
        $collection = @()
        foreach ($item in $InputObject) {
            $collection += Convert-ToHashtable $item
        }
        return $collection
    }
    elseif ($InputObject -is [PSCustomObject]) {
        $hash = @{}
        foreach ($property in $InputObject.PSObject.Properties) {
            $hash[$property.Name] = Convert-ToHashtable $property.Value
        }
        return $hash
    }
    else {
        return $InputObject
    }
}

function Save-Config {
    param(
        [hashtable]$Config,
        [string]$Path
    )

    try {
        $Config | ConvertTo-Json -Depth 10 | Set-Content $Path -Encoding UTF8
        Write-Success "Configuracion guardada en: $Path"
    }
    catch {
        Write-Failure "Error guardando config: $($_.Exception.Message)"
    }
}

function Prompt-ForValue {
    param(
        [string]$Name,
        [string]$Description,
        [string]$CurrentValue,
        [switch]$Required,
        [switch]$IsSecret
    )

    $displayValue = if ($CurrentValue -and !$IsSecret) { " [$CurrentValue]" }
                    elseif ($CurrentValue -and $IsSecret) { " [****]" }
                    else { "" }

    $requiredMark = if ($Required) { " (REQUERIDO)" } else { "" }

    Write-Host ""
    Write-Info "$Description$requiredMark"
    $input = Read-Host "$Name$displayValue"

    if ([string]::IsNullOrWhiteSpace($input)) {
        return $CurrentValue
    }
    return $input
}

function Validate-AndPromptConfig {
    param(
        [hashtable]$Config,
        [switch]$SkipPrompts
    )

    $configChanged = $false

    Write-Host ""
    Write-Host "=" * 60 -ForegroundColor Cyan
    Write-Info "CONFIGURACION DE COMPARACION DE ENDPOINTS"
    Write-Host "=" * 60 -ForegroundColor Cyan

    # Mostrar configuracion actual
    Write-Host ""
    Write-Info "Entornos configurados:"
    Write-Host "  DEV:   $($Config.environments.dev.base_url)"
    Write-Host "  LOCAL: $($Config.environments.local.base_url)"

    # Verificar y solicitar token
    if ([string]::IsNullOrWhiteSpace($Config.authentication.token)) {
        if ($SkipPrompts) {
            Write-Failure "ERROR: Token no configurado y -SkipPrompts activo"
            exit 1
        }

        $token = Prompt-ForValue -Name "Token JWT" `
                                  -Description "Token de autenticacion Bearer (JWT)" `
                                  -CurrentValue $Config.authentication.token `
                                  -Required -IsSecret

        if ([string]::IsNullOrWhiteSpace($token)) {
            Write-Failure "ERROR: El token es obligatorio"
            exit 1
        }

        $Config.authentication.token = $token
        $configChanged = $true
    }
    else {
        Write-Host ""
        Write-Success "Token: Configurado (****)"
    }

    # Verificar datos de prueba
    Write-Host ""
    Write-Info "Datos de prueba:"

    $testDataFields = @(
        @{ key = "idComprobante"; desc = "ID del comprobante electronico"; required = $false },
        @{ key = "idResumenTarjeta"; desc = "ID del resumen de tarjeta (comercios)"; required = $false },
        @{ key = "numeroSocio"; desc = "Numero de socio para gastos de salud"; required = $false },
        @{ key = "anio"; desc = "Anio para certificado de salud"; required = $false },
        @{ key = "idTipoComprobante"; desc = "Tipo de comprobante (1=default)"; required = $false },
        @{ key = "idCuentaCorriente"; desc = "ID de cuenta corriente"; required = $false }
    )

    foreach ($field in $testDataFields) {
        $currentValue = $Config.test_data[$field.key]

        if ([string]::IsNullOrWhiteSpace($currentValue)) {
            Write-Warning "  $($field.key): No configurado"

            if (!$SkipPrompts) {
                $newValue = Prompt-ForValue -Name $field.key `
                                            -Description $field.desc `
                                            -CurrentValue $currentValue

                if (![string]::IsNullOrWhiteSpace($newValue)) {
                    $Config.test_data[$field.key] = $newValue
                    $configChanged = $true
                }
            }
        }
        else {
            Write-Host "  $($field.key): $currentValue"
        }
    }

    # Preguntar si modificar URLs
    if (!$SkipPrompts) {
        Write-Host ""
        $modifyUrls = Read-Host "Desea modificar las URLs de los servidores? (s/N)"

        if ($modifyUrls -eq "s" -or $modifyUrls -eq "S") {
            $devUrl = Prompt-ForValue -Name "DEV URL" `
                                       -Description "URL del servidor DEV (legacy)" `
                                       -CurrentValue $Config.environments.dev.base_url

            if (![string]::IsNullOrWhiteSpace($devUrl)) {
                $Config.environments.dev.base_url = $devUrl
                $configChanged = $true
            }

            $localUrl = Prompt-ForValue -Name "LOCAL URL" `
                                         -Description "URL del servidor LOCAL (nuevo)" `
                                         -CurrentValue $Config.environments.local.base_url

            if (![string]::IsNullOrWhiteSpace($localUrl)) {
                $Config.environments.local.base_url = $localUrl
                $configChanged = $true
            }
        }
    }

    return @{
        Config = $Config
        Changed = $configChanged
    }
}

# ==============================================================================
# FUNCIONES DE COMPARACION
# ==============================================================================

function Get-ResolvedUrl {
    param($baseUrl, $path, $params)

    $url = $baseUrl + $path
    foreach ($key in $params.Keys) {
        $url = $url -replace "\{$key\}", $params[$key]
    }
    return $url
}

function Get-EndpointFile {
    param($url, $outputPath, $token, $timeout)

    try {
        $headers = @{
            "Authorization" = "Bearer $token"
        }

        Invoke-WebRequest -Uri $url -Headers $headers -OutFile $outputPath `
                          -TimeoutSec $timeout -ErrorAction Stop
        return $true
    }
    catch {
        Write-Failure "  ERROR: $($_.Exception.Message)"
        return $false
    }
}

function Get-FileHashMD5 {
    param($filePath)

    if (Test-Path $filePath) {
        return (Get-FileHash -Path $filePath -Algorithm MD5).Hash
    }
    return $null
}

# ==============================================================================
# MAIN
# ==============================================================================

# Reset config si se solicita
if ($ResetConfig) {
    Write-Info "Reseteando configuracion..."
    $config = Get-DefaultConfig
    Save-Config -Config $config -Path $ConfigFile
    Write-Success "Configuracion reseteada. Ejecute nuevamente sin -ResetConfig."
    exit 0
}

# Cargar configuracion
$config = Load-Config -Path $ConfigFile

# Validar y solicitar valores faltantes
$result = Validate-AndPromptConfig -Config $config -SkipPrompts:$SkipPrompts
$config = $result.Config

# Guardar config si cambio
if ($result.Changed -or $SaveConfig) {
    Write-Host ""
    if (!$SaveConfig) {
        $saveAnswer = Read-Host "Desea guardar los cambios en el archivo de configuracion? (S/n)"
        if ($saveAnswer -ne "n" -and $saveAnswer -ne "N") {
            Save-Config -Config $config -Path $ConfigFile
        }
    }
    else {
        Save-Config -Config $config -Path $ConfigFile
    }
}

# Variables de configuracion
$DevBaseUrl = $config.environments.dev.base_url
$LocalBaseUrl = $config.environments.local.base_url
$Token = $config.authentication.token
$OutputDir = $config.settings.output_dir
$Timeout = $config.settings.timeout_seconds

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

# Definir los endpoints a probar usando config
$endpoints = @(
    @{
        Name = "Comprobante Electronico (Facturacion)"
        Path = "/api/facturacion/descargarComprobante/{idComprobante}"
        Params = @{ idComprobante = $config.test_data.idComprobante }
        FileName = "comprobante_electronico.pdf"
    },
    @{
        Name = "Resumen Tarjeta (Comercios)"
        Path = "/api/comprascomercios/descargarResumenTarjeta/{idResumenTarjeta}"
        Params = @{ idResumenTarjeta = $config.test_data.idResumenTarjeta }
        FileName = "resumen_tarjeta_comercios.pdf"
    },
    @{
        Name = "Gastos de Salud"
        Path = "/api/CuentaCorriente/descargarGastosDeSalud/{numeroSocio}/{anio}"
        Params = @{ numeroSocio = $config.test_data.numeroSocio; anio = $config.test_data.anio }
        FileName = "gastos_salud.pdf"
    },
    @{
        Name = "Resumen Tarjeta (Cuenta Corriente)"
        Path = "/api/CuentaCorriente/descargarResumenTarjeta/{idcomprobante}/{idTipoComprobante}"
        Params = @{ idcomprobante = $config.test_data.idComprobante; idTipoComprobante = $config.test_data.idTipoComprobante }
        FileName = "resumen_tarjeta_cc.pdf"
    },
    @{
        Name = "Detalle Plan Salud"
        Path = "/api/CuentaCorriente/descargarPdfCcteSalud/{idCuentaCorriente}"
        Params = @{ idCuentaCorriente = $config.test_data.idCuentaCorriente }
        FileName = "detalle_plan_salud.pdf"
    }
)

Write-Host ""
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Info "INICIANDO COMPARACION DE ENDPOINTS"
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""
Write-Info "DEV:   $DevBaseUrl"
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
    $hasEmptyParams = $false
    foreach ($key in $endpoint.Params.Keys) {
        if ([string]::IsNullOrWhiteSpace($endpoint.Params[$key])) {
            $hasEmptyParams = $true
            break
        }
    }

    if ($hasEmptyParams) {
        Write-Info "  SKIPPED: Faltan parametros por configurar"
        $skippedTests++
        $report += "[$totalTests] $($endpoint.Name): SKIPPED (faltan parametros)`n"
        Write-Host ""
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
    $devSuccess = Get-EndpointFile -url $devUrl -outputPath $devFile -token $Token -timeout $Timeout
    if ($devSuccess) {
        Write-Success " OK"
    }

    # Descargar de LOCAL
    Write-Host "  Descargando de LOCAL..." -NoNewline
    $localSuccess = Get-EndpointFile -url $localUrl -outputPath $localFile -token $Token -timeout $Timeout
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

Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "RESUMEN" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
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
    Write-Info "Tip: Abrir ambos PDFs y comparar visualmente"
}
elseif ($skippedTests -gt 0 -and $passedTests -eq 0 -and $failedTests -eq 0) {
    Write-Warning "TODOS LOS TESTS FUERON SKIPPED - Configure los datos de prueba"
    Write-Info "Ejecute: .\Compare-Endpoints.ps1 (sin -SkipPrompts)"
}
