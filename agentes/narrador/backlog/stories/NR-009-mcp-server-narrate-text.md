## NR-009: MCP server con tool narrate_text

**As a** Claude Code user
**I want** an MCP tool `narrate_text` that converts text to audio
**So that** I can generate narration directly from my Claude Code sessions

### Acceptance Criteria

**AC1: Tool registers in FastMCP**
- Given the narrador MCP server is running
- When Claude Code connects to it
- Then the `narrate_text` tool is listed among available tools

**AC2: Basic narration (short text)**
- Given a text under 5000 characters
- When I call `narrate_text(text="Hola mundo, esto es una prueba")`
- Then it returns the path to a generated MP3 file
- And the file exists and is playable

**AC3: Long text narration with chunking**
- Given a text over 5000 characters
- When I call `narrate_text(text=long_text)`
- Then the text is chunked, each chunk synthesized, and assembled into one file
- And the output plays continuously

**AC4: Provider selection**
- Given multiple providers are registered
- When I call `narrate_text(text="...", provider="openai")`
- Then the specified provider is used
- And omitting provider uses the default (edge-tts)

**AC5: Voice and language selection**
- Given I specify voice and language
- When I call `narrate_text(text="...", voice="es-AR-ElenaNeural", language="es")`
- Then the specified voice and language are used

**AC6: Output format selection**
- Given I specify format
- When I call `narrate_text(text="...", format="wav")`
- Then the output is in WAV format
- And default format is MP3

**AC7: Error response**
- Given an invalid provider name
- When narrate_text is called
- Then a clear error message is returned (not a stack trace)
- And the MCP tool response indicates failure

### Technical Notes
- File: `src/narrador/server.py`
- Use FastMCP (`from mcp.server.fastmcp import FastMCP`)
- Tool parameters: text (str, required), provider (str, optional), voice (str, optional), language (str, optional, default "es"), format (str, optional, default "mp3"), output_filename (str, optional)
- Return: dict with path, duration_seconds, provider_used, chunks_count
- The tool orchestrates: chunk_text -> synthesize per chunk -> assemble -> return path
- Server entry point: `python -m narrador.server`

### Definition of Done
- [ ] FastMCP server starts correctly
- [ ] narrate_text tool registered and callable
- [ ] Full pipeline: chunking -> synthesis -> assembly working
- [ ] All parameters handled correctly
- [ ] Error responses are user-friendly
- [ ] Integration test: end-to-end with Edge TTS
- [ ] Server can be added to claude settings.json

### Story Points: 3
### Priority: Critical
### Epic: EPIC-003: MCP Server Integration
