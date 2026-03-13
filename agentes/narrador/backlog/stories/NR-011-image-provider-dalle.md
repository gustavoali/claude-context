## NR-011: Image provider base + DALL-E 3

**As a** user
**I want** to generate images from text descriptions using DALL-E 3
**So that** I can create visual content to accompany narrated text

### Acceptance Criteria

**AC1: ImageProvider abstract base**
- Given the imagegen module
- When I inspect ImageProvider
- Then it defines abstract methods: `generate(prompt, size, style) -> ImageResult`
- And ImageResult contains: bytes, format, width, height, revised_prompt

**AC2: DALL-E 3 generation works**
- Given OPENAI_API_KEY is set
- When I call `generate(prompt="A sunset over mountains", size="1024x1024")`
- Then it returns a valid PNG image
- And the image matches the prompt description

**AC3: Size and style options**
- Given DALL-E 3 provider
- When I specify size="1792x1024" and style="natural"
- Then the generated image uses those parameters

**AC4: Missing API key handling**
- Given OPENAI_API_KEY is not set
- When DALL-E provider is requested
- Then a clear error indicates the key is required

### Technical Notes
- Files: `src/narrador/imagegen/base.py`, `src/narrador/imagegen/dalle.py`
- Use openai Python SDK (openai.images.generate)
- DALL-E 3 sizes: 1024x1024, 1792x1024, 1024x1792
- DALL-E 3 styles: vivid (default), natural
- This is Etapa 2 - implement after TTS MVP is complete
- Same strategy pattern as TTS providers

### Definition of Done
- [ ] ImageProvider ABC defined
- [ ] ImageResult dataclass
- [ ] DalleProvider implements ImageProvider
- [ ] Integration test (requires API key)
- [ ] Error handling

### Story Points: 3
### Priority: Low
### Epic: EPIC-004: Image Generation (Etapa 2)
