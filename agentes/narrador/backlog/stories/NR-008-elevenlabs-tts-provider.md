## NR-008: ElevenLabs TTS provider

**As a** user
**I want** to use ElevenLabs for premium voice synthesis with custom voices
**So that** I can generate narration with unique, cloned, or highly expressive voices

### Acceptance Criteria

**AC1: Basic synthesis works**
- Given ELEVENLABS_API_KEY is set in .env
- When I call `synthesize("Hello world", voice="Rachel", language="en")`
- Then it returns valid audio bytes from ElevenLabs API

**AC2: Voice listing from account**
- Given valid API key
- When I call `list_voices()`
- Then it returns voices available in the user's ElevenLabs account
- And includes both default and custom/cloned voices

**AC3: Voice settings**
- Given ElevenLabs supports stability and similarity_boost params
- When custom settings are passed
- Then they are applied to the synthesis request

**AC4: Missing API key handling**
- Given ELEVENLABS_API_KEY is not set
- When the provider is requested
- Then a clear error indicates the key is required

### Technical Notes
- File: `src/narrador/tts/elevenlabs_tts.py`
- Use elevenlabs Python SDK
- ElevenLabs has per-character quota on free tier
- Voice settings: stability (0-1), similarity_boost (0-1), style (0-1)
- Lower priority than Edge TTS and OpenAI - implement after core is stable

### Definition of Done
- [ ] ElevenLabsTTSProvider implements TTSProvider
- [ ] Registered in provider registry as "elevenlabs"
- [ ] synthesize() and list_voices() working
- [ ] Integration test (marked @pytest.mark.integration)
- [ ] Quota/rate limit error handling

### Story Points: 4
### Priority: Medium
### Epic: EPIC-002: TTS Core
