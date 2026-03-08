# Claude Code Monitor Flutter - Integracion al Ecosistema Project Admin

**Version:** 1.0
**Fecha:** 2026-02-12
**Estado:** PLANIFICADO

---

## Estado Actual

| Aspecto | Detalle |
|---------|---------|
| **Path** | `C:/apps/claude-code-monitor/claude-code-monitor-flutter` |
| **Contexto** | `C:/claude_context/apps/claude-code-monitor-flutter/` |
| **Stack** | Flutter (Dart), Provider, MVVM |
| **Status** | Scaffolding |
| **Plataformas** | Windows, macOS, Linux (desktop) + Android |

### Conexiones Actuales

| Fuente | Protocolo | Proposito |
|--------|-----------|-----------|
| `~/.claude/dashboard-state.json` | File polling (3s) | Sesiones Claude Code locales |
| Claude Orchestrator (`ws://localhost:8765`) | WebSocket | Sesiones orquestadas (crear, controlar, streaming) |
| Telegram Bot API | HTTP polling | Sincronizacion Android + notificaciones |

---

## Rol en el Ecosistema

La app Flutter es la **contraparte mobile y desktop ligera** del Angular Web Dashboard. Mientras Angular provee una experiencia completa de gestion de proyectos en navegador, Flutter ofrece monitoreo rapido y notificaciones push desde system tray o dispositivo movil.

### Que Provee al Ecosistema

- **Monitoreo ubicuo:** Visibilidad de sesiones Claude desde cualquier dispositivo
- **Control rapido:** Crear sesiones y enviar instrucciones sin abrir navegador
- **Push notifications:** Alertas inmediatas de cambios de estado via Telegram o notificaciones nativas
- **Offline-capable:** La app desktop funciona con datos locales (JSON file) sin depender del backend

### Que Consume del Ecosistema

| Fuente | Datos | Uso |
|--------|-------|-----|
| **Project Admin Backend** (REST API) | Proyectos, sprints, estado general | Project cards, sprint status, datos agregados |
| **Claude Orchestrator** (WebSocket) | Sesiones activas, mensajes de agente | Monitoreo real-time, control de sesiones |
| **Sprint Backlog Manager** (via Project Admin) | Burndown, velocity, stories activas | Metricas rapidas en cards de proyecto |

---

## Puntos de Integracion

### 1. REST API - Project Admin Backend (NUEVO)

**Direccion:** Flutter consume datos de Project Admin.

```
Flutter App
    |
    |-- GET /api/projects          --> Lista de proyectos con estado
    |-- GET /api/projects/:id      --> Detalle de proyecto
    |-- GET /api/projects/:id/sprint/active  --> Sprint activo con board
    |-- GET /api/projects/:id/metrics        --> Velocity, burndown
    |-- GET /api/sessions/active   --> Sesiones Claude activas (agregado)
```

### 2. WebSocket - Claude Orchestrator (EXISTENTE)

**Direccion:** Flutter consume y controla sesiones via WebSocket.

Ya implementado. Cambio para ecosistema: URL del WebSocket debe ser configurable via Project Admin settings.

### 3. Push Notifications (NUEVO)

| Evento | Origen | Canal |
|--------|--------|-------|
| Sprint completado | Sprint Backlog Manager (via Project Admin) | Push notification / Telegram |
| Sesion Claude finalizada | Orchestrator | WebSocket event |
| Build failed | CI/CD (futuro) | Push notification |

### 4. Configuracion Centralizada (NUEVO)

Flutter lee configuracion desde Project Admin (`GET /api/config/flutter`).

---

## Features de Integracion

### Feature 1: Project Dashboard Cards (Alta)
Pantalla principal con cards de cada proyecto: nombre, sprint activo, sesiones Claude activas, health indicator.
Fuente: REST API de Project Admin Backend.

### Feature 2: Sprint Board Mobile (Media)
Vista kanban simplificada del sprint activo. Columnas: Backlog | Ready | In Progress | Review | Done.

### Feature 3: Configuracion de Endpoints (Alta)
Settings para configurar URLs del ecosistema (Project Admin URL, Orchestrator WebSocket URL, polling interval).

### Feature 4: Modo Hibrido - Standalone vs Ecosystem (Alta)
Feature flag en settings. Default: standalone (modo actual). Extension sin eliminacion.

---

## Fase de Activacion

**Fase 2 del ecosistema Project Admin.**

### Prerequisitos
1. Project Admin Backend operativo con REST API basica
2. Sprint Backlog Manager integrado con Project Admin
3. Claude Orchestrator con WebSocket server estable

### Cronograma Estimado

