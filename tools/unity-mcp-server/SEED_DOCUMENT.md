# Unity MCP Server - Seed Document

**Fecha de creacion:** 2026-02-22
**Origen:** Necesidad identificada durante desarrollo de Gaia Protocol (GP-008, GP-027)

---

## 1. Vision General

Unity MCP Server es un paquete UPM (Unity Package Manager) que implementa un servidor MCP (Model Context Protocol) dentro del proceso de Unity Editor. Permite que asistentes de IA como Claude Code manipulen escenas, creen GameObjects, construyan UI, generen prefabs y asignen referencias serializadas de forma programatica, eliminando la necesidad de instrucciones manuales paso a paso en el Editor.

### Problema que Resuelve
Cuando un asistente de IA genera scripts de Unity (MonoBehaviours), el usuario debe realizar manualmente en el Editor:
- Crear GameObjects y asignar componentes
- Construir jerarquias de UI (Canvas, Panels, Buttons, ScrollViews)
- Crear prefabs y arrastrarlos a campos SerializeField
- Configurar RectTransform (anchors, pivots, tamaños)
- Asignar referencias entre componentes

Estas acciones son repetitivas, propensas a errores, y consumen 30-60 minutos por historia de UI. Con el MCP server, Claude las ejecuta directamente.

### Fantasia del Usuario
- "Claude, implementa el panel de inventario" -> Claude escribe los scripts Y configura la escena completa
- Zero manual Editor work para setup de UI estandar
- Ctrl+Z deshace cualquier operacion del asistente

---

## 2. Decisiones de Diseno

| Aspecto | Decision | Razon |
|---------|----------|-------|
| Transport | stdio (stdin/stdout) | Nativo MCP, sin puertos, sin firewall |
| Distribucion | UPM local package | Reutilizable, versionado, limpio |
| Threading | Main thread via EditorApplication.update | Requerido por UnityEditor API |
| Undo | Todas las ops registran Undo | Seguridad: el usuario siempre puede revertir |
| Scope | Editor-only | No afecta builds de runtime |
| Target | Unity 2022.3+ y Unity 6 LTS | Cobertura maxima de versiones activas |

---

## 3. Arquitectura

### Flujo de una tool call
```
Claude Code (MCP Client)
  -> stdin: JSON-RPC request {"method":"tools/call","params":{"name":"create_gameobject",...}}
  -> StdioTransport.ReadMessage()
  -> MessageRouter.Route()
  -> ToolRegistry.GetTool("create_gameobject")
  -> MainThreadDispatcher.EnqueueAsync(tool.Execute)
  -> EditorApplication.update: drain queue, execute on main thread
  -> CreateGameObjectTool: new GameObject("name"), set transform, Undo.Register
  -> McpToolResult {content: "Created 'name' (id: 12345)"}
  -> stdout: JSON-RPC response
  -> Claude Code receives result
```

### Componentes
| Componente | Responsabilidad |
|------------|-----------------|
| StdioTransport | IO stdin/stdout, framing, UTF-8 |
| MessageRouter | Despacho JSON-RPC: initialize, tools/list, tools/call |
| ToolRegistry | Registro, busqueda, listado de tools |
| McpServer | Lifecycle: init, run loop, shutdown |
| MainThreadDispatcher | Queue thread-safe -> main thread |
| Tool Handlers (x17) | Implementacion individual por operacion |

### Interface IMcpTool
```csharp
public interface IMcpTool
{
    string Name { get; }
    string Description { get; }
    JsonElement InputSchema { get; }
    Task<McpToolResult> ExecuteAsync(JsonElement parameters);
}
```

---

## 4. Tools Planificados (22 tools)

### Core Scene (EPIC-002)
| Tool | Descripcion |
|------|-------------|
| create_gameobject | Crear GO con nombre, parent, transform |
| add_component | Agregar componente + setear campos serializados |
| set_transform | Posicion, rotacion, escala |
| find_gameobject | Buscar por nombre, path, o componente |
| delete_gameobject | Destruir GO y children |

