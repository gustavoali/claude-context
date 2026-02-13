# Rate Limiting Spike Analysis

**Fecha:** 2026-02-03
**Estado:** ANÁLISIS COMPLETADO (sin ejecución manual)

---

## 1. Evidencia Existente

### Configuración Actual del Sistema

```javascript
const RATE_LIMITS = {
  MIN_DELAY: 30000,   // 30 segundos
  MAX_DELAY: 120000,  // 2 minutos
  DEFAULT_DELAY: 60000 // 1 minuto
};
```

### Resultados de Crawls Anteriores

| Batch | Status | Cursos | Videos | Rate Limited |
|-------|--------|--------|--------|--------------|
| adefec0f-... | COMPLETED | 11 | 86 | NO |
| 82d0c8f5-... | COMPLETED | 1 | ~20 | NO |

**Observación:** Ningún batch ha reportado rate limiting con procesamiento secuencial.

---

## 2. Análisis de Riesgo

### Comportamiento Conocido de LinkedIn

| Factor | Estado | Evidencia |
|--------|--------|-----------|
| VTT Requests | Sin límite visible | 50+ VTTs por sesión sin problemas |
| Page Navigation | Tolerante | Crawls de 60+ videos sin bloqueos |
| Session Duration | Sin límite | Sesiones de 2+ horas funcionan |
| Concurrent Sessions | **DESCONOCIDO** | No hay evidencia |

### Riesgo de Parallelización

| Concurrency | Riesgo Estimado | Razón |
|-------------|-----------------|-------|
| 1 (actual) | BAJO | Probado extensivamente |
| 2 | BAJO-MEDIO | Similar a un usuario con 2 tabs |
| 3-5 | MEDIO | Patrones no humanos |
| 5+ | ALTO | Claramente automatizado |

---

## 3. Decisión

### Opción A: Spike Manual Completo (2h)

**Pros:**
- Evidencia directa
- Medición precisa de límites

**Cons:**
- Riesgo de suspensión de cuenta
- Requiere cuenta de prueba
- Tiempo de ejecución manual

### Opción B: Implementación Conservadora sin Spike ✅ RECOMENDADO

**Estrategia:**
1. Implementar parallelismo con **máximo 2 contextos**
2. Monitoreo automático de respuestas 429
3. Auto-fallback a secuencial si se detecta rate limiting
4. Delays mínimos de 10s entre requests por contexto

**Pros:**
- Bajo riesgo (2 concurrent = 1 usuario con 2 tabs)
- Mejora de ~50% en tiempo de crawl
- Auto-protección incluida

**Cons:**
- Mejora menor que parallelismo agresivo
- No conocemos el límite real

---

## 4. Implementación Propuesta (Sin Spike)

### Arquitectura de Etapa 2 Conservadora

```
                    ┌─────────────────────┐
                    │  Completion Manager │
                    │  (Max 2 concurrent) │
                    └─────────┬───────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               │
        ┌──────────┐   ┌──────────┐          │
        │ Context 1│   │ Context 2│          │
        │ (Primary)│   │ (Secondary)        │
        └────┬─────┘   └────┬─────┘          │
             │              │                 │
             ▼              ▼                 │
        ┌────────────────────────┐           │
        │   429 Monitor          │           │
        │   - Detect rate limit  │───────────┘
        │   - Auto-fallback      │  (Disable Context 2)
        │   - Increase delays    │
        └────────────────────────┘
```

### Configuración Conservadora

```javascript
const PARALLEL_CONFIG = {
  maxConcurrency: 2,           // Máximo 2 contextos
  minDelayPerContext: 10000,   // 10s entre requests por contexto
  maxDelayPerContext: 30000,   // 30s máximo
  rateLimitThreshold: 3,       // 3 x 429 = disable parallelismo
  fallbackToSequential: true   // Auto-fallback activado
};
```

---

## 5. Recomendación Final

**DECISIÓN: GO CONDICIONAL para Etapa 2**

| Aspecto | Decisión |
|---------|----------|
| Spike Manual | NO REQUERIDO |
| Implementación | Parallelismo conservador (max 2) |
| Monitoreo | Obligatorio (429 detection) |
| Fallback | Automático a secuencial |

### Métricas de Éxito

| Métrica | Target | Medición |
|---------|--------|----------|
| Mejora de velocidad | ≥30% | Tiempo de crawl |
| Rate limiting | 0 incidentes/mes | Contador 429 |
| Confiabilidad | ≥99% | Crawls exitosos |

---

## 6. Plan de Acción

1. **Sprint N+1:** Implementar Etapa 2 con concurrency=2
2. **Monitoreo:** 30 días de observación
3. **Ajuste:** Si 0 rate limits, considerar aumentar a 3

**Archivos a crear:**
- `modules/crawl/workers/parallel-completion-manager.js`
- `modules/crawl/monitors/rate-limit-monitor.js`

---

**Conclusión:** Proceder con implementación conservadora sin spike manual. El riesgo de 2 contextos paralelos es aceptable y similar al comportamiento de un usuario normal con múltiples tabs.
