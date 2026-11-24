---
name: "cartridges runs itself to assemble"
description: "rm2k-snes-cartridges builds each cartridge by spawning `rm2k-snes-cartridges assemble`, its own subcommand, as a process: a leftover of when the assembler was a binary of its own; it becomes a function call"
type: refactor
status: todo
author: taro
---

**Why**: `Cartridges::convert`, in `rm2k-snes/cartridge/src/cartridges.rs`
of the-advocate, runs the converter and then `ASSEMBLE`
—`["rm2k-snes-cartridges", "assemble"]`— with `Command::new`. Until
2026-11-23 the assembler was `rm2k-snes-assemble`, a binary of its own,
and spawning it was the only way; `e18f77aa` made it a subcommand of the
same program and left the call as a process. Now the program runs itself
through the PATH —which, with a `.local-tools` first, may not even be the
same binary— to call code it already links.

> Go ahead, but to `todo` directly, and we take it on as soon as Calandria
> finishes.

(taro, 2026-11-23)

**What is asked**: the cartridge is assembled by calling the subcommand's
code as a function; `ASSEMBLE` goes, and whatever named it —comments, the
book— follows.

What stays a process, and why, so nobody folds it by analogy:

* the converter runs each stage as its own process: the stage cache keys
  each answer by its binary's hash (`stage.rs` `key`);
* `rm2k-snes-cartridges` runs `rm2k-snes-convert` and
  `rm2k-snes-audio msu`, which are other commands, with caches of their
  own;
* `rm2k-snes-audio volume-ceilings` plays each song in a process of its
  own: the snes9x libretro core is a `.so` with global state.

**How to verify**: every game's ROM byte for byte equal with `NO_CACHE=1`,
and the cartridges' fingerprint unchanged in what it covers —it already
hashes `rm2k-snes-cartridges` itself—; then the usual suites.

## Log

### 2026-11-23, Hornero: written, after Calandria's emission work

Nothing done yet. It waits for Calandria's branch so that no tool is
reinstalled while their suites run.
