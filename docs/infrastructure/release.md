# Release & CI/CD Guide / 发布与CI指南

**Status**: ✅ IMPLEMENTED

本文档描述自动化构建和发布流程。

---

## 1. Overview / 概述

Automated build and release pipeline using GitHub Actions to create Windows, macOS, and Linux executables when a new version tag is pushed.

### Supported Platforms

| Platform | Priority | Status | Distribution |
|----------|----------|--------|--------------|
| Windows | High | ✅ Released | GitHub Releases |
| macOS | High | ✅ Released | GitHub Releases |
| Linux | Medium | ✅ Released | GitHub Releases |
| Web | High | ✅ Released | GitHub Pages |
| iOS | Low | Backlog | App Store |
| Android | Low | Backlog | Google Play |

---

## 2. Release Workflow / 发布流程

### Trigger

```yaml
on:
  push:
    tags:
      - 'v*'  # Triggers on v1.0.0, v1.2.3, etc.
```

### Build Matrix

| Platform | Runner | Export Preset | Output |
|----------|--------|---------------|--------|
| Windows | `windows-latest` | "Windows Desktop" | `MinecraftSurvivors-Windows.zip` |
| macOS | `macos-latest` | "macOS" | `MinecraftSurvivors-macOS.zip` |
| Linux | `ubuntu-latest` | "Linux" | `MinecraftSurvivors-Linux.tar.gz` |

---

## 3. GitHub Actions Workflow

**File**: `.github/workflows/release.yml`

```yaml
name: Build and Release

on:
  push:
    tags:
      - 'v*'

env:
  GODOT_VERSION: 4.5.1
  GAME_NAME: MinecraftSurvivors

jobs:
  build-windows:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - uses: chickensoft-games/setup-godot@v2
        with:
          version: ${{ env.GODOT_VERSION }}
          use-dotnet: false
      - run: godot --headless --import
      - run: |
          mkdir -p build/windows
          godot --headless --export-release "Windows Desktop" build/windows/${{ env.GAME_NAME }}.exe
      - uses: actions/upload-artifact@v4
        with:
          name: windows-build
          path: build/windows/

  build-macos:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: chickensoft-games/setup-godot@v2
        with:
          version: ${{ env.GODOT_VERSION }}
          use-dotnet: false
      - run: godot --headless --import
      - run: |
          mkdir -p build/macos
          godot --headless --export-release "macOS" build/macos/${{ env.GAME_NAME }}.app
      - uses: actions/upload-artifact@v4
        with:
          name: macos-build
          path: build/macos/

  create-release:
    needs: [build-windows, build-macos]
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/download-artifact@v4
      - uses: softprops/action-gh-release@v2
        with:
          files: |
            windows-build/*
            macos-build/*
          generate_release_notes: true
          prerelease: ${{ contains(github.ref_name, 'alpha') || contains(github.ref_name, 'beta') || contains(github.ref_name, 'rc') }}
```

---

## 4. Version Naming / 版本命名

### Semantic Versioning

```
v{major}.{minor}.{patch}[-{prerelease}]

Examples:
- v1.0.0        # Stable release
- v1.0.1        # Bug fix
- v1.1.0        # New feature
- v2.0.0        # Major update
- v1.0.0-beta.1 # Beta test
- v1.0.0-alpha.1 # Alpha test
- v1.0.0-rc1    # Release candidate
```

| Tag | Type | Pre-release |
|-----|------|-------------|
| `v1.0.0` | Stable | No |
| `v1.1.0-alpha` | Alpha | Yes |
| `v1.1.0-beta` | Beta | Yes |
| `v1.1.0-rc1` | Release Candidate | Yes |

---

## 5. Release Process / 发布流程

### Step by Step

```bash
# 1. Ensure on main branch
git checkout main
git pull origin main

# 2. Merge develop
git merge develop

# 3. Update version in project.godot
# config/version="1.0.0"

# 4. Commit version update
git add project.godot
git commit -m "chore: bump version to v1.0.0"

# 5. Create tag
git tag -a v1.0.0 -m "Release v1.0.0"

# 6. Push
git push origin main
git push origin v1.0.0

# GitHub Actions will automatically:
# - Run tests
# - Build Windows/macOS/Linux
# - Create GitHub Release
# - Upload build files
```

