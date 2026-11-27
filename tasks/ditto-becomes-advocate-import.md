---
name: "ditto becomes advocate import"
description: "Ditto's binary goes: what a port's just dump asks it —RM2k's .ldb, .lmt and .lmu to the JSON dump in data/— becomes advocate import, and what the test game's recipe asks it —packing its text back to RM2k's format and the round trip— finds a home in advocate too; ditto stays a library"
type: refactor
game: advocate
status: todo
author: taro
links:
  relates: [advocate-init-dump-and-config, one-advocate-command, rm2k-sketch-becomes-a-library]
---

**Why**: once `rm2k-snes-battle`, `wally` and `rm2k-snes-events` go
(with [`tests-without-the-stages-subcommands`](tests-without-the-stages-subcommands.md))
and `rm2k-snes-audio` with its volume ceilings, `ditto` is the last
binary of ours on a port's path besides `advocate`.

> Confirmed, `advocate import` instead of ditto.
>
> Let's separate ditto into its own task. advocate-init-dump-and-config
> stays for... init and config, precisely, and `ditto -> advocate import`
> goes to a new task, to `todo`, and we leave it in the queue.

(taro, 2026-11-27) The name `import`, and why not `dump`, are in
[`advocate-init-dump-and-config`](advocate-init-dump-and-config.md)'s log
of 2026-11-25.

**Who calls `ditto` today**:

* each port's `just dump`, in the ports: `ditto unpack` from the game's
  `.zip` to `data/` —the database and the maps as JSON; pictures, MIDIs
  and sounds are not imported, the build reads them from the untouched
  `.zip`—;
* the test game's `just game`, in the-advocate's `test-game/justfile`:
  `ditto pack` of its text source to RM2k's files, `ditto unpack` of
  those back to the dump the converter reads, and the round trip
  —packed again, byte for byte— that proves Ditto reads what it writes,
  in CI.

**What is asked**:

* **`advocate import`**: what `just dump` does, the action and not
  Ditto's own subcommands; the ports' `just dump` calls it.
* **The test game's way back**: `pack` and the round trip need a home
  —`advocate export`, a flag of `import`, or the test game's recipe
  calling a Rust test instead of a binary—, decided in the design. It
  goes together with whatever is decided about `rm2k-sketch`, which
  feeds that same recipe.
* **`ditto`'s binary goes**, the library stays; `cargo uninstall` of it
  where it was installed, and the book's and READMEs' mentions follow.
* Every port's `data/` byte for byte the same as `ditto unpack`'s, and
  the ROMs byte for byte.

It goes after [`one-advocate-command`](one-advocate-command.md) and
before [`advocate-init-dump-and-config`](advocate-init-dump-and-config.md),
whose `init` calls it.

## Log

### 2026-11-27, Hornero: written

Nothing done yet.

### 2026-11-27, Hornero: `rm2k-sketch` goes with it

> Two separate tasks for tracking, but they can be implemented together.

(taro, 2026-11-27) [`rm2k-sketch-becomes-a-library`](rm2k-sketch-becomes-a-library.md):
the packing this task gives a home reads the test game's sketches too.
