# Backlog - WhatsApp Automation
**Version:** 0.1 | **Actualizacion:** 2026-03-28

## Resumen
| Metrica | Valor |
|---------|-------|
| Total historias | 8 |
| Completadas | 1 |
| En progreso | 0 |
| Pendientes | 7 |

## Vision
Sistema de automatizacion personal de WhatsApp via Playwright.
Permite leer chats, extraer links, enviar mensajes individuales y (futuro) exponer como MCP tools.
Enfoque: bajo riesgo de ban, uso moderado, solo cuentas personales.

## Epics
| Epic | Historias | Puntos | Status |
|------|-----------|--------|--------|
| EPIC-01: Playwright Core | WA-001 a WA-004 | 13 | En progreso |
| EPIC-02: MCP Tools | WA-005 a WA-007 | 8 | Pendiente |
| EPIC-03: Pipeline Automatico | WA-008 | 5 | Pendiente |

## Pendientes (con detalle)

### WA-001: Sesion persistente con Playwright
**Points:** 3 | **Priority:** High | **Epic:** EPIC-01
Como usuario, quiero que WhatsApp Web mantenga la sesion entre ejecuciones para no re-escanear QR.
**AC:**
- Given: primera ejecucion, When: se abre WhatsApp Web, Then: se guarda estado de sesion en disco
- Given: segunda ejecucion, When: existe sesion guardada, Then: se carga sin pedir QR
- Given: sesion expirada, When: se detecta logout, Then: se solicita re-escaneo y se guarda nueva sesion

### WA-002: Extraccion de links del self-chat
**Points:** 2 | **Priority:** High | **Epic:** EPIC-01
Como usuario, quiero extraer automaticamente todos los links del chat "Yo" para procesarlos.
**AC:**
- Given: WhatsApp Web abierto, When: se ejecuta extractor, Then: navega al self-chat y extrae todos los links
- Given: links extraidos, When: se guarda resultado, Then: JSON con URL, fecha, contexto del mensaje
- Given: links ya procesados, When: se re-ejecuta, Then: no duplica links ya guardados

### WA-003: Envio de mensaje individual
**Points:** 3 | **Priority:** Medium | **Epic:** EPIC-01
Como usuario, quiero enviar un mensaje de texto a un contacto especifico via Playwright.
**AC:**
- Given: contacto y mensaje, When: se llama send_message(contact, text), Then: el mensaje se envia exitosamente
- Given: contacto no encontrado, When: se busca, Then: se lanza error descriptivo
- Given: mensaje enviado, When: se verifica, Then: aparece el tick de enviado en la UI

### WA-004: Eliminacion de mensajes del self-chat
**Points:** 5 | **Priority:** Low | **Epic:** EPIC-01 | **PAUSADO**
Como usuario, quiero eliminar mensajes del self-chat una vez procesados.
**Status:** PAUSADO - no reanudar sin instruccion explicita del usuario
**Contexto:** Implementacion anterior interrumpida con ~5 mensajes sin eliminar.

### WA-005: MCP Tool wa_get_links
**Points:** 3 | **Priority:** Medium | **Epic:** EPIC-02
Exponer extraccion de links como MCP tool para Claude Code.
**AC:**
- Given: Claude Code con MCP activo, When: se llama wa_get_links, Then: retorna lista de links del self-chat

### WA-006: MCP Tool wa_send_message
**Points:** 2 | **Priority:** Medium | **Epic:** EPIC-02
Exponer envio de mensajes como MCP tool.
**AC:**
- Given: contacto y texto, When: se llama wa_send_message(contact, text), Then: envia el mensaje

### WA-007: MCP Tool wa_delete_message
**Points:** 3 | **Priority:** Low | **Epic:** EPIC-02
Exponer eliminacion de mensajes como MCP tool.

### WA-008: Pipeline automatico de links
**Points:** 5 | **Priority:** Low | **Epic:** EPIC-03
Pipeline: recibir links en self-chat → evaluar via agente → guardar → notificar.

## Completadas (indice)
| ID | Titulo | Puntos | Fecha | Notas |
|----|--------|--------|-------|-------|
| WA-000 | Extraccion manual de links (Playwright MCP) | 1 | 2026-03-28 | 8 links, 7 evaluados, guardados en JSON |

## ID Registry
| Rango | Estado |
|-------|--------|
| WA-000 | Completada |
| WA-001 a WA-008 | Pendientes |
Proximo ID: WA-009
