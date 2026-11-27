---
name: "Tests without the stages' subcommands"
description: "Besides simulate, the ports' tests ask the stages themselves —screens' window, render, equip, layout and refit, images' backdrops, animations and battlers, Wally, mapdata's vram, engine, pages and compress, battle's experience, field-skill, lines and model, the scans— for what they expect or need; the tests should not depend on the converter's internals, and those subcommands should not be needed"
type: refactor
game: advocate
status: doing
assignee: cardon
agents: [cardon, chaja, Aguará, Mulita]
author: taro
links:
  blocks: [abl-s-test-cartridges-become-test-game-cases]
  relates: [battle-tests-without-simulate, one-advocate-command, the-stages-speak-json-nobody-types, the-volume-ceilings-are-measured-without-a-rom, the-slot-screens-reference-draws-a-lent-face-with-its-own-palette, the-stage-subcommands-only-the-converter-called-have-no-caller, advocate-init-dump-and-config]
  found: [the-test-game-lacks-content-abl-s-runtime-branches-need, abl-s-just-tests-splits-a-quoted-k-expression]
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

### 2026-11-25, Hornero: taro's answers

> [`render` to goldens, one per compared screen, ~370 PNGs, ~4 MB] I
> agree.

> [the build leaves each song's DSP writes beside the ROM, if the size is
> reasonable] Go ahead.

On `goombario`:

> I have doubts about goombario. In part, I think it is not a test per
> se. It is a lint, and it should go in its own stage, and it makes no
> sense for it to be part of `advocate`. It is more for development, like
> `eslint`. It could be part of `just lint`, running `cargo fmt`, `clippy`
> and `goombario`. Buuut we have ASM code generated by Rust, and that one
> we cannot lint before running the build. Does Goombario still bring
> value?

It does: several runtime commits of the last month came from it, and it
checks more than the pull-branch trap —`jsl`/`rts` mismatches, stack
left behind, a width other than the declared one—. What the converter
generates is data, not code, and `--only` already keeps Goombario to the
program's own code; what it needs is a linked ROM, for the `.dbg`.

> Go ahead! And let's have the feature flags enabled in the test ROM,
> instead of `just lint` taking a ROM as an argument.

(taro, 2026-11-25) So, instead of answer 1's (a):

* **`goombario` is a lint, not a test and not part of `advocate`**: the
  the-advocate's `just lint` runs `cargo fmt`, `clippy` and `goombario`
  over the test game's ROM, built with `advocate build` (with the cache,
  after a runtime change that is little more than assembling). ABL's
  `tests/tooling/test_linter.py` and the test game's go.
* **The test game enables every feature flag** the runtime assembles
  conditionally (`.if` branches: the vblank probe, the 4bpp title, MSU-1,
  …), so the one ROM `just lint` checks covers every branch the ABL
  cartridges assemble today. Which flags those are is listed in the step
  that does it, against the ten cartridges of ABL's `advocate.toml`.
* `ditto`'s round trip: as Cardón recommended, the dump checks its own.

### 2026-11-25, Hornero: steps 1, 2 and the lint launched

> Let's go now :D

