# Minecraft Boss List / マインクラフト ボス一覧

This document lists all Minecraft bosses for potential implementation in Minecraft Survivors.

---

## Official Bosses / 公式ボス

### Ender Dragon / エンダードラゴン

| Attribute | Value |
|-----------|-------|
| English Name | Ender Dragon |
| Japanese Name | エンダードラゴン (略称: エンドラ) |
| Chinese Name | 末影龙 |
| HP | 200 (effective 800 due to damage reduction) |
| Location | The End / ジ・エンド |
| Difficulty | ⭐⭐⭐⭐ |

**Special Abilities / 特殊能力:**
- Dragon Breath / ドラゴンブレス - Area damage cloud
- Flight / 飛行 - Flies around the arena
- Charge Attack / 突進攻撃 - Dives at player
- End Crystal Healing / エンドクリスタル回復 - Heals from crystals
- Immune to status effects / 状態異常無効

**Recommended Implementation:**
- Wave 30 boss (FINAL BOSS)
- 800 HP for game balance
- Summons Endermen as minions

---

### Wither / ウィザー

| Attribute | Value |
|-----------|-------|
| English Name | Wither |
| Japanese Name | ウィザー |
| Chinese Name | 凋灵 |
| HP | 300 (Java) / 600 (Bedrock Hard) |
| Location | Summoned / 召喚 |
| Difficulty | ⭐⭐⭐ |

**Special Abilities / 特殊能力:**
- Wither Skull / ウィザースカル - Ranged projectile attack
- Blue Skull / 青スカル - Explosive skull that breaks blocks
- Wither Effect / 凋零効果 - DOT that turns hearts black
- Explosion on Spawn / 召喚時爆発
- Regeneration / 再生 - Heals over time
- Shield Phase / シールドフェーズ - Half HP becomes melee only

**Recommended Implementation:**
- Wave 25 boss (Second-to-last)
- 500 HP for game balance
- Summons Skeletons as minions

---

## Mini-Bosses / ミニボス

### Elder Guardian / エルダーガーディアン

| Attribute | Value |
|-----------|-------|
| English Name | Elder Guardian |
| Japanese Name | エルダーガーディアン |
| Chinese Name | 远古守卫者 |
| HP | 80 |
| Location | Ocean Monument / 海底神殿 |
| Difficulty | ⭐⭐ |

**Special Abilities / 特殊能力:**
- Laser Attack / レーザー攻撃 - Charges then deals damage
- Mining Fatigue Curse / 採掘速度低下の呪い - Debuff aura
- Spike Defense / トゲ防御 - Reflects melee damage
- Swim Speed / 泳ぐ速度 - Fast in water

**Recommended Implementation:**
- Wave 10 boss
- 150 HP for game balance
- Laser attack charges then fires

---

### Warden / ウォーデン

| Attribute | Value |
|-----------|-------|
| English Name | Warden |
| Japanese Name | ウォーデン |
| Chinese Name | 监守者 |
| HP | 500 |
| Location | Deep Dark / ディープダーク |
| Difficulty | ⭐⭐⭐⭐⭐ |

**Special Abilities / 特殊能力:**
- Sonic Boom / ソニックブーム - Ranged unblockable attack
- Melee Slam / 近接叩き - High damage melee
- Darkness Effect / 暗闇効果 - Reduces player vision
- Detection / 探知 - Detects by sound/vibration
- Emerge Animation / 出現アニメーション

**Recommended Implementation:**
- Wave 20 boss
- 400 HP for game balance
- Sonic boom ignores armor

---

### Ravager / ラヴェジャー

| Attribute | Value |
|-----------|-------|
| English Name | Ravager |
| Japanese Name | ラヴェジャー |
| Chinese Name | 劫掠兽 |
| HP | 100 |
| Location | Raids / 襲撃 |
| Difficulty | ⭐⭐ |

**Special Abilities / 特殊能力:**
- Charge Attack / 突進攻撃 - Rams into player
- Roar / 咆哮 - Stuns nearby entities
- Stomp / 踏みつけ - Area damage
- Block Breaking / ブロック破壊 - Destroys crops/leaves

