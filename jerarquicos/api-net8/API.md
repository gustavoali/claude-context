# 📋 ApiMovil - Referencia de API

## 🌐 Base URL

- **Desarrollo**: `https://localhost:7001/api`
- **Staging**: `https://staging-apimovil.company.com/api`
- **Producción**: `https://apimovil.company.com/api`

## 🔐 Autenticación

ApiMovil utiliza **JWT Bearer Token** para autenticación. Todos los endpoints (excepto `/auth/login` y `/health`) requieren autenticación.

### Headers Requeridos

```http
Authorization: Bearer {jwt-token}
Content-Type: application/json
Accept: application/json
```

### Obtener Token

```http
POST /auth/login
Content-Type: application/json

{
  "numeroDocumento": "12345678",
  "pin": "1234",
  "tipoDocumento": "DNI"
}
```

**Respuesta:**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "def50200abc...",
  "expiresIn": 900,
  "tokenType": "Bearer",
  "user": {
    "numeroSocio": "123456",
    "nombre": "Juan",
    "apellido": "Pérez",
    "documento": "12345678",
    "estado": "ACTIVO",
    "esTitular": true
  }
}
```

## 👤 Socios

### Obtener Socio por Número

```http
GET /socios/{numeroSocio}
```

**Parámetros:**
- `numeroSocio` (string): Número único del socio

**Headers:**
- `Authorization: Bearer {token}`

**Respuesta:**
```json
{
  "numeroSocio": "123456",
  "nombre": "Juan Carlos",
  "apellido": "Pérez García",
  "documento": "12345678",
  "tipoDocumento": "DNI",
  "email": "juan.perez@email.com",
  "telefono": "+541123456789",
  "fechaNacimiento": "1980-05-15T00:00:00Z",
  "estado": "ACTIVO",
  "esTitular": true,
  "planCobertura": {
    "codigo": "PREMIUM",
    "descripcion": "Plan Premium",
    "tieneCoberturaMedicamentos": true,
    "tieneCoberturaPsicologia": true,
    "tieneCoberturaDental": true
  },
  "direccion": {
    "calle": "Av. Corrientes",
    "numero": "1234",
    "piso": "5",
    "departamento": "A",
    "codigoPostal": "C1043AAZ",
    "ciudad": "CABA",
    "provincia": "Buenos Aires",
    "pais": "Argentina"
  },
  "fechaAlta": "2020-01-15T00:00:00Z",
  "fechaUltimaModificacion": "2024-01-15T10:30:00Z"
}
```

### Obtener Beneficiarios

```http
GET /socios/{numeroSocio}/beneficiarios
```

**Respuesta:**
```json
{
  "data": [
    {
      "numeroSocio": "123456-01",
      "nombre": "María Elena",
      "apellido": "Pérez",
      "documento": "87654321",
      "tipoDocumento": "DNI",
      "relacion": "CONYUGE",
      "fechaNacimiento": "1985-03-20T00:00:00Z",
      "estado": "ACTIVO",
      "esTitular": false
    }
  ],
  "pagination": {
    "page": 1,
    "pageSize": 10,
    "totalPages": 1,
    "totalCount": 1
  }
}
```

### Actualizar Datos del Socio

```http
PUT /socios/{numeroSocio}
Content-Type: application/json

