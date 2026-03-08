# Learnings - YouTube Content Intelligence MCP
**Actualizacion:** 2026-03-07

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

