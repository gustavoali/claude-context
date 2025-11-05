# Sistema ERP Multinacional - Product Backlog (PARTE 3)

**Versión del Documento:** 1.0 - Parte 3 de 4
**Fecha:** 2025-10-11
**Proyecto:** ERP Backend Multinacional - .NET 8 + MySQL
**Alcance:** 8+ países de las Américas

---

## 📚 User Stories Detalladas (Continuación - Parte 3)

Esta parte continúa el Product Backlog con los Epics más críticos del sistema: Tax Engines por país, Ventas, Contabilidad y Consolidación Multinacional.

---

## Epic 4: Tax Engines por País (CRÍTICO)

**Descripción:**
Implementación de motores fiscales específicos para cada país con Factory Pattern. Cada país tiene su propio Tax Engine que implementa la interfaz `ITaxEngine` y maneja la lógica fiscal específica: generación de comprobantes electrónicos, cálculo de impuestos, integración con organismos fiscales (AFIP, SAT, SII, SUNAT, DIAN, DGI), validaciones fiscales, y reportes obligatorios. Este epic es **CRÍTICO** porque sin los tax engines no es posible operar legalmente en cada país.

**Story Points Totales:** 144 pts
**Prioridad:** MUST HAVE (MoSCoW)
**Riesgo:** CRÍTICO - Requiere conocimiento experto de legislación fiscal de cada país

---

### US-020: Tax Engine Factory Pattern

**Como** Arquitecto del Sistema
**Quiero** implementar el Factory Pattern para Tax Engines
**Para** poder crear el motor fiscal correcto según el país del tenant sin duplicación de código

**Story Points:** 8
**Prioridad:** MUST HAVE
**Epic:** Tax Engines por País
**Dependencias:** US-001 (Multi-Tenancy)

#### Acceptance Criteria

**AC-020.1: Interfaz ITaxEngine**
```gherkin
Given que el sistema necesita soportar múltiples países
When se define la interfaz ITaxEngine
Then debe incluir los métodos:
  - Task<InvoiceResponse> GenerateElectronicInvoiceAsync(Invoice invoice)
  - Task<TaxCalculation> CalculateTaxesAsync(TaxableTransaction transaction)
  - Task<ValidationResult> ValidateFiscalDataAsync(FiscalData data)
  - Task<bool> SubmitToTaxAuthorityAsync(ElectronicDocument document)
  - Task<List<TaxReport>> GetRequiredReportsAsync(DateTime period)
And debe ser agnóstico al país específico
```

**AC-020.2: Factory de Tax Engines**
```gherkin
Given que un tenant pertenece a un país específico (ej: "AR", "MX", "CL")
When se solicita el TaxEngine para ese tenant
Then el TaxEngineFactory debe:
  - Leer el CountryCode del TenantContext
  - Resolver el ITaxEngine correcto vía DI
  - Retornar la implementación específica (ej: ArgentinaTaxEngine)
  - Cachear la instancia por tenant (performance)
And si el país no tiene implementación específica debe retornar GenericTaxEngine
```

**AC-020.3: Registro en DI Container**
```gherkin
Given que el sistema usa ASP.NET Core DI
When se configuran los servicios en Program.cs
Then debe registrar:
  - ITaxEngineFactory como Singleton
  - Cada ITaxEngine (Argentina, Mexico, Chile, etc.) como Scoped
  - TaxEngineFactory con estrategia de resolución por CountryCode
And debe soportar hot-swap de implementaciones sin recompilación
```

**AC-020.4: Logging y Telemetry**
```gherkin
Given que se crea un Tax Engine
When el Factory resuelve la implementación
Then debe logear:
  - País del tenant
  - Implementación de Tax Engine seleccionada
  - Tiempo de resolución
  - Errores si la implementación no existe
And debe exponer métricas para monitoreo (Prometheus/Grafana)
```

#### Definition of Done
- [ ] Interfaz `ITaxEngine` definida en Domain layer
- [ ] `TaxEngineFactory` implementado con Strategy Pattern
- [ ] Registro correcto en DI Container con tests
- [ ] Unit Tests para Factory (coverage >95%)
- [ ] Logging estructurado implementado (Serilog)
- [ ] Documentación XML de la interfaz
- [ ] Ejemplo de implementación de un Tax Engine
- [ ] Code Review aprobado
- [ ] Tests de integración pasando

#### Technical Notes
```csharp
// Domain/Interfaces/ITaxEngine.cs
public interface ITaxEngine
{
    Task<InvoiceResponse> GenerateElectronicInvoiceAsync(Invoice invoice, CancellationToken ct);
    Task<TaxCalculation> CalculateTaxesAsync(TaxableTransaction transaction);
    Task<ValidationResult> ValidateFiscalDataAsync(FiscalData data);
    Task<bool> SubmitToTaxAuthorityAsync(ElectronicDocument document);
    Task<List<TaxReport>> GetRequiredReportsAsync(DateTime period);
    string CountryCode { get; }
}

// Application/Services/TaxEngineFactory.cs
public class TaxEngineFactory : ITaxEngineFactory
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ITenantContext _tenantContext;
    private readonly IMemoryCache _cache;
    private readonly ILogger<TaxEngineFactory> _logger;

    public ITaxEngine GetTaxEngine()
    {
        var countryCode = _tenantContext.CountryCode;
        var cacheKey = $"TaxEngine_{countryCode}";

        return _cache.GetOrCreate(cacheKey, entry =>
        {
            entry.SlidingExpiration = TimeSpan.FromHours(1);

            var engine = countryCode switch
            {
                "AR" => _serviceProvider.GetRequiredService<ArgentinaTaxEngine>(),
                "MX" => _serviceProvider.GetRequiredService<MexicoTaxEngine>(),
                "CL" => _serviceProvider.GetRequiredService<ChileTaxEngine>(),
                "PE" => _serviceProvider.GetRequiredService<PeruTaxEngine>(),
                "CO" => _serviceProvider.GetRequiredService<ColombiaTaxEngine>(),
                "UY" => _serviceProvider.GetRequiredService<UruguayTaxEngine>(),
                _ => _serviceProvider.GetRequiredService<GenericTaxEngine>()
            };

            _logger.LogInformation("Tax Engine resolved: {CountryCode} -> {EngineType}",
                countryCode, engine.GetType().Name);

            return engine;
        });
    }
}
```

---

### US-021: Argentina Tax Engine (AFIP)

**Como** Usuario del sistema en Argentina
**Quiero** que el sistema genere facturas electrónicas válidas con AFIP
**Para** cumplir con la legislación fiscal argentina y emitir CAE

**Story Points:** 21
**Prioridad:** MUST HAVE
**Epic:** Tax Engines por País
**Dependencias:** US-020 (Factory Pattern)

#### Acceptance Criteria

**AC-021.1: Tipos de Comprobante AFIP**
```gherkin
Given que soy un tenant de Argentina
When genero una factura
Then el sistema debe soportar:
  - Factura A (Responsable Inscripto a Responsable Inscripto)
  - Factura B (Responsable Inscripto a Consumidor Final/Monotributista)
  - Factura C (Monotributista/Exento a cualquiera)
  - Factura E (Exportación)
  - Nota de Crédito A/B/C
  - Nota de Débito A/B/C
And debe calcular IVA según el tipo de comprobante
```

**AC-021.2: Cálculo de IVA e Impuestos**
```gherkin
Given una factura con productos/servicios
When se calcula el total
Then debe aplicar las tasas de IVA correctas:
  - IVA 21% (general)
  - IVA 10.5% (reducido)
  - IVA 27% (incrementado)
  - IVA 5% (específico)
  - IVA 0% (exento)
And debe calcular percepciones de IVA si aplica (RG 3337)
And debe calcular percepciones de IIBB según jurisdicción
And debe calcular retenciones de IVA/Ganancias según régimen
```

**AC-021.3: Integración con AFIP Web Services**
```gherkin
Given una factura electrónica lista para enviar
When se invoca SubmitToTaxAuthorityAsync()
Then debe:
  - Autenticarse con AFIP usando WSAA (Ticket de Acceso)
  - Invocar WSFEv1 para Factura Electrónica
  - Enviar comprobante con datos fiscales completos
  - Recibir CAE (Código de Autorización Electrónico)
  - Recibir fecha de vencimiento del CAE
  - Guardar CAE y vencimiento en la factura
And debe manejar errores de AFIP con reintentos (max 3)
And debe logear toda la comunicación para auditoría
```

**AC-021.4: Validaciones Fiscales AFIP**
```gherkin
Given datos fiscales de un cliente/proveedor argentino
When se valida con ValidateFiscalDataAsync()
Then debe:
  - Validar formato de CUIT (11 dígitos, dígito verificador correcto)
  - Consultar condición ante AFIP (WS: ws_sr_padron_a13)
  - Verificar que el CUIT esté activo
  - Obtener condición IVA (Responsable Inscripto, Monotributista, Exento, etc.)
  - Validar domicilio fiscal registrado
And debe cachear resultados (TTL: 24 horas)
```

**AC-021.5: Reportes Obligatorios AFIP**
```gherkin
Given un período fiscal (mes/año)
When se solicitan reportes con GetRequiredReportsAsync()
Then debe generar:
  - Libro IVA Ventas (detalle de facturas emitidas)
  - Libro IVA Compras (detalle de facturas recibidas)
  - CITI Ventas (formato texto para SIAP)
  - CITI Compras (formato texto para SIAP)
  - Régimen de Información de Percepciones
  - Régimen de Información de Retenciones
And debe validar el formato según especificaciones AFIP
```

#### Definition of Done
- [ ] `ArgentinaTaxEngine` implementado con ITaxEngine
- [ ] Integración con WSAA y WSFEv1 funcional
- [ ] Cálculo de IVA/Percepciones/Retenciones correcto
- [ ] Validación de CUIT con Padrón A13
- [ ] Generación de CAE exitosa (tests con ambiente HomologaciónAFIP)
- [ ] Generación de reportes CITI Ventas/Compras
- [ ] Unit Tests (>95% coverage)
- [ ] Integration Tests con mock de AFIP
- [ ] Certificado digital configurado (pruebas en homologación)
- [ ] Documentación de configuración AFIP
- [ ] Error handling robusto con reintentos
- [ ] Logging de auditoría completo
- [ ] Code Review aprobado

