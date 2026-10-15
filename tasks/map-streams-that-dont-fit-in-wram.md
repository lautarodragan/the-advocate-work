---
name: "A map's streams that don't fit in WRAM"
description: "A map's code (map_code) or its grid (map_cells) going over their LZ2 reserve in WRAM stops the build: it leaves out map 2 of The Frozen World and map 1 of Vampires Dawn, the world map"
type: feature
status: testing
assignee: taro
agents: [Carpintero]
---

Two maps, the same limit: the LZ2 reserve of `runtime/far_ram.s`, which
`check_streams` (`rm2k-snes/mapdata/src/materials.rs`) enforces by
stopping the build.

* **The Frozen World, map 2** ("Plate Placement"): "a stream of map_code
  is 38179 bytes and 19968 fit in WRAM". Measured by Calandria on 2026-10-11
  (`exclusions-left-over-in-the-ports.md`) and **checked today**
  (the-advocate `fc6f7456`, ports `a85b7e3`): with 2 brought back, `just
  cartuchos release` in `frozen-world/` stops there. According to the re-sweep of
  2026-10-10, map 1 of the same game asks for 1.8 MB of code alone.
* **Vampires Dawn, map 1** ("Weltkarte", the world map, 300x300):
  "a stream of map_cells is 147232 bytes and 32768 fit in WRAM". Measured by
  Aguará on 2026-10-11 (`vampires-dawn-builds-from-its-toml.md`); the
  comment of `excluded` in `vampires-dawn/rm2k-snes.toml` says so. Not
  checked today (VD takes about two minutes to build). Before, it stopped at
  the ChipSet's animation, which now degrades
  (`tile-animations-that-dont-fit-in-wram.md`: "the grid: 180,000 bytes
  against 64 KB of WRAM").

Tile animations, which had the same kind of limit, now degrade
(the ones that don't fit stay still); the code and the grid have nothing
to lose without changing what the map does.

**What is seen when playing**: those maps aren't in the cartridge, and an event that
leads to them loses the whole page (a `Teleport` to a map that isn't
there doesn't compile). In Vampires Dawn it's the world: it wasn't looked at how far
it can be played without it.

**How to see it**: remove the map from `excluded` in the game's `rm2k-snes.toml`
and `just cartridges release` in its directory.

**What map 2 is** (Calandria, 2026-10-14, the-advocate `14e200fc`, ports
`f775b66`; [research](https://lautarodragan.github.io/the-advocate-docs/progress/book-of-three-and-frozen-world.html)):
Frozen World's "Plate Placement" is part of the game's combat (51 events,
12,225 commands; no `EnemyEncounter` in the game). The stop was run again
today with only map 2 brought back: the same message, 38179 bytes against
19968.

## Done: the code of a map that doesn't fit stays in the cartridge (Carpintero, 2026-10-15)

On top of Hurón's `huron-tp` merged with main (the-advocate `978c0d25`,
ports `08551c6`, docs `huron-tp`), branches `carpintero-rom-code` in the
three repos.

**What**: `code_in_rom` in `rm2k-snes/mapdata/src/record.rs`. A map whose
bytecode is over `LZ2_CAP_CODE` (19,968), or over what the grid and the
block table leave of `$7F`'s upper half, keeps it in the cartridge,
uncompressed, in `.block`s of up to a bank cut where a page or a route
starts (`rom_code_chunks`); its page table points there, and its
`map_code` entry names an empty LZ2 stream with length 0.

**The runtime does not change** (only two comments in `decompress.s`):
the interpreter, `op_route`, `route_for_event` and the battle animation
take the bank from `code_ptr`; `carry_one` already leaves a pointer
outside `$7F` alone, which is right for code that doesn't move; the empty
stream makes `lz2_grid` write nothing, and the length 0 keeps `carry_one`
from taking a `CODE_CARRY` pointer as one of this map's. Shared bodies
(`OP_CALL`) live in ROM already; parallel pages and event routes restart
with the map; saves store no code position. Cross-map sharing: by whole
block, through `Materials::store`; per page across maps, not done (it
would need a block per page).

**Threshold: only the maps that don't fit.** All maps in ROM would cost
A Blurred Line ~68 KB more (code 168.3 KB raw against 100.5 KB of LZ2,
from its `converter.log`) to save decompressing at most 12.7 KB on a load
(its biggest map, map 0 of the cartridge; the rest are under 11 KB, most
under 1 KB). It would also free `CODE_CARRY` and the carry code, but it
moves ABL's ROM and every load's timing. With the threshold every map
that fits emits byte for byte what it did.

**Measured, Frozen World**, with the branch's tools:

* map 3 (29,365 bytes): in the cartridge; `release` builds.
* map 2 (38,179 per the old message): **builds**, and came back in the
  ports' toml (its own commit). 20 warnings of route graphic changes
  past the ROM's table of 8: draft
  `frozen-world-map-2-route-graphic-changes-past-the-table`.
* map 1: its bytecode is now **347,625 bytes** (not 1.8 MB: calls and the
  dedup of pages since), which goes in six blocks of up to a bank; the
  flash no longer stops it (Hurón). It stops next at the audio: "the
  samples of 1 (30546 of -25987 B) do not fit in the ARAM even at the
  minimum": draft `frozen-world-map-1-audio-package-does-not-fit-in-aram`.
  So the draft `flashing-hero-shares-a-palette-with-an-npc` no longer
  describes what stops map 1.

**Verified**:

* `just crate-test mapdata`, with a new unit test; `just test` (27);
  `just rust-test` (all green).
* ABL's `abl.sfc` with the branch's tools is **byte for byte** the one
  built with the branch's base tools (sha256 `b74fc192…`). (Against the
  `abl.sfc` in `~/the-advocate-ports` it differs: that one is older.)
* ABL's `just tests`: 1548 passed, 2 skipped.
* `just boot` in the ports: 22 passed, with map 3 in (before bringing map
  2 back); again with map 2 in, `-k "frozen or code_in_rom"`.
* `tests/test_code_in_rom.py` in the ports, red before (the build stops at
  map 3's stream, with the base tools) and green after: a plate on map 3
  pressed, its message opens, `code_ptr` in bank `$C3`; and map 2's
  parallel page turns switch 186 off.

**Not covered**: a page of a ROM map that keeps running after a
`Teleport` (no test teleports out of a page of map 2 or 3 and goes on);
a map whose code goes in more than one block runs in no test (map 1
doesn't build); bsnes doesn't run `test_code_in_rom.py`. ABL's
`test_decompressed_load.py` would fail on a ROM map (it expects the code
behind the grid), but ABL has none.

**To install when merging**: `mapdata` and `convert` (convert compiles
mapdata in), plus `events` and `convert` from `huron-tp`.

**Not done: the grid** (`map_cells`, Vampires Dawn's map 1, 147,232 bytes
against 64 KB of WRAM): this assignment was the code only. The grid is
read through `ptr_more`/`ptr_minus` across two WRAM halves, so the same
trick does not apply as is.
