<#
.SYNOPSIS
    Abre una nueva ventana de Windows Terminal con Claude Code listo para trabajar
    en un proyecto, detectando automaticamente el estado y arrancando con la accion
    correcta: /sembrar, /brotar, o retomar tareas pendientes.

.DESCRIPTION
    Analiza el estado del proyecto en claude_context y determina la accion:
      - Sin contexto              → /sembrar
      - Semilla sin backlog       → /brotar
      - Backlog sin TASK_STATE    → abrir con contexto
      - TASK_STATE con pendientes → retomar proximos pasos

.PARAMETER Project
    Slug relativo a C:\claude_context (ej: "investigacion/ai-dev-cost-model")
    o short code del project-registry (ej: "adc").

.PARAMETER SourceDoc
    Path absoluto al documento fuente. Solo se usa si el estado detectado es 'sembrar'.

.EXAMPLE
    .\proyecto-remoto.ps1 -Project "investigacion/ai-dev-cost-model"
    .\proyecto-remoto.ps1 -Project "adc"
    .\proyecto-remoto.ps1 -Project "investigacion/ai-dev-cost-model" -SourceDoc "C:\docs\seed.md"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Project,

    [Parameter(Mandatory=$false)]
    [string]$SourceDoc = ""
)

$ErrorActionPreference = "Stop"
$RegistryPath = "C:\claude_context\project-registry.json"
$ContextBase  = "C:\claude_context"

# ── 1. Resolver slug desde short code o slug directo ────────────────────────

function Resolve-ProjectSlug {
    param([string]$Input)

    # Si contiene "/" asumimos slug directo
    if ($Input -match "/") { return $Input }

    # Buscar en registry por short code
    if (Test-Path $RegistryPath) {
        $registry = Get-Content $RegistryPath -Raw | ConvertFrom-Json
        foreach ($key in $registry.projects.PSObject.Properties.Name) {
            $proj = $registry.projects.$key
            if ($proj.short -eq $Input) {
                # context tiene formato: C:/claude_context/clasificador/proyecto
                # extraer el slug desde context
                $ctx = $proj.context -replace "^C:/claude_context/", "" -replace "^C:\\claude_context\\", ""
                return $ctx
            }
        }
    }

    # Fallback: asumir slug directo
    return $Input
}

