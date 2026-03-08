# Sudoku Multi-Size - Project Context
**Version:** 0.1.0 (seed) | **Tests:** N/A | **Coverage:** N/A
**Ubicacion:** C:/apps/sudoku
**Contexto:** C:/claude_context/apps/sudoku

## Descripcion
Juego de Sudoku con soporte para tableros de multiples tamanos (4x4, 6x6, 9x9, 12x12, 16x16) y bloques rectangulares. Incluye generador de puzzles con solucion unica, validacion en tiempo real, solucionador, sistema de pistas, importacion desde JSON/texto/imagenes (OCR) y niveles de dificultad.

## Stack
- **Backend:** Python, FastAPI, Pydantic, Uvicorn
- **Frontend:** HTML5, CSS3, JavaScript (Vanilla)
- **OCR (opcional):** OpenCV, Tesseract

## Componentes
| Componente | Ubicacion | Descripcion |
|------------|-----------|-------------|
| FastAPI App | `backend/app/main.py` | Punto de entrada del servidor |
| Modelos | `backend/app/models/sudoku.py` | Modelos Pydantic |
| Generador | `backend/app/services/generator.py` | Generador de puzzles |
| Validador | `backend/app/services/validator.py` | Validacion de tableros |
| Solucionador | `backend/app/services/solver.py` | Resolucion de puzzles |
| OCR | `backend/app/services/ocr.py` | Importacion desde imagenes |
| Rutas API | `backend/app/api/routes.py` | Endpoints REST |
| Frontend App | `frontend/js/app.js` | Aplicacion principal JS |
| Logica Tablero | `frontend/js/sudoku.js` | Logica del tablero en cliente |
| Cliente API | `frontend/js/api.js` | Comunicacion con backend |
| Estilos | `frontend/css/styles.css` | Estilos CSS |

## Comandos
```bash
# Crear entorno virtual
cd backend && python -m venv venv
venv\Scripts\activate          # Windows

# Instalar dependencias
pip install -r requirements.txt

# Iniciar servidor (dev)
cd backend && uvicorn app.main:app --reload
# Servidor en http://localhost:8000

# Frontend: abrir frontend/index.html o http://localhost:8000/
```

## Endpoints
| Metodo | Endpoint | Descripcion |
|--------|----------|-------------|
| GET | `/api/board/presets` | Presets de tableros |
| POST | `/api/board/create` | Crear nuevo puzzle |
| POST | `/api/board/validate` | Validar tablero |
| POST | `/api/board/solve` | Resolver puzzle |
| POST | `/api/board/hint` | Obtener pista |
| POST | `/api/board/import` | Importar desde JSON |
| POST | `/api/board/import/text` | Importar desde texto |
| POST | `/api/board/ocr` | Importar desde imagen |

## API Docs
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## Agentes Recomendados
| Tarea | Agente |
|-------|--------|
| Backend Python/FastAPI | `python-backend-developer` |
| Frontend JS vanilla | `frontend-react-developer` (adaptar a vanilla) |
| Tests | `test-engineer` |
| Code review | `code-reviewer` |
| Arquitectura | `software-architect` |

## Reglas del Proyecto
- Un solo `main.py` como punto de entrada (no duplicar)
- Comportamiento configurable via variables de entorno, no archivos duplicados
- OCR es opcional (Tesseract debe estar instalado por separado)
- Frontend es vanilla JS, no frameworks
- Celdas vacias se representan con `0` o `.`
