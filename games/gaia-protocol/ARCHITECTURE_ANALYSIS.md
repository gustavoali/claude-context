# Arquitectura - Gaia Protocol
**Version:** 0.1.0 | **Fecha:** 2026-02-21

## Diagrama de Componentes

```
+-----------------------------------------------------------+
|                   Unity Client (Android)                   |
|  +-----------+ +----------+ +----------+ +--------------+ |
|  | UI Layer  | | Map Layer| | Input/   | | Save/Load    | |
|  | (Panels)  | | (HexGrid)| | Actions  | | (JSON files) | |
|  +-----+-----+ +----+-----+ +----+-----+ +------+-------+ |
|        +-------------+----------+-+-----------+            |
|                 +----v----+ +----v-----+ +----v---------+  |
|                 |GameMgr  | |TurnMgr   | |DataMgr       |  |
|                 +----+----+ +----+-----+ +----+---------+  |
+-------------------|-----------|-----------|-+--------------+
                    v           v           v
  +-----------------------------------------------------+
  |           Simulation Core (C# puro)                  |
  |  Determinista | Sin IO | Sin Unity deps              |
  |                                                      |
  |  GameState ─> TurnPipeline ─> TurnResult             |
  |                    |                                  |
  |  Engines: Economy, Climate, Ecology, Social,         |
  |           Influence, Diplomacy, Epic                  |
  |                                                      |
  |  Models: HexTile, Civilization, World, Resources,    |
  |          GlobalClimateState, CouncilState, EpicState  |
  |                                                      |
  |  Data Definitions (POCOs): Biome, Tech, Policy,      |
  |                            District, Epic             |
  +-------------------------+----------------------------+
                            |
                 +----------v-----------+
                 | Data Layer (JSON)    |
                 | biomes, techs,       |
                 | policies, districts  |
                 +----------------------+
```

**Futuro (post-MVP):** `Unity <--HTTP/WS--> .NET 8 API <--> Core <--> PostgreSQL`

## Componentes

| Componente | Carpeta | Responsabilidad |
|------------|---------|-----------------|
| Simulation Core | `src/GaiaProtocol.Core/` | Modelos, engines, logica de turno. C# puro, sin deps de Unity |
| Unity Client | `Assets/Scripts/` | Rendering, UI, input, integracion con Core |
| GameManager | `Assets/Scripts/Game/` | Orquesta partida: init, turno, save/load |
| TurnPipeline | `Core/Simulation/` | Ejecuta engines en orden determinista |
| Engines (x7) | `Core/Simulation/Engines/` | Logica de cada sistema (economia, clima, etc.) |
| Models | `Core/Models/` | Entidades de dominio (HexTile, Civilization, etc.) |
| Data Definitions | `Core/Data/` | POCOs para deserializar JSON de configuracion |
| Data JSON | `Assets/Resources/Data/` | Archivos JSON con biomas, techs, policies, etc. |
| Map Layer | `Assets/Scripts/Map/` | HexGrid rendering, camara, seleccion, overlays |
| UI Layer | `Assets/Scripts/UI/` | Paneles, bindings, navegacion |
| Save/Load | `Assets/Scripts/Persistence/` | Serializacion de GameState a JSON |
| Backend API | `src/GaiaProtocol.Api/` | FUTURO. Vacio hasta post-MVP |

## Flujo de Datos

### Flujo de un turno completo
```
1. JUGADOR selecciona acciones (build distrito, set policy, research tech, propuesta consejo)
2. Unity -> GameManager.SubmitActions(List<PlayerAction>)
3. ActionValidator.Validate(actions, gameState) -> List<ValidatedAction>
4. TurnPipeline.Execute(gameState, validatedActions) -> TurnResult
   |-- 4.1 ApplyActions: muta gameState con acciones validadas
   |-- 4.2 EconomyEngine   -> produce/consume recursos
   |-- 4.3 ClimateEngine   -> CO2, temperatura, eventos
   |-- 4.4 EcologyEngine   -> biodiversidad, degradacion
   |-- 4.5 SocialEngine    -> bienestar, migraciones
   |-- 4.6 InfluenceEngine -> difusion, integraciones
   |-- 4.7 DiplomacyEngine -> tratados, votaciones
   |-- 4.8 EpicEngine      -> progreso epica, victoria check
5. TurnResult = nuevo GameState + TurnSummary + List<GameEvent>
6. Unity actualiza mapa, paneles, notificaciones
7. AI civilizations ejecutan su turno (misma pipeline)
8. Incrementar turno. Volver a 1.
```

### Save/Load
```
Save: GameState -> System.Text.Json.Serialize -> .json en Application.persistentDataPath/saves/
Load: .json -> Deserialize -> GameState -> GameManager.LoadState()
```

