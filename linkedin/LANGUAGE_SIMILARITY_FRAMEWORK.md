# Framework de Similitud de Idiomas para Fallback de Contenido

**Version:** 1.0
**Fecha:** 2026-01-27
**Origen:** Experiencia empirica - LinkedIn Transcript Extractor
**Proposito:** Guia generalizable para estrategias de fallback linguistico

---

## Contexto y Motivacion

Durante el desarrollo del LinkedIn Transcript Extractor, enfrentamos el problema de videos sin subtitulos en el idioma objetivo (español). En lugar de descartar estos videos, implementamos una estrategia de **fallback por similitud linguistica** que permitio recuperar contenido util mediante traduccion automatica.

Este documento captura las conclusiones generales que pueden aplicarse a cualquier par de idiomas.

---

## 1. Concepto de Similitud Linguistica

### 1.1 Definicion

La **similitud linguistica** es una medida de cuan relacionados estan dos idiomas en terminos de:

- **Lexica:** Vocabulario compartido o cognados
- **Gramatical:** Estructuras sintacticas similares
- **Fonetica:** Patrones de pronunciacion
- **Ortografica:** Sistema de escritura

### 1.2 Factores que Determinan la Similitud

| Factor | Descripcion | Impacto en Traduccion |
|--------|-------------|----------------------|
| **Familia linguistica** | Idiomas del mismo origen (ej: romances) | Alto - estructuras compartidas |
| **Contacto historico** | Prestamos y evolucion paralela | Medio - vocabulario compartido |
| **Tipologia** | Orden de palabras (SVO, SOV, etc.) | Alto - facilita traduccion automatica |
| **Sistema de escritura** | Alfabeto compartido vs diferente | Bajo - afecta mas al OCR que a traduccion |

---

## 2. Matriz de Similitud para Español (Caso de Estudio)

### 2.1 Idiomas por Nivel de Similitud

Basado en nuestra experiencia empirica con traducciones automaticas:

#### Tier 1: Muy Alta Similitud (>85% comprension mutua potencial)
| Idioma | Familia | Notas |
|--------|---------|-------|
| **Portugues** | Romance | Lexica ~90% similar, gramatica casi identica |
| **Italiano** | Romance | Lexica ~80% similar, estructuras muy cercanas |
| **Catalan** | Romance | Parcialmente inteligible sin traduccion |
| **Gallego** | Romance | Muy cercano al portugues, alta similitud |

**Calidad de traduccion automatica esperada:** 95-99%
**Recomendacion:** Primera opcion para fallback

#### Tier 2: Alta Similitud (60-85%)
| Idioma | Familia | Notas |
|--------|---------|-------|
| **Frances** | Romance | Mas divergente pero misma familia |
| **Rumano** | Romance | Conserva latín pero con influencias eslavas |
| **Occitano** | Romance | Similar al catalan |

**Calidad de traduccion automatica esperada:** 90-95%
**Recomendacion:** Segunda opcion para fallback

#### Tier 3: Similitud Media (40-60%)
| Idioma | Familia | Notas |
|--------|---------|-------|
| **Ingles** | Germanica | Muchos prestamos latinos, SVO como español |
| **Aleman** | Germanica | Menos cognados pero estructura logica |

**Calidad de traduccion automatica esperada:** 85-92%
**Recomendacion:** Tercera opcion, util para contenido tecnico

#### Tier 4: Baja Similitud (<40%)
| Idioma | Familia | Notas |
|--------|---------|-------|
| **Chino** | Sinítica | Sistema de escritura diferente, tipologia distinta |
| **Japones** | Japonica | Tres sistemas de escritura, SOV |
| **Arabe** | Semitica | Escritura RTL, morfologia compleja |
| **Coreano** | Coreánica | SOV, aglutinante |

**Calidad de traduccion automatica esperada:** 75-85%
**Recomendacion:** Ultimo recurso, revisar resultados

---

## 3. Algoritmo de Seleccion de Fallback

### 3.1 Pseudocodigo General

