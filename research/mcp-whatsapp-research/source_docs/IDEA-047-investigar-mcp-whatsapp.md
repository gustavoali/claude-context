# IDEA-047: Investigar MCP Servers existentes para WhatsApp

**Fecha:** 2026-03-06
**Categoria:** general
**Estado:** Evaluated
**Prioridad:** Alta

---

## Descripcion

Investigar si existen MCP servers que provean integracion con WhatsApp (via WhatsApp Business API, Twilio, o similares), como canal alternativo o complementario a Telegram para comunicacion con el usuario desde agentes autonomos.

## Motivacion

Telegram es el canal actual de Atlas Agent, pero WhatsApp tiene mucha mayor penetracion en Argentina y Latinoamerica. Si existe un MCP server para WhatsApp, se podria ofrecer al usuario elegir el canal de comunicacion, o incluso usar ambos.

## Resultado de la Investigacion

### MCP Servers encontrados

| Proyecto | Stars | API usada | Tipo | Riesgo |
|----------|-------|-----------|------|--------|
| lharries/whatsapp-mcp | 3.3k | whatsmeow (no oficial) | Cuenta personal, QR scan | Ban alto |
| jlucaso1/whatsapp-mcp-ts | Popular | Baileys (no oficial) | Cuenta personal, QR scan | Ban alto |
| FelixIsaac/whatsapp-mcp-extended | Menor | whatsmeow (fork) | 41 tools, muy completo | Ban alto |
| dudu1111685/waha-mcp | Menor | WAHA (self-hosted Docker) | 62 tools, 3 motores | Ban medio-alto |
| wati-io/whatsapp-api-mcp-server | Comercial | Business API oficial | Empresa respaldada | Ban bajo |
| msaelices/whatsapp-mcp-server | Menor | GreenAPI (servicio pago) | Python, HTTP/SSE | Ban bajo |

### Comparacion WhatsApp vs Telegram para agente autonomo

| Criterio | Telegram | WhatsApp |
|----------|----------|----------|
| Costo | Gratis | ~$44/mes (Business API via WATI) |
| Setup | BotFather, 2 min | Verificacion empresa, dias/semanas |
| Mensajes proactivos | Sin restriccion | Solo templates aprobados fuera de ventana 24h |
| Botones interactivos | Inline keyboard (N botones) | Max 3 reply buttons |
| Riesgo de ban (API no oficial) | Nulo | Alto (reportes crecientes 2025-2026) |
| Riesgo de ban (API oficial) | N/A | Bajo pero requiere empresa verificada |

### Costos estimados

| Opcion | Costo/mes |
|--------|-----------|
| Telegram (actual) | $0 |
| WhatsApp Business API (WATI) | ~$44 (plataforma + mensajes) |
| WhatsApp no oficial (Baileys/WAHA) | $0-19 + riesgo operacional de ban |

### Recomendacion: NO VIABLE para Atlas Agent

1. **Ventana de 24h + templates obligatorios** destruyen la autonomia del agente. Un agente que reporta progreso proactivamente cada 30 min necesita poder enviar mensajes sin restricciones.
2. **Costo innecesario** (~$44/mes) vs $0 con Telegram, sin beneficio funcional.
3. **APIs no oficiales** (Baileys, whatsmeow) tienen riesgo de ban inaceptable para sistema 24/7.
4. **Complejidad de setup** vs BotFather en 2 minutos.

### Cuando reevaluar

- Si Meta elimina la ventana de 24h o templates obligatorios
- Si el agente necesita comunicarse con usuarios que NO usan Telegram
- Si se usa para caso profesional/cliente donde WhatsApp es requisito del negocio

## Proyectos Relacionados

- Atlas Agent (C:/agents/atlas-agent) - consumer potencial
- IDEA-043: Agente autonomo sobre Orchestrator con Telegram
- IDEA-046: Investigar MCP Telegram

---

## Historial

| Fecha | Evento |
|-------|--------|
| 2026-03-06 | Idea capturada, investigacion en background |
| 2026-03-06 | Investigacion completada. Resultado: no viable para Atlas Agent, mantener Telegram |
