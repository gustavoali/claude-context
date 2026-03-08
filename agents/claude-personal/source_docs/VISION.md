# Claude Personal - Vision Document

**Fecha:** 2026-02-21
**Estado:** Draft
**Autor:** gdali + Claude

---

## 1. Vision

Claude Personal es un asistente personal de proposito general que funciona via CLI. A diferencia de Claude Code (orientado a desarrollo de software) y Claude Cowork (interfaz web), Claude Personal es un asistente de vida cotidiana accesible desde la terminal, con acceso profundo al sistema de archivos, integraciones con servicios personales y sin restricciones de dominio.

### Pitch
"Tu asistente personal en la terminal. Gestiona archivos, agenda, mails, notas y cualquier tarea del dia a dia, con la inteligencia de Claude y el poder de la linea de comandos."

### Diferenciacion

| Producto | Foco | Interfaz | Limitaciones |
|----------|------|----------|-------------|
| Claude Code | Desarrollo de software | CLI | Solo tareas de ingenieria |
| Claude Cowork | Asistente general | Web | Requiere browser, sin acceso local profundo |
| **Claude Personal** | Vida personal + productividad | CLI | Ninguna restriccion de dominio |

---

## 2. Stack Tecnologico

- **Lenguaje:** C# / .NET 8+
- **Tipo:** CLI application (console app)
- **Core:** Harness sobre Anthropic API (Claude)
- **Autenticacion API:** Soporte dual:
  - API Key de Anthropic (pago por uso)
  - Suscripcion personal de Claude (Max/Pro) via OAuth o session token
- **Persistencia local:** SQLite para historial, preferencias, cache
- **Configuracion:** JSON/YAML en ~/.claude-personal/
- **Plugins/Integraciones:** Sistema modular de tools

---

## 3. Arquitectura

```
┌─────────────────────────────────────────────┐
│                 CLI Interface                │
│        (System.CommandLine / Spectre)        │
├─────────────────────────────────────────────┤
│              Conversation Engine             │
│     (contexto, memoria, historial, tools)    │
├─────────────────────────────────────────────┤
│              Anthropic API Client            │
│      (Messages API + Tool Use Protocol)      │
├────────┬────────┬────────┬────────┬─────────┤
│ Files  │Calendar│ Mail   │ Notes  │  ...    │
│ Tool   │ Tool   │ Tool   │ Tool   │ Tools   │
└────────┴────────┴────────┴────────┴─────────┘
```

### Componentes principales

| Componente | Responsabilidad |
|------------|-----------------|
| **CLI Shell** | Input/output, rendering, autocompletado, historial de comandos |
| **Conversation Engine** | Gestiona el contexto de conversacion, system prompts, memoria persistente |
| **API Client** | Comunicacion con Anthropic API, manejo de tool_use, streaming |
| **Tool Registry** | Registro y descubrimiento de tools disponibles |
| **Tool Implementations** | Cada integracion como un tool independiente |
| **Config Manager** | Preferencias del usuario, API keys, settings de tools |
| **Memory Store** | Historial de conversaciones, datos aprendidos, preferencias inferidas |

---

## 4. Integraciones (Tools)

### Tier 1 - MVP (Core)

| Tool | Descripcion | Implementacion |
|------|-------------|----------------|
| **FileSystem** | Buscar, leer, mover, copiar, organizar archivos | System.IO + glob patterns |
| **Clipboard** | Leer/escribir clipboard del sistema | Windows API / xclip |
| **SystemInfo** | Info del sistema, procesos, disco, RAM | System.Diagnostics |
| **Shell** | Ejecutar comandos del sistema | Process.Start |
| **WebSearch** | Buscar en la web | API de busqueda (Brave, Google) |
| **WebFetch** | Leer contenido de URLs | HttpClient + HTML-to-text |
| **Calculator** | Calculos matematicos y conversiones | Built-in |
| **DateTime** | Fechas, zonas horarias, countdowns | Built-in |

