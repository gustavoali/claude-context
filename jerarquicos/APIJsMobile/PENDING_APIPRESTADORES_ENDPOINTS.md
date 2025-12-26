# Endpoints Pendientes - ApiPrestadores

Este documento lista todos los endpoints y fuentes de datos que necesita el equipo de ApiPrestadores implementar para que `CartillaController` en `ApiJsMobile` pueda funcionar al 100%.

**Fecha de creacion:** 2025-12-03
**Autor:** Equipo ApiJsMobile
**Estado:** PENDIENTE

---

## 1. GET /api/v1/especialidades-medicas

### Proposito
Listar todas las especialidades medicas disponibles en el sistema.

### Requerido por
- `CartillaService.GetEspecialidadesMedicasAsync()`
- `CartillaController.GetEspecialidadesMedicas()`

### Referencia Legacy
El sistema legacy usaba WCF service:
```csharp
AgenteServiciosJs.Generico.Buscar(solicitud)
// Con DTO: EspecialidadMedicaCartillaPlanoDTO
```

### Especificacion del Endpoint

**URL:** `GET /api/v1/especialidades-medicas`

**Query Parameters:**
- Ninguno requerido (lista completa)

**Response 200 OK:**
```json
{
  "records": [
    {
      "id": 1,
      "codigo": "CLI",
      "descripcion": "Clinica Medica"
    },
    {
      "id": 2,
      "codigo": "PED",
      "descripcion": "Pediatria"
    },
    {
      "id": 3,
      "codigo": "CAR",
      "descripcion": "Cardiologia"
    }
  ],
  "totalCount": 150
}
```

### Data Source
- **Tabla:** `ESPECIALIDADES_MEDICAS` (ya existe en ApiPrestadores domain)
- **Campos necesarios:** Id, Codigo (si existe), Descripcion

### Prioridad
**ALTA** - Bloquea funcionalidad critica de busqueda de profesionales

---

## 2. POST /api/v1/favoritos/agregar

### Proposito
Agregar un prestador (profesional o institucion) a los favoritos del usuario.

### Requerido por
- `CartillaService.AgregarFavoritoAsync()`
- `CartillaController.AgregarFavorito()`

### Referencia Legacy
El sistema legacy usaba WCF services:
```csharp
// Para profesionales:
AgenteServiciosJs.MiCartillaProfesionalJs.GrabarFavoritoProfesional(solicitud)

// Para instituciones:
AgenteServiciosJs.MiCartillaProveedorSalud.GrabarFavoritoProveedorSalud(solicitud)
```

### Especificacion del Endpoint

**URL:** `POST /api/v1/favoritos/agregar`

**Request Body:**
```json
{
  "idPersona": 12345,
  "idPrestador": 67890,
  "tipoPrestador": "PROFESIONAL"
}
```

**Campos:**
- `idPersona` (int, required): ID de la persona que agrega el favorito
- `idPrestador` (int, required): ID del prestador (profesional o entidad de salud)
- `tipoPrestador` (string, required): Tipo de prestador
  - Valores validos: `"PROFESIONAL"`, `"ENTIDAD_SALUD"`, `"EMERGENCIA"`

**Response 200 OK:**
```json
{
  "success": true,
  "message": "Favorito agregado correctamente"
}
```

**Response 400 Bad Request:**
```json
{
  "success": false,
  "errorCode": "FAVORITO_DUPLICADO",
  "message": "El prestador ya se encuentra en favoritos"
}
```

**Response 404 Not Found:**
```json
{
  "success": false,
  "errorCode": "PRESTADOR_NO_ENCONTRADO",
  "message": "El prestador especificado no existe"
}
```

### Data Source
- **Tabla(s):** Tabla de relacion persona-favorito (crear si no existe)
- **Validaciones:**
  - Verificar que la persona existe
  - Verificar que el prestador existe
  - Verificar que no sea duplicado

### Prioridad
**MEDIA** - Funcionalidad de Mi Cartilla

---

## 3. POST /api/v1/favoritos/quitar

### Proposito
Eliminar un prestador de los favoritos del usuario.

### Requerido por
- `CartillaService.QuitarFavoritoAsync()`
- `CartillaController.QuitarFavorito()`

### Referencia Legacy
El sistema legacy usaba WCF services:
```csharp
// Para profesionales:
AgenteServiciosJs.MiCartillaProfesionalJs.EliminarFavoritoProfesional(solicitud)

// Para instituciones:
AgenteServiciosJs.MiCartillaProveedorSalud.EliminarFavoritoProveedorSalud(solicitud)
```

### Especificacion del Endpoint

**URL:** `POST /api/v1/favoritos/quitar`

**Request Body:**
```json
{
  "idPersona": 12345,
  "idPrestador": 67890,
  "tipoPrestador": "PROFESIONAL"
}
```

**Campos:**
- `idPersona` (int, required): ID de la persona que quita el favorito
- `idPrestador` (int, required): ID del prestador
- `tipoPrestador` (string, required): Tipo de prestador
  - Valores validos: `"PROFESIONAL"`, `"ENTIDAD_SALUD"`, `"EMERGENCIA"`

