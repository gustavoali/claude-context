# Epic 10: Funcionalidades Avanzadas (E10)

**Version:** v1.3
**Objetivo:** Agregar funcionalidades para usuarios avanzados.
**Valor de negocio:** Atiende a usuarios power-users y nutricionistas.
**Story Points Total:** 23
**Status:** PLANIFICADO (0 de 5 historias completadas)

---

## Historias

| ID | Titulo | Points | Priority | Status |
|----|--------|--------|----------|--------|
| MEW-032 | Informacion individual por gato | 5 | Low | Pending |
| MEW-033 | Modo usuario avanzado | 5 | Low | Pending |
| MEW-034 | Simulaciones hipoteticas | 5 | Low | Pending |
| MEW-035 | Sugerencias automaticas de correccion | 5 | Low | Pending |
| MEW-036 | Sustituciones rapidas en lista de compras | 3 | Low | Pending |

---

## Dependencias entre Historias

```
MEW-032 (Info por gato) - Independiente
MEW-033 (Modo avanzado) - Independiente, base para MEW-034
  --> MEW-034 (Simulaciones) [usa modo avanzado como contexto]
  --> MEW-035 (Sugerencias) [puede usar modo avanzado para detalles]
MEW-036 (Sustituciones) - Independiente

Orden recomendado:
  MEW-032, MEW-033, MEW-036 pueden ser paralelos
  MEW-034 despues de MEW-033
  MEW-035 despues de MEW-033 (recomendado, no bloqueante)
```

---

## Dependencias con Otros Epics

- **E1 (Perfil):** MEW-032 extiende el perfil con gatos individuales, MEW-034 simula cambios de perfil
- **E4 (Menu Semanal):** MEW-033 muestra reglas aplicadas, MEW-035 sugiere correcciones al menu
- **E5 (Lista Compras):** MEW-036 opera sobre la lista de compras
- **E8 (UX):** MEW-023 (errores accionables) es prerequisito conceptual para MEW-035
- **E9 (Exportacion):** Completar E9 primero es recomendado (v1.2 antes de v1.3)

---

## Detalle de Historias

### MEW-032: Informacion individual por gato
**Story Points:** 5 | **Priority:** Low | **Status:** Pending | **DoR Level:** 2

**As a** cuidador de multiples gatos
**I want** registrar nombre y peso de cada gato individualmente
**So that** tenga un registro mas detallado (aunque el calculo use peso total)

**AC1:** Agregar gatos con nombre y peso
**AC2:** Lista de gatos en perfil
**AC3:** Editar y eliminar gatos
**AC4:** Calculo sigue usando peso total (suma)

**Technical Notes:** Nueva tabla cats (id, profile_id, name, weight). Suma debe igualar weight_total.

**Migracion DB requerida:** Agregar tabla `cats`

---

### MEW-033: Modo usuario avanzado
**Story Points:** 5 | **Priority:** Low | **Status:** Pending | **DoR Level:** 2

**As a** usuario avanzado o nutricionista
**I want** activar un modo que muestre mas detalles tecnicos
**So that** pueda auditar los calculos y entender las decisiones del sistema

**AC1:** Toggle en Configuracion
**AC2:** Ver reglas aplicadas en recetas escaladas
**AC3:** Log de decisiones automaticas en menu
**AC4:** Metricas detalladas con valores intermedios

**Technical Notes:** Flag en SharedPreferences. Condicionar UI. Logs en memoria.

---

### MEW-034: Simulaciones hipoteticas
**Story Points:** 5 | **Priority:** Low | **Status:** Pending | **DoR Level:** 2

**As a** cuidador de gatos
**I want** hacer simulaciones "what if" sin guardar cambios
**So that** pueda explorar opciones antes de decidir

**AC1:** Modo simulacion en perfil (cambios temporales)
**AC2:** Banner persistente "Modo simulacion"
**AC3:** Comparar real vs simulado lado a lado
**AC4:** Reset automatico al salir

**Technical Notes:** State temporal (no provider global). Banner con SafeArea. Resetear al salir.

---

### MEW-035: Sugerencias automaticas de correccion
**Story Points:** 5 | **Priority:** Low | **Status:** Pending | **DoR Level:** 2

**As a** cuidador de gatos
**I want** que el sistema sugiera como corregir errores del menu
**So that** no tenga que adivinar la solucion

**AC1:** Boton "Sugerir correccion" junto a cada error
**AC2:** Sugerencia concreta (ej: "Cambiar Viernes de Receta C a Receta A")
**AC3:** Aplicar sugerencia automaticamente
**AC4:** Multiples opciones ordenadas por impacto

**Technical Notes:** Algoritmo: identificar dia problematico, buscar receta alternativa valida. Priorizar cambios minimos.

---

### MEW-036: Sustituciones rapidas en lista de compras
**Story Points:** 3 | **Priority:** Low | **Status:** Pending | **DoR Level:** 1

**As a** cuidador de gatos
**I want** poder sustituir ingredientes desde la lista de compras
**So that** pueda adaptarme si no encuentro algo

**AC1:** Boton "Sustituir" en cada ingrediente
**AC2:** Solo muestra alternativas validas
**AC3:** Recalculo de cantidades si necesario
**AC4:** Revalidacion del menu post-sustitucion

**Technical Notes:** Usar matriz de sustituciones de recetas. Disparar revalidacion.

---

## Migraciones de Base de Datos

| Version | Tabla | Descripcion | Historia |
|---------|-------|-------------|----------|
| v1.3 | cats | Gatos individuales | MEW-032 |

---

## Priorizacion MoSCoW (dentro del epic)

- **Could Have:** MEW-032, MEW-033, MEW-034, MEW-035, MEW-036
- Todas son "nice to have" - ninguna es critica para v1.3

---

## Orden de Implementacion Sugerido

1. MEW-032 (Info por gato) + MEW-033 (Modo avanzado) - en paralelo, independientes
2. MEW-036 (Sustituciones) - independiente, menor complejidad
3. MEW-034 (Simulaciones) - despues de MEW-033
4. MEW-035 (Sugerencias correccion) - despues de MEW-033, mas complejo
