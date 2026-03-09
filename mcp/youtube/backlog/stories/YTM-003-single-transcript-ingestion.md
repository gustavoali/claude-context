# YTM-003: Single Video Transcript Ingestion

**As a** user of the MCP server
**I want** to ingest the transcript for a single YouTube video by its video ID
**So that** the video's spoken content is stored locally and searchable via full-text queries

## Acceptance Criteria

**AC1: Successful transcript fetch and store (manual subtitles)**
- Given a video ID with manually-created subtitles available
- When the ingestion service fetches the transcript
- Then it uses the existing transcript extractor (youtube-transcript-api)
- And stores full_text, segments_json, language, source='manual', word_count in `youtube_transcripts`
- And sets `ingestion_status` to 'transcript_ok' (or 'complete' if metadata also present)
- And the FTS index is updated with the transcript text

**AC2: Fallback to auto-generated subtitles**
- Given a video ID with only auto-generated subtitles
- When manual subtitles are not available
- Then auto-generated subtitles are fetched instead
- And `source` is set to 'auto_generated'
- And `is_generated` semantics are preserved

**AC3: Language preference**
- Given the config setting `youtube_prefer_langs` (default "es,en")
- When multiple subtitle languages are available
- Then the preferred language is selected according to the configured order
- And the `language` field reflects the actually fetched language

**AC4: No transcript available**
- Given a video ID with no subtitles (manual or auto-generated)
- When transcript ingestion is attempted
- Then `ingestion_status` is set to 'metadata_ok' (transcript unavailable, not an error)
- And a note is stored in `error_message`: "No transcript available"
- And the operation does not fail

**AC5: Transcript update (idempotent)**
- Given a video ID with an existing transcript in `youtube_transcripts`
- When transcript ingestion is called again
- Then the existing transcript is replaced with the new data
- And `fetched_at` is updated
- And the FTS index is refreshed

**AC6: Private or deleted video**
- Given a video ID that is private or deleted
- When transcript ingestion is attempted
- Then the error is recorded gracefully (same pattern as AC4)
- And `ingestion_status` reflects the failure

## Technical Notes
- Reuse `TranscriptExtractor` from `src/youtube_mcp/transcript/extractor.py`
- Be aware of youtube-transcript-api v1.2.3 breaking changes (see LEARNINGS.md): instance-based API, `.to_raw_data()` on fetch result
- Store `segments_json` as `json.dumps([{"text": ..., "start": ..., "duration": ...}, ...])` for reconstruction
- `full_text` is the concatenated segment text (spaces between segments) for FTS indexing
- Calculate `word_count` from `full_text.split()`

## Definition of Done
- [ ] Code implemented and reviewed
- [ ] Unit tests: manual subs, auto fallback, no transcript, idempotent update, private video
- [ ] FTS index verified to contain transcript text after ingestion
- [ ] No critical bugs

## Story Points: 2
## Priority: Critical
## Sprint: Backlog
## Epic: EPIC-001 YouTube Video Ingestion
