# Mew Michis - Configuracion de Claude Code

## Proyecto
- **Nombre:** Mew Michis
- **Tipo:** App Movil Flutter
- **Path:** C:/apps/mew-michis
- **Escala:** Micro (1 developer)

## Stack Tecnologico
- **Framework:** Flutter (Dart)
- **Base de Datos:** SQLite (local, offline-first)
- **State Management:** Por definir (Riverpod recomendado)
- **Arquitectura:** Clean Architecture simplificada

## Proceso Aplicable

Segun `15-scale-adaptation-guide.md`, este es un proyecto **Micro**:
- Proceso simplificado (3 fases)
- DoR Level 1 para US <= 3pts
- Two-Track opcional
- TD Register basico

## Convenciones

### Codigo
- Dart style guide oficial
- Nombres en ingles
- Comentarios en espanol cuando sea necesario

### Git
- Branch principal: main
- Feature branches: feature/[descripcion]
- Commits en espanol o ingles, consistentes

### Testing
- Unit tests para logica nutricional (critico)
- Widget tests para UI principal
- Integration tests para flujos completos

## Agentes Recomendados

| Tarea | Agente |
|-------|--------|
| Backlog y US | product-owner |
| Schema SQLite | database-expert |
| Arquitectura | software-architect |
| Testing | test-engineer |
| Code Review | code-reviewer |
| Flutter/Dart | (gap - ejecutar directamente o crear agente) |

## Documentacion del Proyecto
@C:/claude_context/apps/mew-michis/README.md
@C:/claude_context/apps/mew-michis/PRODUCT_BACKLOG.md
@C:/claude_context/apps/mew-michis/TASK_STATE.md

## Links Utiles
- Especificacion: C:/apps/mew-michis/Especificacion_App_Alimentacion_Felina.pdf
- Backlog: C:/claude_context/apps/mew-michis/PRODUCT_BACKLOG.md
- Estado: C:/claude_context/apps/mew-michis/TASK_STATE.md

## Al Retomar Sesion
1. Leer TASK_STATE.md para contexto
2. Verificar proximos pasos
3. Continuar desde donde se dejo

---

**Ultima actualizacion:** 2026-01-26
