# Learnings - API Prestadores
**Actualizacion:** 2026-03-16

## Patrones del Proyecto

### Convencion de nombrado de columnas SQL
Prefijo de 3 letras por tabla: `pro_` (profesionales), `pds_` (proveedores de salud), `con_` (convenios), `loc_` (localidades), etc. PK siempre `XXX_idesec`.

### Framework interno JS.Framework
Compartido entre APIs de la organizacion. No modificar sin coordinacion cross-proyecto.

### TransactionalProxy
Patron custom que envuelve domain services en transacciones automaticas via atributo `[TransactionalAttribute]`. Isolation level: ReadUncommitted.
