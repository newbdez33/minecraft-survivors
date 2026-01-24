# Release Plan (发布计划)

**目标**: Phase 5 完成后，通过 GitHub CI 自动构建并发布 Windows 和 macOS 版本。

---

## 发布概览

| 平台 | 优先级 | 状态 | 发布方式 |
|------|--------|------|----------|
| Windows | 高 | Phase 5后 | GitHub Releases |
| macOS | 高 | Phase 5后 | GitHub Releases |
| Linux | 中 | Phase 5后 | GitHub Releases |
| iOS | 低 | Backlog | App Store |
| Android | 低 | Backlog | Google Play |
| Web | 低 | Backlog | itch.io / GitHub Pages |

---

## 1. GitHub CI/CD 配置

### 1.1 工作流文件结构

```
.github/
├── workflows/
│   ├── build.yml           # 主构建工作流
│   ├── release.yml         # 发布工作流
│   └── test.yml            # 测试工作流
└── ISSUE_TEMPLATE/
    └── bug_report.md
```

### 1.2 构建工作流 (build.yml)

```yaml
# .github/workflows/build.yml
name: Build Game

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  GODOT_VERSION: "4.5.1"
  EXPORT_NAME: "MinecraftSurvivors"

jobs:
  # 运行测试
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Godot
        uses: chickensoft-games/setup-godot@v2
        with:
          version: ${{ env.GODOT_VERSION }}
          use-dotnet: false

      - name: Run Tests
        run: |
          godot --headless --script tests/test_runner.gd --quit-after 300

  # Windows 构建
  build-windows:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v4

      - name: Setup Godot
        uses: chickensoft-games/setup-godot@v2
        with:
          version: ${{ env.GODOT_VERSION }}
          use-dotnet: false
          include-templates: true

      - name: Import Project
        run: godot --headless --import

      - name: Build Windows
        run: |
          mkdir -p build/windows
          godot --headless --export-release "Windows Desktop" build/windows/${{ env.EXPORT_NAME }}.exe

      - name: Upload Windows Build
        uses: actions/upload-artifact@v4
        with:
          name: windows-build
          path: build/windows/

  # macOS 构建
  build-macos:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v4

      - name: Setup Godot
        uses: chickensoft-games/setup-godot@v2
        with:
          version: ${{ env.GODOT_VERSION }}
          use-dotnet: false
          include-templates: true

      - name: Import Project
        run: godot --headless --import

      - name: Build macOS
        run: |
          mkdir -p build/macos
          godot --headless --export-release "macOS" build/macos/${{ env.EXPORT_NAME }}.zip

      - name: Upload macOS Build
        uses: actions/upload-artifact@v4
        with:
          name: macos-build
          path: build/macos/

  # Linux 构建
  build-linux:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v4

      - name: Setup Godot
        uses: chickensoft-games/setup-godot@v2
        with:
          version: ${{ env.GODOT_VERSION }}
          use-dotnet: false
          include-templates: true

      - name: Import Project
        run: godot --headless --import

      - name: Build Linux
        run: |
          mkdir -p build/linux
          godot --headless --export-release "Linux" build/linux/${{ env.EXPORT_NAME }}.x86_64

      - name: Upload Linux Build
        uses: actions/upload-artifact@v4
        with:
          name: linux-build
          path: build/linux/
```

### 1.3 发布工作流 (release.yml)

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags:
      - 'v*'  # 触发条件：推送 v 开头的 tag，如 v1.0.0

env:
  GODOT_VERSION: "4.5.1"
  EXPORT_NAME: "MinecraftSurvivors"

