# Product Backlog - Chemical Sprint 2

**Proyecto:** Chemical - Juego Educativo de Quimica
**Plataforma:** Flutter (Android)
**Fecha:** 2025-12-28
**Estado:** En desarrollo

---

## Epic 2: Mejoras de Visualizacion y Navegacion

**Objetivo:** Enriquecer la informacion mostrada, implementar categorizacion visual con colores, agregar animaciones y habilitar busqueda rapida.

**Story Points Totales:** 34

---

## Resumen de Historias

| ID | Titulo | SP | Prioridad |
|----|--------|----|-----------|
| US-CHEM-020 | Actualizar dataset con info extendida | 3 | High |
| US-CHEM-021 | Mostrar info extendida en tarjeta | 5 | High |
| US-CHEM-022 | Implementar colores por categoria | 8 | High |
| US-CHEM-023 | Agregar animaciones de transicion | 5 | Medium |
| US-CHEM-024 | Implementar busqueda rapida | 8 | High |

---

## US-CHEM-020: Actualizar dataset con informacion extendida

| Campo | Valor |
|-------|-------|
| **Story Points** | 3 |
| **Prioridad** | High |

### Historia

**Como** desarrollador
**Quiero** extender el modelo con masa atomica, grupo, periodo y categoria
**Para** mostrar informacion mas completa y aplicar categorizacion visual

### Criterios de Aceptacion

**AC1: Modelo extendido**
```gherkin
Given el modelo Element actual
When agrego los campos atomicMass, group, period, category
Then el modelo debe incluir todos estos campos
And category debe ser un enum con 10 categorias
```

**AC2: Dataset actualizado**
```gherkin
Given los 118 elementos
When actualizo con la informacion extendida
Then todos deben tener masa atomica (double)
And todos deben tener grupo (1-18, null para lantanidos/actinidos)
And todos deben tener periodo (1-7)
And todos deben tener categoria asignada
```

### Notas Tecnicas

```dart
enum ElementCategory {
  alkalineMetal,      // Metal alcalino
  alkalineEarthMetal, // Metal alcalinoterreo
  transitionMetal,    // Metal de transicion
  postTransitionMetal,// Metal del bloque p
  metalloid,          // Metaloide
  nonmetal,           // No metal
  halogen,            // Halogeno
  nobleGas,           // Gas noble
  lanthanide,         // Lantanido
  actinide            // Actinido
}
```

---

## US-CHEM-021: Mostrar informacion extendida en tarjeta

| Campo | Valor |
|-------|-------|
| **Story Points** | 5 |
| **Prioridad** | High |

### Historia

**Como** usuario
**Quiero** ver masa atomica, grupo, periodo y categoria
**Para** obtener informacion completa sin salir de la pantalla

### Criterios de Aceptacion

**AC1: Informacion visible**
```gherkin
Given que veo la tarjeta de un elemento
When observo el contenido
Then debo ver masa atomica (ej: "12.011 u")
And debo ver grupo (ej: "Grupo 14")
And debo ver periodo (ej: "Periodo 2")
And debo ver categoria en espanol (ej: "No metal")
```

**AC2: Layout balanceado**
```gherkin
Given la tarjeta con info extendida
When visualizo el diseno
Then numero atomico y simbolo deben ser prominentes
And la info adicional debe estar organizada
And el texto debe ser legible (min 14sp)
```

---

## US-CHEM-022: Implementar colores por categoria

| Campo | Valor |
|-------|-------|
| **Story Points** | 8 |
| **Prioridad** | High |

### Historia

**Como** usuario
**Quiero** que cada categoria tenga un color distintivo
**Para** identificar visualmente el tipo de elemento

### Criterios de Aceptacion

**AC1: Paleta de colores**
```gherkin
Given las 10 categorias de elementos
When defino la paleta
Then cada categoria debe tener un color unico
And cada color debe tener buena legibilidad con texto blanco
```

**AC2: Gradiente dinamico**
```gherkin
Given la tarjeta de un elemento
When se renderiza
Then el gradiente debe usar el color de la categoria
And debe ir de mas oscuro a mas claro
```

### Paleta de Colores

| Categoria | Color | Hex |
|-----------|-------|-----|
| Metal alcalino | Rojo | #E74C3C |
| Metal alcalinoterreo | Naranja | #F39C12 |
| Metal de transicion | Azul | #3498DB |
| Metal bloque p | Purpura | #9B59B6 |
| Metaloide | Verde azulado | #1ABC9C |
| No metal | Verde | #2ECC71 |
| Halogeno | Naranja oscuro | #E67E22 |
| Gas noble | Gris | #95A5A6 |
| Lantanido | Naranja rojizo | #D35400 |
| Actinido | Rojo oscuro | #C0392B |

---

## US-CHEM-023: Agregar animaciones de transicion

| Campo | Valor |
|-------|-------|
| **Story Points** | 5 |
| **Prioridad** | Medium |

### Historia

**Como** usuario
**Quiero** ver una animacion suave al cambiar de elemento
**Para** que la navegacion sea mas fluida

### Criterios de Aceptacion

**AC1: Animacion slide**
```gherkin
Given que veo la tarjeta
When avanzo al siguiente elemento
Then la tarjeta debe deslizarse hacia arriba con fade out
And la nueva debe aparecer desde abajo con fade in
When retrocedo
Then la animacion debe invertirse
```

**AC2: Duracion y suavidad**
```gherkin
Given una animacion de transicion
When se reproduce
Then debe durar 250-350ms
And debe usar curva fastOutSlowIn
And no debe haber stuttering
```

---

## US-CHEM-024: Implementar busqueda rapida de elementos

| Campo | Valor |
|-------|-------|
| **Story Points** | 8 |
| **Prioridad** | High |

### Historia

**Como** usuario
**Quiero** saltar rapidamente a un elemento especifico
**Para** no navegar secuencialmente por 118 elementos

### Criterios de Aceptacion

**AC1: FAB con selector**
```gherkin
Given que estoy en la pantalla principal
When toco el FAB
Then debe aparecer un bottom sheet con grid de elementos
And cada celda muestra simbolo + numero atomico
And el color de celda corresponde a la categoria
```

**AC2: Navegacion rapida**
```gherkin
Given el selector abierto
When toco un elemento (ej: "Au")
Then la tarjeta debe cambiar a ese elemento
And el selector debe cerrarse
```

**AC3: UX fluida**
```gherkin
Given el selector abierto
When toco fuera o presiono atras
Then debe cerrarse sin cambiar de elemento
```

---

## Definition of Done - Sprint 2

- [ ] Dataset actualizado con 4 campos nuevos (118 elementos)
- [ ] Tarjeta muestra informacion extendida
- [ ] 10 colores de categoria implementados
- [ ] Animaciones de transicion funcionando
- [ ] FAB con selector de elementos
- [ ] Build sin warnings
- [ ] Testing manual completo
- [ ] Screenshots documentados

---

**Fecha:** 2025-12-28
