# Recetario - Learnings

**Ultima actualizacion:** 2026-02-13

## Patrones Aprendidos

### Parser de Recetas
- JSON-LD Schema.org es el estandar mas confiable para parsear recetas de sitios web
- Muchos sitios argentinos (El Destape, etc.) no usan JSON-LD ni clases CSS estandar
- Los sitios usan headings (h2/h3) con texto como "Ingredientes", "Pasos a seguir", "Preparacion" como separadores de secciones
- Se necesita un fallback por headings con sinonimos en espanol e ingles
- HowToSection de Schema.org es un wrapper que muchos parsers ignoran

### Firebase en Flutter
- Firebase.initializeApp() sin google-services.json crashea la app completa
- Las dependencias de Firebase deben ser condicionales para que el MVP local funcione sin Firebase
- Los providers que dependen de Firebase deben inicializarse condicionalmente

### Drift (SQLite)
- Los archivos .g.dart son necesarios y deben commitearse
- La busqueda con LIKE sobre JSON serializado tiene problemas de precision (buscar "sal" matchea "salsa")

## Decisiones Tomadas

| Fecha | Decision | Razon |
|-------|----------|-------|
| 2026-02-13 | Repo en github.com/gustavoali/recetario | Cuenta gh autenticada es gustavoali |
| 2026-02-13 | Branch principal: master | Default de git init |
