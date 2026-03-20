# AI Dev Transformation - Seed Document
**Fecha:** 2026-03-19
**Estado:** Semilla

## Vision

Investigar y documentar como la IA esta transformando el proceso de desarrollo de software: que cambia, que se gana, que se pierde, y como adaptarse.

## Ejes de Investigacion

### 1. Comprension vs Velocidad
El trade-off central identificado en la literatura inicial. AI aumenta productividad pero reduce comprension del codigo. El estudio de Anthropic muestra 17% menos comprension en developers que delegan vs los que preguntan.

**Preguntas clave:**
- Es inevitable el trade-off o se puede mitigar?
- Que practicas preservan comprension sin sacrificar velocidad?
- Como cambia esto segun seniority del developer?

### 2. Evolucion de Roles
El developer como coordinador de agentes AI vs ejecutor directo. Analogia con la evolucion de otros oficios (artesano -> director de fabrica).

**Preguntas clave:**
- Que habilidades nuevas se requieren? (prompt engineering, context engineering, orquestacion)
- Que habilidades se atrofian? (debugging manual, memorizacion de APIs, coding from scratch)
- Como afecta la carrera profesional del developer?

### 3. Calidad y Deuda Tecnica
AI genera codigo que pasa tests pero puede acumular "comprehension debt" - deuda invisible que no aparece en metricas tradicionales.

**Preguntas clave:**
- Como medir comprehension debt?
- AI genera mas o menos deuda tecnica que developers humanos?
- Como cambian los procesos de code review?

### 4. Herramientas y Paradigmas Emergentes
MCP, agents, coding assistants, context engineering. El stack de desarrollo esta cambiando.

**Preguntas clave:**
- Cuales son las categorias de herramientas AI para desarrollo?
- Que paradigmas nuevos estan surgiendo? (agent-based development, AI pair programming, etc.)
- Como se integran en workflows existentes?

### 5. Economia del Desarrollo con AI
Costos de tokens, ROI de herramientas AI, impacto en estimaciones y planning.

**Preguntas clave:**
- Cambian las metricas de productividad? (LOC/dia es obsoleto?)
- Como se estima esfuerzo cuando AI hace parte del trabajo?
- Que modelo de costos tiene sentido?

### 6. Formacion y Educacion
Como ensenar desarrollo cuando AI puede generar codigo. El dilema de la calculadora para matematicas, aplicado a programacion.

**Preguntas clave:**
- Se deberia ensenar a programar "a mano" primero?
- Como cambian los curriculos de CS/ingenieria?
- Que significa ser "junior" en la era de AI?

## Fuentes Iniciales

### Articulos Base
1. **Comprehension Debt** - Addy Osmani
   - URL: https://addyosmani.com/blog/comprehension-debt/
   - Tesis: La brecha entre codigo existente y comprension del developer crece con AI
   - Takeaway: Comprension genuina es no negociable; usar AI para preguntar, no delegar

2. **AI Assistance and Coding Skills** - Anthropic (RCT)
   - Blog: https://anthropic.com/research/AI-assistance-coding-skills
   - Paper: https://arxiv.org/abs/2601.20245
   - Tesis: AI mejora productividad pero reduce comprension 17% (casi dos letter grades)
   - Hallazgo clave: COMO se usa importa - preguntar > delegar
   - Takeaway: AI como partner de aprendizaje, no como shortcut

3. **El Espejismo del Codigo** - Alvaro Ruiz de Mendarozqueta (intive)
   - Archivo: source_docs/google-doc-export.md
   - Google Doc: https://docs.google.com/document/d/13e2XDyieXX9xY0Fy3ieUVo_YP8VLHTJfsSOInkHUrUY
   - Tesis: Saber programar != ser ingeniero de software. La herramienta (codigo) no es la disciplina (ingenieria)
   - Puntos clave:
     - Distincion herramienta vs disciplina (Parnas, Shaw)
     - Deuda tecnica como sintoma de falta de rigor (Boehm, Cunningham)
     - "Code and fix" como evasion del esfuerzo metodologico
     - AI amplifica el problema: automatiza mal diseno 10x mas rapido (Stanford, GitClear)
     - Complejidad esencial vs accidental (Brooks): AI resuelve la accidental, la esencial requiere ingenieria
     - "AI Native Engineering": el rol humano se concentra en gobernar complejidad esencial
   - Referencias internas: Perry et al. 2023 (Stanford), GitClear 2024, Brooks 1986, Shaw 1990

