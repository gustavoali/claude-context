# YTM-006: FTS5 Search Across Ingested Videos

**As a** user (or LLM via MCP)
**I want** to search across all ingested YouTube videos by keywords in title, description, and transcript
**So that** I can find relevant video content quickly for question answering, research, or reference

## Acceptance Criteria

**AC1: Basic text search**
- Given 10+ videos ingested with metadata and transcripts
- When a search query "machine learning" is executed
- Then videos matching in title, description, OR transcript text are returned
- And results are ranked by FTS5 relevance (bm25)
- And each result includes: video_id, title, channel, duration, language, snippet (highlighted match context)

**AC2: Search with filters**
- Given ingested videos from multiple channels and languages
- When a search is executed with filters (channel, language, min_duration, max_duration, has_transcript)
- Then only videos matching ALL filters AND the text query are returned
- And filters work independently (can filter without text query)

**AC3: Pagination**
- Given a search query that matches 100+ videos
- When `limit=20, offset=0` is provided
- Then the first 20 results are returned
- And `total` reflects the total number of matches (not just the page)
- And `offset=20` returns the next page

**AC4: Empty results**
- Given a search query with no matches
- When the search is executed
- Then an empty result set is returned with total=0
- And no error is raised

**AC5: Search performance**
- Given a database with 1000 ingested videos
- When a search query is executed
- Then results are returned in <100ms
- And FTS5 indexes are used (no full table scans)

**AC6: Snippet extraction**
- Given a search match found in a transcript
- When the result is returned
- Then a `snippet` field contains ~200 characters of context around the match
- And the matched terms are identifiable (prefix/suffix markers or separate field)

**AC7: Search result model**
- Given a search query
- When results are returned
- Then the result model contains: videos (list of YouTubeVideoSummary), total (int), query (str), filters (dict), search_time_ms (float)

## Technical Notes
- Follow the same search patterns as `library/database.py` (FTS5 pre-filter, then SQL filters)
- Use FTS5 `bm25()` ranking function for relevance ordering
- Use FTS5 `snippet()` function for context extraction
- The FTS table indexes: title + description (from youtube_videos) + full_text (from youtube_transcripts)
- This requires a JOIN between youtube_videos and youtube_transcripts in the FTS content sync
- Alternative: denormalized FTS table with all text fields concatenated (simpler, consider tradeoffs)
- `YouTubeSearchQuery` and `YouTubeSearchResult` Pydantic models in `ingestion/models.py`

## Definition of Done
- [ ] Code implemented and reviewed
- [ ] Unit tests: text search, filtered search, pagination, empty results, snippet extraction
- [ ] Performance test with 100+ videos (verify <100ms)
- [ ] No critical bugs

## Story Points: 3
## Priority: High
## Sprint: Backlog
## Epic: EPIC-001 YouTube Video Ingestion
