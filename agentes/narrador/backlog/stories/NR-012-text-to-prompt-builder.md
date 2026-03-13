## NR-012: Text-to-prompt builder para imagenes

**As a** user
**I want** the system to extract key concepts from text and generate image prompts
**So that** generated images accurately illustrate the narrated content

### Acceptance Criteria

**AC1: Key concept extraction**
- Given a paragraph of text describing a scene
- When I call `build_prompt(text, style="illustration")`
- Then it returns an image generation prompt with key visual elements

**AC2: Style presets**
- Given predefined styles (illustration, photorealistic, watercolor, cartoon)
- When I specify a style
- Then the generated prompt incorporates the style directive

**AC3: Sectioned text processing**
- Given a long text with multiple sections/paragraphs
- When I call `build_prompts_for_sections(text, sections_count=3)`
- Then it returns one prompt per logical section
- And each prompt captures different visual aspects

**AC4: Language handling**
- Given text in Spanish
- When building prompts
- Then the output prompts are in English (better for image models)
- And key concepts are correctly translated

### Technical Notes
- File: `src/narrador/text/prompt_builder.py`
- Simple keyword/NLP extraction for MVP (no LLM in the loop)
- Style presets as enum or dict of prompt suffixes
- For Spanish->English concept translation, keep a basic bilingual dictionary or use the text as-is (DALL-E handles Spanish prompts reasonably)
- Etapa 2 - lower priority, implement after image provider base

### Definition of Done
- [ ] build_prompt() function implemented
- [ ] Style presets working
- [ ] Section splitting for multi-prompt generation
- [ ] Unit tests with sample texts
- [ ] Both Spanish and English input tested

### Story Points: 3
### Priority: Low
### Epic: EPIC-004: Image Generation (Etapa 2)
