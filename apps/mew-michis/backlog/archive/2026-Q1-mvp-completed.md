# Historias Completadas - Q1 2026 (MVP + v1.1 parcial)

**Archivado:** 2026-02-05
**Total:** 20 historias, 81 story points
**Periodo:** 2026-01-26 a 2026-02-05
**Versiones:** MVP (E1-E6) + v1.1 parcial (E8)

---

## Resumen por Epic

| Epic | Historias | Story Points | Status |
|------|-----------|--------------|--------|
| E1: Perfil Nutricional | MEW-001, 002, 003 | 10 | Done |
| E2: Catalogo Recetas | MEW-004, 005, 006, 007 | 16 | Done |
| E3: Motor Nutricional | MEW-008, 009, 010 | 13 | Done |
| E4: Menu Semanal | MEW-011, 012, 013 | 13 | Done |
| E5: Lista Compras | MEW-014, 015 | 8 | Done |
| E6: Presupuesto | MEW-016, 017 | 8 | Done |
| E8: UX y Explicabilidad | MEW-019, 020, 021 | 11 | Parcial |
| **Total** | **20 historias** | **81 pts** | |

---

## Epic 1: Perfil Nutricional

---

### MEW-001: Configurar perfil nutricional basico
**Story Points:** 3
**Priority:** Critical
**Status:** Done
**DoR Level:** 1

**As a** cuidador de gatos
**I want** ingresar el peso total de mis gatos, cantidad de gatos, temporada y nivel de actividad
**So that** el sistema pueda calcular las necesidades alimentarias correctas

**Acceptance Criteria:**

**AC1: Ingreso de peso total**
- Given que estoy en la pantalla de perfil nutricional
- When ingreso un peso total valido (ej: 12.5 kg)
- Then el sistema guarda el valor y lo muestra en el perfil
- And el peso debe ser mayor a 0 y menor a 100 kg

**AC2: Configuracion de temporada**
- Given que estoy configurando el perfil
- When selecciono una temporada (verano/invierno)
- Then el sistema registra la temporada para ajustes de aceite
- And muestra indicador visual de la temporada activa

**AC3: Configuracion de nivel de actividad**
- Given que estoy configurando el perfil
- When selecciono nivel de actividad (bajo/normal/alto)
- Then el sistema registra el nivel para ajustes de cantidad
- And muestra el nivel seleccionado

**AC4: Numero de gatos opcional**
- Given que estoy configurando el perfil
- When ingreso el numero de gatos (opcional, default 1)
- Then el sistema lo registra para referencia
- And permite dejarlo vacio usando default

**Technical Notes:**
- Campos: peso_total (decimal), num_gatos (int, nullable), temporada (enum), actividad (enum)
- Validacion en frontend antes de guardar
- UI con inputs numericos y selectores

**Definition of Done:**
- [x] UI de perfil implementada
- [x] Validaciones funcionando
- [x] Unit tests para validaciones
- [x] Widget tests para formulario

---

### MEW-002: Calcular necesidades diarias y semanales
**Story Points:** 5
**Priority:** Critical
**Status:** Done
**DoR Level:** 2

**As a** cuidador de gatos
**I want** ver automaticamente cuanta comida necesitan mis gatos por dia y por semana
**So that** pueda planificar las cantidades correctas

**Acceptance Criteria:**

**AC1: Calculo de gramos diarios base**
- Given que tengo un perfil con peso total de 10 kg
- When el sistema calcula las necesidades
- Then muestra gramos diarios base (formula: peso * factor_actividad * 30-40g)
- And el calculo considera el nivel de actividad

**AC2: Calculo semanal**
- Given que tengo calculados los gramos diarios (ej: 350g/dia)
- When visualizo el resumen nutricional
- Then muestra gramos semanales (diario * 7 = 2450g)
- And muestra equivalente en kg para facilitar comprension

**AC3: Ajuste por temporada**
- Given que la temporada es invierno
- When el sistema calcula necesidades
- Then aplica factor de ajuste (+10% en invierno)
- And muestra nota explicativa del ajuste

**AC4: Actualizacion automatica**
- Given que cambio el peso total en el perfil
- When guardo los cambios
- Then los calculos se actualizan automaticamente
- And todas las vistas dependientes reflejan el nuevo calculo

