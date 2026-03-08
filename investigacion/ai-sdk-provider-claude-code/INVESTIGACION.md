# AI SDK Provider for Claude Agent SDK - Investigacion

**Fecha:** 2026-03-05
**Repo:** ben-vargas/ai-sdk-provider-claude-code (302 stars, 44 forks)
**Version analizada:** 3.4.3
**Licencia:** MIT

---

## Que es

Un **provider** para el [Vercel AI SDK](https://sdk.vercel.ai/) que permite usar Claude Code (via Claude Agent SDK) como modelo de lenguaje. Es el puente entre dos ecosistemas:

- **Vercel AI SDK v6**: Framework de orquestacion de LLMs con funciones como `generateText`, `streamText`, `generateObject`, `streamObject`
- **Claude Agent SDK** (`@anthropic-ai/claude-agent-sdk`): SDK oficial de Anthropic que internamente invoca el proceso CLI `claude`

### Flujo de datos

```
streamText({ model: claudeCode('sonnet'), prompt })
  -> ClaudeCodeLanguageModel.doStream()
  -> convertToClaudeCodeMessages()  (traduce formato AI SDK -> Agent SDK)
  -> query({ prompt, options })      (Agent SDK)
  -> Proceso CLI `claude`            (llama API Anthropic)
  -> Stream SDKPartialAssistantMessage
  -> Traduccion a LanguageModelV3StreamPart
  -> ReadableStream al consumidor
```

---

## Arquitectura

### Componentes principales

| Archivo | Responsabilidad |
|---------|-----------------|
| `claude-code-provider.ts` | Factory del provider. Implementa `ProviderV3`. Export: `claudeCode()` |
| `claude-code-language-model.ts` | Corazon (~1900 lineas). `doGenerate()` y `doStream()` |
| `convert-to-claude-code-messages.ts` | Traduce mensajes AI SDK -> formato Agent SDK |
| `mcp-helpers.ts` | Helper para crear MCP servers in-process |
| `types.ts` | `ClaudeCodeSettings` (~45 campos de configuracion) |
| `validation.ts` | Schema Zod completo para validacion de settings |
| `errors.ts` | Mapeo de errores SDK -> errores AI SDK |
| `map-claude-code-finish-reason.ts` | Traduccion de finish reasons entre ecosistemas |

### Especificacion

```typescript
readonly specificationVersion = 'v3'
readonly defaultObjectGenerationMode = 'json'
readonly supportsImageUrls = false  // Solo base64
readonly supportsStructuredOutputs = true
```

---

## Capacidades

### 1. Streaming token-by-token

Habilita `includePartialMessages: true` por defecto. Procesa eventos `content_block_start/delta/stop` del SDK para streaming granular sin esperar mensajes completos.

### 2. Structured Outputs (generateObject / streamObject)

Soporte nativo via `outputFormat: { type: 'json_schema', schema }` del Agent SDK (constrained decoding). Para `streamObject`, los `input_json_delta` se emiten como `text-delta` y el AI SDK los parsea progresivamente.

### 3. Extended Thinking (reasoning traces)

Bloques `thinking` del SDK procesados completamente:
- **doGenerate**: Extrae thinking blocks como `{ type: 'reasoning', text }`
- **doStream**: Emite `reasoning-start/delta/end`
- Configurable: `thinking: { type: 'adaptive'|'enabled'|'disabled', budgetTokens? }` o `effort: 'low'|'medium'|'high'|'max'`

### 4. MCP Servers

Cuatro tipos soportados:
- `stdio`: proceso externo (ej: `npx @modelcontextprotocol/server-filesystem`)
- `sse`: servidor SSE remoto
- `http`: servidor HTTP remoto
- `sdk`: in-process via `createCustomMcpServer()` con herramientas Zod

Las herramientas MCP se referencian en `allowedTools` con prefijo `mcp__<server>__<tool>`.

### 5. Mid-Session Message Injection

Patron supervisor para interrumpir/redirigir agentes en ejecucion. Usa sistema de cola + promise para sincronizar producer/consumer. La inyeccion ocurre **entre tool calls**, no durante generacion de texto continuo. Requiere `streamingInput: 'always'`.

### 6. Subagent Hierarchy Tracking

Cuando Claude spawna subagentes via `Task` tool, expone relaciones padre-hijo en `providerMetadata['claude-code'].parentToolCallId`. Usa un Map (no stack) para manejar Tasks paralelas.

### 7. Tool streaming lifecycle

Secuencia de eventos por cada tool:
```
tool-input-start -> tool-input-delta* -> tool-input-end -> tool-call -> tool-result | tool-error
```

### 8. Skills de Claude Code

Con `settingSources: ['user', 'project']` y `allowedTools: ['Skill', ...]`, el modelo puede invocar skills definidas en `~/.claude/skills/` o `.claude/skills/`.

### 9. Subagentes programaticos

```typescript
agents: Record<string, {
  description: string,
  prompt: string,
  tools?: string[],
  model?: string,
  mcpServers?: McpServerConfig[]
}>
```
El SDK los expone como herramientas Task al modelo principal.

---

## Ejemplos de uso

### Basico
```typescript
import { claudeCode } from 'ai-sdk-provider-claude-code';
import { streamText } from 'ai';

const result = streamText({
  model: claudeCode('sonnet'),
  prompt: 'Explain quantum computing'
});
```

### Con thinking traces
```typescript
const result = streamText({
  model: claudeCode('sonnet', {
    thinking: { type: 'enabled', budgetTokens: 10000 }
  }),
  prompt: 'Solve this complex problem...'
});
```

### Con MCP server
```typescript
const result = streamText({
  model: claudeCode('sonnet', {
    mcpServers: {
      filesystem: {
        type: 'stdio',
        command: 'npx',
        args: ['@modelcontextprotocol/server-filesystem', '/tmp']
      }
    },
    allowedTools: ['mcp__filesystem__read_file']
  }),
  prompt: 'Read the file at /tmp/data.json'
});
```

### Structured output
```typescript
import { generateObject } from 'ai';
import { z } from 'zod';

const result = await generateObject({
  model: claudeCode('sonnet'),
  schema: z.object({
    name: z.string(),
    age: z.number()
  }),
  prompt: 'Generate a fictional character'
});
```

---

## Metadata expuesta

En cada respuesta, `providerMetadata['claude-code']` incluye:

```typescript
{
  sessionId?: string,       // ID de sesion del SDK
  costUsd?: number,         // Costo estimado en USD
  durationMs?: number,      // Duracion total del request
  modelUsage?: object,      // Desglose de uso por modelo
  truncated?: true,         // Si hubo truncacion del stream
  thinkingTraces?: string[] // Traces de razonamiento (non-streaming)
}
```

Token usage (AI SDK v6):
```typescript
usage.inputTokens: { total, noCache, cacheRead, cacheWrite }
usage.outputTokens: { total }
```

---

## Limitaciones

### Parametros no soportados
- `temperature`, `topP`, `topK`, `presencePenalty`, `frequencyPenalty`, `seed`, `stopSequences`, `maxTokens`
- Emite warnings `unsupported` pero los ignora silenciosamente

### Imagenes
- Solo base64/data URLs (no URLs HTTP remotas)
- Requieren `streamingInput: 'always'` o `canUseTool`

### JSON/Structured Output
- JSON sin schema no soportado (fallback a texto plano)
- Algunos JSON Schema features (`format: email/uri`, regex complejos) pueden fallar silenciosamente

### Otros
- Requiere Node.js >= 18 y CLI `claude` instalado y autenticado
- Message injection solo entre tool calls (no durante generacion continua)
- Tool results truncados a 10,000 chars por defecto (configurable con `maxToolResultSize`)
- Tool input hard limit: 1MB
- No soporta embedding models ni image models

---

## Dependencias

| Paquete | Version | Tipo |
|---------|---------|------|
| `@ai-sdk/provider` | ^3.0.0 | prod |
| `@ai-sdk/provider-utils` | ^4.0.1 | prod |
| `@anthropic-ai/claude-agent-sdk` | ^0.2.63 | prod |
| `zod` | ^4.0.0 | peer |
| `tsup` | - | build |
| `vitest` | - | test |

Dual package: CJS (`dist/index.cjs`) + ESM (`dist/index.js`).

---

## Decisiones de diseno notables

1. **Streaming input mantenido abierto**: El async iterable de input se mantiene vivo hasta que el output stream termina para evitar truncacion (ref: issue #4775 de anthropic/claude-code)

2. **Delta optimization**: Para tool inputs grandes (>10KB), evita calcular deltas de texto y emite el string completo directamente

3. **Extension sin eliminacion**: Campos deprecados (`customSystemPrompt`, `appendSystemPrompt`, `maxThinkingTokens`) siguen funcionando con warnings, mapeados a equivalentes nuevos

4. **`sdkOptions` como escape hatch**: Cualquier opcion del Agent SDK no expuesta explicitamente se puede pasar via `sdkOptions`, con blocklist para campos gestionados internamente

---

## Compatibilidad de versiones

| Provider | AI SDK | SDK subyacente | Estado |
|----------|--------|----------------|--------|
| 3.x.x | v6 | `@anthropic-ai/claude-agent-sdk` | Stable (actual) |
| 2.x.x | v5 | `@anthropic-ai/claude-agent-sdk` | Stable (branch ai-sdk-v5) |
| 1.x.x | v5 | `@anthropic-ai/claude-code` (legacy) | Legacy |
| 0.x.x | v4 | `@anthropic-ai/claude-code` (legacy) | Legacy |

---

## Relevancia para nuestro ecosistema

### Potencial de uso
- Permite construir aplicaciones que usen Claude Code como backend via Vercel AI SDK
- Util para crear UIs custom sobre Claude (dashboards, chatbots especializados)
- El soporte de MCP servers permite exponer nuestros MCP servers (project-admin, sprint-backlog-manager) a aplicaciones AI SDK

### Patrones interesantes
- **Mid-session injection**: Patron supervisor aplicable a nuestro orchestrator
- **Subagent tracking**: Similar a lo que hacemos con claude-orchestrator sessions
- **Extension sin eliminacion**: Alineado con nuestra directiva obligatoria #5
- **MCP in-process**: `createCustomMcpServer()` podria simplificar testing de nuestros MCP servers

### Ideas derivadas
- Explorar si podemos usar este provider para crear una UI web para nuestro orchestrator
- El patron de tool streaming lifecycle podria mejorar el feedback visual en claude-monitor
- Investigar si `sdkOptions` permite pasar configuraciones custom a nuestros workflows