### UI Building (EPIC-003)
| Tool | Descripcion |
|------|-------------|
| create_canvas | Canvas + CanvasScaler + EventSystem |
| create_ui_element | Button, Text, Panel, ScrollView, InputField, Dropdown |
| set_rect_transform | Anchors, pivot, tamaño, presets |
| set_serialized_field | Asignar refs entre componentes (el "drag & drop" programatico) |

### Prefab & Asset (EPIC-004)
| Tool | Descripcion |
|------|-------------|
| create_prefab | Guardar hierarchy como prefab |
| instantiate_prefab | Instanciar prefab en escena |
| save_scene | Guardar escena |

### Advanced (EPIC-005)
| Tool | Descripcion |
|------|-------------|
| get_hierarchy | JSON tree de la escena |
| get_component_info | Inspeccionar componentes y campos |
| create_material | Material con shader y propiedades |
| set_layer_tag | Layer y tag |
| batch_operations | Multiples ops en un Undo group |

---

## 5. MVP (EPIC-001 + EPIC-002 + EPIC-003)

El MVP incluye transport + los tools necesarios para automatizar setup de escenas Unity con UI. Esto desbloquea la integracion con Gaia Protocol (GP-033) y cualquier otro proyecto Unity.

### Criterios de Aceptacion MVP
- Claude Code puede comunicarse con el server via stdio
- Puede crear GameObjects, agregar componentes, construir UI completa
- Puede asignar SerializeField references programaticamente
- Todas las operaciones son Undo-able
- El package se instala en cualquier proyecto Unity via local path
- 0 crashes del Editor por tool calls malformados

### Contenido MVP
- 12 tools (UMS-004 a UMS-012 + UMS-001 a UMS-003)
- Transport stdio funcional
- Tool registry con auto-discovery
- EditMode tests para cada tool
- README con instrucciones de instalacion

---

## 6. Integracion con Claude Code

### Configuracion en claude_desktop_config.json o settings
```json
{
  "mcpServers": {
    "unity-editor": {
      "command": "unity-mcp-bridge",
      "args": ["--project", "C:/path/to/unity/project"]
    }
  }
}
```

### Alternativa: Named Pipe / TCP bridge
Si stdio directo desde Unity Editor es complejo (el Editor no es un proceso CLI), se puede usar un bridge:
```
Claude Code <-> stdio <-> Bridge process <-> Named Pipe <-> Unity Editor MCP Server
```
El bridge es un proceso .NET liviano que traduce stdio a named pipe. El MCP server dentro de Unity escucha en el named pipe.

---

## 7. Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigacion |
|--------|-------------|---------|------------|
| Unity Editor no es proceso CLI (no tiene stdin natural) | Alta | Critico | Bridge process o HTTP localhost fallback |
| Threading issues (main thread requirement) | Media | Alto | MainThreadDispatcher pattern bien testeado |
| SerializedObject API compleja | Media | Medio | Wrapper utility, tests exhaustivos |
| Compatibilidad Unity versions | Baja | Medio | Target 2022.3+ con #if defines si es necesario |
| Scope creep (demasiados tools) | Media | Medio | MVP cerrado en 12 tools, resto es post-MVP |

---

## 8. Proyectos Consumidores

| Proyecto | Dependencia | Beneficio |
|----------|-------------|-----------|
| Gaia Protocol | GP-033 | Automatizar setup de escena, UI, prefabs para historias Unity pendientes |
| (Futuros proyectos Unity) | Agregar a Packages/manifest.json | Cualquier proyecto Unity se beneficia |

---

## 9. Metricas de Exito

| Metrica | Target |
|---------|--------|
| Tiempo setup escena (manual vs MCP) | Reduccion >80% |
| Tool calls exitosos vs fallidos | >95% success rate |
| Tiempo de respuesta por tool call | <500ms promedio |
| Compatibilidad Unity versions | 2022.3 LTS + Unity 6 LTS |
| Crashes del Editor por MCP | 0 |