{
  "email": "nuevo.email@example.com",
  "telefono": "+541187654321",
  "direccion": {
    "calle": "Nueva Calle",
    "numero": "5678",
    "piso": "2",
    "departamento": "B",
    "codigoPostal": "C1234ABC",
    "ciudad": "CABA",
    "provincia": "Buenos Aires"
  }
}
```

## 🏥 Credenciales

### Obtener Credencial Digital

```http
GET /credenciales/{numeroSocio}
```

**Respuesta:**
```json
{
  "numeroSocio": "123456",
  "titular": {
    "nombre": "Juan Carlos",
    "apellido": "Pérez García",
    "documento": "12345678",
    "plan": "PREMIUM"
  },
  "qrCode": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA...",
  "fechaVencimiento": "2024-12-31T23:59:59Z",
  "estado": "ACTIVA",
  "beneficiarios": [
    {
      "numeroSocio": "123456-01",
      "nombre": "María Elena",
      "apellido": "Pérez",
      "relacion": "CONYUGE"
    }
  ],
  "prestadores": {
    "medicos": 150,
    "farmacias": 85,
    "centrosMedicos": 45
  }
}
```

### Descargar Credencial PDF

```http
GET /credenciales/{numeroSocio}/pdf
Accept: application/pdf
```

**Respuesta:** Archivo PDF con la credencial

## 📋 Autorizaciones

### Listar Autorizaciones

```http
GET /autorizaciones?page=1&pageSize=10&estado=PENDIENTE
```

**Parámetros Query:**
- `page` (int): Número de página (default: 1)
- `pageSize` (int): Tamaño de página (default: 10, max: 100)
- `estado` (string): PENDIENTE, APROBADA, RECHAZADA
- `fechaDesde` (datetime): Filtrar desde fecha
- `fechaHasta` (datetime): Filtrar hasta fecha

**Respuesta:**
```json
{
  "data": [
    {
      "id": "AUTH-2024-001234",
      "numeroSocio": "123456",
      "prestacion": {
        "codigo": "CONS-MED-GEN",
        "descripcion": "Consulta Médica General",
        "categoria": "MEDICINA_GENERAL"
      },
      "prestador": {
        "codigo": "PREST-001",
        "nombre": "Dr. Roberto Martínez",
        "especialidad": "Medicina General",
        "direccion": "Av. Santa Fe 1234, CABA"
      },
      "fechaSolicitud": "2024-01-15T14:30:00Z",
      "fechaRequerida": "2024-01-20T09:00:00Z",
      "estado": "PENDIENTE",
      "observaciones": null,
      "montoAutorizado": 15000.00,
      "codigoAutorizacion": null
    }
  ],
  "pagination": {
    "page": 1,
    "pageSize": 10,
    "totalPages": 3,
    "totalCount": 25
  }
}
```

### Solicitar Nueva Autorización

```http
POST /autorizaciones
Content-Type: application/json

{
  "prestacionCodigo": "CONS-MED-ESP",
  "prestadorCodigo": "PREST-002",
  "fechaRequerida": "2024-01-25T10:00:00Z",
  "observaciones": "Consulta de seguimiento",
  "urgente": false
}
```

### Obtener Detalle de Autorización

```http
GET /autorizaciones/{autorizacionId}
```

## 💰 Reintegros

### Listar Reintegros

```http
GET /reintegros?estado=PROCESADO&fechaDesde=2024-01-01
```

**Respuesta:**
```json
{
  "data": [
    {
      "id": "REINT-2024-001234",
      "numeroSocio": "123456",
      "fechaSolicitud": "2024-01-10T09:00:00Z",
      "fechaProcesamiento": "2024-01-15T16:30:00Z",
      "estado": "PROCESADO",
      "montoSolicitado": 25000.00,
      "montoAprobado": 20000.00,
      "porcentajeCobertura": 80,
      "prestacion": {
        "descripcion": "Consulta Psicológica",
        "fecha": "2024-01-08T15:00:00Z",
        "prestador": "Lic. Ana García"
      },
      "documentacion": [
        {
          "tipo": "FACTURA",
          "numero": "0001-00001234",
          "fecha": "2024-01-08T00:00:00Z",
          "monto": 25000.00
        }
      ],
      "observaciones": "Reintegro aprobado según plan Premium"
    }
  ],
  "pagination": {
    "page": 1,
    "pageSize": 10,
    "totalPages": 2,
    "totalCount": 15
  }
}
```

### Solicitar Reintegro

```http
POST /reintegros
Content-Type: multipart/form-data

