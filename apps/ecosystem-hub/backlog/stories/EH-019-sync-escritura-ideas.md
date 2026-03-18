### EH-019: Sync escritura ideas a archivos MD
**Points:** 3 | **Priority:** Medium
**Epic:** EPIC-04: Polish & Integracion
**Dependencies:** EH-014 (crear/editar ideas)

**As a** ecosystem owner
**I want** changes to ideas in the UI to persist back to markdown files
**So that** IDEAS_INDEX.md and individual idea files stay in sync

#### Acceptance Criteria

**AC1: Crear idea persiste al indice**
- Given a new idea is created via the UI
- When the operation completes
- Then a new row is added to the "Ideas Activas" table in IDEAS_INDEX.md
- And the individual idea file is created in the correct category folder

**AC2: Editar idea persiste**
- Given an existing idea is edited via the UI
- When the operation completes
- Then the individual idea file is updated with new content
- And the index row is updated if title, status, or category changed

**AC3: Archivo individual creado correctamente**
- Given a new idea with ID IDEA-048 and category "general"
- When the file is created
- Then it is written to `C:/claude_context/ideas/general/IDEA-048-[slug].md`
- And it follows the IDEA_TEMPLATE.md format

**AC4: Indice no corrompe formato**
- Given IDEAS_INDEX.md has specific table formatting
- When changes are written
- Then table alignment is preserved
- And the rest of the file (estructura, estados, notas sections) is untouched

#### Technical Notes
- Writer reads IDEAS_INDEX.md, modifies table, writes back atomically
- Individual file: use IDEA_TEMPLATE.md as format reference
- Slug generation: lowercase, hyphens, max 50 chars
- Category determines subfolder: projects/, features/, improvements/, general/

#### Definition of Done
- [ ] Crear idea persiste a indice + archivo individual
- [ ] Editar idea actualiza archivo + indice
- [ ] Formato MD preservado
- [ ] Template respetado para archivos nuevos
