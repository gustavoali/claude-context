# Seed Document - MCP WhatsApp Research

**Fuente:** IDEA-047: Investigar MCP Servers existentes para WhatsApp
**Fecha:** 2026-03-06

---

## Objetivo

Investigar, evaluar y documentar el ecosistema de MCP servers para WhatsApp. Mantener un registro actualizado de alternativas, restricciones de la plataforma (Business API, ventana 24h, templates), costos, y viabilidad para agentes autonomos.

## Alcance

- Relevamiento periodico de MCP servers para WhatsApp (oficiales y no oficiales)
- Evaluacion de la WhatsApp Business API y sus restricciones
- Analisis de costos comparados con Telegram
- Monitoreo de cambios en politicas de Meta que afecten viabilidad
- Documentacion de patrones de integracion MCP + WhatsApp
- Evaluacion de riesgo de ban en APIs no oficiales

## Estado Inicial (2026-03-06)

### Hallazgos clave

- 9 MCP servers encontrados (mayoría APIs no oficiales con riesgo de ban)
- El mas popular: lharries/whatsapp-mcp (3.3k stars, whatsmeow, no oficial)
- Unica opcion oficial: wati-io via Business API (~$44/mes)
- Recomendacion: NO viable para Atlas Agent (ventana 24h, templates, costos)
- Reevaluar si Meta cambia politicas

### Candidatos relevantes

| Proyecto | Stars | API | Riesgo ban |
|----------|-------|-----|------------|
| lharries/whatsapp-mcp | 3.3k | whatsmeow (no oficial) | Alto |
| jlucaso1/whatsapp-mcp-ts | Popular | Baileys (no oficial) | Alto |
| FelixIsaac/whatsapp-mcp-extended | Menor | whatsmeow (41 tools) | Alto |
| dudu1111685/waha-mcp | Menor | WAHA Docker (62 tools) | Medio-alto |
| wati-io/whatsapp-api-mcp-server | Comercial | Business API oficial | Bajo |

### Restricciones criticas de WhatsApp para agentes autonomos

1. Ventana de 24h: fuera de ella, solo templates pre-aprobados por Meta
2. Max 3 reply buttons (vs inline keyboard ilimitado en Telegram)
3. Costo ~$44/mes vs $0 en Telegram
4. Verificacion de empresa requerida para Business API
5. APIs no oficiales: ban creciente en 2025-2026

## Entregables

- `FINDINGS.md` - Hallazgos detallados con analisis de APIs
- `CANDIDATES.md` - Registro de candidatos evaluados (actualizable)
- `COST_ANALYSIS.md` - Analisis de costos comparativo
- `RECOMMENDATIONS.md` - Recomendaciones y decisiones
- Actualizaciones cuando Meta cambie politicas o surjan nuevos servers

## Proyectos Relacionados

- Atlas Agent (C:/agents/atlas-agent) - consumer potencial
- IDEA-046 / mcp-telegram-research - investigacion hermana (Telegram)
- IDEA-012 - investigacion general de MCP servers
