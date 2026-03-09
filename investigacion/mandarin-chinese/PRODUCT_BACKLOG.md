# Backlog - Mandarin Chinese Research
**Version:** 1.0 | **Actualizacion:** 2026-03-09

## Resumen
| Metrica | Valor |
|---------|-------|
| Total stories | 15 |
| Puntos totales | 42 |
| Completadas | 0 |
| En progreso | 0 |
| Pendientes | 15 |

## Vision
Construir un corpus personal de conocimiento sobre el chino mandarin, partiendo de su logica
de construccion (pictogramas -> radicales -> caracteres compuestos -> palabras) para desarrollar
una base solida que permita comprender y eventualmente leer/escribir caracteres con autonomia.

## Epics
| Epic | Historias | Puntos | Status |
|------|-----------|--------|--------|
| EPIC-01: Fundamentos del sistema de escritura | MC-001 a MC-004 | 13 | Pendiente |
| EPIC-02: Reglas de composicion de caracteres | MC-005 a MC-007 | 10 | Pendiente |
| EPIC-03: Vocabulario moderno y palabras compuestas | MC-008 a MC-010 | 8 | Pendiente |
| EPIC-04: Fonetica y pronunciacion | MC-011 a MC-013 | 8 | Pendiente |
| EPIC-05: Recursos y metodologia de aprendizaje | MC-014 a MC-015 | 3 | Pendiente |

## Pendientes (indice)
| ID | Titulo | Pts | Prior | Epic | Deps | Output |
|----|--------|-----|-------|------|------|--------|
| MC-001 | Catalogar pictogramas fundamentales (xiang xing zi) | 3 | Critical | 01 | - | notes/pictogramas-fundamentales.md |
| MC-002 | Investigar sistema de radicales (bushou) | 3 | Critical | 01 | - | notes/sistema-radicales.md |
| MC-003 | Analizar evolucion historica de caracteres | 5 | High | 01 | - | notes/evolucion-historica.md |
| MC-004 | Clasificar los 6 metodos de formacion (liushu) | 2 | High | 01 | MC-001 | notes/liushu-seis-metodos.md |
| MC-005 | Investigar composicion fonetico-semantica | 3 | High | 02 | MC-002 | notes/composicion-fonetico-semantica.md |
| MC-006 | Documentar posiciones estructurales de componentes | 3 | Medium | 02 | - | notes/estructuras-componentes.md |
| MC-007 | Analizar patrones de combinacion semantica | 4 | Medium | 02 | MC-002 | notes/patrones-combinacion.md |
| MC-008 | Compilar vocabulario moderno por campo semantico | 3 | Medium | 03 | MC-007 | vocabulary/vocabulario-moderno.md |
| MC-009 | Investigar neologismos y adaptacion de conceptos | 3 | Medium | 03 | MC-007 | vocabulary/neologismos.md |
| MC-010 | Crear listas de vocabulario por frecuencia | 2 | Low | 03 | - | vocabulary/caracteres-frecuentes.md |
| MC-011 | Documentar sistema pinyin completo | 3 | High | 04 | - | notes/sistema-pinyin.md |
| MC-012 | Investigar relacion pronunciacion-componentes foneticos | 3 | Medium | 04 | MC-005 | notes/componentes-foneticos.md |
| MC-013 | Compilar errores de pronunciacion para hispanohablantes | 2 | Medium | 04 | MC-011 | notes/errores-pronunciacion-hispanohablantes.md |
| MC-014 | Curar recursos de aprendizaje de mandarin | 2 | Medium | 05 | - | resources/recursos-aprendizaje.md |
| MC-015 | Definir metodologia personal de estudio | 1 | Low | 05 | - | resources/metodologia-estudio.md |

## Orden sugerido de ejecucion
1. **Ola 1 (bases, paralelo):** MC-001, MC-002, MC-011 (3 pilares independientes)
2. **Ola 2 (derivados):** MC-003, MC-004, MC-005, MC-006
3. **Ola 3 (combinacion):** MC-007, MC-008, MC-009, MC-012, MC-013
4. **Ola 4 (cierre):** MC-010, MC-014, MC-015

## Completadas (indice)
| ID | Titulo | Puntos | Fecha | Detalle |
|----|--------|--------|-------|---------|
| - | - | - | - | - |

## ID Registry
| Rango | Estado |
|-------|--------|
| MC-001 a MC-015 | Asignados |
| MC-016+ | Disponible |
Proximo ID: MC-016

## DoD (adaptado para investigacion)
- [ ] Nota/documento creado en la carpeta correspondiente
- [ ] Fuentes citadas
- [ ] Ejemplos con caracteres chinos + pinyin incluidos
- [ ] Revision de coherencia completada

## Detalle de stories
Archivos individuales en `backlog/stories/MC-NNN-slug.md`
