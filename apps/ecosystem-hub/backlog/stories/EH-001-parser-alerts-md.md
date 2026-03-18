### EH-001: Parser de ALERTS.md
**Points:** 3 | **Priority:** Critical
**Epic:** EPIC-01: Backend - File Parsers & REST
**Dependencies:** Ninguna

**As a** backend service
**I want** to parse ALERTS.md files into structured JSON
**So that** the frontend can consume alerts without parsing markdown

#### Acceptance Criteria

**AC1: Parse alertas activas**
- Given the file `C:/claude_context/ALERTS.md` exists with the standard table format
- When the parser reads the file
- Then it returns an array of alert objects with fields: `date`, `type`, `message`, `action`, `status: "active"`, `scope: "global"`
- And each row of the "Alertas Activas" table becomes one object

**AC2: Parse historial**
- Given ALERTS.md contains a "Historial" section
- When the parser reads the file
- Then it returns historical alerts with fields: `date`, `type`, `message`, `resolution`, `status: "resolved"`

**AC3: Soporte multi-archivo**
- Given both `C:/claude_context/ALERTS.md` and `C:/claude_context/jerarquicos/ALERTS.md` exist
- When the parser is called with a scope parameter
- Then it returns alerts from the corresponding file with the correct scope (`global` or `jerarquicos`)

**AC4: Archivo no encontrado**
- Given a configured alerts file path does not exist
- When the parser attempts to read it
- Then it returns an empty array without throwing an error
- And it logs a warning

**AC5: Formato corrupto**
- Given ALERTS.md has rows that don't match the expected column count
- When the parser reads the file
- Then malformed rows are skipped with a warning log
- And valid rows are still returned

#### Technical Notes
- Parser como modulo independiente en el backend Fastify (extension de Project Admin)
- Markdown table parsing: usar regex o libreria ligera (no full markdown AST)
- Paths configurables via environment variables o config file
- Cachear resultado con TTL de 30s para evitar I/O excesivo en polling

#### Definition of Done
- [ ] Codigo implementado y revisado
- [ ] Unit tests (>=70% coverage del parser)
- [ ] Manejo de errores (archivo inexistente, formato corrupto)
- [ ] Tests pasan con datos reales de ALERTS.md actual
