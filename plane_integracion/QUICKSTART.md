# GitHub App Creation - Quick Start

## TL;DR

**No, you cannot create GitHub Apps purely via API.** GitHub requires browser authorization for security.

## Fastest Method (2 minutes)

```powershell
# Run this command
python create-github-app.py

# Follow prompts:
# 1. Browser opens → Click "Create GitHub App"
# 2. Copy App ID → Paste in terminal
# 3. Copy Client ID → Paste in terminal
# 4. Generate & copy Client Secret → Paste in terminal
# 5. Download private key → Provide path in terminal

# Done! Credentials saved to: C:\tools\plane\github-app-credentials\
```

## What You Get

```
github-app-credentials/
├── .env.github-app        # For Docker Compose
├── credentials.json       # For scripts
└── private-key.pem        # For authentication
```

## Use in Plane

### Docker Compose

```bash
# Copy to your .env file
cat github-app-credentials/.env.github-app >> .env

# Restart Plane
docker-compose restart
```

### Kubernetes

```bash
kubectl create secret generic plane-github-app \
  --from-file=github-app-credentials/private-key.pem \
  --from-literal=app-id=$(grep GITHUB_APP_ID github-app-credentials/.env.github-app | cut -d= -f2) \
  --from-literal=client-id=$(grep GITHUB_CLIENT_ID github-app-credentials/.env.github-app | cut -d= -f2) \
  --from-literal=client-secret=$(grep GITHUB_CLIENT_SECRET github-app-credentials/.env.github-app | cut -d= -f2) \
  --from-literal=webhook-secret=$(grep GITHUB_WEBHOOK_SECRET github-app-credentials/.env.github-app | cut -d= -f2)
```

## Install App

1. Go to: https://github.com/settings/apps/plane-local-dev/installations
2. Click "Install"
3. Select repositories
4. Done!

## Troubleshooting

**Not authenticated?**
```bash
gh auth login
```

**Script not found?**
```bash
cd C:\tools\plane
python create-github-app.py
```

**Need more help?**
- Read: `GITHUB_APP_SETUP.md` (full documentation)
- Check: https://docs.github.com/apps

---

**Time to complete:** 2 minutes
**Manual steps:** 5 (unavoidable due to GitHub security)
**Automation level:** Maximum possible
