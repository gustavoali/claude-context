# Claude Code Monitor - Flutter

**Version:** 1.0.0
**Platform:** Flutter (macOS, Windows, Linux, Android)
**Estado:** En desarrollo

---

## Descripcion

Aplicacion multiplataforma en Flutter que replica la funcionalidad de Claude Code Dashboard (originalmente desarrollado en Swift para macOS).

**Funcionalidad principal:**
- Monitorear sesiones de Claude Code en tiempo real
- Mostrar estado, tokens usados, duracion en un popover/ventana flotante
- Permitir activar la terminal de cada sesion
- Ocultar/mostrar sesiones
- Limpiar automaticamente sesiones antiguas (>24h o idle >5 min)

---

## Arquitectura

**Patron:** MVVM (Model-View-ViewModel)
**State Management:** Provider
**UI:** Flutter widgets (Material Design + custom styling)
**Persistencia:** JSON file-based (`~/.claude/dashboard-state.json`)

**Componentes principales:**
- **Models:** Session, DashboardState, TokenUsage
- **Services:** StateFileService (I/O JSON)
- **ViewModels:** DashboardViewModel (Provider ChangeNotifier)
- **Views:** SystemTrayIcon, PopoverWindow, SessionCard, EmptyState, HiddenSessions

---

## Platforms Target

| Platform | Status | Notas |
|----------|--------|-------|
| macOS | Planned | System tray + popover |
| Windows | Planned | System tray + popup window |
| Linux | Planned | System tray + popup window |
| Android | Planned | Notification + overlay |

---

## Tecnologias

- **Flutter:** 3.x
- **Dart:** 3.x
- **State Management:** Provider
- **System Tray:** `system_tray` package
- **File I/O:** `dart:io` + `path_provider`
- **JSON:** `dart:convert`

---

## Estructura del Proyecto

```
lib/
├── main.dart
├── models/
│   ├── session.dart
│   ├── dashboard_state.dart
│   └── token_usage.dart
├── services/
│   └── state_file_service.dart
├── viewmodels/
│   └── dashboard_viewmodel.dart
├── views/
│   ├── popover_view.dart
│   ├── session_card.dart
│   ├── empty_state_view.dart
│   └── hidden_sessions_view.dart
└── utils/
    ├── time_formatter.dart
    ├── token_formatter.dart
    └── terminal_activator.dart
```

---

## Estado del Proyecto

**Fase actual:** Setup y planificacion

Ver: `PRODUCT_BACKLOG.md` para roadmap detallado.

---

## Documentacion Relacionada

- `ARCHITECTURE.md` - Diseno arquitectonico detallado
- `LEARNINGS.md` - Patrones y decisiones tecnicas
- `PRODUCT_BACKLOG.md` - Backlog de historias
