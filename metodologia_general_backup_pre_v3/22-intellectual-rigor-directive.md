# Rigor Intelectual en Análisis Técnico - Directiva Obligatoria

**Versión:** 1.0
**Fecha:** 2026-01-29
**Estado:** OBLIGATORIO - Aplica a TODOS los análisis y diagnósticos

---

## Origen de esta Directiva

Durante un análisis de datos en el proyecto LinkedIn Transcript Extractor, se afirmó:

> "LinkedIn no ofrece subtítulos en español para esos videos"

Esta afirmación fue presentada como hecho cuando en realidad:
- No había evidencia directa que la sustentara
- Los datos solo mostraban que no se habían capturado VTTs
- La causa real era desconocida

Este tipo de afirmaciones sin fundamento son **perjudiciales** para la construcción de sistemas sólidos.

---

## Principio Fundamental

**Nunca presentar hipótesis como hechos.**

Distinguir siempre entre:
1. **Hechos observados** - Datos concretos, medibles, verificables
2. **Hipótesis** - Explicaciones posibles que requieren verificación
3. **Desconocidos** - Lo que no sabemos y debemos investigar

---

## Por Qué Importa

Las afirmaciones sin fundamento causan:

| Problema | Consecuencia |
|----------|--------------|
| Cierre prematuro de investigación | Bugs reales quedan sin resolver |
| Decisiones arquitectónicas erróneas | Sistema construido sobre premisas falsas |
| Pérdida de tiempo | Esfuerzo invertido en direcciones incorrectas |
| Falsa confianza | Creer que entendemos cuando no entendemos |
| Deuda técnica oculta | Problemas que reaparecen porque nunca se diagnosticaron bien |

---

## Formato Correcto de Análisis

### MAL - Afirmación sin fundamento:
```
"Los 68 videos sin captions no tienen subtítulos ES disponibles en LinkedIn"
```

### BIEN - Distinción clara:
```
**Hechos observados:**
- 68 videos en visited_contexts no tienen entrada en available_captions
- 0 VTTs fueron capturados para esos videos (de ningún idioma)

**Hipótesis (sin verificar):**
- LinkedIn podría no ofrecer subtítulos ES para esos cursos
- El interceptor podría haber fallado durante el crawl
- Podría haber un bug en la lógica de captura

**Desconocido:**
- Qué idiomas ofrece realmente LinkedIn para esos videos
- Por qué el interceptor no capturó nada

**Próximo paso para verificar:**
- Re-crawlear con filterMode: 'captureAll' para ver qué devuelve LinkedIn
```

---

## Reglas Obligatorias

### 1. Usar lenguaje preciso

| Evitar | Usar |
|--------|------|
| "X no funciona porque Y" | "X no funciona. Posible causa: Y (requiere verificación)" |
| "El problema es Z" | "Los datos sugieren que podría ser Z" |
| "LinkedIn no ofrece..." | "No tenemos datos de qué ofrece LinkedIn" |

### 2. Etiquetar explícitamente

Cuando presentes análisis, usar etiquetas:
- `[HECHO]` - Dato observado directamente
- `[HIPÓTESIS]` - Explicación posible sin verificar
- `[DESCONOCIDO]` - Lo que no sabemos
- `[VERIFICAR]` - Acción necesaria para confirmar

### 3. No cerrar investigaciones prematuramente

Si no tenés evidencia directa de la causa:
- NO afirmar que sabés la causa
- SÍ documentar las hipótesis como tales
- SÍ proponer pasos de verificación

### 4. Preferir "no sé" a inventar

Es preferible decir:
> "No sé por qué estos cursos no tienen VTTs capturados. Necesito investigar más."

Que inventar:
> "LinkedIn no ofrece subtítulos para estos cursos."

---

## Aplicación en Código y Documentación

### En comentarios de código:
```javascript
// HIPÓTESIS: LinkedIn podría enviar VTTs en orden diferente
// TODO: Verificar con logs detallados
```

### En reportes de diagnóstico:
```markdown
## Diagnóstico

### Hechos
- Query retorna 0 resultados
- Tabla tiene 1500 registros

### Hipótesis
1. Índice corrupto (probabilidad: baja)
2. Condición WHERE incorrecta (probabilidad: alta)

### Verificación necesaria
- [ ] Revisar plan de ejecución
- [ ] Probar query sin WHERE
```

### En commits:
```
fix: corregir captura de VTTs

Problema observado: VTTs no se guardaban para algunos cursos
Causa identificada: race condition en el interceptor (verificado con logs)
```

NO:
```
fix: corregir problema de LinkedIn que no envía subtítulos
```

---

## Checklist de Verificación

Antes de afirmar una causa o explicación:

- [ ] ¿Tengo datos directos que lo demuestren?
- [ ] ¿Puedo reproducir el problema?
- [ ] ¿He descartado otras explicaciones?
- [ ] ¿Estoy distinguiendo entre hecho e hipótesis?
- [ ] ¿Propongo cómo verificar mi hipótesis?

Si alguna respuesta es NO → Presentar como hipótesis, no como hecho.

---

## Beneficios

1. **Diagnósticos más precisos** - Encontrar la causa real, no la imaginada
2. **Sistemas más sólidos** - Construidos sobre entendimiento real
3. **Menos retrabajo** - No perseguir causas falsas
4. **Mejor documentación** - Registro claro de qué sabemos y qué no
5. **Cultura de rigor** - Estándar de calidad en análisis técnico

---

**Esta directiva es OBLIGATORIA para todo análisis técnico.**
**Claude debe aplicarla en cada diagnóstico, reporte o afirmación causal.**