**Recommended Implementation:**
- Wave 15 boss
- 200 HP for game balance
- Charge attack with knockback

---

### Evoker / エヴォーカー

| Attribute | Value |
|-----------|-------|
| English Name | Evoker |
| Japanese Name | エヴォーカー |
| Chinese Name | 唤魔者 |
| HP | 24 |
| Location | Woodland Mansion / 森の洋館 |
| Difficulty | ⭐⭐ |

**Special Abilities / 特殊能力:**
- Vex Summon / ヴェックス召喚 - Summons flying minions
- Fang Attack / 牙攻撃 - Line of fangs from ground
- Magic / 魔法 - Ranged magic attacks

**Recommended Implementation:**
- Wave 5 boss (First boss)
- 100 HP for game balance
- Summons 3 Vexes

---

## Minecraft Dungeons Bosses / マイクラダンジョンズ ボス

### Redstone Monstrosity / レッドストーンの怪物

| Attribute | Value |
|-----------|-------|
| English Name | Redstone Monstrosity |
| Japanese Name | レッドストーンの怪物 (レッドストーン モンストロシティ) |
| Chinese Name | 红石怪物 |
| Location | Fiery Forge / 燃える鍛冶場 |
| Difficulty | ⭐⭐⭐ |

**Special Abilities / 特殊能力:**
- Ground Slam / 地面叩き - Area damage
- Summon Cubes / キューブ召喚 - Spawns Redstone Cubes
- Fire Breath / 火炎ブレス - Cone attack
- Charge / 突進

**Recommended Implementation:**
- Wave 8 boss
- 250 HP
- Summons small cubes periodically

---

### Nameless One / 名もなき者

| Attribute | Value |
|-----------|-------|
| English Name | Nameless One |
| Japanese Name | 名もなき者 (ネームレスワン) |
| Chinese Name | 无名之人 |
| Location | Desert Temple / 砂漠の神殿 |
| Difficulty | ⭐⭐ |

**Special Abilities / 特殊能力:**
- Staff Attack / 杖攻撃 - Ranged magic
- Skeleton Summon / スケルトン召喚 - Spawns skeletons
- Clone / 分身 - Creates decoys
- Teleport / テレポート

**Recommended Implementation:**
- Wave 6 boss
- 150 HP
- Summons skeletons, teleports when hit

---

### Corrupted Cauldron / 腐敗した大釜

| Attribute | Value |
|-----------|-------|
| English Name | Corrupted Cauldron |
| Japanese Name | 腐敗した大釜 (コラプテッドコールドロン) |
| Chinese Name | 腐化炼药锅 |
| Location | Soggy Swamp / 湿った沼地 |
| Difficulty | ⭐⭐ |

**Special Abilities / 特殊能力:**
- Slime Spawn / スライム召喚 - Spawns slimes
- Poison Cloud / 毒雲 - Area poison
- Bubble Attack / 泡攻撃 - Projectiles

**Recommended Implementation:**
- Wave 5 boss
- 200 HP (stationary)
- Spawns slimes, poison clouds

---

### Heart of Ender / エンダーの心臓

| Attribute | Value |
|-----------|-------|
| English Name | Heart of Ender |
| Japanese Name | エンダーの心臓 (ハートオブエンダー) |
| Chinese Name | 末影之心 |
| Location | Obsidian Pinnacle / 黒曜石の尖塔 |
| Difficulty | ⭐⭐⭐⭐ |

**Special Abilities / 特殊能力:**
- Laser Beam / レーザービーム - Sweeping laser
- Teleport / テレポート - Moves around arena
- Shockwave / 衝撃波 - Area knockback
- Summon Endermen / エンダーマン召喚

**Recommended Implementation:**
- Wave 18 boss
- 400 HP
- Multi-phase fight

---

### Arch-Illager / 邪悪な村人の王

| Attribute | Value |
|-----------|-------|
| English Name | Arch-Illager |
| Japanese Name | 邪悪な村人の王 (アーチイリジャー) |
| Chinese Name | 袭掠首领 |
| Location | Final Boss / 最終ボス |
| Difficulty | ⭐⭐⭐⭐ |

