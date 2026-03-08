# LTE-071: Enrich Course Listing with Completion Data

**As a** user querying courses via API or MCP
**I want** to see completion status and statistics for each course
**So that** I know which courses are fully captured and which need more work

## Acceptance Criteria

**AC1: CourseRepository enhanced**
- Given CourseRepository exists in `modules/storage/repositories/`
- When `findAllWithCompletion()` method is called
- Then it returns all courses from `courses_normalized` with fields: `isComplete`, `completionPercentage`, `videoCount`, `transcriptCount`
- And courses discovered but with 0 transcripts are included in results

**AC2: StorageService updated**
- Given `storageService.listCourses()` is the entry point for course listing
- When called
- Then it delegates to `findAllWithCompletion()` instead of the current method
- And response format includes the new completion fields

**AC3: HTTP endpoint enriched**
- Given `/api/courses` endpoint
- When a GET request is made
- Then response includes `isComplete`, `completionPercentage`, `videoCount`, `transcriptCount` for each course
- And courses with 0 transcripts appear in the list (currently invisible)

**AC4: MCP tool enriched**
- Given `list_courses` MCP tool
- When invoked
- Then output includes completion data per course
- And formatting is LLM-friendly (clear labels, no ambiguous fields)

**AC5: Backward compatibility**
- Given existing consumers of `/api/courses` and `list_courses`
- When the enriched response is returned
- Then all previously existing fields are still present
- And new fields are additive (no breaking changes)

## Technical Notes

- Files: `modules/storage/repositories/course-repo.js`, `modules/storage/services/storage-service.js`, `modules/api/http/routes/`, `modules/api/mcp/tools/`
- The `course_completion_stats` view or `course_summary` view may already have some of this data - evaluate reuse
- Query should LEFT JOIN to include courses with no transcripts
- Performance: Single query with aggregation, not N+1

## Dependencies

- None (independent of LTE-069 and LTE-070)

## Definition of Done

- [ ] `findAllWithCompletion()` implemented and tested
- [ ] `storageService.listCourses()` updated
- [ ] `/api/courses` returns completion data
- [ ] `list_courses` MCP tool returns completion data
- [ ] Courses with 0 transcripts visible
- [ ] No breaking changes to existing response format
- [ ] `npm test` passes

## Story Points: 3
## Priority: High
## Sprint: Next
## Epic: Legacy Data Migration