#### Technical Notes
```csharp
// Infrastructure/TaxEngines/ArgentinaTaxEngine.cs
public class ArgentinaTaxEngine : ITaxEngine
{
    private readonly IAfipWebServiceClient _afipClient;
    private readonly IAfipAuthService _afipAuth;
    private readonly IConfiguration _config;
    private readonly ILogger<ArgentinaTaxEngine> _logger;

    public string CountryCode => "AR";

    public async Task<InvoiceResponse> GenerateElectronicInvoiceAsync(
        Invoice invoice, CancellationToken ct)
    {
        // 1. Validar datos fiscales
        await ValidateFiscalDataAsync(invoice.Customer.FiscalData);

        // 2. Determinar tipo de comprobante (A/B/C/E)
        var compType = DetermineCompType(invoice.Customer.IvaCondition);

        // 3. Calcular impuestos
        var taxCalc = await CalculateTaxesAsync(invoice);

        // 4. Obtener ticket de acceso AFIP
        var ticket = await _afipAuth.GetTicketAsync("wsfe");

        // 5. Armar request WSFEv1
        var request = BuildAfipRequest(invoice, compType, taxCalc);

        // 6. Enviar a AFIP con reintentos
        var response = await _afipClient.FECAESolicitarAsync(ticket, request);

        // 7. Procesar respuesta y guardar CAE
        if (response.FECAEDetResponse.Resultado == "A") // Aprobado
        {
            return new InvoiceResponse
            {
                Success = true,
                AuthorizationCode = response.CAE,
                AuthorizationDate = response.CAEFchVto,
                ElectronicInvoiceUrl = GenerateQrUrl(invoice, response.CAE)
            };
        }

        throw new AfipException(response.Observaciones);
    }

    public async Task<TaxCalculation> CalculateTaxesAsync(TaxableTransaction tx)
    {
        var calc = new TaxCalculation();

        // IVA por línea
        foreach (var line in tx.Lines)
        {
            var ivaRate = GetIvaRate(line.IvaCategory); // 21%, 10.5%, 27%, 5%, 0%
            var ivaAmount = line.NetAmount * ivaRate;

            calc.TaxLines.Add(new TaxLine
            {
                TaxType = "IVA",
                TaxRate = ivaRate,
                BaseAmount = line.NetAmount,
                TaxAmount = ivaAmount
            });
        }

        // Percepciones IVA RG 3337 (si aplica)
        if (RequiresIvaPerception(tx.Customer))
        {
            var perception = CalculateIvaPerception(tx.Customer, calc.TotalNet);
            calc.TaxLines.Add(perception);
        }

        // Percepciones IIBB (según jurisdicción)
        var iibbPerceptions = await CalculateIibbPerceptionsAsync(
            tx.Customer.Province, calc.TotalNet);
        calc.TaxLines.AddRange(iibbPerceptions);

        return calc;
    }

    public async Task<ValidationResult> ValidateFiscalDataAsync(FiscalData data)
    {
        var result = new ValidationResult();

        // 1. Validar formato CUIT
        if (!IsValidCuitFormat(data.TaxId))
        {
            result.AddError("CUIT inválido: formato incorrecto");
            return result;
        }

        // 2. Consultar Padrón A13 AFIP
        var padronInfo = await _afipClient.ConsultarPadronAsync(data.TaxId);

        if (padronInfo == null || padronInfo.Estado != "ACTIVO")
        {
            result.AddError("CUIT no encontrado o inactivo en AFIP");
            return result;
        }

        // 3. Validar condición IVA
        data.IvaCondition = padronInfo.ImpuestoIva; // "Responsable Inscripto", etc.
        result.IsValid = true;

        return result;
    }

    private bool IsValidCuitFormat(string cuit)
    {
        // Validar 11 dígitos y dígito verificador
        if (string.IsNullOrEmpty(cuit) || cuit.Length != 11)
            return false;

        var weights = new[] { 5, 4, 3, 2, 7, 6, 5, 4, 3, 2 };
        var sum = 0;

        for (int i = 0; i < 10; i++)
            sum += int.Parse(cuit[i].ToString()) * weights[i];

        var checkDigit = 11 - (sum % 11);
        if (checkDigit == 11) checkDigit = 0;
        if (checkDigit == 10) checkDigit = 9;

        return checkDigit == int.Parse(cuit[10].ToString());
    }
}

// Configuración en appsettings.json
{
  "Afip": {
    "Environment": "Homologacion", // o "Production"
    "Cuit": "20123456789",
    "CertificatePath": "/certs/afip-cert.pfx",
    "CertificatePassword": "****",
    "WsaaUrl": "https://wsaahomo.afip.gov.ar/ws/services/LoginCms",
    "WsfeUrl": "https://wswhomo.afip.gov.ar/wsfev1/service.asmx",
    "PadronUrl": "https://aws.afip.gov.ar/sr-padron/webservices/personaServiceA13"
  }
}
```

---

### US-022: México Tax Engine (SAT)

**Como** Usuario del sistema en México
**Quiero** que el sistema genere CFDIs (Comprobantes Fiscales Digitales por Internet) válidos con el SAT
**Para** cumplir con la legislación fiscal mexicana y obtener el Timbre Fiscal Digital

**Story Points:** 21
**Prioridad:** MUST HAVE
**Epic:** Tax Engines por País
**Dependencias:** US-020 (Factory Pattern)

#### Acceptance Criteria

**AC-022.1: Tipos de CFDI**
```gherkin
Given que soy un tenant de México
When genero una factura
Then el sistema debe soportar:
  - CFDI 4.0 de Ingreso (factura de venta)
  - CFDI 4.0 de Egreso (nota de crédito)
  - CFDI 4.0 de Traslado (guía de remisión)
  - CFDI 4.0 de Pago (complemento de pago)
  - CFDI 4.0 de Nómina (recibos de pago)
And debe incluir todos los campos obligatorios según SAT
```

**AC-022.2: Cálculo de Impuestos IVA e IEPS**
```gherkin
Given una factura con productos/servicios
When se calcula el total
Then debe aplicar:
  - IVA 16% (tasa general)
  - IVA 0% (tasa exenta - exportación, medicinas, alimentos)
  - IEPS (Impuesto Especial sobre Producción y Servicios)
  - ISR (Impuesto Sobre la Renta) en retenciones
And debe separar claramente traslados vs retenciones
And debe incluir el desglose por concepto
```

**AC-022.3: Timbrado con PAC**
```gherkin
Given un CFDI 4.0 generado en formato XML
When se invoca SubmitToTaxAuthorityAsync()
Then debe:
  - Generar Cadena Original según anexo 20 SAT
  - Firmar XML con Certificado de Sello Digital (CSD)
  - Enviar a PAC (Proveedor Autorizado de Certificación) para timbrado
  - Recibir Timbre Fiscal Digital (TFD)
  - Recibir UUID (folio fiscal único)
  - Insertar TFD en el XML
  - Guardar XML timbrado
And debe manejar errores de PAC con reintentos
And debe validar contra XSD del SAT antes de enviar
```

**AC-022.4: Validaciones Fiscales SAT**
```gherkin
Given datos fiscales de un cliente/proveedor mexicano
When se valida con ValidateFiscalDataAsync()
Then debe:
  - Validar formato de RFC (12 o 13 caracteres con homoclave)
  - Validar RFC contra Lista 69 del SAT (contribuyentes no localizados)
  - Validar domicilio fiscal (código postal válido)
  - Validar Régimen Fiscal (clave de catálogo SAT)
  - Validar Uso de CFDI (clave según catálogo SAT)
And debe usar los catálogos oficiales del SAT (actualizados)
```

**AC-022.5: Reportes y Complementos**
```gherkin
Given un período fiscal
When se solicitan reportes con GetRequiredReportsAsync()
Then debe generar:
  - Layout de DIOT (Declaración Informativa de Operaciones con Terceros)
  - Reporte de CFDIs emitidos (para contabilidad electrónica)
  - Reporte de CFDIs recibidos (para deducibilidad)
  - Complemento de Pago (conciliación de facturas vs pagos)
And debe cumplir con formato de Contabilidad Electrónica SAT
```

#### Definition of Done
- [ ] `MexicoTaxEngine` implementado con ITaxEngine
- [ ] Generación de CFDI 4.0 XML válido (XSD SAT)
- [ ] Integración con PAC (ej: Finkok, Ecodex, SW Sapien) funcional
- [ ] Timbrado exitoso con obtención de UUID
- [ ] Cálculo de IVA/IEPS/ISR correcto
- [ ] Validación de RFC y Lista 69 SAT
- [ ] Generación de Cadena Original correcta
- [ ] Firma digital con CSD implementada
- [ ] Catálogos SAT integrados (Régimen, Uso CFDI, etc.)
- [ ] Unit Tests (>95% coverage)
- [ ] Integration Tests con PAC en ambiente pruebas
- [ ] Certificados de prueba configurados
- [ ] Documentación de configuración SAT/PAC
- [ ] Error handling robusto
- [ ] Code Review aprobado

