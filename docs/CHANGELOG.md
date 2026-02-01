# Changelog / 更新日志

All notable changes to this project will be documented in this file.
本文件记录项目的所有重要更改。

---

## [Unreleased] - 2026-02-01

### Added / 新增
- **Enemy Animation System / 敌人动画系统**
  - Created `EnemyAnimator` component (`scripts/components/enemy_animator.gd`)
  - Walk animations with bob, tilt, and squash effects
  - Attack animations with windup → strike → recovery sequence
  - Hit reaction with flash and shake
  - Special animations: jump (Spider), teleport (Enderman), explosion swell (Creeper), charge (Ravager), sonic boom (Warden), laser (Elder Guardian), breath attack (Dragon), summon (Evoker)
  - Applied to all 6 regular enemies: Zombie, Spider, Skeleton, Creeper, Enderman, Witch
  - Applied to all 6 bosses: Evoker, Elder Guardian, Ravager, Warden, Wither, Ender Dragon

- **Upgrade Visual Feedback System / 升级视觉反馈系统**
  - Created `UpgradeEffect` class (`scripts/effects/upgrade_effect.gd`)
  - Color-coded effects for each upgrade type (red=sharpness, blue=protection, green=swiftness, etc.)
  - Ring expansion and flash effects
  - Screen flash for high-level upgrades
  - Created `StatPopup` class (`scripts/effects/stat_popup.gd`) for floating damage numbers
  - Integrated with `upgrade_manager.gd` and `sword_base.gd`

- **Visual Tests / 视觉测试**
  - `tests/visual/test_enemy_animations.gd` - 29 tests for EnemyAnimator
  - `tests/visual/test_upgrade_effects.gd` - 28 tests for upgrade effects
  - `tests/visual/test_all_enemies_animations.gd` - 71 tests for all enemy types

- **Character Select Localization / 角色选择多语言**
  - Added translations for character select UI (title, close button)
  - Added translations for character names and descriptions
  - Added stat name translations: HP, Speed, Damage, XP, Pickup

### Fixed / 修复
- **Main Menu Buttons Not Working / 主菜单按钮无法点击**
  - Button signal connections were incorrectly placed in `_start_game_for_test()` instead of `_ready()`
  - Moved all button connections and panel initialization to `_ready()`

- **Enhancement Overwritten by Weapon Upgrade / Enhancement被武器升级覆盖**
  - Added `enhancement_damage_bonus`, `enhancement_range_bonus`, `enhancement_cooldown_reduction` variables to `sword_base.gd`
  - Updated `get_total_damage/range/cooldown()` functions to include enhancement bonuses
  - Updated Sharpness, Sweeping Edge, and Haste application in `upgrade_manager.gd` to use new bonus variables

- **Enemies Sticking to Player / 敌人粘在玩家身上**
  - Increased `min_distance` from 30 to 40-80 (larger for bosses)
  - Changed push formula from additive to override: `velocity = push_direction * speed * push_strength * 2.0`
  - Applied fix to all regular enemies and all bosses

### Changed / 变更
- **Title Logo / 标题Logo**
  - Made letters thicker and more blocky (Minecraft style)
  - MINECRAFT stroke width: 12px → 16px
  - SURVIVORS stroke width: 10px → 14px

- **Character Card UI / 角色卡片UI**
  - Added 12px padding with MarginContainer
  - Added rounded border (8px radius) with StyleBoxFlat
  - Added separator line between description and stats
  - Improved text styling (gold name color with outline)

---

## File Changes Summary / 文件变更摘要

### New Files / 新文件
- `scripts/components/enemy_animator.gd`
- `scripts/effects/upgrade_effect.gd`
- `scripts/effects/stat_popup.gd`
- `tests/visual/test_enemy_animations.gd`
- `tests/visual/test_enemy_animations.tscn`
- `tests/visual/test_upgrade_effects.gd`
- `tests/visual/test_upgrade_effects.tscn`
- `tests/visual/test_all_enemies_animations.gd`
- `tests/visual/test_all_enemies_animations.tscn`
- `docs/CHANGELOG.md`

### Modified Files / 修改文件
- `scripts/ui/main_menu.gd` - Fixed button connections
- `scripts/ui/character_select.gd` - Added localization
- `scripts/ui/character_card.gd` - Added localization, updated node paths
- `scripts/weapons/sword_base.gd` - Added enhancement bonus tracking
- `scripts/systems/upgrade_manager.gd` - Fixed enhancement application, added visual feedback
- `scripts/enemies/zombie.gd` - Added animator, improved anti-sticking
- `scripts/enemies/spider.gd` - Added animator, improved anti-sticking
- `scripts/enemies/skeleton.gd` - Added animator, improved anti-sticking
- `scripts/enemies/creeper.gd` - Added animator, improved anti-sticking
- `scripts/enemies/enderman.gd` - Added animator, improved anti-sticking
- `scripts/enemies/witch.gd` - Added animator, improved anti-sticking
- `scripts/enemies/evoker.gd` - Added animator, added anti-sticking
- `scripts/enemies/elder_guardian.gd` - Added animator, added anti-sticking
- `scripts/enemies/ravager.gd` - Added animator, added anti-sticking
- `scripts/enemies/warden.gd` - Added animator, added anti-sticking
- `scripts/enemies/wither.gd` - Added animator, added anti-sticking
- `scripts/enemies/ender_dragon.gd` - Added animator, added anti-sticking
- `scenes/ui/character_card.tscn` - Improved layout with margins and styling
- `assets/ui/menu/title_logo.svg` - Made thicker/blockier
- `localization/translations.csv` - Added character and stat translations

---

## Version History / 版本历史

For older changes, see git commit history.
更早的变更请查看 git 提交历史。
