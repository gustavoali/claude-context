# EPIC-002: Mejora del Importador de Recetas

**Estado:** Pendiente
**Prioridad:** HIGH
**Total Story Points:** 16
**Ultima actualizacion:** 2026-02-13

## Objetivo

Hacer el importador de recetas por URL robusto, seguro y capaz de parsear la mayor variedad posible de sitios de recetas en espanol e ingles.

## Contexto

El RecipeParser actual tiene 3 estrategias de extraccion (JSON-LD, meta tags, heuristica) pero falla con sitios que usan headings HTML como separador de secciones (patrón comun en sitios argentinos/hispanos). Ademas tiene vulnerabilidades de seguridad (SSRF) y problemas de robustez (sin timeout, sin manejo de HowToSection).

## Stories Incluidas

| ID | Titulo | Pts | Prioridad | Estado |
|----|--------|-----|-----------|--------|
| REC-003 | RecipeParser falla con sitios que usan headings como seccion | 5 | HIGH | Pendiente |
| REC-004 | Sin timeout ni manejo de redirects en HTTP request | 2 | HIGH | Pendiente |
| REC-005 | RecipeParser no maneja HowToSection en JSON-LD | 3 | HIGH | Pendiente |
| REC-007 | No hay validacion de seguridad en URL import - SSRF | 2 | HIGH | Pendiente |
| REC-008 | OcrService no dispone TextRecognizer correctamente | 2 | HIGH | Pendiente |
| REC-011 | Mensaje generico cuando parser no encuentra receta | 2 | MEDIUM | Pendiente |

## Orden de Ejecucion Sugerido

1. **REC-007** (HIGH) - Seguridad primero, validar URLs antes de hacer requests
2. **REC-004** (HIGH) - Robustez del HTTP client (timeout, headers)
3. **REC-005** (HIGH) - Soporte HowToSection en JSON-LD
4. **REC-003** (HIGH) - Fallback por headings HTML
5. **REC-008** (HIGH) - Memory leak del OCR
6. **REC-011** (MEDIUM) - UX del mensaje de error

## Criterios de Exito del Epic

- Parser extrae recetas de al menos 10 sitios populares (argentinos + internacionales)
- URLs privadas/locales son rechazadas con mensaje claro
- HTTP requests tienen timeout de 10s y limite de tamanio
- HowToSection de JSON-LD se parsea correctamente
- TextRecognizer se dispone al destruir el provider
- Mensajes de error indican la causa especifica del fallo
- Tests unitarios cubren cada estrategia de parsing

## Riesgos

| Riesgo | Probabilidad | Impacto | Mitigacion |
|--------|-------------|---------|------------|
| Sitios cambian estructura HTML frecuentemente | Alta | Medio | Multiples fallbacks, tests con HTML real |
| False positives en validacion SSRF | Baja | Medio | Whitelist de esquemas permitidos (http, https) |
| ML Kit OCR no disponible en emulador | Media | Bajo | Mock para tests, manual testing en device |

## Dependencias

- EPIC-001 debe estar resuelto (la app debe poder ejecutarse sin Firebase)
- REC-006 (tests) puede ejecutarse en paralelo con estas stories
