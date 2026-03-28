# WhatsApp Automation - Documento Semilla
**Origen:** Exploracion en workspace (sesion 2026-03-28, archivo 4d64fa54)
**Objetivo:** Automatizar interacciones con WhatsApp personal: leer chats y enviar mensajes individuales

---

## Contexto de la Exploracion

El usuario quiere un sistema para:
1. **Leer** contenido de chats (links, mensajes de interes) del WhatsApp personal
2. **Publicar/enviar** mensajes individuales a contactos (no masivo)
3. Caso de uso inicial: extraer links del self-chat y procesarlos automaticamente

---

## Hallazgos de la Exploracion

### El problema central
No existe forma oficial de leer chats personales. Las APIs oficiales (WhatsApp Cloud API, Twilio, GreenAPI) solo funcionan con cuentas Business y NO acceden a chats personales.

### Opciones investigadas

| Opcion | Lee chats? | Envia? | Riesgo ban | Notas |
|--------|-----------|--------|------------|-------|
| Playwright + WhatsApp Web | Si (DOM) | Si (clicks) | Bajo si es moderado | Ya probado, funciona |
| whatsapp-web.js | Si | Si | Medio | Node.js, reverse engineering |
| Baileys | Si | Si | Medio-alto | Node.js, mas activo que wwjs |
| lharries/whatsapp-mcp | Si | Si | Medio | Go + whatsmeow, expone MCP tools |
| WhatsApp Cloud API | No (personal) | Solo Business | Ninguno | Oficial, no aplica |

### Lo que ya se implemento (Fase 1 - Playwright)

1. **Extraccion de links:** Playwright MCP abre WhatsApp Web headless, navega al self-chat, extrae links via JavaScript del DOM. **Funciono perfectamente** - extrajo 8 links.

2. **JSON de salida:** `whatsapp_linkedin_links.json` creado en `C:/CLAUDE_CONTEXT/personal/workspace/` con 7 links de LinkedIn + evaluaciones de cada post via agente.

3. **Eliminacion de mensajes:** Se implemento el flujo de seleccion multiple + delete en WhatsApp Web. Funciono pero la sesion se interrumpio a mitad del proceso (quedaron ~5 mensajes por eliminar).

### Estado del archivo de links

Archivo `whatsapp_linkedin_links.json` en workspace contiene 7 posts de LinkedIn con:
- URL, autor, topic_hint
- `evaluated: true` con texto de evaluacion en todos
- `deleted_from_whatsapp: false` en todos (la eliminacion no se completo)

---

## Plan de Proyecto Propuesto

### Fase 1 (Completada parcialmente): Playwright + WhatsApp Web
- [x] Extraccion de links del self-chat
- [x] Evaluacion de contenido via agentes paralelos
- [x] Guardado en JSON
- [ ] Completar eliminacion de mensajes procesados de WhatsApp
- [ ] Autenticacion persistente (sesion guardada para no re-escanear QR)

### Fase 2: MCP Tool para WhatsApp
- Exponer las capacidades como MCP tool para Claude Code
- Tools propuestas: `wa_get_links`, `wa_send_message`, `wa_delete_message`
- Base: lharries/whatsapp-mcp (Go) o implementacion custom con Playwright

### Fase 3: Automatizacion pipeline
- Trigger automatico al recibir links en self-chat
- Pipeline: recibir -> evaluar -> guardar -> notificar
- Posible integracion con Atlas agent

---

## Decisiones de Diseno

- **Playwright como primera opcion** por bajo riesgo de ban y reutilizacion de infra existente
- **No usar Baileys/whatsapp-web.js** como primera opcion (riesgo de ban mayor)
- **Self-chat como canal de entrada** (mensajes a si mismo = bajo riesgo)
- **Envios individuales** solamente, nunca masivos
- **Sesion persistente** para evitar re-escanear QR en cada uso

---

## Stack Tecnico

- **Runtime:** Node.js (si se usa Baileys) o Python (si se usa Playwright)
- **Browser automation:** Playwright (ya instalado y configurado como MCP)
- **Storage:** JSON/SQLite para persistir links y estado
- **MCP:** Exponer como tools cuando se estabilice la Fase 1

---

## Links de Referencia

- lharries/whatsapp-mcp: https://github.com/lharries/whatsapp-mcp
- Baileys: https://github.com/WhiskeySockets/Baileys
- whatsapp-web.js: https://github.com/pedroslopez/whatsapp-web.js

---

## Archivo de datos existente

`C:/CLAUDE_CONTEXT/personal/workspace/whatsapp_linkedin_links.json`
- 7 posts LinkedIn evaluados
- Pendiente: marcar deleted_from_whatsapp = true cuando se completen las eliminaciones

---

## Instruccion importante para el agente que tome este proyecto

**NO continuar con la eliminacion de mensajes de WhatsApp por ahora.** Esa tarea queda pausada hasta nueva instruccion del usuario. El archivo `whatsapp_linkedin_links.json` ya tiene los links evaluados y guardados - ese objetivo esta cumplido.

Enfocarse en: disenar la arquitectura del proyecto, el backlog, y la estructura de carpetas. La eliminacion de mensajes se retomara en una sesion posterior cuando el usuario lo indique.
