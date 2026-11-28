---
name: "The stages' error kinds outlived their exit codes"
description: "Each stage's `Bad` tells `Answer` from `Usage`, and the converter's `Stop` carries a `code`, for the exit codes their binaries had; the binaries went and nothing reads either but a test"
type: refactor
game: advocate
status: todo
agents: [chaja]
author: chaja
links:
  found-in: [the-advocate-still-speaks-of-the-stages-binaries]
---

Seen by Chajá on 2026-11-28, in the-advocate at `b4654a3a`, doing
[`the-advocate-still-speaks-of-the-stages-binaries`](the-advocate-still-speaks-of-the-stages-binaries.md).

* The stages' `fail.rs` —battle, wally, screens, images, mapdata, events,
  rm2k-snes-audio— split what goes wrong into `Bad::Answer` and
  `Bad::Usage` so that "a script tells those apart without reading the
  message": they were their binaries' exit codes, 1 and 2. The converter
  calls each as a function, and `stage::call_uncached` in
  `rm2k-snes/convert/src/stage.rs` turns either into the same `Stop`.
* `rm2k-snes/convert/src/fail.rs`: `Stop` carries a `code`, 1, or 2 for a
  command line clap refused, which the converter's binary exited with.
  The builder (`Cartridges::convert` in `rm2k-snes/cartridge/src/cartridges.rs`)
  reads only `stop.message`; `rg '\.code\b'` finds the field read by one
  test in `convert/src/stage.rs` and nothing else.
* The converter's flags are still parsed by a clap command named
  `rm2k-snes-convert` (`rm2k-snes/convert/src/options.rs`), which is what
  a refused flag's message calls it; the builder writes those flags from
  the project file. Its `--help` text was fixed in the branch of the task
  above, so it no longer speaks of programs on the PATH.

The comments were made to say all this in that branch; the code was not
touched, being code. What to decide: whether the two kinds and the code
stay —they cost little, and a kind can still be useful in a message— or
go. Nothing seen or heard changes either way.

### 2026-11-28, Hornero: promoted to todo

Promoted by Hornero: code debt, verified: the split and `Stop::code` existed for exit codes that went with the binaries, and only a test reads them; whoever does it folds them where nothing tells them apart, every ROM the same.
