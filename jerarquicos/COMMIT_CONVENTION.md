# Convencion de Commits - Jerarquicos

**Basada en:** Conventional Commits 1.0 (adaptada)
**Autor:** Esteban Odetti
**Ultima actualizacion:** 2026-03-02

---

## Formato

```
#nroHistoria <tipo>[alcance]: descripcion
```

## Tipos Permitidos

| Tipo | Significado |
|------|-------------|
| F | Nueva funcionalidad |
| B | Correccion de errores |
| H | Correccion urgente en produccion (hotfix) |
| D | Documentacion |
| R | Refactorizacion |
| P | Rendimiento |
| Bu | Compilacion |
| M | Mantenimiento |
| S | Estilo |
| Re | Reversion |

## Ejemplos

```
#1234 f(sync): se agrega detalle de articulos
#54321 b(user): corrige limpieza de combo roles
#98781 h(login rowa): no tomaba caracteres especiales en el campo contrasena
```

## Buenas Practicas

- Ser claros y especificos
- Evitar mensajes genericos
- Asociar historias cuando sea posible
- Revisar antes de confirmar
- Minuscula para el tipo
- Alcance entre parentesis indica modulo/componente afectado

---

## Nombrado de Ramas

### Formato

```
<tipo>/<nroHistoria>_<descripcion_breve>
```

### Tipos de rama

| Tipo | Uso | Base | Merge a |
|------|-----|------|---------|
| `feature` | Nueva funcionalidad | `develop` o `staging` | `develop` o `staging` |
| `hotfix` | Correccion urgente en produccion | `staging` o `main` | `staging` o `main` |
| `bugfix` | Correccion de errores no urgentes | `develop` | `develop` |
| `release` | Preparacion de release | `develop` | `staging` / `main` |

### Reglas

- Numero de historia siempre presente (salvo ramas tecnicas sin historia)
- Descripcion en minusculas, separada por guiones bajos (`_`)
- Sin caracteres especiales: no usar ñ, acentos, `#`, espacios
- Descripcion breve pero descriptiva (3-5 palabras maximo)
- En ingles o espanol, pero consistente dentro del proyecto

### Ejemplos

```
feature/185688_reemplazo_dao_x_apilocalizacion
feature/158979_grabar_idcotizacion_expediente
hotfix/184768_corregir_derivar_expediente
bugfix/90464_error_bandeja_ingresos
release/v4
```

### Evitar

```
feature/nueva_funcionalidad          # Sin numero de historia
feature/185688                       # Sin descripcion
feature/185688_Modificación_del_proceso_actual_para_la_búsqueda_en_bandejas  # Acentos, muy largo
feature/#75766-RegularizarCambios    # Caracter especial #, mezcla guion con underscore
```

---

## Documentos Relacionados

- [DEVELOPMENT_BEST_PRACTICES.md](DEVELOPMENT_BEST_PRACTICES.md) - Buenas practicas de desarrollo
- [API_ERROR_CODES.md](API_ERROR_CODES.md) - Catalogo de codigos de error de APIs
- [API_STANDARDS.md](API_STANDARDS.md) - Estandares y buenas practicas de APIs REST
