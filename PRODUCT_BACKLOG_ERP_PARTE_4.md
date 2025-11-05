# Sistema ERP Multinacional - Product Backlog (PARTE 4 - FINAL)

**Versión del Documento:** 1.0 - Parte 4 de 4
**Fecha:** 2025-10-11
**Proyecto:** ERP Backend Multinacional - .NET 8 + MySQL
**Alcance:** 8+ países de las Américas

---

## 📚 User Stories Detalladas (Continuación - Parte 4 Final)

Esta parte final del Product Backlog completa los Epics 5, 6, 7, 8, 9, y 10, además de incluir el RICE Scoring, Release Plan, Dependencies Map, y Métricas de Éxito.

---

## Epic 5: Ventas Multi-País (Continuación)

### US-032: Cobranzas Multi-Moneda

**Como** Usuario del sistema
**Quiero** registrar cobranzas de facturas en múltiples monedas
**Para** llevar el control de pagos recibidos y cuentas por cobrar

**Story Points:** 13
**Prioridad:** MUST HAVE
**Epic:** Ventas Multi-País
**Dependencias:** US-031 (Facturación), US-007 (Multi-Currency)

#### Acceptance Criteria

**AC-032.1: Registro de Cobranza**
```gherkin
Given una factura emitida con saldo pendiente
When registro una cobranza
Then debo capturar:
  - Factura(s) a aplicar el pago
  - Fecha de cobranza
  - Medio de pago (Efectivo, Transferencia, Cheque, Tarjeta, etc.)
  - Moneda del pago recibido
  - Monto cobrado
  - Referencia bancaria (número de operación, cheque, etc.)
  - Cuenta bancaria de destino
And el sistema debe validar que el monto no exceda el saldo pendiente
```

**AC-032.2: Cobranza Multi-Moneda con Conversión**
```gherkin
Given una factura en USD con saldo de $1000
When registro una cobranza en ARS por $80,000
Then el sistema debe:
  - Obtener tipo de cambio vigente (ej: 80 ARS/USD)
  - Calcular equivalente en USD ($1000)
  - Aplicar el pago a la factura
  - Registrar tanto monto en ARS como en USD
  - Actualizar saldo de la factura a $0
  - Registrar tipo de cambio utilizado para auditoría
And debe permitir ajustar el tipo de cambio manualmente si es necesario
```

**AC-032.3: Aplicación de Cobranza a Múltiples Facturas**
```gherkin
Given un cliente con 3 facturas pendientes (F1: $500, F2: $300, F3: $200)
When registro una cobranza de $800
Then debo poder:
  - Seleccionar qué facturas pagar
  - Distribuir el monto entre múltiples facturas
  - Aplicar pagos parciales
  - Ver saldo restante de cada factura
And el sistema debe actualizar el estado de las facturas (Pagada/Pagada Parcial)
```

**AC-032.4: Anticipos y Créditos a Favor**
```gherkin
Given un pago recibido sin factura asociada (anticipo)
When registro la cobranza
Then el sistema debe:
  - Crear un crédito a favor del cliente
  - Permitir aplicar el crédito a facturas futuras
  - Mostrar el saldo a favor en el perfil del cliente
And cuando se emita una nueva factura debe permitir aplicar el anticipo
```

**AC-032.5: Reporte de Cuentas por Cobrar**
```gherkin
Given múltiples facturas y cobranzas en el sistema
When accedo al reporte de Cuentas por Cobrar
Then debo ver:
  - Facturas pendientes por cliente
  - Antigüedad de saldos (0-30, 31-60, 61-90, >90 días)
  - Total por cobrar por moneda
  - Total consolidado en USD
  - Proyección de flujo de caja
  - Clientes con mayor deuda
And debe permitir filtrar por fecha, cliente, moneda
```

#### Definition of Done
- [ ] Entidad `Cobranza` y `CobranzaAplicacion` creadas
- [ ] API REST completa (CRUD)
- [ ] Conversión multi-moneda implementada
- [ ] Aplicación a múltiples facturas funcional
- [ ] Manejo de anticipos implementado
- [ ] Reporte de Cuentas por Cobrar
- [ ] Frontend (formulario, listado, reportes) implementado
- [ ] Unit Tests (>95% coverage)
- [ ] Integration Tests
- [ ] Migraciones de base de datos
- [ ] Documentación API
- [ ] Code Review aprobado

#### Technical Notes
```csharp
// Domain/Entities/Cobranza.cs
public class Cobranza : BaseEntity, IAuditableEntity
{
    public int ClienteId { get; set; }
    public string NumeroRecibo { get; set; }
    public DateTime FechaCobranza { get; set; }
    public MedioPago MedioPago { get; set; }
    public CurrencyCode Moneda { get; set; }
    public decimal MontoTotal { get; set; }

    // Multi-Currency
    public decimal? TipoDeCambio { get; set; }
    public CurrencyCode? MonedaEquivalente { get; set; }
    public decimal? MontoEquivalente { get; set; }

    // Detalles bancarios
    public string ReferenciaBancaria { get; set; }
    public int? CuentaBancariaId { get; set; }

    // Estado
    public bool IsAplicada { get; set; }
    public bool IsAnticipo { get; set; }

    // Audit
    public int TenantId { get; set; }
    public DateTime CreatedAt { get; set; }
    public string CreatedBy { get; set; }
    public DateTime? ModifiedAt { get; set; }
    public string ModifiedBy { get; set; }
    public bool IsDeleted { get; set; }

    // Navigation
    public virtual Cliente Cliente { get; set; }
    public virtual ICollection<CobranzaAplicacion> Aplicaciones { get; set; }
}

public class CobranzaAplicacion : BaseEntity
{
    public int CobranzaId { get; set; }
    public int FacturaId { get; set; }
    public decimal MontoAplicado { get; set; }

    public virtual Cobranza Cobranza { get; set; }
    public virtual Factura Factura { get; set; }
}

public enum MedioPago
{
    Efectivo = 1,
    Transferencia = 2,
    Cheque = 3,
    TarjetaCredito = 4,
    TarjetaDebito = 5,
    MercadoPago = 6,
    Otro = 99
}

// Application/Features/Cobranzas/Commands/RegistrarCobranzaCommand.cs
public class RegistrarCobranzaCommandHandler : IRequestHandler<RegistrarCobranzaCommand, CobranzaDto>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrencyService _currencyService;
    private readonly IMapper _mapper;
    private readonly ILogger<RegistrarCobranzaCommandHandler> _logger;

    public async Task<CobranzaDto> Handle(RegistrarCobranzaCommand request, CancellationToken ct)
    {
        // 1. Crear cobranza
        var cobranza = new Cobranza
        {
            ClienteId = request.ClienteId,
            NumeroRecibo = GenerateNumeroRecibo(),
            FechaCobranza = request.FechaCobranza,
            MedioPago = request.MedioPago,
            Moneda = request.Moneda,
            MontoTotal = request.MontoTotal,
            ReferenciaBancaria = request.ReferenciaBancaria,
            CuentaBancariaId = request.CuentaBancariaId,
            TenantId = _context.CurrentTenantId
        };

        // 2. Aplicar a facturas
        decimal saldoRestante = request.MontoTotal;

        foreach (var aplicacion in request.Aplicaciones)
        {
            var factura = await _context.Facturas
                .FirstOrDefaultAsync(f => f.Id == aplicacion.FacturaId, ct);

            if (factura == null)
                throw new NotFoundException(nameof(Factura), aplicacion.FacturaId);

            // Validar que no se exceda el saldo
            if (aplicacion.Monto > factura.Saldo)
                throw new BusinessException($"Monto a aplicar ({aplicacion.Monto}) excede saldo de factura ({factura.Saldo})");

            // Conversión de moneda si es necesario
            decimal montoAplicadoEnMonedaFactura = aplicacion.Monto;

            if (cobranza.Moneda != factura.Moneda)
            {
                var tipoCambio = await _currencyService.GetExchangeRateAsync(
                    cobranza.Moneda, factura.Moneda, cobranza.FechaCobranza);

                montoAplicadoEnMonedaFactura = aplicacion.Monto * tipoCambio;

                cobranza.TipoDeCambio = tipoCambio;
                cobranza.MonedaEquivalente = factura.Moneda;
                cobranza.MontoEquivalente = montoAplicadoEnMonedaFactura;

                _logger.LogInformation("Conversión de moneda: {MontoOrigen} {MonedaOrigen} = {MontoDestino} {MonedaDestino} (TC: {TipoCambio})",
                    aplicacion.Monto, cobranza.Moneda, montoAplicadoEnMonedaFactura, factura.Moneda, tipoCambio);
            }

            // Crear aplicación
            cobranza.Aplicaciones.Add(new CobranzaAplicacion
            {
                FacturaId = factura.Id,
                MontoAplicado = montoAplicadoEnMonedaFactura
            });

            // Actualizar factura
            factura.Pagado += montoAplicadoEnMonedaFactura;
            factura.Saldo -= montoAplicadoEnMonedaFactura;

            // Actualizar estado
            if (factura.Saldo <= 0)
                factura.Estado = EstadoFactura.Pagada;
            else if (factura.Pagado > 0)
                factura.Estado = EstadoFactura.PagadaParcial;

            saldoRestante -= aplicacion.Monto;
        }

        // 3. Si sobra dinero, es un anticipo
        if (saldoRestante > 0)
        {
            cobranza.IsAnticipo = true;
            _logger.LogInformation("Cobranza con anticipo de {Monto} {Moneda}", saldoRestante, cobranza.Moneda);
        }

        cobranza.IsAplicada = true;

        _context.Cobranzas.Add(cobranza);
        await _context.SaveChangesAsync(ct);

        return _mapper.Map<CobranzaDto>(cobranza);
    }
}
```

---

## Epic 6: Contabilidad Multinacional

**Descripción:**
Sistema contable completo con soporte multi-país, multi-moneda, y generación automática de asientos contables. Incluye planes de cuentas por país, motor de asientos automáticos, asientos intercompany para transferencias entre países, y cierre contable mensual con validaciones.

