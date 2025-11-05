# RestApiTemplateNet8
RestApiTemplateNet8 es un template Rest sencillo asíncrono.
Cuenta con un ejemplo incluido para que puedan a partir del mismo crear sus propios casos de uso.

## Tech
- Net 8
- JS.Framework.API
- Log (Serilog)
- Swagger
- Dapper
- Unit test (NUnit)

## Capas
El proyecto está dividido en las siguientes capas:
- **Domain**
    Contiene los modelos de entidades e Interfaces necesarias, las interfaces de repositorio irán aquí.
- **Dto**
    Contiene los DTO que se usarán para las requests, responses y lo que fuera necesario para comunicarse a través del controlador y la aplicación.
- **Infraestructure**
    Contiene los repositorios y sus interfaces, toda comunicación directa a la base de datos debe realizarse aquí.
- **Application**
    Contiene los servicios y sus interfaces.
    Se aplica regla de negocio. La comunicación hacia los repositorios y mappeo de entidades a dto se realiza aquí.
- **Api**
    Contiene los controladores y las inyecciones de dependencia hacia los otros proyectos.

## Proyectos Unit Test
Las tecnología usadas son **NUnit** y **Moq**.
Cada proyecto que contenga funcionalidad tiene un proyecto de unit test relacionado.
**Api** > **Api.Test**
**Application** > **Application.Test**
**Infraestructure** > **Infraestructure.Test**
**Dto** > **Dto.Test**

## Logs
El template incorpora logs usando Serilog.
Estos se generarán en la carpeta **logs** del proyecto **Api** cuando se ejecuta en forma local.
Para las configuraciones de compilación **Dev**, **Test**, **Staging**, **Production**, se incluye la configuraciones para enviar los datos de logs a traves de Graylog
La configuración de todo lo relacionado a logs se encuentra dentro del archivo **appsettings.json** y de sus transformaciones segun las configuraciones de compilación.

## Propagación de cabeceras
Se utilizan las siguientes cabeceras custom:
1) **X-User-Id**: Para propagar el id del usuario entre las llamadas entre los distintos servicios.
2) **X-Correlation-Id**: GUID generado por el primer servicio que atiende una request para luego ser propagado por la cadena completa de llamadas a los servicios, de tal 
manera que se pueda rastrear un error que se produzca dentro de la cadena completa de llamadas y correlacionar todas las llamadas entre los servicios.

## Manejo de errores (exceptions)
Se implemento un middleware de excepciones IHandlerExceptionMiddleware (HandlerExceptionMiddleware) para manejar de forma centralizada las excepciones que se 
disparen desde cualquier capa de la aplicación.

## Paginado, Ordenamiento y Expansión de entidades
Se implementan el paginado (IPaging), ordenamiento (IOrderBy) y expansion (IExpand) para objetos Dto, se incluyen validadores de Fluent y ejemplos de uso para cada funcion.

---
## Instalación (batch - dotnet)
Este método de instalación consiste en instalar el template a partir de la ejecución de un archivo bat (este ejecuta por dentro líneas de comando **dotnet**). Los pasos a seguir son los siguientes:
1) descargar el repositorio
2) ir a la raíz de la carpeta se haya descargado el repositorio, _por ejemplo_:
_**C:\reposejemplo\RestApiTemplateNet8**_
3) ejecutar el archivo
**installer.bat**
4) en caso de que se haya instalado, recibiremos un mensaje como el siguiente:
    ```sh
    Success: C:\reposejemplo\RestApiTemplateNet8 installed the following templates:
    Template Name		Short Name          Language	Tags
    -----------------	---------------	    --------	------------------
    Rest Api Template	RestApiTemplateNet8	[C#]		Web/WebAPI/ApiRest
    ```
Con esto ya estará disponible el template para ser usado en proyectos nuevos a través de línea de comando.

##### Inicia tu proyecto
1) Crear una carpeta nueva donde prefiera. Por ejemplo:
_**C:\reposejemplo\proyectoprueba**_
2) abrimos la consola de comando dentro de la carpeta mencionada en el paso 1:
Menú **Archivo** > **Abrir Windows PowerShell** > **Abrir Windows PowerShell**
o
**File** > **Open Windows PowerShell** > **Open Windows PowerShell**
3) ejecutar el siguiente comando:
    ```sh
    dotnet new RestApiTemplateNet8 -n NombreDeTuProyectoNuevo -o src
    ```
    _es importante recordar que se debe estar posicionado en la carpeta mencionada en el paso 1, al final todo completo debería verse así:_
    ```sh
    PS C:\reposejemplo\proyectoprueba> dotnet new RestApiTemplateNet8 -n NombreDeTuProyectoNuevo -o src
    ```
