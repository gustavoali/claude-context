# Buenas Practicas de Desarrollo - Jerarquicos

**Fuente:** Presentacion "Buenas practicas de desarrollo" del equipo
**Aplica a:** Todos los proyectos de Jerarquicos (especialmente JS Mobile)
**Ultima actualizacion:** 2026-03-02

---

## Principio General

> "El codigo se escribe una vez, pero se lee cientos de veces"

Las buenas practicas aseguran:
- **Calidad:** Estandares ya probados
- **Mantenibilidad:** Uniformidad de productos
- **Aprendizaje:** Capacitacion de nuevos integrantes
- **Reduccion de bugs:** Protocolos ya validados
- **Trabajo en equipo**

---

## 1. Nombres Representativos

Los nombres de variables, metodos y clases deben ser descriptivos y reflejar claramente su proposito.

### Convenciones de Nomenclatura

| Elemento | Convencion | Ejemplo |
|----------|-----------|---------|
| Clases | PascalCase | `CalculateTotalPrecio` |
| Metodos | PascalCase, usar verbos | `FindTotal()` |
| Variables y parametros | camelCase, usar sustantivos | `totalFactura` |

### Reglas

- Evitar abreviaturas ambiguas y nombres genericos como `data`, `x`, `list`
- Evitar caracteres especiales: ñ, acentos
- Los nombres deben reflejar claramente el proposito

---

## 2. Uso de `var` vs Tipos Explicitos

- **Rendimiento:** No hay diferencias entre `var` y el tipo explicito
- **Usar `var`** cuando el tipo es obvio: `var cliente = new Cliente()`
- **Evitar `var`** en tipos numericos: preferir `int total = 0` sobre `var total = 0`

---

## 3. Orden de Metodos

Los metodos deben estar organizados:
1. **Primero:** Metodos publicos (orden alfabetico)
2. **Despues:** Metodos privados (orden alfabetico)

---

## 4. Parametros de Funciones

### Parametros de entrada
- Idealmente menos de 3 parametros
- Si requiere muchos parametros, refactorizar agrupando en un objeto

### Parametros de salida
- Una funcion deberia devolver un solo objeto/parametro

---

## 5. Complejidad Ciclomatica

Es una metrica que mide la cantidad de caminos independientes en el codigo.

- **Valor mayor a 10:** Codigo dificil de probar y mantener
- **Causa comun:** Funciones complejas sin division en metodos privados
- **Solucion:** Dividir en metodos mas pequenos que hagan una sola cosa y se puedan probar por separado

---

## 6. Comentarios

- **Regla general:** No debe haber comentarios dentro de la logica del codigo
- El codigo debe ser lo suficientemente claro para entender lo que hace
- **Si son necesarios:** Explicar el "por que", no el "que"

---

## 7. Creacion de PR

### Checklist pre-PR

- [ ] Control de archivos antes de asignarlo para revision
- [ ] No pasar mas de 15 archivos por PR
- [ ] Control de checks. Si no se puede tildar alguno, especificar el motivo
- [ ] Imagenes, videos, gifs o informacion extra que ayude a entender que se hizo, donde y por que
- [ ] Documentacion actualizada
- [ ] Unit tests creados y exitosos

---

## Resumen de Beneficios

| Practica | Beneficios |
|----------|-----------|
| Nombres representativos | Lectura, interpretacion, mantenibilidad |
| Parametros controlados | Lectura, interpretacion, mantenibilidad |
| Complejidad ciclomatica baja | Lectura, mantenibilidad, control de logica, testing, evitar codigo repetido |
| PR bien armados | Facilidad de correccion, deteccion temprana de errores |

---

## Documentos Relacionados

- [COMMIT_CONVENTION.md](COMMIT_CONVENTION.md) - Convencion de commits
- [API_ERROR_CODES.md](API_ERROR_CODES.md) - Catalogo de codigos de error de APIs
- [API_STANDARDS.md](API_STANDARDS.md) - Estandares y buenas practicas de APIs REST
