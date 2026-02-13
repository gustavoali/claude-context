# Gaps de Agentes Identificados - Mew Michis

**Fecha:** 2026-01-26
**Identificado por:** Claude (Coordinador)

---

## GAP-001: Agente flutter-developer

### Descripcion
No existe un agente especializado en desarrollo Flutter/Dart en el set de agentes disponibles.

### Tarea que no se puede delegar
- Implementacion de widgets Flutter
- Logica de estado (Riverpod/Bloc/Provider)
- Integracion con SQLite en Flutter
- UI/UX especifica de Flutter
- Platform channels si se necesitan

### Por que no sirven los agentes existentes
- `frontend-react-developer`: Especializado en React/Next.js, no Dart
- `frontend-angular-developer`: Especializado en Angular, no Dart
- `typescript-developer`: TypeScript != Dart

### Impacto de no tener este agente
- Claude debera ejecutar codigo Flutter directamente (excepcion a directiva 18)
- Menor especializacion y posibles errores
- Desarrollo mas lento

### Solucion Propuesta

**Opcion A (Recomendada): Crear agente flutter-developer**

```markdown
**Agente Propuesto:** flutter-developer
**Especialidad:** Desarrollo de aplicaciones moviles con Flutter y Dart
**Tools que necesita:** Read, Write, Edit, Bash, Glob, Grep
**Prompt base sugerido:**
  "Agente especializado en desarrollo Flutter/Dart. Experto en:
   - Widgets y composicion de UI
   - State management (Riverpod, Bloc, Provider)
   - Clean Architecture en Flutter
   - Persistencia local (SQLite, Hive, SharedPreferences)
   - Testing (unit, widget, integration)
   - Platform-specific code cuando sea necesario"
**Prioridad:** Alta (proyecto actual lo requiere)
```

**Opcion B: Ejecutar directamente**
Claude ejecuta tareas de Flutter como excepcion documentada hasta que se cree el agente.

### Decision
Pendiente aprobacion del usuario.

---

## Historial

| Fecha | Gap | Decision |
|-------|-----|----------|
| 2026-01-26 | flutter-developer | Pendiente |