#### Technical Notes
```csharp
// Infrastructure/TaxEngines/MexicoTaxEngine.cs
public class MexicoTaxEngine : ITaxEngine
{
    private readonly IPacClient _pacClient;
    private readonly ISatCatalogsService _satCatalogs;
    private readonly IXmlSigningService _xmlSigner;
    private readonly IConfiguration _config;
    private readonly ILogger<MexicoTaxEngine> _logger;

    public string CountryCode => "MX";

    public async Task<InvoiceResponse> GenerateElectronicInvoiceAsync(
        Invoice invoice, CancellationToken ct)
    {
        // 1. Validar datos fiscales emisor y receptor
        await ValidateFiscalDataAsync(invoice.Issuer.FiscalData);
        await ValidateFiscalDataAsync(invoice.Customer.FiscalData);

        // 2. Calcular impuestos
        var taxCalc = await CalculateTaxesAsync(invoice);

        // 3. Generar XML CFDI 4.0
        var cfdiXml = GenerateCfdi40Xml(invoice, taxCalc);

        // 4. Validar contra XSD del SAT
        ValidateAgainstXsd(cfdiXml);

        // 5. Generar Cadena Original
        var cadenaOriginal = GenerateCadenaOriginal(cfdiXml);

        // 6. Firmar con CSD
        var signedXml = await _xmlSigner.SignXmlAsync(cfdiXml, cadenaOriginal);

        // 7. Enviar a PAC para timbrado
        var timbradoResponse = await _pacClient.TimbrarAsync(signedXml);

        if (timbradoResponse.Success)
        {
            return new InvoiceResponse
            {
                Success = true,
                AuthorizationCode = timbradoResponse.UUID,
                ElectronicDocument = timbradoResponse.XmlTimbrado,
                ElectronicInvoiceUrl = GenerateQrUrl(invoice, timbradoResponse.UUID)
            };
        }

        throw new SatException(timbradoResponse.ErrorMessage);
    }

    private XDocument GenerateCfdi40Xml(Invoice invoice, TaxCalculation taxCalc)
    {
        var cfdi = new XDocument(
            new XDeclaration("1.0", "UTF-8", null),
            new XElement(XName.Get("Comprobante", "http://www.sat.gob.mx/cfd/4"),
                new XAttribute("Version", "4.0"),
                new XAttribute("Serie", invoice.Series),
                new XAttribute("Folio", invoice.Number),
                new XAttribute("Fecha", invoice.Date.ToString("yyyy-MM-ddTHH:mm:ss")),
                new XAttribute("FormaPago", invoice.PaymentMethod), // Catálogo SAT c_FormaPago
                new XAttribute("SubTotal", taxCalc.TotalNet.ToString("F2")),
                new XAttribute("Total", taxCalc.TotalWithTax.ToString("F2")),
                new XAttribute("Moneda", invoice.CurrencyCode),
                new XAttribute("TipoDeComprobante", "I"), // I=Ingreso, E=Egreso, T=Traslado, P=Pago
                new XAttribute("MetodoPago", "PUE"), // PUE=Pago en Una Exhibición, PPD=Pago en Parcialidades
                new XAttribute("LugarExpedicion", invoice.Issuer.PostalCode),

                // Emisor
                new XElement(XName.Get("Emisor", "http://www.sat.gob.mx/cfd/4"),
                    new XAttribute("Rfc", invoice.Issuer.FiscalData.TaxId),
                    new XAttribute("Nombre", invoice.Issuer.Name),
                    new XAttribute("RegimenFiscal", invoice.Issuer.FiscalData.TaxRegime) // Catálogo c_RegimenFiscal
                ),

                // Receptor
                new XElement(XName.Get("Receptor", "http://www.sat.gob.mx/cfd/4"),
                    new XAttribute("Rfc", invoice.Customer.FiscalData.TaxId),
                    new XAttribute("Nombre", invoice.Customer.Name),
                    new XAttribute("DomicilioFiscalReceptor", invoice.Customer.PostalCode),
                    new XAttribute("RegimenFiscalReceptor", invoice.Customer.FiscalData.TaxRegime),
                    new XAttribute("UsoCFDI", invoice.CfdiUsage) // Catálogo c_UsoCFDI
                ),

                // Conceptos (productos/servicios)
                new XElement(XName.Get("Conceptos", "http://www.sat.gob.mx/cfd/4"),
                    invoice.Lines.Select(line => new XElement(XName.Get("Concepto", "http://www.sat.gob.mx/cfd/4"),
                        new XAttribute("ClaveProdServ", line.SatProductCode), // Catálogo c_ClaveProdServ
                        new XAttribute("Cantidad", line.Quantity),
                        new XAttribute("ClaveUnidad", line.SatUnitCode), // Catálogo c_ClaveUnidad
                        new XAttribute("Descripcion", line.Description),
                        new XAttribute("ValorUnitario", line.UnitPrice.ToString("F2")),
                        new XAttribute("Importe", line.Amount.ToString("F2")),
                        new XAttribute("ObjetoImp", "02"), // 02=Sí objeto de impuesto

                        // Impuestos por concepto
                        new XElement(XName.Get("Impuestos", "http://www.sat.gob.mx/cfd/4"),
                            new XElement(XName.Get("Traslados", "http://www.sat.gob.mx/cfd/4"),
                                new XElement(XName.Get("Traslado", "http://www.sat.gob.mx/cfd/4"),
                                    new XAttribute("Base", line.Amount.ToString("F2")),
                                    new XAttribute("Impuesto", "002"), // 002=IVA
                                    new XAttribute("TipoFactor", "Tasa"),
                                    new XAttribute("TasaOCuota", "0.160000"),
                                    new XAttribute("Importe", (line.Amount * 0.16m).ToString("F2"))
                                )
                            )
                        )
                    ))
                ),

                // Impuestos totales
                new XElement(XName.Get("Impuestos", "http://www.sat.gob.mx/cfd/4"),
                    new XAttribute("TotalImpuestosTrasladados", taxCalc.TotalTax.ToString("F2")),
                    new XElement(XName.Get("Traslados", "http://www.sat.gob.mx/cfd/4"),
                        new XElement(XName.Get("Traslado", "http://www.sat.gob.mx/cfd/4"),
                            new XAttribute("Base", taxCalc.TotalNet.ToString("F2")),
                            new XAttribute("Impuesto", "002"), // IVA
                            new XAttribute("TipoFactor", "Tasa"),
                            new XAttribute("TasaOCuota", "0.160000"),
                            new XAttribute("Importe", taxCalc.TotalTax.ToString("F2"))
                        )
                    )
                )
            )
        );

        return cfdi;
    }

    public async Task<ValidationResult> ValidateFiscalDataAsync(FiscalData data)
    {
        var result = new ValidationResult();

        // 1. Validar formato RFC
        if (!IsValidRfcFormat(data.TaxId))
        {
            result.AddError("RFC inválido: formato incorrecto");
            return result;
        }

        // 2. Validar contra Lista 69 SAT (contribuyentes no localizados)
        var isInLista69 = await _satCatalogs.CheckLista69Async(data.TaxId);
        if (isInLista69)
        {
            result.AddError("RFC en Lista 69 del SAT (contribuyente no localizado)");
            return result;
        }

        // 3. Validar Régimen Fiscal
        var regimenValido = await _satCatalogs.ValidateRegimenFiscalAsync(data.TaxRegime);
        if (!regimenValido)
        {
            result.AddError($"Régimen Fiscal inválido: {data.TaxRegime}");
        }

        result.IsValid = !result.HasErrors;
        return result;
    }

    private bool IsValidRfcFormat(string rfc)
    {
        // RFC Persona Moral: 12 caracteres (ej: ABC123456XY1)
        // RFC Persona Física: 13 caracteres (ej: ABCD850101XY2)
        if (string.IsNullOrEmpty(rfc) || (rfc.Length != 12 && rfc.Length != 13))
            return false;

        var regex = new Regex(@"^[A-ZÑ&]{3,4}\d{6}[A-Z0-9]{3}$");
        return regex.IsMatch(rfc);
    }
}

// Configuración en appsettings.json
{
  "Sat": {
    "Environment": "Pruebas", // o "Produccion"
    "Rfc": "EKU9003173C9",
    "CertificatePath": "/certs/csd-cert.cer",
    "KeyPath": "/certs/csd-key.key",
    "KeyPassword": "****",
    "Pac": {
      "Provider": "Finkok", // o "Ecodex", "SWSapien"
      "Username": "demo",
      "Password": "demo",
      "TimbradoUrl": "https://demo-facturacion.finkok.com/servicios/soap/stamp.wsdl"
    }
  }
}
```

---

### US-023: Chile Tax Engine (SII)

**Como** Usuario del sistema en Chile
**Quiero** que el sistema genere Facturas Electrónicas válidas con el SII
**Para** cumplir con la legislación fiscal chilena y obtener el Timbre Electrónico

**Story Points:** 13
**Prioridad:** MUST HAVE
**Epic:** Tax Engines por País
**Dependencias:** US-020 (Factory Pattern)

#### Acceptance Criteria

**AC-023.1: Tipos de Documentos Tributarios Electrónicos (DTE)**
```gherkin
Given que soy un tenant de Chile
When genero un documento tributario
Then el sistema debe soportar:
  - Factura Electrónica (tipo 33)
  - Factura Exenta Electrónica (tipo 34)
  - Boleta Electrónica (tipo 39)
  - Nota de Crédito Electrónica (tipo 61)
  - Nota de Débito Electrónica (tipo 56)
  - Guía de Despacho Electrónica (tipo 52)
And debe incluir todos los campos obligatorios según SII
```

**AC-023.2: Cálculo de IVA**
```gherkin
Given una factura con productos/servicios
When se calcula el total
Then debe aplicar:
  - IVA 19% (tasa general)
  - IVA 0% (exento - educación, salud, etc.)
And debe separar Monto Neto vs Monto Exento
And debe mostrar el desglose del IVA
```

**AC-023.3: Generación de DTE y Timbre Electrónico**
```gherkin
Given un DTE generado en formato XML
When se invoca SubmitToTaxAuthorityAsync()
Then debe:
  - Generar XML según XSD del SII
  - Calcular Timbre Electrónico (hash SHA-1 + firma RSA)
  - Firmar XML con Certificado Digital del contribuyente
  - Enviar a SII vía Web Service (EnvioDTE)
  - Recibir Track ID del envío
  - Consultar estado del envío hasta recibir aceptación
  - Guardar XML con firma y timbre
And debe generar PDF con código 2D (PDF417) del timbre
```

**AC-023.4: Validaciones Fiscales SII**
```gherkin
Given datos fiscales de un cliente/proveedor chileno
When se valida con ValidateFiscalDataAsync()
Then debe:
  - Validar formato de RUT (8-9 dígitos + guión + dígito verificador)
  - Calcular dígito verificador correcto
  - Validar que la Razón Social corresponda al RUT (opcional: consulta SII)
  - Validar giro comercial
And debe formatear RUT correctamente (ej: 76.123.456-7)
```

**AC-023.5: Libro de Compras y Ventas Electrónico**
```gherkin
Given un período fiscal (mes)
When se solicitan reportes con GetRequiredReportsAsync()
Then debe generar:
  - Libro de Compras y Ventas Electrónico (formato XML SII)
  - Registro de Compras y Ventas (RCOF)
  - Detalle de IVA por documento
And debe enviar a SII antes del día 11 del mes siguiente
```

#### Definition of Done
- [ ] `ChileTaxEngine` implementado con ITaxEngine
- [ ] Generación de DTE XML válido (XSD SII)
- [ ] Cálculo de Timbre Electrónico correcto
- [ ] Firma digital con certificado implementada
- [ ] Integración con Web Services SII funcional
- [ ] Validación de RUT con dígito verificador
- [ ] Generación de PDF con código 2D (PDF417)
- [ ] Libro de Compras y Ventas Electrónico
- [ ] Unit Tests (>95% coverage)
- [ ] Integration Tests con SII en ambiente certificación
- [ ] Certificado digital de prueba configurado
- [ ] Documentación de configuración SII
- [ ] Code Review aprobado

#### Technical Notes
```csharp
// Infrastructure/TaxEngines/ChileTaxEngine.cs
public class ChileTaxEngine : ITaxEngine
{
    private readonly ISiiWebServiceClient _siiClient;
    private readonly IXmlSigningService _xmlSigner;
    private readonly IPdfGeneratorService _pdfGenerator;
    private readonly ILogger<ChileTaxEngine> _logger;

    public string CountryCode => "CL";

    public async Task<InvoiceResponse> GenerateElectronicInvoiceAsync(
        Invoice invoice, CancellationToken ct)
    {
        // 1. Validar RUT emisor y receptor
        await ValidateFiscalDataAsync(invoice.Issuer.FiscalData);
        await ValidateFiscalDataAsync(invoice.Customer.FiscalData);

        // 2. Generar DTE XML
        var dteXml = GenerateDteXml(invoice);

        // 3. Calcular Timbre Electrónico
        var timbre = GenerateTimbreElectronico(dteXml);

        // 4. Insertar Timbre en el XML
        var dteConTimbre = InsertTimbre(dteXml, timbre);

        // 5. Firmar XML completo
        var signedXml = await _xmlSigner.SignXmlAsync(dteConTimbre);

        // 6. Enviar a SII
        var trackId = await _siiClient.EnviarDteAsync(signedXml);

        // 7. Consultar estado hasta aceptación
        var estado = await PollDteStatusAsync(trackId);

        // 8. Generar PDF con código 2D
        var pdf = await _pdfGenerator.GenerateDtePdfAsync(signedXml, timbre);

        return new InvoiceResponse
        {
            Success = true,
            AuthorizationCode = trackId.ToString(),
            ElectronicDocument = signedXml.ToString(),
            ElectronicInvoiceUrl = GenerateUrlCedible(invoice, trackId)
        };
    }

    public async Task<ValidationResult> ValidateFiscalDataAsync(FiscalData data)
    {
        var result = new ValidationResult();

        // Validar formato RUT
        if (!IsValidRutFormat(data.TaxId, out string rut, out string dv))
        {
            result.AddError("RUT inválido: formato incorrecto");
            return result;
        }

        // Calcular dígito verificador
        var expectedDv = CalculateRutVerifier(rut);
        if (expectedDv != dv)
        {
            result.AddError($"RUT inválido: dígito verificador incorrecto (esperado: {expectedDv})");
        }

        result.IsValid = !result.HasErrors;
        return result;
    }

    private bool IsValidRutFormat(string rutCompleto, out string rut, out string dv)
    {
        // Formato: 12.345.678-9 o 12345678-9
        rut = "";
        dv = "";

        var cleaned = rutCompleto?.Replace(".", "").Replace("-", "");
        if (string.IsNullOrEmpty(cleaned) || cleaned.Length < 2)
            return false;

        rut = cleaned.Substring(0, cleaned.Length - 1);
        dv = cleaned.Substring(cleaned.Length - 1).ToUpper();

        return int.TryParse(rut, out _) && (char.IsDigit(dv[0]) || dv == "K");
    }

    private string CalculateRutVerifier(string rut)
    {
        int suma = 0;
        int multiplicador = 2;

        for (int i = rut.Length - 1; i >= 0; i--)
        {
            suma += int.Parse(rut[i].ToString()) * multiplicador;
            multiplicador = multiplicador == 7 ? 2 : multiplicador + 1;
        }

        int dv = 11 - (suma % 11);

        return dv switch
        {
            11 => "0",
            10 => "K",
            _ => dv.ToString()
        };
    }
}
```

