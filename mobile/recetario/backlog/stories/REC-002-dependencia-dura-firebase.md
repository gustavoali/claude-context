### REC-002: Dependencia dura de Firebase bloquea build/run sin configuracion

**Points:** 5 | **Priority:** CRITICO | **DoR Level:** L2
**Epic:** EPIC-001 - Estabilizacion y Firebase Condicional

**As a** desarrollador de Recetario
**I want** que Firebase sea una dependencia opcional que no bloquee el build ni la ejecucion
**So that** pueda desarrollar y testear funcionalidades locales sin necesidad de configurar Firebase

#### Acceptance Criteria

**AC1: Build exitoso sin configuracion de Firebase**
- Given que no existe google-services.json en el proyecto
- When ejecuto `flutter build apk` o `flutter run`
- Then el build se completa exitosamente sin errores
- And la app se ejecuta mostrando funcionalidades locales

**AC2: Providers de auth se instancian condicionalmente**
- Given que Firebase no esta inicializado
- When la app carga los providers de autenticacion
- Then los providers de auth retornan un estado "no disponible" en lugar de crashear
- And no se llama a `FirebaseAuth.instance` sin Firebase inicializado

**AC3: Providers de sync se instancian condicionalmente**
- Given que Firebase no esta inicializado
- When la app carga los providers de sincronizacion
- Then los providers de sync retornan un estado "no disponible"
- And no se intenta acceder a Firestore sin Firebase inicializado

**AC4: Navegacion a screens de auth/sync sin crash**
- Given que Firebase no esta inicializado
- When el usuario navega a la pantalla de perfil o sincronizacion
- Then se muestra un estado placeholder indicando que auth/sync no estan configurados
- And no se produce ninguna excepcion

**AC5: Firebase funcional cuando esta configurado**
- Given que google-services.json existe y es valido
- When la app inicia y Firebase se inicializa correctamente
- Then los providers de auth y sync se instancian con FirebaseAuth.instance y Firestore
- And las funcionalidades de login, perfil y sync operan normalmente

#### Technical Notes

- Archivos afectados:
  - `pubspec.yaml` - Las dependencias de Firebase permanecen pero su uso se hace condicional
  - `lib/features/auth/data/services/auth_service.dart` - Inicializacion condicional
  - `lib/features/auth/presentation/providers/auth_provider.dart` - Estado "no disponible"
  - `lib/features/sync/data/services/sync_service.dart` - Inicializacion condicional
  - `lib/features/sync/presentation/providers/sync_provider.dart` - Estado "no disponible"
- Patron recomendado: Crear una abstraccion/interface para auth y sync services, con implementacion Firebase y implementacion NoOp/Disabled
- Reutilizar el flag `isFirebaseAvailable` de REC-001
- No eliminar imports de Firebase, hacerlos condicionales (strategy pattern)

#### DoD

- [ ] Codigo implementado con pattern strategy para auth y sync
- [ ] Tests escritos para ambos escenarios (con y sin Firebase)
- [ ] Manual testing sin google-services.json: build + run + navegacion completa
- [ ] Manual testing con google-services.json: auth y sync funcionales
- [ ] Build 0 warnings
- [ ] `flutter analyze` sin issues
- [ ] Code review aprobado
