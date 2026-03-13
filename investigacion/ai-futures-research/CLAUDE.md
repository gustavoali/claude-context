# AI Futures Research - Project Context
**Version:** 0.1.0 | **Fase:** Seed
**Ubicacion:** C:/investigacion/ai-futures-research/
**Contexto:** C:/claude_context/investigacion/ai-futures-research/

## Descripcion
Investigacion sobre escritos de Dario Amodei y otros investigadores acerca de ventajas y riesgos de la IA. Analisis critico, notas de lectura, y produccion de sintesis propias.

## Stack
- Documentos: PDF, Markdown
- Herramientas: Python (PyMuPDF para extraccion de texto), Claude para analisis

## Documentos Fuente (47 catalogados)
| Autor | Fuentes | Enfoque |
|-------|---------|---------|
| Dario Amodei | 12 | Oportunidades + Riesgos + Policy |
| Bengio, Russell, Tegmark, Harari, Bostrom | 13 | Riesgos, alignment, humanismo |
| Yudkowsky, Hassabis, Altman, Hinton, Suleyman | 13 | Safety, balanced, oportunidades |
| Multi-autor/Policy | 6 | Cartas abiertas, EU AI Act, US EO |

Catalogo completo: `reading_notes/00-source-catalog.md`

## Estructura del Proyecto
```
C:/investigacion/ai-futures-research/   # Directorio de trabajo
  source_docs/                          # PDFs y articulos originales
  reading_notes/                        # Notas de lectura por documento
  analysis/                             # Analisis comparativos y sintesis
  essays/                               # Ensayos propios producidos
```

## Fuentes Adicionales (C:/amodei/)
La carpeta `C:/amodei/` contiene documentos fuente originales y HTMLs descargados.
Los PDFs relevantes estan copiados a `source_docs/` del proyecto.

## Agentes Recomendados
| Tarea | Agente |
|-------|--------|
| Analisis de documentos | general-purpose (Explore) |
| Produccion de ensayos | general-purpose |
| Investigacion web | general-purpose (WebSearch/WebFetch) |

## Reglas del Proyecto
1. Fuentes primarias siempre: citar textualmente, no parafrasear sin atribucion
2. Rigor intelectual: distinguir HECHO, HIPOTESIS, OPINION
3. Balance: presentar multiples perspectivas antes de sintetizar
4. Los documentos fuente originales se preservan intactos en source_docs/

## Docs
@C:/claude_context/investigacion/ai-futures-research/SEED_DOCUMENT.md
@C:/claude_context/investigacion/ai-futures-research/TASK_STATE.md
