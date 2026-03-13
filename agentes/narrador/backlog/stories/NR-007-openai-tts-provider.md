## NR-007: OpenAI TTS provider

**As a** user
**I want** to use OpenAI's TTS API for high-quality narration
**So that** I can generate studio-quality audio when willing to pay for it

### Acceptance Criteria

**AC1: Basic synthesis works**
- Given OPENAI_API_KEY is set in .env
- When I call `synthesize("Hello world", voice="alloy", language="en")`
- Then it returns valid audio bytes from OpenAI TTS API
- And the audio quality is noticeably higher than Edge TTS

**AC2: Voice selection**
- Given OpenAI TTS provider
- When I call `list_voices()`
- Then it returns the available OpenAI voices (alloy, echo, fable, onyx, nova, shimmer)
- And each voice has appropriate metadata

**AC3: Model selection**
- Given the provider supports tts-1 and tts-1-hd models
- When I specify model="tts-1-hd" in config or per-request
- Then the HD model is used for higher quality output

**AC4: Missing API key handling**
- Given OPENAI_API_KEY is not set
- When OpenAI provider is requested
- Then a clear error indicates the key is required
- And the system suggests using Edge TTS as free alternative

**AC5: Rate limit handling**
- Given OpenAI API returns a rate limit error
- When synthesis fails
- Then the error is caught and a TTSError with retry info is raised
- And no partial data is returned

### Technical Notes
- File: `src/narrador/tts/openai_tts.py`
- Use openai Python SDK (openai.audio.speech.create)
- OpenAI TTS supports: alloy, echo, fable, onyx, nova, shimmer voices
- Models: tts-1 (faster, cheaper), tts-1-hd (higher quality)
- Output formats: mp3, opus, aac, flac - default to mp3 for consistency
- OpenAI TTS handles multilingual automatically based on input text

### Definition of Done
- [ ] OpenAITTSProvider implements TTSProvider
- [ ] Registered in provider registry as "openai"
- [ ] synthesize() calls OpenAI API correctly
- [ ] list_voices() returns static voice list with metadata
- [ ] API key validation on init
- [ ] Integration test (marked @pytest.mark.integration, requires key)
- [ ] Error handling for API errors and rate limits

### Story Points: 3
### Priority: High
### Epic: EPIC-002: TTS Core
