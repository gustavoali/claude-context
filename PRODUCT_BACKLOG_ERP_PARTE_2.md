# Sistema ERP Multinacional - Product Backlog (PARTE 2)
**Versión del Documento:** 1.0 - Parte 2 de 4
**Fecha:** 2025-10-11
**Continuación de:** PRODUCT_BACKLOG_ERP.md (Parte 1)

---

## 📚 User Stories Detalladas (Continuación)

### Epic 1: Multi-Currency Engine - User Stories (Continuación)

---

### US-007: API de Consulta de Tipos de Cambio

**Como** Desarrollador de aplicación cliente
**Quiero** consultar tipos de cambio mediante API
**Para** mostrar conversiones en tiempo real a los usuarios

**Priority:** Should Have
**Story Points:** 5
**Sprint:** Fase 1 (Semana 4-7)
**Epic:** Epic 1
**RICE Score:** 100.0

#### Acceptance Criteria

**AC1: Endpoint de Consulta**
- Given un par de monedas (origen, destino)
- When se consulta el endpoint GET /api/exchange-rates
- Then retorna tipo de cambio actual
- And fecha de última actualización
- And fuente del tipo de cambio
- And tipos compra/venta

**AC2: Consulta Histórica**
- Given un par de monedas y rango de fechas
- When se consulta histórico
- Then retorna serie temporal de tipos de cambio
- And permite filtrar por fecha desde/hasta
- And retorna máximo 365 días de historia

**AC3: Performance y Cache**
- Given consultas frecuentes
- When se realizan
- Then responde en <50ms desde cache
- And cache se actualiza cada 1 hora
- And retorna header Last-Modified

**AC4: Múltiples Pares**
- Given una lista de pares de monedas
- When se consulta en batch
- Then retorna todos los tipos en una sola request
- And máximo 20 pares por request

#### Technical Notes

- Endpoint: `GET /api/exchange-rates?from=ARS&to=USD&date=2025-10-11`
- Endpoint batch: `POST /api/exchange-rates/batch`
- Cache en Redis con TTL 1 hora
- Rate limiting: 100 req/min por API key
- Swagger documentation completa

#### Definition of Done

- [ ] Endpoint simple implementado
- [ ] Endpoint histórico implementado
- [ ] Endpoint batch implementado
- [ ] Cache Redis funcional
- [ ] Rate limiting configurado
- [ ] Tests de API (100% endpoints)
- [ ] Documentación Swagger
- [ ] Performance <50ms validado

---

### US-008: Auditoría de Conversiones

**Como** Auditor
**Quiero** revisar todas las conversiones de moneda realizadas
**Para** validar la correctitud de cálculos financieros

**Priority:** Must Have
**Story Points:** 8
**Sprint:** Fase 1 (Semana 4-7)
**Epic:** Epic 1
**RICE Score:** 120.0

#### Acceptance Criteria

**AC1: Log de Conversiones**
- Given cada conversión realizada
- When se completa
- Then se registra en ConversionLog:
  - Timestamp preciso (UTC)
  - Usuario/sistema que solicitó
  - Monto origen y moneda
  - Monto destino y moneda
  - Tipo de cambio utilizado
  - Fuente del tipo de cambio
  - Contexto (factura ID, pago ID, etc.)

**AC2: API de Auditoría**
- Given un auditor autenticado
- When consulta conversiones
- Then puede filtrar por:
  - Rango de fechas
  - Monedas (origen/destino)
  - Usuario
  - Rango de montos
- And resultados paginados (50 por página)
- And exportable a CSV/Excel

**AC3: Detección de Anomalías**
- Given conversiones registradas
- When se detectan:
  - Diferencias >5% vs tipo de cambio oficial
  - Conversiones con montos muy altos
  - Conversiones con tipos manuales
- Then se marca como "requiere revisión"
- And se notifica al auditor

**AC4: Trazabilidad Completa**
- Given un documento con conversión
- When se audita
- Then se puede ver:
  - Tipo de cambio usado en ese momento
  - Diferencias si se recalcula con tipo actual
  - Justificación de diferencias
  - Quién aprobó (si es manual)

#### Technical Notes

- Tabla: `ConversionAuditLog` (append-only, nunca delete)
- Índices: (FechaHora, MonedaOrigenId, MonedaDestinoId, UsuarioId)
- Particionamiento por mes para performance
- Retención: 7 años (compliance)
- Exportación: CSV con LibreOffice compatibility