**Story Points Totales:** 60 pts
**Prioridad:** MUST HAVE (MoSCoW)
**Riesgo:** ALTO - Requiere conocimiento contable especializado

---

### US-033: Plan de Cuentas por País

**Como** Contador
**Quiero** definir y gestionar planes de cuentas específicos por país
**Para** cumplir con las normativas contables locales y generar reportes correctos

**Story Points:** 13
**Prioridad:** MUST HAVE
**Epic:** Contabilidad Multinacional
**Dependencias:** US-001 (Multi-Tenancy)

#### Acceptance Criteria

**AC-033.1: Estructura Jerárquica de Cuentas**
```gherkin
Given que soy Contador
When creo un plan de cuentas
Then debo poder:
  - Definir estructura jerárquica (ej: 1, 1.1, 1.1.01, 1.1.01.001)
  - Asignar código y nombre a cada cuenta
  - Clasificar por tipo (Activo, Pasivo, Patrimonio, Ingreso, Egreso)
  - Marcar cuentas como "Imputable" (acepta asientos) o "de Mayor" (solo totaliza)
  - Asignar moneda por defecto (permite multi-moneda)
  - Configurar si requiere centro de costos
And la estructura debe soportar hasta 5 niveles de profundidad
```

**AC-033.2: Plan de Cuentas por País**
```gherkin
Given que opero en múltiples países
When configuro contabilidad
Then debo poder:
  - Crear un plan de cuentas base (template)
  - Clonar el plan base para cada país
  - Personalizar cuentas según normativa local
  - Mapear cuentas equivalentes entre países (para consolidación)
And cada tenant debe tener asignado el plan de cuentas de su país
```

**AC-033.3: Importación y Exportación**
```gherkin
Given un plan de cuentas existente
When necesito replicarlo
Then debo poder:
  - Exportar a Excel/CSV
  - Importar desde Excel/CSV con validaciones
  - Validar que no haya códigos duplicados
  - Validar estructura jerárquica correcta
And debe mostrar errores de validación claramente
```

**AC-033.4: Búsqueda y Consulta**
```gherkin
Given un plan de cuentas con cientos de cuentas
When busco una cuenta específica
Then debo poder:
  - Buscar por código o nombre
  - Filtrar por tipo de cuenta
  - Ver solo cuentas imputables
  - Ver árbol jerárquico completo
  - Ver saldos acumulados (si hay movimientos)
```

#### Definition of Done
- [ ] Entidad `PlanDeCuentas` y `Cuenta` creadas
- [ ] API REST completa (CRUD)
- [ ] Estructura jerárquica implementada (Hierarchical Data)
- [ ] Importación/Exportación Excel funcional
- [ ] Búsqueda y filtros implementados
- [ ] Frontend (árbol jerárquico, CRUD) implementado
- [ ] Unit Tests (>95% coverage)
- [ ] Integration Tests
- [ ] Migraciones con planes de cuentas seed (AR, MX, CL)
- [ ] Documentación API
- [ ] Code Review aprobado

#### Technical Notes
```csharp
// Domain/Entities/Cuenta.cs
public class Cuenta : BaseEntity
{
    public int PlanDeCuentasId { get; set; }
    public string Codigo { get; set; } // ej: 1.1.01.001
    public string Nombre { get; set; }
    public TipoCuenta Tipo { get; set; } // Activo, Pasivo, Patrimonio, Ingreso, Egreso
    public bool Imputable { get; set; } // True = acepta asientos
    public CurrencyCode MonedaPorDefecto { get; set; }
    public bool RequiereCentroCostos { get; set; }

    // Jerarquía
    public int? CuentaPadreId { get; set; }
    public int Nivel { get; set; } // 1, 2, 3, 4, 5
    public string Path { get; set; } // ej: /1/1.1/1.1.01/1.1.01.001 (para queries eficientes)

    // Mapeo para consolidación
    public string CuentaEquivalenteGlobal { get; set; } // Mapeo a cuenta estándar IFRS

    // Estado
    public bool IsActive { get; set; }

    // Audit
    public int TenantId { get; set; }

    // Navigation
    public virtual PlanDeCuentas PlanDeCuentas { get; set; }
    public virtual Cuenta CuentaPadre { get; set; }
    public virtual ICollection<Cuenta> SubCuentas { get; set; }
    public virtual ICollection<AsientoDetalle> AsientosDetalle { get; set; }
}

public enum TipoCuenta
{
    Activo = 1,
    Pasivo = 2,
    Patrimonio = 3,
    Ingreso = 4,
    Egreso = 5
}

// Application/Features/Cuentas/Queries/GetCuentasArbolQuery.cs
public class GetCuentasArbolQueryHandler : IRequestHandler<GetCuentasArbolQuery, List<CuentaArbolDto>>
{
    private readonly IApplicationDbContext _context;

    public async Task<List<CuentaArbolDto>> Handle(GetCuentasArbolQuery request, CancellationToken ct)
    {
        // Obtener todas las cuentas del tenant
        var cuentas = await _context.Cuentas
            .Where(c => c.TenantId == request.TenantId)
            .OrderBy(c => c.Codigo)
            .ToListAsync(ct);

        // Construir árbol jerárquico
        var cuentasRaiz = cuentas.Where(c => c.CuentaPadreId == null).ToList();

        return cuentasRaiz.Select(c => BuildArbol(c, cuentas)).ToList();
    }

    private CuentaArbolDto BuildArbol(Cuenta cuenta, List<Cuenta> todasCuentas)
    {
        return new CuentaArbolDto
        {
            Id = cuenta.Id,
            Codigo = cuenta.Codigo,
            Nombre = cuenta.Nombre,
            Tipo = cuenta.Tipo.ToString(),
            Imputable = cuenta.Imputable,
            Hijos = todasCuentas
                .Where(c => c.CuentaPadreId == cuenta.Id)
                .Select(c => BuildArbol(c, todasCuentas))
                .ToList()
        };
    }
}
```

---

### US-034: Motor de Asientos Automáticos Multi-Moneda

**Como** Contador
**Quiero** que el sistema genere asientos contables automáticamente
**Para** no tener que registrar manualmente cada transacción y evitar errores

**Story Points:** 21
**Prioridad:** MUST HAVE
**Epic:** Contabilidad Multinacional
**Dependencias:** US-033 (Plan de Cuentas), US-007 (Multi-Currency)

#### Acceptance Criteria

**AC-034.1: Plantillas de Asientos por Tipo de Transacción**
```gherkin
Given que necesito automatizar asientos contables
When configuro plantillas de asientos
Then debo definir reglas para:
  - Factura de Venta: Debe → Cliente, Haber → Ventas + IVA DF
  - Factura de Compra: Debe → Compras + IVA CF, Haber → Proveedor
  - Cobranza: Debe → Banco/Caja, Haber → Cliente
  - Pago: Debe → Proveedor, Haber → Banco/Caja
  - Transferencia Stock: Debe → Stock Destino, Haber → Stock Origen
  - Ajuste por Tipo de Cambio: Debe/Haber → Diferencia Cambio
And cada plantilla debe mapear cuentas del plan de cuentas
```

**AC-034.2: Generación Automática al Emitir Factura**
```gherkin
Given una factura de venta emitida por $1000 + $210 IVA = $1210
When el sistema genera el asiento contable
Then debe crear:
  - Asiento con fecha = fecha factura
  - Línea 1: Debe "Deudores por Venta" $1210
  - Línea 2: Haber "Ventas" $1000
  - Línea 3: Haber "IVA Débito Fiscal" $210
  - Total Debe = Total Haber = $1210 (debe balancear)
And debe vincular el asiento con la factura
And debe marcar el asiento como "Generado Automáticamente"
```

**AC-034.3: Asientos Multi-Moneda con Conversión**
```gherkin
Given una factura en USD de $1000 con TC 80 ARS/USD
When se genera el asiento contable
Then debe:
  - Crear asiento en moneda local (ARS)
  - Registrar importes en ARS ($80,000)
  - Guardar también importe original en USD ($1000)
  - Registrar tipo de cambio utilizado (80)
  - Permitir consultar en ambas monedas
And al mes siguiente si el TC cambió debe generar ajuste por diferencia de cambio
```

**AC-034.4: Validación de Balance**
```gherkin
Given un asiento contable (manual o automático)
When se intenta guardar
Then el sistema debe validar:
  - Total Debe = Total Haber (balance perfecto)
  - Todas las cuentas son imputables
  - Todas las cuentas pertenecen al plan del tenant
  - Fecha no está en período cerrado
  - Descripciones no vacías
And debe bloquear si no balancea con mensaje claro
```

**AC-034.5: Reversion de Asientos**
```gherkin
Given una factura anulada o una transacción revertida
When se anula la transacción
Then el sistema debe:
  - Generar asiento de reversa automáticamente
  - Invertir Debe ↔ Haber del asiento original
  - Vincular asiento original con asiento de reversa
  - Marcar ambos como "Revertido"
And debe mantener trazabilidad completa
```

#### Definition of Done
- [ ] Entidad `Asiento`, `AsientoDetalle` creadas
- [ ] Motor de generación de asientos implementado
- [ ] Plantillas de asientos por tipo de transacción
- [ ] Generación automática en Facturas, Cobranzas, Pagos
- [ ] Soporte multi-moneda en asientos
- [ ] Validación de balance implementada
- [ ] Reversión de asientos funcional
- [ ] Unit Tests (>95% coverage)
- [ ] Integration Tests
- [ ] Migraciones de base de datos
- [ ] Documentación API
- [ ] Code Review aprobado

