# Screen Capture MCP Server - Project Context
**Version:** 0.0.0 | **Tests:** 0 | **Coverage:** 0%
**Ubicacion:** C:/tools/screen-capture

## Stack
- Python 3.11+
- MCP SDK (mcp[cli])
- mss (screen capture, cross-platform, fast)
- Pillow (image processing/resize)

## Componentes
| Componente | Ubicacion | Estado |
|------------|-----------|--------|
| MCP Server | src/server.py | Pendiente |
| Screen capture core | src/capture.py | Pendiente |
| Config | src/config.py | Pendiente |

## Objetivo
MCP server que captura screenshots de la pantalla real del usuario (monitor, ventanas, regiones).
Resuelve la limitacion de Playwright MCP que solo ve su propio browser headless.

## Tools MCP Planificados
| Tool | Descripcion |
|------|-------------|
| `capture_screen` | Captura pantalla completa o monitor especifico |
| `capture_region` | Captura region especifica (x, y, width, height) |
| `capture_window` | Captura ventana por titulo (Windows: win32gui) |
| `list_monitors` | Lista monitores disponibles con resolucion |
| `list_windows` | Lista ventanas abiertas con titulos |

## Comandos
```bash
# Activar venv
.venv/Scripts/activate
# Instalar
pip install -r requirements.txt
# Test
pytest tests/ -v
# Registrar en Claude Code
claude mcp add --transport stdio --scope user screen-capture -- python -m src.server
```

## Reglas del Proyecto
- Output como imagen PNG (Claude Code puede leer imagenes via Read tool)
- Guardar screenshots en directorio temporal configurable
- Opcion de resize para no exceder limites de token de imagen
- No capturar passwords ni datos sensibles visibles (warning al usuario)

## Docs
@C:/claude_context/tools/screen-capture/TASK_STATE.md