#### Definition of Done

- [ ] ConversionAuditLog implementado
- [ ] Logging automático en todas las conversiones
- [ ] API de consulta funcional
- [ ] Filtros y paginación
- [ ] Exportación CSV/Excel
- [ ] Detección de anomalías básica
- [ ] Tests de auditoría completos
- [ ] Retención configurada

---

### US-009: Configuración Multi-Moneda por Tenant

**Como** Administrador de tenant
**Quiero** configurar monedas activas para mi empresa
**Para** controlar qué monedas se pueden usar en transacciones

**Priority:** Must Have
**Story Points:** 8
**Sprint:** Fase 1 (Semana 4-7)
**Epic:** Epic 1
**RICE Score:** 128.0

#### Acceptance Criteria

**AC1: Configuración por Tenant**
- Given un tenant (empresa)
- When administrador configura monedas
- Then puede activar/desactivar monedas del catálogo global
- And establecer moneda local (default)
- And establecer moneda de reporting
- And configurar precisión decimal por moneda

**AC2: Moneda Base y Alternativas**
- Given configuración de tenant
- When se define
- Then tiene una moneda base obligatoria
- And puede tener hasta 5 monedas alternativas activas
- And todas las transacciones se registran en moneda base + original

**AC3: Validación en Transacciones**
- Given una transacción nueva
- When se ingresa con moneda
- Then valida que la moneda esté activa para el tenant
- And permite override solo con permiso especial
- And rechaza monedas inactivas

**AC4: Cambio de Configuración**
- Given cambio de monedas activas
- When se desactiva una moneda
- Then valida que no haya transacciones pendientes en esa moneda
- And permite solo si saldo en moneda = 0
- And registra cambio en audit log

#### Technical Notes

- Tabla: `TenantCurrencyConfig`
- Relación many-to-many: Tenant ↔ Moneda
- Validación en Application Layer
- Evento: `CurrencyConfigChangedEvent`
- Cache de configuración por tenant

#### Definition of Done

- [ ] TenantCurrencyConfig implementado
- [ ] CRUD de configuración funcional
- [ ] Validaciones en transacciones
- [ ] Tests de validación
- [ ] Cambio de configuración con validaciones
- [ ] Audit log de cambios
- [ ] Cache implementado
- [ ] Documentación de configuración

---

## Epic 2: Gestión de Inventario Multinacional - User Stories

---

### US-010: Estructura Regional Multi-País

**Como** Administrador del sistema
**Quiero** definir la jerarquía País → Región → Sucursal → Depósito
**Para** organizar el inventario por ubicaciones geográficas

**Priority:** Must Have
**Story Points:** 13
**Sprint:** Fase 1 (Semana 4-7)
**Epic:** Epic 2
**RICE Score:** 195.0

#### Acceptance Criteria

**AC1: Jerarquía Completa**
- Given la estructura organizacional
- When se configura
- Then Pais contiene Regiones
- And Región contiene Sucursales
- And Sucursal contiene Depósitos
- And cada nivel hereda configuración del nivel superior

**AC2: CRUD por Nivel**
- Given cada nivel de jerarquía
- When se administra
- Then permite crear/editar/eliminar Regiones dentro de País
- And Sucursales dentro de Región
- And Depósitos dentro de Sucursal
- And validaciones de integridad referencial

**AC3: Configuración Heredada**
- Given configuración en nivel superior
- When se crea nivel inferior
- Then hereda:
  - Moneda del país
  - Zona horaria
  - Tax engine
  - Plan de cuentas
- And permite override en niveles inferiores

**AC4: Navegación y Filtros**
- Given la jerarquía completa
- When usuario navega
- Then puede ver árbol jerárquico completo
- And filtrar stock por cualquier nivel
- And consolidar reportes por nivel
- And drill-down desde país hasta depósito específico

#### Technical Notes

- Entidades: `Pais`, `Region`, `Sucursal`, `Deposito`
- Relaciones: Parent-Child con EF Core
- Índices: (PaisId, RegionId, SucursalId)
- Patrón: Composite para jerarquía
- UI: Tree view con lazy loading

#### Definition of Done

- [ ] 4 entidades implementadas con relaciones
- [ ] CRUD completo por nivel
- [ ] Herencia de configuración
- [ ] Validaciones de integridad
- [ ] API endpoints funcionales
- [ ] Tests de jerarquía completos
- [ ] UI de navegación
- [ ] Documentación de estructura

