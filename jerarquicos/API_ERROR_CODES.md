# Catalogo de Codigos de Error de APIs - Jerarquicos

**Fuente:** Documento de buenas practicas del equipo
**Aplica a:** Todos los proyectos de Jerarquicos (especialmente ApiJSMobile)
**Ultima actualizacion:** 2026-03-02

---

## Formato General

```
AXX-NNN - Mensaje descriptivo
```

Donde `AXX` se reemplaza por el prefijo de la API (ej: `AFS` para ApiFuturosSocios, `ALC` para ApiLocalizacion, etc.).

---

## Codigos

### 001 - Internal Server Error (HTTP 500)

```
AXX-001 - No se pudo procesar la peticion. (AXX)
```

- Representa un error 500 (Internal Server Error)
- Cuando el error es producido por fallo de conexion con otra API, agregar entre parentesis la API interviniente

**Ejemplo:** `AFS-001 - No se pudo procesar la peticion. (ApiLocalizacion)`

---

### 002 - Bad Request generico (HTTP 400)

```
AXX-002 - Se produjo un error en la solicitud.
```

- Representa errores 400 (Bad Request)
- Respuesta generica de "bad request"

---

### 003 - Not Found (HTTP 404)

```
AXX-003 - No se encontro el elemento solicitado.
```

- Representa errores 404 (Not Found)
- Respuesta generica de "not found"
- Siempre que se pueda, agregar nuevo mensaje con mas informacion

---

### 004 - Errores de Validacion (HTTP 400)

```
AXX-004 - Origen: {PropertyName} - Mensaje: [mensaje de validacion]
```

- Representa errores 400 (Bad Request) de validacion de datos
- Producidos generalmente por **FluentValidation**
- Usar placeholders de FluentValidation en los mensajes

#### Placeholders disponibles

| Placeholder | Descripcion |
|-------------|-------------|
| `{PropertyName}` | Nombre de la propiedad |
| `{PropertyValue}` | Valor de la propiedad |
| `{ComparisonValue}` | Valor de comparacion |
| `{FormattedComparisonValue}` | Valor de comparacion formateado |
| `{MinLength}` | Longitud minima |
| `{MaxLength}` | Longitud maxima |
| `{Length}` | Longitud actual |
| `{TotalLength}` | Longitud total ingresada |
| `{CollectionIndex}` | Indice en coleccion |
| `{Digits}` | Total de digitos |
| `{IntegerDigits}` | Digitos enteros |
| `{FractionalDigits}` | Digitos decimales |

#### Mensajes de validacion estandar

| Tipo | Mensaje |
|------|---------|
| Dato invalido | `AXX-004 - Origen: {PropertyName} - Mensaje: Dato invalido.` |
| Obligatorio | `AXX-004 - Origen: {PropertyName} - Mensaje: Dato obligatorio.` |
| Codigo practica | `AXX-004 - Origen: {PropertyName} - Mensaje: Debe ingresar al menos un codigo practica.` |
| Mayor o igual | `AXX-004 - Origen: {PropertyName} - Mensaje: Debe ser mayor o igual que {ComparisonValue}.` |
| Mayor que | `AXX-004 - Origen: {PropertyName} - Mensaje: Debe ser mayor que {ComparisonValue}.` |
| Longitud maxima | `AXX-004 - Origen: {PropertyName} - Mensaje: La longitud ingresada es de {TotalLength} caracteres y debe ser menor o igual que {MaxLength} caracteres.` |

---

## Reglas de Uso

1. **Siempre usar el codigo estandar** correspondiente al tipo de error
2. **No inventar codigos nuevos** sin documentarlos aca
3. **No exponer detalles internos** (connection strings, stack traces) en los mensajes al cliente
4. **Agregar contexto** cuando sea posible (ej: que API fallo en un 001)
5. **Validaciones con FluentValidation** deben usar los placeholders estandar para consistencia

---

## Documentos Relacionados

- [COMMIT_CONVENTION.md](COMMIT_CONVENTION.md) - Convencion de commits
- [DEVELOPMENT_BEST_PRACTICES.md](DEVELOPMENT_BEST_PRACTICES.md) - Buenas practicas de desarrollo
- [API_STANDARDS.md](API_STANDARDS.md) - Estandares y buenas practicas de APIs REST
