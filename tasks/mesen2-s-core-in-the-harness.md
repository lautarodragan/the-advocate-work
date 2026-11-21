---
name: "Mesen2's core in the harness"
description: "A recipe that builds Mesen2's core with a libretro shim, so a .mss save state from taro's own game is loaded, its lag counted the way Mesen2 counts it, and its frame profiled by lines"
type: feature
status: done
assignee: taro
author: hornero
agents: [Aguará]
---

Opened by Hornero on 2026-11-17, at the-advocate `ed8d8590` and the ports
`f62e91b`, after
[`abl-lazer-teeth-s-rock-lags`](abl-lazer-teeth-s-rock-lags.md): two rounds
could not reproduce taro's ~35 lag frames, and taro's own `.mss` did it in
minutes, through a shim Aguará wrote around Mesen2's core (left in
`~/scratch/aguara/lt35/shim/`, with the core built at Mesen2 CE `20ba206`,
the version taro plays with).

taro, translated:

> Good idea! I like both. I'd go for the two in parallel, I think.

The other one is
[`debug-switches-for-the-global-state`](debug-switches-for-the-global-state.md).

**Done**: a recipe in the ports —like `just audit-core`— that builds the
core at a pinned commit and the shim; the harness can load a `.mss` and
run from it, and read Mesen2's lag counter; the line profiler usable from
it without touching the ROM; a short how-to where the ports' tests explain
their tools. Whether a test may depend on it (it costs building Mesen2) is
part of the decision: by default it is a tool for reports, not for the
suite.

## Aguará (2026-11-17)

Started from the-advocate `ed8d8590` and the ports `f62e91b`; branch
`aguara-mesen2-core` in the ports. The runtime is not touched.

The plan: the shim of the Lazer Teeth round goes to the ports as
`tests/harness/emulator/mesen2_shim.cpp`, compiled with Mesen2's own
makefile in place of the library its UI loads (`DLLOBJ`), by a recipe
`just mesen2-core` —`audit-core` is already bsnes's— pinned to Mesen2 CE
`20ba206` (fetched from nesdev-org's repository, depth 1, into a clone of
its own that `machine.just` places, `mesen2_source`), installed in
`MESEN2_CORE`. Over it, `tests/harness/mesen2.py` —a `.mss`, presses, the
lag counter, the line profiler— and `just mesen2`. The shim now also sends
the picture, so a state can be looked at, and makes its own home folder for
Mesen2 instead of the ROM's directory (the old one left a `mesen2-home/`
next to the delivered ROM).

The ROM taro's `taro-abl_1.mss` was saved on, rebuilt from its commits —the
ports `428e7c3` with the-advocate `95863f36`'s `cartridge` installed
locally—: `abl.sfc` sha256 `3cfb09a7…`, byte for byte the delivered one the
state loaded on.

### Done (the ports `a627f07`)

* `just mesen2-core`, in `abl/`: from nothing, 72 s with every thread
  —the fetch, the whole of Mesen2 and the LTO link—; with the clone
  already there and only the shim changed, 29 s. It installed
  **`/usr/local/lib/libretro/mesen2_libretro.so`** (`MESEN2_CORE`) and
  left the source in `~/ref/mesen2-core` (`mesen2_source`), both from
  `machine.just`. Needs `gcc`, `make` and SDL2's `sdl2-config`, which
  Mesen2's makefile links.
* `just mesen2 ROM STATE [--press BUTTON:FRAME …] [--frames N] [--watch
  [ROUTINE …]] [--poke SYMBOL=VALUE …] [--shot PNG] [--save MSS]`
  —`tests/harness/mesen2.py`—; from a script, its `Mesen2` over any
  console on the core, and `mesen2.session(case, …)` for a
  `suite.session` on it, with `collect()` for the profiler's hits when the
  `Session` runs the frames.
* The how-to: "Mesen2's core" in `tests/harness/emulator/README.md`, with
  the two rules: a `.mss` only replays on the ROM it was saved from
  —rebuilt from the delivery's two commits—, and only loads on the Mesen2
  version that saved it.

**Decided: no test of the suite depends on it.** It costs Mesen2's
sources, SDL2 and a minute of compiling on a new machine, and its
question —what taro's emulator saw from taro's game— is a report's. What
it found becomes a test on the suite's cores, as `test_stones.py`'s tint
cases did.

What is not there, and why: a `.mss` carries no hash of its ROM —only the
file's name, which is always `abl.sfc`—, so a state on the wrong build
cannot be refused: Mesen2 loads it and runs garbage. Measured: taro's
state on the current `release` gives 123 "lag" frames and 2693 ticks in
120 frames. The how-to says to rebuild; nothing checks it.

### Verified

* taro's `taro-abl_1.mss` on the rebuilt `3cfb09a7…` ROM, through `just
  mesen2`: A then up, 120 frames: **33** lag frames (86 ticks); idle 300
  frames: 0; `--poke tint_s=100`: 6. The three numbers of the Lazer Teeth
  round, and `--watch`'s table line for line the scratch profiler's
  (`flashes_tick` 124-131 lines per tick of "Hit A").
* The picture: `release` booted 600 frames on snes9x and on the shim, 0
  pixels of 57,344 apart at 15 bits (the title screen).
* `mesen2.session` with the harness's throw at Light4 under the opening's
  tint, on the branch's `release`: 9 lost, 8 on Mesen2's counter —the
  round's 9—, and 3286 profiler rows collected after the `Session` ran
  the frames.
* `just tests tests/tooling`: 155 passed and one red,
  `test_new_tests_do_not_name_tools`, because the how-to wrote the
  local-install folder's name; reworded, `test_abl_side.py` and
  `test_index.py` green. The rest of the suite was not run: nothing it
  runs changed —`places.py` gained a variable no test reads—.

**To install when merging**: nothing of the-advocate. The core is already
installed by this run; on another machine, `just mesen2-core` in `abl/`.

## Closed (2026-11-17)

By taro. Verified by Aguará: taro's own `.mss` gives the 33 lag frames through `just mesen2` on the ROM rebuilt from its commits.
