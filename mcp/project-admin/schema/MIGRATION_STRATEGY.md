# Migration Strategy - Project Admin

## Versionado

Cada migration es un archivo SQL en `src/db/migrations/` con prefijo numerico:
```
001_initial_schema.sql
002_seed_data.sql
003_add_column_xyz.sql
```

Los archivos de diseño viven en `claude_context/.../schema/` durante planificacion.
Al implementar, el Backend Developer los copia a `src/db/migrations/`.

## Tabla de Control

`schema_migrations` registra que migraciones fueron aplicadas. Cada archivo SQL
termina con un INSERT a esta tabla. El runner solo ejecuta archivos cuya version
no exista en la tabla.

## Runner (migrate.js)

```javascript
// Pseudocodigo del runner
const files = glob('src/db/migrations/*.sql').sort();
for (const file of files) {
  const version = file.match(/^(\d+)_/)[1];
  const applied = await db.query(
    'SELECT 1 FROM schema_migrations WHERE version = $1', [version]
  );
  if (!applied.rows.length) {
    await db.query(readFileSync(file, 'utf8'));
    // El propio SQL inserta en schema_migrations
  }
}
```

## Idempotencia

Toda migration usa `IF NOT EXISTS`, `ON CONFLICT DO NOTHING` o `DO UPDATE`.
Re-ejecutar una migration ya aplicada no produce errores ni cambios.

## Reversibilidad

Para cada `NNN_forward.sql` se puede crear un `NNN_rollback.sql` opcional.
El rollback no se ejecuta automaticamente; es un script manual para emergencias.
Ejemplo:
```
001_rollback.sql  -> DROP TABLE IF EXISTS projects CASCADE; etc.
```

## Ejecucion

```bash
npm run migrate        # Aplica migraciones pendientes
npm run migrate:status # Muestra versiones aplicadas
npm run seed           # Alias para ejecutar solo 002_seed_data (idempotente)
```

## Reglas

1. Nunca modificar una migration ya aplicada en produccion. Crear una nueva.
2. Toda migration debe ser idempotente.
3. Toda migration registra su version en `schema_migrations` al final.
4. Nombres descriptivos: `003_add_project_priority_column.sql`.
5. El checksum en `schema_migrations` es opcional; sirve para detectar drift.
