---
name: "Rust: the battle domain"
description: "The battle's model, its scenes, its animations and its text screen (battle, battle_scenes, scene, animation, battle_animations, battle_screen) to the rm2k-snes-battle crate, with the ROMs byte for byte identical"
type: refactor
status: done
assignee: taro
---

From taro, on 2026-09-30, in the converter's migration to Rust: after the
screens (Tataupá) comes the battle. `tools/rm2k-snes/battle/` already has the
experience and the encounters; what remains in Python is
`tools/port/battle.py`, `battle_scenes.py`, `scene.py`, `animation.py`,
`battle_animations.py` and `battle_screen.py` —the last one is the battle's
text screen that the screens left out—.

It starts from `main` at the commit that launches the task. There:
`NO_CACHE=1 just cartuchos` gives `abl.sfc` `cdcc323197ee6c66…`, `special`
`15e4f331fe8ff812…`, `encounter-every-step` `dc83ed698b348032…`; `just
pruebas` 878, `just -f tools/justfile test` 49.

## Inventory: what the Python does today

Read on 2026-09-30:

| module | what it does | who uses it |
|---|---|---|
| `battle.py` | **the rules** the emission writes —which skills the battle can offer (`skill_usable`, `skills_of`, `level_learned`, `skill_command_name`), which actions each enemy has (`actions_of_enemy`), which items are offered (`item_usable_in_battle`), the weapon's SP, a troop's gold— and **the simulator**: `Rng`, `Combatant`, `Battle` and `TroopPage`, which play the battle with the same randomness as the ROM | `mapdata` (the rules), and ABL's tests (the simulator, turn by turn against the console) |
| `battle_screen.py` | the battle's text screen: the geometry (`BA_*`, the five orders), the victory rows and their check that they fit, the cropped orders, the revived text, and `item_text` —the screens' rule for writing with their font— | `mapdata`, and the tests (`arnes/batalla.py`, `test_victoria.py`) |
| `scene.py`, `battle_scenes.py` | the backgrounds and the battlers: which ones the cartridge carries, their pixels —scaled with Pillow's `LANCZOS`, reduced with `palette.reduce` or `adeleine`— and their bytes for the `.inc` and the `.msu` | `snes_convert`, `mapdata`, `msu_data`, the scene's tests |
| `animation.py`, `battle_animations.py` | the battle animations: their cells via `rm2k-render`, the console's tint (`color.apply_tint`), the shrinking with `LANCZOS`, `palette.reduce`, and the frames for the `.inc` | `snes_convert`, `map_convert`, `obj_extras`, `mapdata`, `test_parches`, `test_animacion_cuadros` |

## The boundary

**Into `rm2k-snes-battle` goes: the battle's model and its text screen**
—`battle.py` and `battle_screen.py` whole—. **The battle's drawings stay
out** —`scene.py`, `battle_scenes.py`, `animation.py`,
`battle_animations.py`—: see "What stays out".

The stage adds four subcommands to `tables`, which doesn't change:

* **`model`**, the converter's second call, after compiling. **It receives**
  what the cartridge decided and what other domains answered: the actors that
  can be in the party (`possible_members`), the troops the cartridge asks for
  (the compiler's), the items it knows (`items_rom`), the (actor, skill) pairs
  of the compiler (`events.SKILL_SLOT`, in the order of their slot) and the
  width of an item's name, which belongs to the screens. **It reads from the
  dump** the actors, the skills, the items, the enemies, the troops, the terms
  and the states. **It returns** in `model.json`: the screen's geometry
  (`layout`, with `BATTLE_SEED` and `ACTIONS_MAX`); the troops' enemies, with
  their actions; the skills the cartridge carries and those that levelling up
  teaches; at what level the LDB teaches each pair; which items are offered in
  battle; each troop's gold and experience; and the texts the battle writes,
  already cropped —the victory rows, the orders, each actor's for their
  skill, the revived one, the enemy and skill names—. And it says no if the
  victory doesn't fit in its window or an enemy brings more actions than the
  ROM weighs.
* **`simulate`**, for the tests: a battle —actors with their equipment, their
  level and their skills if they're changed; separate enemies or a troop; the
  seed, a troop's pages and its switches— and a list of steps —start, a turn
  with its orders, flee, an enemy action, set HP—; it answers the whole state
  at the end and what each step returned. ABL's tests ask for it through
  `rom/pruebas/arnes/modelo.py`, which keeps the steps and replays the battle
  every time it needs to be looked at: it's deterministic, and that way the
  stage doesn't keep state between calls.
* **`lines`**, for the tests: the victory rows built as the ROM builds them
  —"90 EXP", "Kersh LEVEL 21 achieved!"—.
* **`layout`**: the geometry alone.

**The emission stays in Python** (`mapdata`): it reads from `model.json` what
today it asks `battle.py` and `battle_screen.py`, and the LDB's raw fields
—an enemy's HP, a skill's cost— it still reads from `lcf`, as today: they're
data, not rules. `item_text`, the screens' rule with which the emission writes
all its texts, moves to `screen_stage.py`, which is where the screens' stuff
lives on the Python side.

**The event compiler isn't duplicated**: the troop pages are compiled by
`rm2k-snes-events`, and what the stage reads from them is only what the
simulator needs —when a page runs and which `ShowHiddenMonster`,
`ControlSwitches` and switch branches it has—, which the compiler doesn't
model.

**The RM2k rules other stages already use** —an actor's parameter at its
level, the summed equipment— are copied inside the stage, as
`rm2k-snes-screens` has them in its `texts.rs`: moving them to `rm2k-rules`
means touching two other stages, and it's noted.

## What stays out

* **The battle's drawings**: the backgrounds, the battlers and the
  animations. All three go through Pillow's scaling (`LANCZOS`) and through
  `palette.reduce`, which are the same as `palette.convert`'s —the title, the
  Game Over, the pictures—, and the animations also through
  `color.apply_tint`, which is the screen tint's. Bringing them over without
  that would be moving them halfway: the scaling has to move first, for all of
  them together. What isn't about pixels —which backgrounds and battlers go,
  `patch_uses`, their bytes' format— stays with them, because without the
  pixels it does nothing.

## Done

**The battle's model and its text screen are in Rust**, in
`rm2k-snes-battle`, and `battle.py` and `battle_screen.py` were deleted. The
three ROMs and all of `rom/build/` come out byte for byte identical to
`main`'s; the only difference comes from the last commit's prose, in the
`.dbg`s: see below. The battle's drawings stay in Python: see "What stays
out".

| commit | what |
|---|---|
| `254a53a3` | the task: inventory and boundary |
| `e9441441` | the stage with `model`, `simulate`, `lines` and `layout`; `snes_convert` calls it through `port/battle_stage.py` and `mapdata` writes what it answers; ABL's tests ask for the battle through `rom/pruebas/arnes/modelo.py` |
| `ee79eefe` | the crate's tests against the Python's hashes, with its small game in `tests/game/` |
| `382c046c` | the deletion, only deletion |
| `cd570252` | the prose that named what was deleted —the runtime, `mapdata`, `lcf`, the tests, `tools/README.md`, `AGENTS.md`— |
| `a784774c` | merge of `main` (`0cb3625c`) |

**The crate** adds to `tables`, which didn't change:

* `db.rs`: the database as the battle reads it —actors, skills, items,
  enemies, states, terms and, only if the request names one, the troops,
  which are almost the whole database—;
* `rules.rs`: what RM2k says about the database, trimmed to what this battle
  does —which skills it offers and to whom, what each enemy does, which items
  go in the list, the weapon's SP, what a troop gives—;
* `screen.rs`: the screen's geometry and the texts —the orders, the victory
  rows, the revived one— and the check that they fit;
* `simulate.rs`: the battle turn by turn —the randomness, the combatants, the
  troop pages—, with each formula naming its easyrpg function;
* `model.rs`: the requests and answers of `model`, `simulate` and `lines`.
  Its README states the shape of each one.

On the Python side, `port/battle_stage.py` remains —`model`'s request—,
`item_text` moved to `port/screen_stage.py`, and the tests have
`arnes/modelo.py`, with the same names as the earlier model (`Battle`,
`play_turn`, `actor_of`), which keeps the steps and replays the whole battle
every time it needs to be looked at.

**What changed from the planned boundary**: nothing substantial. Two things
that weren't written down:

* **`CheckTurns` stopped being tested in ABL's tests**: it was
  `modelo._turns`, a model function the test called directly. The four cases
  moved to the crate (`check_turns_is_easyrpgs`), and the Lazer Teeth test
  expects turns 1 and 4 written out.
* **Orders with an item or skill carry its number**, not the `lcf` object; and
  a battle's troop goes by number (`troop=`, `pages=`).

## How it was verified

With throwaway scripts in `<scratchpad>/cardon/`:

* **`compara_model.py`**: what `mapdata` asked `battle.py` and
  `battle_screen.py`, against `model`, on 41 sets of inputs over the whole
  game —all the actors, troops and items, and forty random ones with extra
  (actor, skill) pairs—, and the geometry name by name: identical.
* **`compara_simulate.py`**: 5500 random battles over the whole game —with
  attacks, defends, escapes, items, skills, separate enemy actions, HP set by
  hand, troop pages with their switches—, each combatant's whole state and
  what each step returned: identical, and the ones the Python rejected,
  rejected.
* **`referencia.py`**: the crate tests' small game and the Python's hashes
  —400 battles, 1808 turns, 30 that refuse; 26 models; the victory rows—,
  which are now `cargo test -p rm2k-snes-battle`.
* **The cartridges**: `NO_CACHE=1 just cartuchos` and the sha256 of all of
  `rom/build/` —1032 files, without the cache, the `.o`s, `sello.txt` or
  `conversor.log`; the `.dbg` without `mtime`; the PNGs decoded—, identical to
  the baseline after each commit up to the deletion. After the prose,
  identical except the three `.dbg`s, which name the size of the runtime's
  sources: with the earlier sizes they give the same sha256
  (`verifica_dbg.py`); the comments were rewritten without changing how many
  lines each file has, so no line shifted.
* **The ROMs' sha256**, identical on `main` and here, also after the merge:
  * `release/abl.sfc` `cdcc323197ee6c66d82b1304ce20c3c37f4124d13a6867e851fd13226046b7df`
  * `tests/special/prueba.sfc` `15e4f331fe8ff8123803ae3819a2212a5b84d71cd0a053b7261a9188bbab84b9`
  * `tests/encounter-every-step/prueba.sfc` `dc83ed698b348032514dbb76eaf5f535b6296944075fcba786087533ed5b8a4b`
* **The suites**, after each commit and on the merge: `just pruebas` 878,
  `just -f tools/justfile test` 49, `cargo test -p rm2k-snes-battle` green.

## When merging

* Install `battle` in the global: `just -f tools/justfile install battle`.
  Without the new `rm2k-snes-battle` the converter stops at the second call
  —the old one doesn't know `model`— and so do the battle tests.
* `install-scripts` isn't needed: modules were added and deleted
  (`port/battle_stage.py`, `rom/pruebas/arnes/modelo.py`), not programs, and
  no global symlink points at them.
* It moves neither the ROM nor goldens.

## What stays out

* **The battle's drawings**: the backgrounds, the battlers and the
  animations. All three go through Pillow's scaling (`LANCZOS`) and through
  `palette.reduce`, which are the same as `palette.convert`'s —the title, the
  Game Over, the pictures—, and the animations also through
  `color.apply_tint`, which is the screen tint's. Bringing them over without
  that would be moving them halfway: the scaling has to move first, for all of
  them together. What isn't about pixels —which backgrounds and battlers go,
  `patch_uses`, their bytes' format— stays with them, because without the
  pixels it does nothing.

## What's missing

* **The battle's drawings**, from above: `scene.py`, `battle_scenes.py`,
  `animation.py` and `battle_animations.py`, after the scaling.
* **The actors have no critical hit, neither in the ROM nor in the model, and
  the LDB says they do.** The Python model read `critical_hit` with a
  `getattr` that always fell to the default —`lcf.Actor` doesn't store the
  field—, and `battle.s` sets `BA_CRIT` to zero with the comment "no actor in
  ABL has a critical hit". The dump says the opposite: Kersh, Core, Manta,
  Talan, Arden and AG7 have `critical_hit` on, most with
  `critical_hit_chance` 30. Both sides are wrong the same way, so no test sees
  it. It was kept —with a comment in `Combatant::actor`—, because fixing it
  moves the ROM and the randomness of every battle: it belongs to another
  task, and it would have to be measured against the original.
* **The actor rules are in Rust three times**: the parameter at its level and
  the summed equipment live in `rm2k-snes-battle` (`rules.rs`), in
  `rm2k-snes-screens` (`texts.rs`) and, in Python, in `port/rules.py`, which
  the emission and the compiler still use. Their place is `rm2k-rules`; they
  weren't moved so as not to touch two other stages.
* **`lcf` stores fields only `battle.py` read**: `Enemy.actions` and
  `EnemyAction`, `Actor.rename_skill` and `skill_name`, `Skill.id`. They were
  left unused; they can be deleted.
* **A test battle is replayed in full on every turn**: it costs one process
  per turn —ten milliseconds, ninety with a troop, which is almost the whole
  database—, and no test plays more than thirty.