**Technical Notes:**
- Formula base: peso_kg * 35g (normal), * 30g (bajo), * 40g (alto)
- Ajuste invierno: +10%
- Recalculo reactivo en cambios de perfil

**Definition of Done:**
- [x] Logica de calculo implementada
- [x] Unit tests para todas las formulas
- [x] UI muestra calculos en tiempo real
- [x] Tests de integracion perfil-calculos

---

### MEW-003: Persistir perfil en SQLite
**Story Points:** 2
**Priority:** Critical
**Status:** Done
**DoR Level:** 1

**As a** cuidador de gatos
**I want** que mi perfil se guarde localmente
**So that** no tenga que ingresarlo cada vez que abro la app

**Acceptance Criteria:**

**AC1: Guardado automatico**
- Given que complete mi perfil nutricional
- When presiono guardar o salgo de la pantalla
- Then los datos se persisten en SQLite
- And no se pierde informacion

**AC2: Carga al iniciar**
- Given que tengo un perfil guardado
- When abro la aplicacion
- Then el perfil se carga automaticamente
- And veo mis datos configurados

**AC3: Funcionamiento offline**
- Given que no tengo conexion a internet
- When guardo o cargo mi perfil
- Then funciona correctamente con SQLite local
- And no muestra errores de conexion

**Technical Notes:**
- Tabla: perfil_nutricional (id, peso_total, num_gatos, temporada, actividad, created_at, updated_at)
- Single record pattern (solo un perfil activo)
- sqflite package para Flutter

**Definition of Done:**
- [x] Schema SQLite creado
- [x] Repository implementado
- [x] CRUD funcionando
- [x] Tests de persistencia

---

## Epic 2: Catalogo de Recetas

---

### MEW-004: Definir modelo de datos de recetas base
**Story Points:** 3
**Priority:** Critical
**Status:** Done
**DoR Level:** 2

**As a** desarrollador
**I want** tener un modelo de datos robusto para las recetas
**So that** pueda representar todas las recetas A-F con sus ingredientes y reglas

**Acceptance Criteria:**

**AC1: Estructura de receta**
- Given que defino el modelo de Receta
- When incluyo todos los campos necesarios
- Then contiene: id, nombre, ingredientes[], suplementos[], restricciones, variaciones_permitidas
- And cada ingrediente tiene: tipo, cantidad_base, es_reemplazable, alternativas[]

**AC2: Representacion de restricciones**
- Given que una receta tiene restricciones (ej: max 2x/semana pescado)
- When modelo la restriccion
- Then puedo expresar: tipo_restriccion, limite, periodo, ingrediente_afectado
- And el motor puede evaluar la restriccion

**AC3: Variaciones de proteinas**
- Given que defino variaciones permitidas
- When modelo una variacion
- Then incluye: proteina_base, proteina_reemplazo, porcentaje_maximo, ajuste_aceite
- And puedo validar si una variacion es permitida

**Technical Notes:**
- Entidades: Recipe, Ingredient, Supplement, Restriction, ProteinVariation
- Relaciones: Recipe 1->N Ingredient, Recipe 1->N Restriction
- Datos inmutables (seed data, no CRUD de usuario)

**Definition of Done:**
- [x] Entidades de dominio creadas
- [x] Schema SQLite para recetas
- [x] Unit tests para modelos
- [x] Documentacion de estructura

---

### MEW-005: Cargar recetas A-F predefinidas
**Story Points:** 5
**Priority:** Critical
**Status:** Done
**DoR Level:** 2

**As a** cuidador de gatos
**I want** tener acceso a las 6 recetas base predefinidas
**So that** pueda usarlas para planificar la alimentacion

**Acceptance Criteria:**

**AC1: Seed de recetas al instalar**
- Given que instalo la app por primera vez
- When se inicializa la base de datos
- Then las 6 recetas (A-F) se cargan automaticamente
- And incluyen todos sus ingredientes y restricciones

**AC2: Recetas inmutables**
- Given que visualizo una receta
- When intento editarla
- Then no hay opcion de edicion disponible
- And solo puedo ver los detalles

**AC3: Contenido de cada receta**
- Given que cargo la receta A (ejemplo)
- When verifico su contenido
- Then incluye: proteina principal, vegetales, suplementos (taurina, calcio), cantidades base por kg
- And las cantidades estan normalizadas para 1kg de gato

