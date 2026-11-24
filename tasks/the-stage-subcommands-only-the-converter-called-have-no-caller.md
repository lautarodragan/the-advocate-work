---
name: "The stage subcommands only the converter called have no caller"
description: "Since the converter calls every stage as a function, eleven subcommands of the stage binaries are run by nothing: no test, no recipe, no converter; their main over the stage function is a path nothing executes"
type: refactor
status: draft
author: calandria
agents: [calandria]
links:
  found-in: [the-stages-speak-json-nobody-types]
  relates: [tests-without-the-stages-subcommands]
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
