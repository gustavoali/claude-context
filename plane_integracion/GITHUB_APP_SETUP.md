# GitHub App Setup for Plane.so

This guide provides multiple methods to create a GitHub App for Plane integration, ranging from fully automated to manual approaches.

## Quick Answer: Can You Create GitHub Apps via API?

**NO** - GitHub does not allow creating GitHub Apps purely via API without browser authorization. This is a security measure to prevent unauthorized app creation.

However, the **GitHub App Manifest Flow** is the most automated approach available.

## Available Methods

### Method 1: Python Script (RECOMMENDED - Most User-Friendly)

**Best for:** Maximum automation with clear error handling

```powershell
python create-github-app.py
```

**Features:**
- Interactive prompts with colored output
- Automatic credential extraction
- Saves credentials in multiple formats
- Clear step-by-step guidance
- Only requires ONE browser click

---

### Method 2: PowerShell Script (Windows Native)

**Best for:** Windows users without Python

```powershell
.\create-github-app-automated.ps1
```

**Features:**
- Native Windows PowerShell
- Opens browser automatically
- Saves credentials to organized directory
- Generates .env and JSON formats

---

### Method 3: Bash Script (WSL2/Linux)

**Best for:** WSL2 or Linux users

```bash
bash create-github-app-automated.sh
```

**Features:**
- Cross-platform bash script
- Works in WSL2
- Colored terminal output
- Auto-detects Windows paths

---

## What Each Script Does

### Automation Steps:

1. **Creates Manifest JSON**
   - Configures all app settings
   - Includes permissions and events
   - Adds webhook secret

2. **Verifies Authentication**
   - Checks `gh` CLI authentication
   - Validates GitHub user

3. **Opens Browser**
   - Navigates to GitHub App creation page
   - Displays manifest for reference

4. **Guides Credential Collection**
   - Prompts for App ID
   - Prompts for Client ID
   - Prompts for Client Secret
   - Copies private key file

5. **Saves Credentials**
   - `.env.github-app` - Environment variables
   - `credentials.json` - JSON format
   - `private-key.pem` - Private key file

---

## Manual Steps Required (All Methods)

GitHub requires these manual steps for security:

1. **In Browser:** Click "Create GitHub App" (or paste manifest)
2. **Copy App ID** from settings page
3. **Copy Client ID** from settings page
4. **Generate Client Secret** (click button, copy value)
5. **Generate Private Key** (click button, download .pem file)

**Total Time:** ~2 minutes

---

## Output Files

All credentials are saved to: `C:\tools\plane\github-app-credentials\`

```
github-app-credentials/
├── .env.github-app        # Environment variables for Docker/local
├── credentials.json       # JSON format for scripts
└── private-key.pem        # Private key for JWT authentication
```

### `.env.github-app` Format:

```bash
GITHUB_APP_ID=123456
GITHUB_CLIENT_ID=Iv1.abc123def456
GITHUB_CLIENT_SECRET=ghp_aBcDeFgHiJkLmNoPqRsTuVwXyZ
GITHUB_WEBHOOK_SECRET=f31ab2058d69ec74
```

### `credentials.json` Format:

```json
{
  "app_id": "123456",
  "client_id": "Iv1.abc123def456",
  "client_secret": "ghp_aBcDeFgHiJkLmNoPqRsTuVwXyZ",
  "webhook_secret": "f31ab2058d69ec74",
  "private_key_file": "C:\\tools\\plane\\github-app-credentials\\private-key.pem"
}
```

---

## Integrating with Plane

### Option 1: Docker Compose

Add to your `.env` file:

```bash
# Copy values from .env.github-app
GITHUB_APP_ID=123456
GITHUB_CLIENT_ID=Iv1.abc123def456
GITHUB_CLIENT_SECRET=ghp_aBcDeFgHiJkLmNoPqRsTuVwXyZ
GITHUB_WEBHOOK_SECRET=f31ab2058d69ec74
GITHUB_PRIVATE_KEY="$(cat github-app-credentials/private-key.pem)"
```

Update `docker-compose.yml`:

```yaml
services:
  api:
    environment:
      - GITHUB_APP_ID=${GITHUB_APP_ID}
      - GITHUB_CLIENT_ID=${GITHUB_CLIENT_ID}
      - GITHUB_CLIENT_SECRET=${GITHUB_CLIENT_SECRET}
      - GITHUB_WEBHOOK_SECRET=${GITHUB_WEBHOOK_SECRET}
      - GITHUB_PRIVATE_KEY=${GITHUB_PRIVATE_KEY}