---

### US-024: Perú Tax Engine (SUNAT)

**Como** Usuario del sistema en Perú
**Quiero** que el sistema genere Comprobantes de Pago Electrónicos válidos con SUNAT
**Para** cumplir con la legislación fiscal peruana

**Story Points:** 13
**Prioridad:** MUST HAVE
**Epic:** Tax Engines por País
**Dependencias:** US-020 (Factory Pattern)

#### Acceptance Criteria

**AC-024.1: Tipos de Comprobantes Electrónicos**
```gherkin
Given que soy un tenant de Perú
When genero un comprobante
Then el sistema debe soportar:
  - Factura Electrónica
  - Boleta de Venta Electrónica
  - Nota de Crédito Electrónica
  - Nota de Débito Electrónica
  - Guía de Remisión Electrónica
And debe usar formato UBL 2.1 (estándar internacional)
```

**AC-024.2: Cálculo de IGV y Detracciones**
```gherkin
Given una factura con productos/servicios
When se calcula el total
Then debe aplicar:
  - IGV 18% (Impuesto General a las Ventas)
  - Detracción según anexo (ej: 10% para servicios, 4-15% según bien/servicio)
  - Percepción de IGV si aplica
And debe calcular el monto de detracción automáticamente
And debe generar constancia de detracción
```

**AC-024.3: Envío a OSE o SOL SUNAT**
```gherkin
Given un comprobante electrónico en formato UBL
When se invoca SubmitToTaxAuthorityAsync()
Then debe:
  - Firmar XML con Certificado Digital
  - Enviar a OSE (Operador de Servicios Electrónicos) o SOL SUNAT
  - Recibir CDR (Constancia de Recepción) con código de respuesta
  - Validar que CDR indique "Aceptado" (código 0)
  - Guardar CDR para auditoría
And debe manejar casos de rechazo con errores detallados
```

**AC-024.4: Validaciones Fiscales SUNAT**
```gherkin
Given datos fiscales de un cliente/proveedor peruano
When se valida con ValidateFiscalDataAsync()
Then debe:
  - Validar formato de RUC (11 dígitos numéricos)
  - Validar DNI (8 dígitos) para personas naturales
  - Consultar estado en Padrón SUNAT (opcional)
  - Validar condición de domicilio
And debe cachear resultados
```

**AC-024.5: Reportes PLE (Programa de Libros Electrónicos)**
```gherkin
Given un período fiscal
When se solicitan reportes con GetRequiredReportsAsync()
Then debe generar:
  - Registro de Ventas e Ingresos (formato PLE)
  - Registro de Compras (formato PLE)
  - Libro Diario (formato PLE)
And debe cumplir con el formato txt pipe-delimited de SUNAT
```

#### Definition of Done
- [ ] `PeruTaxEngine` implementado con ITaxEngine
- [ ] Generación de XML UBL 2.1 correcto
- [ ] Firma digital implementada
- [ ] Integración con OSE o SOL SUNAT funcional
- [ ] Cálculo de IGV y Detracciones correcto
- [ ] Validación de RUC/DNI
- [ ] Procesamiento de CDR
- [ ] Generación de PLE (Libros Electrónicos)
- [ ] Unit Tests (>95% coverage)
- [ ] Integration Tests con OSE en ambiente pruebas
- [ ] Documentación de configuración
- [ ] Code Review aprobado

#### Technical Notes
```csharp
// Infrastructure/TaxEngines/PeruTaxEngine.cs
public class PeruTaxEngine : ITaxEngine
{
    private readonly IOseClient _oseClient; // Operador de Servicios Electrónicos
    private readonly IXmlSigningService _xmlSigner;
    private readonly ILogger<PeruTaxEngine> _logger;

    public string CountryCode => "PE";

    public async Task<InvoiceResponse> GenerateElectronicInvoiceAsync(
        Invoice invoice, CancellationToken ct)
    {
        // 1. Generar XML UBL 2.1
        var ublXml = GenerateUblXml(invoice);

        // 2. Calcular detracciones si aplica
        var detraccion = CalculateDetraccion(invoice);
        if (detraccion > 0)
            invoice.Detraccion = detraccion;

        // 3. Firmar XML
        var signedXml = await _xmlSigner.SignXmlAsync(ublXml);

        // 4. Enviar a OSE
        var cdr = await _oseClient.SendBillAsync(signedXml);

        // 5. Validar CDR
        if (cdr.ResponseCode == "0") // Aceptado
        {
            return new InvoiceResponse
            {
                Success = true,
                AuthorizationCode = cdr.DigestValue,
                ElectronicDocument = signedXml.ToString(),
                ConstanciaRecepcion = cdr.XmlContent
            };
        }

        throw new SunatException($"Comprobante rechazado: {cdr.Description}");
    }

    public async Task<TaxCalculation> CalculateTaxesAsync(TaxableTransaction tx)
    {
        var calc = new TaxCalculation();

        // IGV 18%
        var igvBase = tx.Lines.Sum(l => l.NetAmount);
        var igvAmount = igvBase * 0.18m;

        calc.TaxLines.Add(new TaxLine
        {
            TaxType = "IGV",
            TaxRate = 0.18m,
            BaseAmount = igvBase,
            TaxAmount = igvAmount
        });

        // Detracción (si aplica)
        if (RequiresDetraccion(tx))
        {
            var detraccionRate = GetDetraccionRate(tx.Category);
            var detraccionAmount = (igvBase + igvAmount) * detraccionRate;

            calc.TaxLines.Add(new TaxLine
            {
                TaxType = "DETRACCION",
                TaxRate = detraccionRate,
                BaseAmount = igvBase + igvAmount,
                TaxAmount = detraccionAmount
            });
        }

        return calc;
    }

    private bool RequiresDetraccion(TaxableTransaction tx)
    {
        // Anexo 1 y 2 de Resolución de Superintendencia N° 183-2004/SUNAT
        // Servicios >700 soles, ciertos bienes según anexo
        return tx.TotalAmount >= 700 && IsDetraccionCategory(tx.Category);
    }

    private decimal GetDetraccionRate(string category)
    {
        // Tasas según anexo SUNAT
        return category switch
        {
            "SERVICES" => 0.10m, // 10% servicios
            "GRAINS" => 0.04m,   // 4% granos
            _ => 0.10m
        };
    }
}
```

---

### US-025: Colombia Tax Engine (DIAN)

**Como** Usuario del sistema en Colombia
**Quiero** que el sistema genere Facturas Electrónicas válidas con la DIAN
**Para** cumplir con la legislación fiscal colombiana

**Story Points:** 13
**Prioridad:** MUST HAVE
**Epic:** Tax Engines por País
**Dependencias:** US-020 (Factory Pattern)

#### Acceptance Criteria

**AC-025.1: Tipos de Documentos Electrónicos**
```gherkin
Given que soy un tenant de Colombia
When genero un documento
Then el sistema debe soportar:
  - Factura Electrónica de Venta
  - Nota Crédito Electrónica
  - Nota Débito Electrónica
  - Documento Soporte Electrónico (compras)
And debe usar formato UBL 2.1 según especificación DIAN
```

**AC-025.2: Cálculo de IVA y Retenciones**
```gherkin
Given una factura con productos/servicios
When se calcula el total
Then debe aplicar:
  - IVA 19% (general)
  - IVA 5% (reducido - algunos alimentos, medicinas)
  - IVA 0% (exento)
  - ICA (Impuesto de Industria y Comercio) según municipio
  - Retención en la fuente (si aplica)
And debe separar bienes gravados vs excluidos vs exentos
```

**AC-025.3: Envío a DIAN y CUFE**
```gherkin
Given una factura electrónica en formato UBL
When se invoca SubmitToTaxAuthorityAsync()
Then debe:
  - Calcular CUFE (Código Único de Factura Electrónica)
  - Generar QR con información de validación
  - Firmar XML con Certificado Digital
  - Enviar a DIAN vía Web Service
  - Recibir acuse de recibo
  - Validar respuesta de DIAN
And debe enviar también por email al cliente (requisito DIAN)
```

**AC-025.4: Validaciones Fiscales DIAN**
```gherkin
Given datos fiscales de un cliente/proveedor colombiano
When se valida con ValidateFiscalDataAsync()
Then debe:
  - Validar formato de NIT (9-10 dígitos + dígito de verificación)
  - Calcular dígito de verificación correcto
  - Validar régimen tributario (Común, Simplificado, etc.)
  - Validar responsabilidades fiscales (IVA, ICA, etc.)
And debe formatear NIT correctamente
```

**AC-025.5: Reportes DIAN**
```gherkin
Given un período fiscal
When se solicitan reportes con GetRequiredReportsAsync()
Then debe generar:
  - Medios Magnéticos (formato XML DIAN)
  - Reporte de IVA bimestral
  - Reporte de Retención en la Fuente mensual
And debe cumplir con especificaciones técnicas DIAN
```

#### Definition of Done
- [ ] `ColombiaTaxEngine` implementado con ITaxEngine
- [ ] Generación de UBL 2.1 según DIAN
- [ ] Cálculo de CUFE correcto
- [ ] Generación de QR code
- [ ] Firma digital implementada
- [ ] Integración con Web Services DIAN funcional
- [ ] Validación de NIT con dígito verificador
- [ ] Cálculo de IVA/ICA/Retenciones
- [ ] Unit Tests (>95% coverage)
- [ ] Integration Tests con DIAN en ambiente habilitación
- [ ] Documentación de configuración
- [ ] Code Review aprobado