**AC4: Lista de recetas disponibles**
- Given que entro al catalogo de recetas
- When se muestra la lista
- Then veo las 6 recetas con nombre e ingrediente principal
- And puedo navegar a cada una

**Technical Notes:**
- Datos hardcoded en JSON o Dart constants
- Seed ejecuta en primera migracion
- Version de datos para futuras actualizaciones

**Definition of Done:**
- [x] JSON/Constants con 6 recetas completas
- [x] Seed data funcional
- [x] Lista de recetas en UI
- [x] Tests de carga de datos

---

### MEW-006: Visualizar detalle de receta
**Story Points:** 3
**Priority:** High
**Status:** Done
**DoR Level:** 1

**As a** cuidador de gatos
**I want** ver el detalle completo de cada receta
**So that** entienda que ingredientes necesito y sus cantidades

**Acceptance Criteria:**

**AC1: Vista de ingredientes**
- Given que selecciono la receta B
- When se abre el detalle
- Then veo lista de ingredientes con cantidades base (por kg de gato)
- And cada ingrediente muestra: nombre, cantidad, unidad

**AC2: Suplementos obligatorios**
- Given que veo el detalle de una receta
- When reviso la seccion de suplementos
- Then veo taurina y calcio como obligatorios
- And muestra las cantidades requeridas

**AC3: Restricciones visibles**
- Given que la receta tiene higado
- When veo el detalle
- Then muestra advertencia: "Maximo 2 veces por semana"
- And el icono/color indica restriccion

**AC4: Variaciones permitidas**
- Given que la receta permite variaciones
- When veo la seccion de variaciones
- Then lista las proteinas alternativas con porcentajes maximos
- And indica si requiere ajuste de aceite

**Technical Notes:**
- Pantalla de detalle con secciones colapsables
- Iconos para restricciones y advertencias
- Scroll si hay mucho contenido

**Definition of Done:**
- [x] UI de detalle implementada
- [x] Secciones de ingredientes, suplementos, restricciones, variaciones
- [x] Widget tests
- [x] Navegacion desde lista

---

### MEW-007: Aplicar variaciones de proteinas
**Story Points:** 5
**Priority:** High
**Status:** Done
**DoR Level:** 2

**As a** cuidador de gatos
**I want** poder aplicar variaciones permitidas a una receta
**So that** pueda adaptar la receta a los ingredientes disponibles

**Acceptance Criteria:**

**AC1: Seleccionar variacion**
- Given que estoy en el detalle de una receta con variaciones permitidas
- When selecciono "Aplicar variacion"
- Then veo las opciones disponibles (vaca, cerdo, corazon, merluza, cornalito)
- And cada opcion muestra el porcentaje maximo permitido

**AC2: Configurar porcentaje de reemplazo**
- Given que selecciono reemplazar con cerdo
- When configuro el porcentaje (ej: 30%)
- Then el sistema valida que no exceda el maximo permitido
- And muestra error si excede el limite

**AC3: Ajuste automatico de aceite**
- Given que aplico variacion con cerdo (graso)
- When confirmo la variacion
- Then el sistema reduce automaticamente el aceite de la receta
- And muestra nota explicando el ajuste

**AC4: Vista previa de receta modificada**
- Given que configure una variacion valida
- When veo la vista previa
- Then muestra la receta con ingredientes ajustados
- And diferencia visualmente los cambios vs original

**Technical Notes:**
- Reglas: cerdo max 50%, merluza/cornalito max 30%, corazon max 25%
- Ajuste aceite: -50% si cerdo >25%, -100% si pescado graso
- Variacion se guarda asociada a slot de menu, no modifica receta base

**Definition of Done:**
- [x] UI de selector de variaciones
- [x] Logica de validacion de limites
- [x] Logica de ajuste de aceite
- [x] Tests de reglas de negocio

---

## Epic 3: Motor Nutricional

---

### MEW-008: Escalar receta por peso de gatos
**Story Points:** 5
**Priority:** Critical
**Status:** Done
**DoR Level:** 2

**As a** cuidador de gatos
**I want** que las cantidades de ingredientes se escalen segun el peso de mis gatos
**So that** prepare la cantidad correcta de comida

**Acceptance Criteria:**

**AC1: Escalado lineal de ingredientes**
- Given que tengo perfil con 8 kg de gatos
- And una receta con 100g de carne por kg
- When escalo la receta
- Then muestra 800g de carne (100g * 8)
- And todos los ingredientes escalan proporcionalmente

