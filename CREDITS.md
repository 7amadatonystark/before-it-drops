# Credits & code origin

## Base project: 100% human-written tutorial
- **Brackeys, "How to make a Video Game - Godot Beginner Tutorial"** (YouTube, Apr 2024): https://www.youtube.com/watch?v=LOhfqjmasi0
- Source: https://github.com/Brackeys/first-game-in-godot, released into the **public domain** (Unlicense, see `LICENSE-brackeys.txt`).
- Mechanics inspired by **Hollow Knight** (Team Cherry): pogo, masks, benches, dash, Shade. Inspiration only; no Hollow Knight code or assets are used.
- The "Vice Slime" layer is a **parody** of GTA VI conventions (wanted stars, WASTED, Mission Passed): text and colors only. No Rockstar logos, fonts, art or names are used.

## Assets
- **Brackeys Platformer Bundle** (CC0): https://brackeysgames.itch.io/brackeys-platformer-bundle
  - Sprites from asset packs credited by Brackeys; music by Sofia Thirslund; sounds by Asbjørn Thirslund; font by Jayvee Enaguas (HarvettFox96).
- All files in `assets/` are byte-for-byte identical to the Brackeys originals (checked).
- **Hamster guards + Hamster Godfather + boss portraits** (`assets/hamsters/`, `assets/boss/`): cut from meme drawings supplied by the team. **Source/artist: TODO, fill in.**
- **Fighters SPARK / ZOOM / BRAINS** (`assets/characters/`): cut from 3 character sheets supplied by the team. **Source/artist: TODO, fill in who made them.**
- **Sound effects: Kenney (www.kenney.nl), CC0 1.0.** "Impact Sounds" (nail hits, smashes), "Music Jingles" (mission passed, bounced, victory, bounce-back ding, enemy down) and "Interface Sounds" (tag throw). Files in `assets/sounds/kenney/`, license in `LICENSE_CC0.txt`. Human-made, not AI-generated.

- **THE VICE QUEEN (final boss):** original pixel art drawn by the team (Abdullah), cut out and sized by script. Files in `assets/boss/final/`.

## Audit vs. the original tutorial (checked file by file)
| File | Status |
|---|---|
| `scripts/slime.gd` | Unchanged Brackeys |
| `scripts/coin.gd` | Brackeys + team fix: group-based manager lookup in generated story levels and one reward per pickup |
| `scenes/player.tscn`, `slime.tscn`, `coin.tscn`, `platform.tscn`, `music.tscn`, `killzone.tscn` | Unchanged Brackeys |
| `scenes/game.tscn` | Brackeys + 1 line (`leaves_body = false` on the pit killzone) |
| `scripts/player.gd` | Brackeys base + team additions (nail attack, pogo, dash, knockback, bounce on bodies) |
| `scripts/game_manager.gd` | Brackeys base + team additions (masks, geo, benches, hazard respawn, enemy HP, bodies, HUD) |
| `scripts/killzone.gd` | Brackeys base + team additions (damage instead of reload; hazard / death-spike options) |
| `scripts/body_pad.gd`, `scripts/checkpoint.gd` (bench), `scenes/checkpoint.tscn` | New: our mechanics |
| `scripts/boss_arena.gd`, `slime_king.gd`, `ending.gd`, `vice_layer.gd`, `scenes/boss_arena.tscn` | New: boss, ending, GTA-parody layer (text and colors only; Brackeys sprites and tiles) |
| `scripts/characters.gd`, `scripts/character_select.gd`, `scenes/character_select.tscn` | New: fighter select + per-fighter perks/animations |
| `scripts/raid_lobby.gd`, `scripts/raid_camera.gd`, `scenes/raid_lobby.tscn` | New: local co-op BOSS RAID |
| `scripts/story_level.gd`, `scripts/levels.gd`, `scripts/guard.gd`, `scripts/projectile.gd`, `scenes/story_level.tscn` | New: story mode, guards, specials, power shot |
| `scripts/rival.gd`, `scripts/enemy_shot.gd` | New: original rival-buyer characters + Line Cutter mini-boss, drawn in code |
| `scripts/city_backdrop.gd` | New: city skyline background drawn in code (original, no images) |
| `assets/world_tileset.tres` | Brackeys tileset, exported from `game.tscn` so other scenes can use it |
| `tests/*` | New: test and demo tools (not part of the game) |

Team additions were written with AI coding help, which our local event allows for code. Every script starts with an `ORIGIN:` comment saying where it came from.
