# GitHub MCP Integration Design for Plane

## Overview

This document outlines the design for integrating GitHub with Plane using the Model Context Protocol (MCP) GitHub server. This approach leverages GitHub's official MCP server for a modern, standardized integration.

## Architecture

### Components

```
┌─────────────────────────────────────────────────────────────┐
│                     Plane Application                        │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐         ┌──────────────┐                  │
│  │   Frontend   │◄────────┤   Backend    │                  │
│  │  (React/TS)  │         │  (Django/Py) │                  │
│  └──────────────┘         └──────┬───────┘                  │
│                                   │                           │
│                          ┌────────▼────────┐                 │
│                          │  MCP Client     │                 │
│                          │  Service        │                 │
│                          └────────┬────────┘                 │
└───────────────────────────────────┼──────────────────────────┘
                                    │
                                    │ MCP Protocol
                                    │
                          ┌─────────▼────────┐
                          │  GitHub MCP      │
                          │  Server          │
                          │  (Remote/Local)  │
                          └─────────┬────────┘
                                    │
                                    │ GitHub API
                                    │
                          ┌─────────▼────────┐
                          │   GitHub API     │
                          └──────────────────┘
```

### Key Features

1. **Bidirectional Sync**: Issues, PRs, comments between Plane and GitHub
2. **Real-time Updates**: Using MCP resources and notifications
3. **Flexible Authentication**: OAuth 2.0 via GitHub MCP server
4. **Toolsets**: Configurable GitHub capabilities (issues, PRs, repos, etc.)

## Implementation Plan

### Phase 1: MCP Client Setup

**Backend (Python)**
- Install `mcp` Python SDK
- Create `plane/app/services/mcp/` directory structure:
  - `client.py` - MCP client wrapper
  - `github_client.py` - GitHub-specific MCP client
  - `config.py` - MCP configuration management

**Key Dependencies:**
```python
mcp>=1.0.0  # MCP Python SDK
httpx>=0.27.0  # For async HTTP requests
```

### Phase 2: Database Models Enhancement

Extend existing models in `plane/db/models/integration/github.py`:

```python
class GithubMCPConfiguration(ProjectBaseModel):
    """Stores MCP-specific configuration for GitHub integration"""
    workspace_integration = models.ForeignKey(
        "db.WorkspaceIntegration",
        related_name="mcp_configs",
        on_delete=models.CASCADE
    )
    mcp_server_url = models.URLField(
        default="https://api.githubcopilot.com/mcp/"
    )
    enabled_toolsets = models.JSONField(
        default=list,
        help_text="List of enabled MCP toolsets"
    )
    oauth_token = models.TextField(blank=True)
    sync_settings = models.JSONField(default=dict)
    last_sync_at = models.DateTimeField(null=True, blank=True)
```

### Phase 3: API Endpoints

Create new endpoints in `plane/app/views/integration/github_mcp.py`:

```
POST   /api/workspaces/{slug}/integrations/github-mcp/connect/
GET    /api/workspaces/{slug}/integrations/github-mcp/status/
POST   /api/workspaces/{slug}/integrations/github-mcp/sync/
POST   /api/workspaces/{slug}/integrations/github-mcp/sync-issue/{issue_id}/
DELETE /api/workspaces/{slug}/integrations/github-mcp/disconnect/
GET    /api/workspaces/{slug}/integrations/github-mcp/repositories/
POST   /api/workspaces/{slug}/integrations/github-mcp/configure/
```

### Phase 4: MCP Client Service

**Core Functionality:**

1. **Connection Management**
   - Connect to remote MCP server
   - Handle OAuth authentication
   - Manage session lifecycle

2. **Tool Invocation**
   - `create_issue()` - Create GitHub issues from Plane
   - `update_issue()` - Update GitHub issues
   - `create_pull_request()` - Create PRs
   - `search_issues()` - Search GitHub issues
   - `get_repository()` - Get repo info

3. **Resource Monitoring**
   - Subscribe to GitHub issue updates
   - Monitor PR status changes
   - Track repository events

4. **Sync Engine**
   - Bidirectional issue synchronization
   - Comment synchronization
   - Label mapping
   - Status mapping

### Phase 5: Frontend Integration

**New Components:**

1. `GitHubMCPConfigurationModal.tsx`
   - OAuth flow initiation
   - Toolset selection
   - Repository selection
   - Sync settings configuration

2. `GitHubMCPSyncStatus.tsx`
   - Display sync status
   - Show last sync time
   - Manual sync trigger

3. `GitHubIssueLinkBadge.tsx`
   - Display linked GitHub issues
   - Quick link to GitHub
   - Sync status indicator

**Service Layer:**
- Extend `github.service.ts` with MCP-specific methods

### Phase 6: Webhook Integration

While MCP handles most operations, webhooks provide real-time updates:

```python
# plane/app/views/webhook/github_mcp.py
class GitHubMCPWebhookEndpoint(APIView):
    """
    Receives webhooks from GitHub
    Triggers MCP sync operations
    """
    def post(self, request):
        # Verify GitHub signature
        # Parse event type
        # Trigger appropriate MCP sync
        pass
```

## MCP Toolsets Configuration

### Default Toolsets
```json
{
  "toolsets": [
    "context",
    "repos",
    "issues",
    "pull_requests",
    "users"
  ]
}
```

### Optional Toolsets
- `actions` - GitHub Actions integration
- `code_security` - Security scanning
- `projects` - GitHub Projects
- `labels` - Label management
- `notifications` - Notification management

## Authentication Flow

### OAuth 2.0 via MCP Server