#### Technical Notes
```csharp
// Infrastructure/TaxEngines/ColombiaTaxEngine.cs
public class ColombiaTaxEngine : ITaxEngine
{
    private readonly IDianWebServiceClient _dianClient;
    private readonly IXmlSigningService _xmlSigner;
    private readonly IQrCodeGenerator _qrGenerator;
    private readonly ILogger<ColombiaTaxEngine> _logger;

    public string CountryCode => "CO";

    public async Task<InvoiceResponse> GenerateElectronicInvoiceAsync(
        Invoice invoice, CancellationToken ct)
    {
        // 1. Generar CUFE
        var cufe = GenerateCufe(invoice);
        invoice.Cufe = cufe;

        // 2. Generar XML UBL 2.1
        var ublXml = GenerateUblXml(invoice);

        // 3. Firmar XML
        var signedXml = await _xmlSigner.SignXmlAsync(ublXml);

        // 4. Generar QR
        var qrCode = _qrGenerator.Generate(BuildQrData(invoice, cufe));

        // 5. Enviar a DIAN
        var response = await _dianClient.SendBillAsync(signedXml);

        if (response.IsSuccess)
        {
            return new InvoiceResponse
            {
                Success = true,
                AuthorizationCode = cufe,
                ElectronicDocument = signedXml.ToString(),
                QrCodeImage = qrCode
            };
        }

        throw new DianException(response.ErrorMessage);
    }

    private string GenerateCufe(Invoice invoice)
    {
        // CUFE = SHA-384(
        //   NumFac + FecFac + HorFac + ValFac + CodImp1 + ValImp1 + ... +
        //   NitOFE + NumAdq + ClTec + TipAmb
        // )
        var cufeString = $"{invoice.Number}{invoice.Date:yyyyMMdd}{invoice.Date:HHmmss}" +
                        $"{invoice.TotalAmount:F2}{invoice.TaxAmount:F2}" +
                        $"{invoice.Issuer.Nit}{invoice.Customer.Nit}" +
                        $"{_config["Dian:TechnicalKey"]}{_config["Dian:Environment"]}";

        using var sha384 = SHA384.Create();
        var hash = sha384.ComputeHash(Encoding.UTF8.GetBytes(cufeString));
        return Convert.ToHexString(hash).ToLower();
    }

    public async Task<ValidationResult> ValidateFiscalDataAsync(FiscalData data)
    {
        var result = new ValidationResult();

        // Validar NIT
        if (!IsValidNitFormat(data.TaxId, out string nit, out string dv))
        {
            result.AddError("NIT inválido: formato incorrecto");
            return result;
        }

        var expectedDv = CalculateNitVerifier(nit);
        if (expectedDv.ToString() != dv)
        {
            result.AddError($"NIT inválido: dígito de verificación incorrecto");
        }

        result.IsValid = !result.HasErrors;
        return result;
    }

    private int CalculateNitVerifier(string nit)
    {
        int[] primos = { 3, 7, 13, 17, 19, 23, 29, 37, 41, 43, 47, 53, 59, 67, 71 };
        int suma = 0;
        int pos = 0;

        for (int i = nit.Length - 1; i >= 0; i--)
        {
            suma += int.Parse(nit[i].ToString()) * primos[pos++];
        }

        int residuo = suma % 11;
        return residuo > 1 ? 11 - residuo : residuo;
    }
}
```

---

### US-026: Uruguay Tax Engine (DGI)

**Como** Usuario del sistema en Uruguay
**Quiero** que el sistema genere Comprobantes Fiscales Electrónicos válidos con DGI
**Para** cumplir con la legislación fiscal uruguaya

**Story Points:** 13
**Prioridad:** SHOULD HAVE
**Epic:** Tax Engines por País
**Dependencias:** US-020 (Factory Pattern)

#### Acceptance Criteria

**AC-026.1: Tipos de CFE (Comprobantes Fiscales Electrónicos)**
```gherkin
Given que soy un tenant de Uruguay
When genero un comprobante
Then el sistema debe soportar:
  - e-Factura (tipo 111, 112, 113)
  - e-Ticket (tipo 101, 102, 103)
  - e-Boleta (tipo 211, 212, 213)
  - Nota de Crédito Electrónica
  - Nota de Débito Electrónica
  - e-Remito
And debe incluir CAE (Código de Autorización Electrónico)
```

**AC-026.2: Cálculo de IVA**
```gherkin
Given una factura con productos/servicios
When se calcula el total
Then debe aplicar:
  - IVA Básica 22%
  - IVA Mínima 10%
  - IVA 0% (exento)
And debe desglosar IVA por tasa
```

**AC-026.3: Envío a DGI y CFE**
```gherkin
Given un CFE generado
When se invoca SubmitToTaxAuthorityAsync()
Then debe:
  - Generar XML según XSD de DGI
  - Firmar con Certificado Digital
  - Enviar a DGI vía Web Service
  - Recibir número de CFE único
  - Generar código de barras 2D
And debe validar contra RUT Receptor
```

**AC-026.4: Validaciones Fiscales DGI**
```gherkin
Given datos fiscales de un cliente/proveedor uruguayo
When se valida con ValidateFiscalDataAsync()
Then debe:
  - Validar formato de RUT (12 dígitos)
  - Validar dígito verificador
  - Consultar DGI para verificar estado
And debe formatear RUT correctamente
```

**AC-026.5: Reportes DGI**
```gherkin
Given un período fiscal
When se solicitan reportes con GetRequiredReportsAsync()
Then debe generar:
  - Resumen de CFE emitidos
  - Libro IVA Compras
  - Libro IVA Ventas
And debe cumplir con formato DGI
```

#### Definition of Done
- [ ] `UruguayTaxEngine` implementado con ITaxEngine
- [ ] Generación de CFE XML válido
- [ ] Firma digital implementada
- [ ] Integración con DGI funcional
- [ ] Validación de RUT
- [ ] Cálculo de IVA correcto
- [ ] Generación de código de barras 2D
- [ ] Unit Tests (>90% coverage)
- [ ] Integration Tests con DGI en ambiente testing
- [ ] Documentación de configuración
- [ ] Code Review aprobado

#### Technical Notes
```csharp
// Infrastructure/TaxEngines/UruguayTaxEngine.cs
public class UruguayTaxEngine : ITaxEngine
{
    private readonly IDgiWebServiceClient _dgiClient;
    private readonly IXmlSigningService _xmlSigner;
    private readonly ILogger<UruguayTaxEngine> _logger;

    public string CountryCode => "UY";

    public async Task<InvoiceResponse> GenerateElectronicInvoiceAsync(
        Invoice invoice, CancellationToken ct)
    {
        // Implementación similar a otros tax engines
        // con especificidades de DGI Uruguay

        var cfeXml = GenerateCfeXml(invoice);
        var signedXml = await _xmlSigner.SignXmlAsync(cfeXml);
        var response = await _dgiClient.SendCfeAsync(signedXml);

        return new InvoiceResponse
        {
            Success = true,
            AuthorizationCode = response.CfeNumber,
            ElectronicDocument = signedXml.ToString()
        };
    }

    public async Task<ValidationResult> ValidateFiscalDataAsync(FiscalData data)
    {
        var result = new ValidationResult();

        if (!IsValidRutFormat(data.TaxId))
        {
            result.AddError("RUT inválido");
        }

        result.IsValid = !result.HasErrors;
        return result;
    }
}
```

---

### US-027: Tax Engine Genérico (US/CA/Caribe)

**Como** Usuario del sistema en países sin tax engine específico
**Quiero** que el sistema maneje facturación básica
**Para** poder operar en múltiples países con reglas fiscales simples

**Story Points:** 8
**Prioridad:** SHOULD HAVE
**Epic:** Tax Engines por País
**Dependencias:** US-020 (Factory Pattern)

#### Acceptance Criteria

**AC-027.1: Países Soportados**
```gherkin
Given que soy un tenant de un país sin tax engine específico
When el sistema detecta mi país (US, CA, PR, DO, PA, etc.)
Then debe usar el GenericTaxEngine
And debe permitir configurar tasas de impuestos manualmente
```

**AC-027.2: Cálculo de Impuestos Configurable**
```gherkin
Given tasas de impuestos configuradas en la base de datos
When se calcula una factura
Then debe aplicar las tasas configuradas por tenant
And debe soportar múltiples impuestos simultáneos (ej: Sales Tax + Local Tax)
```

**AC-027.3: Facturación Sin Integración Fiscal**
```gherkin
Given un país sin organismo fiscal electrónico
When se genera una factura
Then debe:
  - Generar PDF estándar
  - NO enviar a autoridades fiscales
  - Guardar en base de datos local
  - Permitir numeración manual o automática
```

**AC-027.4: Validaciones Básicas**
```gherkin
Given datos fiscales genéricos
When se valida con ValidateFiscalDataAsync()
Then debe:
  - Validar que TaxId no esté vacío
  - Validar formato según regex configurable
  - NO consultar organismos externos
```

#### Definition of Done
- [ ] `GenericTaxEngine` implementado
- [ ] Configuración de tasas por tenant
- [ ] Cálculo de impuestos configurable
- [ ] Generación de PDF estándar
- [ ] Validaciones básicas
- [ ] Unit Tests (>90% coverage)
- [ ] Documentación de configuración
- [ ] Code Review aprobado

#### Technical Notes
```csharp
// Infrastructure/TaxEngines/GenericTaxEngine.cs
public class GenericTaxEngine : ITaxEngine
{
    private readonly ITenantConfigService _tenantConfig;
    private readonly IPdfGeneratorService _pdfGenerator;
    private readonly ILogger<GenericTaxEngine> _logger;

    public string CountryCode => "GENERIC";

    public async Task<InvoiceResponse> GenerateElectronicInvoiceAsync(
        Invoice invoice, CancellationToken ct)
    {
        // Sin integración fiscal, solo generación local
        var taxCalc = await CalculateTaxesAsync(invoice);
        var pdf = await _pdfGenerator.GenerateInvoicePdfAsync(invoice, taxCalc);

        return new InvoiceResponse
        {
            Success = true,
            AuthorizationCode = $"LOCAL-{invoice.Id}",
            PdfDocument = pdf
        };
    }

    public async Task<TaxCalculation> CalculateTaxesAsync(TaxableTransaction tx)
    {
        var calc = new TaxCalculation();

        // Obtener tasas configuradas para el tenant
        var taxRates = await _tenantConfig.GetTaxRatesAsync();

        foreach (var rate in taxRates)
        {
            var taxAmount = tx.TotalNet * rate.Rate;
            calc.TaxLines.Add(new TaxLine
            {
                TaxType = rate.TaxType,
                TaxRate = rate.Rate,
                BaseAmount = tx.TotalNet,
                TaxAmount = taxAmount
            });
        }

        return calc;
    }

    public async Task<ValidationResult> ValidateFiscalDataAsync(FiscalData data)
    {
        var result = new ValidationResult();

        if (string.IsNullOrWhiteSpace(data.TaxId))
        {
            result.AddError("Tax ID requerido");
        }

        result.IsValid = !result.HasErrors;
        return result;
    }

    public Task<bool> SubmitToTaxAuthorityAsync(ElectronicDocument document)
    {
        // No submission for generic engine
        return Task.FromResult(true);
    }

    public Task<List<TaxReport>> GetRequiredReportsAsync(DateTime period)
    {
        // No mandatory reports
        return Task.FromResult(new List<TaxReport>());
    }
}
```

