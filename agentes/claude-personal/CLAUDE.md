# Claude Personal - Project Context
**Version:** 0.0.0 (seed) | **Tests:** N/A | **Coverage:** N/A
**Ubicacion:** C:/agentes/claude-personal
**Contexto:** C:/claude_context/agentes/claude-personal

## Descripcion
Asistente personal de proposito general via CLI. Harness .NET sobre Anthropic API con tools modulares para gestion de archivos, productividad y vida cotidiana. Sin restricciones de dominio.

## Stack
- **Lenguaje:** C# / .NET 8+
- **CLI:** System.CommandLine + Spectre.Console
- **Core:** Anthropic Messages API + Tool Use Protocol
- **Persistencia:** SQLite (historial, memoria, preferencias)
- **Config:** JSON en ~/.claude-personal/

## Componentes
| Componente | Ubicacion | Estado |
|------------|-----------|--------|
| CLI Shell | src/ClaudePersonal.CLI/ | Pendiente |
| Core Engine | src/ClaudePersonal.Core/ | Pendiente |
| Tools | src/ClaudePersonal.Tools/ | Pendiente |
| Core Tests | tests/ClaudePersonal.Core.Tests/ | Pendiente |
| Tools Tests | tests/ClaudePersonal.Tools.Tests/ | Pendiente |

## Comandos
```bash
dotnet build --no-incremental
dotnet test --configuration Release
dotnet run --project src/ClaudePersonal.CLI
```

## Agentes Recomendados
| Tarea | Agente |
|-------|--------|
| Backend .NET (core, tools) | `dotnet-backend-developer` |
| Arquitectura | `software-architect` |
| Tests | `test-engineer` |
| User stories / backlog | `product-owner` |
| Code review | `code-reviewer` |
| Business decisions | `business-stakeholder` |

## Referencias de Estudio
- **ZeroClaw** (`C:/investigacion/zeroclaw/`): Runtime agentico en Rust, <5MB RAM, trait-driven architecture. Estudiar como inspiracion para: arquitectura de plugins/tools, sistema de memoria, streaming, sandboxing. Comparar rendimiento .NET vs Rust post-MVP.

## Reglas del Proyecto
1. Cada tool es un modulo independiente con interfaz comun (ITool)
2. Tools no dependen entre si, solo del core
3. Streaming por defecto en todas las respuestas
4. Acciones destructivas o de envio requieren confirmacion del usuario

## Docs
@C:/claude_context/agentes/claude-personal/SEED_DOCUMENT.md
@C:/claude_context/agentes/claude-personal/TEAM_ANALYSIS.md
@C:/claude_context/agentes/claude-personal/TEAM_DEVELOPMENT.md
