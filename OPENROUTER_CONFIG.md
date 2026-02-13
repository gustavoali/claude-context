# OpenRouter - Configuración

**Fecha de creación:** 2026-02-01
**Estado:** ACTIVO

---

## ⚠️ ARCHIVO SENSIBLE

Este archivo contiene credenciales de acceso. **NO compartir** y **NO commitear a Git**.

---

## API Key

**API Key:** `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`

**Cuenta:** Registrada el 2026-02-01
**Provider:** OpenRouter (https://openrouter.ai/)

---

## Configuración para Claude Code

### Opción 1: Variables de Entorno (Temporales)

```powershell
# PowerShell - Variables de sesión
$env:ANTHROPIC_BASE_URL = "https://openrouter.ai/api/v1"
$env:ANTHROPIC_API_KEY = "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"

# Lanzar Claude Code
claude
```

### Opción 2: Variables de Entorno (Permanentes)

```powershell
# PowerShell - Configurar permanente para usuario
[System.Environment]::SetEnvironmentVariable('ANTHROPIC_BASE_URL', 'https://openrouter.ai/api/v1', 'User')
[System.Environment]::SetEnvironmentVariable('ANTHROPIC_API_KEY', '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', 'User')

# Reiniciar terminal para que tome efecto
```

### Opción 3: Archivo .env (Recomendado)

Crear archivo `.env` en tu directorio de trabajo:

```env
ANTHROPIC_BASE_URL=https://openrouter.ai/api/v1
ANTHROPIC_API_KEY=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
```

**Importante:** Agregar `.env` a `.gitignore`

---

## Modelos Recomendados

### Modelos Gratuitos

```
meta-llama/llama-3-8b-instruct (free)
meta-llama/llama-3-70b-instruct (free)
google/gemini-flash-1.5 (free tier)
```

### Modelos de Coding (Económicos)

```
deepseek/deepseek-coder (~$0.0002/1K tokens)
qwen/qwen-2.5-coder-32b-instruct (~$0.0006/1K tokens)
qwen/qwen-2.5-coder-7b-instruct (muy económico)
```

### Modelos Premium

```
anthropic/claude-3.5-sonnet (~$0.003/1K tokens)
openai/gpt-4-turbo (~$0.01/1K tokens)
google/gemini-pro-1.5 (~$0.00025/1K tokens)
```

---

## Uso con Claude Code

### Cambiar modelo durante sesión:

```
/model
```

Seleccionar del listado disponible.

### Verificar qué modelo estás usando:

Claude Code muestra el modelo actual en el prompt o status.

---

## Créditos y Billing

**Dashboard:** https://openrouter.ai/credits

**Verificar:**
- Créditos gratuitos disponibles
- Uso actual
- Historial de requests

**Nota:** Algunos usuarios reportan créditos iniciales de $1-5 USD para probar el servicio.

---

## Troubleshooting

### Error 401 - Unauthorized

- Verificar que la API key está correcta
- Verificar que las variables de entorno están configuradas
- Reiniciar terminal

### Error 429 - Rate Limit

- Estás en tier gratuito con limits
- Esperar 1 minuto y reintentar
- Considerar upgrade si necesitas más requests

### Respuestas lentas

- Probar con modelo más pequeño (7B vs 70B)
- Verificar latencia de red: `ping openrouter.ai`
- Probar en diferente horario (menos carga)

---

## Seguridad

### ✅ Buenas Prácticas

- ✅ NO compartir esta API key
- ✅ NO commitear este archivo a Git
- ✅ Rotar key si se compromete
- ✅ Usar variables de entorno, no hardcodear

### ❌ NO Hacer

- ❌ NO subir a repositorio público
- ❌ NO compartir en chat/email
- ❌ NO guardar en código fuente
- ❌ NO compartir screenshots con la key visible

### Si la key se compromete:

1. Ir a https://openrouter.ai/keys
2. Revocar la key comprometida
3. Crear nueva key
4. Actualizar este archivo

---

## Configuración con LiteLLM (LM Studio + OpenRouter)

**Configurado:** 2026-02-03

### Archivos creados:

```
~/.litellm/
├── config.yaml           # Configuración de modelos
├── start-proxy.ps1       # Script para iniciar proxy
└── claude-with-litellm.ps1  # Script para iniciar Claude Code
```

### Uso rápido:

```powershell
# Terminal 1: Iniciar proxy
cd ~/.litellm
.\start-proxy.ps1

# Terminal 2: Iniciar Claude Code
cd ~/.litellm
.\claude-with-litellm.ps1
```

### Modelos disponibles:

| Nombre | Provider | Descripción |
|--------|----------|-------------|
| `local` | LM Studio | Modelo local (requiere LM Studio corriendo) |
| `deepseek` | OpenRouter | DeepSeek Coder (~$0.0002/1K tokens) |
| `qwen` | OpenRouter | Qwen 2.5 Coder 32B |
| `claude` | OpenRouter | Claude 3.5 Sonnet (~$0.003/1K tokens) |
| `gpt4` | OpenRouter | GPT-4 Turbo (~$0.01/1K tokens) |
| `llama` | OpenRouter | Llama 3.1 70B |
| `gemini` | OpenRouter | Gemini Pro 1.5 (~$0.00025/1K tokens) |

### Fallback automático:

Si `local` falla → usa `deepseek` → si falla → usa `qwen`

---

## Historial de Cambios

| Fecha | Acción |
|-------|--------|
| 2026-02-03 | Configuración LiteLLM con LM Studio + OpenRouter |
| 2026-02-01 | Creación inicial, primera API key registrada |

---

**⚠️ RECORDATORIO: Este archivo contiene información sensible. Proteger adecuadamente.**
