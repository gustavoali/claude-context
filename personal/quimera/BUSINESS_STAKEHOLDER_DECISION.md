# Business Stakeholder Decision - Quimera
**Fecha:** 2026-03-21

## Contexto

Quimera es una plataforma de entretenimiento digital generado por AI, dirigida al publico infantil y adolescente argentino (4-19 anos). Combina cuatro productos bajo una marca unificada: cuentos personalizados, historias interactivas, roasts AI y memes/stickers. El proyecto opera como emprendimiento unipersonal con inversion minima en infraestructura (~$16/mes fijos) y margenes brutos del 85-95% por transaccion AI.

Se evalua el proyecto completo: viabilidad del modelo de negocio, estructura de costos, riesgos, y alineacion con las capacidades disponibles (1 developer, stack Python/FastAPI, experiencia previa con LLMs y TTS).

## Evaluacion

| Criterio | Score (1-5) | Comentario |
|----------|-------------|------------|
| Business value | 4 | Nicho desatendido (entretenimiento AI en espanol argentino para menores). Propuesta de valor clara y diferenciada. Potencial de expansion regional. Score no es 5 porque el mercado total es acotado (Argentina, segmento etario especifico). |
| User impact | 5 | Resuelve un problema real: no existe contenido AI personalizado, seguro, y culturalmente relevante para este publico. La personalizacion (nombre del nene como protagonista, humor local) genera conexion emocional que los competidores genericos no pueden replicar. |
| ROI | 4 | Estructura de costos excepcional: $16/mes fijo, margenes 85-95% por generacion. Breakeven en ~1 dia de ventas. El target de $50/dia ($1,500/mes) es alcanzable con volumen modesto (50-80 transacciones/dia). Riesgo: los costos de APIs AI pueden escalar si los proveedores suben precios, y el volumen de transacciones depende de traccion viral no garantizada. |
| Risk | 3 | Riesgo medio-alto por la audiencia de menores. Un incidente de contenido inapropiado puede destruir la reputacion del producto. Compliance legal (Ley 25.326, registro AAIP) requiere atencion profesional. El procesamiento efimero de fotos y la doble moderacion mitigan parcialmente, pero el riesgo reputacional persiste. Los riesgos operativos (MercadoPago, costos AI) tienen mitigaciones claras. |
| Time-to-market | 4 | MVP en 4 semanas es agresivo pero factible dado el stack elegido y la experiencia previa con LLMs/TTS. FastAPI + multi-provider LLM es un stack probado. Lanzar con 2 productos (Cuentos + Roasts) permite validar mercado rapido. El riesgo es que la moderacion de contenido y el age-gating sumen complejidad no prevista. |

**Score ponderado: 4.0/5.0** (pesos: business value 25%, user impact 20%, ROI 25%, risk 15%, TTM 15%)

## Decision: GO

### Justificacion

1. **Nicho verificablemente vacio.** No existe competencia directa en entretenimiento AI en espanol argentino para menores. La ventaja de first-mover en un mercado linguistico-cultural especifico es significativa porque el contenido generado (modismos, referencias culturales, humor) no se replica trivialmente desde afuera.

2. **Economia unitaria favorable.** El negocio es rentable desde la primera transaccion. Con margenes del 85-95% y costos fijos de $16/mes, el punto de equilibrio operativo se alcanza con ~12 transacciones/mes. Esto elimina el riesgo de "quemar capital antes de validar".

3. **Inversion proporcional al riesgo.** El costo de fracaso es bajo: tiempo del developer + ~$16/mes. No hay inversion irrecuperable significativa. El stack (FastAPI, PostgreSQL, proveedores AI via API) no genera lock-in ni costos hundidos.

4. **Flywheel viral integrado.** El flujo Roast viral -> Stickers -> Historias -> Cuentos -> Suscripcion familiar es un mecanismo de adquisicion organica. Si funciona, reduce el CAC a practicamente cero. Si no funciona, los productos igual se sostienen individualmente.

5. **Capacidad tecnica demostrada.** El developer tiene experiencia verificable con LLMs, TTS (proyecto Narrador), y el stack elegido. Esto reduce el riesgo de ejecucion tecnica.

### Reservas

La principal reserva es el riesgo legal y reputacional asociado a contenido AI para menores. Este riesgo no se mitiga solo con tecnologia; requiere consulta legal formal antes del lanzamiento publico. La decision GO esta condicionada a que la moderacion de contenido sea robusta y verificada antes de exponer el producto a usuarios reales.

