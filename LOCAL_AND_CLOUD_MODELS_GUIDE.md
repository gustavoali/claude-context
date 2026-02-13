# Guía Completa: Modelos LLM Locales y Cloud

**Versión:** 1.0
**Fecha:** 2026-02-01
**Estado:** REFERENCIA TÉCNICA

---

## 📋 Índice

1. [Introducción](#introducción)
2. [Conceptos Fundamentales](#conceptos-fundamentales)
3. [Ollama - Modelos Locales](#ollama---modelos-locales)
4. [Ollama Cloud Models](#ollama-cloud-models)
5. [OpenRouter - Multi-Provider Cloud](#openrouter---multi-provider-cloud)
6. [LiteLLM - Proxy Unificado](#litellm---proxy-unificado)
7. [LM Studio - GUI Local](#lm-studio---gui-local)
8. [Comparación de Opciones](#comparación-de-opciones)
9. [Guías de Configuración](#guías-de-configuración)
10. [Recomendaciones por Caso de Uso](#recomendaciones-por-caso-de-uso)
11. [Troubleshooting](#troubleshooting)
12. [Referencias](#referencias)

---

## Introducción

Esta guía documenta las diferentes opciones para ejecutar modelos de lenguaje (LLMs), ya sea localmente en tu máquina o en la nube. Es especialmente útil para desarrolladores que usan Claude Code y quieren alternativas o complementos a los modelos de Anthropic.

### ¿Por qué usar modelos alternativos?

- **Costo:** Modelos locales son gratis (solo hardware)
- **Privacidad:** Datos quedan en tu máquina
- **Offline:** Trabajar sin internet
- **Experimentación:** Probar diferentes modelos
- **Velocidad:** Modelos cloud optimizados con GPU

---

## Conceptos Fundamentales

### Modelos Locales vs Cloud

| Aspecto | Modelos Locales | Modelos Cloud |
|---------|----------------|---------------|
| **Hardware** | Tu CPU/GPU | Datacenter GPU |
| **Velocidad** | 1-10 tokens/s (CPU) | 50-200 tokens/s |
| **Costo** | Gratis (hardware ya comprado) | Pay-per-use |
| **Privacidad** | 100% local | Depende del provider |
| **Tamaño** | Limitado por RAM (hasta ~32B) | Sin límites (hasta 671B+) |
| **Internet** | No necesario | Requerido |

### Tipos de Modelos

**Por tamaño:**
- **Pequeños (1-7B):** Rápidos, menos capaces (TinyLlama, Phi-2)
- **Medianos (7-13B):** Balance (Llama 2, Mistral)
- **Grandes (13-70B):** Muy capaces, requieren mucha RAM
- **Masivos (70B+):** Solo cloud (GPT-4, Claude Opus)

**Por especialidad:**
- **Coding:** DeepSeek Coder, Qwen Coder, CodeLlama
- **General:** Llama, Mistral, Gemma
- **Chat:** ChatGPT, Claude, Gemini

---

## Ollama - Modelos Locales

### ¿Qué es Ollama?

**Ollama** es la herramienta más popular para ejecutar modelos LLM localmente. Simplifica la descarga, gestión y ejecución de modelos open source.

### Características

- ✅ CLI simple e intuitiva
- ✅ Auto-gestión de modelos (descarga, actualización)
- ✅ API REST compatible con OpenAI
- ✅ Soporte para CPU y GPU (NVIDIA, AMD, Metal)
- ✅ Optimización automática para tu hardware
- ✅ Cuantización (modelos más livianos)

### Instalación

**Windows:**
```powershell
# Opción 1: winget
winget install Ollama.Ollama

# Opción 2: Descargar instalador
# https://ollama.ai/download
```

**Verificar instalación:**
```powershell
ollama --version
# Output: ollama version is 0.15.2
```

### Modelos Recomendados para Coding

| Modelo | Tamaño | RAM Mínima | Especialidad |
|--------|--------|------------|--------------|
| `qwen3-coder:30b` | 18GB | 20GB | MoE eficiente, 256K contexto |
| `deepseek-coder-v2:16b` | 8.9GB | 12GB | Debugging, análisis |
| `qwen2.5-coder:32b` | 19GB | 22GB | Alta calidad, 92+ lenguajes |
| `codellama:13b` | 7.4GB | 10GB | Meta's coding model |
| `mistral:7b` | 4.1GB | 6GB | General purpose, rápido |

### Comandos Básicos

```powershell
# Descargar modelo
ollama pull qwen3-coder:30b

# Listar modelos instalados
ollama list

# Ejecutar modelo interactivo
ollama run qwen3-coder:30b

# Eliminar modelo
ollama rm qwen3-coder:30b

# Ver modelos disponibles
# https://ollama.com/library
```

### Uso con Claude Code

**Opción 1: Comando Ollama launch**
```powershell
ollama launch claude --model qwen3-coder:30b
```

**Opción 2: Variables de entorno**
```powershell
$env:ANTHROPIC_BASE_URL = "http://localhost:11434"
$env:ANTHROPIC_AUTH_TOKEN = "ollama"
claude --model qwen3-coder:30b
```

### Ventajas y Limitaciones

**Ventajas:**
- ✅ Completamente gratis
- ✅ 100% privado (datos no salen de tu máquina)
- ✅ Funciona offline
- ✅ Rápido de configurar

**Limitaciones:**
- ❌ Velocidad limitada por CPU (1-10 tokens/s sin GPU)
- ❌ Modelos grandes (32B+) muy lentos en CPU
- ❌ Requiere RAM significativa
- ❌ No soporta modelos comerciales (GPT-4, Claude)

---

## Ollama Cloud Models

### ¿Qué es Ollama Cloud?

**Ollama Cloud Models** es una feature nueva (preview desde v0.12) que permite ejecutar modelos **masivos** en servidores cloud de Ollama, manteniendo la misma interfaz CLI familiar.

### Características Clave

- ✅ Misma interfaz de Ollama (comandos idénticos)
- ✅ Modelos masivos (hasta 671B parámetros)
- ✅ GPU datacenter (respuestas rápidas)
- ✅ Privacidad: Ollama no retiene datos
- ✅ Integración transparente (mezcla local + cloud)

### Modelos Disponibles (Preview)

| Modelo | Tamaño | Tag Cloud |
|--------|--------|-----------|
| **Qwen3 Coder** | 480B | `qwen3-coder:480b-cloud` |
| **DeepSeek V3.1** | 671B | `deepseek-v3.1:671b-cloud` |
| **GPT-OSS** | 120B | `gpt-oss:120b-cloud` |
| **GPT-OSS** | 20B | `gpt-oss:20b-cloud` |

**Nota:** Estos modelos son 10-20x más grandes que los que puedes correr localmente.

### Configuración

**Requisitos:**
- Ollama v0.12 o superior ✅
- Cuenta en ollama.com
- Conexión a internet

**Setup (3 pasos):**

```powershell
# Paso 1: Verificar versión
ollama --version
# Debe ser >= v0.12

# Paso 2: Autenticarse
ollama signin
# Abre navegador para login en ollama.com

# Paso 3: "Pull" modelo cloud
ollama pull qwen3-coder:480b-cloud
```

### Uso

```powershell
# Ejecutar modelo cloud (idéntico a local)
ollama run qwen3-coder:480b-cloud

# Usar con Claude Code
ollama launch claude --model qwen3-coder:480b-cloud

# Listar modelos (locales + cloud)
ollama list
# Los cloud tienen tag ":cloud"
```

### Cómo Identificar Modelos Cloud

```
Formato: [nombre-modelo]:[tamaño]-cloud
                                  ^^^^^
                                  Tag que indica cloud

Ejemplos:
- qwen3-coder:30b        → LOCAL
- qwen3-coder:480b-cloud → CLOUD
- deepseek-v3.1:671b-cloud → CLOUD
```

### Ventajas vs Local

| Aspecto | Ollama Local | Ollama Cloud |
|---------|--------------|--------------|
| **Velocidad** | 1-10 tok/s (CPU) | 50-150 tok/s |
| **Tamaño máximo** | ~32B (según RAM) | 671B+ |
| **Hardware requerido** | RAM significativa | Solo internet |
| **Interfaz** | CLI Ollama | CLI Ollama (idéntica) |
| **Costo** | Gratis | 🤷 No documentado |

### Pricing

**Estado:** No hay información pública de precios (preview)

**Especulación:**
- Probablemente pay-per-use como otros servicios cloud
- Posiblemente créditos gratis para preview
- Verificar en ollama.com después de signin

### Limitaciones Actuales

- ⚠️ Solo 4 modelos disponibles (preview)
- ⚠️ Requiere autenticación (no offline)
- ⚠️ Pricing no transparente aún
- ⚠️ Feature en preview (puede cambiar)

---

## OpenRouter - Multi-Provider Cloud

### ¿Qué es OpenRouter?

**OpenRouter** es un proxy cloud que te da acceso a modelos de **múltiples providers** (OpenAI, Anthropic, Google, Meta, etc.) mediante una API unificada.

### Características

- ✅ 100+ modelos de todos los providers
- ✅ API unificada (formato OpenAI)
- ✅ Pay-per-use (sin suscripciones)
- ✅ Pricing transparente por token
- ✅ Switching rápido entre modelos
- ✅ Fallbacks automáticos opcionales

### Modelos Disponibles

**Coding Models:**
- DeepSeek Coder V2 (~$0.0002/1K tokens)
- Qwen 2.5 Coder (~$0.0006/1K tokens)
- CodeLlama 70B
- GPT-4 Turbo (~$0.01/1K tokens)

**General Models:**
- Claude 3.5 Sonnet (~$0.003/1K tokens)
- Claude 3 Opus (~$0.015/1K tokens)
- GPT-4, GPT-4 Turbo
- Gemini Pro 1.5 (~$0.00025/1K tokens)
- Llama 3 70B (~$0.0006/1K tokens)
- Mixtral 8x22B

**Ventaja:** Puedes probar GPT-4, Claude, Gemini sin múltiples suscripciones.

### Configuración

**Paso 1: Crear cuenta y obtener API key**

```powershell
# Abrir navegador
start https://openrouter.ai/

# 1. Sign up (Google/GitHub)
# 2. Ir a "Keys" en menu
# 3. Create new API key
# 4. Copiar (empieza con sk-or-v1-...)
```

**Paso 2: Configurar Claude Code**

```powershell
# Variables de entorno
$env:ANTHROPIC_BASE_URL = "https://openrouter.ai/api/v1"
$env:ANTHROPIC_API_KEY = "sk-or-v1-TU_KEY_AQUI"

# Lanzar Claude Code
claude
```

**Paso 3: Usar modelos**

```powershell
# Dentro de Claude Code, usar /model para seleccionar
/model

# O especificar modelo en comando
claude --model deepseek/deepseek-coder
```

### Pricing

**Modelo pay-per-use:**
- No suscripción mensual
- Pagas por tokens consumidos
- Precios varían por modelo

**Ejemplos de costo:**

| Modelo | Input (1K tokens) | Output (1K tokens) |
|--------|-------------------|-------------------|
| DeepSeek Coder | $0.00014 | $0.00028 |
| Qwen 2.5 Coder | $0.0006 | $0.0006 |
| GPT-4 Turbo | $0.01 | $0.03 |
| Claude Sonnet | $0.003 | $0.015 |
| Gemini Pro | $0.000125 | $0.000375 |

**Estimación de uso real:**
- 100 prompts de coding (5K tokens c/u) = 500K tokens
- Con DeepSeek: ~$0.10 USD
- Con Qwen: ~$0.30 USD
- Con GPT-4: ~$15 USD

**Créditos gratis:** Algunos usuarios reportan $1-5 iniciales (no garantizado).

### Ventajas

- ✅ Acceso a modelos de todos los providers
- ✅ Sin múltiples suscripciones
- ✅ Pricing transparente
- ✅ Muy económico (DeepSeek, Qwen, Gemini)
- ✅ Puedes probar GPT-4, Claude sin compromiso
- ✅ API estándar OpenAI

### Limitaciones

- ❌ Requiere internet
- ❌ Costo por uso (aunque bajo)
- ❌ No tan simple como Ollama
- ❌ Datos pasan por third-party

---

## LiteLLM - Proxy Unificado

### ¿Qué es LiteLLM?

**LiteLLM** es un proxy/middleware que **traduce** entre diferentes APIs de LLM a un formato unificado. Permite usar múltiples providers con el mismo código.

### Casos de Uso

**Cuándo usar LiteLLM:**
- ✅ Quieres usar múltiples providers (OpenAI + Anthropic + Ollama)
- ✅ Necesitas fallbacks (si falla provider A → usar provider B)
- ✅ Quieres caching de respuestas
- ✅ Necesitas load balancing
- ✅ Integrar LM Studio con Claude Code

**Cuándo NO necesitas LiteLLM:**
- ❌ Usando solo Ollama → Ollama ya tiene API
- ❌ Usando solo OpenRouter → OpenRouter ya es proxy
- ❌ Setup simple → Agrega complejidad innecesaria

### Arquitectura

```
┌──────────────────────────────────────────┐
│  Claude Code                             │
│      ↓                                   │
│  LiteLLM Proxy (localhost:4000)         │
│      ↓                                   │
│  ┌─────────┬──────────┬────────────┐   │
│  │ Ollama  │ OpenAI   │ Anthropic  │   │
│  │ (local) │ (cloud)  │ (cloud)    │   │
│  └─────────┴──────────┴────────────┘   │
└──────────────────────────────────────────┘
```

### Instalación

```powershell
# Instalar LiteLLM
pip install litellm

# Verificar
litellm --version
```

### Configuración

**Crear config.yaml:**

```yaml
# litellm_config.yaml
model_list:
  - model_name: gpt-4
    litellm_params:
      model: openai/gpt-4
      api_key: os.environ/OPENAI_API_KEY

  - model_name: claude-3
    litellm_params:
      model: anthropic/claude-3-sonnet
      api_key: os.environ/ANTHROPIC_API_KEY

  - model_name: qwen-local
    litellm_params:
      model: ollama/qwen3-coder:30b
      api_base: http://localhost:11434

# Fallback automático
fallbacks:
  - model: gpt-4
    fallbacks: [claude-3, qwen-local]

# Caching
cache:
  type: redis
  host: localhost
  port: 6379
```

**Iniciar proxy:**

```powershell
# Con configuración
litellm --config litellm_config.yaml

# Simple (puerto default 4000)
litellm --model ollama/qwen3-coder:30b --api_base http://localhost:11434
```

**Conectar Claude Code:**

```powershell
$env:ANTHROPIC_BASE_URL = "http://localhost:4000"
$env:ANTHROPIC_API_KEY = "any-key"
claude
```

### Features Avanzadas

**1. Fallbacks automáticos:**
```yaml
fallbacks:
  - model: gpt-4
    fallbacks: [claude-3, gpt-3.5]
```

**2. Load balancing:**
```yaml
router_settings:
  routing_strategy: latency-based-routing
```

**3. Caching:**
```yaml
cache:
  type: local  # o redis
  ttl: 3600
```

**4. Rate limiting:**
```yaml
rate_limit:
  rpm: 100  # requests per minute
```

### Ventajas

- ✅ Máxima flexibilidad
- ✅ Fallbacks y redundancia
- ✅ Caching (ahorro de costos)
- ✅ Unifica múltiples providers
- ✅ Load balancing

### Limitaciones

- ❌ Más complejo de configurar
- ❌ Necesitas mantener proxy corriendo
- ❌ Overhead adicional (latencia mínima)
- ❌ Overkill para casos simples

---

## LM Studio - GUI Local

### ¿Qué es LM Studio?

**LM Studio** es una aplicación de escritorio con **interfaz gráfica** para ejecutar modelos LLM localmente. Alternativa visual a Ollama.

### Características

- ✅ GUI amigable (sin CLI)
- ✅ Descarga modelos con clicks
- ✅ Server local con API OpenAI-compatible
- ✅ Chat interface incluida
- ✅ Configuración visual de parámetros
- ✅ Soporte GPU (NVIDIA, AMD, Metal)

### Instalación

```powershell
# Descargar desde
start https://lmstudio.ai/

# Instalador Windows (.exe)
# Tamaño: ~200MB
```

### Uso Básico

**1. Descargar modelos:**
- Abrir LM Studio
- Ir a "Discover"
- Buscar modelo (ej: "qwen coder")
- Click "Download"

**2. Cargar modelo:**
- Ir a "Chat"
- Seleccionar modelo del dropdown
- Click "Load model"

**3. Chatear:**
- Interfaz similar a ChatGPT
- Ajustar parámetros (temperature, context, etc.)

### Integración con Claude Code

**Opción 1: LM Studio Server + LiteLLM**

```powershell
# Paso 1: En LM Studio, iniciar server
# Developer → Start Server → localhost:1234

# Paso 2: Instalar LiteLLM
pip install litellm

# Paso 3: Proxy LiteLLM → LM Studio
litellm --model openai/qwen3-coder-30b --api_base http://localhost:1234/v1

# Paso 4: Claude Code → LiteLLM
$env:ANTHROPIC_BASE_URL = "http://localhost:4000"
$env:ANTHROPIC_API_KEY = "lm-studio"
claude
```

**Opción 2: API directa (si Claude Code soporta)**

```powershell
# LM Studio server en localhost:1234
$env:ANTHROPIC_BASE_URL = "http://localhost:1234/v1"
$env:ANTHROPIC_API_KEY = "lm-studio"
claude
```

### Ventajas

- ✅ No requiere CLI (amigable para no-técnicos)
- ✅ Configuración visual
- ✅ Chat interface incluida
- ✅ Monitoreo de uso de recursos (RAM, GPU)

### Limitaciones

- ❌ GUI consume más recursos que Ollama CLI
- ❌ Menos scriptable/automatable
- ❌ Requiere LiteLLM para Claude Code
- ❌ Más pesado que Ollama

---

## Comparación de Opciones

### Tabla Comparativa Completa

| Característica | Ollama Local | Ollama Cloud | OpenRouter | LiteLLM | LM Studio |
|----------------|--------------|--------------|------------|---------|-----------|
| **Tipo** | Local CLI | Cloud CLI | Cloud API | Proxy | Local GUI |
| **Instalación** | Simple | Simple | API key | pip install | Instalador GUI |
| **Modelos** | Open source locales | 4 modelos masivos | 100+ todos providers | Cualquiera | Open source locales |
| **Tamaño máx** | ~32B (según RAM) | 671B | Sin límite | N/A | ~32B (según RAM) |
| **Velocidad** | 1-10 tok/s CPU | 50-150 tok/s | 50-200 tok/s | Depende backend | 1-10 tok/s CPU |
| **Costo** | Gratis | 🤷 TBD | Pay-per-use | Gratis (pagas backend) | Gratis |
| **Internet** | No | Sí | Sí | Depende | No |
| **Privacidad** | 100% local | No retiene datos | Según provider | Según backend | 100% local |
| **Claude Code** | ✅ Nativo | ✅ Nativo | ✅ Configuración | ⚠️ Proxy requerido | ⚠️ LiteLLM requerido |
| **Complejidad** | Baja | Baja | Baja | Alta | Media |
| **Mejor para** | Dev offline | Modelos masivos | Probar múltiples | Setup avanzado | No-técnicos |

### Matriz de Decisión

```
┌─────────────────────────────────────────────────────────┐
│  ¿Tienes GPU potente?                                   │
│  ├─ SÍ → Ollama Local (gratis, rápido)                 │
│  └─ NO →                                                │
│      ├─ ¿Necesitas modelos masivos (100B+)?            │
│      │   └─ SÍ → Ollama Cloud o OpenRouter             │
│      └─ ¿Necesitas modelos comerciales (GPT-4)?        │
│          └─ SÍ → OpenRouter                            │
│          └─ NO → Ollama Local (aunque lento)           │
│                                                         │
│  ¿Quieres GUI?                                          │
│  └─ SÍ → LM Studio                                     │
│                                                         │
│  ¿Necesitas fallbacks/caching avanzado?                │
│  └─ SÍ → LiteLLM                                       │
└─────────────────────────────────────────────────────────┘
```

---

## Guías de Configuración

### Setup 1: Ollama Local + Claude Code

**Tiempo:** 10 minutos
**Costo:** Gratis
**Mejor para:** Desarrollo offline, privacidad

```powershell
# Paso 1: Instalar Ollama
winget install Ollama.Ollama

# Paso 2: Descargar modelo
ollama pull qwen3-coder:30b

# Paso 3: Usar con Claude Code
ollama launch claude --model qwen3-coder:30b
```

---

### Setup 2: Ollama Cloud + Claude Code

**Tiempo:** 5 minutos
**Costo:** TBD (preview)
**Mejor para:** Modelos masivos, velocidad

```powershell
# Paso 1: Verificar versión Ollama (>=0.12)
ollama --version

# Paso 2: Autenticarse
ollama signin

# Paso 3: Pull modelo cloud
ollama pull qwen3-coder:480b-cloud

# Paso 4: Usar con Claude Code
ollama launch claude --model qwen3-coder:480b-cloud
```

---

### Setup 3: OpenRouter + Claude Code

**Tiempo:** 5 minutos
**Costo:** Pay-per-use
**Mejor para:** Múltiples providers, modelos comerciales

```powershell
# Paso 1: Crear cuenta y obtener API key
start https://openrouter.ai/

# Paso 2: Configurar variables
$env:ANTHROPIC_BASE_URL = "https://openrouter.ai/api/v1"
$env:ANTHROPIC_API_KEY = "sk-or-v1-[TU_KEY]"

# Paso 3: Lanzar Claude Code
claude

# Paso 4: Seleccionar modelo
/model
# Elegir: deepseek/deepseek-coder o qwen/qwen-2.5-coder
```

---

### Setup 4: LM Studio + LiteLLM + Claude Code

**Tiempo:** 20 minutos
**Costo:** Gratis
**Mejor para:** GUI lovers, experimentación visual

```powershell
# Paso 1: Descargar e instalar LM Studio
start https://lmstudio.ai/

# Paso 2: En LM Studio
# - Descargar modelo (ej: qwen3-coder)
# - Developer → Start Server (localhost:1234)

# Paso 3: Instalar LiteLLM
pip install litellm

# Paso 4: Iniciar proxy
litellm --model openai/qwen3-coder-30b --api_base http://localhost:1234/v1

# Paso 5: Configurar Claude Code
$env:ANTHROPIC_BASE_URL = "http://localhost:4000"
$env:ANTHROPIC_API_KEY = "lm-studio"

# Paso 6: Lanzar Claude Code
claude
```

---

### Setup 5: Multi-Provider con LiteLLM

**Tiempo:** 30 minutos
**Costo:** Según providers
**Mejor para:** Máxima flexibilidad, producción

```powershell
# Paso 1: Instalar LiteLLM
pip install litellm

# Paso 2: Crear configuración
# Crear archivo: litellm_config.yaml
```

```yaml
model_list:
  # Ollama local
  - model_name: qwen-local
    litellm_params:
      model: ollama/qwen3-coder:30b
      api_base: http://localhost:11434

  # OpenRouter cloud
  - model_name: deepseek-cloud
    litellm_params:
      model: deepseek/deepseek-coder
      api_base: https://openrouter.ai/api/v1
      api_key: os.environ/OPENROUTER_API_KEY

  # Anthropic directo
  - model_name: claude
    litellm_params:
      model: anthropic/claude-3-sonnet
      api_key: os.environ/ANTHROPIC_API_KEY

# Fallback: Local → Cloud
fallbacks:
  - model: qwen-local
    fallbacks: [deepseek-cloud, claude]

# Caching
cache:
  type: local
  ttl: 3600
```

```powershell
# Paso 3: Configurar API keys
$env:OPENROUTER_API_KEY = "sk-or-v1-..."
$env:ANTHROPIC_API_KEY = "sk-ant-..."

# Paso 4: Iniciar LiteLLM
litellm --config litellm_config.yaml

# Paso 5: Claude Code
$env:ANTHROPIC_BASE_URL = "http://localhost:4000"
claude
```

---

## Recomendaciones por Caso de Uso

### Caso 1: "Quiero empezar rápido y gratis"

**Recomendación:** Ollama Local

```powershell
winget install Ollama.Ollama
ollama pull qwen3-coder:30b
ollama launch claude --model qwen3-coder:30b
```

**Por qué:**
- Setup en 5 minutos
- Gratis total
- No requiere cuenta/API key

---

### Caso 2: "Mi laptop es lenta, necesito velocidad"

**Recomendación:** Ollama Cloud Models

```powershell
ollama signin
ollama pull qwen3-coder:480b-cloud
ollama launch claude --model qwen3-coder:480b-cloud
```

**Por qué:**
- Mismo comando familiar
- GPU datacenter (50-150 tok/s)
- Modelo masivo (480B vs 30B local)

---

### Caso 3: "Quiero probar GPT-4 y otros modelos comerciales"

**Recomendación:** OpenRouter

```powershell
# Setup
$env:ANTHROPIC_BASE_URL = "https://openrouter.ai/api/v1"
$env:ANTHROPIC_API_KEY = "sk-or-v1-..."
claude
```

**Por qué:**
- Acceso a GPT-4, Claude, Gemini
- Pay-per-use (sin suscripciones)
- 100+ modelos

---

### Caso 4: "No me gusta la terminal, quiero GUI"

**Recomendación:** LM Studio

**Por qué:**
- Interfaz visual amigable
- Chat interface incluida
- Configuración con clicks

---

### Caso 5: "Trabajo sin internet frecuentemente"

**Recomendación:** Ollama Local + LM Studio

**Por qué:**
- 100% offline
- Modelos descargados localmente
- Sin dependencia de cloud

---

### Caso 6: "Necesito setup empresarial con fallbacks"

**Recomendación:** LiteLLM Multi-Provider

```yaml
fallbacks:
  - model: ollama-local
    fallbacks: [openrouter-cloud, anthropic-api]
```

**Por qué:**
- Redundancia automática
- Caching (ahorro de costos)
- Control total
- Métricas y monitoring

---

## Troubleshooting

### Problema: "Ollama no responde"

```powershell
# Verificar que Ollama está corriendo
curl http://localhost:11434/api/tags

# Si falla, reiniciar Ollama
# Windows: Services → Ollama → Restart
```

---

### Problema: "Respuestas muy lentas en Ollama local"

**Causa:** Modelo muy grande para tu CPU

**Soluciones:**
1. Usar modelo más pequeño: `ollama pull mistral:7b`
2. Cambiar a Ollama Cloud: `ollama pull qwen3-coder:480b-cloud`
3. Agregar GPU dedicada (NVIDIA)

**Velocidades esperadas:**
- CPU: 1-10 tokens/s
- GPU integrada: 10-30 tokens/s
- GPU dedicada: 50-200 tokens/s

---

### Problema: "Claude Code no conecta a Ollama"

```powershell
# Verificar variables de entorno
echo $env:ANTHROPIC_BASE_URL
# Debe ser: http://localhost:11434

echo $env:ANTHROPIC_API_KEY
# Debe ser: ollama

# Verificar modelo existe
ollama list

# Probar comando directo
ollama run qwen3-coder:30b
```

---

### Problema: "OpenRouter devuelve error 401"

**Causa:** API key incorrecta o no configurada

```powershell
# Verificar variable
echo $env:ANTHROPIC_API_KEY
# Debe empezar con: sk-or-v1-...

# Verificar en OpenRouter web
start https://openrouter.ai/keys

# Regenerar key si es necesario
```

---

### Problema: "LiteLLM proxy no inicia"

```powershell
# Verificar instalación
pip show litellm

# Reinstalar si necesario
pip install --upgrade litellm

# Verificar puerto no en uso
netstat -ano | findstr :4000

# Cambiar puerto si conflicto
litellm --port 8000 --config config.yaml
```

---

### Problema: "Ollama Cloud dice 'signin required'"

```powershell
# Autenticarse
ollama signin

# Verificar autenticación
ollama list
# Debe mostrar modelos cloud disponibles

# Si sigue fallando, logout y re-signin
ollama signout
ollama signin
```

---

### Problema: "Modelo se queda sin memoria"

**Síntomas:**
- Sistema se congela
- Error "out of memory"
- Respuestas muy lentas

**Soluciones:**
```powershell
# Ver modelos cargados
ollama ps

# Descargar modelo del tamaño correcto
# Regla: Modelo tamaño X → necesitas X * 1.5 RAM

# Ejemplos:
# 7B modelo → 12GB RAM mínimo
# 13B modelo → 20GB RAM mínimo
# 30B modelo → 45GB RAM mínimo

# Usar modelo más pequeño si no tienes RAM
ollama pull mistral:7b
```

---

## Referencias

### Documentación Oficial

- **Ollama:** https://ollama.com/
  - Docs: https://docs.ollama.com/
  - Library: https://ollama.com/library
  - Cloud: https://docs.ollama.com/cloud
  - Blog Cloud Models: https://ollama.com/blog/cloud-models

- **OpenRouter:** https://openrouter.ai/
  - Docs: https://openrouter.ai/docs
  - Models: https://openrouter.ai/models
  - Pricing: https://openrouter.ai/models (ver cada modelo)

- **LiteLLM:** https://litellm.ai/
  - Docs: https://docs.litellm.ai/
  - GitHub: https://github.com/BerriAI/litellm

- **LM Studio:** https://lmstudio.ai/
  - Docs: https://lmstudio.ai/docs

- **Claude Code:** https://claude.ai/code
  - Docs: https://docs.claude.com/en/docs/claude-code

### Guías y Tutoriales

- Ollama + Claude Code: https://thushan.github.io/olla/integrations/frontend/claude-code/
- Best Ollama Models for Coding: https://www.codegpt.co/blog/best-ollama-model-for-coding
- Ollama Cloud Beginner's Guide: https://dev.to/coderforfun/a-beginners-guide-to-ollama-cloud-models-3lc2
- LiteLLM Setup Guide: https://docs.litellm.ai/docs/proxy/quick_start

### Comparación de Modelos

- Coding Models Benchmark: https://paperswithcode.com/task/code-generation
- LLM Performance Leaderboard: https://huggingface.co/spaces/HuggingFaceH4/open_llm_leaderboard
- OpenRouter Model Explorer: https://openrouter.ai/models

### Comunidad y Soporte

- Ollama Discord: https://discord.gg/ollama
- OpenRouter Discord: https://discord.gg/openrouter
- LiteLLM Discord: https://discord.gg/litellm
- Reddit r/LocalLLaMA: https://reddit.com/r/LocalLLaMA

---

## Historial de Cambios

| Fecha | Versión | Cambios |
|-------|---------|---------|
| 2026-02-01 | 1.0 | Creación inicial del documento |

---

**Mantenedor:** Claude Code User
**Última revisión:** 2026-02-01
**Estado:** Activo - Referencia técnica completa
