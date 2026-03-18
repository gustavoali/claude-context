### EH-002: Parser de IDEAS_INDEX.md e ideas individuales
**Points:** 5 | **Priority:** Critical
**Epic:** EPIC-01: Backend - File Parsers & REST
**Dependencies:** Ninguna

**As a** backend service
**I want** to parse IDEAS_INDEX.md and individual idea files into structured JSON
**So that** the frontend can browse, filter and display ideas

#### Acceptance Criteria

**AC1: Parse indice de ideas**
- Given `C:/claude_context/ideas/IDEAS_INDEX.md` exists with the standard table
- When the parser reads the file
- Then it returns an array of idea summary objects: `id`, `title`, `category`, `date`, `status`, `file_path`
- And the count matches the rows in the "Ideas Activas" table

**AC2: Parse idea individual**
- Given a path to an individual idea file (e.g., `projects/IDEA-001-agenda-evolution.md`)
- When the parser reads that file
- Then it returns the full content as structured data: title, description (body text), metadata from any frontmatter or headers

**AC3: Categorias correctas**
- Given ideas span categories: projects, features, improvements, general
- When the parser returns the index
- Then each idea has its category correctly extracted from the table's "Categoria" column

**AC4: Estados validos**
- Given ideas have statuses: Seed, Evaluating, Approved, In Progress, Implemented, Paused, Discarded
- When the parser returns ideas
- Then the `status` field contains one of the valid enum values

**AC5: Archivo de idea no encontrado**
- Given the index references a file that does not exist on disk
- When the parser attempts to read the individual idea
- Then it returns the summary data from the index with `detail: null`
- And it logs a warning

#### Technical Notes
- Dos niveles de parsing: indice (tabla MD) y detalle (archivo individual MD libre)
- Para el MVP, el detalle puede ser markdown raw (string) que el frontend renderiza
- Base path: `C:/claude_context/ideas/`
- Cachear indice con TTL de 60s

#### Definition of Done
- [ ] Parser del indice implementado y testeado
- [ ] Parser de idea individual implementado
- [ ] Unit tests (>=70% coverage)
- [ ] Tests con datos reales (47 ideas actuales)
