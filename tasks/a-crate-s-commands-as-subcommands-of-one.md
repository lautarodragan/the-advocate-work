---
name: "A crate's commands as subcommands of one"
description: "rm2k-snes-cartridge installs three commands and rm2k-snes-audio three more; each pair of extras becomes a subcommand of the crate's main command, so the PATH has four commands fewer and no boundary moves"
type: refactor
status: todo
author: taro
---

**Why**: two crates install three binaries each, and every one of them is
a command to know:

* `rm2k-snes/cartridge`: `rm2k-snes-cartridges`, `rm2k-snes-assemble`
  —which only `rm2k-snes-cartridges` runs— and `rm2k-snes-space`;
* `rm2k-snes/rm2k-snes-audio`: `rm2k-snes-audio`, `rm2k-snes-msu` —run
  by the build— and `rm2k-snes-volume-ceilings`, a recipe of ABL's.

They already share a crate, so folding them into subcommands
—`rm2k-snes-cartridges space`, `rm2k-snes-audio msu`— moves no boundary
between responsibilities: it only takes four commands off the PATH. It
follows
[`the-library-crates-carry-binaries-nobody-runs`](the-library-crates-carry-binaries-nobody-runs.md),
and waits for it to be merged, since both touch the justfile's lists.

> Let's go!

(taro, 2026-11-23, approving this and the split, in the book, of the
commands a person runs from those the pipeline runs)

**What is asked**:

* The six binaries become two commands with subcommands; every caller
  follows —the justfiles of the nine games and of the test game, the
  harness, the `Command::new`s in Rust, the fingerprint of
  `rm2k-snes-cartridges`, the release workflow—, and the old names go to
  `RENAMES.md` of the ports for the recipes that change.
* Whatever the caches key by binary —the MSU-1 tracks, `ca65`'s objects—
  keeps meaning what it meant: say what a hit or a miss becomes.
* No ROM changes: every game's ROM byte for byte equal to `main`'s.
