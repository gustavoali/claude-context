### REC-001: Firebase.initializeApp crashea sin google-services.json

**Points:** 3 | **Priority:** CRITICO | **DoR Level:** L1
**Epic:** EPIC-001 - Estabilizacion y Firebase Condicional

**As a** usuario de Recetario
**I want** que la app inicie correctamente sin configuracion de Firebase
**So that** pueda usar todas las funcionalidades locales (CRUD, busqueda, favoritos) sin necesidad de tener Firebase configurado

#### Acceptance Criteria

**AC1: App inicia sin google-services.json**
- Given que el archivo google-services.json no existe en el proyecto
- When la app se ejecuta con `flutter run`
- Then la app inicia correctamente y muestra la pantalla principal de recetas
- And no se produce ningun crash ni excepcion no manejada

**AC2: App inicia con google-services.json presente**
- Given que el archivo google-services.json esta correctamente configurado
- When la app se ejecuta con `flutter run`
- Then Firebase se inicializa correctamente
- And las funcionalidades de auth y sync estan disponibles

**AC3: Funcionalidades locales operan sin Firebase**
- Given que Firebase no esta inicializado
- When el usuario navega por la app (lista, detalle, crear, editar, buscar, favoritos)
- Then todas las funcionalidades locales operan normalmente
- And no hay errores relacionados con Firebase en los logs

**AC4: Indicador de estado de Firebase**
- Given que Firebase no esta inicializado
- When el usuario accede a secciones que requieren Firebase (sync, auth)
- Then se muestra un mensaje informativo indicando que esas funciones requieren configuracion
- And no se produce un crash

#### Technical Notes

- Archivo principal afectado: `lib/main.dart`
- La llamada a `Firebase.initializeApp()` debe ser condicional
- Usar try-catch o verificar existencia de configuracion antes de inicializar
- Considerar un flag booleano global `isFirebaseAvailable` para que otros servicios lo consulten
- No eliminar el codigo de Firebase, solo hacerlo condicional (directiva de extension sin eliminacion)

#### DoD

- [ ] Codigo implementado
- [ ] Tests escritos (verificar inicio con y sin Firebase)
- [ ] Manual testing completado en emulador sin google-services.json
- [ ] Manual testing completado con google-services.json (si disponible)
- [ ] Build 0 warnings
- [ ] `flutter analyze` sin issues