---

## Epic 5: Ventas Multi-País y Facturación

**Descripción:**
Sistema completo de gestión de ventas para múltiples países, incluyendo clientes multi-país, listas de precios con múltiples monedas, gestión de pedidos, facturación electrónica integrada con los Tax Engines específicos de cada país, y gestión de cobranzas con soporte multi-moneda.

**Story Points Totales:** 78 pts
**Prioridad:** MUST HAVE (MoSCoW)
**Riesgo:** ALTO - Requiere integración perfecta con Tax Engines

---

### US-028: Clientes Multi-País

**Como** Usuario del sistema
**Quiero** registrar y gestionar clientes en múltiples países
**Para** poder vender a clientes en toda la región

**Story Points:** 13
**Prioridad:** MUST HAVE
**Epic:** Ventas Multi-País
**Dependencias:** US-001 (Multi-Tenancy), US-020 (Tax Engines)

#### Acceptance Criteria

**AC-028.1: Registro de Cliente**
```gherkin
Given que estoy en el módulo de Clientes
When creo un nuevo cliente
Then debo capturar:
  - Razón Social / Nombre Completo
  - País (select desde catálogo)
  - Tax ID según país (CUIT, RFC, RUT, RUC, NIT, etc.)
  - Condición Fiscal (según país)
  - Domicilio Fiscal completo
  - Contactos (email, teléfono)
  - Moneda por defecto
  - Límite de Crédito (opcional)
  - Condiciones de Pago por defecto
And el sistema debe validar el Tax ID según el país
```

**AC-028.2: Validación Fiscal Automática**
```gherkin
Given un cliente con país y Tax ID ingresados
When guardo el cliente
Then el sistema debe:
  - Invocar el Tax Engine correspondiente al país
  - Validar el Tax ID con ValidateFiscalDataAsync()
  - Consultar organismo fiscal si está disponible
  - Actualizar la Condición Fiscal automáticamente
  - Mostrar warnings si el Tax ID es inválido (permitir guardar con confirmación)
And debe logear el resultado de la validación
```

**AC-028.3: Cliente Multi-Moneda**
```gherkin
Given un cliente registrado
When configuro opciones de facturación
Then debo poder:
  - Asignar moneda por defecto del cliente
  - Permitir facturación en otras monedas
  - Configurar si requiere conversión automática en factura
  - Configurar lista de precios por moneda
And el sistema debe recordar estas preferencias
```

**AC-028.4: Búsqueda y Filtros**
```gherkin
Given múltiples clientes registrados en diferentes países
When busco clientes
Then debo poder filtrar por:
  - País
  - Condición Fiscal
  - Estado (Activo/Inactivo)
  - Límite de crédito excedido
  - Búsqueda por nombre, Tax ID, o email
And debe mostrar resultados paginados
```

**AC-028.5: Auditoría de Cambios**
```gherkin
Given un cliente existente
When se modifica cualquier dato fiscal
Then el sistema debe:
  - Registrar cambio en tabla de auditoría
  - Capturar usuario, fecha, y valores anterior/nuevo
  - Permitir consultar historial de cambios
  - Notificar a Contador si cambia condición fiscal
```

#### Definition of Done
- [ ] Entidad `Cliente` creada en Domain layer
- [ ] API REST completa (CRUD) implementada
- [ ] Validación fiscal integrada con Tax Engines
- [ ] Búsqueda y filtros implementados
- [ ] Frontend (formulario y listado) implementado
- [ ] Auditoría de cambios funcionando
- [ ] Unit Tests (>95% coverage)
- [ ] Integration Tests
- [ ] Migraciones de base de datos
- [ ] Documentación API (Swagger)
- [ ] Code Review aprobado

#### Technical Notes
```csharp
// Domain/Entities/Cliente.cs
public class Cliente : BaseEntity, IAuditableEntity
{
    public string RazonSocial { get; set; }
    public string NombreComercial { get; set; }
    public string CountryCode { get; set; } // AR, MX, CL, etc.
    public string TaxId { get; set; } // CUIT, RFC, RUT, etc.
    public string TaxIdType { get; set; } // Tipo de documento
    public string IvaCondition { get; set; } // Condición ante IVA/impuestos
    public string Address { get; set; }
    public string City { get; set; }
    public string State { get; set; }
    public string PostalCode { get; set; }
    public string Email { get; set; }
    public string Phone { get; set; }

    // Multi-Currency
    public CurrencyCode DefaultCurrency { get; set; }

    // Crédito
    public decimal? CreditLimit { get; set; }
    public int? PaymentTermDays { get; set; } // Días de plazo

    // Estado
    public bool IsActive { get; set; }
    public DateTime? FiscalValidationDate { get; set; }
    public bool FiscalValidationPassed { get; set; }

    // Audit
    public int TenantId { get; set; }
    public DateTime CreatedAt { get; set; }
    public string CreatedBy { get; set; }
    public DateTime? ModifiedAt { get; set; }
    public string ModifiedBy { get; set; }
    public bool IsDeleted { get; set; }

    // Navigation
    public virtual ICollection<Pedido> Pedidos { get; set; }
    public virtual ICollection<Factura> Facturas { get; set; }
}

// Application/Features/Clientes/Commands/CreateClienteCommand.cs
public class CreateClienteCommandHandler : IRequestHandler<CreateClienteCommand, ClienteDto>
{
    private readonly IApplicationDbContext _context;
    private readonly ITaxEngineFactory _taxEngineFactory;
    private readonly IMapper _mapper;
    private readonly ILogger<CreateClienteCommandHandler> _logger;

    public async Task<ClienteDto> Handle(CreateClienteCommand request, CancellationToken ct)
    {
        // 1. Mapear entidad
        var cliente = _mapper.Map<Cliente>(request);

        // 2. Validar fiscalmente
        var taxEngine = _taxEngineFactory.GetTaxEngine(request.CountryCode);
        var fiscalData = new FiscalData
        {
            TaxId = request.TaxId,
            Name = request.RazonSocial,
            Address = request.Address
        };

        var validationResult = await taxEngine.ValidateFiscalDataAsync(fiscalData);

        if (!validationResult.IsValid)
        {
            _logger.LogWarning("Validación fiscal falló para cliente {TaxId}: {Errors}",
                request.TaxId, string.Join(", ", validationResult.Errors));

            cliente.FiscalValidationPassed = false;
            // Permitir guardar con warning, pero marcar como no validado
        }
        else
        {
            cliente.FiscalValidationPassed = true;
            cliente.FiscalValidationDate = DateTime.UtcNow;
            cliente.IvaCondition = fiscalData.IvaCondition; // Actualizar desde validación
        }

        // 3. Guardar
        _context.Clientes.Add(cliente);
        await _context.SaveChangesAsync(ct);

        return _mapper.Map<ClienteDto>(cliente);
    }
}
```

---

### US-029: Listas de Precios Multi-Moneda

**Como** Usuario del sistema
**Quiero** definir listas de precios en múltiples monedas
**Para** poder vender productos a diferentes precios según país y moneda

**Story Points:** 13
**Prioridad:** MUST HAVE
**Epic:** Ventas Multi-País
**Dependencias:** US-011 (Catálogo de Productos), US-007 (Multi-Currency)

#### Acceptance Criteria

**AC-029.1: Creación de Lista de Precios**
```gherkin
Given que soy Administrador o Vendedor
When creo una nueva lista de precios
Then debo capturar:
  - Nombre descriptivo
  - Moneda (select desde catálogo)
  - País de aplicación (opcional)
  - Fecha de vigencia desde
  - Fecha de vigencia hasta (opcional)
  - Tipo (Precio Base, Promoción, Mayorista, etc.)
  - Estado (Activa/Inactiva)
And debe validar que no haya solapamiento de fechas para la misma moneda/país
```

**AC-029.2: Asignación de Precios por Producto**
```gherkin
Given una lista de precios creada
When agrego productos a la lista
Then debo poder:
  - Buscar productos desde el catálogo
  - Asignar precio unitario para cada producto
  - Configurar descuentos por cantidad (ej: >10 unidades = -5%)
  - Copiar precios desde otra lista (con conversión de moneda)
  - Importar precios masivamente (CSV/Excel)
And debe validar que el precio sea mayor a cero
```

**AC-029.3: Conversión Automática de Precios**
```gherkin
Given una lista de precios en USD
When selecciono "Crear lista equivalente en otra moneda"
Then el sistema debe:
  - Solicitar moneda destino
  - Obtener tipo de cambio actual
  - Convertir todos los precios automáticamente
  - Aplicar redondeo configurable
  - Crear nueva lista de precios
And debe permitir ajustar precios manualmente después de la conversión
```

**AC-029.4: Asignación de Lista a Clientes**
```gherkin
Given listas de precios definidas
When configuro un cliente
Then debo poder:
  - Asignar lista de precios por defecto
  - Configurar excepciones (productos con precio especial)
  - Configurar descuentos adicionales (%)
And el sistema debe usar esta lista al crear pedidos/facturas
```

**AC-029.5: Consulta de Precio Vigente**
```gherkin
Given un producto y un cliente
When consulto el precio vigente
Then el sistema debe:
  - Buscar lista de precios asignada al cliente
  - Validar vigencia de la lista (fecha actual entre desde/hasta)
  - Buscar precio del producto en la lista
  - Aplicar descuentos por cantidad si aplica
  - Aplicar descuentos adicionales del cliente
  - Retornar precio final en la moneda de la lista
And debe retornar error si no hay precio definido
```

#### Definition of Done
- [ ] Entidad `ListaDePrecios` y `ListaDePreciosDetalle` creadas
- [ ] API REST completa implementada
- [ ] Conversión automática de precios implementada
- [ ] Asignación a clientes funcional
- [ ] Servicio de consulta de precio vigente
- [ ] Importación masiva de precios (CSV)
- [ ] Frontend (CRUD y asignación) implementado
- [ ] Unit Tests (>95% coverage)
- [ ] Integration Tests
- [ ] Migraciones de base de datos
- [ ] Documentación API
- [ ] Code Review aprobado

