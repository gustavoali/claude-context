# File Reader - Equipo de Desarrollo

**Fecha:** 2026-02-16

---

## Composicion

| Rol | Agente | Perfil | Responsabilidad |
|-----|--------|--------|-----------------|
| Python Developer | `python-backend-developer` | DEVELOPER_BASE | Implementacion del servidor FastAPI, endpoints, validaciones |
| Test Engineer | `test-engineer` | TESTER_BASE | Tests unitarios, integracion, penetracion basica |
| Code Reviewer | `code-reviewer` | REVIEWER_BASE | Review riguroso pre-merge, foco en seguridad |
| MCP Developer | `mcp-server-developer` | AGENT_MCP_SERVER | Integracion MCP (fase evolutiva) |

## Stack

- **Python 3.11+** con FastAPI
- **pytest** para testing
- **uvicorn** como server ASGI
- **Docker** para DB si se necesita en futuro

## Metodologia

**Escala:** Micro (1 dev)
**Proceso:** Simplificado por historia

```
Por cada historia:
  1. Claude coordina, delega a python-backend-developer
  2. Developer implementa en branch feature/
  3. test-engineer escribe y ejecuta tests
  4. code-reviewer hace review riguroso
  5. Usuario hace merge manual
```

## Fases de Implementacion

| Fase | Historias | Agente Principal |
|------|-----------|-----------------|
| 1 - Server base | Setup FastAPI, endpoint read, config | python-backend-developer |
| 2 - Seguridad | Auth middleware, path validation, allowlist | python-backend-developer |
| 3 - Testing | Unit tests, penetration tests | test-engineer |
| 4 - Docs | README, manual interno | python-backend-developer |
| 5 - Deploy | Deploy local controlado | devops-engineer (si necesario) |
| Evolutivo - MCP | Integracion MCP server | mcp-server-developer |

## Reglas del Equipo

- Build 0 errores, 0 warnings
- Tests obligatorios para cada historia
- Code review riguroso antes de merge (foco seguridad)
- Commits los hace el coordinador o el usuario
- Permisos amplios en .claude/settings.local.json