### Tier 2 - Post-MVP (Productividad)

| Tool | Descripcion | Implementacion |
|------|-------------|----------------|
| **Google Calendar** | Ver, crear, modificar eventos | Google Calendar API |
| **Google Mail** | Leer, buscar, redactar mails | Gmail API |
| **Google Drive** | Acceder a documentos en la nube | Google Drive API |
| **Outlook/O365** | Calendario + mail de Microsoft | Microsoft Graph API |
| **Notion** | Notas, bases de datos, wikis | Notion API |
| **Todoist/Trello** | Gestion de tareas personales | API respectiva |
| **Contacts** | Agenda de contactos | Google Contacts API / vCard |

### Tier 3 - Avanzado (Lifestyle)

| Tool | Descripcion | Implementacion |
|------|-------------|----------------|
| **WhatsApp** | Leer/enviar mensajes (via WhatsApp Business API o bridge) | API/Bridge |
| **Spotify** | Control de musica, playlists | Spotify API |
| **Weather** | Clima actual y pronostico | OpenWeatherMap API |
| **Finance** | Tracking de gastos, presupuesto | CSV/Excel import + SQLite |
| **Reminders** | Recordatorios con notificaciones del OS | Windows Task Scheduler |
| **Screenshots** | Capturar y analizar pantalla | Windows API |
| **OCR** | Extraer texto de imagenes/PDFs | Tesseract / Azure Vision |
| **Translate** | Traduccion de textos | DeepL API / built-in Claude |
| **Password Manager** | Consultar passwords (read-only) | Bitwarden CLI |
| **RSS/News** | Feed de noticias personalizado | RSS parser |
| **Bookmarks** | Gestionar bookmarks del browser | Chrome/Firefox bookmarks file |
| **Health/Fitness** | Tracking de habitos, ejercicio | CSV/manual input |

### Tier 4 - Smart Home / IoT

| Tool | Descripcion | Implementacion |
|------|-------------|----------------|
| **Home Assistant** | Control de dispositivos smart home | Home Assistant API |
| **Alarmas** | Configurar alarmas y timers | OS integration |

---

## 5. Modos de Autenticacion con Claude

### Opcion A: API Key de Anthropic
```
claude-personal config set api-key sk-ant-xxxxx
```
- Pago por uso (por tokens)
- Sin limites de rate (segun plan)
- Acceso a todos los modelos

### Opcion B: Suscripcion Personal (Claude Max/Pro)
```
claude-personal auth login
```
- Usa la suscripcion existente del usuario
- Autenticacion via OAuth o session token del browser
- Aprovecha los tokens incluidos en el plan

### Opcion C: Hibrido
- Usa suscripcion para uso cotidiano
- Fallback a API key cuando se agotan tokens de suscripcion
- Configurable por el usuario

---

## 6. Experiencia de Usuario (CLI)

### Modo interactivo (chat)
```
$ claude-personal
CP> busca fotos de mi dni en descargas
Encontre 2 archivos en Downloads/Documentos_Personales/:
  - frente-dni.jpeg (84 KB, 5 feb 2026)
  - detras-dni.jpeg (45 KB, 5 feb 2026)
Queres que los copie a alguna otra carpeta?

CP> que tengo en la agenda para manana?
Manana tenes 3 eventos:
  09:00 - Daily standup (Teams)
  14:00 - Dentista (Av. Corrientes 1234)
  20:00 - Cena con amigos (La Parolaccia)

CP> redactame un mail para el dentista cancelando el turno
```

### Modo comando (one-shot)
```
$ claude-personal ask "que clima hace hoy en buenos aires?"
$ claude-personal files find "contrato alquiler" --in ~/Downloads
$ claude-personal calendar tomorrow
$ claude-personal mail unread --from "banco"
```

### Modo pipe (stdin/stdout)
```
$ cat documento.txt | claude-personal ask "resumime esto"
$ claude-personal ask "genera un CSV de gastos del mes" > gastos.csv
```

---

## 7. Memoria y Contexto

