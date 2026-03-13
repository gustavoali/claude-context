<#
.SYNOPSIS
    Abre una nueva ventana de Windows Terminal y siembra un proyecto Claude.

.DESCRIPTION
    Herramienta generica para sembrar proyectos. Crea el directorio, configura
    permisos amplios (.claude/settings.local.json) y abre una nueva tab de
    Windows Terminal con Claude Code listo para ejecutar /sembrar.

.PARAMETER ProjectSlug
    Slug del proyecto relativo a C:\claude_context
    Ejemplos: "investigacion/llm-landscape", "jerarquicos/MiProyecto"

.PARAMETER SourceDoc
    Path absoluto al documento fuente para /sembrar (opcional).
    Si se omite, Claude pedira el documento interactivamente.

.EXAMPLE
    .\sembrar.ps1 -ProjectSlug "investigacion/llm-landscape" -SourceDoc "C:\docs\llm-seed.md"
    .\sembrar.ps1 -ProjectSlug "investigacion/ai-dev-cost-model"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectSlug,

    [Parameter(Mandatory=$false)]
    [string]$SourceDoc = ""
)

$ErrorActionPreference = "Stop"

$BaseDir    = "C:\claude_context"
$ProjectPath = Join-Path $BaseDir $ProjectSlug
$ProjectName = Split-Path $ProjectSlug -Leaf

Write-Host ""
Write-Host "=== sembrar-remoto ===" -ForegroundColor Cyan
Write-Host "Proyecto : $ProjectName"
Write-Host "Path     : $ProjectPath"
if ($SourceDoc) { Write-Host "Fuente   : $SourceDoc" }
Write-Host ""

# ── 1. Crear directorio del proyecto ────────────────────────────────────────
if (-not (Test-Path $ProjectPath)) {
    New-Item -ItemType Directory -Path $ProjectPath -Force | Out-Null
    Write-Host "[OK] Directorio creado: $ProjectPath" -ForegroundColor Green
} else {
    Write-Host "[INFO] Directorio ya existe: $ProjectPath" -ForegroundColor Yellow
}

# ── 2. Permisos amplios via .claude/settings.local.json ─────────────────────
$ClaudeDir   = Join-Path $ProjectPath ".claude"
$SettingsFile = Join-Path $ClaudeDir "settings.local.json"

if (-not (Test-Path $ClaudeDir)) {
    New-Item -ItemType Directory -Path $ClaudeDir -Force | Out-Null
}

if (-not (Test-Path $SettingsFile)) {
    $settings = '{"permissions":{"allow":["Bash(*)","Read(*)","Write(*)","Edit(*)","WebFetch(domain:*)","WebSearch"]}}'
    Set-Content -Path $SettingsFile -Value $settings -Encoding UTF8
    Write-Host "[OK] Permisos configurados: $SettingsFile" -ForegroundColor Green
} else {
    Write-Host "[INFO] settings.local.json ya existe, no se sobreescribe" -ForegroundColor Yellow
}

# ── 3. Mensaje de bienvenida y tarea para Claude en la nueva terminal ────────
$sembrarCmd = if ($SourceDoc) {
    "/sembrar con documento fuente en: $SourceDoc"
} else {
    "/sembrar"
}

# Script que se ejecuta en la nueva terminal
$innerScript = @"
# Bloquear titulo via TitleLocker (igual que 'proyecto') - survives claude
[TitleLocker]::Lock('sembrar: $ProjectName')
`$function:global:prompt = {
    [TitleLocker]::ChangeTitle('sembrar: $ProjectName')
    "PS `$(`$executionContext.SessionState.Path.CurrentLocation)`$('>' * (`$nestedPromptLevel + 1)) "
}
Write-Host ''
Write-Host '======================================' -ForegroundColor Cyan
Write-Host '  SEMBRAR: $ProjectName' -ForegroundColor Cyan
Write-Host '  Path: $ProjectPath' -ForegroundColor Gray
$(if ($SourceDoc) { "Write-Host '  Fuente: $SourceDoc' -ForegroundColor Gray" })
Write-Host '======================================' -ForegroundColor Cyan
Write-Host ''
Write-Host 'Iniciando Claude Code...' -ForegroundColor Yellow
Write-Host 'Instruccion a ejecutar: $sembrarCmd' -ForegroundColor Yellow
Write-Host ''
Set-Location '$ProjectPath'
Remove-Item Env:CLAUDECODE -ErrorAction SilentlyContinue
claude '$sembrarCmd'
"@

# ── 4. Abrir nueva tab en Windows Terminal ───────────────────────────────────
$encodedScript = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($innerScript))

$wtArgs = "new-tab --title `"Sembrar: $ProjectName`" --startingDirectory `"$ProjectPath`" -- powershell.exe -NoExit -EncodedCommand $encodedScript"

Write-Host "[OK] Abriendo nueva terminal..." -ForegroundColor Green
Start-Process "wt.exe" -ArgumentList $wtArgs

Write-Host ""
Write-Host "[DONE] Nueva terminal abierta con Claude Code." -ForegroundColor Green
Write-Host "       Ve a esa ventana, Claude ejecutara /sembrar automaticamente." -ForegroundColor Gray
Write-Host ""
