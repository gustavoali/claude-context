### CMA-012: Proveedores de insumos legales
**Points:** 3 | **Priority:** Low | **Epic:** EPIC-04 Red de Recursos

**As a** cultivador que necesita armar su setup
**I want** una lista de proveedores confiables de insumos
**So that** pueda comprar lo necesario sin riesgo y con buenos precios

**AC1: Insumos de cultivo**
- Given que se necesitan multiples insumos (iluminacion, sustrato, fertilizantes, macetas)
- When se arma la lista de proveedores
- Then incluye: growshops online y fisicos en Argentina, rango de precios, reputacion, si envian a todo el pais

**AC2: Semillas**
- Given la situacion particular de las semillas en Argentina
- When se documenta
- Then incluye: bancos nacionales e internacionales que envian a Argentina, precios tipicos, confiabilidad, legalidad actual de la compra

**AC3: Presupuesto estimado de setup completo**
- Given que el costo es un factor de decision
- When se arma el presupuesto
- Then incluye: setup minimo viable (low budget), setup recomendado (mid range), setup premium, con precio total estimado en ARS para cada rango

**Technical Notes:**
- Archivo destino: `docs/fase-4/proveedores-insumos.md`
- Precios se desactualizan rapido, incluir fecha de relevamiento
