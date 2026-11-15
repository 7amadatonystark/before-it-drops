# Agent brief: ZIKO (Levels)

You're Ziko's coding agent. Ziko owns **the levels**: where the fun and the theme happen.
Read `/AGENTS.md` first (hard rules + progress report). Branch name: `ziko/levels`.

## Deadline
**Pull requests must be open by 2:45 PM.** Feature freeze is at 3:00 PM and submission is at 5:00 PM.

## How levels work
The story levels are **text maps** in `scripts/levels.gd` (1 character = 1 tile, 16 px). Edit the maps; no scene editing needed. Press F5, pick a fighter, play. (Quick test: in `story_level.gd` the level number comes from `Engine.get_meta("level_index")`.)
Each level also has `title`, `line` (story text), `signs`, `exit` (door label), `tiles` (grass / brick / stone / sand) and `backdrop` (docks / streets / roof / store).

Legend:
| Char | Thing |
|---|---|
| `#` | ground |
| `=` | one-way platform (put them in pairs) |
| `X` | death spikes (instant death, your body stays) |
| `P` | start · `B` bench · `C` coin · `E` exit |
| `g` / `h` / `f` | hamster guards: lollipop (2 HP) / smug (3 HP, fast) / flame (5 HP, hops) |
| `1`-`9` | sign (text in `"signs"`) |
| `.` | empty (falling below the map = pit) |

**Rival buyers (ready on `main`):** `s` scalper (throws price tags) · `t` streamer (fast) · `o` preorder guy (receipt shield: pogo him or hit his back) · `L` THE LINE CUTTER mini-boss (the exit stays locked until he's beaten; one is already on the Level 3 roof).

## Numbers (tile = 16 px)
- Normal jump ≈ 2.9 tiles up and ≈ 5 tiles across. Pogo ≈ 2.9 tiles up from the hit point.
- Body bounce ≈ 5.6 tiles up (hold jump ≈ 8). Dash ≈ 3.3 tiles across (1 air dash).
- A 3-tile wall needs a pogo. A 5-tile wall needs a body bounce (put `X` right in front of it).
- All fighters run at the same speed. SPARK reaches further, ZOOM hits twice as hard, BRAINS has 6 masks.

## Tasks (in order; report after each)
1. **Playtest Levels 1-3** with SPARK, ZOOM and BRAINS. Each must be beatable. Fix anything impossible or boring by editing the maps.
2. **Secrets:** 1-2 per level, coins on high ledges reachable only by a body bounce or a pogo chain.
3. **Guards:** more in Level 2, a flame guard on the Level 3 ledge.
4. **Rival buyers:** add a few `s` / `t` / `o` to each level (one of each is already placed in Levels 1-2). Make sure the Line Cutter's roof is wide enough for his charge to be dodgeable.
5. **Report** the minimum deaths per level and anything unfair.

## Done when
All 3 levels can be beaten with every fighter, and the Level 3 exit leads to the boss (already wired).
