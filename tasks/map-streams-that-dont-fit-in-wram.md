---
name: "A map's streams that don't fit in WRAM"
description: "A map's code (map_code) or its grid (map_cells) going over their LZ2 reserve in WRAM stops the build: it leaves out map 2 of The Frozen World and map 1 of Vampires Dawn, the world map"
type: feature
status: draft
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
