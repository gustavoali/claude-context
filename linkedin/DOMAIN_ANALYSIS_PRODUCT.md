# Analisis de Dominio - LinkedIn Transcript Extractor

**Perspectiva:** Producto
**Fecha de Analisis:** 2026-01-29
**Analista:** Product Owner (Claude)
**Version del Sistema:** 0.13.0
**Estado:** MVP Funcional en Produccion

---

## 1. Actores del Sistema

### 1.1 Actor Principal: Aprendiz Digital

**Descripcion:** [HECHO] Usuario con suscripcion a LinkedIn Learning que desea extraer transcripciones de cursos para uso con herramientas de IA.

**Objetivos:**
- [HECHO] Capturar transcripciones de videos mientras navega LinkedIn Learning
- [HECHO] Exportar transcripciones en formato optimizado para LLMs
- [HECHO] Construir una biblioteca personal de conocimiento consultable
- [HIPOTESIS] Estudiar contenido offline o en otro formato
- [HIPOTESIS] Crear resumenes y notas a partir del contenido

**Caracteristicas:**
- Tiene cuenta activa de LinkedIn (Learning o Premium)
- Tiene conocimientos tecnicos basicos (instalar extension de Chrome)
- Usa LLMs como ChatGPT o Claude para aprendizaje

**Frustraciones actuales (problema que resuelve LTE):**
- [HECHO] LinkedIn Learning no permite exportar transcripciones nativas
- [HIPOTESIS] Copiar manualmente es tedioso y propenso a errores
- [HIPOTESIS] Los LLMs no tienen acceso directo al contenido de LinkedIn Learning

---

### 1.2 Actor Secundario: LLM Consumidor

**Descripcion:** [HECHO] Sistemas de IA (ChatGPT, Claude) que consumen las transcripciones para proporcionar valor al usuario.

**Objetivos:**
- [HECHO] Recibir transcripciones en formato estructurado y limpio
- [HECHO] Poder buscar y consultar contenido especifico
- [HECHO] Responder preguntas sobre el contenido de los cursos

**Interfaces de integracion:**
| Interface | LLM Target | Mecanismo | Estado |
|-----------|------------|-----------|--------|
| HTTP Server | ChatGPT | GPT Actions via ngrok | [HECHO] Funcional |
| MCP Server | Claude Desktop | Model Context Protocol | [HECHO] Funcional |
| Export Manual | Cualquier LLM | Copy/Paste | [HECHO] Funcional |

---

### 1.3 Actor Tecnico: Administrador del Sistema

**Descripcion:** [HECHO] Usuario tecnico que instala, configura y mantiene el sistema LTE.

**Objetivos:**
- Instalar y configurar todos los componentes
- Ejecutar crawls automatizados de cursos
- Monitorear estado del sistema
- Resolver problemas y realizar backups

**Capacidades requeridas:**
- Manejo de linea de comandos
- Instalacion de extensiones de Chrome en modo desarrollador
- Ejecucion de scripts Node.js

**Nota:** [HECHO] En el contexto actual, el Aprendiz Digital y el Administrador son la misma persona (proyecto personal).

---

## 1.4 Modelo de Dominio (Perspectiva de Producto)

Desde la perspectiva del usuario, los conceptos del dominio se organizan asi:

```
┌─────────────────────────────────────────────────────────────┐
│  LO QUE EL USUARIO VE (Entidades de Dominio)                │
│                                                             │
│  Curso (Course)                                             │
│    "Quiero los transcripts del curso de Azure AI"           │
│    └── Capitulo (Chapter)                                   │
│         "El capitulo sobre Speech Services"                 │
│         └── Video                                           │
│              "El video de configuracion inicial"            │
│              └── Transcript                                 │
│                   "El texto que dice el instructor"         │
├─────────────────────────────────────────────────────────────┤
│  LO QUE EL USUARIO NO VE (Infraestructura)                  │
│                                                             │
│  - VTTs sin asignar (proceso interno)                       │
│  - Contextos visitados (tracking interno)                   │
│  - Crawls y Batches (operaciones tecnicas)                  │
└─────────────────────────────────────────────────────────────┘
```

**Lenguaje del Usuario:**
- "Capturar un curso" → Ejecutar crawl
- "Capturar una carpeta" → Ejecutar batch
- "Buscar en mis transcripts" → Consulta a la base de datos
- "Preguntar sobre el contenido" → Consulta via LLM

---

## 2. Casos de Uso Principales

