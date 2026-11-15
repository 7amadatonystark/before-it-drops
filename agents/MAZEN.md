# Agent brief: MAZEN (Menus, UI & Game Feel)

You're Mazen's coding agent. Mazen owns **everything around the gameplay**: the story intro, pause menu, and how good it *feels*.
Read `/AGENTS.md` first (hard rules + progress report). Branch name: `mazen/ui-feel`.

## Deadline
**Pull requests must be open by 2:45 PM.** Feature freeze is at 3:00 PM and submission is at 5:00 PM. Small and working beats big and broken.

## What already exists (don't rebuild it)
- **Select screen** (`scenes/character_select.tscn`, main scene): title "BEFORE IT DROPS", 3 fighters, pad support, B = boss, R / OPTIONS = BOSS RAID.
- **Story levels** (`scenes/story_level.tscn` + `scripts/levels.gd`), **boss + ending** (`scenes/boss_arena.tscn`), **co-op lobby** (`scenes/raid_lobby.tscn`).
- **HUD**: masks (one row per player), SOUL bar, GEO, deaths, SLIME ALERT stars.
- **GTA-parody layer** (`vice_layer.gd`): BOUNCED death screen, MISSION PASSED, level title cards.
- **Game feel already done**: camera shake, slow-mo on death, slash arc, squash on bounce, SMASH! popups.

## Facts you need
- Font: `assets/fonts/PixelOperator8-Bold.ttf`. Music: `scenes/music.tscn`. Sounds: `assets/sounds/`.
- Story text: `Levels.STORY` in `scripts/levels.gd` (`const Levels = preload("res://scripts/levels.gd")`).
- Start the story from your code: `Engine.set_meta("level_index", 1)` then `get_tree().change_scene_to_file("res://scenes/story_level.tscn")`.
- Game manager (group `"game_manager"`): `deaths`, `score` (= geo), `soul`, `players` (array), `masks` (player 1). Each player: `pmasks`, `pmax`, `is_dead`, `velocity`, `is_on_floor()`.
- Body bounce = a player's `velocity.y` <= -400 right after landing. Pogo = `velocity.y` suddenly about -300 in the air.
- **Every screen must work with a PS4 pad**: d-pad / stick to move, CROSS to confirm, CIRCLE to go back, OPTIONS = pause in game.
- You can't edit protected scripts, so react from **your own** scripts (autoloads or nodes that watch values each frame).

## Already merged from your branch (thanks!)
Title screen `scenes/menu.tscn` (now the main scene → fighter select), `Stats` autoload + `level_stats.gd`, your pit-during-immunity fix and both tests. **Your old branch started from an outdated `main`, so start fresh:** `git checkout main && git pull && git checkout -B mazen/ui-feel-2`.

## Tasks (in order; one PR each; report after each)
1. **Story intro:** `scenes/intro.tscn` + `scripts/intro.gd`. Black screen; show each line of `Levels.STORY` one by one (typewriter or fade); "Press any key / CROSS". Then start the story (see above). The select screen already goes to `scenes/intro.tscn` automatically as soon as that file exists.
2. **Pause menu:** autoload `PauseMenu` (`scripts/pause_menu.gd`, add it to `project.godot` [autoload]). Esc or OPTIONS pauses during levels and the boss (not on the select screen or lobby). Buttons: Resume / Restart level (`reload_current_scene`) / Change fighter (`scenes/character_select.tscn`). Works with pad + mouse + keyboard. Process mode ALWAYS.
3. **Game feel extras** (new autoload or node, watch values):
   - "BOING!" popup + dust puff (CPUParticles2D) on body bounces; small white spark on pogo.
   - White screen flash (0.05 s) when any player loses a mask.
   - Fade-to-black between scenes (`SceneTransition` autoload with a ColorRect).
4. **Controls card:** a "CONTROLS" button in the pause menu showing keyboard + PS4 controls (see README "Controls" and "Skills").

## Done when
Select → Intro → Level 1-3 → Boss → Ending all flow, pause works everywhere in game with keyboard and pad, and the effects show up without editing protected scripts.
