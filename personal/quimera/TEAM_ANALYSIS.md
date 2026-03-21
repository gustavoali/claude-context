# Quimera - Equipo de Analisis

## Composicion

### Software Architect
**Agente:** `software-architect`
**Responsabilidad:** Arquitectura del motor compartido (LLM, Image Gen, TTS, PDF), diseno de la plataforma multi-producto, estrategia de escalabilidad.
**Foco:** Como los 4 productos comparten servicios backend sin acoplamiento, separacion de concerns entre generacion de contenido y presentacion, estrategia de cache.

### Product Owner
**Agente:** `product-owner`
**Responsabilidad:** Backlog, priorizacion de features, definicion de AC para cada producto.
**Foco:** Fase 1 MVP (cuentos + roasts), balance entre los 4 productos, metricas de exito por segmento etario.

### Security Analyst
**Agente:** `software-architect` (perfil seguridad)
**Responsabilidad:** Proteccion de menores, compliance Ley 25.326, moderacion de contenido.
**Foco:** Filtros por edad, procesamiento efimero de fotos, politica anti-bullying en roasts, consent flow para padres.

### Business Stakeholder
**Agente:** `business-stakeholder`
**Responsabilidad:** Validacion del modelo de precios, decisiones de pricing AR vs USD, canal de distribucion.
**Foco:** MercadoPago integration, conversion dinamica ARS/USD, estrategia de growth viral.
