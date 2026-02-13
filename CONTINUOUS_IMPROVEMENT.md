# Tareas de Mejora Continua - Sistema Claude

**Ultima actualizacion:** 2026-01-26
**Responsable:** Claude (Asistente de Direccion)
**Directiva:** `metodologia_general/21-continuous-improvement-directive.md`

---

## Tareas Pendientes

### [PENDIENTE] Revisar definiciones de agentes custom
- **Prioridad:** Media
- **Ubicacion:** `C:/Users/gdali/.claude/agents/`
- **Trigger:** Cuando haya momento apropiado (fin de sprint, baja actividad)
- **Alcance:**
  1. Revisar consistencia entre definiciones de agentes
  2. Identificar gaps (agentes que faltan)
  3. Identificar redundancias (agentes que se solapan)
  4. Proponer mejoras en prompts y responsabilidades
  5. Optimizar uso de contexto (reducir longitud sin perder calidad)
  6. Verificar que ejemplos sean claros y utiles
  7. Estandarizar formato entre todos los agentes
- **Output:** Documento con propuestas para aprobacion del usuario

### [PENDIENTE] Consolidar documentos de metodologia
- **Prioridad:** Baja
- **Observacion:** Se identifico que hay ~15 @imports en User Memory
- **Propuesta:** Crear resumen compacto que reduzca carga de contexto
- **Trigger:** Cuando se detecte que el contexto esta muy cargado

### [PENDIENTE] Limpiar carpeta methodology vs metodologia_general
- **Prioridad:** Baja
- **Observacion:** Parecen ser duplicados o versiones anteriores
- **Accion:** Verificar y consolidar si corresponde

---

## Tareas Completadas

| Fecha | Tarea | Resultado |
|-------|-------|-----------|
| 2026-01-26 | Crear agente flutter-developer | Creado en ~/.claude/agents/ |

---

## Criterios para Ejecutar Mejoras

1. **Fin de sprint** - Momento natural de reflexion
2. **Baja actividad** - Cuando no hay tareas urgentes
3. **Deteccion de problema** - Si se identifica gap o issue durante trabajo
4. **Solicitud del usuario** - Cuando el usuario lo pida explicitamente

---

## Notas

- Estas tareas NO son urgentes, son de mejora continua
- Siempre consultar con el usuario antes de implementar cambios
- Documentar propuestas antes de ejecutar
- Priorizar trabajo del proyecto sobre mejoras del sistema
