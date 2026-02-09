@echo off
REM ==============================================================================
REM Script para ejecutar la comparacion de endpoints
REM ==============================================================================

REM CONFIGURAR ESTAS VARIABLES ANTES DE EJECUTAR:
set DEV_URL=https://dev-api.example.com
set LOCAL_URL=http://localhost:5000
set TOKEN=PEGAR_TOKEN_AQUI

echo.
echo Ejecutando comparacion de endpoints...
echo DEV: %DEV_URL%
echo LOCAL: %LOCAL_URL%
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0Compare-Endpoints.ps1" -DevBaseUrl "%DEV_URL%" -LocalBaseUrl "%LOCAL_URL%" -Token "%TOKEN%"

echo.
pause