### 2.1 CU-001: Captura Pasiva de Transcripciones

**Actor:** Aprendiz Digital
**Trigger:** Usuario navega a un video de LinkedIn Learning
**Precondicion:** Extension instalada y habilitada

**Flujo Principal:**
1. Usuario abre video en LinkedIn Learning
2. LinkedIn carga archivo VTT de subtitulos
3. Extension intercepta y captura el VTT
4. Extension extrae contexto (curso, video, capitulo)
5. Extension envia datos al Native Host
6. Native Host persiste en SQLite
7. Badge muestra contador actualizado

**Flujo Alternativo - Sin subtitulos:**
- Si el video no tiene VTT en idioma preferido, no se captura nada
- [HECHO] Sistema filtra por idioma espanol por defecto

**Estado:** [HECHO] Completamente implementado

---

### 2.2 CU-002: Crawl Automatizado de Curso Completo

**Actor:** Administrador del Sistema
**Trigger:** Usuario inicia crawl via API o linea de comandos
**Precondicion:** Sesion de LinkedIn activa en perfil de Chrome

**Flujo Principal:**
1. Usuario proporciona URL del curso
2. Crawler abre navegador con perfil persistente
3. Crawler navega a tabla de contenidos del curso
4. Para cada video:
   a. Crawler navega al video
   b. Interceptor captura VTT via page.route()
   c. VTT se guarda en unassigned_vtts
   d. Contexto se guarda en visited_contexts
5. Post-crawl: Matching semantico asigna VTTs a videos
6. Transcripciones finales se guardan en transcripts

**Metricas de exito:** [HECHO]
- Tasa de captura: >95% de videos con subtitulos
- Precision de matching: >90%

**Estado:** [HECHO] Completamente implementado (v0.10.0+)

---

### 2.3 CU-003: Batch Crawl de Colecciones/Carpetas

**Actor:** Administrador del Sistema
**Trigger:** Usuario inicia batch via API con URL de carpeta
**Precondicion:** Sesion de LinkedIn activa

**Flujo Principal:**
1. Usuario proporciona URL de coleccion/carpeta/path
2. Folder Parser extrae lista de cursos de la pagina
3. Batch Manager crea cola de cursos
4. Para cada curso en cola:
   a. Ejecutar CU-002 (Crawl de curso)
   b. Esperar delay configurable (rate limiting)
   c. Actualizar progreso
5. Generar reporte de completitud

**Tipos de folders soportados:** [HECHO]
- Collections (`/learning/collections/{id}`)
- Saved Courses (`/learning/me/saved`)
- Learning Paths (`/learning/paths/{slug}`)
- My Learning (`/learning/me`)
- Topics (`/learning/topics/{slug}`)
- Search Results (`/learning/search?keywords=...`)

**Estado:** [HECHO] Completamente implementado (v0.13.0)

---

### 2.4 CU-004: Consulta de Contenido via LLM

**Actor:** LLM Consumidor (ChatGPT/Claude)
**Trigger:** Usuario hace pregunta al LLM sobre contenido de cursos
**Precondicion:** Servidor HTTP o MCP corriendo

**Flujo Principal (ChatGPT):**
1. Usuario hace pregunta en ChatGPT con GPT Action configurado
2. ChatGPT invoca endpoint `/api/ask` con query
3. Server busca en transcripciones
4. Server retorna contexto relevante
5. ChatGPT genera respuesta basada en contenido

**Flujo Principal (Claude Desktop):**
1. Usuario hace pregunta en Claude Desktop
2. Claude usa MCP tool `search_transcripts` o `ask_about_content`
3. MCP Server busca en base de datos
4. Claude genera respuesta basada en contenido

**Estado:** [HECHO] Ambas interfaces funcionales

---

### 2.5 CU-005: Exportacion Manual de Transcripciones

**Actor:** Aprendiz Digital
**Trigger:** Usuario abre popup de extension
**Precondicion:** Hay transcripciones capturadas

**Flujo Principal:**
1. Usuario hace click en icono de extension
2. Popup muestra transcripcion actual
3. Usuario selecciona formato:
   - "Copy with Timestamps" ([MM:SS] texto)
   - "Copy Text Only" (texto plano)
4. Transcripcion se copia al clipboard
5. Usuario pega en LLM de su preferencia

**Estado:** [HECHO] Implementado

---

### 2.6 CU-006: Navegacion y Busqueda de Cursos

**Actor:** LLM Consumidor
**Trigger:** LLM necesita explorar contenido disponible

