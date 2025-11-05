# GitHub MCP Webhook - Quick Start Guide

## TL;DR

GitHub webhook handler for real-time Plane synchronization. Validates signatures, processes events asynchronously, ensures idempotency.

## Setup in 5 Minutes

### 1. Run Migration
```bash
cd plane-app/apps/api
python manage.py migrate
```

### 2. Configure Repository Sync
```python
from plane.db.models import GithubRepositorySync, GithubRepository, Project, User, WorkspaceIntegration

# Create or get repository sync
repository_sync = GithubRepositorySync.objects.create(
    repository=github_repo,
    project=your_project,
    workspace_integration=workspace_integration,
    actor=bot_user,
    credentials={
        'github_token': 'ghp_your_token',
        'webhook_secret': 'your_secret_here',
        'server_path': 'npx',
        'server_args': ['-y', '@modelcontextprotocol/server-github']
    }
)
```

### 3. Add GitHub Webhook
Go to GitHub repo → Settings → Webhooks → Add webhook

```
Payload URL: https://your-plane.com/api/webhooks/github-mcp/
Content type: application/json
Secret: your_secret_here (same as credentials.webhook_secret)
Events: ✓ Issues, ✓ Issue comments, ✓ Pull requests
```

### 4. Test
Create an issue in GitHub → Check Plane for new issue

## Key Files

| File | Purpose |
|------|---------|
| `plane/app/views/webhook/github_mcp.py` | Webhook endpoint |
| `plane/bgtasks/github_mcp_webhook.py` | Background tasks |
| `plane/db/models/integration/github_webhook.py` | Event tracking model |

## Common Operations

### Check Recent Events
```python
from plane.db.models import GithubWebhookEvent
GithubWebhookEvent.objects.order_by('-created_at')[:5]
```

### Check Failed Events
```python
failed = GithubWebhookEvent.objects.filter(status='failed')
for event in failed:
    print(f"{event.event_type}: {event.error_message}")
```

### Manually Process Event
```python
from plane.bgtasks.github_mcp_webhook import process_github_issue_event

process_github_issue_event.delay(
    issue_number=42,
    repository_sync_id='your-sync-id',
    force=True
)
```

### Monitor Celery Queue
```bash
celery -A plane inspect active
celery -A plane inspect stats
```

## Event Flow

```
GitHub → Webhook View → Validate Signature → Queue Task → Process Event → Update Plane
                ↓                                   ↓
         Check Idempotency                  Store Result in DB
```

## Troubleshooting

### Webhook Returns 401
- Check secret matches between GitHub and `repository_sync.credentials.webhook_secret`

### Webhook Returns 404
- Verify `GithubRepositorySync` exists for the repository
- Check `repository.repository_id` matches GitHub repo ID

### Events Not Processing
- Check Celery workers: `celery -A plane inspect active`
- Check logs: `tail -f /var/log/celery/worker.log`
- Check database: `GithubWebhookEvent.objects.filter(status='failed')`

### Duplicate Processing
- Should never happen (idempotency via `delivery_id`)
- If it does, check database constraints

## Security Notes

- Signatures validated using HMAC SHA-256
- CSRF exempt (webhooks can't include CSRF tokens)
- Webhook secret should be strong and unique
- Never expose webhook endpoint without signature validation

## Performance Tips

- Webhook returns 202 immediately (non-blocking)
- Processing happens asynchronously in Celery
- Database indexes on `delivery_id`, `event_type`, `status`
- Failed events auto-retry up to 3 times

## API Endpoints

**POST /api/webhooks/github-mcp/**
- Receives GitHub webhook events
- Returns 202 Accepted on success
- Returns 401 on invalid signature
- Returns 404 if repo not configured

**GET /api/webhooks/github-mcp/**
- Returns endpoint info (for verification)

## Supported Events

- ✅ `issues` (opened, edited, closed, reopened)
- ✅ `issue_comment` (created, edited, deleted)
- ⚠️ `pull_request` (acknowledged, not fully implemented)

## State Mapping

| GitHub State | Plane State |
|--------------|-------------|
| `open` | In Progress (started group) |
| `closed` | Done (completed group) |

## Data Models

**GithubWebhookEvent**
- `delivery_id`: Unique GitHub delivery ID
- `event_type`: Event type (issues, issue_comment, etc.)
- `status`: pending → processing → completed/failed
- `payload`: Full webhook payload
- `result`: Processing result data
- `error_message`: Error if failed

**GithubIssueSync**
- Links Plane Issue to GitHub issue
- Tracks sync status

**GithubCommentSync**
- Links Plane IssueComment to GitHub comment
- Enables soft delete tracking

## Configuration

### Required Settings
```python
# settings.py
CELERY_BROKER_URL = 'redis://localhost:6379/0'
CELERY_RESULT_BACKEND = 'redis://localhost:6379/0'
```

### Required Environment Variables
```bash
GITHUB_TOKEN=ghp_your_token
WEBHOOK_SECRET=your_webhook_secret
```

## Development

### Run Tests
```bash
# (Tests not yet implemented - see WEBHOOK_IMPLEMENTATION_SUMMARY.md)
python manage.py test plane.app.views.webhook.github_mcp
python manage.py test plane.bgtasks.github_mcp_webhook
```

### Debug Locally
```bash
# Run Celery in foreground
celery -A plane worker -l debug

# Use ngrok for local testing
ngrok http 8000
# Use ngrok URL as webhook URL in GitHub
```

### View Logs
```bash
# Django logs
tail -f /var/log/plane/api.log | grep github_mcp

# Celery logs
tail -f /var/log/celery/worker.log | grep github_mcp
```

## Full Documentation

See `plane-app/apps/api/plane/app/views/webhook/README_GITHUB_MCP.md` for complete documentation.

## Need Help?

1. Check the comprehensive README
2. Review the implementation summary
3. Check GitHub webhook delivery logs
4. Review Celery task logs
5. Query `GithubWebhookEvent` table for event history
