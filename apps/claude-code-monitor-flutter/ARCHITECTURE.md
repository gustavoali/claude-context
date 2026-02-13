# Arquitectura - Claude Code Monitor Flutter

**Version:** 1.0
**Fecha:** 2026-02-01

---

## Vision General

Aplicacion multiplataforma que monitorea sesiones de Claude Code mediante polling de archivo JSON.

**Patron arquitectonico:** MVVM (Model-View-ViewModel)

```
┌─────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                │
│  (Views - Flutter Widgets)                          │
│  - SystemTrayIcon                                   │
│  - PopoverWindow                                    │
│  - SessionCard, EmptyState, HiddenSessions          │
└─────────────────┬───────────────────────────────────┘
                  │ (observes)
                  ↓
┌─────────────────────────────────────────────────────┐
│                   VIEWMODEL LAYER                   │
│  (DashboardViewModel - Provider ChangeNotifier)     │
│  - state: DashboardState                            │
│  - polling timer (3s)                               │
│  - hide/unhide sessions                             │
│  - cleanup stale sessions                           │
└─────────────────┬───────────────────────────────────┘
                  │ (uses)
                  ↓
┌─────────────────────────────────────────────────────┐
│                    SERVICE LAYER                    │
│  (StateFileService)                                 │
│  - readState() -> DashboardState?                   │
│  - writeState(DashboardState)                       │
│  - hasFileChanged() -> bool                         │
└─────────────────┬───────────────────────────────────┘
                  │ (reads/writes)
                  ↓
┌─────────────────────────────────────────────────────┐
│                   PERSISTENCE LAYER                 │
│  JSON File: ~/.claude/dashboard-state.json          │
└─────────────────────────────────────────────────────┘
```

---

## Capas

### 1. Model Layer

**Entidades principales:**

```dart
enum SessionStatus {
  working,      // Sesion activa ejecutando
  waitingInput, // Esperando input del usuario
  idle,         // Sin actividad
  ended,        // Sesion terminada
  error         // Error ocurrido
}

class TokenUsage {
  final int input;
  final int output;
  int get total => input + output;
}

class Session {
  final String sessionId;
  final String cwd;
  final SessionStatus status;
  final String? statusDetail;
  final DateTime updatedAt;
  final DateTime? startedAt;
  final TokenUsage? tokenUsage;

  String get projectName; // computed: basename(cwd)
  bool get isStale;       // computed: >24h o ended >5min
}

class DashboardState {
  final int version;
  final List<Session> sessions;
  final List<String> hiddenSessions;

  List<Session> get visibleSessions;      // computed
  List<Session> get hiddenSessionObjects; // computed
}
```

**JSON Schema:**
```json
{
  "version": 1,
  "sessions": [
    {
      "session_id": "xyz-123",
      "cwd": "/path/to/project",
      "status": "working",
      "status_detail": "Running Bash",
      "started_at": "2026-02-01T10:30:00Z",
      "updated_at": "2026-02-01T10:35:45Z",
      "token_usage": {
        "input": 5000,
        "output": 2500
      }
    }
  ],
  "hidden_sessions": ["old-session-id"]
}
```

---

### 2. Service Layer

**StateFileService:**
```dart
class StateFileService {
  static const String stateFilePath = '~/.claude/dashboard-state.json';
  DateTime? _lastModified;

  // Optimizacion: solo lee si archivo cambio
  bool hasFileChanged();

  // Lee y decodifica JSON
  Future<DashboardState?> readState();

  // Escribe atomicamente (temp file + rename)
  Future<void> writeState(DashboardState state);
}
```

**Responsabilidades:**
- I/O del archivo JSON
- Deteccion de cambios (optimization)
- Serialization/deserialization
- Atomic writes

---

### 3. ViewModel Layer

**DashboardViewModel:**
```dart
class DashboardViewModel extends ChangeNotifier {
  DashboardState _state = DashboardState.empty();
  Timer? _pollingTimer;
  final StateFileService _fileService;

  DashboardState get state => _state;

  // Computed properties
  String get menuBarIcon; // decide icono segun estado

  // Lifecycle
  void startPolling(); // Timer cada 3s
  void stopPolling();

  // Actions
  Future<void> loadState();
  Future<void> pollState();
  void hideSession(String sessionId);
  void unhideSession(String sessionId);
  void cleanStale();
}
```

**Responsabilidades:**
- Coordinar logica de negocio
- Polling timer (3 segundos)
- Cleanup de sesiones stale
- Notificar cambios a UI (via ChangeNotifier)

