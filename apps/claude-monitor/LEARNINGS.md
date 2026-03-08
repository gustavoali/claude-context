# Learnings - Claude Code Monitor Flutter

**Proyecto:** Claude Code Monitor (Flutter)
**Inicio:** 2026-02-01

---

## Patrones y Decisiones Tecnicas

Este documento registra patrones descubiertos, decisiones arquitectonicas y learnings durante el desarrollo.

---

## 2026-02-01 - Setup Inicial

### LEARNING: Delegacion con Contexto Insuficiente

**Problema:** Al delegar CCM-001 al agente flutter-developer, no se incluyó:
- Los nombres exactos de los modelos (Session, TokenUsage, DashboardState)
- El mecanismo de persistencia (lee `~/.claude/dashboard-state.json`)
- El contenido de ARCHITECTURE.md

**Resultado:** El agente creó una arquitectura válida pero diferente:
- `SubprocessInfo` en lugar de `Session`
- `ConversationService` en lugar de `StateFileService`
- Enfoque de detección de procesos en lugar de lectura de JSON

**Solucion:** Al delegar, SIEMPRE incluir:
1. Nombres exactos de clases/archivos
2. Contexto arquitectónico completo
3. Schemas de datos
4. Contenido de docs de referencia (no solo mencionar)

**Accion:** Documentado en `metodologia_general/18-claude-coordinator-role.md` v1.1

---

### Decision: State Management con Provider
**Razon:**
- Simplicidad y comunidad grande
- Integración nativa con Flutter
- Suficiente para el scope de la app (polling-based, no reactive streams complejos)

### Decision: Arquitectura MVVM
**Razon:**
- Separacion clara de concerns
- Replicar patron de la app Swift original
- Testeable (ViewModels pueden ser unit tested sin UI)

### Decision: Polling cada 3 segundos
**Razon:**
- Suficiente para mostrar estado en tiempo "casi real"
- Bajo overhead (solo lee archivo si cambio)
- No requiere WebSockets ni complejidad adicional

---

## Patrones a Aplicar

### Pattern: File Change Detection
```dart
// Optimizacion: solo leer archivo si modification date cambio
DateTime? _lastModified;

bool hasFileChanged(File file) {
  final currentModified = file.lastModifiedSync();
  if (_lastModified == null || currentModified != _lastModified) {
    _lastModified = currentModified;
    return true;
  }
  return false;
}
```

### Pattern: Staleness Cleanup
```dart
// Remover sesiones antiguas automaticamente
bool isStale(Session session) {
  final now = DateTime.now();

  // Sesion terminada hace >5 min
  if (session.status == SessionStatus.ended || session.status == SessionStatus.idle) {
    return now.difference(session.updatedAt).inMinutes > 5;
  }

  // Cualquier sesion >24 horas
  return now.difference(session.updatedAt).inHours > 24;
}
```

---

## Decisiones Pendientes

- [ ] Como implementar system tray en Android? (usar notification en su lugar)
- [ ] Terminal activation: como detectar terminales en cada plataforma?
- [ ] UI: Material Design o custom para replicar look macOS?

---

## Referencias

- App Swift original: `C:/apps/claude-code-monitor/claude-code-monitor-swift/`
- Analisis completo: Ver session donde se analizo la app Swift