### Memoria de corto plazo
- Contexto de la conversacion actual (ventana de tokens)
- Compresion automatica de mensajes antiguos

### Memoria de largo plazo
- SQLite local con datos aprendidos del usuario
- Preferencias inferidas (horarios, contactos frecuentes, ubicaciones)
- Historial de conversaciones buscable
- Facts explicitamente guardados por el usuario

```
CP> recorda que mi dentista es el Dr. Perez, Av. Corrientes 1234
Guardado.

CP> cual es mi dentista?
Tu dentista es el Dr. Perez, en Av. Corrientes 1234.
```

---

## 8. Seguridad y Privacidad

- **Todo local:** La data del usuario vive en su maquina, no en la nube (excepto lo que va a la API de Claude)
- **Encriptacion:** La base de datos de memoria se puede encriptar con password
- **Permisos granulares:** Cada tool tiene permisos configurables (read-only, read-write, disabled)
- **Confirmacion:** Acciones destructivas o de envio (mail, mensajes) requieren confirmacion
- **Audit log:** Log local de todas las acciones ejecutadas por tools
- **Secrets management:** API keys y tokens en credential manager del OS, no en archivos planos

---

## 9. MVP - Alcance

### Incluido en MVP
- CLI interactivo + modo comando + modo pipe
- Autenticacion con API key de Anthropic
- Tools Tier 1: FileSystem, Clipboard, Shell, WebSearch, WebFetch, Calculator, DateTime, SystemInfo
- Memoria de largo plazo basica (facts, preferencias)
- Historial de conversaciones
- Configuracion via JSON
- Streaming de respuestas

### Excluido del MVP
- Autenticacion via suscripcion personal
- Integraciones Tier 2-4 (calendario, mail, etc.)
- Encriptacion de base de datos
- Plugins de terceros
- Auto-update

---

## 10. Estructura del Proyecto (Propuesta)

```
claude-personal/
  src/
    ClaudePersonal.CLI/           # Entry point, shell, rendering
    ClaudePersonal.Core/          # Conversation engine, API client, memory
    ClaudePersonal.Tools/         # Tool implementations (cada tool en subcarpeta)
    ClaudePersonal.Tools.Google/  # Google integrations (Tier 2)
    ClaudePersonal.Tools.Microsoft/ # Microsoft integrations (Tier 2)
  tests/
    ClaudePersonal.Core.Tests/
    ClaudePersonal.Tools.Tests/
  docs/
  README.md
```

---

## 11. Competencia y Diferenciacion

| Producto | Pros | Contras vs Claude Personal |
|----------|------|---------------------------|
| Claude Code | Potente para dev | Solo software engineering |
| Claude Cowork | Interfaz web amigable | Sin acceso local, requiere browser |
| Siri/Cortana/Alexa | Voice-first, integrado al OS | Limitados en inteligencia, vendor lock |
| ChatGPT Desktop | UI nativa | Sin acceso profundo a archivos, tools limitados |
| Aider/Continue | Dev tools | Solo codigo |
| **Claude Personal** | CLI potente, acceso total al sistema, extensible, privado | Requiere terminal (no es para todos) |

---

## 12. Riesgos

| Riesgo | Mitigacion |
|--------|-----------|
| Autenticacion con suscripcion personal puede no ser viable/legal | Empezar con API key, investigar opciones |
| Scope creep con tantas integraciones | MVP estricto con Tier 1, el resto va post-MVP |
| Seguridad al dar acceso amplio al filesystem | Permisos granulares + confirmacion + audit log |
| Rate limits de la API | Cache inteligente, compresion de contexto |
| Privacidad al enviar datos personales a la API | Disclaimer claro, opcion de filtrar datos sensibles |

---

## 13. Proximos Pasos

1. Revisar y aprobar este documento
2. `/sembrar` con este documento como fuente
3. `/brotar` para arquitectura detallada y backlog
4. Sprint 1: CLI shell + API client + FileSystem tool + memoria basica
