---
name: "ChangeMapTileset is not done"
description: "The command is dropped since 2026-10-16: the map keeps its ChipSet. Frozen World's frozen bazaar and temple don't show, and Vampires Dawn's bat would keep the ground's passability"
type: feature
game: [frozen-world, vampires-dawn]
status: testing
assignee: taro
agents: [Carpintero, Hornero, Mulita]
author: mulita
---

Seen by Mulita on 2026-10-16, with the-advocate `759aa0ba` plus branch
`mulita-changemaptileset` and the ports `4b2d41e`, in The Frozen World and
Vampires Dawn.

**What is seen**: since `changemaptileset-is-not-compiled.md`,
`ChangeMapTileset` compiles to nothing —a `tileset-not-changed` loss in
`degradations.json`— and the map keeps the ChipSet it was converted with.
In The Frozen World the bazaar (maps 9 and 149) and the temple's two
scenes (47 and 99) keep their water and waterfalls moving where the
original shows them still; map 129's swap changes only passability for a
route that walks through, and loses nothing. In Vampires Dawn the five
parallel pages that swap to the bat's ChipSet (maps 1, 28, 56, 89, 90:
same graphics, every cell open, nothing above the hero) run but do
nothing; it does not show yet because the bat itself does not compile
(`vampires-dawn-transformations-dont-compile.md`).

**What doing it costs** is measured in that task, "Phase 2": per variant,
one more conversion of the map over the same grid, and at run time a
swap of the block table, the passability, the tiles and the palettes, with
an opcode. Vampires Dawn's case alone is cheaper: every cell open, without
the drawing.

**How to see it**: `just cartridges` in `frozen-world/` and
`vampires-dawn/`, and the `tileset-not-changed` losses of
`build/release/degradations.json`; Frozen World's intro on map 9, after
the flash, with the water still in the original.

## Defined

Wishlist, on 2026-10-16, by Cardón: since `d9577293` the command is dropped and its pages
run, so nothing stops. The Frozen World shows moving water where the
original shows it still; Vampires Dawn's bat waits for
`vampires-dawn-transformations-dont-compile.md`, and when that is done
this one becomes needed for its passability.

**Done** means, per Phase 2 of `changemaptileset-is-not-compiled.md`, a
map's variants converted over its grid and swapped at run time with an
opcode, and the `tileset-not-changed` losses gone. Vampires Dawn's case
alone —every cell open, no drawing— is a smaller first piece.

## Log

### 2026-11-22, Carpintero: still so, to todo

Checked against the-advocate `0ae40e0a` and the ports `89f77b4`. The
compiler still drops it: `CHANGE_MAP_TILESET` in
`rm2k-snes/events/src/compile.rs` notes `tileset-not-changed` and
emits nothing. The `build/release/degradations.json` of that day lists
10 `tileset-not-changed` in The Frozen World, on maps 9, 47, 99, 129 and
149, and 8 in Vampires Dawn, on maps 28, 56, 89 and 90; Vampires Dawn's
map 1, which has the fifth page (event 16), has no line in either file.
Counted in the `data/` of the nine games, `ChangeMapTileset` (11710) is
in those two only, 10 each. Moved to `todo` by taro's request, with
`game: [frozen-world, vampires-dawn]`.

### 2026-11-23, Hornero: taken for Mulita, with opcode 0x5C

> ChangeMapTileset-is-not-done too?

(taro, asking whether it can run in parallel with the others.)

### 2026-11-23, Mulita: the design, and the compiler

From the-advocate `75d46e3c`, the ports `8aef866` and the book `ce517f8`, on
branches `mulita-changemaptileset-2`.

**The design**, chosen to keep the runtime small:

* **A variant is a whole map record** —`map_table`, behind the real maps— and
  an `anim_table` entry: a copy of the map's with what the ChipSet changes
  pointing to its own data (tiles, CGRAM, the layer above, the animation, the
  grid with its block table and passability, the terrain). Swapping it in is
  setting `map_ofs` to it, so everything that reads the record —the
  window's strips, `back_from_battle`, `back_to_map`, the animation— follows
  without knowing.