**Special Abilities / 特殊能力:**
- Orb of Dominance / 支配のオーブ - Magic attacks
- Summon Mobs / モブ召喚 - Various illagers
- Phase Transitions / フェーズ移行 - Multiple forms
- Magic Blast / 魔法爆発

**Recommended Implementation:**
- Final boss (Wave 30)
- 500 HP
- Multi-phase with minion waves

---

## Implementation Priority / 実装優先度

| Priority | Boss | Wave | HP | Status | Reason |
|----------|------|------|-----|--------|--------|
| 1 | Evoker / エヴォーカー | 5 | 100 | ✅ **DONE** | First boss, minion summoner |
| 2 | Elder Guardian / エルダーガーディアン | 10 | 150 | ⏳ Planned | Good laser mechanic |
| 3 | Ravager / ラヴェジャー | 15 | 200 | ⏳ Planned | Charge attack variety |
| 4 | Warden / ウォーデン | 20 | 400 | ⏳ Planned | Late-game challenge |
| 5 | Wither / ウィザー | 25 | 500 | ⏳ Planned | Second-to-last boss |
| 6 | Ender Dragon / エンダードラゴン | 30 | 800 | ⏳ Planned | FINAL BOSS |

---

## Boss Spawn Mechanics / ボス出現メカニクス

### Proposed System:
1. **Boss Wave**: Every 5 waves, a boss spawns
2. **Boss Health Bar**: Full-screen health bar at top
3. **Arena Clear**: Regular enemies stop spawning during boss
4. **Rewards**: Boss drops special items/XP

### Boss Wave Schedule:
| Wave | Boss | Difficulty |
|------|------|------------|
| 5 | Evoker / 唤魔者 | ⭐⭐ Easy |
| 10 | Elder Guardian / 远古守卫者 | ⭐⭐ Medium |
| 15 | Ravager / 劫掠兽 | ⭐⭐⭐ Medium |
| 20 | Warden / 监守者 | ⭐⭐⭐⭐ Hard |
| 25 | Wither / 凋灵 | ⭐⭐⭐⭐ Very Hard |
| 30 | Ender Dragon / 末影龙 | ⭐⭐⭐⭐⭐ FINAL |

---

## Visual Design Notes / ビジュアルデザインノート

### Size Scale (pixels):
| Boss | Width | Height | Scale vs Player | Wave |
|------|-------|--------|-----------------|------|
| Evoker | 16 | 32 | 1.5x | 5 |
| Elder Guardian | 32 | 32 | 2x | 10 |
| Ravager | 32 | 32 | 2x | 15 |
| Warden | 24 | 48 | 2x | 20 |
| Wither | 48 | 48 | 3x | 25 |
| Ender Dragon | 64 | 48 | 4x | 30 |

### Color Palette:
- **Wither**: Black (#1a1a1a), Dark Gray (#4a4a4a), Blue skull (#5555ff)
- **Ender Dragon**: Black (#0a0a0a), Purple (#aa00aa), Pink eyes (#ff55ff)
- **Warden**: Teal (#008b8b), Dark Blue (#00008b), Glowing core (#55ffff)
- **Elder Guardian**: Gray (#808080), Orange spikes (#ff8800), Cyan eye (#00ffff)

---

## References / 参考資料

- [Minecraft Wiki - Boss](https://minecraft.wiki/w/Boss)
- [Minecraft Wiki JP - エンダードラゴン](https://ja.minecraft.wiki/w/エンダードラゴン)
- [Minecraft Wiki JP - ウィザー](https://ja.minecraft.wiki/w/ウィザー)
- [Minecraft Dungeons Wiki](https://minecraft.fandom.com/ja/wiki/Minecraft_Dungeons:Mob)
- [Minecraft Dungeons Boss Guide](https://gamewith.jp/minecraft-dungeons/article/show/207572)

---

## Version Info

- Document Version: 1.1
- Created: 2026-01-26
- Updated: 2026-01-29
- Game Phase: 6 (Boss System Implementation)
- **Evoker Boss: IMPLEMENTED** (63 tests passing)
