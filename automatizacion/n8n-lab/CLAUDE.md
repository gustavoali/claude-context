# n8n-lab - Project Context
**Version:** 0.1.0 | **Estado:** Seed
**Ubicacion:** C:/dev/automatizacion/n8n-lab

## Descripcion
Proyecto de investigacion y aprendizaje sobre n8n (workflow automation).
Objetivo: explorar capacidades de n8n, construir workflows de prueba, documentar patrones.

## Stack
- **n8n:** Self-hosted en Docker (via WSL)
- **Docker:** Container para n8n + servicios auxiliares
- **Documentacion:** Markdown en el repo

## Componentes
| Componente | Ubicacion | Estado |
|------------|-----------|--------|
| n8n server | Docker container | Pendiente setup |
| Workflows | workflows/ | Vacio |
| Documentacion | docs/ | Vacio |

## Comandos
```bash
# Levantar n8n
docker compose up -d

# Ver logs
docker compose logs -f n8n

# Parar
docker compose down

# Acceder a n8n UI
# http://localhost:5678
```

## Agentes Recomendados
| Tarea | Agente |
|-------|--------|
| Setup Docker/infra | `devops-engineer` |
| Investigacion/docs | `general-purpose` |

## Reglas del Proyecto
- Workflows exportados como JSON en `workflows/`
- Cada workflow documentado en `docs/workflows/`
- Docker compose como unica forma de levantar servicios

## Docs
@C:/claude_context/automatizacion/n8n-lab/TASK_STATE.md
@C:/claude_context/automatizacion/n8n-lab/PRODUCT_BACKLOG.md
@C:/claude_context/automatizacion/n8n-lab/LEARNINGS.md