(taro, 2026-11-25) Step 1 to Cardón; step 2 (Wally's invariants, parallel) to Aguará; Goombario as a lint over the test game with every feature flag on to Chajá, in parallel.

### 2026-11-25, Chajá: Goombario a lint over the test game

On the-advocate `e267b6b3` and the ports `7403613`. Branches `chaja-lint`
in both.

#### What changed

* **the-advocate**: `just lint` is `lint-rust` —`cargo fmt` and
  `clippy`, as before— and `lint-runtime`, which builds the test game with
  the installed tools and runs Goombario over **every** cartridge of it
  (`lint` in `test-game/justfile`), checking also that it looked at
  something, as the test did. `test-game/tests/test_linter.py` goes. CI:
  the `lint` job runs `lint-rust`, and the test game's job, which has
  cc65 and the tools, `lint-runtime`. `lint-runtime` refuses when the
  tools on the PATH were installed from another checkout, since the build
  assembles that one's runtime and would lint it instead.
* **The test game's `lint` cartridge**: the whole game with
  `--title-4bpp --debug-screen --phasing --enemy-hp --msu-everything
  --vblank-probe`, every converter flag that makes the runtime assemble
  code. A cartridge apart and not `release`, as the assignment preferred:
  `--msu-everything` makes a ROM that does not start without its `.msu`,
  the probe costs every vblank a few lines, and the debug screen's option
  moves the pause menu's goldens. No test runs it, so **no golden
  moved**, and `release` and `test-vblank` are byte for byte the same. It
  needed a title picture (`Title/Title.png`, ours, drawn by a script, in
  `AUTHORS.md`; only `lint` shows it) and a name for switch 1 and variable
  1, without which the debug screen does not assemble (`DBG_PAGES > 0`).
  With `release` and `test-vblank` linted too, both sides of every flag
  are seen.
* **The ports**: ABL's `tests/tooling/test_linter.py` goes, in a commit of
  its own that can wait (below).

#### The runtime's conditionals, against the cartridges

Every `.if`/`.ifdef` of `runtime/` on a symbol, read as each cartridge's
`.sfc.dbg` defines it —ABL's eleven built at `e267b6b3`, the test game's
three—. **On a build flag** (the converter's options): `DEBUG_SCREEN`,
`DEBUG_PHASING`, `VBLANK_PROBE`, `TITLE_BPP`, `SCREEN_TITLE`/`SCREEN_ROW`
(`--no-title`), `MSU_REQUIRED` (`--msu-everything`), `HERO_SPEED_KEYS`
(`--no-speed-keys`, whose off side assembles nothing) and `BA_HP_ENEMIES`
(`--enemy-hp`); `--no-timer`, `--test-encounters`, `--test-events-max`,
`--test-graphic`, `--hero-above` and `--text-padding` assemble no
different code, only data. **All covered** by the test game's three
cartridges together, both sides; `--enemy-hp` beyond what ABL has.

**On the game's content**, which no flag gives: ABL's cartridges assemble
some 2,000 lines the test game's do not —`layer_text_on` (the box over the
layer above, 1127 lines), `posed_stills` (472), `WINDOW_SYSTEMS > 1`,
`GAME_OVER_TILES > 0`, `COMPAR_N > 0`, `PICTURE_SETS > 0`, the custom
menu, `TEXT_INK_ENTRY = 0`, `WINDOW_BACKDROP_LINES = 1`, `SLOT_MENU_TILES
<> SLOT_TILES`—. That is game content to write, not a flag to turn on, so
it is the draft
[`the-test-game-lacks-content-abl-s-runtime-branches-need`](the-test-game-lacks-content-abl-s-runtime-branches-need.md),
with the table. Three of them are one side of a pair that cannot be in
one ROM (`TEXT_INK_ENTRY`, `WINDOW_BACKDROP_LINES`, `WINDOW_SYSTEMS`): the
test game would need a cartridge with other maps for each. And four that
nobody linted before either, ABL nor the test game, because only other
ports assemble them: `paint_table`, `sand_table`, `SHOW_WINDOW_SLOTS`,
`WIDE_VARIABLES > 0`.

**So removing ABL's `test_linter.py` today loses the lint of those ~2,000
lines** until the draft is done. Its commit is separate
(`417e102` in the ports) so that it can wait.

#### Verified

* `just lint` green; and **red** with a `pha`/`pla`/`bne` planted in
  `msu_required` (`msu1.s`), which only `lint` assembles: Goombario
  flagged it on `lint` alone, `release` and `test-vblank` green. Thrown
  away.
* Time: `lint-runtime` **4.3 s cold** (the test game's `build/` deleted:
  three cartridges converted and assembled) and **1.0 s warm**; Goombario
  itself is half a second a cartridge. The whole `just lint` 23 s with
  clippy's first run in the worktree, **2.8 s warm**.
* `just test` (29), `just rust-test --no-fail-fast` (green; with
  `SOUNDFONT` set to FluidR3 `the_synth_bass_releases_as_the_soundfont_says`
  is red, as it is on `main`: it expects the original game's SoundFont),
  `SOUNDFONT=…FluidR3_GM.sf2 just test-game` (230 passed, 6 skipped).
* Ports, with the branch's tools: `just boot` (218 passed), and the eight
  other games' `release` byte for byte equal to the global build of
  `e267b6b3`; ABL's `just tests` 1683 passed, 2 skipped —the 1694 of
  Cardón's trace less the eleven of `test_linter.py`—, and its eleven
  cartridges byte for byte the same (`abl.sfc` `3bf35fd7665c2045`). In a
  fresh ports worktree `just tests` stops at `_xdist` until `just
  cartridges` has run: its check runs pytest, and `conftest.py` refuses
  without `build/advocate.json` —the known false alarm—.

#### What is left

* **When merging**: nothing to install, no Rust changed. In
  `~/the-advocate` `just lint` works with the global tools, which are that
  checkout's; in a worktree it asks for `just install-local .local-tools
  advocate`.
* The draft above, and whether ABL's commit waits for it: Hornero's or
  taro's.
* The task stays `doing` with Cardón: this is one part of it.

### 2026-11-25, Cardón: step 1, the slots and the numbers the build leaves

Started on the-advocate `e267b6b3`, ports `7403613`, branches
`cardon-tests-step1` in both.

#### What the build leaves

* **`slots.json`, a file beside each ROM**, not keys in `advocate.json`:
  the slots are the converter's answer for one cartridge, written where it
  writes the rest of what it answers for it —`culprits.json`,
  `degradations.json`, `events-request.json`—, while `advocate.json` is
  the builder's account of the project, written by another program after
  the converter has run. Putting them there would make the builder read
  and copy a converter's file for no reader that does not already know the
  cartridge's directory. It is `{"variables": [[variable, slot]],
  "skills": [[actor, skill, bit]]}`, from the compiler's second call, the
  one the ROM is built with.
* **Which pages compile** needs no new file: `culprits.json`, beside each
  ROM since this morning, lists every page of every map of the game that
  does not, judged the way the first call compiles it.
* **The equates**, measured against the tests rather than taken from the
  classification's count: after this step the tests read 13 numbers the
  `.inc` did not write —`MESSAGES_STEP`; `ITEM_HELP_HEIGHT`,
  `ITEM_LIST_Y`, `ITEM_NAME_WIDTH`; `BA_MSG_ROW1`, `BA_PAGE_MSG_ROW0`,
  `BA_PAGE_MSG_COL`, `COMMAND_ATTACK`, `COMMAND_DEFEND`, `COMMAND_ITEM`,
  `COMMAND_SKILL`, `VICTORY`, `DEFEAT`— plus the `.msu`'s layout
  (`MSU_SIGNATURE_SIZE`, `MSU_BACKDROPS_START`, `MSU_BACKDROP_SPAN`,
  `MSU_COLORS_AT`). The classification's "engine 9, screens 5" counted
  names that are read only by what this step removes
  (`TRIGGER_TOUCH_HERO`, `TRIGGER_AUTOSTART`, through
  `test_protocol_against_the_game`), names the ROM already has under
  another (`KEY_VALUE_DIR` is `KEY_VALUE_UP`…`LEFT`, `ENEMIES_MAX` is
  `BA_ENEMIES_MAX`), a docstring (`SLOT_Y`) and local constants of a test
  (`FRAMES_PER_SECOND`, `EQUIPMENT_SLOTS`, `CELL`).
* **Not all of `engine.rs` and the two layouts as equates**: six names
  collide with what the `.inc` or the runtime already define in other
  units —`GRID` is a far RAM label, `EQ_PARAM_ARROW`, `MENU_EXP_Y`,
  `WINDOW_LINE`, `BA_SKILL_COLUMN_DX`, `RAIN_DROPS` mean something else
  there—, so the emission writes the list the tests read, in
  `for_readers`, and a name missing from the `.sym` is an error that says
  where to add it.

#### What the tests read now

* ABL: `data.variable_slots` and `skill_slots` read the cartridge's
  `slots.json`; `data.page_of`, which returned a page's code and was only
  asked "is it not None", is `data.page_compiles`, from `culprits.json`.
  A new `equates` module points the generic harness's `engine` at
  `release`'s `.sym`, and `screen_stage.layout()`, `model.arrangement()`
  and `events.X` are that table. The `.msu`'s offsets and signature size
  come from it too (`music.msu_backdrop`, `test_msu_data`,
  `test_msu_effects`); the rest of `rm2k-snes-audio constants` is step 5's.
* The root: `Cartridge.variable_slots` and The Frozen World cursor's
  `put_variable` read `slots.json`.
* The test game and the generic harness: `engine` reads the current
  game's `.sym`; `Cartridge.variable_slots`, `slots.json`.
* `test_protocol_against_the_game`'s walk went —its dispatch test stays—;
  `test_pages.py`'s two page-record tests went to the events crate, over
  its small game; its slot test looks at `release`'s slots.

`release`'s slots are not the game's alone: two of its cases name
variables 18 and 69, which the game does not, so the game's from 19 on
sit two slots further than in a cartridge without those cases. By
design —the slots go by number over everything the cartridge carries,
and a save from another build is not kept—, so not a draft; the test's
docstring says it.

#### The subcommands

Nothing called the five after this, so they went in their own commit:
`rm2k-snes-events scan`, `rm2k-snes-convert scan`, `rm2k-snes-mapdata
engine` (with `engine::numbers()`), `rm2k-snes-screens layout`,
`rm2k-snes-battle layout`. The functions the converter calls stay. The
events binary is left with `culprits` alone.

#### Measured

* **ROMs**: the twenty `.sfc` of the nine games (eleven of ABL, two of
  Zounds, one of each other), built in the ports worktree with the
  recipes, are byte for byte the same with `e267b6b3`'s global tools and
  with this branch's first in PATH. The `.sym` and `.dbg` gain exactly the
  seventeen new equates; none moves or goes.
* **Worker time**: from the classification's trace, the suite stops
  spending 24.3 s in `rm2k-snes-convert scan` (22 calls), 2.1 s in
  `rm2k-snes-events scan` (3) and under 0.1 s in each of the other three
  (8 calls each): ~26 s of ABL's suite and the boot's.

#### Run

With this branch's tools first in PATH: the-advocate's `just lint`,
`just test` (29 passed) and `just rust-test --no-fail-fast` green;
`just test-game` with FluidR3, 231 passed and 6 skipped; ABL's `just
tests`, 1691 passed and 2 skipped —1694 before, less the three tests that
went—; the root's `just boot`, 218 passed, once The Frozen World's
`Cartridge.data` was given back (a first run had Zounds' debug-map tests
red for it). No golden moved. After merging the-advocate's `main`
—Chajá's lint—: `SOUNDFONT=… just lint` green, Goombario over the test
game's three cartridges included, and `just test-game` 230 passed and 6
skipped, its `test_linter.py` gone with that merge.

#### Branches, and what to install when merging

* the-advocate `cardon-tests-step1`: `a2db41ba` (the build leaves the
  slots and the numbers), `e3c23a83` (the five subcommands go), and main
  merged in. Install `events mapdata screens battle convert advocate`:
  `convert` and `advocate` for the ROMs' `slots.json` and equates, the
  other four because their binaries lost a subcommand.
* the-advocate-ports `cardon-tests-step1`: `55959d3`. It needs the tools
  above: with the global ones, `slots.json` is missing and the new
  equates are not in the `.sym`.
* the-advocate-docs `cardon-tests-step1`: `4d521a6`, "The tools" page.
* Aguará's step 2 touches `tools.md` too, the `wally` line of "Running
  them by hand", next to the lines this one changes.

Status stays `doing`: steps 2 to 8 are the task's.

### 2026-11-25, Aguará: step 2, Wally's invariants into Wally

On the-advocate `e267b6b3`, ports `7403613`, docs `69c7c16`; merged with
main at the-advocate `b39ece00`, ports `5df6a64`, docs `8e18cb6`.
Branches `aguara-tests-step2` in the three.

#### What changed

* **Two checks in the conversion, at every build of every game**, which
  stop it when they break —a bug in the rule, not a limit of the game,
  so there is no loss to declare—: `baking::hold`, right after
  `bakeable` (each baked tile opaque over its 16x16, tile 0 empty, and
  the table giving the cell the bits the event's row imposed), and `hold`
  at the end of `drawable_npcs` in `sprites/split.rs` (nobody but a
  leader candidate, or a look only the hero shows, in a leader's
  palette).
* `test_timer_palette.py` → `every_event_is_drawn_when_the_palettes_fall_short`
  in wally's `tests/lending.rs`; `test_leaders.py` →
  `a_map_earlier_in_the_directory_does_not_put_its_leader_in_front` in
  the converter's `scan.rs`. Both shown red with the lending and the
  per-map party reset broken.
* ABL's `test_baked.py`, `test_flash_palette.py`, `test_timer_palette.py`,
  `test_leaders.py` and `harness/map_stage.py` deleted, and `leaders` and
  `map_context` out of `harness/converter.py`; `test_fork_maps.py` finds
  the built ChipSets in `project.path("build")`'s `patches-manual`.
* The book: the flash divergence and the leaders' decision cite the new
  guards; the baked events' optimization names `baking::hold`.

**No test or harness calls `wally` or `rm2k-snes-convert leaders` /
`map-context` any more** —grep of the ports, the-advocate's `tests/`,
the test game and the harness—. What still names them: their own
binaries, wally's crate tests that drive the binary
(`whole_map.rs`, `command_line.rs`), `LAYOUT.md`, the converter's README,
`queries.rs`'s doc, and the book's `tools.md` "Running them by hand".
They go with the binaries at the end of the task.

#### Verified

* The nine games' `just cartridges`, on my branch before the merge, with
  my `advocate` against the globals at `e267b6b3`: every `.sfc`, `.msu`
  and `.inc` byte for byte equal; `converter.log` equal in eight, and
  Vampires Dawn's gains only the compiler's 672 left-out warnings because
  the globals' run took that answer from the cache
  ([`the-event-compiler-s-left-out-warning-never-reaches-the-log`](the-event-compiler-s-left-out-warning-never-reaches-the-log.md),
  known); `.dbg`, `stamp.txt` and `advocate.json` differ only in the
  runtime's path. So every invariant holds today and the log gains no
  line.
* Broken on purpose, ABL's `release` stops:
  * the rule without its opacity filter: "map 11: baking an event broke
    its rule: event 33 is baked with tile 10033, which has transparent
    pixels";
  * the row's bits computed apart from the table (`tile_passability`
    flipping a bit): "event 36 imposed Some(14) on cell 4817 and, baked,
    the map's table says 0xf". Two more realistic breaks —the rule
    baking tiles that go above the hero, or the next tile— found no
    candidate in any of the nine games, so the passability check guards
    a regression none of them can trigger through the rule today;
  * the split letting anyone into a leader's palette: "map 3: the split
    put @tile:ChipSet1_3:31:0 in palette 1, which is a leader's" —the
    Emitter Room—.
* On the merged tree, with `events mapdata screens battle convert
  advocate wally` installed locally: `just lint` (with `SOUNDFONT`),
  `just test`, `just rust-test --no-fail-fast` (all green but
  `the_synth_bass_releases_as_the_soundfont_says`, which wants the
  Microsoft GS SoundFont and I had given it FluidR3; green with the right
  one), `just test-game` with FluidR3 (230 passed, 6 skipped), ports'
  `just boot` (218 passed), ABL's `just tests` (1681 passed, 2 skipped,
  2 min 30 s of pytest). No golden moved. `abl.sfc` `3bf35fd7665c2045`.
  `just test` caught Kersh's name in an assertion message of the moved
  test (`test_no_game_names.py`): fixed.

#### What the tests stop catching

* That the baking rule still reaches some map of ABL: a filter too many
  bakes nothing and looks the same. Left: the crate's
  `bakeable_says_what_is_baked_and_why_it_is_safe` and the test game's
  baked map 15, both of which only fail if they stop baking.
* A leader that a map splits with its other characters
  (`shared_leaders`), which ABL's test looked at on maps 1 to 3 with
  party [10]: the build's check looks only at the leaders' own palettes,
  which is the split's promise; the rest is `separate_from_hero`'s.
* The timer and the leaders on ABL's map 2 and opening themselves: the
  crates check the same mechanism on invented maps.

#### Suite time

The four files, alone, one process, at `7403613` with the globals:
**197 s** —`test_baked.py`'s three tests 63 s each, the other seven
1 to 2 s—. What the checks add to the build was not measured apart: they
read sheets the drawer already drew, once per map.

Status stays `doing`: steps 3 to 8 are the task's.

### 2026-11-25, Hornero: steps 1 and 2 merged; the rest in series

Verified on the merged tree and pushed. taro, at 97% of the weekly limit: the remaining steps go one at a time, smallest first —6, then 8, then 4, 5, 3—, so a cut loses little.

### 2026-11-25, Cardón: step 6, mapdata's own tests to its crate

From the-advocate `67d52e0c`, ports `a09625d`, docs `dcfcdd9`; branches
`cardon-tests-step6` in the three.

#### What moved

* ABL's `test_the_own_route_points_to_the_block_it_receives` is
  `the_own_route_points_to_the_block_it_receives` in `record.rs` of
  `rm2k-snes-mapdata`: the same invented page, through `page_table` as a
  function; it also checks that both pointers are there. **Stops catching
  nothing**: the request was already invented.
* `test_lz2.py`'s round trip is `each_block_comes_back_equal_through_its_streams`
  in `materials.rs`: two generated maps with all eight kinds —a background
  of two buffers, a grid with an empty second half, a block shared between
  maps— through `compress_blocks` and `stream_of`, read back with `lz2`'s
  decoder. **Stops catching** a block shape only ABL's real maps reach, and
  a fault `lz2`'s compressor and decoder would share, which the harness's
  own decoder could see. That decoder, `tests/harness/lz2.py`, went with
  its only test —the one that read the five commands by hand—: `lz2`'s
  tests check the encoder's bytes against the format, and the ROM's
  decompressor reads the real streams in `test_decompressed_load.py`, which
  stays.
* Both shown red with a mutation: the route's pointer built from another
  label, and `stream_of` dropping every part after the first.
* `test_pages.py` keeps its other two tests —`release`'s slots, the Tram
  Officer compiles—: they ask no stage, and are ABL's facts.

#### The subcommands

`pages` and `compress` had no other caller and went. `vram` stays: the
screens' harness (`screen_stage.py`) still asks it, until step 3. The
book's `tools.md` says so.

#### Verified

With `mapdata convert advocate` installed locally from `277e4218`:
`release`'s `abl.sfc` byte for byte equal to the one `a09625d` built with
the globals; `just lint` (with FluidR3's `SOUNDFONT`) and `just rust-test
--no-fail-fast` green; ABL's `just tests` at `76a5f7c`, 1668 passed and 2
skipped.

#### Branches, and what to install when merging

the-advocate `277e4218`, ports `76a5f7c`, docs `925913d`, all
`cardon-tests-step6`. Install `just install mapdata convert advocate`:
the libraries' code did not change, only tests and the `mapdata` binary,
so the ROMs do not move.

Status stays `doing`: steps 3, 4, 5, 7 and 8 are the task's.

### 2026-11-25, Cardón: step 8, the remainder

From the-advocate `a86c5ceb`, ports `0dd2248`, docs `93df660`; branches
`cardon-tests-step8` in the three.

#### `convert compile`: the troop triggers from the LDB

`test_troop_events.py`'s two tests that asked it —the agents' liftoff on
turn 1 alone, the Lazer Teeth's page on turn 1 every 3 with Talan's HP—
check what the game's LDB says the ROM cases go through, so they read
**the LDB with RM2k's rule** (`turn_b` is the base, as easyrpg's
`CheckTurns` takes it), not the ROM's troop table: the header in front of
each page's code is reached only through the page's pointer, and reading
it would rebuild the walk the ROM does. Shown red by swapping the two
fields in the test's reader.

**Stops catching** the compiler carrying the turn the other way round:
held now by `the_turn_s_base_is_turn_b` in `troops.rs` of
`rm2k-snes-events`, shown red with the fields swapped in `trigger()`, and
still by ABL's ROM cases of the liftoff and the Lazer Teeth. Nothing else
called `rm2k-snes-convert compile`, so it went, with `Compiler::loose`;
`converter.py` keeps only `boxes()`, and `events.Trigger` went.

#### `prebuild` out of `games.py`

The root's `just boot` depends on a new root recipe, `just cartridges`,
which builds every game but ABL at the same time —what `deliver` did on
its own, and now calls with `TRACKS=1`—. The tests build nothing:
`built()` reads `build/advocate.json`, and a missing or stale cartridge
is a red that says to run `just boot`. `prebuild`, `needed`, the lock and
`_just` went; `conftest.py` only imports `games` first, for the import
path. The eight up to date take 0.2 s, so `just boot -k vampires`
building them all costs nothing once built.

#### `ditto`'s round trip: the dump checks its own

Both `test_round_trip.py` went. The test game's `just game` packs the
exact dump again and `cmp`s each RM2k file; each port's `just dump`
does the same through `rpg_maker_files.py --same`, case-insensitive as
the test was. Shown red: a byte changed in the test game's `.lmt` copy,
and a byte appended to Zounds' `RPG_RT.lmt` (a byte changed *inside* a
field Ditto reads comes back equal, as it should). **Stops catching**: a
change to Ditto that breaks the originals' round trip shows when a game
is dumped again, not on `just boot`; Ditto's `round_trip.rs` still
measures whatever `DITTO_CORPUS` names, and the test game's check runs in
CI and in `just lint`.

#### Verified

With `convert advocate` installed locally: ABL `release`'s `abl.sfc`
`3bf35fd7665c2045`, byte for byte the one the globals built; `just lint`
(FluidR3's `SOUNDFONT`) and `just rust-test --no-fail-fast` green; ports'
`just boot` 209 passed (218 minus the nine round trips); ABL's `just
tests` 1668 passed, 2 skipped.

#### Branches, and what to install when merging

the-advocate `e5823e72`, ports `2a80216`, docs `0623fe4`, all
`cardon-tests-step8`. Install `just install convert advocate`: the
library lost only dead code, so the ROMs do not move. The events crate
changed only in a test.

Status stays `doing`: steps 3, 4, 5 and 7 are the task's.

### 2026-11-25, Hornero: paused at the weekly limit

Steps 1, 2, 6 and 8 merged, verified and pushed. Left: 4 (images), 5 (audio), 3 (screens), one at a time; 7 with `battle-tests-without-simulate` (which also owns `test_zounds_special_items.py`'s `simulate`). ABL's `test_linter.py` stays held (ports branch `chaja-lint`) until the test game carries the runtime branches.

### 2026-11-27, Hornero: steps 3, 4 and 5 in parallel

The weekly limit reset: screens to Carpintero, images to Chajá, audio to Mulita. Step 7 waits for `battle-tests-without-simulate`.

### 2026-11-27, Mulita: step 5, the audio — the writes measured

From the-advocate `2b4f8cf2`, ports `4821050`, docs `c956b2f`; branches
`mulita-tests-step5` in the three.

**What the writes weigh**, measured on ABL's `release` built at `4821050`,
decoding each of its 107 songs from the ROM with `rm2k-snes-audio decode`
as the harness does: **1,893,648 writes**, in 185,992 frames that write
something; its streams are 1,120,360 bytes of the ROM. As
`[[frame, register, value]]` JSON that is **25.7 MB** per cartridge, 6.5 MB
gzipped; a compact binary would be 4.2 MB, 1.3 MB gzipped. The test
cartridges carry from 1 to 13 songs, a fraction of that.

Judged reasonable **compressed and one file per song**: written with fast
compression it is **8.6 MB** for `release` (Vampire's Dawn's is 8.2 MB, the
other games' 1 to 4 MB, ABL's test cartridges under 1.5 MB), beside a
`.dbg` of 55 MB and an `.o` of 61 MB, and a test that asks for one song
reads only that one. Not as one plain JSON: 26 MB per
cartridge, parsed whole by every worker that asks for a single song.
`flate2` is already in the workspace (the project's `archive.rs`), so
nothing new comes in.
