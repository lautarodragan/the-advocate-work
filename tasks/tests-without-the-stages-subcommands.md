---
name: "Tests without the stages' subcommands"
description: "Besides simulate, the ports' tests ask the stages themselves —screens' window, render, equip, layout and refit, images' backdrops, animations and battlers, Wally, mapdata's vram, engine, pages and compress, battle's experience, field-skill, lines and model, the scans— for what they expect or need; the tests should not depend on the converter's internals, and those subcommands should not be needed"
type: refactor
status: doing
assignee: taro
agents: [cardon]
author: taro
links:
  blocks: [abl-s-test-cartridges-become-test-game-cases]
  relates: [battle-tests-without-simulate, one-advocate-command, the-stages-speak-json-nobody-types, the-volume-ceilings-are-measured-without-a-rom, the-slot-screens-reference-draws-a-lent-face-with-its-own-palette, the-stage-subcommands-only-the-converter-called-have-no-caller, advocate-init-dump-and-config]
---

**Why**: the same as
[`battle-tests-without-simulate`](battle-tests-without-simulate.md), for
the rest of the stages. A test that takes what it expects from a stage
checks our code against our code; a harness that needs a stage's internals
to look at the ROM ties every test to how the converter is built today.

> And regarding rm2k-snes-screens window and family: I aim at the same.
> I would like them not to be needed.

(taro, 2026-11-24)

**What the tests ask today**, from `abl/tests/harness/` in the ports
unless it says otherwise:

* `rm2k-snes-screens` (`screen_stage.py`): `render` —a screen as the
  console has to show it—, `equip`, `layout` —the screens' geometry—,
  `window` —the colour-memory entries the message window takes—, `refit`
  —the message boxes reflowed for a window—;
* `rm2k-snes-images` (`image_stage.py`): `backdrops`, `animations`,
  `battlers`;
* `wally` (`map_stage.py`);
* `rm2k-snes-mapdata`: `vram` (`screen_stage.py`), `engine` —the engine's
  numbers, `rm2k-snes/harness/rm2k_snes_harness/engine.py` in
  the-advocate—, `pages` (`tests/tooling/test_pages.py`), `compress`
  (`tests/tooling/test_lz2.py`);
* `rm2k-snes-battle` (`model.py`), besides `simulate`: `experience`,
  `field-skill`, `lines`, `model`, `layout`;
* the scans: `rm2k-snes-events scan` (the harness's `game.py`, the ports'
  `tests/games.py`) and `rm2k-snes-convert scan`
  (`tests/test_frozen_world_cursor.py`);
* **The converter's own queries**, which the design of
  [`the-stages-speak-json-nobody-types`](the-stages-speak-json-nobody-types.md)
  found missing from this list: `rm2k-snes-convert leaders`,
  `map-context`, `boxes` and `compile` besides `scan`, used by 26 files of
  ABL's tests —through `abl/tests/harness/converter.py`—; once the
  converter is a library they have nowhere to live;
* **`rm2k-snes-audio`'s subcommands**: the eight the harness's
  `music.py` and `test_music_ceilings.py` call (the latter goes with
  [`the-volume-ceilings-are-measured-without-a-rom`](the-volume-ceilings-are-measured-without-a-rom.md)).

**What is asked**:

1. **The classification first**, written here and shown to taro: each
   use is one of
   * **an oracle** —what the test expects—: replaced by what RM2k's rules
     say, by a golden, or by something the ROM shows on its own (a menu
     that lists what the database has, a box that does not overflow);
   * **what the harness needs to look at the ROM** —where a variable
     lives, how many maps there are—: taken from what is already the
     interface —the `.dbg` `ld65` writes, the dump, `rm2k-snes-project`
     (later `advocate project`)— and not from a stage;
   * **a test of the stage itself** that lives in the ports by history
     (`test_lz2.py`, `test_pages.py`): moved to the crate's own tests.
2. **Then the change**, one stage at a time, with what each one stops
   catching said in so many words.
3. **The subcommands nobody calls any more go**, and the stages are left
   with what the conversion asks of them —which is what
   [`the-stages-speak-json-nobody-types`](the-stages-speak-json-nobody-types.md)
   turns into libraries: the fewer entry points they have, the simpler that
   is—.

`rm2k-snes-cartridges assemble --sources`/`--memory-map` and `space`,
which the harness calls too, are the builder's and stay: they are what
[`one-advocate-command`](one-advocate-command.md) keeps.

