# GitHub MCP Integration - Production Deployment Guide

**Version**: 1.0.0
**Date**: October 16, 2025
**Status**: Ready for Production

---

## Table of Contents

1. [Pre-Deployment Checklist](#pre-deployment-checklist)
2. [Environment Setup](#environment-setup)
3. [Database Migrations](#database-migrations)
4. [Dependencies Installation](#dependencies-installation)
5. [Celery Configuration](#celery-configuration)
6. [GitHub OAuth Setup](#github-oauth-setup)
7. [MCP Server Configuration](#mcp-server-configuration)
8. [Frontend Build & Deploy](#frontend-build--deploy)
9. [Testing in Production](#testing-in-production)
10. [Rollback Plan](#rollback-plan)
11. [Monitoring & Alerts](#monitoring--alerts)
12. [Troubleshooting](#troubleshooting)

---

## Pre-Deployment Checklist

Before deploying to production, ensure:

- [ ] All 550+ tests passing locally
- [ ] Code review completed
- [ ] Product Owner sign-off obtained
- [ ] Database backup completed
- [ ] Rollback plan documented
- [ ] Monitoring dashboards configured
- [ ] GitHub OAuth app created
- [ ] MCP server endpoint accessible
- [ ] Celery workers and beat configured
- [ ] Redis instance available

---

## Environment Setup

### Required Environment Variables

Add these to your `.env` or environment configuration:

```bash
# GitHub OAuth Configuration
GITHUB_CLIENT_ID=your_github_oauth_app_client_id
GITHUB_CLIENT_SECRET=your_github_oauth_app_client_secret
GITHUB_CALLBACK_URL=https://your-domain.com/api/auth/github/callback

# MCP Server Configuration
MCP_GITHUB_SERVER_URL=https://api.githubcopilot.com/mcp/
MCP_CONNECTION_TIMEOUT=30
MCP_MAX_RETRIES=3
MCP_RETRY_DELAY=1

# Celery Configuration (if not already set)
CELERY_BROKER_URL=redis://localhost:6379/0
CELERY_RESULT_BACKEND=redis://localhost:6379/0

# Redis Configuration (if not already set)
REDIS_URL=redis://localhost:6379/1

# Feature Flags (optional - for gradual rollout)
ENABLE_GITHUB_MCP_INTEGRATION=true
GITHUB_MCP_MAX_SYNC_BATCH_SIZE=100
GITHUB_MCP_DEFAULT_SYNC_INTERVAL=300  # 5 minutes
```

### Configuration File

Create or update `plane/app/settings/production.py`:

```python
# GitHub MCP Integration Settings
GITHUB_MCP_SETTINGS = {
    'server_url': env('MCP_GITHUB_SERVER_URL', default='https://api.githubcopilot.com/mcp/'),
    'connection_timeout': env.int('MCP_CONNECTION_TIMEOUT', default=30),
    'max_retries': env.int('MCP_MAX_RETRIES', default=3),
    'retry_delay': env.int('MCP_RETRY_DELAY', default=1),
    'max_sync_batch_size': env.int('GITHUB_MCP_MAX_SYNC_BATCH_SIZE', default=100),
    'default_sync_interval': env.int('GITHUB_MCP_DEFAULT_SYNC_INTERVAL', default=300),
}

# GitHub OAuth Settings
GITHUB_OAUTH_SETTINGS = {
    'client_id': env('GITHUB_CLIENT_ID'),
    'client_secret': env('GITHUB_CLIENT_SECRET'),
    'callback_url': env('GITHUB_CALLBACK_URL'),
    'scopes': ['repo', 'read:user', 'user:email'],
}
```

---

## Database Migrations

### Step 1: Backup Current Database

```bash
# PostgreSQL backup
pg_dump -h localhost -U plane_user -d plane_db -F c -b -v -f "plane_backup_$(date +%Y%m%d_%H%M%S).dump"

# Or using Django dumpdata (slower but portable)
cd plane-app/apps/api
python manage.py dumpdata --natural-foreign --natural-primary -e contenttypes -e auth.Permission > backup_$(date +%Y%m%d_%H%M%S).json
```

### Step 2: Apply Migrations

```bash
cd plane-app/apps/api

# Check migration status
python manage.py showmigrations db

# Apply new migrations
python manage.py migrate db 0108_githubwebhookevent
python manage.py migrate db 0109_githubsyncjob

# Verify migrations applied
python manage.py showmigrations db | grep github
```

Expected output:
```
[X] 0108_githubwebhookevent
[X] 0109_githubsyncjob
```

### Step 3: Verify Tables Created

```sql
-- Connect to PostgreSQL
psql -U plane_user -d plane_db

-- Check tables
\dt github_*

-- Expected tables:
-- github_repositories
-- github_repository_syncs
-- github_issue_syncs
-- github_comment_syncs
-- github_webhook_events  (new)
-- github_sync_jobs       (new)

-- Verify indexes
\di github_*
```

---

## Dependencies Installation

### Backend Dependencies

```bash
cd plane-app/apps/api

# Install production dependencies
pip install -r requirements/production.txt

# Verify key packages installed
pip list | grep -E "(mcp|httpx|aiohttp|tenacity)"

# Expected output:
# mcp                  0.9.0
# httpx                0.27.0
# aiohttp              3.9.3
# tenacity             8.2.3
```

### Frontend Dependencies

```bash
cd apps/web

# Install dependencies
npm install

# Or with pnpm
pnpm install

# Verify MSW and testing libraries (for development/staging)
npm list | grep -E "(msw|@testing-library)"
```

---

## Celery Configuration

### Step 1: Update Celery Beat Schedule

Edit `plane/bgtasks/celery_config.py` or `celerybeat-schedule.py`:

```python
from celery.schedules import crontab

CELERYBEAT_SCHEDULE = {
    # ... existing tasks ...

    # GitHub MCP Periodic Sync (every 5 minutes)
    'github-mcp-periodic-sync': {
        'task': 'github_mcp.periodic_sync_all',
        'schedule': crontab(minute='*/5'),  # Every 5 minutes
        'options': {
            'expires': 240,  # Task expires after 4 minutes
        },
    },

    # GitHub MCP Cleanup Old Jobs (daily at 2 AM)
    'github-mcp-cleanup-jobs': {
        'task': 'github_mcp.cleanup_old_jobs',
        'schedule': crontab(hour=2, minute=0),
        'options': {
            'expires': 3600,
        },
    },
}
```

### Step 2: Register New Tasks

Ensure tasks are imported in `plane/bgtasks/__init__.py`:

```python
# Import GitHub MCP tasks
from plane.bgtasks.github_mcp_sync import (
    sync_github_repository_async,
    sync_single_issue_async,
    periodic_sync_all_integrations,
    cleanup_old_sync_jobs,
)

from plane.bgtasks.github_mcp_webhook import (
    process_github_webhook_event,
)
```

### Step 3: Restart Celery Workers

```bash
# Stop existing workers
pkill -f 'celery worker'
pkill -f 'celery beat'

# Start new workers (adjust concurrency based on server resources)
celery -A plane worker -l info --concurrency=4 &

# Start beat scheduler
celery -A plane beat -l info &

# Verify workers started
celery -A plane inspect active
celery -A plane inspect registered | grep github_mcp
```

Expected output should include:
```
- github_mcp.sync_repository
- github_mcp.sync_issue
- github_mcp.periodic_sync_all
- github_mcp.cleanup_old_jobs
- github_mcp.process_webhook_event
```

### Step 4: Monitor Celery Logs

```bash
# Tail celery logs
tail -f /var/log/celery/worker.log
tail -f /var/log/celery/beat.log

# Or if using systemd
journalctl -u celery-worker -f
journalctl -u celery-beat -f
```

---

## GitHub OAuth Setup

### Step 1: Create GitHub OAuth App

1. Go to GitHub Settings → Developer Settings → OAuth Apps
2. Click "New OAuth App"
3. Fill in details:
   - **Application name**: `Plane GitHub Integration`
   - **Homepage URL**: `https://your-plane-domain.com`
   - **Authorization callback URL**: `https://your-plane-domain.com/api/auth/github/callback`
4. Click "Register application"
5. Copy the **Client ID** and **Client Secret**

### Step 2: Configure Scopes

The integration requires these scopes:
- `repo` - Full access to repositories
- `read:user` - Read user profile
- `user:email` - Access user email

### Step 3: Test OAuth Flow

```bash
# Test authorization URL generation
curl -X GET "https://your-plane-domain.com/api/workspaces/{slug}/integrations/github-mcp/oauth/authorize"

# Expected response:
# {
#   "authorization_url": "https://github.com/login/oauth/authorize?client_id=...&redirect_uri=...&scope=repo+read:user+user:email"
# }
```

---

## MCP Server Configuration

### Step 1: Verify MCP Server Access

```bash
# Test MCP server connectivity
curl -X POST https://api.githubcopilot.com/mcp/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_GITHUB_TOKEN" \
  -d '{"jsonrpc": "2.0", "method": "ping", "id": 1}'

# Expected response:
# {"jsonrpc": "2.0", "result": "pong", "id": 1}
```

### Step 2: Configure MCP Client Settings

Create `plane/app/services/mcp/config.py` (if not exists):

```python
from django.conf import settings

MCP_CONFIG = {
    'github': {
        'server_url': settings.GITHUB_MCP_SETTINGS['server_url'],
        'timeout': settings.GITHUB_MCP_SETTINGS['connection_timeout'],
        'max_retries': settings.GITHUB_MCP_SETTINGS['max_retries'],
        'retry_delay': settings.GITHUB_MCP_SETTINGS['retry_delay'],
    }
}
```

### Step 3: Test MCP Client

```python
# Run in Django shell
python manage.py shell

from plane.app.services.mcp.github_client import GitHubMCPClient
import asyncio

async def test_mcp():
    config = {
        'server_url': 'https://api.githubcopilot.com/mcp/',
        'access_token': 'YOUR_TEST_TOKEN'
    }

    async with GitHubMCPClient(config) as client:
        # Test connection
        user = await client.get_authenticated_user()
        print(f"Connected as: {user['login']}")

        # Test repository access
        repos = await client.list_repositories()
        print(f"Found {len(repos)} repositories")

    return True

# Run test
asyncio.run(test_mcp())
```

---

## Frontend Build & Deploy

### Step 1: Build Frontend

```bash
cd apps/web

# Set production environment
export NODE_ENV=production

# Build
npm run build

# Or with pnpm
pnpm build

# Output should be in apps/web/.next/ or apps/web/dist/
```

### Step 2: Verify Build Output

```bash
# Check build size
du -sh apps/web/.next/

# Verify critical files exist
ls -lh apps/web/.next/static/chunks/

# Check for GitHub MCP components
find apps/web/.next/ -name "*github-mcp*"
```

### Step 3: Deploy Frontend (depends on your setup)

**Option A: Next.js Standalone**
```bash
# Copy build to server
rsync -avz apps/web/.next/ user@server:/var/www/plane/web/.next/

# Restart Next.js server
pm2 restart plane-web
```

**Option B: Static Export**
```bash
# If using static export
npm run export
rsync -avz apps/web/out/ user@server:/var/www/plane/web/
```

**Option C: Docker**
```bash
# Rebuild Docker image
docker build -t plane-web:latest -f web/Dockerfile .
docker push your-registry/plane-web:latest

# Deploy
kubectl rollout restart deployment/plane-web
```

---

## Testing in Production

### Step 1: Smoke Tests

```bash
# 1. Check API health
curl https://your-plane-domain.com/api/health/

# 2. Check GitHub MCP endpoints available
curl https://your-plane-domain.com/api/workspaces/test/integrations/github-mcp/status/ \
  -H "Authorization: Bearer YOUR_API_TOKEN"

# Expected: 404 (not configured yet) or 200 (if test integration exists)

# 3. Verify Celery tasks registered
celery -A plane inspect registered | grep github_mcp

# 4. Check migrations applied
python manage.py showmigrations db | grep -E "(0108|0109)"
```

### Step 2: Integration Test

1. **Connect GitHub Repository**:
   - Login to Plane as workspace admin
   - Go to Settings → Integrations → GitHub MCP
   - Click "Connect GitHub"
   - Authorize OAuth
   - Select a test repository
   - Configure sync settings
   - Click "Connect"

2. **Verify Connection**:
   - Check status shows "Connected"
   - Verify repository appears in list
   - Check database for records:
     ```sql
     SELECT * FROM github_repositories WHERE name = 'test-repo';
     SELECT * FROM github_repository_syncs WHERE repository_id = ...;
     ```

3. **Test Manual Sync**:
   - Click "Sync Now" button
   - Verify sync job created:
     ```sql
     SELECT * FROM github_sync_jobs ORDER BY created_at DESC LIMIT 5;
     ```
   - Monitor Celery logs for sync progress
   - Verify issues synced to Plane

4. **Test Webhook**:
   - Go to GitHub → Repository → Settings → Webhooks
   - Verify webhook registered (if auto-configured)
   - Or manually add webhook:
     - URL: `https://your-plane-domain.com/api/webhooks/github-mcp/`
     - Content type: `application/json`
     - Secret: (from workspace integration config)
     - Events: Issues, Issue comments, Pull requests
   - Create a test issue on GitHub
   - Verify webhook received and processed:
     ```sql
     SELECT * FROM github_webhook_events ORDER BY created_at DESC LIMIT 5;
     ```
   - Verify issue created in Plane

### Step 3: Performance Test

```bash
# Test sync performance with multiple issues
time curl -X POST https://your-plane-domain.com/api/workspaces/test/integrations/github-mcp/sync/ \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"direction": "from_github", "force": false}'

# Monitor sync job progress
watch -n 2 'curl -s https://your-plane-domain.com/api/workspaces/test/integrations/github-mcp/status/ \
  -H "Authorization: Bearer YOUR_API_TOKEN" | jq .current_sync_job'
```

---

## Rollback Plan

### If Issues Occur After Deployment

**Level 1: Disable Feature (Quick - 2 minutes)**

```bash
# Set feature flag to false
export ENABLE_GITHUB_MCP_INTEGRATION=false

# Restart services
systemctl restart plane-api
systemctl restart celery-worker
systemctl restart celery-beat
```

**Level 2: Rollback Migrations (Medium - 10 minutes)**

```bash
cd plane-app/apps/api

# Rollback to previous migration
python manage.py migrate db 0107_migrate_filters_to_rich_filters

# Verify rollback
python manage.py showmigrations db | tail -5
```

**Level 3: Full Rollback (Slow - 30 minutes)**

```bash
# 1. Stop services
systemctl stop celery-worker celery-beat plane-api

# 2. Restore database backup
pg_restore -h localhost -U plane_user -d plane_db -c plane_backup_TIMESTAMP.dump

# 3. Revert code to previous version
git revert <commit-hash>
git push origin main

# 4. Redeploy previous version
# (deployment steps depend on your setup)

# 5. Restart services
systemctl start plane-api celery-worker celery-beat
```

**Rollback Decision Matrix:**

| Severity | Issue | Action |
|----------|-------|--------|
| Critical | Data loss, system down | Level 3: Full Rollback |
| High | Major bugs, sync failures | Level 2: Rollback Migrations |
| Medium | Minor bugs, performance issues | Level 1: Disable Feature |
| Low | UI glitches, cosmetic issues | Fix forward with hotfix |

---

## Monitoring & Alerts

### Key Metrics to Monitor

**Application Metrics:**
- GitHub MCP sync success rate
- Average sync duration
- Webhook processing latency
- API endpoint response times
- MCP connection errors
- GitHub API rate limit usage

**Infrastructure Metrics:**
- Celery queue depth
- Celery worker CPU/memory
- Database connection pool
- Redis memory usage

### Recommended Monitoring Setup

**1. Celery Flower (Task Monitoring)**

```bash
# Install Flower
pip install flower

# Start Flower dashboard
celery -A plane flower --port=5555

# Access at http://localhost:5555
```

**2. Prometheus Metrics (if using)**

Add to `plane/app/middleware/metrics.py`:

```python
from prometheus_client import Counter, Histogram

github_mcp_sync_total = Counter(
    'github_mcp_sync_total',
    'Total GitHub MCP sync jobs',
    ['status', 'direction']
)

github_mcp_sync_duration = Histogram(
    'github_mcp_sync_duration_seconds',
    'GitHub MCP sync duration',
    ['direction']
)

github_mcp_webhook_total = Counter(
    'github_mcp_webhook_total',
    'Total GitHub webhooks received',
    ['event_type', 'status']
)
```

**3. Application Logs**

```bash
# Tail application logs
tail -f /var/log/plane/api.log | grep github_mcp

# Search for errors
grep -i "error" /var/log/plane/api.log | grep github_mcp

# Monitor webhook events
tail -f /var/log/plane/api.log | grep "GitHub webhook"
```

**4. Alerts Configuration**

Create alerts in your monitoring system:

```yaml
# Example: Prometheus Alert Rules
groups:
  - name: github_mcp
    interval: 30s
    rules:
      - alert: GitHubMCPSyncFailureRate
        expr: rate(github_mcp_sync_total{status="failed"}[5m]) > 0.1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High GitHub MCP sync failure rate"

      - alert: GitHubMCPWebhookProcessingDelay
        expr: github_mcp_webhook_processing_duration_seconds > 30
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "GitHub webhook processing is slow"

      - alert: GitHubMCPMCPConnectionErrors
        expr: rate(github_mcp_connection_errors_total[5m]) > 1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "GitHub MCP server connection errors"
```

---

## Troubleshooting

### Issue 1: Migrations Fail

**Symptom**: `python manage.py migrate` fails with errors

**Solutions**:

```bash
# Check current migration status
python manage.py showmigrations db

# Check for conflicts
python manage.py migrate --check

# Force specific migration
python manage.py migrate db 0109 --fake

# If fake needed, manually apply SQL
psql -U plane_user -d plane_db -f plane/db/migrations/0109_githubsyncjob_manual.sql
```

### Issue 2: Celery Tasks Not Running

**Symptom**: Sync jobs queued but not processing

**Debug Steps**:

```bash
# Check Celery workers active
celery -A plane inspect active

# Check task registration
celery -A plane inspect registered | grep github_mcp

# Check queue depth
celery -A plane inspect stats

# Restart workers
pkill -f 'celery worker' && celery -A plane worker -l debug &

# Monitor logs
tail -f /var/log/celery/worker.log
```

### Issue 3: MCP Connection Errors

**Symptom**: `MCPConnectionError` in logs

**Debug Steps**:

```bash
# Test MCP server access
curl -X POST https://api.githubcopilot.com/mcp/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{"jsonrpc": "2.0", "method": "ping", "id": 1}'

# Check token validity
curl -H "Authorization: Bearer TOKEN" https://api.github.com/user

# Verify network connectivity
ping api.githubcopilot.com
traceroute api.githubcopilot.com

# Check firewall rules
sudo iptables -L -n | grep 443
```

### Issue 4: OAuth Flow Fails

**Symptom**: Users can't authorize GitHub

**Debug Steps**:

```bash
# Verify OAuth app configuration
curl "https://github.com/settings/developers"

# Check callback URL matches
echo $GITHUB_CALLBACK_URL

# Test authorization URL
curl https://your-plane-domain.com/api/workspaces/test/integrations/github-mcp/oauth/authorize

# Check logs for OAuth errors
grep -i "oauth" /var/log/plane/api.log | tail -20
```

### Issue 5: Webhook Events Not Processing

**Symptom**: GitHub events not syncing

**Debug Steps**:

```sql
-- Check webhook events received
SELECT
  event_type,
  status,
  COUNT(*) as count,
  MAX(created_at) as last_received
FROM github_webhook_events
WHERE created_at > NOW() - INTERVAL '1 hour'
GROUP BY event_type, status;

-- Check for failed events
SELECT
  id,
  event_type,
  status,
  error_message,
  created_at
FROM github_webhook_events
WHERE status = 'failed'
ORDER BY created_at DESC
LIMIT 10;
```

**GitHub Webhook Debugging**:

1. Go to GitHub → Repository → Settings → Webhooks
2. Click on the webhook
3. Click "Recent Deliveries"
4. Click on a delivery to see request/response
5. Verify response is 200/202
6. Check X-Hub-Signature-256 validation

### Issue 6: High Memory Usage

**Symptom**: Celery workers consuming too much memory

**Solutions**:

```bash
# Reduce worker concurrency
celery -A plane worker -l info --concurrency=2

# Enable worker autoscale
celery -A plane worker -l info --autoscale=4,1

# Set max tasks per worker before restart
celery -A plane worker -l info --max-tasks-per-child=100

# Monitor memory
watch -n 5 'ps aux | grep celery | grep -v grep'
```

### Issue 7: Database Lock Timeouts

**Symptom**: `database is locked` or lock timeout errors

**Solutions**:

```python
# In Django settings, increase timeout
DATABASES = {
    'default': {
        ...
        'OPTIONS': {
            'connect_timeout': 10,
            'options': '-c statement_timeout=30000',  # 30 seconds
        }
    }
}
```

```sql
-- Check for long-running queries
SELECT
  pid,
  now() - pg_stat_activity.query_start AS duration,
  query,
  state
FROM pg_stat_activity
WHERE state != 'idle'
  AND query NOT LIKE '%pg_stat_activity%'
ORDER BY duration DESC;

-- Kill long-running query if needed
SELECT pg_terminate_backend(PID);
```

---

## Post-Deployment Validation

### Checklist

- [ ] All migrations applied successfully
- [ ] No errors in application logs
- [ ] Celery workers running and processing tasks
- [ ] Celery beat scheduler running
- [ ] Test OAuth flow completes successfully
- [ ] Test repository connection works
- [ ] Test manual sync completes
- [ ] Test webhook event processing works
- [ ] Monitor dashboards showing data
- [ ] No performance degradation
- [ ] Rollback plan tested and documented

### Success Criteria

**Technical:**
- API response times < 500ms (p95)
- Sync completion < 60s for 100 issues
- Webhook processing < 5s
- Zero critical errors in first 24 hours
- Test coverage maintained > 85%

**Business:**
- At least 1 successful integration per workspace
- User satisfaction score > 4/5
- Support tickets < 5 in first week
- ROI tracking shows positive trend

---

## Support Contacts

**Development Team:**
- Lead: [Name] - [email]
- Backend: [Name] - [email]
- Frontend: [Name] - [email]

**Infrastructure:**
- DevOps: [Name] - [email]
- DBA: [Name] - [email]

**Escalation:**
- On-call: [phone]
- Slack: #plane-github-mcp-support

---

## Appendix

### A. Database Schema

```sql
-- GitHub Webhook Events Table
CREATE TABLE github_webhook_events (
    id UUID PRIMARY KEY,
    delivery_id VARCHAR(255) UNIQUE NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL,
    payload JSONB NOT NULL,
    result JSONB,
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    processed_at TIMESTAMP
);

CREATE INDEX idx_github_webhook_delivery ON github_webhook_events(delivery_id);
CREATE INDEX idx_github_webhook_status ON github_webhook_events(status);
CREATE INDEX idx_github_webhook_created ON github_webhook_events(created_at);

-- GitHub Sync Jobs Table
CREATE TABLE github_sync_jobs (
    id UUID PRIMARY KEY,
    job_id VARCHAR(255) UNIQUE NOT NULL,
    workspace_integration_id UUID NOT NULL,
    repository_sync_id UUID,
    status VARCHAR(20) NOT NULL,
    direction VARCHAR(20) NOT NULL,
    items_total INTEGER DEFAULT 0,
    items_synced INTEGER DEFAULT 0,
    items_failed INTEGER DEFAULT 0,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    error_message TEXT,
    error_details JSONB,
    filters JSONB,
    metadata JSONB,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE INDEX idx_github_sync_job_id ON github_sync_jobs(job_id);
CREATE INDEX idx_github_sync_status ON github_sync_jobs(status);
CREATE INDEX idx_github_sync_wi ON github_sync_jobs(workspace_integration_id, status);
```

### B. API Endpoints

```
POST   /api/workspaces/{slug}/integrations/github-mcp/connect/
DELETE /api/workspaces/{slug}/integrations/github-mcp/disconnect/
GET    /api/workspaces/{slug}/integrations/github-mcp/status/
POST   /api/workspaces/{slug}/integrations/github-mcp/sync/
PATCH  /api/workspaces/{slug}/integrations/github-mcp/configure/
GET    /api/workspaces/{slug}/integrations/github-mcp/repositories/
GET    /api/workspaces/{slug}/integrations/github-mcp/oauth/authorize
GET    /api/auth/github/callback
POST   /api/webhooks/github-mcp/
```

### C. Celery Tasks

```
github_mcp.sync_repository            - Full repository sync
github_mcp.sync_issue                 - Single issue sync
github_mcp.periodic_sync_all          - Periodic auto-sync
github_mcp.cleanup_old_jobs           - Cleanup old sync jobs
github_mcp.process_webhook_event      - Process webhook events
```

---

**End of Deployment Guide**

For additional support, refer to:
- Technical Documentation: `PHASE_5_EXECUTION_SUMMARY.md`
- Test Documentation: `PHASE_6_TESTING_VALIDATION_SUMMARY.md`
- Product Backlog: `PRODUCT_BACKLOG_GITHUB_MCP_INTEGRATION.md`
