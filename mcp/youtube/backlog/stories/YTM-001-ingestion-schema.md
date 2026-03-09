# YTM-001: YouTube Ingestion Schema & Database Layer

**As a** developer building the ingestion pipeline
**I want** dedicated SQLite tables for YouTube video metadata and transcripts with FTS5 indexing
**So that** ingested YouTube content is stored separately from local library files and is searchable via full-text queries

## Acceptance Criteria

**AC1: youtube_videos table creation**
- Given the ingestion database is initialized
- When the schema is applied
- Then a `youtube_videos` table exists with columns: `video_id` (PK, TEXT), `title` (TEXT NOT NULL), `channel` (TEXT NOT NULL), `channel_id` (TEXT), `description` (TEXT), `duration_seconds` (INTEGER), `upload_date` (TEXT), `view_count` (INTEGER), `like_count` (INTEGER), `thumbnail_url` (TEXT), `tags` (TEXT, JSON array), `categories` (TEXT, JSON array), `language` (TEXT), `is_live` (INTEGER), `ingested_at` (TEXT NOT NULL), `updated_at` (TEXT NOT NULL), `ingestion_status` (TEXT NOT NULL DEFAULT 'pending')

**AC2: youtube_transcripts table creation**
- Given the ingestion database is initialized
- When the schema is applied
- Then a `youtube_transcripts` table exists with columns: `video_id` (PK, TEXT, FK to youtube_videos), `language` (TEXT NOT NULL), `source` (TEXT NOT NULL, one of 'manual', 'auto_generated', 'whisper'), `full_text` (TEXT NOT NULL), `segments_json` (TEXT, JSON array of {text, start, duration}), `word_count` (INTEGER), `fetched_at` (TEXT NOT NULL)

**AC3: FTS5 virtual table**
- Given both tables exist
- When the FTS5 index is created
- Then a `youtube_videos_fts` virtual table indexes `title`, `description`, and `full_text` (from transcript) with `video_id` as UNINDEXED key
- And the FTS table uses content sync triggers to stay updated on INSERT, UPDATE, DELETE

**AC4: Indexes**
- Given the schema is applied
- When queries run against common filter patterns
- Then indexes exist on: `youtube_videos(channel)`, `youtube_videos(upload_date)`, `youtube_videos(ingestion_status)`, `youtube_videos(language)`

**AC5: Database class with CRUD operations**
- Given a `YouTubeDatabase` class is instantiated with a db path
- When `upsert_video()` is called with a Pydantic model
- Then the video is inserted or updated in `youtube_videos`
- And when `upsert_transcript()` is called
- Then the transcript is stored and the FTS index is updated
- And when `get_video()` is called with a video_id
- Then the video metadata and transcript (if present) are returned

**AC6: Separate database file**
- Given the config setting `YOUTUBE_DB_PATH` (default `~/.youtube-mcp/youtube.db`)
- When the ingestion database is initialized
- Then it uses a separate SQLite file from the library database (`library.db`)
- And WAL mode, foreign keys, and NORMAL synchronous are enabled

**AC7: Ingestion status tracking**
- Given a video record exists
- When its status is queried
- Then `ingestion_status` is one of: 'pending', 'metadata_ok', 'transcript_ok', 'complete', 'error'
- And `error_message` (TEXT, nullable) stores the last error if status is 'error'

## Technical Notes
- Follow the same patterns as `library/database.py`: parameterized queries, context manager, structlog
- New module location: `src/youtube_mcp/ingestion/` (parallel to `library/`)
- New exception classes in `src/youtube_mcp/ingestion/exceptions.py` using error codes INGESTION_1900-1999
- Pydantic models in `src/youtube_mcp/ingestion/models.py`
- Store tags/categories as JSON strings (like library stores no equivalent; use `json.dumps/loads`)
- Store transcript segments as JSON for reconstruction, but full_text as plain text for FTS

## Definition of Done
- [ ] Code implemented and reviewed
- [ ] Unit tests written and passing (schema creation, CRUD, FTS triggers)
- [ ] WAL mode and pragmas verified in tests
- [ ] No critical bugs
- [ ] Config setting for db path added to Settings class

## Story Points: 3
## Priority: Critical
## Sprint: Backlog
## Epic: EPIC-001 YouTube Video Ingestion