**Ciclo de polling:**
```
Timer (3s) tick
  ↓
hasFileChanged()?
  ↓ No → skip
  ↓ Yes
readState()
  ↓
cleanStale()
  ↓
notifyListeners()
  ↓
UI updates
```

---

### 4. View Layer

**Componentes UI:**

```dart
// System tray icon
SystemTrayIcon
  - icono dinamico (○ ● ⚠ ✕)
  - onClick → mostrar popover

// Ventana principal
PopoverWindow
  - 350px ancho
  - max 400px alto (scrollable)
  - Header: "Claude Code" + contador
  - Body: ListView de SessionCard
  - Footer: HiddenSessions + Quit button

// Tarjeta de sesion
SessionCard
  - Status icon + project name + hide button
  - Status detail (si existe)
  - Token usage + duration + time ago
  - onClick → activar terminal
  - onHide → ocultar sesion

// Estado vacio
EmptyStateView
  - Terminal icon + mensaje
  - Mostrar cuando sessions.isEmpty

// Sesiones ocultas
HiddenSessionsView
  - ExpansionTile con lista de sesiones ocultas
  - Eye icon para mostrar sesion
```

**Responsive behavior:**
- macOS/Windows/Linux: popover flotante
- Android: notification + fullscreen overlay (TBD)

---

### 5. Utils Layer

**TimeFormatter:**
```dart
class TimeFormatter {
  static String duration(DateTime start, DateTime end);
  // Ej: "2h 35m", "45m"

  static String relativeTime(DateTime date);
  // Ej: "just now", "5m ago", "2h ago"
}
```

**TokenFormatter:**
```dart
class TokenFormatter {
  static String format(int count);
  // 1_500_000 → "1.5M"
  // 5_500     → "5.5k"
  // 42        → "42"
}
```

**TerminalActivator:**
```dart
class TerminalActivator {
  static Future<bool> activateSession(Session session);
  // Platform-specific: buscar y activar terminal
  // macOS: AppleScript
  // Windows: ProcessStartInfo
  // Linux: wmctrl / xdotool
}
```

---

## Flujos de Datos

### Flujo 1: Inicio de App
```
main()
  ↓
runApp(ChangeNotifierProvider(DashboardViewModel))
  ↓
DashboardViewModel.startPolling()
  ↓
Timer cada 3s → pollState()
```

### Flujo 2: Deteccion de Cambio
```
Hook script actualiza dashboard-state.json
  ↓
Timer tick (3s)
  ↓
hasFileChanged() → true
  ↓
readState()
  ↓
cleanStale()
  ↓
notifyListeners()
  ↓
UI rebuild (Consumer<DashboardViewModel>)
```

### Flujo 3: User Interaction
```
User click en SessionCard
  ↓
onTap() → TerminalActivator.activateSession()
  ↓
Terminal app se activa (platform-specific)

User click hide button
  ↓
onHide() → viewModel.hideSession(sessionId)
  ↓
writeState() (persiste hidden_sessions)
  ↓
notifyListeners()
  ↓
UI actualiza (sesion desaparece)
```

---

## Decisiones Arquitectonicas

### Decision 1: Provider vs Riverpod/Bloc
**Elegido:** Provider

**Razon:**
- Simplicidad (app pequeña, no necesita complejidad de Riverpod)
- Comunidad grande, bien documentado
- Suficiente para polling-based state

### Decision 2: Polling vs WebSockets
**Elegido:** Polling cada 3 segundos

**Razon:**
- Replicar comportamiento de app Swift original
- Suficiente para UX (3s es casi real-time)
- Menos complejidad que WebSockets
- Hook script solo escribe archivo, no servidor

### Decision 3: File-based vs Database
**Elegido:** JSON file (`~/.claude/dashboard-state.json`)

**Razon:**
- Replicar arquitectura original
- Simplicidad (no setup de DB)
- Datos pequeños (<50 sesiones)
- Shared state con hook script

### Decision 4: System Tray Package
**Candidatos:**
- `system_tray` (win/mac/linux)
- `tray_manager` (alternativa)

**TBD:** Evaluar en implementacion

### Decision 5: Android Strategy
**Problema:** Android no tiene system tray

**Solucion propuesta:**
- Notification persistente con estado
- Tap notification → abrir app fullscreen
- Overlay flotante? (requiere permisos especiales)

**TBD:** Definir en backlog

---

## Performance Considerations

### Optimizacion 1: File Change Detection
```dart
// Solo leer archivo si modification date cambio
// Evita decodificar JSON innecesariamente
if (!hasFileChanged()) return;
```

