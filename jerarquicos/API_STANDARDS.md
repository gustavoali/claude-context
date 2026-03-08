# Estandares y Buenas Practicas de APIs REST - Jerarquicos

**Fuente:** Documento "Estandares-buenas-practicas-APIs.docx" del equipo
**Aplica a:** Todas las APIs de Jerarquicos (ApiJSMobile, ApiLocalizacion, ApiCalculadora, etc.)
**Ultima actualizacion:** 2026-03-02

---

## 1. Que es una API REST

Una API REST cumple las siguientes caracteristicas:
- **Cliente-servidor:** Una parte solicita informacion, otra la proporciona
- **Sin estado (Stateless):** El resultado de una peticion no depende de peticiones anteriores. El cliente proporciona todo lo necesario para su procesamiento
- **Cacheable:** Debe ser posible etiquetar una respuesta como cacheable para reusarla posteriormente
- **Interfaz uniforme:** Las URIs hacen referencia a recursos, cada recurso tiene una URI unica
- **Mensajes autodescriptivos:** Cada mensaje tiene la informacion suficiente para entender como procesarlo
- **HATEOAS:** Uso de hiperenlaces en la respuesta que apuntan hacia los recursos relacionados
- **Sistema en capas:** Cliente y servidor son agnosticos respecto a las capas intermedias

---

## 2. Diseno Orientado a Recursos

- Centrarse en las **entidades de negocio** que expone la API
- Las URIs deben basarse en **sustantivos**, no en verbos
- Las URIs deben ser **intuitivas, predecibles y faciles de comprender**
- Un recurso no tiene que corresponder a un solo elemento de datos fisico
- **No reflejar la estructura interna** de la base de datos. REST modela entidades y operaciones de negocio
- El cliente no debe exponerse a la implementacion interna

---

## 3. Metodos HTTP

| Metodo | Accion | Naming Controller | Naming Servicio | Naming Dominio | Naming Repositorio |
|--------|--------|-------------------|-----------------|----------------|--------------------|
| GET | Leer un recurso | Find | Find | Find | Find |
| POST | Crear un recurso | Add | Add | Add | Add |
| PUT | Actualizar un recurso | Update | Update | Update | Update |
| DELETE | Borrar un recurso | Remove | Remove | Remove | Remove |

---

## 4. URIs

### Reglas obligatorias

- Siempre hacer referencia a objetos **en plural** (ej: `/productos`, `/usuarios`)
- Usar **sustantivos**, nunca verbos en los endpoints (los verbos HTTP ya especifican la accion)
- Usar siempre **minusculas**
- **Evitar guiones bajos** (`_`), usar guiones (`-`) si es necesario
- **Evitar barra diagonal al final** (`/productos/` -> `/productos`)
- **No incluir extension** del tipo de recurso en la URI (`.json`, `.xml`)
- La representacion del recurso se solicita a traves de la cabecera `Accept`

### Anidamiento de recursos

- **Evitar URLs muy largas** con multiples jerarquias
- Reducir la longitud del endpoint al minimo
- El identificador debe bastar para acceder al recurso

**Incorrecto:**
```
GET /api/v1/organizaciones/5/departamentos/3/empleados/42
```

**Correcto:**
```
GET /api/v1/empleados/42
```

---

## 5. Unificacion de Endpoints

- **Unificar endpoints** que presenten una misma logica
- Unificar GETs en uno solo y pasarle por **parametros** los diferentes filtros necesarios
- A nivel de repositorio se diferencia cada logica
- Los endpoints deben retornar una **unica respuesta** en caso de exito
- Cuando distintos clientes requieran distintos DTOs pero la logica sea la misma, retornar un **unico DTO** y cada cliente adapta a sus requerimientos

---

## 6. Nombrado de DTOs

| Tipo | Nomenclatura | Ejemplo |
|------|-------------|---------|
| DTO de entrada | `{Recurso}{NombreMetodo}RequestDto` | `PersonaFindRequestDto` |
| DTO de respuesta | `{Recurso}{NombreMetodo}ResponseDto` | `PersonaFindResponseDto` |

**Nota:** `{NombreMetodo}` es opcional y deberia evitarse siempre que sea posible.

**Ejemplos simplificados:**
- `PersonaRequestDto` (entrada)
- `PersonaResponseDto` (respuesta)

---

## 7. Nombres de Metodos

- Deben ser **descriptivos** y reflejar claramente la accion que se realiza
- **No deben ser excesivamente largos**
- Buscar equilibrio entre claridad y brevedad

---

## 8. Codigos de Estado HTTP

| Codigo | Significado | Uso |
|--------|-------------|-----|
| **200** | Ok | La peticion salio bien |
| **201** | Created | Se creo el recurso solicitado |
| **202** | Accepted | Devolver mensaje en caso de no pasar validaciones de negocio (*) |
| **204** | No Content | La solicitud se completo con exito pero la respuesta es vacia |
| **400** | Bad Request | El servidor recibio una peticion mal formada |
| **401** | Unauthorized | No esta autenticado (no existe un usuario) |
| **404** | Not Found | No se encontro el recurso solicitado |
| **422** | Unprocessable | Errores de negocio |
| **500** | Internal Server Error | Error de servidor |

(*) Revisar relacion entre 202 y 422 para el manejo de errores y excepciones.

### Mensajes de error
- Deben expresarse de manera **clara y explicita**
- De ser posible, **indicar como solucionarlos**

---

## 9. Endpoints Nuevos

- Si se agrega un nuevo endpoint a una API existente, **continuar con el formato y tecnologia** que se viene utilizando
- Se puede analizar si es posible un refactor con cambio/agregado de tecnologia

---

## 10. Uso de Genericos (FindAll)

- Por norma general **NO se debe utilizar FindAll sin filtros**
- Siempre debe venir un filtro que acote la cantidad de registros
- Aplica tanto para APIs como para servicios WCF
- En servicios genericos de ServiciosJS, **verificar que nunca llegue Id=0** (hace FindAll de toda la tabla)

### Cuando NO se pueden usar
- Buscar Persona
- Buscar Comprobante
- Entidades con gran volumen de datos

### Cuando SI se podrian usar
- Buscar tipos de Almacenes (contiene solo 15 registros)
- Entidades de catalogo con pocos registros

**Regla:** Si se necesita utilizar, analizar el caso particular.

---

## 11. Checklist para APIs Nuevas

- [ ] Chequeo contra template de API
- [ ] Uso de ApiGateway configurado
- [ ] BdSession configurado
- [ ] Handler implementado
- [ ] Backend Service con configuraciones
- [ ] Configuraciones de Graylog
- [ ] Configuraciones de NewRelic

---

## Documentos Relacionados

- [DEVELOPMENT_BEST_PRACTICES.md](DEVELOPMENT_BEST_PRACTICES.md) - Buenas practicas de desarrollo
- [COMMIT_CONVENTION.md](COMMIT_CONVENTION.md) - Convencion de commits
- [API_ERROR_CODES.md](API_ERROR_CODES.md) - Catalogo de codigos de error de APIs