## ADRs (Architecture Decision Records)

### ADR-001: Organizacion del codigo compartido

**Contexto:** Core debe ser C# puro, usado por Unity ahora y potencialmente por backend .NET despues. 1 developer.

| Opcion | Pros | Contras |
|--------|------|---------|
| A: Shared .csproj referenciado por Unity | Testeable con xUnit, reutilizable | Requiere config Assembly Definition |
| B: Codigo duplicado | Simple al inicio | Divergencia inmediata, inaceptable |
| C: NuGet package | Versionado explicito | Over-engineering, Unity no consume NuGet nativo |

**Decision:** Opcion A. Un .csproj en `src/GaiaProtocol.Core/` targeteando netstandard2.1. Unity referencia via .asmdef o DLL copiada a Assets/Plugins/. Tests en proyecto separado con xUnit (net8.0).

---

### ADR-002: Patron de los engines de simulacion

**Contexto:** 7 engines procesan GameState secuencialmente. Deben ser deterministas, testeables, extensibles.

| Opcion | Pros | Contras |
|--------|------|---------|
| A: Clases estaticas | Maximo simplicidad | No mockeable, no inyecta config |
| B: Interfaz comun IEngine | Testeable, mockeable, orden configurable | Algo mas de ceremony |
| C: Pipeline middleware | Max extensibilidad, interceptors | Over-engineering para 7 engines fijos |

**Decision:** Opcion B. `IEngine.Process(GameState)`. TurnPipeline mantiene `List<IEngine>` en orden fijo. Engines reciben config via constructor.

---

### ADR-003: Persistencia de game state (MVP offline)

**Contexto:** Guardar/cargar en Android. Estado: ~625 hexes, civilizaciones, techs, clima global.

| Opcion | Pros | Contras |
|--------|------|---------|
| A: JSON (System.Text.Json) | Debuggeable, sin deps extra, compatible backend | Mas grande, mas lento que binario |
| B: MessagePack | Rapido, ~50% tamaño | No legible, dep externa |
| C: SQLite local | Queries parciales | Over-engineering para MVP |

**Decision:** Opcion A. Para 625 hexes sera ~500KB-2MB, aceptable. Legibilidad facilita debugging. Migrar a MessagePack post-MVP si > 5MB.

---

### ADR-004: Configuracion data-driven (biomas, techs, policies)