```

---

### Option 2: Kubernetes

Create a secret:

```bash
kubectl create secret generic plane-github-app \
  --from-literal=app-id=123456 \
  --from-literal=client-id=Iv1.abc123def456 \
  --from-literal=client-secret=ghp_aBcDeFgHiJkLmNoPqRsTuVwXyZ \
  --from-literal=webhook-secret=f31ab2058d69ec74 \
  --from-file=private-key=github-app-credentials/private-key.pem
```

Reference in deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: plane-api
spec:
  template:
    spec:
      containers:
      - name: api
        env:
        - name: GITHUB_APP_ID
          valueFrom:
            secretKeyRef:
              name: plane-github-app
              key: app-id
        - name: GITHUB_CLIENT_ID
          valueFrom:
            secretKeyRef:
              name: plane-github-app
              key: client-id
        - name: GITHUB_CLIENT_SECRET
          valueFrom:
            secretKeyRef:
              name: plane-github-app
              key: client-secret
        - name: GITHUB_WEBHOOK_SECRET
          valueFrom:
            secretKeyRef:
              name: plane-github-app
              key: webhook-secret
        - name: GITHUB_PRIVATE_KEY
          valueFrom:
            secretKeyRef:
              name: plane-github-app
              key: private-key
```

---

### Option 3: Environment Variables (Development)

```bash
export GITHUB_APP_ID=123456
export GITHUB_CLIENT_ID=Iv1.abc123def456
export GITHUB_CLIENT_SECRET=ghp_aBcDeFgHiJkLmNoPqRsTuVwXyZ
export GITHUB_WEBHOOK_SECRET=f31ab2058d69ec74
export GITHUB_PRIVATE_KEY="$(cat github-app-credentials/private-key.pem)"
```

---

## Post-Creation Steps

### 1. Install the App on Repositories

Visit: `https://github.com/settings/apps/plane-local-dev/installations`

- Click "Install"
- Select repositories (all or specific)
- Confirm installation

### 2. Configure Webhook Endpoint

The webhook URL is already configured: `http://localhost:8000/api/v1/github/webhook/`

For production, update to your public URL.

### 3. Test the Integration

```bash
# Test webhook endpoint
curl -X POST http://localhost:8000/api/v1/github/webhook/ \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: ping" \
  -d '{"zen": "Keep it logically awesome."}'

# Expected response: 200 OK
```

### 4. Verify in Plane

- Navigate to Plane settings
- Check GitHub integration status
- Test repository connection

---

## Troubleshooting

### Issue: "gh: command not found"

**Solution:** Install GitHub CLI

```powershell
# Windows (winget)
winget install --id GitHub.cli

# Or download from: https://cli.github.com/
```

### Issue: "Not authenticated with GitHub CLI"

**Solution:** Login to GitHub

```bash
gh auth login
```

### Issue: "Private key file not found"

**Solution:** Ensure the .pem file downloaded to your Downloads folder

```powershell
# Check Downloads folder
ls $env:USERPROFILE\Downloads\*.pem

# Move to credentials folder
Move-Item "$env:USERPROFILE\Downloads\your-app.pem" "C:\tools\plane\github-app-credentials\private-key.pem"
```

### Issue: "Webhook not receiving events"

**Checklist:**
1. Verify app is installed on repository
2. Check webhook URL is accessible (use ngrok for local)
3. Verify webhook secret matches
4. Check Plane logs for errors

### Issue: "Rate limit exceeded"

**Solution:** GitHub Apps have higher rate limits. Ensure you're using app authentication, not personal token.

---

## Security Best Practices

