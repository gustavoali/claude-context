# Epic 9: Exportacion y Compartir (E9)

**Version:** v1.2
**Objetivo:** Permitir exportar y compartir listas de compras, menus y datos.
**Valor de negocio:** Facilita el uso practico y la difusion de la app.
**Story Points Total:** 21
**Status:** PLANIFICADO (0 de 5 historias completadas)

---

## Historias

| ID | Titulo | Points | Priority | Status |
|----|--------|--------|----------|--------|
| MEW-027 | Exportar lista de compras (texto/WhatsApp) | 5 | High | Pending |
| MEW-028 | Modo compra real con redondeo comercial | 3 | Medium | Pending |
| MEW-029 | Historico de precios por ingrediente | 5 | Medium | Pending |
| MEW-030 | Costo por comida individual | 3 | Medium | Pending |
| MEW-031 | Compartir menu semanal | 5 | Low | Pending |

---

## Dependencias entre Historias

```
MEW-027 (Exportar lista) - Independiente, puede ser primera
MEW-028 (Modo compra) - Independiente de MEW-027
MEW-029 (Historico precios) - Independiente, requiere nueva tabla
MEW-030 (Costo por comida) - Independiente, reutiliza logica MEW-017
MEW-031 (Compartir menu) - Independiente

Todas las historias son independientes entre si.
Se pueden desarrollar en cualquier orden o en paralelo.
```

---

## Dependencias con Otros Epics

- **E5 (Lista Compras):** MEW-027, MEW-028, MEW-036 operan sobre la lista de compras
- **E6 (Presupuesto):** MEW-029 extiende precios de MEW-016, MEW-030 extiende costos de MEW-017
- **E4 (Menu Semanal):** MEW-031 comparte el menu semanal
- **E8 (UX):** Completar E8 primero es recomendado (v1.1 antes de v1.2)

---

## Detalle de Historias

### MEW-027: Exportar lista de compras (texto/WhatsApp)
**Story Points:** 5 | **Priority:** High | **Status:** Pending | **DoR Level:** 2

**As a** cuidador de gatos
**I want** exportar mi lista de compras como texto
**So that** pueda enviarla por WhatsApp o copiarla facilmente

**AC1:** Boton "Compartir" abre sheet del sistema
**AC2:** Formato texto organizado por categorias
**AC3:** Incluye metadata (fecha, peso gatos, semana)
**AC4:** Opcion copiar al clipboard

**Technical Notes:** Usar share_plus package. Texto plano con saltos de linea.

---

### MEW-028: Modo compra real con redondeo comercial
**Story Points:** 3 | **Priority:** Medium | **Status:** Pending | **DoR Level:** 1

**As a** cuidador de gatos
**I want** ver las cantidades redondeadas para compra real
**So that** pueda pedir cantidades practicas en la carniceria

**AC1:** Toggle "Modo compra" en lista
**AC2:** Redondeo inteligente (carnes a 50g/100g hacia arriba)
**AC3:** Indicador de diferencia: "900g (+53g)"
**AC4:** Suplementos mantienen precision exacta

**Technical Notes:** Redondeo carnes multiplos de 50g. Huevos enteros. Persistir preferencia.

---

### MEW-029: Historico de precios por ingrediente
**Story Points:** 5 | **Priority:** Medium | **Status:** Pending | **DoR Level:** 2

**As a** cuidador de gatos
**I want** ver como han cambiado los precios de los ingredientes
**So that** pueda trackear la inflacion y planificar mejor

**AC1:** Registro automatico al cambiar precio
**AC2:** Historial por ingrediente con fechas y variacion %
**AC3:** Grafico de tendencia opcional (3+ registros)
**AC4:** Indicador +X% o -X% en lista de precios

**Technical Notes:** Nueva tabla price_history. Max 12 registros/ingrediente. Grafico con fl_chart (opcional).

**Migracion DB requerida:** Agregar tabla `price_history (ingredient_id, price, date)`

---

### MEW-030: Costo por comida individual
**Story Points:** 3 | **Priority:** Medium | **Status:** Pending | **DoR Level:** 1

**As a** cuidador de gatos
**I want** ver el costo de cada comida individual
**So that** tenga una metrica mas tangible que el costo semanal

**AC1:** Costo por dia visible en cada slot del menu
**AC2:** Costo promedio por comida en resumen de presupuesto
**AC3:** Desglose por dia al tocar

**Technical Notes:** Reutilizar logica de MEW-017. Mostrar en MenuDayCard.

---

### MEW-031: Compartir menu semanal
**Story Points:** 5 | **Priority:** Low | **Status:** Pending | **DoR Level:** 2

**As a** cuidador de gatos
**I want** compartir mi menu semanal con otros
**So that** pueda mostrar mi planificacion o pedir feedback

**AC1:** Boton "Compartir menu" genera imagen o texto
**AC2:** Formato visual con 7 dias y badge seguridad
**AC3:** Formato texto como alternativa
**AC4:** Preview antes de compartir

**Technical Notes:** RepaintBoundary o screenshot para imagen. share_plus package.

---

## Packages Nuevos Requeridos

| Package | Uso | Historias |
|---------|-----|-----------|
| `share_plus` | Compartir contenido via apps del sistema | MEW-027, MEW-031 |
| `fl_chart` | Graficos de tendencia de precios (opcional) | MEW-029 |

---

## Migraciones de Base de Datos

| Version | Tabla | Descripcion | Historia |
|---------|-------|-------------|----------|
| v1.2 | price_history | Historial de precios | MEW-029 |

---

## Priorizacion MoSCoW (dentro del epic)

- **Should Have:** MEW-027, MEW-028, MEW-030
- **Could Have:** MEW-029, MEW-031

---

## Orden de Implementacion Sugerido

1. MEW-027 (Exportar lista) - valor inmediato mas alto
2. MEW-028 (Modo compra) + MEW-030 (Costo por comida) - en paralelo
3. MEW-029 (Historico precios) - requiere migracion
4. MEW-031 (Compartir menu) - menor prioridad