#### Technical Notes
```csharp
// Domain/Entities/ListaDePrecios.cs
public class ListaDePrecios : BaseEntity
{
    public string Nombre { get; set; }
    public CurrencyCode Moneda { get; set; }
    public string CountryCode { get; set; } // Opcional
    public DateTime VigenciaDesde { get; set; }
    public DateTime? VigenciaHasta { get; set; }
    public TipoListaPrecios Tipo { get; set; } // Base, Promocion, Mayorista, etc.
    public bool IsActive { get; set; }

    public int TenantId { get; set; }

    // Navigation
    public virtual ICollection<ListaDePreciosDetalle> Detalles { get; set; }
    public virtual ICollection<Cliente> ClientesAsignados { get; set; }
}

public class ListaDePreciosDetalle : BaseEntity
{
    public int ListaDePreciosId { get; set; }
    public int ProductoId { get; set; }
    public decimal PrecioUnitario { get; set; }

    // Descuentos por cantidad
    public decimal? CantidadMinima { get; set; }
    public decimal? DescuentoPorcentaje { get; set; }

    // Navigation
    public virtual ListaDePrecios Lista { get; set; }
    public virtual Producto Producto { get; set; }
}

// Application/Services/PrecioService.cs
public class PrecioService : IPrecioService
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrencyService _currencyService;

    public async Task<decimal> GetPrecioVigenteAsync(
        int productoId,
        int clienteId,
        decimal cantidad,
        CancellationToken ct)
    {
        // 1. Obtener cliente y su lista de precios
        var cliente = await _context.Clientes
            .Include(c => c.ListaDePreciosAsignada)
            .FirstOrDefaultAsync(c => c.Id == clienteId, ct);

        if (cliente?.ListaDePreciosAsignada == null)
            throw new BusinessException("Cliente sin lista de precios asignada");

        var lista = cliente.ListaDePreciosAsignada;

        // 2. Validar vigencia
        var hoy = DateTime.UtcNow.Date;
        if (hoy < lista.VigenciaDesde.Date ||
            (lista.VigenciaHasta.HasValue && hoy > lista.VigenciaHasta.Value.Date))
            throw new BusinessException("Lista de precios fuera de vigencia");

        // 3. Buscar precio del producto
        var detalle = await _context.ListaDePreciosDetalles
            .Where(d => d.ListaDePreciosId == lista.Id && d.ProductoId == productoId)
            .OrderByDescending(d => d.CantidadMinima ?? 0)
            .FirstOrDefaultAsync(ct);

        if (detalle == null)
            throw new BusinessException($"Producto {productoId} sin precio en la lista");

        var precio = detalle.PrecioUnitario;

        // 4. Aplicar descuento por cantidad
        if (detalle.CantidadMinima.HasValue && cantidad >= detalle.CantidadMinima.Value)
        {
            var descuento = detalle.DescuentoPorcentaje ?? 0;
            precio = precio * (1 - descuento / 100);
        }

        // 5. Aplicar descuento adicional del cliente
        if (cliente.DescuentoAdicional.HasValue)
        {
            precio = precio * (1 - cliente.DescuentoAdicional.Value / 100);
        }

        return Math.Round(precio, 2);
    }

    public async Task<ListaDePrecios> ConvertirListaAOtraMonedaAsync(
        int listaOrigenId,
        CurrencyCode monedaDestino,
        string nombreDestino,
        CancellationToken ct)
    {
        var listaOrigen = await _context.ListasDePrecios
            .Include(l => l.Detalles)
            .FirstOrDefaultAsync(l => l.Id == listaOrigenId, ct);

        if (listaOrigen == null)
            throw new NotFoundException(nameof(ListaDePrecios), listaOrigenId);

        // Obtener tipo de cambio
        var tipoCambio = await _currencyService.GetExchangeRateAsync(
            listaOrigen.Moneda, monedaDestino, DateTime.UtcNow);

        // Crear nueva lista
        var listaDestino = new ListaDePrecios
        {
            Nombre = nombreDestino,
            Moneda = monedaDestino,
            CountryCode = listaOrigen.CountryCode,
            VigenciaDesde = listaOrigen.VigenciaDesde,
            VigenciaHasta = listaOrigen.VigenciaHasta,
            Tipo = listaOrigen.Tipo,
            IsActive = true,
            TenantId = listaOrigen.TenantId
        };

        // Convertir precios
        foreach (var detalleOrigen in listaOrigen.Detalles)
        {
            var precioConvertido = detalleOrigen.PrecioUnitario * tipoCambio;

            listaDestino.Detalles.Add(new ListaDePreciosDetalle
            {
                ProductoId = detalleOrigen.ProductoId,
                PrecioUnitario = Math.Round(precioConvertido, 2),
                CantidadMinima = detalleOrigen.CantidadMinima,
                DescuentoPorcentaje = detalleOrigen.DescuentoPorcentaje
            });
        }

        _context.ListasDePrecios.Add(listaDestino);
        await _context.SaveChangesAsync(ct);

        return listaDestino;
    }
}
```

---

### US-030: Pedidos de Venta Multi-País

**Como** Usuario del sistema
**Quiero** crear y gestionar pedidos de venta
**Para** registrar los pedidos de clientes antes de facturar

**Story Points:** 13
**Prioridad:** MUST HAVE
**Epic:** Ventas Multi-País
**Dependencias:** US-028 (Clientes), US-029 (Listas de Precios)

#### Acceptance Criteria

**AC-030.1: Creación de Pedido**
```gherkin
Given que soy Vendedor
When creo un nuevo pedido
Then debo capturar:
  - Cliente (search/select)
  - Fecha del pedido
  - Moneda (heredada del cliente o seleccionable)
  - Lista de precios a aplicar
  - Productos con cantidades
  - Precios unitarios (desde lista de precios, editables)
  - Descuentos por línea
  - Condiciones de pago
  - Fecha de entrega estimada
  - Observaciones
And el sistema debe calcular totales automáticamente
```

**AC-030.2: Validaciones de Negocio**
```gherkin
Given un pedido en creación
When intento guardar
Then el sistema debe validar:
  - Cliente activo y con datos fiscales válidos
  - Productos activos y con stock disponible (warning si no hay stock)
  - Precios > 0
  - No exceder límite de crédito del cliente (warning, permitir con confirmación)
  - Moneda del pedido compatible con país del cliente
And debe mostrar errores/warnings claros
```

**AC-030.3: Estados del Pedido (Workflow)**
```gherkin
Given un pedido guardado
When cambio su estado
Then los estados válidos son:
  - Borrador → Confirmado (requiere aprobación si excede monto)
  - Confirmado → En Preparación
  - En Preparación → Listo para Envío
  - Listo para Envío → Enviado
  - Enviado → Entregado
  - Cualquier estado → Cancelado (requiere motivo)
And debe registrar cambios de estado con usuario y fecha
And debe notificar al Almacén cuando pasa a "En Preparación"
```

**AC-030.4: Conversión a Factura**
```gherkin
Given un pedido en estado "Confirmado" o posterior
When selecciono "Generar Factura"
Then el sistema debe:
  - Validar que el pedido no tenga factura asociada
  - Crear borrador de factura con datos del pedido
  - Copiar líneas de productos, precios, descuentos
  - Asociar factura al pedido
  - Permitir editar factura antes de emitir
And debe evitar facturar el mismo pedido dos veces
```

**AC-030.5: Reportes de Pedidos**
```gherkin
Given múltiples pedidos en el sistema
When accedo al reporte de pedidos
Then debo poder:
  - Filtrar por fecha, cliente, estado, vendedor
  - Ver resumen de ventas por período
  - Ver pedidos pendientes de facturar
  - Ver pedidos con entrega retrasada
  - Exportar a Excel/PDF
And debe mostrar totales en moneda de origen y convertidos a USD
```

#### Definition of Done
- [ ] Entidad `Pedido` y `PedidoLinea` creadas
- [ ] API REST completa (CRUD)
- [ ] Workflow de estados implementado (State Pattern)
- [ ] Validaciones de negocio implementadas
- [ ] Conversión a factura funcional
- [ ] Frontend (formulario, listado, reportes) implementado
- [ ] Unit Tests (>95% coverage)
- [ ] Integration Tests
- [ ] Migraciones de base de datos
- [ ] Documentación API
- [ ] Code Review aprobado

#### Technical Notes
```csharp
// Domain/Entities/Pedido.cs
public class Pedido : BaseEntity, IAuditableEntity
{
    public int ClienteId { get; set; }
    public string NumeroPedido { get; set; } // Auto-generado
    public DateTime FechaPedido { get; set; }
    public DateTime? FechaEntregaEstimada { get; set; }
    public EstadoPedido Estado { get; set; }
    public CurrencyCode Moneda { get; set; }
    public int? ListaDePreciosId { get; set; }

    // Totales
    public decimal SubTotal { get; set; }
    public decimal DescuentoTotal { get; set; }
    public decimal Total { get; set; }

    // Condiciones
    public int? PaymentTermDays { get; set; }
    public string Observaciones { get; set; }

    // Facturación
    public int? FacturaId { get; set; }
    public bool Facturado { get; set; }

    // Audit
    public int TenantId { get; set; }
    public int VendedorId { get; set; }
    public DateTime CreatedAt { get; set; }
    public string CreatedBy { get; set; }
    public DateTime? ModifiedAt { get; set; }
    public string ModifiedBy { get; set; }
    public bool IsDeleted { get; set; }

    // Navigation
    public virtual Cliente Cliente { get; set; }
    public virtual Factura Factura { get; set; }
    public virtual ICollection<PedidoLinea> Lineas { get; set; }
    public virtual ICollection<PedidoEstadoHistorial> EstadoHistorial { get; set; }
}

public class PedidoLinea : BaseEntity
{
    public int PedidoId { get; set; }
    public int ProductoId { get; set; }
    public decimal Cantidad { get; set; }
    public decimal PrecioUnitario { get; set; }
    public decimal DescuentoPorcentaje { get; set; }
    public decimal Total { get; set; }

    // Navigation
    public virtual Pedido Pedido { get; set; }
    public virtual Producto Producto { get; set; }
}

public enum EstadoPedido
{
    Borrador = 0,
    Confirmado = 1,
    EnPreparacion = 2,
    ListoParaEnvio = 3,
    Enviado = 4,
    Entregado = 5,
    Cancelado = 99
}

// Application/Features/Pedidos/Commands/ConvertirPedidoAFacturaCommand.cs
public class ConvertirPedidoAFacturaCommandHandler : IRequestHandler<ConvertirPedidoAFacturaCommand, FacturaDto>
{
    private readonly IApplicationDbContext _context;
    private readonly IFacturaService _facturaService;
    private readonly IMapper _mapper;

    public async Task<FacturaDto> Handle(ConvertirPedidoAFacturaCommand request, CancellationToken ct)
    {
        // 1. Obtener pedido
        var pedido = await _context.Pedidos
            .Include(p => p.Cliente)
            .Include(p => p.Lineas).ThenInclude(l => l.Producto)
            .FirstOrDefaultAsync(p => p.Id == request.PedidoId, ct);

        if (pedido == null)
            throw new NotFoundException(nameof(Pedido), request.PedidoId);

        // 2. Validar estado
        if (pedido.Facturado)
            throw new BusinessException("El pedido ya fue facturado");

        if (pedido.Estado == EstadoPedido.Borrador || pedido.Estado == EstadoPedido.Cancelado)
            throw new BusinessException($"No se puede facturar un pedido en estado {pedido.Estado}");

        // 3. Crear factura
        var factura = new Factura
        {
            ClienteId = pedido.ClienteId,
            PedidoId = pedido.Id,
            FechaFactura = DateTime.UtcNow,
            Moneda = pedido.Moneda,
            SubTotal = pedido.SubTotal,
            DescuentoTotal = pedido.DescuentoTotal,
            Total = pedido.Total,
            Estado = EstadoFactura.Borrador,
            TenantId = pedido.TenantId
        };

        // 4. Copiar líneas
        foreach (var lineaPedido in pedido.Lineas)
        {
            factura.Lineas.Add(new FacturaLinea
            {
                ProductoId = lineaPedido.ProductoId,
                Cantidad = lineaPedido.Cantidad,
                PrecioUnitario = lineaPedido.PrecioUnitario,
                DescuentoPorcentaje = lineaPedido.DescuentoPorcentaje,
                Total = lineaPedido.Total
            });
        }

        _context.Facturas.Add(factura);

        // 5. Marcar pedido como facturado
        pedido.Facturado = true;
        pedido.FacturaId = factura.Id;

        await _context.SaveChangesAsync(ct);

        return _mapper.Map<FacturaDto>(factura);
    }
}
```

