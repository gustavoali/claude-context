# Spoti-Admin - Configuracion de Claude Code

## Descripcion del Proyecto
App Flutter para Android que accede a las canciones favoritas de Spotify y las clasifica por multiples parametros (audio features, genero, artista, mood).

## Stack Tecnologico
- **Framework:** Flutter 3.x
- **State Management:** Riverpod
- **HTTP Client:** Dio
- **Auth:** OAuth 2.0 PKCE
- **Storage:** flutter_secure_storage (tokens), Hive (cache)
- **API:** Spotify Web API

## Estructura del Proyecto
```
lib/
├── main.dart
├── core/           # Config, constants, theme
├── data/           # Models, repositories, services
├── domain/         # Entities, usecases
├── presentation/   # Providers, screens, widgets
└── utils/          # Helpers (mood calculator, etc.)
```

## Comandos Frecuentes
```bash
# Run app
flutter run

# Build APK
flutter build apk

# Run tests
flutter test

# Generate Hive adapters
flutter pub run build_runner build
```

## URLs y Endpoints
- **Spotify API Base:** https://api.spotify.com/v1
- **Auth URL:** https://accounts.spotify.com/authorize
- **Token URL:** https://accounts.spotify.com/api/token

## Scopes de Spotify
- `user-library-read` - Leer liked songs
- `user-read-private` - Info del perfil
- `user-read-playback-state` - Estado de reproduccion
- `streaming` - Playback integrado (Premium)

## Convenciones
- Usar Riverpod para state management
- Modelos inmutables con copyWith
- Manejo de errores con Either o Result pattern
- Nombres en ingles para codigo, espanol para UI

## Features Principales
1. **Autenticacion:** OAuth 2.0 PKCE sin backend
2. **Liked Songs:** Fetch paginado con cache local
3. **Audio Features:** Batch fetch de caracteristicas
4. **Clasificacion:** Por mood, energy, tempo, etc.
5. **Filtros:** Sliders y chips configurables
6. **Playback:** 3 modos (none, open Spotify, integrated)

## Documentacion Relacionada
- Plan de implementacion: ~/.claude/plans/starry-baking-rivest.md