---

### US-011: Catálogo de Productos Multi-Precio

**Como** Gerente de productos
**Quiero** gestionar productos con precios por país/moneda
**Para** vender en múltiples mercados con pricing local

**Priority:** Must Have
**Story Points:** 13
**Sprint:** Fase 1 (Semana 4-7)
**Epic:** Epic 2
**RICE Score:** 195.0

#### Acceptance Criteria

**AC1: Producto Base**
- Given un producto
- When se crea
- Then tiene atributos base:
  - Código único (SKU)
  - Descripción localizada (ES, PT, EN)
  - Categoría
  - Unidad de medida
  - Tipo (producto, servicio, combo)
  - Estado (activo/inactivo)

**AC2: Precios Multi-Moneda**
- Given un producto creado
- When se configuran precios
- Then puede tener múltiples precios:
  - Por país
  - Por moneda
  - Por lista de precios
  - Precio base + margen por país
- And al menos un precio activo

**AC3: Conversión Automática de Precios**
- Given un producto con precio en USD
- When se consulta precio en otro país
- Then si no tiene precio local:
  - Convierte desde precio base usando tipo de cambio
  - Aplica margen configurado del país
  - Redondea según reglas del país
- And cachea conversión por 1 hora

**AC4: Variantes de Producto**
- Given un producto con variantes (talla, color)
- When se gestiona
- Then cada variante tiene:
  - SKU específico
  - Precios independientes
  - Stock independiente
- And hereda atributos del producto padre

#### Technical Notes

- Entidades: `Producto`, `ProductoPrecio`, `ProductoVariante`
- Tabla de precios: (ProductoId, PaisId, MonedaId, ListaPrecioId, Precio, FechaDesde, FechaHasta)
- Índice único: (ProductoId, PaisId, MonedaId, ListaPrecioId, FechaDesde)
- Cache de conversiones en Redis
- Soporte i18n para descripciones

#### Definition of Done

- [ ] Entidad Producto con atributos base
- [ ] ProductoPrecio multi-moneda
- [ ] Conversión automática funcionando
- [ ] Variantes de producto
- [ ] CRUD completo
- [ ] API endpoints
- [ ] Tests multi-moneda
- [ ] Cache implementado

---

### US-012: Stock por Depósito

**Como** Almacenero
**Quiero** gestionar stock por depósito
**Para** saber disponibilidad exacta por ubicación

**Priority:** Must Have
**Story Points:** 13
**Sprint:** Fase 1 (Semana 4-7)
**Epic:** Epic 2
**RICE Score:** 195.0

#### Acceptance Criteria

**AC1: Stock Físico por Depósito**
- Given un producto
- When se consulta stock
- Then muestra por cada depósito:
  - Stock físico actual
  - Stock comprometido (reservado)
  - Stock disponible (físico - comprometido)
  - Stock en tránsito (transferencias pendientes)
  - Stock mínimo/máximo configurado

**AC2: Actualización en Tiempo Real**
- Given movimientos de stock
- When ocurren:
  - Ingresos por compra
  - Egresos por venta
  - Transferencias
  - Ajustes
- Then actualiza stock inmediatamente
- And registra en MovimientoStock
- And mantiene trazabilidad completa

**AC3: Consolidación Multi-Nivel**
- Given jerarquía de ubicaciones
- When se consulta stock
- Then puede consolidar por:
  - Depósito (nivel más bajo)
  - Sucursal (suma de depósitos)
  - Región (suma de sucursales)
  - País (suma de regiones)
  - Global (suma de todo)

**AC4: Alertas de Stock**
- Given umbrales configurados
- When stock alcanza niveles:
  - Stock < mínimo → Alerta de reposición
  - Stock = 0 → Alerta de quiebre
  - Stock > máximo → Alerta de exceso
- Then notifica a usuarios configurados
- And sugiere acciones (comprar, transferir)

#### Technical Notes

- Entidad: `Stock` (ProductoId, DepositoId, Cantidad)
- Índice único compuesto: (ProductoId, DepositoId)
- Trigger: Recalcular stock en cada movimiento
- Cache: Stock disponible por 5 minutos
- Query optimization: Índices en ProductoId y DepositoId

#### Definition of Done