#### Technical Notes
```csharp
// Domain/Entities/Asiento.cs
public class Asiento : BaseEntity, IAuditableEntity
{
    public string NumeroAsiento { get; set; }
    public DateTime Fecha { get; set; }
    public TipoAsiento Tipo { get; set; } // Manual, Automático, Cierre, Apertura, Ajuste
    public string Descripcion { get; set; }
    public bool IsAutomatico { get; set; }
    public bool IsRevertido { get; set; }
    public int? AsientoReversaId { get; set; }

    // Moneda
    public CurrencyCode Moneda { get; set; }
    public decimal? TipoDeCambio { get; set; }

    // Origen
    public string OrigenTipo { get; set; } // "Factura", "Cobranza", "Pago", etc.
    public int? OrigenId { get; set; }

    // Totales
    public decimal TotalDebe { get; set; }
    public decimal TotalHaber { get; set; }
    public bool IsBalanceado => TotalDebe == TotalHaber;

    // Audit
    public int TenantId { get; set; }
    public DateTime CreatedAt { get; set; }
    public string CreatedBy { get; set; }
    public DateTime? ModifiedAt { get; set; }
    public string ModifiedBy { get; set; }
    public bool IsDeleted { get; set; }

    // Navigation
    public virtual ICollection<AsientoDetalle> Detalles { get; set; }
    public virtual Asiento AsientoReversa { get; set; }
}

public class AsientoDetalle : BaseEntity
{
    public int AsientoId { get; set; }
    public int CuentaId { get; set; }
    public string TipoMovimiento { get; set; } // "DEBE" o "HABER"
    public decimal Importe { get; set; }

    // Multi-Moneda
    public CurrencyCode? MonedaOriginal { get; set; }
    public decimal? ImporteOriginal { get; set; }

    // Centro de Costos (opcional)
    public int? CentroCostosId { get; set; }

    public string Descripcion { get; set; }

    // Navigation
    public virtual Asiento Asiento { get; set; }
    public virtual Cuenta Cuenta { get; set; }
}

// Application/Services/AsientoAutomaticoService.cs
public class AsientoAutomaticoService : IAsientoAutomaticoService
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrencyService _currencyService;
    private readonly ILogger<AsientoAutomaticoService> _logger;

    public async Task<Asiento> GenerarAsientoDeFacturaVentaAsync(
        Factura factura, CancellationToken ct)
    {
        // 1. Obtener cuentas del plan
        var cuentaCliente = await GetCuentaByCodigoAsync("1.1.01"); // Deudores por Venta
        var cuentaVentas = await GetCuentaByCodigoAsync("4.1.01");  // Ventas
        var cuentaIvaDF = await GetCuentaByCodigoAsync("2.1.05");   // IVA Débito Fiscal

        // 2. Conversión a moneda local si es necesario
        var monedaLocal = CurrencyCode.ARS; // Obtener de configuración del tenant
        var importesEnMonedaLocal = factura.Moneda == monedaLocal
            ? (factura.SubTotal, factura.TotalImpuestos, factura.Total)
            : await ConvertirAMonedaLocalAsync(factura);

        decimal tipoCambio = factura.Moneda == monedaLocal
            ? 1
            : await _currencyService.GetExchangeRateAsync(factura.Moneda, monedaLocal, factura.FechaFactura);

        // 3. Crear asiento
        var asiento = new Asiento
        {
            NumeroAsiento = GenerateNumeroAsiento(),
            Fecha = factura.FechaFactura,
            Tipo = TipoAsiento.Automatico,
            Descripcion = $"Factura Venta {factura.NumeroFactura} - {factura.Cliente.RazonSocial}",
            IsAutomatico = true,
            Moneda = monedaLocal,
            TipoDeCambio = tipoCambio,
            OrigenTipo = "Factura",
            OrigenId = factura.Id,
            TenantId = factura.TenantId
        };

        // 4. Línea DEBE: Deudores por Venta (Total)
        asiento.Detalles.Add(new AsientoDetalle
        {
            CuentaId = cuentaCliente.Id,
            TipoMovimiento = "DEBE",
            Importe = importesEnMonedaLocal.Total,
            MonedaOriginal = factura.Moneda,
            ImporteOriginal = factura.Total,
            Descripcion = $"Cliente: {factura.Cliente.RazonSocial}"
        });

        // 5. Línea HABER: Ventas (SubTotal)
        asiento.Detalles.Add(new AsientoDetalle
        {
            CuentaId = cuentaVentas.Id,
            TipoMovimiento = "HABER",
            Importe = importesEnMonedaLocal.SubTotal,
            MonedaOriginal = factura.Moneda,
            ImporteOriginal = factura.SubTotal,
            Descripcion = "Ventas del período"
        });

        // 6. Línea HABER: IVA Débito Fiscal (Impuestos)
        asiento.Detalles.Add(new AsientoDetalle
        {
            CuentaId = cuentaIvaDF.Id,
            TipoMovimiento = "HABER",
            Importe = importesEnMonedaLocal.TotalImpuestos,
            MonedaOriginal = factura.Moneda,
            ImporteOriginal = factura.TotalImpuestos,
            Descripcion = "IVA Débito Fiscal"
        });

        // 7. Calcular totales
        asiento.TotalDebe = asiento.Detalles.Where(d => d.TipoMovimiento == "DEBE").Sum(d => d.Importe);
        asiento.TotalHaber = asiento.Detalles.Where(d => d.TipoMovimiento == "HABER").Sum(d => d.Importe);

        // 8. Validar balance
        if (!asiento.IsBalanceado)
        {
            throw new ContabilidadException($"Asiento no balanceado. Debe: {asiento.TotalDebe}, Haber: {asiento.TotalHaber}");
        }

        // 9. Guardar
        _context.Asientos.Add(asiento);
        await _context.SaveChangesAsync(ct);

        _logger.LogInformation("Asiento automático generado: {NumeroAsiento} para Factura {NumeroFactura}",
            asiento.NumeroAsiento, factura.NumeroFactura);

        return asiento;
    }
}
```

---

### US-035: Asientos Intercompany para Transferencias

**Como** Contador
**Quiero** que las transferencias entre países generen asientos intercompany
**Para** mantener la contabilidad correcta y permitir consolidación

**Story Points:** 13
**Prioridad:** MUST HAVE
**Epic:** Contabilidad Multinacional
**Dependencias:** US-034 (Motor de Asientos), US-015 (Transferencias Inter-País)

#### Acceptance Criteria

**AC-035.1: Asientos en País Origen (Salida)**
```gherkin
Given una transferencia de stock de AR a MX por $1000 USD
When se confirma la transferencia en el país origen (AR)
Then debe generar asiento:
  - Debe: "Cuenta Intercompany MX" $1000 USD (convertido a ARS)
  - Haber: "Stock Productos" $1000 USD (convertido a ARS)
  - Descripción: "Transferencia a México - Orden T-001"
And debe marcar el asiento como "Intercompany"
```

**AC-035.2: Asientos en País Destino (Entrada)**
```gherkin
Given la misma transferencia de AR a MX
When se confirma la recepción en el país destino (MX)
Then debe generar asiento:
  - Debe: "Stock Productos" $1000 USD (convertido a MXN)
  - Haber: "Cuenta Intercompany AR" $1000 USD (convertido a MXN)
  - Descripción: "Recepción desde Argentina - Orden T-001"
And debe vincular con el asiento del país origen
```

**AC-035.3: Conciliación Intercompany**
```gherkin
Given múltiples transferencias entre países en un período
When genero reporte de conciliación intercompany
Then debo ver:
  - Todas las cuentas intercompany por país
  - Saldo de cada cuenta intercompany
  - Diferencias si las hay (por tipo de cambio, timing, etc.)
  - Detalle de movimientos no conciliados
And debe permitir ajustar diferencias con asientos de corrección
```

**AC-035.4: Costos de Transferencia**
```gherkin
Given una transferencia con costos asociados (flete, seguro, impuestos)
When se registran los costos
Then debe:
  - Generar asiento adicional por los costos
  - Debe: "Stock Productos" (incrementa valor del inventario)
  - Haber: "Proveedor Flete/Seguros"
  - Vincular costos con la transferencia
And debe incluir costos en el valor del stock recibido
```

#### Definition of Done
- [ ] Generación automática de asientos intercompany implementada
- [ ] Asientos en origen y destino vinculados
- [ ] Reporte de conciliación intercompany
- [ ] Manejo de costos de transferencia
- [ ] Unit Tests (>95% coverage)
- [ ] Integration Tests
- [ ] Documentación de proceso intercompany
- [ ] Code Review aprobado

#### Technical Notes
```csharp
// Application/Services/IntercompanyAsientoService.cs
public class IntercompanyAsientoService : IIntercompanyAsientoService
{
    private readonly IApplicationDbContext _context;
    private readonly IAsientoAutomaticoService _asientoService;
    private readonly ICurrencyService _currencyService;

    public async Task GenerarAsientosIntercompanyAsync(
        TransferenciaInterPais transferencia, CancellationToken ct)
    {
        // 1. Asiento en país origen (salida)
        var asientoOrigen = await GenerarAsientoSalidaAsync(transferencia, ct);

        // 2. Asiento en país destino (entrada) - solo si ya fue recibida
        Asiento asientoDestino = null;
        if (transferencia.Estado == EstadoTransferencia.Recibida)
        {
            asientoDestino = await GenerarAsientoEntradaAsync(transferencia, ct);

            // 3. Vincular asientos
            asientoOrigen.AsientoIntercompanyRelacionadoId = asientoDestino.Id;
            asientoDestino.AsientoIntercompanyRelacionadoId = asientoOrigen.Id;

            await _context.SaveChangesAsync(ct);
        }
    }

    private async Task<Asiento> GenerarAsientoSalidaAsync(
        TransferenciaInterPais transferencia, CancellationToken ct)
    {
        var paisOrigen = transferencia.SucursalOrigen.CountryCode;
        var paisDestino = transferencia.SucursalDestino.CountryCode;

        // Obtener moneda local del país origen
        var monedaLocal = GetMonedaLocalByCountry(paisOrigen);

        // Convertir monto a moneda local
        var montoLocal = await _currencyService.ConvertAsync(
            transferencia.ValorTotal,
            transferencia.Moneda,
            monedaLocal,
            transferencia.FechaTransferencia);

        var asiento = new Asiento
        {
            Fecha = transferencia.FechaTransferencia,
            Tipo = TipoAsiento.Intercompany,
            Descripcion = $"Transferencia Intercompany a {paisDestino} - {transferencia.NumeroTransferencia}",
            Moneda = monedaLocal,
            OrigenTipo = "TransferenciaInterPais",
            OrigenId = transferencia.Id,
            TenantId = transferencia.TenantIdOrigen
        };

        // Debe: Cuenta Intercompany Destino
        var cuentaIntercompanyDestino = await GetCuentaIntercompanyAsync(paisDestino);
        asiento.Detalles.Add(new AsientoDetalle
        {
            CuentaId = cuentaIntercompanyDestino.Id,
            TipoMovimiento = "DEBE",
            Importe = montoLocal,
            MonedaOriginal = transferencia.Moneda,
            ImporteOriginal = transferencia.ValorTotal,
            Descripcion = $"A Cobrar de {paisDestino}"
        });

        // Haber: Stock Productos
        var cuentaStock = await GetCuentaStockAsync();
        asiento.Detalles.Add(new AsientoDetalle
        {
            CuentaId = cuentaStock.Id,
            TipoMovimiento = "HABER",
            Importe = montoLocal,
            MonedaOriginal = transferencia.Moneda,
            ImporteOriginal = transferencia.ValorTotal,
            Descripcion = "Salida de stock por transferencia"
        });

        asiento.TotalDebe = montoLocal;
        asiento.TotalHaber = montoLocal;

        _context.Asientos.Add(asiento);
        await _context.SaveChangesAsync(ct);

        return asiento;
    }
}
```

