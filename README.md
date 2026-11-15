# BEFORE IT DROPS: Haven Hack Club game jam (Godot 4.3+)

*We got GTA VI before release day.* A parody platformer set in the city of Vice Slime.

**Theme: Bounce Back.** A Hollow Knight-style platformer: strike down to **pogo** off enemies and spikes.
When you die, your body stays behind holding your geo, as a **bounce pad**. Your failures help you bounce back higher.

Built on Brackeys' "How to make a Video Game - Godot Beginner Tutorial"
(YouTube: https://www.youtube.com/watch?v=LOhfqjmasi0, code: https://github.com/Brackeys/first-game-in-godot, public domain).
Assets: Brackeys Platformer Bundle (CC0): https://brackeysgames.itch.io/brackeys-platformer-bundle. See `CREDITS.md`.

## Run
Open Godot 4.3+, click **Import**, select `project.godot`, then press **F5**.
**Play in the browser:** the itch.io page (web build). **Trailer:** `docs/trailer.mp4`.

Flow: **title screen** → **CHOOSE YOUR FIGHTER** (←/→ pick, ENTER play, **B** = straight to the boss, **R** = co-op) → **story intro** → Level 1 → 2 → 3 → **the Hamster Godfather** → **THE VICE QUEEN** → ending.
**Esc / OPTIONS** pauses (resume · restart · quit to title).

### CO-OP: the whole story for up to 3 (one shared screen)
On the select screen press **R** (or **OPTIONS** on a PS4 pad). In the lobby, each controller presses **CROSS** to join (keyboard: ENTER), uses **LEFT/RIGHT** to pick a fighter, and presses **OPTIONS** (or ENTER) to start. You play Levels 1–3 and both boss fights together.
PS4 controls: stick/d-pad move · CROSS jump · SQUARE attack (hold down in the air = pogo) · CIRCLE or R1 dash.
The camera zooms out to keep everyone and the boss on screen. When a player dies, their body becomes a trampoline for the team, and they bounce back at the bench 1 second later.

### Story mode
GTA VI drops today. Fight through the line of rival buyers (meme hamsters) across **The Docks → Neon Streets → The Roof** to the game store. In front of the store, beat **THE HAMSTER GODFATHER** (a scalper; his backup walks out of the store door), then the final boss **THE VICE QUEEN** (the team's original pixel art) for the **last copy**.

### BOUNCE IT BACK
Strike a `$$$` price tag (scalpers and the Godfather throw them) and it flies back gold, homes in on the nearest enemy and hits twice as hard. It's the way to break the bosses' armor.
Levels are text maps in `scripts/levels.gd`.

### Enemies
| Map letter | Enemy |
|---|---|
| `g` `h` `f` | Hamster guards: lollipop, smug, flame |
| `s` | Scalper: throws price tags |
| `t` | Streamer: fast, spams chat |
| `o` | Preorder guy: receipt shield (pogo him or hit his back) |
| `L` | THE LINE CUTTER: mini-boss that guards the store door |

### Skills
| Key (keyboard / PS4) | Skill |
|---|---|
| L / TRIANGLE | **Special**: SPARK finger gun · ZOOM shoulder charge · BRAINS heal +1 mask |
| I / R2 or L1 | **Power shot**: costs 1/3 of the SOUL meter (fill it by hitting things), piercing, 3 damage |

### Fighters
| Fighter | Perk |
|---|---|
| SPARK | Long reach: nail hits 40% further |
| ZOOM | BRUTE FORCE: double damage, smashes enemies back, can hit the boss from the side |
| BRAINS | 6 masks instead of 5 |

### Controls (Hollow Knight style)
| Key | Action |
|---|---|
| A/D or ←/→ | Move |
| Space | Jump (hold = higher, tap = short hop) |
| J or X | Nail attack (hold W = up-slash; in the air hold S = **down-slash / POGO**) |
| K, C or Shift | Dash (1 air dash, refreshed on landing or after a pogo) |

### Systems
- **5 masks** (health). Enemies knock you back and cost 1 mask. Hazards cost 1 mask and send you to the last safe ground.
- **Geo** (coins). Slimes take 2 hits and drop 2 geo.
- **Benches** = checkpoint + full heal.
- **Death spikes** (`instant_kill`): instant death, so your body lands exactly there. Used for "die on purpose" puzzles.
- **Die → your body stays** with all your geo, as a **bounce pad**. Strike it to take your geo back; land on it to bounce high.
- **Sound:** Kenney CC0 hits, smashes and sax jingles (`scripts/sfx.gd`, `Sfx.play("hit")`). One global `Music` player; the boss fight plays it faster.
- **Look:** one dark-purple outline shader on every sprite + a Vice Slime sunset/vignette color grade (`scripts/look.gd`, `assets/shaders/`).

## Files
| File | What it does |
|---|---|
| `scripts/player.gd` | Brackeys movement + nail attack, pogo, dash, knockback, bouncing on bodies |
| `scripts/game_manager.gd` | Masks, geo, deaths, benches, hazard respawn, enemy HP, leaving bodies, HUD |
| `scripts/body_pad.gd` | Your body: solid, bouncy, holds your geo (glowing dot) |
| `scripts/killzone.gd` | Damage area. `leaves_body` on = enemy; off = hazard. `instant_kill` = death spikes |
| `scripts/checkpoint.gd` + `scenes/checkpoint.tscn` | **Bench**: drag into a level (respawn here + heal) |
| `scenes/boss_arena.tscn` + `scripts/boss_arena.gd` | Boss room "The Throne", built from Brackeys tiles (`assets/world_tileset.tres`) |
| `scripts/slime_king.gd` | **Hamster Godfather** boss: hops, slams (jump the shockwave), spawns lollipop guards in phase 2. Pogo, ZOOM, or power shots hurt him; side nail hits CLANK |
| `scenes/character_select.tscn` + `scripts/character_select.gd` | Home screen: CHOOSE YOUR FIGHTER (main scene) |
| `scenes/story_level.tscn`, `scripts/story_level.gd`, `scripts/levels.gd` | Story levels built from text maps |
| `scripts/city_backdrop.gd` | Parallax Vice Slime city behind every level (docks / streets / roof) and the **game store front** in the boss arena, all drawn in code |
| `scripts/rival.gd`, `scripts/enemy_shot.gd` | Rival buyers + Line Cutter mini-boss (original characters drawn in code) |
| `scripts/guard.gd`, `scripts/projectile.gd`, `assets/hamsters/` | Hamster guards, power shots and sparks |
| `scenes/raid_lobby.tscn`, `scripts/raid_lobby.gd`, `scripts/raid_camera.gd` | BOSS RAID co-op: join lobby + shared zooming camera |
| `scripts/characters.gd` + `assets/characters/` | Fighter list, perks, animation mapping (rename fighters here) |
| `scripts/boss_portrait.gd` + `assets/boss/` | Boss face next to the health bar that reacts (smug, angry, squashed, enraged, defeated). Drop hand-drawn PNGs in `assets/boss/` to replace the placeholder |
| `scripts/ending.gd` | After the boss: MISSION PASSED, then all your old bodies stand up. "They all got back up." |
| `scripts/vice_layer.gd` | GTA VI parody layer: sunset tint, SLIME ALERT stars, BOUNCED death screen, MISSION PASSED, meme title card. Game title constant lives here |
| `scenes/menu.tscn`, `scenes/intro.tscn`, `scripts/pause_menu.gd`, `scripts/game_feel.gd`, `scripts/scene_transition.gd` | Mazen: title screen, story intro, pause menu, hit/landing feel, fades |
| `assets/boss/final/` | THE VICE QUEEN: body + 6 mood portraits (team art). Name/line in `scripts/slime_king.gd` |
| `tests/test_*.gd` (13 tests) | `godot --headless -s tests/<file>.gd` should print `RESULT: PASS`. `tests/demo_full.gd` records the full-game trailer |
| `export_presets.cfg` | Web export preset (Project → Export → Web) |

## Level design numbers (tile = 16 px)
| Move | Height / distance |
|---|---|
| Normal jump | ≈ 2 tiles up |
| Pogo off an enemy or spike | ≈ 2 tiles up from the hit point (chainable) |
| Bounce on a body | ≈ 4–5 tiles up (hold jump ≈ 5–6) |
| Dash | ≈ 3–4 tiles across |

## Level design rules
1. Every level needs at least one ledge you can **only** reach by bouncing on your own body. Put **death spikes** (`instant_kill = true`) right below it.
2. Teach pogo before you require it (a single slime over a small gap first).
3. Put a **bench** before every hard part, but never right on a death spot (you'd respawn on your body and bounce instantly).
4. Pits = hazard killzone (`leaves_body = false`): costs 1 mask, puts you back on the edge.

## Team
- **Abdullah Bedir:** core mechanics, bosses, co-op, merging, web build, pitch.
- **Ziko:** levels, secrets, level tests.
- **Mazen Ragab:** title screen, story intro, pause menu, game feel, controls card.

