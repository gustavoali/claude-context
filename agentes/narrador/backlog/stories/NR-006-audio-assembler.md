## NR-006: Audio assembler (concatenar chunks)

**As a** user
**I want** multiple audio chunks to be concatenated into a single output file
**So that** I get one continuous audio file from a long text narration

### Acceptance Criteria

**AC1: Concatenation of MP3 chunks**
- Given a list of MP3 audio byte segments
- When I call `assemble(chunks, output_path, format="mp3")`
- Then a single MP3 file is created at output_path
- And the audio plays continuously without gaps or clicks

**AC2: WAV output support**
- Given MP3 chunks
- When I call `assemble(chunks, output_path, format="wav")`
- Then the output is a valid WAV file
- And the audio content is identical to the MP3 version

**AC3: Silence insertion between chunks**
- Given chunks and a pause_ms parameter
- When I call `assemble(chunks, output_path, pause_ms=500)`
- Then 500ms of silence is inserted between each chunk
- And no silence is added before the first or after the last chunk

**AC4: Single chunk passthrough**
- Given a list with one chunk
- When assembly is called
- Then the chunk is written directly to output_path without processing
- And the output format matches the requested format

**AC5: File naming and output directory**
- Given config.output_dir is set
- When assembly completes without explicit output_path
- Then the file is saved to output_dir with a timestamped name
- And the full path is returned

### Technical Notes
- File: `src/narrador/audio/assembler.py`
- Use pydub for audio manipulation (AudioSegment)
- pydub requires ffmpeg installed for MP3 support - document this
- Consider: ffmpeg is often available in WSL, add to project prerequisites
- Return the output file path as string for MCP tool response
- Default pause between chunks: 300ms (natural reading pace)

### Definition of Done
- [ ] assemble() function implemented
- [ ] MP3 and WAV output formats working
- [ ] Silence insertion between chunks
- [ ] Unit tests with sample audio bytes
- [ ] ffmpeg dependency documented in README/pyproject.toml

### Story Points: 3
### Priority: Critical
### Epic: EPIC-002: TTS Core