4) en caso de que se haya creado, recibiremos un mensaje como el siguiente:
    ```sh
    The template "Rest Api Template" was created successfully.
    ```

Con eso ya tendrá su proyecto listo (_basado en **Rest Api Template**_).

---
## Configuración inicial
Configure la **cadena de conexión** en el proyecto **Api**, archivo **appsettings.json** apuntando a la base de datos.
La línea a modificar sería:
```sh
"DefaultConnection": "Server=PUTSERVERHERE;Database=PUTDATABASEHERE;Trusted_Connection=True;"
```

---
## Crear caso de uso
En el proyecto de RestApiTemplateNet8 se adjuntó un Sample a modo guía de todo lo necesario para crear un caso de uso, desde el controlador hasta el dominio.
A continuación se detalla que archivos y dónde se deben agregar en caso de querer realizar un nuevo caso de uso, para el ejemplo lo llamaremos **Person**:

**Proyecto Domain**
- crear la carpeta **Person**
    - crear el modelo **Person.cs**
    - crear la interfaz **IPersonRepository**

**Proyecto Dto**
- crear la carpeta **Person**
    - crear el dto **PersonRequestDto.cs**
    - crear el dto **PersonResponseDto.cs**


**Proyecto Application**
- en la carpeta **Interfaces**
    - crear la interfaz **IPersonService.cs**
- en la carpeta **Mappers**
    - crear el perfil de mappeo **PersonProfile.cs**
- en la carpeta **Services**
    - crear el servicio **PersonService.cs**

**Proyecto Api**
- en la carpeta **Controllers**
    - crear el controlador **PersonController.cs**
- en el archivo **Startup.cs**
    - agregar la inyeccion de dependencia correspondiente a AutoMapper:
    ```sh
    builder.Services.AddAutoMapper(typeof(PersonProfile).Assembly);
    ```
**Proyecto Infraestructure**
- en la carpeta **Repositories**
    - crear el repositorio **PersonRepository.cs**
- en el archivo **DependencyInjectionManagement.cs**
    - registrar las inyecciones de dependencias en su bloque correspondiente
    
Eso ser�a todo lo necesario para tener nuestro caso de uso nuevo funcionando.

### Unit Testing, no olvidar
Como buena pr�ctica, ser�a recomendable que para los archivos anteriormente mencionados les creen los correspondientes unit tests.

**Proyecto Infraestructure.Test**
- en la carpeta **Repositories**
    - crear la carpeta **PersonRepositoryTests** y dentro un archivo .cs por cada método a testear

**Proyecto Application.Test**
- en la carpeta **Services**
    - crear la carpeta **PersonServiceTests** y dentro un archivo .cs por cada método a testear

**Proyecto Api.Test**
- en la carpeta **Controllers**
    - crear la carpeta **PersonControllerTests** y dentro un archivo .cs por cada action a testear

---
## Base de datos de ejemplo
En el caso de que se desee probar la funcionalidad de Sample es necesario crear la base de datos correspondiente, puede llamarla como quiera.
Una vez creada la base de datos ejecute en ella el script SQL que se adjuntará, esto creará las tablas y sus registros.
```sh
--crear tablas
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Table [dbo].[Sample] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sample](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RandomNumber] [int] NOT NULL,
	[Description] [varchar](max) NULL,
	[CategoryId] [int] NULL,
 CONSTRAINT [PK_Sample] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SampleCategory] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SampleCategory](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](max) NULL,
 CONSTRAINT [PK_SampleCategory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SampleDetail] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SampleDetail](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SampleId] [int] NOT NULL,
	[DetailName] [varchar](100) NOT NULL,
 CONSTRAINT [PK_SampleDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [FK_Sample_SampleCategory] ******/
CREATE NONCLUSTERED INDEX [FK_Sample_SampleCategory] ON [dbo].[Sample]
(
	[CategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [FK_SampleDetail_Sample] ******/
CREATE NONCLUSTERED INDEX [FK_SampleDetail_Sample] ON [dbo].[SampleDetail]
(
	[SampleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Sample]  WITH CHECK ADD  CONSTRAINT [FK_Sample_SampleCategory] FOREIGN KEY([CategoryId])
REFERENCES [dbo].[SampleCategory] ([Id])
GO
ALTER TABLE [dbo].[Sample] CHECK CONSTRAINT [FK_Sample_SampleCategory]
GO
ALTER TABLE [dbo].[SampleDetail]  WITH CHECK ADD  CONSTRAINT [FK_SampleDetail_Sample] FOREIGN KEY([SampleId])
REFERENCES [dbo].[Sample] ([Id])
GO
ALTER TABLE [dbo].[SampleDetail] CHECK CONSTRAINT [FK_SampleDetail_Sample]
GO
USE [master]
GO
ALTER DATABASE [sampledb] SET  READ_WRITE 
GO


CREATE TABLE [dbo].[Sample](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RandomNumber] [int] NOT NULL,
	[Description] [varchar](max) NULL,
 CONSTRAINT [PK_Sample] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SampleDetail](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SampleId] [int] NOT NULL,
	[DetailName] [varchar](100) NOT NULL,
 CONSTRAINT [PK_SampleDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SampleDetail]  WITH CHECK ADD  CONSTRAINT [FK_SampleDetail_Sample] FOREIGN KEY([SampleId])
REFERENCES [dbo].[Sample] ([Id])
GO
ALTER TABLE [dbo].[SampleDetail] CHECK CONSTRAINT [FK_SampleDetail_Sample]
GO

--insertar registros
INSERT INTO [dbo].[SampleCategory] ([Name])
  VALUES
  ('Category 1'),
  ('Category 2'),
  ('Category 3')

INSERT INTO [dbo].[Sample]([RandomNumber], [Description], [CategoryId]))
  VALUES
  (0, 'Some description 0', 1),
  (1, 'Some description 1', 1)

  GO

  INSERT INTO [dbo].[SampleDetail]([SampleId], [DetailName])
  VALUES
  (1, 'Some detail name 1'),
  (2, 'Some detail name 2')
```