**Flujos disponibles:**
| Operacion | Endpoint HTTP | MCP Tool | Estado |
|-----------|---------------|----------|--------|
| Listar cursos | GET /api/courses | list_courses | [HECHO] |
| Ver estructura | GET /api/courses/:slug | get_course_structure | [HECHO] |
| Buscar texto | GET /api/search?q= | search_transcripts | [HECHO] |
| Ver transcript | GET /api/videos/:id | get_video_transcript | [HECHO] |
| Comparar videos | - | compare_videos | [HECHO] |
| Ver temas | - | get_topics_overview | [HECHO] |

**Estado:** [HECHO] 11 herramientas MCP disponibles

---

## 3. Propuesta de Valor

### 3.1 Value Proposition Canvas

**Segmento de Cliente:** Profesionales que usan LinkedIn Learning + LLMs

**Jobs to be Done:**
1. [HECHO] **Funcional:** Extraer conocimiento de videos de LinkedIn Learning
2. [HECHO] **Funcional:** Hacer que el contenido sea consultable por IA
3. [HIPOTESIS] **Social:** Demostrar dominio de temas profesionales
4. [HIPOTESIS] **Emocional:** Sentir que aprovecha al maximo su suscripcion

**Pains (Dolores que alivia):**
| Dolor | Como LTE lo alivia | Evidencia |
|-------|-------------------|-----------|
| No hay export nativo en LinkedIn | Captura automatica invisible | [HECHO] |
| Copiar manualmente es tedioso | Crawl automatizado de cursos completos | [HECHO] |
| LLMs no acceden a contenido privado | Servidores HTTP/MCP como puente | [HECHO] |
| Dificil buscar en videos | Busqueda full-text en transcripciones | [HECHO] |
| Rate limiting de LinkedIn | Batch crawl con delays configurables | [HECHO] |

**Gains (Beneficios que entrega):**
| Beneficio | Descripcion | Evidencia |
|-----------|-------------|-----------|
| Biblioteca personal de conocimiento | Transcripciones organizadas por curso | [HECHO] 162 videos, 7 cursos |
| Integracion con IA | ChatGPT y Claude pueden consultar contenido | [HECHO] Funcional |
| Captura sin friccion | Solo navegar, la extension hace el resto | [HECHO] |
| Escalabilidad | Batch crawl de colecciones completas | [HECHO] v0.13.0 |

---

### 3.2 Unique Selling Points

1. **Transparencia total:** La captura ocurre en tu navegador, sin servidores externos
2. **Integracion nativa con LLMs:** MCP para Claude, GPT Actions para ChatGPT
3. **Automatizacion completa:** De 0 a biblioteca personal en un comando
4. **Matching inteligente:** Sistema semantico que asocia correctamente VTTs con videos
5. **Multi-idioma:** Soporte para 47 idiomas de subtitulos (captura completa)

---

## 4. User Journeys

### 4.1 Journey: Primera Captura (Onboarding)

```
Etapa        | Accion Usuario                    | Sistema                          | Emocion
-------------|-----------------------------------|----------------------------------|----------
Descubrimiento| Encuentra proyecto en GitHub     | -                                | Curiosidad
Instalacion  | Clona repo, carga extension       | Setup Native Host                | Ansiedad tecnica
Primer uso   | Abre video LinkedIn Learning      | Captura automatica VTT           | Sorpresa
Verificacion | Abre popup, ve transcripcion      | Muestra contenido parseado       | Satisfaccion
Export       | Copia a ChatGPT, hace pregunta    | -                                | "Wow, funciona!"
Adopcion     | Configura GPT Action              | Servidor HTTP responde           | Empoderado
```

**Momentos criticos:**
- [VERIFICAR CON USUARIO] La instalacion del Native Host puede ser confusa
- [HECHO] El primer "badge +1" genera el momento "aha!"

---

### 4.2 Journey: Crawl de Curso Completo

```
Etapa        | Accion Usuario                    | Sistema                          | Duracion
-------------|-----------------------------------|----------------------------------|----------
Setup        | npm run crawl:setup               | Abre Chrome, login LinkedIn      | 2 min
Inicio       | npm run crawl -- --url "..."      | Navega a curso                   | Instantaneo
Observacion  | Ve navegador automatico           | Reproduce cada video             | 30-60 min/curso
Espera       | Puede hacer otras cosas           | Matching post-crawl              | 2-5 min
Verificacion | curl /api/courses/:slug           | Retorna estructura               | Instantaneo
Consulta     | Pregunta a Claude sobre curso     | MCP responde con contexto        | Segundos
```

