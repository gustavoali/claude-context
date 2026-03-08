# AI SDK Provider Claude Code - Project Context
**Tipo:** Investigacion / Referencia
**Ubicacion:** C:/investigacion/ai-sdk-provider-claude-code/
**Repo original:** ben-vargas/ai-sdk-provider-claude-code (302 stars)
**Categoria:** tool

## Que es
Vercel AI SDK provider para Claude Agent SDK. Puente entre AI SDK v6 y el CLI de Claude Code.

## Estructura clave
```
src/
  claude-code-provider.ts       - Factory del provider (ProviderV3)
  claude-code-language-model.ts - Core: doGenerate() y doStream() (~1900 lineas)
  convert-to-claude-code-messages.ts - Traduccion de mensajes
  mcp-helpers.ts                - Helpers MCP in-process
  types.ts                      - ClaudeCodeSettings (~45 campos)
examples/                       - 29 ejemplos de uso
```

## Docs
@C:/claude_context/investigacion/ai-sdk-provider-claude-code/INVESTIGACION.md