---

### US-036: Cierre Contable Mensual

**Como** Contador
**Quiero** realizar cierres contables mensuales
**Para** generar balances y reportes contables oficiales

**Story Points:** 13
**Prioridad:** MUST HAVE
**Epic:** Contabilidad Multinacional
**Dependencias:** US-034 (Asientos Automáticos)

#### Acceptance Criteria

**AC-036.1: Proceso de Cierre**
```gherkin
Given un mes con asientos contables
When ejecuto el cierre del mes
Then el sistema debe:
  - Validar que no haya asientos sin balancear
  - Generar asientos de ajuste por tipo de cambio (si hay moneda extranjera)
  - Calcular saldos de todas las cuentas
  - Marcar el período como "Cerrado"
  - Generar Balance de Sumas y Saldos
  - Generar Estado de Resultados
  - Generar Balance General
And debe bloquear edición de asientos del período cerrado
```

**AC-036.2: Ajustes por Tipo de Cambio**
```gherkin
Given cuentas en moneda extranjera al cierre del mes
When el TC cambió desde la transacción original
Then el sistema debe:
  - Recalcular saldos con TC de cierre
  - Comparar con saldo registrado
  - Generar asiento de ajuste por diferencia de cambio
  - Debe/Haber: "Diferencia de Cambio" (resultado del ejercicio)
And debe registrar el TC de cierre usado
```

**AC-036.3: Balance de Sumas y Saldos**
```gherkin
Given un período cerrado
When genero el Balance de Sumas y Saldos
Then debe mostrar para cada cuenta:
  - Saldo Inicial
  - Movimientos Debe
  - Movimientos Haber
  - Saldo Final (Deudor o Acreedor)
And debe totalizar por tipo de cuenta
And debe exportar a Excel/PDF
```

**AC-036.4: Estado de Resultados**
```gherkin
Given un período cerrado
When genero el Estado de Resultados
Then debe mostrar:
  - Ingresos (cuentas 4.x)
  - Costos (cuentas 5.x)
  - Utilidad Bruta
  - Gastos Operativos (cuentas 6.x)
  - Resultado Operativo
  - Resultado Financiero
  - Resultado Neto
And debe comparar con períodos anteriores
```

**AC-036.5: Balance General**
```gherkin
Given un período cerrado
When genero el Balance General
Then debe mostrar:
  - ACTIVOS (cuentas 1.x) con subtotales
    - Activo Corriente
    - Activo No Corriente
  - PASIVOS (cuentas 2.x) con subtotales
    - Pasivo Corriente
    - Pasivo No Corriente
  - PATRIMONIO NETO (cuentas 3.x)
    - Capital
    - Resultados Acumulados
    - Resultado del Ejercicio
And debe cumplir: Activo = Pasivo + Patrimonio
```

#### Definition of Done
- [ ] Proceso de cierre contable implementado
- [ ] Ajustes por tipo de cambio automáticos
- [ ] Balance de Sumas y Saldos generado
- [ ] Estado de Resultados generado
- [ ] Balance General generado
- [ ] Bloqueo de períodos cerrados
- [ ] Exportación a Excel/PDF
- [ ] Unit Tests (>95% coverage)
- [ ] Integration Tests
- [ ] Documentación del proceso de cierre
- [ ] Code Review aprobado

#### Technical Notes
```csharp
// Application/Features/Contabilidad/Commands/CerrarPeriodoCommand.cs
public class CerrarPeriodoCommandHandler : IRequestHandler<CerrarPeriodoCommand, CierreContableDto>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrencyService _currencyService;
    private readonly IBalanceService _balanceService;

    public async Task<CierreContableDto> Handle(CerrarPeriodoCommand request, CancellationToken ct)
    {
        var (año, mes) = (request.Año, request.Mes);

        // 1. Validar que no haya asientos desbalanceados
        var asientosDesbalanceados = await _context.Asientos
            .Where(a => a.Fecha.Year == año && a.Fecha.Month == mes && !a.IsBalanceado)
            .CountAsync(ct);

        if (asientosDesbalanceados > 0)
            throw new BusinessException($"Hay {asientosDesbalanceados} asientos sin balancear. Corrija antes de cerrar.");

        // 2. Generar ajustes por diferencia de cambio
        await GenerarAjustesPorDiferenciaDeCambioAsync(año, mes, ct);

        // 3. Calcular saldos de cuentas
        var saldos = await CalcularSaldosCuentasAsync(año, mes, ct);

        // 4. Generar reportes
        var balanceSumasYSaldos = await _balanceService.GenerarBalanceSumasYSaldosAsync(año, mes);
        var estadoResultados = await _balanceService.GenerarEstadoResultadosAsync(año, mes);
        var balanceGeneral = await _balanceService.GenerarBalanceGeneralAsync(año, mes);

        // 5. Crear registro de cierre
        var cierre = new CierreContable
        {
            Año = año,
            Mes = mes,
            FechaCierre = DateTime.UtcNow,
            UsuarioCierre = _context.CurrentUserId,
            BalanceSumasYSaldosJson = JsonSerializer.Serialize(balanceSumasYSaldos),
            EstadoResultadosJson = JsonSerializer.Serialize(estadoResultados),
            BalanceGeneralJson = JsonSerializer.Serialize(balanceGeneral),
            ResultadoNeto = estadoResultados.ResultadoNeto,
            TenantId = _context.CurrentTenantId
        };

        _context.CierresContables.Add(cierre);
        await _context.SaveChangesAsync(ct);

        return new CierreContableDto
        {
            Año = año,
            Mes = mes,
            FechaCierre = cierre.FechaCierre,
            BalanceSumasYSaldos = balanceSumasYSaldos,
            EstadoResultados = estadoResultados,
            BalanceGeneral = balanceGeneral
        };
    }

    private async Task GenerarAjustesPorDiferenciaDeCambioAsync(int año, int mes, CancellationToken ct)
    {
        // Obtener cuentas en moneda extranjera con saldo al cierre
        var cuentasMonedaExtranjera = await _context.AsientosDetalle
            .Where(d => d.Asiento.Fecha.Year == año && d.Asiento.Fecha.Month == mes)
            .Where(d => d.MonedaOriginal.HasValue && d.MonedaOriginal != CurrencyCode.ARS)
            .GroupBy(d => new { d.CuentaId, d.MonedaOriginal })
            .Select(g => new
            {
                g.Key.CuentaId,
                g.Key.MonedaOriginal,
                SaldoOriginal = g.Sum(d => d.TipoMovimiento == "DEBE" ? d.ImporteOriginal.Value : -d.ImporteOriginal.Value)
            })
            .ToListAsync(ct);

        var fechaCierre = new DateTime(año, mes, DateTime.DaysInMonth(año, mes));

        foreach (var cuenta in cuentasMonedaExtranjera)
        {
            if (cuenta.SaldoOriginal == 0) continue;

            // TC al cierre
            var tcCierre = await _currencyService.GetExchangeRateAsync(
                cuenta.MonedaOriginal.Value, CurrencyCode.ARS, fechaCierre);

            // Saldo en moneda local al TC de cierre
            var saldoAjustado = cuenta.SaldoOriginal * tcCierre;

            // Saldo registrado actual
            var saldoRegistrado = await _context.AsientosDetalle
                .Where(d => d.CuentaId == cuenta.CuentaId && d.Asiento.Fecha <= fechaCierre)
                .SumAsync(d => d.TipoMovimiento == "DEBE" ? d.Importe : -d.Importe, ct);

            var diferencia = saldoAjustado - saldoRegistrado;

            if (Math.Abs(diferencia) > 0.01m) // Tolerancia de 1 centavo
            {
                // Generar asiento de ajuste
                await GenerarAsientoAjusteDiferenciaCambioAsync(
                    cuenta.CuentaId, diferencia, fechaCierre, ct);
            }
        }
    }
}
```

---

## Epic 7: Consolidación & IFRS

**Descripción:**
Sistema de consolidación de estados financieros multi-país bajo normas IFRS, con eliminación de transacciones intercompany, reexpresión contable por inflación, y reporting multinacional consolidado.

**Story Points Totales:** 55 pts
**Prioridad:** SHOULD HAVE (MoSCoW)
**Riesgo:** MEDIO - Requiere conocimiento IFRS

---

### US-037: Consolidación de Balances Multi-País

**Como** CFO
**Quiero** consolidar los balances de todos los países
**Para** tener una visión financiera global de la operación

