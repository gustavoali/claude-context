# Repositorio-ApiMovil - Configuracion de Proyecto

**Tipo:** API REST .NET Framework 4.x (Legacy)

## Documentacion Relacionada

@C:/claude_context/jerarquicos/Repositorio-ApiMovil/FEATURES.md
**Organizacion:** Jerarquicos Salud
**Estado:** En mantenimiento (siendo reemplazado por ApiJsMobile)

---

## Descripcion del Proyecto

API Mobile legacy para Jerarquicos Salud. Este proyecto esta siendo migrado a ApiJsMobile (.NET 8).

**IMPORTANTE:** Este proyecto es de REFERENCIA para la migracion. Los nuevos desarrollos deben hacerse en ApiJsMobile.

## Estructura del Proyecto

```
Repositorio-ApiMovil/
├── Api/                    # Proyecto principal Web API
│   ├── Controllers/        # Controladores de la API
│   ├── Dto/               # Data Transfer Objects
│   ├── Filters/           # Filtros de accion
│   ├── Models/            # Modelos de datos
│   ├── Utils/             # Utilidades
│   ├── Web.config         # Configuracion base
│   ├── Web.Dev.config     # Config Development
│   ├── Web.Test.config    # Config Test
│   ├── Web.StagingAndroid.config
│   ├── Web.StagingIOS.config
│   ├── Web.ProductionAndroid.config
│   └── Web.ProductionIOS.config
├── BackendServices/        # Servicios de backend
├── microservices/          # Microservicios relacionados
├── tests/                  # Tests del proyecto
└── ApiMovil.sln           # Solucion Visual Studio
```

## URLs de Ambientes (Referencia)

| Ambiente | URL Base |
|----------|----------|
| Development | srvappdevelop.jerarquicossalud.com.ar |
| Test | srvtest.jerarquicossalud.com.ar |
| Staging | srvappstaging.jerarquicossalud.com.ar |
| Production | balanceadorbackendprod01.jerarquicossalud.com.ar |

## Tecnologias

- **.NET Framework 4.x** (NO .NET Core)
- **ASP.NET Web API 2**
- **MSBuild** para compilacion
- **Web.config transforms** para ambientes
- **WCF Services** para comunicacion con backend

## Comandos de Build

```bash
# Build con MSBuild (Visual Studio 2022)
"C:/Program Files/Microsoft Visual Studio/2022/Community/MSBuild/Current/Bin/amd64/MSBuild.exe" "Api/01.Api.csproj" -t:Build -p:Configuration=Debug -verbosity:quiet

# O desde Visual Studio
# Build > Build Solution (Ctrl+Shift+B)
```

## Uso como Referencia para Migracion

Este proyecto se usa para:
1. **Consultar endpoints legacy** - Ver rutas y parametros originales
2. **Extraer configuraciones** - URLs de APIs backend en Web.*.config
3. **Entender logica de negocio** - Servicios WCF y DTOs originales
4. **Mantener compatibilidad** - Las rutas en ApiJsMobile deben coincidir

## Archivos Clave para Referencia

- `Api/Controllers/CartillaController.cs` - Endpoints de cartilla medica
- `Api/Web.*.config` - URLs de APIs por ambiente
- `BackendServices/` - Clientes WCF originales

## Notas Importantes

- NO desarrollar nuevas funcionalidades aqui
- Usar solo como referencia para migracion a ApiJsMobile
- Las configuraciones de URL en Web.config son la fuente de verdad para ambientes

---

## Directiva de Documentacion de Features

**OBLIGATORIO:** Toda feature o fix trabajado debe quedar registrado para poder recuperar el contexto en futuras sesiones.

### Estructura de Documentacion

```
C:/claude_context/jerarquicos/Repositorio-ApiMovil/
├── FEATURES.md                    # Indice de todas las features
└── features/
    └── [id]_[nombre]/             # Carpeta por feature
        ├── README.md              # Descripcion, endpoints, ramas, archivos
        ├── response_*.json        # Ejemplos de respuestas
        └── [otros recursos]       # Postman, scripts, etc.
```

### Cuando Documentar

- Al iniciar trabajo en una feature/fix nueva
- Al completar una feature/fix
- Al retomar trabajo en una feature existente (actualizar estado)

### Como Documentar

1. **Crear carpeta:** `features/[id_historia]_[nombre_corto]/`
2. **Crear README.md** con: descripcion, endpoints, ramas, archivos clave, notas tecnicas
3. **Agregar ejemplos** de response en archivos `.json`
4. **Actualizar indice** en `FEATURES.md`

### Ubicacion

- **Indice:** `C:/claude_context/jerarquicos/Repositorio-ApiMovil/FEATURES.md`
- **Detalle:** `C:/claude_context/jerarquicos/Repositorio-ApiMovil/features/[id]_[nombre]/`

---

## Directivas de Codigo

### Comentarios y documentacion

**Principio:** El codigo debe ser autoexplicativo.

- **NO agregar** comentarios inline explicativos dentro del codigo
- **Mantener** los comentarios legacy que ya existan
- **Documentacion XML** (`/// <summary>`): Agregar unicamente cuando:
  - Se crean metodos nuevos
  - Se modifica la firma de metodos existentes
