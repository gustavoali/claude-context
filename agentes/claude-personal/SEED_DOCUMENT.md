# Claude Personal - Seed Document

**Fecha de consolidacion:** 2026-02-21
**Fuente:** VISION.md

---

## 1. Vision

Claude Personal es un asistente personal de proposito general via CLI. A diferencia de Claude Code (desarrollo de software) y Claude Cowork (interfaz web), Claude Personal es un asistente de vida cotidiana en terminal con acceso profundo al sistema, integraciones con servicios personales y sin restricciones de dominio.

**Pitch:** "Tu asistente personal en la terminal. Gestiona archivos, agenda, mails, notas y cualquier tarea del dia a dia."

---

## 2. Stack

- **Lenguaje:** C# / .NET 8+
- **Tipo:** CLI application (console app)
- **Core:** Harness sobre Anthropic API (Messages API + Tool Use)
- **Auth:** Soporte dual - API Key de Anthropic + suscripcion personal (Max/Pro)
- **Persistencia:** SQLite para historial, memoria, preferencias
- **Config:** JSON en ~/.claude-personal/
- **Plugins:** Sistema modular de tools

---

## 3. Arquitectura

```
CLI Interface (System.CommandLine / Spectre.Console)
  -> Conversation Engine (contexto, memoria, tools)
    -> Anthropic API Client (Messages + Tool Use + streaming)
      -> Tool Registry + Tool Implementations
```

### Componentes

| Componente | Responsabilidad |
|------------|-----------------|
| CLI Shell | Input/output, rendering, autocompletado, historial |
| Conversation Engine | Contexto, system prompts, memoria persistente |
| API Client | Comunicacion con Anthropic, tool_use, streaming |
| Tool Registry | Registro y descubrimiento de tools |
| Tool Implementations | Cada integracion como tool independiente |
| Config Manager | Preferencias, API keys, settings de tools |
| Memory Store | Historial, facts aprendidos, preferencias inferidas |

---

## 4. Integraciones (Tools por Tier)

### Tier 1 - MVP
- FileSystem (buscar, leer, mover, copiar, organizar)
- Clipboard (leer/escribir)
- SystemInfo (sistema, procesos, disco, RAM)
- Shell (ejecutar comandos)
- WebSearch (busqueda web)
- WebFetch (leer URLs)
- Calculator (calculos y conversiones)
- DateTime (fechas, zonas horarias, countdowns)

### Tier 2 - Productividad
- Google Calendar, Gmail, Google Drive
- Outlook/O365 (Microsoft Graph)
- Notion
- Todoist/Trello
- Contacts

### Tier 3 - Lifestyle
- WhatsApp, Spotify, Weather, Finance, Reminders
- Screenshots, OCR, Translate, Password Manager
- RSS/News, Bookmarks, Health/Fitness

### Tier 4 - Smart Home / IoT
- Home Assistant, Alarmas

---

## 5. Modos de Uso

- **Interactivo (chat):** `claude-personal` -> prompt CP>
- **Comando (one-shot):** `claude-personal ask "que clima hace?"`
- **Pipe (stdin/stdout):** `cat doc.txt | claude-personal ask "resumime"`

---

## 6. Autenticacion

- **Opcion A:** API Key de Anthropic (pago por uso)
- **Opcion B:** Suscripcion personal Claude Max/Pro (OAuth/session token)
- **Opcion C:** Hibrido (suscripcion primero, fallback a API key)

---

## 7. Memoria

- **Corto plazo:** Contexto de conversacion con compresion automatica
- **Largo plazo:** SQLite local - facts, preferencias, historial buscable
- **Explícita:** `CP> recorda que mi dentista es el Dr. Perez`

---

## 8. Seguridad

- Todo local (datos en la maquina del usuario)
- Encriptacion opcional de la DB de memoria
- Permisos granulares por tool (read-only, read-write, disabled)
- Confirmacion para acciones destructivas o de envio
- Audit log local
- Secrets en credential manager del OS

---

## 9. MVP

**Incluido:**
- CLI interactivo + comando + pipe
- Auth con API key
- Tools Tier 1 (8 tools)
- Memoria basica (facts, preferencias)
- Historial de conversaciones
- Config JSON
- Streaming

**Excluido:**
- Auth via suscripcion personal
- Integraciones Tier 2-4
- Encriptacion de DB
- Plugins de terceros
- Auto-update

---

## 10. Estructura del Proyecto

```
claude-personal/
  src/
    ClaudePersonal.CLI/
    ClaudePersonal.Core/
    ClaudePersonal.Tools/
    ClaudePersonal.Tools.Google/      # Tier 2
    ClaudePersonal.Tools.Microsoft/   # Tier 2
  tests/
    ClaudePersonal.Core.Tests/
    ClaudePersonal.Tools.Tests/
  docs/
```

---

## 11. Riesgos

| Riesgo | Mitigacion |
|--------|-----------|
| Auth con suscripcion puede no ser viable | Empezar con API key |
| Scope creep con integraciones | MVP estricto Tier 1 |
| Seguridad del filesystem | Permisos granulares + confirmacion + audit |
| Rate limits API | Cache + compresion de contexto |
| Privacidad (datos a la API) | Disclaimer + filtrado opcional de datos sensibles |