**Story Points:** 21
**Prioridad:** SHOULD HAVE
**Epic:** Consolidación & IFRS
**Dependencias:** US-036 (Cierre Contable), US-033 (Plan de Cuentas)

#### Acceptance Criteria

**AC-037.1: Mapeo de Cuentas a Estándar Global**
```gherkin
Given planes de cuentas diferentes por país
When configuro la consolidación
Then debo poder:
  - Mapear cada cuenta local a una cuenta estándar IFRS
  - Definir reglas de agregación (suma, promedio, etc.)
  - Configurar conversión de moneda a USD
And debe validar que todas las cuentas estén mapeadas
```

**AC-037.2: Conversión Multi-Moneda a USD**
```gherkin
Given balances cerrados en AR (ARS), MX (MXN), CL (CLP)
When consolido los balances
Then el sistema debe:
  - Obtener TC de cierre de cada moneda a USD
  - Convertir todos los saldos a USD
  - Aplicar TC promedio del período para Estado de Resultados
  - Aplicar TC de cierre para Balance General
  - Registrar TCs utilizados para trazabilidad
```

**AC-037.3: Balance Consolidado**
```gherkin
Given balances convertidos de todos los países
When genero el Balance Consolidado
Then debe mostrar:
  - Activos Consolidados por categoría
  - Pasivos Consolidados por categoría
  - Patrimonio Consolidado
  - Desglose por país (drill-down)
  - Diferencias de conversión acumuladas
And debe cumplir: Activo = Pasivo + Patrimonio
```

**AC-037.4: Estado de Resultados Consolidado**
```gherkin
Given Estados de Resultados de todos los países
When consolido
Then debe mostrar:
  - Ingresos Consolidados
  - Costos y Gastos Consolidados
  - Resultado Operativo Consolidado
  - Resultado Neto Consolidado
  - Comparativo vs período anterior
And debe permitir drill-down por país
```

#### Definition of Done
- [ ] Mapeo de cuentas a estándar IFRS implementado
- [ ] Conversión multi-moneda a USD funcional
- [ ] Balance Consolidado generado
- [ ] Estado de Resultados Consolidado
- [ ] Drill-down por país implementado
- [ ] Unit Tests (>90% coverage)
- [ ] Integration Tests
- [ ] Documentación de proceso de consolidación
- [ ] Code Review aprobado

---

### US-038: Eliminaciones Intercompany

**Como** CFO
**Quiero** eliminar transacciones intercompany en la consolidación
**Para** evitar duplicaciones y presentar cifras consolidadas correctas

**Story Points:** 13
**Prioridad:** SHOULD HAVE
**Epic:** Consolidación & IFRS
**Dependencias:** US-037 (Consolidación), US-035 (Asientos Intercompany)

#### Acceptance Criteria

**AC-038.1: Identificación de Saldos Intercompany**
```gherkin
Given transacciones intercompany durante el período
When ejecuto el proceso de consolidación
Then el sistema debe:
  - Identificar todas las cuentas intercompany
  - Calcular saldos recíprocos entre países
  - Detectar diferencias (por TC, timing, errores)
  - Generar reporte de conciliación
```

**AC-038.2: Asientos de Eliminación**
```gherkin
Given saldos intercompany identificados
When genero eliminaciones
Then debe crear asientos de eliminación para:
  - Cuentas por Cobrar/Pagar Intercompany → Eliminar ambos
  - Ventas/Compras Intercompany → Eliminar ambos
  - Resultado en Ventas Intercompany → Diferir hasta venta a terceros
And debe mantener estos asientos separados (no afectan libros locales)
```

**AC-038.3: Balance Post-Eliminación**
```gherkin
Given balance consolidado con eliminaciones aplicadas
When consulto el balance final
Then debe mostrar:
  - Solo transacciones con terceros (no intercompany)
  - Saldos intercompany en cero
  - Resultado neto ajustado por eliminaciones
And debe permitir ver pre y post eliminaciones
```

#### Definition of Done
- [ ] Identificación automática de saldos intercompany
- [ ] Generación de asientos de eliminación
- [ ] Aplicación de eliminaciones en consolidación
- [ ] Reporte de conciliación intercompany
- [ ] Unit Tests (>90% coverage)
- [ ] Documentación
- [ ] Code Review aprobado

---

### US-039: Reexpresión Contable por Inflación (IAS 29)

**Como** Contador
**Quiero** reexpresar estados financieros de países con hiperinflación
**Para** cumplir con IAS 29 (Economías Hiperinflacionarias)

**Story Points:** 13
**Prioridad:** SHOULD HAVE
**Epic:** Consolidación & IFRS
**Dependencias:** US-036 (Cierre Contable)

#### Acceptance Criteria

**AC-039.1: Identificación de Economías Hiperinflacionarias**
```gherkin
Given configuración de países
When marco un país como hiperinflacionario (ej: Argentina)
Then el sistema debe:
  - Activar reexpresión automática
  - Solicitar índice de inflación mensual
  - Aplicar IAS 29 en reportes consolidados
```

**AC-039.2: Cálculo de Coeficientes de Reexpresión**
```gherkin
Given un país con inflación acumulada
When calculo reexpresión
Then debe:
  - Usar índice oficial (ej: IPC en Argentina)
  - Calcular coeficiente por mes de origen
  - Aplicar coeficiente a partidas no monetarias
  - NO reexpresar partidas monetarias (ya reflejan inflación)
```

**AC-039.3: Estados Financieros Reexpresados**
```gherkin
Given balances reexpresados
When genero reportes
Then debe mostrar:
  - Valores históricos
  - Valores reexpresados
  - Diferencias (RECPAM - Resultado por Exposición a Cambios en Poder Adquisitivo)
And debe incluir nota explicativa en reportes
```

#### Definition of Done
- [ ] Configuración de países hiperinflacionarios
- [ ] Cálculo de coeficientes de reexpresión
- [ ] Aplicación de IAS 29
- [ ] Reportes con valores reexpresados
- [ ] Unit Tests (>90% coverage)
- [ ] Documentación IAS 29
- [ ] Code Review aprobado

---

### US-040: Reporting Multinacional IFRS

**Como** CFO
**Quiero** generar reportes consolidados bajo normas IFRS
**Para** presentar a inversores y cumplir con regulaciones internacionales

**Story Points:** 8
**Prioridad:** SHOULD HAVE
**Epic:** Consolidación & IFRS
**Dependencias:** US-037 (Consolidación), US-038 (Eliminaciones)

#### Acceptance Criteria

**AC-040.1: Balance Consolidado IFRS**
```gherkin
Given datos consolidados de todos los países
When genero Balance bajo IFRS
Then debe incluir:
  - Statement of Financial Position (Balance General)
  - Clasificación IFRS (Current/Non-Current)
  - Notas explicativas
  - Comparativo período anterior
And debe exportar a Excel/PDF
```

**AC-040.2: Income Statement IFRS**
```gherkin
Given resultados consolidados
When genero Income Statement
Then debe mostrar:
  - Revenue (Ingresos)
  - Cost of Sales (Costo de Ventas)
  - Gross Profit (Utilidad Bruta)
  - Operating Expenses (Gastos Operativos)
  - EBITDA
  - Operating Profit (EBIT)
  - Finance Costs
  - Profit Before Tax
  - Income Tax
  - Net Profit
And debe incluir comparativo y variaciones %
```

**AC-040.3: Cash Flow Statement**
```gherkin
Given movimientos de efectivo
When genero Cash Flow Statement
Then debe clasificar en:
  - Operating Activities (Actividades Operativas)
  - Investing Activities (Actividades de Inversión)
  - Financing Activities (Actividades de Financiamiento)
  - Net Increase/Decrease in Cash
And debe reconciliar con efectivo en Balance
```

**AC-040.4: Statement of Changes in Equity**
```gherkin
Given movimientos en patrimonio
When genero Statement of Changes in Equity
Then debe mostrar:
  - Capital al inicio
  - Resultado del ejercicio
  - Dividendos pagados
  - Otros movimientos de patrimonio
  - Capital al cierre
```

#### Definition of Done
- [ ] Balance IFRS generado
- [ ] Income Statement IFRS
- [ ] Cash Flow Statement
- [ ] Statement of Changes in Equity
- [ ] Exportación a Excel/PDF
- [ ] Notas explicativas incluidas
- [ ] Unit Tests (>90% coverage)
- [ ] Documentación
- [ ] Code Review aprobado

---

## Epic 8: User Management & RBAC

**Descripción:**
Sistema robusto de gestión de usuarios, autenticación JWT, autorización basada en roles (RBAC), y auditoría de acciones. Soporta 7 roles: Admin, Almacenero, Comprador, Vendedor, Tesorero, Contador, Auditor.

**Story Points Totales:** 34 pts
**Prioridad:** MUST HAVE

---

### US-041: Autenticación JWT y Gestión de Usuarios

**Como** Administrador
**Quiero** gestionar usuarios con autenticación segura
**Para** controlar el acceso al sistema

**Story Points:** 13
**Prioridad:** MUST HAVE
**Epic:** User Management & RBAC
**Dependencias:** Ninguna

#### Acceptance Criteria

**AC-041.1: Registro e Inicio de Sesión**
```gherkin
Given un usuario registrado
When intenta iniciar sesión con email y contraseña
Then el sistema debe:
  - Validar credenciales con BCrypt
  - Generar JWT token con claims (UserId, Email, TenantId, Roles, CountryCode)
  - Retornar token con expiración de 8 horas
  - Retornar refresh token con expiración de 30 días
And debe logear el inicio de sesión
```

**AC-041.2: Gestión de Usuarios**
```gherkin
Given que soy Administrador
When gestiono usuarios
Then debo poder:
  - Crear usuarios con email, nombre, rol
  - Asignar tenant y país
  - Configurar permisos específicos
  - Desactivar usuarios (soft delete)
  - Resetear contraseñas
And debe validar email único
```

**AC-041.3: Refresh Token**
```gherkin
Given un token JWT expirado
When envío el refresh token
Then el sistema debe:
  - Validar refresh token
  - Generar nuevo JWT token
  - Retornar nuevo par de tokens
And debe invalidar refresh token si se reutiliza (seguridad)
```