{
  "prestacionDescripcion": "Consulta Neurológica",
  "fechaPrestacion": "2024-01-20T11:00:00Z",
  "prestadorNombre": "Dr. Carlos Rodríguez",
  "montoSolicitado": 35000.00,
  "observaciones": "Consulta especialista fuera de cartilla",
  "documentos": [/* archivos PDF/JPG */]
}
```

## 👨‍⚕️ Prestadores

### Buscar Prestadores

```http
GET /prestadores/buscar?especialidad=CARDIOLOGIA&ciudad=CABA&disponible=true
```

**Parámetros Query:**
- `especialidad` (string): Código de especialidad médica
- `ciudad` (string): Ciudad del prestador
- `provincia` (string): Provincia del prestador  
- `nombre` (string): Búsqueda por nombre
- `disponible` (bool): Solo prestadores con turnos disponibles
- `cobertura` (string): Tipo de cobertura (TOTAL, PARCIAL)

**Respuesta:**
```json
{
  "data": [
    {
      "codigo": "PREST-CARDIO-001",
      "nombre": "Dr. Eduardo Ramírez",
      "especialidades": [
        {
          "codigo": "CARDIOLOGIA",
          "descripcion": "Cardiología",
          "subEspecialidad": "Cardiología Intervencionista"
        }
      ],
      "direccion": {
        "calle": "Av. Las Heras",
        "numero": "2574",
        "ciudad": "CABA",
        "provincia": "Buenos Aires",
        "telefono": "+541145678901"
      },
      "horarios": [
        {
          "dia": "LUNES",
          "horaDesde": "08:00",
          "horaHasta": "12:00"
        },
        {
          "dia": "MIERCOLES", 
          "horaDesde": "14:00",
          "horaHasta": "18:00"
        }
      ],
      "tipoCobertura": "TOTAL",
      "requiereAutorizacion": false,
      "turnosDisponibles": true,
      "calificacion": 4.8,
      "distancia": 2.5
    }
  ],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "totalPages": 3,
    "totalCount": 45
  }
}
```

### Obtener Prestador por Código

```http
GET /prestadores/{codigoPrestador}
```

## 💊 Farmacias

### Buscar Farmacias

```http
GET /farmacias/buscar?ciudad=CABA&radio=5&lat=-34.6118&lng=-58.3960
```

**Respuesta:**
```json
{
  "data": [
    {
      "codigo": "FARM-001",
      "nombre": "Farmacia Central",
      "direccion": {
        "calle": "Av. Córdoba",
        "numero": "1234",
        "ciudad": "CABA",
        "provincia": "Buenos Aires",
        "codigoPostal": "C1055AAA"
      },
      "telefono": "+541143210987",
      "horarios": {
        "lunesAViernes": "08:00-20:00",
        "sabados": "09:00-13:00",
        "domingos": "CERRADO"
      },
      "servicios": [
        "DELIVERY",
        "INYECCIONES",
        "MEDICAMENTOS_ESPECIALES"
      ],
      "distancia": 1.2,
      "abierto": true
    }
  ],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "totalPages": 1,
    "totalCount": 8
  }
}
```

## 🔔 Notificaciones

### Obtener Notificaciones

```http
GET /notificaciones?leida=false&page=1&pageSize=20
```

**Respuesta:**
```json
{
  "data": [
    {
      "id": "NOT-2024-001234",
      "titulo": "Autorización Aprobada",
      "mensaje": "Su autorización AUTH-2024-001234 ha sido aprobada",
      "tipo": "AUTORIZACION",
      "prioridad": "MEDIA",
      "leida": false,
      "fechaCreacion": "2024-01-15T10:30:00Z",
      "fechaVencimiento": "2024-02-15T23:59:59Z",
      "acciones": [
        {
          "texto": "Ver Autorización",
          "url": "/autorizaciones/AUTH-2024-001234",
          "tipo": "ENLACE"
        }
      ]
    }
  ],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "totalPages": 1,
    "totalCount": 5
  },
  "resumen": {
    "noLeidas": 5,
    "total": 15
  }
}
```

### Marcar Notificación como Leída

```http
PUT /notificaciones/{notificacionId}/marcar-leida
```

## 📊 Reportes

### Generar Reporte de Consumo

```http
GET /reportes/consumo?periodo=2024-01&formato=PDF
```

**Parámetros:**
- `periodo` (string): Período en formato YYYY-MM
- `formato` (string): PDF, EXCEL, JSON
- `incluirBeneficiarios` (bool): Incluir datos de beneficiarios

## ❤️ Health Checks

### Estado General

```http
GET /health
```

**Respuesta:**
```json
{
  "status": "Healthy",
  "totalDuration": "00:00:00.1234567",
  "entries": {
    "microservices": {
      "status": "Healthy",
      "duration": "00:00:00.0567890",
      "data": {
        "sociosService": "Healthy",
        "credencialesService": "Healthy",
        "autorizacionesService": "Healthy"
      }
    },
    "redis": {
      "status": "Healthy", 
      "duration": "00:00:00.0123456"
    }
  }
}
```

### Readiness Probe

```http
GET /health/ready
```

### Liveness Probe

```http
GET /health/live
```

## 🚨 Códigos de Error

### Códigos HTTP Estándar

| Código | Descripción | Uso |
|--------|-------------|-----|
| 200    | OK | Operación exitosa |
| 201    | Created | Recurso creado |
| 204    | No Content | Operación exitosa sin contenido |
| 400    | Bad Request | Datos de entrada inválidos |
| 401    | Unauthorized | Token inválido o expirado |
| 403    | Forbidden | Sin permisos para el recurso |
| 404    | Not Found | Recurso no encontrado |
| 409    | Conflict | Conflicto en el estado del recurso |
| 422    | Unprocessable Entity | Validación de negocio falló |
| 429    | Too Many Requests | Rate limit excedido |
| 500    | Internal Server Error | Error interno del servidor |
| 502    | Bad Gateway | Error en microservicio externo |
| 503    | Service Unavailable | Servicio temporalmente no disponible |

### Formato de Error

```json
{
  "type": "https://httpstatuses.com/400",
  "title": "Bad Request",
  "status": 400,
  "detail": "Los datos proporcionados no son válidos",
  "instance": "/api/socios/123456",
  "traceId": "0HMVB9BLQF:00000001",
  "errors": {
    "email": ["El formato de email no es válido"],
    "telefono": ["El teléfono es requerido"]
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

## 🔒 Rate Limiting

- **Desarrollo**: 1000 requests/minuto por IP
- **Staging**: 500 requests/minuto por IP  
- **Producción**: 100 requests/minuto por IP

Headers de respuesta:
```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1642248000
```

## 📝 Paginación

Todos los endpoints que devuelven listas soportan paginación:

**Parámetros Query:**
- `page`: Número de página (default: 1)
- `pageSize`: Elementos por página (default: 10, max: 100)

**Headers de Respuesta:**
```http
X-Pagination: {"page":1,"pageSize":10,"totalPages":5,"totalCount":47}
```

## 🔄 Versionado

La API usa versionado por URL:
- `/api/v1/socios` - Versión 1 (actual)
- `/api/v2/socios` - Versión 2 (futura)

Versiones soportadas:
- **v1**: Estable (deprecated: 2025-01-01)
- **v2**: En desarrollo

## 📱 SDKs y Clientes

### JavaScript/TypeScript
```bash
npm install @company/apimovil-client
```

### C#
```bash
dotnet add package Company.ApiMovil.Client
```

### Swagger/OpenAPI
- **Desarrollo**: https://localhost:7001/swagger
- **Staging**: https://staging-apimovil.company.com/swagger

---

Para más información detallada, consulte la [documentación interactiva de Swagger](https://apimovil.company.com/swagger) en el ambiente correspondiente.