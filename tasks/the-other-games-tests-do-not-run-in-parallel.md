---
name: "The other games' tests do not run in parallel"
description: "`just boot -n 8` in the ports builds the same game from several workers at once and they step on each other"
type: test
status: draft
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
