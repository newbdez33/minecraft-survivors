# Deploying to GitHub Pages

This guide explains how to deploy the web version of Minecraft Survivors to GitHub Pages.

## Prerequisites

1. **GitHub Pages enabled** in repository settings
2. **Web export preset** configured in `export_presets.cfg`

## One-Time Setup

### 1. Enable GitHub Pages

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Pages**
3. Under "Build and deployment":
   - **Source**: Select "GitHub Actions"
4. Save

### 2. Verify Export Preset

Ensure `export_presets.cfg` contains the Web preset:

```ini
[preset.3]
name="Web"
platform="Web"
...
```

## Deployment Process

### Automatic Deployment (Recommended)

The workflow automatically deploys when you merge `develop` to `main`:

```bash
# 1. Ensure you're on develop with latest changes
git checkout develop
git pull

# 2. Switch to main and pull latest
git checkout main
git pull origin main

# 3. Merge develop into main
git merge develop -m "Merge develop: <description of changes>"

# 4. Push to trigger deployment
git push origin main

# 5. Switch back to develop for continued work
git checkout develop
```

### Check Deployment Status

1. Go to your repository on GitHub
2. Click **Actions** tab
3. Find "Deploy to GitHub Pages" workflow
4. Check the status (green = success)

### Access the Game

Once deployed, the game is available at:

```
https://<username>.github.io/<repo-name>/
```

For this repository:
**https://newbdez33.github.io/minecraft-survivors/**

## Workflow Details

The deployment workflow (`.github/workflows/deploy-web.yml`) does the following:

1. **Trigger**: Activates on push to `main` branch
2. **Build**:
   - Sets up Godot 4.5.1
   - Imports project assets
   - Exports Web/HTML5 version
3. **Headers**: Adds COOP/COEP headers for SharedArrayBuffer support
4. **Deploy**: Uploads to GitHub Pages

## Troubleshooting

### Build Fails

1. Check the Actions tab for error logs
2. Common issues:
   - Missing export templates
   - Invalid export preset configuration
   - Asset import errors

### Game Doesn't Load

1. **SharedArrayBuffer error**: Ensure COOP/COEP headers are set
2. **CORS issues**: Game must be served from the same origin
3. **Cache**: Try hard refresh (Ctrl+Shift+R)

### Pages Not Updating

1. Check if the workflow completed successfully
2. GitHub Pages may take 1-2 minutes to update
3. Clear browser cache

## Quick Reference

| Action | Command |
|--------|---------|
| Merge and deploy | `git checkout main && git merge develop && git push` |
| Check workflow | GitHub → Actions → "Deploy to GitHub Pages" |
| View game | https://newbdez33.github.io/minecraft-survivors/ |

## Related Files

- `.github/workflows/deploy-web.yml` - Deployment workflow
- `export_presets.cfg` - Export configurations (preset.3 = Web)
- `CLAUDE.md` - Project documentation with CI/CD section
