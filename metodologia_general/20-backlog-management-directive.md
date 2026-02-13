# Gestion de Backlog con Agente Product Owner - Directiva Obligatoria

**Version:** 1.0
**Fecha:** 2026-01-23
**Estado:** OBLIGATORIO - Aplica a TODOS los proyectos

---

## Proposito

Garantizar consistencia en la gestion del backlog de productos, evitando:
- Colisiones de IDs de historias entre sesiones
- Historias mal definidas sin acceptance criteria claros
- Duplicacion de trabajo por falta de visibilidad del backlog existente

---

## Directiva Principal

**Claude DEBE delegar al agente `product-owner` cualquier operacion de creacion o modificacion de historias en el backlog.**

---

## Cuando Aplicar Esta Directiva

Delegar al agente `product-owner` cuando:
- El usuario solicita crear una nueva historia/feature
- El usuario quiere modificar una historia existente
- Se necesita priorizar el backlog
- Se requiere definir acceptance criteria
- Se va a asignar un nuevo ID de historia

---

## Proceso Obligatorio

### Paso 1: Verificar ID Registry

Antes de crear cualquier historia nueva, el agente `product-owner` debe:

1. Leer el archivo de backlog del proyecto (tipicamente `PRODUCT_BACKLOG.md`)
2. Localizar la seccion "ID Registry" o equivalente
3. Verificar el ultimo ID asignado
4. Asignar el siguiente ID disponible

### Paso 2: Definir Historia con Formato Correcto

Toda historia debe incluir:

```markdown
### [ID]: [Titulo descriptivo]
**Story Points:** [1/2/3/5/8/13]
**Priority:** [Critical/High/Medium/Low]
**Status:** [Pending/In Progress/Done]

**As a** [tipo de usuario]
**I want** [objetivo]
**So that** [beneficio]

**Acceptance Criteria:**
- AC1: Given [contexto], When [accion], Then [resultado]
- AC2: ...

**Technical Notes:**
[Notas tecnicas relevantes]
```

### Paso 3: Actualizar ID Registry

Despues de crear la historia, actualizar el ID Registry:

```markdown
## ID Registry

| ID | Descripcion | Status |
|----|-------------|--------|
| XXX-001 | Historia anterior | Done |
| XXX-002 | Nueva historia | Pending |  <-- Nueva entrada

**Proximo ID disponible:** XXX-003
```

---

## Formato del ID Registry

Cada proyecto con backlog debe mantener un ID Registry con:

```markdown
## ID Registry (Evitar Colisiones)

| ID | Descripcion | Status |
|----|-------------|--------|
| [PREFIX]-001 | [Descripcion corta] | [Pending/In Progress/Done] |
| [PREFIX]-002 | [Descripcion corta] | [Pending/In Progress/Done] |
...

**Proximo ID disponible:** [PREFIX]-[N+1]
```

El prefijo (PREFIX) debe ser consistente para cada proyecto:
- Ejemplo: LTE (LinkedIn Transcript Extractor)
- Ejemplo: YRUS (YouTube RAG User Stories)
- Ejemplo: API (ApiJsMobile)

---

## Responsabilidades

### Claude (Coordinador):
- Identificar cuando se necesita gestion de backlog
- Delegar al agente `product-owner`
- NO crear historias directamente

### Agente `product-owner`:
- Verificar ID Registry antes de crear historias
- Definir historias con formato completo
- Actualizar ID Registry despues de crear
- Priorizar backlog segun valor de negocio
- Comunicar con el usuario sobre decisiones de producto

### Usuario (Product Owner Real):
- Aprobar o rechazar historias propuestas
- Tomar decisiones de priorizacion final
- Validar acceptance criteria

---

## Ejemplo de Delegacion

```
Usuario: "Necesito agregar una feature para exportar transcripts a PDF"

Claude: "Voy a delegar esto al agente product-owner para crear la historia correctamente."

[Claude usa Task tool con product-owner agent]

Prompt al agente:
"El usuario solicita una feature para exportar transcripts a PDF.
1. Lee PRODUCT_BACKLOG.md y verifica el ID Registry
2. Asigna el proximo ID disponible
3. Define la user story con acceptance criteria
4. Actualiza el ID Registry
5. Presenta la historia al usuario para aprobacion"
```

---

## Excepciones

La unica excepcion es cuando:
- El proyecto NO tiene backlog formal (proyecto muy pequeno)
- El usuario explicitamente pide NO usar el proceso formal

En estos casos, documentar la excepcion.

---

## Relacion con Otras Directivas

### Con 18-claude-coordinator-role.md:
- Esta directiva es una especializacion del rol de coordinador
- Refuerza que Claude no ejecuta, sino que delega

### Con 19-task-state-persistence.md:
- El backlog complementa el estado de tareas
- TASK_STATE.md es para trabajo en curso
- PRODUCT_BACKLOG.md es para trabajo futuro

---

## Beneficios

1. **Consistencia:** Todas las historias tienen el mismo formato
2. **Trazabilidad:** IDs unicos permiten seguimiento
3. **Sin colisiones:** ID Registry previene duplicados entre sesiones
4. **Calidad:** Acceptance criteria claros desde el inicio
5. **Visibilidad:** Backlog centralizado y actualizado

---

## Checklist de Verificacion

Antes de considerar una historia como "ready":

- [ ] ID unico asignado y registrado
- [ ] Formato user story correcto (As a/I want/So that)
- [ ] Minimo 2 acceptance criteria en formato Given/When/Then
- [ ] Story points estimados
- [ ] Priority asignada
- [ ] ID Registry actualizado con nueva entrada

---

**Esta directiva es OBLIGATORIA para todo proyecto con backlog formal.**
**Claude debe delegar al agente `product-owner` proactivamente.**