$slug        = Resolve-ProjectSlug -Input $Project
$contextPath = Join-Path $ContextBase ($slug -replace "/", "\")
$projectName = Split-Path $slug -Leaf

# Intentar obtener path del proyecto real desde registry
$projectPath = $contextPath  # default
if (Test-Path $RegistryPath) {
    $registry = Get-Content $RegistryPath -Raw | ConvertFrom-Json
    foreach ($key in $registry.projects.PSObject.Properties.Name) {
        $proj = $registry.projects.$key
        $ctxNorm = ($proj.context -replace "^C:/claude_context/", "") -replace "/", "\"
        if ($ctxNorm -eq ($slug -replace "/", "\")) {
            $rawPath = $proj.path -replace "/", "\"
            if ($rawPath -and (Test-Path $rawPath)) {
                $projectPath = $rawPath
            }
            break
        }
    }
}

# ── 2. Detectar estado del proyecto ─────────────────────────────────────────

$hasSeedDoc   = Test-Path (Join-Path $contextPath "SEED_DOCUMENT.md")
$hasBacklog   = Test-Path (Join-Path $contextPath "PRODUCT_BACKLOG.md")
$hasTaskState = Test-Path (Join-Path $contextPath "TASK_STATE.md")
$hasClaudeMd  = Test-Path (Join-Path $contextPath "CLAUDE.md")

$status      = "desconocido"
$action      = "abrir"
$actionLabel = ""
$instruction = ""

if (-not $hasSeedDoc -and -not $hasClaudeMd) {
    $status      = "nuevo"
    $action      = "sembrar"
    $actionLabel = "SEMBRAR"
    $workDir     = $contextPath
    if ($SourceDoc) {
        $instruction = "/sembrar con documento fuente en: $SourceDoc"
    } else {
        $instruction = "/sembrar"
    }
}
elseif ($hasSeedDoc -and -not $hasBacklog) {
    $status      = "semilla"
    $action      = "brotar"
    $actionLabel = "BROTAR"
    $workDir     = if (Test-Path $projectPath) { $projectPath } else { $contextPath }
    $instruction = "/brotar $projectName"
}
elseif ($hasTaskState) {
    # Leer proximos pasos del TASK_STATE
    $taskContent = Get-Content (Join-Path $contextPath "TASK_STATE.md") -Raw -ErrorAction SilentlyContinue
    $proximosPasos = ""
    if ($taskContent -match "(?s)## Proximos Pasos\r?\n(.*?)(\r?\n##|\z)") {
        $proximosPasos = $Matches[1].Trim()
    }
    $status      = "en-progreso"
    $action      = "retomar"
    $actionLabel = "RETOMAR"
    $workDir     = if (Test-Path $projectPath) { $projectPath } else { $contextPath }
    if ($proximosPasos) {
        $instruction = "Retomar trabajo en el proyecto $projectName. Lee TASK_STATE.md y continua con los proximos pasos pendientes."
    } else {
        $instruction = "Continuar trabajo en el proyecto $projectName. Revisar contexto y esperar instrucciones."
    }
}
elseif ($hasBacklog) {
    $status      = "activo"
    $action      = "continuar"
    $actionLabel = "CONTINUAR"
    $workDir     = if (Test-Path $projectPath) { $projectPath } else { $contextPath }
    $instruction = "Revisar contexto del proyecto $projectName y esperar instrucciones."
}
else {
    $status      = "semilla"
    $action      = "brotar"
    $actionLabel = "BROTAR"
    $workDir     = if (Test-Path $projectPath) { $projectPath } else { $contextPath }
    $instruction = "/brotar $projectName"
}

# Crear workDir si no existe (caso sembrar)
if (-not (Test-Path $workDir)) {
    New-Item -ItemType Directory -Path $workDir -Force | Out-Null
}

# ── 3. Configurar permisos en workDir ───────────────────────────────────────
$claudeDir    = Join-Path $workDir ".claude"
$settingsFile = Join-Path $claudeDir "settings.local.json"

if (-not (Test-Path $claudeDir)) {
    New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
}
if (-not (Test-Path $settingsFile)) {
    $settings = '{"permissions":{"allow":["Bash(*)","Read(*)","Write(*)","Edit(*)","WebFetch(domain:*)","WebSearch"]}}'
    Set-Content -Path $settingsFile -Value $settings -Encoding UTF8
}

# ── 4. Resumen en consola actual ─────────────────────────────────────────────

$statusColors = @{
    "nuevo"      = "Magenta"
    "semilla"    = "Yellow"
    "en-progreso" = "Cyan"
    "activo"     = "Green"
    "desconocido" = "Gray"
}
$statusColor = $statusColors[$status]

Write-Host ""
Write-Host "=== proyecto-remoto ===" -ForegroundColor Cyan
Write-Host "Proyecto  : $projectName" -ForegroundColor White
Write-Host "Slug      : $slug" -ForegroundColor Gray
Write-Host "Contexto  : $contextPath" -ForegroundColor Gray
Write-Host "Work dir  : $workDir" -ForegroundColor Gray
Write-Host "Estado    : $status" -ForegroundColor $statusColor
Write-Host "Accion    : $actionLabel" -ForegroundColor $statusColor
Write-Host "Instruccion: $instruction" -ForegroundColor White
Write-Host ""

# ── 5. Script interno para la nueva terminal ────────────────────────────────

$innerScript = @"
[TitleLocker]::Lock('$actionLabel`: $projectName')
`$function:global:prompt = {
    [TitleLocker]::ChangeTitle('$actionLabel`: $projectName')
    "PS `$(`$executionContext.SessionState.Path.CurrentLocation)`$('>' * (`$nestedPromptLevel + 1)) "
}

Write-Host ''
Write-Host '======================================' -ForegroundColor Cyan
Write-Host '  $actionLabel`: $projectName' -ForegroundColor Cyan
Write-Host '  Contexto : $contextPath' -ForegroundColor Gray
Write-Host '  Work dir : $workDir' -ForegroundColor Gray
Write-Host '  Estado   : $status' -ForegroundColor $statusColor
Write-Host '======================================' -ForegroundColor Cyan
Write-Host ''
Write-Host 'Iniciando Claude Code...' -ForegroundColor Yellow
Write-Host 'Instruccion: $instruction' -ForegroundColor Yellow
Write-Host ''
Set-Location '$workDir'
Remove-Item Env:CLAUDECODE -ErrorAction SilentlyContinue
claude '$instruction'
"@

# ── 6. Abrir nueva tab en Windows Terminal ───────────────────────────────────

$encoded = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($innerScript))
$wtArgs  = "new-tab --title `"$actionLabel`: $projectName`" --startingDirectory `"$workDir`" -- powershell.exe -NoExit -EncodedCommand $encoded"

Start-Process "wt.exe" -ArgumentList $wtArgs

Write-Host "[OK] Nueva terminal abierta." -ForegroundColor Green
Write-Host "     Ve a esa ventana — Claude ejecutara la accion automaticamente." -ForegroundColor Gray
Write-Host ""