- [ ] Entidad Stock implementada
- [ ] Actualización en tiempo real
- [ ] Consolidación multi-nivel
- [ ] Alertas configuradas
- [ ] API de consulta de stock
- [ ] Tests de concurrencia (crítico)
- [ ] Performance <100ms consulta
- [ ] Dashboard de stock

---

### US-013: Movimientos de Stock con Auditoría

**Como** Auditor
**Quiero** ver todos los movimientos de stock
**Para** trazabilidad completa del inventario

**Priority:** Must Have
**Story Points:** 8
**Sprint:** Fase 1 (Semana 5-7)
**Epic:** Epic 2
**RICE Score:** 128.0

#### Acceptance Criteria

**AC1: Registro de Movimientos**
- Given cualquier cambio en stock
- When ocurre
- Then se registra en MovimientoStock:
  - Tipo movimiento (Ingreso, Egreso, Transferencia, Ajuste)
  - Producto y depósito
  - Cantidad (+ o -)
  - Stock anterior y stock nuevo
  - Documento origen (Compra, Venta, Transferencia)
  - Usuario que realizó
  - Fecha/hora exacta
  - Observaciones

**AC2: Tipos de Movimiento**
- Given diferentes operaciones
- When se registran
- Then clasifica movimientos:
  - Compra: Ingreso desde proveedor
  - Venta: Egreso a cliente
  - Transferencia Entrada: desde otro depósito
  - Transferencia Salida: hacia otro depósito
  - Ajuste Positivo: corrección de inventario
  - Ajuste Negativo: merma, robo, vencimiento
  - Producción: transformación de productos

**AC3: Consulta de Historial**
- Given un producto y depósito
- When se consulta historial
- Then muestra timeline completo de movimientos
- And permite filtrar por:
  - Tipo de movimiento
  - Rango de fechas
  - Usuario
  - Documento
- And exportable a Excel

**AC4: Conciliación de Stock**
- Given stock actual y movimientos
- When se concilia
- Then stock actual = stock inicial + suma de movimientos
- And detecta discrepancias
- And permite ajustes con justificación

#### Technical Notes

- Tabla: `MovimientoStock` (append-only, nunca delete/update)
- Índices: (ProductoId, DepositoId, FechaHora), (DocumentoId)
- Particionamiento por mes
- Retención: 5 años mínimo
- Validación: SUM(movimientos) = stock actual

#### Definition of Done

- [ ] MovimientoStock implementado
- [ ] Registro automático en todos los flujos
- [ ] API de consulta de historial
- [ ] Filtros y paginación
- [ ] Exportación Excel
- [ ] Conciliación automática
- [ ] Tests de integridad
- [ ] Performance con millones de registros

---

### US-014: Transferencias Inter-Sucursal

**Como** Almacenero
**Quiero** transferir stock entre depósitos de la misma sucursal
**Para** balancear inventario localmente

**Priority:** Must Have
**Story Points:** 13
**Sprint:** Fase 1 (Semana 5-7)
**Epic:** Epic 2
**RICE Score:** 195.0

#### Acceptance Criteria

**AC1: Solicitud de Transferencia**
- Given stock disponible en depósito origen
- When se crea transferencia
- Then:
  - Selecciona depósito origen y destino
  - Selecciona productos y cantidades
  - Valida stock disponible en origen
  - Crea documento TransferenciaStock
  - Estado inicial: "Pendiente"

**AC2: Flujo de Estados**
- Given una transferencia creada
- When avanza por workflow
- Then pasa por estados:
  - Pendiente → Aprobada → En Tránsito → Recibida → Completada
  - Permite cancelar solo si Pendiente o Aprobada
- And cada cambio de estado registra usuario y timestamp

**AC3: Impacto en Stock**
- Given transferencia en flujo
- When cambia estado
- Then actualiza stock:
  - Aprobada: Reserva en origen (stock comprometido)
  - En Tránsito: Egreso de origen, aún no ingreso en destino
  - Recibida: Ingreso en destino
  - Completada: Libera reservas

**AC4: Conciliación de Cantidades**
- Given transferencia en destino
- When se recibe
- Then permite recibir cantidad:
  - Completa (= enviada)
  - Parcial (< enviada) → Requiere justificación
  - Exceso (> enviada) → Bloqueado
- And si parcial, genera ajuste por diferencia

#### Technical Notes

- Entidad: `TransferenciaStock`
- Workflow: State pattern
- Estados: Enum `EstadoTransferencia`
- Validaciones: FluentValidation
- Events: `TransferenciaEstadoCambiadoEvent`
- Notificaciones: Email a responsables