**AC2: Escalado de suplementos**
- Given que tengo 8 kg de gatos
- And taurina es 250mg por kg
- When escalo la receta
- Then muestra 2000mg (2g) de taurina
- And el calcio tambien escala

**AC3: Redondeo practico**
- Given que el calculo da 847.3g de carne
- When se muestra el resultado
- Then redondea a 850g (multiplos de 5 o 10 para practicidad)
- And mantiene precision en suplementos

**AC4: Recalculo reactivo**
- Given que cambio el peso en el perfil
- When vuelvo a ver una receta
- Then las cantidades estan actualizadas
- And no necesito refrescar manualmente

**Technical Notes:**
- Factor de escala = peso_total / 1kg (las recetas base son por kg)
- Redondeo: ingredientes a 5g, suplementos a 10mg
- Cache de calculos si es necesario por performance

**Definition of Done:**
- [x] Servicio de escalado implementado
- [x] Unit tests con multiples escenarios
- [x] Integracion con vista de recetas
- [x] Tests de redondeo

---

### MEW-009: Calcular suplementos obligatorios
**Story Points:** 3
**Priority:** Critical
**Status:** Done
**DoR Level:** 2

**As a** cuidador de gatos
**I want** que el sistema calcule automaticamente los suplementos obligatorios
**So that** la dieta sea nutricionalmente completa

**Acceptance Criteria:**

**AC1: Taurina siempre incluida**
- Given que visualizo cualquier receta escalada
- When reviso los suplementos
- Then la taurina aparece con cantidad calculada
- And muestra nota: "Obligatorio - esencial para gatos"

**AC2: Calcio siempre incluido**
- Given que visualizo cualquier receta escalada
- When reviso los suplementos
- Then el calcio aparece con cantidad calculada
- And muestra forma recomendada (carbonato de calcio o hueso molido)

**AC3: Advertencia si falta suplemento**
- Given que genero una lista de compras
- When no incluye taurina o calcio
- Then el sistema muestra advertencia critica
- And no permite finalizar sin confirmar

**AC4: Cantidades por kg**
- Given que calculo suplementos para 5 kg de gatos
- When verifico las cantidades
- Then taurina = 250mg * 5 = 1250mg
- And calcio = cantidad segun formula de la receta

**Technical Notes:**
- Taurina: 250mg/kg/dia (minimo)
- Calcio: varia segun receta, tipicamente 1g/kg
- Destacar visualmente en UI

**Definition of Done:**
- [x] Logica de calculo de suplementos
- [x] Advertencias implementadas
- [x] Unit tests
- [x] UI con seccion de suplementos destacada

---

### MEW-010: Aplicar ajustes estacionales
**Story Points:** 5
**Priority:** High
**Status:** Done
**DoR Level:** 2

**As a** cuidador de gatos
**I want** que el sistema ajuste automaticamente las cantidades segun la temporada
**So that** mis gatos reciban la nutricion adecuada en cada epoca

**Acceptance Criteria:**

**AC1: Ajuste de aceite en invierno**
- Given que la temporada configurada es invierno
- And la receta incluye aceite
- When escalo la receta
- Then el aceite aumenta un 20%
- And muestra nota: "Ajuste de invierno aplicado"

**AC2: Sin ajuste en verano**
- Given que la temporada configurada es verano
- When escalo la receta
- Then las cantidades de aceite son las base
- And no muestra nota de ajuste

**AC3: Indicador visual de ajuste**
- Given que hay ajuste estacional aplicado
- When veo la receta escalada
- Then los ingredientes ajustados tienen indicador (icono o color)
- And puedo ver el valor original vs ajustado

**AC4: Ajuste por cerdo**
- Given que aplique variacion con cerdo >25%
- When escalo la receta
- Then el aceite se reduce (cerdo es mas graso)
- And la reduccion se combina con ajuste estacional si aplica

**Technical Notes:**
- Invierno: aceite +20%
- Cerdo >25%: aceite -50%
- Pescado graso: aceite -100%
- Los ajustes se aplican en orden y se combinan

**Definition of Done:**
- [x] Logica de ajustes estacionales
- [x] Combinacion con ajustes por variaciones
- [x] Unit tests para todas las combinaciones
- [x] UI con indicadores de ajustes

---

