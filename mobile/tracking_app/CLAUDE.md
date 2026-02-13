# Tracking App - Flutter GPS Tracking Application

## Descripcion del Proyecto

Aplicacion movil personal de tracking de ubicacion desarrollada en Flutter. Permite registrar recorridos GPS de forma controlada con sesiones manuales.

## Stack Tecnologico

- **Framework:** Flutter (Dart)
- **State Management:** Provider
- **GPS:** Geolocator package
- **Persistencia:** SQLite (sqflite)
- **Mapas:** flutter_map + OpenStreetMap
- **Export/Import:** share_plus, path_provider, file_picker
- **Plataforma target:** Android e iOS
- **CI/CD:** Codemagic (para builds iOS sin Mac)

## Estructura del Proyecto

```
lib/
├── core/
│   ├── constants/      # Constantes de la app
│   ├── database/       # DatabaseService (SQLite)
│   ├── theme/          # Configuracion de tema
│   └── utils/          # Utilidades (date_utils, etc.)
├── features/
│   └── tracking/
│       ├── data/
│       │   ├── models/       # TrackingSession, LocationPoint, MovementState
│       │   ├── repositories/ # SessionRepository, LocationPointRepository
│       │   └── services/     # LocationService, ExportService, ImportService, MovementDetector
│       └── presentation/
│           ├── providers/    # TrackingProvider
│           ├── screens/      # TrackingScreen, HistoryScreen, SessionDetailScreen
│           └── widgets/      # TrackingControls, SessionInfoCard, RouteMap
├── services/
│   └── permissions/    # PermissionService
├── app.dart
└── main.dart

ios/
├── Runner/
│   ├── Info.plist      # Permisos iOS (ubicacion, background, file sharing)
│   └── Assets.xcassets/
├── Podfile             # Dependencias CocoaPods
└── Runner.xcworkspace

docs/
└── iOS_BUILD_GUIDE.md  # Guia completa para build iOS

codemagic.yaml          # Configuracion CI/CD para builds automaticos
```

## Comandos Frecuentes

### Android

```bash
# Ejecutar en emulador
flutter run -d emulator-5554

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# Verificar entorno
flutter doctor

# Listar dispositivos
flutter devices
```

### iOS (requiere Mac o Codemagic)

```bash
# Instalar dependencias iOS
cd ios && pod install && cd ..

# Build iOS sin firmar (para AltStore)
flutter build ios --release --no-codesign

# Build iOS firmado (para TestFlight)
flutter build ipa --release
```

## Roadmap (User Stories)

### Completadas
- US-01: Crear proyecto Flutter base
- US-02: Estructura inicial del proyecto
- US-03: Iniciar sesion de tracking
- US-04: Pausar y detener sesion
- US-05: Solicitar permisos de ubicacion
- US-06: Registrar puntos GPS
- US-07: Guardar sesiones en SQLite
- US-08: Mostrar recorrido en mapa (flutter_map + OpenStreetMap)
- US-09: Detectar estado de movimiento con histeresis
- US-10: Exportar recorrido (GPX/JSON con share)
- US-11: Pantalla de historial de sesiones
- US-12: Detalle de sesion con mapa y estadisticas
- US-13: Eliminar sesion del historial
- US-14: Importar recorridos desde archivo GPX/JSON
- US-15: Preparar proyecto para iOS (Info.plist, Podfile, Codemagic)

### Pendientes - Gestion de Segmentos (Epic)
- US-16: Nombrar sesiones de tracking (2 pts)
- US-17: Modelo de datos para segmentos (3 pts)
- US-18: Pantalla editor de segmentos (5 pts)
- US-19: Seleccion de segmento por tap en mapa (5 pts)
- US-20: Seleccion de segmento por rango de tiempo (3 pts)
- US-21: Guardar y gestionar segmentos (3 pts)
- US-22: Estadisticas de segmento (2 pts)
- US-23: Exportar sesion con segmentos (3 pts)
Ver: `docs/US_SEGMENT_MANAGEMENT.md`

### Pendientes - Background Service
- US-24: Implementar foreground service para tracking en background
- US-25: Notificacion persistente durante tracking
- US-26: Auto-resume de sesion tras reinicio de app

### Pendientes - Mejoras de UI
- Indicador pulsante/animado cuando graba
- Timer en tiempo real
- FAB circular para iniciar
- Cards con gradientes
- Pantalla inicial mas atractiva
- Animaciones de transicion

## Notas Tecnicas

### Permisos Android (AndroidManifest.xml)
- INTERNET (para map tiles)
- ACCESS_FINE_LOCATION
- ACCESS_COARSE_LOCATION
- ACCESS_BACKGROUND_LOCATION
- FOREGROUND_SERVICE
- FOREGROUND_SERVICE_LOCATION
- WAKE_LOCK

### Permisos iOS (Info.plist)
- NSLocationWhenInUseUsageDescription
- NSLocationAlwaysAndWhenInUseUsageDescription
- NSLocationAlwaysUsageDescription
- UIBackgroundModes: location
- UIFileSharingEnabled (para import/export GPX)

### Filtrado de Puntos GPS
- Se filtran puntos con accuracy > minAccuracyMeters (configurable)
- Distancia minima entre puntos configurable

### Deteccion de Movimiento (MovementDetector)
- Promedio de velocidad con buffer de 5 muestras
- Requiere 3 muestras consecutivas para cambiar estado
- Histeresis de 0.3 m/s en los limites
- Umbrales:
  - Estacionario: < 0.5 m/s
  - Caminando: 0.5 - 2.0 m/s
  - Vehiculo: > 2.0 m/s

### Exportacion (ExportService)
- Formato GPX: Compatible con aplicaciones de mapas
- Formato JSON: Incluye estadisticas y puntos detallados
- Share: Usa share_plus para compartir archivo externamente

### Importacion (ImportService)
- Soporta archivos GPX y JSON generados por la app
- Preview antes de confirmar importacion
- Genera nuevos IDs para evitar conflictos
- Parseo de GPX con regex (lat, lon, ele, time, speed)

## Build iOS sin Mac

### Opcion 1: Codemagic (Recomendado)
1. Subir proyecto a GitHub
2. Conectar con Codemagic.io
3. Ejecutar workflow `ios-workflow`
4. Descargar IPA de artifacts

### Opcion 2: AltStore (para instalar en iPhone)
1. Descargar AltServer en Windows
2. Conectar iPhone por USB
3. Instalar AltStore en iPhone
4. Cargar el IPA desde AltStore
5. Renovar cada 7 dias

Ver `docs/iOS_BUILD_GUIDE.md` para instrucciones detalladas.

## Versiones Publicadas

| Version | Fecha | Cambios |
|---------|-------|---------|
| 1.0.0 | 2025-12-30 | Primera release con tracking, mapas, export |
| 1.0.1 | 2025-12-30 | Agregada importacion de archivos GPX/JSON |
| 1.0.2 | 2025-12-30 | Fix: Agregado permiso INTERNET para map tiles |
| 1.0.3 | 2026-01-04 | Auto-guardado periodico y recuperacion de sesiones interrumpidas |

## Referencias

- Backlog completo: `Tracking_App_User_Stories.pdf`
- Guia iOS: `docs/iOS_BUILD_GUIDE.md`
