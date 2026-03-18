### EH-018: Sync escritura alertas a ALERTS.md
**Points:** 3 | **Priority:** High
**Epic:** EPIC-04: Polish & Integracion
**Dependencies:** EH-010 (crear/resolver alertas desde UI)

**As a** ecosystem owner
**I want** changes made to alerts in the UI to persist back to ALERTS.md
**So that** the markdown files stay in sync and Claude sessions can read updated data

#### Acceptance Criteria

**AC1: Resolver alerta persiste**
- Given an active alert is resolved via the UI
- When the operation completes
- Then the alert row moves from "Alertas Activas" to "Historial" in ALERTS.md
- And the resolution notes and date are written in the historial row

**AC2: Crear alerta persiste**
- Given a new alert is created via the UI
- When the operation completes
- Then a new row is added to the "Alertas Activas" table in ALERTS.md
- And the markdown table formatting is preserved

**AC3: Formato tabla preservado**
- Given ALERTS.md has a specific markdown table format
- When the backend writes changes
- Then the table alignment and separators are preserved
- And no other content in the file is altered

**AC4: Scope correcto**
- Given an alert is created with scope "jerarquicos"
- When the write happens
- Then it writes to `C:/claude_context/jerarquicos/ALERTS.md` (not global)

**AC5: Concurrent safety**
- Given the file might be read by Claude sessions simultaneously
- When the backend writes to ALERTS.md
- Then it uses atomic write (write to temp file + rename) to prevent corruption

#### Technical Notes
- Writer module: reads file, parses, modifies in-memory, serializes back to MD, atomic write
- Preserve the "Ultima revision" date at the top of the file
- Markdown table serialization: maintain column widths from original
- File paths from same config as EH-001

#### Definition of Done
- [ ] Resolver alerta persiste a archivo correcto
- [ ] Crear alerta persiste a archivo correcto
- [ ] Formato tabla no se corrompe
- [ ] Atomic write implementado
- [ ] Tests con archivo real (copy de ALERTS.md)