#### Definition of Done

- [ ] TransferenciaStock implementada
- [ ] Workflow de estados completo
- [ ] Validaciones de stock
- [ ] Impacto en stock correcto
- [ ] Recepción con conciliación
- [ ] API completa
- [ ] Tests de workflow
- [ ] Notificaciones configuradas

---

### US-015: Transferencias Inter-País con Costos

**Como** Gerente de logística
**Quiero** transferir stock entre países
**Para** balancear inventario regional

**Priority:** Must Have
**Story Points:** 13
**Sprint:** Fase 1 (Semana 6-7)
**Epic:** Epic 2
**RICE Score:** 169.0

#### Acceptance Criteria

**AC1: Transferencia Internacional**
- Given stock en país origen
- When se crea transferencia inter-país
- Then:
  - Selecciona sucursal origen (país A) y destino (país B)
  - Valida permisos especiales (solo gerentes regionales)
  - Requiere aprobación de ambos países
  - Calcula costos de traslado internacional
  - Genera documentación de exportación/importación

**AC2: Costos de Transferencia**
- Given transferencia inter-país
- When se calculan costos
- Then incluye:
  - Costo de transporte internacional
  - Seguros
  - Aranceles/impuestos de importación (si aplica)
  - Costos aduaneros
- And se registra en moneda origen y destino
- And se puede prorratear por producto

**AC3: Asientos Intercompany**
- Given transferencia completada entre países
- When se contabiliza
- Then genera asientos automáticos:
  - País Origen: Egreso de inventario (costo original)
  - País Destino: Ingreso de inventario (costo original + costos traslado)
  - Asientos intercompany para eliminación en consolidación
- And en moneda local de cada país + USD

**AC4: Documentación Fiscal**
- Given transferencia inter-país
- When se completa
- Then genera:
  - Factura de exportación (país origen)
  - Factura de importación (país destino)
  - Documento de transporte internacional
  - Declaración aduanera
- And documentos según regulación de cada país

#### Technical Notes

- Entidad: `TransferenciaInternacional` extends `TransferenciaStock`
- Service: `IntercompanyTransferService`
- Accounting: `IntercompanyAccountingService`
- Integración: APIs aduaneras (si disponible)
- Aprobaciones: Workflow multi-nivel
- Documents: PDF generation por país

#### Definition of Done

- [ ] TransferenciaInternacional implementada
- [ ] Cálculo de costos completo
- [ ] Asientos intercompany generados
- [ ] Workflow de aprobaciones
- [ ] Documentación fiscal por país
- [ ] Tests multi-moneda
- [ ] Tests de asientos contables
- [ ] Validación con contadores

---

## Epic 3: Compras Multinacionales - User Stories

---

### US-016: Proveedores Multi-País

**Como** Comprador
**Quiero** gestionar proveedores de múltiples países
**Para** realizar compras internacionales

**Priority:** Must Have
**Story Points:** 8
**Sprint:** Fase 1 (Semana 6-7)
**Epic:** Epic 3
**RICE Score:** 128.0

#### Acceptance Criteria

**AC1: Alta de Proveedor**
- Given un nuevo proveedor
- When se registra
- Then captura:
  - Datos básicos (nombre, contacto)
  - País de origen
  - Identificación fiscal del país (CUIT, RFC, RUT, etc.)
  - Condición fiscal (IVA, ISR, etc.)
  - Moneda de operación preferida
  - Términos de pago default
  - Incoterms para internacionales

**AC2: Validación Fiscal por País**
- Given país del proveedor
- When se valida identificación fiscal
- Then aplica reglas del país:
  - Argentina: CUIT/CUIL (11 dígitos)
  - México: RFC (12-13 caracteres)
  - Chile: RUT (formato 12.345.678-9)
  - Perú: RUC (11 dígitos)
- And valida formato con regex
- And permite integración con API de validación (AFIP, SAT, etc.)

**AC3: Multi-Moneda en Proveedor**
- Given un proveedor
- When se configura moneda
- Then:
  - Tiene moneda preferida
  - Puede operar en múltiples monedas
  - Precios se pueden consultar en moneda proveedor o local
  - Conversión automática con tipo de cambio del día

**AC4: Categorización y Scoring**
- Given proveedores registrados
- When se gestionan
- Then permite:
  - Categorizar por tipo de producto
  - Calificar (scoring 1-5 estrellas)
  - Marcar como proveedor preferido
  - Historial de compras y cumplimiento
  - KPIs (tiempo entrega, calidad, precio)

