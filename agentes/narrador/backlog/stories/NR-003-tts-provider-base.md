## NR-003: TTS provider base (strategy pattern)

**As a** developer
**I want** an abstract base class and registry for TTS providers
**So that** new providers can be added without modifying existing code

### Acceptance Criteria

**AC1: Abstract base class defined**
- Given I import `narrador.tts.base`
- When I inspect TTSProvider
- Then it defines abstract methods: `synthesize(text, voice, language) -> bytes` and `list_voices(language) -> list[Voice]`
- And it defines a `name` property returning the provider identifier

**AC2: Voice model defined**
- Given the base module
- When I inspect the Voice dataclass
- Then it has fields: id (str), name (str), language (str), gender (str | None)
- And it can be serialized to dict for MCP tool responses

**AC3: Provider registry works**
- Given multiple providers are implemented
- When I call `get_provider("edge-tts")`
- Then it returns the Edge TTS provider instance
- And calling `get_provider("nonexistent")` raises a clear error

**AC4: Strategy selection at runtime**
- Given config has DEFAULT_PROVIDER set
- When the system starts
- Then the default provider is used unless overridden per-request
- And any registered provider can be selected by name

### Technical Notes
- File: `src/narrador/tts/base.py`
- Use ABC (Abstract Base Class) from Python stdlib
- Registry pattern: dict mapping name -> class, with factory function
- Voice dataclass with `@dataclass` decorator
- synthesize() returns raw audio bytes, format handling is caller's responsibility
- Consider async: edge-tts is async, openai SDK supports async. Base should define both sync and async or use async only.

### Definition of Done
- [ ] TTSProvider ABC with abstract methods
- [ ] Voice dataclass
- [ ] Provider registry (register/get functions)
- [ ] Unit tests for registry logic
- [ ] Type hints on all public interfaces

### Story Points: 3
### Priority: Critical
### Epic: EPIC-002: TTS Core