---

### US-031: Facturación Multi-País con Tax Engine

**Como** Usuario del sistema
**Quiero** emitir facturas electrónicas válidas en cada país
**Para** cumplir con las obligaciones fiscales locales

**Story Points:** 21
**Prioridad:** MUST HAVE
**Epic:** Ventas Multi-País
**Dependencias:** US-020 a US-027 (Tax Engines), US-028 (Clientes), US-030 (Pedidos)

#### Acceptance Criteria

**AC-031.1: Creación de Factura**
```gherkin
Given que soy Vendedor o Contador
When creo una nueva factura
Then debo capturar:
  - Cliente (obligatorio)
  - Fecha de emisión
  - Moneda
  - Productos/Servicios con cantidades y precios
  - Método de pago
  - Condiciones de pago
And el sistema debe:
  - Auto-numerar la factura según país
  - Detectar Tax Engine según país del cliente
  - Calcular impuestos automáticamente
  - Mostrar preview del total
```

**AC-031.2: Cálculo de Impuestos por País**
```gherkin
Given una factura con líneas de productos
When calculo los totales
Then el sistema debe:
  - Invocar el Tax Engine del país (ej: ArgentinaTaxEngine)
  - Calcular impuestos según legislación local (IVA, percepciones, retenciones)
  - Desglosar impuestos por tipo y tasa
  - Calcular total incluyendo todos los impuestos
And debe mostrar el desglose claro al usuario
```

**AC-031.3: Emisión de Factura Electrónica**
```gherkin
Given una factura en estado "Borrador"
When selecciono "Emitir Factura Electrónica"
Then el sistema debe:
  - Validar datos fiscales del cliente
  - Validar que no falten datos obligatorios
  - Invocar SubmitToTaxAuthorityAsync() del Tax Engine
  - Enviar factura al organismo fiscal (AFIP, SAT, SII, etc.)
  - Recibir autorización (CAE, UUID, Timbre, etc.)
  - Actualizar factura con código de autorización
  - Cambiar estado a "Emitida"
  - Generar PDF con código QR/2D
  - Enviar PDF por email al cliente
And debe manejar errores del organismo fiscal (mostrar mensaje y permitir reintentar)
```

**AC-031.4: Factura Multi-Moneda**
```gherkin
Given una factura en moneda diferente a la local
When emito la factura
Then el sistema debe:
  - Mostrar totales en moneda de la factura
  - Calcular tipo de cambio vigente
  - Mostrar equivalente en moneda local (si lo requiere el país)
  - Registrar tipo de cambio usado
  - Incluir tipo de cambio en el documento fiscal (si lo requiere el país)
```

**AC-031.5: Anulación y Notas de Crédito**
```gherkin
Given una factura emitida
When necesito anularla o corregirla
Then debo poder:
  - Crear Nota de Crédito asociada (si el país lo requiere)
  - Emitir Nota de Crédito electrónica con el Tax Engine
  - Marcar factura original como "Anulada" o "Con Nota de Crédito"
  - Registrar motivo de la anulación
And el sistema debe validar que no se pueda borrar una factura emitida
```

#### Definition of Done
- [ ] Entidad `Factura` y `FacturaLinea` creadas
- [ ] API REST completa (CRUD)
- [ ] Integración con todos los Tax Engines implementada
- [ ] Cálculo de impuestos multi-país funcionando
- [ ] Emisión de factura electrónica exitosa
- [ ] Generación de PDF con QR/código 2D
- [ ] Envío de email al cliente
- [ ] Notas de Crédito implementadas
- [ ] Frontend (formulario, listado, preview PDF) implementado
- [ ] Unit Tests (>95% coverage)
- [ ] Integration Tests con Tax Engines
- [ ] Migraciones de base de datos
- [ ] Documentación API
- [ ] Code Review aprobado

#### Technical Notes
```csharp
// Domain/Entities/Factura.cs
public class Factura : BaseEntity, IAuditableEntity
{
    public int ClienteId { get; set; }
    public int? PedidoId { get; set; }
    public string NumeroFactura { get; set; } // Auto-generado según país
    public DateTime FechaFactura { get; set; }
    public EstadoFactura Estado { get; set; }
    public CurrencyCode Moneda { get; set; }

    // Totales
    public decimal SubTotal { get; set; }
    public decimal DescuentoTotal { get; set; }
    public decimal TotalImpuestos { get; set; }
    public decimal Total { get; set; }

    // Multi-Currency
    public decimal? TipoDeCambio { get; set; }
    public decimal? TotalMonedaLocal { get; set; }

    // Autorización Fiscal
    public string CodigoAutorizacion { get; set; } // CAE, UUID, etc.
    public DateTime? FechaAutorizacion { get; set; }
    public string XmlElectronico { get; set; } // XML firmado
    public string PdfUrl { get; set; }

    // Pago
    public string MetodoPago { get; set; }
    public int? PaymentTermDays { get; set; }
    public DateTime? FechaVencimiento { get; set; }
    public decimal Pagado { get; set; }
    public decimal Saldo { get; set; }

    // Anulación
    public bool IsAnulada { get; set; }
    public string MotivoAnulacion { get; set; }
    public int? NotaDeCreditoId { get; set; }

    // Audit
    public int TenantId { get; set; }
    public DateTime CreatedAt { get; set; }
    public string CreatedBy { get; set; }
    public DateTime? ModifiedAt { get; set; }
    public string ModifiedBy { get; set; }
    public bool IsDeleted { get; set; }

    // Navigation
    public virtual Cliente Cliente { get; set; }
    public virtual Pedido Pedido { get; set; }
    public virtual ICollection<FacturaLinea> Lineas { get; set; }
    public virtual ICollection<FacturaImpuesto> Impuestos { get; set; }
    public virtual ICollection<Cobranza> Cobranzas { get; set; }
}

public class FacturaImpuesto : BaseEntity
{
    public int FacturaId { get; set; }
    public string TipoImpuesto { get; set; } // IVA, IGV, Percepción, Retención, etc.
    public decimal TasaImpuesto { get; set; }
    public decimal BaseImponible { get; set; }
    public decimal MontoImpuesto { get; set; }

    public virtual Factura Factura { get; set; }
}

public enum EstadoFactura
{
    Borrador = 0,
    Emitida = 1,
    Pagada = 2,
    PagadaParcial = 3,
    Vencida = 4,
    Anulada = 99
}

// Application/Features/Facturas/Commands/EmitirFacturaElectronicaCommand.cs
public class EmitirFacturaElectronicaCommandHandler : IRequestHandler<EmitirFacturaElectronicaCommand, FacturaDto>
{
    private readonly IApplicationDbContext _context;
    private readonly ITaxEngineFactory _taxEngineFactory;
    private readonly IPdfGeneratorService _pdfGenerator;
    private readonly IEmailService _emailService;
    private readonly IMapper _mapper;
    private readonly ILogger<EmitirFacturaElectronicaCommandHandler> _logger;

    public async Task<FacturaDto> Handle(EmitirFacturaElectronicaCommand request, CancellationToken ct)
    {
        // 1. Obtener factura
        var factura = await _context.Facturas
            .Include(f => f.Cliente)
            .Include(f => f.Lineas).ThenInclude(l => l.Producto)
            .Include(f => f.Impuestos)
            .FirstOrDefaultAsync(f => f.Id == request.FacturaId, ct);

        if (factura == null)
            throw new NotFoundException(nameof(Factura), request.FacturaId);

        // 2. Validar estado
        if (factura.Estado != EstadoFactura.Borrador)
            throw new BusinessException($"La factura no está en estado Borrador (estado actual: {factura.Estado})");

        // 3. Validar datos fiscales del cliente
        var taxEngine = _taxEngineFactory.GetTaxEngine(factura.Cliente.CountryCode);

        var fiscalValidation = await taxEngine.ValidateFiscalDataAsync(new FiscalData
        {
            TaxId = factura.Cliente.TaxId,
            Name = factura.Cliente.RazonSocial
        });

        if (!fiscalValidation.IsValid)
        {
            throw new BusinessException($"Datos fiscales del cliente inválidos: {string.Join(", ", fiscalValidation.Errors)}");
        }

        try
        {
            // 4. Emitir factura electrónica
            var invoice = _mapper.Map<Invoice>(factura); // Mapear a modelo del Tax Engine

            var response = await taxEngine.GenerateElectronicInvoiceAsync(invoice, ct);

            if (!response.Success)
            {
                throw new TaxEngineException($"Error al emitir factura: {response.ErrorMessage}");
            }

            // 5. Actualizar factura con respuesta
            factura.CodigoAutorizacion = response.AuthorizationCode;
            factura.FechaAutorizacion = DateTime.UtcNow;
            factura.XmlElectronico = response.ElectronicDocument;
            factura.Estado = EstadoFactura.Emitida;

            // 6. Generar PDF
            var pdf = await _pdfGenerator.GenerateFacturaPdfAsync(factura, response);
            var pdfUrl = await _pdfGenerator.SavePdfAsync(pdf, $"factura_{factura.NumeroFactura}.pdf");
            factura.PdfUrl = pdfUrl;

            await _context.SaveChangesAsync(ct);

            // 7. Enviar email al cliente
            await _emailService.SendFacturaEmailAsync(factura.Cliente.Email, factura, pdfUrl);

            _logger.LogInformation("Factura {NumeroFactura} emitida exitosamente. CAE/UUID: {Autorizacion}",
                factura.NumeroFactura, factura.CodigoAutorizacion);

            return _mapper.Map<FacturaDto>(factura);
        }
        catch (TaxEngineException ex)
        {
            _logger.LogError(ex, "Error al emitir factura electrónica {NumeroFactura}", factura.NumeroFactura);
            throw new BusinessException($"Error del organismo fiscal: {ex.Message}. Por favor reintente.");
        }
    }
}
```

---

**CONTINÚA EN PARTE 4...**

Este documento continúa con:
- US-032: Cobranzas Multi-Moneda
- Epic 6: Contabilidad Multinacional (US-033 a US-036)
- Epic 7: Consolidación & IFRS (US-037 a US-040)
- Parte 4: RICE Scoring, Release Plan, Dependencies Map, Métricas y KPIs
