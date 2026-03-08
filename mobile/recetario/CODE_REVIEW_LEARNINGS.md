# Code Review Learnings - Recetario

**Version:** 1.0
**Ultima actualizacion:** 2026-02-13

---

## Reglas del Proyecto

### R001: Patron estandar para features opcionales/condicionales

Toda feature que pueda estar ausente (dependencia externa no configurada, feature flag, etc.) debe seguir este patron:

1. `Provider<bool>` flag en `core/di/providers.dart` (default: deshabilitado)
2. Override en `ProviderScope` de `main.dart` segun resultado de inicializacion
3. Providers de servicio retornan `null` si feature deshabilitada (`Provider<Service?>`)
4. StateNotifiers aceptan service nullable y hacen guard con early return en cada accion
5. Screens verifican el flag PRIMERO en `build()` y muestran vista de fallback informativa

**Ejemplo:** `isFirebaseAvailableProvider` + auth/sync providers nullable.

**Razon:** Evita crashes por dependencias no configuradas y mantiene un unico patron predecible en todo el proyecto.

---

### R002: Resolver issues conocidos al modificar un archivo

Si un archivo se modifica como parte de un EPIC o story, revisar el backlog por issues pendientes en ese mismo archivo y resolverlos en conjunto.

**Razon:** Evita tocar el mismo archivo multiples veces en commits separados. Reduce churn y aprovecha que el contexto del archivo ya esta cargado.

**Excepcion:** Si el fix del issue pendiente es complejo (>3pts) o no relacionado, crear story separada.
