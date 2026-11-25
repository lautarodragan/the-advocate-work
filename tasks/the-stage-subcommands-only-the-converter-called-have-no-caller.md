---
name: "The stage subcommands only the converter called have no caller"
description: "Since the converter calls every stage as a function, eleven subcommands of the stage binaries are run by nothing: no test, no recipe, no converter; their main over the stage function is a path nothing executes"
type: refactor
status: testing
assignee: taro
author: calandria
agents: [calandria, tijereta]
links:
  found-in: [the-stages-speak-json-nobody-types]
  relates: [tests-without-the-stages-subcommands]
  part-of: [one-advocate-command]
---

Seen by Calandria on 2026-11-24, doing A9 of
[`the-stages-speak-json-nobody-types`](the-stages-speak-json-nobody-types.md)
on the-advocate `9ae5671a`, ports `4c23c9e`.

**What**: phase A kept every stage binary and every subcommand, a `main`
over the same `stage` function, because the tests call some of them. The
ones only the converter called are now called by nothing. Grepped in the
ports (`tests/`, `experiments/`, every `justfile` and `game.just`) and
in the-advocate's `test-game/`, `rm2k-snes/harness/` and `tests/`, against
the design's table of who calls what (section 4 of the task above):

| Binary | Subcommands nothing runs |
|---|---|
| `wally` | `map` |
| `rm2k-snes-events` | `compile` (`culprits` is a person's, and `scan` the tests') |
| `rm2k-snes-screens` | `boxes`, `faces`, `convert` |
| `rm2k-snes-images` | `fullscreen`, `picture`, `background` |
| `rm2k-snes-battle` | `tables` |
| `rm2k-snes-mapdata` | `emit` |
| `rm2k-snes-audio` | `cartridge` |

The stage functions behind them are covered by every build; what no test
executes is each `main`'s reading of the flags and writing of `--out`
(A6 checked `emit`'s by hand once, A7 said `cartridge`'s has no test).

**What to decide**: remove those subcommands now —each a few dozen lines
of `main.rs`, and their usage lines in the crates' READMEs—, or keep them
for a person to run a stage alone on a dump, as the book's "Running them
by hand" in `tools.md` promises. One-advocate-command removes the stage
binaries once the tests stop calling them, which takes these with them;
removing them earlier only shrinks what that task removes.

## Log

### 2026-11-24, Hornero: promoted to `todo`

Promoted by Hornero: verified by grep against every caller, nothing seen
or heard changes, and removing them goes the way taro already set —the
book's decision "One command, and no tool runs another"; the stage
binaries go once the tests stop calling them—. Decided: remove the
eleven subcommands, their usage lines in the READMEs, and fix the book's
"Running them by hand" in `tools.md` to name only what still runs. Not
urgent: `one-advocate-command` would take them with it.

### 2026-11-24, Calandria: one more, and the crate tests that drive them

Seen designing [`one-advocate-command`](one-advocate-command.md), at
the-advocate `cd3a40af`:

* **`rm2k-snes-patches --request DECISIONS BUILD`** (`main.rs:67`, "the
  converter: one build's patches") has no caller either: the converter
  calls `rm2k_snes_patches` as a function since A8, and nothing in the
  ports or the test game passes `--request` (grep of `4c23c9e`). Its
  `BUILD` and `--check` modes stay, `test_patches.py` and ABL's
  `patches-check` run them.
* **Crate tests run some of the eleven through the binary**: `wally map`
  in `whole_map.rs`, `decorative.rs`, `fused_tiles.rs`, `shared_slots.rs`
  and `too_many_npcs.rs`; `rm2k-snes-battle tables` and
  `rm2k-snes-events compile` in their `command_line.rs`. So "nothing runs
  them" holds for the ports and the converter, not for `just rust-test`:
  removing a subcommand moves its tests onto the stage function, and that
  is most of the step.

### 2026-11-25, Tijereta: the twelve removed, their tests on the functions

On the-advocate `cd3a40af` (branch `tijereta-dead-subcommands`), the book
at `ae2b401` (branch `tijereta-dead-subcommands`), ports `4c23c9e`
(nothing to change there).

#### Grepped again before removing

The ports' `tests/`, `experiments/`, every `justfile` and `game.just`;
the-advocate's `test-game/`, `rm2k-snes/harness/`, `tests/`,
`.github/workflows/`; the book. What the ports' harness asks the stage
binaries is `wally bakeable`/`split`, the screens' `render`, `refit`,
`layout`, `equip`, `window`, the images' `backdrops`, `battlers`,
`animations`, the battle's model questions, the mapdata's `vram`,
`pages`, `compress`, `engine`, the events' `scan`, and `rm2k-snes-audio`'s
`compile`, `keys`, `wav`, `find-song`, `volume-ceilings`: none of the
twelve. The `"compile"` and `"boxes"` in ABL's `converter.py` are
`rm2k-snes-convert`'s queries, not the stages'.

#### What went, and where its tests went

Lines of `main.rs` removed (added) per binary, `git diff --numstat`:

| Binary | Gone | `main.rs` |
|---|---|---|
| `wally` | `map` | -23 (+3) |
| `rm2k-snes-events` | `compile` | -5 (+2) |
| `rm2k-snes-screens` | `boxes`, `faces`, `convert` | -62 (+10) |
| `rm2k-snes-images` | `fullscreen`, `picture`, `background` | -41 (+4) |
| `rm2k-snes-battle` | `tables` | -41 (+4) |
| `rm2k-snes-mapdata` | `emit` (and its `--raw`) | -47 (+5) |
| `rm2k-snes-audio` | `cartridge` | -66 |
| `rm2k-snes-patches` | `--request` | -30 (+5) |

* Wally's five map tests call `stage::map` —the converter's entry—
  through `tests/common/mod.rs`, which reads the request file the test
  wrote, types it and writes the answer where the test reads it;
  `stage::map_of`, the untyped entry only the binary used, went.
* The events' three compile tests moved to `tests/compile_stage.rs`, over
  `stage::compile`; `command_line.rs` keeps the binary's `scan`.
* The battle's `command_line.rs`, all `tables`, became `tables_stage.rs`
  over `stage::tables`. **Its exit-code-2 test went**: a function has no
  request file, and no test is left on that binary's exit codes.
* The patches' tests write a build as the converter does (`stage::patches`
  and `put`) and then copy and check it with the binary; the test of
  `--request`'s own argument checks went with it.

Two commits, the removal with its tests and then the prose (the crates'
READMEs, the `stage.rs` headers, the mapdata request's comments). The
book's "Running them by hand" in `tools.md` now lists what each stage
binary still runs; the road's diagram and table keep naming the steps by
binary and function, and say the rest are functions only.

**Left for step 6**: the converter's crate (`convert/README.md`, `maps.rs`,
`emit.rs`, `compiler.rs`, `fullscreen.rs`, `animations.rs`, `scene.rs`,
`screens.rs`, `Cargo.toml`, `convert.rs`), `runtime/message_face.s`,
`LAYOUT.md`, and the book's `tools.md` diagram and
`internals/the-converters-stages.md` still name the old subcommands as
the stages' names. The converter is Calandria's while it becomes a
library, and the runtime is in the fingerprint.

#### Verified

With `just install-local .local-tools convert wally events screens images
battle mapdata rm2k-snes-audio patches` first in PATH, in a ports worktree
at `4c23c9e`: `NO_CACHE=1 just cartridges --force` of the nine games (ABL
`--without-tracks`) gives the 20 `.sfc` —ABL's release and its ten test
cartridges, Zounds' two, one per other game— **byte for byte equal** to
the same build with the globals of `cd3a40af`; ABL's `abl.sfc` sha256
`3bf35fd7…1718`. Then, green: `just lint`, `just test`, `just rust-test
--no-fail-fast`, `SOUNDFONT=…/FluidR3_GM.sf2 just test-game`, the ports'
`just boot` and ABL's `just tests`. Only the `.sfc` were compared, not
every file of `build/`: nothing that writes the others changed, but that
was not measured.

**What no test covers any more**: the battle binary's exit codes (its
only test of them was the `tables` one), and the patches binary's refusal
of a wrong call with `--check`.

**To install when merging**: `just install convert wally events screens
images battle mapdata rm2k-snes-audio patches`.
