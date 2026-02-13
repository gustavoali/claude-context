# Product Backlog - Chemical MVP v1.0

**Proyecto:** Chemical - Juego Educativo de Quimica
**Plataforma:** Flutter (Android)
**Fecha de Creacion:** 2025-12-28
**Estado:** Listo para Sprint Planning

---

## Vision del Producto

Chemical es un juego educativo que combina elementos de puzzle, aventura y simulador de laboratorio, integrando conceptos de quimica con ecologia sustentable. El MVP establece la mecanica core de navegacion por elementos de la tabla periodica.

---

## Epic 1: Navegacion Basica de Elementos Quimicos

**Objetivo:** Permitir al usuario explorar los 118 elementos de la tabla periodica mediante navegacion simple por tarjetas.

**Valor de Negocio:** Validar la mecanica core del juego y obtener feedback temprano sobre la UX de navegacion.

**Story Points Totales:** 23 puntos

---

## Historias de Usuario

---

### US-CHEM-001: Visualizar Tarjeta de Elemento Quimico

| Campo | Valor |
|-------|-------|
| **Story Points** | 3 |
| **Prioridad** | Must Have |
| **Sprint** | MVP Sprint 1 |

#### Historia

**Como** usuario de la aplicacion
**Quiero** ver una tarjeta con informacion del elemento Hidrogeno al iniciar la app
**Para** conocer los datos basicos del primer elemento de la tabla periodica

#### Criterios de Aceptacion

**AC1: Pantalla Inicial**
```gherkin
Given que abro la aplicacion por primera vez
When la app carga completamente
Then veo una tarjeta centrada en la pantalla
And la tarjeta muestra el elemento Hidrogeno (H, numero atomico 1)
```

**AC2: Informacion Visible en Tarjeta**
```gherkin
Given que estoy viendo una tarjeta de elemento
When observo el contenido de la tarjeta
Then veo el simbolo quimico del elemento (ej: H)
And veo el nombre del elemento (ej: Hidrogeno)
And veo el numero atomico (ej: 1)
And todos los textos son legibles con buen contraste
```

**AC3: Diseno Visual**
```gherkin
Given que visualizo la tarjeta
When observo su diseno
Then la tarjeta tiene un diseno atractivo apropiado para un juego educativo
And la tarjeta ocupa un tamano apropiado en la pantalla
And hay suficiente espacio debajo de la tarjeta para mensajes
```

#### Notas Tecnicas
- Usar `Card` widget de Flutter Material Design
- Colores y tipografia consistentes con tema educativo
- Considerar responsive design para diferentes tamanos de pantalla

#### Definition of Done
- [ ] Codigo implementado y funcional
- [ ] Tarjeta renderiza correctamente en emulador Android
- [ ] Diseno visual aprobado
- [ ] No hay errores en consola
- [ ] Probado en al menos 2 tamanos de pantalla diferentes

---

### US-CHEM-002: Navegar al Siguiente Elemento

| Campo | Valor |
|-------|-------|
| **Story Points** | 5 |
| **Prioridad** | Must Have |
| **Sprint** | MVP Sprint 1 |

#### Historia

**Como** usuario de la aplicacion
**Quiero** poder avanzar al siguiente elemento tocando la mitad inferior de la tarjeta
**Para** explorar los elementos quimicos en orden ascendente

#### Criterios de Aceptacion

**AC1: Deteccion de Tap en Mitad Inferior**
```gherkin
Given que estoy viendo una tarjeta de elemento
When hago tap en la mitad inferior de la tarjeta
Then la app detecta el gesto correctamente
And la app identifica que fue en la mitad inferior
```

**AC2: Transicion al Siguiente Elemento**
```gherkin
Given que estoy viendo el Hidrogeno (elemento 1)
When hago tap en la mitad inferior de la tarjeta
Then la tarjeta se actualiza mostrando el Helio (elemento 2)
And el simbolo cambia a "He"
And el nombre cambia a "Helio"
And el numero atomico cambia a "2"
```

**AC3: Navegacion Continua**
```gherkin
Given que estoy viendo cualquier elemento que no sea el ultimo
When hago tap repetidamente en la mitad inferior
Then puedo avanzar secuencialmente por todos los elementos
And cada tap muestra el siguiente elemento en orden (1->2->3->...->118)
```

