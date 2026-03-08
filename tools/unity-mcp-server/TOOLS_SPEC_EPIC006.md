# Unity MCP Server - EPIC-006: Component Wiring & Scene Automation
**Version:** 1.0 | **Fecha:** 2026-02-25
**Solicitado por:** Gaia Protocol (GP-032 scene assembly)
**Estado:** Especificacion lista para desarrollo

---

## Contexto

El UMS tiene 17 tools funcionales (MVP completo, EPIC-001 a EPIC-005). Sin embargo, al intentar automatizar el ensamblaje de una escena compleja como Gaia Protocol (22 MonoBehaviours, UI Canvas con paneles, cross-references entre componentes), se identificaron gaps criticos que impiden la automatizacion completa.

### Problema principal: Component Reference Wiring

El tool `set_serialized_field` resuelve paths de escena a `GameObject`, pero muchos campos `[SerializeField]` son de tipo Component (ej: `Camera`, `Image`, `TextMeshProUGUI`, `HexGridRenderer`). Unity espera una referencia al componente especifico, no al GameObject contenedor.

**Ejemplo real de Gaia Protocol:**
```csharp
// GameHUD.cs
[SerializeField] private TextMeshProUGUI _turnText;      // Necesita ref a TMP component
[SerializeField] private TextMeshProUGUI _resourcesText;  // Necesita ref a TMP component
[SerializeField] private Button _endTurnButton;           // Necesita ref a Button component

// HexGridRenderer.cs
[SerializeField] private Material _hexMaterial;           // Asset ref (ya funciona)
[SerializeField] private Camera _mainCamera;              // Necesita ref a Camera component
```

Con el tool actual, `set_serialized_field` con path `"Canvas/HUD/TurnText"` asigna el GameObject, no el componente `TextMeshProUGUI`. Esto falla silenciosamente para campos tipados como Component.

---

## Historias Propuestas

### UMS-026: Component-typed field resolution in set_serialized_field
**Points:** 5 | **Priority:** Critical | **Epic:** EPIC-006
**As a** AI assistant **I want** set_serialized_field to resolve Component-typed references correctly **so that** I can wire MonoBehaviour cross-references without manual intervention.

#### Acceptance Criteria
**AC1:** Given a field `[SerializeField] private Camera _cam`, When I call `set_serialized_field` with value `"Main Camera"` (scene path), Then the tool resolves it to the `Camera` component on that GameObject (not the GameObject itself).

**AC2:** Given a field `[SerializeField] private TextMeshProUGUI _text`, When I call `set_serialized_field` with value `"Canvas/Panel/Label"`, Then the tool finds the `TextMeshProUGUI` component on that GameObject.

**AC3:** Given a field `[SerializeField] private Button _btn`, When I call `set_serialized_field` with value `"Canvas/Panel/MyButton"`, Then the tool assigns the `Button` component from that GameObject.

**AC4:** Given a field `[SerializeField] private GameObject _go`, When I call `set_serialized_field` with value `"SomeObject"`, Then the tool continues assigning the GameObject as before (backward compatible).

**AC5:** Given a field typed as `IEngine` (interface), When I call `set_serialized_field`, Then the tool returns an appropriate error message explaining that interface-typed fields cannot be assigned via scene path.

#### Technical Notes
- In `SerializedPropertyHelper.cs`, when the `SerializedProperty.propertyType == ObjectReference`:
  1. Read `property.type` (returns something like `PPtr<Camera>` or `PPtr<$TextMeshProUGUI>`)
  2. Extract the expected type name from the PPtr wrapper
  3. If the expected type inherits from `Component` (not `GameObject`), resolve the scene path to the GameObject, then call `GetComponent<ExpectedType>()` on it
  4. If the expected type is `GameObject`, use the existing behavior
  5. If the expected type is an asset type (Material, Sprite, etc.), use `AssetDatabase.LoadAssetAtPath` (existing behavior)
- Edge case: Multiple components of the same type on one GameObject. Use the first match (`GetComponent` default) unless an index is specified.
- Consider supporting optional syntax: `"Canvas/Panel/Label:TextMeshProUGUI"` for disambiguation, but default should auto-detect from field type.

