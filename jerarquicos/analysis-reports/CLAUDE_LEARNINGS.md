# Claude Code - Aprendizajes y Mejores Prácticas

## Propósito
Este documento captura aprendizajes clave y mejores prácticas descubiertos durante el desarrollo para aplicarlos consistentemente en futuras sesiones.

---

## 🎯 **Principios de Diseño**

### KISS (Keep It Simple, Stupid)
- **Aprendido en**: PBI 160067 - Migración WCF a REST
- **Lección**: No agregar capas de abstracción innecesarias solo por "buenas prácticas"
- **Ejemplo**: Eliminar `ExpedienteAutorizacionPdfService` y usar directamente `IApiExpedienteAutorizacionClient`
- **Aplicar**: Siempre preguntar "¿Esto realmente agrega valor o solo complejidad?"

### Cumplir Requisitos Exactos
- **Principio**: Hacer exactamente lo que piden los requisitos, sin "mejoras" no solicitadas
- **Anti-patrón**: Agregar feature flags o funcionalidad adicional no requerida
- **Validación**: Si no está en los requisitos, no lo implementes

---

## 🛠️ **Mejores Prácticas Técnicas**

### Migración de APIs
1. **Identificar llamadas existentes** usando grep/search
2. **Analizar parámetros necesarios** del endpoint destino
3. **Crear DTOs mínimos** sin over-engineering
4. **Implementar cliente HTTP directo** sin capas intermedias
5. **Reemplazar llamadas** manteniendo la estructura de respuesta HTTP
6. **Verificar compilación** en cada paso

### Limpieza de Código
- **Eliminar usings no utilizados** después de cada cambio
- **Remover comentarios redundantes** que no agregan información
- **Mantener solo código esencial**
- **Verificar compilación** después de limpiezas

---

## 🔄 **Proceso de Development**

### Uso de TodoWrite Tool
- **Siempre usar** para tareas complejas o multi-paso
- **Marcar como completed** inmediatamente después de terminar cada tarea
- **Mantener un solo item in_progress** a la vez
- **Útil para** dar visibilidad al usuario del progreso

### Code Review Internal
- **Cuestionar decisiones de diseño** durante el desarrollo
- **Validar si una abstracción realmente agrega valor**
- **Preguntar "¿Por qué este approach?"** antes de implementar
- **Considerar alternativas más simples**

---

## 🚫 **Anti-Patrones Identificados**

### Over-Engineering
- ❌ Crear servicios adaptadores innecesarios
- ❌ Agregar feature flags no requeridos
- ❌ Implementar capas de abstracción "por si acaso"
- ✅ **Alternativa**: Implementación directa y simple

### Sobrecomplicación de Requisitos
- ❌ Agregar funcionalidad "mejorada" no pedida
- ❌ Asumir necesidades futuras no documentadas
- ✅ **Alternativa**: Seguir requisitos al pie de la letra

---

## 📋 **Checklist para Futuras Implementaciones**

### Antes de Implementar
- [ ] ¿Los requisitos están claramente entendidos?
- [ ] ¿Esta solución es la más simple que funciona?
- [ ] ¿Cada capa/clase agrega valor real?
- [ ] ¿Hay alternativas más directas?

### Durante Implementación
- [ ] ¿Estoy siguiendo principios KISS?
- [ ] ¿Cada abstracción está justificada?
- [ ] ¿El código será fácil de mantener?
- [ ] ¿Estoy cumpliendo exactamente los requisitos?

### Después de Implementar
- [ ] ¿Se puede simplificar aún más?
- [ ] ¿Hay código/capas innecesarias?
- [ ] ¿La solución es fácil de entender?
- [ ] ¿Cumple todos los requisitos sin extras?

---

## 🎓 **Lecciones Específicas por Proyecto**

### PBI 160067 - Migración WCF a REST (Sep 2025)
**Contexto**: Migrar método `ObtenerPdfExpedienteAutorizacion` de WCF a REST API

**Errores Iniciales**:
- Crear `ExpedienteAutorizacionPdfService` innecesario
- Agregar feature flag no requerido
- Over-engineering de la solución

**Correcciones Aplicadas**:
- Uso directo de `IApiExpedienteAutorizacionClient.GetPdf()`
- Eliminación de capas intermedias
- Cumplimiento exacto de requisitos

**Aprendizaje Clave**: 
> "El patrón más simple que funciona es generalmente el correcto"

**Feedback del Usuario**:
> "¿Cuál fue el criterio que te decidió a realizarla de esa manera?" - Esta pregunta reveló la sobreingeniería

---

## 🔮 **Para Próximas Sesiones**

### Al Iniciar un Proyecto
1. Leer este documento al comenzar
2. Revisar checklist de implementación
3. Aplicar principios KISS desde el inicio
4. Validar approach con preguntas simples

### Durante el Desarrollo
- Referenciar anti-patrones identificados
- Aplicar lecciones específicas relevantes
- Mantener focus en simplicidad

### Al Finalizar
- Documentar nuevos aprendizajes aquí
- Actualizar checklist si es necesario
- Reflexionar sobre decisiones tomadas

---

**Última actualización**: 10 de Septiembre de 2025
**Proyecto**: ApiMovil - Migración WCF to REST
**Contribuyentes**: Claude AI + Usuario (Pair Programming)