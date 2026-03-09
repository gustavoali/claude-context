# YTM-002: Single Video Metadata Ingestion

**As a** user of the MCP server
**I want** to ingest metadata for a single YouTube video by its video ID
**So that** the video's title, channel, description, and other metadata are stored locally for LLM access

## Acceptance Criteria

**AC1: Successful metadata fetch and store**
- Given a valid YouTube video ID (e.g., "dQw4w9WgXcQ")
- When the ingestion service fetches metadata
- Then it uses the existing `MetadataExtractor` to get video metadata via yt-dlp
- And maps the `VideoMetadata` model to the `youtube_videos` table
- And sets `ingestion_status` to 'metadata_ok'
- And returns the stored video record

**AC2: Video already ingested (idempotent update)**
- Given a video ID that already exists in `youtube_videos`
- When metadata ingestion is called for the same video ID
- Then the existing record is updated with fresh metadata
- And `updated_at` is set to the current timestamp
- And no duplicate row is created

**AC3: Private or deleted video handling**
- Given a video ID for a private, deleted, or age-restricted video
- When metadata ingestion is attempted
- Then the video record is created with `ingestion_status` = 'error'
- And `error_message` contains the specific yt-dlp error
- And the operation does not raise an unhandled exception

**AC4: Network error handling**
- Given yt-dlp cannot reach YouTube (network timeout, DNS failure)
- When metadata ingestion is attempted
- Then an appropriate `IngestionError` is raised with error code in INGESTION_1900-1999
- And the video record (if pre-existing) retains its previous state

**AC5: Metadata field mapping**
- Given a successful yt-dlp extraction
- When the result is stored
- Then the following fields are mapped: video_id, title, channel, channel_id, description, duration_seconds, upload_date, view_count, like_count, thumbnail_url, tags (as JSON), categories (as JSON), language, is_live

## Technical Notes
- Reuse `MetadataExtractor` from `src/youtube_mcp/metadata/extractor.py` (do not duplicate yt-dlp logic)
- New file: `src/youtube_mcp/ingestion/service.py` with `IngestionService` class
- `IngestionService` takes `YouTubeDatabase` and `MetadataExtractor` as dependencies (DI)
- Handle the `MetadataExtractionError` from the metadata module and translate to ingestion status

## Definition of Done
- [ ] Code implemented and reviewed
- [ ] Unit tests: success, idempotent update, private video, network error
- [ ] Integration test with real yt-dlp against a known public video (mark as slow/optional)
- [ ] No critical bugs

## Story Points: 2
## Priority: Critical
## Sprint: Backlog
## Epic: EPIC-001 YouTube Video Ingestion
