# Practicas Avanzadas (Cargar Bajo Demanda)

**Version:** 3.0
**Fecha:** 2026-02-04
**Estado:** ACTIVO - Cargar cuando el proyecto lo requiera (Medium+ scale)

Este archivo consolida practicas avanzadas de los docs 11-14 de v2.
Para proyectos micro (1 dev), estas practicas son OPCIONALES.

---

## 1. Two-Track Agile (Discovery + Delivery)

### Concepto

Preparar Sprint N+1 durante Sprint N, eliminando gap entre sprints.

```
Sprint N:
  Track 2 (Delivery 88%): Ejecutar Epic actual
  Track 1 (Discovery 12%): Preparar Epic siguiente

Sprint N+1 comienza SIN delay.
```

**Resultado: +25% sprints/ano** (28 → 36 sprints)

### Distribucion de Tiempo (Sprint 10 dias)

| Track | Horas | % | Actividad |
|-------|-------|---|-----------|
| Track 2 Delivery | ~41h | 88% | Implementacion, testing, review |
| Track 1 Discovery | ~6h | 12% | Diagnostico, planning, backlog |

### Discovery Checklist
- Week 1: Diagnostico tecnico (3h) + Project plan (2h)
- Week 2: Product backlog (2h) + Business decision (1h)
- Output: Epic N+1 con GO decision, listo para Sprint N+1

### Reglas
- Discovery solo para Sprint N+1 (no mas adelante)
- Max 15% del sprint en discovery
- Si surge P0, pausar discovery
- Epic preparado DEBE ejecutarse (no waste)

---

## 2. Technical Debt Management

### Metricas Clave

**Interest Rate:** Horas perdidas por sprint por NO arreglar el debt.
**Fix Cost:** Horas para eliminar el debt completamente.
**ROI:** `(Interest Rate x Sprints Remaining) / Fix Cost`

### Decision Rules

| ROI | Accion |
|-----|--------|
| >10x | Fix INMEDIATAMENTE |
| 5-10x | Fix en proximo sprint |
| <5x | Fix cuando haya capacidad |
| Severity=Critical | Fix sin importar ROI |

### Ejemplo
```
TD-002: No hay indexes en TranscriptSegments
  Interest: 5h/sprint (queries lentos + debugging)
  Fix Cost: 3h
  Sprints remaining: 20
  ROI = (5 x 20) / 3 = 33x → FIX INMEDIATAMENTE
```

### TD Register

Ubicacion: `TECHNICAL_DEBT_REGISTER.md` en raiz del proyecto.

```markdown
| ID | Descripcion | Severidad | Interest/Sprint | Fix Cost | ROI | Status |
|----|-------------|-----------|-----------------|----------|-----|--------|
| TD-001 | No indexes | High | 5h | 3h | 33x | Open |
```

### Strategic Debt (Riesgo Futuro)

Para debt que funciona HOY pero sera problema futuro:

```
Strategic ROI = (Future Emergency Cost x Probability) / Fix Cost Today
```

| Strategic ROI | Horizon | Decision |
|---------------|---------|----------|
| >10x | Any | Fix immediately |
| 5-10x | <6 months | Fix next sprint |
| 3-5x | <6 months | Plan next quarter |
| <3x | Any | Monitor, revisit annually |

Review: Quarterly (no cada sprint como operational debt).

---

## 3. Capacity Planning

### Formula

```
Capacity (h) = Team Days x Hours/Day x Efficiency x Availability

Ejemplo (1 dev, sprint 10 dias):
  = 1 x 10 x 6h x 0.80 x 0.98
  = 47h

Commitment (80%): 37.6h
Buffer (20%): 9.4h
```

### Parametros

| Parametro | Valor tipico | Notas |
|-----------|-------------|-------|
| Hours/Day | 6h | 8h - 2h overhead |
| Efficiency | 0.80 | Ajustar despues de 3 sprints |
| Availability | 0.98 | Menos vacaciones/sick |
| Buffer | 20% | Para bugs, TD, urgencias |

### Conversion a Story Points

```
Hours/Point = promedio ultimos 3 sprints
Capacity (pts) = Delivery Hours / Hours per Point
Commitment = Capacity x 0.80
```

### Red Flags
- Commitment > 100% capacity → De-scope inmediatamente
- Buffer < 15% → Reducir commitment
- Velocity dropping 3 sprints consecutivos → Investigar causa

---

## 4. Definition of Ready (Completo)

### Level 1: Minimum (US <= 3pts)

- [ ] ID unico asignado
- [ ] Titulo descriptivo
- [ ] 2+ AC basicos (Given-When-Then)
- [ ] Dependencies: ninguna o documentadas
- [ ] Componentes afectados identificados
- [ ] Technical Lead approval

### Level 2: Standard (US 3-8pts)

Todo Level 1, mas:
- [ ] User story format (As a/I want/So that)
- [ ] 3-5 AC con Given-When-Then (happy path + edge cases)
- [ ] Dependencies todas resueltas
- [ ] API contracts definidos (si aplica)
- [ ] DB changes identificados
- [ ] Performance requirements claros
- [ ] Security considerations documentadas
- [ ] Test strategy definida (unit + integration)
- [ ] Coverage target: >70% unit, >60% integration
- [ ] Product Owner + Technical Lead approval

### Level 3: Comprehensive (US >8pts, criticas)

Todo Level 2, mas:
- [ ] Architecture Decision Record
- [ ] Security audit + threat modeling
- [ ] Penetration test plan
- [ ] Load test plan
- [ ] Deployment strategy (blue-green, canary, feature flags)
- [ ] Monitoring & alerting rules
- [ ] Rollback plan documentado y testeado
- [ ] Risk assessment matrix (probability x impact)
- [ ] Multi-stakeholder approval

### Gating Rules

- DoR no completo → NO iniciar desarrollo
- Bloqueador detectado → PAUSE historia, crear issue
- Estimacion >13 pts → SPLIT en historias mas pequenas

---

## 5. Specialized Analyst Agents

Agentes para analisis especializados (no siempre necesarios):

| Agente | Uso |
|--------|-----|
| `data-quality-analyst` | Datos corruptos, anomalias, distribuciones |
| `matching-specialist` | Correlacion entre datasets, deduplicacion |
| `localization-analyst` | Deteccion de idioma, traduccion, i18n |

Invocar via Task tool con subagent_type apropiado.

---

## 6. Observability (para Medium+ projects)

### Stack Minimo
- **Structured Logging:** Correlation IDs, log levels correctos
- **Metrics:** Business + technical (p95 latency, error rates)
- **Traces:** Distributed tracing para performance bottlenecks

### Regla: No merge sin docs
- API docs updated (Swagger)
- README updated si setup cambio
- CHANGELOG entry creada
- Configuration documented

---

**Version:** 3.0 | **Ultima actualizacion:** 2026-02-04
**Nota:** Este archivo se carga bajo demanda. Para micro projects, no es necesario.