## Log

### 2026-11-24, Hornero: written

Nothing done yet. The list above comes from a grep of the harnesses on
2026-11-24 (ports `4c23c9e`, the-advocate `90d1041d`); the classification
redoes it.

### 2026-11-24, Hornero: two gaps added

Found by Calandria's design; taro agreed to add them.

### 2026-11-25, Hornero: the classification to Cardón

> Let's go with tests-without-the-stages-subcommands.

(taro, 2026-11-25) After
[`one-advocate-command`](one-advocate-command.md): `rm2k-snes-project`
and `rm2k-snes-cartridges` are gone —what the harness asked them is in
`build/advocate.json`, and the harness is an installed package—, so the
"interface" of point 1 is the ROM, the `.dbg`, the dump and that file.
taro's answer 4 there adds `goombario` and `ditto` in the tests to this
classification. Cardón does point 1, the classification, written here
for taro before anything changes.

### 2026-11-25, Cardón: the classification

On the-advocate `e267b6b3`, ports `7403613`. Nothing changed in the code
repos.

#### How it was measured

* **Grep** of the ports —ABL's `tests/` and `tests/harness/`, the root's
  `tests/`, `experiments/`— and of the-advocate's `test-game/tests/` and
  `rm2k-snes/harness/`, for every `subprocess`, `shutil.which` and
  `stage.run`.
* **A trace**: every binary of ours on the PATH wrapped by a throwaway
  script that logs `PYTEST_CURRENT_TEST`, the arguments and the time;
  then ABL's `just tests` (1694 passed, 2 skipped, 4 min 33 s, 8 workers)
  and the root's `just boot` (218 passed, 2 min 46 s) run with it, in a
  ports worktree at `7403613`. The test game's suite was not run: its
  calls are few and were read. The trace names the test that made each
  call, but the harness caches most answers per process, so the test
  files that depend on a row are counted by grep, and the trace's count is
  a lower bound.

**What the calls cost today**: the summed time inside our binaries during
ABL's suite is **433 s** of its 2184 worker-seconds (8 x 273 s), about a
fifth. Of that, `volume-ceilings` is 91 s and `simulate` 19 s —other
tasks'—, and this task's rows are the other **~323 s**. One row is most of
it: `test_baked.py`'s three tests ask `wally bakeable` and
`rm2k-snes-convert map-context` once per map, and again in each test
—939 and 945 calls, **222 s**, 60 to 90 s per test—, so those three are
the long poles of a 4.5-minute suite. The rest is cheap: `boxes` 33 s (67
calls, not cached), `scan` 24 s, `render` 14 s, `leaders` 11 s, the others
under 5 s each. The boot suite spends 9 s in them (Ditto, 6 s).

**What the build already leaves that answers part of it**: the `.dbg`
carries every equate the assembly defines, referenced or not (checked
with a toy `ca65 -g` + `ld65 --dbgfile`: an unreferenced `FOO = 5` is
there), so a number the converter writes into an `.inc` as an equate is
in the `.dbg` at no ROM cost; `culprits.json` lists the pages left out;
`events-request.json` is beside each ROM; `advocate.json` has each
cartridge's directory.

#### The calls, by stage

"Files" is test files that depend on the row (grep, through the harness's
helpers); calls and seconds are the trace's.

**`rm2k-snes-events scan` and `rm2k-snes-convert scan`** —25 calls, 26 s—

