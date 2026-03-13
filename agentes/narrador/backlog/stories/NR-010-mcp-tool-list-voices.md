## NR-010: MCP tool list_voices

**As a** Claude Code user
**I want** an MCP tool `list_voices` that shows available voices
**So that** I can discover and select the right voice before narrating

### Acceptance Criteria

**AC1: Tool registers in FastMCP**
- Given the narrador MCP server is running
- When Claude Code connects
- Then `list_voices` is available as a tool

**AC2: List voices for a language**
- Given Edge TTS provider is available
- When I call `list_voices(language="es")`
- Then it returns a list of Spanish voices with id, name, gender
- And voices are grouped or tagged by provider

**AC3: List voices for a specific provider**
- Given I specify a provider
- When I call `list_voices(provider="edge-tts", language="en")`
- Then only Edge TTS English voices are returned

**AC4: List all available voices**
- Given no filters
- When I call `list_voices()`
- Then it returns voices from all available providers
- And each voice indicates which provider it belongs to

**AC5: Provider not available**
- Given OPENAI_API_KEY is not set
- When I call `list_voices(provider="openai")`
- Then it returns an error indicating the provider is not configured

### Technical Notes
- File: same `src/narrador/server.py` (additional tool)
- Parameters: language (str, optional), provider (str, optional)
- Return: list of voice objects with provider, id, name, language, gender
- Cache voice lists to avoid repeated API calls (especially for edge-tts which queries a remote endpoint)
- Consider a TTL cache (5 min) for voice listings

### Definition of Done
- [ ] list_voices tool registered in MCP server
- [ ] Filtering by language and provider works
- [ ] Returns structured voice data
- [ ] Voice list caching implemented
- [ ] Integration test with Edge TTS

### Story Points: 3
### Priority: High
### Epic: EPIC-003: MCP Server Integration
