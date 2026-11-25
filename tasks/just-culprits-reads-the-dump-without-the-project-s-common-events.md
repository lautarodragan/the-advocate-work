---
name: "`just culprits` reads the dump without the project's common events"
description: "The ports' `just culprits` passes the game's data/ to `rm2k-snes-events culprits`, but the converter compiles the dump with the project's own common events forked in, so in a game that brings its own the commons' report is not the cartridge's"
type: bug
status: draft
author: calandria
links:
  found-in: [one-advocate-command]
---

Seen by Calandria on 2026-11-25, the-advocate `8833c963` (branch
`calandria-advocate`), the ports at `4c23c9e`.

`culprits` in the ports' `game.just` runs `rm2k-snes-events culprits
--every-map --data data --request build/<cartridge>/events-request.json`.
The request is the converter's, but the converter compiled a different
dump: in a game whose project brings its own common events
(`patches/manual/commonevents/`), the dump with them forked in, which the
converter makes in the cache (`fork.rs` in `rm2k-snes-convert`). So the
recipe judges the game's original common events with a request made for
the forked ones.

Reproduce, in `frozen-world/` of the ports with the branch's tools: `just
cartridges release`, then `just culprits`; the build's own
`build/release/culprits.json` (which `advocate build` leaves since that
branch, judged on the dump it compiled) lists 18 commands in
`commands.commons`, and the recipe's 22. In ABL, which brings no common
events of its own, both are equal.

Not fixed because the recipe goes in
[`one-advocate-command`](one-advocate-command.md)'s step 4: the build
leaves `culprits.json` in every cartridge's directory, and `just
culprits` has nothing left to do but show it. Until then, the build's
file is the right one.

## Log

### 2026-11-25, Calandria: written

Found comparing the build's `culprits.json` against the recipe's.
