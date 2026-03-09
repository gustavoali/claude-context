# YTM-004: Combined Single Video Ingestion Pipeline

**As a** user of the MCP server
**I want** to ingest both metadata and transcript for a video in a single operation
**So that** I can populate the database with complete video information in one step

## Acceptance Criteria

**AC1: Full ingestion pipeline**
- Given a valid YouTube video ID
- When `ingest_video(video_id)` is called
- Then metadata is fetched first via yt-dlp
- And transcript is fetched second via youtube-transcript-api
- And both are stored in their respective tables
- And `ingestion_status` is set to 'complete'
- And the FTS index contains title + description + transcript text

**AC2: Partial success (metadata ok, transcript unavailable)**
- Given a video that has metadata but no subtitles
- When the full ingestion pipeline runs
- Then metadata is stored successfully
- And `ingestion_status` is set to 'metadata_ok'
- And the FTS index contains title + description (without transcript)
- And the return value indicates transcript was unavailable (not an error)

**AC3: Total failure (video private/deleted)**
- Given a video ID for a private or deleted video
- When the full ingestion pipeline runs
- Then `ingestion_status` is set to 'error'
- And `error_message` describes the failure
- And the pipeline does not raise an unhandled exception

**AC4: Return model with ingestion summary**
- Given any ingestion attempt
- When the pipeline completes
- Then an `IngestionResult` model is returned with: video_id, status, metadata_fetched (bool), transcript_fetched (bool), error_message (optional), duration_ms (processing time)

**AC5: Skip if already complete (optional force flag)**
- Given a video ID that already has `ingestion_status` = 'complete'
- When `ingest_video(video_id)` is called without `force=True`
- Then the existing data is returned without re-fetching
- And when called with `force=True`
- Then metadata and transcript are re-fetched and updated

## Technical Notes
- This story composes the work from YTM-002 and YTM-003 into a single `ingest_video()` method on `IngestionService`
- The method should be async-friendly (the MCP tools layer is async via FastMCP)
- Wrap yt-dlp calls carefully: they are synchronous and can block; consider `asyncio.to_thread()` if needed
- Transaction: metadata insert + transcript insert should be in a single SQLite transaction where possible

## Definition of Done
- [ ] Code implemented and reviewed
- [ ] Unit tests: full success, partial success, total failure, skip-if-complete, force re-fetch
- [ ] E2E test with a known public video (mark as slow/optional)
- [ ] No critical bugs

## Story Points: 3
## Priority: High
## Sprint: Backlog
## Epic: EPIC-001 YouTube Video Ingestion
