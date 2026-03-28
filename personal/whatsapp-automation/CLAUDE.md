# WhatsApp Automation - Project Context
**Version:** 0.1.0 | **Estado:** Fase 1 parcialmente completada
**Ubicacion:** `C:/personal/whatsapp-automation`
**Repo:** github.com/gustavoali/whatsapp-automation

## Stack
- **Runtime:** Python 3.11
- **Browser automation:** Playwright (disponible via MCP `mcp__playwright__*`)
- **Storage:** JSON (inicial) → SQLite (Fase 2)
- **MCP:** Futuro: exponer como tools cuando se estabilice Fase 1

## Componentes
| Componente | Ubicacion | Estado |
|------------|-----------|--------|
| wa_browser.py | src/ | pendiente |
| wa_extractor.py | src/ | pendiente |
| wa_messenger.py | src/ | pendiente |
| extract_links.py | scripts/ | pendiente |
| links.json | data/ | existe (workspace) |

## Comandos
```bash
# Ejecutar extraccion de links
python scripts/extract_links.py

# Python del sistema
C:\Users\gdali\AppData\Local\Programs\Python\Python311\python.exe
```

## Datos Existentes
- `C:/claude_context/personal/workspace/whatsapp_linkedin_links.json`
  - 7 posts LinkedIn evaluados
  - `deleted_from_whatsapp: false` en todos (eliminacion no completada)

## Agentes Recomendados
| Tarea | Agente |
|-------|--------|
| Implementar modulos Python | `python-backend-developer` |
| Implementar MCP server | `mcp-server-developer` |
| Tests | `test-engineer` |

## Reglas del Proyecto
- NO envios masivos. Solo mensajes individuales.
- Self-chat como canal de entrada/prueba principal
- Playwright es la opcion preferida (menor riesgo de ban)
- NO usar Baileys/whatsapp-web.js como primera opcion
- NO reanudar eliminacion de mensajes sin instruccion explicita del usuario

## Docs
@C:/claude_context/personal/whatsapp-automation/TASK_STATE.md
@C:/claude_context/personal/whatsapp-automation/PRODUCT_BACKLOG.md
