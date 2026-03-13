## NR-004: Edge TTS provider (default gratis)

**As a** user
**I want** text-to-speech using Edge TTS as the default free provider
**So that** I can generate audio without any API keys or costs

### Acceptance Criteria

**AC1: Basic synthesis works**
- Given I have the Edge TTS provider
- When I call `synthesize("Hola mundo", voice="es-AR-ElenaNeural", language="es")`
- Then it returns valid MP3 audio bytes
- And the audio is audible and matches the requested text

**AC2: English synthesis works**
- Given Edge TTS provider
- When I call `synthesize("Hello world", voice="en-US-AriaNeural", language="en")`
- Then it returns valid MP3 audio bytes in English

**AC3: Voice listing works**
- Given Edge TTS provider
- When I call `list_voices(language="es")`
- Then it returns a list of Voice objects for Spanish voices
- And each voice has id, name, language, and gender populated

**AC4: Default voice selection**
- Given no specific voice is requested
- When I call `synthesize("text", language="es")`
- Then it uses a sensible default Spanish voice
- And for language="en" it uses a sensible default English voice

**AC5: Error handling**
- Given Edge TTS service is unavailable (network error)
- When synthesis is attempted
- Then a clear TTSError is raised with the original error context
- And no partial files are left on disk

### Technical Notes
- File: `src/narrador/tts/edge_tts.py`
- edge-tts library is async (uses `edge_tts.Communicate`)
- Implementation must handle async: either run in event loop or use asyncio.run()
- Edge TTS outputs MP3 natively
- Voice IDs follow pattern: `{lang}-{region}-{Name}Neural` (e.g., `es-AR-ElenaNeural`)
- No API key needed - this is the zero-config default provider

### Definition of Done
- [ ] EdgeTTSProvider implements TTSProvider
- [ ] Registered in provider registry as "edge-tts"
- [ ] synthesize() returns valid MP3 bytes
- [ ] list_voices() returns real voice list from edge-tts
- [ ] Default voices for es and en configured
- [ ] Integration test with actual Edge TTS (marks: @pytest.mark.integration)
- [ ] Error handling for network failures

### Story Points: 3
### Priority: Critical
### Epic: EPIC-002: TTS Core
