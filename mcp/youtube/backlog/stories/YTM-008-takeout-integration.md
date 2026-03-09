# YTM-008: Takeout Integration as Ingestion Source

**As a** user who has exported their YouTube data via Google Takeout
**I want** to feed Takeout-parsed video IDs directly into the ingestion pipeline
**So that** I can build a searchable knowledge base from my Watch Later, playlists, and history

## Acceptance Criteria

**AC1: Takeout to ingestion bridge**
- Given a parsed Takeout export (via existing `parse_takeout_zip` or `parse_takeout_folder`)
- When `ingest_from_takeout(playlist_name, videos)` is called
- Then the video IDs are extracted from the Takeout data structure `[{"video_id": str, "time_added": str | None}]`
- And each video ID is passed to the batch ingestion pipeline (YTM-005)
- And `time_added` from Takeout is stored as an additional field in `youtube_videos` (new column `source_added_at`)

**AC2: Ingest specific playlist from Takeout**
- Given a Takeout ZIP or folder path
- When `ingest_takeout_playlist(source_path, playlist_name)` is called
- Then the specified playlist is parsed from the export
- And its video IDs are ingested via the batch pipeline
- And the result includes: playlist_name, total_videos, ingested, failed, skipped

**AC3: Ingest all playlists from Takeout**
- Given a Takeout ZIP or folder path
- When `ingest_all_takeout(source_path)` is called
- Then all playlists in the export are parsed
- And all unique video IDs (deduplicated across playlists) are ingested
- And the result includes per-playlist summaries

**AC4: Source tracking**
- Given a video ingested from Takeout
- When the video record is queried
- Then `ingestion_source` field indicates "takeout" (vs "manual" for direct ingestion, "playlist" for playlist-based)
- And `source_playlist` stores the Takeout playlist name (if applicable)

**AC5: MCP tool for Takeout ingestion**
- Given the MCP server is running
- When the `youtube.ingest_from_takeout` tool is called with `source_path` and optional `playlist_name`
- Then the Takeout is parsed and videos are ingested
- And the result includes the batch summary

## Technical Notes
- Reuse `parse_takeout_zip` and `parse_takeout_folder` from `src/youtube_mcp/playlists/takeout_import.py`
- Add `ingestion_source` (TEXT) and `source_playlist` (TEXT, nullable) columns to `youtube_videos` (update YTM-001 schema if not yet implemented, or add via migration)
- Add `source_added_at` (TEXT, nullable) to preserve the original Takeout timestamp
- The Takeout parser returns `list[dict[str, str | None]]` with `video_id` and `time_added` keys
- For Watch Later specifically, the Takeout export is the only way to access this data (YouTube API does not expose WL)

## Definition of Done
- [ ] Code implemented and reviewed
- [ ] Unit tests: single playlist ingest, all playlists, source tracking, dedup
- [ ] Integration test with a sample Takeout CSV fixture
- [ ] MCP tool registered and functional
- [ ] No critical bugs

## Story Points: 2
## Priority: Medium
## Sprint: Backlog
## Epic: EPIC-001 YouTube Video Ingestion
