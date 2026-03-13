# Learnings - YouTube Content Intelligence MCP
**Actualizacion:** 2026-03-08

## Patrones del Proyecto
- Pipeline secuencial: URL -> Metadata -> Transcript (subs o Whisper) -> Processing -> Artifacts
- Cada modulo tiene su propio exceptions.py con error codes del taxonomy
- Cache en disco con TTL diferenciado (transcripts 24h, metadata 1h)
- FastMCP como framework MCP (stdio transport)

### 2026-03-07 - youtube-transcript-api v1.2.3 breaking API change
**Context:** Tests passed but E2E against real YouTube failed. The `youtube-transcript-api` library changed from class methods to instance-based API.
**Learning:** `YouTubeTranscriptApi.list_transcripts(video_id)` became `YouTubeTranscriptApi().list(video_id)`, and `transcript.fetch()` now returns a `FetchedTranscript` object instead of `list[dict]`. Use `.to_raw_data()` on the result to get back the `list[dict]` format. When mocking, `mock_api_class.list_transcripts` becomes `mock_api_class.return_value.list`, and `fetch()` mocks need an intermediate mock object with `.to_raw_data()`.
**Applies to:** Any project using `youtube-transcript-api` >= 1.0

### 2026-03-07 - Windows cp1252 console encoding breaks on Unicode output
**Context:** E2E test succeeded but printing transcript text with musical note characters (ÔÖ¬) caused `UnicodeEncodeError: 'charmap' codec can't encode characters` on Windows console using cp1252.
**Learning:** When printing text that may contain Unicode to Windows console, use `.encode('ascii', errors='replace').decode('ascii')` or set `PYTHONIOENCODING=utf-8`. This is a Windows-specific issue with the default console encoding (cp1252), not a bug in the application code.
**Applies to:** Any Python project doing console output on Windows with non-ASCII text

### 2026-03-08 - Artifact generators have inconsistent method names
**Context:** E2E pipeline test failed with `AttributeError: 'KeyPointExtractor' object has no attribute 'generate'` when trying to call `.generate()` on all artifact classes uniformly.
**Learning:** The artifact classes use different method names: `SummaryGenerator.generate()` and `TimelineGenerator.generate()` vs `KeyPointExtractor.extract()` and `ClaimClassifier.extract()`. When calling these classes, check the actual method name per class rather than assuming a uniform API.
**Applies to:** This project (youtube-mcp artifacts module)

### 2026-03-08 - YouTube Data API v3 cannot access Watch Later and Liked Videos playlists
**Context:** After implementing playlist tools and authenticating via OAuth2, user asked why "Watch Later" didn't appear in the playlist listing.
**Learning:** YouTube's system playlists (Watch Later = `WL`, Liked Videos = `LL`) are **not accessible** via the YouTube Data API v3. The API returns 403 when trying to read them, even with proper authentication. Only user-created playlists are returned by `playlists.list(mine=True)`. Workaround: Google Takeout export or manually copying videos to a user-created playlist.
**Applies to:** Any project using YouTube Data API v3 for playlist management

### 2026-03-08 - Google OAuth2 "installed" app flow with token persistence
**Context:** Setting up OAuth2 for YouTube API access using a Desktop app credential (`client_secret.json` with type `installed`).
**Learning:** For Desktop/CLI apps, use `google-auth-oauthlib` `InstalledAppFlow.from_client_secrets_file()` with `run_local_server()`. This opens the browser for user consent and spins up a temporary localhost redirect server. Save the resulting credentials to a `token.json` file and reload on subsequent runs to avoid re-authentication. Token includes refresh token when `access_type=offline` is set.
**Applies to:** Any Python project needing YouTube API or Google API access from CLI/desktop apps

### 2026-03-08 - YouTube Data API v3 quota costs for batch playlist operations
**Context:** Needed to add 744 videos to new playlists. Each `playlistItems.insert` costs 50 quota units, and the daily limit is 10,000 units, meaning only ~180 video inserts per day are possible.
**Learning:** YouTube Data API v3 has a daily quota of 10,000 units per project. Read operations (`list`) cost 1 unit, but write operations (`insert`, `create`) cost 50 units each. `playlistItems.delete` also costs 50 units. For batch operations involving hundreds of playlist inserts, plan for multi-day execution (~180 inserts/day max). Quota resets at midnight Pacific Time (follows DST: PDT in summer, PST in winter). In Argentina (ART, UTC-3 fijo): reset a ~04:00 ART durante PDT, ~05:00 ART durante PST. **Nota:** durante el cambio DST (segundo domingo de Marzo en USA) puede haber desfase. Considerar also que delete operations (mover videos = delete + insert) consumen cuota doble. Consider fetching all data first (cheap reads), then batching writes across days. Monitor via Google Cloud Console > IAM & Admin > Quotas.
**Applies to:** Any project doing bulk YouTube Data API v3 write operations (playlist management, video uploads, etc.)

### 2026-03-08 - Google Takeout playlist files have `-videos` suffix in filenames
**Context:** Trying to import Watch Later from a Takeout ZIP. The `import_watch_later` function searched for a playlist named `"watch later"` but the parsed dict contained `"Watch later-videos"` because the filename was `Watch later-videos.csv`.
**Learning:** Google Takeout names playlist CSV files as `<playlist_name>-videos.csv` (and `<name>-videos(N).csv` for duplicates). When parsing Takeout exports, strip the `-videos` suffix from the filename stem to recover the original playlist name. Use regex `r"-videos(?:\(\d+\))?$"` to handle both patterns. Without this, playlist name matching (e.g., looking for "Watch Later") will fail because the parsed name retains the suffix.
**Applies to:** Any project parsing Google Takeout YouTube exports

### 2026-03-08 - YouTube API "Precondition check failed" for unavailable videos
**Context:** During batch import of Watch Later videos from Takeout, video `et3lsC88iRc` returned HTTP 400 with `"Precondition check failed"` (`failedPrecondition`) when trying to add it to a playlist via `playlistItems.insert`.
**Learning:** The YouTube Data API v3 returns HTTP 400 with reason `failedPrecondition` when attempting to add a video that is deleted, private, or otherwise unavailable to a playlist. This is distinct from a 404 (video not found) - the API uses 400 with this specific reason. In batch import scripts, catch this as a non-fatal error and skip the video rather than halting the entire import.
**Applies to:** Any project doing bulk playlist operations via YouTube Data API v3

### 2026-03-09 - SQLite idempotent schema migrations via ALTER TABLE with try/except
**Context:** Adding source tracking columns (`ingestion_source`, `source_playlist`, `source_added_at`) to an existing SQLite table in the ingestion module. Needed the migration to be safe to run multiple times.
**Learning:** SQLite does not support `IF NOT EXISTS` for `ALTER TABLE ADD COLUMN`. The idiomatic pattern is to wrap each `ALTER TABLE` statement in its own `try/except sqlite3.OperationalError: pass` block. This makes the migration idempotent - it succeeds on first run and silently skips on subsequent runs. Execute each statement individually (not as a batch via `executescript`) so that one existing column doesn't prevent the others from being added. Commit after all migrations complete.
**Applies to:** Any Python project using SQLite that needs to evolve schemas without a dedicated migration framework (Alembic, etc.)

