# MEW-029: Historico de precios por ingrediente
**Epic:** E9 - Exportacion y Compartir
**Version:** v1.2
**Story Points:** 5
**Priority:** Medium
**Status:** Pending
**DoR Level:** 2

---

## User Story

**As a** cuidador de gatos
**I want** ver como han cambiado los precios de los ingredientes
**So that** pueda trackear la inflacion y planificar mejor

---

## Acceptance Criteria

**AC1: Registro automatico de cambios**
- Given que actualizo el precio de un ingrediente
- When guardo el nuevo precio
- Then el sistema guarda el precio anterior con fecha
- And mantiene historial de los ultimos 12 meses

**AC2: Ver historial por ingrediente**
- Given que estoy en la pantalla de precios
- When toco un ingrediente
- Then veo historial de precios con fechas
- And muestra variacion porcentual

**AC3: Grafico de tendencia (opcional)**
- Given que veo historial de un ingrediente
- When hay suficientes datos (3+ registros)
- Then muestra grafico simple de linea
- And visualizo la tendencia

**AC4: Indicador de variacion**
- Given que veo la lista de precios
- When un precio cambio recientemente
- Then muestra indicador: +15% o -5%
- And el color indica si subio (rojo) o bajo (verde)

---

## Technical Notes
- Tabla: price_history (ingredient_id, price, date)
- Mantener maximo 12 registros por ingrediente
- Grafico opcional con fl_chart

---

## Definition of Done
- [ ] Tabla de historial de precios
- [ ] UI de historial por ingrediente
- [ ] Indicador de variacion en lista
- [ ] Tests de persistencia