### Optimizacion 2: Limit Sessions
```dart
// Maximo 50 sesiones en memoria
// Mas antiguas son limpiadas automaticamente
const maxSessions = 50;
```

### Optimizacion 3: Debounced UI Updates
```dart
// notifyListeners() solo si state realmente cambio
if (_state != newState) {
  _state = newState;
  notifyListeners();
}
```

---

## Testing Strategy

### Unit Tests
- Models: serialization/deserialization
- Services: file I/O, change detection
- ViewModels: business logic, cleanup

### Widget Tests
- SessionCard rendering
- EmptyState display
- HiddenSessions expand/collapse

### Integration Tests
- Full polling flow
- Hide/unhide sessions
- Terminal activation (mock)

---

## Platform-Specific Considerations

| Platform | System Tray | Terminal Activation | Notes |
|----------|-------------|---------------------|-------|
| macOS | system_tray | AppleScript | Native popover |
| Windows | system_tray | Process API | Popup window |
| Linux | system_tray | wmctrl/xdotool | Popup window |
| Android | Notification | Intent | Fullscreen |

---

## Dependencies (Estimado)

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  path_provider: ^2.0.0
  system_tray: ^2.0.0  # TBD: verificar version
  intl: ^0.18.0        # Para formateo de fechas

dev_dependencies:
  flutter_test:
    sdk: flutter
  test: ^1.24.0
```

---

## Proximos Pasos (ACTUALIZADO 2026-02-05)

### Completados (Sprints 1-8)
1. ~~Crear backlog detallado (product-owner)~~ Done
2. ~~Implementar models + JSON serialization~~ Done
3. ~~Implementar StateFileService~~ Done
4. ~~Implementar DashboardViewModel~~ Done
5. ~~Implementar UI components~~ Done
6. ~~Testing~~ Done (444 tests)
7. ~~Telegram Integration~~ Done (Sprint 6)
8. ~~Android App~~ Done (Sprint 8)

### Siguiente: Epic 8 - Integracion Claude Orchestrator

**Dependencia externa:** `C:/mcp/claude-orchestrator/` (scaffolding completo)

**Componentes a agregar:**

1. **OrchestratorService** (lib/services/orchestrator_service.dart)
   - WebSocket client a ws://localhost:8765
   - Connection management (connect, disconnect, reconnect)
   - Message serialization/deserialization
   - Stream<OrchestratorEvent> para eventos push

2. **Modelos nuevos** (lib/models/)
   - OrchestratorSession (similar a Session pero con agentSessionId)
   - AgentMessage (type, content, tool, result)
   - OrchestratorEvent (session_created, session_updated, agent_message, etc.)

3. **DashboardViewModel extendido**
   - Inyectar OrchestratorService como dependencia opcional
   - Combinar sessions de ambas fuentes (JSON + Orchestrator)
   - Nuevos methods: createOrchestratorSession, sendInstruction

4. **UI Components nuevos**
   - CreateSessionDialog: Selector proyecto, nombre, tools
   - InstructionInputSheet: TextField + send + cancel
   - SessionCard extendido: Boton "Send" para sesiones orchestrator

Ver `TASK_STATE.md` para historias detalladas.

---

## Arquitectura Extendida (con Orchestrator)

```
┌─────────────────────────────────────────────────────────────┐
│                    FLUTTER APP                               │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────┐     ┌──────────────────────────────┐  │
│  │ StateFileService │     │ OrchestratorService (NUEVO)  │  │
│  │ (polling JSON)   │     │ (WebSocket real-time)        │  │
│  └────────┬─────────┘     └──────────────┬───────────────┘  │
│           │                              │                   │
│           └──────────────┬───────────────┘                   │
│                          │                                   │
│              ┌───────────▼───────────┐                       │
│              │   DashboardViewModel  │                       │
│              │   (combina ambos)     │                       │
│              └───────────┬───────────┘                       │
│                          │                                   │
│              ┌───────────▼───────────┐                       │
│              │      Views            │                       │
│              │ + CreateSessionDialog │                       │
│              │ + InstructionInput    │                       │
│              └───────────────────────┘                       │
└──────────────────────────┼───────────────────────────────────┘
                           │ WebSocket
                           ▼
┌──────────────────────────────────────────────────────────────┐
│              Claude Orchestrator (ws://localhost:8765)       │
│              C:/mcp/claude-orchestrator/                     │
└──────────────────────────────────────────────────────────────┘
```

---

**Revision:** 2026-02-05
**Estado:** MVP completado (96%). Epic 8 (Orchestrator) planificado.