**Contexto:** Datos de juego editables sin recompilar. Accesibles desde Core (C# puro) y Unity (UI).

| Opcion | Pros | Contras |
|--------|------|---------|
| A: JSON files puros | Compartible con backend, editable | No integra con Unity Inspector |
| B: ScriptableObjects | Integracion nativa Unity | No compartible con Core |
| C: Hibrido JSON + ScriptableObjects | Core lee JSON, Unity agrega visual | Dos fuentes, sincronizar IDs |

**Decision:** Opcion C. JSON define mecanica (stats, costos, efectos). ScriptableObjects mapean IDs a assets visuales (sprites, colores). IDs son strings estables (`"biome_forest"`, `"tech_solar_energy"`).

---

### ADR-005: Estructura del mapa hexagonal

**Contexto:** Mapa 25x25. Operaciones: acceso, vecinos, iteracion, busquedas por area.

| Opcion | Pros | Contras |
|--------|------|---------|
| A: Array 2D offset | O(1), memoria contigua | Vecinos con parity check |
| B: Dictionary axial (q,r) | Vecinos triviales (6 offsets), mapas irregulares | Hash overhead |
| C: Flat array + conversion | O(1), cache-friendly | Complejidad de conversion |

**Decision:** Opcion B. Para 625 hexes el overhead es despreciable. Seed ya define axial (q,r). `HexCoord` struct inmutable con Q, R, computed S=-Q-R. Metodos: `Neighbors()`, `Distance()`, `Ring()`, `Range()`.

## Interfaces y Contratos

```csharp
// --- Interfaces clave ---
public interface IEngine { void Process(GameState state); }

public interface IDataProvider
{
    IReadOnlyList<BiomeDefinition> Biomes { get; }
    IReadOnlyList<TechDefinition> Technologies { get; }
    IReadOnlyList<PolicyDefinition> Policies { get; }
    IReadOnlyList<DistrictDefinition> Districts { get; }
    IReadOnlyList<EpicDefinition> Epics { get; }
    T GetById<T>(string id) where T : class, IGameDefinition;
}

public interface IGameDefinition { string Id { get; } string Name { get; } }

// --- Structs/Classes principales ---
public readonly struct HexCoord : IEquatable<HexCoord>  // Q, R, S=-Q-R
public class GameState         // TurnNumber, World, Civilizations, Climate, Council, ActiveEpic
public class World             // Dictionary<HexCoord, HexTile> Tiles, Width, Height
public class HexTile           // Coord, BiomeId, LandUse, Population, Pollution, EcologicalIntegrity,
                               // InfluenceByPlayer (Dict<string,float>), OwnerId, DistrictIds
public class Civilization      // Id, Name, Resources, ResearchedTechIds, ActivePolicyIds,
                               // CurrentResearchId, Wellbeing, Stability, IsHuman
public class Resources         // Production, Food, Science, Culture, Money (all float)
public class GlobalClimateState // Co2Ppm, TemperatureAnomaly, SeaLevelRise, BiodiversityIndex

// --- Turn Pipeline ---
public class TurnPipeline      // List<IEngine> _engines; Execute(GameState, List<ValidatedAction>) -> TurnResult
public class TurnResult        // NewState, Summary (TurnSummary), Events (List<GameEvent>), Victory (VictoryCheck)
```

## Folder Structure

```
gaia-protocol/
|-- src/
|   |-- GaiaProtocol.Core/              # netstandard2.1
|   |   |-- Models/                     # HexCoord, GameState, World, HexTile, Civilization,
|   |   |   |                           # Resources, GlobalClimateState, CouncilState, EpicState
|   |   |   |-- Actions/               # PlayerAction, ValidatedAction
|   |   |-- Data/
|   |   |   |-- Definitions/           # IGameDefinition, BiomeDef, TechDef, PolicyDef, DistrictDef, EpicDef
|   |   |   |-- IDataProvider.cs
|   |   |   |-- JsonDataProvider.cs
|   |   |-- Simulation/
|   |   |   |-- IEngine.cs, TurnPipeline.cs, ActionValidator.cs
|   |   |   |-- TurnResult.cs, TurnSummary.cs, GameEvent.cs, VictoryCheck.cs
|   |   |   |-- Engines/               # Economy, Climate, Ecology, Social, Influence, Diplomacy, Epic
|   |   |-- Map/                        # HexUtils.cs, MapGenerator.cs
|   |
|   |-- GaiaProtocol.Core.Tests/        # xUnit (net8.0)
|   |   |-- Engines/                    # Tests por engine
|   |   |-- Models/                     # HexCoordTests, etc.
|   |   |-- Simulation/                 # TurnPipelineTests, ActionValidatorTests
|   |   |-- Scenarios/                  # ScenarioRunner, GoldenFiles/
|   |   |-- Fixtures/                   # GameStateBuilder (builder pattern)
|   |
|   |-- GaiaProtocol.Api/               # FUTURO - vacio
|   |-- GaiaProtocol.sln
|
|-- Assets/                              # Unity project root
|   |-- Scripts/
|   |   |-- Game/                       # GameManager, TurnManager, DataManager
|   |   |-- Map/                        # HexGridRenderer, HexTileView, CameraController, MapOverlay
|   |   |-- UI/                         # Panels/, HUD/, Notifications/
|   |   |-- Persistence/               # SaveManager
|   |   |-- AI/                         # SimpleAI
|   |-- Resources/Data/                 # biomes.json, technologies.json, policies.json, districts.json, epics.json
|   |-- Plugins/                        # GaiaProtocol.Core.dll (compiled Core)
|-- docs/
|-- .gitignore
```

## Testing Strategy

| Nivel | Herramienta | Que testea | Ejemplo |
|-------|-------------|------------|---------|
| Unit | xUnit + FluentAssertions | Cada engine aislado | EconomyEngine con 1 ciudad produce recursos |
| Model | xUnit | HexCoord, Resources | `Distance((0,0),(2,1)) == 2` |
| Pipeline | xUnit | TurnPipeline orden | 2 engines modifican estado secuencialmente |
| Scenario | ScenarioRunner | N turnos con seed | 20 turnos sin acciones: CO2 sube |
| Snapshot | Golden files | Estado serializado | Turno 10 seed X == snapshot |
| Balance | Custom runner | IA vs IA masivo | 100 partidas: ninguna civ >70% wins |

**Principios:** Determinismo obligatorio (fallo intermitente = bug). GameStateBuilder para crear estados de test. Tests corren fuera de Unity via xUnit.

**Coverage targets:** Engines >80%, Models >70%, Overall Core >70%.

## Performance Strategy

| Operacion | Target | Contexto |
|-----------|--------|----------|
| Turno completo | < 200ms | 25x25, 4 civs, 7 engines |
| Save | < 500ms | GameState completo a JSON |
| Load | < 1s | Deserializar + init |
| Frame rate | 30 FPS | Android mid-range 2023+ |

**Estrategias:** Structs donde posible (HexCoord), evitar LINQ en hot paths, frustum culling, pooling de tiles. Source generators de System.Text.Json para IL2CPP/AOT.

### Determinismo (critico)
- **Acumulaciones:** Usar `decimal` o fixed-point para CO2, temperatura (evitar error de float).
- **Orden de iteracion:** Dictionary no garantiza orden. Iterar con `.OrderBy(h => h.Key)` en engines.
- **PRNG:** Determinista con seed en GameState (`System.Random` con seed fija). No usar `Random.Shared`.
- **Sin DateTime:** El turno es la unidad de tiempo.

## Technical Debt Activo

| ID | Descripcion | Severidad | Notas |
|----|-------------|-----------|-------|
| TD-001 | Core en netstandard2.1 (limita APIs) | Low | Trade-off para Unity. Migrar cuando soporte .NET 8 |
| TD-002 | JSON saves pueden crecer | Low | OK para 25x25. MessagePack si > 5MB |
| TD-003 | IA simple (heuristica basica) | Medium | Suficiente para MVP |
| TD-004 | Sin backend/multiplayer | Medium | Arquitectura preparada, no implementado |

## Decisiones Arquitectonicas

| Decision | Fecha | Razon |
|----------|-------|-------|
| Core como proyecto C# separado de Unity | 2026-02-21 | Testabilidad, reutilizacion (ADR-001) |
| IEngine como interfaz comun | 2026-02-21 | Testabilidad + simplicidad (ADR-002) |
| JSON para persistencia MVP | 2026-02-21 | Debuggability, tamaño aceptable (ADR-003) |
| Hibrido JSON + ScriptableObjects | 2026-02-21 | Core sin deps Unity + assets visuales (ADR-004) |
| Dictionary axial para mapa | 2026-02-21 | Vecinos triviales, ya definido en seed (ADR-005) |
| netstandard2.1 para Core | 2026-02-21 | Compatibilidad Unity 2021+ |
| xUnit fuera de Unity | 2026-02-21 | Velocidad, CI/CD standard |
| PRNG con seed en GameState | 2026-02-21 | Determinismo para replay y testing |

## Stack

| Tecnologia | Version | Uso |
|------------|---------|-----|
| C# | 9.0 (netstandard2.1) | Simulation Core |
| .NET SDK | 8.0 | Build y tests del Core |
| Unity | 2022.3 LTS o 6000.x | Cliente Android |
| xUnit | 2.x | Unit tests |
| FluentAssertions | 7.x | Assertions expresivas |
| System.Text.Json | incluido | Serializacion JSON |
| Android SDK | API 26+ (8.0+) | Target minimo |
| PostgreSQL | 17 | FUTURO - backend multiplayer |
| .NET 8 (API) | 8.0 | FUTURO - backend |

## Security Threat Model

**Fecha:** 2026-02-21 | **Revision:** 1.0

### MVP Offline (Android Single-Player)

| # | Amenaza | Severidad | Mitigacion | Fase |
|---|---------|-----------|------------|------|
| T-01 | Save file tampering (editar JSON) | Low | HMAC-SHA256 checksum. Marcar partida como modificada, no bloquear. | MVP |
| T-02 | Data JSON tampering (biomas, techs) | Low | Embeber en APK (StreamingAssets). Validar schemas con checksums. | MVP |
| T-03 | APK repackaging | Low | IL2CPP (Unity default release). Integrity check basico. | MVP |
| T-04 | Memory manipulation (GameGuardian) | Low | No mitigar en MVP. Server-authoritative invalida en multiplayer. | Post-MVP |

### Post-MVP Multiplayer

| # | Amenaza | Severidad | Mitigacion | Fase |
|---|---------|-----------|------------|------|
| T-05 | Cliente no confiable | Critical | Server-authoritative: backend ejecuta TurnPipeline. ActionValidator en server. | Post-MVP |
| T-06 | Autenticacion debil | High | OAuth 2.0 / OpenID Connect. JWT con refresh tokens. | Post-MVP |
| T-07 | Rate limiting ausente | High | ASP.NET RateLimiter middleware. 60 req/min general, 10/min advance-turn. | Post-MVP |
| T-08 | SQL injection | Medium | EF Core parametriza. Prohibir FromSqlRaw con interpolacion. | Post-MVP |
| T-09 | Broken authorization | High | Ownership check en cada endpoint: game.OwnerId == currentUserId. | Post-MVP |
| T-10 | Desync multiplayer | High | Determinismo + replay validation. Server es fuente de verdad. | Post-MVP |
| T-11 | WebSocket hijacking | Medium | JWT en handshake. Timeout 5 min. Validar origin. | Post-MVP |

### Integridad de Simulacion

El determinismo del Core es feature de seguridad: permite replay validation. Mantener action log por partida como audit trail.
