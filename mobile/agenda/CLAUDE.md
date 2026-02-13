# Agenda - Organizador de Tiempo Personal

## Descripcion del Proyecto
Aplicacion movil desarrollada en Flutter para organizar tiempo entre proyectos personales, desarrollo de ideas, esparcimiento e investigacion. Permite asignar tiempo disponible a diferentes items y registrar el tiempo invertido.

## Stack Tecnologico
- **Framework:** Flutter 3.38.5
- **Lenguaje:** Dart 3.10.4
- **State Management:** flutter_bloc
- **Persistencia Local:** Hive
- **Notificaciones:** flutter_local_notifications
- **DI:** get_it
- **Arquitectura:** Clean Architecture

## Estructura del Proyecto
```
lib/
├── core/
│   ├── di/                 # Dependency Injection (get_it)
│   ├── theme/              # App theme configuration
│   ├── constants/          # App constants
│   ├── utils/              # Utility functions
│   └── widgets/            # Shared widgets
│
├── features/
│   ├── items/              # Proyectos, ideas, tareas
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/   # ItemEntity
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── bloc/       # ItemBloc
│   │       ├── pages/      # ItemListPage, AddItemPage
│   │       └── widgets/    # ItemCard
│   │
│   ├── time_tracking/      # Registro de tiempo
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/   # TimeEntryEntity
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── bloc/       # TimerBloc
│   │       └── widgets/    # ActiveTimerWidget
│   │
│   └── categories/         # Categorias de items
│       ├── data/models/
│       └── domain/entities/ # CategoryEntity
│
└── config/
    └── routes/
```

## Entidades Principales

### ItemEntity
- **Tipos:** Proyecto, Idea, Tarea, Nota
- **Estados:** Activo, Pausado, Completado, Archivado
- **Tiempo:** timeBudgetMinutes (asignado), timeSpentMinutes (invertido)
- **Organizacion:** categoryId, tags, parentId (jerarquia)

### TimeEntryEntity
- Registro de sesiones de trabajo
- Soporte para timer (inicio/fin) o entrada manual
- Asociado a un ItemEntity

### CategoryEntity
- Categorias predefinidas: Desarrollo, Ideas, Investigacion, Personal, Esparcimiento, Aprendizaje
- Color e icono personalizables

## Features Implementadas
- [x] Lista de items con filtros por categoria/estado
- [x] Crear/Editar/Eliminar items (proyectos, ideas, tareas)
- [x] Asignar tiempo presupuestado a cada item
- [x] Registrar tiempo invertido manualmente
- [x] Categorias con colores (6 predefinidas)
- [x] Prioridad (Alta/Media/Baja)
- [x] Barra de progreso tiempo invertido vs asignado
- [x] Estadisticas generales (items activos, completados, tiempo total)
- [x] Busqueda de items
- [x] Persistencia local con Hive
- [x] UI moderna con Material Design 3
- [x] Timer en tiempo real (iniciar/detener sesion)
- [x] Widget de timer activo persistente en pantalla principal
- [x] Cambio de timer entre items con confirmacion

## Features Pendientes
- [ ] Historial de sesiones de trabajo (TimeEntry)
- [ ] Estadisticas detalladas por categoria
- [ ] Vista de calendario/agenda
- [ ] Notificaciones/Recordatorios
- [ ] Tema oscuro
- [ ] Subtareas para proyectos
- [ ] Exportar datos

## Comandos Frecuentes
```bash
# Ejecutar app
flutter run

# Analizar codigo
flutter analyze

# Ejecutar tests
flutter test

# Build Android APK
flutter build apk
```

## Convenciones de Codigo
- Clean Architecture con separacion clara de capas
- BLoC pattern para state management
- Nombres en ingles para codigo
- Tests unitarios para domain layer

## Documentacion Relacionada
@C:/claude_context/mobile/agenda/README.md
