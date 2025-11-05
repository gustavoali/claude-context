# Directrices de Desarrollo - YouTube RAG Project

## Fecha de creación: 2025-09-20
## Autor: Claude (Revisión y optimización de código)

## 🚫 REGLA FUNDAMENTAL: NO DUPLICACIÓN DE FUNCIONES

### Problema Identificado
Durante la revisión del código se encontraron múltiples versiones de archivos `main.py`:
- `main.py` - Versión principal de producción
- `main_test.py` - Versión de prueba con endpoints simplificados
- `main_real.py` - Versión con procesamiento real de video
- `main_simple.py` - Versión simplificada

Esta duplicación causó:
1. **Confusión en el desarrollo**: Cambios aplicados al archivo incorrecto
2. **Mantenimiento complejo**: Múltiples lugares donde aplicar correcciones
3. **Inconsistencias**: Diferentes comportamientos entre "versiones"
4. **Debugging difícil**: No claridad sobre qué código se ejecuta

### Nueva Directriz: UN SOLO PUNTO DE ENTRADA

**REGLA**: Debe existir UN SOLO archivo `main.py` que maneje todos los entornos mediante configuración.

### Implementación de Entornos por Configuración

#### Variables de Entorno Requeridas
```bash
# Tipo de entorno
ENVIRONMENT=development|testing|production

# Modo de procesamiento
PROCESSING_MODE=mock|real|hybrid

# Tipo de almacenamiento
STORAGE_MODE=memory|database|hybrid

# Funcionalidades específicas
ENABLE_AUTH=true|false
ENABLE_WEBSOCKETS=true|false
ENABLE_METRICS=true|false
ENABLE_REAL_PROCESSING=true|false
```

#### Estructura de Configuración
```python
# app/core/config.py
class Settings(BaseSettings):
    # Entorno
    ENVIRONMENT: Literal["development", "testing", "production"] = "development"

    # Modos operativos
    PROCESSING_MODE: Literal["mock", "real", "hybrid"] = "mock"
    STORAGE_MODE: Literal["memory", "database", "hybrid"] = "database"

    # Funcionalidades toggleables
    ENABLE_AUTH: bool = True
    ENABLE_WEBSOCKETS: bool = True
    ENABLE_METRICS: bool = True
    ENABLE_REAL_PROCESSING: bool = False

    @property
    def is_testing(self) -> bool:
        return self.ENVIRONMENT == "testing"

    @property
    def use_mock_storage(self) -> bool:
        return self.STORAGE_MODE in ["memory", "hybrid"] and self.is_testing
```

#### Patrones de Implementación

##### 1. Endpoints Condicionales
```python
# En lugar de múltiples archivos, usar:
if settings.ENABLE_AUTH:
    app.include_router(auth.router, prefix="/auth")

if settings.ENABLE_WEBSOCKETS:
    app.include_router(websocket.router, prefix="/ws")
```

##### 2. Servicios Intercambiables
```python
# app/services/factory.py
def get_video_processor():
    if settings.PROCESSING_MODE == "real":
        return RealVideoProcessor()
    elif settings.PROCESSING_MODE == "mock":
        return MockVideoProcessor()
    else:  # hybrid
        return HybridVideoProcessor()

def get_storage_service():
    if settings.STORAGE_MODE == "memory":
        return MemoryStorage()
    elif settings.STORAGE_MODE == "database":
        return DatabaseStorage()
    else:  # hybrid
        return HybridStorage()
```

##### 3. Middleware Condicional
```python
# En main.py
if settings.ENABLE_METRICS:
    app.add_middleware(MetricsMiddleware)

if settings.ENABLE_AUTH and not settings.is_testing:
    app.add_middleware(AuthMiddleware)
```

### Configuraciones por Entorno

#### Development (.env.development)
```
ENVIRONMENT=development
PROCESSING_MODE=mock
STORAGE_MODE=database
ENABLE_AUTH=false
ENABLE_REAL_PROCESSING=false
DEBUG=true
```

#### Testing (.env.testing)
```
ENVIRONMENT=testing
PROCESSING_MODE=mock
STORAGE_MODE=memory
ENABLE_AUTH=false
ENABLE_WEBSOCKETS=false
ENABLE_METRICS=false
```

#### Production (.env.production)
```
ENVIRONMENT=production
PROCESSING_MODE=real
STORAGE_MODE=database
ENABLE_AUTH=true
ENABLE_REAL_PROCESSING=true
DEBUG=false
```

## 📋 REGLAS DE DESARROLLO

### 1. Antes de Crear Código Duplicado
- [ ] ¿Puede resolverse con una variable de configuración?
- [ ] ¿Es realmente necesario o es solo conveniencia?
- [ ] ¿Se puede abstraer en una función/clase configurable?

### 2. Al Encontrar Código Duplicado
- [ ] Identificar las diferencias reales entre versiones
- [ ] Extraer lógica común a funciones base
- [ ] Parametrizar las diferencias mediante configuración
- [ ] Eliminar archivos duplicados

### 3. Nuevas Funcionalidades
- [ ] Diseñar con configuración desde el inicio
- [ ] Documentar variables de entorno necesarias
- [ ] Probar en todos los modos configurados
- [ ] Actualizar documentación de configuración

## 🛠️ HERRAMIENTAS DE VALIDACIÓN

### Script de Validación
```python
# scripts/validate_no_duplicates.py
def validate_no_duplicates():
    """Validar que no existan archivos main_* duplicados"""
    main_files = glob.glob("app/main_*.py")
    if main_files:
        raise ValueError(f"Archivos duplicados encontrados: {main_files}")

def validate_config_coverage():
    """Validar que todas las configuraciones estén documentadas"""
    # Implementar validación de variables de entorno
    pass
```

### Pre-commit Hook
```bash
#!/bin/bash
# .git/hooks/pre-commit
python scripts/validate_no_duplicates.py || exit 1
```

## 📖 DOCUMENTACIÓN OBLIGATORIA

### Para Nuevas Variables de Configuración
1. Agregar a `app/core/config.py`
2. Documentar en `docs/configuration.md`
3. Agregar ejemplos en archivos `.env.example`
4. Actualizar tests de configuración

### Para Nuevos Modos Operativos
1. Documentar comportamiento esperado
2. Crear tests para cada modo
3. Validar compatibilidad con configuraciones existentes
4. Actualizar guías de deployment

## 🎯 OBJETIVOS A LARGO PLAZO

1. **Un solo punto de entrada**: `main.py` únicamente
2. **Configuración declarativa**: Todo comportamiento via variables
3. **Testing exhaustivo**: Todos los modos probados automáticamente
4. **Documentación viva**: Configuración auto-documentada
5. **Deployment flexible**: Mismo código, múltiples entornos

---

**Esta directriz es OBLIGATORIA para todo desarrollo futuro en el proyecto.**
**Cualquier violación debe ser rechazada en code review.**