## Epic 4: Menu Semanal

---

### MEW-011: Crear menu semanal con calendario
**Story Points:** 5
**Priority:** Critical
**Status:** Done
**DoR Level:** 2

**As a** cuidador de gatos
**I want** planificar el menu de la semana en un calendario visual
**So that** pueda organizar las comidas de mis gatos

**Acceptance Criteria:**

**AC1: Vista de 7 dias**
- Given que entro al constructor de menu
- When se muestra la pantalla
- Then veo 7 slots (Lunes a Domingo)
- And cada slot indica si esta vacio o tiene receta asignada

**AC2: Asignar receta a dia**
- Given que selecciono el slot del Martes
- When elijo una receta del catalogo
- Then la receta queda asignada al Martes
- And el slot muestra el nombre de la receta

**AC3: Asignar variacion a dia**
- Given que asigne receta A al Miercoles
- When selecciono "Aplicar variacion"
- Then puedo configurar la variacion para ese dia especifico
- And la variacion solo afecta ese slot

**AC4: Copiar receta a otro dia**
- Given que tengo receta en Lunes
- When selecciono "Copiar"
- Then puedo pegarla en otro dia de la semana
- And copia la receta con sus variaciones

**AC5: Limpiar slot**
- Given que tengo receta asignada en Jueves
- When selecciono "Limpiar"
- Then el slot queda vacio
- And puedo asignar otra receta

**Technical Notes:**
- Modelo: MenuSemanal con 7 slots (dia, receta_id, variacion)
- UI: Grid o lista de 7 items
- Drag & drop opcional para v2

**Definition of Done:**
- [x] UI de calendario semanal
- [x] Asignacion de recetas a slots
- [x] Variaciones por slot
- [x] Widget tests

---

### MEW-012: Validar restricciones semanales
**Story Points:** 5
**Priority:** Critical
**Status:** Done
**DoR Level:** 2

**As a** cuidador de gatos
**I want** que el sistema valide automaticamente las restricciones nutricionales
**So that** no cometa errores que perjudiquen la salud de mis gatos

**Acceptance Criteria:**

**AC1: Validacion de pescado (max 2/semana)**
- Given que asigne pescado a Lunes y Miercoles
- When intento asignar pescado a Viernes
- Then el sistema muestra advertencia: "Pescado maximo 2 veces por semana"
- And permite continuar con confirmacion explicita

**AC2: Validacion de higado (max 2/semana)**
- Given que asigne recetas con higado a Martes y Jueves
- When intento asignar higado a Sabado
- Then el sistema muestra advertencia sobre limite de higado
- And explica riesgos de exceso de vitamina A

**AC3: Validacion de aceite obligatorio**
- Given que asigne receta sin pescado graso a Lunes
- When la receta no incluye aceite
- Then el sistema advierte: "Aceite obligatorio si no hay pescado graso"
- And sugiere agregar aceite manualmente

**AC4: Resumen de validaciones**
- Given que complete el menu semanal
- When visualizo el resumen
- Then veo un checklist de validaciones (OK/Warning/Error)
- And puedo navegar a los dias con problemas

**AC5: Bloqueo de errores criticos**
- Given que el menu tiene error critico (ej: sin taurina)
- When intento generar lista de compras
- Then el sistema bloquea la accion
- And muestra que errores debo corregir

**Technical Notes:**
- Validaciones: pescado <=2, higado <=2, aceite si no pescado, suplementos siempre
- Clasificacion: Error (bloquea), Warning (confirmar), Info (informativo)
- Ejecutar validaciones en tiempo real al modificar menu

**Definition of Done:**
- [x] Motor de validaciones implementado
- [x] UI de warnings y errores
- [x] Bloqueo de acciones con errores
- [x] Unit tests para cada regla

---

### MEW-013: Persistir menu semanal
**Story Points:** 3
**Priority:** High
**Status:** Done
**DoR Level:** 1

**As a** cuidador de gatos
**I want** que mi menu semanal se guarde automaticamente
**So that** no pierda mi planificacion

**Acceptance Criteria:**

**AC1: Guardado automatico**
- Given que modifico el menu semanal
- When cambio de pantalla o cierro la app
- Then los cambios se guardan automaticamente
- And no hay boton de guardar explicito

**AC2: Carga del ultimo menu**
- Given que tengo un menu guardado
- When abro el constructor de menu
- Then veo el ultimo menu configurado
- And puedo continuar editandolo