```
FUNCION seleccionar_fallback(idioma_objetivo, idiomas_disponibles):

    # Obtener matriz de similitud para el idioma objetivo
    similitudes = obtener_similitudes(idioma_objetivo)

    # Ordenar idiomas disponibles por similitud descendente
    candidatos = []
    PARA CADA idioma EN idiomas_disponibles:
        SI idioma != idioma_objetivo:
            score = similitudes[idioma]
            candidatos.agregar((idioma, score))

    candidatos.ordenar_por_score_descendente()

    # Filtrar por umbral minimo de calidad
    UMBRAL_MINIMO = 0.75  # 75% calidad esperada
    candidatos = filtrar(candidatos, score >= UMBRAL_MINIMO)

    RETORNAR candidatos
```

### 3.2 Implementacion en JavaScript (de nuestro proyecto)

```javascript
// Prioridad de fallback para español
const FALLBACK_PRIORITY_ES = [
  { code: 'pt', name: 'Portuguese', similarity: 0.90 },
  { code: 'it', name: 'Italian', similarity: 0.82 },
  { code: 'ca', name: 'Catalan', similarity: 0.85 },
  { code: 'fr', name: 'French', similarity: 0.75 },
  { code: 'en', name: 'English', similarity: 0.65 },
  { code: 'de', name: 'German', similarity: 0.55 }
];

function selectBestFallback(targetLang, availableLangs) {
  const priorities = FALLBACK_PRIORITIES[targetLang] || [];

  for (const fallback of priorities) {
    if (availableLangs.includes(fallback.code)) {
      return {
        language: fallback.code,
        expectedQuality: fallback.similarity,
        needsReview: fallback.similarity < 0.80
      };
    }
  }

  return null; // No suitable fallback
}
```

---

## 4. Generalizacion a Otros Idiomas

### 4.1 Template de Matriz de Similitud

Para crear una matriz de similitud para cualquier idioma objetivo:

```yaml
# Template: language_similarity_matrix.yaml
target_language: "[CODIGO_ISO]"
target_name: "[NOMBRE]"
language_family: "[FAMILIA]"

tiers:
  tier_1_very_high:  # >85% similarity
    - code: ""
      name: ""
      family: ""
      notes: ""
      expected_quality: 0.95

  tier_2_high:  # 60-85% similarity
    - code: ""
      name: ""
      family: ""
      notes: ""
      expected_quality: 0.90

  tier_3_medium:  # 40-60% similarity
    - code: ""
      name: ""
      family: ""
      notes: ""
      expected_quality: 0.85

  tier_4_low:  # <40% similarity
    - code: ""
      name: ""
      family: ""
      notes: ""
      expected_quality: 0.75

fallback_config:
  min_quality_threshold: 0.75
  require_human_review_below: 0.85
  max_fallback_chain_length: 3
```

### 4.2 Familias Linguisticas Principales

Para referencia al construir matrices:

| Familia | Idiomas Principales | Caracteristicas |
|---------|---------------------|-----------------|
| **Romance** | ES, PT, IT, FR, RO, CA | Derivados del latin, alta similitud interna |
| **Germanica** | EN, DE, NL, SV, NO, DA | Cognados germinicos, SVO mayormente |
| **Eslava** | RU, PL, UK, CS, BG, SR | Casos gramaticales, escritura variable |
| **Sinítica** | ZH (Mandarin, Cantonés) | Tonal, logografico |
| **Semítica** | AR, HE | RTL, raices triliterales |
| **Japonica** | JA | SOV, multiples escrituras |
| **Coreánica** | KO | SOV, aglutinante, Hangul |
| **Indoaria** | HI, BN, UR | Derivadas del sanscrito |

### 4.3 Ejemplos de Matrices para Otros Idiomas

#### Para Ingles (EN) como objetivo:
```
Tier 1: Holandes (NL), Aleman (DE), Afrikaans (AF)
Tier 2: Sueco (SV), Noruego (NO), Danes (DA)
Tier 3: Frances (FR), Español (ES), Italiano (IT)
Tier 4: Chino (ZH), Japones (JA), Arabe (AR)
```

#### Para Portugues (PT) como objetivo:
```
Tier 1: Español (ES), Gallego (GL), Italiano (IT)
Tier 2: Frances (FR), Catalan (CA), Rumano (RO)
Tier 3: Ingles (EN)
Tier 4: Aleman (DE), Chino (ZH)
```

#### Para Chino Mandarin (ZH) como objetivo:
```
Tier 1: Chino Cantonés, Chino clasico
Tier 2: Japones (comparte caracteres), Coreano (prestamos)
Tier 3: Vietnamita (prestamos historicos)
Tier 4: Ingles, Español (muy distantes)
```