jobs:
  build-all:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        include:
          - platform: windows
            export_preset: "Windows Desktop"
            extension: ".exe"
          - platform: macos
            export_preset: "macOS"
            extension: ".zip"
          - platform: linux
            export_preset: "Linux"
            extension: ".x86_64"

    steps:
      - uses: actions/checkout@v4

      - name: Setup Godot
        uses: chickensoft-games/setup-godot@v2
        with:
          version: ${{ env.GODOT_VERSION }}
          use-dotnet: false
          include-templates: true

      - name: Import Project
        run: godot --headless --import

      - name: Build ${{ matrix.platform }}
        run: |
          mkdir -p build/${{ matrix.platform }}
          godot --headless --export-release "${{ matrix.export_preset }}" \
            build/${{ matrix.platform }}/${{ env.EXPORT_NAME }}${{ matrix.extension }}

      - name: Create Archive
        run: |
          cd build/${{ matrix.platform }}
          if [ "${{ matrix.platform }}" = "windows" ]; then
            zip -r ../${{ env.EXPORT_NAME }}-${{ matrix.platform }}-${{ github.ref_name }}.zip .
          elif [ "${{ matrix.platform }}" = "linux" ]; then
            tar -czvf ../${{ env.EXPORT_NAME }}-${{ matrix.platform }}-${{ github.ref_name }}.tar.gz .
          else
            mv ${{ env.EXPORT_NAME }}.zip ../${{ env.EXPORT_NAME }}-${{ matrix.platform }}-${{ github.ref_name }}.zip
          fi

      - name: Upload Artifact
        uses: actions/upload-artifact@v4
        with:
          name: ${{ matrix.platform }}-release
          path: build/${{ env.EXPORT_NAME }}-${{ matrix.platform }}-${{ github.ref_name }}.*

  create-release:
    runs-on: ubuntu-latest
    needs: build-all
    permissions:
      contents: write

    steps:
      - uses: actions/checkout@v4

      - name: Download All Artifacts
        uses: actions/download-artifact@v4
        with:
          path: releases/

      - name: Generate Changelog
        id: changelog
        run: |
          echo "## What's Changed" > CHANGELOG.md
          echo "" >> CHANGELOG.md
          git log --pretty=format:"- %s" $(git describe --tags --abbrev=0 HEAD^)..HEAD >> CHANGELOG.md || echo "- Initial release" >> CHANGELOG.md

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          files: releases/**/*
          body_path: CHANGELOG.md
          draft: false
          prerelease: ${{ contains(github.ref_name, 'beta') || contains(github.ref_name, 'alpha') }}
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### 1.4 测试工作流 (test.yml)

```yaml
# .github/workflows/test.yml
name: Run Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

env:
  GODOT_VERSION: "4.5.1"

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Godot
        uses: chickensoft-games/setup-godot@v2
        with:
          version: ${{ env.GODOT_VERSION }}
          use-dotnet: false

      - name: Import Project
        run: godot --headless --import

      - name: Run Unit Tests
        run: |
          godot --headless --script tests/test_runner.gd --quit-after 300 2>&1 | tee test_output.txt
          if grep -q "FAILED" test_output.txt; then
            exit 1
          fi

      - name: Upload Test Results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: test-results
          path: test_output.txt

  visual-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Godot
        uses: chickensoft-games/setup-godot@v2
        with:
          version: ${{ env.GODOT_VERSION }}
          use-dotnet: false

      - name: Setup Virtual Display
        run: |
          sudo apt-get update
          sudo apt-get install -y xvfb
          Xvfb :99 -screen 0 1920x1080x24 &
          echo "DISPLAY=:99" >> $GITHUB_ENV

      - name: Import Project
        run: godot --headless --import

      - name: Run Visual Tests
        run: |
          timeout 300 godot --path . tests/visual/visual_test_runner.tscn || true

      - name: Upload Screenshots
        uses: actions/upload-artifact@v4
        with:
          name: visual-test-screenshots
          path: ~/.local/share/godot/app_userdata/*/test_screenshots/
```

---

## 2. Godot 导出配置

### 2.1 export_presets.cfg

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
codesign/enable=false
application/modify_resources=true
application/icon="res://assets/icon.ico"
application/console_wrapper_icon=""
application/icon_interpolation=4
application/file_version=""
application/product_version=""
application/company_name="Minecraft Survivors"
application/product_name="Minecraft Survivors"
application/file_description="Minecraft Survivors Game"
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
export_path="build/macos/MinecraftSurvivors.zip"
encryption_include_filters=""
encryption_exclude_filters=""
encrypt_pck=false
encrypt_directory=false

