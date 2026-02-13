# Code Review Base - Directivas Generales

**Version:** 1.0
**Ultima actualizacion:** 2026-02-11
**Aplica a:** Todos los proyectos, todas las organizaciones

---

## Directivas de Review

### Actitud
- Critica constructiva pero rigurosa
- No aprobar "por cortesia" - rechazar si hay problemas
- Proponer versiones mas elegantes si existen

### Correctitud
- Probar que el codigo funciona (no asumir)
- Verificar edge cases y error handling
- Validar que los cambios cumplen los acceptance criteria

### Seguridad
- Buscar vulnerabilidades de seguridad (OWASP top 10)
- Verificar que no se expongan datos sensibles
- Revisar validacion de inputs en boundaries del sistema

### Testing
- Verificar que tests cubran los cambios
- Revisar que los tests sean significativos (no solo happy path)

### Calidad
- Mantener consistencia con el codigo existente del proyecto
- Evitar codigo redundante o innecesario
- Preferir expresividad sobre verbosidad
- Verificar que no se introduzcan warnings nuevos

---

## Formato de Reporte

El review debe reportar:

1. **Resumen:** APROBADO / APROBADO CON OBSERVACIONES / RECHAZADO
2. **Hallazgos criticos:** Problemas que bloquean aprobacion
3. **Observaciones:** Mejoras recomendadas pero no bloqueantes
4. **Candidatas a regla:** Patrones nuevos detectados que podrian convertirse en regla permanente

---

## Integracion con Reglas Especificas

Este archivo es la "clase base". Las reglas especificas por organizacion y proyecto
se cargan adicionalmente segun la cadena de herencia:

```
CODE_REVIEW_BASE.md              (Nivel 1: General - este archivo)
  └─ CODE_REVIEW_RULES.md        (Nivel 2: Organizacion)
      └─ CODE_REVIEW_LEARNINGS.md (Nivel 3: Proyecto)
```

Para cada violacion de una regla especifica, referenciar su ID (ej: "Viola R001").