| Etapa | Descripcion | Estimacion |
|-------|-------------|------------|
| E1 | Configuracion de endpoints + HTTP client | 1 sprint |
| E2 | Project Dashboard Cards | 1 sprint |
| E3 | Sprint Board Mobile | 1 sprint |
| E4 | Push notifications via ecosistema | 1 sprint |
| E5 | Testing de integracion E2E | 0.5 sprint |

**Total estimado:** 4-5 sprints desde que Project Admin Backend este disponible.

---

## Equipo de Trabajo

### Flutter Developer (Lead)

- **Agente:** `flutter-developer`
- **Funciones:**
  - Implementar nuevas screens y widgets para el ecosistema (Project Cards, Sprint Board)
  - Crear `ProjectAdminService` para comunicacion HTTP con el backend
  - Extender settings para configuracion de endpoints del ecosistema
  - Implementar modo hibrido (standalone vs ecosystem) con feature flags
  - Adaptar `DashboardViewModel` para consumir datos de Project Admin
  - Integrar push notifications nativas (desktop + Android)
- **Tareas clave:**
  1. Crear `ProjectAdminService` (HTTP client con retry, auth, caching)
  2. Implementar `ProjectDashboardScreen` con cards de proyecto
  3. Implementar `SprintBoardScreen` con vista kanban simplificada
  4. Crear `EcosystemSettingsView` para configuracion de conexiones
  5. Implementar feature flag standalone/ecosystem
  6. Push notifications nativas (Windows toast, macOS notification center, Android FCM)
- **Entregables:**
  - `lib/services/project_admin_service.dart`
  - `lib/models/project_summary.dart`, `sprint_summary.dart`
  - `lib/views/project_dashboard_screen.dart`
  - `lib/views/sprint_board_screen.dart`
  - `lib/views/ecosystem_settings_view.dart`
  - `lib/services/notification_service.dart`
- **Dependencias:** Requiere API contracts del backend (software-architect). Requiere backend operativo para testing de integracion.

### Test Engineer

- **Agente:** `test-engineer`
- **Funciones:**
  - Widget tests para nuevas screens
  - Unit tests para `ProjectAdminService` (mock HTTP responses)
  - Integration tests para flujo completo ecosistema
  - Tests de modo hibrido (standalone vs ecosystem switching)
  - Tests de error handling (backend down, timeout, auth failure)
- **Entregables:**
  - `test/services/project_admin_service_test.dart`
  - `test/widgets/project_dashboard_screen_test.dart`
  - `test/widgets/sprint_board_screen_test.dart`
  - `test/integration/ecosystem_integration_test.dart`
  - Coverage report (target: >70% en codigo nuevo)
- **Dependencias:** Requiere implementacion del flutter-developer completada para cada feature.

### Code Reviewer

- **Agente:** `code-reviewer`
- **Funciones:**
  - Code review riguroso pre-merge de cada feature
  - Verificar adherencia a patron MVVM existente
  - Validar que modo hibrido no rompe funcionalidad existente
  - Revisar manejo de errores de red
  - Verificar que no se hardcodean URLs o credenciales
- **Entregables:**
  - Code review reports por cada PR
  - Sign-off de calidad para merge
- **Dependencias:** Se ejecuta despues de cada feature completada y testeada.

### Software Architect

- **Agente:** `software-architect`
- **Funciones:**
  - Definir API contracts entre Flutter y Project Admin Backend
  - Disenar patron de comunicacion HTTP (caching, retry policy, circuit breaker)
  - Validar que la arquitectura hibrida (standalone/ecosystem) es sostenible
  - Definir estrategia de notificaciones cross-platform
  - Evaluar si Provider sigue siendo suficiente o migrar a Riverpod
- **Entregables:**
  - `API_CONTRACTS_FLUTTER.md`
  - `INTEGRATION_DESIGN.md`
  - Recomendacion de state management con justificacion
- **Dependencias:** Se ejecuta primero (upstream de flutter-developer).

---

## Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigacion |
|--------|-------------|---------|------------|
| Backend no disponible | Media | Alto | Modo standalone como fallback automatico |
| Latencia de red en mobile | Media | Medio | Cache agresivo + datos locales |
| Complejidad de estado crece | Alta | Medio | Evaluar migracion Provider -> Riverpod |
| Breaking changes en API backend | Media | Alto | Versionado de API + contract tests |

---

## Decisiones Abiertas

1. State management: Mantener Provider o migrar a Riverpod?
2. Autenticacion: JWT, API key, o sin auth (solo red local)?
3. Cache strategy: Cuanto tiempo cachear datos de Project Admin?
4. Android push: FCM (Firebase) o seguir con Telegram bridge?
5. Offline mode: Que datos persistir localmente?

---

**Ecosistema:** Project Admin
**Fase de activacion:** Phase 2