**AC3: Historial de menus (opcional MVP)**
- Given que quiero crear un nuevo menu
- When selecciono "Nuevo menu"
- Then el menu anterior se archiva
- And puedo acceder al historial

**AC4: Offline completo**
- Given que no tengo conexion
- When guardo o cargo el menu
- Then funciona correctamente
- And no hay dependencia de red

**Technical Notes:**
- Tabla: menu_semanal (id, fecha_inicio, created_at)
- Tabla: menu_slot (id, menu_id, dia, receta_id, variacion_json)
- Un menu activo a la vez, historial para futuro

**Definition of Done:**
- [x] Schema de persistencia
- [x] Auto-save implementado
- [x] Carga al iniciar
- [x] Tests de persistencia

---

## Epic 5: Lista de Compras

---

### MEW-014: Generar lista de compras semanal
**Story Points:** 5
**Priority:** Critical
**Status:** Done
**DoR Level:** 2

**As a** cuidador de gatos
**I want** generar automaticamente la lista de compras del menu semanal
**So that** sepa exactamente que comprar y en que cantidad

**Acceptance Criteria:**

**AC1: Consolidacion de ingredientes**
- Given que mi menu tiene 7 dias con recetas asignadas
- When genero la lista de compras
- Then los ingredientes iguales se suman
- And veo cantidad total semanal de cada ingrediente

**AC2: Cantidades escaladas**
- Given que mi perfil es de 10 kg de gatos
- When genero la lista
- Then las cantidades estan escaladas al peso de mis gatos
- And considera ajustes estacionales y variaciones

**AC3: Ingredientes con unidades correctas**
- Given que la lista incluye carne (g), taurina (mg), huevos (unidades)
- When visualizo la lista
- Then cada ingrediente muestra unidad apropiada
- And las cantidades estan redondeadas practicamente

**AC4: Lista para menu incompleto**
- Given que mi menu tiene solo 5 dias asignados
- When genero lista
- Then solo incluye ingredientes de los 5 dias
- And muestra advertencia de menu incompleto

**Technical Notes:**
- Algoritmo: iterar slots -> escalar recetas -> agrupar ingredientes -> sumar cantidades
- Redondeo: carnes a 50g, suplementos a 5mg, huevos enteros
- Ordenar por categoria

**Definition of Done:**
- [x] Servicio de generacion de lista
- [x] Consolidacion correcta
- [x] UI de lista de compras
- [x] Unit tests

---

### MEW-015: Agrupar ingredientes por categoria
**Story Points:** 3
**Priority:** High
**Status:** Done
**DoR Level:** 1

**As a** cuidador de gatos
**I want** ver la lista de compras agrupada por categorias
**So that** pueda comprar de forma organizada

**Acceptance Criteria:**

**AC1: Categorias definidas**
- Given que genero la lista de compras
- When visualizo la lista
- Then los ingredientes estan agrupados en: Carnes, Visceras, Pescados, Vegetales, Huevos/Lacteos, Suplementos, Aceites
- And cada categoria tiene header visible

**AC2: Orden dentro de categoria**
- Given que una categoria tiene multiples items
- When visualizo la seccion
- Then los items estan ordenados alfabeticamente
- And muestran cantidad y unidad

**AC3: Categorias vacias ocultas**
- Given que el menu no incluye pescado
- When genero la lista
- Then la categoria Pescados no aparece
- And no hay secciones vacias

**AC4: Checkbox para marcar comprado**
- Given que estoy en la lista de compras
- When toco un ingrediente
- Then puedo marcarlo como comprado
- And el estado se persiste

**Technical Notes:**
- Enum de categorias con orden predefinido
- Cada ingrediente tiene categoria asignada en modelo
- Persist estado de checkbox en SQLite

**Definition of Done:**
- [x] Agrupacion por categorias
- [x] UI con secciones colapsables
- [x] Checkboxes funcionales
- [x] Widget tests

---

## Epic 6: Presupuesto

---

### MEW-016: Registrar precios de ingredientes
**Story Points:** 3
**Priority:** Medium
**Status:** Done
**DoR Level:** 1

**As a** cuidador de gatos
**I want** ingresar los precios de cada ingrediente
**So that** el sistema pueda calcular el costo total

**Acceptance Criteria:**