```
1. User clicks "Connect GitHub" in Plane
   ↓
2. Plane backend initiates OAuth flow with MCP server
   ↓
3. User redirected to GitHub authorization page
   ↓
4. User approves permissions
   ↓
5. GitHub redirects back to Plane callback
   ↓
6. Plane receives OAuth token
   ↓
7. Token stored in GithubMCPConfiguration
   ↓
8. MCP client uses token for all GitHub operations
```

## Sync Strategy

### Pull-based Sync
- Periodic polling using MCP resources
- Configurable interval (default: 5 minutes)
- Sync on-demand via UI

### Push-based Sync
- GitHub webhooks trigger MCP operations
- Real-time updates for issues/PRs
- Comment sync on webhook events

### Conflict Resolution
- Last-write-wins strategy
- Timestamp-based conflict detection
- Manual resolution UI for conflicts

## Data Mapping

### Issue Mapping
| Plane Field | GitHub Field | Notes |
|-------------|--------------|-------|
| name | title | Direct mapping |
| description | body | Markdown format |
| state | state | Open/Closed mapping |
| priority | labels | Custom label prefix |
| assignees | assignees | User mapping required |
| created_at | created_at | ISO timestamp |

### Label Mapping
- Plane labels → GitHub labels (auto-create if missing)
- Configurable label prefix (e.g., `plane:priority-high`)

### Comment Mapping
- Bidirectional comment sync
- Track sync status to avoid duplicates
- Preserve comment threading

## Error Handling

### MCP Connection Errors
- Retry with exponential backoff
- Fallback to direct GitHub API
- User notification on persistent failures

### Sync Errors
- Log detailed error information
- Mark failed syncs in database
- Provide retry mechanism

### Rate Limiting
- Respect GitHub API rate limits
- Implement request queuing
- Provide feedback to users

## Security Considerations

1. **Token Storage**
   - Encrypt OAuth tokens at rest
   - Use Django's encryption utilities
   - Rotate tokens periodically

2. **Webhook Verification**
   - Verify GitHub webhook signatures
   - Validate payload structure
   - Rate limit webhook endpoints

3. **Permission Scopes**
   - Request minimal required scopes
   - Document required permissions
   - Allow users to review scopes

## Testing Strategy

### Unit Tests
- MCP client operations
- Data mapping functions
- Sync logic

### Integration Tests
- MCP server communication
- OAuth flow
- Webhook handling

### E2E Tests
- Complete sync workflows
- Conflict resolution
- Error scenarios

## Performance Optimization

1. **Caching**
   - Cache repository metadata
   - Cache user mappings
   - TTL-based cache invalidation

2. **Batch Operations**
   - Batch issue updates
   - Bulk comment sync
   - Reduce API calls

3. **Async Processing**
   - Use Celery for background sync
   - Queue-based webhook processing
   - Non-blocking MCP operations

## Monitoring & Observability

### Metrics to Track
- Sync success/failure rate
- MCP request latency
- GitHub API usage
- Active integrations count

### Logging
- Structured logging for all MCP operations
- Error tracking with context
- Audit trail for syncs

## Migration Path

### From Existing GitHub Integration
1. Identify existing GitHub integrations
2. Offer migration wizard
3. Preserve existing sync data
4. Gradual rollout with feature flag

## Future Enhancements

1. **Advanced Sync**
   - Custom field mapping
   - Selective sync (filter by labels/projects)
   - Two-way PR sync

2. **AI Features**
   - Auto-link related issues
   - Suggest PR reviewers
   - Generate issue descriptions

3. **Analytics**
   - Sync performance dashboard
   - GitHub activity insights
   - Team collaboration metrics

## File Structure

```
plane/
├── app/
│   ├── services/
│   │   └── mcp/
│   │       ├── __init__.py
│   │       ├── client.py              # Base MCP client
│   │       ├── github_client.py       # GitHub MCP client
│   │       ├── config.py              # Configuration
│   │       ├── sync_engine.py         # Sync logic
│   │       └── exceptions.py          # Custom exceptions
│   ├── views/
│   │   └── integration/
│   │       ├── github_mcp.py          # API endpoints
│   │       └── github_mcp_webhook.py  # Webhook handler
│   └── serializers/
│       └── integration/
│           └── github_mcp.py          # Serializers
├── db/
│   └── models/
│       └── integration/
│           └── github.py              # Enhanced models
└── bgtasks/
    └── github_mcp_sync.py             # Background tasks

apps/web/
├── core/
│   ├── components/
│   │   └── integration/
│   │       ├── github-mcp-config-modal.tsx
│   │       ├── github-mcp-sync-status.tsx
│   │       └── github-issue-link-badge.tsx
│   └── services/
│       └── integrations/
│           └── github-mcp.service.ts  # Frontend service
```

## Timeline Estimate

- **Phase 1**: MCP Client Setup - 2 days
- **Phase 2**: Database Models - 1 day
- **Phase 3**: API Endpoints - 3 days
- **Phase 4**: MCP Service Logic - 4 days
- **Phase 5**: Frontend Integration - 3 days
- **Phase 6**: Webhook Integration - 2 days
- **Testing & Refinement** - 3 days

**Total**: ~18 days (3-4 weeks)

## Success Criteria

1. ✅ Users can connect GitHub via MCP with OAuth
2. ✅ Issues sync bidirectionally between Plane and GitHub
3. ✅ Comments sync in real-time
4. ✅ Labels map correctly
5. ✅ Webhook events trigger appropriate syncs
6. ✅ Error handling gracefully manages failures
7. ✅ Performance meets SLA (<500ms for sync operations)
8. ✅ Test coverage >80%

## References

- [GitHub MCP Server Documentation](https://github.com/github/github-mcp-server)
- [MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk)
- [MCP Specification](https://github.com/modelcontextprotocol/specification)