**Metricas observadas:** [HECHO]
- Curso promedio: 20-40 videos
- Tiempo por video: ~30 segundos
- Tiempo total por curso: 10-20 minutos

---

### 4.3 Journey: Batch Crawl de Coleccion (v0.13.0)

```
Etapa        | Accion Usuario                    | Sistema                          | Duracion
-------------|-----------------------------------|----------------------------------|----------
Inicio       | POST /api/batch-crawl             | Parsea coleccion, crea cola      | 1-2 min
Monitoreo    | GET /api/batch-crawl/:id/status   | Retorna progreso                 | -
(Opcional)   | POST /api/batch-crawl/:id/pause   | Pausa despues de curso actual    | -
Espera       | Desconectarse si desea            | Proceso continua independiente   | Horas
Verificacion | GET /api/courses                  | Lista cursos nuevos              | Instantaneo
```

**Caso real documentado:** [HECHO]
- Coleccion "Expectations": 11 items
- 6 cursos reales procesados
- 114 videos procesados, 86 guardados
- 4 cursos nuevos en BD

---

## 5. Flujos de Usuario Detallados

### 5.1 Flujo: Captura Pasiva (Extension)

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  LinkedIn   │     │  Extension  │     │ Native Host │     │   SQLite    │
│  Learning   │     │  Chrome     │     │   Node.js   │     │   Database  │
└──────┬──────┘     └──────┬──────┘     └──────┬──────┘     └──────┬──────┘
       │                   │                   │                   │
       │ GET video.vtt     │                   │                   │
       │──────────────────>│                   │                   │
       │                   │                   │                   │
       │ Response: VTT     │                   │                   │
       │<──────────────────│                   │                   │
       │                   │                   │                   │
       │                   │ webRequest.onCompleted                │
       │                   │───────┐           │                   │
       │                   │       │ Intercepta│                   │
       │                   │<──────┘           │                   │
       │                   │                   │                   │
       │                   │ fetch(vtt_url)    │                   │
       │                   │───────┐           │                   │
       │                   │       │ Descarga  │                   │
       │                   │<──────┘           │                   │
       │                   │                   │                   │
       │                   │ Native Message    │                   │
       │                   │ {type: SAVE_*}    │                   │
       │                   │──────────────────>│                   │
       │                   │                   │                   │
       │                   │                   │ INSERT transcript │
       │                   │                   │──────────────────>│
       │                   │                   │                   │
       │                   │                   │ OK                │
       │                   │                   │<──────────────────│
       │                   │                   │                   │
       │                   │ Response: OK      │                   │
       │                   │<──────────────────│                   │
```

---

### 5.2 Flujo: Consulta via ChatGPT

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Usuario   │     │   ChatGPT   │     │ HTTP Server │     │   SQLite    │
│             │     │ GPT Action  │     │  Express.js │     │   Database  │
└──────┬──────┘     └──────┬──────┘     └──────┬──────┘     └──────┬──────┘
       │                   │                   │                   │
       │ "Que dice el      │                   │                   │
       │  curso sobre X?"  │                   │                   │
       │──────────────────>│                   │                   │
       │                   │                   │                   │
       │                   │ POST /api/ask     │                   │
       │                   │ {query: "X"}      │                   │
       │                   │──────────────────>│                   │
       │                   │                   │                   │
       │                   │                   │ SELECT ... LIKE   │
       │                   │                   │──────────────────>│
       │                   │                   │                   │
       │                   │                   │ [transcripts]     │
       │                   │                   │<──────────────────│
       │                   │                   │                   │
       │                   │ {context, sources}│                   │
       │                   │<──────────────────│                   │
       │                   │                   │                   │
       │ "Segun el curso   │                   │                   │
       │  de AI Speech..." │                   │                   │
       │<──────────────────│                   │                   │
```

---

## 6. Glosario de Terminos de Negocio

### Conceptos de Dominio