#### Notas Tecnicas
- Usar `GestureDetector` con `onTapDown` para detectar posicion del tap
- Comparar posicion Y del tap con altura de la tarjeta para determinar mitad
- Estado del elemento actual debe ser reactivo (`StatefulWidget`)
- Considerar animacion de transicion entre elementos

#### Definition of Done
- [ ] Codigo implementado y funcional
- [ ] Tap en mitad inferior detectado correctamente
- [ ] Navegacion funciona desde elemento 1 hasta 118
- [ ] Tests manuales completados
- [ ] No hay crashes ni errores en navegacion

---

### US-CHEM-003: Navegar al Elemento Anterior

| Campo | Valor |
|-------|-------|
| **Story Points** | 3 |
| **Prioridad** | Must Have |
| **Sprint** | MVP Sprint 1 |

#### Historia

**Como** usuario de la aplicacion
**Quiero** poder retroceder al elemento anterior tocando la mitad superior de la tarjeta
**Para** revisar elementos ya vistos

#### Criterios de Aceptacion

**AC1: Deteccion de Tap en Mitad Superior**
```gherkin
Given que estoy viendo una tarjeta de elemento
When hago tap en la mitad superior de la tarjeta
Then la app detecta el gesto correctamente
And la app identifica que fue en la mitad superior
```

**AC2: Transicion al Elemento Anterior**
```gherkin
Given que estoy viendo el Helio (elemento 2)
When hago tap en la mitad superior de la tarjeta
Then la tarjeta se actualiza mostrando el Hidrogeno (elemento 1)
And el simbolo cambia a "H"
And el nombre cambia a "Hidrogeno"
And el numero atomico cambia a "1"
```

**AC3: Navegacion Bidireccional**
```gherkin
Given que estoy en cualquier elemento intermedio
When alterno taps entre mitad superior e inferior
Then puedo navegar hacia adelante y hacia atras libremente
And los cambios son consistentes y predecibles
```

#### Notas Tecnicas
- Complementa la logica de US-CHEM-002
- Misma estructura de `GestureDetector` pero con logica inversa
- Validar limites: no decrementar si ya estas en elemento 1

#### Definition of Done
- [ ] Codigo implementado y funcional
- [ ] Tap en mitad superior detectado correctamente
- [ ] Navegacion inversa funciona desde elemento 118 hasta 1
- [ ] Navegacion bidireccional probada manualmente
- [ ] No hay crashes ni comportamientos inesperados

---

### US-CHEM-004: Mensaje al Llegar al Inicio de la Tabla

| Campo | Valor |
|-------|-------|
| **Story Points** | 2 |
| **Prioridad** | Must Have |
| **Sprint** | MVP Sprint 1 |

#### Historia

**Como** usuario de la aplicacion
**Quiero** ver un mensaje cuando intento retroceder desde el Hidrogeno
**Para** saber que no hay mas elementos anteriores

#### Criterios de Aceptacion

**AC1: Mensaje al Intentar Retroceder desde Hidrogeno**
```gherkin
Given que estoy viendo el Hidrogeno (elemento 1)
When hago tap en la mitad superior de la tarjeta
Then aparece un mensaje debajo de la tarjeta
And el mensaje indica "Este es el primer elemento de la tabla periodica"
And la tarjeta NO cambia (sigue mostrando Hidrogeno)
```

**AC2: Visibilidad del Mensaje**
```gherkin
Given que el mensaje de inicio se muestra
When observo la pantalla
Then el mensaje es claramente visible
And el mensaje tiene un diseno consistente con la UI
And el mensaje esta posicionado debajo de la tarjeta
```

**AC3: Desaparicion del Mensaje**
```gherkin
Given que el mensaje de inicio esta visible
When hago tap en la mitad inferior de la tarjeta
Then el mensaje desaparece
And navego al Helio normalmente
```

#### Notas Tecnicas
- Usar `Text` widget posicionado debajo del `Card`
- Controlar visibilidad del mensaje con estado booleano
- Color del mensaje: informativo (azul o similar)

#### Definition of Done
- [ ] Codigo implementado y funcional
- [ ] Mensaje se muestra correctamente al intentar retroceder desde elemento 1
- [ ] Mensaje desaparece al avanzar
- [ ] Diseno del mensaje aprobado
- [ ] Testing manual completado

---

### US-CHEM-005: Mensaje al Llegar al Final de la Tabla

| Campo | Valor |
|-------|-------|
| **Story Points** | 2 |
| **Prioridad** | Must Have |
| **Sprint** | MVP Sprint 1 |

