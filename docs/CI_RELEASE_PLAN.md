# GitHub CI Release Plan

**Status**: ✅ IMPLEMENTED
**Priority**: Medium
**Target**: Windows & macOS builds

---

## Overview

Automated build and release pipeline using GitHub Actions to create Windows and macOS executables when a new version tag is pushed.

## Trigger

```yaml
on:
  push:
    tags:
      - 'v*'  # Triggers on v1.0.0, v1.2.3, etc.
```

## Build Matrix

| Platform | Runner | Export Preset | Output |
|----------|--------|---------------|--------|
| Windows | `windows-latest` | "Windows Desktop" | `MinecraftSurvivors-Windows.zip` |
| macOS | `macos-latest` | "macOS" | `MinecraftSurvivors-macOS.zip` |

---

## Workflow File

`.github/workflows/release.yml`

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
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Godot
        uses: chickensoft-games/setup-godot@v2
        with:
          version: ${{ env.GODOT_VERSION }}
          use-dotnet: false

      - name: Import Project
        run: godot --headless --import

      - name: Build Windows
        run: |
          mkdir -p build/windows
          godot --headless --export-release "Windows Desktop" build/windows/${{ env.GAME_NAME }}.exe

      - name: Package Windows
        run: |
          cd build/windows
          7z a -tzip ../../${{ env.GAME_NAME }}-Windows-${{ github.ref_name }}.zip *

      - name: Upload Artifact
        uses: actions/upload-artifact@v4
        with:
          name: windows-build
          path: ${{ env.GAME_NAME }}-Windows-${{ github.ref_name }}.zip

  build-macos:
    runs-on: macos-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Godot
        uses: chickensoft-games/setup-godot@v2
        with:
          version: ${{ env.GODOT_VERSION }}
          use-dotnet: false

      - name: Import Project
        run: godot --headless --import

      - name: Build macOS
        run: |
          mkdir -p build/macos
          godot --headless --export-release "macOS" build/macos/${{ env.GAME_NAME }}.app

      - name: Package macOS
        run: |
          cd build/macos
          zip -r ../../${{ env.GAME_NAME }}-macOS-${{ github.ref_name }}.zip ${{ env.GAME_NAME }}.app

      - name: Upload Artifact
        uses: actions/upload-artifact@v4
        with:
          name: macos-build
          path: ${{ env.GAME_NAME }}-macOS-${{ github.ref_name }}.zip

  create-release:
    needs: [build-windows, build-macos]
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - name: Download Windows Build
        uses: actions/download-artifact@v4
        with:
          name: windows-build

      - name: Download macOS Build
        uses: actions/download-artifact@v4
        with:
          name: macos-build

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          files: |
            ${{ env.GAME_NAME }}-Windows-${{ github.ref_name }}.zip
            ${{ env.GAME_NAME }}-macOS-${{ github.ref_name }}.zip
          generate_release_notes: true
          draft: false
          prerelease: ${{ contains(github.ref_name, 'alpha') || contains(github.ref_name, 'beta') }}
```

---

## Export Presets

Need to create `export_presets.cfg` in project root:

```ini
[preset.0]
name="Windows Desktop"
platform="Windows Desktop"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="build/windows/MinecraftSurvivors.exe"
encryption_include_filters=""
encryption_exclude_filters=""
encrypt_pck=false
encrypt_directory=false

[preset.0.options]
custom_template/debug=""
custom_template/release=""
debug/export_console_wrapper=1
binary_format/embed_pck=true
texture_format/bptc=true
texture_format/s3tc=true
texture_format/etc=false
texture_format/etc2=false
binary_format/architecture="x86_64"
codesign/enable=false
application/modify_resources=true
application/icon="res://assets/icon.ico"
application/console_wrapper_icon=""
application/icon_interpolation=4
application/file_version=""
application/product_version=""
application/company_name="Minecraft Survivors"
application/product_name="Minecraft Survivors"
application/file_description=""
application/copyright=""
application/trademarks=""
application/export_angle=0
ssh_remote_deploy/enabled=false

[preset.1]
name="macOS"
platform="macOS"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="build/macos/MinecraftSurvivors.app"
encryption_include_filters=""
encryption_exclude_filters=""
encrypt_pck=false
encrypt_directory=false

