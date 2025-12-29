# Suite de Pruebas de Postman - ApiJsMobile

## Archivos incluidos

| Archivo | Descripcion |
|---------|-------------|
| `ApiJsMobile.postman_collection.json` | Coleccion completa con 24 endpoints |
| `ApiJsMobile.postman_environment.json` | Variables de entorno para desarrollo local |

## Importar en Postman

1. Abrir Postman
2. Click en **Import** (esquina superior izquierda)
3. Arrastrar ambos archivos JSON o seleccionarlos
4. Confirmar importacion

## Estructura de la Coleccion

```
ApiJsMobile - Suite de Pruebas de Integracion
├── Auth (2 endpoints)
│   ├── Login
│   └── Validate Token
├── Cartilla (19 endpoints)
│   ├── Emergencias
│   │   ├── Get Emergencias (Publico)
│   │   └── Get Emergencias (Protegido)
│   ├── Instituciones
│   │   ├── Get Tipos de Institucion
│   │   ├── Get Instituciones Cerca De Mi (Publico)
│   │   ├── Get Instituciones Cerca De Mi (Protegido)
│   │   ├── Get Instituciones Radio N (Publico)
│   │   ├── Get Instituciones Radio N (Protegido)
│   │   ├── Get Instituciones Cerca De Mi - Mapa (Publico)
│   │   └── Get Instituciones Cerca De Mi - Mapa (Protegido)
│   ├── Profesionales
│   │   ├── Get Especialidades Medicas
│   │   ├── Get Profesionales Radio N (Publico)
│   │   ├── Get Profesionales Radio N (Protegido)
│   │   ├── Get Profesionales Cerca De Mi (Publico)
│   │   ├── Get Profesionales Cerca De Mi (Protegido)
│   │   ├── Get Profesionales Cerca De Mi - Mapa (Publico)
│   │   └── Get Profesionales Cerca De Mi - Mapa (Protegido)
│   └── Favoritos
│       ├── Agregar Favorito
│       ├── Quitar Favorito
│       └── Buscar Favoritos
└── Health Check (1 endpoint)
    └── Health Check - Swagger
```

## Uso Basico

### 1. Configurar Variables de Entorno

En el environment `ApiJsMobile - Local Development`, actualizar:

| Variable | Descripcion | Valor por defecto |
|----------|-------------|-------------------|
| `baseUrl` | URL base de la API | `https://localhost:5001` |
| `username` | Usuario para login | `usuario_test` |
| `password` | Password para login | `password123` |
| `idPersona` | ID de persona de prueba | `12345` |

### 2. Obtener Token (obligatorio para endpoints protegidos)

1. Ejecutar `Auth > Login`
2. El token se guarda automaticamente en la variable `token`
3. Los endpoints protegidos lo usaran automaticamente

### 3. Ejecutar Endpoints

- **Endpoints publicos**: Funcionan sin token
- **Endpoints protegidos**: Requieren token (ejecutar Login primero)

## Variables de Entorno

| Variable | Uso | Ejemplo |
|----------|-----|---------|
| `baseUrl` | URL base de la API | `https://localhost:5001` |
| `apiVersion` | Version de la API | `1.0` |
| `token` | Token JWT (se auto-actualiza) | `eyJhbG...` |
| `username` | Usuario para login | `usuario_test` |
| `password` | Password para login | `password123` |
| `idPersona` | ID de persona | `12345` |
| `idLocalidad` | ID de localidad | `1` |
| `radio` | Radio en km | `10` |
| `latitud` | Latitud GPS | `-34.6037` |
| `longitud` | Longitud GPS | `-58.3816` |

## Tests Automatizados

Cada request incluye tests automaticos:

```javascript
// Verificar status 200
pm.test('Status code is 200', function () {
    pm.response.to.have.status(200);
});

// Verificar estructura de respuesta
pm.test('Response is valid CartillaResponseDto', function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('success');
    pm.expect(jsonData).to.have.property('data');
});
```

## Ejecutar Suite Completa

### Desde Postman UI

1. Click derecho en la coleccion
2. Seleccionar **Run collection**
3. Configurar opciones de ejecucion
4. Click **Run**

### Desde Newman (CLI)

```bash
# Instalar Newman
npm install -g newman

# Ejecutar coleccion
newman run ApiJsMobile.postman_collection.json \
    -e ApiJsMobile.postman_environment.json \
    --reporters cli,json \
    --reporter-json-export results.json
```

## Crear Environment para Otros Ambientes

### QA/Staging

```json
{
    "key": "baseUrl",
    "value": "https://api-qa.ejemplo.com"
}
```

### Produccion

```json
{
    "key": "baseUrl",
    "value": "https://api.ejemplo.com"
}
```

## Notas

- Las coordenadas de ejemplo son de Buenos Aires, Argentina
- Algunos endpoints estan pendientes de implementacion completa (marcados en descripcion)
- El token tiene validez limitada, re-ejecutar Login si expira