#### Definition of Done
- [ ] Autenticación JWT implementada
- [ ] CRUD de usuarios completo
- [ ] Refresh token funcional
- [ ] Hashing de contraseñas con BCrypt
- [ ] Middleware de autenticación
- [ ] Unit Tests (>95% coverage)
- [ ] Integration Tests
- [ ] Documentación API
- [ ] Code Review aprobado

---

### US-042: Autorización RBAC (Role-Based Access Control)

**Como** Administrador
**Quiero** definir roles y permisos granulares
**Para** controlar qué puede hacer cada usuario

**Story Points:** 13
**Prioridad:** MUST HAVE
**Epic:** User Management & RBAC
**Dependencias:** US-041 (Autenticación)

#### Acceptance Criteria

**AC-042.1: Definición de Roles**
```gherkin
Given el sistema
When defino roles
Then debe soportar:
  - Admin: Acceso total
  - Almacenero: Stock, Transferencias, Recepciones
  - Comprador: Proveedores, OC, Recepciones
  - Vendedor: Clientes, Pedidos, Facturas
  - Tesorero: Cobranzas, Pagos, Bancos
  - Contador: Contabilidad, Reportes, Cierres
  - Auditor: Solo lectura en todo
And cada rol debe tener permisos predefinidos
```

**AC-042.2: Permisos Granulares**
```gherkin
Given un recurso (ej: /api/facturas)
When un usuario intenta acceder
Then el sistema debe validar:
  - Tiene el rol adecuado
  - Tiene permisos sobre el recurso (Read, Create, Update, Delete)
  - Pertenece al mismo tenant (multi-tenancy)
  - Tiene acceso al país (si aplica)
And debe retornar 403 Forbidden si no tiene permisos
```

**AC-042.3: Middleware de Autorización**
```gherkin
Given endpoints protegidos con [Authorize(Roles = "Contador")]
When un usuario sin rol Contador intenta acceder
Then debe:
  - Bloquear acceso con 403
  - Logear intento de acceso no autorizado
  - NO exponer información sensible en el error
```

#### Definition of Done
- [ ] Roles definidos y configurados
- [ ] Permisos granulares implementados
- [ ] Middleware de autorización funcional
- [ ] Atributos [Authorize] aplicados en controllers
- [ ] Validación de tenant en queries (filtro global)
- [ ] Unit Tests (>95% coverage)
- [ ] Integration Tests
- [ ] Documentación de roles y permisos
- [ ] Code Review aprobado

---

### US-043: Auditoría de Acciones de Usuario

**Como** Auditor
**Quiero** consultar logs de todas las acciones de usuarios
**Para** cumplir con auditorías y detectar actividades sospechosas

**Story Points:** 8
**Prioridad:** MUST HAVE
**Epic:** User Management & RBAC
**Dependencias:** US-041 (Autenticación)

#### Acceptance Criteria

**AC-043.1: Registro de Auditoría**
```gherkin
Given cualquier acción de un usuario autenticado
When se ejecuta (Create, Update, Delete)
Then el sistema debe logear:
  - Usuario (Id, Email)
  - Tenant
  - Fecha y hora
  - Acción (Create/Update/Delete)
  - Entidad afectada
  - Valores anteriores (para Update/Delete)
  - Valores nuevos (para Create/Update)
  - IP del usuario
And debe almacenarse en tabla AuditLog
```

**AC-043.2: Consulta de Logs**
```gherkin
Given que soy Auditor o Admin
When consulto logs de auditoría
Then debo poder filtrar por:
  - Usuario
  - Fecha (rango)
  - Entidad (Factura, Cliente, Producto, etc.)
  - Acción (Create/Update/Delete)
  - Tenant
And debe mostrar resultados paginados
```

**AC-043.3: Reporte de Auditoría**
```gherkin
Given un período específico
When genero reporte de auditoría
Then debe incluir:
  - Total de acciones por usuario
  - Acciones por tipo (Create/Update/Delete)
  - Acciones por entidad
  - Timeline de eventos
And debe exportar a Excel/PDF
```

#### Definition of Done
- [ ] Tabla AuditLog creada
- [ ] Interceptor de auditoría implementado
- [ ] Captura automática de cambios en entidades
- [ ] API de consulta de logs
- [ ] Reporte de auditoría
- [ ] Frontend de consulta de logs
- [ ] Unit Tests (>90% coverage)
- [ ] Documentación
- [ ] Code Review aprobado

---

## Epic 9: DevOps & Testing Infrastructure

**Descripción:**
Infraestructura completa de CI/CD, testing automatizado, monitoreo, y deployment en múltiples ambientes. Incluye GitHub Actions, Docker, tests automatizados, y observabilidad con Serilog/Prometheus/Grafana.

**Story Points Totales:** 34 pts
**Prioridad:** MUST HAVE

---

### US-044: Pipeline CI/CD con GitHub Actions

**Como** DevOps Engineer
**Quiero** automatizar build, test, y deploy
**Para** asegurar calidad y acelerar releases

**Story Points:** 13
**Prioridad:** MUST HAVE
**Epic:** DevOps & Testing
**Dependencias:** Ninguna

#### Acceptance Criteria

**AC-044.1: Pipeline de Build y Test**
```gherkin
Given un commit pusheado a GitHub
When se dispara el pipeline CI
Then debe:
  - Restore de dependencias (dotnet restore)
  - Build del proyecto (dotnet build)
  - Ejecutar tests unitarios (dotnet test)
  - Ejecutar tests de integración
  - Generar reporte de coverage (>90% requerido)
  - Fallar el build si coverage <90% o tests fallan
```

**AC-044.2: Code Quality y Security Scans**
```gherkin
Given el pipeline CI corriendo
When ejecuta análisis de calidad
Then debe:
  - Ejecutar SonarQube/SonarCloud
  - Verificar code smells, bugs, vulnerabilidades
  - Ejecutar Dependabot para actualizar dependencias
  - Fallar si hay vulnerabilidades críticas
```

**AC-044.3: Deployment Automatizado**
```gherkin
Given tests pasando y code quality OK
When se mergea a rama main
Then debe:
  - Build de imagen Docker
  - Push a Docker Registry
  - Deploy automático a ambiente Staging
  - Ejecutar smoke tests en Staging
  - Notificar en Slack si falla
```

#### Definition of Done
- [ ] GitHub Actions workflow configurado
- [ ] Pipeline CI/CD funcional
- [ ] Code quality checks implementados
- [ ] Deployment a Staging automatizado
- [ ] Notificaciones configuradas
- [ ] Documentación de pipeline
- [ ] Code Review aprobado

---

### US-045: Tests Automatizados (Unit + Integration)

**Como** Developer
**Quiero** suite completa de tests automatizados
**Para** garantizar calidad y evitar regresiones

**Story Points:** 13
**Prioridad:** MUST HAVE
**Epic:** DevOps & Testing
**Dependencias:** Ninguna

#### Acceptance Criteria

**AC-045.1: Unit Tests con xUnit**
```gherkin
Given cada servicio y handler implementado
When escribo tests unitarios
Then debo cubrir:
  - Todos los métodos públicos
  - Casos de éxito (happy path)
  - Casos de error (validaciones, exceptions)
  - Edge cases
  - Mocks para dependencias externas
And coverage debe ser >95% en capa Application
```

**AC-045.2: Integration Tests**
```gherkin
Given endpoints API implementados
When escribo integration tests
Then debo probar:
  - Endpoints completos (request → response)
  - Base de datos real (TestContainers para MySQL)
  - Autenticación y autorización
  - Multi-tenancy isolation
  - Validaciones de negocio end-to-end
And debe usar WebApplicationFactory
```

**AC-045.3: Test Coverage Reporting**
```gherkin
Given tests ejecutados
When genero reporte de coverage
Then debe mostrar:
  - Coverage global (>90% target)
  - Coverage por capa (Domain, Application, Infrastructure)
  - Líneas no cubiertas
  - Coverage de cálculos fiscales (100% requerido)
And debe integrar con SonarCloud
```

#### Definition of Done
- [ ] Suite de unit tests completa (>95% coverage)
- [ ] Suite de integration tests completa (>80% coverage)
- [ ] TestContainers configurado para MySQL
- [ ] Mocks y fixtures organizados
- [ ] Tests ejecutándose en CI
- [ ] Reporte de coverage generado
- [ ] Documentación de testing
- [ ] Code Review aprobado

---

### US-046: Observabilidad (Logging, Metrics, Tracing)

**Como** DevOps Engineer
**Quiero** monitoreo y observabilidad completa
**Para** detectar y resolver problemas rápidamente

**Story Points:** 8
**Prioridad:** MUST HAVE
**Epic:** DevOps & Testing
**Dependencias:** Ninguna

#### Acceptance Criteria

**AC-046.1: Structured Logging con Serilog**
```gherkin
Given el sistema en ejecución
When ocurre cualquier evento
Then debe logear:
  - Requests HTTP (request/response)
  - Errores y excepciones
  - Eventos de negocio importantes
  - Performance (tiempo de respuesta)
  - Formato JSON estructurado
And debe enviar logs a Seq o ELK Stack
```

**AC-046.2: Métricas con Prometheus**
```gherkin
Given el sistema expone métricas en /metrics
When Prometheus scrape las métricas
Then debe incluir:
  - Request count por endpoint
  - Request duration (latencia)
  - Error rate
  - Database connection pool
  - Custom metrics de negocio (facturas/día, etc.)
```

**AC-046.3: Dashboards en Grafana**
```gherkin
Given métricas en Prometheus
When accedo a Grafana
Then debo ver dashboards para:
  - API Health (uptime, latency, error rate)
  - Database Performance (queries, connections)
  - Business Metrics (facturas, ventas, stock)
  - Alerts configurados (error rate >5%, latency >1s)
```