### Pre-release Checklist

```markdown
## Pre-release Checks

### Code Quality
- [ ] All unit tests pass (389+ tests)
- [ ] No compiler warnings
- [ ] Code reviewed

### Game Functionality
- [ ] Game starts normally
- [ ] All major features work
- [ ] Localization displays correctly (EN/JA/ZH)

### Build Testing
- [ ] Windows build runs
- [ ] macOS build runs
- [ ] Linux build runs

### Documentation
- [ ] README updated
- [ ] CHANGELOG updated
- [ ] Version number updated
```

---

## 6. Export Presets / 导出配置

**File**: `export_presets.cfg`

Presets configured for:
- Windows Desktop (x86_64)
- macOS (Universal)
- Linux (x86_64)
- Web/HTML5

---

## 7. Required Assets / 所需资源

| Asset | Path | Format | Notes |
|-------|------|--------|-------|
| Windows Icon | `assets/icon.ico` | ICO | 256x256 multi-resolution |
| macOS Icon | `assets/icon.icns` | ICNS | 1024x1024 |

### Create Icons

**Windows (.ico)**:
```bash
convert icon.png -define icon:auto-resize=256,128,64,48,32,16 icon.ico
```

**macOS (.icns)**:
```bash
mkdir icon.iconset
sips -z 16 16 icon.png --out icon.iconset/icon_16x16.png
# ... (see full script in Godot docs)
iconutil -c icns icon.iconset
```

---

## 8. Web Deployment / Web 部署

**File**: `.github/workflows/deploy-web.yml`

Automatically deploys to GitHub Pages on push to `main`:

1. Builds Web/HTML5 version
2. Configures COOP/COEP headers for SharedArrayBuffer
3. Deploys to GitHub Pages

**Play at**: `https://<username>.github.io/<repo-name>/`

---

## 9. Build Artifacts / 构建产物

```
MinecraftSurvivors-Windows-v1.0.0.zip
├── MinecraftSurvivors.exe
├── MinecraftSurvivors.pck
└── README.txt

MinecraftSurvivors-macOS-v1.0.0.zip
└── MinecraftSurvivors.app/
    └── Contents/
        ├── Info.plist
        ├── MacOS/MinecraftSurvivors
        └── Resources/MinecraftSurvivors.pck

MinecraftSurvivors-Linux-v1.0.0.tar.gz
├── MinecraftSurvivors.x86_64
├── MinecraftSurvivors.pck
└── README.txt
```

---

## 10. Release Notes Template

```markdown
# Minecraft Survivors v1.0.0

## New Features
- Feature 1
- Feature 2

## Bug Fixes
- Fix 1
- Fix 2

## Downloads

| Platform | Download |
|----------|----------|
| Windows | [MinecraftSurvivors-Windows-v1.0.0.zip](link) |
| macOS | [MinecraftSurvivors-macOS-v1.0.0.zip](link) |
| Linux | [MinecraftSurvivors-Linux-v1.0.0.tar.gz](link) |

## System Requirements

### Minimum
- OS: Windows 10 / macOS 10.14 / Ubuntu 20.04
- CPU: Dual-core 2.0 GHz
- RAM: 4 GB
- GPU: OpenGL 3.3 compatible
- Storage: 200 MB
```

---

## 11. Optional Enhancements

### itch.io Upload

```yaml
- uses: robpc/itchio-upload-action@v1
  with:
    path: MinecraftSurvivors-Windows.zip
    project: your-username/minecraft-survivors
    channel: windows
    api-key: ${{ secrets.ITCHIO_API_KEY }}
```

### Discord Notification

```yaml
- uses: sarisia/actions-status-discord@v1
  with:
    webhook: ${{ secrets.DISCORD_WEBHOOK }}
    title: "New Release: ${{ github.ref_name }}"
```

---

## 12. Changelog / 更新日志

- **2026-01-24**: CI/CD workflow implemented
- **2026-01-23**: Initial release plan created