| Use | Tests | Class | Replacement, and what it stops catching |
|---|---|---|---|
| Where an RM2k variable or an actor's skill lives in `FAR_VARIABLES`/`FAR_SKILL`: ABL's `data.variable_slots` and `skill_slots`, the generic harness's and `games.py`'s `Cartridge.variable_slots`, `variable_slot` in `test_frozen_world_cursor.py` | ABL ~28 files (23 direct, plus through `stones`, `stretch_plant`, `battle.knows`); the test game 5 files, 41 uses; the root 6 files (Desert Nightmare 4, Zounds, Frozen World) | harness looking at the ROM | **the build leaves the slots**: the converter has the answer, so a `slots.json` beside each ROM or a key per cartridge in `advocate.json`. A few KB per cartridge. Nothing lost. `game.py` already reads `events-request.json` to redo the answer; it would read the answer instead |
| `data.page_of(...) is not None`: "this page compiles", a precondition | 4 files (`test_equipment_and_skills`, `test_inn`, `test_game_over`, `test_pages`) | harness looking at the build | `culprits.json`'s `pages`, the ones left out. Nothing lost |
| `test_protocol_against_the_game.py`: every page of the 328 maps through the bytecode walk | 1 file, 1 test | test of the compiler, by history | **goes**: its docstring says the converter already does the walk on every build and stops if a page does not land, and `release` carries every map. It stops catching nothing the build does not |
| `test_pages.py`: the compiler's decisions on five ABL pages (an item condition, a variable condition, the slots are the whole game's, a route's block) | 1 file, 5 tests | test of `rm2k-snes-events` with ABL as fixture | to the events crate's tests, with invented pages of the same shape; where it changes what the ROM does, a test-game case. Stops catching: a regression only ABL's exact pages trigger |
| `converter.loose_page` | nothing calls it | dead helper | goes |

**`rm2k-snes-mapdata engine`, `rm2k-snes-screens layout`,
`rm2k-snes-battle layout`** —8 calls each, at import, so every ABL test
depends on them; under 0.1 s—

| Use | Tests | Class | Replacement |
|---|---|---|---|
| The engine's numbers (`JUMP_STEP`, `KEY_VALUE_*`, `ITEM_MAX`, `ENC_SEED`, the troop triggers…) and the screens' and battle's geometry (`SLOT_Y`, `BA_MSG_ROW1`, `ITEM_NAME_WIDTH`, `COMMAND_*`, `VICTORY`…) | engine: 19 test files, plus the test game's `test_key`, `test_speed`, `test_variables`; screens: 4; battle: 13, most through the battle model | harness looking at the ROM, mostly | **the `.dbg`**. Of the 106 engine numbers 63 are already there; tests use 23, and 9 of those are not (`TRIGGER_TOUCH_HERO`, `TRIGGER_AUTOSTART`, `FRAMES_PER_SECOND`, `MESSAGES_STEP`, `ENEMIES_MAX`, `EQUIPMENT_SLOTS`, `KEY_VALUE_DIR` —a list—, and two generic names that may be false hits). Of the screens' 260 names tests use 18, 5 missing; of the battle's 64 they use 10, 9 missing. The converter writes those as equates in the `.inc`: zero ROM bytes, a list as `NAME_0…`. Where a test asserts a value as an oracle —`test_key.py`'s `KEY_VALUE_DECISION == 5`— it keeps the literal, and nothing is lost |

**`rm2k-snes-screens`**

| Use | Tests | Class | Replacement, and what it stops catching |
|---|---|---|---|
| `render` (367 calls, 14 s), with `mapdata vram` for its default `slots`: the menu, items, target, skills, equipment, shop, slots, End Game and title as the console has to show them, compared pixel by pixel | 18 files, 76 tests in the trace (`test_menu_*_drawing`, `test_shop_*`, `test_end_game`, `test_healing_skills`, `test_experience_drawing`…) | **oracle**, our code against our code | **goldens**, one per compared screen, frozen after being looked at. Up to 367 PNGs; the suite's goldens average 10 KB, so ~4 MB, fewer once deduplicated; and one review. Stops catching: a birth defect in a new screen —which today `render.rs` and the runtime would both have to carry to pass—. Question 2 |
| `equip`: what equipping leaves (`Game_Actor::ChangeEquipment`) | 1 file (`test_menu_equipment_drawing`), 2 tests | oracle | RM2k's rule, written in the test from easyrpg-player: deterministic, a few lines. Nothing lost |
| `window`: the colours the message window takes, `== 12` | 1 file, 1 test | test of the stage with ABL's System | the build leaves the number (an equate, or the screens' entry in `advocate.json`) and the test keeps its 12; or to the screens crate with a fixture System. Nothing lost |
| `refit`, with `convert boxes` (67 calls, 33 s) and `battle.message_window`: the boxes refitted for the window | `test_game_texts` (2 tests), `test_troop_events`, `test_troop_systems`, `test_battle`, `test_battle_skill_results` | oracle | **what the ROM shows on its own**: the words on screen are the LDB's, in order, and each row fits the window —its width and the font's advances read from the ROM by symbol—. "The whole game fits without losing words" becomes a check the converter makes at every build (a box that loses words is a degradation or an error), read from `degradations.json`. Stops catching: a refit that keeps the words but breaks the lines elsewhere than intended |

