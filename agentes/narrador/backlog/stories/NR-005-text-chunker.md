## NR-005: Text chunker para textos largos

**As a** user
**I want** long texts to be split into natural segments before synthesis
**So that** TTS providers can handle texts exceeding their input limits without cutting mid-sentence

### Acceptance Criteria

**AC1: Paragraph-level chunking**
- Given a text with multiple paragraphs (separated by double newlines)
- When I call `chunk_text(text, max_chars=5000)`
- Then each chunk respects paragraph boundaries
- And no chunk exceeds max_chars

**AC2: Sentence-level chunking for long paragraphs**
- Given a single paragraph exceeding max_chars
- When chunking is applied
- Then the paragraph is split at sentence boundaries (. ! ?)
- And no sentence is split mid-word

**AC3: Markdown stripping**
- Given text with markdown formatting (headers, bold, links, lists)
- When preprocessing is applied
- Then markdown syntax is stripped to plain text
- And the readable content is preserved

**AC4: Short text passthrough**
- Given a text shorter than max_chars
- When chunk_text() is called
- Then it returns a single chunk with the original text
- And no unnecessary processing occurs

**AC5: Empty and edge cases**
- Given empty string, whitespace-only, or None input
- When chunk_text() is called
- Then it returns an empty list
- And no errors are raised

### Technical Notes
- File: `src/narrador/text/chunker.py`
- Use Python stdlib for sentence splitting (re module with regex for sentence boundaries)
- Do NOT add spacy dependency for MVP - keep it simple with regex
- max_chars default: 5000 (Edge TTS handles up to ~10K but smaller chunks = better quality)
- Return: `list[str]` where each string is a chunk
- Consider preserving chunk order metadata (index) for assembly

### Definition of Done
- [ ] chunk_text() function implemented
- [ ] Paragraph and sentence-level splitting works
- [ ] Markdown stripping (basic: headers, bold, italic, links)
- [ ] Unit tests covering all AC scenarios
- [ ] Edge cases: empty input, single word, unicode, very long sentences

### Story Points: 3
### Priority: Critical
### Epic: EPIC-002: TTS Core