#### Definition of Done
- [ ] Serilog configurado con formato JSON
- [ ] Prometheus metrics endpoint implementado
- [ ] Grafana dashboards creados
- [ ] Alerts configurados
- [ ] Health checks implementados
- [ ] Documentación de observabilidad
- [ ] Code Review aprobado

---

## Epic 10: Localization Adicional

**Descripción:**
Soporte adicional de localización para facilitar expansión futura a nuevos países y regiones. Incluye i18n, formateo de fechas/monedas, y configuración regional.

**Story Points Totales:** 21 pts
**Prioridad:** COULD HAVE

---

### US-047 a US-050: Localización Adicional

**Resumen Rápido:**
- US-047: i18n (Internacionalización) - 8 pts
- US-048: Formateo Regional de Fechas/Monedas - 5 pts
- US-049: Time Zones Multi-País - 5 pts
- US-050: Plantillas de Documentos Localizadas - 3 pts

_(Definición detallada omitida por brevedad, pero incluiría AC completos y DoD)_

---

---

## 📊 RICE Scoring - Top 20 User Stories

**Metodología RICE:**
- **Reach:** Número de usuarios impactados (1-10)
- **Impact:** Impacto en el negocio (0.25=Bajo, 0.5=Medio, 1=Alto, 2=Muy Alto, 3=Crítico)
- **Confidence:** Confianza en las estimaciones (50%=Baja, 80%=Media, 100%=Alta)
- **Effort:** Story Points (esfuerzo en semanas)

**Fórmula:** RICE Score = (Reach × Impact × Confidence) / Effort

| Rank | US ID | User Story | Reach | Impact | Confidence | Effort | RICE Score | Prioridad |
|------|-------|-----------|-------|--------|------------|--------|------------|-----------|
| 1 | US-001 | Multi-Tenancy Context | 10 | 3 | 100% | 8 | **37.5** | CRÍTICO |
| 2 | US-020 | Tax Engine Factory Pattern | 10 | 3 | 100% | 8 | **37.5** | CRÍTICO |
| 3 | US-021 | Argentina Tax Engine (AFIP) | 8 | 3 | 80% | 21 | **9.14** | CRÍTICO |
| 4 | US-022 | México Tax Engine (SAT) | 8 | 3 | 80% | 21 | **9.14** | CRÍTICO |
| 5 | US-007 | API Consulta Tipos de Cambio | 10 | 2 | 100% | 5 | **40.0** | MUST HAVE |
| 6 | US-031 | Facturación Multi-País con Tax Engine | 9 | 3 | 80% | 21 | **10.29** | MUST HAVE |
| 7 | US-011 | Catálogo Productos Multi-Precio | 9 | 2 | 100% | 13 | **13.85** | MUST HAVE |
| 8 | US-010 | Estructura Regional Multi-País | 10 | 2 | 100% | 13 | **15.38** | MUST HAVE |
| 9 | US-034 | Motor Asientos Automáticos | 8 | 2 | 80% | 21 | **6.10** | MUST HAVE |
| 10 | US-023 | Chile Tax Engine (SII) | 7 | 2 | 80% | 13 | **8.62** | MUST HAVE |
| 11 | US-024 | Perú Tax Engine (SUNAT) | 6 | 2 | 80% | 13 | **7.38** | MUST HAVE |
| 12 | US-030 | Pedidos de Venta Multi-País | 8 | 2 | 100% | 13 | **12.31** | MUST HAVE |
| 13 | US-028 | Clientes Multi-País | 9 | 2 | 100% | 13 | **13.85** | MUST HAVE |
| 14 | US-016 | Proveedores Multi-País | 8 | 2 | 100% | 8 | **20.0** | MUST HAVE |
| 15 | US-017 | Orden de Compra Multi-Moneda | 8 | 2 | 100% | 13 | **12.31** | MUST HAVE |
| 16 | US-029 | Listas de Precios Multi-Moneda | 7 | 2 | 100% | 13 | **10.77** | MUST HAVE |
| 17 | US-015 | Transferencias Inter-País | 6 | 3 | 80% | 13 | **11.08** | MUST HAVE |
| 18 | US-032 | Cobranzas Multi-Moneda | 8 | 2 | 100% | 13 | **12.31** | MUST HAVE |
| 19 | US-041 | Autenticación JWT | 10 | 2 | 100% | 13 | **15.38** | MUST HAVE |
| 20 | US-042 | Autorización RBAC | 10 | 2 | 100% | 13 | **15.38** | MUST HAVE |

**Conclusión del RICE Scoring:**
- Las User Stories con mayor RICE score son las de **Multi-Tenancy** y **Tax Engines**, validando que son la base crítica del sistema.
- Las stories de **Multi-Currency** y **Estructura Regional** tienen alto score por impacto en todos los usuarios.
- Las stories de **Tax Engines específicos** (AR, MX, CL, PE) son críticas pero tienen effort alto, reduciendo su score.

---

## 🎯 Release Plan - 5 Releases (20-24 semanas)

### **Release 1: Foundation (Semanas 1-4) - 8 Stories, 89 pts**

**Objetivo:** Establecer la base arquitectónica multi-tenant, multi-moneda, y estructura regional.

**User Stories:**
- ✅ US-001: Multi-Tenancy Context (8 pts)
- ✅ US-002: Base de Datos Multi-Tenant (13 pts)
- ✅ US-003: API REST Base con Swagger (8 pts)
- ✅ US-004: Autenticación JWT Multi-Tenant (13 pts)
- ✅ US-007: API Consulta Tipos de Cambio (5 pts)
- ✅ US-008: Auditoría de Conversiones (8 pts)
- ✅ US-009: Configuración Multi-Moneda por Tenant (8 pts)
- ✅ US-010: Estructura Regional Multi-País (13 pts)
- ✅ US-044: Pipeline CI/CD (13 pts)

**Entregables:**
- Infraestructura multi-tenant funcional
- API base con autenticación JWT
- Multi-Currency Engine básico
- Pipeline CI/CD operativo
- Tests unitarios (>95% coverage)

**Riesgos:**
- Complejidad de multi-tenancy en MySQL
- **Mitigación:** Validación exhaustiva con integration tests

---

### **Release 2: Tax Engines Core (Semanas 5-9) - 8 Stories, 110 pts**

**Objetivo:** Implementar Tax Engines para los 3 países principales (AR, MX, CL) + Factory Pattern.

**User Stories:**
- ✅ US-020: Tax Engine Factory Pattern (8 pts)
- ✅ US-021: Argentina Tax Engine (AFIP) - CAE, IVA (21 pts)
- ✅ US-022: México Tax Engine (SAT) - CFDI 4.0 (21 pts)
- ✅ US-023: Chile Tax Engine (SII) - DTE (13 pts)
- ✅ US-024: Perú Tax Engine (SUNAT) (13 pts)
- ✅ US-025: Colombia Tax Engine (DIAN) (13 pts)
- ✅ US-026: Uruguay Tax Engine (DGI) (13 pts)
- ✅ US-027: Tax Engine Genérico (8 pts)

**Entregables:**
- Factory Pattern de Tax Engines operativo
- Tax Engines de AR, MX, CL 100% funcionales (certificados en homologación)
- Tax Engines de PE, CO, UY implementados
- Tests de integración con organismos fiscales (ambiente pruebas)

**Riesgos:**
- Complejidad de integración con AFIP/SAT/SII
- Certificados digitales requeridos
- **Mitigación:** Testing exhaustivo en ambientes de homologación

---

### **Release 3: Inventory & Purchases (Semanas 10-13) - 9 Stories, 141 pts**

**Objetivo:** Gestión completa de inventario multinacional y compras.

**User Stories:**
- ✅ US-011: Catálogo de Productos Multi-Precio (13 pts)
- ✅ US-012: Stock por Depósito (13 pts)
- ✅ US-013: Movimientos de Stock con Auditoría (8 pts)
- ✅ US-014: Transferencias Inter-Sucursal (13 pts)
- ✅ US-015: Transferencias Inter-País con Costos (13 pts)
- ✅ US-016: Proveedores Multi-País (8 pts)
- ✅ US-017: Orden de Compra Multi-Moneda (13 pts)
- ✅ US-018: Recepción de Compra con Validación (13 pts)
- ✅ US-019: Factura de Proveedor con Matching (13 pts)

**Entregables:**
- Inventario multi-depósito funcional
- Transferencias inter-país con asientos intercompany
- Ciclo completo de compras (OC → Recepción → Factura)
- Three-way matching implementado

**Riesgos:**
- Complejidad de transferencias inter-país
- **Mitigación:** Workflow de estados bien definido

---

### **Release 4: Sales & Accounting (Semanas 14-18) - 10 Stories, 151 pts**

**Objetivo:** Ventas multinacionales y contabilidad con asientos automáticos.

**User Stories:**
- ✅ US-028: Clientes Multi-País (13 pts)
- ✅ US-029: Listas de Precios Multi-Moneda (13 pts)
- ✅ US-030: Pedidos de Venta Multi-País (13 pts)
- ✅ US-031: Facturación Multi-País con Tax Engine (21 pts)
- ✅ US-032: Cobranzas Multi-Moneda (13 pts)
- ✅ US-033: Plan de Cuentas por País (13 pts)
- ✅ US-034: Motor de Asientos Automáticos (21 pts)
- ✅ US-035: Asientos Intercompany (13 pts)
- ✅ US-036: Cierre Contable Mensual (13 pts)
- ✅ US-045: Tests Automatizados (13 pts)

**Entregables:**
- Ciclo completo de ventas (Pedido → Factura → Cobranza)
- Facturación electrónica integrada con Tax Engines
- Contabilidad automática funcional
- Cierre contable mensual operativo
- Suite de tests automatizados completa (>90% coverage)

**Riesgos:**
- Integración contabilidad con Tax Engines
- **Mitigación:** Validaciones exhaustivas de asientos balanceados

---

### **Release 5: Consolidation & Advanced Features (Semanas 19-24) - 10 Stories, 120 pts**

**Objetivo:** Consolidación multinacional, IFRS, RBAC, y features avanzadas.