**AC1: Lista de ingredientes con precio**
- Given que entro a la seccion de precios
- When visualizo la lista
- Then veo todos los ingredientes usados en las recetas
- And cada uno tiene campo para ingresar precio

**AC2: Precio por unidad estandar**
- Given que ingreso precio de carne
- When especifico el precio
- Then es precio por kg (o por unidad para huevos, etc.)
- And el sistema indica la unidad esperada

**AC3: Guardar precios**
- Given que ingreso varios precios
- When salgo de la pantalla
- Then los precios se guardan automaticamente
- And persisten entre sesiones

**AC4: Precios opcionales**
- Given que no se el precio de un ingrediente
- When lo dejo vacio
- Then el sistema acepta el valor vacio
- And el calculo de costo muestra "incompleto"

**Technical Notes:**
- Tabla: precios_ingredientes (ingrediente_id, precio, unidad, updated_at)
- Precio decimal con 2 decimales
- Moneda local (pesos argentinos default)

**Definition of Done:**
- [x] UI de lista de precios
- [x] Persistencia de precios
- [x] Validacion de inputs
- [x] Tests

---

### MEW-017: Calcular costo semanal y por kilo
**Story Points:** 5
**Priority:** Medium
**Status:** Done
**DoR Level:** 2

**As a** cuidador de gatos
**I want** ver el costo total semanal y el costo por kilo de gato
**So that** pueda presupuestar la alimentacion

**Acceptance Criteria:**

**AC1: Costo semanal total**
- Given que tengo menu completo y precios ingresados
- When visualizo el resumen de presupuesto
- Then veo el costo total semanal en pesos
- And desglosa costo por categoria

**AC2: Costo por kilo de gato**
- Given que mi perfil tiene 8 kg de gatos y costo semanal de $16000
- When veo el resumen
- Then muestra costo por kg: $2000/kg/semana
- And permite comparar con alimentacion comercial

**AC3: Costo diario**
- Given que tengo costo semanal calculado
- When veo el resumen
- Then tambien muestra costo diario promedio
- And costo por gato si tengo numero de gatos

**AC4: Ingredientes sin precio**
- Given que faltan precios de algunos ingredientes
- When calculo el costo
- Then muestra costo parcial con advertencia
- And lista ingredientes sin precio

**AC5: Actualizacion automatica**
- Given que cambio precios o menu
- When vuelvo al presupuesto
- Then el costo se recalcula automaticamente
- And refleja cambios inmediatamente

**Technical Notes:**
- Costo = sum(cantidad_ingrediente * precio_unitario)
- Costo por kg = costo_total / peso_gatos
- Mostrar advertencias si datos incompletos

**Definition of Done:**
- [x] Logica de calculo de costos
- [x] UI de resumen de presupuesto
- [x] Manejo de precios faltantes
- [x] Unit tests

---

## Epic 8: UX y Explicabilidad (parcial)

---

### MEW-019: Onboarding guiado inicial
**Story Points:** 5
**Priority:** Critical
**Status:** Done
**DoR Level:** 2

**As a** nuevo usuario de Mew Michis
**I want** una introduccion guiada al abrir la app por primera vez
**So that** entienda las reglas nutricionales clave antes de empezar

**Acceptance Criteria:**

**AC1: Pantallas de onboarding**
- Given que abro la app por primera vez
- When se carga la aplicacion
- Then veo una secuencia de 3-4 pantallas explicativas
- And puedo navegar con swipe o botones

**AC2: Contenido educativo esencial**
- Given que estoy en el onboarding
- When leo las pantallas
- Then aprendo sobre: taurina (esencial), calcio (obligatorio), limites de higado/pescado
- And cada concepto tiene explicacion simple y visual

**AC3: Opcion de saltar**
- Given que ya conozco el sistema
- When veo el onboarding
- Then puedo saltar con boton "Omitir"
- And voy directo a la app

**AC4: No se repite**
- Given que complete o salte el onboarding
- When abro la app nuevamente
- Then no veo el onboarding otra vez
- And puedo acceder desde Configuracion si quiero verlo de nuevo

**Technical Notes:**
- Usar PageView con indicador de pagina
- Persistir flag "onboarding_completed" en SharedPreferences
- Imagenes/iconos simples para cada concepto
- Maximo 4 pantallas para no abrumar