**Response 200 OK:**
```json
{
  "success": true,
  "message": "Favorito eliminado correctamente"
}
```

**Response 404 Not Found:**
```json
{
  "success": false,
  "errorCode": "FAVORITO_NO_ENCONTRADO",
  "message": "El prestador no se encuentra en favoritos"
}
```

### Data Source
- **Tabla(s):** Tabla de relacion persona-favorito
- **Validaciones:**
  - Verificar que el favorito existe antes de eliminar

### Prioridad
**MEDIA** - Funcionalidad de Mi Cartilla

---

## ~~4. Integracion ApiLocalizacionClient~~ COMPLETADO

> **Estado:** IMPLEMENTADO (2025-12-04)
>
> Se implemento `IApiLocalizacionClient` en `BackendServices.ApiLocalizacion` consumiendo la API de Localizacion existente.

### Implementacion Realizada

**Archivos creados:**
- `BackendServices/ApiLocalizacion/Interfaces/IApiLocalizacionClient.cs`
- `BackendServices/ApiLocalizacion/ApiLocalizacionClient.cs`
- `BackendServices/ApiLocalizacion/ApiLocalizacionClientServiceConfig.cs`
- `BackendServices/ApiLocalizacion/Models/LocalidadCercanaResponseDto.cs`
- `BackendServices/ApiLocalizacion/Models/LocalidadActualResponseDto.cs`
- `BackendServices/ApiLocalizacion/Models/LocalidadResponseDto.cs`
- `BackendServices/ApiLocalizacion/Models/ProvinciaResponseDto.cs`
- `BackendServices/ApiLocalizacion/Models/GenericApiResponse.cs`

**Endpoints consumidos de ApiLocalizacion:**
- `GET v1/Localidad/{id}` - Obtener localidad por ID
- `GET v1/Localidad/{id}/LocalidadesCercanas/{radioKm}` - Obtener localidades cercanas
- `GET v1/Localidad/LocalidadActual?latitud=X&longitud=Y` - Obtener localidad actual por coordenadas

**Metodos de CartillaService actualizados:**
- `GetEmergenciasAsync()` - Usa `ObtenerLocalidadesCercanasAsync()`
- `GetInstitucionesRadioNAsync()` - Usa `ObtenerLocalidadesCercanasAsync()`
- `GetProfesionalesRadioNAsync()` - Usa `ObtenerLocalidadesCercanasAsync()`

**Configuracion en appsettings.json:**
```json
"ApiLocalizacionSettings": {
  "RutaApiLocalizacion": "http://srvappdevelop.jerarquicossalud.com.ar:8290/api/Localizacion/",
  "NamedClient": "ApiLocalizacion",
  "Username": "Api Localizacion Default",
  "Proxy": false,
  "ObtenerLocalidad": "v1/Localidad/{0}",
  "ObtenerLocalidadesCercanas": "v1/Localidad/{0}/LocalidadesCercanas/{1}",
  "ObtenerLocalidadActual": "v1/Localidad/LocalidadActual"
}
```

---

## ~~5. Integracion ApiCoberturaSociosClient~~ COMPLETADO

> **Estado:** IMPLEMENTADO (2025-12-05)
>
> Se implemento `IApiCoberturaSociosClient` en `BackendServices.ApiCoberturaSocios` consumiendo la API de Cobertura de Socios para obtener el PlanId real del socio autenticado.

### Implementacion Realizada

**Archivos creados:**
- `BackendServices/ApiCoberturaSocios/Interfaces/IApiCoberturaSociosClient.cs`
- `BackendServices/ApiCoberturaSocios/ApiCoberturaSociosClient.cs`
- `BackendServices/ApiCoberturaSocios/ApiCoberturaSociosClientServiceConfig.cs`
- `BackendServices/ApiCoberturaSocios/Models/FindElegibilidadSocioResponseDto.cs`
- `BackendServices/ApiCoberturaSocios/Models/PlanSocioVigenteDto.cs`
- `BackendServices.Test/ApiCoberturaSocios/ApiCoberturaSociosClientTests.cs`
- `BackendServices.Test/ApiCoberturaSocios/ApiCoberturaSociosClientServiceConfigTests.cs`

**Endpoints consumidos de ApiCoberturaSocios:**
- `GET v1/socios/elegibilidad?numeroSocio=X&ordenSocio=Y&fechaReferencia=Z` - Obtener elegibilidad y plan del socio

**Metodos implementados en ApiCoberturaSociosClient:**
- `FindElegibilidadSocioAsync()` - Obtiene la elegibilidad completa del socio
- `GetPlanIdAsync()` - Obtiene el PlanId del socio (con fallback a DefaultPlanId=24)

**Actualizaciones en CartillaController:**
- Se reemplazo el metodo `GetPlanId()` hardcodeado por `GetPlanIdAsync()` que llama a la API
- Se agregaron metodos `GetNumeroSocioFromClaims()` y `GetOrdenSocioFromClaims()` para extraer datos del JWT
- Los endpoints publicos usan `GetDefaultPlanId()` (valor 24)
- Los endpoints protegidos usan `await GetPlanIdAsync()` para obtener el plan real del socio

