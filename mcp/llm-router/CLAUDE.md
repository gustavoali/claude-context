# LLM Router - Project Context
**Version:** 0.1.0 | **Tests:** 1 (test_mcp.py) | **Coverage:** N/A
**Ubicacion:** C:/investigacion/llm-router
**Repo:** https://github.com/gustavoali/llm-router

## Descripcion
MCP server (stdio) que rutea prompts al modelo LLM optimo segun tipo de tarea, costo y disponibilidad. Derivado de investigacion de llm-landscape.

## Stack
- Python 3.12+
- MCP SDK (mcp package)
- SQLite (metricas)
- Providers: Groq (free), Ollama (local), Anthropic, Gemini

## Componentes
| Componente | Ubicacion | Responsabilidad |
|------------|-----------|-----------------|
| server.py | raiz | Entry point MCP, tool handlers |
| router/config.py | router/ | Carga config.yaml + .env |
| router/router.py | router/ | Logica de ruteo por task_type |
| router/dispatcher.py | router/ | Llamadas HTTP a cada provider |
| router/metrics.py | router/ | SQLite para metricas de uso |
| config.yaml | raiz | Reglas de ruteo + pricing |

## Comandos
```bash
# Activar venv
.venv/Scripts/activate

# Arrancar server
python -u server.py

# Tests
python test_mcp.py
```

## MCP Tools
| Tool | Descripcion |
|------|-------------|
| lr_query | Ruteo automatico por task_type (coding, analysis, summary, etc.) |
| lr_query_model | Query directo a modelo especifico (bypass router) |
| lr_metrics | Metricas de uso: tokens, costos, latencia |
| lr_list_models | Lista modelos con estado de disponibilidad |
| lr_reset_metrics | Reset de contadores |

## Reglas del Proyecto
- .env con API keys, NUNCA commitear
- config.yaml define routing rules y fallbacks
- Metricas en data/metrics.db (auto-creado)
- Registrado en ~/.claude.json como MCP server "llm-router"

## Relaciones
- **Derivado de:** llm-landscape (investigacion de modelos)
- **Relacionado con:** agent-token-economics (monitoreo de costos)

## Agentes Recomendados
| Tarea | Agente |
|-------|--------|
| Implementar features | `python-backend-developer` |
| Agregar providers | `mcp-server-developer` |
| Tests | `test-engineer` |

## Docs
@C:/claude_context/mcp/llm-router/TASK_STATE.md