### 1. Never Commit Credentials

Add to `.gitignore`:

```
# GitHub App Credentials
github-app-credentials/
.env.github-app
credentials.json
private-key.pem
*.pem
```

### 2. Rotate Secrets Regularly

- Generate new client secret every 90 days
- Rotate webhook secret quarterly
- Generate new private key if compromised

### 3. Use Environment-Specific Apps

- Development: `Plane Local Dev`
- Staging: `Plane Staging`
- Production: `Plane Production`

### 4. Limit Permissions

Only grant permissions your app needs:
- `contents: write` - For repository access
- `issues: write` - For issue management
- `pull_requests: write` - For PR management

### 5. Monitor App Activity

Check logs regularly:
- Failed authentication attempts
- Unusual API usage
- Permission escalation attempts

---

## Manifest Configuration Explained

```json
{
  "name": "Plane Local Dev",              // App name (must be unique)
  "url": "http://localhost:3000",         // Homepage URL
  "hook_attributes": {
    "url": "http://localhost:8000/api/v1/github/webhook/",  // Webhook endpoint
    "active": true                        // Enable webhooks
  },
  "redirect_url": "http://localhost:3000/api/auth/github/callback",  // OAuth callback
  "callback_urls": ["http://localhost:3000/api/auth/github/callback"],
  "setup_url": "http://localhost:3000",   // Post-installation redirect
  "description": "Plane project management integration",
  "public": false,                        // Private app (recommended for dev)
  "default_permissions": {
    "contents": "write",                  // Read/write repository contents
    "issues": "write",                    // Manage issues
    "metadata": "read",                   // Read repository metadata
    "pull_requests": "write",             // Manage pull requests
    "statuses": "write",                  // Update commit statuses
    "members": "read"                     // Read organization members
  },
  "default_events": [                     // Webhook events to subscribe to
    "issues",                             // Issue created/updated
    "issue_comment",                      // Comments on issues
    "pull_request",                       // PR created/updated
    "pull_request_review",                // PR reviews
    "pull_request_review_comment",        // PR review comments
    "push"                                // Code pushed
  ]
}
```

---

## Alternative: Manual Creation (Backup Method)

If scripts fail, create manually:

1. Go to: https://github.com/settings/apps/new
2. Fill in the form:
   - **Name:** Plane Local Dev
   - **Homepage URL:** http://localhost:3000
   - **Callback URL:** http://localhost:3000/api/auth/github/callback
   - **Webhook URL:** http://localhost:8000/api/v1/github/webhook/
   - **Webhook Secret:** f31ab2058d69ec74
3. Set permissions (see manifest above)
4. Subscribe to events (see manifest above)
5. Click "Create GitHub App"
6. Save credentials as shown in scripts

---

## Comparison: GitHub App vs Personal Access Token

| Feature | GitHub App | Personal Token |
|---------|-----------|----------------|
| Rate Limit | 5,000/hour per installation | 5,000/hour total |
| Permissions | Fine-grained | Broad scopes |
| Security | More secure (short-lived tokens) | Less secure (long-lived) |
| Installation | Per repository | User-wide |
| Webhooks | Built-in | Requires separate setup |
| **Recommendation** | **Use for production** | Use for testing only |

---

## Next Steps

1. Run one of the creation scripts
2. Install app on your repositories
3. Configure Plane with credentials
4. Test webhook delivery
5. Monitor integration logs
6. Set up production app (different from dev)

---

## Support

If you encounter issues:

1. Check Plane documentation: https://docs.plane.so
2. GitHub Apps documentation: https://docs.github.com/apps
3. Check script output for error messages
4. Verify authentication with `gh auth status`

---

## References

- [GitHub Apps Documentation](https://docs.github.com/apps)
- [App Manifest Flow](https://docs.github.com/apps/sharing-github-apps/registering-a-github-app-from-a-manifest)
- [GitHub CLI Documentation](https://cli.github.com/)
- [Plane.so Documentation](https://docs.plane.so)

---

**Generated:** 2025-10-13
**Scripts Version:** 1.0.0
**Author:** DevOps Automation
