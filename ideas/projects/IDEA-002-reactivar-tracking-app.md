# IDEA-002: Reactivar Tracking App

**Fecha:** 2026-02-12
**Categoria:** projects
**Estado:** Seed
**Prioridad:** Media

---

## Descripcion

Retomar el desarrollo de Tracking App (C:/mobile/tracking_app), actualmente en v1.0.3 publicada. El core funciona bien (tracking GPS, mapas, export/import, deteccion de movimiento). Hay backlog pendiente con features definidas.

## Motivacion

La app esta funcional pero tiene features pendientes que mejorarian significativamente la experiencia de uso, especialmente el tracking en background y la gestion de segmentos.

## Alcance Estimado

Mediano - hay backlog definido con user stories y estimaciones.

## Proximos pasos al reactivar

1. Revisar estado del codigo y dependencias (flutter pub outdated)
2. Decidir prioridad entre los 3 bloques pendientes:
   - **Epic Segmentos** (US-16 a US-23, ~26 pts): nombrar sesiones, crear/editar segmentos
   - **Background Service** (US-24 a US-26): tracking sin tener la app en primer plano
   - **Mejoras UI**: indicador pulsante, timer, animaciones
3. Armar sprint y delegar a flutter-developer

## Proyectos Relacionados

- Tracking App: C:/mobile/tracking_app
- Contexto: C:/claude_context/mobile/tracking_app/CLAUDE.md
- Backlog de segmentos: docs/US_SEGMENT_MANAGEMENT.md (dentro del proyecto)

## Notas

- v1.0.3 fue la ultima release (2026-01-04)
- CI/CD configurado con Codemagic para builds iOS
- Stack: Flutter + Provider + SQLite + flutter_map

---

## Historial

| Fecha | Evento |
|-------|--------|
| 2026-02-12 | Recordatorio de reactivacion registrado |
