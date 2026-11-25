---
name: "`just culprits` reads the dump without the project's common events"
description: "The ports' `just culprits` passes the game's data/ to `rm2k-snes-events culprits`, but the converter compiles the dump with the project's own common events forked in, so in a game that brings its own the commons' report is not the cartridge's"
type: bug
status: testing
assignee: taro
agents: [calandria]
author: calandria
links:
  found-in: [one-advocate-command]
  part-of: [one-advocate-command]
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

### 2026-11-25, Hornero: promoted to `todo`

Promoted by Hornero: measured on The Frozen World (22 commands against
18), the fix is not in doubt —the dump with the project's common events—,
and nothing seen or heard changes. It goes with step 4 of
`one-advocate-command`.

### 2026-11-25, Calandria: fixed with step 4

`just culprits` (`game.just`) no longer runs the event compiler: it builds
the cartridge if it is stale and prints the table of the `culprits.json`
the build left beside the ROM —`culprits.py`, at the root of the ports,
which is the table `rm2k-snes-events culprits` printed—. The build judges
the dump it compiled, the fork with the project's common events.

Checked on The Frozen World, ports branch `calandria-step4`: the build's
`culprits.json` has 18 rows in `commands.commons`, and
`rm2k-snes-events culprits --every-map --data data` over the same request
22, the four the game's original common events use and the project's
replace; the printed table is the same for both, since it shows only the
commands that leave a page out or are skipped, and none of the four does.
ABL's table, through the new recipe, equal to the old one's.