**`rm2k-snes-images`**

| Use | Tests | Class | Replacement, and what it stops catching |
|---|---|---|---|
| `backdrops`, `battlers` (278 calls): the battle scene as converted, against the screen | `test_battle_scene_drawing` (7 tests), `test_msu_data` | oracle | goldens of the scene (battle goldens exist; these add the cases); and the `.msu`'s backdrops **against the ROM itself**: the same battle with and without the `.msu` has to look the same pixel for pixel, which is what the backdrops in MSU-1 promise. Stops catching: a birth defect in a new backdrop's conversion |
| `animations` (41 calls): every frame of every animation, to check what reaches VRAM | `test_animation_frames` (1 test) | test of `frame_without_gaps` in mapdata, through the ROM | the round trip of `frame_without_gaps` to the mapdata crate, over generated frames; the ROM side stays with the `animation-drawing` goldens, plus a few frames frozen. Stops catching: a frame that only ABL's real cells break |

**`wally`, `rm2k-snes-convert map-context` and `leaders`** —the 222 s—

| Use | Tests | Class | Replacement, and what it stops catching |
|---|---|---|---|
| `bakeable` on every map: what is baked covers the cell and keeps its passability | `test_baked` (3 tests) | test of the stage's invariants | **Wally checks them itself at every build** and stops if one breaks, as the compiler stops on a bad walk; the test goes. Stops catching nothing, and the suite loses its three longest tests |
| `split` with `leaders`: no tile shares a leader's palette | `test_flash_palette` (3 maps) | invariant of the stage | the same: a check in Wally's split at every build |
| `split` with 6 palettes on map 2: the timer costs no event | `test_timer_palette` (2 tests) | test of the stage, counterfactual (6 palettes, not the build's 8) | to Wally's crate tests, with an invented map that falls short; its docstring says the mechanism's tests already are there (`extras.rs`) |
| `leaders`: Kersh can lead in the opening | `test_leaders` (2 tests) | test of the converter with ABL's data | to the converter's tests, with an invented game of the same shape (a map that puts the leader after another); the ROM side is the opening's golden, which draws Kersh |
| `map-context` for where the built ChipSets are | `test_fork_maps` (1 test) | harness looking at the build | the cartridge's directory, in `advocate.json` |

**`rm2k-snes-battle`, besides `simulate`**

| Use | Tests | Class | Replacement |
|---|---|---|---|
| `model`: `items_usable_in_battle`, `troop_gold` | 5 files | oracle | RM2k's rules —the item's kind and flags; the sum of the members' gold—, written in the test |
| `lines`: the victory lines | `test_victory`, `test_troop_events` | oracle | the LDB's terms filled as RM2k fills them, and the same "words in order, each row fits" as the boxes |
| `experience`: `ChangeExp`, `ChangeLevel` | `test_event_experience` (3 tests) | oracle | `harness/experience.py`, which already is RM2k's curve in Python from easyrpg-player and which the other experience tests use |
| `field-skill`: a healing skill from the menu, with the battle's randomness | `test_healing_skills`, `test_menu_special_items` (7 tests) | oracle, the same nature as `simulate` | **with [`battle-tests-without-simulate`](battle-tests-without-simulate.md)**: exact where the variance is 0, a range otherwise |

**`rm2k-snes-mapdata pages` and `compress`**

| Use | Tests | Class | Replacement |
|---|---|---|---|
| `compress`: every block of every cartridge through the stage's streams and `tests/harness/lz2.py` | `test_lz2` (11 cartridges, and one more test) | test of the stage, by history | to the mapdata crate (the streams' round trip, with `lz2`'s decoder), over generated blocks of every kind; the ROM side is `test_decompressed_load.py`, which stays. Stops catching: a block shape only ABL's maps have |
| `pages` | `test_pages` (1 call) | test of the stage | with `test_pages`, to the crates |

**`rm2k-snes-audio`** (`volume-ceilings` is
[`the-volume-ceilings-are-measured-without-a-rom`](the-volume-ceilings-are-measured-without-a-rom.md)'s)

| Use | Tests | Class | Replacement |
|---|---|---|---|
| `constants` | `test_msu_data`, `test_music_allocation`, `test_music_package`, `test_msu_effects` | mixed | the DSP registers (`kon`, `v_srcn`), the BRR block's 9 bytes and the 60 ticks are properties of the hardware: literals. The `.msu`'s layout (`msu_backdrops_start`, `msu_backdrop_span`, `msu_colors_at`, the signature's size) as equates in the `.dbg`. `headroom`, `master`, `directory_max` go with the compile tests below |
| `compile`, `keys`: the bank and the packages for requests the tests make up (a smaller ARAM, a fixed headroom) | `test_music_allocation`, `test_music_package` | test of the stage, counterfactual | to the audio crate's tests, with invented MIDIs and `SOUNDFONT` as its tests already take it. Stops catching: an allocation only ABL's songs reach |
| `decode`: what the stream writes to the DSP, the model of `music_frame`, to hold what the 65816 wrote to it | `test_music_writes`, `test_drum_kit_sounds` | oracle: the compiler's spec | **the build leaves each song's writes** beside the ROM —the compiler already decodes every song with that model and stops if they are not its spec—, and the test compares the ROM's log with that file. Size not measured. Question 3 |
| `msu-index`, `msu-sign`: reading the `.msu`, and signing an altered one | `test_msu_data`, `test_msu_effects` | harness looking at the product; `msu-sign` makes a test input | the build leaves the `.msu`'s index (JSON beside it); the signature is computed in the test from the book's format (`internals/the-msu-file.md`) |
| `wav`, `find-song`, `pitch` | `test_msu_effects`, `test_msu` | oracle, harness | Python's `wave` with the compiler's rule (mono, 16 bits); `resources.find_resource`, which the harness already has; the pitch register's formula, a property of the DSP |

**The other binaries**

| Use | Tests | Class | Replacement |
|---|---|---|---|
| `goombario` over every cartridge | ABL's `test_linter` (11 cartridges, 7 s), the test game's | a lint of the product | question 1 |
| `ditto unpack` + `pack` | the root's `test_round_trip` (9 games, 6 s), the test game's | a test of Ditto | question 1 |
| `just cartridges` → `advocate build`, from `games.py`'s `prebuild` | the root's boot suite | the builder, run by the tests | the boot recipe builds first, as ABL's does after `one-advocate-command`'s answer 3; `prebuild` goes |
| `ca65` + `ld65` in `test_space.py` | 9 tests | not ours: a test of the builder's space measurement against `ld65` | to the cartridge crate's tests, with a toy program |

#### The steps, one stage at a time

Sizes: S is a day's agent or less, M a day or two, L more.

1. **The slots and the numbers the build leaves** (M). the-advocate: the
   converter leaves the slots per cartridge and writes the missing equates
   (engine 9, screens 5, battle 9, the `.msu`'s layout). Ports:
   `data.variable_slots`, `skill_slots`, `page_of`, `engine`, `layout()`,
   `arrangement()` read them; `test_protocol_against_the_game` goes.
   **Retires** `rm2k-snes-events scan`, `rm2k-snes-convert scan`,
   `mapdata engine`, `screens layout`, `battle layout`. First, because the
   rest reads these numbers.
2. **Wally's invariants into Wally** (M). The bake and split checks run at
   every build; `test_timer_palette` and `test_leaders` to the crates;
   `test_fork_maps` reads the directory from `advocate.json`. **Retires**
   the `wally` binary whole, `convert map-context` and `leaders`, and
   ~222 s of the suite's worker time. Parallel with 3 to 6.
3. **The screens** (L, mostly review). Goldens for `render`; `equip` as
   RM2k's rule; `window` from the build; `refit` and `boxes` as "the words
   and the width". **Retires** the `rm2k-snes-screens` binary whole,
   `convert boxes`, `mapdata vram`. After 1; parallel with 2, 4, 5.
4. **The images** (M). Battle-scene goldens, the `.msu` with and without,
   `frame_without_gaps` to the crate. **Retires** the `rm2k-snes-images`
   binary whole. Parallel.
5. **The audio** (M). First measure the writes' size; the build leaves
   them and the `.msu`'s index; the `compile` and `keys` tests to the
   crate; the rest in Python. **Retires** every `rm2k-snes-audio`
   subcommand but `msu` and `volume-ceilings` —the latter until its
   task—. Parallel.
6. **The mapdata's own tests** (S). `test_lz2` and `test_pages` to the
   crates. **Retires** `mapdata pages` and `compress`, and with 1 and 3
   the `rm2k-snes-mapdata` binary whole. After 1.
7. **The battle's other questions** (S), together with
   [`battle-tests-without-simulate`](battle-tests-without-simulate.md):
   `model`, `lines`, `experience` as above, `field-skill` with `simulate`.
   **Retires**, with that task, the `rm2k-snes-battle` binary whole.
8. **The remainder** (S): `convert compile` —`page_triggers`, a troop's
   page triggers, in `test_troop_events`— read from the ROM's troop table
   by symbol, or from the LDB with RM2k's rule; `prebuild` out of
   `games.py`; whatever question 1 decides.

Each step says in its commit what it stops catching; the tables above are
the first draft of that.

#### What ends with no caller

After 1 to 8: **every stage binary** —`wally`, `rm2k-snes-screens`,
`rm2k-snes-images`, `rm2k-snes-battle`, `rm2k-snes-mapdata`,
`rm2k-snes-events` but its `culprits`— and **every query of
`rm2k-snes-convert`** (`scan`, `compile`, `leaders`, `map-context`,
`boxes`), so the converter's binary has nothing left either. **What
survives, and why**: `rm2k-snes-events culprits` and `rm2k-snes-audio
msu` and `volume-ceilings` are a person's or a recipe's, not a test's
—whether they become `advocate` subcommands or recipes is
`one-advocate-command`'s business—; `goombario`, `ditto`, `rm2k-sketch`
and `fxpak` are tools of their own, and only question 1 says whether a
test still runs the first two.

#### Seen along the way

* `test_baked.py` computes `baked()` —one `wally bakeable` and one
  `map-context` per map— in each of its three tests, not once: the 222 s
  above. Step 2 takes it away whole, so it is not a draft.
* `/usr/local/bin/brr`, of 2026-09-20, is Gunter's binary from before its
  rename (`a1238756`): nothing builds or calls it. A leftover of this
  machine, not of a repo.
* `abl/experiments/fonts/mockups.py` calls `rm2k-render`, which is no
  longer a command; its README already says so and how to run it again.

### 2026-11-25, Cardón: questions for taro

1. **`goombario` and `ditto` in the tests.** Both look at something real
   —goombario lints the runtime inside the built ROM; the round trip
   proves Ditto reads what RPG Maker wrote, over nine originals, and what
   it writes itself, over the test game—, but they run a binary of ours.
   Options:
   * **(a) they become checks of what already runs them**: `advocate
     build` calls Goombario as a library over each cartridge it builds and
     writes the result in `advocate.json` —as the patches' check moved in
     on 2026-11-25—, and the dump —`just dump`, later `advocate dump`—
     checks its own round trip each time it unpacks a game, as the test
     game's `just game` does after packing. The tests read the result, or
     go. Cost: ~7 s of CPU per full ABL build, and a build that reports a
     lint.
   * (b) they stay, as the rule's stated exception: a tool that tests the
     product or another tool.
   * (c) they leave the suites for the crates' tests with a corpus:
     `DITTO_CORPUS` would take several games and `.zip`s, and Goombario
     would run over the test game in CI. Until 2026-11-23 the round trip
     was a recipe nobody ran unless they touched Ditto, which is why it
     went into the tests.

   **Recommended: (a).** Both nets stay on every build, and no test calls
   a binary.

2. **The screens' drawings become goldens.** `render` is the biggest
   oracle: 18 files compare the console against a screen our own stage
   draws. Options: **(a) one golden per compared screen**, deduplicated
   (up to ~370, ~4 MB, one review), losing the "drawn twice" check for a
   new screen; (b) goldens for one state per screen, and the rest asserted
   on what the ROM shows on its own —the list holds what the database
   says, the numbers are the RAM's—: fewer goldens, fewer pixels checked;
   (c) a drawing of the screens in Python in the harness, a second model
   of ours, which is what the rule wants gone. **Recommended: (a)**: it is
   the same bargain as every other golden of the suite.

3. **The music's writes.** `test_music_writes` and `test_drum_kit_sounds`
   hold the 65816 decoder to the compiler's spec of each song. Options:
   **(a) the build leaves each song's writes beside the ROM** —size not
   measured; the compiler already computes them—; (b) a decoder in Python
   in the harness, a second model of ours; (c) the tests go, trusting the
   compiler's own check at build time, which does not see the 65816.
   **Recommended: (a)**, if the size is reasonable; measuring it is the
   first thing step 5 does.