#### Historia

**Como** usuario de la aplicacion
**Quiero** ver un mensaje cuando intento avanzar desde el Oganeson
**Para** saber que no hay mas elementos posteriores

#### Criterios de Aceptacion

**AC1: Mensaje al Intentar Avanzar desde Oganeson**
```gherkin
Given que estoy viendo el Oganeson (elemento 118)
When hago tap en la mitad inferior de la tarjeta
Then aparece un mensaje debajo de la tarjeta
And el mensaje indica "Este es el ultimo elemento de la tabla periodica"
And la tarjeta NO cambia (sigue mostrando Oganeson)
```

**AC2: Consistencia Visual**
```gherkin
Given que el mensaje de fin se muestra
When observo la pantalla
Then el mensaje tiene el mismo diseno que el mensaje de inicio
And el mensaje esta posicionado debajo de la tarjeta
```

**AC3: Desaparicion del Mensaje**
```gherkin
Given que el mensaje de fin esta visible
When hago tap en la mitad superior de la tarjeta
Then el mensaje desaparece
And retrocedo al elemento 117 normalmente
```

#### Notas Tecnicas
- Logica similar a US-CHEM-004 pero para limite superior
- Validar que numero atomico == 118 antes de mostrar mensaje
- Reutilizar componente de mensaje para mantener consistencia

#### Definition of Done
- [ ] Codigo implementado y funcional
- [ ] Mensaje se muestra correctamente al intentar avanzar desde elemento 118
- [ ] Mensaje desaparece al retroceder
- [ ] Consistencia visual con mensaje de inicio
- [ ] Navegacion completa (1->118) probada manualmente

---

### US-CHEM-006: Dataset de Elementos Quimicos

| Campo | Valor |
|-------|-------|
| **Story Points** | 5 |
| **Prioridad** | Must Have |
| **Sprint** | MVP Sprint 1 |

#### Historia

**Como** desarrollador
**Quiero** tener un dataset con los 118 elementos de la tabla periodica
**Para** alimentar la funcionalidad de navegacion

#### Criterios de Aceptacion

**AC1: Datos Minimos Requeridos**
```gherkin
Given que se necesita informacion de elementos
When consulto el dataset
Then cada elemento tiene:
  - Numero atomico (1-118)
  - Simbolo quimico (H, He, Li, etc.)
  - Nombre en espanol (Hidrogeno, Helio, Litio, etc.)
```

**AC2: Completitud del Dataset**
```gherkin
Given el dataset de elementos
When cuento los elementos disponibles
Then hay exactamente 118 elementos
And estan ordenados por numero atomico
And no hay elementos duplicados
```

**AC3: Formato de Datos**
```gherkin
Given que accedo al dataset
When consulto un elemento por su indice
Then puedo obtener sus propiedades facilmente
And el formato es compatible con Flutter (List o clase Dart)
```

#### Notas Tecnicas

Estructura sugerida:

```dart
class ChemicalElement {
  final int atomicNumber;
  final String symbol;
  final String name;

  const ChemicalElement({
    required this.atomicNumber,
    required this.symbol,
    required this.name,
  });
}
```

- Crear archivo `lib/data/elements_data.dart`
- Fuente de datos: Wikipedia o tabla periodica oficial IUPAC
- Hardcodear datos en codigo para el MVP

#### Definition of Done
- [ ] Dataset creado con 118 elementos
- [ ] Datos verificados contra fuente oficial
- [ ] Codigo puede cargar y acceder a los datos
- [ ] Validacion basica implementada (no nulos, secuencia correcta)

---

### US-CHEM-007: Testing Manual del MVP

| Campo | Valor |
|-------|-------|
| **Story Points** | 3 |
| **Prioridad** | Must Have |
| **Sprint** | MVP Sprint 1 |

#### Historia

**Como** Product Owner
**Quiero** realizar testing manual completo del MVP
**Para** validar que todas las funcionalidades core funcionan correctamente

#### Criterios de Aceptacion

**AC1: Plan de Testing**
```gherkin
Given que el MVP esta implementado
When preparo el plan de testing
Then documento los casos de prueba a ejecutar
And incluyo casos happy path y edge cases
```

**AC2: Ejecucion en Dispositivo**
```gherkin
Given el plan de testing
When ejecuto las pruebas en un dispositivo Android
Then todas las historias US-CHEM-001 a US-CHEM-006 funcionan
And no hay crashes ni errores visibles
```