#### Technical Notes

- Entidad: `Proveedor`
- Validadores por país: `ProveedorValidator{AR|MX|CL|PE}`
- API de validación fiscal: Opcional, con fallback manual
- Índice: (PaisId, IdentificacionFiscal)
- Soft delete

#### Definition of Done

- [ ] Entidad Proveedor implementada
- [ ] Validación fiscal por país
- [ ] Multi-moneda configurada
- [ ] Categorización y scoring
- [ ] API CRUD completa
- [ ] Tests de validación por país
- [ ] Integración con AFIP (Argentina)
- [ ] Documentación

---

### US-017: Orden de Compra Multi-Moneda

**Como** Comprador
**Quiero** crear órdenes de compra en moneda del proveedor
**Para** comprar productos importados

**Priority:** Must Have
**Story Points:** 13
**Sprint:** Fase 1 (Semana 6-7)
**Epic:** Epic 3
**RICE Score:** 195.0

#### Acceptance Criteria

**AC1: Creación de OC**
- Given productos a comprar
- When se crea Orden de Compra
- Then:
  - Selecciona proveedor
  - Moneda default = moneda proveedor
  - Permite cambiar moneda manualmente
  - Captura productos, cantidades, precios unitarios
  - Calcula subtotal, impuestos, total
  - Condiciones de pago y entrega
  - Incoterm si es internacional

**AC2: Cálculo de Costos Multi-Moneda**
- Given OC en moneda extranjera (ej: USD)
- When se calcula
- Then:
  - Precio producto en moneda proveedor
  - Tipo de cambio del día para conversión a moneda local
  - Impuestos según país del proveedor
  - Costos de importación (aranceles, flete) si aplica
  - Total en moneda proveedor
  - Total en moneda local (estimado)

**AC3: Aprobación de OC**
- Given OC creada
- When requiere aprobación
- Then workflow según monto:
  - <$1000 USD: Auto-aprobada
  - $1000-$10000: Aprobación supervisor
  - >$10000: Aprobación gerencia
- And notificación por email
- And tracking de estado (Borrador → Pendiente → Aprobada → Enviada → Recibida)

**AC4: Documento Fiscal**
- Given OC aprobada
- When se genera documento
- Then:
  - PDF con formato del país
  - Numeración correlativa por sucursal
  - Firma digital si requerido
  - Envío automático a proveedor por email
  - Registro en sistema fiscal si requerido (ej: AFIP)

#### Technical Notes

- Entidad: `OrdenCompra`
- Detalle: `OrdenCompraDetalle` (productos)
- Workflow: State pattern
- Cálculos: `PurchaseCalculationService`
- PDF: QuestPDF library
- Email: Configuración SMTP por tenant

#### Definition of Done

- [ ] OrdenCompra implementada
- [ ] Cálculos multi-moneda correctos
- [ ] Workflow de aprobación
- [ ] PDF generation
- [ ] Envío por email
- [ ] API completa
- [ ] Tests multi-moneda (100%)
- [ ] Tests de workflow

---

### US-018: Recepción de Compra con Validación

**Como** Almacenero
**Quiero** recibir mercadería de una orden de compra
**Para** actualizar inventario y registrar diferencias

**Priority:** Must Have
**Story Points:** 13
**Sprint:** Fase 1 (Semana 7)
**Epic:** Epic 3
**RICE Score:** 195.0

#### Acceptance Criteria

**AC1: Recepción Contra OC**
- Given OC aprobada y enviada
- When llega mercadería
- Then:
  - Busca OC por número
  - Muestra productos esperados vs recibidos
  - Permite ingresar cantidades reales recibidas
  - Valida lotes/series si aplica
  - Valida vencimientos
  - Permite recepción parcial o completa

**AC2: Control de Calidad**
- Given productos recibidos
- When se inspeccionan
- Then permite registrar:
  - Cantidad aceptada
  - Cantidad rechazada (con motivo)
  - Observaciones de calidad
  - Fotos de productos dañados
- And productos rechazados no ingresan a stock
- And genera nota de devolución si aplica

**AC3: Actualización de Stock**
- Given productos aceptados
- When se confirma recepción
- Then:
  - Ingresa a stock del depósito seleccionado
  - Genera movimiento de stock tipo "Compra"
  - Actualiza stock disponible
  - Registra costo unitario en moneda local
  - Actualiza valuación de inventario (PPP)