[preset.1.options]
custom_template/debug=""
custom_template/release=""
debug/export_console_wrapper=1
binary_format/architecture="universal"
texture_format/bptc=true
texture_format/s3tc=true
texture_format/etc=false
texture_format/etc2=false
codesign/codesign=1
codesign/installer_identity=""
codesign/apple_team_id=""
codesign/identity=""
codesign/entitlements/custom_file=""
codesign/entitlements/allow_jit_code_execution=false
codesign/entitlements/allow_unsigned_executable_memory=false
codesign/entitlements/allow_dyld_environment_variables=false
codesign/entitlements/disable_library_validation=false
codesign/entitlements/audio_input=false
codesign/entitlements/camera=false
codesign/entitlements/location=false
codesign/entitlements/address_book=false
codesign/entitlements/calendars=false
codesign/entitlements/photos_library=false
codesign/entitlements/apple_events=false
codesign/entitlements/debugging=false
codesign/entitlements/app_sandbox/enabled=false
codesign/entitlements/app_sandbox/network_server=false
codesign/entitlements/app_sandbox/network_client=false
codesign/entitlements/app_sandbox/device_usb=false
codesign/entitlements/app_sandbox/device_bluetooth=false
codesign/entitlements/app_sandbox/files_downloads=0
codesign/entitlements/app_sandbox/files_pictures=0
codesign/entitlements/app_sandbox/files_music=0
codesign/entitlements/app_sandbox/files_movies=0
codesign/entitlements/app_sandbox/helper_executables=[]
notarization/notarization=0
privacy/microphone_usage_description=""
privacy/camera_usage_description=""
privacy/location_usage_description=""
privacy/address_book_usage_description=""
privacy/calendar_usage_description=""
privacy/photos_library_usage_description=""
privacy/desktop_folder_usage_description=""
privacy/documents_folder_usage_description=""
privacy/downloads_folder_usage_description=""
privacy/network_volumes_usage_description=""
privacy/removable_volumes_usage_description=""
application/icon="res://assets/icon.icns"
application/bundle_identifier="com.minecraftsurvivors.game"
application/signature=""
application/app_category="Games"
application/short_version="1.0.0"
application/version="1.0.0"
application/copyright=""
application/copyright_localized={}
application/min_macos_version="10.12"
application/export_angle=0
display/high_res=true
ssh_remote_deploy/enabled=false
```

---

## Required Assets

| Asset | Path | Format | Notes |
|-------|------|--------|-------|
| Windows Icon | `assets/icon.ico` | ICO | 256x256 multi-resolution |
| macOS Icon | `assets/icon.icns` | ICNS | 1024x1024 |

### Create Icons

**Windows (.ico)**:
```bash
# Using ImageMagick
convert icon.png -define icon:auto-resize=256,128,64,48,32,16 icon.ico
```

**macOS (.icns)**:
```bash
# On macOS
mkdir icon.iconset
sips -z 16 16     icon.png --out icon.iconset/icon_16x16.png
sips -z 32 32     icon.png --out icon.iconset/icon_16x16@2x.png
sips -z 32 32     icon.png --out icon.iconset/icon_32x32.png
sips -z 64 64     icon.png --out icon.iconset/icon_32x32@2x.png
sips -z 128 128   icon.png --out icon.iconset/icon_128x128.png
sips -z 256 256   icon.png --out icon.iconset/icon_128x128@2x.png
sips -z 256 256   icon.png --out icon.iconset/icon_256x256.png
sips -z 512 512   icon.png --out icon.iconset/icon_256x256@2x.png
sips -z 512 512   icon.png --out icon.iconset/icon_512x512.png
sips -z 1024 1024 icon.png --out icon.iconset/icon_512x512@2x.png
iconutil -c icns icon.iconset
```

---

## Release Process

1. **Update version** in `project.godot`:
   ```ini
   config/version="1.0.0"
   ```

2. **Create and push tag**:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

3. **GitHub Actions runs automatically**:
   - Builds Windows executable
   - Builds macOS app bundle
   - Creates GitHub Release with both files

4. **Release appears at**:
   `https://github.com/newbdez33/minecraft-survivors/releases`

---

## Version Naming

| Tag | Type | Pre-release |
|-----|------|-------------|
| `v1.0.0` | Stable | No |
| `v1.1.0-alpha` | Alpha | Yes |
| `v1.1.0-beta` | Beta | Yes |
| `v1.1.0-rc1` | Release Candidate | Yes |

---

## Implementation Checklist

- [ ] Create `assets/icon.ico` (Windows) - Optional, builds work without custom icon
- [ ] Create `assets/icon.icns` (macOS) - Optional, builds work without custom icon
- [x] Create `export_presets.cfg` - Already exists with Windows, macOS, Linux
- [x] Create `.github/workflows/release.yml` - DONE
- [ ] Test build locally with Godot export
- [ ] Push first tag to test CI
- [ ] Verify releases are created correctly

---

## Optional Enhancements

### 1. itch.io Upload

```yaml
- name: Upload to itch.io
  uses: robpc/itchio-upload-action@v1
  with:
    path: ${{ env.GAME_NAME }}-Windows-${{ github.ref_name }}.zip
    project: your-username/minecraft-survivors
    channel: windows
    api-key: ${{ secrets.ITCHIO_API_KEY }}
```

### 2. Discord Notification

```yaml
- name: Discord Notification
  uses: sarisia/actions-status-discord@v1
  with:
    webhook: ${{ secrets.DISCORD_WEBHOOK }}
    title: "New Release: ${{ github.ref_name }}"
    description: "Download at: ${{ github.server_url }}/${{ github.repository }}/releases/tag/${{ github.ref_name }}"
```

### 3. Linux Build

Add to build matrix:
```yaml
build-linux:
  runs-on: ubuntu-latest
  steps:
    - name: Build Linux
      run: godot --headless --export-release "Linux/X11" build/linux/${{ env.GAME_NAME }}.x86_64
```

---

## Estimated Time

| Task | Time |
|------|------|
| Create icons | 30 min |
| Setup export presets | 15 min |
| Create workflow file | 15 min |
| Test & debug | 1-2 hours |
| **Total** | ~2-3 hours |
