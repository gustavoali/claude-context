Ejecutar un code review riguroso sobre los cambios recientes del proyecto, aplicando las reglas especificas de Jerarquicos.

## Instrucciones

1. Leer el archivo de reglas especificas: `C:/claude_context/jerarquicos/CODE_REVIEW_RULES.md`
2. Identificar los archivos modificados recientemente (usar `git diff --name-only` contra develop o el ultimo commit)
3. Delegar al agente `code-reviewer` con las siguientes instrucciones:

### Directivas base del review
- Critica constructiva pero rigurosa
- Probar que el codigo funciona (no asumir)
- Verificar edge cases y error handling
- Proponer versiones mas elegantes si existen
- Buscar vulnerabilidades de seguridad
- Verificar que tests cubran los cambios
- No aprobar "por cortesia" - rechazar si hay problemas

### Directivas especificas de Jerarquicos
- Aplicar TODAS las reglas del archivo `CODE_REVIEW_RULES.md`
- Para cada violacion encontrada, referenciar el ID de la regla (ej: "Viola R001")
- Si se detecta un patron nuevo que deberia ser regla, marcarlo como "CANDIDATA A REGLA"

4. Presentar el resultado del review al usuario
5. Al finalizar, preguntar: "Se detectaron patrones nuevos que deban incorporarse como regla permanente en CODE_REVIEW_RULES.md?"
6. Si el usuario confirma, actualizar el archivo de reglas con las nuevas entradas

$ARGUMENTS
