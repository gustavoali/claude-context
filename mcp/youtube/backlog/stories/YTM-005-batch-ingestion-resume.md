# YTM-005: Batch Ingestion with Resume Capability

**As a** user who needs to ingest hundreds of videos from Takeout or playlists
**I want** batch ingestion with progress tracking and the ability to resume after interruption
**So that** I can process large video lists without losing progress on quota limits, network issues, or session timeouts

## Acceptance Criteria

**AC1: Batch ingestion from a list of video IDs**
- Given a list of video IDs (e.g., 500 IDs from a Takeout export)
- When `ingest_batch(video_ids)` is called
- Then each video is processed through the full ingestion pipeline (YTM-004)
- And progress is tracked: total, completed, failed, skipped, remaining
- And a batch summary is returned upon completion

**AC2: Resume capability**
- Given a batch ingestion that was interrupted (network error, session close, quota limit)
- When `ingest_batch(video_ids)` is called again with the same list
- Then videos with `ingestion_status` = 'complete' are skipped
- And videos with `ingestion_status` = 'error' are retried
- And videos with `ingestion_status` = 'pending' or 'metadata_ok' are processed
- And progress resumes from where it left off

**AC3: Progress callback**
- Given a batch ingestion in progress
- When each video is processed
- Then a progress dict is emitted with: current_index, total, video_id, status, errors_so_far
- And the caller can use this for real-time progress display

**AC4: Error isolation**
- Given a video in the batch that fails (private, deleted, network error)
- When the error occurs
- Then the error is recorded for that video (status='error', error_message set)
- And the batch continues processing the next video
- And the batch summary includes per-video error details

**AC5: Batch summary model**
- Given a batch ingestion completes (or is interrupted)
- When the summary is returned
- Then it contains: batch_id, total_videos, completed, failed, skipped, errors (list of {video_id, error}), started_at, completed_at, duration_seconds

**AC6: Configurable concurrency (future-ready)**
- Given batch ingestion is implemented
- When processing videos
- Then videos are processed sequentially by default (concurrency=1)
- And the design allows future extension to parallel ingestion (concurrency>1) without architectural changes

**AC7: Rate limiting awareness**
- Given youtube-transcript-api and yt-dlp may be rate-limited
- When a rate limit or transient error is detected
- Then the service waits briefly (exponential backoff, max 3 retries per video)
- And logs the retry attempts

## Technical Notes
- Each video's ingestion_status in SQLite acts as the progress checkpoint (no separate state file needed)
- The resume mechanism is implicit: query `youtube_videos` for non-complete statuses
- For initial implementation, process sequentially. The `concurrency` parameter can be a no-op placeholder
- Consider a `batch_id` column or `ingestion_batch` table for grouping batch runs (optional, could be deferred)
- yt-dlp has its own rate limiting; youtube-transcript-api can get 429s from YouTube

## Definition of Done
- [ ] Code implemented and reviewed
- [ ] Unit tests: full batch, resume after interruption, error isolation, skip completed
- [ ] Test with 10+ video IDs including 2-3 known-bad IDs
- [ ] No critical bugs

## Story Points: 3
## Priority: High
## Sprint: Backlog
## Epic: EPIC-001 YouTube Video Ingestion
