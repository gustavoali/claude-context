# Incidente: Sugerencias de herramientas MCP perdidas por interrupcion de sesion

## Metadata
**Fecha:** 2026-02-25 | **Proyecto:** Gaia Protocol + Unity MCP Server
**Tipo:** perdida_de_sugerencia
**Severidad:** Alto
**Detectado por:** Usuario (al retomar sesion siguiente)

## Descripcion
Durante una sesion de desarrollo de Gaia Protocol (implementacion de GP-022/027/030/031 - historias Unity), se discutieron sugerencias sobre herramientas adicionales necesarias en el Unity MCP Server para automatizar el ensamblaje de escenas (GP-032). La sesion fue interrumpida por limite de contexto.

## Contexto perdido
- Lista especifica de herramientas MCP sugeridas para el proyecto UMS
- Razonamiento detras de cada sugerencia
- Prioridad relativa entre las herramientas
- Posible planificacion o backlog propuesto

## Impacto
- ~30 min de re-analisis para reconstruir las sugerencias desde cero
- Las sugerencias originales pudieron haber tenido matices que se perdieron
- El usuario tuvo que preguntar explicitamente "habia planificacion respecto de ellas" sin poder obtener respuesta

## Causa raiz
1. Las sugerencias quedaron solo en el contexto de la conversacion (no escritas a archivo)
2. No existia una directiva que obligara a persistir sugerencias inmediatamente
3. El TASK_STATE no tenia seccion de "Sugerencias Pendientes"
4. La sesion se interrumpio antes del cierre formal (no hubo oportunidad de checkpoint)

## Mitigacion aplicada
- Se re-analizaron los gaps del UMS desde cero usando un agente Explore
- Se creo TOOLS_SPEC_EPIC006.md con 6 nuevas historias (UMS-026 a UMS-031)
- Se actualizo el PRODUCT_BACKLOG del UMS

## Prevencion implementada
- Directiva 12b: Documentar sugerencias y decisiones inmediatamente
- Directiva 12c: Checkpoints de estado en el flujo de trabajo
- Directiva 12d: Observacion continua de resiliencia de contexto
- Seccion "Sugerencias Pendientes" en TASK_STATE

## Leccion aprendida
Las sugerencias son el tipo de contexto MAS vulnerable porque:
1. No son "trabajo en curso" (no hay codigo que commitear)
2. No son errores (no hay stack trace que copiar)
3. Son efimeras por naturaleza (surgen en la conversacion y se olvidan)
4. Su valor solo se reconoce cuando se necesitan (despues de perderse)

La unica defensa es **escribirlas inmediatamente**, no cuando sean "formales" o "completas".