---

### UMS-027: Scene management tools (create_scene, add_to_build_settings)
**Points:** 3 | **Priority:** High | **Epic:** EPIC-006
**As a** AI assistant **I want** to create new scenes and manage build settings **so that** I can set up a project from scratch without manual Editor work.

#### Acceptance Criteria
**AC1:** Given I call `create_scene` with path `"Assets/Scenes/MainGame.unity"`, When executed, Then a new empty scene is created and saved at that path.

**AC2:** Given an existing scene, When I call `add_to_build_settings` with its path, Then the scene appears in Build Settings at the next available index.

**AC3:** Given I call `create_scene` with `set_active: true`, When executed, Then the new scene becomes the active scene in the Editor.

#### Technical Notes
- `EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single)` + `SaveScene`
- `EditorBuildSettings.scenes` array manipulation for build settings
- Complementa `save_scene` (UMS-017) que solo guarda la escena activa

---

### UMS-028: Asset discovery tool (find_asset)
**Points:** 3 | **Priority:** High | **Epic:** EPIC-006
**As a** AI assistant **I want** to search for assets by name, type, or label **so that** I can find asset paths for references without knowing the exact path.

#### Acceptance Criteria
**AC1:** Given I call `find_asset` with `type: "Material"` and `name: "Hex"`, When executed, Then returns all Material assets whose name contains "Hex" with their full asset paths.

**AC2:** Given I call `find_asset` with `type: "Prefab"` and `folder: "Assets/Prefabs"`, When executed, Then returns all prefabs in that folder.

**AC3:** Given I call `find_asset` with `type: "TextAsset"` and `extension: ".json"`, When executed, Then returns all JSON files in the project.

**AC4:** Given I call `find_asset` with `type: "MonoScript"` and `name: "GameManager"`, When executed, Then returns the script asset path.

#### Technical Notes
- Usar `AssetDatabase.FindAssets(filter, searchInFolders)` con filter syntax de Unity: `"t:Material Hex"`, `"t:Prefab"`, etc.
- Retornar path, name, type, y GUID por cada resultado
- Limitar resultados a 50 por defecto (parametro `max_results`)

---

### UMS-029: Layout component helpers
**Points:** 2 | **Priority:** Medium | **Epic:** EPIC-006
**As a** AI assistant **I want** a convenience tool to configure layout components **so that** I can set up complex UI hierarchies efficiently.

#### Acceptance Criteria
**AC1:** Given a GameObject, When I call `set_layout` with `type: "vertical"`, `spacing: 8`, `padding: [10,10,5,5]`, `child_expand_width: true`, Then a VerticalLayoutGroup is added (or configured if exists) with those settings.

**AC2:** Given a GameObject, When I call `set_layout` with `type: "horizontal"` and similar params, Then a HorizontalLayoutGroup is configured.

**AC3:** Given a GameObject, When I call `set_layout` with `type: "grid"`, `cell_size: [100, 100]`, `constraint: "fixed_column_count"`, `constraint_count: 3`, Then a GridLayoutGroup is configured.

**AC4:** Given a GameObject, When I call `set_layout` with `content_size_fitter: {"horizontal": "preferred", "vertical": "preferred"}`, Then a ContentSizeFitter is added/configured alongside the layout.

**AC5:** Given a GameObject, When I call `set_layout` with `layout_element: {"preferred_width": 200, "min_height": 50, "flexible_width": 1}`, Then a LayoutElement is added/configured.

#### Technical Notes
- Combina add_component + set_serialized_field en un solo call orientado a layout
- Padding como array [left, right, top, bottom] o objeto {left, right, top, bottom}
- Soportar los 3 layout groups + ContentSizeFitter + LayoutElement en un solo tool
- Si el componente ya existe, actualizar en lugar de agregar duplicado

---

