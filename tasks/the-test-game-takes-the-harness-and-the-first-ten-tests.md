---
name: "The test game takes the harness and the first ten tests"
description: "Phase 2's last two items: split ABL's harness so its generic part serves the test game in the-advocate, and move the ten M1 tests of what RM2k does from ABL's suite to the test game"
type: test
status: testing
assignee: taro
agents: [Tijereta]
author: taro
game: test-game
---

taro, on 2026-11-22, translated, about closing
[`golden-game-and-two-repos`](golden-game-and-two-repos.md):

> Go ahead! I'd like to take it on soon.

What is left of phase 2 of the book's
[`research/2026-10-02-the-test-game.md`](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-02-the-test-game.html),
section 5, as Tijereta checked it on 2026-11-22 (the-advocate `0ae40e0a`,
the ports `89f77b4`):

1. **The harness split.** ABL's harness is whole in
   `abl/tests/harness/` in the ports, and `test-game/tests/game.py` in
   the-advocate calls itself "a stopgap" until the generic part comes
   over. The part that knows nothing of ABL —the cores, the session, the
   symbols, the captures and the comparison at 15 bits— goes to
   the-advocate, where the test game uses it; ABL's own stays in the
   ports and uses it from there.
2. **The ten M1 tests**: `test_variables`, `test_conditional`,
   `test_labels`, `test_jumps`, `test_same_door`, `test_speed`,
   `test_key`, `test_terrain`, `test_own_action` and `test_camera`, all
   still in `abl/tests/rpgmaker/` and with no copy in
   `test-game/tests/`. Each moves with its cases built in the test game's
   maps, and leaves ABL's suite only once its copy is green in both cores.

**Done** is both items: the stopgap gone, the ten tests run by `just
test-game` and by CI, and ABL's suite without them. With that,
`golden-game-and-two-repos` can be closed. Phases 3 to 5 are not part of
this.

## Log

### 2026-11-22, Tijereta: taken

Started from the-advocate `0ae40e0a`, the ports `238c90b`, the book
`3e6bb0b`. Branches `tijereta-test-game-harness` in the three, worktrees
under `~/scratch/tijereta/tg/`. ABL's suite and the ports' `just boot` run
first on `238c90b` untouched, with the global tools, as the "before".

### 2026-11-22, Tijereta: the harness's generic part, to the-advocate

What knows no game went to the-advocate as one Python package,
`rm2k_snes_harness`, in `rm2k-snes/harness/`: ABL's libretro driver
(`retro.py`, the superset: it has the MSU-1 log), the three bsnes patches
and Mesen2's shim (`cores/`), RPG Maker's rules (`rm2k.py`), the engine's
numbers and the stage runner (`engine.py`, `stage.py`), and what was the
test game's stopgap, made generic: a `Game` (its root, its builder flags,
its goldens) handed once to `use`, the `Cartridge`, the tick-clock
`Session` and the 15-bit `golden`. `test-game/tests/game.py` and the
test game's copy of the driver are gone; its `conftest.py` says what is
its own.

**How the ports find it**: `rm2k-snes-project --harness` prints the
directory, with no project needed —the ports' root runs several games—,
and the JSON's `suite.harness` says it too. It is the checkout the tools
were installed from, like the runtime, so a worktree's `.local-tools/`
brings its own harness and its own runtime together, and nothing in the
ports names where the-advocate is. ABL's `places.py`, which every entry
point imports first, appends it to `sys.path`; the root's `games.py` does
the same; the four experiments ask the binary; `just audit-core` and
`just mesen2-core` take the patches and the shim from there. A release's
archive carries `rm2k-snes/harness/` and its smoke test checks the binary
finds the archive's. The test game names it in its `pytest.ini`, by its
place in the repo: it is tested with its own checkout's harness.

**What ABL's harness takes from it**: the driver, the rules, the engine
and the stages. Its `console.Session` —title screen, menus, saves through
the slot screen, the frame-clock `run`— is still its own, and the generic
`Session` copies its clock; rebasing one on the other is part of what the
progress page now lists as next, with the menus and models.

#### Verified

