# MEW-039: Formato SER y exportacion de recetas
**Epic:** E11 - Recetas Personalizadas
**Version:** v2.0
**Story Points:** 8
**Priority:** Low
**Status:** Pending
**DoR Level:** 2

---

## User Story

**As a** usuario de Mew Michis
**I want** exportar mis recetas en formato estandar
**So that** pueda compartirlas o hacer backup

---

## Acceptance Criteria

**AC1: Definicion de formato SER**
- Given que defino el formato
- When documento la estructura
- Then incluye: metadata, ingredientes, suplementos, reglas, version
- And es JSON versionado

**AC2: Exportar receta individual**
- Given que tengo una receta (oficial o custom)
- When toco "Exportar"
- Then genera archivo .ser.json
- And puedo compartirlo

**AC3: Exportar menu completo**
- Given que tengo un menu semanal
- When exporto el menu
- Then genera archivo con las 7 recetas usadas
- And mantiene las variaciones aplicadas

**AC4: Metadata de exportacion**
- Given que exporto una receta
- When reviso el archivo
- Then incluye: fecha, version del motor, autor, tipo
- And es trazable

---

## Technical Notes
- Formato JSON con schema definido
- Version del formato para compatibilidad futura
- Usar file_picker para guardar
- SER = Standard Export Recipe (formato propio de Mew Michis)
- Definir schema JSON versionado para evitar incompatibilidades

---

## Dependencies
- MEW-037 (Modelo recetas extendidas) - OBLIGATORIO, define estructura base
- Package file_picker

---

## Definition of Done
- [ ] Schema SER definido y documentado
- [ ] Exportacion de receta individual
- [ ] Exportacion de menu completo
- [ ] Documentacion del formato
- [ ] Unit tests
- [ ] Integration tests
- [ ] Code review aprobado
- [ ] Build 0 warnings