**AC3: Documentacion de Resultados**
```gherkin
Given que complete el testing
When documento los resultados
Then registro:
  - Casos de prueba ejecutados
  - Status (pass/fail)
  - Bugs encontrados (si hay)
  - Screenshots de funcionalidad clave
```

#### Casos de Prueba Minimos

1. Apertura inicial de app (elemento 1 visible)
2. Navegacion forward (1->10->50->100->118)
3. Navegacion backward (118->100->50->10->1)
4. Navegacion bidireccional aleatoria
5. Mensaje de inicio (tap superior en elemento 1)
6. Mensaje de fin (tap inferior en elemento 118)
7. Verificar info correcta de 10 elementos aleatorios

#### Definition of Done
- [ ] Plan de testing documentado
- [ ] Testing ejecutado en emulador
- [ ] Testing ejecutado en dispositivo real (si disponible)
- [ ] Reporte de testing completado
- [ ] Todos los bugs criticos resueltos
- [ ] Sign-off del Product Owner

---

## Resumen del Backlog

| ID | Historia | SP | Prioridad | Dependencias |
|----|----------|----|-----------|--------------|
| US-CHEM-006 | Dataset de Elementos | 5 | Must | - |
| US-CHEM-001 | Visualizar Tarjeta | 3 | Must | US-CHEM-006 |
| US-CHEM-002 | Navegar Siguiente | 5 | Must | US-CHEM-001 |
| US-CHEM-003 | Navegar Anterior | 3 | Must | US-CHEM-001 |
| US-CHEM-004 | Mensaje Inicio | 2 | Must | US-CHEM-003 |
| US-CHEM-005 | Mensaje Final | 2 | Must | US-CHEM-002 |
| US-CHEM-007 | Testing Manual | 3 | Must | Todas |
| **TOTAL** | | **23** | | |

---

## Definition of Done - MVP Sprint

### Para cada User Story:
- [ ] Codigo implementado en Flutter
- [ ] Funcionalidad probada en emulador Android
- [ ] No hay errores de compilacion
- [ ] Codigo committeado a Git con mensaje descriptivo
- [ ] Acceptance Criteria validados

### Para el Sprint MVP completo:
- [ ] Todas las historias completadas
- [ ] App compila y ejecuta sin errores
- [ ] Dataset de 118 elementos cargado correctamente
- [ ] Navegacion bidireccional funciona (1 a 118)
- [ ] Mensajes de limites se muestran correctamente
- [ ] Testing manual completado
- [ ] No hay bugs criticos abiertos

---

## Arquitectura Tecnica

### Estructura de Carpetas

```
lib/
├── main.dart                    # Entry point
├── models/
│   └── chemical_element.dart    # Modelo de datos
├── data/
│   └── elements_data.dart       # Dataset de 118 elementos
├── screens/
│   └── element_card_screen.dart # Pantalla principal
└── widgets/
    ├── element_card.dart        # Widget de tarjeta
    └── boundary_message.dart    # Widget de mensaje
```

### Tecnologias

- **Framework:** Flutter SDK 3.16+
- **Lenguaje:** Dart 3.0+
- **UI:** Material Design 3
- **State Management:** StatefulWidget (suficiente para MVP)

### Dependencias

```yaml
dependencies:
  flutter:
    sdk: flutter
  # No se requieren dependencias externas para MVP
```

---

## Cronograma Sugerido

| Dia | Historias | Estimacion |
|-----|-----------|------------|
| 1-2 | US-CHEM-006 + US-CHEM-001 | 8 pts |
| 3 | US-CHEM-002 | 5 pts |
| 4 | US-CHEM-003 | 3 pts |
| 5 | US-CHEM-004 + US-CHEM-005 | 4 pts |
| 6 | Integracion y ajustes UI | - |
| 7 | US-CHEM-007 | 3 pts |

**Velocidad estimada:** 23 story points en 7 dias

---

## Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigacion |
|--------|--------------|---------|------------|
| Dataset incompleto/incorrecto | Media | Alto | Validar contra fuente IUPAC |
| Deteccion de tap imprecisa | Media | Medio | Testear con diferentes tamanos de pantalla |
| Performance en dispositivos low-end | Baja | Medio | Probar en emulador con specs bajas |

---

**Documento generado:** 2025-12-28
**Proxima revision:** Al completar MVP Sprint 1
