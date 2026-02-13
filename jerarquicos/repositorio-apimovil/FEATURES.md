# Registro de Features - Repositorio-ApiMovil

**Ultima actualizacion:** 2026-02-10
**Proposito:** Indice de features/fixes trabajados. Cada feature tiene su carpeta con documentacion completa.

---

## Indice de Features

| ID Historia | Nombre | Estado | Carpeta |
|-------------|--------|--------|---------|
| 179610, 178134 | Comprobantes Electronicos | Completado | [Ver detalle](features/179610_178134_comprobantes_electronicos/) |
| - | Reemplazo llamadas legacy reportes | En Progreso | [Ver detalle](features/reemplazo_llamadas_legacy_reportes/) |

---

## Estructura de Carpetas

```
features/
└── [id]_[nombre]/
    ├── README.md           # Descripcion, endpoints, ramas, archivos clave
    ├── response_*.json     # Ejemplos de respuestas
    └── [otros recursos]    # Postman collections, scripts, etc.
```

---

## Como Agregar una Nueva Feature

1. Crear carpeta: `features/[id_historia]_[nombre_corto]/`
2. Crear `README.md` con el template (ver abajo)
3. Agregar ejemplos de response en archivos `.json`
4. Actualizar este indice

---

## Template para Nueva Feature

Crear `features/[id]_[nombre]/README.md`:

```markdown
# Feature: [Nombre de la Feature]

**Historias:** [IDs separados por coma]
**Estado:** Pendiente / En Progreso / Completado / En Review
**Fecha trabajo:** [Mes Año]

---

## Descripcion

[Descripcion breve de la feature]

---

## Endpoints Implementados

| Metodo | Ruta | Descripcion | Historia |
|--------|------|-------------|----------|
| [GET/POST/PUT/DELETE] | [ruta] | [descripcion] | [id] |

---

## Ramas Git

| Historia | Rama | Proposito |
|----------|------|-----------|
| [id] | `[nombre-rama]` | [descripcion] |

---

## Archivos Clave

### Controllers
- `[ruta]`

### DTOs
- `[ruta]`

### Services
- `[ruta]`

---

## Estructura de Respuesta

[Ejemplo JSON con explicacion de campos]

---

## Notas Tecnicas

- [Nota 1]
- [Nota 2]
```

---

## Historico de Actualizaciones

| Fecha | Accion | Feature |
|-------|--------|---------|
| 2026-01-27 | Reorganizacion a carpetas | - |
| 2026-01-27 | Documentacion inicial | Comprobantes Electronicos |
| 2026-02-10 | Documentacion inicial | Reemplazo llamadas legacy reportes |
