# MC-012: Investigar la relacion entre pronunciacion y componentes foneticos
**Points:** 3 | **Priority:** Medium | **Epic:** EPIC-04 | **Deps:** MC-005

**As a** estudiante de mandarin
**I want** entender como los componentes foneticos de los caracteres dan pistas de pronunciacion
**So that** pueda usar la estructura del caracter para inferir su sonido

## Acceptance Criteria

**AC1: Series foneticas documentadas**
- Given que grupos de caracteres comparten componente fonetico y sonido similar
- When investigo las series foneticas
- Then documento al menos 10 series (un componente fonetico + 5 caracteres derivados)
- And para cada serie indico que tan confiable es la pista fonetica en mandarin moderno

**AC2: Tasa de confiabilidad**
- Given que no todos los componentes foneticos siguen siendo predictivos
- When analizo las series
- Then calculo o cito un porcentaje aproximado de confiabilidad del sistema fonetico
- And explico los factores historicos que degradaron la prediccion

## Technical Notes
- Depende parcialmente de MC-005 (composicion fonetico-semantica)
- Output: notes/componentes-foneticos.md
