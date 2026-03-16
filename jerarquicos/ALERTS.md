# Alertas - Jerarquicos
**Ultima revision:** 2026-03-13

## Alertas Activas
| Fecha | Proyecto | Tipo | Mensaje | Accion |
|-------|----------|------|---------|--------|
| 2026-02-25 | FuturosSociosApi (feature/185688) | code-review | C1: catch en ApiLocalizacionClient silencia errores sin setear `response.Success = false`. C2: ObtenerOpcionesGenerales sin early return en errores, setea `Exito = true` sobreescribiendo fallos. | Resolver C1 y C2 antes de PR a develop |
| 2026-02-25 | FuturosSociosApi (feature/185688) | pendiente | PR a develop bloqueado por fixes de code review | Hacer PR despues de resolver C1 y C2 |
| 2026-02-14 | APIJsMobile (feature/176505) | pendiente | Tests sin ejecutar post-merge con develop | `dotnet build --no-incremental && dotnet test` |
| 2026-02-14 | APIJsMobile (feature/176505) | pendiente | Documentacion CartillaController desactualizada: dice 4 endpoints, hay 19 implementados | Actualizar CARTILLA_IMPLEMENTATION.md y PENDING_APIPRESTADORES_ENDPOINTS.md |

## Deadlines
| Proyecto | Descripcion | Deadline | Prioridad |
|----------|-------------|----------|-----------|

## Historial
| Fecha | Proyecto | Tipo | Mensaje | Resolucion |
|-------|----------|------|---------|------------|
