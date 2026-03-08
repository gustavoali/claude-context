### REC-009: SyncEngine descarga TODAS las recetas en cada sync

**Points:** 3 | **Priority:** HIGH | **DoR Level:** L1
**Epic:** EPIC-004 - Sync y Performance

**As a** usuario de Recetario
**I want** que la sincronizacion solo descargue recetas nuevas o modificadas desde la ultima sync
**So that** la sincronizacion sea rapida, consuma menos datos moviles y no sobrecargue el dispositivo

#### Acceptance Criteria

**AC1: Primera sync descarga todas las recetas**
- Given que el usuario sincroniza por primera vez (no hay timestamp de ultima sync)
- When se ejecuta la sincronizacion
- Then se descargan todas las recetas del servidor
- And se guarda el timestamp de esta sincronizacion

**AC2: Syncs subsiguientes son incrementales**
- Given que ya se realizo una sincronizacion previa con timestamp guardado
- When se ejecuta una nueva sincronizacion
- Then solo se descargan recetas creadas o modificadas despues del timestamp guardado
- And se usa el metodo `downloadRecipesSince()` que ya existe en el codigo

**AC3: Sync forzado descarga todo**
- Given que el usuario fuerza una sincronizacion completa (pull-to-refresh largo o boton dedicado)
- When se ejecuta la sincronizacion forzada
- Then se descargan todas las recetas del servidor (reset del timestamp)
- And se actualiza el timestamp al completar

**AC4: Timestamp persiste entre sesiones**
- Given que el usuario cierra y reabre la app
- When se ejecuta la sincronizacion
- Then se usa el timestamp guardado de la sesion anterior
- And no se descargan recetas ya sincronizadas

#### Technical Notes

- Archivo afectado: `lib/features/sync/data/services/sync_engine.dart` (linea 44)
- El metodo `downloadRecipesSince(DateTime since)` ya existe pero no se usa
- Actualmente se llama a `downloadAllRecipes()` en cada sync
- Guardar el timestamp de ultima sync en SharedPreferences o en la base de datos Drift
- Usar el server timestamp de Firestore (no el reloj local) para evitar problemas de sincronizacion de relojes

#### DoD

- [ ] Codigo implementado usando `downloadRecipesSince()`
- [ ] Timestamp de ultima sync persistido entre sesiones
- [ ] Tests unitarios verificando sync incremental vs full
- [ ] Manual testing: sync inicial + sync incremental + sync forzado
- [ ] Build 0 warnings
