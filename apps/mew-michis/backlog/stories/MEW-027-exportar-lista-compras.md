# MEW-027: Exportar lista de compras (texto/WhatsApp)
**Epic:** E9 - Exportacion y Compartir
**Version:** v1.2
**Story Points:** 5
**Priority:** High
**Status:** Pending
**DoR Level:** 2

---

## User Story

**As a** cuidador de gatos
**I want** exportar mi lista de compras como texto
**So that** pueda enviarla por WhatsApp o copiarla facilmente

---

## Acceptance Criteria

**AC1: Boton de exportar**
- Given que estoy en la lista de compras
- When toco el boton "Compartir"
- Then se abre el sheet de compartir del sistema
- And puedo elegir WhatsApp, copiar, etc.

**AC2: Formato de texto legible**
- Given que exporto la lista
- When veo el texto generado
- Then esta organizado por categorias
- And muestra: "Carnes: Pollo 800g, Higado 200g..."

**AC3: Incluir metadata**
- Given que exporto la lista
- When veo el texto
- Then incluye: fecha, peso de gatos, semana
- And tiene header identificando la app

**AC4: Copiar al clipboard**
- Given que quiero copiar sin compartir
- When toco "Copiar"
- Then el texto se copia al clipboard
- And aparece confirmacion

---

## Technical Notes
- Usar share_plus package
- Formatear texto plano con saltos de linea
- Incluir emoji opcionales para categorias

---

## Definition of Done
- [ ] Boton compartir en lista de compras
- [ ] Formato de texto legible
- [ ] Integracion con share sheet
- [ ] Opcion copiar clipboard
