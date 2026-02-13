# Estado de Tareas - Configuración Claude Code con Modelos Locales

**Última actualización:** 2026-01-31 21:45
**Sesión activa:** No

---

## Resumen Ejecutivo

**Trabajo en curso:** Configuración de Claude Code para trabajar con modelos locales (Ollama, LM Studio, OpenRouter)
**Fase actual:** Descarga de modelos Ollama casi completa
**Bloqueantes:** Ninguno

---

## Tareas Completadas

### ✅ #1 Instalar y configurar Ollama
- **Estado:** completada
- **Descripción:** Instalación de Ollama y configuración con Claude Code
- **Archivos afectados:**
  - Ollama instalado en: `C:\Users\gdali\AppData\Local\Programs\Ollama\ollama.exe`
  - Variables de entorno configuradas y luego eliminadas
- **Resultado:**
  - Ollama 0.15.2 instalado correctamente
  - Modelo qwen3-coder:30b (18GB) descargado y funcionando
  - Variables de entorno eliminadas para usar Anthropic por defecto
  - Comando para usar Ollama: `ollama launch claude --model qwen3-coder:30b`

### ✅ Descargar modelos adicionales de coding
- **Estado:** completada
- **Descripción:** Descarga de modelos recomendados para coding
- **Modelos descargados:**
  1. ✅ qwen3-coder:30b (18GB) - Completado
  2. ✅ deepseek-coder-v2:16b (8.9GB) - Completado
  3. ✅ qwen2.5-coder:32b (19GB) - Completado
- **Resultado:** 3 modelos listos para usar con Claude Code

---

## Tareas Pendientes

### ⏳ #2 Configurar LM Studio con proxy
- **Estado:** pendiente
- **Descripción:** Instalar LM Studio + LiteLLM proxy para usar con Claude Code
- **Pasos necesarios:**
  1. Descargar e instalar LM Studio desde https://lmstudio.ai/
  2. Instalar LiteLLM: `pip install litellm`
  3. Configurar proxy: `litellm --model openai/qwen3-coder-30b --api_base http://localhost:1234/v1`
  4. Variables de entorno: `ANTHROPIC_BASE_URL=http://localhost:4000`, `ANTHROPIC_API_KEY=lm-studio`
- **Nota:** Es opcional, Ollama ya funciona. LM Studio solo si quieres GUI.

### ⏳ #3 Configurar OpenRouter cloud
- **Estado:** pendiente
- **Descripción:** Configurar acceso a modelos cloud vía OpenRouter
- **Pasos necesarios:**
  1. Crear cuenta en https://openrouter.ai/
  2. Obtener API key
  3. Configurar: `ANTHROPIC_BASE_URL=https://openrouter.ai/api/v1`, `ANTHROPIC_API_KEY=<openrouter-key>`
  4. Probar acceso a modelos cloud

### ✅ #4 Completar descarga qwen2.5-coder:32b
- **Estado:** completada
- **Descripción:** Descarga completada exitosamente
- **Task ID background:** bae2277 (exit code 0)
- **Resultado:** Modelo listo para usar (19GB)

---

## Contexto Técnico

### Configuración Actual de Claude Code

**Por defecto (nuevas terminales):**
- Conecta a Anthropic (Sonnet/Opus)
- Variables de entorno de Ollama fueron eliminadas

**Para usar modelos locales:**
```powershell
# Opción 1: Ollama (recomendado)
ollama launch claude --model qwen3-coder:30b
ollama launch claude --model deepseek-coder-v2:16b
ollama launch claude --model qwen2.5-coder:32b

# Opción 2: Manual
$env:ANTHROPIC_BASE_URL = "http://localhost:11434"
$env:ANTHROPIC_AUTH_TOKEN = "ollama"
claude --model qwen3-coder:30b
```

### Modelos Disponibles en Ollama

| Modelo | Tamaño | Estado | Especialidad |
|--------|--------|--------|--------------|
| qwen3-coder:30b | 18GB | ✅ Listo | MoE eficiente, 256K contexto |
| deepseek-coder-v2:16b | 8.9GB | ✅ Listo | Debugging, análisis de código |
| qwen2.5-coder:32b | 19GB | ✅ Listo | Mejor calidad general, 92+ lenguajes |

