# GitHub App Creation Tools for Plane.so

Automated scripts to create GitHub Apps with minimal manual steps.

## Files Overview

| File | Purpose | Best For |
|------|---------|----------|
| `create-github-app.py` | Python automation script | **RECOMMENDED** - Most user-friendly |
| `create-github-app-automated.ps1` | PowerShell script | Windows users without Python |
| `create-github-app-automated.sh` | Bash script | WSL2/Linux users |
| `create-github-app.ps1` | Simple PowerShell helper | Basic guidance only |
| `GITHUB_APP_SETUP.md` | Complete documentation | Full reference guide |
| `QUICKSTART.md` | Quick reference | 2-minute setup guide |

## Quick Start

### Option 1: Python (Recommended)

```powershell
python create-github-app.py
```

### Option 2: PowerShell

```powershell
.\create-github-app-automated.ps1
```

### Option 3: Bash (WSL2)

```bash
bash create-github-app-automated.sh
```

## What Gets Created

```
github-app-credentials/
├── .env.github-app        # Environment variables
├── credentials.json       # JSON format
└── private-key.pem        # Private key
```

## Key Question: Can You Automate This Completely?

**Answer: NO** - GitHub does not provide API endpoints to create apps without browser authorization.

**Why?** Security. GitHub requires human verification to prevent unauthorized app creation.

**Best Alternative:** These scripts use GitHub's **Manifest Flow** to minimize manual steps to just 5 clicks.

## Manual Steps Required (All Methods)

1. Click "Create GitHub App" in browser
2. Copy App ID
3. Copy Client ID
4. Generate & copy Client Secret
5. Download private key

**Total time:** ~2 minutes

## Features

- **Maximum Automation**: Only 5 manual steps (unavoidable)
- **Multiple Formats**: Saves credentials as .env, JSON, and PEM
- **Interactive**: Clear prompts with colored output
- **Error Handling**: Validates inputs and files
- **Documentation**: Includes next steps and integration guides

## Integration Examples

### Docker Compose

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

### Kubernetes

```yaml
env:
- name: GITHUB_APP_ID
  valueFrom:
    secretKeyRef:
      name: plane-github-app
      key: app-id
```

### Environment Variables

```bash
export GITHUB_APP_ID=123456
export GITHUB_CLIENT_ID=Iv1.abc123
export GITHUB_CLIENT_SECRET=ghp_secret
```

## Security Notes

- Never commit credentials to git
- Use separate apps for dev/staging/prod
- Rotate secrets regularly
- Limit permissions to minimum required

## Prerequisites

- GitHub CLI (`gh`) installed and authenticated
- Python 3.x (for Python script)
- PowerShell 5.1+ (for PowerShell script)
- Bash (for bash script)

## Installation Check

```bash
# Check gh CLI
gh --version
gh auth status

# Check Python
python --version

# Check PowerShell
$PSVersionTable.PSVersion
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `gh: command not found` | Install GitHub CLI: `winget install GitHub.cli` |
| Not authenticated | Run: `gh auth login` |
| Python not found | Install Python 3.x |
| Permission denied | Run PowerShell as Administrator |

## Documentation

- **Quick Start**: `QUICKSTART.md` (2-minute guide)
- **Full Docs**: `GITHUB_APP_SETUP.md` (complete reference)
- **GitHub Docs**: https://docs.github.com/apps
- **Plane Docs**: https://docs.plane.so

## Support

1. Read `GITHUB_APP_SETUP.md` for detailed documentation
2. Check script output for error messages
3. Verify `gh auth status` shows authentication
4. Review GitHub Apps documentation

## Architecture

```
User Request
    ↓
[Script] Creates manifest JSON
    ↓
[Script] Opens browser → GitHub
    ↓
[User] Clicks "Create App" (1 click)
    ↓
[User] Copies credentials (4 inputs)
    ↓
[Script] Saves to multiple formats
    ↓
✓ Ready to use in Plane
```

## Comparison with Alternatives

| Method | Automation Level | Time | Steps |
|--------|-----------------|------|-------|
| **These Scripts** | ✓✓✓ 95% | 2 min | 5 clicks |
| Manual Form | ✗ 0% | 10 min | 20+ fields |
| Manual Manifest | ✓ 50% | 5 min | Paste JSON + 5 clicks |
| Pure API | ✗ Impossible | N/A | Not supported by GitHub |

## Why No Pure API?

GitHub's decision to require browser authorization is intentional:

1. **Security**: Prevents automated abuse
2. **Verification**: Ensures human controls app creation
3. **Audit**: Creates clear authorization trail
4. **Compliance**: Meets security standards

## Alternative Considered

**GitHub Manifest Flow** (used by these scripts):
- POST manifest to GitHub
- Receive temporary code
- User authorizes in browser
- Exchange code for credentials

This is the **most automated method** GitHub supports.

## Success Criteria

After running any script, you should have:

- [x] App created in GitHub
- [x] App ID saved
- [x] Client ID saved
- [x] Client Secret saved
- [x] Private key downloaded
- [x] Credentials in multiple formats
- [x] Ready to integrate with Plane

## Next Steps

1. **Create app**: Run one of the scripts
2. **Install app**: Visit GitHub settings
3. **Configure Plane**: Add credentials
4. **Test webhook**: Verify delivery
5. **Production**: Create separate app

## License

These scripts are provided as-is for Plane.so integration.

## Version

- **Scripts Version**: 1.0.0
- **Last Updated**: 2025-10-13
- **Tested With**:
  - GitHub CLI v2.81.0
  - Python 3.x
  - PowerShell 5.1+
  - Windows 11 / WSL2

---

**Ready to start?** Run: `python create-github-app.py`

**Need help?** Read: `QUICKSTART.md` or `GITHUB_APP_SETUP.md`
