---
name: "The other games' tests do not run in parallel"
description: "`just boot -n 8` in the ports builds the same game from several workers at once and they step on each other"
type: test
status: done
author: chaja
---

Seen by Chajá on 2026-10-18, at the ports `ffc3a5b` with the-advocate
`9033e6dd` plus the window's bands, in a fresh worktree of the ports with
nothing built.

`just boot -n 8`, from the root of the ports, passes `-n 8` to pytest, and
xdist runs several tests of the same game at once: each one finds the
game's cartridge stale and runs `just cartridges` in its directory, in the
same `build/release/`. Nine tests failed with errors that are not the
game's: `rm2k-snes-mapdata: …/book-of-three/build/release/raw: Directory
not empty`, `mapdata.inc:33332: Error: Unexpected end of line`, `Symbol
'BOOT_FRAMES' is already defined`. Run serially, the same tree gave 67
passed.

The recipe's comment says nothing about running it in parallel, and ABL's
`just tests` does run with xdist, so the flag is an easy thing to reach
for.

## Defined

On 2026-10-20, by Tijereta.

Checked against the ports `68bf55b`: still so —the root's `boot` recipe
is `cd tests && pytest "$@"`, and its comment does not mention `-n`—.
**Done**: `just boot -n 8` on a fresh worktree of the ports, with nothing
built, passes as the serial run does: each game's tests in one worker
(xdist's `--dist loadgroup` with an `xdist_group` per game, or a lock
around each game's `just cartridges`), or the recipe refusing `-n` with a
message that says why. **First step**: reproduce the errors with `just
boot -n 8` on a fresh worktree, while no other suite runs.

## Log

### 2026-11-21, Hornero: done with Calandria's parallel `just boot`

Fixed on the way by the ports' `42379bf`
([`the-ports-boot-tests-and-the-delivery-take-too-long`](the-ports-boot-tests-and-the-delivery-take-too-long.md)):
`just boot` runs with xdist by default, each game's `just cartridges`
under a `flock` of its own in `tests/games.py`, and `tests/conftest.py`
builds the games a run needs before the tests start. Its cold run, with
nothing built, passed whole in 397 s.
