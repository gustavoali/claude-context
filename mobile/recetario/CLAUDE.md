# Recetario - App de Recetas de Cocina

## Descripcion del Proyecto

App Android desarrollada con Flutter para almacenar y organizar recetas de cocina de multiples fuentes.

## Stack Tecnologico

- **Framework**: Flutter 3.38.5
- **State Management**: Riverpod
- **Local Database**: Drift (SQLite)
- **Cloud Database**: Firebase Firestore (Fase 3)
- **Auth**: Google Sign-In (Fase 3)
- **OCR**: Google ML Kit (Fase 2)

## Arquitectura

Clean Architecture con feature-based structure:

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── database/      # Drift database
│   ├── di/            # Riverpod providers
│   └── theme/         # App theme
└── features/
    └── recipes/
        ├── data/          # Repositories, DAOs, Models
        ├── domain/        # Entities, Repository interfaces
        └── presentation/  # Screens, Widgets, Providers
```

## Modelo de Datos Principal

```dart
class Recipe {
  String id;           // UUID local
  String? cloudId;     // ID en Firestore
  String title;
  String? description;
  List<String> ingredients;
  List<String> steps;
  String? imageUrl;
  int? servings;
  int? prepTimeMinutes;
  int? cookTimeMinutes;
  List<String> tags;
  String? sourceUrl;
  RecipeSource source; // manual, url, image
  SyncStatus syncStatus;
  bool isFavorite;
}
```

## Fases del Proyecto

### Fase 1: MVP Local (COMPLETADA)
- [x] Setup proyecto Flutter
- [x] Modelo de datos + Drift database
- [x] CRUD de recetas manual
- [x] UI: lista, detalle, formulario
- [x] Busqueda y favoritos

### Fase 2: Importacion (PENDIENTE)
- [ ] Import desde URL (JSON-LD parser)
- [ ] OCR con ML Kit
- [ ] Preview y edicion

### Fase 3: Auth + Sync (PENDIENTE)
- [ ] Firebase setup
- [ ] Google Sign-In
- [ ] Sync bidireccional
- [ ] Conflict resolution manual

### Fase 4: Polish (PENDIENTE)
- [ ] Categorias y tags mejorados
- [ ] Compartir recetas
- [ ] Dark mode toggle

## Comandos Frecuentes

```bash
# Desarrollo
flutter run

# Build
flutter build apk

# Generar codigo Drift
dart run build_runner build --delete-conflicting-outputs

# Analizar
flutter analyze

# Tests
flutter test
```

## Convenciones

- Usar ConfigureAwait(false) no aplica (es Dart, no .NET)
- Providers en `presentation/providers/`
- DAOs en `data/datasources/local/`
- Entities inmutables con Equatable

## Decisiones Tecnicas

1. **Riverpod sobre Bloc**: Menos boilerplate, mejor testing
2. **Drift sobre sqflite**: Type-safe, migrations, reactive streams
3. **JSON-LD primero**: Estandar Schema.org para parsear recetas
4. **Sync manual**: Mostrar conflictos al usuario para resolver
