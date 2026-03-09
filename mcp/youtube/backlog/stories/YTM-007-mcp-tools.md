# YTM-007: MCP Tool Exposure

**As a** LLM using the MCP server
**I want** MCP tools to ingest, search, and retrieve YouTube video data
**So that** I can access YouTube content knowledge through the standard MCP protocol

## Acceptance Criteria

**AC1: youtube.ingest_video tool**
- Given the MCP server is running
- When the `youtube.ingest_video` tool is called with a `video_id` parameter
- Then the full ingestion pipeline (metadata + transcript) is executed
- And the result includes: video_id, title, channel, ingestion_status, metadata_fetched, transcript_fetched
- And optional parameter `force` (default false) allows re-ingestion

**AC2: youtube.ingest_batch tool**
- Given the MCP server is running
- When the `youtube.ingest_batch` tool is called with a list of `video_ids`
- Then batch ingestion is executed with progress tracking
- And the result includes: total, completed, failed, skipped, errors
- And optional parameter `source_label` allows tagging the batch (e.g., "takeout-watch-later")

**AC3: youtube.search_videos tool**
- Given ingested videos exist in the database
- When the `youtube.search_videos` tool is called with a `query` parameter
- Then FTS5 search is executed across title, description, and transcript
- And results include: video_id, title, channel, duration_formatted, language, snippet
- And optional filters: channel, language, has_transcript, min_duration, max_duration, limit, offset

**AC4: youtube.get_video_detail tool**
- Given an ingested video exists
- When the `youtube.get_video_detail` tool is called with a `video_id`
- Then the complete metadata and transcript (if available) are returned
- And the response includes: all metadata fields, transcript full_text, transcript source, word_count, segment_count
- And if the video is not in the database, a clear "not found" message is returned

**AC5: youtube.get_ingestion_stats tool**
- Given the ingestion database has data
- When the `youtube.get_ingestion_stats` tool is called
- Then statistics are returned: total_videos, with_transcript, without_transcript, error_count, total_word_count, channels (top 10 by count), languages (distribution)

**AC6: Error handling in MCP layer**
- Given any MCP tool call
- When an internal error occurs (database error, network error, invalid input)
- Then a structured error response is returned (not an unhandled exception)
- And the error includes an error code from the INGESTION_1900-1999 range
- And the MCP server remains stable (does not crash)

## Technical Notes
- New file: `src/youtube_mcp/mcp/ingestion_tools.py` (follows pattern of `library_tools.py`)
- Register tools in `src/youtube_mcp/mcp/server.py` (or `tools.py`)
- Tool naming convention: `youtube.*` prefix (aligns with existing `youtube.get_transcript`, `library.*`)
- For batch ingestion via MCP, consider that MCP calls may have timeout limits; large batches should return a batch_id and allow status polling, OR process synchronously if the list is small (<50)
- Use structlog for operation logging within tools

## Definition of Done
- [ ] Code implemented and reviewed
- [ ] Unit tests for each tool (mocked database/service)
- [ ] Integration test: ingest 1 video via MCP tool, then search for it, then get detail
- [ ] Tools visible in MCP server tool listing
- [ ] No critical bugs

## Story Points: 3
## Priority: High
## Sprint: Backlog
## Epic: EPIC-001 YouTube Video Ingestion