* **The grid is shared**: the converter asks Wally for the map once per
  ChipSet (a `chipset` in the request) and numbers the blocks by every
  conversion at once —a cell's block is the tuple of its blocks under each—,
  so the block table has the same size and lands in the same place behind
  the grid, and the bytecode behind it does not move.
* **The swap** decompresses the variant's block table and passability over
  the map's (no grid, no bytecode); a variant that draws differently also
  uploads its tiles, palettes and animation and refills the window, with the
  screen off for that tick. One whose ChipSet has the same picture and
  animation —Vampires Dawn's bat, Frozen World's map 129— keeps the map's
  drawing and takes only its passability and terrain: nothing is uploaded.
* **The compiler** numbers them as the panoramas: `tilesets` per map in its
  request, own first; `OP_CHANGE_TILESET` (0x5C) carries the place. A
  command in a common event, after a jump or on a map without variants keeps
  its `tileset-not-changed`, and it is no longer an `ACCEPTED_UNDONE` debt.
  Unit test `a_tileset_change_swaps_in_a_variant_of_the_map`, red without the
  swap (`left: [0]`).

### 2026-11-23, Mulita: the converter, the runtime and what it swaps

**What came out**, with the branch's tools: Frozen World's five maps take
their variants —9 (11), 47 and 99 (14), 149 (8) drawing, 129 (25)
passability only—, with the same block count each (64, 52, 64, 17, 64);
Vampires Dawn's four in the cartridge (28, 56 → 71; 89, 90 → 92), all
passability only, 28 with one block more (233). Map 1 is not in the
cartridge. `tileset-not-changed` losses: none in either game; the test
game keeps its one, on purpose (common event 3).

**Seen**: the original under Wine (its own RPG_RT.exe) draws map 9's water
moving before the flash and still after it —two captures half a second
apart identical in the water—, and the console after the flash too. The
temple's two scenes, entered by a door and played tapping A, swap 13 → 14
→ 13 → 14 (47) and 13 → 14 (99), drawn whole; map 149 swaps under its
white flash. Captures in `/shared/captures/2026-11-23-changemaptileset/`.

**Tests**, each red first with the global tools:

* the-advocate: `a_tileset_change_swaps_in_a_variant_of_the_map` (events),
  three of `variants.rs` (the joined numbering), and the test game's map 16,
  the frost, with `test_tileset_swap.py`: Winter (ChipSet 3, ours: Exterior
  with a winter palette) draws otherwise and keeps the hedge; "Exterior
  above" draws the same and opens it; 0 puts both back. Goldens
  `frost-own`, `frost-winter`.
* the ports: `test_the_bazaar_stops_after_the_flash` in
  `test_frozen_world.py` (VRAM tiles still, the record not the map's own;
  golden `frozen-world-bazaar-stopped`) and
  `test_vampires_dawn_bat_tileset.py` (switch 29 written on map 56: every
  block open in WRAM, the screen unchanged, the walls back when off).

### 2026-11-23, Mulita: delivered, to testing

Branches `mulita-changemaptileset-2`, each with `main` merged in: the-advocate
`cab45db6`, the ports `1ed6060`, the book `e7ce232`. Opcode `0x5C`,
`OP_CHANGE_TILESET`. **Done in full**: Frozen World's five maps and Vampires
Dawn's four in the cartridge; no `tileset-not-changed` is left in either.

**To install when merging**: `wally`, `events`, `mapdata`, `convert` and
`cartridge` (the bytecode changed, and the runtime has `tileset.s`).

**Run**, with those tools and the merged trees: `just test` 29 passed;
`just test-game` 230 passed, 6 skipped; the ports' `just boot` 208 passed;
ABL's `just tests` 1692 passed, 2 skipped, no golden moved; `abl.sfc`
`5ad1913bd8c42347` (sha256, first 16). Goombario asked two things of
`tileset.s`, answered in its own commit.

**What no test covers**: the swaps of Frozen World's maps 47, 99, 149 and
129 (played once by hand, captured); a battle, a menu or a saved game with
a variant in —`back_from_battle` and `back_to_map` read the record in use,
a load comes back with the map's own—; the refusals (panorama,
substitutions, posed events, events drawn otherwise, an animation that does
not fit), which no map of the ports reaches; and Vampires Dawn's bat for
real, which does not compile yet: its test writes switch 29.