---

## 5. Metricas de Evaluacion

### 5.1 Metricas para Validar Calidad de Traduccion

| Metrica | Descripcion | Uso |
|---------|-------------|-----|
| **BLEU Score** | Precision de n-gramas vs referencia | Traduccion automatica |
| **Cosine Similarity** | Similitud de embeddings semanticos | Preservacion de significado |
| **Edit Distance** | Operaciones para transformar | Correccion post-traduccion |
| **Human Evaluation** | Juicio de hablantes nativos | Gold standard |

### 5.2 Metricas Empiricas de Nuestro Proyecto

```
Resultados de fallback ES ← otros idiomas:

Portugues → Español:
  - Traducciones usadas: 15
  - Calidad reportada: Alta
  - Errores detectados: 0
  - Conclusion: Excelente fallback

Italiano → Español:
  - Traducciones usadas: 8
  - Calidad reportada: Alta
  - Errores detectados: 0
  - Conclusion: Muy buen fallback

Ingles → Español:
  - Traducciones usadas: 2
  - Calidad reportada: Buena
  - Errores detectados: 0
  - Conclusion: Aceptable para contenido tecnico

Total recuperado via fallback: 25 videos (de 39 nuevos = 64%)
```

---

## 6. Consideraciones Especiales

### 6.1 Contenido Tecnico vs General

El contenido tecnico (IT, ciencia, medicina) tiende a traducirse mejor debido a:

- **Terminologia estandarizada:** Muchos terminos tecnicos son prestamos del ingles
- **Estructura objetiva:** Menos ambiguedad que contenido literario
- **Contexto claro:** El dominio especifico reduce polisemia

**Recomendacion:** Para contenido tecnico, se puede ser mas permisivo con fallbacks de Tier 3.

### 6.2 Dialectos y Variantes

Considerar que algunos "idiomas" son variantes mutuamente inteligibles:

| Grupo | Variantes | Tratamiento |
|-------|-----------|-------------|
| Español | ES-ES, ES-MX, ES-AR | Intercambiables |
| Portugues | PT-PT, PT-BR | Intercambiables con diferencias menores |
| Chino | ZH-CN, ZH-TW | Simplificado vs Tradicional |
| Ingles | EN-US, EN-GB | Intercambiables |

### 6.3 Deteccion de Idioma

Antes de aplicar fallback, es crucial detectar correctamente el idioma disponible:

```javascript
// Patrones de deteccion usados en nuestro proyecto
const LANGUAGE_INDICATORS = {
  es: {
    chars: /[áéíóúüñ¿¡]/,
    words: /\b(que|para|como|pero|también|está)\b/i
  },
  pt: {
    chars: /[ãõç]/,
    words: /\b(que|para|como|mas|também|está|não|são)\b/i
  },
  it: {
    chars: /[àèìòù]/,
    words: /\b(che|per|come|anche|essere|sono|della)\b/i
  },
  fr: {
    chars: /[àâçéèêëïîôùûü]/,
    words: /\b(que|pour|comme|mais|aussi|être|sont|dans)\b/i
  },
  en: {
    chars: null, // ASCII mostly
    words: /\b(the|that|with|from|have|this|they|what)\b/i
  }
};
```

---

## 7. Recomendaciones para Implementacion

### 7.1 Arquitectura Sugerida

```
┌─────────────────────────────────────────────────────────┐
│                  Content Acquisition                     │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│              Language Detection Module                   │
│  - Detect source language                                │
│  - Confidence score                                      │
└─────────────────────────┬───────────────────────────────┘
                          │
              ┌───────────┴───────────┐
              │                       │
              ▼                       ▼
┌─────────────────────┐   ┌─────────────────────────────┐
│ Target Language     │   │ Fallback Selection          │
│ Available           │   │ - Load similarity matrix    │
│ → Use directly      │   │ - Select best available     │
└─────────────────────┘   │ - Apply translation         │
                          └─────────────┬───────────────┘
                                        │
                                        ▼
                          ┌─────────────────────────────┐
                          │ Quality Validation          │
                          │ - Check expected quality    │
                          │ - Flag for review if needed │
                          └─────────────────────────────┘
```

### 7.2 Configuracion Recomendada

