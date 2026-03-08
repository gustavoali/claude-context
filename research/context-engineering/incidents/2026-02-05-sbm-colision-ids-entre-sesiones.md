## Incidente: Colision de IDs de historias entre sesiones de trabajo
**Fecha:** 2026-02-05 (aprox, previo al inicio de SBM) | **Proyecto:** Multiples proyectos (pre-Sprint Backlog Manager)
**Tipo:** perdida_de_estado
**Severidad:** medio
**Detectado por:** Claude (referenciado como "problema historico" en LEARNINGS.md de SBM)

## Descripcion
Antes de la implementacion de Sprint Backlog Manager con PostgreSQL, los IDs de historias de usuario se gestionaban manualmente en archivos PRODUCT_BACKLOG.md. Cada sesion de Claude que necesitaba crear una historia consultaba el ID Registry del backlog para determinar el proximo ID disponible. Sin embargo, en sesiones concurrentes o cuando el contexto del backlog no se cargaba correctamente, se asignaban IDs duplicados a historias diferentes.

## Contexto perdido
- El ultimo ID asignado en una sesion anterior no siempre se reflejaba en el archivo cuando otra sesion empezaba
- En sesiones concurrentes (multiples agentes o worktrees), no habia mecanismo de locking
- El ID Registry podia estar desactualizado si la sesion anterior no habia commiteado sus cambios

## Impacto
- Conflictos al merge: dos historias con el mismo ID y diferente contenido
- Confusion al referenciar historias por ID ("LTE-015 se refiere a cual de las dos?")
- Tiempo de resolucion manual para renumerar y actualizar referencias
- Estimado: ~15-30 min por incidente de colision

## Causa raiz
1. El ID Registry era un archivo de texto plano sin mecanismo de atomicidad
2. No habia locking entre sesiones concurrentes
3. El estado del backlog podia estar desactualizado entre sesiones (no commiteado o no sincronizado)
4. La gestion manual de IDs secuenciales es inherentemente vulnerable a condiciones de carrera

## Mitigacion aplicada
- Sprint Backlog Manager implemento ID Registry en PostgreSQL con secuencias atomicas
- Cada proyecto tiene su propio contador secuencial por tipo de entidad
- La concurrencia se resuelve a nivel de base de datos (PostgreSQL sequences)

## Prevencion implementada
- Directiva 3 (obligatory-directives.md): "Todo cambio de codigo pasa por backlog primero"
- Agente `product-owner` debe "Leer backlog existente y verificar ID Registry" antes de asignar IDs
- SBM como fuente unica de verdad para IDs (cuando esta disponible)

## Leccion aprendida
La gestion de estado compartido (como IDs secuenciales) en archivos de texto es fragil cuando multiples sesiones pueden operar sobre el mismo recurso. La solucion es mover el estado compartido a un sistema con garantias de atomicidad (base de datos), o implementar protocolos estrictos de locking/checkout en el flujo de trabajo.