**AC4: Diferencias y Excepciones**
- Given cantidades recibidas vs ordenadas
- When difieren
- Then:
  - Recibido < Ordenado: Recepción parcial, OC queda pendiente
  - Recibido > Ordenado: Requiere autorización especial
  - Producto no ordenado recibido: Bloquea recepción
  - Calidad rechazada: Genera reclamo a proveedor

#### Technical Notes

- Entidad: `RecepcionCompra`
- Service: `PurchaseReceivingService`
- Stock update: Transactional (Unit of Work)
- Validations: FluentValidation
- Photos: Storage en Blob/S3
- Workflow: Estados de recepción

#### Definition of Done

- [ ] RecepcionCompra implementada
- [ ] Control de calidad
- [ ] Actualización de stock transaccional
- [ ] Manejo de diferencias
- [ ] Registro de lotes/series
- [ ] API completa
- [ ] Tests de integridad de stock (crítico)
- [ ] Tests de concurrencia

---

### US-019: Factura de Proveedor con Matching

**Como** Contador
**Quiero** registrar facturas de proveedor
**Para** contabilizar correctamente las compras

**Priority:** Must Have
**Story Points:** 13
**Sprint:** Fase 1 (Semana 7)
**Epic:** Epic 3
**RICE Score:** 169.0

#### Acceptance Criteria

**AC1: Registro de Factura**
- Given factura recibida del proveedor
- When se registra
- Then captura:
  - Número de factura
  - Fecha de factura
  - Fecha de vencimiento
  - Proveedor
  - Moneda (puede diferir de OC)
  - Tipo de cambio al día de factura
  - Subtotal, impuestos, total
  - Concepto (productos, servicios, gastos)

**AC2: Matching Three-Way**
- Given factura registrada
- When se valida
- Then verifica matching:
  - Factura vs Orden de Compra (montos, productos)
  - Factura vs Recepción (cantidades recibidas)
  - Factura vs Precios acordados
- And marca excepciones si:
  - Diferencia >5% en montos
  - Productos facturados no recibidos
  - Precios diferentes a OC

**AC3: Diferencias de Cambio**
- Given factura en moneda extranjera
- When se registra con fecha diferente a OC/Recepción
- Then:
  - Calcula diferencia de cambio vs OC
  - Calcula diferencia de cambio vs recepción
  - Genera asiento de diferencia de cambio
  - Separa costo producto vs diferencia cambio

**AC4: Generación de Asiento Contable**
- Given factura validada
- When se contabiliza
- Then genera asiento:
  - Débito: Inventario (o Gasto según concepto)
  - Débito: IVA Crédito Fiscal (o impuesto del país)
  - Crédito: Cuentas por Pagar
- And asiento en moneda local + moneda original
- And conversión a USD para consolidación

#### Technical Notes

- Entidad: `FacturaProveedor`
- Service: `SupplierInvoiceMatchingService`
- Accounting: `AccountingEntryService`
- Validación: Three-way match algorithm
- Tolerancia: Configurable por tenant (default 5%)
- Asientos: Template por país

#### Definition of Done

- [ ] FacturaProveedor implementada
- [ ] Three-way matching funcional
- [ ] Cálculo diferencias de cambio
- [ ] Generación asientos automática
- [ ] API completa
- [ ] Tests de matching
- [ ] Tests contables (100%)
- [ ] Validación con contador

---

**CONTINÚA EN PARTE 3...**

---

## 📝 Resumen de Parte 2

**User Stories Creadas:** US-007 a US-019 (13 historias)

**Epics Cubiertos:**
- ✅ Epic 1: Multi-Currency Engine (completado)
- ✅ Epic 2: Gestión de Inventario Multinacional (en progreso)
- ✅ Epic 3: Compras Multinacionales (en progreso)

**Story Points Acumulados:** 141 puntos (Parte 2)

**Próxima Parte 3 Incluirá:**
- Resto de Epic 3: Compras
- Epic 4: Tax Engines por País (crítico)
- Epic 5: Ventas Multi-País
- Epic 6: Contabilidad Multinacional

---

**Versión:** 1.0 (Parte 2 de 4)
**Última Actualización:** 2025-10-11
**Estado:** READY FOR REVIEW
**Siguiente:** Crear Parte 3 del Backlog