### Hardware
- RAM disponible: 64GB
- Modelos solo consumen RAM cuando están cargados
- En disco ocupan: 18GB + 8.9GB + 19GB = ~46GB

### Comandos Útiles

```powershell
# Ver modelos descargados
ollama list

# Probar modelo directamente
ollama run qwen3-coder:30b

# Cambiar modelo en Claude Code (comando interno)
/model

# Verificar progreso de descarga
Get-Content "C:\Users\gdali\AppData\Local\Temp\claude\C--Users-gdali\tasks\bae2277.output" -Tail 5
```

---

## Próximos Pasos

### Al Retomar Esta Sesión:

1. **Verificar si terminó qwen2.5-coder:32b:**
   ```powershell
   ollama list
   ```

2. **Probar los 3 modelos con Claude Code:**
   ```powershell
   # En nueva terminal
   ollama launch claude --model qwen3-coder:30b
   # Probar algunos prompts de coding

   # Luego probar con deepseek
   ollama launch claude --model deepseek-coder-v2:16b

   # Luego probar con qwen2.5 (cuando termine)
   ollama launch claude --model qwen2.5-coder:32b
   ```

3. **Comparar rendimiento de los modelos:**
   - Velocidad de respuesta
   - Calidad de código generado
   - Uso de memoria

4. **Decidir si continuar con LM Studio o OpenRouter:**
   - Si Ollama satisface → marcar #2 y #3 como "won't do"
   - Si quieres probar más opciones → continuar con LM Studio o OpenRouter

---

## Historial de Sesiones

### 2026-01-31 (sesión actual)
**Realizado:**
- Instalamos Ollama 0.15.2 vía winget
- Descargamos qwen3-coder:30b (18GB)
- Configuramos variables de entorno para Ollama
- Descargamos deepseek-coder-v2:16b (8.9GB) ✅
- Iniciamos descarga de qwen2.5-coder:32b (19GB) - 89% completo
- Eliminamos variables de entorno permanentes para usar Anthropic por defecto
- Probamos cambio de modelo con /model
- Verificamos que funcionan tanto Anthropic como Ollama

**Decisiones tomadas:**
- Usar Ollama como opción primaria para modelos locales (más simple que LM Studio)
- Dejar LM Studio y OpenRouter como opcionales
- Configuración por defecto: Anthropic
- Para usar local: comando explícito `ollama launch claude`

**Problemas encontrados:**
- Respuestas lentas en Opus 4.5 (solucionado: usar Sonnet para tareas rápidas)
- Variables de entorno causaban conflicto (solucionado: eliminadas)

---

## Notas para Retomar

### Verificaciones Necesarias al Retomar:

1. ✅ Verificar que Ollama esté corriendo:
   ```powershell
   curl http://localhost:11434/api/tags
   ```

2. ✅ Listar modelos disponibles:
   ```powershell
   ollama list
   ```

3. ✅ Si qwen2.5-coder no terminó, verificar progreso o reiniciar descarga:
   ```powershell
   ollama pull qwen2.5-coder:32b
   ```

### Comandos Críticos a Recordar:

```powershell
# Para usar Anthropic (Sonnet/Opus) - DEFAULT
claude

# Para usar Ollama local
ollama launch claude --model qwen3-coder:30b

# Cambiar modelo durante sesión
/model

# Ver qué está usando Claude Code actualmente
# (si dice "model not found" → está en Anthropic)
# (si funciona con modelos locales → está en Ollama)
```

### Referencias:
- Documentación Ollama: https://ollama.com/library
- Claude Code + Ollama: https://thushan.github.io/olla/integrations/frontend/claude-code/
- Comparación modelos coding: https://www.codegpt.co/blog/best-ollama-model-for-coding

---

## Estado de Descargas en Background

**Task ID bae2277 (qwen2.5-coder:32b):**
- Estado: running
- Progreso: 89% (17GB/19GB)
- Tiempo restante estimado: ~4 minutos
- Output: C:\Users\gdali\AppData\Local\Temp\claude\C--Users-gdali\tasks\bae2277.output
- Comando: `ollama pull qwen2.5-coder:32b`

**Task ID b5241ac (deepseek-coder-v2:16b):**
- Estado: ✅ completed (exit code 0)
- Tamaño final: 8.9GB
- Resultado: success

---

**Próxima sesión:** Probar los 3 modelos locales y decidir configuración de LM Studio/OpenRouter
