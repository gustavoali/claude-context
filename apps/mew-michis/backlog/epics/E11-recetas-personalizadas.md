# Epic 11: Recetas Personalizadas (E11)

**Version:** v2.0
**Objetivo:** Permitir crear y compartir recetas personalizadas validadas.
**Valor de negocio:** Comunidad, lock-in positivo, potencial monetizacion.
**Story Points Total:** 34
**Status:** FUTURO (0 de 4 historias completadas)

---

## Historias

| ID | Titulo | Points | Priority | Status |
|----|--------|--------|----------|--------|
| MEW-037 | Modelo de recetas extendidas | 8 | Low | Pending |
| MEW-038 | Crear receta personalizada | 8 | Low | Pending |
| MEW-039 | Formato SER y exportacion de recetas | 8 | Low | Pending |
| MEW-040 | Importacion de recetas externas | 10 | Low | Pending |

---

## Dependencias entre Historias

```
MEW-037 (Modelo recetas extendidas)
  --> MEW-038 (Crear receta personalizada) [necesita modelo extendido]
  --> MEW-039 (Formato SER) [necesita modelo para serializar]
      --> MEW-040 (Importacion) [necesita formato SER definido]

Cadena de dependencias estricta:
  MEW-037 -> MEW-038 (paralelo con MEW-039)
  MEW-037 -> MEW-039 -> MEW-040

MEW-037 es prerequisito para todas las demas.
MEW-038 y MEW-039 pueden ser paralelos despues de MEW-037.
MEW-040 depende de MEW-039 (necesita formato SER).
```

---

## Dependencias con Otros Epics

- **E2 (Catalogo):** MEW-037 extiende el modelo de Recipe de E2
- **E3 (Motor Nutricional):** Recetas extendidas deben pasar por validacion nutricional
- **E4 (Menu Semanal):** MEW-038 recetas custom usables en menu
- **E12 (Validacion):** El motor de validacion debe soportar recetas extendidas
- **Prerrequisitos:** Se recomienda completar E8, E9, E10 antes de iniciar E11

---

## Detalle de Historias

### MEW-037: Modelo de recetas extendidas
**Story Points:** 8 | **Priority:** Low | **Status:** Pending | **DoR Level:** 2

**As a** desarrollador
**I want** un modelo de datos que soporte recetas personalizadas
**So that** los usuarios puedan crear variaciones seguras de las recetas base

**AC1:** Entidad ExtendedRecipe con id, base_recipe_id, name, author, modifications[], type
**AC2:** Modificaciones controladas (cambio proteina, ajuste porcentajes, sustituciones)
**AC3:** Validacion obligatoria via motor nutricional
**AC4:** Diferenciacion visual custom vs official

**Technical Notes:**
- Tabla: extended_recipes (id, base_recipe_id, name, author, type, created_at)
- Tabla: recipe_modifications (recipe_id, modification_type, value)
- Validacion via ValidationService existente

---

### MEW-038: Crear receta personalizada
**Story Points:** 8 | **Priority:** Low | **Status:** Pending | **DoR Level:** 2

**As a** cuidador de gatos
**I want** crear mi propia receta basada en una receta oficial
**So that** pueda adaptarla a mis necesidades manteniendo la seguridad

**AC1:** Iniciar desde receta base con "Crear variacion"
**AC2:** Modificar ingredientes con validacion en tiempo real
**AC3:** Guardar como receta custom con badge correspondiente
**AC4:** Usar en menu igual que recetas oficiales

**Technical Notes:** Editor basado en RecipeDetailScreen. Validacion en tiempo real. Guardar como ExtendedRecipe.

---

### MEW-039: Formato SER y exportacion de recetas
**Story Points:** 8 | **Priority:** Low | **Status:** Pending | **DoR Level:** 2

**As a** usuario de Mew Michis
**I want** exportar mis recetas en formato estandar
**So that** pueda compartirlas o hacer backup

**AC1:** Formato SER definido (JSON versionado con metadata, ingredientes, suplementos, reglas)
**AC2:** Exportar receta individual como .ser.json
**AC3:** Exportar menu completo con 7 recetas y variaciones
**AC4:** Metadata de exportacion (fecha, version motor, autor, tipo)

**Technical Notes:** JSON con schema definido. Version del formato. file_picker para guardar.

---

### MEW-040: Importacion de recetas externas
**Story Points:** 10 | **Priority:** Low | **Status:** Pending | **DoR Level:** 2

**As a** usuario de Mew Michis
**I want** importar recetas creadas por otros
**So that** pueda usar recetas compartidas por la comunidad

**AC1:** Importar archivo .ser.json
**AC2:** Validacion: formato correcto, reglas nutricionales, version compatible
**AC3:** Resultado: aceptada, aceptada con ajustes, o rechazada con explicacion
**AC4:** Receta importada en catalogo con badge "importada"
**AC5:** Rechazo con explicacion y sugerencia de correccion

**Technical Notes:** Parsear JSON con validacion de schema. Validar contra reglas nutricionales. Ajustes automaticos menores.

---

## Packages Nuevos Requeridos

| Package | Uso | Historias |
|---------|-----|-----------|
| `file_picker` | Importar/exportar archivos .ser.json | MEW-039, MEW-040 |

---

## Migraciones de Base de Datos

| Version | Tabla | Descripcion | Historia |
|---------|-------|-------------|----------|
| v2.0 | extended_recipes | Recetas personalizadas | MEW-037 |
| v2.0 | recipe_modifications | Modificaciones sobre receta base | MEW-037 |

---

## Priorizacion MoSCoW (dentro del epic)

- **Won't Have (this release):** Todas - planificado para v2.0+
- El epic completo esta en el horizonte futuro

---

## Riesgos

| Riesgo | Probabilidad | Impacto | Mitigacion |
|--------|-------------|---------|------------|
| Recetas custom inseguras nutricionalmente | Alta | Critico | Validacion obligatoria estricta |
| Formato SER incompatible entre versiones | Media | Alto | Versionado desde el inicio |
| Importacion de recetas maliciosas/corruptas | Media | Alto | Validacion completa + sandbox |
| Complejidad de UI del editor de recetas | Alta | Medio | Basarse en RecipeDetailScreen existente |

---

## Orden de Implementacion (estricto)

1. MEW-037 (Modelo extendido) - prerequisito obligatorio
2. MEW-038 (Crear receta) + MEW-039 (Formato SER) - en paralelo
3. MEW-040 (Importacion) - ultimo, depende de formato SER

**Estimacion total:** 8-10 semanas
