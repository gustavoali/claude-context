# File Reader - Project Context

**Version:** 0.1.0 (brotado - listo para desarrollo)
**Ubicacion:** C:/mcp/file-reader
**Categoria:** mcp

## Descripcion

Servidor local de lectura segura de archivos. Expone contenido del filesystem a procesos de analisis automatizados con control de acceso, auditoria y aislamiento.

## Stack

- **Runtime:** Python 3.11+
- **Framework:** FastAPI
- **Auth:** API Key (header X-API-Key)
- **Logging:** Archivo local
- **Futuro:** Integracion MCP, extraccion PDF/DOCX, chunking LLM

## Componentes

| Componente | Ubicacion | Estado |
|------------|-----------|--------|
| API REST | file_tool_server.py | Pendiente |
| Config | config.py | Pendiente |
| Auth Middleware | file_tool_server.py | Pendiente |
| Path Validator | path_validator.py | Pendiente |
| Access Logger | access_logger.py | Pendiente |
| Sandbox | sandbox/ | Pendiente |

## Comandos

```bash
# Install
pip install -r requirements.txt

# Run
uvicorn file_tool_server:app --host 127.0.0.1 --port 8000

# Test
pytest
```

## Seguridad

- Solo localhost (127.0.0.1)
- API Key obligatoria
- Allowlist de directorios
- Extensiones restringidas
- Limite 2MB por archivo
- Log de accesos

## Agentes Recomendados

| Tarea | Agente |
|-------|--------|
| Implementacion | `python-backend-developer` |
| Tests | `test-engineer` |
| Code review | `code-reviewer` |
| Seguridad | `code-reviewer` (modo seguridad) |
| Integracion MCP | `mcp-server-developer` |

## Docs

@C:/claude_context/mcp/file-reader/SEED_DOCUMENT.md
@C:/claude_context/mcp/file-reader/ARCHITECTURE_ANALYSIS.md
@C:/claude_context/mcp/file-reader/SECURITY_ANALYSIS.md
@C:/claude_context/mcp/file-reader/PRODUCT_BACKLOG.md
@C:/claude_context/mcp/file-reader/BUSINESS_STAKEHOLDER_DECISION.md