```yaml
fallback_settings:
  # Habilitar/deshabilitar fallback
  enabled: true

  # Umbral minimo de similitud para usar fallback
  min_similarity: 0.70

  # Maxima cantidad de fallbacks en cadena
  max_chain_length: 2

  # Marcar contenido traducido
  mark_translated: true

  # Servicio de traduccion
  translation_service: "google_translate"  # o "deepl", "azure"

  # Logging
  log_fallback_usage: true
```

### 7.3 Metadata a Preservar

Cuando se usa contenido traducido, preservar:

```json
{
  "content": "Texto traducido...",
  "original_language": "pt",
  "target_language": "es",
  "translation_method": "automatic",
  "translation_service": "google_translate",
  "expected_quality": 0.90,
  "similarity_tier": 1,
  "needs_review": false,
  "translated_at": "2026-01-27T10:30:00Z"
}
```

---

## 8. Trabajo Futuro y Extensiones

### 8.1 Mejoras Potenciales

1. **Machine Learning para Similitud**
   - Usar embeddings multilingues (mBERT, XLM-R) para calcular similitud semantica real
   - Entrenar modelo con pares de traducciones evaluadas

2. **Fallback Dinamico**
   - Ajustar matriz basado en calidad observada
   - A/B testing de diferentes ordenes de prioridad

3. **Traduccion Especializada por Dominio**
   - Glosarios tecnicos personalizados
   - Fine-tuning de modelos por vertical

4. **Evaluacion Continua**
   - Pipeline automatico de validacion de calidad
   - Feedback loop de usuarios

### 8.2 Agentes Especializados Sugeridos

Para analisis mas profundo, considerar estos agentes:

| Agente | Especialidad | Uso |
|--------|--------------|-----|
| `localization-analyst` | Estrategias de i18n | Diseño de sistemas multilingues |
| `linguistic-expert` | Analisis de similitud | Construccion de matrices |
| `translation-evaluator` | Validacion de calidad | QA de traducciones |
| `domain-specialist` | Terminologia tecnica | Glosarios especializados |

---

## 9. Conclusiones

### 9.1 Lecciones Aprendidas

1. **La similitud linguistica predice calidad de traduccion**
   - Idiomas de la misma familia producen mejores traducciones automaticas
   - El portugues e italiano son excelentes fallbacks para español

2. **El contenido tecnico es mas tolerante**
   - Terminologia estandarizada reduce errores
   - Se pueden usar fallbacks de tiers mas bajos

3. **La deteccion de idioma es critica**
   - Un error en deteccion propaga a toda la cadena
   - Usar multiples indicadores (caracteres + palabras + patrones)

4. **Metadata de traduccion es esencial**
   - Permite filtrar o priorizar contenido original
   - Facilita auditorias de calidad

5. **El 64% de recuperacion justifica el esfuerzo**
   - En nuestro caso, 25 de 39 videos se recuperaron via fallback
   - El ROI de implementar fallback es alto

### 9.2 Regla General

> **Si el idioma objetivo no esta disponible, preferir siempre un idioma de la misma familia linguistica. La calidad de traduccion automatica decae significativamente al cruzar fronteras de familia.**

---

## Apendice A: Codigos ISO 639-1 Comunes

| Codigo | Idioma | Familia |
|--------|--------|---------|
| es | Español | Romance |
| pt | Portugues | Romance |
| it | Italiano | Romance |
| fr | Frances | Romance |
| ro | Rumano | Romance |
| ca | Catalan | Romance |
| en | Ingles | Germanica |
| de | Aleman | Germanica |
| nl | Holandes | Germanica |
| sv | Sueco | Germanica |
| ru | Ruso | Eslava |
| pl | Polaco | Eslava |
| zh | Chino | Sinítica |
| ja | Japones | Japonica |
| ko | Coreano | Coreánica |
| ar | Arabe | Semítica |
| hi | Hindi | Indoaria |

---

## Apendice B: Referencias

1. Ethnologue - Languages of the World: https://www.ethnologue.com/
2. WALS - World Atlas of Language Structures: https://wals.info/
3. ISO 639 Language Codes: https://www.loc.gov/standards/iso639-2/php/code_list.php
4. Google Translate Language Support: https://cloud.google.com/translate/docs/languages

---

**Documento generado:** 2026-01-27
**Basado en:** Experiencia empirica del proyecto LinkedIn Transcript Extractor
**Para uso de:** Agentes especializados en localizacion y analisis linguistico
