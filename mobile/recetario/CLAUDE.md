# Recetario - App de Recetas de Cocina

## Documentacion
@C:/claude_context/mobile/recetario/LEARNINGS.md
@C:/claude_context/mobile/recetario/TASK_STATE.md
@C:/claude_context/mobile/recetario/PRODUCT_BACKLOG.md

## Descripcion del Proyecto

App Android desarrollada con Flutter para almacenar y organizar recetas de cocina de multiples fuentes.

## Repositorio

- **GitHub:** https://github.com/gustavoali/recetario
- **Branch principal:** master
- **Version actual:** 0.9.0+1

## Stack Tecnologico

- **Framework**: Flutter 3.38.5
- **State Management**: Riverpod
- **Local Database**: Drift (SQLite)
- **Cloud Database**: Firebase Firestore (Fase 3 - no configurado)
- **Auth**: Google Sign-In (Fase 3 - no configurado)
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
    ├── recipes/
    │   ├── data/          # Repositories, DAOs, Models
    │   ├── domain/        # Entities, Repository interfaces
    │   └── presentation/  # Screens, Widgets, Providers
    ├── import/
    │   ├── url_import/    # RecipeParser (JSON-LD, microdata, heuristic)
    │   ├── image_import/  # OcrService (ML Kit)
    │   └── presentation/  # Import screens + providers
    ├── auth/
    │   ├── data/          # AuthService (Google Sign-In + Firebase)
    │   ├── domain/        # AppUser entity
    │   └── presentation/  # ProfileScreen + providers
    └── sync/
        ├── data/          # SyncService + SyncEngine (Firestore)
        └── presentation/  # ConflictResolutionScreen + providers
```

## Estado del Proyecto

### Fase 1: MVP Local (COMPLETADA)
- [x] Setup proyecto Flutter
- [x] Modelo de datos + Drift database (schema v1)
- [x] CRUD de recetas manual
- [x] UI: lista, detalle, formulario
- [x] Busqueda y favoritos

### Fase 2: Importacion (CODIGO EXISTE - SIN VALIDAR)
- [x] Import desde URL (RecipeParser: JSON-LD > microdata > CSS heuristic)
- [x] OCR con ML Kit (OcrService)
- [x] Preview y edicion (RecipePreviewScreen)
- [ ] Fallback por headings (REC-003 - bug conocido)
- [ ] Tests del parser y OCR (REC-006)

### Fase 3: Auth + Sync (CODIGO EXISTE - FIREBASE NO CONFIGURADO)
- [x] AuthService (Google Sign-In)
- [x] SyncService + SyncEngine (Firestore, conflict resolution)
- [x] ProfileScreen, ConflictResolutionScreen
- [ ] Firebase setup (google-services.json) - **BLOQUEANTE: REC-001/REC-002**
- [ ] Inicializacion condicional de Firebase

### Fase 4: Polish (PENDIENTE)
- [x] Dark mode (system mode)
- [ ] Dark mode toggle manual (REC-019)
- [ ] Categorias y tags mejorados (REC-023)
- [ ] Compartir recetas (REC-024)

## Bloqueantes Criticos

1. **REC-001/REC-002:** `Firebase.initializeApp()` en `main.dart` crashea la app sin `google-services.json`. Necesita inicializacion condicional.

## Backlog

- **Total stories:** 29
- **Total story points:** 108
- **Criticos:** 2 (8pts) - Firebase condicional
- **High:** 8 (31pts) - Parser, tests, seguridad
- **Medium:** 12 (27pts) - UX/UI, calidad de codigo
- **Low:** 7 (42pts) - Features nuevas

Ver detalle en PRODUCT_BACKLOG.md

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

- Providers en `presentation/providers/`
- DAOs en `data/datasources/local/`
- Entities inmutables con Equatable
- UI en espanol argentino
- Codigo y nombres tecnicos en ingles

## Decisiones Tecnicas

1. **Riverpod sobre Bloc**: Menos boilerplate, mejor testing
2. **Drift sobre sqflite**: Type-safe, migrations, reactive streams
3. **JSON-LD primero**: Estandar Schema.org para parsear recetas
4. **Sync manual**: Mostrar conflictos al usuario para resolver
5. **Firebase condicional**: Firebase debe ser opcional para que el MVP local funcione sin configuracion