[preset.1.options]

custom_template/debug=""
custom_template/release=""
debug/export_console_wrapper=1
binary_format/embed_pck=true
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
codesign/entitlements/app_sandbox/files_user_selected=0
notarization/notarization=0
application/icon="res://assets/icon.icns"
application/bundle_identifier="com.minecraftsurvivors.game"
application/signature=""
application/app_category="public.app-category.games"
application/short_version=""
application/version=""
application/copyright=""
application/copyright_localized={}
application/min_macos_version="10.14"
application/export_angle=0
display/high_res=true
ssh_remote_deploy/enabled=false

[preset.2]

name="Linux"
platform="Linux"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="build/linux/MinecraftSurvivors.x86_64"
encryption_include_filters=""
encryption_exclude_filters=""
encrypt_pck=false
encrypt_directory=false

[preset.2.options]

custom_template/debug=""
custom_template/release=""
debug/export_console_wrapper=1
binary_format/embed_pck=true
texture_format/bptc=true
texture_format/s3tc=true
texture_format/etc=false
texture_format/etc2=false
binary_format/architecture="x86_64"
ssh_remote_deploy/enabled=false
```

---

## 3. 版本号规范

### 3.1 语义化版本

```
v{major}.{minor}.{patch}[-{prerelease}]

示例:
- v1.0.0        # 正式发布
- v1.0.1        # Bug修复
- v1.1.0        # 新功能
- v2.0.0        # 重大更新
- v1.0.0-beta.1 # Beta测试版
- v1.0.0-alpha.1 # Alpha测试版
```

### 3.2 版本历史规划

| 版本 | 内容 | 状态 |
|------|------|------|
| v0.1.0-alpha | Phase 1-3 核心功能 | 完成 |
| v0.2.0-alpha | Phase 4 游戏感觉 | 完成 |
| v0.3.0-beta | Phase 5 游戏增强 | 计划中 |
| v1.0.0 | 正式发布版 | 计划中 |

---

## 4. 发布流程

### 4.1 发布检查清单

```markdown
## 发布前检查

### 代码质量
- [ ] 所有单元测试通过 (277+ tests)
- [ ] 所有视觉测试通过 (33 scenarios)
- [ ] 无编译警告
- [ ] 代码已审查

### 游戏功能
- [ ] 游戏可以正常启动
- [ ] 主要功能都能正常工作
- [ ] 存档/读档功能正常
- [ ] 本地化显示正确 (EN/JA/ZH)

### 构建测试
- [ ] Windows 构建可运行
- [ ] macOS 构建可运行
- [ ] Linux 构建可运行

### 文档
- [ ] README 已更新
- [ ] CHANGELOG 已更新
- [ ] 版本号已更新

### 发布
- [ ] 创建 Git Tag
- [ ] GitHub Release 自动创建
- [ ] 下载链接有效
```

### 4.2 发布命令

```bash
# 1. 确保在 main 分支
git checkout main
git pull origin main

# 2. 合并 develop
git merge develop

# 3. 更新版本号 (在 project.godot)
# config/version="1.0.0"

# 4. 提交版本更新
git add project.godot
git commit -m "chore: bump version to v1.0.0"

# 5. 创建 Tag
git tag -a v1.0.0 -m "Release v1.0.0 - Phase 5 Complete"

# 6. 推送
git push origin main
git push origin v1.0.0

# GitHub Actions 会自动:
# - 运行测试
# - 构建 Windows/macOS/Linux
# - 创建 GitHub Release
# - 上传构建文件
```

---

## 5. 发布产物

### 5.1 文件结构

```
MinecraftSurvivors-windows-v1.0.0.zip
├── MinecraftSurvivors.exe
├── MinecraftSurvivors.pck
└── README.txt

MinecraftSurvivors-macos-v1.0.0.zip
└── MinecraftSurvivors.app/
    └── Contents/
        ├── Info.plist
        ├── MacOS/
        │   └── MinecraftSurvivors
        └── Resources/
            └── MinecraftSurvivors.pck

