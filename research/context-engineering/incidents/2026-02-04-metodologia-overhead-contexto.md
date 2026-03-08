## Incidente: Sobrecarga de contexto por ~15 @imports en User Memory
**Fecha:** 2026-02-04 (aprox, durante migracion a v3) | **Proyecto:** Metodologia General
**Tipo:** otro (degradacion_de_contexto)
**Severidad:** medio
**Detectado por:** Claude (registrado en CONTINUOUS_IMPROVEMENT.md como tarea pendiente)

## Descripcion
La Metodologia General evoluciono de v1 a v2 a v3 a lo largo de multiples meses. Cada vez que se detectaba un problema o un incidente, se creaba un nuevo documento o directiva. El User Memory (`~/.claude/CLAUDE.md`) acumulo ~15 @imports a documentos de metodologia que se cargaban en CADA sesion de CADA proyecto.

El documento CONTINUOUS_IMPROVEMENT.md registra esto como tarea pendiente: "Se identifico que hay ~15 @imports en User Memory. Propuesta: Crear resumen compacto que reduzca carga de contexto."

Adicionalmente, se identifico que existian dos carpetas paralelas (`methodology/` y `metodologia_general/`) que parecian ser duplicados o versiones anteriores, lo cual agravaba la confusion.

## Contexto perdido (o degradado)
- No se "perdio" contexto en el sentido clasico, sino que el exceso de contexto diluia la atencion
- Con 15+ documentos cargados, las directivas especificas podian pasar desapercibidas
- El contexto util para una tarea puntual se mezclaba con contexto irrelevante para esa tarea
- Las sesiones consumian parte significativa de la ventana de contexto solo en metodologia

## Impacto
- Mayor consumo de la ventana de contexto antes de empezar a trabajar
- Posible ignorancia selectiva: con tanto contexto, algunas directivas podian no aplicarse consistentemente
- Confusion entre documentos de metodologia v2 (en `methodology/`) y v3 (en `metodologia_general/`)
- Overhead de mantenimiento: actualizar directivas requeria tocar multiples archivos

## Causa raiz
1. Crecimiento organico: cada incidente generaba un nuevo documento sin consolidar los existentes
2. No habia politica de compactacion o consolidacion periodica
3. Los documentos se creaban reactivamente (despues de un incidente) sin evaluar el costo de contexto adicional
4. La estructura de archivos no se reorganizaba al crecer

## Mitigacion aplicada
- Migracion de v2 a v3 de la metodologia: consolidacion de ~15 documentos en 6 archivos core
- Documentos v2 movidos a `metodologia_general_backup_pre_v3/`
- Creacion de `07-project-memory-management.md` con limites de tamanio por archivo
- Limites explicitos: CLAUDE.md max 150 lineas, TASK_STATE max 200, BACKLOG max 300, ARCHITECTURE max 400

## Prevencion implementada
- Limites de tamanio documentados y monitoreados (directiva 7)
- Politica de limpieza: "Si esta en contexto activo, debe ser util AHORA"
- Sistema de archivado: informacion historica se mueve a `archive/` fuera del contexto activo
- Claude ejecuta limpieza automaticamente cuando detecta exceso
- Carga bajo demanda de `05-advanced-practices.md` (solo para proyectos medium+)

## Leccion aprendida
El contexto tiene un costo: cada linea que se carga en la ventana ocupa espacio que podria usarse para el trabajo real. La acumulacion incremental de directivas y documentos es insidiosa porque cada adicion individual es "pequeña", pero el efecto acumulado puede degradar significativamente la eficiencia.

La solucion no es dejar de documentar, sino tener una politica activa de compactacion, archivado y carga selectiva. El contexto ideal es el MINIMO necesario para la tarea actual, no todo lo que se ha aprendido historicamente.