* the-advocate: `just test` 29 passed; `just crate-test project`; clippy
  and rustfmt on `rm2k-project`; `just test-game` 78 passed, 1 skipped
  (the same as before: the rename's save, in bsnes).
* ABL's `just tests` and the ports' `just boot`, before (`238c90b`, global
  tools) and after (the harness commits, with only `rm2k-snes-project`
  from a frozen worktree of the-advocate's branch): **1728 passed, 2
  skipped** and **198 passed**, both times.

### 2026-11-22, Tijereta: the ten tests, to the test game

All ten moved, each rewritten on the test game's maps and run in snes9x
and bsnes —ABL ran them in snes9x alone—, and then deleted from ABL with
the sixteen cases only they used (`save-198` stays: others use it).
What the test game needed:

* **cases** for each (`variables*`, `screen-of-*`, `labels`, `branch*`,
  `key-wait-for-*`, `speed*`, `terrain`, `camera-fast*`), switches in
  1400-1430, the RM2k variable numbers ABL's used;
* **the lookout** (map 10) gets "Dispatcher", an automatic page on switch
  1430 that teleports to the clearing: `test_jumps`'s dispatcher case;
* **terrains** 2-4 in the database, and the showcase's ChipSet (2) gives
  tiles 5000-5003 terrains 1-4 and the first water 3: `test_terrain`,
  whose expected values come from the dump's `.tiles` and `terrain_data`;
* **the doors**, map 12, two rooms crossed by teleports to the same map,
  a door that opens (moving itself and a marker) and a hatch above the
  hero: `test_same_door` and `test_own_action`. Its events are
  `move_type: stationary` —the format's default is random, and the first
  run had them wandering—;
* **the patchwork**, map 13, 60x60 of diagonal stripes of five lower
  tiles: `test_camera`, with a guard that no row or column draws like its
  neighbours one or two away, which the plain would fail.

The generic `Session` learned `variable(number)` (through the event
compiler's `scan`, as ABL's `data.variable_slots`), `switches=` at boot
and `turn_on`, `put_byte`/`put_word`, `event`, `party`, `box_up`,
`running_a_page`, `run(ticks, holding)`, `until_control`, `go_to_map`,
`window` and `wrongly_drawn_cells`.

Differences from ABL's versions, on purpose: the screen-place case uses
the plain (pan) and the meadow (screen-sized) instead of ABL's map 5; the
saturation case writes 999999 itself instead of calling ABL's common event
45; the item count uses the Sword; the own-action "head on" half faces the
hatch itself, which is the rule's other half (ABL's faced a blocking event
two cells short of it); the conditional's "game page" half is a case with
the shape of ABL's map 52 page.

Seen red on the way, and why: the key cases pressed during the case's
`Wait 5` —tenths of a second, thirty frames: measured, a press before them
is not read—, and the doors' events wandering. The moved tests were not
seen red against the defects they guard: that was done in ABL, where they
were born.

#### Skips in bsnes (5 new)

The two saves (variables, speed), as the leader-name rename already did:
bsnes keeps the SRAM between consoles in a process and does not let it be
cleared. The three window checks of `test_camera`: bsnes's core exposes no
VRAM.

#### Verified

* the-advocate at `65f68fee`: `just test` 29 passed; `just test-game -rs`
  **164 passed, 6 skipped** (the five above and the rename's). No golden
  of the test game changed and none is new: nothing to look at in
  `/shared/captures/2026-11-22-test-game-m1/` but captures of the two new
  maps, which are not goldens.

### 2026-11-22, Tijereta: ABL without them, merged with main, to testing

ABL's ten files are deleted. **Their sixteen cases stay**, unused by any
test: deleting them was tried first, and ABL's suite went red in two
places —`test_the_versioned_patches_are_what_the_converter_decides`, with
maps 17, 199, 307 and 315 keeping more colours (53 to 75, 59 to 74, 15 to
18, 18 to 45), and `test_delcentric_pump[17]`, 9 of 57,344 pixels—: the
cases are pages of the `release` taro plays, and taking them out moves
what the converter decides for other maps. With them back the suite is
green, so that was the cause. Taking them out is a change of what is
seen, with its patches regenerated and its golden looked at: left for a
change that wants it. The README's index loses the ten and says where they
went; four comments that cited them point to the test game.

The book: the progress page says phase 2 is done and what is next —the
rest of the harness (ABL's menus, screens, models, and its `Session`'s
clock, which the generic one copies), and phase 3—; A Blurred Line's page
and the emulators' reference say where the driver and the audit patch
live now. Research pages are snapshots and were not touched. The
the-advocate README no longer says it runs no ROM test.

#### Verified on the merged tree

The ports merged with main (`1850365`), with `rm2k-snes-project` from
the-advocate's branch (`65f68fee`'s harness) and the rest global:

* ABL's `just tests`: **1686 passed, 2 skipped** —the 1728 less the 42
  tests the ten files held—.
* the ports' `just boot`: **196 passed, 3 failed**, the three of
  `test_desert_nightmare_menu.py` (15,568 pixels off each): main has
  Mulita's goldens for the menu on painted maps, whose runtime fix is
  the-advocate's `mulita-dn-menu-face`, not in the-advocate's main nor in
  the global tools. Not from this change; the 196 others are green.
* the-advocate needed no merge: its main has not moved from `0ae40e0a`.

#### When merging

* the-advocate touches `rm2k-project` —`rm2k-snes-project --harness`, and
  `suite.harness` in its JSON—: `just install project` at least, before
  the ports run, since ABL's `places.py` and the root's `games.py` ask it
  on import; AGENTS.md says a `project` change reinstalls everything.
* the CI's cores cache key changes (the patches moved): a first run
  rebuilds them.
* What the test game's maps gained —maps 12 and 13, a dispatcher on map
  10, terrains on ChipSet 2— changed no golden of it.