MinecraftSurvivors-linux-v1.0.0.tar.gz
├── MinecraftSurvivors.x86_64
├── MinecraftSurvivors.pck
└── README.txt
```

### 5.2 Release Notes 模板

```markdown
# Minecraft Survivors v1.0.0

## 🎮 游戏特性

### Phase 5 新增内容
- ☠️ **中毒系统**: 女巫药水造成持续伤害
- 🏆 **排行榜**: 本地高分记录
- ⭐ **成就系统**: 15个可解锁成就
- 👥 **角色系统**: Steve 和 Alex
- 🔥 **连击系统**: 连续击杀获得加成
- ⚔️ **武器进化**: 弓箭→十字弓
- 💎 **幸运掉落**: 稀有道具掉落
- 📺 **屏幕反馈**: 震动、伤害数字、特效

### 游戏内容
- 6种敌人: Zombie, Skeleton, Spider, Creeper, Enderman, Witch
- 8相日夜循环
- 7种被动升级
- 多语言支持: English, 日本語, 中文

## 📥 下载

| 平台 | 下载 |
|------|------|
| Windows | [MinecraftSurvivors-windows-v1.0.0.zip](link) |
| macOS | [MinecraftSurvivors-macos-v1.0.0.zip](link) |
| Linux | [MinecraftSurvivors-linux-v1.0.0.tar.gz](link) |

## 🎯 系统要求

### 最低配置
- OS: Windows 10 / macOS 10.14 / Ubuntu 20.04
- CPU: 双核 2.0 GHz
- RAM: 4 GB
- GPU: OpenGL 3.3 兼容
- 存储: 200 MB

## 🐛 已知问题
- 无

## 📝 更新日志
[完整更新日志](CHANGELOG.md)
```

---

## 6. macOS 代码签名 (可选)

如需分发到 macOS 且避免"无法验证开发者"警告：

### 6.1 Apple Developer 账号

1. 注册 Apple Developer Program ($99/年)
2. 创建 Developer ID Application 证书
3. 创建 App-specific password

### 6.2 GitHub Secrets 配置

```
APPLE_CERTIFICATE_BASE64    # 导出的 .p12 证书 (base64)
APPLE_CERTIFICATE_PASSWORD  # 证书密码
APPLE_ID                    # Apple ID 邮箱
APPLE_APP_PASSWORD          # App-specific password
APPLE_TEAM_ID               # Team ID
```

### 6.3 签名工作流更新

```yaml
# 在 macOS 构建步骤后添加
- name: Sign macOS App
  if: matrix.platform == 'macos'
  env:
    APPLE_CERTIFICATE: ${{ secrets.APPLE_CERTIFICATE_BASE64 }}
    APPLE_PASSWORD: ${{ secrets.APPLE_CERTIFICATE_PASSWORD }}
  run: |
    # 导入证书
    echo $APPLE_CERTIFICATE | base64 --decode > certificate.p12
    security create-keychain -p "" build.keychain
    security import certificate.p12 -k build.keychain -P "$APPLE_PASSWORD" -T /usr/bin/codesign
    security set-key-partition-list -S apple-tool:,apple: -s -k "" build.keychain

    # 签名
    codesign --force --deep --sign "Developer ID Application" build/macos/MinecraftSurvivors.app
```

---

## 7. 时间线

| 阶段 | 时间 | 任务 |
|------|------|------|
| Phase 5 开发 | Week 1-4 | 实现所有功能 |
| 测试 | Week 5 | 运行所有测试，修复Bug |
| Beta 发布 | Week 6 | v1.0.0-beta.1 |
| 反馈收集 | Week 6-7 | 收集用户反馈 |
| Bug 修复 | Week 7-8 | 修复报告的问题 |
| 正式发布 | Week 8 | v1.0.0 |

---

## 附录: 图标资源

需要准备的图标文件：

| 文件 | 尺寸 | 用途 |
|------|------|------|
| icon.ico | 多尺寸 (16-256) | Windows |
| icon.icns | 多尺寸 (16-1024) | macOS |
| icon.png | 512x512 | Linux/通用 |

可使用工具生成:
- https://makeappicon.com/
- https://iconverticons.com/
