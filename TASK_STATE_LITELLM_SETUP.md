# Estado de Tareas - Configuracion LiteLLM + OpenRouter

**Ultima actualizacion:** 2026-02-04 (cierre de sesion)
**Sesion activa:** No

---

## Resumen Ejecutivo

**Trabajo realizado:** Configuracion de arranque dual de Claude Code (Anthropic + modelos alternativos via LiteLLM/OpenRouter)
**Estado:** Funcional con reservas - pendiente prueba final con CLAUDE_CONFIG_DIR
**Bloqueantes:** Ninguno

---

## Tareas Completadas

### 1. COMPLETADA - Conversion CV a PDF
- Andrea_Paola_Traverzaro_CV.docx -> PDF
- Instalado docx2pdf para futuras conversiones

### 2. COMPLETADA - Investigacion OpenRouter
- Revisada documentacion oficial
- API key ya existente en C:/claude_context/OPENROUTER_CONFIG.md

### 3. COMPLETADA - Instalacion LiteLLM
- `pip install "litellm[proxy]"` instalado correctamente
- Proxy funciona en puerto 4000

### 4. COMPLETADA - Configuracion LiteLLM
- Config: `~/.litellm/config.yaml`
- Modelos configurados: local (LM Studio), deepseek, qwen, claude, gpt4, llama, gemini
- Fallback: local -> deepseek -> qwen
- Script proxy: `~/.litellm/start-proxy.ps1`

### 5. COMPLETADA - Scripts de arranque dual
- `~/claude-launcher.ps1` - Menu selector
- `~/claude-anthropic.ps1` - Modo Anthropic (default, sin cambios)
- `~/claude-alternativo.ps1` - Modo LiteLLM + OpenRouter

### 6. PENDIENTE VERIFICACION - CLAUDE_CONFIG_DIR
- Solucion para sesiones simultaneas sin conflicto de auth
- Anthropic usa `~/.claude/` (default)
- Alternativo usa `~/.claude-alt/` (aislado)
- **NO se probo todavia** - el usuario cerro sesion antes

---

## Problemas Encontrados y Resueltos

| Problema | Solucion |
|----------|----------|
| LiteLLM faltaba dependencia `backoff` | Instalar con `pip install "litellm[proxy]"` |
| Auth conflict (token claude.ai + API_KEY) | Usar CLAUDE_CONFIG_DIR separado |
| Flag `--api-key` no existe en Claude Code | Eliminado, usar solo env vars |
| `claude /logout` cerraba todas las sesiones | Reemplazado por CLAUDE_CONFIG_DIR |

---

## Archivos Creados/Modificados

### Nuevos
- `C:/Users/gdali/.litellm/config.yaml` - Config LiteLLM
- `C:/Users/gdali/.litellm/start-proxy.ps1` - Iniciar proxy
- `C:/Users/gdali/.litellm/claude-with-litellm.ps1` - (obsoleto, reemplazado)
- `C:/Users/gdali/claude-launcher.ps1` - Menu selector
- `C:/Users/gdali/claude-anthropic.ps1` - Modo Anthropic
- `C:/Users/gdali/claude-alternativo.ps1` - Modo alternativo

### Modificados
- `C:/claude_context/OPENROUTER_CONFIG.md` - Agregada seccion LiteLLM

---

## Proximos Pasos

1. **Probar `.\claude-alternativo.ps1`** - Verificar que CLAUDE_CONFIG_DIR resuelve el conflicto
2. **Si funciona:** Probar seleccion de modelo con `/model` dentro de Claude
3. **Si NO funciona:** Investigar alternativas (posible bug conocido de CLAUDE_CONFIG_DIR en Windows)
4. **Opcional:** Instalar LM Studio y configurar modelo local
5. **Opcional:** Verificar creditos disponibles en OpenRouter dashboard

---

## Notas para Retomar

- LiteLLM proxy puede no estar corriendo al retomar. El script lo detecta y ofrece iniciarlo.
- La API key de OpenRouter esta en `C:/claude_context/OPENROUTER_CONFIG.md`
- La guia completa de modelos esta en `C:/claude_context/LOCAL_AND_CLOUD_MODELS_GUIDE.md`
- docx2pdf quedo instalado globalmente (util para futuras conversiones)
