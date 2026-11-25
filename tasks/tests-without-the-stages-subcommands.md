---
name: "Tests without the stages' subcommands"
description: "Besides simulate, the ports' tests ask the stages themselves —screens' window, render, equip, layout and refit, images' backdrops, animations and battlers, Wally, mapdata's vram, engine, pages and compress, battle's experience, field-skill, lines and model, the scans— for what they expect or need; the tests should not depend on the converter's internals, and those subcommands should not be needed"
type: refactor
status: todo
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