| Termino | Definicion | Ejemplo |
|---------|------------|---------|
| **Transcript** | Texto completo de subtitulos de un video | "Hoy hablaremos de Azure AI..." |
| **VTT** | Formato de archivo de subtitulos (Web Video Text Tracks) | archivo .vtt con timestamps |
| **Caption** | Segmento individual de texto con timestamp | [00:05] "Bienvenidos al curso" |
| **Course** | Curso de LinkedIn Learning | "Azure AI for Developers" |
| **Video** | Leccion individual dentro de un curso | "Introduction to AI Speech" |
| **Chapter** | Agrupacion de videos dentro de un curso | "Module 1: Getting Started" |
| **Collection** | Carpeta de LinkedIn con cursos guardados | "My AI Learning Path" |
| **Slug** | Identificador URL-friendly | "azure-ai-for-developers-azure-ai-speech" |

### Conceptos Tecnicos

| Termino | Definicion | Rol en Sistema |
|---------|------------|----------------|
| **Native Host** | Proceso Node.js que recibe mensajes de la extension | Persistencia en SQLite |
| **Native Messaging** | Protocolo de Chrome para comunicar extension con proceso local | Puente extension-backend |
| **Deferred Matching** | Sistema que asocia VTTs con videos post-captura | Precision de asignacion |
| **Semantic Matching** | Algoritmo que compara keywords entre titulo y contenido | Primera fase de matching |
| **MCP** | Model Context Protocol - estandar para conectar LLMs con datos | Integracion Claude Desktop |
| **GPT Action** | Plugin de ChatGPT que llama APIs externas | Integracion ChatGPT |
| **Batch Crawl** | Proceso de crawl de multiples cursos en secuencia | Automatizacion masiva |
| **Rate Limiting** | Delay entre requests para evitar bloqueos | 30-60s entre cursos |

### Metricas de Negocio

| Metrica | Definicion | Target |
|---------|------------|--------|
| **Tasa de Captura** | % videos con subtitulos capturados exitosamente | >95% |
| **Precision de Matching** | % VTTs asignados al video correcto | >90% |
| **Calidad de Transcript** | % transcripts sin artefactos | >98% |
| **Tiempo por Curso** | Minutos para crawlear curso completo | 10-20 min |

---

## 7. Criterios de Exito del Producto

### 7.1 Criterios Funcionales [HECHO - Documentados]

| Criterio | Target | Estado Actual |
|----------|--------|---------------|
| Confiabilidad de deteccion | >95% | [HECHO] Funcional |
| Usabilidad de export | <=2 clicks | [HECHO] 2 botones en popup |
| Calidad de transcripts | >98% sin artefactos | [HECHO] VTT nativo |
| Test coverage | >70% | [HECHO] 79.29% |

### 7.2 Criterios No Funcionales

| Criterio | Target | Estado | Evidencia |
|----------|--------|--------|-----------|
| Tiempo de captura | <5s por video | [HECHO] | Intercepcion automatica |
| Persistencia | Sobrevive restart | [HECHO] | SQLite + backup |
| Integracion LLM | ChatGPT + Claude | [HECHO] | HTTP + MCP servers |
| Escalabilidad | >100 videos | [HECHO] | 162 videos en BD |

---

## 8. Puntos Pendientes de Validacion

### [VERIFICAR CON USUARIO]

1. **Perfil de usuario tipico:**
   - Es correcto que el usuario objetivo es un profesional tecnico?
   - Cual es el nivel de comfort esperado con linea de comandos?

2. **Casos de uso no documentados:**
   - Hay otros LLMs o plataformas que se desean soportar?
   - Existe necesidad de compartir transcripciones entre usuarios?

3. **Roadmap de producto:**
   - El MVP actual satisface las necesidades principales?
   - Cual es la prioridad relativa de features pendientes?

4. **Modelo de uso:**
   - Es predominantemente uso personal o hay escenarios de equipo?
   - Existe necesidad de sincronizacion entre dispositivos?

---

## 9. Proximos Pasos Recomendados

### Corto Plazo (Sprint Actual)
1. [PENDIENTE] LTE-005: Manejo de errores robusto
2. [PENDIENTE] Documentar flujo de onboarding para usuarios nuevos

### Mediano Plazo
1. [BACKLOG] Export multi-formato (LTE-016)
2. [BACKLOG] Busqueda avanzada en transcripts (LTE-018)

### Largo Plazo
1. [HIPOTESIS] Soporte para otras plataformas de video (Coursera, Udemy)
2. [HIPOTESIS] Sincronizacion cloud de biblioteca personal

---

**Documento generado:** 2026-01-29
**Fuentes:** CLAUDE.md, PRODUCT_BACKLOG.md, ARCHITECTURE_ANALYSIS.md, README.md, TASK_STATE.md
**Proximo review:** Despues de Sprint N+1