**User Stories:**
- ✅ US-037: Consolidación de Balances Multi-País (21 pts)
- ✅ US-038: Eliminaciones Intercompany (13 pts)
- ✅ US-039: Reexpresión Contable IAS 29 (13 pts)
- ✅ US-040: Reporting Multinacional IFRS (8 pts)
- ✅ US-041: Autenticación JWT y Usuarios (13 pts) *(Mover a R1 si es crítico)*
- ✅ US-042: Autorización RBAC (13 pts)
- ✅ US-043: Auditoría de Acciones (8 pts)
- ✅ US-046: Observabilidad (Logging, Metrics, Tracing) (8 pts)
- ✅ US-047: i18n (8 pts)
- ✅ US-005: Documentación API y Arquitectura (5 pts)
- ✅ US-006: Deployment y Configuración Productiva (8 pts)

**Entregables:**
- Consolidación multinacional IFRS funcional
- Eliminaciones intercompany automáticas
- Reexpresión por inflación (IAS 29)
- RBAC completo con 7 roles
- Observabilidad completa (Serilog + Prometheus + Grafana)
- Sistema productivo deployado

**Riesgos:**
- Complejidad de consolidación IFRS
- **Mitigación:** Consultoría con contador experto en IFRS

---

## 🔗 Dependencies Map y Critical Path

### **Dependencias Críticas:**

```
US-001 (Multi-Tenancy) ──┬─→ US-020 (Tax Factory) ─→ US-021/022/023/024/025/026/027 (Tax Engines)
                         │                                           ↓
                         ├─→ US-007 (Multi-Currency) ────────────────┼─→ US-031 (Facturación)
                         │                                           │           ↓
                         ├─→ US-010 (Estructura Regional) ───────────┼─→ US-032 (Cobranzas)
                         │                                           │
                         └─→ US-033 (Plan de Cuentas) ─→ US-034 (Asientos Automáticos)
                                                                      ↓
                                                             US-035 (Asientos Intercompany)
                                                                      ↓
                                                             US-036 (Cierre Contable)
                                                                      ↓
                                                             US-037 (Consolidación)
```

**Critical Path (Ruta Crítica):**
1. US-001 → US-020 → US-021 (Tax AR) → US-031 (Facturación) → US-032 (Cobranzas) → **Release 4**
2. US-001 → US-033 (Plan Cuentas) → US-034 (Asientos) → US-036 (Cierre) → **Release 4**
3. US-037 (Consolidación) → **Release 5**

**Total duración Critical Path:** ~16 semanas (mínimo)

---

## ✅ Definition of Done (Global)

**Criterios generales que TODA User Story debe cumplir antes de considerarse Done:**

### **Código:**
- [ ] Código implementado siguiendo Clean Architecture
- [ ] Código cumple con C# coding standards (StyleCop)
- [ ] Sin code smells críticos en SonarQube
- [ ] Sin vulnerabilidades de seguridad
- [ ] Comentarios XML en métodos públicos
- [ ] Logging estructurado implementado

### **Testing:**
- [ ] Unit Tests escritos y pasando (>95% coverage)
- [ ] Integration Tests escritos y pasando (>80% coverage)
- [ ] Tests de cálculos fiscales/contables al 100%
- [ ] Tests ejecutándose en pipeline CI

### **Base de Datos:**
- [ ] Migraciones de EF Core creadas
- [ ] Seed data incluido (si aplica)
- [ ] Índices definidos para performance
- [ ] Relaciones y constraints correctas

### **API:**
- [ ] Endpoints REST implementados con versionado
- [ ] Swagger/OpenAPI documentado
- [ ] Validaciones de input (FluentValidation)
- [ ] Manejo de errores global (middleware)
- [ ] Response estándar (Result pattern)

### **Seguridad:**
- [ ] Autenticación JWT requerida (si aplica)
- [ ] Autorización RBAC implementada (si aplica)
- [ ] Validación de tenant en queries
- [ ] Logs de auditoría generados

### **Documentación:**
- [ ] README actualizado (si es feature nueva)
- [ ] Documentación técnica en Wiki
- [ ] Diagramas actualizados (si aplica)

### **Code Review:**
- [ ] Pull Request creado
- [ ] Code Review aprobado por 1+ developers
- [ ] CI checks pasando (build, tests, code quality)
- [ ] Branch mergeado a develop/main

### **QA & Deployment:**
- [ ] Smoke tests en Staging pasando
- [ ] Demo funcional al Product Owner
- [ ] Aceptación del Product Owner
- [ ] Deployado a Staging exitosamente

---

## 📈 Métricas de Éxito y KPIs

### **Métricas de Desarrollo:**

| Métrica | Target | Medición |
|---------|--------|----------|
| **Test Coverage** | >90% | SonarCloud/Coverlet |
| **Code Quality Score** | A | SonarQube |
| **Build Success Rate** | >95% | GitHub Actions |
| **PR Review Time** | <24h | GitHub Insights |
| **Deployment Frequency** | 2x/semana | CI/CD metrics |
| **Mean Time to Recovery (MTTR)** | <2h | Incident logs |
| **Vulnerabilities** | 0 críticas | Dependabot/Snyk |

### **Métricas de Negocio:**

| KPI | Target | Descripción |
|-----|--------|-------------|
| **Facturas Electrónicas Emitidas** | >95% éxito | % de facturas autorizadas por organismo fiscal |
| **Tiempo de Cierre Contable** | <2 días | Tiempo para cerrar un mes contable |
| **Precisión de Tipos de Cambio** | 100% | Exactitud en conversiones multi-moneda |
| **Conciliación Intercompany** | >98% automática | % de transacciones intercompany conciliadas sin intervención manual |
| **Uptime del Sistema** | >99.5% | Disponibilidad del sistema |
| **Tiempo de Respuesta API** | <500ms p95 | Percentil 95 de latencia de API |
| **Satisfacción de Usuarios** | >4.5/5 | NPS o encuestas de satisfacción |

### **Métricas de Consolidación:**

| Métrica | Target | Descripción |
|---------|--------|-------------|
| **Tiempo de Consolidación** | <4 horas | Tiempo para consolidar balances de todos los países |
| **Diferencias de Consolidación** | <0.5% | Diferencias no explicadas post-eliminación |
| **Compliance IFRS** | 100% | Reportes cumplen con normas IFRS |
| **Auditorías Sin Hallazgos** | >90% | % de auditorías sin observaciones críticas |

---

## 🎉 Resumen Ejecutivo del Backlog Completo

### **Estadísticas Generales:**

- **Total User Stories:** 50
- **Total Story Points:** ~630 pts
- **Total Epics:** 10
- **Duración Estimada:** 20-24 semanas
- **Team Size Recomendado:** 4-6 developers + 1 QA + 1 DevOps

### **Distribución por Epic:**

| Epic | Stories | Story Points | % Total |
|------|---------|--------------|---------|
| Epic 0: Foundation & Setup | 6 | 63 | 10% |
| Epic 1: Multi-Currency Engine | 3 | 21 | 3% |
| Epic 2: Gestión Inventario Multinacional | 6 | 73 | 12% |
| Epic 3: Compras Multinacionales | 4 | 47 | 7% |
| Epic 4: Tax Engines por País | 8 | 110 | 17% |
| Epic 5: Ventas Multi-País | 5 | 73 | 12% |
| Epic 6: Contabilidad Multinacional | 4 | 60 | 10% |
| Epic 7: Consolidación & IFRS | 4 | 55 | 9% |
| Epic 8: User Management & RBAC | 3 | 34 | 5% |
| Epic 9: DevOps & Testing | 3 | 34 | 5% |
| Epic 10: Localization Adicional | 4 | 21 | 3% |

### **Distribución por Prioridad (MoSCoW):**

- **MUST HAVE:** 38 stories (75%) - 480 pts
- **SHOULD HAVE:** 8 stories (16%) - 110 pts
- **COULD HAVE:** 4 stories (8%) - 40 pts
- **WON'T HAVE:** 0 stories (0%)

### **Tech Stack Confirmado:**

**Backend:**
- .NET 8 (ASP.NET Core Web API)
- Entity Framework Core 8
- MySQL 8
- Redis (caching)
- Hangfire (background jobs)

**Integrations:**
- AFIP Web Services (Argentina)
- SAT PAC (México)
- SII Web Services (Chile)
- SUNAT OSE (Perú)
- DIAN Web Services (Colombia)
- DGI Web Services (Uruguay)

**DevOps & Tools:**
- Docker + Docker Compose
- GitHub Actions
- SonarCloud
- Serilog + Seq/ELK
- Prometheus + Grafana
- xUnit + FluentAssertions
- TestContainers

---

## 🚀 Próximos Pasos

1. **Validación del Backlog:** Revisar con stakeholders (CFO, Contador, Auditor)
2. **Refinement de Sprint 1:** Desglosar US-001 a US-004 en tareas técnicas
3. **Setup de Ambiente:** Configurar repos, CI/CD, ambientes (Dev/Staging/Prod)
4. **Kickoff del Proyecto:** Sprint Planning de Release 1
5. **Comenzar Desarrollo:** Implementar US-001 (Multi-Tenancy Context)

---

**FIN DEL PRODUCT BACKLOG - PARTE 4 de 4**

---

**Notas Finales:**
- Este backlog es un documento vivo que debe actualizarse según feedback del equipo y cambios en el negocio.
- Las estimaciones de Story Points son preliminares y deben refinarse en cada Sprint Planning.
- Los Tax Engines específicos (AR, MX, CL, PE, CO, UY) requieren consultoría con expertos fiscales de cada país.
- La consolidación IFRS (Epic 7) requiere validación con contador experto en IFRS.
- El plan de 20-24 semanas es agresivo pero alcanzable con un equipo experimentado y dedicado.

**Contacto para Consultas:**
- Product Owner: [Definir]
- Scrum Master: [Definir]
- Tech Lead: [Definir]

---

**🎯 ¡Backlog Completo! Listo para iniciar el desarrollo del ERP Multinacional.**
