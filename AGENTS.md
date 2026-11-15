# AGENTS.md: rules for every AI coding agent (Codex, Claude, etc.)

You're working on **BEFORE IT DROPS** (set in the city of Vice Slime; repo name: Robot-Metabolism), a Godot 4.3 (GDScript) 2D platformer for the Haven Hack Club game jam (theme: "Bounce Back"), with a GTA VI parody/meme layer.

**Story:** GTA VI drops today. Three friends (SPARK, ZOOM, BRAINS) fight through the line of rival buyers (meme hamsters) to the store, where THE HAMSTER GODFATHER, a scalper, is holding the LAST COPY.
**Game flow:** `scenes/menu.tscn` (main scene, Mazen's title) → `scenes/character_select.tscn` → `scenes/story_level.tscn` built from the text maps in `scripts/levels.gd` (Level 1 The Docks → 2 Neon Streets → 3 The Roof; `Engine.get_meta("level_index")`) → `scenes/boss_arena.tscn` (in front of the game store: Hamster Godfather, then THE VICE QUEEN if `assets/boss/final/body.png` exists) → ending ("You got the LAST COPY"). Co-op (R on the select screen) plays this whole path with 2–3 players.
**Guards:** `scripts/guard.gd` kinds `lolli` (2 HP), `smug` (3 HP, fast), `flame` (5 HP, hops). Map letters g / h / f.
**Rival buyers** (`scripts/rival.gd`, original characters drawn in code): `s` scalper (throws price tags, 3 HP) · `t` streamer (fast zig-zag, 3 HP) · `o` preorder guy (receipt shield blocks front hits; pogo him or hit his back; ZOOM breaks it; 4 HP) · `L` THE LINE CUTTER mini-boss (14 HP, telegraphs then charges; double damage while dizzy; **the level exit stays locked until he's beaten**). All of them shout catchphrases.
**Specials (L / TRIANGLE):** SPARK finger gun (3 sparks) · ZOOM shoulder charge · BRAINS heal +1 mask. **Power shot (I / R2 / L1):** costs 33 SOUL (SOUL fills +11 per hit), piercing, 3 damage (`scripts/projectile.gd`).
**BOSS RAID (local co-op, Brawlhalla-style shared screen):** from the select screen press R / OPTIONS → `scenes/raid_lobby.tscn` → up to 3 players (PS4 pads + keyboard) fight the Hamster Godfather together. Raid setup is in `Engine.get_meta("raid")` (`[{device, char}]`). Each player has its own masks (`pmasks`, `pmax`), input prefix and `player_index`. `game_manager.players` lists them all. Never assume only one player in new code: use the `who` argument of `player_hit(from_pos, hazard, who)` and `player_died(leave_body, who)`.
**Fighters:** SPARK (long reach), ZOOM (brute: double damage, breaks boss armor from the side), BRAINS (6 masks), defined in `scripts/characters.gd`, frames in `assets/characters/<id>/`. The chosen id is stored in `Engine.get_meta("character")`. With no choice (e.g. pressing F6 on a level), the Brackeys knight is used.
**Core mechanics (Hollow Knight style):**
- **Nail attack:** J or X. Hold W to slash up; in the air, hold S to slash down.
- **POGO:** a down-slash that hits an enemy, spikes or one of your bodies bounces you up (HK's signature move, and our "Bounce Back").
- **Dash:** K, C or Shift (one air dash, refreshed on landing or after a pogo).
- **Masks:** 5 health. Enemies = knockback, -1 mask. Hazards (spikes/pits) = -1 mask and respawn at the last safe ground.
- **Geo:** coins. Enemies drop 2 geo.
- **Benches:** checkpoint + full heal.
- **Death spikes:** a killzone with `instant_kill = true` = instant death; your body lands exactly there (for "die on purpose" puzzles).
- **THE TWIST (our Shade):** at 0 masks you die. Your body stays where you fell, holding all your geo, and it becomes a **bounce pad**. Strike your body to take the geo back; land on it to bounce much higher.

## Deadline
PRs open by **2:45 PM** · feature freeze **3:00 PM** · submission **5:00 PM**. Small and working beats big and broken.

## Who are you working for?
- If the human is **Ziko** → read and follow `agents/ZIKO.md`
- If the human is **Mazen** → read and follow `agents/MAZEN.md`
- If you don't know, ask: "Are you Ziko or Mazen?" before changing anything.

## Hard rules (all agents)
1. **Protected files: DO NOT EDIT** `scripts/player.gd`, `scripts/game_manager.gd`, `scripts/body_pad.gd`, `scripts/killzone.gd`, `scripts/characters.gd`, `scripts/character_select.gd`, `scripts/slime_king.gd`, `scripts/boss_portrait.gd`, `scripts/vice_layer.gd`, `scripts/ending.gd`, `scripts/raid_lobby.gd`, `scripts/raid_camera.gd`, `scripts/boss_arena.gd`, `scripts/story_level.gd`, `scripts/guard.gd`, `scripts/projectile.gd`, `scripts/city_backdrop.gd`, `scripts/rival.gd`, `scripts/enemy_shot.gd`. (`scripts/levels.gd`, the level maps, CAN be edited by Ziko.) Abdullah owns them. If you need a change there, say so in your report instead.
2. Work on **your own branch** (`ziko/...` or `mazen/...`). Never push to `main`. Open a pull request when a task works.
3. Godot **4.3**, GDScript, renderer = GL Compatibility (must run in the browser on itch.io).
4. **Don't generate any new assets yourself** (images, music, sounds), and don't add famous meme characters or real people's photos. Use what's in `assets/` (Brackeys bundle, the team's fighter and boss sheets) or CC0 packs from kenney.nl that the human downloads. Credit any new asset in `CREDITS.md`.
5. Keep changes small. Prefer **new scripts and scenes** over editing existing ones.
6. Useful hooks: the player is in group `"player"` (`facing`, `invuln`, `last_safe`, `take_hit()`, `custom_char`, `speed_mult`, `reach`, `power`), bodies are in group `"bounce_pad"` (`geo`), and the game manager is in group `"game_manager"` (`masks`, `max_masks`, `heat` (SLIME ALERT), `score` = geo, `soul`, `deaths`, `respawn_point`, `player_hit(from_pos, hazard)`, `player_died()`, `set_checkpoint(pos)`, `hit_enemy(enemy, by)`). Enemies = any node with a `Killzone` child (killzone `leaves_body = true`); hazards = a killzone with `leaves_body = false`; death spikes = a killzone with `instant_kill = true`. Enemy HP is stored as meta `"hp"` (default 2).
7. After changes, the game must still open and run (F5). If you can run Godot headless, run `tests/test_bounce.gd`, `test_hk.gd`, `test_raid.gd`, `test_hazard_respawn.gd` and `test_stats.gd` (`godot --headless -s tests/<file>`). All must print `RESULT: PASS`.
8. **Always start from the latest `main`** (`git checkout main && git pull`, then create or reset your branch from it). Branches made from an old `main` can't be merged.

## Required: progress report at the end of EVERY response
Finish every response with this block filled in:

```
## PROGRESS REPORT
Agent for: <Ziko|Mazen>
Branch: <branch name>
Task: <task number + name from your agents/ file>
Status: <DONE | IN PROGRESS | BLOCKED>
Done this session:
- <file changed/created>: <what it does>
How to test (human): <exact steps, e.g. "Open scenes/level_1.tscn, press F6, jump over the gap and press S+J on the slime">
Problems / needs Abdullah: <anything blocked, or "none">
Next task: <what you'll do next>
```