4. **Do Users Write More Insecure Code with AI Assistants?** - Perry et al. (Stanford, 2023)
   - Archivo: source_docs/perry-2023-summary.md
   - Paper: https://arxiv.org/abs/2211.03622
   - Tesis: Developers con AI generan codigo significativamente menos seguro + falsa sensacion de seguridad
   - Datos clave: Solo 21% del grupo AI produjo codigo seguro vs 36% control; 30-73% de vulnerabilidades originadas en codigo del modelo

5. **Coding on Copilot** - GitClear (2024)
   - Archivo: source_docs/gitclear-2024-summary.md
   - Reporte: https://www.gitclear.com/coding_on_copilot_data_shows_ais_downward_pressure_on_code_quality
   - Tesis: AI aumenta productividad bruta pero crea deuda tecnica masiva
   - Datos clave: 153M lineas analizadas, code churn duplicado, correlacion Pearson 0.98 entre adopcion Copilot y "mistake code", refactoring colapso de 25% a <10%

6. **No Silver Bullet: Essence and Accidents of Software Engineering** - Brooks (1986)
   - Archivo: source_docs/brooks-1986-summary.md
   - Paper: https://worrydream.com/refs/Brooks_1986_-_No_Silver_Bullet.pdf
   - Tesis: Complejidad esencial vs accidental. AI resuelve lo accidental, lo esencial requiere ingenieria humana
   - Conceptos clave: 4 problemas esenciales (complexity, conformity, changeability, invisibility)

7. **Prospects for an Engineering Discipline of Software** - Shaw (CMU, 1990)
   - Archivo: source_docs/shaw-parnas-classics-summary.md
   - Paper: https://www.sei.cmu.edu/library/prospects-for-an-engineering-discipline-of-software/
   - Tesis: Modelo de maduracion Craft -> Commercial -> Professional Engineering

8. **Software Engineering Programs Are Not Computer Science Programs** - Parnas (1999)
   - Archivo: source_docs/shaw-parnas-classics-summary.md
   - Paper: https://bioinfo.uib.es/~joemiro/semdoc/PlansEstudis/Bachelor_Masters_Curricula/DParnas.pdf
   - Tesis: SE es disciplina de ingenieria, no subarea de CS. Educacion cientifica != ingenieril

9. **Coding in the Red: The State of Global Technical Debt** - CAST Software (2025)
   - Archivo: source_docs/tech-debt-reports-summary.md
   - Reporte: https://www.castsoftware.com/ciu/coding-in-the-red-technical-debt-report-2025
   - Datos clave: 61 mil millones de dias de trabajo para remediar deuda tecnica global, 45% del codigo global es fragil

10. **Build Your Tech and Balance Your Debt** - Accenture (2024)
    - Archivo: source_docs/tech-debt-reports-summary.md
    - Reporte: https://www.accenture.com/us-en/insights/consulting/build-tech-balance-debt
    - Datos clave: USD 2.41 billones/ano costo de deuda tecnica en EE.UU., 41% de ejecutivos citan IA como top-3 contribuyente

### Por Investigar
- Stack Overflow Developer Survey (tendencias de adopcion de AI tools)
- GitHub Copilot estudios de productividad
- Papers sobre pair programming humano vs AI pair programming
- Estudios sobre code review de codigo AI-generated
- Reportes de empresas que adoptaron AI coding (early adopters)
- Ruiz de Mendarozqueta, Bustos & Colla (2021) - "Agile and software engineering, an invisible bond" (ASSE/SADIO)

## Relacion con Otros Proyectos del Ecosistema

| Proyecto | Relacion |
|----------|----------|
| `ai-futures-research` | Proyecto hermano mas amplio (impacto AI en actividad humana general) |
| `agent-token-economics` | Datos sobre costos de tokens y economia de agentes |
| `ai-dev-cost-model` | Modelos de costo de desarrollo con AI |
| `context-engineering` | Investigacion sobre context engineering (tecnica clave) |
| `llm-landscape` | Panorama de modelos LLM disponibles |

## Formato de Output

Documentos internos en Markdown. Estructura tentativa:
- Un documento por eje de investigacion
- Sintesis periodica integrando hallazgos
- Referencias bibliograficas en cada documento