**Configuracion en appsettings.json:**
```json
"ApiCoberturaSociosSettings": {
  "RutaApiCoberturaSocios": "http://srvappdevelop.jerarquicossalud.com.ar:8290/api/coberturaSocios/",
  "NamedClient": "ApiCoberturaSocios",
  "Username": "Api Cobertura Socios Default",
  "Proxy": false,
  "FindElegibilidadSocio": "v1/socios/elegibilidad"
}
```

**Tests:** 38 tests unitarios creados con 100% de cobertura del cliente.

---

## 6. Campos Adicionales Faltantes (Menor Prioridad)

### 6.1 Cobertura24x7 para Emergencias
**Archivo:** `CartillaService.cs` linea 579
```csharp
Cobertura24x7 = false // TODO: Get real data when available in ApiPrestadores
```

**Descripcion:** Campo que indica si el servicio de emergencia tiene cobertura 24x7.
**Impacto:** Informativo, no bloquea funcionalidad.

### 6.2 Email para Instituciones y Profesionales
**Archivo:** `CartillaService.cs` lineas 733, 753
```csharp
Email = null // TODO: Get email when available in ApiPrestadores
```

**Descripcion:** Campo de email de contacto.
**Impacto:** Informativo, no bloquea funcionalidad.

### 6.3 FechaAgregado para Favoritos
**Archivo:** `CartillaService.cs` lineas 718, 734, 753
```csharp
FechaAgregado = DateTime.Now // TODO: Get real date from ApiPrestadores when available
```

**Descripcion:** Fecha en que se agrego el prestador a favoritos.
**Impacto:** Informativo, actualmente usa fecha actual como workaround.

---

## Resumen de Prioridades

| Endpoint/Feature | Prioridad | Bloquea Funcionalidad | Estado |
|------------------|-----------|----------------------|--------|
| GET /especialidades-medicas | ALTA | Si - Busqueda de profesionales | PENDIENTE |
| ~~ApiLocalizacionClient~~ | ~~ALTA~~ | ~~Si - Precision de busquedas~~ | **COMPLETADO** |
| ~~ApiCoberturaSociosClient~~ | ~~ALTA~~ | ~~Si - PlanId real del socio~~ | **COMPLETADO** |
| POST /favoritos/agregar | MEDIA | Si - Mi Cartilla | PENDIENTE |
| POST /favoritos/quitar | MEDIA | Si - Mi Cartilla | PENDIENTE |
| Cobertura24x7 | BAJA | No | PENDIENTE |
| Email | BAJA | No | PENDIENTE |
| FechaAgregado | BAJA | No | PENDIENTE |

---

## Mapeo de Rutas Legacy vs Nuevo Controller

Para garantizar compatibilidad transparente, las rutas deben coincidir exactamente.

### Rutas del Legacy (`ApiMovil.Api`)
Prefijo: `api/Cartilla/`

| Metodo | Ruta Legacy | Auth |
|--------|-------------|------|
| GET | `api/Cartilla/Emergencias/{localidad}/{radio}` | No |
| GET | `api/Cartilla/Emergencias/{localidad}/{radio}/{idPersona}` | Si |
| GET | `api/Cartilla/TiposInstitucion` | No |
| GET | `api/Cartilla/Instituciones/CercaDeMi` | No |
| GET | `api/Cartilla/Instituciones/CercaDeMiProtegido` | Si |
| GET | `api/Cartilla/Instituciones/RadioN` | No |
| GET | `api/Cartilla/Instituciones/RadioNProtegido` | Si |
| GET | `api/Cartilla/Instituciones/CercaDeMi/Mapa` | No |
| GET | `api/Cartilla/Instituciones/CercaDeMi/MapaProtegido` | Si |
| GET | `api/Cartilla/EspecialidadesMedicas` | No |
| GET | `api/Cartilla/Profesionales/RadioN` | No |
| GET | `api/Cartilla/Profesionales/RadioNProtegido` | Si |
| GET | `api/Cartilla/Profesionales/CercaDeMi` | No |
| GET | `api/Cartilla/Profesionales/CercaDeMiProtegido` | Si |
| GET | `api/Cartilla/Profesionales/CercaDeMi/Mapa` | No |
| GET | `api/Cartilla/Profesionales/CercaDeMi/MapaProtegido` | Si |
| POST | `api/Cartilla/AgregarFavorito` | Si |
| POST | `api/Cartilla/QuitarFavorito` | Si |
| GET | `api/Cartilla/BuscarFavoritos/{idPersona}` | Si |

### Rutas del Nuevo Controller (`ApiJsMobile`)
Prefijo: `api/v{version:apiVersion}/Cartilla/`

**NOTA IMPORTANTE:** El nuevo controller usa versionamiento de API.
- Ruta real: `api/v1/Cartilla/...`

Las rutas internas (despues del prefijo) son identicas al legacy.

---

## Contacto

Para consultas sobre estos requerimientos:
- **Equipo:** ApiJsMobile
- **Archivo de referencia:** `CartillaService.cs`
- **Controller:** `CartillaController.cs`

---

**Ultima actualizacion:** 2025-12-18