## Metricas de Exito

### Fase 1 - MVP (Semanas 1-4)
| KPI | Target | Medicion |
|-----|--------|----------|
| MVP funcional | Cuentos + Roasts operativos | Demo end-to-end |
| Moderacion | 0 outputs inapropiados en 100 generaciones de prueba | Test suite de moderacion |
| Costo por generacion | Cuento < $0.15, Roast < $0.05 | Logs de API costs |
| Tiempo de generacion | Cuento < 60s, Roast < 15s | Performance logs |
| Landing page | Pagina publica con propuesta de valor | URL activa |

### Fase 2 - Traccion (Meses 2-3)
| KPI | Target | Medicion |
|-----|--------|----------|
| Usuarios registrados | 100 | DB count |
| Transacciones/dia | 20 | Dashboard |
| Revenue/dia | $10 USD | MercadoPago reports |
| Tasa de compartido (roasts) | >30% de roasts generados se comparten | Share tracking |
| Retencion 7 dias | >20% de usuarios vuelven | Analytics |
| NPS padres (cuentos) | >40 | Encuesta post-compra |

### Fase 3 - Escala (Meses 3-6)
| KPI | Target | Medicion |
|-----|--------|----------|
| Suscriptores activos | 30 -> 150 | DB count |
| Revenue/dia | $30 -> $50 USD | Payment reports |
| CAC (costo adquisicion) | < $2 USD | Marketing spend / nuevos usuarios |
| LTV suscriptor | > $20 USD | Revenue por usuario en 6 meses |
| Churn mensual suscripciones | < 15% | Cancelaciones / activos |
| Incidentes de contenido | 0 criticos | Moderacion logs |

## Riesgos a Monitorear

### Riesgo 1: Contenido inapropiado para menores (CRITICO)
- **Probabilidad:** Media | **Impacto:** Catastrofico
- **Mitigacion:** Double moderation (pre-prompt + post-generation), safe mode por segmento etario, blocklist de temas, human review de muestras semanales
- **Trigger de re-evaluacion:** Cualquier incidente donde un menor reciba contenido inapropiado, incluso en testing interno
- **Accion si se activa:** Pausar producto afectado inmediatamente, analizar causa raiz, no reactivar hasta fix verificado

### Riesgo 2: Compliance legal - Ley 25.326 y regulaciones de menores
- **Probabilidad:** Alta (es certeza que aplica) | **Impacto:** Alto
- **Mitigacion:** Consulta legal ANTES del lanzamiento publico. Procesamiento efimero de fotos. Cuentas de menores de 13 bajo control parental. Registro AAIP si corresponde.
- **Trigger de re-evaluacion:** Si la consulta legal identifica requisitos que cambian significativamente la arquitectura o el modelo de negocio
- **Accion si se activa:** Adaptar producto o restringir funcionalidades segun recomendacion legal

### Riesgo 3: Escalada de costos AI
- **Probabilidad:** Media | **Impacto:** Medio
- **Mitigacion:** Multi-provider con fallback (Claude/GPT-4o-mini/Groq/Llama). Stable Diffusion self-hosted como fallback de image gen. Monitoreo de costo por generacion en dashboard.
- **Trigger de re-evaluacion:** Costo promedio por generacion sube >50% respecto al baseline de Fase 1
- **Accion si se activa:** Migrar a providers mas economicos, optimizar prompts, considerar modelos locales

### Riesgo 4: Traccion insuficiente
- **Probabilidad:** Media | **Impacto:** Alto
- **Mitigacion:** Lanzar con 2 productos (validar rapido), medir compartidos virales, iterar sobre feedback temprano
- **Trigger de re-evaluacion:** Mes 2 con <5 transacciones/dia despues de esfuerzo de distribucion activo
- **Accion si se activa:** Pivotar producto (cambiar target de edad, cambiar producto lider), o pausar proyecto

### Riesgo 5: MercadoPago bloquea cuenta
- **Probabilidad:** Baja | **Impacto:** Alto (corta revenue inmediatamente)
- **Mitigacion:** Stripe como procesador secundario configurado desde el inicio. Documentacion clara del negocio ante MercadoPago.
- **Trigger de re-evaluacion:** Bloqueo efectivo de cuenta
- **Accion si se activa:** Switchear a Stripe, evaluar si el bloqueo es por la naturaleza del contenido (AI + menores)