**Implementacion:**
- 4 pantallas: Bienvenida, Taurina, Calcio, Limites
- Provider de estado de onboarding con Riverpod
- Redirect desde go_router
- 15 tests de onboarding pasando

**Definition of Done:**
- [x] 3-4 pantallas de onboarding implementadas
- [x] Contenido sobre taurina, calcio, limites
- [x] Persistencia de estado completado
- [x] Boton omitir funcional
- [x] Widget tests

---

### MEW-020: Desglose explicativo del calculo nutricional
**Story Points:** 3
**Priority:** High
**Status:** Done
**DoR Level:** 1

**As a** cuidador de gatos
**I want** ver como se calcula la cantidad diaria de comida
**So that** entienda de donde vienen los numeros y confie en el sistema

**Acceptance Criteria:**

**AC1: Boton de ver desglose**
- Given que estoy en la pantalla de perfil con calculos
- When toco un icono de informacion junto al valor diario
- Then se abre un modal/bottomsheet con el desglose

**AC2: Formula visible**
- Given que veo el desglose
- When leo el contenido
- Then muestra: "Peso (X kg) x Factor actividad (Y) x Base (35g) = Z gramos/dia"
- And si hay ajuste estacional, lo muestra tambien

**AC3: Valores intermedios**
- Given que veo el desglose
- When reviso los calculos
- Then puedo ver cada paso del calculo
- And entiendo como se llega al resultado final

**Implementacion:**
- Archivos creados: calculation_step_card.dart, calculation_breakdown_sheet.dart, recipe_scaling_breakdown_sheet.dart
- Boton "Ver calculo" en home_screen.dart
- IconButton calculadora en recipe_detail_screen.dart
- 20 tests nuevos

**Technical Notes:**
- Reutilizar CalculationService para obtener valores intermedios
- BottomSheet con scroll si es largo
- Formatear numeros de forma legible

**Definition of Done:**
- [x] Icono de info junto a valores calculados
- [x] Modal/BottomSheet con formula
- [x] Valores intermedios visibles
- [x] Unit tests para formatting

---

### MEW-021: Tooltips de justificacion nutricional
**Story Points:** 3
**Priority:** High
**Status:** Done
**DoR Level:** 1

**As a** cuidador de gatos
**I want** entender por que existen las restricciones (higado, pescado)
**So that** siga las reglas conscientemente y no por imposicion

**Acceptance Criteria:**

**AC1: Icono de tooltip en restricciones**
- Given que veo una restriccion en una receta (ej: "Max 2x/semana")
- When toco el icono de ayuda junto a la restriccion
- Then aparece tooltip con explicacion

**AC2: Contenido educativo**
- Given que veo tooltip de higado
- When leo el contenido
- Then explica: "El higado es rico en Vitamina A. El exceso puede causar hipervitaminosis."
- And es conciso (2-3 lineas max)

**AC3: Tooltips para pescado**
- Given que veo tooltip de pescado
- When leo el contenido
- Then explica: "Algunos pescados contienen tiaminasa que destruye la vitamina B1."
- And menciona que el limite es por seguridad

**AC4: Tooltips para suplementos**
- Given que veo tooltip de taurina
- When leo el contenido
- Then explica: "Los gatos no sintetizan taurina. Es esencial para corazon y vision."

**Implementacion:**
- Archivos creados: nutritional_explanations.dart, info_tooltip.dart
- Tooltips en: ingredient_list.dart, supplement_section.dart, scaled_ingredient_row.dart, validation_summary_card.dart
- 46 tests nuevos (30 unit + 16 widget)

**Technical Notes:**
- Usar Tooltip widget de Flutter o PopupMenuButton
- Textos predefinidos en constantes
- Iconos consistentes (info circle)

**Definition of Done:**
- [x] Tooltips en restricciones de recetas
- [x] Tooltips en suplementos obligatorios
- [x] Contenido educativo correcto
- [x] Widget tests

---

## Metricas de la Sesion de Archivado

| Metrica | Valor |
|---------|-------|
| Historias completadas | 20 |
| Story points completados | 81 |
| Epics completados | 6 (E1-E6) |
| Epics parcialmente completados | 1 (E8) |
| Tests totales al archivar | 465 |
| Bugs pendientes | 1 (MEW-018) |
| Deployment | Samsung SM A135M (Android 13 API 33) |
| APK release | 20.4MB |