### UMS-030: Auto-reconnect del server tras desconexion
**Points:** 3 | **Priority:** Medium | **Epic:** EPIC-006
**As a** developer **I want** the MCP server to automatically reconnect when the client disconnects **so that** I don't have to manually restart via the Unity menu.

#### Acceptance Criteria
**AC1:** Given the MCP server is running, When the Claude Code session disconnects, Then the server detects the disconnect and starts listening for a new connection within 2 seconds.

**AC2:** Given a new Claude Code session starts, When it connects to the named pipe, Then the server accepts the connection without manual intervention.

**AC3:** Given the server is in reconnect-wait state, When I check `Tools > Unity MCP > Status`, Then it shows "Waiting for connection..." (not "Stopped").

#### Technical Notes
- Actualmente el server detiene el loop cuando el pipe se cierra. Cambiar a un loop externo que re-crea el NamedPipeServerStream y vuelve a esperar conexion.
- Considerar un delay configurable entre intentos (1-2 segundos)
- Logging del evento de reconexion para diagnostico

---

### UMS-031: Tests para las nuevas herramientas
**Points:** 3 | **Priority:** High | **Epic:** EPIC-006
**As a** developer **I want** EditMode tests for all new tools **so that** regressions are caught automatically.

#### Acceptance Criteria
**AC1:** Given UMS-026 (component resolution), When corro tests, Then hay al menos 8 tests cubriendo: Camera, Button, Image, TextMeshProUGUI, custom MonoBehaviour, GameObject (backward compat), asset ref, error case.

**AC2:** Given UMS-027 (scene management), When corro tests, Then hay al menos 4 tests: create scene, save, add to build settings, create with set_active.

**AC3:** Given UMS-028 (find_asset), When corro tests, Then hay al menos 4 tests: by type, by name, by folder, max_results limit.

**AC4:** Given UMS-029 (layout helpers), When corro tests, Then hay al menos 6 tests: vertical, horizontal, grid, content_size_fitter, layout_element, update existing.

**AC5:** Todos los tests nuevos pasan en Unity Test Runner (EditMode).

#### Technical Notes
- Seguir patrones de los 75 tests existentes
- Crear test scene fixtures temporales cuando sea necesario
- Tests de UMS-026 son los mas criticos: probar con tipos reales de Unity (Camera, Light, Canvas)

---

## Resumen

| ID | Titulo | Pts | Prioridad | Dependencia |
|----|--------|-----|-----------|-------------|
| UMS-026 | Component-typed field resolution | 5 | Critical | Ninguna |
| UMS-027 | Scene management tools | 3 | High | Ninguna |
| UMS-028 | Asset discovery tool | 3 | High | Ninguna |
| UMS-029 | Layout component helpers | 2 | Medium | Ninguna |
| UMS-030 | Auto-reconnect del server | 3 | Medium | Ninguna |
| UMS-031 | Tests para nuevas herramientas | 3 | High | UMS-026 a UMS-029 |
| **Total** | | **19** | | |

### Orden de desarrollo recomendado

**Ola 1 (paralelo):** UMS-026 + UMS-027 + UMS-028 (independientes, 11 pts)
**Ola 2 (paralelo):** UMS-029 + UMS-030 (independientes, 5 pts)
**Ola 3:** UMS-031 (tests, depende de Ola 1+2, 3 pts)

### Impacto en Gaia Protocol

Con UMS-026 resuelto, el ensamblaje de la escena de Gaia Protocol (GP-032) se puede automatizar completamente:
- Crear Canvas + hierarchy de UI (~40 GameObjects)
- Agregar 22 MonoBehaviours a los GameObjects correctos
- Wiring de ~60 SerializeField references (Component-typed y asset-typed)
- Crear prefabs reutilizables
- Configurar Build Settings

Sin UMS-026, el wiring de campos Component-typed (~70% de los campos) requiere trabajo manual en el Inspector.

---

## ID Registry Update
| Rango | Estado |
|-------|--------|
| UMS-001 a UMS-025 | Asignados (25 Done) |
| UMS-026 a UMS-031 | Asignados (EPIC-006 - Pending) |
| Proximo ID: UMS-032 |
