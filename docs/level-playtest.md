# Ziko — levels handoff

Branch: `ziko/levels`. Base: main `727c1cc`. Engine: official Godot 4.3 stable.

## Current work

| Task | Result |
|---|---|
| 1 — Playtest | Nine scripted routes pass: all three fighters in all three levels. Each Level 3 route reaches the boss scene. |
| 2 — Secrets | One optional high coin ledge per level; all nine secret routes collect the reward and return without another death. |
| 3 — Guards | Two extra lollipop guards in Neon Streets; a flame guard on the first Roof ledge. |
| 4 — Rivals | Docks gains a preorder buyer and streamer; Neon Streets gains a scalper; Roof gains a streamer and preorder buyer. Line Cutter runway expanded from 6 to 23 tiles and spawn moved farther from the entry. |
| 5 — Deaths/fairness | Observed route counts and unfair behavior are reported below. Global minimum deaths and human difficulty remain unverified. |

Other fixes: the original floating Docks scalper now stands on ground; a paired one-way step lets every fighter cross the Docks wall even after nearby enemies die.

The high secret coins sit at `(648, 24)`, `(904, 24)`, and `(72, 24)`, above paired ledges at y48. Tests reach them with a boosted body bounce and check that a measured normal jump from nearby ordinary terrain cannot reach the pickup. This is a local clearance check, not a proof against every advanced route. For example, enemy pogo timing can create alternatives elsewhere in the level.

The Docks return test drops safely left of the spike pad, then reuses that body to reach the exit deck. It selects the original spike body explicitly because the duplicate-death bug can also create a body at the bench.

## Coin reward fix

`coin.gd` is not in AGENTS.md's protected list. Its owner-dependent `%GameManager` lookup ran before dynamically generated coins received their owner. The script now uses the existing `game_manager` group and awards each coin once while its pickup animation finishes. A collision test reproduces pickup, re-entry during the animation, exactly one GEO, and eventual removal. CREDITS.md records this modification.

No protected scripts, assets, input settings, or rendering settings changed.

## Reproduce verification

Run from the repository root using Godot 4.3:

```bash
godot --headless --editor --import --quit
godot --headless -s tests/test_bounce.gd
godot --headless -s tests/test_hk.gd
godot --headless -s tests/test_raid.gd
godot --headless --fixed-fps 60 -s tests/test_story_layout.gd
godot --headless --fixed-fps 60 -s tests/test_story_coin.gd
for level in 1 2 3; do
  for fighter in spark zoom brains; do
    godot --headless --fixed-fps 60 -s tests/test_story_routes.gd -- "$level" "$fighter"
    godot --headless --fixed-fps 60 -s tests/test_story_secrets.gd -- "$level" "$fighter"
  done
done
```

The final serial run passed all **23 invocations**, with no GDScript errors. Each prints `RESULT: PASS`. Engine anchor/resource warnings remain, and some runs log a pre-existing palm-polygon triangulation error.

Normal and secret routes use actual inputs, live enemies, health, and movement. They do not teleport players, grant health, modify movement, or remove enemies. Each starts at its selected level, rather than playing a continuous campaign. The isolated coin test deliberately positions a non-controllable player as a collision fixture; it is not a playthrough.

The locked-gate assertion calls the exit handler directly. After the Line Cutter is beaten, the player physically enters the door and the test asserts the scene transition. Human verification of entering the locked door through its collision signal is still needed. The tests do not beat the final boss or test physical controllers.

The coin collision test does not separately exercise two players entering in the same physics step; its re-entry occurs after the pickup animation disables collision. The production once guard is present, but that particular branch is not directly covered.

The fight controller uses nail attacks, pogo, and power shots; ZOOM's off-edge recovery uses an actual jump, dash, and pogo. It does not move the enemy by script. BRAINS and SPARK use their specials. ZOOM's shoulder charge remains a human playtest item.

## Death counts and minimum-death limits

| Level | SPARK | ZOOM | BRAINS | Intended body gates |
|---|---:|---:|---:|---:|
| Docks | 2 | 2 | 2 | 1 |
| Neon Streets | 2 | 2 | 2 | 1 |
| Roof | 4 | 4 | 4 | 2 |

These are **verified route counts, not minimum deaths**. Each intentional spike fall counted twice in these runs. Pogo routes through moving enemies may bypass gates; a minimum requires separate route discovery, especially after the added enemies. The three secrets return without adding deaths to their respective approaches.

## Needs Abdullah — protected code

1. **Spike falls count twice.** First Roof contact kills near `(79.83, 175.93)`; another death occurs at respawn `(56, 176)` without another approach. The second gate does the same at the bench. Repro: run a Roof route and inspect `DEATH` lines. Investigate deferred collision disable/enable and instant-kill contact around respawn in `player.gd`, `game_manager.gd`, and `killzone.gd`.
2. **Repeated pit falls can escape recovery.** Keep returning to the first Docks pit immediately after hazard respawn. The entry-only killzone calls `player_hit`, which ignores invulnerable players; an ignored entry is never retried. A focused input-only reproduction ended at `(301.37, 16424.24)`, alive with 3 masks below the map.
3. **Line Cutter can be knocked off the deck and hang in midair.** `game_manager.damage_enemy` shifts a Node2D's x position directly; `rival.gd` has no fall/bounds recovery. A ZOOM reproduction left it at `(220.17, 32)` with 7 HP, outside the deck that begins at x288. The test can recover with real dash/pogo inputs, but this remains unfair for players and must not be considered fixed by the map changes.
4. **Baseline raid test timing can flake under concurrent load.** One concurrent Godot 4.3 run sampled an incomplete player list and failed; the unchanged test assumes setup is finished by physics frame 10, while the manager awaits a process frame. The final serial run passed. Godot 4.6.3 also failed the baseline; required-version verification here uses 4.3.
5. Existing anchor/resource warnings and intermittent palm-polygon triangulation errors need a separate owner pass.

The earlier story coin failure is resolved in this branch.

## Human review and applying the handoff

F5, choose each fighter, and play Docks → Neon Streets → Roof → store. Check sign readability, secret visibility, guards near checkpoints, the wanted/death overlays, jump timing, camera bounds, and rooftop combat. Hold jump when landing on the body for the high bounce. If a door was entered during combat, step away and re-enter after beating the Line Cutter.

GitHub publication was denied with HTTP 403 and the terminal has no push credentials. The cumulative patch includes all commits since the original main. From a clean checkout at that base:

```bash
git switch -c ziko/levels
git am /path/to/robot-metabolism-level-fixes.patch
```

Resolve the protected issues and confirm human difficulty/minimum-death routes before treating the full game as submission-ready. No PR has been created and main was not modified.