Solo restará configurar la **cadena de conexión** en el proyecto **Api**, archivo **appsettings.json** apuntando a la base de datos que acaba de crear.

---

## Inyección de dependencias
El proyecto utiliza una clase centralizada `DependencyInjectionManagement` dentro de **Infraestructure**, donde se configuran todas las inyecciones de dependencia.

Ejemplo de configuración de servicios de aplicación y repositorios:

```csharp
/// <summary>
/// Configura las inyecciones de dependencia para los servicios de aplicación.
/// </summary>
/// <param name="services">Colección de servicios de la aplicación.</param>
private static void InitializeApplicationServices(this IServiceCollection services)
{
    services.AddScoped<ISampleService, SampleService>();
}

/// <summary>
/// Configura las inyecciones de dependencia para los repositorios de la aplicación.
/// </summary>
/// <param name="services">Colección de servicios de la aplicación.</param>
private static void InitializeRepositories(this IServiceCollection services)
{
    services.AddScoped<IGenericRepository<Sample>, GenericRepository<Sample>>();
    services.AddScoped<ISampleRepository, SampleRepository>();
    services.AddScoped<IGenericRepository<SampleDetail>, GenericRepository<SampleDetail>>();
    services.AddScoped<ISampleDetailRepository, SampleDetailRepository>();
    services.AddScoped<IGenericRepository<SampleCategory>, GenericRepository<SampleCategory>>();
    services.AddScoped<ISampleCategoryRepository, SampleCategoryRepository>();
}
```
## Transacciones en Base de Datos con Transactional Proxy

En los casos donde sea necesario el uso de transacciones, se proveen 2 ejemplos en la plantilla donde se puede observar el uso de transacciones:
1) api/v1/sample (HTTP POST)
El objetivo de este end-point es realizar el alta en base de datos de un sample compuesto por la cabecera (Sample) y el detalle (List<SampleDetail>), en el caso que ocurra un error durante la inserción de un detalle se revierte la transacción completa.
2) api/v1/sample/{id} (HTTP PUT)
El objetivo de este end-point es realizar la actualización completa de un sample, es decir se actualizan los datos de la cabecera (Sample), se eliminan los detalles anteriores y se insertan los detalles nuevos (List<SampleDetail>), en el caso que ocurra un error en cualquier paso del proceso se revierte la transacción completa.

Para encapsular la lógica transaccional de forma automática, se añade un **Transactional Proxy** que permite marcar métodos como transaccionales mediante el atributo `[Transactional]`.

Ejemplo:
```csharp
public interface ISampleService
{
    [Transactional]
    Task<int> Add(SampleAddRequestDto request);

    [Transactional]
    Task<bool> Update(int sampleId, SampleUpdateRequestDto request);
}
```

En `DependencyInjectionManagement`, se debe inicializar el proxy:

```csharp
private static void InitializeTransactionalProxies(this IServiceCollection services)
{
    services.AddTransactionalProxy<ISampleService, SampleService>();
}
```

Esto asegura que las transacciones funcionen correctamente dentro de la aplicación.





