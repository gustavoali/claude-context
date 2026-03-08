## Incidente: Duplicacion de archivos main_*.py por contexto fragmentado entre sesiones
**Fecha:** 2025-09-20 (aprox) | **Proyecto:** YouTube RAG
**Tipo:** duplicacion_de_trabajo
**Severidad:** alto
**Detectado por:** Claude (durante revision de codigo)

## Descripcion
Durante el desarrollo del proyecto YouTube RAG, se crearon multiples versiones del archivo de entrada principal de la aplicacion:
- `main.py` - Version principal de produccion
- `main_test.py` - Version de prueba con endpoints simplificados
- `main_real.py` - Version con procesamiento real de video
- `main_simple.py` - Version simplificada

Cada version fue creada en sesiones diferentes, donde la sesion nueva no tenia contexto suficiente sobre las decisiones de la sesion anterior, o no sabia que ya existia una version funcional. En lugar de parametrizar el comportamiento existente, se creo un archivo nuevo cada vez.

## Contexto perdido
- Decisiones de diserio sobre por que el main.py original estaba estructurado de cierta forma
- Que funcionalidad era mock vs real en cada version
- Cual era la version "oficial" que debia usarse en cada entorno
- La intencion original de cada variante

## Impacto
- Cambios aplicados al archivo incorrecto (bugs por confusion)
- Mantenimiento complejo: correcciones debian replicarse en multiples archivos
- Inconsistencias: diferentes comportamientos entre "versiones"
- Debugging dificil: no habia claridad sobre que codigo se ejecutaba realmente
- Se requirio una sesion dedicada de limpieza y consolidacion (~2-3 horas)

## Causa raiz
1. No existia un mecanismo de persistencia de decisiones de diserio entre sesiones
2. Cada sesion nueva operaba sin conocimiento del estado previo del proyecto
3. No habia una convencion de "un solo punto de entrada" documentada
4. La falta de contexto sobre el "por que" de cada archivo llevo a crear nuevos en lugar de modificar los existentes

## Mitigacion aplicada
- Limpieza completa: 3 archivos duplicados criticos eliminados
- 3 versiones de video_crud_client consolidadas a 1
- Scripts organizados en directorios tematicos
- Creacion de `DEVELOPMENT_GUIDELINES.md` con la regla "NO DUPLICACION DE FUNCIONES"
- Implementacion de patron de entornos por configuracion (variables de entorno en lugar de archivos separados)

## Prevencion implementada
- Directriz obligatoria: "UN SOLO archivo main.py que maneje todos los entornos mediante configuracion"
- Checklist pre-creacion: "Puede resolverse con variable de configuracion?" antes de crear archivos nuevos
- `CODE_CLEANUP_SUMMARY.md` documentando la limpieza como referencia

## Leccion aprendida
La duplicacion de archivos es un sintoma clasico de perdida de contexto entre sesiones. Cuando una nueva sesion no sabe que decisiones se tomaron antes ni por que, el camino de menor resistencia es crear algo nuevo en lugar de modificar lo existente. La solucion no es solo limpiar la duplicacion, sino persistir las decisiones de diserio para que la siguiente sesion las conozca.