### Riesgo 6: Padres desconfian de AI para sus hijos
- **Probabilidad:** Media | **Impacto:** Medio
- **Mitigacion:** Landing page transparente sobre como funciona la AI, politica de privacidad visible, opcion de preview para padres antes de entregar al nene, badge "contenido revisado"
- **Trigger de re-evaluacion:** Feedback consistente de desconfianza en primeros 50 usuarios
- **Accion si se activa:** Agregar capa de "curaduria humana" visible, reducir mencion de AI en marketing

## Condiciones de Re-evaluacion

| Condicion | Cuando evaluar | Accion |
|-----------|----------------|--------|
| Revenue < $5/dia al final del Mes 2 | Semana 8 | Analizar si el problema es producto, distribucion o mercado. Si es mercado, considerar pivot o cierre. |
| Incidente de contenido inapropiado con usuario real | Inmediato | Pausar producto, fix, no reactivar sin verificacion. Si es sistematico, reconsiderar viabilidad. |
| Consulta legal identifica bloqueante regulatorio | Pre-launch | Adaptar o reducir scope. Si el costo de compliance supera la capacidad, pausar hasta tener recursos. |
| Costos AI superan 30% del revenue | Revision mensual | Migrar providers, optimizar, o ajustar precios. |
| Competidor directo entra al mercado con mas recursos | Al detectar | Evaluar diferenciacion sostenible. Si no hay moat, acelerar features o pivotar. |
| Mes 4 sin suscriptores recurrentes | Semana 16 | El modelo unitario puede sostenerse, pero sin recurrencia el negocio no escala. Evaluar si el problema es precio, valor percibido, o friccion de pago. |

## Recomendaciones Estrategicas

### 1. Consulta legal pre-launch es bloqueante, no opcional
Dado que la audiencia son menores de edad, operar sin validacion legal es un riesgo existencial. Antes de exponer el producto a usuarios reales (incluso beta), obtener opinion legal sobre: procesamiento de datos de menores, consentimiento parental, procesamiento efimero de fotos, y terminos de servicio. Presupuestar $200-500 USD para esta consulta.

### 2. Lanzar Roasts primero, Cuentos segundo
Los roasts tienen el loop viral mas corto (generar -> compartir -> amigo entra) y el costo mas bajo por generacion ($0.02). Usarlos como punta de lanza para adquisicion. Los cuentos requieren mas infraestructura (image gen + TTS + PDF) y tienen un ciclo de venta mas largo (convencer al padre). Secuenciar: roasts como adquisicion viral, cuentos como monetizacion premium.

### 3. Medir el coeficiente viral desde el dia 1
La metrica mas importante de Fase 1 no es revenue sino K-factor (cuantos usuarios nuevos trae cada usuario). Si K > 1, el crecimiento es organico y el negocio se financia solo. Si K < 0.5, la distribucion requiere inversion que hoy no existe. Implementar tracking de shares desde el MVP.

### 4. Pricing en pesos con referencia interna en USD
El mercado argentino es sensible al precio en dolares. Publicar precios en pesos argentinos con actualizacion periodica basada en tipo de cambio. Internamente, todo el modelo financiero en USD para estabilidad. Considerar "precios psicologicos" locales (ej: $999 ARS en vez de equivalente exacto).

### 5. No invertir en frontend premium antes de validar demanda
El MVP puede ser funcional con una UI basica (formulario -> generacion -> resultado). No gastar semanas en PWA pulida antes de confirmar que hay usuarios dispuestos a pagar. La iteracion sobre el producto es mas valiosa que el polish visual en esta etapa.

### 6. Construir el moat en contenido, no en tecnologia
La tecnologia (FastAPI + LLM APIs) es replicable. El moat esta en: (a) la calidad del prompt engineering para tono argentino, (b) la base de usuarios y efecto red viral, (c) el catlogo de templates/tematicas culturalmente relevantes. Invertir tiempo en refinar prompts y templates, no en over-engineering la plataforma.

### 7. Plan de contingencia para procesamiento de fotos
Los roasts con foto son el producto mas viral pero tambien el de mayor riesgo legal (fotos de menores). Tener una variante "sin foto" (solo descripcion textual) lista desde el inicio. Si el analisis legal desaconseja procesar fotos de menores, el producto sigue siendo viable con input textual.

---

**Aprobado por:** Business Stakeholder (evaluacion automatizada)
**Proxima revision:** Semana 8 (fin de Fase 1) o ante cualquier trigger de re-evaluacion
