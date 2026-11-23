---
name: "Recipes that only wrap a command"
description: "Recipes that add nothing to the command they run go; the eight identical games' justfiles become one shared file; and the dump's round trip stops being a recipe repeated nine times and becomes a test, on the test game and on the nine games"
type: refactor
status: todo
author: taro
---

**Why**: a recipe is worth having when it saves something repeated —the
whole toolchain behind `just cartridges`, the machine's flags, the
environment of `machine.just` the harness reads—. Some only wrap one
command with nothing added, and the eight games other than ABL each carry
the same 62-line justfile, differing only in `GAME_DIR`.

> There's no need for everything to go through the justfile. The idea is
> that it helps with repetitive tasks. Having a `just build` that calls the
> whole toolchain, for example, can make sense. A `just assemble` that is
> not much more than a wrapper of `rm2k-snes-cartridges assemble` adds
> nothing.

> [dump-round-trip] I think it shouldn't be a recipe or a command, but a
> test, right? We could run it on the test game, maybe.

(taro, 2026-11-23, and "dale" to all of what follows)

**What is asked**:

* **Recipes that go**: `dedupe-frames` and `objects-per-line` at the
  ports' root; `hub` in the test game; `patches` in ABL; `which` in
  the-advocate; and ABL's finished experiments' `msu-dma`, `msu-port` and
  `sram-dma` —how each was built stays in its `abl/experiments/<x>/`—.
  Whatever names them —docs, the book, tasks' "how to reproduce"— says
  the command instead. Check each one first: a recipe that does provide
  the environment or flags something needs, stays, and the task says why.
* **One justfile for the games**: what the eight games share goes to one
  file the ports import, the way `machine.just` is; each game keeps only
  its `GAME_DIR` and what is its own. ABL takes from it what it shares.
* **The round trip is a test**: `dump-round-trip` in the nine games and
  `ditto-round-trip` in the-advocate go. In their place, a test that
  unpacks and packs back and compares byte for byte:
  * in the test game's suite, which runs in CI —it proves Ditto reads
    what Ditto writes—;
  * and in the ports' `boot` suite, once per game, over each game's
    original —which is what proves Ditto reads what RPG Maker wrote—.
  Ditto's own `round_trip.rs`, which only runs with `DITTO_CORPUS`, is
  looked at too: kept, folded into those, or gone, with the why.
* No ROM changes.
