---
name: "Nothing caps the actor count against FAR_HP and FAR_SP"
description: "FAR_HP and FAR_SP are 128 B apart and FAR_EQUIPMENT has 752 B, so a game with more than 64 LDB actors has its HP table run into its SP table with no assert on either side; ABL has 61"
type: bug
status: testing
assignee: taro
agents: [Hurón]
---

Seen by Hurón on 2026-10-15, in the study
[`the-wram-and-sram-map-measured`](the-wram-and-sram-map-measured.md),
with the-advocate `6fa69781` and the ports at `f015801`.

**What happens**: `FAR_HP` is at `$7E3700` and `FAR_SP` at `$7E3780`, a
word per LDB actor each (`runtime/far_ram.s`); `FAR_ACTOR_GFX` follows at
`$7E3800` and `FAR_EQUIPMENT` has `$7E2C00`–`$7E2EEF` for ten bytes per
actor. So the map holds 64 actors in the HP and SP tables and 75 in the
equipment's, and **nothing asserts it**: `grep` finds no `.assert` on
`ACTORS_N` in the runtime, and the converter emits `ACTORS_N` from the
LDB's actor count without a cap (`rm2k-snes/mapdata/src/emit.rs`). ABL has
61 actors, 122 of the 128 bytes.

**How to reproduce**: a game whose LDB has 65 actors or more. None of the
eight ports has; a copy of ABL's LDB with four actors appended would.

**What to decide**: an `.assert ACTORS_N * 2 <= FAR_SP - FAR_HP` next to
the two tables and one for the equipment, so the build stops; or sizing
the tables by the game, which is what letting the linker place the far RAM
map does (the study's first suggestion).

## Done (Hurón, 2026-10-16)

Fell out of [letting the linker place far RAM](let-the-linker-place-the-far-ram-map.md):
`FAR_EQUIPMENT`, `FAR_HP`, `FAR_SP` and `FAR_ACTOR_GFX` are a `.res` each in
`runtime/far_ram_game.s`, sized `ACTORS_N * 10`, `* 2`, `* 2` and `* 1`
after the cartridge's `.inc`, so no number of actors can run one table into
the next. What still caps them is that an actor number is a byte
everywhere, so the build stops with `.assert ACTORS_N <= 256` (the-advocate
`762f7f92`). ABL's `test_wram_reservations.py::test_the_actors_tables_are_the_games_size`
checks the four sizes per cartridge; it was red on the relocation alone
(61 actors, tables of 752, 128, 128 and 256 B) and replaces the old
`test_sprite_actor.py` check that `FAR_ACTOR_GFX` ended before the battle,
which only made sense while both were placed by hand (the ports `d8ced42`).

To install when merging: `cartridge`, with the far RAM task.
